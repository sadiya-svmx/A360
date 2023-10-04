/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * mapping informations. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 * A360TOOL-819 Ramachandra Mohan       26 Nov 2021     Validation service for Object Mapping.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_ObjectMappingManager {

    /**
     * Static variable to hold instance of this class.
     */
    private static ADM_ObjectMappingManager instance = null;
    
    /**
     * Static variable to hold object mapping details for each mappingId queried.
     */
    private static Map<String, Adm.ObjectMapping> objectMappingMap = new Map<String, Adm.ObjectMapping>();
    
    /**
     * Static variable to hold Object mapping with object mapping detail records.
     */
    private static Map<String, SVMXA360__CONF_ObjectMapping__c> objectMappingRecordMap = new Map<String, SVMXA360__CONF_ObjectMapping__c>();

    /**
     * Static variable to hold entityDetails.
     */
    Private static Map<String, String> entityDetails = new Map<String, String>();

    /**
     * Static method to return instnace of this class.
     */
    public static ADM_ObjectMappingManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_ObjectMappingManager();
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all object mapping records configured.
     */
    public List<Adm.ObjectMapping> getAllObjectMappings() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() - enter' );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getAllObjectMappingRecords();
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappings() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }
    
    /**
     * This method is used to retrieve all object mapping records configured.
     */
    public List<Adm.ObjectMapping> getAllObjectMappingsWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingsWithDetails() - enter' );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getAllObjectMappingWithDetailsRecords();
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    
                    final Adm.ObjectMapping objectMapping = createObjectMapping( objectMappingRecord );
                    
                    if( objectMappingRecord.Object_Mapping_Details__r.size() > 0 ) {
                        
                        // Create Object mapping details wrapper
                        objectMapping.objectMappingDetails = new List<Adm.ObjectMappingDetail>();
                        for( SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord : objectMappingRecord.Object_Mapping_Details__r ) {
                            objectMapping.objectMappingDetails.add( createObjectMappingDetail( objectMappingDetailRecord ) );
                        }
                    }
                    
                    objectMappingList.add( objectMapping );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingsWithDetails() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappingsWithDetails() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingsWithDetails() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }

        
    /**
     * This method is used to retrieve all object mapping records configured.
     */
    public Map<String, Adm.ObjectMapping> getObjectMappingsWithDetailsByIds(List<String> mappingIds) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsWithDetailsByIds() - enter' );
        
        Map<String, Adm.ObjectMapping> objectMappingMap = new Map<String, Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping id
            if( mappingIds == null || mappingIds.isEmpty() ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingWithDetailRecords() : Invalid request parameters. mappingIds= ' + mappingIds );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getAllObjectMappingWithDetailsRecords(mappingIds);
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    
                    final Adm.ObjectMapping objectMapping = createObjectMapping( objectMappingRecord );
                    
                    if( objectMappingRecord.Object_Mapping_Details__r.size() > 0 ) {
                        
                        // Create Object mapping details wrapper
                        objectMapping.objectMappingDetails = new List<Adm.ObjectMappingDetail>();
                        for( SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord : objectMappingRecord.Object_Mapping_Details__r ) {
                            objectMapping.objectMappingDetails.add( createObjectMappingDetail( objectMappingDetailRecord ) );
                        }
                    }
                    
                    objectMappingMap.put( objectMapping.id, objectMapping );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsWithDetailsByIds() : Retrieved requested object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsWithDetailsByIds() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsWithDetailsByIds() - exit; objectMappingMap.size()= ' + objectMappingMap.size() );
        }
        
        return objectMappingMap;
    }

    /**
     * This method is used to retrieve object mapping records configured for requested target object API name.
     */
    public List<Adm.ObjectMapping> getObjectValueMappingsByName( final String targetObjectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() - enter; targetObjectAPIName= ' + targetObjectAPIName );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getObjectValueMappingRecordsByName( targetObjectAPIName );
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to retrieve object mapping records configured for requested target object API name.
     */
    public List<Adm.ObjectMapping> getObjectValueMappingsByName( final String targetObjectAPIName, final String headerObject ) {
       
        System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() - enter; targetObjectAPIName= ' + targetObjectAPIName );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__Description__c,
                                                                    SVMXA360__TargetObjectAPIName__c, SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_ObjectMapping__c WHERE 
                                                                    SVMXA360__TargetObjectAPIName__c = :targetObjectAPIName AND SVMXA360__Type__c = 'Value Mapping' AND 
                                                                    (SVMXA360__HeaderRecordObject__c =: headerObject OR SVMXA360__HeaderRecordObject__c = null) ORDER BY Name] );
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to retrieve object mapping records configured for requested target object API name.
     */
    public List<Adm.ObjectMapping> getObjectMappingsByName( final String targetObjectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter; targetObjectAPIName= ' + targetObjectAPIName );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getObjectMappingRecordsByName( targetObjectAPIName );
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }
    
    /**
     * This method is used to retrieve object mapping records configured for requested target object API name.
     */
    public List<Adm.ObjectMapping> getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter; targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName=' + sourceObjectAPIName );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) || String.isBlank( sourceObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName=' + sourceObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getObjectMappingRecordsByName( targetObjectAPIName, sourceObjectAPIName );
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to retrieve object mapping records configured for requested target object API name.
     */
    public List<Adm.ObjectMapping> getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName, final String headerObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter; targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName=' + sourceObjectAPIName );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) || String.isBlank( sourceObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName=' + sourceObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c , SVMXA360__SourceObjectAPIName__c, 
                            SVMXA360__TargetObjectAPIName__c,  SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_ObjectMapping__c 
                            WHERE SVMXA360__TargetObjectAPIName__c = :targetObjectAPIName AND SVMXA360__SourceObjectAPIName__c =:sourceObjectAPIName 
                            AND (SVMXA360__HeaderRecordObject__c =: headerObject OR SVMXA360__HeaderRecordObject__c = null)
                            ORDER BY Name] );

            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to retrieve object mapping records configured for requested target object API name.
     */
    public List<Adm.ObjectMapping> getObjectMappingsByName( final List<String> targetObjectAPIName, final List<String> sourceObjectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter; targetObjectAPIName.size= ' + targetObjectAPIName.size() + '; sourceObjectAPIName.size=' + sourceObjectAPIName.size() );
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            
            // Verify object mapping ids
            if( targetObjectAPIName.isEmpty() || sourceObjectAPIName.isEmpty() ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName.size() + '; sourceObjectAPIName=' + sourceObjectAPIName.size() );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all object mappings
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = getObjectMappingRecordsByName( targetObjectAPIName, sourceObjectAPIName );
            
            if( objectMappingRecordList.size() > 0 ) {
                
                // Create object mapping wrapper for each mapping retrieved.
                for( SVMXA360__CONF_ObjectMapping__c objectMappingRecord : objectMappingRecordList ) {
                    objectMappingList.add( createObjectMapping( objectMappingRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() : Retrieved all object mappings' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }
    
    /**
     * This method is used to retrieve all object mapping records.
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getAllObjectMappingRecords() {
        
        final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList;
        
        try {
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c , SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c, SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_ObjectMapping__c ORDER BY Name] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappingRecords() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingRecords() - exit; objectMappingList.size()= ' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }
    
    /**
     * Retrieve mapping by target object API name.
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getObjectMappingRecordsByName( final String targetObjectAPIName) {
        
        final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList;
        
        try {
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingRecordsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c , SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c, SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__TargetObjectAPIName__c = : String.escapeSingleQuotes(targetObjectAPIName) ORDER BY Name] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingRecordsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingRecordsByName() - exit; objectMappingList.size()= ' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }

    /**
     * Retrieve value mappings by target object API name.
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getObjectValueMappingRecordsByName( final String targetObjectAPIName) {
        
        final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList;
        
        try {
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectValueMappingRecordsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c , SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c, SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name FROM 
                                                           SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__TargetObjectAPIName__c = :targetObjectAPIName AND SVMXA360__Type__c = 'Value Mapping' ORDER BY Name] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingRecordsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingRecordsByName() - exit; objectMappingList.size()= ' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }
    
    /**
     * Retrieve mapping by target object API name and Source object API name.
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getObjectMappingRecordsByName( final String targetObjectAPIName, final String sourceObjectAPIName ) {
        
        final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList;
        
        try {
            // Verify object mapping id
            if( String.isBlank(targetObjectAPIName ) || String.isBlank( sourceObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingRecordsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName=' + sourceObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c , SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c,  SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name 
                                                           FROM SVMXA360__CONF_ObjectMapping__c 
                                                           WHERE SVMXA360__TargetObjectAPIName__c = :targetObjectAPIName AND SVMXA360__SourceObjectAPIName__c =:sourceObjectAPIName ORDER BY Name] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingRecordsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingRecordsByName() - exit; objectMappingList.size()= ' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }
    /**
     * Retrieve mapping by target object API name and Source object API name.
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getObjectMappingRecordsByName( final List<String> targetObjectAPIName, final List<String> sourceObjectAPIName ) {
        
        final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList;
        
        try {
            // Verify object mapping ids
            if( targetObjectAPIName.isEmpty() || sourceObjectAPIName.isEmpty() ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingRecordsByName() : Invalid request parameters. targetObjectAPIName= ' + targetObjectAPIName.size() + '; sourceObjectAPIName=' + sourceObjectAPIName.size() );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c , SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c, SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name 
                                                           FROM SVMXA360__CONF_ObjectMapping__c 
                                                           WHERE SVMXA360__TargetObjectAPIName__c IN:targetObjectAPIName AND SVMXA360__SourceObjectAPIName__c IN:sourceObjectAPIName ORDER BY Name] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingRecordsByName() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingRecordsByName() - exit; objectMappingList.size()= ' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }
    /**
     * 
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getAllObjectMappingWithDetailsRecords() {
        
        List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = new List<SVMXA360__CONF_ObjectMapping__c>();
        
        try {
                
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Type__c, SVMXA360__Description__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c,  SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name,
                                                           (SELECT Id, SVMXA360__Type__c, SVMXA360__SourceFieldAPIName__c, SVMXA360__TargetFieldAPIName__c, SVMXA360__Value__c, SVMXA360__LiteralParameter__c, SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c FROM Object_Mapping_Details__r ) 
                                                           FROM SVMXA360__CONF_ObjectMapping__c] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappingWithDetailsRecords() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingWithDetailsRecords() - exit; objectMappingRecordList=' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }

    /**
     * 
     */
    public List<SVMXA360__CONF_ObjectMapping__c> getAllObjectMappingWithDetailsRecords( List<String> mappingIds ) {
        
        List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = new List<SVMXA360__CONF_ObjectMapping__c>();
        
        try {
                
            objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Type__c, SVMXA360__Description__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c,  SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name,
                                                           (SELECT Id, SVMXA360__Type__c, SVMXA360__SourceFieldAPIName__c, SVMXA360__TargetFieldAPIName__c, SVMXA360__Value__c, SVMXA360__LiteralParameter__c, SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c FROM Object_Mapping_Details__r ) 
                                                           FROM SVMXA360__CONF_ObjectMapping__c WHERE Id IN: mappingIds OR SVMXA360__DeveloperName__c IN: mappingIds] );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappingWithDetailsRecords() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingWithDetailsRecords() - exit; objectMappingRecordList=' + objectMappingRecordList.size() );
        }
        
        return objectMappingRecordList;
    }

    /**
     * 
     */
    public SVMXA360__CONF_ObjectMapping__c getObjectMappingWithDetailRecords( final String objectMappingId ) {
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord;
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(objectMappingId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingWithDetailRecords() : Invalid request parameters. objectMappingId= ' + objectMappingId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            if( !objectMappingRecordMap.containsKey( objectMappingId ) ) {
                
                List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Type__c, SVMXA360__Description__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c,  SVMXA360__HeaderRecordObject__c, LastModifiedDate, LastModifiedBy.Name,
                                                    (SELECT Id, SVMXA360__Type__c, SVMXA360__SourceFieldAPIName__c, SVMXA360__TargetFieldAPIName__c, SVMXA360__Value__c, SVMXA360__LiteralParameter__c, SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c FROM Object_Mapping_Details__r ) 
                                                    FROM SVMXA360__CONF_ObjectMapping__c WHERE id = :objectMappingId OR SVMXA360__DeveloperName__c = :objectMappingId ] );
            	
                if( objectMappingRecordList.size() > 0 ) {
                    objectMappingRecordMap.put(objectMappingId, objectMappingRecordList.get(0) );
                }
            }
            
            objectMappingRecord = objectMappingRecordMap.get(objectMappingId);
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingWithDetailRecords() : Failed to retrieve Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingWithDetailRecords() - exit; objectMappingRecord=' + objectMappingRecord );
        }
        
        return objectMappingRecord;
    }
    
    /**
     * 
     */
    public Adm.ObjectMapping getObjectMappingDetails( final String objectMappingId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - enter; objectMappingId= ' + objectMappingId );
        
        Adm.ObjectMapping objectMapping;
        
        try {
            
            // Verify object mapping id
            if( String.isBlank(objectMappingId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Invalid request parameters. objectMappingId= ' + objectMappingId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            if( !objectMappingMap.containsKey(objectMappingId) ) {
                
                // Retrieve object mapping and object mapping details for requested object mapping id
                final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = getObjectMappingWithDetailRecords( objectMappingId );
                
                // Throw record not exists exception if no record found for requested mapping id
                if( objectMappingRecord != null ) {
                    
                    // Create object mapping and object mapping detail wrappers
                    objectMapping = createObjectMapping( objectMappingRecord );
                    if( objectMappingRecord.Object_Mapping_Details__r.size() > 0 ) {
                        Set<String> sourceObjectFields = new Set<String>();
                        Set<String> targetObjectFields = new Set<String>();
                        Set<String> userFields = new Set<String>();
                        Set<String> headerObjectFields = new Set<String>();
                        
                        // Create Object mapping details wrapper
                        objectMapping.objectMappingDetails = new List<Adm.ObjectMappingDetail>();
                        for( SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord : objectMappingRecord.Object_Mapping_Details__r ) {
                            if (objectMappingDetailRecord.SVMXA360__Type__c == 'Field') {
                                sourceObjectFields.add(objectMappingDetailRecord.SVMXA360__SourceFieldAPIName__c);  
                            }
                            targetObjectFields.add(objectMappingDetailRecord.SVMXA360__TargetFieldAPIName__c);
                            if (objectMappingDetailRecord.SVMXA360__Value__c == 'User') {
                                userFields.add(objectMappingDetailRecord.SVMXA360__LiteralParameter__c);
                            } else if (objectMappingDetailRecord.SVMXA360__Value__c == 'Current Record') {
                                targetObjectFields.add(objectMappingDetailRecord.SVMXA360__LiteralParameter__c);
                            } else if (objectMappingDetailRecord.SVMXA360__Value__c == 'Current Record Header') {
                                headerObjectFields.add(objectMappingDetailRecord.SVMXA360__LiteralParameter__c);
                            }
                            objectMapping.objectMappingDetails.add( createObjectMappingDetail( objectMappingDetailRecord ) );
                        }
                        objectMapping.message = queryMappingObjectFields(sourceObjectFields, targetObjectFields, userFields, headerObjectFields, objectMapping);
                    }
                    objectMappingMap.put(objectMappingId, objectMapping );
                } else {
                    System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Record not exists. objectMappingId= ' + objectMappingId );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
                }
            }
            
            objectMapping = objectMappingMap.get(objectMappingId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mapping details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - exit; objectMapping= ' + objectMapping );
        }
        
        return objectMapping;
    }

    /**
     * Method validates to find if there are any change in field api name or field data type before saving mapping
     */
    public Adm.ObjectMapping validateBeforeSaveMappingDetails( Adm.ObjectMapping objectMapping ) {
        System.debug( LoggingLevel.DEBUG, 'validateBeforeSaveMappingDetails() - enter' );

        objectMapping.message = '';
        if(objectMapping != null && objectMapping.objectMappingDetails.size() > 0) {
            Set<String> sourceObjectFields = new Set<String>();
            Set<String> targetObjectFields = new Set<String>();
            Set<String> userFields = new Set<String>();
            Set<String> headerObjectFields = new Set<String>();
            for( Adm.ObjectMappingDetail mappingDetailRecord : objectMapping.objectMappingDetails ) {
                if (mappingDetailRecord.mappingType == 'Field') {
                    sourceObjectFields.add(mappingDetailRecord.sourceFieldAPIName);  
                }
                targetObjectFields.add(mappingDetailRecord.targetFieldAPIName);
                if (mappingDetailRecord.value == 'User') {
                    userFields.add(mappingDetailRecord.literalParameterAPIName);
                } else if (mappingDetailRecord.value == 'Current Record') {
                    targetObjectFields.add(mappingDetailRecord.literalParameterAPIName);
                } else if (mappingDetailRecord.value == 'Current Record Header') {
                    headerObjectFields.add(mappingDetailRecord.literalParameterAPIName);
                }
            }
            objectMapping.message = queryMappingObjectFields(sourceObjectFields, targetObjectFields, userFields, headerObjectFields, objectMapping);
        }

        System.debug( LoggingLevel.DEBUG, 'validateBeforeSaveMappingDetails() - exit' );
        return objectMapping;
    
    }    

    /**
     * Method validates to find if there are any change in field api name or field data type on retrieve
     */
    public Adm.ValidationResult validateObjectMapping( Adm.ObjectMapping objectMapping  ) { 
        
        System.debug( LoggingLevel.DEBUG, 'validateObjectMapping() - enter' );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.Mapping );
        
        try {
            
            List<String> objectList = new List<String>();
            if (entityDetails == null || entityDetails.size() == 0) {
                List<Common.EntityDetails> sObjectTypeAllDetails = COMM_DescribeManager.getInstance().getAllGlobalDescribe();
                for (Common.EntityDetails entityDetail: sObjectTypeAllDetails) {
                    entityDetails.put(entityDetail.objectAPIName, entityDetail.objectLabel);
                }  
            }
            if (String.isNotBlank(objectMapping.sourceObjectAPIName) && entityDetails.containsKey(objectMapping.sourceObjectAPIName)) {
                objectList.add(objectMapping.sourceObjectAPIName);
            }
            if (String.isNotBlank(objectMapping.targetObjectAPIName) && entityDetails.containsKey(objectMapping.targetObjectAPIName)) {
                objectList.add(objectMapping.targetObjectAPIName);
            }
            if (String.isNotBlank(objectMapping.headerRecordObject) && entityDetails.containsKey(objectMapping.headerRecordObject)) {
                objectList.add(objectMapping.headerRecordObject);
            }
            
            if (String.isNotBlank(objectMapping.sourceObjectAPIName) && !entityDetails.containsKey(objectMapping.sourceObjectAPIName)) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Source Object does not exists: ' + objectMapping.sourceObjectAPIName ) );
            }
                                                 
            if (String.isNotBlank(objectMapping.targetObjectAPIName) && !entityDetails.containsKey(objectMapping.targetObjectAPIName)) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Target Object does not exists: ' + objectMapping.targetObjectAPIName ) );
            }
            if (String.isNotBlank(objectMapping.headerRecordObject) && !entityDetails.containsKey(objectMapping.headerRecordObject)) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Header Object does not exists: ' + objectMapping.headerRecordObject ) );
            }
            
            objectList.add('User');
            for( Adm.ObjectMappingDetail mappingDetailRecord : objectMapping.objectMappingDetails ) {
                if (String.isNotBlank(mappingDetailRecord.relatedObjectDetails)) {
                    if (mappingDetailRecord.relatedObjectDetails.contains('.')) {
                        objectList.addAll(mappingDetailRecord.relatedObjectDetails.split('\\.') );
                    } else {
                        objectList.add(mappingDetailRecord.relatedObjectDetails);
                    }
                }
            }
            Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
            sObjectResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults(objectList);

            for( Adm.ObjectMappingDetail mappingDetailRecord : objectMapping.objectMappingDetails ) {
                mappingDetailRecord.errorMessage = '';
                Adm.MappingErrorMessage errorDetail = new Adm.MappingErrorMessage();
                if( mappingDetailRecord.targetFieldAPIName.endsWithIgnoreCase('Longitude__s') || mappingDetailRecord.targetFieldAPIName.endsWithIgnoreCase('Latitude__s') ) {
                    mappingDetailRecord.targetFieldAPIName = mappingDetailRecord.targetFieldAPIName.replace('Longitude__s', 'c');
                    mappingDetailRecord.targetFieldAPIName = mappingDetailRecord.targetFieldAPIName.replace('Latitude__s', 'c');
                }
                errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.targetObjectAPIName, mappingDetailRecord.targetFieldAPIName.toLowerCase());
                if( errorDetail.hasError ) {
                    errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.targetObjectAPIName, mappingDetailRecord.targetFieldAPIName);
                }
                if (errorDetail != null && errorDetail.hasError ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Object: ' + objectMapping.targetObjectAPIName + ', Field does not exists: ' + errorDetail.errorMessage.substring( 0, errorDetail.errorMessage.length() - 1 ) ) );
                }
                if(errorDetail == null || (errorDetail != null && !errorDetail.hasError)) {
                    
                    if (mappingDetailRecord.mappingType.toUpperCase() == 'FIELD') {
                        
                        errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.sourceObjectAPIName, mappingDetailRecord.sourceFieldAPIName.toLowerCase() );
                        
                        if( errorDetail.hasError ) {
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.sourceObjectAPIName, mappingDetailRecord.sourceFieldAPIName );
                        }
                        
                        mappingDetailRecord = findMappingDetailErrors(errorDetail, mappingDetailRecord, sObjectResultMap, objectMapping.targetObjectAPIName, objectMapping.sourceObjectAPIName, mappingDetailRecord.sourceFieldAPIName);
                        if( errorDetail != null && errorDetail.hasError ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Object: ' + objectMapping.targetObjectAPIName + ', Field does not exists: ' + errorDetail.errorMessage.substring( 0, errorDetail.errorMessage.length() - 1 ) ) );
                        }
                    }
                    
                    if (mappingDetailRecord.mappingType.toUpperCase() == 'VALUE' && mappingDetailRecord.targetFieldAPIName.equalsIgnoreCase('RecordTypeId') && String.isNotBlank(mappingDetailRecord.value) ) {
                        if( !COMM_RecordTypeManager.getInstance().hasRecordType(objectMapping.targetObjectAPIName, mappingDetailRecord.value) ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Object: ' + objectMapping.targetObjectAPIName + ', RecordType does not exists: ' + mappingDetailRecord.value ) );
                        }
                    }
                    
                    if (mappingDetailRecord.mappingType.toUpperCase() == 'FUNCTION' && (mappingDetailRecord.value == 'User' || mappingDetailRecord.value == 'Current Record' || mappingDetailRecord.value == 'Current Record Header')) { 
                        
                        String literalObjectApiName = '';
                        if (mappingDetailRecord.value == 'User') {
                            literalObjectApiName = 'User';
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, 'User', mappingDetailRecord.literalParameterAPIName.toLowerCase()); 
                            if( errorDetail.hasError ) {
                                errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, 'User', mappingDetailRecord.literalParameterAPIName); 
                            }
                        } else if (mappingDetailRecord.value == 'Current Record') {
                            literalObjectApiName = objectMapping.targetObjectAPIName;
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.targetObjectAPIName, mappingDetailRecord.literalParameterAPIName.toLowerCase()); 
                            if( errorDetail.hasError ) {
                                errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.targetObjectAPIName, mappingDetailRecord.literalParameterAPIName); 
                            }
                        } else if (mappingDetailRecord.value == 'Current Record Header' && objectMapping.headerRecordObject != null ) {
                            literalObjectApiName = objectMapping.headerRecordObject;
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.headerRecordObject, mappingDetailRecord.literalParameterAPIName.toLowerCase());
                            if( errorDetail.hasError ) {
                                errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.headerRecordObject, mappingDetailRecord.literalParameterAPIName);
                            }
                        }
                        
                        if( String.isNotBlank(literalObjectApiName) && String.isNotBlank(mappingDetailRecord.literalParameterAPIName) ) {
                            mappingDetailRecord = findMappingDetailErrors(errorDetail, mappingDetailRecord, sObjectResultMap, objectMapping.targetObjectAPIName, literalObjectApiName, mappingDetailRecord.literalParameterAPIName);
                        }
                        
                        if( errorDetail != null && errorDetail.hasError ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Mapping, 'Object: ' + objectMapping.targetObjectAPIName + ', Field does not exists: ' + errorDetail.errorMessage.substring( 0, errorDetail.errorMessage.length() - 1 ) ) );
                        }
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Failed to retrieve Object Mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Failed to retrieve Object Mapping details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateObjectMapping() - exit; validationResult= ' + validationResult );
        }
        
        return validationResult;

    }
    
    /**
     * Method validates to find if there are any change in field api name or field data type on retrieve
     */
    public Adm.ObjectMapping validateMapping( Adm.ObjectMapping objectMapping  ) { 
        System.debug( LoggingLevel.DEBUG, 'validateMapping() - enter' );
        
        try {
            Integer errorCount = 0;
            List<String> objectList = new List<String>();
            if (entityDetails == null || entityDetails.size() == 0) {
                List<Common.EntityDetails> sObjectTypeAllDetails = COMM_DescribeManager.getInstance().getAllGlobalDescribe();
                for (Common.EntityDetails entityDetail: sObjectTypeAllDetails) {
                    entityDetails.put(entityDetail.objectAPIName, entityDetail.objectLabel);
                }  
            }
            if (String.isNotBlank(objectMapping.sourceObjectAPIName) && entityDetails.containsKey(objectMapping.sourceObjectAPIName)) {
                objectList.add(objectMapping.sourceObjectAPIName);
            }
            if (String.isNotBlank(objectMapping.targetObjectAPIName) && entityDetails.containsKey(objectMapping.targetObjectAPIName)) {
                objectList.add(objectMapping.targetObjectAPIName);
            }
            if (String.isNotBlank(objectMapping.headerRecordObject) && entityDetails.containsKey(objectMapping.headerRecordObject)) {
                objectList.add(objectMapping.headerRecordObject);
            }
            objectList.add('User');
            for( Adm.ObjectMappingDetail mappingDetailRecord : objectMapping.objectMappingDetails ) {
                if (String.isNotBlank(mappingDetailRecord.relatedObjectDetails)) {
                    if (mappingDetailRecord.relatedObjectDetails.contains('.')) {
                        objectList.addAll(mappingDetailRecord.relatedObjectDetails.split('\\.') );
                    } else {
                        objectList.add(mappingDetailRecord.relatedObjectDetails);
                    }
                }
            }
            Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
            sObjectResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults(objectList);

            for( Adm.ObjectMappingDetail mappingDetailRecord : objectMapping.objectMappingDetails ) {
                mappingDetailRecord.errorMessage = '';
                Adm.MappingErrorMessage errorDetail = new Adm.MappingErrorMessage();
                errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.targetObjectAPIName, mappingDetailRecord.targetFieldAPIName);
                if (errorDetail != null) {
                    errorCount = errorDetail.hasError ? errorCount + 1 : errorCount;
                }
                if(errorDetail == null || (errorDetail != null && !errorDetail.hasError)) {    
                    if (mappingDetailRecord.mappingType.toUpperCase() == 'FIELD') {
                        errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.sourceObjectAPIName, mappingDetailRecord.sourceFieldAPIName);
                        mappingDetailRecord = findMappingDetailErrors(errorDetail, mappingDetailRecord, sObjectResultMap, objectMapping.targetObjectAPIName, objectMapping.sourceObjectAPIName, mappingDetailRecord.sourceFieldAPIName);
                        errorCount = mappingDetailRecord.hasError != null && mappingDetailRecord.hasError ? errorCount + 1 : errorCount;
                    }
                if (mappingDetailRecord.mappingType.toUpperCase() == 'FUNCTION' && (mappingDetailRecord.value == 'User' || mappingDetailRecord.value == 'Current Record' || mappingDetailRecord.value == 'Current Record Header')) { 
                        String literalObjectApiName = '';
                        if (mappingDetailRecord.value == 'User') {
                            literalObjectApiName = 'User';
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, 'User', mappingDetailRecord.literalParameterAPIName); 
                        } else if (mappingDetailRecord.value == 'Current Record') {
                            literalObjectApiName = objectMapping.targetObjectAPIName;
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.targetObjectAPIName, mappingDetailRecord.literalParameterAPIName);
                        } else if (mappingDetailRecord.value == 'Current Record Header') {
                            literalObjectApiName = objectMapping.headerRecordObject;
                            errorDetail = validateObjectMappingDetail(sObjectResultMap, mappingDetailRecord, objectMapping.headerRecordObject, mappingDetailRecord.literalParameterAPIName);
                        }
                        mappingDetailRecord = findMappingDetailErrors(errorDetail, mappingDetailRecord, sObjectResultMap, objectMapping.targetObjectAPIName, literalObjectApiName, mappingDetailRecord.literalParameterAPIName);
                        errorCount = mappingDetailRecord.hasError != null && mappingDetailRecord.hasError ? errorCount + 1 : errorCount;  
                    }
                }
            }
            if(errorCount > 0) {
                objectMapping.message = System.Label.Message_ErrorOccured;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateMapping() : Failed to retrieve Object Mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateMapping() : Failed to retrieve Object Mapping details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateMapping() - exit; objectMapping= ' + objectMapping );
        }
        
        return objectMapping;

    }

     /**
     * 
     */
    public Adm.MappingErrorMessage validateObjectMappingDetail( Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap, Adm.ObjectMappingDetail mappingDetailRecord, String objectApiName, String objectFieldApiName ) {

        Adm.MappingErrorMessage errorDetail = new Adm.MappingErrorMessage();
        errorDetail.hasError = false;
        errorDetail.errorMessage = '';  

        if(objectFieldApiName.contains('.') && String.isNotBlank(mappingDetailRecord.relatedObjectDetails)) {
            List<String> objectList = new List<String>();
            List<String> fieldList = new List<String>();
            objectList.add(objectApiName);
            objectList.addAll(mappingDetailRecord.relatedObjectDetails.split('\\.'));
            fieldList.addAll(objectFieldApiName.split('\\.'));
            for (Integer index = 0; index < fieldList.size() ; index++) {
                String fieldApiName;
                if(index != fieldList.size() -1) {
                    if (fieldList[index].endsWith('__r')) {
                        fieldApiName = fieldList[index].replace('__r', '__c');
                    } else {
                        fieldApiName = fieldList[index].substringBefore('.') + 'Id';
                    }
                } else {
                    fieldApiName = fieldList[index];   
                }
                if (sObjectResultMap.get(objectList[index]) == null || !sObjectResultMap.get(objectList[index]).containsKey(fieldApiName) ||
                (sObjectResultMap.get(objectList[index]).containsKey(fieldApiName) && !sObjectResultMap.get(objectList[index]).get(fieldApiName).isAccessible())) {
                    errorDetail.hasError = true;
                    errorDetail.errorMessage += fieldApiName + ',';     
                }
            }
        } else if (sObjectResultMap.get(objectApiName) == null || !sObjectResultMap.get(objectApiName).containsKey(objectFieldApiName) ||
        (sObjectResultMap.get(objectApiName).containsKey(objectFieldApiName) && !sObjectResultMap.get(objectApiName).get(objectFieldApiName).isAccessible())) {

            errorDetail.hasError = true;
            errorDetail.errorMessage += objectFieldApiName + ',';
        }
        return errorDetail;
    }

    /**
     * 
     */
    public Adm.MappingErrorMessage validateMappingDetailDataType( Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap, Adm.ObjectMappingDetail mappingDetailRecord, String targetObjectAPIName, String sourceObjectAPIName, String objectFieldApiName ) {

        Adm.MappingErrorMessage errorDetail = new Adm.MappingErrorMessage();
        errorDetail.hasError = false;
        errorDetail.errorMessage = ''; 
        Schema.DisplayType targetFieldType;
        Schema.DisplayType fieldType;
        if (sObjectResultMap.get(targetObjectAPIName).get(mappingDetailRecord.targetFieldAPIName) != null) {
            targetFieldType = sObjectResultMap.get(targetObjectAPIName).get(mappingDetailRecord.targetFieldAPIName).getType();   
        }
        if(objectFieldApiName.contains('.') && String.isNotBlank(mappingDetailRecord.relatedObjectDetails)) {
            String objectName;
            if (mappingDetailRecord.relatedObjectDetails.contains('.')) {
                objectName = mappingDetailRecord.relatedObjectDetails.substringAfterLast('.');
            } else {
                objectName =  mappingDetailRecord.relatedObjectDetails;  
            }
            String fieldName = objectFieldApiName.substringAfterLast('.');
            if (sObjectResultMap.get(objectName).get(fieldName) != null) {
                fieldType = sObjectResultMap.get(objectName).get(fieldName).getType();
            }
            errorDetail = checkDataTypeCompatibility(targetFieldType, fieldType);
        } else {
            if (sObjectResultMap.get(sourceObjectAPIName).get(objectFieldApiName) != null) {
                fieldType = sObjectResultMap.get(sourceObjectAPIName).get(objectFieldApiName).getType();
            }
            if ( targetFieldType != null && fieldType != null) {
                errorDetail = checkDataTypeCompatibility(targetFieldType, fieldType);
            }    
        }
        return errorDetail;
    }

    private Adm.MappingErrorMessage checkDataTypeCompatibility (Schema.DisplayType targetDateType, Schema.DisplayType sourceDataType) {
        Adm.MappingErrorMessage errorDetail = new Adm.MappingErrorMessage();
        errorDetail.hasError = false;
        errorDetail.errorMessage = ''; 
        Map<Schema.DisplayType, List<Schema.DisplayType>> compatibilityMatrix = new Map<Schema.DisplayType, List<Schema.DisplayType>>();
        compatibilityMatrix = populateCompatibilityMatrix();
        if (targetDateType == Schema.DisplayType.DATE && !compatibilityMatrix.get(targetDateType).contains(sourceDataType)) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,'; 
        } else if (targetDateType == Schema.DisplayType.MULTIPICKLIST && !compatibilityMatrix.get(targetDateType).contains(sourceDataType)) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,'; 
        } else if (targetDateType == Schema.DisplayType.TEXTAREA && !compatibilityMatrix.get(targetDateType).contains(sourceDataType)) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,'; 
        } else if (targetDateType == Schema.DisplayType.ENCRYPTEDSTRING && !compatibilityMatrix.get(targetDateType).contains(sourceDataType)) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,'; 
        } else if (targetDateType == Schema.DisplayType.STRING && !compatibilityMatrix.get(targetDateType).contains(sourceDataType)) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,'; 
        } else if (targetDateType == Schema.DisplayType.EMAIL && !compatibilityMatrix.get(targetDateType).contains(sourceDataType)) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,'; 
        } else if (!compatibilityMatrix.keySet().contains(targetDateType) && targetDateType != sourceDataType && targetDateType != Schema.DisplayType.REFERENCE) {
            errorDetail.hasError = true;
            errorDetail.errorMessage += 'Invalid data type,';  
        }
        return errorDetail;
    }
    
    /**
     * This method is used to save/update object mapping and object mapping details.
     * 
     * @param objectMapping Object mapping with list of object mapping details to be saved.
     */
    public Adm.ObjectMapping saveObjectMapping( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveObjectMapping() - enter; objectMapping= ' + objectMapping );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid object mapping informations.
            if( objectMapping == null || objectMapping.name == null || String.isBlank(objectMapping.targetObjectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Invalid request parameters. objectMapping= ' + objectMapping );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Upsert object mapping record.
            final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxDatabase.upsertRecord(createObjectMappingRecord(objectMapping));
            
            System.debug( LoggingLevel.INFO, 'saveObjectMapping() : Saved Object Mapping record. Name= ' + objectMappingRecord.Name );
            
            Map<String, SVMXA360__CONF_ObjectMappingDetail__c> oldMappingDetailMap = new Map<String, SVMXA360__CONF_ObjectMappingDetail__c>();
            
            // Retrieve all existing object mapping detail records for requested object mapping. 
            // Retrieve only if the object mapping exists.
            if( String.isNotBlank( objectMapping.id ) != null ) {
                oldMappingDetailMap.putAll( [SELECT Id FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__c = :objectMapping.id ]);
            }
            
            // Varify object mapping details, throw exception if not exists.
            if( objectMapping.objectMappingDetails != null && objectMapping.objectMappingDetails.size() > 0 ) {
                
                // Create object mapping detail sobject for each detail in request
                List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetailRecordList = new List<SVMXA360__CONF_ObjectMappingDetail__c>();
                for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                    
                    // Create Object Mapping detail sObject
                    final SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord = createObjectMappingDetailSObject(objectMappingRecord.Id, objectMappingDetail );
                    
                    objectMappingDetailRecordList.add(objectMappingDetailRecord);
                    
                    // remove detail record from existing record list if found in request.
                    if( oldMappingDetailMap.containsKey( objectMappingDetailRecord.Id ) ) {
                        oldMappingDetailMap.remove( objectMappingDetailRecord.Id );
                    }
                }
                
                // Upsert all object mapping detail records
                objectMappingDetailRecordList = SvmxDatabase.upsertRecord(objectMappingDetailRecordList);
                
                System.debug( LoggingLevel.INFO, 'saveObjectMapping() : Saved Object Mapping Detail records. Name= ' + objectMappingRecord.Name );
                
                // Delete object mapping detail records which is removed in request.
                if( oldMappingDetailMap.size() > 0 ) {
                    delete oldMappingDetailMap.values();
                }
                
                // Update Id's for object mapping and object mapping details in response
                objectMapping.id = objectMappingRecord.id;
                for( Integer index = 0; index < objectMappingDetailRecordList.size(); index++ ) {
                    objectMapping.objectMappingDetails.get(index).id = objectMappingDetailRecordList.get(index).id;
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Invalid request parameters. objectMapping= ' + objectMapping );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveObjectMapping() - exit; objectMapping= ' + objectMapping );
        }
        
        return objectMapping;
    }
    
    /**
     * This method is used to save/update object mapping and object mapping details.
     * 
     * @param objectMappingList Object mapping with list of object mapping details to be saved.
     */
    public List<Adm.ObjectMapping> saveObjectMappings( final List<Adm.ObjectMapping> objectMappingList ) {
        return saveObjectMappings(objectMappingList, true);
    }
    
    /**
     * This method is used to save/update object mapping and object mapping details.
     * 
     * @param objectMappingList Object mapping with list of object mapping details to be saved.
     */
    public List<Adm.ObjectMapping> saveObjectMappings( final List<Adm.ObjectMapping> objectMappingList, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveObjectMappings() - enter; objectMappingList= ' + objectMappingList.size() );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid object mapping informations.
            if( objectMappingList == null || objectMappingList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Invalid request parameters. objectMappingList= ' + objectMappingList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Upsert object mapping record.
            final Map<Id, SVMXA360__CONF_ObjectMapping__c> objectMappingRecordMap = new Map<Id, SVMXA360__CONF_ObjectMapping__c>();
            final List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = (List<SVMXA360__CONF_ObjectMapping__c>) SvmxDatabase.upsertRecord(createObjectMappingRecords(objectMappingList), allOrNothing);
            
            objectMappingRecordMap.putAll( objectMappingRecordList );
            
            Map<String, SVMXA360__CONF_ObjectMappingDetail__c> oldMappingDetailMap = new Map<String, SVMXA360__CONF_ObjectMappingDetail__c>();
            
            // Retrieve all existing object mapping detail records for requested object mapping. 
            oldMappingDetailMap.putAll( (List<SVMXA360__CONF_ObjectMappingDetail__c>) SvmxDatabase.query([SELECT Id FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__c = :objectMappingRecordMap.keySet() ]));
                
            // Create object mapping detail sobject for each detail in request
            List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetailRecordList = new List<SVMXA360__CONF_ObjectMappingDetail__c>();
            
            for( Integer index = 0; index < objectMappingList.size(); index++ ) {
                
                final Adm.ObjectMapping objectMapping = objectMappingList.get(index);
                final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = objectMappingRecordList.get(index);
                
                objectMapping.id = objectMappingRecord.id;
                
                for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                    
                    // Create Object Mapping detail sObject
                    final SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord = createObjectMappingDetailSObject(objectMappingRecord.Id, objectMappingDetail );
                    objectMappingDetail.id = objectMappingDetailRecord.id;
                    
                    objectMappingDetailRecordList.add(objectMappingDetailRecord);
                    
                    // remove detail record from existing record list if found in request.
                    if( String.isNotBlank(objectMappingDetailRecord.Id) && oldMappingDetailMap.containsKey( objectMappingDetailRecord.Id ) ) {
                        oldMappingDetailMap.remove( objectMappingDetailRecord.Id );
                    }
                }
            }
            
            // Upsert all object mapping detail records
            objectMappingDetailRecordList = SvmxDatabase.upsertRecord(objectMappingDetailRecordList, allOrNothing );
            
            // Delete object mapping detail records which is removed in request.
            if( oldMappingDetailMap.size() > 0 ) {
                delete oldMappingDetailMap.values();
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Failed to save Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Failed to save Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveObjectMappings() - exit; objectMappingList= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }
    
    /**
     * This method is used to delete object mapping and object mapping detail records 
     * for requested object mapping id.
     */
    public void deleteObjectMapping( final String objectMappingId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteObjectMapping() - enter; objectMappingId= ' + objectMappingId );
        
        try {
            // Verify for valid mapping id.
            if( String.isBlank( objectMappingId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Invalid request parameters. objectMappingId= ' + objectMappingId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE Id = :objectMappingId OR SVMXA360__DeveloperName__c = :objectMappingId ] );
            
            System.debug( LoggingLevel.INFO, 'deleteObjectMapping() : Object mapping and details removed successfully. objectMappingId= ' + objectMappingId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to delete Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to delete Object Mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteObjectMapping() - exit');
        }
    }
    
    /**
     * This private method is used to create object mapping detail sobject 
     * for the requested wrapper structure.
     */
    private SVMXA360__CONF_ObjectMappingDetail__c createObjectMappingDetailSObject( String objectMappingId, Adm.ObjectMappingDetail objectMappingDetail ) {
        
        System.debug( LoggingLevel.FINE, 'createObjectMappingDetailSObject() - enter; objectMappingId= ' + objectMappingId );
        
        final SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord = new SVMXA360__CONF_ObjectMappingDetail__c();
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( objectMappingDetail.mappingType ) || String.isBlank( objectMappingDetail.targetFieldAPIName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'createObjectMappingDetailSObject() : Invalid request parameters. objectMappingDetail= ' + objectMappingDetail );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Assign id field if object detail already exists. 
            // Assign Master Object id only for new records.
            if( String.isNotBlank( objectMappingDetail.id ) ) {
                objectMappingDetailRecord.id = objectMappingDetail.id;
            } else {
                objectMappingDetailRecord.SVMXA360__ObjectMappingID__c = objectMappingId;
            }
            
            // Assign all field values from request to the sobject fields.
            objectMappingDetailRecord.SVMXA360__SourceFieldAPIName__c = objectMappingDetail.mappingType.equalsIgnoreCase('Function') ? null : objectMappingDetail.sourceFieldAPIName;
            objectMappingDetailRecord.SVMXA360__TargetFieldAPIName__c = objectMappingDetail.targetFieldAPIName;
            objectMappingDetailRecord.SVMXA360__Type__c = objectMappingDetail.mappingType;
            objectMappingDetailRecord.SVMXA360__Value__c = objectMappingDetail.mappingType.equalsIgnoreCase('Field') ? null : objectMappingDetail.value;
            objectMappingDetailRecord.SVMXA360__LiteralParameter__c = objectMappingDetail.mappingType.equalsIgnoreCase('Function') ? objectMappingDetail.literalParameterAPIName : null;
            objectMappingDetailRecord.SVMXA360__RelatedObjectDetails__c = objectMappingDetail.relatedObjectDetails;
        
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createObjectMappingDetailSObject() : Failed to create Object Mapping detail sobject. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createObjectMappingDetailSObject() - exit; record= ' + objectMappingDetailRecord );
        }
        
        return objectMappingDetailRecord;
    }
    
    /**
     * Private method to create Object mapping record.
     */
    private List<SVMXA360__CONF_ObjectMapping__c> createObjectMappingRecords( final List<Adm.ObjectMapping> objectMappingList ) {
        
        System.debug( LoggingLevel.FINE, 'createObjectMappingRecords() - enter; objectMappingList= ' + objectMappingList.size() );
        
        List<SVMXA360__CONF_ObjectMapping__c> objectMappingRecordList = new List<SVMXA360__CONF_ObjectMapping__c>();
        
        try {
            Map<String, Id> developerNameIdMap = new Map<String, Id>();
            
            for( SVMXA360__CONF_ObjectMapping__c mappingRecord : getAllObjectMappingRecords() ) {
                developerNameIdMap.put( mappingRecord.SVMXA360__DeveloperName__c, mappingRecord.id );
            }
            
            for( Adm.ObjectMapping objectMapping : objectMappingList ) {
                
                if( developerNameIdMap.containsKey( objectMapping.developerName ) ) {
                    objectMapping.id = developerNameIdMap.get(objectMapping.developerName);
                }
                
                objectMappingRecordList.add(createObjectMappingRecord(objectMapping));
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createObjectMappingRecords() - exit; objectMappingRecordList= ' + objectMappingRecordList );
        }
        
        return objectMappingRecordList;
    }
    
    /**
     * Private method to create Object mapping record.
     */
    private SVMXA360__CONF_ObjectMapping__c createObjectMappingRecord( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.FINE, 'createObjectMappingRecord() - enter; objectMapping= ' + objectMapping );
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = new SVMXA360__CONF_ObjectMapping__c();
        
        if( objectMapping.id != null ) {
            objectMappingRecord.Id = objectMapping.id;
        } else {
            objectMappingRecord.SVMXA360__DeveloperName__c = objectMapping.developerName; //COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping );
        }
        
        objectMappingRecord.SVMXA360__Type__c = objectMapping.mappingType;
        objectMappingRecord.SVMXA360__Description__c = objectMapping.description;
        objectMappingRecord.SVMXA360__SourceObjectAPIName__c = objectMapping.sourceObjectAPIName;
        objectMappingRecord.SVMXA360__TargetObjectAPIName__c = objectMapping.targetObjectAPIName;
        objectMappingRecord.Name = objectMapping.name;
        objectMappingRecord.SVMXA360__HeaderRecordObject__c = objectMapping.headerRecordObject;
        objectMappingRecord.SVMXA360__ObjectMappingJSON__c = JSON.serialize( objectMapping, true);
        
        return objectMappingRecord;
    }
    
    /**
     * Private method to create object mapping wrapper from object mapping record.
     */
    private Adm.ObjectMapping createObjectMapping( final SVMXA360__CONF_ObjectMapping__c objectMappingRecord ) {
        
        Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
        
        objectMapping.id = objectMappingRecord.Id;
        objectMapping.name = objectMappingRecord.Name;
        objectMapping.mappingType = objectMappingRecord.SVMXA360__Type__c;
        objectMapping.description = objectMappingRecord.SVMXA360__Description__c;
        objectMapping.sourceObjectAPIName = objectMappingRecord.SVMXA360__SourceObjectAPIName__c;
        objectMapping.targetObjectAPIName = objectMappingRecord.SVMXA360__TargetObjectAPIName__c;
        objectMapping.headerRecordObject = objectMappingRecord.SVMXA360__HeaderRecordObject__c;
        objectMapping.developerName = objectMappingRecord.SVMXA360__DeveloperName__c;
        objectMapping.lastModifiedDate = objectMappingRecord.LastModifiedDate;
        objectMapping.lastModifiedBy = objectMappingRecord.LastModifiedBy.Name;
        
        return objectMapping;
    }

    /**
     * Private method to create object mapping detail wrapper from object mapping detail record.
     */
    private Adm.ObjectMappingDetail createObjectMappingDetail( final SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetailRecord ) {
        
        Adm.ObjectMappingDetail objectMappingDetail = new Adm.ObjectMappingDetail();
        
        objectMappingDetail.id = objectMappingDetailRecord.Id;
        objectMappingDetail.sourceFieldAPIName = objectMappingDetailRecord.SVMXA360__SourceFieldAPIName__c;
        objectMappingDetail.targetFieldAPIName = objectMappingDetailRecord.SVMXA360__TargetFieldAPIName__c;
        objectMappingDetail.mappingType = objectMappingDetailRecord.SVMXA360__Type__c;
        objectMappingDetail.value = objectMappingDetailRecord.SVMXA360__Value__c;
        objectMappingDetail.literalParameterAPIName = objectMappingDetailRecord.SVMXA360__LiteralParameter__c;
        objectMappingDetail.relatedObjectDetails = objectMappingDetailRecord.SVMXA360__RelatedObjectDetails__c;
        
        return objectMappingDetail;
    }

    /***
     * Private method to query all fields of specific object mapping
     */ 
    private String queryMappingObjectFields( Set<String> sourceObjectFields, Set<String> targetObjectFields, Set<String> userFields, Set<String> headerFields, Adm.ObjectMapping objectMappingRecord ) {
        
        try {

            if (entityDetails == null || entityDetails.size() == 0) {
                List<Common.EntityDetails> sObjectTypeAllDetails = COMM_DescribeManager.getInstance().getAllGlobalDescribe();
                for (Common.EntityDetails entityDetail: sObjectTypeAllDetails) {
                    entityDetails.put(entityDetail.objectAPIName, entityDetail.objectLabel);
                }  
            }

            if( sourceObjectFields != null && sourceObjectFields.size() > 0 && String.isNotBlank(objectMappingRecord.sourceObjectAPIName) 
                && entityDetails.containsKey(objectMappingRecord.sourceObjectAPIName)) {
                List<SObject> source = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(sourceObjectFields), ',') + ' from '+ String.escapeSingleQuotes( objectMappingRecord.sourceObjectAPIName ) + ' WITH SECURITY_ENFORCED limit 0'));
            }
            if( targetObjectFields != null && targetObjectFields.size() > 0 && String.isNotBlank(objectMappingRecord.targetObjectAPIName)
                && entityDetails.containsKey(objectMappingRecord.targetObjectAPIName)) {
                List<SObject> target = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(targetObjectFields), ',') + ' from '+ String.escapeSingleQuotes( objectMappingRecord.targetObjectAPIName ) + ' WITH SECURITY_ENFORCED limit 0'));
            }
            if( userFields != null && userFields.size() > 0 ) {
                List<SObject> userObj = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(userFields), ',') + ' from User WITH SECURITY_ENFORCED limit 0'));
            }
            if( headerFields != null && headerFields.size() > 0 && objectMappingRecord.headerRecordObject != null
                && entityDetails.containsKey(objectMappingRecord.headerRecordObject)) {
                List<SObject> headerObj = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(headerFields), ',') + ' from '+ String.escapeSingleQuotes( objectMappingRecord.headerRecordObject ) + ' WITH SECURITY_ENFORCED limit 0'));
            }

        } catch(System.QueryException e){
            System.debug(LoggingLevel.ERROR, 'queryMappingObjectFields() : Object/Field is not Accessible for query records. Error= ' + e.getMessage());
            return e.getMessage();
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'queryMappingObjectFields() : Invalid Query Clause. Error= ' + e.getStackTraceString() );
            throw e;
        }
        return null;
    }

     /***
     * Private method to query all fields of specific object mapping
     */ 
    private String queryMappingObjectFields( Set<String> sourceObjectFields, Set<String> targetObjectFields, Set<String> userFields, Adm.ObjectMapping objectMappingRecord ) {
        
        try {

            if( sourceObjectFields != null && sourceObjectFields.size() > 0 && String.isNotBlank(objectMappingRecord.sourceObjectAPIName) ) {
                List<SObject> source = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(sourceObjectFields), ',') + ' from '+ String.escapeSingleQuotes( objectMappingRecord.sourceObjectAPIName ) + ' limit 0'));
            }
            if( targetObjectFields != null && targetObjectFields.size() > 0 && String.isNotBlank(objectMappingRecord.targetObjectAPIName) ) {
                List<SObject> target = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(targetObjectFields), ',') + ' from '+ String.escapeSingleQuotes( objectMappingRecord.targetObjectAPIName ) + ' limit 0'));
            }
            if( userFields != null && userFields.size() > 0 ) {
                List<SObject> userObj = SvmxDatabase.query(Database.query('Select '+ String.join(new List<String>(userFields), ',') + ' from User limit 0'));
            }

        } catch(System.QueryException e){
            System.debug(LoggingLevel.ERROR, 'queryMappingObjectFields() : Object/Field is not Accessible for query records. Error= ' + e.getMessage());
            return System.Label.Message_ValidatingConfiguration;
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'queryMappingObjectFields() : Invalid Query Clause. Error= ' + e.getStackTraceString() );
            throw e;
        }
        return null;
    }

    /***
    * Private method to populate mapping details error message
    */ 
    private Adm.ObjectMappingDetail findMappingDetailErrors( Adm.MappingErrorMessage errorDetail, Adm.ObjectMappingDetail mappingDetailRecord, Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap,
        String targetObjectAPIName, String objectApiName, String fieldApiName ) {
        
        if (errorDetail != null && String.isNotBlank(errorDetail.errorMessage)) {
            mappingDetailRecord = populateMappingDetailErrorMessage(errorDetail, mappingDetailRecord);
        }     
        else if (errorDetail == null || (errorDetail != null && !errorDetail.hasError) ) {
            errorDetail = validateMappingDetailDataType(sObjectResultMap, mappingDetailRecord, targetObjectAPIName, objectApiName, fieldApiName);
            if (errorDetail != null && String.isNotBlank(errorDetail.errorMessage)) {
                mappingDetailRecord = populateMappingDetailErrorMessage(errorDetail, mappingDetailRecord);
            }
        }
        return mappingDetailRecord;
    }

    /***
    * Private method to populate mapping details error message
    */ 
    private Adm.ObjectMappingDetail populateMappingDetailErrorMessage( Adm.MappingErrorMessage errorDetail, Adm.ObjectMappingDetail mappingDetailRecord) {
        
        mappingDetailRecord.hasError = errorDetail.hasError ? true : errorDetail.hasError;
        mappingDetailRecord.errorMessage += errorDetail.errorMessage;
        return mappingDetailRecord;
    }

    public Map<Schema.DisplayType, List<Schema.DisplayType>> populateCompatibilityMatrix() {
        Map<Schema.DisplayType, List<Schema.DisplayType>> compatibilityMatrix = new Map<Schema.DisplayType, List<Schema.DisplayType>>();
        List<Schema.DisplayType> compatibleFieldsForEmail = new List<Schema.DisplayType>();
        List<Schema.DisplayType> compatibleFieldsForDate = new List<Schema.DisplayType>();
        List<Schema.DisplayType> compatibleFieldsForMultiPicklist = new List<Schema.DisplayType>();
        List<Schema.DisplayType> compatibleFieldsForText= new List<Schema.DisplayType>();
        List<Schema.DisplayType> compatibleFieldsForEncryptedText= new List<Schema.DisplayType>();

        compatibleFieldsForEmail.add(Schema.DisplayType.TEXTAREA);
        compatibleFieldsForEmail.add(Schema.DisplayType.STRING);
        compatibleFieldsForEmail.add(Schema.DisplayType.EMAIL);

        compatibleFieldsForDate.add(Schema.DisplayType.DATE);
        compatibleFieldsForDate.add(Schema.DisplayType.DATETIME);

        compatibleFieldsForMultiPicklist.add(Schema.DisplayType.MULTIPICKLIST);
        compatibleFieldsForMultiPicklist.add(Schema.DisplayType.PICKLIST);

        compatibleFieldsForText.add(Schema.DisplayType.PICKLIST);
        compatibleFieldsForText.add(Schema.DisplayType.STRING);
        compatibleFieldsForText.add(Schema.DisplayType.TEXTAREA);
        compatibleFieldsForText.add(Schema.DisplayType.EMAIL);
        compatibleFieldsForText.add(Schema.DisplayType.URL);
        compatibleFieldsForText.add(Schema.DisplayType.REFERENCE);
        compatibleFieldsForText.add(Schema.DisplayType.BOOLEAN);
        compatibleFieldsForText.add(Schema.DisplayType.PHONE);

        compatibleFieldsForEncryptedText.add(Schema.DisplayType.ENCRYPTEDSTRING);
        compatibleFieldsForEncryptedText.addAll(compatibleFieldsForText);

        compatibilityMatrix.put(Schema.DisplayType.DATE, compatibleFieldsForDate);
        compatibilityMatrix.put(Schema.DisplayType.MULTIPICKLIST, compatibleFieldsForMultiPicklist);
        compatibilityMatrix.put(Schema.DisplayType.TEXTAREA, compatibleFieldsForText);
        compatibilityMatrix.put(Schema.DisplayType.ENCRYPTEDSTRING, compatibleFieldsForEncryptedText);
        compatibilityMatrix.put(Schema.DisplayType.STRING, compatibleFieldsForText);
        compatibilityMatrix.put(Schema.DisplayType.EMAIL, compatibleFieldsForEmail);

        return compatibilityMatrix;

    } 
    
    /**
     * Private consructor to restrict multiple instance creation of this class.
     */
    private ADM_ObjectMappingManager() {
    }
}