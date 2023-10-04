/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements methods to retrieve and save hierarchy configurations. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       25 May 2021     Created.
 *****************************************************************************************************/
public with sharing class ADM_HierarchyConfigManager {
    
    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final ADM_HierarchyConfigManager instance = new ADM_HierarchyConfigManager();

    /**
     * Public method to retrieve instance of this class.
     */
    public static ADM_HierarchyConfigManager getInstance() {
        return instance;
    }

    /**
     * This method is used to retrieve all hierarchy configurations with only 
     * header level information.
    */
    public List<Adm.HierarchyConfig> getAllHierarchyConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigurations() - enter' );
        
        List<Adm.HierarchyConfig> hierarchyConfigList = new List<Adm.HierarchyConfig>();
        
        try {
            List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords = getAllHierarchyConfigRecords();
            hierarchyConfigList = buildHierarchyConfigs(hierarchyConfigRecords);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllHierarchyConfigurations() : Failed to retrieve hierarchy configurations. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllHierarchyConfigurations() : Failed to retrieve hierarchy configurations. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigurations() - exit; hierarchyConfigList= ' + hierarchyConfigList );
        }
        
        return hierarchyConfigList;
    }

    /**
     * This method is used to retrieve details of the hierarchy configuration for requested id.
     */
    public Adm.HierarchyConfig getHierarchyConfigurationWithDetails( final String hierarchyConfigId ) {

        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationWithDetails() - enter; hierarchyConfigId= ' + hierarchyConfigId);

        Adm.HierarchyConfig hierarchyConfig;

        try {

            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }

            hierarchyConfig = getHierarchyConfiguration(hierarchyConfigId);

            hierarchyConfig.hierarchyConfigDetailList = getHierarchyConfigurationDetailList(hierarchyConfigId);

            hierarchyConfig.hierarchyConfigAccessList = getHierarchyConfigurationAccessList(hierarchyConfigId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationWithDetails() : Failed to retrieve hierarchy configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationWithDetails() : Failed to retrieve hierarchy configuration. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationWithDetails() - exit; hierarchyConfig= ' + hierarchyConfig);
        }

        return hierarchyConfig;
    }

    /**
     * This method is used to retrieve profile Ids and the associated configuration details for requested config id.
     */
    public List<Adm.ProfileInfo> getAssignedProfileDetails( final String hierarchyConfigId ) {

        System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - enter; hierarchyConfigId= ' + hierarchyConfigId);

        Map<Id,List<String>> profileDetailsMap = new Map<Id,List<String>>();
        List<Adm.ProfileInfo> profileInfoList = new List<Adm.ProfileInfo>();

        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_HierarchyConfigAccess__c> hierarchyConfigAccessList = SvmxDatabase.query([SELECT Id, SVMXA360__HierarchyConfigId__r.Name, 
                                                                                                          SVMXA360__ProfileId__c
                                                                                                          FROM SVMXA360__CONF_HierarchyConfigAccess__c WHERE 
                                                                                                          SVMXA360__HierarchyConfigId__c != :hierarchyConfigId]);
            
            if ( !hierarchyConfigAccessList.isEmpty() ) {

                Set<Id> profileIds = new Set<Id>();
                for (SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRec : hierarchyConfigAccessList) {
                    profileIds.add(hierarchyConfigAccessRec.SVMXA360__ProfileId__c);
                }
                /* sfge-disable-next-line ApexFlsViolationRule */
                List<Profile> profiles = SvmxDatabase.query([SELECT Id,Name from Profile where Id in:profileIds]);
                Map<Id,Profile> profileMap = new Map<Id,Profile>();
                profileMap.putAll(profiles);

                for (SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRecord : hierarchyConfigAccessList) {
                    if( !profileDetailsMap.containsKey(hierarchyConfigAccessRecord.SVMXA360__ProfileId__c) ) {
                        profileDetailsMap.put( hierarchyConfigAccessRecord.SVMXA360__ProfileId__c, new List<String>() );
                    }
                    
                    profileDetailsMap.get(hierarchyConfigAccessRecord.SVMXA360__ProfileId__c).add(hierarchyConfigAccessRecord.SVMXA360__HierarchyConfigId__r.Name); 
                }

                if ( !profileDetailsMap.isEmpty() ) {
                    Adm.ProfileInfo profileInfo;

                    for (Id profileId : profileDetailsMap.keySet()) {
                        profileInfo = new Adm.ProfileInfo();
                        profileInfo.profileId = profileId;
                        profileInfo.profileName = profileMap.get(profileId).Name;
                        profileInfo.hierarchyConfigNames = profileDetailsMap.get(profileId);
                        profileInfoList.add(profileInfo);
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetails() : Failed to retrieve profile details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetails() : Failed to retrieve profile details for the cofig Id. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - exit; profileInfoList= ' + profileInfoList);
        }

        return profileInfoList;
    }

    /**
     * This method is used to save the requested hierarchy configuration.
     */
    public Adm.HierarchyConfig saveHierarchyConfiguration( Adm.HierarchyConfig hierarchyConfig) {

        System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - enter; hierarchyConfig= ' + hierarchyConfig);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            if ( hierarchyConfig == null ) {
                System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Invalid request parameters. hierarchyConfig= ' + hierarchyConfig );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            saveHierarchyConfigurations( new List<Adm.HierarchyConfig> {hierarchyConfig} ).get(0);

        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to save Hierarchy configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to Hierarchy configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - exit; hierarchyConfig = '+hierarchyConfig);
        }

        return hierarchyConfig;
    }
    
    /**
     * This method is used to validate the requested hierarchy configuration.
     */
    public Adm.ValidationResult validateHierarchyConfiguration( Adm.HierarchyConfig hierarchyConfig, final List<Adm.ReferenceData> referenceDatas) {

        return validateHierarchyConfigurations( new List<Adm.HierarchyConfig> {hierarchyConfig}, referenceDatas ).get(0);
    }
    
    /**
     * This method is used to validate the requested hierarchy configuration.
     */
    public List<Adm.ValidationResult> validateHierarchyConfigurations( List<Adm.HierarchyConfig> hierarchyConfigList, final List<Adm.ReferenceData> referenceDatas) {

        System.debug( LoggingLevel.DEBUG, 'validateHierarchyConfiguration() - enter');
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {

            final Set<String> profileNameSet = new Set<String>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            for( Profile profileRecord : (List<Profile>) SvmxDatabase.query([SELECT Name FROM Profile]) ) {
                profileNameSet.add(profileRecord.Name);
            }
            
            final Set<String> expressionSet = new Set<String>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_Expression__c> expressionList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Expression__c] );
            
            for( SVMXA360__CONF_Expression__c expressionRecord : expressionList ) {
                expressionSet.add(expressionRecord.SVMXA360__DeveloperName__c);
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                
                for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                    
                    if( referenceData.configType == Adm.ConfigurationType.Expression ) {
                        expressionSet.add(configurationData.developerName);
                    }
                }
            }
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            
            for( Adm.HierarchyConfig hierarchyConfig : hierarchyConfigList ) {

                final Adm.ValidationResult validationResult = new Adm.ValidationResult();
                validationResults.add( validationResult );
                
                // Verify request for valid expression informations.
                if( hierarchyConfig == null || hierarchyConfig.hierarchyConfigDetailList == null ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateExpressions() : Invalid request parameters. hierarchyConfig= ' + hierarchyConfig );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }
            
                for( Adm.HierarchyConfigDetail hierarchyConfigDetail : hierarchyConfig.hierarchyConfigDetailList ) {
                    
                    if( !entityDefinitionMap.containsKey(hierarchyConfigDetail.objectAPIName) ) {
                        
                        try {
                            final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(hierarchyConfigDetail.objectAPIName);
                            entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                        }
                        catch( SvmxSystem.SvmxNestedException e ) {
                            
                            validationResult.addDetailResult( new Adm.ValidationResult(Adm.ConfigurationType.AssetHierarchy,'Object does not exists: ' + hierarchyConfigDetail.objectAPIName ));
                            continue;
                        }
                    }
                    
                    final Common.EntityDefinition entityDefinition = entityDefinitionMap.get(hierarchyConfigDetail.objectAPIName);
                    
                    for( Adm.HierarchyConfigField hierarchyConfigField : hierarchyConfigDetail.hierarchyConfigFieldList ) {
                        if( String.isNotBlank(hierarchyConfigField.fieldAPIName) && !entityDefinition.fieldDefinitionsByApiName.containsKey( hierarchyConfigField.fieldAPIName.toLowerCase() ) ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetHierarchy, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + hierarchyConfigField.fieldAPIName ) );
                        }
                    }
                    
                    if( String.isNotBlank( hierarchyConfigDetail.qualifyingCriteria ) && !expressionSet.contains(hierarchyConfigDetail.qualifyingCriteria) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetHierarchy, 'Qualifying Criteria does not exists : ' + hierarchyConfigDetail.qualifyingCriteria ) );
                    }
                    
                    if( String.isNotBlank( hierarchyConfigDetail.notificationCriteria ) && !expressionSet.contains(hierarchyConfigDetail.notificationCriteria) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetHierarchy, 'Notification Criteria does not exists : ' + hierarchyConfigDetail.notificationCriteria ) );
                    }
                }
                
                if( hierarchyConfig.hierarchyConfigAccessList != null ) {
                    
                    for( Adm.HierarchyConfigAccess hierarchyConfigAccess : hierarchyConfig.hierarchyConfigAccessList ) {
                        
                        if( !profileNameSet.contains(hierarchyConfigAccess.profileName) ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetHierarchy, 'Asset Hierarchy Name: ' + hierarchyConfig.name + ', Profile does not exists: ' + hierarchyConfigAccess.profileName ) );
                        }
                    }
                }
            }

        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateHierarchyConfiguration() : Failed to validate Hierarchy configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateHierarchyConfiguration() : Failed to validate Hierarchy configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateHierarchyConfiguration() - exit' );
        }
        
        return validationResults;
    }

    /**
     * This method is used to save the requested hierarchy configuration.
     */
    public List<Adm.HierarchyConfig> saveHierarchyConfigurations( List<Adm.HierarchyConfig>  hierarchyConfigs) {

        System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfigurations() - enter; hierarchyConfigs= ' + hierarchyConfigs);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            // Verify request for valid expression informations.
            if( hierarchyConfigs == null || hierarchyConfigs.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigurations() : Invalid request parameters. hierarchyConfigs= ' + hierarchyConfigs );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords = new List<SVMXA360__CONF_HierarchyConfig__c>();
            Set<Id> hierarchyConfigRecordIds = new Set<Id>();
            Integer defaultCount = 0;

            for (Adm.HierarchyConfig hierarchyConfig : hierarchyConfigs ){

                if ( hierarchyConfig.name == null || hierarchyConfig.developerName == null ) {
                    System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Invalid request parameters. hierarchyConfig= ' + hierarchyConfig );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }

                hierarchyConfigRecords.add(buildHierachyConfigRecord(hierarchyConfig));

                if( hierarchyConfig.id != null ) {
                    hierarchyConfigRecordIds.add (hierarchyConfig.id);
                }

                if( hierarchyConfig.defaultConfiguration == true) {

                    defaultCount += 1;

                    if (defaultCount > 1) {
                        System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Invalid arguments. hierarchyConfigs= ' + hierarchyConfigs );
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                    }
                }

            } 
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigDefaultRecords = SvmxDatabase.query([SELECT Id, SVMXA360__IsDefault__c 
                                                                                                        FROM SVMXA360__CONF_HierarchyConfig__c 
                                                                                                        WHERE SVMXA360__IsDefault__c = true AND 
                                                                                                        ID NOT IN:hierarchyConfigRecordIds]);

            if ( defaultCount == 1 && !hierarchyConfigDefaultRecords.isEmpty()) {

                for (SVMXA360__CONF_HierarchyConfig__c hierarchyConfigDefaultRecord : hierarchyConfigDefaultRecords) {
                    hierarchyConfigDefaultRecord.SVMXA360__IsDefault__c = false;
                }
                SvmxDatabase.updateRecord(hierarchyConfigDefaultRecords);
                    
            } 

            if ( !hierarchyConfigRecordIds.isEmpty() ) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                List<SVMXA360__CONF_HierarchyConfigDetail__c> hierarchyConfigDetailRecordsTobeDeleted = SvmxDatabase.query([SELECT Id from SVMXA360__CONF_HierarchyConfigDetail__c where SVMXA360__HierarchyConfigId__c IN :hierarchyConfigRecordIds]);

                if ( !hierarchyConfigDetailRecordsTobeDeleted.isEmpty() ) {
                    SvmxDatabase.deleteRecord( hierarchyConfigDetailRecordsTobeDeleted );
                }

            }
            
            SvmxDatabase.upsertRecord(hierarchyConfigRecords);

            hierarchyConfigs = saveHierarchyConfigDetailAndAccessList(hierarchyConfigs,hierarchyConfigRecords);
            
        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to save Hierarchy configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to Hierarchy configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - exit; hierarchyConfigs = '+hierarchyConfigs);
        }

        return hierarchyConfigs;
    }

    /**
     * This method is used to save the hierarchy configuration detail list for requested information.
     */
    public List<Adm.HierarchyConfig> saveHierarchyConfigDetailAndAccessList( List<Adm.HierarchyConfig>  hierarchyConfigs, 
                                                                    List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords) {

        System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfigDetailAndAccessList() - enter; hierarchyConfigs= ' + hierarchyConfigs);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            List<SVMXA360__CONF_HierarchyConfigDetail__c> hierarchyConfigDetailRecords = new List<SVMXA360__CONF_HierarchyConfigDetail__c>();
            List<SVMXA360__CONF_HierarchyConfigAccess__c> hierarchyConfigAccessRecords = new List<SVMXA360__CONF_HierarchyConfigAccess__c>();
            Map<Id, List<SVMXA360__CONF_HierarchyConfigDetail__c>> hierarchyConfigDetailRecordListMap = new Map<Id, List<SVMXA360__CONF_HierarchyConfigDetail__c>>();
            Map<Id, List<SVMXA360__CONF_HierarchyConfigAccess__c>> hierarchyConfigAccessRecordListMap = new Map<Id, List<SVMXA360__CONF_HierarchyConfigAccess__c>>();
            Set<Id> hierarchyConfigRecordIds = new Set<Id>();
            
            for( Integer index = 0; index < hierarchyConfigs.size(); index++ ) {

                final Adm.HierarchyConfig hierarchyConfig = hierarchyConfigs.get(index);
                final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = hierarchyConfigRecords.get(index);
                final List<SVMXA360__CONF_HierarchyConfigDetail__c> singleHierarchyConfigDetailRecordList = new List<SVMXA360__CONF_HierarchyConfigDetail__c>();
                final List<SVMXA360__CONF_HierarchyConfigAccess__c> singleHierarchyConfigAccessRecordList = new List<SVMXA360__CONF_HierarchyConfigAccess__c>();

                hierarchyConfig.id = hierarchyConfigRecord.id;

                hierarchyConfigRecordIds.add(hierarchyConfigRecord.id);

                if ( hierarchyConfig.hierarchyConfigDetailList == null || hierarchyConfig.hierarchyConfigDetailList.isEmpty() ) {

                    System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigDetailAndAccessList() : Invalid request parameters. hierarchyConfig= ' + hierarchyConfig );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );

                } else {

                    for( Adm.HierarchyConfigDetail hierarchyConfigDetail : hierarchyConfig.HierarchyConfigDetailList ) {

                        if (hierarchyConfigDetail.hierarchyConfigFieldList == null || hierarchyConfigDetail.hierarchyConfigFieldList.isEmpty()){

                            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigDetailAndAccessList() : Invalid request parameters. hierarchyConfig= ' + hierarchyConfig );
                            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );

                        } else {

                            hierarchyConfigDetail.hierarchyConfigId = hierarchyConfigRecord.id;

                            SVMXA360__CONF_HierarchyConfigDetail__c hierarchyConfigDetailRecord = buildHierachyConfigDetailRecord(hierarchyConfigDetail);
                            hierarchyConfigDetailRecords.add( hierarchyConfigDetailRecord );
                            singleHierarchyConfigDetailRecordList.add(hierarchyConfigDetailRecord);
                            
                        }
                    }

                    hierarchyConfigDetailRecordListMap.put( hierarchyConfig.id, singleHierarchyConfigDetailRecordList);
                }

                if ( hierarchyConfig.hierarchyConfigAccessList != null || hierarchyConfig.hierarchyConfigAccessList.isEmpty() ) {

                    for( Adm.HierarchyConfigAccess hierarchyConfigAccess : hierarchyConfig.hierarchyConfigAccessList ) {

                        hierarchyConfigAccess.hierarchyConfigId = hierarchyConfigRecord.id;

                        SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRecord = buildHierachyConfigAccessRecord(hierarchyConfigAccess);
                        hierarchyConfigAccessRecords.add( hierarchyConfigAccessRecord );
                        singleHierarchyConfigAccessRecordList.add(hierarchyConfigAccessRecord);
                    }

                    hierarchyConfigAccessRecordListMap.put( hierarchyConfig.id, singleHierarchyConfigAccessRecordList);

                }
            }

            hierarchyConfigDetailRecords = SvmxDatabase.upsertRecord(hierarchyConfigDetailRecords);

            deleteExistingAccessAndFieldRecords( hierarchyConfigRecordIds, hierarchyConfigAccessRecordListMap );

            if (!hierarchyConfigAccessRecords.isEmpty()) {
                hierarchyConfigAccessRecords = SvmxDatabase.upsertRecord(hierarchyConfigAccessRecords);
            }

            hierarchyConfigs = saveHierarchyConfigFieldList( hierarchyConfigDetailRecordListMap,hierarchyConfigAccessRecordListMap,hierarchyConfigs );

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigDetailAndAccessList() : Failed to save Hierarchy configuration detail and access records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigDetailAndAccessList() : Failed to save Hierarchy configuration detail and access records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfigDetailAndAccessList() - exit; hierarchyConfigs = '+hierarchyConfigs);
        }

        return hierarchyConfigs;

    }

    /**
     * This method is used to save the hierarchy configuration field list for requested information.
     */
    public List<Adm.HierarchyConfig> saveHierarchyConfigFieldList( Map<Id, List<SVMXA360__CONF_HierarchyConfigDetail__c>> hierarchyConfigDetailRecordListMap, 
                                                                   Map<Id, List<SVMXA360__CONF_HierarchyConfigAccess__c>> hierarchyConfigAccessRecordListMap,
                                                                   List<Adm.HierarchyConfig>  hierarchyConfigs) {
        
        System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfigFieldList() - enter; hierarchyConfigs= ' + hierarchyConfigs);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            List<SVMXA360__CONF_HierarchyFields__c> hierarchyConfigFieldRecords = new List<SVMXA360__CONF_HierarchyFields__c>();
            Map<Id, List<SVMXA360__CONF_HierarchyFields__c>> hierarchyConfigFieldRecordListMap = new Map<Id, List<SVMXA360__CONF_HierarchyFields__c>>();
        
            for( Adm.HierarchyConfig hierarchyConfigRec :  hierarchyConfigs ) {

                if ( !hierarchyConfigAccessRecordListMap.isEmpty() ) {

                    final List<SVMXA360__CONF_HierarchyConfigAccess__c> singleHierarchyConfigAccessRecordList = hierarchyConfigAccessRecordListMap.get(hierarchyConfigRec.id);

                    for( Integer index = 0; index < singleHierarchyConfigAccessRecordList.size(); index++ ) {
                        hierarchyConfigRec.hierarchyConfigAccessList.get(index).id = singleHierarchyConfigAccessRecordList.get(index).id;
                    }

                }
                    
                final List<SVMXA360__CONF_HierarchyConfigDetail__c> singleHierarchyConfigDetailRecordList = hierarchyConfigDetailRecordListMap.get(hierarchyConfigRec.id);
                                                                            
                for( Integer index = 0; index < singleHierarchyConfigDetailRecordList.size(); index++ ) {

                    hierarchyConfigRec.HierarchyConfigDetailList.get(index).id = singleHierarchyConfigDetailRecordList.get(index).id;
                    final Adm.HierarchyConfigDetail hierarchyConfigDetail = hierarchyConfigRec.HierarchyConfigDetailList.get(index);

                    final List<SVMXA360__CONF_HierarchyFields__c> singleHierarchyConfigFieldRecordList = new List<SVMXA360__CONF_HierarchyFields__c>();

                    for( Adm.HierarchyConfigField hierarchyConfigField : hierarchyConfigDetail.hierarchyConfigFieldList ) {

                        if ( hierarchyConfigField.fieldAPIName == null || hierarchyConfigField.sequence == null) {
                            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigFieldList() : Invalid request parameters. hierarchyConfigDetail= ' + hierarchyConfigDetail );
                            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                        }

                        hierarchyConfigField.hierarchyConfigDetailId = hierarchyConfigDetail.id;

                        SVMXA360__CONF_HierarchyFields__c hierarchyConfigFieldRecord = buildHierachyConfigFieldRecord(hierarchyConfigField);
                        hierarchyConfigFieldRecords.add( hierarchyConfigFieldRecord );
                        singleHierarchyConfigFieldRecordList.add(hierarchyConfigFieldRecord);
                    }

                    hierarchyConfigFieldRecordListMap.put( hierarchyConfigDetail.id, singleHierarchyConfigFieldRecordList);

                }
                
            }

            hierarchyConfigFieldRecords = SvmxDatabase.upsertRecord(hierarchyConfigFieldRecords);

            for( Adm.HierarchyConfig hierarchyConfigRec :  hierarchyConfigs ) {

                for (Adm.HierarchyConfigDetail hierarchyConfigDetail : hierarchyConfigRec.HierarchyConfigDetailList) {

                    final List<SVMXA360__CONF_HierarchyFields__c> singleHierarchyConfigFieldRecordList = hierarchyConfigFieldRecordListMap.get(hierarchyConfigDetail.id);
                    
                    for( Integer index = 0; index < singleHierarchyConfigFieldRecordList.size(); index++ ) {
                        hierarchyConfigDetail.hierarchyConfigFieldList.get(index).id = singleHierarchyConfigFieldRecordList.get(index).id;
                    }
                }
            }
        
        }

        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigFieldList() : Failed to save Hierarchy configuration fields. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfigFieldList() : Failed to save Hierarchy configuration fields. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfigFieldList() - exit; hierarchyConfigs = '+hierarchyConfigs);
        }

        return hierarchyConfigs;
    }

    /**
     * Method to delete existing config access records.
     */
    public void deleteExistingAccessAndFieldRecords( final Set<Id> hierarchyConfigRecordIds, Map<Id, List<SVMXA360__CONF_HierarchyConfigAccess__c>> hierarchyConfigAccessRecordListMap ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteExistingAccessRecords() - enter; hierarchyConfigRecordIds= ' + hierarchyConfigRecordIds + ' ;hierarchyConfigAccessRecordListMap = '+hierarchyConfigAccessRecordListMap);
        
        try {

            if( hierarchyConfigRecordIds.size() == 1 && !hierarchyConfigAccessRecordListMap.isEmpty() && 
                hierarchyConfigAccessRecordListMap.containsKey((new List<Id>(hierarchyConfigRecordIds))[0])) {

                Set<String> profileIds = new Set<String>();
                Id configId = (new List<Id>(hierarchyConfigRecordIds))[0];

                for (SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRecord : hierarchyConfigAccessRecordListMap.get(configId)) {
                    profileIds.add(hierarchyConfigAccessRecord.SVMXA360__ProfileId__c);
                }
                /* sfge-disable-next-line ApexFlsViolationRule */
                final List<SVMXA360__CONF_HierarchyConfigAccess__c> hierarchyConfigSameProfileAccessRecords = SvmxDatabase.query([Select Id from SVMXA360__CONF_HierarchyConfigAccess__c where SVMXA360__HierarchyConfigId__c != :configId AND SVMXA360__ProfileId__c IN :profileIds]);
                
                if ( !hierarchyConfigSameProfileAccessRecords.isEmpty() ) {
                    SvmxDatabase.deleteRecord( hierarchyConfigSameProfileAccessRecords );
                }

            } 
            /* sfge-disable-next-line ApexFlsViolationRule */
            final List<SVMXA360__CONF_HierarchyConfigAccess__c> hierarchyConfigAccessRecords = SvmxDatabase.query([Select Id from SVMXA360__CONF_HierarchyConfigAccess__c where SVMXA360__HierarchyConfigId__c IN :hierarchyConfigRecordIds]);
                
            if ( !hierarchyConfigAccessRecords.isEmpty() ) {
                SvmxDatabase.deleteRecord( hierarchyConfigAccessRecords );
            }

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExistingAccessRecords() : Failed to delete access records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteExistingAccessRecords() - exit' );
        }
    }

    /**
     * This method is used to retrieve hierarchy configuration detail list for requested id.
     */
    public List<Adm.HierarchyConfigDetail> getHierarchyConfigurationDetailList( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationDetailList() - enter' );
        
        List<Adm.HierarchyConfigDetail> hierarchyConfigDetailList = new List<Adm.HierarchyConfigDetail>();
        
        try {
            
            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }

            List<SVMXA360__CONF_HierarchyConfigDetail__c> hierarchyConfigDetailRecords = getHierarchyConfigDetailRecords(hierarchyConfigId);
            
            if ( !hierarchyConfigDetailRecords.isEmpty() ) {

                for( SVMXA360__CONF_HierarchyConfigDetail__c hierarchyConfigDetailRecord : hierarchyConfigDetailRecords ) {

                    Adm.HierarchyConfigDetail hierarchyConfigDetail = buildHierarchyConfigDetail( hierarchyConfigDetailRecord );

                    if(hierarchyConfigDetailRecord.SVMXA360__Hierarchy_Configuration_Fields__r.size() > 0) {
                        hierarchyConfigDetail.hierarchyConfigFieldList = new List<Adm.HierarchyConfigField>(); 
                        for( SVMXA360__CONF_HierarchyFields__c hierarchyConfigFieldRecord : hierarchyConfigDetailRecord.SVMXA360__Hierarchy_Configuration_Fields__r ) {
                            hierarchyConfigDetail.hierarchyConfigFieldList.add( buildHierarchyConfigField( hierarchyConfigFieldRecord ) );
                        }
                    }
                    hierarchyConfigDetailList.add(hierarchyConfigDetail);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationDetailList() : Failed to retrieve hierarchy configuration details. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationDetailList() : Failed to retrieve hierarchy configuration details. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationDetailList() - exit; hierarchyConfigDetailList= ' + hierarchyConfigDetailList );
        }
        
        return hierarchyConfigDetailList;
    }

    /**
     * This method is used to retrieve hierarchy configuration access list for requested id.
     */
    public List<Adm.HierarchyConfigAccess> getHierarchyConfigurationAccessList( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationAccessList() - enter' );
        
        List<Adm.HierarchyConfigAccess> hierarchyConfigAccessList = new List<Adm.HierarchyConfigAccess>();
        
        try {
            
            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }

            List<SVMXA360__CONF_HierarchyConfigAccess__c> hierarchyConfigAccessRecords = getHierarchyConfigAccessRecords(hierarchyConfigId);
            
            if ( !hierarchyConfigAccessRecords.isEmpty() ) {

                for( SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRecord : hierarchyConfigAccessRecords ) {

                    Adm.HierarchyConfigAccess hierarchyConfigAccess = buildHierarchyConfigAccess( hierarchyConfigAccessRecord );
                    hierarchyConfigAccessList.add(hierarchyConfigAccess);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationAccessList() : Failed to retrieve hierarchy configuration access list. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationAccessList() : Failed to retrieve hierarchy configuration access list. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationAccessList() - exit; hierarchyConfigAccessList= ' + hierarchyConfigAccessList );
        }
        
        return hierarchyConfigAccessList;
    }

    /**
     * This method is used to retrieve hierarchy configuration for requested id.
     */
    public Adm.HierarchyConfig getHierarchyConfiguration( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - enter' );
        
        Adm.HierarchyConfig hierarchyConfig = new Adm.HierarchyConfig();
        
        try {
            
            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }
            
            final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = getHierarchyConfigRecord( hierarchyConfigId );
            hierarchyConfig = buildHierarchyConfig(hierarchyConfigRecord);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfiguration() : Failed to retrieve hierarchy configuration. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfiguration() : Failed to retrieve hierarchy configuration. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - exit; hierarchyConfig= ' + hierarchyConfig );
        }
        
        return hierarchyConfig;
    }

    /**
     * Retrieve Hierarchy Config record.
     */
    public SVMXA360__CONF_HierarchyConfig__c getHierarchyConfigRecord( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigRecord() - enter' );
        
        SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord;
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            final List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__IsDefault__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_HierarchyConfig__c WHERE Id = :hierarchyConfigId]);
                
            if( hierarchyConfigRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' hierarchyConfigId= ' + hierarchyConfigId );
            }
            
            hierarchyConfigRecord = hierarchyConfigRecords.get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigRecord() - exit' );
        }
        
        return hierarchyConfigRecord;
    }

    /**
     * Retrieve Hierarchy Config detail records.
     */
    public List<SVMXA360__CONF_HierarchyConfigDetail__c> getHierarchyConfigDetailRecords( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigDetailRecords() - enter' );
        
        List<SVMXA360__CONF_HierarchyConfigDetail__c> hierarchyConfigDetailRecords = new List<SVMXA360__CONF_HierarchyConfigDetail__c>();
        
        try {

            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            hierarchyConfigDetailRecords = SvmxDatabase.query([SELECT Id, Name, SVMXA360__EnableDefaultRecordActions__c, 
                                                               SVMXA360__DisplayIconName__c, SVMXA360__EnableSPMWizards__c, 
                                                               SVMXA360__HierarchyConfigId__c, SVMXA360__ObjectAPIName__c,
                                                              SVMXA360__fieldForDisplayIcon__c,SVMXA360__FilterCriteria__c,
                                                               SVMXA360__EnableNotification__c,SVMXA360__NotificationFilterCriteria__c, 
                                                              SVMXA360__NotificationFilterCriteria__r.Name, SVMXA360__FilterCriteria__r.Name,
                                                              SVMXA360__AllowManagingChildAssets__c,
                                                               (SELECT Id, Name, SVMXA360__FieldAPIName__c,
                                                                SVMXA360__HierarchyConfigurationDetailId__c,
                                                                SVMXA360__Sequence__c from SVMXA360__Hierarchy_Configuration_Fields__r
                                                                ORDER by SVMXA360__Sequence__c)
                                                               FROM SVMXA360__CONF_HierarchyConfigDetail__c WHERE 
                                                               SVMXA360__HierarchyConfigId__c = :hierarchyConfigId]);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigDetailRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigDetailRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigDetailRecords() - exit' );
        }
        
        return hierarchyConfigDetailRecords;
    }

    /**
     * Retrieve Hierarchy Config access records.
     */
    public List<SVMXA360__CONF_HierarchyConfigAccess__c> getHierarchyConfigAccessRecords( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigAccessRecords() - enter' );
        
        List<SVMXA360__CONF_HierarchyConfigAccess__c> hierarchyConfigAccessRecords = new List<SVMXA360__CONF_HierarchyConfigAccess__c>();
        
        try {

            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            hierarchyConfigAccessRecords = SvmxDatabase.query([SELECT Id, Name, SVMXA360__HierarchyConfigId__c, SVMXA360__ProfileId__c
                                                               FROM SVMXA360__CONF_HierarchyConfigAccess__c WHERE 
                                                               SVMXA360__HierarchyConfigId__c = :hierarchyConfigId]);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigAccessRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigAccessRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigAccessRecords() - exit' );
        }
        
        return hierarchyConfigAccessRecords;
    }

    /**
     * Public method to retrieve all hierarchy config records.
     */
    public List<SVMXA360__CONF_HierarchyConfig__c> getAllHierarchyConfigRecords() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigRecords() - enter' );
        
        List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords = new List<SVMXA360__CONF_HierarchyConfig__c>();
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            hierarchyConfigRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__IsDefault__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_HierarchyConfig__c ORDER by Name]);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllHierarchyConfigRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllHierarchyConfigRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigRecords() - exit; hierarchyConfigRecords= ' + hierarchyConfigRecords );
        }
        
        return hierarchyConfigRecords;
    }

    /**
     * Public method to delete hierarchy config record.
     */
    public void deleteHierarchyConfig( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - enter; hierarchyConfigId= ' + hierarchyConfigId );
        
        try {
            
            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            final List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords = SvmxDatabase.query([Select Id, SVMXA360__IsDefault__c from SVMXA360__CONF_HierarchyConfig__c where Id = :hierarchyConfigId]);
            
            if( hierarchyConfigRecords[0].SVMXA360__IsDefault__c) {
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_DefaultHierarchyConfiguration );
            }

            SvmxDatabase.deleteRecord( hierarchyConfigRecords[0] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteHierarchyConfig() : Failed to hierarchy config record. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteHierarchyConfig() : Failed to delete hierarchy config record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - exit' );
        }
    }

    private List<Adm.HierarchyConfig> buildHierarchyConfigs( final List<SVMXA360__CONF_HierarchyConfig__c> hierarchyConfigRecords ) {
        
        final List<Adm.HierarchyConfig> hierarchyConfigList = new List<Adm.HierarchyConfig>();
        if( hierarchyConfigRecords != null && !hierarchyConfigRecords.isEmpty() ) {
            
            for( SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord : hierarchyConfigRecords ) {
                hierarchyConfigList.add( buildHierarchyConfig(hierarchyConfigRecord) );
            }
        }
        
        return hierarchyConfigList;
    }

    private Adm.HierarchyConfig buildHierarchyConfig( final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord ) {
        
        final Adm.HierarchyConfig hierarchyConfig = new Adm.HierarchyConfig();
        hierarchyConfig.id = hierarchyConfigRecord.id;
        hierarchyConfig.name = hierarchyConfigRecord.Name;
        hierarchyConfig.lastModifiedDate = hierarchyConfigRecord.LastModifiedDate;
        hierarchyConfig.lastModifiedBy = hierarchyConfigRecord.LastModifiedBy.Name;
        hierarchyConfig.description = hierarchyConfigRecord.SVMXA360__Description__c;
        hierarchyConfig.developerName = hierarchyConfigRecord.SVMXA360__DeveloperName__c;
        hierarchyConfig.defaultConfiguration = hierarchyConfigRecord.SVMXA360__IsDefault__c;
        
        return hierarchyConfig;
    }

    private SVMXA360__CONF_HierarchyConfig__c buildHierachyConfigRecord (Adm.HierarchyConfig hierarchyConfig) {

        SVMXA360__CONF_HierarchyConfig__c hierachyConfigRecord = new SVMXA360__CONF_HierarchyConfig__c();

        if ( hierarchyConfig.id != null ) {
            hierachyConfigRecord.Id = hierarchyConfig.id;
        }

        hierachyConfigRecord.Name = hierarchyConfig.name;
        hierachyConfigRecord.SVMXA360__Description__c = hierarchyConfig.description;
        hierachyConfigRecord.SVMXA360__DeveloperName__c = hierarchyConfig.developerName;
        hierachyConfigRecord.SVMXA360__IsDefault__c = hierarchyConfig.defaultConfiguration != null ? hierarchyConfig.defaultConfiguration : false;
        
        return hierachyConfigRecord;
    }

    private Adm.HierarchyConfigDetail buildHierarchyConfigDetail( final SVMXA360__CONF_HierarchyConfigDetail__c hierarchyConfigDetailRecord ) {
        
        final Adm.HierarchyConfigDetail hierarchyConfigDetail = new Adm.HierarchyConfigDetail();
        hierarchyConfigDetail.id = hierarchyConfigDetailRecord.id;
        hierarchyConfigDetail.name = hierarchyConfigDetailRecord.Name;
        hierarchyConfigDetail.hierarchyConfigId = hierarchyConfigDetailRecord.SVMXA360__HierarchyConfigId__c;
        hierarchyConfigDetail.objectAPIName = hierarchyConfigDetailRecord.SVMXA360__ObjectAPIName__c;
        hierarchyConfigDetail.defaultRecordActions = hierarchyConfigDetailRecord.SVMXA360__EnableDefaultRecordActions__c;
        hierarchyConfigDetail.displayIconName = hierarchyConfigDetailRecord.SVMXA360__DisplayIconName__c;
        hierarchyConfigDetail.enableSPMWizards = hierarchyConfigDetailRecord.SVMXA360__EnableSPMWizards__c;
        hierarchyConfigDetail.qualifyingCriteria = hierarchyConfigDetailRecord.SVMXA360__FilterCriteria__c;
        hierarchyConfigDetail.qualifyingCriteriaName = hierarchyConfigDetailRecord.SVMXA360__FilterCriteria__r.Name;
        hierarchyConfigDetail.enableNotifications = hierarchyConfigDetailRecord.SVMXA360__EnableNotification__c;
        hierarchyConfigDetail.notificationCriteria = hierarchyConfigDetailRecord.SVMXA360__NotificationFilterCriteria__c;
        hierarchyConfigDetail.notificationCriteriaName = hierarchyConfigDetailRecord.SVMXA360__NotificationFilterCriteria__r.Name;
        hierarchyConfigDetail.fieldForDisplayIconName = hierarchyConfigDetailRecord.SVMXA360__FieldForDisplayIcon__c;
        hierarchyConfigDetail.allowManagingChildAssets = hierarchyConfigDetailRecord.SVMXA360__AllowManagingChildAssets__c;
        return hierarchyConfigDetail;
    }

    private SVMXA360__CONF_HierarchyConfigDetail__c buildHierachyConfigDetailRecord( Adm.HierarchyConfigDetail hierarchyConfigDetail ) {
        List<SVMXA360__CONF_Expression__c> hierarchyNotificationExpressionRecord = new List<SVMXA360__CONF_Expression__c>();
        /* sfge-disable-next-line ApexFlsViolationRule */
        hierarchyNotificationExpressionRecord = SvmxDatabase.query([SELECT Id, SVMXA360__DeveloperName__c ,Name
                                                               FROM SVMXA360__CONF_Expression__c WHERE 
                                                               SVMXA360__DeveloperName__c = 'ASTN_Open_Asset_Notifications']);
        
        SVMXA360__CONF_HierarchyConfigDetail__c hierachyConfigDetailRecord = new SVMXA360__CONF_HierarchyConfigDetail__c();
        hierachyConfigDetailRecord.SVMXA360__HierarchyConfigId__c = hierarchyConfigDetail.hierarchyConfigId;
        hierachyConfigDetailRecord.SVMXA360__EnableDefaultRecordActions__c = hierarchyConfigDetail.defaultRecordActions != null ? hierarchyConfigDetail.defaultRecordActions : false;
        hierachyConfigDetailRecord.SVMXA360__DisplayIconName__c = hierarchyConfigDetail.displayIconName;
        hierachyConfigDetailRecord.SVMXA360__EnableSPMWizards__c = hierarchyConfigDetail.enableSPMWizards != null ? hierarchyConfigDetail.enableSPMWizards : false;
        hierachyConfigDetailRecord.SVMXA360__ObjectAPIName__c = hierarchyConfigDetail.objectAPIName;
        hierachyConfigDetailRecord.SVMXA360__FieldForDisplayIcon__c = hierarchyConfigDetail.fieldForDisplayIconName;
        hierachyConfigDetailRecord.SVMXA360__FilterCriteria__c = hierarchyConfigDetail.qualifyingCriteria;
        hierachyConfigDetailRecord.SVMXA360__EnableNotification__c = hierarchyConfigDetail.enableNotifications != null ? hierarchyConfigDetail.enableNotifications : false;
        hierachyConfigDetailRecord.SVMXA360__AllowManagingChildAssets__c = hierarchyConfigDetail.allowManagingChildAssets != null ? hierarchyConfigDetail.allowManagingChildAssets : false;
        if (hierachyConfigDetailRecord.SVMXA360__EnableNotification__c && 
            hierarchyConfigDetail.notificationCriteria == null && 
            hierarchyNotificationExpressionRecord.size() > 0) {
                hierachyConfigDetailRecord.SVMXA360__NotificationFilterCriteria__c =  hierarchyNotificationExpressionRecord[0].Id; 
            }else{
                hierachyConfigDetailRecord.SVMXA360__NotificationFilterCriteria__c = hierarchyConfigDetail.notificationCriteria;                    
            }
        if (!hierachyConfigDetailRecord.SVMXA360__EnableNotification__c && 
            hierarchyConfigDetail.notificationCriteria != null) {
            hierachyConfigDetailRecord.SVMXA360__NotificationFilterCriteria__c = null;
        }
        return hierachyConfigDetailRecord;
    }
    
    private Adm.HierarchyConfigField buildHierarchyConfigField( final SVMXA360__CONF_HierarchyFields__c hierarchyConfigFieldRecord ) {
        
        final Adm.HierarchyConfigField hierarchyConfigField = new Adm.HierarchyConfigField();
        hierarchyConfigField.id = hierarchyConfigFieldRecord.id;
        hierarchyConfigField.name = hierarchyConfigFieldRecord.Name;
        hierarchyConfigField.hierarchyConfigDetailId = hierarchyConfigFieldRecord.SVMXA360__HierarchyConfigurationDetailId__c;
        hierarchyConfigField.fieldAPIName = hierarchyConfigFieldRecord.SVMXA360__FieldAPIName__c;
        hierarchyConfigField.sequence = Integer.Valueof(hierarchyConfigFieldRecord.SVMXA360__Sequence__c);
        
        return hierarchyConfigField;
    }

    private SVMXA360__CONF_HierarchyFields__c buildHierachyConfigFieldRecord( final Adm.HierarchyConfigField hierarchyConfigField ) {
        
        SVMXA360__CONF_HierarchyFields__c hierarchyConfigFieldRecord = new SVMXA360__CONF_HierarchyFields__c();

        hierarchyConfigFieldRecord.SVMXA360__HierarchyConfigurationDetailId__c = hierarchyConfigField.hierarchyConfigDetailId;
        hierarchyConfigFieldRecord.SVMXA360__FieldAPIName__c = hierarchyConfigField.fieldAPIName;
        hierarchyConfigFieldRecord.SVMXA360__Sequence__c = hierarchyConfigField.sequence;
        
        return hierarchyConfigFieldRecord;

    }

    private Adm.HierarchyConfigAccess buildHierarchyConfigAccess( final SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRecord ) {
        
        final Adm.HierarchyConfigAccess hierarchyConfigAccess = new Adm.HierarchyConfigAccess();
        hierarchyConfigAccess.id = hierarchyConfigAccessRecord.id;
        hierarchyConfigAccess.name = hierarchyConfigAccessRecord.Name;
        hierarchyConfigAccess.hierarchyConfigId = hierarchyConfigAccessRecord.SVMXA360__HierarchyConfigId__c;
        hierarchyConfigAccess.profileId = hierarchyConfigAccessRecord.SVMXA360__ProfileId__c;
        hierarchyConfigAccess.profileName = getProfileName(hierarchyConfigAccessRecord.SVMXA360__ProfileId__c);
        
        return hierarchyConfigAccess;
    }

    public String getProfileName ( Id profileId) {

        System.debug( LoggingLevel.DEBUG, 'getProfileName() - enter' );
        
        List<Profile> profileRecords = new List<Profile>();
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            profileRecords = SvmxDatabase.query([SELECT Id, Name from Profile where Id =:profileId ]);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProfileName() : Failed to retrieve Name. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProfileName() - exit; profileRecords= ' + profileRecords );
        }
        
        return profileRecords[0].Name;
    }

    private SVMXA360__CONF_HierarchyConfigAccess__c buildHierachyConfigAccessRecord( final Adm.HierarchyConfigAccess hierarchyConfigAccess ) {

        SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccessRecord = new SVMXA360__CONF_HierarchyConfigAccess__c();

        hierarchyConfigAccessRecord.SVMXA360__HierarchyConfigId__c = hierarchyConfigAccess.hierarchyConfigId;
        hierarchyConfigAccessRecord.SVMXA360__ProfileId__c = hierarchyConfigAccess.profileId;
        
        return hierarchyConfigAccessRecord;

    }

}