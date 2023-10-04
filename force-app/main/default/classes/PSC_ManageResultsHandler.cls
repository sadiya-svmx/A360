/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods with actual implementation which will be
 * comsumed by the class PSC_ManageResults_LS.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          28 Dec 2020     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class PSC_ManageResultsHandler {

    private static final List<String> BATCH_STATUS_LIST = new List<String> {'Holding', 'Queued', 'Preparing', 'Processing'};
    // public static final String WO_OBJ_PREFIX = COMM_DescribeManager.getInstance().getObjectDescribe('WorkOrder').getKeyPrefix();
    private static final String RO_OBJ_PREFIX = COMM_DescribeManager.getInstance().getObjectDescribe('ReturnOrder').getKeyPrefix();
    private static final String OPPORTUNITY_OBJ_PREFIX = COMM_DescribeManager.getInstance().getObjectDescribe('Opportunity').getKeyPrefix();
    // public static List<SVMXA360__PSCRequiredParts__c> pscRequiredParts = new List<SVMXA360__PSCRequiredParts__c>();
    private static final String PROSPECTING_VALUE = 'Prospecting';
    private static final String ASSET_NOTIFICATION_STATUS_VALUE = 'Draft';
    private static final String ASSET_NOTIFICATION_SEVERITY_VALUE = 'Moderate';
    public static Map<String,List<SObject>> sourceRecIdTargetObjOpntyLineItemMap = new Map<String,List<SObject>>();
    public static Map<String, Double> productIdListPrice = new Map<String, Double>();
    public static Boolean isPriceBookActiveForOppnty = true;

    private final static List<String> assetSearchFields = new List<String>{
        'Name', 'Account.Name', 'SerialNumber', 'toLabel(Status)', 'Location.Name'
    };
    /**
     * This method is used to retrieve current status of the Manage Results card component for the requested PSC record.
     * 
     * @param pscRecordId Record Id of the PSC record for which the current status needs to be fetched.
     * 
     * @return Returns instance of Psc.ResultLineStatus with status and other data.
     */
    public Psc.ResultLineStatus getResultLineStatus(final String pscRecordId) {

        System.debug( LoggingLevel.DEBUG, 'getResultLineStatus() - enter; pscRecordId= ' + pscRecordId );
        
        Psc.ResultLineStatus response = new Psc.ResultLineStatus();
        
        try {
            if(String.isBlank(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'getResultLineStatus() : Invalid request parameters. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            if (isGenerateOutputBatchRunning(pscRecordId)) {
                response.isBatchRunning = true;

                //Query log record which is latest and has running batch id
                List<SVMXA360__PSCEngineLog__c> engineLogList = SvmxDatabase.query([SELECT Id, SVMXA360__BatchId__c FROM SVMXA360__PSCEngineLog__c WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId AND SVMXA360__LogType__c = 'OutputGeneration' AND SVMXA360__BatchId__c != null ORDER BY CreatedDate DESC LIMIT 1]);
                if (!engineLogList.isEmpty()) {
                    String engineLogRecordId = engineLogList[0].Id;
                    response.linesDelivered = Database.countQuery('SELECT Count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId AND Status = \'OutputGenerated\' AND SVMXA360__PSCEngineLogId__c =: engineLogRecordId AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != \'NoDelivery\' WITH SECURITY_ENFORCED');
                    response.totalLinesForDelivery = Database.countQuery('SELECT Count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != \'NoDelivery\' AND ((Status = \'OutputGenerated\' AND SVMXA360__PSCEngineLogId__c =: engineLogRecordId) OR (Status = \'Draft\' AND SVMXA360__PSCEngineLogId__c = null)) WITH SECURITY_ENFORCED');
                }
            } else {
                response.isBatchRunning = false;
                response.linesGenerated = getLinesGeneratedCount(pscRecordId);
                response.linesDelivered = getLinesDeliveredCount(pscRecordId);

                Map<String, Integer> objectWithRecordCreatedCount = getItemsDeliveredCount(pscRecordId);
                response.casesDelivered = objectWithRecordCreatedCount.get('Case');
                response.workOrderDelivered = objectWithRecordCreatedCount.get('WorkOrder');
                response.returnOrderDelivered = objectWithRecordCreatedCount.get('ReturnOrder');
                response.opportunityDelivered = objectWithRecordCreatedCount.get('Opportunity');
                response.assetNotificationDelivered = objectWithRecordCreatedCount.get('AssetNotification');
            }
        }
        catch(SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'getResultLineStatus() : Failed to retrieve ResultLineStatus status. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getResultLineStatus() : Failed to retrieve the ResultLineStatus status. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getResultLineStatus() - exit; response= ' + response);
        }
        
        return response;
    }

    /**
     * This method is used to retrieve Result line records for Manage Result Line component for the requested PSC record.
     * 
     * @param request Record Id of the PSC record and list of Field API names for which the Result Lines needs to be fetched.
     * 
     * @return Returns instance of List<Map<String, Object>> with Result Lines.
     */
    public List<Map<String, Object>> getResultLines(final Psc.ResultLineRequest request) {

        System.debug(LoggingLevel.DEBUG, 'getResultLines() - enter; request= ' + request );
        
        List<Map<String, Object>> recordList = new List<Map<String, Object>>();
        
        try {
            if(request == null || String.isBlank(request.id) || request.fieldApiNames == null || request.fieldApiNames.size() == 0) {
                System.debug(LoggingLevel.ERROR, 'getResultLines() : Invalid request parameters. request= ' + request);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            String queryFieldString = String.join(request.fieldApiNames, ',');
            List<SObject> psciRecords = getPsciRecords(String.escapeSingleQuotes(request.id), queryFieldString, null);

            for (SObject record : psciRecords) {
                Map<String, Object> recordInMap = new Map<String, Object>();
                for (String field: request.fieldApiNames) {
                    if (field != null) {
                        recordInMap.put(field, SvmxDatabase.getFieldValue(record, field));
                    }
                }
                recordList.add(recordInMap);
            }
        }
        catch(SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'getResultLines() : Failed to retrieve ResultLines. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getResultLines() : Failed to retrieve ResultLines. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getResultLines() - exit; recordList= ' + recordList);
        }
        
        return recordList;
    }

    /**
     * This method is used to retrieve Add Asset Modal columns for Manage Result Line component.
     * 
     * @return Returns instance of List<ColumnInformation> with Add Asset Modal Columns.
     */
    public List<Psc.ColumnInformation> getAddAssetColumns() {

        System.debug( LoggingLevel.DEBUG, 'getAddAssetColumns() - enter' );
        
        List<Psc.ColumnInformation> columnInformations = new List<Psc.ColumnInformation>();
        
        try {
            columnInformations = getColumnInfoForAddAsset();
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getAddAssetColumns() : Failed to retrieve AddAssetColumns. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getAddAssetColumns() - exit; columnInformations= ' + columnInformations);
        }
        
        return columnInformations;
    }

    /**
     * This method is used to retrieve Asset records for Manage Result Line component in the modal.
     * 
     * @param SearchAssetRequest contains Product id and search keyword for fetching Asset records.
     * 
     * @return Returns List<Asset> as all the asset records.
     */
    public List<Asset> getAssetRecords(final Psc.SearchAssetRequest request) {
        System.debug(LoggingLevel.DEBUG, 'PSC_ManageResultsHandler-getAssetRecords() - enter; request= ' + request);
        List<Asset> assetRecordList = new List<Asset>();

        try {
            if(String.isBlank(request.id) || String.isBlank(request.searchKeyword)) {
                System.debug(LoggingLevel.ERROR, 'getAssetRecords() : Invalid request parameters. request= ' + request);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }

            String recQueryStr;

            String productId = String.escapeSingleQuotes(request.id);
            System.debug(LoggingLevel.INFO, 'getAssetRecords() :productId Id= :'+productId);

            recQueryStr = 'SELECT Id, Name, AccountId, Account.Name, SerialNumber, toLabel(Status), LocationId, Location.Name, CreatedDate FROM Asset';

            //where clause for parent objects- ServiceContract,ContractLineItem and Entitlement
            String whereClause =' WHERE Product2Id =\''+productId+'\'';

            String searchKey =  '%'+String.escapeSingleQuotes(request.searchKeyword)+'%';
            whereClause+= ' AND ( ';
            for (Integer index=0; index<assetSearchFields.size(); index++) {
                whereClause+= assetSearchFields[index]+' Like \''+searchKey+'\'';
                if(index != assetSearchFields.size()-1) {
                    whereClause+=' OR ';
                }
            }
            whereClause+= ' )';
            recQueryStr += whereClause + ' ORDER BY Name ASC';
            System.debug(LoggingLevel.INFO, 'getAssetRecords() :query for RecordList is :'+recQueryStr);

            assetRecordList = SvmxDatabase.query(recQueryStr);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getAssetRecords() : Failed to retrieve Asset Records. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getAssetRecords() - exit; assetRecordList.size()= ' + assetRecordList.size());
        }
        return assetRecordList;
    }

    /**
     * This method is used to insert/update ProductServiceCampaignItem records.
     * 
     * @param psciRecordList ProductServiceCampaignItem record list which needs to be inserted or updated.
     * 
     * @return nothing
     */
    public void insertUpdatePsciRecords(final List<ProductServiceCampaignItem> psciRecordList) {
        System.debug(LoggingLevel.DEBUG, 'insertUpdatePsciRecords() - enter; psciRecordList= ' + psciRecordList);

        try{
            if(psciRecordList == null || psciRecordList.isEmpty()) {
                System.debug(LoggingLevel.ERROR, 'insertUpdatePsciRecords() : Invalid request parameters. psciRecordList= ' + psciRecordList);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            SvmxDatabase.upsertRecord(psciRecordList);
        }
        catch(SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'insertUpdatePsciRecords() : Failed to insert/update ProductServiceCampaignItem records. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'insertUpdatePsciRecords() : Failed to insert/update ProductServiceCampaignItem records. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'insertUpdatePsciRecords() - exit;');
        }
    }

    /**
     * This method is used to initiate PSC_GenerateOutputBatch batch for the requested PSC record.
     * 
     * @param pscRecordId record id of the PSC record for which PSC_GenerateOutputBatch batch needs to be initiated.
     * 
     * @return Returns nothing if execution is successfull.
     * Otherwise throws exception if execution fails.
     */
    public void initiateGenerateOutputBatch(final String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'initiateGenerateOutputBatch() - enter; pscRecordId= ' + pscRecordId);

        try{
            if(String.isBlank(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'initiateGenerateOutputBatch() : Invalid request parameters. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            if(isPscHasInactiveOrMissingPscConfiguration(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'initiateGenerateOutputBatch() : Either Psc Configuration is missing or associated Psc Configuration is Inactive. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.PSC_CONF_MISSING_INACTIVE);
            }

            if(isGenerateOutputBatchRunning(pscRecordId)){
                System.debug(LoggingLevel.ERROR, 'initiateGenerateOutputBatch() : Batch is already running. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.BATCH_IN_PROGRESS + ' ' + pscRecordId);
            }

            //Initiate the batch
            PSC_GenerateOutputBatch generateOutputBatch = new PSC_GenerateOutputBatch();
            generateOutputBatch.pscRecordId = pscRecordId;
            Integer batchSize = getBatchSizeForGenerateOutput();
            Id batchId = Database.executeBatch(generateOutputBatch, batchSize);

            //Create PSC engine log record
            SVMXA360__PSCEngineLog__c pscEngineLog = new SVMXA360__PSCEngineLog__c();
            pscEngineLog.SVMXA360__ProductServiceCampaignId__c = pscRecordId;
            pscEngineLog.SVMXA360__BatchId__c = batchId;
            pscEngineLog.SVMXA360__LogType__c = 'OutputGeneration';
            SvmxDatabase.insertRecord(pscEngineLog);
        }
        catch(SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'initiateGenerateOutputBatch() : Failed to initiate PSC_GenerateOutputBatch batch. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'initiateGenerateOutputBatch() : Failed to initiate PSC_GenerateOutputBatch batch. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'initiateGenerateOutputBatch() - exit;');
        }
    }

    public Boolean isPscHasInactiveOrMissingPscConfiguration(String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'isPscHasInactiveOrMissingPscConfiguration() - enter; pscRecordId= ' + pscRecordId);

        Boolean configurationIsMissingOrInactive = true;

        List<ProductServiceCampaign> pscRecordList = SvmxDatabase.query([SELECT SVMXA360__PSCConfigurationId__c, SVMXA360__PSCConfigurationId__r.SVMXA360__Active__c FROM ProductServiceCampaign WHERE Id =: pscRecordId]);
        if (pscRecordList != null && pscRecordList.size() > 0 && String.isNotBlank(pscRecordList[0].SVMXA360__PSCConfigurationId__c) && pscRecordList[0].SVMXA360__PSCConfigurationId__r.SVMXA360__Active__c) {
            configurationIsMissingOrInactive = false;
        }

        System.debug(LoggingLevel.DEBUG, 'isPscHasInactiveOrMissingPscConfiguration() - exit; configurationIsMissingOrInactive= ' + configurationIsMissingOrInactive);

        return configurationIsMissingOrInactive;
    }

    public Boolean isGenerateOutputBatchRunning(String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'isGenerateOutputBatchRunning() - enter; pscRecordId= ' + pscRecordId);

        if(String.isBlank(pscRecordId)) {
            System.debug(LoggingLevel.ERROR, 'isGenerateOutputBatchRunning() : Invalid parameter. pscRecordId= ' + pscRecordId);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        List<String> batchIdList = new List<String>();

        // collect all the batches related to PSC
        List<SVMXA360__PSCEngineLog__c> engineLogList = SvmxDatabase.query([SELECT SVMXA360__BatchId__c FROM SVMXA360__PSCEngineLog__c WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId AND SVMXA360__LogType__c = 'OutputGeneration' AND SVMXA360__BatchId__c != null]);
        for(SVMXA360__PSCEngineLog__c log : engineLogList){
            batchIdList.add(log.SVMXA360__BatchId__c);
        }
        return Test.isRunningTest() ? false : !batchIdList.isEmpty() && Database.countQuery('SELECT count() FROM AsyncApexJob WHERE Id IN : batchIdList AND Status IN : BATCH_STATUS_LIST WITH SECURITY_ENFORCED') > 0 ? true : false;
    }

    private Integer getBatchSizeForGenerateOutput() {
        System.debug(LoggingLevel.DEBUG, 'getBatchSizeForGenerateOutput() - enter;');
        
        Integer batchSizeForOutput = 50; //Default value

        Schema.DescribeSobjectResult describeResult = COMM_DescribeManager.getInstance().getObjectDescribe('SVMXA360__CONF_PSCConfiguration__c');
        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosByDeveloperName();
        String recordTypeIdOfSetting =  recordTypeInfoMap.get('PSC_Settings').getRecordTypeId();

        List<SVMXA360__CONF_PSCConfiguration__c> settingConfiguration = SvmxDatabase.query([SELECT SVMXA360__DeliveryBatchSize__c FROM SVMXA360__CONF_PSCConfiguration__c WHERE SVMXA360__DeveloperName__c = 'Default_PSC_Settings' AND RecordTypeId =: recordTypeIdOfSetting LIMIT 1]);
        if (settingConfiguration != null && !settingConfiguration.isEmpty() && settingConfiguration[0].SVMXA360__DeliveryBatchSize__c != null) {
            batchSizeForOutput = Integer.valueOf(settingConfiguration[0].SVMXA360__DeliveryBatchSize__c);
        }

        System.debug(LoggingLevel.DEBUG, 'getBatchSizeForGenerateOutput() - exit;');

        return batchSizeForOutput;
    }

    private List<Psc.ColumnInformation> getColumnInfoForAddAsset() {
        List<Psc.ColumnInformation> columnList = new List<Psc.ColumnInformation>();

        Map<String, Schema.SObjectField> assetDescribeMap = COMM_DescribeManager.getInstance().getObjectFieldMap('Asset');

        columnList.add(createColumnInfoForAddAsset(assetDescribeMap.get('Name'))); // Asset name
        columnList.add(createColumnInfoForAddAsset(assetDescribeMap.get('AccountId'))); // Account field
        columnList.add(createColumnInfoForAddAsset(assetDescribeMap.get('SerialNumber'))); // Serial Number field
        columnList.add(createColumnInfoForAddAsset(assetDescribeMap.get('Status'))); // Status field
        columnList.add(createColumnInfoForAddAsset(assetDescribeMap.get('LocationId'))); // Location field

        return columnList;
    }

    private Psc.ColumnInformation createColumnInfoForAddAsset(Schema.SObjectField field) {
        
        Schema.DescribeFieldResult fieldDesc = COMM_DescribeManager.getInstance().getFieldDescribe(field);

        Psc.ColumnInformation column = new Psc.ColumnInformation();

        column.label = fieldDesc.getLabel();
        column.apiName = fieldDesc.getName();
        column.dataType = String.valueOf(fieldDesc.getType());

        if (fieldDesc.getType() == Schema.DisplayType.REFERENCE) {

            column.relatedObjectName = String.valueOf(fieldDesc.getReferenceTo()[0]);

            String referenceNameField = COMM_DescribeManager.getInstance().getReferenceNameField(fieldDesc);
            column.relatedNameField = referenceNameField.split('\\.')[1];
        }

        return column;
    }

    public List<ProductServiceCampaignItem> getPsciRecords(String pscRecordId, String queryFields, String whereClause) {
        String query = 'SELECT ' + queryFields + ' FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId = \'' + String.escapeSingleQuotes(pscRecordId) + '\'';

        if(String.isNotBlank(whereClause)) {
            query = query + ' AND ' + whereClause;
        }
        return SvmxDatabase.query(query);
    }

    private Integer getLinesGeneratedCount(String pscRecordId) {

        System.debug(LoggingLevel.DEBUG, 'getLinesGeneratedCount() - enter');

        Integer lineCount = 0;

        try {
            lineCount = Database.countQuery('SELECT Count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId WITH SECURITY_ENFORCED');
        }
        catch(System.QueryException e){
            System.debug(LoggingLevel.ERROR, 'getLinesGeneratedCount() : Object/Field is not Accessible for query records. Error= ' + e.getMessage());
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.RESTRICTED_ACCESS + 'ProductServiceCampaignItem');
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getLinesGeneratedCount() : Object/Field is not Accessible for query records.');
            throw e;
        }
        return lineCount;
    }

    private Integer getLinesDeliveredCount(String pscRecordId) {

        System.debug(LoggingLevel.DEBUG, 'getLinesDeliveredCount() - enter');

        Integer lineCount = 0;

        try {
            lineCount = Database.countQuery('SELECT Count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId AND Status = \'OutputGenerated\' WITH SECURITY_ENFORCED');
        }
        catch(System.QueryException e){
            System.debug(LoggingLevel.ERROR, 'getLinesDeliveredCount() : Object/Field is not Accessible for query records. Error= ' + e.getMessage());
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.RESTRICTED_ACCESS + 'ProductServiceCampaignItem');
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getLinesDeliveredCount() : Object/Field is not Accessible for query records.');
            throw e;
        }
        return lineCount;
    }

    private Map<String, Integer> getItemsDeliveredCount(String pscRecordId) {

        Map<String, Integer> objectWithRecordCreatedCount = new Map<String, Integer>{ 
            'Case' => 0,
            'WorkOrder' => 0,
            'ReturnOrder' => 0,
            'Opportunity' => 0,
            'AssetNotification' => 0
        };

        String queryFieldString = 'SVMXA360__DeliveryMethod__c';
        String whereClause = 'Status = \'OutputGenerated\' AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != \'NoDelivery\'';
        List<ProductServiceCampaignItem> psciList = getPsciRecords(pscRecordId, queryFieldString, whereClause);
        
        for (ProductServiceCampaignItem psci : psciList) {
            if (objectWithRecordCreatedCount.containsKey(psci.SVMXA360__DeliveryMethod__c)) {
                Integer existingCount = objectWithRecordCreatedCount.get(psci.SVMXA360__DeliveryMethod__c);
                existingCount++;
                objectWithRecordCreatedCount.put(psci.SVMXA360__DeliveryMethod__c, existingCount);
            }
        }

        return objectWithRecordCreatedCount;
    }

    public static void applyMappingPscToCase(ProductServiceCampaign pscRecord, Case mappedCaseRec, Map<String, String> mappingKeyMappingIdMap, Map<String, String> placeHolderValueMap, Map<String, List<String>> defaultFieldList) {
        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToCase() - enter;');

        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();
        List<String> overridableFields = new List<String>();
        Map<String,List<SObject>> sourceRecIdTargetRecMap = new Map<String,List<SObject>>();

        sourceRecIdTargetRecMap.put(pscRecord.Id, new List<SObject>{mappedCaseRec});
        Map<String,List<SObject>> mappedRecord = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('PSC2CASE'), sourceRecIdTargetRecMap);
        if (!mappedRecord.isEmpty() && mappedRecord.containsKey(pscRecord.Id)) {
            List<Case> caseList = (List<Case>) mappedRecord.get(pscRecord.Id);
            mappedCaseRec = caseList[0];
            List<SVMXA360__CONF_ObjectMappingDetail__c> fieldMapping = SvmxDatabase.query([SELECT SVMXA360__TargetFieldAPIName__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__r.SVMXA360__DeveloperName__c =: mappingKeyMappingIdMap.get('PSC2CASE') AND SVMXA360__TargetFieldAPIName__c IN : defaultFieldList.get('Case')]);
            for(SVMXA360__CONF_ObjectMappingDetail__c configData : fieldMapping){
                overridableFields.add(configData.SVMXA360__TargetFieldAPIName__c);
            }
            Map<String, Object> fieldsToValueMap = mappedCaseRec.getPopulatedFieldsAsMap();
            if(overridableFields.contains('AssetId')){
                populatePlaceHolderValueMap('AssetId', 'assetIdForCase', fieldsToValueMap, placeHolderValueMap);
            }
            if(overridableFields.contains('ProductId')){
                populatePlaceHolderValueMap('ProductId', 'productIdForCase', fieldsToValueMap, placeHolderValueMap);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToCase() - exit;');
    }

    public static void applyMappingPscToReturnOrder(ProductServiceCampaign pscRecord, ReturnOrder mappedReturnOrderRec, Map<String, String> mappingKeyMappingIdMap, Map<String, String> placeHolderValueMap, Map<String, List<String>> defaultFieldList) {
        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToReturnOrder() - enter;');

        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();
        List<String> overridableFields = new List<String>();
        Map<String,List<SObject>> sourceRecIdTargetRecMap = new Map<String,List<SObject>>();

        sourceRecIdTargetRecMap.put(pscRecord.Id, new List<SObject>{mappedReturnOrderRec});
        Map<String,List<SObject>> mappedRecord = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('PSC2RORD'), sourceRecIdTargetRecMap);
        if (!mappedRecord.isEmpty() && mappedRecord.containsKey(pscRecord.Id)) {
            List<ReturnOrder> returnOrderList = (List<ReturnOrder>) mappedRecord.get(pscRecord.Id);
            mappedReturnOrderRec = returnOrderList[0];
            List<SVMXA360__CONF_ObjectMappingDetail__c> fieldMapping = SvmxDatabase.query([SELECT SVMXA360__TargetFieldAPIName__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__r.SVMXA360__DeveloperName__c =: mappingKeyMappingIdMap.get('PSC2RORD') AND SVMXA360__TargetFieldAPIName__c IN : defaultFieldList.get('ReturnOrder')]);
            for(SVMXA360__CONF_ObjectMappingDetail__c configData : fieldMapping){
                overridableFields.add(configData.SVMXA360__TargetFieldAPIName__c);
            }
            Map<String, Object> fieldsToValueMap = mappedReturnOrderRec.getPopulatedFieldsAsMap();
            if(overridableFields.contains('SVMXA360__AssetId__c')){
                populatePlaceHolderValueMap('SVMXA360__AssetId__c', 'assetIdForRO', fieldsToValueMap, placeHolderValueMap);
            }
            if(overridableFields.contains('SourceLocationId')){
                populatePlaceHolderValueMap('SourceLocationId', 'locationIdForRO', fieldsToValueMap, placeHolderValueMap);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToReturnOrder() - exit;');
    }

    public static void applyMappingPscToWorkOrder(ProductServiceCampaign pscRecord, WorkOrder mappedWorkOrderRec, Map<String, String> mappingKeyMappingIdMap, Map<String, String> placeHolderValueMap, Map<String, List<String>> defaultFieldList) {

        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToWorkOrder() - enter;');
        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();
        List<String> overridableFields = new List<String>();
        Map<String,List<SObject>> sourceRecIdTargetRecMap = new Map<String,List<SObject>>();

        sourceRecIdTargetRecMap.put(pscRecord.Id, new List<SObject>{mappedWorkOrderRec});
        Map<String,List<SObject>> mappedRecord = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('PSC2WORD'), sourceRecIdTargetRecMap);
        if (!mappedRecord.isEmpty() && mappedRecord.containsKey(pscRecord.Id)) {
            List<WorkOrder> workOrderList = (List<WorkOrder>) mappedRecord.get(pscRecord.Id);
            mappedWorkOrderRec = workOrderList[0];
            List<SVMXA360__CONF_ObjectMappingDetail__c> fieldMapping = SvmxDatabase.query([SELECT SVMXA360__TargetFieldAPIName__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__r.SVMXA360__DeveloperName__c =: mappingKeyMappingIdMap.get('PSC2WORD') AND SVMXA360__TargetFieldAPIName__c IN : defaultFieldList.get('WorkOrder')]);
            for(SVMXA360__CONF_ObjectMappingDetail__c configData : fieldMapping){
                overridableFields.add(configData.SVMXA360__TargetFieldAPIName__c);
            }
            Map<String, Object> fieldsToValueMap = mappedWorkOrderRec.getPopulatedFieldsAsMap();
            if(overridableFields.contains('AssetId')){
                populatePlaceHolderValueMap('AssetId', 'assetIdForWO', fieldsToValueMap, placeHolderValueMap);
            }
            if(overridableFields.contains('SVMXA360__ProductId__c')){
                populatePlaceHolderValueMap('SVMXA360__ProductId__c', 'productIdForWO', fieldsToValueMap, placeHolderValueMap);
            }
            if(overridableFields.contains('LocationId')){
                populatePlaceHolderValueMap('LocationId', 'locationIdForWO', fieldsToValueMap, placeHolderValueMap);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToWorkOrder() - exit;');
    }

    public void applyMappingPscToOpportunity(HeaderRecordMappingWrapper headerRecordMappingWrapper) {
        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToOpportunity() - enter;');

        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();
        List<String> overridableFields = new List<String>();
        Map<String,List<SObject>> sourceRecIdTargetRecMap = new Map<String,List<SObject>>();

        sourceRecIdTargetRecMap.put(headerRecordMappingWrapper.pscRecord.Id, new List<SObject>{headerRecordMappingWrapper.mappedOpportunityRec});
        Map<String,List<SObject>> mappedRecord = objectMappingHandler.applyObjectMapping(headerRecordMappingWrapper.mappingKeyMappingIdMap.get('PSC2OPPNTY'), sourceRecIdTargetRecMap);
        if (!mappedRecord.isEmpty() && mappedRecord.containsKey(headerRecordMappingWrapper.pscRecord.Id)) {
            List<Opportunity> opportunityList = (List<Opportunity>) mappedRecord.get(headerRecordMappingWrapper.pscRecord.Id);
            headerRecordMappingWrapper.mappedOpportunityRec = opportunityList[0];
            List<SVMXA360__CONF_ObjectMappingDetail__c> fieldMapping = SvmxDatabase.query([SELECT SVMXA360__TargetFieldAPIName__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__r.SVMXA360__DeveloperName__c =: headerRecordMappingWrapper.mappingKeyMappingIdMap.get('PSC2OPPNTY') AND SVMXA360__TargetFieldAPIName__c IN : headerRecordMappingWrapper.defaultFieldList.get('Opportunity')]);
            for(SVMXA360__CONF_ObjectMappingDetail__c configData : fieldMapping){
                overridableFields.add(configData.SVMXA360__TargetFieldAPIName__c);
            }
            Map<String, Object> fieldsToValueMap = headerRecordMappingWrapper.mappedOpportunityRec.getPopulatedFieldsAsMap();
            if(overridableFields.contains('AccountId')){
                populatePlaceHolderValueMap('AccountId', 'accountIdForOppnty', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
            if(overridableFields.contains('Name')){
                populatePlaceHolderValueMap('Name', 'nameForOppnty', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
            if(overridableFields.contains('CloseDate')){
                populatePlaceHolderValueMap('CloseDate', 'closeDateForOppnty', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
            if(overridableFields.contains('StageName')){
                populatePlaceHolderValueMap('StageName', 'stageNameForOppnty', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToOpportunity() - exit;');
    }

    public void applyMappingPscToAssetNotification(HeaderRecordMappingWrapper headerRecordMappingWrapper) {
        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToAssetNotification() - enter;');

        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();
        List<String> overridableFields = new List<String>();
        Map<String,List<SObject>> sourceRecIdTargetRecMap = new Map<String,List<SObject>>();

        sourceRecIdTargetRecMap.put(headerRecordMappingWrapper.pscRecord.Id, new List<SObject>{headerRecordMappingWrapper.mappedAssetNotificationRec});
        Map<String,List<SObject>> mappedRecord = objectMappingHandler.applyObjectMapping(headerRecordMappingWrapper.mappingKeyMappingIdMap.get('PSC2ASSETNOTI'), sourceRecIdTargetRecMap);
        if (!mappedRecord.isEmpty() && mappedRecord.containsKey(headerRecordMappingWrapper.pscRecord.Id)) {
            List<SVMXA360__AssetNotification__c> assetNotificationList = (List<SVMXA360__AssetNotification__c>) mappedRecord.get(headerRecordMappingWrapper.pscRecord.Id);
            headerRecordMappingWrapper.mappedAssetNotificationRec = assetNotificationList[0];
            List<SVMXA360__CONF_ObjectMappingDetail__c> fieldMapping = SvmxDatabase.query([SELECT SVMXA360__TargetFieldAPIName__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__r.SVMXA360__DeveloperName__c =: headerRecordMappingWrapper.mappingKeyMappingIdMap.get('PSC2ASSETNOTI') AND SVMXA360__TargetFieldAPIName__c IN : headerRecordMappingWrapper.defaultFieldList.get('AssetNotification')]);
            for(SVMXA360__CONF_ObjectMappingDetail__c configData : fieldMapping){
                overridableFields.add(configData.SVMXA360__TargetFieldAPIName__c);
            }
            Map<String, Object> fieldsToValueMap = headerRecordMappingWrapper.mappedAssetNotificationRec.getPopulatedFieldsAsMap();
            if(overridableFields.contains('SVMXA360__Description__c')){
                populatePlaceHolderValueMap('SVMXA360__Description__c', 'descForAssetNoti', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
            if(overridableFields.contains('SVMXA360__Severity__c')){
                populatePlaceHolderValueMap('SVMXA360__Severity__c', 'severityForAssetNoti', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
            if(overridableFields.contains('SVMXA360__Status__c')){
                populatePlaceHolderValueMap('SVMXA360__Status__c', 'statusForAssetNoti', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
            if(overridableFields.contains('SVMXA360__Title__c')){
                populatePlaceHolderValueMap('SVMXA360__Title__c', 'titleForAssetNoti', fieldsToValueMap, headerRecordMappingWrapper.placeHolderValueMap);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'applyMappingPscToAssetNotification() - exit;');
    }

    public static void populatePlaceHolderValueMap(String fieldApiName, String keyNameForMap, Map<String, Object> fieldsToValueMap, Map<String, String> placeHolderValueMap) {
        String value = fieldsToValueMap.containsKey(fieldApiName) ? String.valueOf(fieldsToValueMap.get(fieldApiName)) : null;
        placeHolderValueMap.put(keyNameForMap, value);
    }

    public static workOrder createWorkOrderRecord(ProductServiceCampaignItem pscItem, WorkOrder mappedWorkOrderRec, ProductServiceCampaign pscRecord, Map<String, String> placeHolderValueMap) {
        System.debug(LoggingLevel.DEBUG, 'createWorkOrderRecord() - enter;');

        WorkOrder workOrder = mappedWorkOrderRec.clone(false, true, false, false);
        workOrder.AssetId = !'PLACEHOLDER_VALUE_ASSET'.equalsIgnoreCase(placeHolderValueMap.get('assetIdForWO')) ? placeHolderValueMap.get('assetIdForWO') : pscItem.AssetId;
        workOrder.SVMXA360__ProductId__c = !'PLACEHOLDER_VALUE_PRODUCT'.equalsIgnoreCase(placeHolderValueMap.get('productIdForWO')) ? placeHolderValueMap.get('productIdForWO') : pscItem.Asset.Product2Id;
        workOrder.LocationId =  !'PLACEHOLDER_VALUE_LOCATION'.equalsIgnoreCase(placeHolderValueMap.get('locationIdForWO')) ? placeHolderValueMap.get('locationIdForWO') : pscItem.Asset.LocationId;
        workOrder.ProductServiceCampaignId = pscRecord.Id;
        workOrder.ProductServiceCampaignItemId = pscItem.Id;

        System.debug(LoggingLevel.DEBUG, 'createWorkOrderRecord() - exit;');
        return workOrder;
    }

    public static ReturnOrder createReturnOrderRecord(ProductServiceCampaignItem pscItem, ReturnOrder mappedReturnOrderRec, ProductServiceCampaign pscRecord, Map<String, String> placeHolderValueMap) {
        System.debug(LoggingLevel.DEBUG, 'createReturnOrderRecord() - enter;');

        ReturnOrder returnOrder = mappedReturnOrderRec.clone(false, true, false, false);
        returnOrder.SVMXA360__AssetId__c = !'PLACEHOLDER_VALUE_ASSET'.equalsIgnoreCase(placeHolderValueMap.get('assetIdForRO')) ? placeHolderValueMap.get('assetIdForRO') : pscItem.AssetId;
        returnOrder.SourceLocationId =  !'PLACEHOLDER_VALUE_LOCATION'.equalsIgnoreCase(placeHolderValueMap.get('locationIdForRO')) ? placeHolderValueMap.get('locationIdForRO') : pscItem.Asset.LocationId;
        returnOrder.ProductServiceCampaignId = pscRecord.Id;

        System.debug(LoggingLevel.DEBUG, 'createReturnOrderRecord() - exit;');
        return returnOrder;
    }

    public static Case createCaseRecord(ProductServiceCampaignItem pscItem, Case mappedCaseRec, ProductServiceCampaign pscRecord, Map<String, String> placeHolderValueMap) {
        System.debug(LoggingLevel.DEBUG, 'createCaseRecord() - enter;');

        Case caseRecord = mappedCaseRec.clone(false, true, false, false);
        caseRecord.AssetId = !'PLACEHOLDER_VALUE_ASSET'.equalsIgnoreCase(placeHolderValueMap.get('assetIdForCase')) ? placeHolderValueMap.get('assetIdForCase') : pscItem.AssetId;
        caseRecord.ProductId =  !'PLACEHOLDER_VALUE_PRODUCT'.equalsIgnoreCase(placeHolderValueMap.get('productIdForCase')) ? placeHolderValueMap.get('productIdForCase') : pscItem.Asset.Product2Id;
        caseRecord.SVMXA360__ProductServiceCampaignId__c = pscRecord.Id;
        caseRecord.SVMXA360__ProductServiceCampaignItemId__c = pscItem.Id;

        System.debug(LoggingLevel.DEBUG, 'createCaseRecord() - exit;');
        return caseRecord;
    }

    public Opportunity createOpportunityRecord(ProductServiceCampaignItem pscItem, Opportunity mappedOpportunityRec, ProductServiceCampaign pscRecord, Map<String, String> placeHolderValueMap) {
        System.debug(LoggingLevel.DEBUG, 'createOpportunityRecord() - enter;');

        Opportunity opportunity = mappedOpportunityRec.clone(false, true, false, false);
        opportunity.AccountId = !'PLACEHOLDER_VALUE_ACCOUNT'.equalsIgnoreCase(placeHolderValueMap.get('accountIdForOppnty')) ? placeHolderValueMap.get('accountIdForOppnty') : pscItem.Asset.AccountId;
        opportunity.Name = !'PLACEHOLDER_VALUE_NAME'.equalsIgnoreCase(placeHolderValueMap.get('nameForOppnty')) ? placeHolderValueMap.get('nameForOppnty') : formatName(pscRecord.ProductServiceCampaignName, pscItem.Asset.SerialNumber, 120);
        opportunity.CloseDate = !'PLACEHOLDER_VALUE_CLOSE_DATE'.equalsIgnoreCase(placeHolderValueMap.get('closeDateForOppnty')) ? Date.valueOf(placeHolderValueMap.get('closeDateForOppnty')) : pscRecord.EndDate;
        opportunity.StageName = !'PLACEHOLDER_VALUE_STAGE_NAME'.equalsIgnoreCase(placeHolderValueMap.get('stageNameForOppnty')) ? placeHolderValueMap.get('stageNameForOppnty') : PROSPECTING_VALUE;
        opportunity.Pricebook2Id = pscRecord.SVMXA360__PriceBookId__c;
        opportunity.SVMXA360__ProductServiceCampaignId__c = pscRecord.Id;

        System.debug(LoggingLevel.DEBUG, 'createOpportunityRecord() - exit;');
        return opportunity;
    }

    public SVMXA360__AssetNotification__c createAssetNotificationRecord(ProductServiceCampaignItem pscItem, SVMXA360__AssetNotification__c mappedAssetNotificationRec, ProductServiceCampaign pscRecord, Map<String, String> placeHolderValueMap) {
        System.debug(LoggingLevel.DEBUG, 'createAssetNotificationRecord() - enter;');

        SVMXA360__AssetNotification__c assetNotification = mappedAssetNotificationRec.clone(false, true, false, false);
        assetNotification.SVMXA360__AssetId__c = pscItem.AssetId;
        assetNotification.SVMXA360__Title__c = !'PLACEHOLDER_VALUE_TITLE'.equalsIgnoreCase(placeHolderValueMap.get('titleForAssetNoti')) ? placeHolderValueMap.get('titleForAssetNoti') : formatName(pscRecord.ProductServiceCampaignName, pscItem.Asset.SerialNumber, 255);
        assetNotification.SVMXA360__ProductServiceCampaignItemId__c = pscItem.Id;
        assetNotification.SVMXA360__ProductServiceCampaignId__c = pscRecord.Id;
        assetNotification.SVMXA360__Status__c = !'PLACEHOLDER_VALUE_STATUS'.equalsIgnoreCase(placeHolderValueMap.get('statusForAssetNoti')) ? placeHolderValueMap.get('statusForAssetNoti') : ASSET_NOTIFICATION_STATUS_VALUE;
        assetNotification.SVMXA360__Severity__c = !'PLACEHOLDER_VALUE_SEVERITY'.equalsIgnoreCase(placeHolderValueMap.get('severityForAssetNoti')) ? placeHolderValueMap.get('severityForAssetNoti') : ASSET_NOTIFICATION_SEVERITY_VALUE;
        assetNotification.SVMXA360__Description__c = !'PLACEHOLDER_VALUE_DESCRIPTION'.equalsIgnoreCase(placeHolderValueMap.get('descForAssetNoti')) ? placeHolderValueMap.get('descForAssetNoti') : pscRecord.Description;

        System.debug(LoggingLevel.DEBUG, 'createAssetNotificationRecord() - exit;');
        return assetNotification;
    }

    public static String formatName(String pscName, String serialNumber, Integer nameValueLength) {
        String name = '';
        if (String.isNotBlank(serialNumber)) {
            name = serialNumber + ' - ' + pscName;
        } else {
            name = pscName;
        }
        if (String.isNotBlank(name) && name.length() > nameValueLength) {
            Integer adjustedCharLength = name.length() - nameValueLength;
            name = (String.isNotBlank(serialNumber) ? serialNumber : '') + ' - ' + pscName.substring(0, pscName.length() - adjustedCharLength);
        }
        return name;
    }

    //public static void insertAllOutputRecord(List<SObject> allObjectRecordList, List<ProductRequired> productRequiredList, List<ReturnOrderLineItem> returnOrderLineItemList, List<ProductServiceCampaignItem> psciLines, Map<String, ProductServiceCampaignItem> woToPsciMap, Map<String, ProductServiceCampaignItem> roToPsciMap, Map<String, String> failedLineErrorMap) {
    public static void insertAllOutputRecord(List<SObject> allObjectRecordList, List<ReturnOrderLineItem> returnOrderLineItemList, List<OpportunityLineItem> opportunityLineItemList, List<ProductServiceCampaignItem> psciLines, Map<String, ProductServiceCampaignItem> roToPsciMap, Map<String, ProductServiceCampaignItem> opportunityToPsciMap, Map<String, String> failedLineErrorMap) {
        System.debug(LoggingLevel.DEBUG, 'insertAllOutputRecord() - enter;');

        List<Database.SaveResult> allRecordSaveResult = !allObjectRecordList.isEmpty() ? Database.insert(allObjectRecordList, false) : new List<Database.SaveResult>();
        Integer count = 0;

        for(Database.SaveResult sr : allRecordSaveResult) {
            if(sr.isSuccess()) {
                String recordId = (String) sr.getId();
                /* if(recordId.startsWith(WO_OBJ_PREFIX)){
                    productRequiredList.addAll(getProductRequiredList(sr.getId(), psciLines[count].Id, psciLines[count].ProductServiceCampaignId));
                    woToPsciMap.put(sr.getId(), psciLines[count]);
                } else */
                if(recordId.startsWith(RO_OBJ_PREFIX)){
                    returnOrderLineItemList.add(getReturnOrderLineItem(sr.getId(), psciLines[count]));
                    roToPsciMap.put(sr.getId(), psciLines[count]);
                } else if(recordId.startsWith(OPPORTUNITY_OBJ_PREFIX)){
                    try {
                        opportunityLineItemList.add(getOpportunityLineItem(sr.getId(), psciLines[count]));
                        opportunityToPsciMap.put(sr.getId(), psciLines[count]);
                    } catch (SvmxSystem.SvmxNestedException e) {
                        failedLineErrorMap.put(psciLines[count].Id, e.getMessage());
                    }
                }
            }
            else{
                String errorMsg = sr.getErrors()[0].getMessage();
                failedLineErrorMap.put(psciLines[count].Id, errorMsg);
            }
            count++;
        }
        allRecordSaveResult = null; //ClearMemory

        System.debug(LoggingLevel.DEBUG, 'insertAllOutputRecord() - exit;');
    }

    /* private static List<ProductRequired> getProductRequiredList(String workOrderId, String psciId, String pscRecordId){
        System.debug(LoggingLevel.DEBUG, 'getProductRequiredList() - enter;');

        List<ProductRequired> productRequiredList = new List<ProductRequired> ();
        for(SVMXA360__PSCRequiredParts__c reqPart  : pscRequiredParts){
            ProductRequired productRequiredInstance = new ProductRequired();
            productRequiredInstance.ParentRecordId = workOrderId;
            productRequiredInstance.SVMXA360__ProductServiceCampaignId__c = pscRecordId;
            productRequiredInstance.SVMXA360__ProductServiceCampaignItemId__c = psciId;
            productRequiredInstance.Product2Id = reqPart.SVMXA360__ProductId__c;
            productRequiredInstance.QuantityRequired = reqPart.SVMXA360__Quantity__c;
            productRequiredInstance.QuantityUnitOfMeasure = reqPart.SVMXA360__ProductId__r.QuantityUnitOfMeasure;
            productRequiredList.add(productRequiredInstance);
        }

        System.debug(LoggingLevel.DEBUG, 'getProductRequiredList() - exit;');
        return productRequiredList;
    } */

    private static ReturnOrderLineItem getReturnOrderLineItem(String returnOrderId, ProductServiceCampaignItem psci){
        System.debug(LoggingLevel.DEBUG, 'getReturnOrderLineItem() - enter;');

        ReturnOrderLineItem returnOrderLineItem = new ReturnOrderLineItem();
        returnOrderLineItem.ReturnOrderId = returnOrderId;
        returnOrderLineItem.ProductServiceCampaignItemId = psci.Id;
        returnOrderLineItem.AssetId = psci.AssetId;
        returnOrderLineItem.QuantityReturned = 1.0;

        System.debug(LoggingLevel.DEBUG, 'getReturnOrderLineItem() - exit;');
        return returnOrderLineItem;
    }

    private static OpportunityLineItem getOpportunityLineItem(String opportunityId, ProductServiceCampaignItem psci){
        System.debug(LoggingLevel.DEBUG, 'getOpportunityLineItem() - enter;');

        if (!isPriceBookActiveForOppnty) {
            throw new SvmxSystem.SvmxNestedException(System.Label.Error_PriceBookInactive);
        }

        if (!productIdListPrice.containsKey(psci.Asset.Product2Id)) {
            throw new SvmxSystem.SvmxNestedException(System.Label.Error_PriceBookNotConfigured);
        }

        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        if(!sourceRecIdTargetObjOpntyLineItemMap.isEmpty() && sourceRecIdTargetObjOpntyLineItemMap.containsKey(psci.AssetId)) {
            opportunityLineItem = (OpportunityLineItem) sourceRecIdTargetObjOpntyLineItemMap.get(psci.AssetId)[0];
        }
        opportunityLineItem.OpportunityId = opportunityId;
        opportunityLineItem.SVMXA360__ProductServiceCampaignItemId__c = psci.Id;
        opportunityLineItem.Product2Id = psci.Asset.Product2Id;
        opportunityLineItem.SVMXA360__AssetId__c = psci.AssetId;
        opportunityLineItem.Quantity = 1.0;
        opportunityLineItem.TotalPrice = productIdListPrice.get(psci.Asset.Product2Id);

        System.debug(LoggingLevel.DEBUG, 'getOpportunityLineItem() - exit;');
        return opportunityLineItem;
    }

    /* public static void insertProductRequiredRecords(List<ProductRequired> productRequiredList, Map<String, ProductServiceCampaignItem> woToPsciMap, Map<String, String> failedLineErrorMap){
        System.debug(LoggingLevel.DEBUG, 'insertProductRequiredRecords() - enter;');

        List<Database.SaveResult> productRequiredSaveResult = !productRequiredList.isEmpty() ? Database.insert(productRequiredList, false) : new List<Database.SaveResult>();
        Integer productRequiredCounter = 0;
        for(Database.SaveResult sr : productRequiredSaveResult) {
            if(!sr.isSuccess()) {
                String workOrderId = productRequiredList[productRequiredCounter].ParentRecordId;
                String pscLineId = woToPsciMap.get(workOrderId).Id;
                if(failedLineErrorMap.containsKey(pscLineId)){
                    String existingErrorOnFcoLine = failedLineErrorMap.get(pscLineId);
                    failedLineErrorMap.put(pscLineId, existingErrorOnFcoLine + ', ' + sr.getErrors()[0].getMessage());
                }
                else{
                    failedLineErrorMap.put(pscLineId, sr.getErrors()[0].getMessage());
                }
                woToPsciMap.remove(workOrderId);
            }
            productRequiredCounter++;
        }
        productRequiredSaveResult = null; //Clear memory

        System.debug(LoggingLevel.DEBUG, 'insertProductRequiredRecords() - exit;');
    } */

    public static void insertReturnOrderLineItemRecords(List<ReturnOrderLineItem> returnOrderLineItemList, Map<String, ProductServiceCampaignItem> roToPsciMap, Map<String, String> failedLineErrorMap){
        System.debug(LoggingLevel.DEBUG, 'insertReturnOrderLineItemRecords() - enter;');

        List<Database.SaveResult> returnOrderLineItemResult = !returnOrderLineItemList.isEmpty() ? Database.insert(returnOrderLineItemList, false) : new List<Database.SaveResult>();
        Integer returnOrderLineItemCounter = 0;
        for(Database.SaveResult sr : returnOrderLineItemResult) {
            if(!sr.isSuccess()) {
                String returnOrderId = returnOrderLineItemList[returnOrderLineItemCounter].ReturnOrderId;
                String pscLineId = roToPsciMap.get(returnOrderId).Id;
                if(failedLineErrorMap.containsKey(pscLineId)){
                    String existingErrorOnFcoLine = failedLineErrorMap.get(pscLineId);
                    failedLineErrorMap.put(pscLineId, existingErrorOnFcoLine + ', ' + sr.getErrors()[0].getMessage());
                }
                else{
                    failedLineErrorMap.put(pscLineId, sr.getErrors()[0].getMessage());
                }
                roToPsciMap.remove(returnOrderId);
            }
            returnOrderLineItemCounter++;
        }
        returnOrderLineItemResult = null; //Clear memory

        System.debug(LoggingLevel.DEBUG, 'insertReturnOrderLineItemRecords() - exit;');
    }

    public void insertOpportunityLineItemRecords(List<OpportunityLineItem> opportunityLineItemList, Map<String, ProductServiceCampaignItem> opportunityToPsciMap, Map<String, String> failedLineErrorMap){
        System.debug(LoggingLevel.DEBUG, 'insertOpportunityLineItemRecords() - enter;');

        List<Database.SaveResult> opportunityLineItemResult = !opportunityLineItemList.isEmpty() ? Database.insert(opportunityLineItemList, false) : new List<Database.SaveResult>();
        Integer opportunityLineItemCounter = 0;
        for(Database.SaveResult sr : opportunityLineItemResult) {
            if(!sr.isSuccess()) {
                String opportunityId = opportunityLineItemList[opportunityLineItemCounter].OpportunityId;
                String pscLineId = opportunityToPsciMap.get(opportunityId).Id;
                if(failedLineErrorMap.containsKey(pscLineId)){
                    String existingErrorOnFcoLine = failedLineErrorMap.get(pscLineId);
                    failedLineErrorMap.put(pscLineId, existingErrorOnFcoLine + ', ' + sr.getErrors()[0].getMessage());
                }
                else{
                    failedLineErrorMap.put(pscLineId, sr.getErrors()[0].getMessage());
                }
                opportunityToPsciMap.remove(opportunityId);
            }
            opportunityLineItemCounter++;
        }
        opportunityLineItemResult = null; //Clear memory

        System.debug(LoggingLevel.DEBUG, 'insertOpportunityLineItemRecords() - exit;');
    }

    /**
    * Used to generate log details of batch
    */
    public static String getLogDetails(Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap, Map<Integer, Integer> recordCountInBatchMap, String batchId, Integer totalNoOfRecords, String pscRecordId){
        String sectionSeparator = '----------------------------------------------';
        String newLine  = '\n';
        AsyncApexJob apexJob = [SELECT TotalJobItems FROM AsyncApexJob WHERE Id =: batchId WITH SECURITY_ENFORCED];
        Integer totalNoOfBatches = apexJob.TotalJobItems;
        Integer failedBatchCount = failedRecordsWithBatchNoMap.size();
        Integer totalFailedRecords = Database.countQuery('SELECT count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId AND Status = \'Draft\' AND AssetId != null AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != \'NoDelivery\' WITH SECURITY_ENFORCED');
        String logDetails = 'Total No. of Records: ' + totalNoOfRecords + newLine;
        String batchLogDetails = '';

        for(Integer batchNo : failedRecordsWithBatchNoMap.keySet()){
            batchLogDetails += sectionSeparator + newLine + 'Details of records causing failure of Batch No: ' + batchNo + newLine;
            batchLogDetails += 'Total No. of PSC Lines in Batch: ' + recordCountInBatchMap.get(batchNo) + newLine;
            batchLogDetails += newLine + 'Error Logs:' + newLine;
            Map<String, String> errorMap = failedRecordsWithBatchNoMap.get(batchNo);
            for(String pscLineId : errorMap.keySet()){
                batchLogDetails += pscLineId + ': ' + errorMap.get(pscLineId) + newLine;
            }
            batchLogDetails += newLine;
        }
        
        logDetails += 'Success: ' + (totalNoOfRecords - totalFailedRecords) + newLine;
        logDetails += 'Failure: ' + totalFailedRecords + newLine + newLine;
        logDetails += 'Total No. of Batches: ' + totalNoOfBatches + newLine;
        logDetails += 'Successful Batches: ' + (totalNoOfBatches - failedBatchCount) + newLine;
        logDetails += 'Failed Batches: ' + failedBatchCount + newLine;
        logDetails += batchLogDetails;
        return logDetails;
    }

    public static void fetchMappingIds(ProductServiceCampaign pscRecord, Map<String, String> mappingKeyMappingIdMap) {
        System.debug(LoggingLevel.DEBUG, 'fetchMappingIds() - enter;');

        String mappingJson = pscRecord.SVMXA360__PSCConfigurationId__r.SVMXA360__PSCMappingJSON__c;
        if (String.isNotBlank(mappingJson)) {
            try{
                List<PSC_ManageResultsHandler.PscMappingConfiguration> mappingConfigurationList = (List<PSC_ManageResultsHandler.PscMappingConfiguration>) JSON.deserializeStrict(mappingJson, List<PSC_ManageResultsHandler.PscMappingConfiguration>.class);
                for (PSC_ManageResultsHandler.PscMappingConfiguration mappingConfiguration : mappingConfigurationList){
                    if (String.isNotBlank(mappingConfiguration.targetMappingKey) && String.isNotBlank(mappingConfiguration.targetMappingId)) {
                        mappingKeyMappingIdMap.put(mappingConfiguration.targetMappingKey, mappingConfiguration.targetMappingId);
                    }
                }
            }
            catch(System.JSONException e) {
                System.debug(LoggingLevel.ERROR, 'fetchMappingIds() - Error= ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'fetchMappingIds() : Failed to deserialize MappingJSON.Error= ' + e.getStackTraceString());
            }
        }

        System.debug(LoggingLevel.DEBUG, 'fetchMappingIds() - exit;');
    }

    public class PscMappingConfiguration {
        public String targetMappingKey {get;set;}
        public String targetMappingId {get;set;}
    }

    /**
    * Used to create email body for PSC owner once Generate Output batch gets completed
    */ 
    public static String getEmailBodyForPSCOwner(ProductServiceCampaign pscRecord, Integer totalNoOfRecord, Integer failureCount, SVMXA360__PSCEngineLog__c pscLog){

        Datetime startedOn = PSC_SearchCriteriaHandler.getUserDateTime(pscLog.SVMXA360__StartedOn__c); //converting it to user time zone for email
        Datetime completedOn = PSC_SearchCriteriaHandler.getUserDateTime(pscLog.SVMXA360__CompletedOn__c); //converting it to user time zone for email

        String pscName = pscRecord.ProductServiceCampaignName;
        String processingTime = String.valueOf(((completedOn).getTime() - (startedOn).getTime()) / (1000 * 60));
        String emailBody = Label.Label_SystemGeneratedEmail + '<br/><br/>';
        emailBody += Label.Label_DeliveryOutputGenerationProcess + ' ' + pscName + ' ' + Label.Label_HasCompletedWith + '<br/><br/>';
        emailBody += '<b>' + Label.Label_TotalNumberOfRecordsToCreate + ' ' + '</b>' + totalNoOfRecord  + '<br/>';
        emailBody += '<b>' + Label.Label_NumberOfRecordsSuccessfullyCreated + ' ' + '</b>' + (totalNoOfRecord - failureCount)  + '<br/><br/>';
        emailBody += '<b>' + Label.Label_DeliveryOutputStartTime + ' ' + '</b>'  + startedOn + ' - ' + PSC_SearchCriteriaHandler.userTimeZoneDisplayName + '<br/>';
        emailBody += '<b>' + Label.Label_DeliveryOutputFinishTime + ' ' + '</b>' + completedOn + ' - ' + PSC_SearchCriteriaHandler.userTimeZoneDisplayName + '<br/>';
        emailBody += '<b>' + Label.Label_ElapsedTimeInMinutes + ' ' + '</b>' + processingTime + '<br/>';
        return emailBody;
    }

    // Internal wrapper class for passing data to methods
    public class HeaderRecordMappingWrapper {
        public ProductServiceCampaign pscRecord;
        public Opportunity mappedOpportunityRec;
        public SVMXA360__AssetNotification__c mappedAssetNotificationRec;
        public Map<String, String> mappingKeyMappingIdMap;
        public Map<String, String> placeHolderValueMap;
        public Map<String, List<String>> defaultFieldList;
    }
}