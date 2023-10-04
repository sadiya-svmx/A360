/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This handler class contains utility methods for service contract creation.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       6 Sept 2021     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class SCON_ServiceContractPlanHelper {

    /**
     * Method to prepare the service response when dml operation partially succeeded.
     */
    public static void prepareServiceResponse (Common.ServiceResponse serviceResponse, Common.DatabaseResult dbResult, String sourceError) {

        if (dbResult != null && dbResult.errors !=null && ! dbResult.errors.isEmpty()) {
            serviceResponse.errors = ( serviceResponse.errors == null ? new List<SvmxGlobal.SvmxError>() : serviceResponse.errors );
            serviceResponse.errors.addAll(dbResult.errors);
            serviceResponse.success = false;
            serviceResponse.message = sourceError;
        }    
    }

    /**
     * Static method to retrieve service contract plan record
     */
    public static SVMXA360__ServiceContractPlan__c getSCONfromCLIPlanProductId (String planProductId) {

        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = new SVMXA360__ServiceContractPlan__c();

        try{

            String objectName = String.valueOf( ( (Id) planProductId ).getSobjectType() );
            
            if (objectName != 'Product2') {
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_IsCLIPlanProductId );
            }

            List<SVMXA360__ContractLineItemPlan__c> cliPlanRecords = SvmxDatabase.query( [Select Id,Name,SVMXA360__ProductId__c,SVMXA360__ServiceContractPlanId__c from SVMXA360__ContractLineItemPlan__c Where SVMXA360__ProductId__c =: planProductId ] );

            if( cliPlanRecords == null || cliPlanRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' planProductId= ' + planProductId );
            }

            SVMXA360__ContractLineItemPlan__c  cliplanRecord = cliPlanRecords.get(0);

            serviceContractPlanRecord = getServiceContractPlanRecord(cliplanRecord.SVMXA360__ServiceContractPlanId__c);
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getSCONfromCLIPlanProductId() : Failed to getServiceContractPlanRecord. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getSCONfromCLIPlanProductId() : Failed to getServiceContractPlanRecord. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSCONfromCLIPlanProductId() - exit; serviceContractPlanRecord= ' + serviceContractPlanRecord);
        }

        return serviceContractPlanRecord;
    }
    
    /**
     * Static method to retrieve service contract plan record
     */
    public static SVMXA360__ServiceContractPlan__c getServiceContractPlanRecord (String serviceContractProductId) {

        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = new SVMXA360__ServiceContractPlan__c();

        try{

            List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = SvmxDatabase.query( [Select Id,Name,SVMXA360__Description__c,SVMXA360__ServicePlanProductId__c,SVMXA360__IsActive__c from SVMXA360__ServiceContractPlan__c Where Id =:serviceContractProductId OR SVMXA360__ServicePlanProductId__c =: serviceContractProductId OR SVMXA360__ServicePlanProductId__r.ExternalId =: serviceContractProductId ] );

            if( serviceContractPlanRecords == null || serviceContractPlanRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' serviceContractProductId= ' + serviceContractProductId );
            }

            serviceContractPlanRecord = serviceContractPlanRecords.get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanRecord() : Failed to getServiceContractPlanRecord. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanRecord() : Failed to getServiceContractPlanRecord. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecord() - exit; serviceContractPlanRecord= ' + serviceContractPlanRecord);
        }

        return serviceContractPlanRecord;
    }

    /**
     * Static method to retrieve service contract record
     */
    public static ServiceContract getServiceContractRecord (Id serviceContractId) {

        ServiceContract serviceContractRecord = new ServiceContract();

        try{

            String query = 'Select Id, StartDate, EndDate, AccountId, Pricebook2Id,Pricebook2.Name';

            if ( UserInfo.isMultiCurrencyOrganization() ) {
                query += ', CurrencyIsoCode ';
            }

            query +=  '  from ServiceContract Where Id =: serviceContractId';

            List<ServiceContract> serviceContractRecords = SvmxDatabase.query( Database.query( query ) );

            if( serviceContractRecords == null || serviceContractRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' serviceContractId= ' + serviceContractId );
            }

            serviceContractRecord = serviceContractRecords.get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceContractRecord() : Failed to getServiceContractRecord. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceContractRecord() : Failed to getServiceContractRecord. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractRecord() - exit; serviceContractRecord= ' + serviceContractRecord);
        }

        return serviceContractRecord;
    }

    /**
     * Static method to populate contract line item Id to the request
     */
    public static List<ContractLineAssetData> updateAssetDataRequest ( List<ContractLineItem> contractLineItemList, 
                                                                                           Map<Id,ContractLineAssetData> contractLineAssetDataMap) {
        
        List<ContractLineAssetData> contractLineAssetList = new List<ContractLineAssetData>();

        for ( ContractLineItem contractLineItemRecord : contractLineItemList ) {

            ContractLineAssetData assetRequestData = contractLineAssetDataMap.get(contractLineItemRecord.AssetId);
            assetRequestData.contractLineItemId = contractLineItemRecord.Id;
            contractLineAssetList.add(assetRequestData);
        }

        return contractLineAssetList;
    }

    /**
     * Static method to publish platform event for create operation
     */
    public static SVMXA360__ApplicationEventBus__e buildCreatePlatformEvent ( Map<Id,Id> assetContractPlanMap, String serviceContractPlanId, 
                                                                              ServiceContract serviceContractRecord, Id userId, 
                                                                              SVMXA360__SCONAuthoringLog__c parentLogRecord ) {

        System.debug( LoggingLevel.DEBUG, 'publishPlatformEvent() - enter; parentLogRecord = ' + parentLogRecord );

        SVMXA360__ApplicationEventBus__e servicemaxEvent = new SVMXA360__ApplicationEventBus__e();

        try {

            servicemaxEvent.Type__c = 'SCONAuthoring';
            servicemaxEvent.SVMXA360__SourceRecordId__c = serviceContractRecord.Id;
            servicemaxEvent.SVMXA360__SourceObjectAPIName__c = 'ServiceContract';
            servicemaxEvent.SVMXA360__Payload__c = buildPayload(assetContractPlanMap, null, serviceContractPlanId, serviceContractRecord, parentLogRecord );
            servicemaxEvent.SVMXA360__OperationType__c = 'Create';
            servicemaxEvent.SVMXA360__UserId__c = userId;

        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'buildCreatePlatformEvent() : Failed to build platform event. Error= ' + e.getMessage() );
            throw e;
        }
        finally {

            System.debug( LoggingLevel.DEBUG, 'buildCreatePlatformEvent() - exit; servicemaxEvent= ' + servicemaxEvent);
        }
        return servicemaxEvent;
    }

    /**
     * Static method to build payload for platform event
     */
    private static String buildPayload( Map<Id,Id> assetContractPlanMap, List<Id> recordIds, String serviceContractPlanId, 
                                       ServiceContract serviceContractRecord, SVMXA360__SCONAuthoringLog__c parentLogRecord ) {
        
        final Scon.PlatformEventRequest platformEventRequest = new Scon.PlatformEventRequest();

        if ( assetContractPlanMap != null ) {
            platformEventRequest.assetServiceContractPlanIdMap = assetContractPlanMap;
            platformEventRequest.serviceContractRecord = serviceContractRecord;
        } 
        
        else if ( recordIds != null ) {
            platformEventRequest.recordIds = recordIds;
            platformEventRequest.serviceContractId = serviceContractRecord.Id;
        }

        if ( serviceContractPlanId != null ){
            platformEventRequest.serviceContractPlanId = serviceContractPlanId;
        }

        platformEventRequest.parentSCONLogRecordId = parentLogRecord.Id;
            
        return JSON.serialize(platformEventRequest);
    }

    /**
     * Static method to create platform event for delete operation
     */
    private static SVMXA360__ApplicationEventBus__e buildPlatformEvent ( List<Id> recordIds, ServiceContract serviceContractRecord, 
                                                                        Id userId, SVMXA360__SCONAuthoringLog__c parentLogRecord ) {

        System.debug( LoggingLevel.DEBUG, 'buildPlatformEvent() - enter; parentLogRecord = ' + parentLogRecord );

        SVMXA360__ApplicationEventBus__e servicemaxEvent = new SVMXA360__ApplicationEventBus__e();
        servicemaxEvent.Type__c = 'SCONAuthoring';
        servicemaxEvent.SVMXA360__SourceRecordId__c = serviceContractRecord.Id;
        servicemaxEvent.SVMXA360__SourceObjectAPIName__c = 'ServiceContract';
        servicemaxEvent.SVMXA360__Payload__c = buildPayload(null, recordIds, null, serviceContractRecord, parentLogRecord );
        servicemaxEvent.SVMXA360__OperationType__c = 'Delete';
        servicemaxEvent.SVMXA360__UserId__c = userId;

        return servicemaxEvent;
        
    }

    /**
     * Static method to publish platform events for bulk assets processing
     */
    public static SVMXA360__SCONAuthoringLog__c publishContractLinePlatformEvents( Scon.ServiceContractPlanRequest sconRequest , ServiceContract serviceContractRecord) {

        System.debug( LoggingLevel.DEBUG, 'publishContractLinePlatformEvents() - enter; serviceContractRecordId= ' + serviceContractRecord );

        SVMXA360__SCONAuthoringLog__c parentLogRecord = new SVMXA360__SCONAuthoringLog__c();

        try {

            Map<Id,Id> assetContractPlanMap = new Map<Id,Id>();
            Id userId = UserInfo.getUserId();

            parentLogRecord.SVMXA360__ServiceContractId__c = serviceContractRecord.Id;
            parentLogRecord.SVMXA360__OperationType__c = 'Create';
            parentLogRecord.SVMXA360__TotalNumberOfBatches__c = Integer.valueOf((sconRequest.assetServiceContractPlanIdMap.size()/100.0).round(System.RoundingMode.CEILING));
            parentLogRecord.SVMXA360__LogType__c = 'Master';
            parentLogRecord.SVMXA360__UserId__c = userId;
            parentLogRecord.SVMXA360__TotalBatchesCompleted__c = 0;

            parentLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( parentLogRecord );

            List<SVMXA360__ApplicationEventBus__e> platformEvents = new List<SVMXA360__ApplicationEventBus__e>();

            for ( Id assetId : sconRequest.assetServiceContractPlanIdMap.keySet() ) {

                assetContractPlanMap.put(assetId, sconRequest.assetServiceContractPlanIdMap.get(assetId));

                if ( assetContractPlanMap.size() == 100 ) {
                    platformEvents.add(SCON_ServiceContractPlanHelper.buildCreatePlatformEvent ( assetContractPlanMap, sconRequest.serviceContractPlanId, serviceContractRecord, userId, parentLogRecord));
                    assetContractPlanMap.clear();
                }

                if ( platformEvents.size() == 3 ) {
                    publishPlatformEvents( platformEvents );
                    platformEvents.clear();
                }
            }

            if ( !assetContractPlanMap.isEmpty() ) {
                platformEvents.add(SCON_ServiceContractPlanHelper.buildCreatePlatformEvent ( assetContractPlanMap, sconRequest.serviceContractPlanId, serviceContractRecord, userId, parentLogRecord));
            }

            if ( !platformEvents.isEmpty() ) {
                publishPlatformEvents( platformEvents );
                platformEvents.clear();
            }
        
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Service Contract. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Service Contract. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createServiceContract() - exit; serviceContractRecord= ' + serviceContractRecord);
        }

        return parentLogRecord;
    }

    public static void publishPlatformEvents ( List<SVMXA360__ApplicationEventBus__e> platformEvents ) {

        List<Database.SaveResult> saveResultList = EventBus.publish(platformEvents);

        for( Database.SaveResult saveResult : saveResultList ) {

            if( saveResult.isSuccess() ) {
                System.debug( LoggingLevel.DEBUG, 'Successfully published SCON Authoring Events.' );
            } else {
                    
                for( Database.Error error : saveResult.getErrors() ) {
                    System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + error.getStatusCode() + ' - ' + error.getMessage() );
                }
            }
        }
    }

    /**
     * Static method to update parent log record and create child log records
     */
    public static void createSCONLogRecord( String serviceContractRecordId, String parentSCONLogRecordId, String userId, Scon.LogMessage logMessage, 
                                      String operationType) {

        System.debug( LoggingLevel.DEBUG, 'createSCONLogRecord() - enter; parentSCONLogRecordId= ' + parentSCONLogRecordId);
        
        try {

            SVMXA360__SCONAuthoringLog__c sconLogRecord = new SVMXA360__SCONAuthoringLog__c();

            sconLogRecord.SVMXA360__ServiceContractId__c = serviceContractRecordId;
            sconLogRecord.SVMXA360__OperationType__c = operationType;
            sconLogRecord.SVMXA360__LogType__c = 'Detail';
            sconLogRecord.SVMXA360__ParentSCONAuthoringLogId__c = parentSCONLogRecordId;
            sconLogRecord.SVMXA360__UserId__c = userId;
            
            if ( logMessage.errors == null ) {
                sconLogRecord.SVMXA360__Status__c = 'Success';
            } else {
                sconLogRecord.SVMXA360__Status__c = 'Failed';
            }

            sconLogRecord.SVMXA360__Message__c = JSON.serializePretty(logMessage);

            sconLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( sconLogRecord );

            List<SVMXA360__SCONAuthoringLog__c> sconParentLogRecords = SvmxDatabase.query([SELECT Id, SVMXA360__Status__c, SVMXA360__TotalBatchesCompleted__c, SVMXA360__TotalNumberOfBatches__c,
                                                                                          (Select Id, SVMXA360__Status__c from SVMXA360__SCON_Authoring_Logs__r 
                                                                                            where SVMXA360__ParentSCONAuthoringLogId__c = :parentSCONLogRecordId )
                                                                                           FROM SVMXA360__SCONAuthoringLog__c where Id = :parentSCONLogRecordId for update]);

            if ( !sconParentLogRecords.isEmpty() ){

                SVMXA360__SCONAuthoringLog__c parentLog = sconParentLogRecords[0];

                parentLog.SVMXA360__TotalBatchesCompleted__c += 1;

                ServiceContract sconRecord = new ServiceContract();
                Boolean sconDeleted = false;

                if ( parentLog.SVMXA360__TotalBatchesCompleted__c == parentLog.SVMXA360__TotalNumberOfBatches__c) {

                    Boolean failedBatch = false;
                    List<ServiceContract> serviceContractRecords = SvmxDatabase.query([Select Id, SVMXA360__ContractAuthoringStatus__c from 
                                                                                    ServiceContract where Id = :serviceContractRecordId]);
                    
                    sconRecord = serviceContractRecords[0];

                    for ( SVMXA360__SCONAuthoringLog__c childLogRecord : parentLog.SVMXA360__SCON_Authoring_Logs__r ) {

                        if (childLogRecord.SVMXA360__Status__c == 'Failed') {
                            failedBatch = true;
                        }
                    } 

                    if (failedBatch) {
                        
                        parentLog.SVMXA360__Status__c = 'Failed';
                        sconRecord.SVMXA360__ContractAuthoringStatus__c = 'Incomplete';
                     } else {

                        parentLog.SVMXA360__Status__c = 'Success';
                        sconRecord.SVMXA360__ContractAuthoringStatus__c = 'AuthoringCompleted';
                    }

                    if ( sconRecord.SVMXA360__ContractAuthoringStatus__c != null && 
                         sconRecord.SVMXA360__ContractAuthoringStatus__c == 'AuthoringCompleted' && operationType == 'Delete' ) {

                        List<SVMXA360__SCONAuthoringLog__c> sconLogRecords = 
                        SvmxDatabase.query([SELECT Id from SVMXA360__SCONAuthoringLog__c where SVMXA360__ServiceContractId__c = :sconRecord.Id]);
                        SvmxDatabase.deleteRecord( sconLogRecords );
                        SvmxDatabase.deleteRecord( sconRecord );
                        sconDeleted = true;

                    } else {
                        sconRecord = (ServiceContract) SvmxDatabase.updateRecord( sconRecord );
                    }
                }

                if (!sconDeleted) {
                    parentLog = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.updateRecord( parentLog );
                }
            }

        } 
        catch( SvmxSystem.SvmxNestedException e ) {

            updateParentAndSCONFailedStatus( parentSCONLogRecordId, serviceContractRecordId);
            System.debug( LoggingLevel.ERROR, 'createSCONLogRecord() : Failed to create Log records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            updateParentAndSCONFailedStatus( parentSCONLogRecordId, serviceContractRecordId);
            System.debug( LoggingLevel.ERROR, 'createSCONLogRecord() : Failed to create Log records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createSCONLogRecord() - exit; parentSCONLogRecordId= ' + parentSCONLogRecordId);
        }

    }

    /**
     * Static method to update parent log and service contract status
     */
    private static void updateParentAndSCONFailedStatus( String parentSCONLogRecordId, String serviceContractRecordId) {

        try {

            List<SVMXA360__SCONAuthoringLog__c> sconParentLogRecords = SvmxDatabase.query([SELECT Id, SVMXA360__Status__c FROM 
                                                                                           SVMXA360__SCONAuthoringLog__c where 
                                                                                           Id = :parentSCONLogRecordId for update]);

            SVMXA360__SCONAuthoringLog__c parentLog = sconParentLogRecords[0];
            parentLog.SVMXA360__Status__c = 'Failed';

            List<ServiceContract> serviceContractRecords = SvmxDatabase.query([Select Id, SVMXA360__ContractAuthoringStatus__c from 
                                                                                    ServiceContract where Id = :serviceContractRecordId]);
        
            ServiceContract sconRecord = serviceContractRecords[0];                                                                        
            sconRecord.SVMXA360__ContractAuthoringStatus__c = 'Incomplete'; 

            sconRecord = (ServiceContract) SvmxDatabase.updateRecord( sconRecord );

            parentLog = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.updateRecord( parentLog );

        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'updateParentLogAndSCONFailedStatus() : Failed to update parent Log and SCON Log records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateParentLogAndSCONFailedStatus() - exit; parentSCONLogRecordId= ' + parentSCONLogRecordId);
        }

    }

    /**
     * Static method to fetch pricebook map for the plans and product set
     */
    public static Map<String, PricebookEntry> getPricebookEntryMap (List<Scon.ServiceContractPlan> serviceContractPlans, Set<String> uniqueProductSet, ServiceContract serviceContractRecord) {

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
        Set<String> pricebook2Ids = new Set<String>();

        try {

            ServiceContract emptyServiceContract = new ServiceContract();

            if ( serviceContractRecord == emptyServiceContract ) {

                for (Scon.ServiceContractPlan serviceContractPlan : serviceContractPlans) {
                    pricebook2Ids.add(serviceContractPlan.pricebookId);
                }
            }
            else {
                pricebook2Ids.add(serviceContractRecord.Pricebook2Id);
            }
            
            String query = 'SELECT Id, Name, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :uniqueProductSet AND Pricebook2Id IN :pricebook2Ids';

            if( UserInfo.isMultiCurrencyOrganization() ) {

                String currencyCode;
                if (serviceContractRecord != emptyServiceContract) {
                	currencyCode = (String)serviceContractRecord.get('CurrencyISOCode');
                } else {
                    currencyCode = serviceContractPlans[0].currencyIsoCode;
                }
                pricebookEntries = SvmxDatabase.query(Database.query(query + ' AND CurrencyISOCode = :currencyCode'));
            } else {
                pricebookEntries = SvmxDatabase.query(Database.query(query));
            }
            
            for( PricebookEntry pricebookEntryRecord : pricebookEntries ) {
                pricebookEntryMap.put(pricebookEntryRecord.Product2Id, pricebookEntryRecord);
            }
        }
        catch( SvmxSystem.SvmxNestedException e ){

            System.debug( LoggingLevel.ERROR, 'getPricebookEntryMap() : Failed to get pricebook entry map. Error= ' + e.getMessage() );
            throw e;
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getPricebookEntryMap() : Failed to get pricebook entry map. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookEntryMap() - exit; pricebookEntryMap= ' + pricebookEntryMap);
        }

        return pricebookEntryMap;
    }

    /**
     * Static method to fetch assets and list of Ids
     */
    public static List<Asset> getAssetRecords( final Set<Id> assetIds ) {

        List<Asset> assetRecordList = new List<Asset>();

        try {

            assetRecordList = SvmxDatabase.query([SELECT Id, Name, AccountId, Product2Id , ProductFamily, LocationId FROM Asset WHERE Id IN :assetIds]);

        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAssetRecords() : Failed to fetch Asset records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetRecords() - exit; assetRecordList= ' + assetRecordList);
        }

        return assetRecordList;
    }

    /**
     * Static method to fetch assets for source record and contract plan
     */
    public static List<Asset> getAssetRecords( final Id sourceRecordId, final Id locationId, final Scon.ServiceContractPlan serviceContractPlan,
                                         final Boolean evaluateForChildAssets) {

        final Set<String> keySet = new Set<String>();
        List<Asset> assetRecordList = new List<Asset>();

        try {

            for( Scon.ContractLineItemPlan contractLineDefinition : serviceContractPlan.contractLineItemPlans ) {

                final String key = contractLineDefinition.productId != null ? contractLineDefinition.productId : contractLineDefinition.productFamily;
                keySet.add( key );
            }

            String query = 'SELECT Id, Name, AccountId, Product2Id , ProductFamily, LocationId FROM Asset WHERE ';
            String productFilter = '( Product2Id IN :keySet OR ProductFamily IN :keySet ) AND ';
            query += evaluateForChildAssets ? '' : productFilter;

            if (locationId != null) {
                assetRecordList = SvmxDatabase.query(Database.query(query + 'LocationId = :locationId'));
            } else if (evaluateForChildAssets) {
                assetRecordList = getFilterAssetRecordsList(query, productFilter, sourceRecordId, keySet );
            } else {
                assetRecordList = SvmxDatabase.query(Database.query(query + '(AccountId = :sourceRecordId OR Id = :sourceRecordId)'));
            }

        } 
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getAssetRecords() : Failed to fetch Asset records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAssetRecords() : Failed to fetch Asset records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetRecords() - exit; assetRecordList= ' + assetRecordList);
        }

        return assetRecordList;
    }

    /**
     * Static method to to filter assets based on matching product
     */
    private static List<Asset> getFilterAssetRecordsList(String query, String productFilter, String sourceRecordId, Set<String> keySet) {
        System.debug( LoggingLevel.DEBUG, 'getFilterAssetRecordsList() - enter; query= ' + query + ' keySet=' + keySet);

        List<Asset> assetList = new List<Asset>();
        //Check if the Asset is Root Asset
        if( isRootAsset(sourceRecordId) ) {
            return SvmxDatabase.query(
                Database.query ( query + productFilter + ' RootAssetId = :sourceRecordId'));
        }

        List<Asset> filterAssetList = new List<Asset>();
        for (Asset asset : getNestedAssetList(query, new Set<Id> {sourceRecordId}, new List<Asset>() )) {
            if ( keySet.contains(asset.Product2Id) ||  keySet.contains(asset.ProductFamily) ) {
                filterAssetList.add(asset);
            }
        }

        System.debug( LoggingLevel.DEBUG, 'getFilterAssetRecordsList() - exit; filterAssetList= ' + filterAssetList);
        return filterAssetList;
    }

    /**
     * Static method to find the root asset
     */
    private static Boolean isRootAsset(Id sourceRecordId) {
        System.debug( LoggingLevel.DEBUG, 'isRootAsset() - enter; sourceRecordId= ' + sourceRecordId );

        List<Asset> assetList = SvmxDatabase.query( 
            Database.query ('SELECT Id, RootAssetId FROM Asset '+
            'WHERE Id =: sourceRecordId AND RootAssetId =:sourceRecordId AND ParentId = NULL'));
        return !assetList.isEmpty();
    }

    /**
     * Static method to fetch the nested assets
     */
    private static List<Asset> getNestedAssetList(String query, Set<Id> assetIdSet, List<Asset> finalAssetList) {
        System.debug( LoggingLevel.DEBUG, 'getNestedAssetList() - enter; query= ' + query + ' assetIdSet=' + assetIdSet);
        List<Asset> assetList;

        try {
            assetList = SvmxDatabase.query( Database.query ( query + '(' +
                + 'Id NOT IN :finalAssetList AND ( Id = :assetIdSet ' +
                + 'OR ParentId IN :assetIdSet ' +
                + 'OR Parent.ParentId IN :assetIdSet ' +
                + 'OR Parent.Parent.ParentId IN :assetIdSet ' +
                + 'OR Parent.Parent.Parent.ParentId IN :assetIdSet ' +
                + 'OR Parent.Parent.Parent.Parent.ParentId IN :assetIdSet ' +
                + 'OR Parent.Parent.Parent.Parent.Parent.ParentId IN :assetIdSet))'));

            if ( assetList.isEmpty() ) {
                return finalAssetList;
            }
            
            for (Asset asset : assetList) {
                assetIdSet.add(asset.Id);
            }

            finalAssetList.addAll(assetList);
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getNestedAssetList() : Failed to fetch nested Asset records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getNestedAssetList() : Failed to fetch nested Asset records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getNestedAssetList() - exit; assetList= ' + assetList);
        }

        return getNestedAssetList(query, assetIdSet, finalAssetList);
    }

    /**
     * Static method to publish platform events for delete
     */
    public static SVMXA360__SCONAuthoringLog__c publishDeletePlatformEvents( ServiceContract serviceContractRecord) {

        System.debug( LoggingLevel.DEBUG, 'publishDeletePlatformEvents() - enter' );

        SVMXA360__SCONAuthoringLog__c parentLogRecord = new SVMXA360__SCONAuthoringLog__c();

        try {

            if( serviceContractRecord == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            Id userId = UserInfo.getUserId();

            parentLogRecord.SVMXA360__ServiceContractId__c = serviceContractRecord.Id;
            parentLogRecord.SVMXA360__OperationType__c = 'Delete';
            parentLogRecord.SVMXA360__LogType__c = 'Master';
            parentLogRecord.SVMXA360__UserId__c = userId;
            parentLogRecord.SVMXA360__TotalBatchesCompleted__c = 0;

            parentLogRecord.SVMXA360__TotalNumberOfBatches__c = calculateBatchSize( serviceContractRecord );
            parentLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( parentLogRecord );

            List<SVMXA360__ApplicationEventBus__e> platformEvents = buildPlatformEvents( serviceContractRecord, parentLogRecord, userId );
            
            if ( !platformEvents.isEmpty() ) {

                List<Database.SaveResult> saveResultList = EventBus.publish(platformEvents);

                for( Database.SaveResult saveResult : saveResultList ) {

                    if( saveResult.isSuccess() ) {

                        System.debug( LoggingLevel.DEBUG, 'Successfully published delete platform event.' );
                    } else {
                        for( Database.Error error : saveResult.getErrors() ) {
                            System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + error.getStatusCode() + ' - ' + error.getMessage() );
                        }
                    }
                }
            }
        
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'publishDeletePlatformEvents() : Failed to publish delete platform events. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'publishDeletePlatformEvents() : Failed to publish delete platform events. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'publishDeletePlatformEvents() - exit; parentLogRecord = ' + parentLogRecord);
        }

        return parentLogRecord;
    }

    private static Integer calculateBatchSize( ServiceContract serviceContractRecord ) {

        Integer totalBatches = 0;

        if ( !serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r.isEmpty() ) {
            totalBatches = totalBatches + Integer.valueOf((serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r.size()/2000.0).round(System.RoundingMode.CEILING));
        }

        if ( !serviceContractRecord.Entitlements.isEmpty() ) {
            totalBatches = totalBatches + Integer.valueOf((serviceContractRecord.Entitlements.size()/2000.0).round(System.RoundingMode.CEILING));
        }

        if ( !serviceContractRecord.ContractLineItems.isEmpty() ) {
            totalBatches = totalBatches + Integer.valueOf((serviceContractRecord.ContractLineItems.size()/2000.0).round(System.RoundingMode.CEILING));
        }

        return totalBatches;
    }

    private static List<SVMXA360__ApplicationEventBus__e> buildPlatformEvents ( ServiceContract serviceContractRecord, 
                                                                                SVMXA360__SCONAuthoringLog__c parentLogRecord, Id userId) {

        List<Id> recordIds = new List<Id>();
        List<SVMXA360__ApplicationEventBus__e> platformEvents = new List<SVMXA360__ApplicationEventBus__e>();

        if ( !serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r.isEmpty() ) {

            for ( SVMXA360__ContractPriceLineItem__c contractPriceLineItemRecord : serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r ) {

                recordIds.add(contractPriceLineItemRecord.Id);

                if ( recordIds.size() == 2000 ) {
                    platformEvents.add( buildPlatformEvent ( recordIds, serviceContractRecord, userId, parentLogRecord));
                    recordIds.clear();
                }
            }
            
            if ( !recordIds.isEmpty() ){
                platformEvents.add( buildPlatformEvent ( recordIds, serviceContractRecord, userId, parentLogRecord));
            }
        }

        if ( !serviceContractRecord.Entitlements.isEmpty() ) {

            recordIds = new List<Id>();

            for ( Entitlement entitlementRecord : serviceContractRecord.Entitlements ) {

                recordIds.add(entitlementRecord.Id);

                if ( recordIds.size() == 2000 ) {
                    platformEvents.add( buildPlatformEvent ( recordIds, serviceContractRecord, userId, parentLogRecord));
                    recordIds.clear();
                }
            }
            
            if ( !recordIds.isEmpty() ){
                platformEvents.add( buildPlatformEvent ( recordIds, serviceContractRecord, userId, parentLogRecord));
            }
        }

        if ( !serviceContractRecord.ContractLineItems.isEmpty() ) {

            recordIds = new List<Id>();

            for ( ContractLineItem cliRecord : serviceContractRecord.ContractLineItems ) {

                recordIds.add(cliRecord.Id);

                if ( recordIds.size() == 2000 ) {
                    platformEvents.add( buildPlatformEvent ( recordIds, serviceContractRecord, userId, parentLogRecord));
                    recordIds.clear();
                }
            }
            
            if ( !recordIds.isEmpty() ){
                platformEvents.add( buildPlatformEvent ( recordIds, serviceContractRecord, userId, parentLogRecord));
            }
        }

        return platformEvents;
    }

    /**
     * Static method to validate entitled service data for CPQ
     */
    public static void validateEntitledServiceData (EntitledServiceData entitledServiceData) {
        System.debug( LoggingLevel.DEBUG, 'validateEntitledServiceData() - enter; entitledServiceData= ' + entitledServiceData );
        // Get instance of COMM_DescribeManager
        final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
        Map<String, Schema.SObjectField> sObjectFieldResultMap;        
        try {

            if (entitledServiceData == null) {
                System.debug(LoggingLevel.ERROR, 'createEntitledServices Invalid request, entitledServiceData: '+ entitledServiceData );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
            if( String.isBlank(entitledServiceData.entitledServiceName) || entitledServiceData.serviceProductId == null 
              || String.isBlank(entitledServiceData.serviceContractId) || String.isBlank(entitledServiceData.serviceUnit) || String.isBlank(entitledServiceData.serviceQty) ) {

                System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Invalid request parameters. entitledServiceData= ' + entitledServiceData );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            if (String.isNotBlank(entitledServiceData.subscriptionFieldName) || String.isNotBlank(entitledServiceData.subscribedAssetFieldName)) {
                //Get the map of fields for Service Contract Object
                sObjectFieldResultMap = describeManager.getObjectFieldMap( 'Entitlement' );

                // Check if the field is valid
                if(String.isNotBlank(entitledServiceData.subscriptionFieldName) && !sObjectFieldResultMap.ContainsKey(entitledServiceData.subscriptionFieldName) ){
                    System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Invalid fields on Entitlement object' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS + entitledServiceData.subscriptionFieldName);
                }
                if(String.isNotBlank(entitledServiceData.subscribedAssetFieldName) && !sObjectFieldResultMap.ContainsKey(entitledServiceData.subscribedAssetFieldName)){
                    System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Invalid fields on Entitlement object' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS +entitledServiceData.subscribedAssetFieldName );
                }
            }
            
            System.debug( LoggingLevel.INFO, 'validateEntitledServiceData() :  entitledServiceData= ' + entitledServiceData );

        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateEntitledServiceData() - exit; entitledServiceData='+entitledServiceData);
        }
    }
    /**
     * Static method to retrieve existing entitled service records for given service contract or contract line item.
     */
    public static List<Entitlement> getEntitledServiceRecords (EntitledServiceData entitledServiceData) {

        List<Entitlement> entitledServiceRecords = new List<Entitlement>();

        try{

            Id recordTypeId =
                Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(COMM_Constants.RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();

            entitledServiceRecords = SvmxDatabase.query( [Select Id, ServiceContractId, ContractLineItemId, SVMXA360__EntitledServiceProductId__c, SVMXA360__TotalServiceAmount__c, SVMXA360__TotalServiceCount__c, SVMXA360__ServiceCountType__c from Entitlement Where ServiceContractId =: entitledServiceData.serviceContractId AND ContractLineItemId =: entitledServiceData.contractLineItemId AND SVMXA360__EntitledServiceProductId__c =:entitledServiceData.serviceProductId AND RecordTypeId =:recordTypeId] );
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getEntitledServiceRecords() : Failed to get entitledServiceRecords. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getEntitledServiceRecords() : Failed to get entitledServiceRecords. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceRecords() - exit; entitledServiceRecords= ' + entitledServiceRecords);
        }

        return entitledServiceRecords;
    }

    public static Scon.ServiceContractPlanRequest buildSconRequest (ServiceContractData serviceContractData, SVMXA360__ServiceContractPlan__c serviceContractPlanRecord) {

        System.debug( LoggingLevel.DEBUG, 'buildSconRequest() - enter; serviceContractData= ' + serviceContractData + '; serviceContractPlanRecord= ' + serviceContractPlanRecord);

        Scon.ServiceContractPlanRequest sconRequest = new Scon.ServiceContractPlanRequest();

        sconRequest.sourceRecordId = serviceContractData.accountId;
        sconRequest.serviceContractStartDate = serviceContractData.startDate;
        sconRequest.serviceContractName = serviceContractData.serviceContractName;
        sconRequest.serviceContractDescription = serviceContractData.description;
        sconRequest.serviceContractPlanId = serviceContractPlanRecord.Id;
        sconRequest.serviceContractEndDate = serviceContractData.endDate;
        sconRequest.pricebookId = serviceContractData.pricebookId;
        sconRequest.salesContractId = serviceContractData.salesContractId;
        sconRequest.salesContractIdFieldName = serviceContractData.salesContractIdFieldName;
        sconRequest.evaluateForChildAssets = false;
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = null;

        return sconRequest;
    }

    public static Entitlement buildEntitlementRecord (EntitledServiceData entitledServiceData, ServiceContract serviceContractRecord,
                                                ContractLineItem contractLineItemRecord) {
        System.debug( LoggingLevel.Info, 'buildEntitlementRecord() - enter; serviceContractRecord= ' + serviceContractRecord);
        System.debug( LoggingLevel.Info, 'buildEntitlementRecord() - enter; contractLineItemRecord= ' + contractLineItemRecord);

        final Entitlement entitledServiceRecord = new Entitlement();

        try {
            entitledServiceRecord.RecordTypeId =
                Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(COMM_Constants.RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();

            entitledServiceRecord.ServiceContractId = serviceContractRecord.Id;
            entitledServiceRecord.Name = entitledServiceData.entitledServiceName;
            entitledServiceRecord.AccountId = serviceContractRecord.AccountId;
            if ( contractLineItemRecord != null ) {
                entitledServiceRecord.ContractLineItemId = contractLineItemRecord.Id;
                entitledServiceRecord.AssetId = contractLineItemRecord.AssetId;
            }

            if (entitledServiceData.startDate !=null) {
                entitledServiceRecord.StartDate = entitledServiceData.startDate;
            } else {
                entitledServiceRecord.StartDate = (contractLineItemRecord != null && contractLineItemRecord.StartDate != null) ? contractLineItemRecord.StartDate :  serviceContractRecord.StartDate;
            }

            if (entitledServiceData.endDate !=null) {
                entitledServiceRecord.EndDate = entitledServiceData.endDate;
            } else {
                entitledServiceRecord.EndDate = (contractLineItemRecord != null && contractLineItemRecord.EndDate != null) ? contractLineItemRecord.EndDate :  serviceContractRecord.EndDate;
            }
            
            entitledServiceRecord.SVMXA360__EntitledServiceProductId__c = entitledServiceData.serviceProductId;

            entitledServiceRecord.SVMXA360__ServiceCountType__c = entitledServiceData.serviceUnit;
            if( entitledServiceData.serviceUnit != null ) {
                if( entitledServiceData.serviceUnit.equalsIgnoreCase(SCON_ServiceContractPlanManager.StringAmount) ) {
                    entitledServiceRecord.SVMXA360__TotalServiceAmount__c = String.isNotBlank(entitledServiceData.serviceQty) ? Integer.valueOf( entitledServiceData.serviceQty ) : null;
                    entitledServiceRecord.SVMXA360__ServiceAmountAlertThreshold__c = String.isNotBlank(entitledServiceData.thresholdAlert) ? Integer.valueOf( entitledServiceData.thresholdAlert ) : null;
                } else {
                    entitledServiceRecord.SVMXA360__TotalServiceCount__c = String.isNotBlank(entitledServiceData.serviceQty) ? Integer.valueOf( entitledServiceData.serviceQty ) : null;
                    entitledServiceRecord.SVMXA360__ServiceCountAlertThreshold__c = String.isNotBlank(entitledServiceData.thresholdAlert) ? Integer.valueOf( entitledServiceData.thresholdAlert ) : null;
                }
            }
            entitledServiceRecord.SVMXA360__CaseEntitlementProcessId__c  = entitledServiceData.caseEntitlementProcess;
            entitledServiceRecord.SVMXA360__WorkOrderEntitlementProcessId__c  = entitledServiceData.workOrderEntitlementProcess;

            if (String.isNotBlank(entitledServiceData.subscriptionFieldName)) {
                entitledServiceRecord.put(entitledServiceData.subscriptionFieldName, entitledServiceData.subscriptionId );
            }
            if (String.isNotBlank(entitledServiceData.subscribedAssetFieldName)) {
                entitledServiceRecord.put(entitledServiceData.subscribedAssetFieldName, entitledServiceData.subscribedAssetId );
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'buildEntitlementRecord() : Failed to build entitled service record Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildEntitlementRecord() - exit; entitledServiceRecord='+entitledServiceRecord);
        }

        return entitledServiceRecord;
    }

    public static List<Scon.OfferedMaintenancePlanTemplate> getOfferedMaintenancePlanTemplates (Set<Id> serviceContractPlanIdSet, Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap) {
        System.debug( LoggingLevel.Info, 'getOfferedMaintenancePlanTemplates() - enter; serviceContractPlanIdSet= ' + serviceContractPlanIdSet);

        List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = new List<Scon.OfferedMaintenancePlanTemplate>();

        try {

            List<Scon.ServiceContractPlan> serviceContractPlanList = new List<Scon.ServiceContractPlan>();

            for(Id eachSCONPlanId : serviceContractPlanIdSet) {                
                serviceContractPlanList.add( serviceContractPlanMap.get( eachSCONPlanId ));
            }
            
            if (serviceContractPlanList != null && !serviceContractPlanList.isEmpty() ) {

                for(Scon.ServiceContractPlan eachSconPlan : serviceContractPlanList) {

                    if( eachSconPlan.offeredMaintenancePlanTemplates != null && !eachSconPlan.offeredMaintenancePlanTemplates.isEmpty() ) {
                        offeredMPTList.addAll(eachSconPlan.offeredMaintenancePlanTemplates);
                    }
                }
            }            
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getOfferedMaintenancePlanTemplates() : Failed to get offeredMPTList Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getOfferedMaintenancePlanTemplates() - exit; offeredMPTList='+offeredMPTList);
        }
        return offeredMPTList;
    }

    public static Scon.ContractLineItemResponse createContractLinesWithoutPlan (ContractLineItemData contractLineItemData, ServiceContract serviceContractRecord) {

        Scon.ContractLineItemResponse contractLineItemResponse = new Scon.ContractLineItemResponse();

        try {

            Map<Id,ContractLineAssetData> contractLineAssetDataMap = new Map<Id,ContractLineAssetData>();
            Set<Id> pricebookEntryIds = new Set<Id>();

            for ( ContractLineAssetData assetRequest : contractLineItemData.assetDataList ) {

                if ( assetRequest.pricebookEntryId == null ) {
                    throw new SvmxSystem.SvmxNestedException( String.format(
                        System.Label.Error_PriceBookEntryMissing,
                        new List<String> {
                            contractLineItemData.serviceContractId,
                            assetRequest.assetId
                        }
                    ));
                }

                pricebookEntryIds.add(assetRequest.pricebookEntryId);
                contractLineAssetDataMap.put(assetRequest.assetId, assetRequest);
            }

            contractLineItemResponse.contractLineAssetDataMap = contractLineAssetDataMap;

            List<Asset> assetRecordList = SCON_ServiceContractPlanHelper.getAssetRecords( contractLineAssetDataMap.keyset() );

            if ( assetRecordList.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_NoMatchingAssetsFound );
            }

            ContractLineAssetData contractLineAssetRequest;

            final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();

            Map<String, Schema.SObjectField> contractLineFieldResultMap = describeManager.getObjectFieldMap( 'ContractLineItem' );

            List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();

            List<PricebookEntry> pricebookEntries = SvmxDatabase.query([SELECT Id, Name, UnitPrice FROM PricebookEntry
                                                                        where Id IN :pricebookEntryIds]);
            
            Map<Id,PricebookEntry> pricebookEntryMap = new Map<Id,PricebookEntry>();

            for ( PricebookEntry pricebookEntryRecord : pricebookEntries ) {
                pricebookEntryMap.put(pricebookEntryRecord.Id,pricebookEntryRecord);
            }

            ContractLineItem contractLineItemRecord;

            for (Asset assetRecord : assetRecordList ) {

                if ( contractLineAssetDataMap != null && !contractLineAssetDataMap.isEmpty() && contractLineAssetDataMap.containsKey(assetRecord.Id) ) {
                    contractLineAssetRequest = contractLineAssetDataMap.get(assetRecord.Id);
                }

                contractLineItemRecord = buildContractLineItem( assetRecord, null, serviceContractRecord, contractLineAssetRequest, contractLineFieldResultMap );

                contractLineItemRecord.PricebookEntryId = pricebookEntryMap.get(contractLineAssetRequest.pricebookEntryId).Id;
                contractLineItemRecord.UnitPrice = pricebookEntryMap.get(contractLineAssetRequest.pricebookEntryId).UnitPrice;

                contractLineItemList.add( contractLineItemRecord );
            }

            contractLineItemResponse.contractLineItemList = contractLineItemList;
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLinesWithoutPlan() : Failed to create CLIs. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLinesWithoutPlan() : Failed to create CLIs. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLinesWithoutPlan() - exit; contractLineItemResponse= ' + contractLineItemResponse);
        }

        return contractLineItemResponse;
    }

    public static ContractLineItem buildContractLineItem( final Asset assetRecord, final Scon.ContractLineItemPlan contractLineItemPlan, ServiceContract serviceContractRecord, ContractLineAssetData contractLineAssetRequest, Map<String, Schema.SObjectField> contractLineFieldResultMap ) {

        final ContractLineItem contractLineItemRecord = new ContractLineItem();

        contractLineItemRecord.AssetId = assetRecord.Id;
        contractLineItemRecord.ServiceContractId = serviceContractRecord.Id;
        contractLineItemRecord.StartDate = serviceContractRecord.StartDate;

        if( contractLineItemPlan!= null && contractLineItemPlan.duration != null && contractLineItemPlan.unitOfTime != null ) {
            contractLineItemRecord.EndDate = COMM_DateLiteralUtils.calculateEndDate( serviceContractRecord.StartDate, contractLineItemPlan.duration, contractLineItemPlan.unitOfTime );
        } else {
            contractLineItemRecord.EndDate = serviceContractRecord.EndDate;
        }

        if( contractLineItemPlan!= null && contractLineItemPlan.discount != null) {
            contractLineItemRecord.Discount = contractLineItemPlan.discount;
        }

        contractLineItemRecord.Quantity = 1;

        if ( contractLineAssetRequest != null ) {

            if ( contractLineAssetRequest.startDate != null ) {
                contractLineItemRecord.StartDate = contractLineAssetRequest.startDate;
            }

            if ( contractLineAssetRequest.endDate != null ) {
                contractLineItemRecord.EndDate = contractLineAssetRequest.endDate;
            }

            populateSubscriptionFields( contractLineItemRecord, contractLineAssetRequest, contractLineFieldResultMap );
        }
        
        return contractLineItemRecord;
    }

    private static void populateSubscriptionFields ( ContractLineItem contractLineItemRecord, ContractLineAssetData contractLineAssetRequest, Map<String, Schema.SObjectField> contractLineFieldResultMap ) {
        
        if ( String.isNotBlank(contractLineAssetRequest.subscriptionFieldName) ||  
             String.isNotBlank(contractLineAssetRequest.subscribedAssetFieldName)) {
            //Get the map of fields for Contract Line Item Object

            if( String.isNotBlank(contractLineAssetRequest.subscriptionFieldName) ) {
                    
                if (!contractLineFieldResultMap.ContainsKey(contractLineAssetRequest.subscriptionFieldName)){
                    System.debug( LoggingLevel.ERROR, 'buildContractLineItem() : Invalid field on Contract Line Item' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                }

                contractLineItemRecord.put(contractLineAssetRequest.subscriptionFieldName, contractLineAssetRequest.subscriptionId );
            }

            if( String.isNotBlank(contractLineAssetRequest.subscribedAssetFieldName) ) {
                    
                if (!contractLineFieldResultMap.ContainsKey(contractLineAssetRequest.subscribedAssetFieldName)){
                    System.debug( LoggingLevel.ERROR, 'buildContractLineItem() : Invalid field on Contract Line Item' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                }

                contractLineItemRecord.put(contractLineAssetRequest.subscribedAssetFieldName, contractLineAssetRequest.subscribedAssetId );
            }
        }

    }

    public static Scon.ContractLineItemPlan evaluateQualifyingPlan (Scon.ServiceContractPlan serviceContractPlan, String servicePlanProductId) {
        
        Scon.ContractLineItemPlan qualifyingContractLineDefinition = new Scon.ContractLineItemPlan();
        if ( serviceContractPlan?.contractLineItemPlans != null && serviceContractPlan.contractLineItemPlans.size() > 0 ) {
            for( Scon.ContractLineItemPlan cliPlan : serviceContractPlan.contractLineItemPlans ) {

                if (servicePlanProductId == cliPlan.productId) {
                    qualifyingContractLineDefinition = cliPlan;
                    break;
                }
            }
        }

        return qualifyingContractLineDefinition;
    }

}