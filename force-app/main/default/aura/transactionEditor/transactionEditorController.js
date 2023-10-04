/* eslint-disable no-console */
({
    doInit: function(cmp,evt,hlp){
        const currUrl = window.location.href;
        const splitValues = currUrl.split("#");
        let retValue =  "/index.html";
        if(splitValues.length > 1) {
            retValue = "/index.html" + '#' + splitValues[1];
        }
    	cmp.set("v.url_path", retValue);
  	},
    
    onUsageLibLoaded: function(cmp) {
        console.log("Usage Lib Loaded");
    },
    
    handleMessage: function(component, message, helper) {
        var params = JSON.parse(JSON.stringify(message._params));
        var payload  = params.payload;
        var entityType = payload.entityType, 
        recordId = payload.recordId, 
        objectName = payload.objectName, 
        sourceObject = payload.sourceObject, 
        headerObject = payload.headerObject, 
        isHeaderObjectField = payload.isHeaderObjectField, 
        objectLabel = payload.objectLabel;

        var isValueMapping = entityType === "VALUEMAPPING";
        var isFieldMapping = entityType === "FIELDMAPPING";
        var isLookupConfig = entityType === "LOOKUPCONFIG";
        var isExpression = entityType === "EXPRESSION";
        var isVisibilityCriteria = entityType === "VISIBILITY_CRITERIA";
        var isConfigurationFilter = entityType === "CONFIGURATION_FILTER";
        var isWizard = entityType === "WIZARD";
        if (isLookupConfig || isFieldMapping || isValueMapping || isExpression || 
            isVisibilityCriteria || isWizard || isConfigurationFilter) {
            var navService = component.find("navService");
            var pageReference;
            if(isLookupConfig) {
                pageReference = {
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: "SVMXA360__setupHome"
                    },
                    state: {
                        c__objectName : objectName,
                        c__recordId : recordId,
                        c__isLookupEditor : true,
                        c__headerObjectAPIName : headerObject,
                        c__isHeaderObjectField : isHeaderObjectField,
                    }
                };
            }

            if(isWizard) {
                pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: "SVMXA360__wizardDetail"
                    },
                    state: {
                        c__actionName : "view",
                        c__objectName : objectName,
                        c__objectLabel : objectLabel,
                        c__currentItem :"service_wizards"
                    }
                };
            }
            
            if(isValueMapping || isFieldMapping) {
                pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: "SVMXA360__mappingDetail"
                    },
                    state: {
                        c__actionName : recordId ? "edit" : "new",
                        c__mappingType : isValueMapping ? "Value Mapping": "Field Mapping",
                        c__target: objectName,
                        c__currentItem: "mapping_rules",
                        c__recordId : recordId,
                        c__source: isFieldMapping ? sourceObject : null,
                    }
                };
            }
            
            if(isExpression || isVisibilityCriteria || isConfigurationFilter) {
                pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: "SVMXA360__expressionDetail"
                    },
                    state: {
                        c__actionName : recordId ? "edit" : "new",
                        c__objectName: objectName,
                        c__currentItem: "expression_builder",
                        c__recordId : recordId,
                    }
                };
                if (isVisibilityCriteria) {
                    pageReference['state']['c__expressionType'] = "visibility_criteria";
                }
                if (isConfigurationFilter) {
                    pageReference['state']['c__expressionType'] = "configuration_filter";
                }
            }
       
            if(navService){
                navService.generateUrl(pageReference)
                .then($A.getCallback(function(url) {
                        window.open(url);
                    }), $A.getCallback(function(error) {
                        //handle error
                    })
                );
            }
        }

        if (entityType === "GET_APP_INFO") {
            var userTimeFormat = $A.get("$Locale.timeFormat");
            var appInfo = {
                identityKey : entityType,
                data : {
                    screenType: "Transaction",
                	timeFormat: userTimeFormat,
                }
            };
            component.find("FSLMAX_LayoutEditor").message(appInfo);
        }

        if (entityType === "REFRESH_URL") {
            const currUrl = window.location.href;
            const splitValues = currUrl.split("#");
            if(splitValues.length > 1) {
                const url = splitValues[0];
                const urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": url,
                });
                urlEvent.fire();
            }
        }
        
         if (entityType === "FORMAT_DATE_TIME_FOR_LIST_VIEW" || entityType === "FORMAT_DATE_TIME_FOR_MODAL_VIEW") {
            let layoutList = payload.data || [];
            const sfLocaleInfo = $A.get("$Locale");
            const { userLocaleLang, shortDatetimeFormat, timezone } = sfLocaleInfo;
            layoutList = layoutList.map((layoutItem) => {
                 
                 let { lastModifiedDate } = layoutItem;
                 const dateTimeObj = $A.localizationService.parseDateTimeUTC(lastModifiedDate);
                 $A.localizationService.UTCToWallTime(dateTimeObj, timezone, function(walltime) {
                     lastModifiedDate = $A.localizationService.formatDateTimeUTC(walltime,shortDatetimeFormat, userLocaleLang);
                 });
                 const updatedItem = Object.assign({},layoutItem);
             	 updatedItem.lastModifiedDate = lastModifiedDate;
             	 return updatedItem;
             });
            component.find("FSLMAX_LayoutEditor").message({
                identityKey: entityType,
                data: layoutList,
            });
        }
    },

    handleError: function(component, event, helper) {
        var error = event.getParams();
    }
});
/* eslint-enable */