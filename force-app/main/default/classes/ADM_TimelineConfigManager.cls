/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements methods to retrieve and save timeline configurations. 
 *
 * @author Adam Daw
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Adam Daw       01 June 2021     Created.
 *****************************************************************************************************/
public with sharing class ADM_TimelineConfigManager {
    
    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final ADM_TimelineConfigManager instance = new ADM_TimelineConfigManager();

    /**
     * Public method to retrieve instance of this class.
     */
    public static ADM_TimelineConfigManager getInstance() {
        return instance;
    }

    /**
     * This method is used to retrieve all timeline configurations with only 
     * header level informations.
    */
    public List<Adm.TimelineConfig> getAllTimelineConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigurations() - enter' );
        
        List<Adm.TimelineConfig> timelineConfigList = new List<Adm.TimelineConfig>();
        
        try {
            List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords = getAllTimelineConfigRecords();
            timelineConfigList = buildTimelineConfigs(timelineConfigRecords);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTimelineConfigurations() : Failed to retrieve timeline configurations. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTimelineConfigurations() : Failed to retrieve timeline configurations. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigurations() - exit; timelineConfigList= ' + timelineConfigList );
        }
        
        return timelineConfigList;
    }

    /**
     * This method is used to retrieve details of the timeline configuration for requested id.
     */
    public Adm.TimelineConfig getTimelineConfigurationWithDetails( final String timelineConfigId ) {

        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationWithDetails() - enter; timelineConfigId= ' + timelineConfigId);

        Adm.TimelineConfig timelineConfig;

        try {

            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }

            timelineConfig = getTimelineConfiguration(timelineConfigId);

            timelineConfig.timelineConfigDetailList = getTimelineConfigurationDetailList(timelineConfigId);

            timelineConfig.timelineConfigAccessList = getTimelineConfigurationAccessList(timelineConfigId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationWithDetails() : Failed to retrieve timeline configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationWithDetails() : Failed to retrieve timeline configuration. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationWithDetails() - exit; timelineConfig= ' + timelineConfig);
        }

        return timelineConfig;
    }

    /**
     * This method is used to retrieve profile Ids and the associated configuration details for requested config id.
     */
    public List<Adm.TimelineProfileInfo> getAssignedProfileDetailsForTimeline( final String timelineConfigId ) {

        System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetailsForTimeline() - enter; timelineConfigId= ' + timelineConfigId);

        Map<Id,List<String>> profileDetailsMap = new Map<Id,List<String>>();
        List<Adm.TimelineProfileInfo> profileInfoList = new List<Adm.TimelineProfileInfo>();

        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessList = SvmxDatabase.query([SELECT Id, SVMXA360__TimelineConfigId__r.Name, 
                                                                                                          SVMXA360__ProfileId__c 
                                                                                                          FROM SVMXA360__CONF_TimelineConfigAccess__c WHERE 
                                                                                                          SVMXA360__TimelineConfigId__c != :timelineConfigId]);
            
            for (SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord : timelineConfigAccessList) {
                if( !profileDetailsMap.containsKey(timelineConfigAccessRecord.SVMXA360__ProfileId__c) ) {
                    profileDetailsMap.put( timelineConfigAccessRecord.SVMXA360__ProfileId__c, new List<String>() );
                }
                
                profileDetailsMap.get(timelineConfigAccessRecord.SVMXA360__ProfileId__c).add(timelineConfigAccessRecord.SVMXA360__TimelineConfigId__r.Name); 
            }

            if ( !profileDetailsMap.isEmpty() ) {
                Adm.TimelineProfileInfo profileInfo;

                for (Id profileId : profileDetailsMap.keySet()) {
                    profileInfo = new Adm.TimelineProfileInfo();
                    profileInfo.profileId = profileId;
                    profileInfo.timelineConfigNames = profileDetailsMap.get(profileId);
                    profileInfoList.add(profileInfo);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetailsForTimeline() : Failed to retrieve profile details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetailsForTimeline() : Failed to retrieve profile details for the cofig Id. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetailsForTimeline() - exit; profileInfoList= ' + profileInfoList);
        }

        return profileInfoList;
    }

    /**
     * This method is used to retrieve profile Ids and the associated configuration details for requested config id.
     */
    public List<Adm.TimelineProfileInfo> getAllAssignedProfileDetails( ) {

        System.debug( LoggingLevel.DEBUG, 'getAllAssignedProfileDetails() - enter;');

        Map<Id,List<String>> profileDetailsMap = new Map<Id,List<String>>();
        List<Adm.TimelineProfileInfo> profileInfoList = new List<Adm.TimelineProfileInfo>();
        Map<String, String> profileNameMap = new Map<String, String>();

        try {

            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessList = SvmxDatabase.query([SELECT Id, 
                                                                                                          SVMXA360__TimelineConfigId__r.Name, 
                                                                                                          SVMXA360__ProfileId__c
                                                                                                          FROM SVMXA360__CONF_TimelineConfigAccess__c]);
            
            for (SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord : timelineConfigAccessList) {
                if( !profileDetailsMap.containsKey(timelineConfigAccessRecord.SVMXA360__ProfileId__c) ) {
                    profileDetailsMap.put( timelineConfigAccessRecord.SVMXA360__ProfileId__c, new List<String>() );
                }
                
                
                profileDetailsMap.get(timelineConfigAccessRecord.SVMXA360__ProfileId__c).add(timelineConfigAccessRecord.SVMXA360__TimelineConfigId__r.Name); 
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<Profile> accessProfiles = SvmxDatabase.query([SELECT Id, Name FROM Profile WHERE Id IN :profileDetailsMap.keySet()]);                                                                                                      
            
            for (Profile profile : accessProfiles) {
                if ( !profileNameMap.containsKey(profile.Id) ) {
                    profileNameMap.put( profile.Id, profile.Name );
                }
            }

            if ( !profileDetailsMap.isEmpty() ) {
                Adm.TimelineProfileInfo profileInfo;

                for (Id profileId : profileDetailsMap.keySet()) {
                    profileInfo = new Adm.TimelineProfileInfo();
                    profileInfo.profileId = profileId;
                    profileInfo.profileName = profileNameMap.get(profileId);
                    profileInfo.timelineConfigNames = profileDetailsMap.get(profileId);
                    profileInfoList.add(profileInfo);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllAssignedProfileDetails() : Failed to retrieve profile details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllAssignedProfileDetails() : Failed to retrieve profile details for the cofig Id. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllAssignedProfileDetails() - exit; profileInfoList= ' + profileInfoList);
        }

        return profileInfoList;
    }

    /**
     * This method is used to save the requested timeline configuration.
     */
    public Adm.TimelineConfig saveTimelineConfiguration( Adm.TimelineConfig timelineConfig) {

        System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - enter; timelineConfig= ' + timelineConfig);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            if ( timelineConfig == null ) {
                System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Invalid request parameters. timelineConfig= ' + timelineConfig );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            saveTimelineConfigurations( new List<Adm.TimelineConfig> {timelineConfig} ).get(0);

        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to save Timeline configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to Timeline configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - exit; timelineConfig = '+timelineConfig);
        }

        return timelineConfig;
    }
    
    /**
     * This method is used to save the requested timeline configuration.
     */
    public Adm.ValidationResult validateTimelineConfiguration( Adm.TimelineConfig timelineConfig, final List<Adm.ReferenceData> referenceDatas ) {
        return validateTimelineConfigurations( new List<Adm.TimelineConfig> {timelineConfig}, referenceDatas ).get(0);
    }

    /**
     * This method is used to validate the requested timeline configuration.
     */
    public List<Adm.ValidationResult> validateTimelineConfigurations( List<Adm.TimelineConfig> timelineConfigList, final List<Adm.ReferenceData> referenceDatas ) {

        System.debug( LoggingLevel.DEBUG, 'validateTimelineConfigurations() - enter');
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {

            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            final Set<String> expressionSet = new Set<String>();
            final List<Adm.Expression> expressionList = ADM_ExpressionManager.getInstance().getAllExpressions();
            
            for( Adm.Expression expression : expressionList ) {
                expressionSet.add( expression.developerName );
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                
                for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                    
                    if( referenceData.configType == Adm.ConfigurationType.Expression ) {
                        expressionSet.add(configurationData.developerName);
                    }
                }
            }
            
            final Set<String> profileNameSet = new Set<String>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            for( Profile profileRecord : (List<Profile>) SvmxDatabase.query([SELECT Name FROM Profile]) ) {
                profileNameSet.add(profileRecord.Name);
            }
            
            for( Adm.TimelineConfig timelineConfig : timelineConfigList ) {

                final Adm.ValidationResult validationResult = new Adm.ValidationResult();
                validationResults.add( validationResult );
                
                // Verify request for valid expression informations.
                if( timelineConfig == null || timelineConfig.timelineConfigDetailList == null ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateExpressions() : Invalid request parameters. timelineConfig= ' + timelineConfig );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }
            
                for( Adm.TimelineConfigDetail timelineConfigDetail : timelineConfig.timelineConfigDetailList ) {
                        
                    if( !entityDefinitionMap.containsKey(timelineConfigDetail.objectAPIName) ) {
                        
                        try {
                            final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(timelineConfigDetail.objectAPIName);
                            entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                        }
                        catch( SvmxSystem.SvmxNestedException e ) {
                            
                            validationResult.addDetailResult( new Adm.ValidationResult(Adm.ConfigurationType.AssetTimeline,'Object does not exists: ' + timelineConfigDetail.objectAPIName ));
                            continue;
                        }
                    }
                    
                    final Common.EntityDefinition entityDefinition = entityDefinitionMap.get(timelineConfigDetail.objectAPIName);
                        
                    if( String.isNotBlank(timelineConfigDetail.qualifyingCriteria) && !expressionSet.contains(timelineConfigDetail.qualifyingCriteria) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult(Adm.ConfigurationType.AssetTimeline,'Criteria does not exists: ' + timelineConfigDetail.qualifyingCriteria ));
                    }
                    
                    if( String.isNotBlank(timelineConfigDetail.sourceFieldAPIName) && !entityDefinition.fieldDefinitionsByApiName.containsKey( timelineConfigDetail.sourceFieldAPIName.toLowerCase() ) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetTimeline, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + timelineConfigDetail.sourceFieldAPIName ) );
                    }
                    
                    if( String.isNotBlank(timelineConfigDetail.startDateFieldAPIName) && !entityDefinition.fieldDefinitionsByApiName.containsKey( timelineConfigDetail.startDateFieldAPIName.toLowerCase() ) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetTimeline, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + timelineConfigDetail.startDateFieldAPIName ) );
                    }
                    
                    if( String.isNotBlank(timelineConfigDetail.endDateFieldAPIName) && !entityDefinition.fieldDefinitionsByApiName.containsKey( timelineConfigDetail.endDateFieldAPIName.toLowerCase() ) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetTimeline, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + timelineConfigDetail.endDateFieldAPIName ) );
                    }
                }
                
                if( timelineConfig.timelineConfigAccessList != null ) {
                    
                    for( Adm.TimelineConfigAccess timelineConfigAccess : timelineConfig.timelineConfigAccessList ) {
                        
                        if( !profileNameSet.contains(timelineConfigAccess.profileName) ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.AssetTimeline, 'AssetTimeline Name: ' + timelineConfig.name + ', Profile does not exists: ' + timelineConfigAccess.profileName ) );
                        }
                    }
                }
            }
        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTimelineConfigurations() : Failed to validate Timeline configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTimelineConfigurations() : Failed to validate Timeline configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateHierarchyConfiguration() - exit' );
        }
        
        return validationResults;
    }
    
    /**
     * This method is used to save the requested timeline configuration.
     */
    public List<Adm.TimelineConfig> saveTimelineConfigurations( List<Adm.TimelineConfig>  timelineConfigs) {

        System.debug( LoggingLevel.DEBUG, 'saveTimelineConfigurations() - enter; timelineConfigs= ' + timelineConfigs);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            // Verify request for valid expression informations.
            if( timelineConfigs == null || timelineConfigs.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'saveTimelineConfigurations() : Invalid request parameters. timelineConfigs= ' + timelineConfigs );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords = new List<SVMXA360__CONF_TimelineConfig__c>();
            Set<Id> timelineConfigRecordIds = new Set<Id>();
            Integer defaultCount = 0;

            for (Adm.TimelineConfig timelineConfig : timelineConfigs ){

                if ( timelineConfig.name == null || timelineConfig.developerName == null ) {
                    System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Invalid request parameters. timelineConfig= ' + timelineConfig );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }

                timelineConfigRecords.add(buildTimelineConfigRecord(timelineConfig));

                if( timelineConfig.id != null ) {
                    timelineConfigRecordIds.add (timelineConfig.id);
                }

                if( timelineConfig.isDefault == true) {

                    defaultCount += 1;

                    if (defaultCount > 1) {
                        System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Invalid arguments. timelineConfigs= ' + timelineConfigs );
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                    }
                }

            } 

            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_TimelineConfig__c> timelineConfigDefaultRecords = SvmxDatabase.query([SELECT Id, SVMXA360__IsDefault__c 
                                                                                                        FROM SVMXA360__CONF_TimelineConfig__c 
                                                                                                        WHERE SVMXA360__IsDefault__c = true AND 
                                                                                                        ID NOT IN:timelineConfigRecordIds]);

            if ( defaultCount == 1 && !timelineConfigDefaultRecords.isEmpty()) {

                for (SVMXA360__CONF_TimelineConfig__c timelineConfigDefaultRecord : timelineConfigDefaultRecords) {
                    timelineConfigDefaultRecord.SVMXA360__IsDefault__c = false;
                }
                SvmxDatabase.updateRecord(timelineConfigDefaultRecords);
                    
            } 
            
            SvmxDatabase.upsertRecord(timelineConfigRecords);

            timelineConfigs = saveTimelineConfigDetailAndAccessList(timelineConfigs,timelineConfigRecords);
            
        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to save Timeline configuration. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to Timeline configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - exit; timelineConfigs = '+timelineConfigs);
        }

        return timelineConfigs;
    }

    /**
     * This method is used to save the timeline configuration detail list for requested information.
     */
    public List<Adm.TimelineConfig> saveTimelineConfigDetailAndAccessList( List<Adm.TimelineConfig>  timelineConfigs, 
                                                                    List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords) {

        System.debug( LoggingLevel.DEBUG, 'saveTimelineConfigDetailAndAccessList() - enter; timelineConfigs= ' + timelineConfigs);
        
        Savepoint sPoint = Database.setSavepoint();

        try {

            List<SVMXA360__CONF_TimelineConfigDetail__c> timelineConfigDetailRecords = new List<SVMXA360__CONF_TimelineConfigDetail__c>();
            List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessRecords = new List<SVMXA360__CONF_TimelineConfigAccess__c>();
            Map<Id, List<SVMXA360__CONF_TimelineConfigDetail__c>> timelineConfigDetailRecordListMap = new Map<Id, List<SVMXA360__CONF_TimelineConfigDetail__c>>();
            Map<Id, List<SVMXA360__CONF_TimelineConfigAccess__c>> timelineConfigAccessRecordListMap = new Map<Id, List<SVMXA360__CONF_TimelineConfigAccess__c>>();
            Set<Id> timelineConfigRecordIds = new Set<Id>();
            Set<Id> timelineConfigDetailRecordIds = new Set<Id>();
            List<SVMXA360__CONF_TimelineConfigDetail__c> detailsToDelete = new List<SVMXA360__CONF_TimelineConfigDetail__c>();


            for( Integer index = 0; index < timelineConfigs.size(); index++ ) {

                final Adm.TimelineConfig timelineConfig = timelineConfigs.get(index);
                final SVMXA360__CONF_TimelineConfig__c timelineConfigRecord = timelineConfigRecords.get(index);
                final List<SVMXA360__CONF_TimelineConfigDetail__c> singleTimelineConfigDetailRecordList = new List<SVMXA360__CONF_TimelineConfigDetail__c>();
                final List<SVMXA360__CONF_TimelineConfigAccess__c> singleTimelineConfigAccessRecordList = new List<SVMXA360__CONF_TimelineConfigAccess__c>();
                

                timelineConfig.id = timelineConfigRecord.id;

                timelineConfigRecordIds.add(timelineConfigRecord.id);

                if ( timelineConfig.timelineConfigDetailList == null || timelineConfig.timelineConfigDetailList.isEmpty() ) {

                    System.debug( LoggingLevel.ERROR, 'saveTimelineConfigDetailAndAccessList() : Invalid request parameters. timelineConfig= ' + timelineConfig );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );

                } else {

                    for( Adm.TimelineConfigDetail timelineConfigDetail : timelineConfig.TimelineConfigDetailList ) {

                        timelineConfigDetail.timelineConfigId = timelineConfigRecord.id;

                        if (timelineConfigDetail.id != null) {
                            timelineConfigDetailRecordIds.add(timelineConfigDetail.id);
                        }

                        SVMXA360__CONF_TimelineConfigDetail__c timelineConfigDetailRecord = buildTimelineConfigDetailRecord(timelineConfigDetail);
                        timelineConfigDetailRecords.add( timelineConfigDetailRecord );
                        singleTimelineConfigDetailRecordList.add(timelineConfigDetailRecord);
                            
                    }

                    timelineConfigDetailRecordListMap.put( timelineConfig.id, singleTimelineConfigDetailRecordList);
                }

                /* sfge-disable-next-line ApexFlsViolationRule */
                for(sObject detailObj : SvmxDatabase.query([SELECT Id, 
                SVMXA360__TimelineConfigId__c FROM SVMXA360__CONF_TimelineConfigDetail__c WHERE 
                SVMXA360__TimelineConfigId__c IN :timelineConfigDetailRecordListMap.keySet()])) {
                    Boolean keepDetail = false;
                    SVMXA360__CONF_TimelineConfigDetail__c detail = (SVMXA360__CONF_TimelineConfigDetail__c)detailObj;
                    for(SVMXA360__CONF_TimelineConfigDetail__c configDetail : timelineConfigDetailRecordListMap.get(detail.SVMXA360__TimelineConfigId__c)){
                        if(configDetail.Id == detail.Id){
                            keepDetail = true;
                        }
                    }
                    if(keepDetail == false){
                        detailsToDelete.add(detail);
                    }
                }

                if ( timelineConfig.timelineConfigAccessList != null || timelineConfig.timelineConfigAccessList.isEmpty() ) {

                    for( Adm.TimelineConfigAccess timelineConfigAccess : timelineConfig.timelineConfigAccessList ) {

                        timelineConfigAccess.timelineConfigId = timelineConfigRecord.id;

                        SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord = buildTimelineConfigAccessRecord(timelineConfigAccess);
                        timelineConfigAccessRecords.add( timelineConfigAccessRecord );
                        singleTimelineConfigAccessRecordList.add(timelineConfigAccessRecord);
                    }

                    timelineConfigAccessRecordListMap.put( timelineConfig.id, singleTimelineConfigAccessRecordList);

                }
            }

            timelineConfigDetailRecords = SvmxDatabase.upsertRecord(timelineConfigDetailRecords);

            deleteExistingAccessRecords( timelineConfigRecordIds, timelineConfigAccessRecordListMap, timelineConfigDetailRecordIds );

            if(!detailsToDelete.isEmpty()){
                SvmxDatabase.deleteRecord(detailsToDelete);
            }

            if (!timelineConfigAccessRecords.isEmpty()) {
                timelineConfigAccessRecords = SvmxDatabase.upsertRecord(timelineConfigAccessRecords);
            }

        } catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfigDetailAndAccessList() : Failed to save Timeline configuration detail and access records. Error= ' + e.getMessage() );
            throw e;
        } catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfigDetailAndAccessList() : Failed to save Timeline configuration detail and access records. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'saveTimelineConfigDetailAndAccessList() - exit; timelineConfigs = '+timelineConfigs);
        }

        return timelineConfigs;

    }


    /**
     * Method to delete existing config access records.
     */
    public void deleteExistingAccessRecords( final Set<Id> timelineConfigRecordIds, Map<Id, List<SVMXA360__CONF_TimelineConfigAccess__c>> timelineConfigAccessRecordListMap, 
                                                     final Set<Id> timelineConfigDetailRecordIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteExistingAccessRecords() - enter; timelineConfigRecordIds= ' + timelineConfigRecordIds + ' ;timelineConfigDetailRecordIds = '+timelineConfigDetailRecordIds);
        
        try {

            if( timelineConfigRecordIds.size() == 1 && !timelineConfigAccessRecordListMap.isEmpty() && 
                timelineConfigAccessRecordListMap.containsKey((new List<Id>(timelineConfigRecordIds))[0])) {

                Set<String> profileIds = new Set<String>();
                Id configId = (new List<Id>(timelineConfigRecordIds))[0];

                for (SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord : timelineConfigAccessRecordListMap.get(configId)) {
                    profileIds.add(timelineConfigAccessRecord.SVMXA360__ProfileId__c);
                }

                final List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigSameProfileAccessRecords = 
                    SvmxDatabase.query([Select Id from SVMXA360__CONF_TimelineConfigAccess__c where SVMXA360__TimelineConfigId__c != :configId AND 
                                        SVMXA360__ProfileId__c IN :profileIds]);
                
                if ( !timelineConfigSameProfileAccessRecords.isEmpty() ) {
                    SvmxDatabase.deleteRecord( timelineConfigSameProfileAccessRecords );
                }

            } 

            final List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessRecords = SvmxDatabase.query([Select Id from SVMXA360__CONF_TimelineConfigAccess__c where SVMXA360__TimelineConfigId__c IN :timelineConfigRecordIds]);
                
            if ( !timelineConfigAccessRecords.isEmpty() ) {
                SvmxDatabase.deleteRecord( timelineConfigAccessRecords );
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
     * This method is used to retrieve timeline configuration detail list for requested id.
     */
    public List<Adm.TimelineConfigDetail> getTimelineConfigurationDetailList( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationDetailList() - enter' );
        
        List<Adm.TimelineConfigDetail> timelineConfigDetailList = new List<Adm.TimelineConfigDetail>();
        
        try {
            
            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }

            List<SVMXA360__CONF_TimelineConfigDetail__c> timelineConfigDetailRecords = getTimelineConfigDetailRecords(timelineConfigId);
            
            if ( !timelineConfigDetailRecords.isEmpty() ) {
                final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions('Asset');

                for( SVMXA360__CONF_TimelineConfigDetail__c timelineConfigDetailRecord : timelineConfigDetailRecords ) {

                    Adm.TimelineConfigDetail timelineConfigDetail = buildTimelineConfigDetail( timelineConfigDetailRecord, entityDefinition );
                    timelineConfigDetailList.add(timelineConfigDetail);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationDetailList() : Failed to retrieve timeline configuration details. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationDetailList() : Failed to retrieve timeline configuration details. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationDetailList() - exit; timelineConfigDetailList= ' + timelineConfigDetailList );
        }
        
        return timelineConfigDetailList;
    }

    /**
     * This method is used to retrieve timeline configuration access list for requested id.
     */
    public List<Adm.TimelineConfigAccess> getTimelineConfigurationAccessList( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationAccessList() - enter' );
        
        List<Adm.TimelineConfigAccess> timelineConfigAccessList = new List<Adm.TimelineConfigAccess>();
        
        try {
            
            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }

            List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessRecords = getTimelineConfigAccessRecords(timelineConfigId);
            
            if ( !timelineConfigAccessRecords.isEmpty() ) {

                Map<String, String> profileIds = new Map<String, String>();

                for( SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord : timelineConfigAccessRecords ) {

                    profileIds.put(timelineConfigAccessRecord.SVMXA360__ProfileId__c, '');
                }

                /* sfge-disable-next-line ApexFlsViolationRule */
                for(sObject profileObj : SvmxDatabase.query([SELECT Id, Name FROM Profile WHERE Id IN :profileIds.keySet()])){
                    Profile profile = (Profile)profileObj;
                    profileIds.put(profile.Id, profile.Name);
                }

                for( SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord : timelineConfigAccessRecords ) {

                    Adm.TimelineConfigAccess timelineConfigAccess = buildTimelineConfigAccess( timelineConfigAccessRecord );
                    timelineConfigAccess.profileName = profileIds.get(timelineConfigAccess.profileId);
                    timelineConfigAccessList.add(timelineConfigAccess);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationAccessList() : Failed to retrieve timeline configuration access list. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationAccessList() : Failed to retrieve timeline configuration access list. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationAccessList() - exit; timelineConfigAccessList= ' + timelineConfigAccessList );
        }
        
        return timelineConfigAccessList;
    }

    /**
     * This method is used to retrieve timeline configuration for requested id.
     */
    public Adm.TimelineConfig getTimelineConfiguration( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfiguration() - enter' );
        
        Adm.TimelineConfig timelineConfig = new Adm.TimelineConfig();
        
        try {
            
            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }
            
            final SVMXA360__CONF_TimelineConfig__c timelineConfigRecord = getTimelineConfigRecord( timelineConfigId );
            timelineConfig = buildTimelineConfig(timelineConfigRecord);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfiguration() : Failed to retrieve timeline configuration. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfiguration() : Failed to retrieve timeline configuration. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfiguration() - exit; timelineConfig= ' + timelineConfig );
        }
        
        return timelineConfig;
    }

    /**
     * Retrieve Timeline Config record.
     */
    public SVMXA360__CONF_TimelineConfig__c getTimelineConfigRecord( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigRecord() - enter' );
        
        SVMXA360__CONF_TimelineConfig__c timelineConfigRecord;
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            final List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__IsDefault__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_TimelineConfig__c WHERE Id = :timelineConfigId]);
                
            if( timelineConfigRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' timelineConfigId= ' + timelineConfigId );
            }
            
            timelineConfigRecord = timelineConfigRecords.get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigRecord() - exit' );
        }
        
        return timelineConfigRecord;
    }

    /**
     * Retrieve Timeline Config detail records.
     */
    public List<SVMXA360__CONF_TimelineConfigDetail__c> getTimelineConfigDetailRecords( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigDetailRecords() - enter' );
        
        List<SVMXA360__CONF_TimelineConfigDetail__c> timelineConfigDetailRecords = new List<SVMXA360__CONF_TimelineConfigDetail__c>();
        
        try {

            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            timelineConfigDetailRecords = SvmxDatabase.query([SELECT Id, Name, 
                                                               SVMXA360__IconName__c, SVMXA360__BackgroundColor__c,
                                                               SVMXA360__TimelineConfigId__c, SVMXA360__ObjectAPIName__c,
                                                               SVMXA360__DisplayFieldAPIName__c, SVMXA360__SourceFieldAPIName__c,
                                                               SVMXA360__StartDateFieldAPIName__c, SVMXA360__EndDateFieldAPIName__c,
                                                               SVMXA360__Sequence__c, SVMXA360__QualifyingCriteria__c,
                                                               SVMXA360__QualifyingCriteria__r.Name,SVMXA360__ShowMatchingOnLoad__c 
                                                               FROM SVMXA360__CONF_TimelineConfigDetail__c WHERE 
                                                               SVMXA360__TimelineConfigId__c = :timelineConfigId ORDER BY SVMXA360__Sequence__c]);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigDetailRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigDetailRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigDetailRecords() - exit' );
        }
        
        return timelineConfigDetailRecords;
    }

    /**
     * Retrieve Timeline Config access records.
     */
    public List<SVMXA360__CONF_TimelineConfigAccess__c> getTimelineConfigAccessRecords( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigAccessRecords() - enter' );
        
        List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessRecords = new List<SVMXA360__CONF_TimelineConfigAccess__c>();
        
        try {

            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            timelineConfigAccessRecords = SvmxDatabase.query([SELECT Id, Name, SVMXA360__TimelineConfigId__c, SVMXA360__ProfileId__c
                                                               FROM SVMXA360__CONF_TimelineConfigAccess__c WHERE 
                                                               SVMXA360__TimelineConfigId__c = :timelineConfigId]);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigAccessRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigAccessRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigAccessRecords() - exit' );
        }
        
        return timelineConfigAccessRecords;
    }

    /**
     * Public method to retrieve all timeline config records.
     */
    public List<SVMXA360__CONF_TimelineConfig__c> getAllTimelineConfigRecords() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigRecords() - enter' );
        
        List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords = new List<SVMXA360__CONF_TimelineConfig__c>();
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            timelineConfigRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__IsDefault__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_TimelineConfig__c ORDER by Name]);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTimelineConfigRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTimelineConfigRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigRecords() - exit; timelineConfigRecords= ' + timelineConfigRecords );
        }
        
        return timelineConfigRecords;
    }

    /**
     * Public method to delete timeline config record.
     */
    public void deleteTimelineConfig( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - enter; timelineConfigId= ' + timelineConfigId );
        
        try {
            
            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }

            final List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords = SvmxDatabase.query([Select Id, SVMXA360__IsDefault__c from SVMXA360__CONF_TimelineConfig__c where Id = :timelineConfigId]);
            
            if( timelineConfigRecords[0].SVMXA360__IsDefault__c) {
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_DefaultTimelineConfiguration );
            }

            SvmxDatabase.deleteRecord( timelineConfigRecords[0] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineConfig() : Failed to timeline config record. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineConfig() : Failed to delete timeline config record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - exit' );
        }
    }

    /**
     * Public method to delete timeline detail record.
     */
    public void deleteTimelineDetail( final String timelineDetailId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - enter; timelineDetailId= ' + timelineDetailId );
        
        try {
            
            if( String.isBlank(timelineDetailId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineDetailId= ' + timelineDetailId );
            }

            final List<SVMXA360__CONF_TimelineConfigDetail__c> timelineConfigDetailRecords = SvmxDatabase.query([Select Id from SVMXA360__CONF_TimelineConfigDetail__c where Id = :timelineDetailId]);

            SvmxDatabase.deleteRecord( timelineConfigDetailRecords[0] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineDetail() : Failed to timeline detail record. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineDetail() : Failed to delete timeline detail record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - exit' );
        }
    }

    private List<Adm.TimelineConfig> buildTimelineConfigs( final List<SVMXA360__CONF_TimelineConfig__c> timelineConfigRecords ) {
        
        final List<Adm.TimelineConfig> timelineConfigList = new List<Adm.TimelineConfig>();
        if( timelineConfigRecords != null && !timelineConfigRecords.isEmpty() ) {
            
            for( SVMXA360__CONF_TimelineConfig__c timelineConfigRecord : timelineConfigRecords ) {
                timelineConfigList.add( buildTimelineConfig(timelineConfigRecord) );
            }
        }
        
        return timelineConfigList;
    }

    private Adm.TimelineConfig buildTimelineConfig( final SVMXA360__CONF_TimelineConfig__c timelineConfigRecord ) {
        
        final Adm.TimelineConfig timelineConfig = new Adm.TimelineConfig();
        timelineConfig.id = timelineConfigRecord.id;
        timelineConfig.name = timelineConfigRecord.Name;
        timelineConfig.lastModifiedDate = timelineConfigRecord.LastModifiedDate;
        timelineConfig.lastModifiedBy = timelineConfigRecord.LastModifiedBy.Name;
        timelineConfig.description = timelineConfigRecord.SVMXA360__Description__c;
        timelineConfig.developerName = timelineConfigRecord.SVMXA360__DeveloperName__c;
        timelineConfig.isDefault = timelineConfigRecord.SVMXA360__IsDefault__c;
        
        return timelineConfig;
    }

    private SVMXA360__CONF_TimelineConfig__c buildTimelineConfigRecord (Adm.TimelineConfig timelineConfig) {

        SVMXA360__CONF_TimelineConfig__c timelineConfigRecord = new SVMXA360__CONF_TimelineConfig__c();

        if ( timelineConfig.id != null ) {
            timelineConfigRecord.Id = timelineConfig.id;
        }

        timelineConfigRecord.Name = timelineConfig.name;
        timelineConfigRecord.SVMXA360__Description__c = timelineConfig.description;
        timelineConfigRecord.SVMXA360__DeveloperName__c = timelineConfig.developerName;
        timelineConfigRecord.SVMXA360__IsDefault__c = timelineConfig.isDefault != null ? timelineConfig.isDefault : false;
        
        return timelineConfigRecord;
    }

    private Adm.TimelineConfigDetail buildTimelineConfigDetail( final SVMXA360__CONF_TimelineConfigDetail__c timelineConfigDetailRecord,Common.EntityDefinition fieldDef ) {
        List<Common.FieldDefinition> fieldDefinitions = fieldDef.fieldDefinitions;
        final Adm.TimelineConfigDetail timelineConfigDetail = new Adm.TimelineConfigDetail();
        timelineConfigDetail.id = timelineConfigDetailRecord.id;
        timelineConfigDetail.name = timelineConfigDetailRecord.Name;
        timelineConfigDetail.timelineConfigId = timelineConfigDetailRecord.SVMXA360__TimelineConfigId__c;
        timelineConfigDetail.objectAPIName = timelineConfigDetailRecord.SVMXA360__ObjectAPIName__c;
        Type objType = Type.forName('Schema.' + timelineConfigDetailRecord.SVMXA360__ObjectAPIName__c );
        timelineConfigDetail.objectLabel = objType != null 
            ? ((SObject) objType.newInstance()).getSObjectType().getDescribe().getLabel()
            : '';
        timelineConfigDetail.showMatchingOnLoad = timelineConfigDetailRecord.SVMXA360__ShowMatchingOnLoad__c;
        timelineConfigDetail.iconName = timelineConfigDetailRecord.SVMXA360__IconName__c;
        timelineConfigDetail.backgroundColor = timelineConfigDetailRecord.SVMXA360__BackgroundColor__c;
        timelineConfigDetail.sequence = timelineConfigDetailRecord.SVMXA360__Sequence__c;
        timelineConfigDetail.displayFieldAPIName = timelineConfigDetailRecord.SVMXA360__DisplayFieldAPIName__c;
        timelineConfigDetail.sourceFieldAPIName = timelineConfigDetailRecord.SVMXA360__SourceFieldAPIName__c;
        timelineConfigDetail.startDateFieldAPIName = timelineConfigDetailRecord.SVMXA360__StartDateFieldAPIName__c;
        if (String.isNotBlank(timelineConfigDetail.startDateFieldAPIName)) {
            for (Common.FieldDefinition def: fieldDefinitions) {
                if (def.apiName.equalsIgnoreCase(timelineConfigDetail.startDateFieldAPIName)) {
                    timelineConfigDetail.startDateFieldLabel = def.label;
                    break;
                }
            }
        }
        timelineConfigDetail.endDateFieldAPIName = timelineConfigDetailRecord.SVMXA360__EndDateFieldAPIName__c;
        if (String.isNotBlank(timelineConfigDetail.endDateFieldAPIName)) {
            for (Common.FieldDefinition def: fieldDefinitions) {
                if (def.apiName.equalsIgnoreCase(timelineConfigDetail.endDateFieldAPIName)) {
                    timelineConfigDetail.endDateFieldLabel = def.label;
                    break;
                }
            }
        }
        timelineConfigDetail.qualifyingCriteria = timelineConfigDetailRecord.SVMXA360__QualifyingCriteria__c;
        timelineConfigDetail.qualifyingCriteriaName = timelineConfigDetailRecord.SVMXA360__QualifyingCriteria__r.Name;
        
        return timelineConfigDetail;
    }

    private SVMXA360__CONF_TimelineConfigDetail__c buildTimelineConfigDetailRecord( Adm.TimelineConfigDetail timelineConfigDetail ) {

        SVMXA360__CONF_TimelineConfigDetail__c timelineConfigDetailRecord = new SVMXA360__CONF_TimelineConfigDetail__c();
        System.debug(timelineConfigDetail);
        if ( timelineConfigDetail.id != null ) {
            timelineConfigDetailRecord.Id = timelineConfigDetail.id;
        } else {
            timelineConfigDetailRecord.SVMXA360__TimelineConfigId__c = timelineConfigDetail.timelineConfigId;
        }

        timelineConfigDetailRecord.SVMXA360__ObjectAPIName__c = timelineConfigDetail.objectAPIName;
        timelineConfigDetailRecord.SVMXA360__BackgroundColor__c = timelineConfigDetail.backgroundColor;
        timelineConfigDetailRecord.SVMXA360__IconName__c = timelineConfigDetail.iconName;
        timelineConfigDetailRecord.SVMXA360__DisplayFieldAPIName__c = timelineConfigDetail.displayFieldAPIName;
        timelineConfigDetailRecord.SVMXA360__SourceFieldAPIName__c = timelineConfigDetail.sourceFieldAPIName;
        timelineConfigDetailRecord.SVMXA360__StartDateFieldAPIName__c = timelineConfigDetail.startDateFieldAPIName;
        timelineConfigDetailRecord.SVMXA360__EndDateFieldAPIName__c = timelineConfigDetail.endDateFieldAPIName;
        timelineConfigDetailRecord.SVMXA360__QualifyingCriteria__c = timelineConfigDetail.qualifyingCriteria;
        timelineConfigDetailRecord.SVMXA360__Sequence__c = timelineConfigDetail.sequence;
        timelineConfigDetailRecord.SVMXA360__ShowMatchingOnLoad__c = timelineConfigDetail.showMatchingOnLoad;
        
        return timelineConfigDetailRecord;
    }

    private Adm.TimelineConfigAccess buildTimelineConfigAccess( final SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord ) {
        
        final Adm.TimelineConfigAccess timelineConfigAccess = new Adm.TimelineConfigAccess();
        timelineConfigAccess.id = timelineConfigAccessRecord.id;
        timelineConfigAccess.name = timelineConfigAccessRecord.Name;
        timelineConfigAccess.timelineConfigId = timelineConfigAccessRecord.SVMXA360__TimelineConfigId__c;
        timelineConfigAccess.profileId = timelineConfigAccessRecord.SVMXA360__ProfileId__c;
        
        return timelineConfigAccess;
    }

    private SVMXA360__CONF_TimelineConfigAccess__c buildTimelineConfigAccessRecord( final Adm.TimelineConfigAccess timelineConfigAccess ) {

        SVMXA360__CONF_TimelineConfigAccess__c timelineConfigAccessRecord = new SVMXA360__CONF_TimelineConfigAccess__c();

        timelineConfigAccessRecord.SVMXA360__TimelineConfigId__c = timelineConfigAccess.timelineConfigId;
        timelineConfigAccessRecord.SVMXA360__ProfileId__c = timelineConfigAccess.profileId;
        
        return timelineConfigAccessRecord;

    }

}