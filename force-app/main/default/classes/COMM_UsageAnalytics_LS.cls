/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 * @brief A class which provides usage analytics methods to retrieve analytics data
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna Nagapudi      19 Jan 2022      Created.
 *****************************************************************************************************/
public with sharing class COMM_UsageAnalytics_LS {

    /**
     * A public wrapper variable.
     */
    public static Common.UsageAnalytics usageAnalytics = new Common.UsageAnalytics();


    public static Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = new Map<String, Schema.DescribeSobjectResult>();

    /**
    * This method generate input for transaction usage analytics.
    */
    @AuraEnabled
    public static Common.ServiceResponse generateTransactionUsageAnalytics( String requestJson ) {

        Common.UsageAnalytics usageAnalyticsInput = (Common.UsageAnalytics) JSON.deserializeStrict( requestJson, Common.UsageAnalytics.class );

        System.debug( LoggingLevel.DEBUG, 'generateTransactionUsageAnalytics() - enter; usageAnalyticsInput= ' + usageAnalyticsInput );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {

            // Verify for valid layout developerName
            if( usageAnalyticsInput == null || usageAnalyticsInput.layoutDeveloperName == null ) {
                
                System.debug( LoggingLevel.ERROR, 'generateTransactionUsageAnalytics() : Invalid argument; usageAnalyticsInput= ' + usageAnalyticsInput );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            usageAnalytics.eventType = 'SPMRuntime';
            usageAnalytics.Type = 'Transaction';
            usageAnalytics.dynamicSectionsCount = 0;
            usageAnalytics.autoFillMappingCount = 0;
            usageAnalytics.contextualFilterCount = 0;
            usageAnalytics.customButtonsCount = 0;
            usageAnalytics.numberOfFieldsInHeader = 0;
            usageAnalytics.numberOfFieldsInChild = 0;
            usageAnalytics.numberOfLookupsConfiguredInHeader = 0;
            usageAnalytics.numberOfLookupsConfiguredInChild = 0;
            usageAnalytics.childCount = 0;
            usageAnalytics.childObjects = '';
            usageAnalytics.wizardHandOverTime = usageAnalyticsInput.wizardHandOverTime;
            usageAnalytics.layoutLoadTime = usageAnalyticsInput.layoutLoadTime;
            usageAnalytics.layoutSaveTime = usageAnalyticsInput.layoutSaveTime;
            usageAnalytics.numberOfRecordsInChildTab = usageAnalyticsInput.numberOfRecordsInChildTab;
            usageAnalytics.numberOfRecordsAcrossChildren = usageAnalyticsInput.numberOfRecordsAcrossChildren;

            if (usageAnalyticsInput.layoutUsageType == 'TRANSACTION_RECORDPAGE') {
                usageAnalytics.layoutUsageType = 'RECORDPAGE';
            } else if (usageAnalyticsInput.layoutUsageType == 'TRANSACTION_FLOW' || usageAnalyticsInput.layoutUsageType == 'SCREEN_FLOW') {
                usageAnalytics.layoutUsageType = 'FLOW';
            } else {
                usageAnalytics.layoutUsageType = 'WIZARD';
            }

            if (usageAnalyticsInput.wizardStepId != null && usageAnalytics.layoutUsageType == 'FLOW') {
                List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList =  SvmxDatabase.query( [SELECT Id, SVMXA360__Target__c FROM SVMXA360__CONF_ProcessWizardStep__c WHERE Id = :usageAnalyticsInput.wizardStepId]); 
                usageAnalytics.flowName = wizardStepList[0].SVMXA360__Target__c;
            } else if (usageAnalytics.layoutUsageType == 'FLOW') {
                usageAnalytics.flowName = 'RECORDPAGE';
            }
            

            String orgId = UserInfo.getOrganizationId();
            String userId = orgId + '-' + UserInfo.getUserId();
            String recordId = orgId + '-' + usageAnalyticsInput.recordId;
            usageAnalytics.userId = EncodingUtil.base64Encode(Blob.valueof(userId));
            usageAnalytics.recordId = EncodingUtil.base64Encode(Blob.valueof(recordId));
            usageAnalytics.organizationId = orgId;

            populateUserDetails();

            Adm.PageLayout pageLayout = ADM_PageLayoutManager.getInstance().getPageLayoutDetails(usageAnalyticsInput.layoutDeveloperName,false,null);
            usageAnalytics.layoutDeveloperName = pageLayout.developerName;
            usageAnalytics.layoutType = pageLayout.pageHeader.screenType;
            usageAnalytics.headerObject = pageLayout.pageHeader.objectAPIName;
            usageAnalytics.transactionType = pageLayout.pageHeader.transactionType;

            if ( pageLayout.pageHeader.fieldSets != null && pageLayout.pageHeader.fieldSets.size() > 0 ) {
                usageAnalytics.fieldSetUsage = true;
            }

            populateHeaderElementDetails(pageLayout.pageHeader.elements);

            populateHeaderSectionDetails(pageLayout.pageHeader.sections );

            populateRelatedSectionDetails(pageLayout.lines);

            System.debug('usageAnalytics' + JSON.serialize(usageAnalytics));
            serviceResponse = CONF_PageLayoutRunTime_LS.sendToNewRelic(JSON.serialize(usageAnalytics));

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'generateTransactionUsageAnalytics() : Failed to retrieve run time page data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'generateTransactionUsageAnalytics() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    } 
    
    /**
    * This method to generate user details.
    */
    public static void populateUserDetails() {

        List<User> userList =  SvmxDatabase.query( [SELECT Id, UserType, Country, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()]); 
        usageAnalytics.Region = userList[0].Country;
        usageAnalytics.timezone = userList[0].TimeZoneSidKey;
        usageAnalytics.userType = userList[0].UserType;
        
    }

    /**
    * This method to generate header element details.
    */
    public static void populateHeaderElementDetails(List<Adm.PageElement> headerElements) {

        if (headerElements != null && headerElements.size() > 0) {

            for (Adm.PageElement element : headerElements) {
                if (element.formFillMappingId != null || element.expressionBasedMapping != null) {
                    usageAnalytics.autoFillMappingCount = usageAnalytics.autoFillMappingCount + 1;
                }

                if (element.overrideLookupContext) {
                    usageAnalytics.contextualFilterCount = usageAnalytics.contextualFilterCount + 1;
                }

                if (element.type != null && element.type == 'Button') {
                    usageAnalytics.customButtonsCount = usageAnalytics.customButtonsCount + 1;
                }

                if (element.type != null && element.type == 'Field') {
                    usageAnalytics.numberOfFieldsInHeader = usageAnalytics.numberOfFieldsInHeader + 1;
                }

                if (element.type != null && element.type == 'Field' && element.lookupConfigId != null) {
                    usageAnalytics.numberOfLookupsConfiguredInHeader = usageAnalytics.numberOfLookupsConfiguredInHeader + 1;
                }
            }

        }

    }

    /**
    * This method to generate header section details.
    */
    public static void populateHeaderSectionDetails(List<Adm.PageSection> headerSections) {

        if (headerSections != null && headerSections.size() > 0) {

            for (Adm.PageSection section : headerSections) {

                if (section.visibilityCriteria != null) {
                    usageAnalytics.dynamicSectionsCount = usageAnalytics.dynamicSectionsCount + 1;
                }

                for (Adm.PageElement element : section.elements) {

                    if (element.formFillMappingId != null || element.expressionBasedMapping != null) {
                        usageAnalytics.autoFillMappingCount = usageAnalytics.autoFillMappingCount + 1;
                    }
                    if (element.overrideLookupContext) {
                        usageAnalytics.contextualFilterCount = usageAnalytics.contextualFilterCount + 1;
                    }

                    if (element.type != null && element.type == 'Button') {
                        usageAnalytics.customButtonsCount = usageAnalytics.customButtonsCount + 1;
                    }

                    if (element.type != null && element.type == 'Field') {
                        usageAnalytics.numberOfFieldsInHeader = usageAnalytics.numberOfFieldsInHeader + 1;
                    }

                    if (element.type != null && element.type == 'Field' && element.lookupConfigId != null) {
                        usageAnalytics.numberOfLookupsConfiguredInHeader = usageAnalytics.numberOfLookupsConfiguredInHeader + 1;
                    }
                }
            }

        }
        
    }

    /**
    * This method to generate user details.
    */
    public static void populateRelatedSectionDetails(List<Adm.PageDetail> pageDetails) {

        for (Adm.PageDetail line : pageDetails) {
            if (line.objectAPIName != null) {
                usageAnalytics.childObjects = usageAnalytics.childObjects + line.objectAPIName + ';';
                usageAnalytics.childCount = usageAnalytics.childCount + 1;
            }

            if (line.visibilityCriteria != null) {
                usageAnalytics.dynamicSectionsCount = usageAnalytics.dynamicSectionsCount + 1;
            }

            for (Adm.PageElement element : line.elements) {
                if (element.formFillMappingId != null || element.expressionBasedMapping != null) {
                    usageAnalytics.autoFillMappingCount = usageAnalytics.autoFillMappingCount + 1;
                } 
                if (element.overrideLookupContext) {
                    usageAnalytics.contextualFilterCount = usageAnalytics.contextualFilterCount + 1;
                }

                if (element.type != null && element.type == 'Button') {
                    usageAnalytics.customButtonsCount = usageAnalytics.customButtonsCount + 1;
                }

                if (element.type != null && element.type == 'Field') {
                    usageAnalytics.numberOfFieldsInChild = usageAnalytics.numberOfFieldsInChild + 1;
                }

                if (element.type != null && element.type == 'Field' && element.lookupConfigId != null) {
                    usageAnalytics.numberOfLookupsConfiguredInChild = usageAnalytics.numberOfLookupsConfiguredInChild + 1;
                }
            }

        }
        
    }
}