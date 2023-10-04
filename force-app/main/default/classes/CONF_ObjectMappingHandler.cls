/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This handler class to validate and apply object mappings.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 * A360CE-295   Ramachandra Mohan       03 Nov 2020     Support Date/Datetime fields for value mapping.
 * A360ENG-1121 Jason Bradley           04 June 2021    Prevent mapped nulls from being populated into Checkbox fields, allowing default values instead.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class CONF_ObjectMappingHandler {
    
    /***
     * Private static string constant to hold CurrencyIsoCode.
     */
    private static final String CurrencyIsoCode 	= 'CurrencyIsoCode';
    private static final String exceptionMessage 	= 'SObject row was retrieved via SOQL without querying the requested field';
    private static Map<Id,SObject> currentRecordHeaderMap = new Map<Id,SObject>();
    private static Map<Id,SObject> userRecordMap = new Map<Id,SObject>();
    private static Map<String, Map<String,Object>> multiLevelFieldValueforCRH = new Map<String, Map<String,Object>>();
    
    /**
     * This method is to create and apply mapping from requested mapping and source record ID.
     * 
     * @param mappingId Object Mapping id for which mapping configurations to be retrieved and applied.
     * @param sourceRecordId Source record id from which fields to be populated to target sobject.
     * 
     * @return Returns newly created sobject with fields populated from source sobject.
     */
    public SObject createAndApplyObjectMapping( final String mappingId, final SObject sourceSObject) {
        
        System.debug( LoggingLevel.DEBUG, 'createAndApplyObjectMapping() - enter' );
        
        SObject targetSObject;
        
        try {
            
            if( String.isBlank(mappingId) ) {
                
                System.debug( LoggingLevel.ERROR, 'createAndApplyObjectMapping() : Invalid arguments. mappingId= ' + mappingId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);
            
            if( objectMapping.mappingType.equalsIgnoreCase('Field Mapping') && sourceSObject == null ) {
                
                System.debug( LoggingLevel.ERROR, 'createAndApplyObjectMapping() : Invalid request parameters. sourceSObject= ' + sourceSObject );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final SObject newTargetSObject = (SObject) Type.forName('Schema.' + objectMapping.targetObjectAPIName ).newInstance();
            targetSObject = applyObjectMapping(objectMapping, new List<SObject>{newTargetSObject}, sourceSObject ).get(0);
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createAndApplyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createAndApplyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createAndApplyObjectMapping() - exit' );
        }        
        return targetSObject;
    }
    
    /**
     * This method is used to perform object apply mapping for requested mapping id and source target list map.
     */
    public Map<String,List<SObject>> applyObjectMapping( final String mappingId, final Map<String,List<SObject>> sourceIdtargetSObjectMap ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        Map<String,List<SObject>> resultSourceIdtargetSObjectMap = new Map<String,List<SObject>>();
        try {
            
            if( String.isBlank(mappingId) || sourceIdtargetSObjectMap == null || sourceIdtargetSObjectMap.size() == 0 ) {
                
            	System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. mappingId= ' + mappingId + '; sourceIdtargetSObjectMap= ' + sourceIdtargetSObjectMap );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final List<SObject> sourceRecordList = retrieveSourceRecords( mappingId, new List<String>(sourceIdtargetSObjectMap.keySet()), new List<String>(), null );
            
            resultSourceIdtargetSObjectMap = applyObjectMapping( mappingId, sourceIdtargetSObjectMap, sourceRecordList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return resultSourceIdtargetSObjectMap;
    }
    
    /**
     * This method is used to perform object apply mapping for requested mapping id and source target list map.
     */
    public Map<String,List<SObject>> applyObjectMapping( final String mappingId, final Map<String,List<SObject>> sourceIdtargetSObjectMap, final List<SObject> sourceRecordList ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        Map<String,List<SObject>> resultSourceIdtargetSObjectMap = new Map<String,List<SObject>>();
        try {
            
            // Verify for valid request parameter.
            if( String.isBlank(mappingId) || sourceIdtargetSObjectMap == null || sourceIdtargetSObjectMap.size() == 0 ) {
                
            	System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. mappingId= ' + mappingId + '; sourceIdtargetSObjectMap= ' + sourceIdtargetSObjectMap );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);
            for( SObject sourceRecord : sourceRecordList ) {
                
                String sourceRecordId = (String) sourceRecord.get('Id');
                if( !sourceIdtargetSObjectMap.containsKey(sourceRecordId) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Record not exists in requested map.. sourceRecordId= ' + sourceRecordId );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
                } 
                
                resultSourceIdtargetSObjectMap.put( sourceRecordId, applyObjectMapping( objectMapping, sourceIdtargetSObjectMap.get(sourceRecordId), sourceRecord ) );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        return resultSourceIdtargetSObjectMap;
    }
    
    /**
     * This method is used to perform object apply mapping for requested mapping id and target object.
     */
    public SObject applyObjectMapping( final String mappingId, final SObject targetSObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        SObject resultSObject;
        try {
            
            if( String.isBlank(mappingId) || targetSObject == null ) {
                
            	System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. mappingId= ' + mappingId + '; targetSObject= ' + targetSObject );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);
            resultSObject = applyObjectMapping( objectMapping, new List<SObject>{targetSObject}, null ).get(0);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return resultSObject;
    }
    
    /**
     * This method is used to perform object apply mapping.
     */
    public SObject applyObjectMapping( final String mappingId, final SObject targetSObject, final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        SObject resultSObject;
        try {
            
            if( String.isBlank(mappingId) || targetSObject == null ) {
                
            	System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid arguments. mappingId= ' + mappingId + '; targetSObject= ' + targetSObject );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            resultSObject = applyObjectMapping( mappingId, new List<SObject>{targetSObject}, sourceRecord ).get(0);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return resultSObject;
    }
    
    /**
     * This method is used to perform object apply mapping.
     */
    public SObject applyObjectMapping( final String mappingId, final SObject targetSObject, final SObject sourceRecord, final SObject currentRecordHeader ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        SObject resultSObject;
        try {
            
            if( String.isBlank(mappingId) || targetSObject == null ) {
                
            	System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid arguments. mappingId= ' + mappingId + '; targetSObject= ' + targetSObject );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            if (applyObjectMapping( mappingId, new List<SObject>{targetSObject}, sourceRecord, currentRecordHeader ).size() > 0 ) {
                resultSObject = applyObjectMapping( mappingId, new List<SObject>{targetSObject}, sourceRecord, currentRecordHeader ).get(0);
            }    
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return resultSObject;
    }

        /**
     * This method is used to perform apply mapping for requested mapping id.
     */
    public List<SObject> applyObjectMapping( final String mappingId, final List<SObject> targetSObjectList, final SObject sourceRecord, final SObject currentRecordHeader ) {
       
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        List<SObject> returnSObjectList;
            
        try {
            
            // Verify for valid object mapping configuration.
            if( String.isBlank(mappingId) || targetSObjectList == null || targetSObjectList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. mappingId= ' + mappingId + '; targetSObjectList= ' + targetSObjectList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);            
            if ( currentRecordHeader != null && String.isNotBlank(currentRecordHeader.id) && objectMapping.headerRecordObject != null ) {
                String sObjName = (currentRecordHeader.id).getSObjectType().getDescribe().getName();
                if(!sObjName.equalsIgnoreCase(objectMapping.headerRecordObject)) {
                    System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameter current record header. mappingId= ' + mappingId + '; currentRecordHeader= ' + currentRecordHeader );
                    throw new SvmxSystem.SvmxNestedException( System.Label.Error_InvalidCurrentRecordHeader );
                } else {
                    returnSObjectList = applyObjectMapping(objectMapping, targetSObjectList, sourceRecord, currentRecordHeader );
                }
            } else {
                if ( currentRecordHeader != null && currentRecordHeader.id == null && !multiLevelFieldValueforCRH.containsKey(objectMapping.id)) {
                    getMultiLevelFieldValueforCRH(currentRecordHeader,objectMapping);
                }
                returnSObjectList = applyObjectMapping(objectMapping, targetSObjectList, sourceRecord, currentRecordHeader );   
            }
        }
        catch( System.SObjectException e ) {    
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Object/Field is not accessible. Error= ' + e.getMessage() );
            if(e.getMessage().contains(exceptionMessage)) {
                List<String> errorMsgSplit = e.getMessage().split(':');
                String errorMessage = System.Label.Message_UserDoesnotHaveAccess + errorMsgSplit.remove(1);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage );
            } else {
                throw e;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        return returnSObjectList;
    }
    /**
     * This method is used to perform apply mapping for requested mapping id.
     */
    public List<SObject> applyObjectMapping( final String mappingId, final List<SObject> targetSObjectList, final SObject sourceRecord ) {
       
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - enter' );
        
        List<SObject> returnSObjectList;
            
        try {
            
            // Verify for valid object mapping configuration.
            if( String.isBlank(mappingId) || targetSObjectList == null || targetSObjectList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. mappingId= ' + mappingId + '; targetSObjectList= ' + targetSObjectList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);            
            returnSObjectList = applyObjectMapping(objectMapping, targetSObjectList, sourceRecord, null );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return returnSObjectList;
    }
    
    /**
     * This method is used to perform apply mapping for requested object mapping, targt objects and source object.
     */
    private List<SObject> applyObjectMapping( final Adm.ObjectMapping objectMapping, final List<SObject> targetSObjectList, final SObject sourceRecord ) {

        List<SObject> targetSObjectApplyList = new List<SObject>();
       
        try {
                        
            switch on objectMapping.mappingType {
                
                when 'Field Mapping' {
                    
                    // Verify for valid object mapping configuration.
                    if( sourceRecord == null ) {
                        
                        System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. objectMapping= ' + objectMapping + '; targetSObjectList= ' + targetSObjectList );
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                    }
                    targetSObjectApplyList = applyObjectFieldMapping(objectMapping, targetSObjectList, sourceRecord, null );
                }
                when 'Value Mapping' {
                    targetSObjectApplyList = applyObjectValueMapping( objectMapping, targetSObjectList, null );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Object mapping type not supported. Type= ' + objectMapping.mappingType );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return targetSObjectApplyList;
    }

        /**
     * This method is used to perform apply mapping for requested object mapping, targt objects and source object.
     */
    private List<SObject> applyObjectMapping( final Adm.ObjectMapping objectMapping, final List<SObject> targetSObjectList, final SObject sourceRecord, final SObject currentRecordHeader ) {

        List<SObject> targetSObjectApplyList = new List<SObject>();
        try {
                        
            switch on objectMapping.mappingType {
                
                when 'Field Mapping' {
                    
                    // Verify for valid object mapping configuration.
                    if( sourceRecord == null ) {
                        
                        System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. objectMapping= ' + objectMapping + '; targetSObjectList= ' + targetSObjectList );
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                    }
                    targetSObjectApplyList = applyObjectFieldMapping(objectMapping, targetSObjectList, sourceRecord, currentRecordHeader );
                }
                when 'Value Mapping' {
                    targetSObjectApplyList = applyObjectValueMapping( objectMapping, targetSObjectList, currentRecordHeader );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Object mapping type not supported. Type= ' + objectMapping.mappingType );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        }
        
        return targetSObjectApplyList;
    }
    
    /**
     * This method is used to retrieve source record for requested mapping id and source record id.
     * 
     * @param mappingId Object mapping record ID from which mapping to be applied.
     * @sourceRecordId Source record id for which records to be retrieved.
     * @whereClause Where clause to be considered while quering records, if any, otherwise null.
     * 
     * @Returns Returns source record for given source record if with source fields configured in the object mapping.
     */
    public SObject retrieveSourceRecord( final String mappingId, final String sourceRecordId, final List<String> sourceFields, final String whereClause ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecord() - enter; mappingId= ' + mappingId + '; sourceRecordId= ' + sourceRecordId );
        
        SObject sourceRecord;
        
        try {
            // Verify for valid object mapping configuration.
            if( String.isBlank( mappingId ) || String.isBlank( sourceRecordId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'retrieveSourceRecord() : Invalid request parameters. mappingId= ' + mappingId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);
            final List<SObject> sourceRecordList = retrieveSourceRecords( objectMapping, new List<String>{sourceRecordId}, sourceFields, whereClause);
            
            sourceRecord = sourceRecordList.get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecord() : Failed to retrieve source record. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecord() : Failed to retrieve source record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecord() - exit' );
        }
        
        return sourceRecord;
    }
    
    /**
     * This method is used to retrieve source record for configured source fields in the mapping.
     */
    public List<SObject> retrieveSourceRecords( final String mappingId, final List<String> sourceRecordIds, final List<String> sourceFields, final String whereClause ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecord() - enter' );
        
        List<SObject> sourceRecordList;
        
        try {
            // Verify for valid object mapping configuration.
            if( String.isBlank( mappingId ) || sourceRecordIds == null || sourceRecordIds.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'retrieveSourceRecord() : Invalid request parameters. mappingId= ' + mappingId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);
            sourceRecordList = retrieveSourceRecords( objectMapping, sourceRecordIds, sourceFields, whereClause );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecord() : Failed to retrieve source record. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecord() : Failed to retrieve source record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecord() - exit' );
        }
        
        return sourceRecordList;
    }
    
    /**
     * This method is used to retrieve records for requested source record Ids. The source fields 
     * are queried in addition to configured fields in the source object mapping.
     */
    public List<SObject> retrieveSourceRecords( final Adm.ObjectMapping objectMapping, final List<String> sourceRecordIds, final List<String> sourceFields, final String whereClause ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecords() - enter; objectMapping= ' + objectMapping + '; sourceRecordIds= ' + sourceRecordIds );
        
        List<SObject> sourceRecordList = new List<SObject>();
        
        try {
            // Verify for valid object mapping configuration.
            if( objectMapping == null || objectMapping.objectMappingDetails == null || objectMapping.objectMappingDetails.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Invalid request parameters. objectMapping= ' + objectMapping );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve all source fields configured.
            final Set<String> sourceFieldAPINames = new Set<String>{'Id'};
            for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                
                if( String.isNotBlank(objectMappingDetail.sourceFieldAPIName) ) {
                    sourceFieldAPINames.add( objectMappingDetail.sourceFieldAPIName );
                }
            }
            // Add requested additional fields if any. 
            if( sourceFields != null && !sourceFields.isEmpty() ) {
                sourceFieldAPINames.addAll(sourceFields);
            }
            
            // Retrieve source record if fields are available.
            if( sourceFieldAPINames.size() > 0 ) {
                
                String queryString = 'SELECT ' + String.join(new List<String>(sourceFieldAPINames), ',') + ' FROM ' + objectMapping.sourceObjectAPIName + ' WHERE Id IN :sourceRecordIds';
                queryString = String.isNotBlank(whereClause) ? (queryString + ' AND ' + whereClause) : queryString;
                
                System.debug(LoggingLevel.DEBUG, 'Retrieving Source Records. queryString= ' + queryString );
                
                sourceRecordList = SvmxDatabase.query( Database.query(queryString) );
                
                if( sourceRecordList == null || sourceRecordList.size() == 0 ) {
                    
                    System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Record not exists. sourceRecordIds= ' + sourceRecordIds );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
                }
            } else {
                System.debug( LoggingLevel.WARN, 'retrieveSourceRecords() : No source field configured in the object mapping. objectMapping.name= ' + objectMapping.name );
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Failed to retrieve source record. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Failed to retrieve source record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecords() - exit' );
        }
        
        return sourceRecordList;
    }
    
    /**
     * This method is used to perform object apply mapping for requested list of target object records and source record.
     */
    private List<SObject> applyObjectFieldMapping( final Adm.ObjectMapping objectMapping, final List<SObject> targetSObjectList, SObject sourceRecord, SObject currentRecordHeader) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectFieldMapping() - enter' );
        List<SObject> targetSObjectApplyList = new List<SObject>();
        
        try {
            
            // Retrieve field describe for configured target object API name.
            Map<String, Schema.DescribeFieldResult> describeFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( objectMapping.targetObjectAPIName );
            Set<String> sourceReferenceFields =  new Set<String>();
            Set<String> targetReferenceFields =  new Set<String>();
            Set<String> currentRecordHeaderReferenceFields =  new Set<String>();
            Set<String> userReferenceFields =  new Set<String>();
            SObject userRecord;

            //consolidate multi level fields based on source, target, user , current record header objects
            for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                if (objectMappingDetail.mappingType.toUpperCase() == 'FIELD' && 
                    objectMappingDetail.sourceFieldAPIName != null &&
                    objectMappingDetail.sourceFieldAPIName.contains('.')) {
                        sourceReferenceFields.add(objectMappingDetail.sourceFieldAPIName);
                } else if (objectMappingDetail.mappingType.toUpperCase() == 'FUNCTION' && objectMappingDetail.literalParameterAPIName != null && objectMappingDetail.literalParameterAPIName.contains('.')) {
                    if (objectMappingDetail.value == 'User') {
                        userReferenceFields.add(objectMappingDetail.literalParameterAPIName);
                    } else if (objectMappingDetail.value == 'Current Record') {
                        targetReferenceFields.add(objectMappingDetail.literalParameterAPIName);
                    } else if (objectMappingDetail.value == 'Current Record Header') {
                        currentRecordHeaderReferenceFields.add(objectMappingDetail.literalParameterAPIName);
                    }
                }
            }
            // userRecord contains all single and multi level field values
            if(!userRecordMap.containsKey(objectMapping.id)) {
                userRecord = getCurrentUserRecord(userReferenceFields);
                userRecordMap.put(objectMapping.id, userRecord);
            } else {
                userRecord = userRecordMap.get(objectMapping.id);   
            }
            
            // sourceRecord contains all single and multi level field values
            if ( sourceReferenceFields.size() > 0) {
                sourceRecord = getRecordWithMultiReferenceFields(sourceRecord, sourceReferenceFields);
            }
            // currentRecordHeader contains all single and multi level field values
            if( currentRecordHeader != null && currentRecordHeader.Id != null && currentRecordHeaderReferenceFields.size() > 0 ) {
                if ( !currentRecordHeaderMap.containsKey(objectMapping.id)  ) {
                    currentRecordHeader = getRecordWithMultiReferenceFields(currentRecordHeader, currentRecordHeaderReferenceFields);
                    currentRecordHeaderMap.put(objectMapping.id, currentRecordHeader);
                } else {
                    currentRecordHeader = currentRecordHeaderMap.get(objectMapping.id);
                }
            }
        
            for( SObject targetObject : targetSObjectList ) {
                
                for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                    
                    // Verify whether configured fiend api name exists or not.
                    if( !describeFieldResultMap.containsKey( objectMappingDetail.targetFieldAPIName ) ) {
                        
                        System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Field not exists. fieldAPIName= ' + objectMappingDetail.targetFieldAPIName );
                		throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                    }
                    
                    // Perform value mapping for field CurrencyIsoCode only if the org is a multi currency organization.
                    if( !Userinfo.isMultiCurrencyOrganization() && CurrencyIsoCode.equalsIgnoreCase( objectMappingDetail.targetFieldAPIName )  ) {
                        
                        System.debug( LoggingLevel.WARN, 'applyObjectFieldMapping() : Not a Multi currency organization. Skipping field ' + objectMappingDetail.targetFieldAPIName );
                        continue;
                    }
                    
                    Schema.DescribeFieldResult fieldDescribe = describeFieldResultMap.get(objectMappingDetail.targetFieldAPIName);
                    Schema.DisplayType displayType = fieldDescribe.getType();

                    Object fieldValue;
                    
                    switch on objectMappingDetail.mappingType.toUpperCase() {
                        
                        when 'FIELD' {
                            // Source field API name is mandatory for Field Mapping.
                            if( String.isBlank( objectMappingDetail.sourceFieldAPIName ) ) {
                                
                                System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Invalid request parameters. sourceFieldAPIName= ' + objectMappingDetail.sourceFieldAPIName );
                                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                            }
                            
                            if (objectMappingDetail.sourceFieldAPIName != null && objectMappingDetail.sourceFieldAPIName.contains('.')) {
                                //stores multi level field values
                                fieldValue = getValueOfMultiReference(sourceRecord, objectMappingDetail.sourceFieldAPIName);
                            } else {
                                //stores single level field values
                                fieldValue = sourceRecord.get(objectMappingDetail.sourceFieldAPIName);
                            }
                        }
                        when 'VALUE' {
                            fieldValue = getFieldValueByType(displayType, objectMappingDetail.value, objectMapping.targetObjectAPIName);
                        }
                        when 'FUNCTION' {
                            if(objectMappingDetail.value == 'Current Record') {

                                fieldValue = getFieldValueForMapping(targetObject, objectMappingDetail);

                            } else if (objectMappingDetail.value == 'User') {

                                fieldValue = getFieldValueForMapping(userRecord, objectMappingDetail);

                            } else if (objectMappingDetail.value == 'Current Record Header') {

                                fieldValue = getFieldValueForCurrentRecordHeader(currentRecordHeader, objectMappingDetail, objectMapping.id);

                            }
                            else {
                                fieldValue = getFieldValueByFunction(displayType, objectMappingDetail.value);
                            }
                        }
                        when else {
                            System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Object mapping detail type not supported. Type= ' + objectMappingDetail.mappingType );
                            throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                        }
                    }

                    populateField(targetObject, fieldDescribe, fieldValue);
                }
                targetSObjectApplyList.add(targetObject);
            }
        }
        catch( System.SObjectException e ) {    
            System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Object/Field is not accessible. Error= ' + e.getMessage() );
            if(e.getMessage().contains(exceptionMessage)) {
                List<String> errorMsgSplit = e.getMessage().split(':');
                String errorMessage = System.Label.Message_UserDoesnotHaveAccess + errorMsgSplit.remove(1);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage );
            } else {
                throw e;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Failed to retrieve source record. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectFieldMapping() - exit' );
        }
        
        return targetSObjectApplyList;
    }
    
    /**
     * This method is used to perform apply value mapping for requested target record and mapping id.
     */
    private List<SObject> applyObjectValueMapping( final Adm.ObjectMapping objectMapping, final List<SObject> targetSObjectList, SObject currentRecordHeader ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectValueMapping() - enter' );
        List<SObject> targetSObjectApplyList = new List<SObject>();
        
        try {
            // Retrieve fieldds for target object API name.
            Map<String, Schema.DescribeFieldResult> describeFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( objectMapping.targetObjectAPIName );
            Set<String> targetReferenceFields =  new Set<String>();
            Set<String> userReferenceFields =  new Set<String>();
            Set<String> currentRecordHeaderReferenceFields =  new Set<String>();
            SObject userRecord;

            //consolidate multi level fields based on source, target, user , current record header objects
            for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {  //mapping server issue
                if (objectMappingDetail.mappingType.toUpperCase() == 'FUNCTION' && objectMappingDetail.literalParameterAPIName != null && objectMappingDetail.literalParameterAPIName.contains('.')) {
                    if (objectMappingDetail.value == 'User') {
                        userReferenceFields.add(objectMappingDetail.literalParameterAPIName);
                    } else if (objectMappingDetail.value == 'Current Record') {
                        targetReferenceFields.add(objectMappingDetail.literalParameterAPIName);
                    } else if (objectMappingDetail.value == 'Current Record Header') {
                        currentRecordHeaderReferenceFields.add(objectMappingDetail.literalParameterAPIName);
                    }
                }
            }
            // userRecord contains all single and multi level field values
            if(!userRecordMap.containsKey(objectMapping.id)) {
                userRecord = getCurrentUserRecord(userReferenceFields);
                userRecordMap.put(objectMapping.id, userRecord);
            } else {
                userRecord =  userRecordMap.get(objectMapping.id);   
            }
            // currentRecordHeader contains all single and multi level field values
            if( currentRecordHeader != null && currentRecordHeader.Id != null && currentRecordHeaderReferenceFields.size() > 0 ) {
                if ( !currentRecordHeaderMap.containsKey(objectMapping.id)  ) {
                    currentRecordHeader = getRecordWithMultiReferenceFields(currentRecordHeader, currentRecordHeaderReferenceFields);
                    currentRecordHeaderMap.put(objectMapping.id, currentRecordHeader);
                } else {
                    currentRecordHeader = currentRecordHeaderMap.get(objectMapping.id);
                }
            }
        
            // For each requested target record, perform apply mapping for configured object mapping.
            for( SObject targetObject : targetSObjectList ) {
                
                // Apply target field value for each field configured in mapping.
                for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                    
                    // Verify whether configured fiend api name exists or not.
                    if( !describeFieldResultMap.containsKey( objectMappingDetail.targetFieldAPIName ) ) {
                        
                        System.debug( LoggingLevel.ERROR, 'applyObjectValueMapping() : Field not exists. fieldAPIName= ' + objectMappingDetail.targetFieldAPIName );
                		throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                    }
                    
                    // Perform value mapping for field CurrencyIsoCode only if the org is a multi currency organization.
                    if( !Userinfo.isMultiCurrencyOrganization() && CurrencyIsoCode.equalsIgnoreCase( objectMappingDetail.targetFieldAPIName )  ) {
                        
                        System.debug( LoggingLevel.WARN, 'applyObjectValueMapping() : Not a Multi currency organization. Skipping field ' + objectMappingDetail.targetFieldAPIName );
                        continue;
                    }
                    
                    // Get field display type to perform value mapping. Value mapping will support only Value & Function type.
                    Schema.DescribeFieldResult fieldDescribe = describeFieldResultMap.get(objectMappingDetail.targetFieldAPIName);
                    Schema.DisplayType displayType = fieldDescribe.getType();

                    Object fieldValue;

                    switch on objectMappingDetail.mappingType.toUpperCase() {
                        
                        when 'VALUE' {
                            fieldValue = getFieldValueByType(displayType, objectMappingDetail.value, objectMapping.targetObjectAPIName);
                        }
                        when 'FUNCTION' {
                            if(objectMappingDetail.value == 'Current Record') {

                                fieldValue = getFieldValueForMapping(targetObject, objectMappingDetail);
                            
                            } else if (objectMappingDetail.value == 'User') {
                                
                                fieldValue = getFieldValueForMapping(userRecord, objectMappingDetail);

                            } else if (objectMappingDetail.value == 'Current Record Header') {
                            
                                fieldValue = getFieldValueForCurrentRecordHeader(currentRecordHeader, objectMappingDetail, objectMapping.id);

                            } else {
                                fieldValue = getFieldValueByFunction(displayType, objectMappingDetail.value);
                            }
                        }
                        when else {
                            System.debug( LoggingLevel.ERROR, 'applyObjectValueMapping() : Object mapping detail type not supported. Type= ' + objectMappingDetail.mappingType );
                            throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                        }
                    }

                    populateField(targetObject, fieldDescribe, fieldValue);
                }
                targetSObjectApplyList.add(targetObject);
            }
        }
        catch( System.SObjectException e ) {    
            System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Object/Field is not accessible. Error= ' + e.getMessage() );
            if(e.getMessage().contains(exceptionMessage)) {
                List<String> errorMsgSplit = e.getMessage().split(':');
                String errorMessage = System.Label.Message_UserDoesnotHaveAccess + errorMsgSplit.remove(1);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage );
            } else {
                throw e;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectValueMapping() : Failed to perform apply mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch(Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyObjectValueMapping() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyObjectValueMapping() - exit' );
        }

        return targetSObjectApplyList;
    }
    
    /**
     * This method is used to retrieve value for requested literal.
     */
    private Object getFieldValueByFunction( final Schema.Displaytype displaytype, final String value ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldValueByFunction() - enter' );
        
        Object fieldValue;
        
        try {
            
            fieldValue = getFieldValueByFunction( displaytype, value, null );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldValueByFunction() : Failed to retrieve value for function. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldValueByFunction() - exit' );
        }
        
        return fieldValue;
    }
    
    /**
     * This method is used to retrieve value for requested literal.
     */
    @TestVisible private Object getFieldValueByFunction( final Schema.Displaytype displaytype, final String value, SObject targetObject  ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldValueByFunction() - enter' );
        
        Object fieldValue;
        
        try {
            
            switch on displaytype {
                                
                when String, Reference {
                    fieldValue = getStringValueByFunction(value, targetObject);
                }
                when Date, Datetime {
                    fieldValue = COMM_DateLiteralUtils.getDateForLiteral(displaytype, value );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'applyObjectFieldMapping() : Object mapping detail type not supported. displaytype= ' + displaytype );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldValueByFunction() : Failed to retrieve value for function. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldValueByFunction() - exit' );
        }
        
        return fieldValue;
    }
    
    /**
     * This method is used to retrieve value for requested function.
     * 
     * @param value Supported Servicemax literal for which String value to be created.
     * @param targetObject Optional SObject record to support self reference field value mapping.
     * 
     * @return Returns string value for requested literal, Otherwise, returns null.
     */
    @TestVisible private String getStringValueByFunction( final String value, final SObject targetObject ) {
        
        String fieldValue;
        
        try {
            switch on value.toUpperCase() {
            
                when 'FSVMXCURRENTUSERID' {
                    fieldValue = UserInfo.getUserId();
                }
                when 'FSVMXNULL' {
                    fieldValue = null;
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'getStringValueByFunction() : Function not supported. value= ' + value );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getStringValueByFunction() : Failed to retrieve value for function. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getStringValueByFunction() - exit' );
        }
        
        return fieldValue;
    }
        /**
     * This method is used to retrieve field value for given display type.
     * 
     * @param displaytype Data type fpr which value to be converted to datatype instance.
     * @param value Value to be pared or converted to the requested datatype instance.
     */
    @TestVisible public Object getFieldValueByType( final Schema.Displaytype displaytype, final String value) {

		System.debug( LoggingLevel.DEBUG, 'getFieldValueByType() - enter; displaytype= ' + displaytype );
        
        Object fieldValue;
        
        try {
            
            // Create instance for requested data type.
            switch on displaytype {
                
                when Double, Currency, Percent {
                    fieldValue = Double.valueOf( value );
                }
                when Integer {
                    fieldValue = Integer.valueOf( value );
                }
                when Long {
                    fieldValue = Long.valueOf( value );
                }
                when Boolean {
                    fieldValue = Boolean.valueOf( value );
                }
                when Date {
                    fieldValue = convertToDate(value);
                }
                when Datetime {
                    fieldValue = convertToDateTime(value);
                }
                when Time {
                    
                    // Parse time which is in the form of '10:23:33.123z'
                    if( String.isNotBlank(value) ) {
                        
                        Integer milliSecond = 0;
                        String timeString = value.removeEndIgnoreCase('z');
                        
                        if( timeString.indexOf('.') != -1 ) {
                            
                            milliSecond = Integer.valueOf( timeString.substring( timeString.indexOf('.') + 1 ) );
                            timeString = timeString.split('\\.')[0];
                        }
                        
                        if( timeString.indexOf(':') != -1 ) {
                            
                            List<String> timeSplitList = timeString.split(':');
                            if( timeSplitList.size() == 3 ) {
                                fieldValue = Time.newInstance(Integer.valueOf(timeSplitList[0]), Integer.valueOf(timeSplitList[1]), Integer.valueOf(timeSplitList[2]), milliSecond);
                            }
                        }
                    }
                }
                when Phone {
                    fieldValue = value.replaceAll('\\\\D','');
                }
                when Id, String, Picklist, MultiPicklist, Email, Reference, TextArea, EncryptedString, URL {
                    fieldValue = String.valueOf( value );
                }
                when else {
                    // Address, base64, DataCategoryGroupReference
                    System.debug( LoggingLevel.ERROR, 'getFieldValueByType() : Object mapping field type not supported for value mapping. displaytype= ' + displaytype );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldValueByType() : Failed to retrieve value for datatype. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldValueByType() : Failed to retrieve value for datatype. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldValueByType() - exit; fieldValue= ' + fieldValue );
        }
        
        return fieldValue;
    }
    /**
     * This method is used to retrieve field value for given display type.
     * 
     * @param displaytype Data type fpr which value to be converted to datatype instance.
     * @param value Value to be pared or converted to the requested datatype instance.
     */
    @TestVisible public Object getFieldValueByType( final Schema.Displaytype displaytype, final String value, final String targetObjectAPIName ) {

		System.debug( LoggingLevel.DEBUG, 'getFieldValueByType() - enter; displaytype= ' + displaytype );
        
        Object fieldValue;
        
        try {
            
            // Create instance for requested data type.
            switch on displaytype {
                
                when Double, Currency, Percent {
                    fieldValue = Double.valueOf( value );
                }
                when Integer {
                    fieldValue = Integer.valueOf( value );
                }
                when Long {
                    fieldValue = Long.valueOf( value );
                }
                when Boolean {
                    fieldValue = Boolean.valueOf( value );
                }
                when Date {
                    fieldValue = convertToDate(value);
                }
                when Datetime {
                    fieldValue = convertToDateTime(value);
                }
                when Time {
                    
                    // Parse time which is in the form of '10:23:33.123z'
                    if( String.isNotBlank(value) ) {
                        
                        Integer milliSecond = 0;
                        String timeString = value.removeEndIgnoreCase('z');
                        
                        if( timeString.indexOf('.') != -1 ) {
                            
                            milliSecond = Integer.valueOf( timeString.substring( timeString.indexOf('.') + 1 ) );
                            timeString = timeString.split('\\.')[0];
                        }
                        
                        if( timeString.indexOf(':') != -1 ) {
                            
                            List<String> timeSplitList = timeString.split(':');
                            if( timeSplitList.size() == 3 ) {
                                fieldValue = Time.newInstance(Integer.valueOf(timeSplitList[0]), Integer.valueOf(timeSplitList[1]), Integer.valueOf(timeSplitList[2]), milliSecond);
                            }
                        }
                    }
                }
                when Phone {
                    fieldValue = value.replaceAll('\\\\D','');
                }
                when Reference {
                    if (String.valueOf( value ) InstanceOf ID) {
                        fieldValue = String.valueOf( value );
                    } else {
                        fieldValue = getIdByRecordTypeName(targetObjectAPIName, value);
                    }
                }
                when Id, String, Picklist, MultiPicklist, Email, TextArea, EncryptedString, URL {
                    fieldValue = String.valueOf( value );
                }
                when else {
                    // Address, base64, DataCategoryGroupReference
                    System.debug( LoggingLevel.ERROR, 'getFieldValueByType() : Object mapping field type not supported for value mapping. displaytype= ' + displaytype );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldValueByType() : Failed to retrieve value for datatype. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldValueByType() : Failed to retrieve value for datatype. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldValueByType() - exit; fieldValue= ' + fieldValue );
        }
        
        return fieldValue;
    }

    /**
     * This method is used to return record type Id by developer Name 
     */
    private String getIdByRecordTypeName( final String objectAPIName, final String value ) {
        
        String recordTypeId;

        List<Common.RecordType> recordTypeDetails = COMM_MetadataManager.getInstance().getRecordTypeDetails( objectAPIName );
        
        for (Common.RecordType recordType : recordTypeDetails) {
            if (value == recordType.developerName || value == recordType.name) {
                recordTypeId = recordType.id;
            }
        }
        return recordTypeId;
    }
    
    /**
     * This method is used to convert date string to Date instance.
     * Supports both 2014-10-29 format. 
     */
    private Date convertToDate( final String value ) {
        
        Date dateInstance;
        
        if( value.indexOf('-') == -1 ) {
            
            try {
                dateInstance = Date.parse(value);
            }
            catch(Exception e ) {
                dateInstance = Date.valueOf(value);
            }
        } else {
            List<String> dayList = value.split('-');
            dateInstance = Date.newInstance( Integer.valueOf(dayList[0]), Integer.valueOf(dayList[1]),Integer.valueOf(dayList[2]) );
        }
        return dateInstance;
    }
    
    /**
     * This method is used to convert datetime string to Datetime instance.
     * Supports both 10/14/2011, 11:46 AM & 2014-07-31T19:00:00.000Z format. 
     */
    private DateTime convertToDateTime( final String value ) {
        
        DateTime datetimeInstance;
        
        if( value.indexOf('T') == -1 ) {
            datetimeInstance = Datetime.parse(value);
        } else {
            List<String> dateAndTimeList = value.split('T');
            List<String> dayList = dateAndTimeList[0].split('-');
            List<string> timeList = dateAndTimeList[1].split(':');
            datetimeInstance = DateTime.newInstance( Integer.valueOf(dayList[0]), Integer.valueOf(dayList[1]),Integer.valueOf(dayList[2]), Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]),Integer.valueOf(timeList[2].split('\\.')[0]));
        }
        return datetimeInstance;
    }

    /** mapping server issue
     * This method is used to get all fields of current user record which includes multi level reference fields
     */
    public SObject getCurrentUserRecord( Set<String> multiReferenceFields) { //mapping server issue
        Map<String, Schema.DescribeFieldResult> fieldDescribeResult = COMM_DescribeManager.getInstance().getFieldDescribeResults('User');
        Set<String> userFieldSet= new Set<String>();
        List<SObject> userRecords = new List<SObject>();
        for(Schema.DescribeFieldResult fieldDesc : fieldDescribeResult.values()){
            userFieldSet.add(fieldDesc.getName());
        }

        userFieldSet.addAll(multiReferenceFields);
        
        String queryString = 'SELECT ' + String.join(new List<String>(userFieldSet), ',') + 
                                ' FROM User' + ' WHERE Id = \'' + System.UserInfo.getUserId() + '\'' ;
        System.debug( LoggingLevel.DEBUG, 'getCurrentUserRecord() - queryString= ' + queryString );
        userRecords = Database.query(queryString);
        SObjectAccessDecision decision = Security.stripInaccessible( AccessType.READABLE, userRecords );
        userRecords = decision.getRecords();
        return userRecords.get(0);
    }

    /** mapping server issue
     * This method is used to get record appending with multi reference fields with existing single level fields
     */
    public SObject getRecordWithMultiReferenceFields (SObject sObjectRecord, Set<String> multiReferenceFields) { //mapping server issue
        Id recordId = sObjectRecord.Id;
        Schema.SObjectType sObjectType = sObjectRecord.getSObjectType();
        Map<String, Object> sObjectRecordFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObjectRecord));

        SObject resultSObject;
        if (String.isNotBlank(recordId)) {
            // If the header record already exists in the DB, we can simply query for the relationship fields and merge the data
            String queryString = 'SELECT ' + String.join(new List<String>(multiReferenceFields), ',') +
                ' FROM ' + String.escapeSingleQuotes( String.valueOf(sObjectType) ) +
                ' WHERE Id =: recordId';
            System.debug( LoggingLevel.DEBUG, 'getRecordWithMultiReferenceFields() - queryString= ' + queryString );

            List<SObject> sObjectRecords = Database.query(queryString);
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, sObjectRecords);
            sObjectRecords = decision.getRecords();
            Map<String, Object> sObjectRecordWithReferenceFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObjectRecords[0]));

            for (String fieldName : sObjectRecordWithReferenceFields.keyset()) {
                sObjectRecordFields.put(fieldName, sObjectRecordWithReferenceFields.get(fieldName));
            }
        } else {
            // If the header record does not already exist in the DB, we need to gather any referenced related records and query for the requested fields
            
            // Gather target record Ids and fields by object name for bulkified querying
            Map<String, Set<String>> fieldPathsByReferencedObjectName = new Map<String, Set<String>>();
            Map<String, Set<Id>> referencedRecordIdsByObjectName = new Map<String, Set<Id>>();
            for (String fieldPath : multiReferenceFields) {
                List<String> pathParts = fieldPath.split('\\.');
                String initialPathPart = pathParts.remove(0);
                String initialReferenceField = COMM_DescribeManager.getInstance().resolveToFieldName(initialPathPart);

                Map<String, Schema.SObjectField> fieldsForReferencedObject = COMM_DescribeManager.getInstance().getObjectFieldMap(String.valueOf(sObjectType));
                Schema.SObjectField initialReferenceSObjectField = fieldsForReferencedObject.get(initialReferenceField);

                if (initialReferenceSObjectField == null) {
                    System.debug(
                        LoggingLevel.ERROR,
                        'getRecordWithMultiReferenceFields() : Reference field in literal expression does not exist. Field= ' + initialReferenceField
                    );
                    throw new SvmxSystem.SvmxNestedException(ErrorMessage.FIELD_NOT_EXISTS);
                }

                Schema.DescribeFieldResult initialReferenceFieldDescribe = initialReferenceSObjectField.getDescribe();
                if (initialReferenceFieldDescribe.getType() != DisplayType.REFERENCE) {
                    System.debug(
                        LoggingLevel.ERROR,
                        'getRecordWithMultiReferenceFields() : Invalid field in literal expression. Expected a reference field. Field= ' + initialReferenceField
                    );
                    throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
                }

                if (initialReferenceFieldDescribe.isNamePointing()) {
                    System.debug(
                        LoggingLevel.ERROR,
                        'getRecordWithMultiReferenceFields() : Invalid reference field in literal expression. Polymorphic fields unsupported. Field= ' + initialReferenceField
                    );
                    throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
                }

                Schema.SObjectType referencedSObjectType = initialReferenceFieldDescribe.getReferenceTo()[0];
                String referencedObjectName = String.valueOf(referencedSObjectType);
                Id referencedRecordId = (Id)sObjectRecord.get(initialReferenceField);
                
                Set<Id> adjacentRecordIds = referencedRecordIdsByObjectName.get(referencedObjectName);
                if (adjacentRecordIds == null) {
                    adjacentRecordIds = new Set<Id>();
                    referencedRecordIdsByObjectName.put(referencedObjectName, adjacentRecordIds);
                }
                adjacentRecordIds.add(referencedRecordId);

                Set<String> adjacentFieldPaths = fieldPathsByReferencedObjectName.get(referencedObjectName);
                if (adjacentFieldPaths == null) {
                    adjacentFieldPaths = new Set<String>();
                    fieldPathsByReferencedObjectName.put(referencedObjectName, adjacentFieldPaths);
                }
                adjacentFieldPaths.add(String.join(pathParts, '.'));
            }

            // Organize response records by Id for insertion back into header record
            Map<Id, SObject> referencedRecordsById = new Map<Id, SObject>();
            for (String referencedObjectName : referencedRecordIdsByObjectName.keySet()) {
                Set<String> referencedFieldPaths = fieldPathsByReferencedObjectName.get(referencedObjectName);
                Set<Id> referencedRecordsIds = referencedRecordIdsByObjectName.get(referencedObjectName);

                String referencedRecordsQuery = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(referencedFieldPaths), ',')) +
                    ' FROM ' + referencedObjectName +
                    ' WHERE Id IN: referencedRecordsIds';

                List<SObject> referencedRecords = Database.query(referencedRecordsQuery);
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, referencedRecords);
                referencedRecords = decision.getRecords();

                for (SObject referencedRecord : referencedRecords) {
                    referencedRecordsById.put(referencedRecord.Id, referencedRecord);
                }
            }

            // Insert referenced record data back into header record
            for (String fieldPath : multiReferenceFields) {
                List<String> pathParts = fieldPath.split('\\.');
                String initialPathPart = pathParts.remove(0);
                String initialReferenceField = COMM_DescribeManager.getInstance().resolveToFieldName(initialPathPart);
                Id referencedRecordId = (Id)sObjectRecord.get(initialReferenceField);
                SObject referencedRecord = referencedRecordsById.get(referencedRecordId);

                sObjectRecordFields.put(initialPathPart, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(referencedRecord)));
            }
        }

        resultSObject = (SObject)JSON.deserialize(JSON.serialize(sObjectRecordFields), SObject.class);
        return resultSObject;
    }    

    /** mapping server issue
     * This method is used to retrive value of multi reference field from existing SObject
     */
    public Object getValueOfMultiReference (SObject sObjectRecord, String multiReferenceField) { //mapping server issue
        Object fieldValue;
        if (sObjectRecord != null && multiReferenceField != null) {
            List<String> fieldList = new List<String>();
            fieldList = multiReferenceField.split('\\.');
            Integer fieldslevel = fieldList.size();
            if (fieldslevel >= 1) {
                for (Integer i = 0; i < fieldslevel-1; i++) {
                    if (sObjectRecord != null) {
                        sObjectRecord = sObjectRecord.getSObject(fieldList.get(i));   
                    }else{
                        break;
                    }
                }
                if(sObjectRecord != null) {
                    fieldValue = sObjectRecord.get(fieldList.get(fieldslevel-1));
                }
            }
        }
        return fieldValue;
    }

    /** mapping server issue
     * This method is used to retrive value of multi reference field for new SObject record
     */
    public Object multiReferenceValueForNewRecord (SObject sObjectRecord, String multiReferenceField, String relatedObjectDetails) { //mapping server issue
        String fieldName = '';
        Object fieldValue;
        List<SObject> sObjectrecords = new List<SObject>();
        if (multiReferenceField.substringBefore('.').endsWith('__r')) {
            fieldName = multiReferenceField.substringBefore('.').replace('__r', '__c');
        } else {
            fieldName = multiReferenceField.substringBefore('.') + 'Id';
        }

        if(sObjectRecord.get(fieldName) != null) {
            String queryString = 'SELECT ' + multiReferenceField.substringAfter('.') + 
                ' FROM ' + relatedObjectDetails.substringBefore('.') + ' WHERE Id = \'' + sObjectRecord.get(fieldName) + '\'' ;
            System.debug( LoggingLevel.DEBUG, 'multiReferenceValueForNewRecord() - queryString= ' + queryString );

            sObjectrecords = Database.query(queryString);
            SObjectAccessDecision decision = Security.stripInaccessible( AccessType.READABLE, sObjectrecords );
            sObjectrecords = decision.getRecords();
            if(!sObjectrecords.isEmpty()){
                if(multiReferenceField.substringAfter('.').contains('.')) {
                    fieldValue = getValueOfMultiReference(sObjectrecords.get(0), multiReferenceField.substringAfter('.'));
                } else  {
                    fieldValue = sObjectrecords.get(0).get(multiReferenceField.substringAfter('.'));
                }
            }
            
        }
        return fieldValue;
    }

    /**
     * This method is used to retrieve the mapped target object field value. 
     */
    private Object getFieldValueForMapping( SObject sObjectRecord, Adm.ObjectMappingDetail objectMappingDetail ) {
        
        Object targetFieldValue;
        
        if (sObjectRecord != null && objectMappingDetail.literalParameterAPIName != null && objectMappingDetail.literalParameterAPIName.contains('.')) {
            if (sObjectRecord.Id != null) {
                //stores multi level fields for existing target object
                targetFieldValue = getValueOfMultiReference(sObjectRecord, objectMappingDetail.literalParameterAPIName);
            } else {
                //stores multi level fields for new target object
                targetFieldValue = multiReferenceValueForNewRecord(sObjectRecord, objectMappingDetail.literalParameterAPIName, objectMappingDetail.relatedObjectDetails);
            }
        } else if (sObjectRecord != null && objectMappingDetail.literalParameterAPIName != null) {
            //stores single level fields 
            targetFieldValue = sObjectRecord.get( objectMappingDetail.literalParameterAPIName ); 
        }

        return targetFieldValue;
    }

    /**
     * This method is used to retrieve the mapped target object field value. 
     */
    private Object getFieldValueForCurrentRecordHeader( SObject sObjectRecord, Adm.ObjectMappingDetail objectMappingDetail, String objectMappingId ) {
        
        Object targetFieldValue;
        
        if (sObjectRecord != null && objectMappingDetail.literalParameterAPIName != null && objectMappingDetail.literalParameterAPIName.contains('.')) {
            if (sObjectRecord.Id != null) {
                //stores multi level fields for existing target object
                targetFieldValue = getValueOfMultiReference(sObjectRecord, objectMappingDetail.literalParameterAPIName);
            } else {
                //stores multi level fields for new target object
                if (multiLevelFieldValueforCRH.containsKey(objectMappingId)) {
                    targetFieldValue = multiLevelFieldValueforCRH.get(objectMappingId).get(objectMappingDetail.literalParameterAPIName);  
                }
            }
        } else if (sObjectRecord != null && objectMappingDetail.literalParameterAPIName != null) {
            //stores single level fields 
            targetFieldValue = sObjectRecord.get( objectMappingDetail.literalParameterAPIName ); 
        }

        return targetFieldValue;
    }

    /**
     * This method is used to retrieve the mapped target object field value. 
     */
    private void getMultiLevelFieldValueforCRH( SObject currentRecordHeader, Adm.ObjectMapping objectMapping ) {
        try {
            Map<String, Set<String>> objectFieldMap = new Map<String, Set<String>>();
            Map<String, String> queryObjectFieldMap = new Map<String, String>();
            Map<String, SObject> objectRecordMap = new Map<String, SObject>();
            Map<String, Object> literalValueCRH = new  Map<String, Object>();
            Object fieldValue;

            for (Adm.ObjectMappingDetail mappingDetail: objectMapping.objectMappingDetails) {
                if (mappingDetail.value == 'Current Record Header' && mappingDetail.relatedObjectDetails != null) {
                    String objectName = (mappingDetail.relatedObjectDetails).contains('.') ? (mappingDetail.relatedObjectDetails).substringBefore('.') : mappingDetail.relatedObjectDetails;
                    if(objectFieldMap.containsKey(objectName)) {
                        objectFieldMap.get(objectName).add(mappingDetail.literalParameterAPIName);
                    } else {
                        Set<String> fieldList = new Set<String>();
                        fieldList.add(mappingDetail.literalParameterAPIName);
                        objectFieldMap.put(objectName,fieldList);
                    }
                }
            }
            for (String multiObject: objectFieldMap.keySet()) {
                String fieldName;
                String multiLevelFieldName;
                Set<String> multiFieldSet = new Set<String>();
                List<String> multiFieldList = new List<String>();
                List<SObject> sObjectrecords = new List<SObject>();
                if (objectFieldMap.get(multiObject).size() > 0) {
                    multiLevelFieldName = (new List<String>(objectFieldMap.get(multiObject)))[0].substringBefore('.');
                }
                if(!multiLevelFieldName.endsWith('__c')) {
                    fieldName = multiLevelFieldName + 'Id';
                } 
                for (String field : objectFieldMap.get(multiObject)) {
                    multiFieldSet.add(field.substringAfter('.'));
                }
                if (objectFieldMap.get(multiObject).size() > 0 && currentRecordHeader.get(fieldName) != null) {
                    String queryString = 'SELECT ' + String.join(new List<String>(multiFieldSet), ',') + 
                        ' FROM ' + multiObject + ' WHERE Id = \'' + currentRecordHeader.get(FieldName) + '\'' ;
                    System.debug( LoggingLevel.DEBUG, 'getMultiLevelFieldValueforCRH() - queryString= ' + queryString );
                
                    sObjectrecords = Database.query(queryString);
                    SObjectAccessDecision decision = Security.stripInaccessible( AccessType.READABLE, sObjectrecords );
                    sObjectrecords = decision.getRecords();
                    if(!sObjectrecords.isEmpty()){
                        objectRecordMap.put(multiObject,sObjectrecords.get(0));
                    }   
                }
            }
            for (Adm.ObjectMappingDetail mappingDetail: objectMapping.objectMappingDetails) {
                if (mappingDetail.value == 'Current Record Header' && mappingDetail.relatedObjectDetails != null) {
                    String objectName = (mappingDetail.relatedObjectDetails).contains('.') ? (mappingDetail.relatedObjectDetails).substringBefore('.') : mappingDetail.relatedObjectDetails;
                    String multiLevelField = (mappingDetail.literalParameterAPIName).substringAfter('.');
                    if (multiLevelField.contains('.') && objectRecordMap.containsKey(objectName)) {
                        fieldValue = getValueOfMultiReference(objectRecordMap.get(objectName), (mappingDetail.literalParameterAPIName).substringAfter('.'));
                        literalValueCRH.put(mappingDetail.literalParameterAPIName,fieldValue);
                    } else if (objectRecordMap.containsKey(objectName)) {
                        fieldValue = objectRecordMap.get(objectName).get(multiLevelField);
                        literalValueCRH.put(mappingDetail.literalParameterAPIName,fieldValue);
                    }
                }
            }
            multiLevelFieldValueforCRH.put(objectMapping.id,literalValueCRH);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getMultiLevelFieldValueforCRH() : Failed to populate field. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }

    /**
     * Populates the target field on the record given the provided value.
     * Includes additional pre-validation to prevent the propagation of invalid mapped values.
     */
    private static void populateField(SObject sObjectRecord, Schema.DescribeFieldResult fieldDescribe, Object value) {
        try {
            if (sObjectRecord == null) {
                return;
            }

            // When a null is provided for a checkbox field, skip it to allow the DB default value to be populated instead
            if (value == null && fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
                return;
            }

            if (value != null && fieldDescribe.getType() == Schema.DisplayType.DATE) {
                String dateValue = String.valueOf(value);
                Datetime dateTimeValue = (datetime) value;
                //field value of SObject.get() for datetime field return as 2021-09-24 04:51:36
                //field value of SObject.get() for date field return as 2021-09-24 00:00:00
                //so add below if condition
                if(!dateValue.endsWith(' 00:00:00')) {
                value = (Object)dateTimeValue.date(); 
                }
            }

            if(value != null && fieldDescribe.getType() == Schema.DisplayType.TEXTAREA) {
                value = (Object)String.valueOf(value);
            }

            // Finally, if all pre-validation is passed, populate the target field with the given value
            sObjectRecord.put(fieldDescribe.getName(), value);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'populateField() : Failed to populate field. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }
}