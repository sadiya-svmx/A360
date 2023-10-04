/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements install handler to perform post install script.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        	Name                    Date            Comment
 *****************************************************************************************************
 *              	Ramachandra Mohan       16 Jun 2020     Created.
 * BLOS-314     	Ramachandra Mohan       16 Jul 2020     Updated onInstall to perform DML only if records exists.
 * A360TOOL-54  	Manish Kushwah          06 Oct 2020     Added method createFeatureAccess for creating/updating Feature Access records.
 * A360TOOL-10  	Ramachandra Mohan       13 Oct 2020     Invoke import data handler.
 * A360TOOL-58  	Ramachandra Mohan       14 Oct 2020     Skip FLS check for feature access.
 * A360TOOL-501 	Ramachandra Mohan       27 May 2021     Added method to create supported language.
 * A360TOOL-483 	Ramachandra Mohan       07 Jun 2021     Invoke Translation Data Loader Batch.
 *              	Sathya Pachaiappan      11 Jun 2021     Called Batch job through queueable.
 * A360TOOL-1239	Ramachandra Mohan		12 Aug 2022     Support for configuration usage settings and code refactor.
 * A360TOOL-1472    Ramachandra Mohan       22 Jun 2023     Version check before enabling configurator flag.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
global without sharing class CONF_PostInstallHandler implements InstallHandler,Queueable,Database.AllowsCallouts {

    private static final String ERROR_DEFAULT_DEPOT_FINDER_RULE		= 'Failed to create default depot finder rule.';
    private static final String ERROR_DEFAULT_WARRANTY_RULE			= 'Failed to create default Warranty configuration rule.';
    private static final String ERROR_ASSET360_ADMIN_PAGES			= 'Failed to create Asset 360 Admin Pages.';
    private static final String ERROR_GLOBAL_PROPERTIES				= 'Failed to create Global Properties Custom Settings.';
    private static final String ERROR_INIT_IMPORT_HANDLER			= 'Failed to Initialize import handler.';
    
    private boolean isUpgradeInstall = false;
    
    private static Integer LAST_METADATA_CHANGE_MAJOR_VERSION		= 6;

    //private static final String ERROR_FEATURE_ACCESS_SETTINGS		= 'Failed to create Feature Access settings.';

    /**
     * private variable to hold logger for mail.
     */
    private static CONF_PostInstallLogger installLogger = CONF_PostInstallLogger.getInstance();

    /**
     * This method is used to invoke post-install script manually.
     *
     * @param previousInstalledVersion Asset 360 package version installed in the Org.
     */
    global void manualInstall( final String previousInstalledVersion  ) {
        manualInstall( '1', true  );
    }

    /**
     * This method is used to invoke post-install script manually.
     *
     * @param previousInstalledVersion Asset 360 package version installed in the Org.
     */
    global void manualInstall( final String previousInstalledVersion, final Boolean overwrite  ) {
        processPostInstall( UserInfo.getUserId(), String.isNotBlank( previousInstalledVersion  ), previousInstalledVersion, overwrite  );
    }

    /**
     * Implementation method which will be invoked by Salesforce once package installation is successful.
     *
     * @param context InstallContext instance with version informations.
     */
    global void onInstall( final InstallContext context ) {

        System.debug( LoggingLevel.DEBUG, 'onInstall() - enter');

        try {

            if( context == null ) {

                System.debug( LoggingLevel.ERROR, 'onInstall() : Invalid Post Install context. context= ' + context );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            //A360TOOL-756  A360 installer check for SVMXC core package in Org
            List<Publisher> corePackageInfo = [SELECT Name, NamespacePrefix FROM Publisher WHERE NamespacePrefix = 'SVMXC'];
            if(corePackageInfo.size() > 0){

                System.debug( LoggingLevel.ERROR, 'onInstall() : SVMXC package already available in this org' );
                throw new SvmxSystem.SvmxNestedException( 'onInstall() : SVMXC package already available in this org' );
            }

            Boolean isUpgrade = false;
            String previousVersion = null;

            if( context.isUpgrade() ) {

                isUpgrade = true;
                previousVersion = (context.previousVersion() != null ) ? String.valueOf( context.previousVersion() ) : null;
            }

            System.debug( 'onInstall() - isUpgrade= ' + isUpgrade + '; previousVersion= ' + previousVersion );
            
            processPostInstall( context.installerID(), isUpgrade, previousVersion, false );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'onInstall() : Failed to process Post Install script. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'onInstall() : Failed to perform post install script. Error= ' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'onInstall() - exit');
        }
    }

    @future(callout=true)
    public static void processPostInstall( final Id userId, final Boolean isUpgrade, final String previousVersion, final Boolean overwrite ) {

        System.debug( LoggingLevel.DEBUG, 'processPostInstall() - enter');

        try {

            SvmxSystem.isRunningPostInstall = true;
            TOOL_ImportDataHandler importDataHandler = new TOOL_ImportDataHandler( isUpgrade, previousVersion, overwrite );
            // Create default configuration records
            importDataHandler.processConfigurationData();

            // Create global properties records.
            createGlobalProperties( isUpgrade, previousVersion );
            createOrgDefaultAssetHierarchy();

            // Create Asset 360 Admin screen configuration.
            //createAsset360AdminPages();
            createDefaultWarrantyConfigRules();
            createDefaultDepotFinderSetting();
            createDefaultPSCConfiguration();
            createDefaultEntitlementSetting();
            ADM_EntitlementSettingsManager.getInstance().getAllEntitlementSettings();
            updateEntitlementSetting();
            updateWizardStepDeveloperName();
            
            // TODO update Layout Section 'on Load' Evaluation Event to 'Always', remove this code in future release.
            if ( isUpgrade ) {
                updateVisibilityCriteria();
            }
            CONF_PostInstallHandler  postInstallInstance = new CONF_PostInstallHandler();
            postInstallInstance.setIsUpgrade(isUpgrade);
            System.enqueueJob(postInstallInstance);
            // Create Asset 360 feature access settings.
            //createFeatureAccessSettings();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'processPostInstall() : Failed to perform post install script. Error= ' + e.getStackTraceString() );
            installLogger.applicationLog( e.getMessage() );
            installLogger.applicationLog( e.getStackTraceString() );
        }
        finally {

            installLogger.createApplicationLogs(userId);

            // Send email
            installLogger.sendEmail( userId, isUpgrade, previousVersion );

            System.debug( LoggingLevel.DEBUG, 'processPostInstall() - exit');
        }
    }

    global void execute(QueueableContext context) {
        Database.executeBatch( new COMM_TranslationDataLoaderBatch('Asset360Translations', this.isUpgradeInstall), 200);
        Database.executeBatch( new ADM_RecentItemsBatch());  
    }

    private static void updateVisibilityCriteria() {
        
        System.debug( LoggingLevel.DEBUG, 'updateVisibilityCriteria() - enter');
        installLogger.logDetail('Started Processing Visibility Criteria value update.');

        try {

            List<SVMXA360__CONF_LayoutSection__c> layoutSections = [SELECT id, SVMXA360__EvaluationEvent__c FROM SVMXA360__CONF_LayoutSection__c WHERE SVMXA360__EvaluationEvent__c = 'Field Change'];
            if ( layoutSections.size() != 0 ) {
                
                for( SVMXA360__CONF_LayoutSection__c layoutSection : layoutSections ) {
                    layoutSection.SVMXA360__EvaluationEvent__c = 'Always';
                }
                
                update layoutSections;
                
                installLogger.logSummary('Processing Visibility Criteria value update : Success');
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'updateVisibilityCriteria() : Failed to update Visibility Criteria values. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to update Visibility Criteria values. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Visibility Criteria value update : Failed');
            installLogger.logDetail('Failed to update Visibility Criteria values. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'Update Visibility Criteria values - exit');
            installLogger.logDetail('End of Processing Visibility Criteria value updates.');
        }
    }
    
    private static void createOrgDefaultAssetHierarchy() {
        
        System.debug( LoggingLevel.DEBUG, 'createOrgDefaultAssetHierarchy() - enter');
        installLogger.logDetail('Started Processing Org Default Asset Hierarchy Setting.');

        try {

            final SVMXA360__CONF_CSET_AssetHierarchy__c orgDefault = SVMXA360__CONF_CSET_AssetHierarchy__c.getOrgDefaults();
            
            if( orgDefault.Id == null ) {
                
                orgDefault.SVMXA360__HierarchyTypeForAsset__c = 'location_to_asset';
                orgDefault.SVMXA360__HierarchyTypeForWorkOrder__c = 'location_to_asset';
                
                insert orgDefault;
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createOrgDefaultAssetHierarchy() : Failed to create Org Default Asset Hierarchy Setting. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to create Org Default Asset Hierarchy Setting. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Org Default Asset Hierarchy Setting : Failed');
            installLogger.logDetail('Failed to create Org Default Asset Hierarchy Setting. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'Org Default Asset Hierarchy Setting() - exit');
            installLogger.logDetail('End of Processing Org Default Asset Hierarchy Setting.');
        }
    }
    
    private static void createAsset360AdminPages() {

        System.debug( LoggingLevel.DEBUG, 'createAsset360AdminPages() - enter');
        installLogger.logDetail('Started Processing Admin Pages');

        try {

            List<SVMXA360__CONF_AdminPage__c> adminPageList = ADM_AdminPageManager.getInstance().getActiveAdminPageRecords();

            if(adminPageList.size() == 0) {
                ADM_AdminPageManager.getInstance().createDefaultAdminPages();
                installLogger.logSummary('Processing Admin Pages : Success');
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createAsset360AdminPages() : Failed to create Asset 360 Admin Pages. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to create Admin Pages. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Admin Pages : Failed');
            installLogger.logDetail('Failed to create Asset 360 Admin Pages. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createAsset360AdminPages() - exit');
            installLogger.logDetail('End of Processing Admin Pages');
        }
    }

    private static void createDefaultPSCConfiguration() {

        System.debug( LoggingLevel.DEBUG, 'createDefaultPSCConfiguration() - enter');
        installLogger.logDetail('Started Processing Default PSC Configuration');

        try {

            List<SVMXA360__CONF_PSCConfiguration__c> pscConfigurationList = (List<SVMXA360__CONF_PSCConfiguration__c>) SvmxDatabase.query([SELECT Id FROM SVMXA360__CONF_PSCConfiguration__c WHERE SVMXA360__DeveloperName__c = 'Default_PSC_Settings']);

            if(pscConfigurationList.size() == 0) {

               	SVMXA360__CONF_PSCConfiguration__c pscConfiguration = new SVMXA360__CONF_PSCConfiguration__c();
                pscConfiguration.SVMXA360__SearchResultsPerPSC__c = 500;
                pscConfiguration.SVMXA360__DeliveryBatchSize__c = 50;
                pscConfiguration.SVMXA360__SearchBatchSize__c  = 250;
                pscConfiguration.Name  = 'Default PSC Settings';
                pscConfiguration.SVMXA360__DeveloperName__c = 'Default_PSC_Settings';
                pscConfiguration.RecordTypeId = SVMXA360__CONF_PSCConfiguration__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('PSC Settings').getRecordTypeId();

                SvmxDatabase.insertRecord(pscConfiguration);

                installLogger.logSummary('Processing Default PSC Configuration : Success');
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createDefaultPSCConfiguration() : Failed to create Default PSC Configuration. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to create Default PSC Configuration. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Default PSC Configuration : Failed');
            installLogger.logDetail('Failed to create Asset 360 Admin Pages. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createDefaultPSCConfiguration() - exit');
            installLogger.logDetail('End of Processing Default PSC Configuration');
        }
    }

    /*private void createFeatureAccessSettings() {

        System.debug( LoggingLevel.DEBUG, 'createFeatureAccessSettings() - enter');
        installLogger.logDetail('Started Processing Feature Access Settings');

        try {

            //Added for creating Feature Access records
            final Map<String, SVMXA360__CONF_CSET_FeatureAccess__c> allFeatureAccessRecords = SVMXA360__CONF_CSET_FeatureAccess__c.getAll();
            final List<SVMXA360__CONF_CSET_FeatureAccess__c> newFeatureAccessRecords = new List<SVMXA360__CONF_CSET_FeatureAccess__c>();
            newFeatureAccessRecords.addAll( createFeatureAccess( allFeatureAccessRecords ) );
            if( newFeatureAccessRecords.size() > 0 ) {
                // Disabled FLS check as this custom setting is protected.
                upsert newFeatureAccessRecords;
                installLogger.logSummary('Processing Feature Access Settings : Success');
            }
        }
        catch( Exception e ) {
            installLogger.logSummary('Processing Feature Access Settings : Failed');
            System.debug( LoggingLevel.ERROR, 'createFeatureAccessSettings() : Failed to create Feature access settings. Error= ' + e.getStackTraceString() );
            Logger.error( ERROR_FEATURE_ACCESS_SETTINGS );
            installLogger.logDetail('Failed to create Feature access settings. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createFeatureAccessSettings() - exit');
            installLogger.logDetail('End of Processing Feature Access Settings');
        }
    }*/

    private static void createGlobalProperties( final Boolean isUpgrade, final String previousVersion ) {

        System.debug( LoggingLevel.DEBUG, 'createGlobalProperties() - enter');
        installLogger.logDetail('Started Processing Global Properties');

        try {

            final Map<String, SVMXA360__CONF_CSET_GlobalProperties__c> allGlobalPropertyMap = SVMXA360__CONF_CSET_GlobalProperties__c.getAll();
            final List<SVMXA360__CONF_CSET_GlobalProperties__c> newGlobalProperties = new List<SVMXA360__CONF_CSET_GlobalProperties__c>();
            newGlobalProperties.addAll( createCustomSettings( allGlobalPropertyMap, Common.DefaultAllowedCoreObjects, CONF_CustomSettingsManager.KEY_ALLOWED_CORE_OBJECT ) );
            newGlobalProperties.addAll( createCustomSettings( allGlobalPropertyMap, Common.DefaultSupportedLanguages, CONF_CustomSettingsManager.KEY_SUPPORTED_LANGUAGE ) );
            newGlobalProperties.addAll( createCustomSettings( allGlobalPropertyMap, Common.DefaultAppUsageTrackingSettings, CONF_CustomSettingsManager.KEY_ENABLE_APP_USAGE_TRACKING ) );
            newGlobalProperties.addAll( createCustomSettings( allGlobalPropertyMap, Common.DefaultApplicationConfigSettings, CONF_CustomSettingsManager.KEY_AUTO_CONFIGURATOR ) );
            newGlobalProperties.addAll( createCustomSettings( allGlobalPropertyMap, Common.DefaultConfigurationUsageSettings, CONF_CustomSettingsManager.KEY_CONFIGURATION_USAGE_SETTINGS ) );

            if( newGlobalProperties.size() > 0 ) {

                // Upserting global properties.
                upsert newGlobalProperties;
                installLogger.logSummary('Processing Global Properties : Success');
            }
            
            if( isUpgrade ) {
                
                String executeAutoConfig = 'false';
                String autoConfigStatus = 'COMPLETED';
                
                final System.Version systemVersion = String.isNotBlank(previousVersion) ? SvmxTooling.toVersion( previousVersion ) : null;
                final Common.GlobalProperty globalProperty = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName('GP800');
                
                if( ( globalProperty != null && String.isNotBlank(globalProperty.value) && globalProperty.value.equalsIgnoreCase('true') ) ||
                  ( systemVersion != null && systemVersion.major() < LAST_METADATA_CHANGE_MAJOR_VERSION ) ) {
                    
                    executeAutoConfig = 'true';
                	autoConfigStatus = 'TODO';
                }

                // Reset values for each install/upgrade
                CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP800', executeAutoConfig);
                CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP801', autoConfigStatus);
                CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP802', '');
            }
            
            CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP605', 'f9c8bd26b72a74ebe814d644c139e3e8FFFFNRAL');
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createGlobalProperties() : Failed to create Global Properties. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to create Global Properties. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Global Properties : Failed');
            installLogger.logDetail('Failed to create Global Properties. Error = ' + e.getMessage());
        }
        finally {

            System.debug( LoggingLevel.DEBUG, 'createGlobalProperties() - exit');
            installLogger.logDetail('End of Processing Global Properties');
        }
    }

    /**
     * Private method to add default allowed core objects if not exists.
     *
     * @param allGlobalPropertyMap list of global properties from org.
     */
    private static List<SVMXA360__CONF_CSET_GlobalProperties__c> createCustomSettings( final Map<String, SVMXA360__CONF_CSET_GlobalProperties__c> allGlobalPropertyMap, final Map<String,String> settingsMap, final String key ) {

        System.debug( LoggingLevel.DEBUG, 'createCustomSettings() - enter');

        final List<SVMXA360__CONF_CSET_GlobalProperties__c> newCustomSettings = new List<SVMXA360__CONF_CSET_GlobalProperties__c>();

        try {

            for( String name : settingsMap.keySet() ) {

            	// Create Custom Setting if not exists.
                if( !allGlobalPropertyMap.containsKey(name) ) {

                    final SVMXA360__CONF_CSET_GlobalProperties__c customSetting = new SVMXA360__CONF_CSET_GlobalProperties__c();
                    customSetting.Name = name;
                    customSetting.SVMXA360__Key__c = key;
                    customSetting.SVMXA360__Value__c = settingsMap.get(name);

                    newCustomSettings.add(customSetting);

                    System.debug( LoggingLevel.INFO, 'createCustomSettings() : Created Custom Setting. Name= ' + name );
                }
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createCustomSettings() : Failed to create custom settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createCustomSettings() - exit');
        }

        return newCustomSettings;
    }

    private static SVMXA360__CONF_WarrantyConfig__c createDefaultWarrantyConfigRules(){

        System.debug( LoggingLevel.DEBUG, 'createDefaultWarrantyConfigRules() - enter');
        installLogger.logDetail('Started Processing Warranty Config Rules');

        SVMXA360__CONF_WarrantyConfig__c warrantyConfigRecord;
        try {
            List<SVMXA360__CONF_WarrantyConfig__c> lstWarrantyConfigRecords = Database.query('Select ' + COMM_Constants.WARRANTY_CONFIG_FIELDS + ' from SVMXA360__CONF_WarrantyConfig__c where SVMXA360__RuleScope__c = \'Global\' limit 1');
            if(lstWarrantyConfigRecords.isEmpty()){
                warrantyConfigRecord = new SVMXA360__CONF_WarrantyConfig__c();
                warrantyConfigRecord.SVMXA360__AutoWarrOnCreateAsset__c = true;
                warrantyConfigRecord.SVMXA360__AutoWarrOnUpdateAsset__c = true;
                warrantyConfigRecord.SVMXA360__EffectiveFromConfig__c = '{"Manufacture Date":"ManufactureDate","Install Date":"InstallDate","Purchase Date":"PurchaseDate"}';
                warrantyConfigRecord.SVMXA360__RuleScope__c = 'Global';
                warrantyConfigRecord.SVMXA360__RuleID__c = 'GBL_WARR_RULE';
                warrantyConfigRecord.SVMXA360__RuleTitle__c = 'Global Warranty Rule';
                List<SVMXA360__CONF_ObjectMapping__c> lstobjectMapping = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c where SVMXA360__SourceObjectAPIName__c = 'WarrantyTerm' and SVMXA360__TargetObjectAPIName__c = 'AssetWarranty' limit 1];
                if (!lstobjectMapping.isEmpty()) {
                    warrantyConfigRecord.SVMXA360__ObjectMapping__c = lstobjectMapping[0].Id;
                }

                SvmxDatabase.insertRecord(warrantyConfigRecord);
                installLogger.logSummary('Processing Warranty Config Rules : Success');
            } else{
                warrantyConfigRecord = lstWarrantyConfigRecords[0];
                System.debug(LoggingLevel.INFO, ' Warranty Configuration record already exists ' + warrantyConfigRecord);
            }
        }

        catch (Exception e) {

            System.debug(LoggingLevel.ERROR, ' Exception in querying or creating record ' + e.getMessage());

            installLogger.applicationLog( 'Failed to create Warranty Rules. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Warranty Config Rules : Failed');
            installLogger.logDetail('Exception in querying or creating record ' + e.getMessage());
        }
        finally {

            System.debug( LoggingLevel.DEBUG, 'createDefaultWarrantyConfigRules() - exit');
            installLogger.logDetail('End of Processing Warranty Config Rules');
        }

        return warrantyConfigRecord;
    }

    private static SVMXA360__CONF_DepotFinderRule__c createDefaultDepotFinderSetting() {

        System.debug( LoggingLevel.DEBUG, 'createDefaultDepotFinderSetting() - enter');
        installLogger.logDetail('Started Processing Depot Finder Setting');

        SVMXA360__CONF_DepotFinderRule__c depotFinderSetting;

        try {

            List<SVMXA360__CONF_DepotFinderRule__c> lstDepotFinderSettings = [Select Id,Name,SVMXA360__DeveloperName__c,SVMXA360__EnableDepotFinder__c,SVMXA360__RuleScope__c,SVMXA360__ObjectAPIName__c from SVMXA360__CONF_DepotFinderRule__c where SVMXA360__RuleScope__c = 'Global' and SVMXA360__ObjectAPIName__c = 'ReturnOrder' limit 1];
            if (lstDepotFinderSettings.isEmpty()) {
                depotFinderSetting = new SVMXA360__CONF_DepotFinderRule__c();
                depotFinderSetting.SVMXA360__DeveloperName__c = 'GBL_DPOT_RULE';
                depotFinderSetting.SVMXA360__EnableDepotFinder__c = false;
                depotFinderSetting.SVMXA360__RuleScope__c = 'Global';
                depotFinderSetting.SVMXA360__ObjectAPIName__c = 'ReturnOrder';
                SvmxDatabase.insertRecord(depotFinderSetting);
                installLogger.logSummary('Processing Depot Finder Setting : Success');
            } else{
                depotFinderSetting = lstDepotFinderSettings[0];
                System.debug(LoggingLevel.INFO, ' Depot Finder record already exists ' + depotFinderSetting);
            }
        }

        catch( Exception e ) {

            System.debug(LoggingLevel.ERROR, ' Exception in querying or creating record ' + e.getMessage());

            installLogger.applicationLog( 'Failed to create Depot Finder Setting. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Depot Finder Setting : Failed');
            installLogger.logDetail('Exception in querying or creating record ' + e.getMessage());
        }
        finally {

            System.debug( LoggingLevel.DEBUG, 'createDefaultDepotFinderSetting() - exit');
            installLogger.logDetail('End of Processing Default Depot Finder Setting');
        }

        return depotFinderSetting;
    }

    private static void createDefaultEntitlementSetting() {

        System.debug( LoggingLevel.DEBUG, 'createDefaultEntitlementSetting() - enter');
        installLogger.logDetail('Started Processing Default Entitlement Setting');

        try {

            List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettingList = (List<SVMXA360__CONF_EntitlementSettings__c>) SvmxDatabase.query([SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE SVMXA360__DeveloperName__c = 'EVER_Common_Entitlement_Setting']);

            if(entitlementSettingList.size() == 0) {

               	SVMXA360__CONF_EntitlementSettings__c entitlementSetting = new SVMXA360__CONF_EntitlementSettings__c();
                entitlementSetting.SVMXA360__DeveloperName__c = 'EVER_Common_Entitlement_Setting';
                entitlementSetting.SVMXA360__AssignEntitledService__c = false;
                entitlementSetting.SVMXA360__InheritServiceOnWorkOrder__c = false;
                entitlementSetting.SVMXA360__InheritServiceOnReturnOrder__c  = false;
                entitlementSetting.SVMXA360__AssignPricebook__c  = false;
                entitlementSetting.SVMXA360__AdjustServiceThreshold__c = false;
                entitlementSetting.SVMXA360__AdjustVisitCountAssignedObject__c  = 'Case';
                entitlementSetting.RecordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();

                SvmxDatabase.insertRecord(entitlementSetting);

                installLogger.logSummary('Processing Default Entitlement Setting : Success');
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createDefaultEntitlementSetting() : Failed to create Default Entitlement Setting. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to create Default Entitlement Setting. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Default Entitlement Setting : Failed');
            installLogger.logDetail('Failed to create Entitlement Setting. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createDefaultEntitlementSetting() - exit');
            installLogger.logDetail('End of Processing Default Entitlement Setting');
        }
    }

    private static void updateEntitlementSetting() {

        System.debug( LoggingLevel.DEBUG, 'updateEntitlementSetting() - enter');
        installLogger.logDetail('Started Processing Entitlement Settings Record Type Update');

        try {

            List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettingList = (List<SVMXA360__CONF_EntitlementSettings__c>) SvmxDatabase.query([SELECT Id, SVMXA360__OnHoldEntitlements__c, RecordTypeId  FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = null OR SVMXA360__OnHoldEntitlements__c = null]);

            if( !entitlementSettingList.isEmpty() ) {

                Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();

                for( SVMXA360__CONF_EntitlementSettings__c entitlementSetting : entitlementSettingList ) {
                    entitlementSetting.RecordTypeId = entitlementSetting.RecordTypeId == null ? recordTypeId : entitlementSetting.RecordTypeId;
                    entitlementSetting.SVMXA360__OnHoldEntitlements__c = entitlementSetting.SVMXA360__OnHoldEntitlements__c != null ? entitlementSetting.SVMXA360__OnHoldEntitlements__c : false;
                }

                SvmxDatabase.updateRecord(entitlementSettingList);

                installLogger.logSummary('Processing Entitlement Settings Record Type Update : Success');
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'updateEntitlementSetting() : Failed to update Entitlement Setting. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to update Entitlement Setting. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Entitlement Settings Record Type Update : Failed');
            installLogger.logDetail('Failed to update Entitlement Setting Record Type. Error = ' + e.getMessage());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateEntitlementSetting() - exit');
            installLogger.logDetail('End of Processing Entitlement Settings Record Type Update');
        }
    }

    /**
     * A360TOOL-1113 Private method to update wizard steps developer name.
     *
     */
    private static void updateWizardStepDeveloperName() {

        System.debug( LoggingLevel.DEBUG, 'updateWizardStepDeveloperName() - enter');
        installLogger.logDetail('Started Processing Wizard Step Developer Name Update');
        try {
            List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = (List<SVMXA360__CONF_ProcessWizardStep__c>) SvmxDatabase.query([SELECT Id,Name,SVMXA360__DeveloperName__c,SVMXA360__ProcessWizard__r.SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ProcessWizardStep__c WHERE SVMXA360__DeveloperName__c = null]);
            if(wizardStepList != null && wizardStepList.size() > 0) {

                for(SVMXA360__CONF_ProcessWizardStep__c wizardStep : wizardStepList){
                    wizardStep.SVMXA360__DeveloperName__c = wizardStep.SVMXA360__ProcessWizard__r.SVMXA360__DeveloperName__c + '_' + wizardStep.Name?.replace(' ', '_');
                    wizardStep.SVMXA360__DeveloperName__c = normalizeDeveloperName(wizardStep.SVMXA360__DeveloperName__c);
                }

                SvmxDatabase.updateRecord(wizardStepList);
                installLogger.logSummary('Processing Wizard Step Developer Name Update : Success');
            }

        } catch (Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'updateWizardStepDeveloperName() : Failed to update wizard step developer name. Error= ' + e.getStackTraceString() );

            installLogger.applicationLog( 'Failed to update wizard step developer name. Error= ' + e.getMessage() );

            installLogger.logSummary('Processing Wizard Step Developer Name Update : Failed');
            installLogger.logDetail('Failed to update Wizard Step Developer Name. Error = ' + e.getMessage());
        } finally {
            
            System.debug( LoggingLevel.DEBUG, 'updateWizardStepDeveloperName() - exit');
            installLogger.logDetail('End of Processing Wizard Step Developer Name Update');
        }
    }

    private static String normalizeDeveloperName(String inputValue) {
        if (inputValue != null && inputValue.length() > 140) {
            inputValue = inputValue.substring(0, 140);
        }
    
        return inputValue;
    }

    public boolean isUpgrade() {
        return this.isUpgradeInstall;
    }

    public void setIsUpgrade (boolean upgrade) {
        this.isUpgradeInstall = upgrade;
    }

    /**
     * Private method to add default feature access records if not exists.
     *
     * @param featureAccessMap list of feature access records from org.
     */
    /*private List<SVMXA360__CONF_CSET_FeatureAccess__c> createFeatureAccess( final Map<String, SVMXA360__CONF_CSET_FeatureAccess__c> featureAccessMap ) {

        System.debug( LoggingLevel.DEBUG, 'createFeatureAccess() - enter');

        final List<SVMXA360__CONF_CSET_FeatureAccess__c> newFeatureAccess = new List<SVMXA360__CONF_CSET_FeatureAccess__c>();

        try {
            for( String name : SvmxLicense.DefaultFeatureAccessMap.keySet() ) {

                // Create Custom Setting if not exists.
                SVMXA360__CONF_CSET_FeatureAccess__c featureAccess;
                if( featureAccessMap.containsKey(name) ) {
                    featureAccess = featureAccessMap.get(name);
                } else {
                    featureAccess = new SVMXA360__CONF_CSET_FeatureAccess__c();
                    featureAccess.Name = name;
                }
                featureAccess.SVMXA360__SettingValue__c = SvmxLicense.DefaultFeatureAccessMap.get(name);
                newFeatureAccess.add(featureAccess);

                System.debug( LoggingLevel.INFO, 'createFeatureAccess() : Created Custom Settings. featureAccess= ' + featureAccess );
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createFeatureAccess() : Failed to create Custom Settings record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createFeatureAccess() - exit - newFeatureAccess:' + newFeatureAccess);
        }
        return newFeatureAccess;
    }*/
}