({
    navigateRecord: function (cmp,redirectRecordId) {
        var navService = cmp.find('navService');
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: redirectRecordId,
                actionName: 'view',
                nooverride : new Date().getTime()
            }
        };
        if(cmp.get('v.noRedirect')) {
            var workspaceAPI = cmp.find("workspace");
            workspaceAPI.isConsoleNavigation().then(function(response) {
                if (response === true){
                    navService.navigate(pageReference);
                } else {
                    navService.generateUrl (pageReference)
                        .then($A.getCallback(function(url) {
                                window.open(url);
                            }), $A.getCallback(function(error) {
                                console.error(error);
                            })
                        );
                }
            });
              
        } else {
            navService.navigate(pageReference);
        }
       
    },
    
    processInlineNavigation: function (cmp, redirectRecordId) {
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response === true){
                workspaceAPI.getFocusedTabInfo().then(function(workspaceResponse) {
                    var focusedTabId = workspaceResponse.tabId;
                    cmp.set('v.currTabId', focusedTabId);
                    var navService = cmp.find('navService');
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: redirectRecordId,
                            actionName: 'view',
                            nooverride : new Date().getTime()
                        }
                    };
                    navService.generateUrl(pageReference)
                        .then($A.getCallback(function(url) {
                            var currWorkspaceAPI = cmp.find("workspace");
                            currWorkspaceAPI.closeTab({tabId: cmp.set('v.currTabId')});
                            window.location.replace(url);
                        }), $A.getCallback(function(error) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                "message": error,
                                type: 'error'
                            });
                            toastEvent.fire();
                        }));
                });
            }
        });
    },
    
    processTabNavigation: function (cmp, objId){
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response === true){
                workspaceAPI.getFocusedTabInfo().then(function(workspaceResponse) {
                    var focusedTabId = workspaceResponse.tabId;
                    cmp.set('v.currTabId', focusedTabId);
                    var navService = cmp.find('navService');
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: objId,
                            actionName: 'view',
                            nooverride : new Date().getTime()
                        }
                    };
                    navService.navigate(pageReference);
                    window.setTimeout(
                        $A.getCallback(function() {
                            var currWorkspaceAPI = cmp.find("workspace");
                            currWorkspaceAPI.closeTab({tabId: cmp.get('v.currTabId')});
                        }), 500
                    );                    
                });                
            } else {
                var navService = cmp.find('navService');
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: objId,
                        actionName: 'view',
                        nooverride : new Date().getTime()
                    }
                };
                navService.navigate(pageReference);
            }
        });
    },

    invokeRecordAction: function(cmp,event){
        var action = cmp.get("c.invokeRecordAction");
        action.setParams({ 
            actionName : cmp.get("v.actionName"),
            wizardStepId: cmp.get("v.stepId"),
            recordId: cmp.get('v.recordId') });
        action.setCallback(this, function(response) {
            try {
                var state = response.getState();
                var data = response.getReturnValue();
                cmp.set("v.showProgress",false);
                cmp.set('v.isOpen', false);
                if (state === "SUCCESS" &&  data.success) {
                    $A.get('e.force:refreshView').fire();
                    var successMsg = $A.get("$Label.c.Messge_TransactionSaved");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"success",
                        "message": successMsg
                    });
                    toastEvent.fire();
                }
                else if (state === "ERROR" || !data.success) {
                    var errorMsg = '';
                    if (data.message){
                        errorMsg = data.message;
                    }
                    if (data.error && data.error.length > 0) {
                        errorMsg = data.error[0].message;
                    }

                    var errToastEvent = $A.get("e.force:showToast");
                    errToastEvent.setParams({
                        "type": "error",
                        "message": errorMsg,
                        "mode":"sticky"
                    });
                    errToastEvent.fire();
                }        
            } catch(error) {
                var errToastEvent = $A.get("e.force:showToast");
                errToastEvent.setParams({
                    "type": "error",
                    "message": error,
                    "mode":"sticky"
                });
                errToastEvent.fire();
            } finally {
                cmp.set('v.isOpen', false);
            }
            
        });
        $A.enqueueAction(action);
    },

    closeTabOnConsoleNavigation: function(cmp){
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response === true){
                workspaceAPI.getFocusedTabInfo().then(function(workspaceResponse) {
                    var focusedTabId = workspaceResponse.tabId;
                    cmp.set('v.currTabId', focusedTabId);
                    window.setTimeout(
                        $A.getCallback(function() {
                            var currWorkspaceAPI = cmp.find("workspace");
                            currWorkspaceAPI.closeTab({tabId: cmp.get('v.currTabId')});
                        }), 500
                    );                    
                });                
            }
        });
    },

    showtoast: function() {
        var successMsg = $A.get("$Label.c.Messge_TransactionSaved")
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "message": successMsg
        });
        toastEvent.fire();
    },

    setOverflow: function (visiblity) {
        document.body.style.overflow = visiblity;
    },

    invokeURLAction: function (cmp) {
        var urlPath = cmp.get('v.actionName');
        var mapping = JSON.parse(cmp.get('v.mapping'));
        var urlParamsstr = Object.keys(mapping).map(function(key) {
            return encodeURIComponent(key) + '=' + encodeURIComponent(mapping[key]);
        }).join('&');
        if (urlParamsstr) {
            urlPath +='?'+ urlParamsstr ;
        }
        cmp.set("v.urlPath",urlPath);
        var customLabels = urlPath.match(/{\$\w*\.\w*\.\w*}/gm);
        if (customLabels && customLabels.length > 0) {
            var label = customLabels[0].replace('{','').replace('}','');
            var isError = false;
            cmp.get('v.erroredCustomLabelList').forEach( erroredLabel => {
                  if (erroredLabel.toUpperCase().includes(label.toUpperCase())){
                      cmp.set("v.showProgress",false);
                      cmp.set('v.isOpen', false);
                      var errToastEvent = $A.get("e.force:showToast");
                      errToastEvent.setParams({
                          "type": "error",
                          "message": $A.get("$Label.c.Error_PageNotExists"),
                          "mode":"sticky"
                      });
                      errToastEvent.fire();
                      isError = true;
                  }
              });
              if(!isError){
                  var translatedDomainName = $A.getReference(label);
                cmp.set("v.domainName", translatedDomainName);
              }
        } else {
            this.launchURL (cmp,urlPath);
        }
    },

    launchURL: function(cmp, url) {
        var currURL = `${window.location.protocol}//${window.location.hostname}`;
        if (url.startsWith(currURL)) {
            url = url.substring(currURL.length);
        } 

        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response === true){
                workspaceAPI.getFocusedTabInfo().then(function(workspaceResponse) {
                    var focusedTabId = workspaceResponse.tabId;
                    cmp.set('v.currTabId', focusedTabId);
                    window.setTimeout(
                        $A.getCallback(function() {
                            location.assign(url);
                        }), 12
                    ); 
                    window.setTimeout(
                        $A.getCallback(function() {
                            var currWorkspaceAPI = cmp.find("workspace");
                            currWorkspaceAPI.closeTab({tabId: cmp.get('v.currTabId')});
                        }), 10
                    );                    
                });                
            } else {
                if(cmp.get('v.OpenAsModal') === 'MODAL'){
                    cmp.set("v.showProgress",false);
                    cmp.set('v.isOpen', false);
                    window.open(url);
                }else{
                    location.assign(url);
                }
            }
        });
    },

    isMobileDevice: function() {
        var device = $A.get("$Browser.formFactor");
        return device === 'TABLET' || device === 'PHONE';
    }
})