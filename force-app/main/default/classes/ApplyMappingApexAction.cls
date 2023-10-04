/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief An invocable apex action to perform apply mapping.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       21 May 2020     Created.
 * A360CE-261   Ramachandra Mohan       17 Oct 2020     Handle multiple source record request.
 * A360ENG-415  Ramachandra Mohan       01 Nov 2020     Handle source to child mapping.
 * A360ENG-423  Ramachandra Mohan       05 Nov 2020     Bypas null check for source list.
 *****************************************************************************************************/
global with sharing class ApplyMappingApexAction {
    
    // Apply mapping request parameters
    global class ApplyMappingRequest {
        
        @InvocableVariable(label='Mapping Id' description='Object Mapping Configuration Id' required=true)
        global String mappingId;
        
        @InvocableVariable(label='Source Records' description='Source Object record from which fields are to be mapped.')
        global List<SObject> sourceSObjectList;
        
        @InvocableVariable(label='Target Records' description='Target Object record where the field values are to be populated.')
        global List<SObject> targetSObjectList;
    }
    
    // Apply mapping response.
    global class ApplyMappingResponse {
        
        @InvocableVariable(label='Target SObject Records After Mapping' description='Target Object with populated field values.' required=true)
        global List<SObject> targetSObjectList;
    }
    
    /**
     * This method is used to invoke apply mapping form Flow Apex Actions.
     * 
     * @param applyMappingRequestList Apply Mapping request parameters which includes object mapping Id, source object 
     * when mapping is of type field mapping and optional target object to be returned post apply mapping. 
     */
	@InvocableMethod(label='Apply Mapping' description='Apex action to perform Field/Value mapping.' category='Asset 360 Core')
    global static List<ApplyMappingResponse> applyObjectMapping( List<ApplyMappingRequest> applyMappingRequestList ) {
        
        System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit' );
        
        ApplyMappingResponse mappingResponse = new ApplyMappingResponse();
        
        try {
            
            // Check for valid apply mapping request.
            if( applyMappingRequestList == null || applyMappingRequestList.size() == 0 ) {
            
                System.debug( LoggingLevel.ERROR, 'applyObjectMapping() : Invalid request parameters. applyMappingRequestList= ' + applyMappingRequestList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            mappingResponse.targetSObjectList = new List<SObject>();
            final CONF_ObjectMappingHandler handler = new CONF_ObjectMappingHandler();
            final ApplyMappingRequest applyMappingRequest = applyMappingRequestList.get(0);
            Set<String> queryReferenceFields = new Set<String>();

            for(SVMXA360__CONF_ObjectMappingDetail__c mappingElement : (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__TargetFieldAPIName__c, SVMXA360__LiteralParameter__c, 
                                                                        SVMXA360__Type__c, SVMXA360__Value__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE (SVMXA360__ObjectMappingID__c =: applyMappingRequest.mappingId
                                                                        OR SVMXA360__ObjectMappingID__r.SVMXA360__DeveloperName__c =: applyMappingRequest.mappingId) AND SVMXA360__Type__c = 'Function' AND 
                                                                        SVMXA360__Value__c = 'Current Record' AND SVMXA360__LiteralParameter__c != null])){ 

                queryReferenceFields.add(mappingElement.SVMXA360__LiteralParameter__c);
            }

            applyMappingRequest.targetSObjectList = createTargetObjects( applyMappingRequest.targetSObjectList, applyMappingRequest.mappingId);
            
            applyMappingRequest.targetSObjectList = queryMergeReferenceFields(applyMappingRequest.targetSObjectList, queryReferenceFields);


            if( applyMappingRequest.sourceSObjectList != null && applyMappingRequest.targetSObjectList != null && applyMappingRequest.sourceSObjectList.size() < applyMappingRequest.targetSObjectList.size() ) {
                
                if( applyMappingRequest.sourceSObjectList.size() == 1 ) {
                    
                    final SObject sourceRecord = applyMappingRequest.sourceSObjectList.get(0);
                    for( SObject targetSObject : applyMappingRequest.targetSObjectList ) {
                        mappingResponse.targetSObjectList.add( handler.applyObjectMapping( applyMappingRequest.mappingId, targetSObject, sourceRecord ) );
                    }
                }
                
            } else if( applyMappingRequest.sourceSObjectList != null && applyMappingRequest.sourceSObjectList.size() > 0 ) {
                
                for( Integer index = 0; index < applyMappingRequest.sourceSObjectList.size(); index++ ) {
                    
                    final SObject sourceRecord = applyMappingRequest.sourceSObjectList.get(index);
                    
                    // The handler creates target object instance if not exists otherwise, populates target object from request parameter.
                    if( applyMappingRequest.targetSObjectList == null || applyMappingRequest.targetSObjectList.size() == 0 ) {
                        mappingResponse.targetSObjectList.add( handler.createAndApplyObjectMapping( applyMappingRequest.mappingId, sourceRecord ) );
                    } else {
                        mappingResponse.targetSObjectList.add( handler.applyObjectMapping( applyMappingRequest.mappingId, applyMappingRequest.targetSObjectList.get(index), sourceRecord ) );
                    }
                }
            } else {
                
                final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(applyMappingRequest.mappingId);
                
                if( !objectMapping.mappingType.equalsIgnoreCase('Field Mapping') ) {
                    // Handle for Value Mapping
                    // The handler creates target object instance if not exists otherwise, populates target object from request parameter.
                    if( applyMappingRequest.targetSObjectList == null || applyMappingRequest.targetSObjectList.size() == 0 ) {
                        mappingResponse.targetSObjectList.add( handler.createAndApplyObjectMapping( applyMappingRequest.mappingId, null ) );
                    } else {
                        for( SObject targetSObject : applyMappingRequest.targetSObjectList ) {
                            mappingResponse.targetSObjectList.add( handler.applyObjectMapping( applyMappingRequest.mappingId, targetSObject, null ) );
                        }
                    }
                }
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
            System.debug( LoggingLevel.DEBUG, 'applyObjectMapping() - exit; targetSObjectList= ' + mappingResponse.targetSObjectList );
        }
        
        return new List<ApplyMappingResponse>{mappingResponse};
    }
    
    /**
     * Clean list by removing null elements.
     */
    private static List<SObject> createTargetObjects( final List<SObject> sObjectList, final String mappingId ) {
        
        List<SObject> resultSObjectList = sObjectList;
        if( sObjectList != null && String.isNotBlank(mappingId) ) {
            
            final Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(mappingId);
            if( String.isNotBlank( objectMapping.targetObjectAPIName )  ) {
                resultSObjectList = new List<SObject>();
                for( SObject sObjectRecord : sObjectList ) {
                    resultSObjectList.add( ( sObjectRecord != null ) ? sObjectRecord : (SObject) Type.forName('Schema.' + objectMapping.targetObjectAPIName ).newInstance() );
                }
            }
        }
        return resultSObjectList;
    }

    private static List<sObject> queryMergeReferenceFields(List<sObject> targetRecords, Set<String> queryReferenceFields){
        if(targetRecords != null && !targetRecords.isEmpty() && !queryReferenceFields.isEmpty()){
            sObjectType sobjectType = targetRecords[0].getSObjectType();
            Map<Id, SObject> targetsObjectMap = new Map<Id, SObject>();
            List<SObject> tempTargetList = new List<SObject>();
            for(sObject targetSobjRec : targetRecords){
                if(targetSobjRec.get('Id') != null){
                    targetsObjectMap.put((Id)targetSobjRec.get('Id'), targetSobjRec);
                } else {
                    tempTargetList.add(targetSobjRec);
                }
            }

            Set<Id> targetRecordIDs = targetsObjectMap.keySet();

            String queryString = 'SELECT Id, ' + String.join(new List<String>(queryReferenceFields), ',') + ' FROM ' + sobjectType + ' WHERE ID IN : targetRecordIDs ';
            List<SObject> sObjectList = Database.query(queryString);
            
            for(SObject sObjRec : sObjectList){
                if(targetsObjectMap.containsKey(sObjRec.Id)){
                    Map<String, Object> sObjectRecordFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(targetsObjectMap.get(sObjRec.Id)));
                    Map<String, Object> sObjectRecordWithReferenceFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObjRec));
                    for (String fieldName : sObjectRecordWithReferenceFields.keyset()) {
                        sObjectRecordFields.put(fieldName, sObjectRecordWithReferenceFields.get(fieldName));
                    }
                    sObject mergedSobjectRecord =(SObject)JSON.deserialize(JSON.serialize(sObjectRecordFields), SObject.class);
                    tempTargetList.add(mergedSobjectRecord);
                }
            }
            targetRecords = tempTargetList;            
        }

        return targetRecords;
    }    
}