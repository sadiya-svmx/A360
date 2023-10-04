/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to import configurations from static resource  
 *
 * @author Sathish Kumar DB
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sathish Kumar DB       	06 Oct 2020     Created.
 *              Sathish Kumar DB       	04 Feb 2021     A360TOOL-243
 *****************************************************************************************************/
public without sharing class TOOL_ImportDataHandler extends TOOL_AbstractDataHandler {
    
    final private Map<String, String> expressionsMap = new Map<String, String>();

    final private Map<String, String> objectMappingData = new Map<String, String>();

    final private Map<String, String> lookupMap = new Map<String, String>();

    private DataWrapper dataWrapper = new DataWrapper();

    private Boolean isUpgrade = false;
    
    private Boolean overwrite = false;

    private System.Version previousVersion;

    final private Map<String, Map<String,String>> recordTypeMap = new Map<String, Map<String,String>>();
    
    private CONF_PostInstallLogger installLogger = CONF_PostInstallLogger.getInstance();
    
    public TOOL_ImportDataHandler() {
        super( TOOL_AbstractDataHandler.HandlerType.ImportData );
    }
    
    public TOOL_ImportDataHandler( final Boolean isUpgrade, final String previousVersion ) {
        this(isUpgrade, previousVersion, false);
    }
    
    public TOOL_ImportDataHandler( final Boolean isUpgrade, final String previousVersion, final Boolean overwrite ) {
        
        super( TOOL_AbstractDataHandler.HandlerType.ImportData );
        
        this.isUpgrade = isUpgrade;
        this.overwrite = overwrite;
        
        if( previousVersion != null ) {
            this.previousVersion = SvmxTooling.toVersion( previousVersion );
        }
    }
    
    /**
     * This method fetches all json data from static resource and saves in the constant variable.
     */
    @TestVisible override protected void initHandler() {
        
        System.debug( LoggingLevel.DEBUG, 'initHandler() - enter' );
        
        try {
            //get static resource file path
            String staticResourcePath = getStaticResourcePath(ASSET360_CONFIGURATION_FILENAME);
            if(String.isNotBlank(staticResourcePath)){
                String dataWrapperJson = getJsonData(staticResourcePath);
                if(String.isNotBlank(dataWrapperJson)){
                    SvmxTooling.ConfigurationData seedWrapper = (SvmxTooling.ConfigurationData) JSON.deserialize(dataWrapperJson, SvmxTooling.ConfigurationData.class);
                    installLogger.logDetail('Processed Static Resource Successfully');
                    
					System.debug( 'initHandler() - isUpgrade= ' + isUpgrade + '; previousVersion= ' + previousVersion );
                    
                    if( isUpgrade && previousVersion != null ) {
                        
                        System.debug( LoggingLevel.DEBUG, 'initHandler() - Processing data for Upgrade' );
                        dataWrapper = parseDataWrapper(seedWrapper);
                    }
                    else{
                        dataWrapper.adminPageList.addAll(seedWrapper.adminPageList != null ? seedWrapper.adminPageList : new List<Adm.AdminPage>());
                        dataWrapper.mappingList.addAll(seedWrapper.mappingList != null ? seedWrapper.mappingList : new List<Adm.ObjectMapping>());
                        dataWrapper.expressionList.addAll(seedWrapper.expressionList != null ? seedWrapper.expressionList : new List<Adm.Expression>());
                        dataWrapper.lookupConfigList.addAll(seedWrapper.lookupConfigList != null ? seedWrapper.lookupConfigList : new List<Adm.LookupConfig>());
                        dataWrapper.pageLayoutList.addAll(seedWrapper.pageLayoutList != null ? seedWrapper.pageLayoutList : new List<Adm.PageLayout>());
                        dataWrapper.wizardList.addAll(seedWrapper.wizardList != null ? seedWrapper.wizardList : new List<Adm.ProcessWizard>());
                        dataWrapper.entitlementRuleList.addAll(seedWrapper.entitlementRuleList != null ? seedWrapper.entitlementRuleList : new List<Adm.EntitlementRule>());
                        dataWrapper.transactionList.addAll(seedWrapper.transactionList != null ? seedWrapper.transactionList : new List<Adm.PageLayout>());
                    }
                }
                
                for(RecordType recordType : [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType]) {
                    if( !recordTypeMap.containsKey(recordType.SObjectType) ) {
                        recordTypeMap.put(recordType.SObjectType, new Map<String,String>());
                    }
                    recordTypeMap.get(recordType.SObjectType).put(recordType.Name, recordType.DeveloperName);
                }
                
                List<SVMXA360__CONF_ExpressionDetail__c> expressionDetailList = [SELECT Id, SVMXA360__FieldAPIName__c, SVMXA360__ExpressionId__r.SVMXA360__ObjectAPIName__c, SVMXA360__RelatedObjectDetails__c, SVMXA360__Operand__c, SVMXA360__RelationshipFieldAPIName__c FROM SVMXA360__CONF_ExpressionDetail__c WHERE SVMXA360__FieldAPIName__c like '%.RecordTypeId' OR SVMXA360__FieldAPIName__c = 'RecordTypeId'];
                for( SVMXA360__CONF_ExpressionDetail__c expressionDetail : expressionDetailList ) {
                    
                    String objectAPIName = expressionDetail.SVMXA360__ExpressionId__r.SVMXA360__ObjectAPIName__c;
                    if( String.isNotBlank(expressionDetail.SVMXA360__RelatedObjectDetails__c) ) {
                        
                        objectAPIName = expressionDetail.SVMXA360__RelatedObjectDetails__c;
                        if( expressionDetail.SVMXA360__RelatedObjectDetails__c.indexOf('.') != -1 ) {
                            objectAPIName = expressionDetail.SVMXA360__RelatedObjectDetails__c.substringAfterLast('.');
                        }
                    }
                    if( recordTypeMap.containsKey(objectAPIName) && recordTypeMap.get(objectAPIName).containsKey(expressionDetail.SVMXA360__Operand__c) ) {
                        
                        expressionDetail.SVMXA360__Operand__c = recordTypeMap.get(objectAPIName).get(expressionDetail.SVMXA360__Operand__c);
                        expressionDetail.SVMXA360__RelationshipFieldAPIName__c = 'DeveloperName';
                    }
                }
                
                update expressionDetailList;
            }
        } 
        catch (Exception e) {
            
            System.debug(LoggingLevel.ERROR, 'Error in initHandler ' +  e.getStackTraceString());
            installLogger.applicationLog( 'Failed to initialize configuration data import. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Failed to initialize configuration data import.');
            installLogger.logDetail('Error while initialize import : ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initHandler() - exit' );
        }
    }
    
    /**
     * This method saves the Mapping from the json using mapping service
     */
    @TestVisible override protected void handleMapping() {
        
        System.debug( LoggingLevel.DEBUG, 'handleMapping() - enter' );
        installLogger.logDetail('Started Processing Mapping');
        
        try {
            if(dataWrapper != null && dataWrapper.mappingList != null && dataWrapper.mappingList.size() > 0){
                
                List<Adm.ObjectMapping> newObjectMappingList = ADM_ObjectMappingManager.getInstance().saveObjectMappings(dataWrapper.mappingList, true);
                if(newObjectMappingList != null && newObjectMappingList.size() > 0) {
                    
                    System.debug( LoggingLevel.DEBUG, 'Processed Mapping Successfully - '+newObjectMappingList.size() );
                    installLogger.logDetail('Processed ' + newObjectMappingList.size() + ' Mapping Successfully');
                    installLogger.logSummary('Processing Mapping : Success');
                }
            }

            //get all mappings from org
            List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappings();
            if(objectMappingList != null && objectMappingList.size() > 0){
                for(Adm.ObjectMapping objMapping : objectMappingList){
                    objectMappingData.put(objMapping.developerName, objMapping.id);
                }
            }
        }
        catch (Exception e) {
            
            installLogger.applicationLog( 'Failed to create Object Mapping. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Mapping : Failed');
            installLogger.logDetail('Error while processing Mapping : ' + e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleMapping() : Error while processing Mapping ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleMapping() - exit' );
            installLogger.logDetail('End of Processing Mapping');
        }
    }
    
    /**
     * This method saves the Expression from the json using expression service
     */
    @TestVisible override protected void handleExpression() {
        
        System.debug( LoggingLevel.DEBUG, 'handleExpression() - enter' );
        installLogger.logDetail('Started Processing Expression');
        
        try {
            if(dataWrapper != null && dataWrapper.expressionList != null && dataWrapper.expressionList.size() > 0){
                
                List<Adm.Expression> newExpressionList = ADM_ExpressionManager.getInstance().saveExpressions(dataWrapper.expressionList, true);
                if(newExpressionList != null && newExpressionList.size() > 0){
                    System.debug( LoggingLevel.DEBUG, 'Processed Expression Successfully - '+newExpressionList.size() );
                    installLogger.logDetail('Processed ' + newExpressionList.size() + ' Expression Successfully');
                    installLogger.logSummary('Processing Expression : Success');
                    for(Adm.Expression expression : newExpressionList){
                        System.debug( LoggingLevel.DEBUG, 'Expression Insert - ' + expression.developerName + ' - '+ expression.id);
                    }
                }
            }

            //get all expressions from org
            List<Adm.Expression> expressionsList = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails();
            if(expressionsList != null && expressionsList.size() > 0){
                for(Adm.Expression expression : expressionsList){
                    expressionsMap.put(expression.developerName, expression.id);
                }
            }
        }
        catch (Exception e) {
            installLogger.applicationLog( 'Failed to create Expressions. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Expression : Failed');
            installLogger.logDetail('Error while processing Expression : ' + e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleExpression() : Error while processing Expression ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleExpression() - exit' );
            installLogger.logDetail('End of Processing Expression');
        }
    }

    /**
     * This method saves the Lookup Configurations from the json using lookup service
     */
    @TestVisible override protected void handleLookupConfig() {

        System.debug( LoggingLevel.DEBUG, 'handleLookupConfig() - enter' );
        installLogger.logDetail('Started Processing Lookup Configuration');
        
        try {
            
            List<Adm.LookupConfig> lookupList = ADM_LookupConfigManager.getInstance().getAllLookupConfigurations();
            if(lookupList != null && lookupList.size() > 0){
                for(Adm.LookupConfig lookup : lookupList){
                    lookupMap.put(lookup.developerName, lookup.id);
                }
            }
            
            if(dataWrapper != null && dataWrapper.lookupConfigList != null && dataWrapper.lookupConfigList.size() > 0){
                for(Adm.LookupConfig lookup : dataWrapper.lookupConfigList){
                    if(lookup.basicFilterId != null){
                        lookup.basicFilterId = expressionsMap.get(lookup.basicFilterId);
                    }
                    if( lookupMap.containsKey(lookup.developerName) ) {
                        lookup.id = lookupMap.get(lookup.developerName);
                    }
                }

                List<Adm.LookupConfig> newLookupList = ADM_LookupConfigManager.getInstance().saveLookupConfigurations(dataWrapper.lookupConfigList);
                if(newLookupList != null && newLookupList.size() > 0){
                    System.debug( LoggingLevel.DEBUG, 'Processed Lookup Configuration Successfully - '+newLookupList.size() );
                    installLogger.logDetail('Processed ' + newLookupList.size() + ' Lookup Configuration Successfully');
                    installLogger.logSummary('Processing Lookup Configuration : Success');

                    for(Adm.LookupConfig lookup : newLookupList){
                        System.debug( LoggingLevel.DEBUG, 'Lookup Configuration Insert - ' + lookup.developerName + ' - '+ lookup.id);
                    }
                }
            }

            //get all lookups from org
            lookupList = ADM_LookupConfigManager.getInstance().getAllLookupConfigurations();
            if(lookupList != null && lookupList.size() > 0){
                for(Adm.LookupConfig lookup : lookupList){
                    lookupMap.put(lookup.developerName, lookup.id);
                }
            }
        }
        catch (Exception e) {
            installLogger.applicationLog( 'Failed to create Lookup Configurations. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Lookup Configuration : Failed');
            installLogger.logDetail('Error while processing Lookup Configuration : ' + e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleLookupConfig() : Error while processing Lookup Configuration ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleLookupConfig() - exit' );
            installLogger.logDetail('End of Processing Lookup Configuration');
        }
    }
       
    /**
     * This method saves the Page Layout from the json using page layout service
     */
    @TestVisible override protected void handlePageLayout() {
        
        System.debug( LoggingLevel.DEBUG, 'handlePageLayout() - enter' );
        installLogger.logDetail('Started Processing Page Layout');
        
        try {
            if(dataWrapper != null && dataWrapper.pageLayoutList != null && dataWrapper.pageLayoutList.size() > 0){
                
                Boolean hasError = false;
                for( Adm.PageLayout pageLayout : dataWrapper.pageLayoutList ) {
                    
                    if( pageLayout.pageHeader != null && pageLayout.pageHeader.sections != null ) {
                        for(Adm.PageSection pageSection : pageLayout.pageHeader.sections){
                            for(Adm.PageElement element : pageSection.elements){
                                if(element.lookupConfigId != null){
                                    element.lookupConfigId = lookupMap.get(element.lookupConfigId);
                                }
                            }
                        }
                    }
                    if( pageLayout.lines != null ) {
                        for(Adm.PageDetail pageLine : pageLayout.lines){
                            for(Adm.PageElement element : pageLine.elements){
                                if(element.lookupConfigId != null){
                                    element.lookupConfigId = lookupMap.get(element.lookupConfigId);
                                }
                            }
                        }
                    }
                    
                    //ADM_PageLayoutManager.getInstance().savePageLayout(pageLayout);
                }
                ADM_PageLayoutManager.getInstance().savePageLayouts(dataWrapper.pageLayoutList);
                
                System.debug( LoggingLevel.DEBUG, 'Processed Page Layout Successfully - '+dataWrapper.pageLayoutList.size() );
                installLogger.logDetail('Processed ' + dataWrapper.pageLayoutList.size() + ' Page Layout Successfully');
                installLogger.logSummary('Processing Page Layout : Success');
            }
        }
        catch (Exception e) {
            installLogger.applicationLog( 'Failed to create Screen Designers. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Page Layout : Failed');
            installLogger.logDetail('Error while processing Page Layout : ' + e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handlePageLayout() : Error while processing Page Layout ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handlePageLayout() - exit' );
            installLogger.logDetail('End of Processing Page Layout');
        }
    }
    
    /**
     * This method saves the Wizard from the json using wizard service
     */
    @TestVisible override protected void handleProcessWizard() {
        
        System.debug( LoggingLevel.DEBUG, 'handleProcessWizard() - enter' );
        installLogger.logDetail('Started Processing Wizard');
        
        try {
            if(dataWrapper != null && dataWrapper.wizardList != null && dataWrapper.wizardList.size() > 0) {
                
                Map<String,id> wizardStepIdMap = new Map<String,id>();
                for( SVMXA360__CONF_ProcessWizardStep__c ProcessWizardRecord : [ SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ProcessWizardStep__c ] ) {
                    wizardStepIdMap.put(ProcessWizardRecord.SVMXA360__DeveloperName__c, ProcessWizardRecord.Id );
                }
                
                List<Adm.ProcessWizard> saveWizardList = new List<Adm.ProcessWizard>();
				Map<String,id> wizardIdMap = new Map<String,id>();
                List<Adm.ProcessWizard> wizardList = ADM_ProcessWizardManager.getInstance().getAllProcessWizardDetails();
                Map<String,List<Adm.ProcessWizard>> wizardMap = new Map<String,List<Adm.ProcessWizard>>();
                if(wizardList != null && wizardList.size() > 0){
                    for(Adm.ProcessWizard wizard : wizardList) {
                        
                        wizardIdMap.put(wizard.developerName, wizard.id);
                        if(wizardMap.containsKey(wizard.objectAPIName)){
                            wizardMap.get(wizard.objectAPIName).add(wizard);
                        } else {
                            List<Adm.ProcessWizard> processWizard = new List<Adm.ProcessWizard>();
                            processWizard.add(wizard);
                            wizardMap.put(wizard.objectAPIName, processWizard);
                        }
                    }
                }

                List<String> objectAPINames = new List<String>();
                List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
                for(Adm.ProcessWizard wizard : dataWrapper.wizardList){
                    wizard.id = wizardIdMap.get(wizard.developerName);
                    if(!objectAPINames.contains(wizard.objectAPIName)){
                        objectAPINames.add(wizard.objectAPIName);
                    }

                    wizard.expressionId = expressionsMap.containsKey(wizard.expressionId) ? expressionsMap.get(wizard.expressionId) : wizard.expressionId;
                    
                    if( wizard.steps != null ) {
                        for(Adm.ProcessStep step : wizard.steps) {
                            if( wizardStepIdMap.containsKey( step.developerName ) ) {
                                step.id = wizardStepIdMap.get(step.developerName);
                            }
                            step.expressionId = expressionsMap.containsKey(step.expressionId) ? expressionsMap.get(step.expressionId) : step.expressionId;
                        }
                    }
                    
                    if( wizard.access != null && profileList.size() > 0 ){
                        for(Adm.ProcessAccess access : wizard.access) {
                            if( access.profileId == null ) {
                                access.profileId = profileList[0].Id;
                            }
                        }
                    }

                    if(isUpgrade && wizardMap.containsKey(wizard.objectAPIName)){
                        wizardMap.get(wizard.objectAPIName).add(wizard);
                    }
                    else{
                        saveWizardList.add(wizard);
                    }
                }

                //handle new wizard in upgrade
                if(isUpgrade && objectAPINames.size() > 0){
                    for(String objectApiName : objectAPINames){
                        if(wizardMap.containsKey(objectApiName)){
                            saveWizardList.addAll(wizardMap.get(objectApiName));
                        }
                    }   
                }

                System.debug( LoggingLevel.DEBUG, 'wizardDataList - '+ saveWizardList.size() );
                
                List<Adm.ProcessWizard> newWizardList = ADM_ProcessWizardManager.getInstance().saveProcessWizards(saveWizardList, objectAPINames);
                if(newWizardList != null && newWizardList.size() > 0) {
                    
                    System.debug( LoggingLevel.DEBUG, 'Processed Wizard Successfully - '+newWizardList.size() );
                    installLogger.logDetail('Processed ' + newWizardList.size() + ' Wizard Successfully');
                    installLogger.logSummary('Processing Wizard : Success');
                }
            }
        } 
        catch (Exception e) {
            
            installLogger.applicationLog( 'Failed to create Wizards. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Wizard : Failed');
            installLogger.logDetail('Error while processing Wizard : '+ e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleProcessWizard() : Error while processing Wizard ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleProcessWizard() - exit' );
            installLogger.logDetail('End of Processing Wizard');
        }
    }
    
    /**
     * This method saves the Entitlement Rule from the json using entitlement rule service
     */
    @TestVisible override protected void handleEntitlementRule() {
        
        System.debug( LoggingLevel.DEBUG, 'handleEntitlementRule() - enter' );
        installLogger.logDetail('Started Processing Entitlement Rule');
        
        try {
            if(dataWrapper != null && dataWrapper.entitlementRuleList != null && dataWrapper.entitlementRuleList.size() > 0){
                 
                List<Adm.EntitlementRule> newEntitlementRuleList = ADM_EntitlementRuleManager.getInstance().saveEntitlementRules(dataWrapper.entitlementRuleList);
                if(newEntitlementRuleList != null && newEntitlementRuleList.size() > 0){
                    System.debug( LoggingLevel.DEBUG, 'Processed Entitlement Rule Successfully - '+newEntitlementRuleList.size() );
                    installLogger.logDetail('Processed ' + newEntitlementRuleList.size() + ' Entitlement Rule Successfully');
                    installLogger.logSummary('Processing Entitlement Rule : Success');
                }
            }
        }
        catch (Exception e) {
            installLogger.applicationLog( 'Failed to create Entitlement Rules. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Entitlement Rule : Failed');
            installLogger.logDetail('Error while processing Entitlement Rule : '+ e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleEntitlementRule() : Error while processing Entitlement Rule ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleEntitlementRule() - enter' );
            installLogger.logDetail('End of Processing Entitlement Rule');
        }
    }

    /**
     * This method saves the Admin Page from the json using admin page service
     */
    @TestVisible override protected void handleAdminPage() {
        
        System.debug( LoggingLevel.DEBUG, 'handleAdminPage() - enter' );
        installLogger.logDetail('Started Processing Admin Page');
        
        try {
            delete [SELECT id FROM SVMXA360__CONF_AdminPage__c];
            ADM_AdminPageManager.getInstance().createDefaultAdminPages();
            installLogger.logSummary('Processing Admin Page : Success');
        }
        catch (Exception e) {
            installLogger.applicationLog( 'Failed to create Admin Page. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Admin Page : Failed');
            installLogger.logDetail('Error while processing Admin Page : '+ e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleAdminPage() : Error while processing Admin Page ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleAdminPage() - enter' );
            installLogger.logDetail('End of Processing Admin Page');
        }
    }

    /**
     * This method saves the Transaction from the json using page layout service
     */
    @TestVisible override protected void handleTransaction() {
        
        System.debug( LoggingLevel.DEBUG, 'handleTransaction() - enter' );
        installLogger.logDetail('Started Processing Transaction');
        
        try {
            if(dataWrapper != null && dataWrapper.transactionList != null && dataWrapper.transactionList.size() > 0){
                
                Boolean hasError = false;
                for( Adm.PageLayout transactionData : dataWrapper.transactionList ) {
                    if( transactionData.pageHeader != null ) {
                        if(transactionData.pageHeader.valueMapping != null){
                            transactionData.pageHeader.valueMapping = objectMappingData.get(transactionData.pageHeader.valueMapping);
                        }
                        if(transactionData.pageHeader.fieldMapping != null){
                            transactionData.pageHeader.fieldMapping = objectMappingData.get(transactionData.pageHeader.fieldMapping);
                        }
                        if(transactionData.pageHeader.qualifyingCriteria != null){
                            transactionData.pageHeader.qualifyingCriteria = expressionsMap.get(transactionData.pageHeader.qualifyingCriteria);
                        }

                        if( transactionData.pageHeader.sections != null ){
                            for(Adm.PageSection pageSection : transactionData.pageHeader.sections){
                                if(pageSection.visibilityCriteria != null){
                                    pageSection.visibilityCriteria = expressionsMap.get(pageSection.visibilityCriteria);
                                }
                                for(Adm.PageElement element : pageSection.elements){
                                    if(element.lookupConfigId != null){
                                        element.lookupConfigId = lookupMap.get(element.lookupConfigId);
                                    }
                                    //A360TOOL-466
                                    if(element.formFillMappingName != null){
                                        element.formFillMappingId = objectMappingData.get(element.formFillMappingName);
                                    }
                                }
                            }
                        }
                    }
                    if( transactionData.lines != null ) {
                        for(Adm.PageDetail pageLine : transactionData.lines){
                            if(pageLine.fieldMapping != null){
                                pageLine.fieldMapping = objectMappingData.get(pageLine.fieldMapping);
                            }
                            if(pageLine.valueMapping != null){
                                pageLine.valueMapping = objectMappingData.get(pageLine.valueMapping);
                            }
                            if(pageLine.qualifyingCriteria != null){
                                pageLine.qualifyingCriteria = expressionsMap.get(pageLine.qualifyingCriteria);
                            }
                            for(Adm.PageElement element : pageLine.elements){
                                if(element.lookupConfigId != null){
                                    element.lookupConfigId = lookupMap.get(element.lookupConfigId);
                                }
                                //A360TOOL-466
                                if(element.formFillMappingName != null){
                                    element.formFillMappingId = objectMappingData.get(element.formFillMappingName);
                                }
                            }
                        }
                    }
                }
                ADM_PageLayoutManager.getInstance().savePageLayouts(dataWrapper.transactionList);
                
                System.debug( LoggingLevel.DEBUG, 'Processed Transaction Successfully - '+dataWrapper.transactionList.size() );
                installLogger.logDetail('Processed ' + dataWrapper.transactionList.size() + ' Transaction Successfully');
                installLogger.logSummary('Processing Transaction : Success');
            }
        }
        catch (Exception e) {
            installLogger.applicationLog( 'Failed to create Transactions. Error= ' + e.getMessage() );
            
            installLogger.logSummary('Processing Transaction : Failed');
            installLogger.logDetail('Error while processing Transaction : ' + e.getMessage());
            System.debug( LoggingLevel.ERROR, 'handleTransaction() : Error while processing Transaction ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleTransaction() - exit' );
            installLogger.logDetail('End of Processing Transaction');
        }
    }

    @TestVisible private DataWrapper parseDataWrapper(SvmxTooling.ConfigurationData configurationData){

        DataWrapper seedWrapper = new DataWrapper();
        try {

            if( configurationData != null && previousVersion != null ) {

                if(configurationData.adminPageList != null && configurationData.adminPageList.size() > 0){
                    seedWrapper.adminPageList = configurationData.adminPageList;
                }
                
                if(configurationData.mappingList != null && configurationData.mappingList.size() > 0) {
                    List<SVMXA360__CONF_ObjectMapping__c> existingMappings = SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ObjectMapping__c] );
                    Map<String, Id> objectMappingMap = new Map<String, Id>();
                    if(existingMappings != null && existingMappings.size() > 0){
                        for(SVMXA360__CONF_ObjectMapping__c mapping : existingMappings){
                            objectMappingMap.put(mapping.SVMXA360__DeveloperName__c, mapping.Id);
                        }
                    }

                    for(SvmxTooling.MappingData objMapping : configurationData.mappingList) {
                        if( !objectMappingMap.containsKey(objMapping.developerName) || this.overwrite ) {
                            if( objectMappingMap.containsKey(objMapping.developerName) ) {
                                objMapping.Id = objectMappingMap.get(objMapping.developerName);
                            }
                            seedWrapper.mappingList.add(objMapping);
                        }
                    }
                }

                if(configurationData.expressionList != null && configurationData.expressionList.size() > 0) {
                    List<SVMXA360__CONF_Expression__c> existingExpressions = SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Expression__c] );
                    Map<String, Id> expressionMap = new Map<String, Id>();
                    if(existingExpressions != null && existingExpressions.size() > 0){
                        for(SVMXA360__CONF_Expression__c expression : existingExpressions){
                            expressionMap.put(expression.SVMXA360__DeveloperName__c, expression.Id);
                        }
                    }

                    for(SvmxTooling.ExpressionData expression : configurationData.expressionList){
                        if( !expressionMap.containsKey(expression.developerName) || this.overwrite ) {
                            if( expressionMap.containsKey(expression.developerName) ) {
                                expression.id = expressionMap.get(expression.developerName);
                            }
                            seedWrapper.expressionList.add(expression);
                        }
                    }
                }

                if(configurationData.lookupConfigList != null && configurationData.lookupConfigList.size() > 0) {
                    List<SVMXA360__CONF_LookupConfiguration__c> existingLookups = SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_LookupConfiguration__c] );
                    Map<String, Id> lookupMap = new Map<String, Id>();
                    if(existingLookups != null && existingLookups.size() > 0){
                        for(SVMXA360__CONF_LookupConfiguration__c lookup : existingLookups){
                            lookupMap.put(lookup.SVMXA360__DeveloperName__c, lookup.Id);
                        }
                    }

                    for(SvmxTooling.LookupConfigData lookup : configurationData.lookupConfigList){
                        if( !lookupMap.containsKey(lookup.developerName) || this.overwrite ) {
                            if( lookupMap.containsKey(lookup.developerName) ) {
                                lookup.id = lookupMap.get(lookup.developerName);
                            }
                            seedWrapper.lookupConfigList.add(lookup);
                        }
                    }
                }

                if(configurationData.pageLayoutList != null && configurationData.pageLayoutList.size() > 0) {
                    List<SVMXA360__CONF_Layout__c> existingLayouts = SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c where SVMXA360__ScreenType__c = '' OR SVMXA360__ScreenType__c = 'Screen'] );
                    Map<String, Id> layoutMap = new Map<String, Id>();
                    if(existingLayouts != null && existingLayouts.size() > 0){
                        for(SVMXA360__CONF_Layout__c layout : existingLayouts){
                            layoutMap.put(layout.SVMXA360__DeveloperName__c, layout.Id);
                        }
                    }

                    for(SvmxTooling.PageLayoutData layout : configurationData.pageLayoutList){
                        if( !layoutMap.containsKey(layout.developerName) || this.overwrite ) {
                            if( layoutMap.containsKey(layout.developerName) ) {
                                layout.id = layoutMap.get(layout.developerName);
                            }
                            seedWrapper.pageLayoutList.add(layout);
                        }
                    }
                }

                if(configurationData.wizardList != null && configurationData.wizardList.size() > 0) {
                    
                    List<Adm.ProcessWizard> existingWizards = ADM_ProcessWizardManager.getInstance().getAllProcessWizardDetails();
                    
                    Map<String, Adm.ProcessWizard> wizardMap = new Map<String, Adm.ProcessWizard>();
                    final Map<String,Integer> sequenceMap = new Map<String,Integer>();
                    
                    if(existingWizards != null && existingWizards.size() > 0) {
                        
                        for(Adm.ProcessWizard wizard : existingWizards) {
                            
                            wizardMap.put(wizard.developerName, wizard);
                            
                            if( !sequenceMap.containsKey(wizard.objectAPIName) ) {
                                sequenceMap.put( wizard.objectAPIName, 0 );
                            }
                            
                            if( sequenceMap.get(wizard.objectAPIName) <  wizard.sequence ) {
                                sequenceMap.put( wizard.objectAPIName, wizard.sequence );
                            }
                        }
                    }

                    for(SvmxTooling.ProcessWizardData wizard : configurationData.wizardList){
                        
                        if( wizardMap.containsKey(wizard.developerName) ) {
                            
                            Adm.ProcessWizard existingWizard = wizardMap.get(wizard.developerName);
                            wizard.id = existingWizard.id;
                            wizard.access = existingWizard.access;
                            wizard.expressionId = existingWizard.expressionId;
                            wizard.sequence = existingWizard.sequence;
                            wizard.isModified = true;
                            wizard.active = existingWizard.active;
                            
                            mergeWizardSteps(wizard, existingWizard );
                        } else {
                            if( !sequenceMap.containsKey(wizard.objectAPIName) ) {
                                sequenceMap.put( wizard.objectAPIName, 0 );
                            }
                            wizard.sequence = sequenceMap.get(wizard.objectAPIName) + 1;
                            sequenceMap.put( wizard.objectAPIName, sequenceMap.get(wizard.objectAPIName) + 1 );
                        }
                        
                        seedWrapper.wizardList.add(wizard);
                    }
                }

                if(configurationData.entitlementRuleList != null && configurationData.entitlementRuleList.size() > 0){
                    List<SVMXA360__CONF_EntitlementRule__c> existingRules = SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_EntitlementRule__c] );
                    Map<String, Id> ruleMap = new Map<String, Id>();
                    if(existingRules != null && existingRules.size() > 0){
                        for(SVMXA360__CONF_EntitlementRule__c rule : existingRules){
                            ruleMap.put(rule.SVMXA360__DeveloperName__c, rule.Id);
                        }
                    }

                    for(SvmxTooling.EntitlementRuleData entitlement : configurationData.entitlementRuleList){
                        if( !ruleMap.containsKey(entitlement.developerName) || this.overwrite ) {
                            if( ruleMap.containsKey(entitlement.developerName) ) {
                                entitlement.id = ruleMap.get(entitlement.developerName);
                            }
                            seedWrapper.entitlementRuleList.add(entitlement);
                        }
                    }
                }

                if(configurationData.transactionList != null && configurationData.transactionList.size() > 0) {
                    List<SVMXA360__CONF_Layout__c> existingTransactions = SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c where SVMXA360__ScreenType__c = 'Transaction'] );
                    Map<String, Id> transactionMap = new Map<String, Id>();
                    if(existingTransactions != null && existingTransactions.size() > 0){
                        for(SVMXA360__CONF_Layout__c transactionData : existingTransactions){
                            transactionMap.put(transactionData.SVMXA360__DeveloperName__c, transactionData.Id);
                        }
                    }

                    for(SvmxTooling.TransactionData transactionData : configurationData.transactionList){
                        if( !transactionMap.containsKey(transactionData.developerName) || this.overwrite ) {
                            if( transactionMap.containsKey(transactionData.developerName) ) {
                                transactionData.id = transactionMap.get(transactionData.developerName);
                            }
                            seedWrapper.transactionList.add(transactionData);
                        }
                    }
                }
            }

        } 
        catch (Exception e) {
            
            installLogger.applicationLog( 'Failed to process Configuration Data. Error= ' + e.getMessage() );
            installLogger.logDetail('Error while parsing seed data : '+ e.getStackTraceString());
            System.debug( LoggingLevel.ERROR, 'parseDataWrapper() : Error while parsing seed data ' + e.getStackTraceString());
        }
        
        return seedWrapper;
    }
    
    private void mergeWizardSteps( final SvmxTooling.ProcessWizardData wizard, final Adm.ProcessWizard existingWizard ) {
        
        System.debug( LoggingLevel.DEBUG, 'mergeWizardSteps() - enter' );
        
        Map<String,Adm.ProcessStep> processStepMap = new Map<String,Adm.ProcessStep>();
        
        for( Adm.ProcessStep step : wizard.steps ) {
            
            step.sequence = null;
            processStepMap.put( (step.type+step.target ), step);
        }
        
        Integer maxSequence = 0;
        
        for( Adm.ProcessStep step : existingWizard.steps ) {
            
            if( !processStepMap.containsKey((step.type+step.target )) || !this.overwrite ) {
                
                if( maxSequence < step.sequence ) {
                    maxSequence = step.sequence;
                }
                
                step.isModified = true;
                processStepMap.put((step.type+step.target ), step);
            }
        }
        
        for( Adm.ProcessStep step : wizard.steps ) {
            if( step.sequence == null ) {
                step.sequence = ++maxSequence;
            }
        }
        
        wizard.steps = processStepMap.values();
        
        System.debug( LoggingLevel.DEBUG, 'mergeWizardSteps() - exit' );
    }
}