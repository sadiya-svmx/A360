({
    init: function (cmp, event, helper) {
        var myPageRef = cmp.get('v.pageReference');
        if (myPageRef) {
            cmp.set('v.showClose', false);
            if(cmp.get("v.isOpen") && myPageRef.state.c__actionType !== 'Flow'){
                cmp.set("v.isOpen", false);
            }
            cmp.set('v.recordId', myPageRef.state.c__objectRecordId);
            cmp.set('v.stepId', myPageRef.state.c__stepId);
            cmp.set('v.uniqueStepGuid', myPageRef.state.c__uniqueStepGuid);
            cmp.set('v.objectApiName', myPageRef.state.c__objectApiName);
            cmp.set('v.isTrackingOn', myPageRef.state.c__isTrackingOn);
            cmp.set('v.actionName', myPageRef.state.c__actionName);
            cmp.set('v.actionType', myPageRef.state.c__actionType);
            cmp.set('v.mapping', myPageRef.state.c__mapping);
            cmp.set('v.stepName', myPageRef.state.c__wizardStepName);
            cmp.set('v.stepIcon', myPageRef.state.c__wizardStepIcon);
            cmp.set('v.stepComplete', myPageRef.state.c__stepComplete);
            cmp.set('v.stepCompletionEnabled', myPageRef.state.c__stepCompletionEnabled);
            var openAsModal;
            switch(typeof myPageRef.state.c__OpenAsModal){
                case 'string':
                    try{
                        openAsModal = JSON.parse(myPageRef.state.c__OpenAsModal.toLowerCase());   
                    }catch(exception){
                        openAsModal = false;
                    }
                    break;
                case 'boolean':                    
                    openAsModal = myPageRef.state.c__OpenAsModal;
                    break;
                case 'undefined':
                    openAsModal = false;
                    break;
                default:
                    openAsModal = false;
                    break;
            }
            if (myPageRef.state.c__actionType === 'url'){
                helper.invokeURLAction(cmp);
                return;
            }
            cmp.set("v.OpenAsModal", openAsModal);
            cmp.set("v.uid", new Date().getTime());
            cmp.set("v.isOpen", true);
        }
    },
    
    onTabFocused: function (cmp,event,helper){
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response === true ){
                var focusedTabInfo = workspaceAPI.getFocusedTabInfo();
                if (focusedTabInfo) {
                    focusedTabInfo.then(function(tabDetail) {
                        if(tabDetail.pageReference &&
                           tabDetail.pageReference.state &&
                           tabDetail.pageReference.state.c__wizardStepName){
                            var focusedTabId = tabDetail.tabId;
                            workspaceAPI.setTabLabel({
                                tabId: focusedTabId,
                                label: tabDetail.pageReference.state.c__wizardStepName
                            });
                            workspaceAPI.setTabIcon({
                                tabId: focusedTabId,
                                icon: tabDetail.pageReference.state.c__wizardStepIcon,
                                iconAlt: "action"
                            });
                        }
                    });    
                }
            }
        });
    
    },

    closeModel: function (cmp, event, helper) {
        if (cmp.get('v.OpenAsModal')) {
            cmp.set('v.isOpen', false);
        } else {
            helper.processTabNavigation(cmp, cmp.get('v.recordId'));
        }
        helper.setOverflow('visible');
        window.removeEventListener('popstate', helper.setOverflow);
    },

    handleStatusChange: function (cmp, event, helper) {
        if (event.getParam('showError') === true) {
            cmp.set('v.showClose', true);
        } else {
            if (cmp.get('v.OpenAsModal')) {
                helper.setOverflow('visible');
                window.removeEventListener('popstate', helper.setOverflow);
                if(cmp.get("v.noRedirect")){
                    cmp.find("refreshMessageChannel").publish({
                        source: 'c:SvmxFlowLauncher',
                        sourceId: event.getParam('redirectRecordId')
                    });
                }
                if (event.getParam('status') !== 'CANCELLED'
                    && event.getParam('actionType') !== 'Flow'
                    && event.getParam('showToast')) {
                    helper.showtoast();
                }
                if (event.getParam('redirectRecordId') === cmp.get('v.recordId') ) {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.navigateRecord(cmp, event.getParam('redirectRecordId'));
                }
            } else {
                if (event.getParam('status') !== 'CANCELLED'
                        && event.getParam('actionType') !== "Flow"
                        && event.getParam('showToast')) {
                    helper.showtoast();
                }
                if (event.getParam('status') === 'FINISHED_SCREEN' 
                        || event.getParam('status') === 'FINISHED'
                        || event.getParam('status') === 'CANCELLED'
                        || event.getParam('actionType') === 'Flow') {
                    helper.processTabNavigation(cmp, event.getParam('redirectRecordId'));
                }
            }
            cmp.set('v.isOpen', false); 
        }
    },

    launchActioninModal: function (cmp, event, helper) {
        cmp.set("v.isStaticAction", false);
        var params = event.getParam("arguments").eventMsg;
        var actionName = params.c__actionName;
        var recordId = params.c__objectRecordId;
        var actionType = params.c__actionType;
        var mapping = params.c__mapping;
        if (actionName && recordId) {
            var flowComp = cmp.find('flowData');
            if (flowComp) {
                flowComp.destroy();
            }
            cmp.set('v.showClose', false);
            cmp.set("v.recordId", recordId);
            cmp.set("v.actionName", actionName);
            cmp.set("v.mapping", mapping);
            cmp.set("v.actionType", actionType);
            cmp.set("v.OpenAsModal", "MODAL");
            cmp.set('v.stepName', params.c__wizardStepName);
            cmp.set('v.stepIcon', params.c__wizardStepIcon);
            cmp.set('v.stepId', params.c__stepId);
            cmp.set('v.uniqueStepGuid', params.c__uniqueStepGuid);
            cmp.set('v.objectApiName', params.c__objectApiName);
            cmp.set('v.isTrackingOn', params.c__isTrackingOn);
            cmp.set('v.stepComplete', params.c__stepComplete);
            cmp.set('v.stepCompletionEnabled', params.c__stepCompletionEnabled);
            var modalClasses = [
                'slds-modal',
                'slds-fade-in-open'               
            ];
            if(actionType === 'Record Action' 
                || actionType === 'url'){
                modalClasses.push('slds-modal_small');
            } else {
                modalClasses.push('slds-modal_large');
            }
            cmp.set('v.computedClassName', modalClasses.join(" "));
            if (helper.isMobileDevice())
                cmp.set('v.computedContainerClassName', "svmx-mobile-container slds-modal__container");
            else 
                cmp.set('v.computedContainerClassName', "svmx-modal-container slds-modal__container");
            var modalContainerClasses = ['slds-modal__content'];

            if (helper.isMobileDevice()) {
                modalContainerClasses.push('slds-var-p-around_small');
            } else {
                modalContainerClasses.push(...[
                    'slds-var-p-around_medium',
                    'slds-p-bottom_none',
                    'slds-p-left_none',
                    'slds-p-right_none',
                ]);
            }

            if(actionType === 'Record Action' 
                || actionType === 'url'){
                modalContainerClasses.push('svmx-modal-min-height');
            }
            cmp.set('v.computedContainerContentClassName', modalContainerClasses.join(" "));
            if (actionType === 'Record Action'){
                cmp.set("v.isStaticAction", true);
                cmp.set("v.isRecordAction", true);
                cmp.set("v.showProgress", true);
                cmp.set("v.isOpen", true);
                
                helper.invokeRecordAction(cmp,event);
            }else if (actionType === 'url'){
                cmp.set("v.isStaticAction", true);
                cmp.set("v.showProgress", true);
                cmp.set("v.isOpen", true);
                helper.invokeURLAction(cmp,event);
            } else{
                cmp.set("v.isOpen", true);
                window.addEventListener('popstate', helper.setOverflow.bind(null, 'hidden')());
            }
        }
    },

    launchURL: function(cmp, event, helper) { 
        var domainName = cmp.get("v.domainName");
        if(domainName && domainName.includes('//')){
            var urlPath = cmp.get("v.urlPath");
            var customLabels = urlPath.match(/{\$\w*\.\w*\.\w*}/gm);
            if(customLabels && customLabels.length > 0) {
                urlPath = urlPath.replace(customLabels[0], domainName);
                helper.launchURL (cmp,urlPath);
            }
        }else if(domainName.includes('$')){
            cmp.get('v.erroredCustomLabelList').push(domainName);
            cmp.set("v.showProgress",false);
            cmp.set('v.isOpen', false);
            var errToastEvent = $A.get("e.force:showToast");
            errToastEvent.setParams({
                "type": "error",
                "message": $A.get("$Label.c.Error_PageNotExists"),
                "mode":"sticky"
            });
            errToastEvent.fire();
        }
    }
});