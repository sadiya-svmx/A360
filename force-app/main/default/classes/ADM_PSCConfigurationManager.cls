/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * mapping informations. 
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *             Soumyaranjan Pati      11th Jan 2021     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_PSCConfigurationManager {
    
    /**
     * Static variable to hold instance of this class.
     */
    private static ADM_PSCConfigurationManager instance = null;
    
    private class MappingConfig {
        public String targetMappingKey;
        public String targetMappingId;
    }
    
    /**
     * Static method to return instnace of this class.
     */
    public static ADM_PSCConfigurationManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_PSCConfigurationManager();
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all PSC Configurations.
     */
    public List<Adm.PSCConfigurations> getConfigTemplates() {
        
        System.debug( LoggingLevel.DEBUG, 'getConfigTemplates() - enter' );
        
        List<Adm.PSCConfigurations> pscConfigMappingList = new List<Adm.PSCConfigurations>();
        
        try {
            
            // Retrieve all Configurations
            final List<SVMXA360__CONF_PSCConfiguration__c> pscConfigList = ADM_PSCConfigurationManager.getInstance().getAllPSCConfigurationsRecords() != null ? ADM_PSCConfigurationManager.getInstance().getAllPSCConfigurationsRecords() : getAllPSCConfigurationsRecords();
            
            if( pscConfigList.size() > 0 ) {
                
                // Create PSC Config wrapper for each PSC.
                for( SVMXA360__CONF_PSCConfiguration__c internalVar : pscConfigList ) {
                    pscConfigMappingList.add( createObjectMapping( internalVar ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplates() : Retrieved all PSC Configurations' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getConfigTemplates() : Failed to retrieve PSC Configurations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplates() - exit; pscConfigMappingList.size()= ' + pscConfigMappingList.size() );
        }
        
        return pscConfigMappingList;
    }

    /**
     * This method is used to retrieve requested PSC Configurations.
     */
    public List<Adm.PSCConfigurations> getConfigTemplateInfo(final String configTemplateId) {
        
        System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() - enter' );
        
        List<Adm.PSCConfigurations> pscConfigMappingList = new List<Adm.PSCConfigurations>();
        
        try {
            
            // Retrieve requested Configurations
            final List<SVMXA360__CONF_PSCConfiguration__c> pscConfigList = ADM_PSCConfigurationManager.getInstance().getPSCConfigurationRecord(configTemplateId) != null ? ADM_PSCConfigurationManager.getInstance().getPSCConfigurationRecord(configTemplateId) : getPSCConfigurationRecord(configTemplateId);
            
            if( pscConfigList.size() > 0 ) {
                // Create PSC Config wrapper for each PSC.
                for( SVMXA360__CONF_PSCConfiguration__c internalVar : pscConfigList ) {
                    pscConfigMappingList.add( createObjectMapping( internalVar ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() : Retrieved all PSC Configurations' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Failed to retrieve PSC Configurations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() - exit; pscConfigMappingList.size()= ' + pscConfigMappingList.size() );
        }
        
        return pscConfigMappingList;
    }

    /**
     * This method is used to retrieve PSC Configurations Setting.
     */
    public List<Adm.PSCConfigurations> getSettingConfigTemplates() {
        
        System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() - enter' );
        
        List<Adm.PSCConfigurations> pscConfigMappingList = new List<Adm.PSCConfigurations>();
        
        try {
            
            // Retrieve all Configurations Settings
            final List<SVMXA360__CONF_PSCConfiguration__c> pscConfigList = ADM_PSCConfigurationManager.getInstance().getPSCConfigurationsSettings() != null ? ADM_PSCConfigurationManager.getInstance().getPSCConfigurationsSettings() : getPSCConfigurationsSettings();
            
            if( pscConfigList.size() > 0 ) {
                
                // Create PSC Config wrapper for each PSC.
                for( SVMXA360__CONF_PSCConfiguration__c internalVar : pscConfigList ) {
                    pscConfigMappingList.add( createObjectMappingforSetting( internalVar ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() : Retrieved all PSC Configurations Setting' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getSettingConfigTemplates() : Failed to retrieve PSC Configurations Setting. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() - exit; pscConfigMappingList.size()= ' + pscConfigMappingList.size() );
        }
        
        return pscConfigMappingList;
    }
    /**
     * This method is used to retrieve Object mapping.
     */
    public List<Adm.KeyValueInfo> getObjectMappingDetails(final String sourceObject, final String targetObject) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - enter' );
        
        List<Adm.KeyValueInfo> keyValueInfoList = new List<Adm.KeyValueInfo>();
        
        try {
            
            // Retrieve all Object mapping 
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingVar = ADM_PSCConfigurationManager.getInstance().getObjectMappingRecords(sourceObject, targetObject) != null ? ADM_PSCConfigurationManager.getInstance().getObjectMappingRecords(sourceObject, targetObject) : getObjectMappingRecords(sourceObject, targetObject);
            
            if( objectMappingVar.size() > 0 ) {
                
                // Create PSC Config wrapper for each PSC.
                for( SVMXA360__CONF_ObjectMapping__c internalVar : objectMappingVar ) {
                    keyValueInfoList.add(  createMapping(internalVar) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() : Retrieved Object mapping' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - exit; ' );
        }
        
        return keyValueInfoList;
    }
    /**
     * This method is used to retrieve all object mapping records.
     */
    private List<SVMXA360__CONF_ObjectMapping__c> getObjectMappingRecords(final String sourceObject, final String targetObject) {
        
        final List<SVMXA360__CONF_ObjectMapping__c> objectRecordList;
        
        try {
            objectRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ObjectMapping__c where SVMXA360__SourceObjectAPIName__c =:sourceObject and SVMXA360__TargetObjectAPIName__c =:targetObject ORDER BY SVMXA360__DeveloperName__c] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingRecords() : Failed to retrieve Object mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingRecords() - exit; objectRecordList.size()= ' + objectRecordList.size() );
        }
        
        return objectRecordList;
    }
    /**
     * This method is used to retrieve all PSC Configurations.
     */
    public List<SVMXA360__CONF_PSCConfiguration__c> getAllPSCConfigurationsRecords() {
        
        final List<SVMXA360__CONF_PSCConfiguration__c> objectRecordList;
        
        try {
            objectRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Description__c, SVMXA360__Active__c, LastModifiedDate, SVMXA360__Email__c, SVMXA360__PSCMappingJSON__c FROM SVMXA360__CONF_PSCConfiguration__c where RecordType.DeveloperName ='PSC_Configuration' ORDER BY Name] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPSCConfigurationsRecords() : Failed to retrieve PSC Configurations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPSCConfigurationsRecords() - exit; objectRecordList.size()= ' + objectRecordList.size() );
        }
        
        return objectRecordList;
    }

    /**
     * This method is used to retrieve requested PSC Configurations.
     */
    public List<SVMXA360__CONF_PSCConfiguration__c> getPSCConfigurationRecord(final String configTemplateId) {
        
        final List<SVMXA360__CONF_PSCConfiguration__c> objectRecordList;
        
        try {
            objectRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Description__c, SVMXA360__Active__c, LastModifiedDate, SVMXA360__Email__c, SVMXA360__PSCMappingJSON__c FROM SVMXA360__CONF_PSCConfiguration__c where Id = :configTemplateId] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPSCConfigurationRecord() : Failed to retrieve PSC Configurations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPSCConfigurationRecord() - exit; objectRecordList.size()= ' + objectRecordList.size() );
        }
        
        return objectRecordList;
    }
    
    /**
     * This method is used to retrieve PSC Configurations Settings.
     */
    public List<SVMXA360__CONF_PSCConfiguration__c> getPSCConfigurationsSettings() {
        
        final List<SVMXA360__CONF_PSCConfiguration__c> objectRecordList;
        
        try {
            objectRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__SearchResultsPerPSC__c, SVMXA360__DeliveryBatchSize__c, SVMXA360__SearchBatchSize__c FROM SVMXA360__CONF_PSCConfiguration__c where RecordType.DeveloperName ='PSC_Settings' and SVMXA360__DeveloperName__c = 'Default_PSC_Settings' limit 1] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPSCConfigurationsSettings() : Failed to retrieve PSC Configurations settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPSCConfigurationsSettings() - exit; objectRecordList.size()= ' + objectRecordList.size() );
        }
        
        return objectRecordList;
    }

    /**
     * This method is used to check PSC.
     */
    public List<ProductServiceCampaign> getPSCTemplateUses(final String configTemplateId) {
        
        final List<ProductServiceCampaign> objectRecordList;
        
        try {
            List<string> listOfStatus = new List<string> {'Closed', 'Completed', 'Canceled', 'Cannot Complete'};

            objectRecordList = SvmxDatabase.query( [SELECT Id, ProductServiceCampaignName FROM ProductServiceCampaign WHERE SVMXA360__PSCConfigurationId__c = :String.escapeSingleQuotes(configTemplateId) AND Status NOT IN: listOfStatus] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPSCConfigurationsSettings() : Failed to retrieve PSC Configurations settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPSCConfigurationsSettings() - exit; objectRecordList.size()= ' + objectRecordList.size() );
        }
        
        return objectRecordList;
    }
    
    /**
     * This method is used to delete PSC Templates 
     * for requested PSC COnfig Template id.
     */
    public void deleteConfigTemplate( final String configTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteConfigTemplate() - enter; configTemplateId= ' + configTemplateId );
        
        try {
            // Verify for valid config Template id.
            if( String.isBlank( configTemplateId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Invalid request parameters. configTemplateId= ' + configTemplateId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<ProductServiceCampaign> objectRecordList = getPSCTemplateUses(configTemplateId);

            if( objectRecordList.size() > 0 ) {
                
                String errorMessage = '';

                for (ProductServiceCampaign pscRecord : objectRecordList) {
                    errorMessage += pscRecord.ProductServiceCampaignName+', ';
                }

                System.debug( LoggingLevel.ERROR, 'Template Used by other active PSC records' );
                throw new SvmxSystem.SvmxNestedException( System.Label.Label_PSC_Template_Check_Message +' '+ errorMessage.removeEndIgnoreCase(', ') );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_PSCConfiguration__c WHERE Id = :configTemplateId] );
            
            System.debug( LoggingLevel.INFO, 'deleteConfigTemplate() : Config Template removed successfully. configTemplateId= ' + configTemplateId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete Config Template. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete Config Template. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteConfigTemplate() - exit');
        }
    }
    
    /**
     * Implimentation: save the PSC template settings
     */
    public Adm.ValidationResult validateConfigTemplate( final Adm.PSCConfigurations pscConfiguration, final List<Adm.ReferenceData> referenceDatas ) {
        return validateConfigTemplates( new List<Adm.PSCConfigurations>{pscConfiguration}, referenceDatas).get(0);
    }
    /**
     * Implimentation: save the PSC template settings
     */
    public List<Adm.ValidationResult> validateConfigTemplates( final List<Adm.PSCConfigurations> pscConfigurationList, final List<Adm.ReferenceData> referenceDatas ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateConfigTemplates() - enter; pscConfigurationList= ' + pscConfigurationList );
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        try {
            
            final Set<String> mappingSet = new Set<String>();
			List<SVMXA360__CONF_ObjectMapping__c> mappingList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ObjectMapping__c] );
            
            for( SVMXA360__CONF_ObjectMapping__c mappingRecord : mappingList ) {
                mappingSet.add(mappingRecord.SVMXA360__DeveloperName__c);
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                
                if( referenceData.configType != Adm.ConfigurationType.Mapping ) {
                    continue;
                }
                
                for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                    mappingSet.add(configurationData.developerName);
                }
            }
            
            for( Adm.PSCConfigurations pscConfiguration : pscConfigurationList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.Transactions );
                validationResults.add( validationResult );
                
                if( String.isBlank(pscConfiguration.mappingJson) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateConfigTemplates() : Invalid mapping configuration. pscConfiguration= ' + pscConfiguration.name );
                    validationResult.setError( 'Invalid mapping configuration. pscConfiguration= ' + pscConfiguration.name );
                    
                    continue;
                }
                
                try {
                    
                    List<MappingConfig> mappingConfigList = (List<MappingConfig>) JSON.deserialize(pscConfiguration.mappingJson, List<MappingConfig>.class) ;
                    
                    if( mappingConfigList == null || mappingConfigList.isEmpty() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'validateConfigTemplates() : Invalid mapping configuration. pscConfiguration= ' + pscConfiguration.name );
                        validationResult.setError( 'Invalid mapping configuration. pscConfiguration= ' + pscConfiguration.name );
                        
                        continue;
                    }
                    
                    for( MappingConfig mappingConfig : mappingConfigList ) {
                        if( String.isNotBlank(mappingConfig.targetMappingId) && !mappingSet.contains(mappingConfig.targetMappingId) ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.ProductServiceCampaign, 'Object Mapping does not exists : '+ mappingConfig.targetMappingId ) );
                        }
                    }
                }
                catch(Exception e) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateConfigTemplates() : Failed to parse JSON. error= ' + e.getMessage() );
                    validationResult.setError( 'Invalid mapping configuration. pscConfiguration= ' + pscConfiguration.name );
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Save config Template . Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigTemplates() - exit; validationResults= ' + validationResults );
        }
        return validationResults;
    }

    /**
     * Implimentation: save the PSC template settings
     */
    public String saveConfigTemplates( final Adm.PSCConfigurations configTemplate ) {
        
        System.debug( LoggingLevel.FINEST, 'saveConfigTemplates() - enter; configTemplate= ' + configTemplate );
        String configTemplateId = '';
        try {
            
            // Verify for valid PSC Config Template setting id to perform Update operation.
            if( configTemplate == null || configTemplate.id == null ) {
                
                System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Invalid request parameters. configTemplate= ' + configTemplate );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Verify for PSC Config Template uses.
            if( !configTemplate.isActive && String.isNotBlank( configTemplate.id ) ) {
                List<ProductServiceCampaign> objectRecordList = getPSCTemplateUses( configTemplate.id );
                if( objectRecordList.size() > 0 ) {
                
                    String errorMessage = '';
    
                    for (ProductServiceCampaign pscRecord : objectRecordList) {
                        errorMessage += pscRecord.ProductServiceCampaignName+', ';
                    }
    
                    System.debug( LoggingLevel.ERROR, 'Used active template' );
                    throw new SvmxSystem.SvmxNestedException( System.Label.Label_PSC_Template_Inactive_Check_Message +' '+ errorMessage.removeEndIgnoreCase(', ') );
                }
            }

            SVMXA360__CONF_PSCConfiguration__c pscConfigVar = new SVMXA360__CONF_PSCConfiguration__c();
            pscConfigVar.SVMXA360__Description__c = configTemplate.description;
            pscConfigVar.SVMXA360__Active__c = configTemplate.isActive;
            pscConfigVar.SVMXA360__Email__c = configTemplate.emailId;
            pscConfigVar.SVMXA360__PSCMappingJSON__c = configTemplate.mappingJson;
            pscConfigVar.Name = configTemplate.name;
            if (!String.isBlank(configTemplate.id)) {
                pscConfigVar.Id = configTemplate.id;
            }
            pscConfigVar.RecordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( SVMXA360__CONF_PSCConfiguration__c.getSObjectType(), 'PSC_Configuration' );
            pscConfigVar.SVMXA360__DeveloperName__c = configTemplate.developerName;
            List<SVMXA360__CONF_PSCConfiguration__c> pscConfigVarList = new List<SVMXA360__CONF_PSCConfiguration__c>();
            pscConfigVarList.add(pscConfigVar);
            updateConfigTemplateSetting( pscConfigVarList );
            configTemplateId = String.valueOf(pscConfigVarList[0].id);
            System.debug( LoggingLevel.INFO, 'saveConfigTemplates() : Saved pscConfigVar= ' + pscConfigVarList[0].id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Save Config Template . Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Save config Template . Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveConfigTemplates() - exit; configTemplate= ' + configTemplate );
        }
        return configTemplateId;
    }

    /**
     * Implimentation: update PSC Template setting update
     */
    public void updateConfigTemplateSetting( final Adm.PSCConfigurations configTemplate ) {

        System.debug( LoggingLevel.DEBUG, 'ADM_PSCConfigurationManager.updateConfigTemplateSetting() - enter' );
        
        try {
            
            // Verify for valid PSC Config Template setting id to perform Update operation.
            if( configTemplate == null || configTemplate.id == null ) {
                
                System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Invalid request parameters. configTemplate= ' + configTemplate );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            SVMXA360__CONF_PSCConfiguration__c pscConfigVar = new SVMXA360__CONF_PSCConfiguration__c();
            pscConfigVar.SVMXA360__SearchResultsPerPSC__c = configTemplate.searchResultPerPSC;
            pscConfigVar.SVMXA360__DeliveryBatchSize__c = configTemplate.deliveryBatch;
            pscConfigVar.SVMXA360__SearchBatchSize__c = configTemplate.searchBatch;
            pscConfigVar.Id = configTemplate.id;
            updateConfigTemplateSetting( new List<SVMXA360__CONF_PSCConfiguration__c>{ pscConfigVar } );
            System.debug( LoggingLevel.INFO, 'updateConfigTemplateSetting() : Updated configTemplate Setting= ' + configTemplate.id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, ' updateConfigTemplateSetting() : Failed to Update Config Template Setting. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update config Template Setting. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'ADM_PSCConfigurationManager.updateConfigTemplateSetting() - exit');
        }
    }
    /**
     * This method is used to Update PSC Templates Setting
     * for requested PSC COnfig Template record.
     */
    public void updateConfigTemplateSetting( final List<SVMXA360__CONF_PSCConfiguration__c> configTemplateRecords ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateConfigTemplateSetting() - enter; configTemplateRecords: ' + configTemplateRecords );
        
        try {
            if( configTemplateRecords == null || configTemplateRecords.isEmpty()) {
             
                System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Invalid request parameters. configTemplateRecords= ' + configTemplateRecords );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.upsertRecord(configTemplateRecords);
            
            System.debug( LoggingLevel.INFO, 'updateConfigTemplateSetting() : Config Template updated successfully. configTemplateRecords= ' + configTemplateRecords );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update Config Template. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update Config Template Setting. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateConfigTemplateSetting() - exit');
        }
    }

    /**
     * Private method to create PSC wrapper from object mapping record.
     */
    private Adm.PSCConfigurations createObjectMapping( final SVMXA360__CONF_PSCConfiguration__c configTemplateRecord ) {
        
        Adm.PSCConfigurations objectMapping = new Adm.PSCConfigurations();
        
        objectMapping.id = configTemplateRecord.Id;
        objectMapping.name = configTemplateRecord.Name;
        objectMapping.developerName = configTemplateRecord.SVMXA360__DeveloperName__c;
        objectMapping.isActive = configTemplateRecord.SVMXA360__Active__c;
        objectMapping.description = configTemplateRecord.SVMXA360__Description__c;
        objectMapping.lastModifiedDate = configTemplateRecord.LastModifiedDate;
        objectMapping.emailId = configTemplateRecord.SVMXA360__Email__c;
        objectMapping.mappingJson = configTemplateRecord.SVMXA360__PSCMappingJSON__c;
        
        return objectMapping;
    }
    /**
     * Private method to create Key Value from object mapping record.
     */
    private Adm.KeyValueInfo createMapping( final SVMXA360__CONF_ObjectMapping__c configTemplateRecord ) {
        
        Adm.KeyValueInfo keyValueVar = new Adm.KeyValueInfo();
        
        keyValueVar.key = configTemplateRecord.SVMXA360__DeveloperName__c;
        keyValueVar.value = configTemplateRecord.Name;
        
        return keyValueVar;
    }

    /**
     * Private method to create PSC wrapper from object mapping record.
     */
    private Adm.PSCConfigurations createObjectMappingforSetting( final SVMXA360__CONF_PSCConfiguration__c configTemplateRecord ) {
        
        Adm.PSCConfigurations objectMapping = new Adm.PSCConfigurations();
        
        objectMapping.id = configTemplateRecord.Id;
        objectMapping.name = configTemplateRecord.Name;
        objectMapping.searchResultPerPSC = configTemplateRecord.SVMXA360__SearchResultsPerPSC__c;
        objectMapping.deliveryBatch = configTemplateRecord.SVMXA360__DeliveryBatchSize__c;
        objectMapping.searchBatch = configTemplateRecord.SVMXA360__SearchBatchSize__c;
        
        return objectMapping;
    }

    /**
     * Private consructor to restrict multiple instance creation of this class.
     */
    private ADM_PSCConfigurationManager() {
    }
}