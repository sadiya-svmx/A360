/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete LookupConfigurations.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Aug 2020     Created.
 * A360APP-60   Ramachandra Mohan       03 Nov 2020     Methods to retrieve all lookup configurations and bulk save.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_LookupConfigManager {
	
    private static ADM_LookupConfigManager instance;

    public static ADM_LookupConfigManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_LookupConfigManager();
        }
        
        return instance;
    }

    public List<Adm.LookupConfig> getLookupConfigurations( final String objectName, final String headerObject ){
                
        System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - enter; objectName ' + objectName );
        
        List<Adm.LookupConfig> lookupConfigList = new List<Adm.LookupConfig>();

        try {
            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getLookupConfigurations() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            final List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__BasicFilter__c, SVMXA360__DefaultLookupforObject__c, 
                                                            SVMXA360__DefaultOperator__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__DisplayFields__c, SVMXA360__ExtendedFields__c, 
                                                            SVMXA360__FieldToReturn__c, SVMXA360__ObjectAPIName__c, SVMXA360__HeaderRecordObject__c, SVMXA360__RecordsPerPageReturn__c, SVMXA360__SearchFields__c, 
                                                            LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_LookupConfiguration__c WHERE SVMXA360__ObjectAPIName__c =: objectName AND 
                                                            (SVMXA360__HeaderRecordObject__c =: headerObject OR SVMXA360__HeaderRecordObject__c = null)]);
            
            for(SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord : lookupConfigRecordList){
                lookupConfigList.add( createLookupConfigWrapper(lookupConfigRecord) );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getLookupConfigurations() : Failed to retrieve Lookup Configuration for given object. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getLookupConfigurations() : Failed to retrieve Lookup Configuration for given object. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - exit; lookupConfigList.size()= ' + lookupConfigList.size() );
        }
        
        return lookupConfigList;
    }
    
    public List<Adm.LookupConfig> getAllLookupConfigurations() {
                
        System.debug( LoggingLevel.DEBUG, 'getAllLookupConfigurations() - enter' );
        
        List<Adm.LookupConfig> lookupConfigList = new List<Adm.LookupConfig>();

        try {
            
            final List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = queryAllLookupConfigRecords();
            
            for(SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord : lookupConfigRecordList){
                lookupConfigList.add( createLookupConfigWrapper(lookupConfigRecord) );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllLookupConfigurations() : Failed to retrieve Lookup Configuration for given object. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllLookupConfigurations() : Failed to retrieve Lookup Configuration for given object. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllLookupConfigurations() - exit; lookupConfigList.size()= ' + lookupConfigList.size() );
        }
        
        return lookupConfigList;
    }
    
    public Adm.LookupConfig getLookupConfigDetail( final String lookupConfigId ) {

        System.debug( LoggingLevel.DEBUG, 'getLookupConfig() - enter; lookupConfigId ' + lookupConfigId );
        
        Adm.LookupConfig lookupConfig;
        
        try {
            if( String.isBlank(lookupConfigId) ) {
    
                System.debug( LoggingLevel.ERROR, 'getLookupConfig() : Invalid request parameters. lookupConfigId= ' + lookupConfigId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            final List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = queryLookupConfigRecords( lookupConfigId, null );
            
            if(lookupConfigList.isEmpty()){
                System.debug( LoggingLevel.ERROR, 'queryLookupConfigRecord() : Requested lookupConfigId does not exist. lookupConfigId= ' + lookupConfigId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            lookupConfig = createLookupConfigWrapper(lookupConfigList[0]);                                           

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getLookupConfig() : Failed to retrieve Lookup Config. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getLookupConfig() - exit; Lookup Config Detail ' + lookupConfig );
        }
        
        return lookupConfig;
    }

    public Adm.LookupConfig saveLookupConfig( final Adm.LookupConfig lookupConfig ){
        
        System.debug( LoggingLevel.DEBUG, 'saveLookupConfig() - enter; lookupConfig ' + lookupConfig );

        Savepoint sPoint = Database.setSavepoint();

        try{
            
            if( lookupConfig == null || lookupConfig.name == null || String.isBlank( lookupConfig.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'saveLookupConfig() : Invalid request parameters. lookupConfig= ' + lookupConfig );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord = mapLookupConfig(lookupConfig);

            if(lookupConfig.basicFilter != null){
                    
                lookupConfig.basicFilter = ADM_ExpressionManager.getInstance().saveExpression( lookupConfig.basicFilter );
                    
                if( String.isNotBlank( lookupConfig.basicFilter.id ) ) {
                    lookupConfigRecord.SVMXA360__BasicFilter__c = lookupConfig.basicFilter.id;
                }            
            } else {
                if(lookupConfig.id != null){
                    final SVMXA360__CONF_LookupConfiguration__c oldLookupConfig = (SVMXA360__CONF_LookupConfiguration__c) SvmxDatabase.query( [SELECT SVMXA360__BasicFilter__c FROM SVMXA360__CONF_LookupConfiguration__c WHERE id = :lookupConfig.id ] ).get(0);
                    
                    if( oldLookupConfig.SVMXA360__BasicFilter__c != null ) {
                        ADM_ExpressionManager.getInstance().deleteExpression(oldLookupConfig.SVMXA360__BasicFilter__c);
                        lookupConfig.basicFilterId = null;
                    }
                }
            }

            lookupConfigRecord = (SVMXA360__CONF_LookupConfiguration__c) SvmxDatabase.upsertRecord(lookupConfigRecord);
                
            System.debug( LoggingLevel.INFO, 'saveLookupConfig() : Saved LookupConfiguration. Name= ' + lookupConfigRecord.Name );
            
            lookupConfig.id = lookupConfigRecord.id;
        }    
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveLookupConfig() : Failed to save LookupConfig. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveLookupConfig() : Failed to save LookupConfig. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveLookupConfig() - exit; lookupConfig= ' + lookupConfig );
        }
        
        return lookupConfig;
    } 

    public List<Adm.LookupConfig> saveLookupConfigurations( final List<Adm.LookupConfig> lookupConfigList ){
        
        System.debug( LoggingLevel.DEBUG, 'saveLookupConfigurations() - enter; lookupConfigList ' + lookupConfigList );

        Savepoint sPoint = Database.setSavepoint();

        try{
            
            if( lookupConfigList == null || lookupConfigList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveLookupConfigurations() : Invalid request parameters. lookupConfig= ' + lookupConfigList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = mapLookupConfigurations(lookupConfigList);

            lookupConfigRecordList = (List<SVMXA360__CONF_LookupConfiguration__c>) SvmxDatabase.upsertRecord(lookupConfigRecordList);
            
            for( Integer index = 0; index < lookupConfigRecordList.size(); index++ ) {
                lookupConfigList.get(index).id = lookupConfigRecordList.get(index).id;
            }
            
        }    
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveLookupConfigurations() : Failed to save LookupConfig. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveLookupConfigurations() : Failed to save LookupConfig. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveLookupConfigurations() - exit; lookupConfigList= ' + lookupConfigList );
        }
        
        return lookupConfigList;
    } 
    
    public Adm.ValidationResult validateLookupConfiguration( final Adm.LookupConfig lookupConfig ) {
        return validateLookupConfigurations( new List<Adm.LookupConfig> {lookupConfig} ).get(0);
    }
    
    public List<Adm.ValidationResult> validateLookupConfigurations( final List<Adm.LookupConfig> lookupConfigList ){
        
        System.debug( LoggingLevel.DEBUG, 'validateLookupConfigurations() - enter; lookupConfigList ' + lookupConfigList );
        
		List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            final List<Adm.ValidationResult> serviceValidationResults = new List<Adm.ValidationResult>();
            List<Adm.Expression> expressionList = new List<Adm.Expression>();
            
            for( Adm.LookupConfig lookupConfig : lookupConfigList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.LookupConfig );
                validationResults.add( validationResult );
                
                // Verify request for valid lookup config informations.
                if( lookupConfig == null || String.isBlank(lookupConfig.objectAPIName ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateLookupConfigurations() : Invalid request parameters. lookupConfig= ' + lookupConfig );
                    validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER);
                    continue;
                }
                
                if( !entityDefinitionMap.containsKey(lookupConfig.objectAPIName) ) {
                    
                    try {
                        final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(lookupConfig.objectAPIName);
                        entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                    }
                    catch( SvmxSystem.SvmxNestedException e ) {
                        
                        validationResult.setError('Object does not exists: ' + lookupConfig.objectAPIName);
                        continue;
                    }
                }
                
                if( lookupConfig.basicFilter != null ) {
                    serviceValidationResults.add(validationResult);
                    expressionList.add( lookupConfig.basicFilter );
                }
            }
            
            List<Adm.ValidationResult> expressionValidationResults = ADM_ExpressionManager.getInstance().validateExpressions(expressionList );
            
            for( Integer index = 0; index < serviceValidationResults.size(); index++ ) {
                
                final Adm.ValidationResult validationResult = serviceValidationResults.get(index);
                final Adm.ValidationResult expressionValidationResult = expressionValidationResults.get(index);
                
                if( !expressionValidationResult.isValid ) {
                    
                    if( String.isNotBlank(expressionValidationResult.error) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, expressionValidationResult.error ) );
                    }
                    
                    if( expressionValidationResult.detailResults != null && expressionValidationResult.detailResults.size() > 0 ) {
                        validationResult.addAllDetailResult( expressionValidationResult.detailResults );
                    }
                }
            }
        }    
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateLookupConfigurations() : Failed to validate LookupConfig. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateLookupConfigurations() : Failed to validate LookupConfig. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateLookupConfigurations() - exit; validationResults= ' + validationResults.size() );
        }
        
        return validationResults;
    } 
    
    public void deleteLookupConfig( final String lookupConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteLookupConfig() - enter; lookupConfigId= ' + lookupConfigId );
        
        Savepoint sPoint = Database.setSavepoint();

        try {
            if( String.isBlank( lookupConfigId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteLookupConfig() : Invalid request parameters. lookupConfigId= ' + lookupConfigId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = (List<SVMXA360__CONF_LookupConfiguration__c>) SvmxDatabase.query( [SELECT Id, SVMXA360__BasicFilter__c FROM SVMXA360__CONF_LookupConfiguration__c WHERE Id = :lookupConfigId] );
            
            if(lookupConfigRecordList.isEmpty()){
                
                System.debug( LoggingLevel.ERROR, 'deleteLookupConfig() : Requested record does not exist= ' + lookupConfigId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );                
            }

            SvmxDatabase.deleteRecord( lookupConfigRecordList );
            
            if( lookupConfigRecordList[0].SVMXA360__BasicFilter__c != null ) {
                ADM_ExpressionManager.getInstance().deleteExpression( lookupConfigRecordList[0].SVMXA360__BasicFilter__c );
            }
            
            System.debug( LoggingLevel.INFO, 'deleteLookupConfig() : LookupConfig deleted successfully. lookupConfigId= ' + lookupConfigId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            Database.rollback( sPoint );

            System.debug( LoggingLevel.ERROR, 'deleteLookupConfig() : Failed to delete LookupConfig. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deleteLookupConfig() : Failed to delete LookupConfig. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteLookupConfig() - exit');
        }
    }

    List<SVMXA360__CONF_LookupConfiguration__c> queryLookupConfigRecords( final String lookupConfigId, final String objectAPIName ) {

        String queryStr = 'SELECT Id, Name, SVMXA360__BasicFilter__c, SVMXA360__DefaultLookupforObject__c, ' +
                            'SVMXA360__DefaultOperator__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__DisplayFields__c, SVMXA360__ExtendedFields__c, '+ 
                            'SVMXA360__FieldToReturn__c, SVMXA360__ObjectAPIName__c, SVMXA360__HeaderRecordObject__c, SVMXA360__RecordsPerPageReturn__c, SVMXA360__SearchFields__c, LastModifiedDate, LastModifiedBy.Name FROM ' +
                            'SVMXA360__CONF_LookupConfiguration__c ';

        if(lookupConfigId != null || objectAPIName != null){
            queryStr += 'WHERE ';
            if(lookupConfigId != null){
                queryStr += 'Id =: lookupConfigId OR SVMXA360__DeveloperName__c =: lookupConfigId ';
            } else if(objectAPIName != null){
                queryStr += 'SVMXA360__ObjectAPIName__c =: objectAPIName ';
            } 
        }   
                 
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = Database.query( queryStr ) ;    
        return SvmxDatabase.query(lookupConfigRecordList);
    } 
    
    List<SVMXA360__CONF_LookupConfiguration__c> queryAllLookupConfigRecords() {

        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = SvmxDatabase.query( 
            [SELECT Id, Name, SVMXA360__BasicFilter__c, SVMXA360__DefaultLookupforObject__c, SVMXA360__DefaultOperator__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__DisplayFields__c, SVMXA360__ExtendedFields__c, SVMXA360__FieldToReturn__c, SVMXA360__ObjectAPIName__c, SVMXA360__HeaderRecordObject__c, SVMXA360__RecordsPerPageReturn__c, SVMXA360__SearchFields__c, LastModifiedDate, LastModifiedBy.Name 
             FROM SVMXA360__CONF_LookupConfiguration__c]);

        return lookupConfigRecordList;
    } 
    
    Adm.LookupConfig createLookupConfigWrapper( SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord ){
        final Adm.LookupConfig lookupConfig = new Adm.LookupConfig();
        lookupConfig.id = lookupConfigRecord.Id;
        lookupConfig.developerName = lookupConfigRecord.SVMXA360__DeveloperName__c;
        lookupConfig.name = lookupConfigRecord.Name;
        lookupConfig.description = lookupConfigRecord.SVMXA360__Description__c;
        lookupConfig.basicFilterId = lookupConfigRecord.SVMXA360__BasicFilter__c;
        lookupConfig.defaultLookup = lookupConfigRecord.SVMXA360__DefaultLookupforObject__c;
        lookupConfig.displayFields = lookupConfigRecord.SVMXA360__DisplayFields__c;
        lookupConfig.searchFields = lookupConfigRecord.SVMXA360__SearchFields__c;
        lookupConfig.extendedFields = lookupConfigRecord.SVMXA360__ExtendedFields__c;
        lookupConfig.fieldToReturn = lookupConfigRecord.SVMXA360__FieldToReturn__c;
        lookupConfig.objectAPIName = lookupConfigRecord.SVMXA360__ObjectAPIName__c;
        lookupConfig.headerRecordObject = lookupConfigRecord.SVMXA360__HeaderRecordObject__c;
        lookupConfig.defaultOperator = lookupConfigRecord.SVMXA360__DefaultOperator__c;
        lookupConfig.lastModifiedBy = lookupConfigRecord.LastModifiedBy.Name;
        lookupConfig.lastModifiedDate = String.valueOfGmt(lookupConfigRecord.LastModifiedDate);
        lookupConfig.recordsPerPage = Integer.valueOf(lookupConfigRecord.SVMXA360__RecordsPerPageReturn__c);
        return lookupConfig;
    }

    private List<SVMXA360__CONF_LookupConfiguration__c> mapLookupConfigurations( final List<Adm.LookupConfig> lookupConfigList) {
        
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigRecordList = new List<SVMXA360__CONF_LookupConfiguration__c>();
        for( Adm.LookupConfig lookupConfig : lookupConfigList ) {
            SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord = mapLookupConfig(lookupConfig);
            if( lookupConfig.basicFilterId != null ) {
                lookupConfigRecord.SVMXA360__BasicFilter__c = lookupConfig.basicFilterId;
            }
            lookupConfigRecordList.add(lookupConfigRecord);
        }
        return lookupConfigRecordList;
    }
    
    SVMXA360__CONF_LookupConfiguration__c mapLookupConfig(Adm.LookupConfig lookupConfig){
        SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord = new SVMXA360__CONF_LookupConfiguration__c();
        if(lookupConfig.id != null){
            lookupConfigRecord.Id = lookupConfig.id;
        }
        lookupConfigRecord.SVMXA360__DeveloperName__c = lookupConfig.developerName;
        lookupConfigRecord.Name = lookupConfig.name;
        lookupConfigRecord.SVMXA360__Description__c = lookupConfig.description;
        lookupConfigRecord.SVMXA360__DefaultLookupforObject__c = lookupConfig.defaultLookup;
        lookupConfigRecord.SVMXA360__DisplayFields__c = lookupConfig.displayFields;
        lookupConfigRecord.SVMXA360__SearchFields__c = lookupConfig.searchFields;
        lookupConfigRecord.SVMXA360__ExtendedFields__c = lookupConfig.extendedFields;
        lookupConfigRecord.SVMXA360__FieldToReturn__c = lookupConfig.fieldToReturn;
        lookupConfigRecord.SVMXA360__ObjectAPIName__c = lookupConfig.objectAPIName;
        lookupConfigRecord.SVMXA360__HeaderRecordObject__c = lookupConfig.headerRecordObject;
        lookupConfigRecord.SVMXA360__DefaultOperator__c = lookupConfig.defaultOperator;
        lookupConfigRecord.SVMXA360__RecordsPerPageReturn__c = lookupConfig.recordsPerPage;
        return lookupConfigRecord;

    }
}