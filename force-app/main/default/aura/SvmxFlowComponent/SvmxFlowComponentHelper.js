({
    launchAction: function (cmp) {
        var flowComp = cmp.find('flowData');
        if (flowComp) {
            flowComp.destroy();
        }
        cmp.set("v.showError",false);
        cmp.set("v.errorMessage",null);
        var attributes = {};
        attributes["aura:id"] =  "flowData";
        attributes["onstatuschange"] =  cmp.getReference("c.handleStatusChange");
        attributes["isInModal"] =  cmp.get("v.isInModal");
        attributes["recordId"] =  cmp.get("v.objRecordId");
        if (cmp.get("v.actionType") === 'SPM Transaction') {
            attributes["stepCompletionEnabled"] = cmp.get("v.stepCompletionEnabled");
            attributes["stepComplete"] = cmp.get("v.stepComplete");
            attributes["stepId"] = cmp.get("v.stepId");
        }
        var mappingObj = JSON.parse(cmp.get("v.mapping"));
        for (var prop in mappingObj) {
            if (mappingObj.hasOwnProperty(prop)) {
                try{
                    attributes[prop] = JSON.parse(mappingObj[prop]);
                }catch(error){
                    attributes[prop] = mappingObj[prop];
                }
            }
        }
        $A.createComponent(
            cmp.get('v.actionType') === "Flow" 
            ? "lightning:flow"
            : cmp.get('v.actionName'),
            attributes,
            function (flow, status, errorMessage) {
                if (status === "SUCCESS") {
                    cmp.set("v.body", []);
                    var body = cmp.get("v.body");
                    body.push(flow);
                    cmp.set("v.body", body);
                    if (cmp.get('v.actionName') && cmp.get('v.actionType') === 'Flow') {
                        var flowInputVariables = [
                            {
                                name: 'recordId',
                                type: 'String',
                                value: cmp.get('v.objRecordId'),
                            }
                        ];
                        flow.startFlow(cmp.get('v.actionName'), flowInputVariables);
                    }
                }
                if(errorMessage){
                    cmp.set("v.showError",true);
                    cmp.set("v.errorMessage",errorMessage);
                    var compEvent = cmp.getEvent("flowStatusEvent");
                    if(compEvent){
                        compEvent.setParams({ "showError": cmp.get("v.showError") });
                        compEvent.fire();
                    }
                }
            }
        )
        this.publishUsageData(cmp, 'STARTED');
    },
    
    handleFlowStatusChange: function (cmp, event) {
        var fireEvent = false;
        var statusVal = event.getParam('status').toUpperCase();
        var showToastVal = event.getParam('showToast');
        if (statusVal === 'FINISHED' 
            || statusVal === 'FINISHED_SCREEN' 
            || statusVal === 'CANCELLED') {
            var flowComp = cmp.find('flowData');
            if (flowComp) {
                flowComp.destroy();
            }
            var outputVariables = event.getParam('outputVariables');
            if (outputVariables && outputVariables.length > 0) {
                var itemIndex = outputVariables.findIndex(function(item) { 
                    return item.name === 'redirect_recordId'
                });
                if (itemIndex > -1) {
                    cmp.set("v.redirectRecordId", outputVariables[itemIndex].value
                    ? outputVariables[itemIndex].value
                    : cmp.get('v.objRecordId') );
                } else{
                    cmp.set("v.redirectRecordId", cmp.get('v.objRecordId'));
                }
            } else{
                cmp.set("v.redirectRecordId", cmp.get('v.objRecordId'));
            }
            cmp.set("v.showError", false);
            fireEvent = true;
            this.publishUsageData(cmp, statusVal);
        } else if (statusVal === 'ERROR') {
            fireEvent = true;
            this.publishUsageData(cmp, statusVal);
            cmp.set("v.showError", true);
        }
        if (fireEvent) {
            var compEvent = cmp.getEvent("flowStatusEvent");
            compEvent.setParams({ "status": statusVal });
            compEvent.setParams({ "redirectRecordId": cmp.get("v.redirectRecordId") });
            compEvent.setParams({ "showError": cmp.get("v.showError") });
            compEvent.setParams({ "showToast": showToastVal });
            compEvent.setParams({ "actionType" : cmp.get('v.actionType') });
            compEvent.fire();
        }
    },
    
    destroyComponent: function (cmp, event) {
        var flowComp = cmp.find('flowData');
        if (flowComp) {
            flowComp.destroy();
        }
    },
    
    publishUsageData: function(cmp, statusVal){
        const uniqueId = cmp.get("v.uniqueStepGuid");
        const isTrackingOn = cmp.get("v.isTrackingOn");
        if(uniqueId && isTrackingOn){
            const action = cmp.get('c.publishUsageData');
            let requestJson = {};
            requestJson.uniqueId= uniqueId;
            if(statusVal === 'STARTED'){
                requestJson.actionDeveloperName= cmp.get("v.actionName")
                requestJson.actionName= cmp.get("v.stepName");
                requestJson.appName='Wizard';
                requestJson.actionRecordId= cmp.get("v.stepId");
                requestJson.objectApiName= cmp.get("v.objectApiName");
                requestJson.sourceRecordId= cmp.get("v.objRecordId");
                requestJson.epochStartTime= Date.now();
            }else{
                requestJson.status= statusVal;
                requestJson.epochEndTime= Date.now();
            }
            action.setParams({requestJson: JSON.stringify(requestJson)});
            
            action.setCallback(this, function(response) {
                const state = response.getState();
                if(state != 'SUCCESS'){
                    console.error(`Failed to publish usage data.`);
                }
            });
            $A.enqueueAction(action);
        }        
    }
})