/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/update entitlement settings.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       13 Jul 2020     Created.
 * A360CE-746   Ramachandra Mohan       28 Mar 2021     Include Fully Consumed Services.
 *****************************************************************************************************/
public with sharing class ADM_EntitlementSettingsManager {

    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_EntitlementSettingsManager instance;

    private static List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettingList;

    // List of unsupported stack ranking fields.
    private final static Set<String> unsupportedFields = new Set<String>{
        'BillingLatitude',
        'BillingLongitude',
        'ShippingLatitude', 
        'ShippingLongitude',
        'LastReferencedDate', 
        'LastViewedDate',
        'LineItemCount', 
        'ShippingHandling',
        'SystemModstamp',
        'Tax'
    };

    // Static string variable to hold record type Common configuration
    public static final String RECORD_TYPE_COMMON_CONFIGURATION = 'CommonConfiguration';

    // Static string variable to hold record type Object configuration
    public static final String RECORD_TYPE_OBJECT_CONFIGURATION = 'ObjectConfiguration';

    /**
     * Static method to retrieve instance of this class. Only one instance of
     * this class will be created per transaction.
     */
    public static ADM_EntitlementSettingsManager getInstance() {

        if( instance == null ) {
            instance = new ADM_EntitlementSettingsManager();
        }

        return instance;
    }

    /**
     * This method is used to retrieve all the entitlement Settingss.
     *
     * @return Returns List of all entitlement settings exists in the database.
     */
    public List<Adm.EntitlementSettings> getAllEntitlementSettings() {

        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - enter' );

        List<Adm.EntitlementSettings> entitlementSettingsList = new List<Adm.EntitlementSettings>();

        try {

            // Retrieve all entitlement Settingss
            List<SVMXA360__CONF_EntitlementSettings__c > entitlementSettingsRecordList = getAllEntitlementSettingsRecords();

            if( entitlementSettingsRecordList.size() == 0 ) {
                entitlementSettingsRecordList = createDefaultSettingsRecords();
            }

            if( entitlementSettingsRecordList.size() > 0 ) {

                // Create entitlement Settings wrapper for each retrieved entitlement Settings records.
                for( SVMXA360__CONF_EntitlementSettings__c  entitlementSettingsRecord : entitlementSettingsRecordList ) {
                    entitlementSettingsList.add( createEntitlementSettings( entitlementSettingsRecord ) );
                }

                System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() : Retrieved all entitlement settings' );
            } else {
                System.debug( LoggingLevel.WARN, 'getAllEntitlementSettings() : No entitlement settings found');
            }
        }

        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAllEntitlementSettings() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - exit; entitlementSettingsList.size()= ' + entitlementSettingsList.size() );
        }

        return entitlementSettingsList;
    }

    /**
     * This method is used to retrieve all the entitlement Settingss.
     *
     * @param objectName Object name for which entitlement settings to be returned.
     * @return Returns entitlement settings exists in the database.
     */
    public Adm.EntitlementSettings getEntitlementSettings( final String objectName ) {

        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - enter' );

        Adm.EntitlementSettings entitlementSettings;

        try {

            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {

                System.debug( LoggingLevel.ERROR, 'getEntitlementSettings() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            // Retrieve all entitlement Settingss
            final List<SVMXA360__CONF_EntitlementSettings__c > entitlementSettingsRecordList = getEntitlementSettingsRecords(objectName);

            if( entitlementSettingsRecordList.size() > 0 ) {

                entitlementSettings = createEntitlementSettings( entitlementSettingsRecordList.get(0) );
                System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() : Retrieved all entitlement settings' );
            } else {
                System.debug( LoggingLevel.WARN, 'getEntitlementSettings() : No entitlement settings found');
            }
        }

        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getEntitlementSettings() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - exit; entitlementSettings= ' + entitlementSettings );
        }

        return entitlementSettings;
    }

    public Adm.CommonEntitlementSettings getCommonEntitlementSetting() {

        System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() - enter' );

        Adm.CommonEntitlementSettings entitlementSettings;

        try {

            final List<SVMXA360__CONF_EntitlementSettings__c > entitlementSettingsRecordList = getCommonEntitlementSettingsRecord();

            if( entitlementSettingsRecordList.size() > 0 ) {

                entitlementSettings = createCommonEntitlementSettings( entitlementSettingsRecordList.get(0) );
                System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() : Retrieved all entitlement settings' );
            }
        }

        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getCommonEntitlementSetting() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() - exit; entitlementSettings= ' + entitlementSettings );
        }

        return entitlementSettings;
    }

    public List<String> getUnsupportedStackRankingFields() {

        System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - enter' );

        List<String> unsupportedStackRankingFields = new List<String>();

        try {

            unsupportedStackRankingFields.addAll(unsupportedFields);
            
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getUnsupportedStackRankingFields() : Failed to get unsupported fields. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - exit; unsupportedStackRankingFields= ' + unsupportedStackRankingFields );
        }

        return unsupportedStackRankingFields;
    }

    /**
     * This method is used to save requested entitlement settings. If entitlement id not exists then,
     * new entitlement Settings record will be created otherwise, existing entitlement Settings will be updated.
     *
     * @param entitlementSettings Entitlement Settings wrapper instance to be created/updated.
     *
     * @return Returns Adm.EntitlementSettings with created/updated record details.
     */
    public Adm.EntitlementSettings saveEntitlementSettings( final Adm.EntitlementSettings entitlementSettings ) {

        System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - enter; entitlementSettings= ' + entitlementSettings );

        Savepoint sPoint = Database.setSavepoint();

        try {

            // Verify request for valid entitlement Settings informations.
            if( entitlementSettings == null || String.isBlank( entitlementSettings.objectAPIName ) ) {

                System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Invalid request parameters. entitlementSettings= ' + entitlementSettings );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }


            // Upsert entitlement Settings record.
            final SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord = (SVMXA360__CONF_EntitlementSettings__c) SvmxDatabase.upsertRecord(createEntitlementSettingsRecord(entitlementSettings));

            System.debug( LoggingLevel.INFO, 'saveEntitlementSettings() : Saved Entitlement Settings. Name= ' + entitlementSettingsRecord.Name );

            // Update entitlement Settings id and sequence in the response.
            entitlementSettings.id = entitlementSettingsRecord.id;
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            Database.rollback( sPoint );

            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save Entitlement Settings. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            Database.rollback( sPoint );

            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save Entitlement Settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - exit; entitlementSettings= ' + entitlementSettings );
        }

        return entitlementSettings;
    }


    /**
     * This method is used to save requested entitlement settings. If entitlement id not exists then,
     * new entitlement Settings record will be created otherwise, existing entitlement Settings will be updated.
     *
     * @param entitlementSettings Entitlement Settings wrapper instance to be created/updated.
     *
     * @return Returns Adm.EntitlementSettings with created/updated record details.
     */
    public Adm.CommonEntitlementSettings saveCommonEntitlementSettings( final Adm.CommonEntitlementSettings commonEntitlementSettings ) {

        System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - enter; entitlementSettings= ' + commonEntitlementSettings );

        Savepoint sPoint = Database.setSavepoint();

        try {

            // Verify request for valid entitlement Settings informations.
            if( commonEntitlementSettings == null || ( commonEntitlementSettings.adjustServiceThreshold == true && String.isBlank(commonEntitlementSettings.adjustVisitCountAssignedObject) ) ) {

                System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Invalid request parameters. entitlementSettings= ' + commonEntitlementSettings );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            // Upsert entitlement Settings record.
            final SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord = (SVMXA360__CONF_EntitlementSettings__c) SvmxDatabase.upsertRecord(createCommonEntitlementSettingsRecord(commonEntitlementSettings));

            System.debug( LoggingLevel.INFO, 'saveEntitlementSettings() : Saved Entitlement Settings. entitlementSettingsRecord= ' + entitlementSettingsRecord );

            // Update entitlement Settings id and sequence in the response.
            commonEntitlementSettings.id = entitlementSettingsRecord.id;
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            Database.rollback( sPoint );

            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save Entitlement Settings. Error= ' + e.getMessage() + e.getStackTraceString());
            throw e;
        }
        catch( Exception e ) {

            Database.rollback( sPoint );

            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save Entitlement Settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - exit; entitlementSettings= ' + commonEntitlementSettings );
        }

        return commonEntitlementSettings;
    }

    /**
     * This method is used to retrieve all entitlement Settings records.
     *
     * @returns Returns list of entitlement Settings records.
     */
    public List<SVMXA360__CONF_EntitlementSettings__c > getAllEntitlementSettingsRecords() {

        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettingsRecords() - enter');

        List<SVMXA360__CONF_EntitlementSettings__c > entitlementSettingsRecordList = new List<SVMXA360__CONF_EntitlementSettings__c >();

        try {
            Id recordTypeId = getRecordTypeInfosByDeveloperName(RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
            /* sfge-disable-next-line ApexFlsViolationRule */
            entitlementSettingsRecordList = entitlementSettingsRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__AccountAPIName__c, SVMXA360__AssetAPIName__c, SVMXA360__AllowOverrideSettings__c, SVMXA360__IncludeFullyConsumedServices__c, SVMXA360__ExpiredEntitlements__c, SVMXA360__FutureEntitlements__c, SVMXA360__Scope__c, SVMXA360__DeveloperName__c, SVMXA360__CoveredBy__c, SVMXA360__IncludeParentAsset__c, SVMXA360__IncludeRootAsset__c, SVMXA360__MatchAccount__c, SVMXA360__ObjectAPIName__c, SVMXA360__DefaultBillingType__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__FutureEntitlementsDuration__c, SVMXA360__ExpiredEntitlementsDuration__c, SVMXA360__OnHoldEntitlements__c FROM SVMXA360__CONF_EntitlementSettings__c WHERE  RecordTypeId = :recordTypeId]);
        }
        catch( Exception e ) {
            

            System.debug( LoggingLevel.ERROR, 'getAllEntitlementSettingsRecords() : Failed to retrieve Entitlement Settingss. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettingsRecords() - exit; entitlementSettingsRecordList.size()= ' + entitlementSettingsRecordList.size() );
        }

        return entitlementSettingsRecordList;
    }

    /**
     * This method is used to retrieve all entitlement Settings records.
     *
     * @param objectName object API name for which entitlement settings to be retrieved.
     * @returns Returns list of entitlement Settings records.
     */
    public List<SVMXA360__CONF_EntitlementSettings__c> getEntitlementSettingsRecords( final String objectName ) {

        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettingsRecords() - enter; objectName= ' + objectName);

        List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettingsRecordList = new List<SVMXA360__CONF_EntitlementSettings__c>();

        try {

            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {

                System.debug( LoggingLevel.ERROR, 'getEntitlementSettingsRecords() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            Id recordTypeId = getRecordTypeInfosByDeveloperName(RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
            /* sfge-disable-next-line ApexFlsViolationRule */
            entitlementSettingsRecordList = entitlementSettingsRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__AccountAPIName__c, SVMXA360__AssetAPIName__c, SVMXA360__AllowOverrideSettings__c, SVMXA360__IncludeFullyConsumedServices__c, SVMXA360__ExpiredEntitlements__c, SVMXA360__FutureEntitlements__c, SVMXA360__Scope__c, SVMXA360__DeveloperName__c, SVMXA360__CoveredBy__c, SVMXA360__IncludeParentAsset__c, SVMXA360__IncludeRootAsset__c, SVMXA360__MatchAccount__c, SVMXA360__ObjectAPIName__c, SVMXA360__DefaultBillingType__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__FutureEntitlementsDuration__c, SVMXA360__ExpiredEntitlementsDuration__c, SVMXA360__OnHoldEntitlements__c FROM SVMXA360__CONF_EntitlementSettings__c WHERE SVMXA360__ObjectAPIName__c = :objectName AND RecordTypeId = :recordTypeId]);

        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getEntitlementSettingsRecords() : Failed to retrieve Entitlement Settingss. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementSettingsRecords() - exit; entitlementSettingsRecordList.size()= ' + entitlementSettingsRecordList.size() );
        }

        return entitlementSettingsRecordList;
    }

    /**
     * This method is used to retrieve all entitlement Settings records.
     *
     * @param objectName object API name for which entitlement settings to be retrieved.
     * @returns Returns list of entitlement Settings records.
     */
    public List<SVMXA360__CONF_EntitlementSettings__c> getCommonEntitlementSettingsRecord() {

        try {

            if( commonEntitlementSettingList == null ) {

                Id recordTypeId = getRecordTypeInfosByDeveloperName(RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
                /* sfge-disable-next-line ApexFlsViolationRule */
                commonEntitlementSettingList = SvmxDatabase.query( [SELECT Name, SVMXA360__AssignEntitledService__c, 
                SVMXA360__AssignPricebook__c, SVMXA360__InheritServiceOnWorkOrder__c, 
                SVMXA360__InheritServiceOnReturnOrder__c, 
                SVMXA360__AdjustServiceThreshold__c, 
                SVMXA360__AdjustVisitCountAssignedObject__c, 
                SVMXA360__ContractStackRankingFieldAPIName__c, 
                SVMXA360__ContractStackRankingOrder__c,
                SVMXA360__ApplyStackRanking__c, SVMXA360__WarrantyStackRankingFieldAPIName__c,
                SVMXA360__WarrantyStackRankingOrder__c  FROM 
                SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId]);
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getCommonEntitlementSettingsRecords() : Failed to retrieve Entitlement Settingss. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSettingsRecords() - exit; commonEntitlementSettingList= ' + commonEntitlementSettingList );
        }

        return commonEntitlementSettingList;
    }

    /**
     * This method is used to retrieve the RecordTypeInfo of given objects record type..
     *
     * @param objectName Object API name of the Record type.
     * @param recordTypeName Record type name whose we we want Id.
     *
     * @returns Returns Schema.RecordTypeInfo for the given object's record type.
     */
    public Schema.RecordTypeInfo getRecordTypeInfosByDeveloperName( final String recordTypeName ) {

        System.debug( LoggingLevel.DEBUG, 'getRecordTypeInfosByDeveloperName() - enter;');

        Schema.RecordTypeInfo recordTypeInfo;

        try {
            recordTypeInfo = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getRecordTypeInfosByDeveloperName() : Failed to fetch record type info. Error= ' + e.getStackTraceString() );
            throw e;
        }

        System.debug( LoggingLevel.DEBUG, 'getRecordTypeInfosByDeveloperName() - exit;');

        return recordTypeInfo;
    }

    /**
     * This method is used to create entitlement Settings wrapper for requested entitlement Settings record.
     *
     * @param entitlementSettingsRecord Entitlement Settings sobject record from which wrapper to be created.
     *
     * @return Returns Adm.EntitlementSettings instance with populated values from entitlementSettingsRecord.
     */
    private Adm.EntitlementSettings createEntitlementSettings( final SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord ) {

        System.debug( LoggingLevel.DEBUG, 'createEntitlementSettings() - enter; entitlementSettingsRecord= ' + entitlementSettingsRecord);

        Adm.EntitlementSettings entitlementSettings = new Adm.EntitlementSettings();
        entitlementSettings.id = entitlementSettingsRecord.id;
        entitlementSettings.name = entitlementSettingsRecord.Name;
        entitlementSettings.scope = entitlementSettingsRecord.SVMXA360__Scope__c;
        entitlementSettings.developerName = entitlementSettingsRecord.SVMXA360__DeveloperName__c;
        entitlementSettings.defaultBillingType = entitlementSettingsRecord.SVMXA360__DefaultBillingType__c;
        entitlementSettings.objectAPIName = entitlementSettingsRecord.SVMXA360__ObjectAPIName__c;
        entitlementSettings.coveredBy = entitlementSettingsRecord.SVMXA360__CoveredBy__c;
        entitlementSettings.assetAPIName = entitlementSettingsRecord.SVMXA360__AssetAPIName__c;
        entitlementSettings.accountAPIName = entitlementSettingsRecord.SVMXA360__AccountAPIName__c;
        entitlementSettings.allowOverrideSettings = entitlementSettingsRecord.SVMXA360__AllowOverrideSettings__c;
        entitlementSettings.expiredEntitlements = entitlementSettingsRecord.SVMXA360__ExpiredEntitlements__c;
        entitlementSettings.futureEntitlements = entitlementSettingsRecord.SVMXA360__FutureEntitlements__c;
        entitlementSettings.includeParentAsset = entitlementSettingsRecord.SVMXA360__IncludeParentAsset__c;
        entitlementSettings.includeRootAsset = entitlementSettingsRecord.SVMXA360__IncludeRootAsset__c;
        entitlementSettings.matchAccount = entitlementSettingsRecord.SVMXA360__MatchAccount__c;
        entitlementSettings.fullyConsumedServices = entitlementSettingsRecord.SVMXA360__IncludeFullyConsumedServices__c != null ? entitlementSettingsRecord.SVMXA360__IncludeFullyConsumedServices__c : true;
        entitlementSettings.lastModifiedDate = entitlementSettingsRecord.LastModifiedDate;
        entitlementSettings.lastModifiedBy = entitlementSettingsRecord.LastModifiedBy.Name;
        entitlementSettings.futureEntitlementDuration = entitlementSettingsRecord.SVMXA360__FutureEntitlementsDuration__c;
        entitlementSettings.expiredEntitlementDuration = entitlementSettingsRecord.SVMXA360__ExpiredEntitlementsDuration__c;
        entitlementSettings.onHoldEntitlements = entitlementSettingsRecord.SVMXA360__OnHoldEntitlements__c  != null ? entitlementSettingsRecord.SVMXA360__OnHoldEntitlements__c : true;

        System.debug( LoggingLevel.DEBUG, 'createEntitlementSettings() - exit; entitlementSettings= ' + entitlementSettings);

        return entitlementSettings;
    }

    /**
     * This method is used to create entitlement Settings wrapper for requested entitlement Settings record.
     *
     * @param entitlementSettingsRecord Entitlement Settings sobject record from which wrapper to be created.
     *
     * @return Returns Adm.EntitlementSettings instance with populated values from entitlementSettingsRecord.
     */
    private Adm.CommonEntitlementSettings createCommonEntitlementSettings( final SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord ) {

        System.debug( LoggingLevel.DEBUG, 'createCommonEntitlementSettings() - enter; entitlementSettingsRecord= ' + entitlementSettingsRecord);

        Adm.CommonEntitlementSettings entitlementSettings = new Adm.CommonEntitlementSettings();
        entitlementSettings.id = entitlementSettingsRecord.id;
        entitlementSettings.name = entitlementSettingsRecord.Name;
        entitlementSettings.assignEntitledService = entitlementSettingsRecord.SVMXA360__AssignEntitledService__c;
        entitlementSettings.assignPricebook = entitlementSettingsRecord.SVMXA360__AssignPricebook__c;
        entitlementSettings.inheritServiceOnWorkOrder = entitlementSettingsRecord.SVMXA360__InheritServiceOnWorkOrder__c;
        entitlementSettings.inheritServiceOnReturnOrder = entitlementSettingsRecord.SVMXA360__InheritServiceOnReturnOrder__c;
        entitlementSettings.adjustServiceThreshold = entitlementSettingsRecord.SVMXA360__AdjustServiceThreshold__c;
        entitlementSettings.adjustVisitCountAssignedObject = entitlementSettingsRecord.SVMXA360__AdjustVisitCountAssignedObject__c;
        entitlementSettings.applyStackRanking = entitlementSettingsRecord.SVMXA360__ApplyStackRanking__c;
        entitlementSettings.contractStackRankingAPIName = entitlementSettingsRecord.SVMXA360__ContractStackRankingFieldAPIName__c;
        entitlementSettings.contractStackRankingOrder = entitlementSettingsRecord.SVMXA360__ContractStackRankingOrder__c;
        entitlementSettings.warrantyStackRankingAPIName = entitlementSettingsRecord.SVMXA360__WarrantyStackRankingFieldAPIName__c;
        entitlementSettings.warrantyStackRankingOrder = entitlementSettingsRecord.SVMXA360__WarrantyStackRankingOrder__c;

        System.debug( LoggingLevel.DEBUG, 'createCommonEntitlementSettings() - exit; entitlementSettings= ' + entitlementSettings);

        return entitlementSettings;
    }


    /**
     * Private method to create entitlement Settings record.
     *
     * @param entitlementSettings Entitlement Settings wrappef for which SObject to be created.
     * @return Returns SVMXA360__CONF_EntitlementSettings__c sobject with populated values from entitlementSettings.
     */
    private SVMXA360__CONF_EntitlementSettings__c createEntitlementSettingsRecord( final Adm.EntitlementSettings entitlementSettings ) {

        System.debug( LoggingLevel.DEBUG, 'createEntitlementSettingsRecord() - enter; entitlementSettings= ' + entitlementSettings);

        SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord = new SVMXA360__CONF_EntitlementSettings__c();

        if( String.isNotBlank( entitlementSettings.id ) ) {
            entitlementSettingsRecord.id = entitlementSettings.id;
        } else {
            entitlementSettingsRecord.SVMXA360__DeveloperName__c = entitlementSettings.developerName;
        }

        entitlementSettingsRecord.SVMXA360__Scope__c = entitlementSettings.scope;
        entitlementSettingsRecord.SVMXA360__ObjectAPIName__c = entitlementSettings.objectAPIName;
        entitlementSettingsRecord.SVMXA360__CoveredBy__c = entitlementSettings.coveredBy;
        entitlementSettingsRecord.SVMXA360__AssetAPIName__c = entitlementSettings.assetAPIName;
        entitlementSettingsRecord.SVMXA360__AccountAPIName__c = entitlementSettings.accountAPIName;
        entitlementSettingsRecord.SVMXA360__AllowOverrideSettings__c = entitlementSettings.allowOverrideSettings;
        entitlementSettingsRecord.SVMXA360__ExpiredEntitlements__c = entitlementSettings.expiredEntitlements != null ? entitlementSettings.expiredEntitlements : false;
        entitlementSettingsRecord.SVMXA360__FutureEntitlements__c = entitlementSettings.futureEntitlements != null ? entitlementSettings.futureEntitlements : false;
        entitlementSettingsRecord.SVMXA360__IncludeParentAsset__c = entitlementSettings.includeParentAsset != null ? entitlementSettings.includeParentAsset : false;
        entitlementSettingsRecord.SVMXA360__IncludeRootAsset__c = entitlementSettings.includeRootAsset != null ? entitlementSettings.includeRootAsset : false;
        entitlementSettingsRecord.SVMXA360__MatchAccount__c = entitlementSettings.matchAccount != null ? entitlementSettings.matchAccount : false;
        entitlementSettingsRecord.SVMXA360__IncludeFullyConsumedServices__c = entitlementSettings.fullyConsumedServices != null ? entitlementSettings.fullyConsumedServices : true;
        entitlementSettingsRecord.SVMXA360__DefaultBillingType__c = entitlementSettings.defaultBillingType;
        entitlementSettingsRecord.SVMXA360__FutureEntitlementsDuration__c = entitlementSettings.futureEntitlementDuration;
        entitlementSettingsRecord.SVMXA360__ExpiredEntitlementsDuration__c = entitlementSettings.expiredEntitlementDuration;
        entitlementSettingsRecord.SVMXA360__OnHoldEntitlements__c = entitlementSettings.onHoldEntitlements != null ? entitlementSettings.onHoldEntitlements : true;

        System.debug( LoggingLevel.DEBUG, 'createEntitlementSettingsRecord() - exit; entitlementSettingsRecord= ' + entitlementSettingsRecord);

        return entitlementSettingsRecord;
    }

    /**
     * This method is used to create entitlement Settings wrapper for requested entitlement Settings record.
     *
     * @param entitlementSettingsRecord Entitlement Settings sobject record from which wrapper to be created.
     *
     * @return Returns Adm.EntitlementSettings instance with populated values from entitlementSettingsRecord.
     */
    private SVMXA360__CONF_EntitlementSettings__c createCommonEntitlementSettingsRecord( final Adm.CommonEntitlementSettings entitlementSettings ) {

        System.debug( LoggingLevel.DEBUG, 'createCommonEntitlementSettingsRecord() - enter; entitlementSettings= ' + entitlementSettings);
        SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord = new SVMXA360__CONF_EntitlementSettings__c();
        entitlementSettingsRecord.id = entitlementSettings.id;
        entitlementSettingsRecord.SVMXA360__AssignEntitledService__c = entitlementSettings.assignEntitledService == null ? false : entitlementSettings.assignEntitledService;
        entitlementSettingsRecord.SVMXA360__AssignPricebook__c = entitlementSettings.assignPricebook == null ? false : entitlementSettings.assignPricebook;
        entitlementSettingsRecord.SVMXA360__InheritServiceOnWorkOrder__c = entitlementSettings.inheritServiceOnWorkOrder == null ? false : entitlementSettings.inheritServiceOnWorkOrder;
        entitlementSettingsRecord.SVMXA360__InheritServiceOnReturnOrder__c = entitlementSettings.inheritServiceOnReturnOrder == null ? false : entitlementSettings.inheritServiceOnReturnOrder;
        entitlementSettingsRecord.SVMXA360__AdjustServiceThreshold__c = entitlementSettings.adjustServiceThreshold == null ? false : entitlementSettings.adjustServiceThreshold;
        entitlementSettingsRecord.SVMXA360__AdjustVisitCountAssignedObject__c = entitlementSettings.adjustVisitCountAssignedObject;
        entitlementSettingsRecord.SVMXA360__ApplyStackRanking__c = entitlementSettings.applyStackRanking == null ? false : entitlementSettings.applyStackRanking;
        entitlementSettingsRecord.SVMXA360__ContractStackRankingFieldAPIName__c = entitlementSettings.contractStackRankingAPIName;
        entitlementSettingsRecord.SVMXA360__ContractStackRankingOrder__c = entitlementSettings.contractStackRankingOrder;
        entitlementSettingsRecord.SVMXA360__WarrantyStackRankingFieldAPIName__c = entitlementSettings.warrantyStackRankingAPIName;
        entitlementSettingsRecord.SVMXA360__WarrantyStackRankingOrder__c = entitlementSettings.warrantyStackRankingOrder;
        entitlementSettingsRecord.RecordTypeId = getRecordTypeInfosByDeveloperName(RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();

        if( entitlementSettings.id == null ){
            entitlementSettingsRecord.SVMXA360__DeveloperName__c = 'Common_Entitlement_Settings';
            entitlementSettingsRecord.SVMXA360__ObjectAPIName__c = 'Common_Entitlement_Settings';
        }

        System.debug( LoggingLevel.DEBUG, 'createCommonEntitlementSettingsRecord() - exit; entitlementSettings= ' + entitlementSettingsRecord);

        return entitlementSettingsRecord;
    }

    /**
     * Private method to create entitlement Settings record.
     *
     * @param entitlementSettings Entitlement Settings wrappef for which SObject to be created.
     * @return Returns SVMXA360__CONF_EntitlementSettings__c sobject with populated values from entitlementSettings.
     */
    private List<SVMXA360__CONF_EntitlementSettings__c> createDefaultSettingsRecords() {

        System.debug( LoggingLevel.FINEST, 'createDefaultSettingsRecords() - enter');

        List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettingsRecordList = new List<SVMXA360__CONF_EntitlementSettings__c>();

        entitlementSettingsRecordList.add(
            new SVMXA360__CONF_EntitlementSettings__c(
                SVMXA360__DeveloperName__c 			= 'Case_Entitlement_Settings',
                SVMXA360__ObjectAPIName__c 			= 'Case',
                SVMXA360__CoveredBy__c 				= 'Asset',
                SVMXA360__AssetAPIName__c			= 'AssetId',
                SVMXA360__AccountAPIName__c 		= 'AccountId',
                SVMXA360__AllowOverrideSettings__c 	= true,
                SVMXA360__MatchAccount__c 			= true,
                SVMXA360__IncludeFullyConsumedServices__c = true,
                RecordTypeId						= getRecordTypeInfosByDeveloperName(RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId()
            )
        );

        entitlementSettingsRecordList.add(
            new SVMXA360__CONF_EntitlementSettings__c(
                SVMXA360__DeveloperName__c 			= 'WorkOrder_Entitlement_Settings',
                SVMXA360__ObjectAPIName__c 			= 'WorkOrder',
                SVMXA360__CoveredBy__c 				= 'Asset',
                SVMXA360__AssetAPIName__c			= 'AssetId',
                SVMXA360__AccountAPIName__c 		= 'AccountId',
                SVMXA360__AllowOverrideSettings__c 	= true,
                SVMXA360__MatchAccount__c 			= true,
                SVMXA360__IncludeFullyConsumedServices__c  = true,
                RecordTypeId						= getRecordTypeInfosByDeveloperName(RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId()
            )
        );

        entitlementSettingsRecordList.add(
            new SVMXA360__CONF_EntitlementSettings__c(
                SVMXA360__DeveloperName__c 			= 'ReturnOrder_Entitlement_Settings',
                SVMXA360__ObjectAPIName__c 			= 'ReturnOrder',
                SVMXA360__CoveredBy__c 				= 'Asset',
                SVMXA360__AssetAPIName__c			= 'SVMXA360__AssetId__c',
                SVMXA360__AccountAPIName__c 		= 'AccountId',
                SVMXA360__AllowOverrideSettings__c 	= true,
                SVMXA360__MatchAccount__c 			= true,
                SVMXA360__IncludeFullyConsumedServices__c  = true,
                RecordTypeId						= getRecordTypeInfosByDeveloperName(RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId()
            )
        );

        entitlementSettingsRecordList = SvmxDatabase.insertRecord(entitlementSettingsRecordList);
        System.debug( LoggingLevel.FINEST, 'createDefaultSettingsRecords() - exit; entitlementSettingsRecordList= ' + entitlementSettingsRecordList);

        return entitlementSettingsRecordList;
    }

    /**
     * Private constructor to restrict creation of this class instance.
     */
    private ADM_EntitlementSettingsManager() {
    }
}