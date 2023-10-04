/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This Batch class will be used to generate Work Order, Return Order and Case
 * records based on the ProductServiceCampaignItem records for the particular PSC record.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-100   Manish Kushwah          25 Jan 2021     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
global with sharing class PSC_GenerateOutputBatch implements Database.Batchable<sObject>, Database.Stateful{

    global String pscRecordId;
    public ProductServiceCampaign pscRecord;
    public SVMXA360__PSCEngineLog__c logRecord;
    
    WorkOrder mappedWorkOrderRec = new WorkOrder();
    ReturnOrder mappedReturnOrderRec = new ReturnOrder();
    Case mappedCaseRec = new Case();
    Opportunity mappedOpportunityRec = new Opportunity();
    SVMXA360__AssetNotification__c mappedAssetNotificationRec = new SVMXA360__AssetNotification__c();

    // List<SVMXA360__PSCRequiredParts__c> pscRequiredParts = new List<SVMXA360__PSCRequiredParts__c>();

    Map<String, String> mappingKeyMappingIdMap = new Map<String, String>{ 
        'PSC2WORD' => null, 'ASSET2WORD' => null,
        'PSC2CASE' => null, 'ASSET2CASE' => null,
        'PSC2RORD' => null, 'ASSET2RORD' => null,
        'PSC2OPPNTY' => null, 'ASSET2OPPNTYPROD' => null,
        'PSC2ASSETNOTI' => null, 'ASSET2ASSETNOTI' => null
    };

    public Map<String, List<String>> defaultFieldList = new Map<String, List<String>>{
        'WorkOrder' => new List<String> {'AssetId','SVMXA360__ProductId__c','LocationId'},
        'ReturnOrder' => new List<String> {'SVMXA360__AssetId__c','SourceLocationId'},
        'Case' => new List<String> {'AssetId','ProductId'},
        'Opportunity' => new List<String> {'AccountId','Name','CloseDate','StageName'},
        'AssetNotification' => new List<String> {'SVMXA360__Description__c','SVMXA360__Severity__c','SVMXA360__Status__c','SVMXA360__Title__c'}
    };

    Map<String, String> placeHolderValueMap = new Map<String, String>{
        'assetIdForWO' => 'PLACEHOLDER_VALUE_ASSET',
        'productIdForWO' => 'PLACEHOLDER_VALUE_PRODUCT',
        'locationIdForWO' => 'PLACEHOLDER_VALUE_LOCATION',
        'assetIdForRO' => 'PLACEHOLDER_VALUE_ASSET',
        'locationIdForRO' => 'PLACEHOLDER_VALUE_LOCATION',
        'assetIdForCase' => 'PLACEHOLDER_VALUE_ASSET',
        'productIdForCase' => 'PLACEHOLDER_VALUE_PRODUCT',
        'accountIdForOppnty' => 'PLACEHOLDER_VALUE_ACCOUNT',
        'nameForOppnty' => 'PLACEHOLDER_VALUE_NAME',
        'closeDateForOppnty' => 'PLACEHOLDER_VALUE_CLOSE_DATE',
        'stageNameForOppnty' => 'PLACEHOLDER_VALUE_STAGE_NAME',
        'descForAssetNoti' => 'PLACEHOLDER_VALUE_DESCRIPTION',
        'severityForAssetNoti' => 'PLACEHOLDER_VALUE_SEVERITY',
        'statusForAssetNoti' => 'PLACEHOLDER_VALUE_STATUS',
        'titleForAssetNoti' => 'PLACEHOLDER_VALUE_TITLE'
    };

    public Integer totalNoOfRecords = 0;
    public static final Integer MAX_LOG_LENGTH = 131072;
    Map<Integer, Map<String, String>> failedRecordsWithBatchNoMap = new Map<Integer, Map<String, String>>();
    Integer failedBatchCount = 0;
    Map<Integer, Integer> recordCountInBatchMap = new Map<Integer, Integer>();
    public String errorMessageCaptureFromCatch = '';
    PSC_ManageResultsHandler manageResultsHandlerInstance = new PSC_ManageResultsHandler();

    global List<SObject> start(Database.BatchableContext bc) {

        System.debug(LoggingLevel.DEBUG, 'PSC_GenerateOutputBatch: start() - enter; pscRecordId= ' + pscRecordId);
        List<ProductServiceCampaignItem> productServiceCampaignItemList = new List<ProductServiceCampaignItem>();
        List<String> overridableFields = new List<String>();
        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();

        try {
            PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
            String pscQueryFields = 'Id, ProductServiceCampaignName, Description, SVMXA360__PSCConfigurationId__c, SVMXA360__PSCConfigurationId__r.SVMXA360__PSCMappingJSON__c, SVMXA360__PSCConfigurationId__r.SVMXA360__Active__c, SVMXA360__PSCConfigurationId__r.SVMXA360__Email__c, SVMXA360__NotifyPSCOwner__c, Owner.Email, EndDate, SVMXA360__PriceBookId__c, SVMXA360__PriceBookId__r.IsActive';
            List<ProductServiceCampaign> pscRecordList = searchCriteriaHandler.getPscRecord(pscRecordId, pscQueryFields, null);

            if(!pscRecordList.isEmpty()) {
                pscRecord = pscRecordList[0];

                if (pscRecord.SVMXA360__PSCConfigurationId__c == null || (pscRecord.SVMXA360__PSCConfigurationId__c != null && pscRecord.SVMXA360__PSCConfigurationId__r.SVMXA360__Active__c == false)) {
                    System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch: start() : Either Psc Configuration is missing or associated Psc Configuration is Inactive. pscRecordId= ' + pscRecordId);
                    throw new SvmxSystem.SvmxNestedException(ErrorMessage.PSC_CONF_MISSING_INACTIVE);
                }

                // fetch ProductServiceCampaignItem records that needs to be processed
                productServiceCampaignItemList = SvmxDatabase.query([SELECT Id, AssetId, Asset.Product2Id, Asset.LocationId, Asset.AccountId, Asset.SerialNumber, SVMXA360__DeliveryMethod__c, ProductServiceCampaignId, SVMXA360__PSCEngineLogId__c, Status FROM ProductServiceCampaignItem
                                                WHERE ProductServiceCampaignId =: pscRecordId AND Status = 'Draft' 
                                                AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != 'NoDelivery'
                                                AND AssetId != null ORDER BY SVMXA360__DeliveryMethod__c ASC]);

                List<SVMXA360__PSCEngineLog__c> engineLogRecord = SvmxDatabase.query([SELECT Id, SVMXA360__StartedOn__c, SVMXA360__CompletedOn__c, SVMXA360__BatchId__c FROM SVMXA360__PSCEngineLog__c WHERE SVMXA360__BatchId__c =: bc.getJobId() LIMIT 1]);
                if(!engineLogRecord.isEmpty()){
                    logRecord = engineLogRecord[0];
                    engineLogRecord[0].SVMXA360__StartedOn__c = DateTime.now();
                    SvmxDatabase.updateRecord(engineLogRecord);
                }
                
                //Populate mappingIds to the variable mappingKeyMappingIdMap
                PSC_ManageResultsHandler.fetchMappingIds(pscRecord, mappingKeyMappingIdMap);

                //Fetch Required Parts records
                // pscRequiredParts = SvmxDatabase.query([SELECT SVMXA360__ProductId__c, SVMXA360__ProductId__r.QuantityUnitOfMeasure, SVMXA360__ProductServiceCampaignId__c, SVMXA360__Quantity__c FROM SVMXA360__PSCRequiredParts__c WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId]);

                //Apply Mapping for PSC to WO
                if (mappingKeyMappingIdMap.get('PSC2WORD') != null) {
                    PSC_ManageResultsHandler.applyMappingPscToWorkOrder(pscRecord, mappedWorkOrderRec, mappingKeyMappingIdMap, placeHolderValueMap, defaultFieldList);
                }

                //Apply Mapping for PSC to RO
                if (mappingKeyMappingIdMap.get('PSC2RORD') != null) {
                    PSC_ManageResultsHandler.applyMappingPscToReturnOrder(pscRecord, mappedReturnOrderRec, mappingKeyMappingIdMap, placeHolderValueMap, defaultFieldList);
                }

                //Apply Mapping for PSC to Case
                if (mappingKeyMappingIdMap.get('PSC2CASE') != null) {
                    PSC_ManageResultsHandler.applyMappingPscToCase(pscRecord, mappedCaseRec, mappingKeyMappingIdMap, placeHolderValueMap, defaultFieldList);
                }

                //Apply Mapping for PSC to Opportunity
                if (mappingKeyMappingIdMap.get('PSC2OPPNTY') != null) {
                    PSC_ManageResultsHandler.HeaderRecordMappingWrapper headerRecordMappingWrapper = new PSC_ManageResultsHandler.HeaderRecordMappingWrapper();
                    headerRecordMappingWrapper.pscRecord = pscRecord;
                    headerRecordMappingWrapper.mappedOpportunityRec = mappedOpportunityRec;
                    headerRecordMappingWrapper.mappingKeyMappingIdMap = mappingKeyMappingIdMap;
                    headerRecordMappingWrapper.placeHolderValueMap = placeHolderValueMap;
                    headerRecordMappingWrapper.defaultFieldList = defaultFieldList;
                    manageResultsHandlerInstance.applyMappingPscToOpportunity(headerRecordMappingWrapper);
                }

                //Apply Mapping for PSC to Asset Notification
                if (mappingKeyMappingIdMap.get('PSC2ASSETNOTI') != null) {
                    PSC_ManageResultsHandler.HeaderRecordMappingWrapper headerRecordMappingWrapper = new PSC_ManageResultsHandler.HeaderRecordMappingWrapper();
                    headerRecordMappingWrapper.pscRecord = pscRecord;
                    headerRecordMappingWrapper.mappedAssetNotificationRec = mappedAssetNotificationRec;
                    headerRecordMappingWrapper.mappingKeyMappingIdMap = mappingKeyMappingIdMap;
                    headerRecordMappingWrapper.placeHolderValueMap = placeHolderValueMap;
                    headerRecordMappingWrapper.defaultFieldList = defaultFieldList;
                    manageResultsHandlerInstance.applyMappingPscToAssetNotification(headerRecordMappingWrapper);
                }
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch() start() - Error= ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch: start() - StackTrace= ' + e.getStackTraceString());
        }
        System.debug(LoggingLevel.DEBUG, 'PSC_GenerateOutputBatch: start() - exit; productServiceCampaignItemList size= ' + productServiceCampaignItemList.size());

        totalNoOfRecords = productServiceCampaignItemList.size();
        return productServiceCampaignItemList;
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        System.debug(LoggingLevel.DEBUG, 'PSC_GenerateOutputBatch: execute() - enter; scope= ' + scope);
        Savepoint savepoint = Database.setSavepoint();
        CONF_ObjectMappingHandler objectMappingHandler = new CONF_ObjectMappingHandler();
        List<ProductServiceCampaignItem> psciLines = (List<ProductServiceCampaignItem>)(scope);

        try {
            Boolean queryPriceBookEntries = false;
            Map<String,List<SObject>> sourceRecIdTargetObjWOMap = new Map<String,List<SObject>>();
            Map<String,List<SObject>> sourceRecIdTargetObjROMap = new Map<String,List<SObject>>();
            Map<String,List<SObject>> sourceRecIdTargetObjCaseMap = new Map<String,List<SObject>>();
            Map<String,List<SObject>> sourceRecIdTargetObjOpportunityMap = new Map<String,List<SObject>>();
            Map<String,List<SObject>> sourceRecIdTargetObjOpntyLineItemMap = new Map<String,List<SObject>>();
            Map<String,List<SObject>> sourceRecIdTargetObjAssetNotiMap = new Map<String,List<SObject>>();

            List<ProductServiceCampaignItem> linesForWOAsset = new List<ProductServiceCampaignItem>();
            List<ProductServiceCampaignItem> linesForROAsset = new List<ProductServiceCampaignItem>();
            List<ProductServiceCampaignItem> linesForCaseAsset = new List<ProductServiceCampaignItem>();
            List<ProductServiceCampaignItem> linesForOpportunityAsset = new List<ProductServiceCampaignItem>();
            List<ProductServiceCampaignItem> linesForAssetNotiAsset = new List<ProductServiceCampaignItem>();

            Map<String, String> failedLineErrorMap = new Map<String, String> ();
            // List<ProductRequired> productRequiredList = new List<ProductRequired>();
            List<ReturnOrderLineItem> returnOrderLineItemList = new List<ReturnOrderLineItem>();
            List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();

            // Map<String, ProductServiceCampaignItem> woToPsciMap = new Map<String, ProductServiceCampaignItem>();
            Map<String, ProductServiceCampaignItem> roToPsciMap = new Map<String, ProductServiceCampaignItem>();
            Map<String, ProductServiceCampaignItem> opportunityToPsciMap = new Map<String, ProductServiceCampaignItem>();

            List<SObject> allObjectRecordList = new List<SObject>();

            for (ProductServiceCampaignItem pscItem : psciLines) {
                pscItem.SVMXA360__PSCEngineLogId__c = logRecord.Id;
                String deliveryMethod = pscItem.SVMXA360__DeliveryMethod__c;
                if (pscItem.AssetId != null) {
                    switch on deliveryMethod {
                        when 'WorkOrder' {
                            WorkOrder workOrder = PSC_ManageResultsHandler.createWorkOrderRecord(pscItem, mappedWorkOrderRec, pscRecord, placeHolderValueMap);
                            sourceRecIdTargetObjWOMap.put(pscItem.AssetId, new List<SObject>{workOrder});
                            linesForWOAsset.add(pscItem);
                        }
                        when 'ReturnOrder' {
                            ReturnOrder returnOrder = PSC_ManageResultsHandler.createReturnOrderRecord(pscItem, mappedReturnOrderRec, pscRecord, placeHolderValueMap);
                            sourceRecIdTargetObjROMap.put(pscItem.AssetId, new List<SObject>{returnOrder});
                            linesForROAsset.add(pscItem);
                        }
                        when 'Case' {
                            Case caseRecord = PSC_ManageResultsHandler.createCaseRecord(pscItem, mappedCaseRec, pscRecord, placeHolderValueMap);
                            sourceRecIdTargetObjCaseMap.put(pscItem.AssetId, new List<SObject>{caseRecord});
                            linesForCaseAsset.add(pscItem);
                        }
                        when 'Opportunity' {
                            queryPriceBookEntries = true;
                            Opportunity opportunityRecord = manageResultsHandlerInstance.createOpportunityRecord(pscItem, mappedOpportunityRec, pscRecord, placeHolderValueMap);
                            sourceRecIdTargetObjOpportunityMap.put(pscItem.AssetId, new List<SObject>{opportunityRecord});
                            sourceRecIdTargetObjOpntyLineItemMap.put(pscItem.AssetId, new List<SObject>{new OpportunityLineItem()});
                            linesForOpportunityAsset.add(pscItem);
                        }
                        when 'AssetNotification' {
                            SVMXA360__AssetNotification__c assetNotificationRecord = manageResultsHandlerInstance.createAssetNotificationRecord(pscItem, mappedAssetNotificationRec, pscRecord, placeHolderValueMap);
                            sourceRecIdTargetObjAssetNotiMap.put(pscItem.AssetId, new List<SObject>{assetNotificationRecord});
                            linesForAssetNotiAsset.add(pscItem);
                        }
                    }
                }
            }

            psciLines = new List<ProductServiceCampaignItem>();
            psciLines.addAll(linesForWOAsset);
            psciLines.addAll(linesForROAsset);
            psciLines.addAll(linesForCaseAsset);
            psciLines.addAll(linesForOpportunityAsset);
            psciLines.addAll(linesForAssetNotiAsset);

            linesForWOAsset.clear(); //ClearMemory
            linesForROAsset.clear(); //ClearMemory
            linesForCaseAsset.clear(); //ClearMemory
            linesForOpportunityAsset.clear(); //ClearMemory
            linesForAssetNotiAsset.clear(); //ClearMemory

            // Apply mapping for Asset To WO
            if(mappingKeyMappingIdMap.get('ASSET2WORD') != null && !sourceRecIdTargetObjWOMap.isEmpty()){
                sourceRecIdTargetObjWOMap = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('ASSET2WORD'), sourceRecIdTargetObjWOMap);
            }
            for(List<SObject> recordList : sourceRecIdTargetObjWOMap.values()) {
                allObjectRecordList.addAll(recordList);
            }
            sourceRecIdTargetObjWOMap.clear(); //ClearMemory

            // Apply mapping for Asset To RO
            if(mappingKeyMappingIdMap.get('ASSET2RORD') != null && !sourceRecIdTargetObjROMap.isEmpty()){
                sourceRecIdTargetObjROMap = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('ASSET2RORD'), sourceRecIdTargetObjROMap); 
            }
            for (List<SObject> recordList : sourceRecIdTargetObjROMap.values()) {
                allObjectRecordList.addAll(recordList);
            }
            sourceRecIdTargetObjROMap.clear(); //ClearMemory

            // Apply mapping for Asset To Case
            if(mappingKeyMappingIdMap.get('ASSET2CASE') != null && !sourceRecIdTargetObjCaseMap.isEmpty()){
                sourceRecIdTargetObjCaseMap = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('ASSET2CASE'), sourceRecIdTargetObjCaseMap); 
            }
            for (List<SObject> recordList : sourceRecIdTargetObjCaseMap.values()) {
                allObjectRecordList.addAll(recordList);
            }
            sourceRecIdTargetObjCaseMap.clear(); //ClearMemory

            // Collect Opportunity Record
            for (List<SObject> recordList : sourceRecIdTargetObjOpportunityMap.values()) {
                allObjectRecordList.addAll(recordList);
            }
            sourceRecIdTargetObjOpportunityMap.clear(); //ClearMemory

            // Apply mapping for Asset To Opportunity Line Item
            if(mappingKeyMappingIdMap.get('ASSET2OPPNTYPROD') != null && !sourceRecIdTargetObjOpntyLineItemMap.isEmpty()){
                sourceRecIdTargetObjOpntyLineItemMap = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('ASSET2OPPNTYPROD'), sourceRecIdTargetObjOpntyLineItemMap); 
            }

            if(queryPriceBookEntries && pscRecord.SVMXA360__PriceBookId__c != null) {
                Map<String, Double> productIdListPrice = new Map<String, Double>();
                List<PricebookEntry> pricebookEntryList = SvmxDatabase.query([SELECT Product2Id, UnitPrice FROM PricebookEntry 
                                                            WHERE Pricebook2Id =: pscRecord.SVMXA360__PriceBookId__c AND IsActive = true]);
                for(PricebookEntry pbe: pricebookEntryList) {
                    productIdListPrice.put(pbe.Product2Id, pbe.UnitPrice);
                }
                PSC_ManageResultsHandler.productIdListPrice = productIdListPrice;
                PSC_ManageResultsHandler.isPriceBookActiveForOppnty = pscRecord.SVMXA360__PriceBookId__r.IsActive;
                pricebookEntryList.clear();
            }

            // Apply mapping for Asset To Asset Notification
            if(mappingKeyMappingIdMap.get('ASSET2ASSETNOTI') != null && !sourceRecIdTargetObjAssetNotiMap.isEmpty()){
                sourceRecIdTargetObjAssetNotiMap = objectMappingHandler.applyObjectMapping(mappingKeyMappingIdMap.get('ASSET2ASSETNOTI'), sourceRecIdTargetObjAssetNotiMap); 
            }
            for (List<SObject> recordList : sourceRecIdTargetObjAssetNotiMap.values()) {
                allObjectRecordList.addAll(recordList);
            }
            sourceRecIdTargetObjAssetNotiMap.clear(); //ClearMemory

            // Insert all output records
            // PSC_ManageResultsHandler.pscRequiredParts = pscRequiredParts;
            // PSC_ManageResultsHandler.insertAllOutputRecord(allObjectRecordList, productRequiredList, returnOrderLineItemList, psciLines, woToPsciMap, roToPsciMap, failedLineErrorMap);
            PSC_ManageResultsHandler.sourceRecIdTargetObjOpntyLineItemMap = sourceRecIdTargetObjOpntyLineItemMap;
            PSC_ManageResultsHandler.insertAllOutputRecord(allObjectRecordList, returnOrderLineItemList, opportunityLineItemList, psciLines, roToPsciMap, opportunityToPsciMap, failedLineErrorMap);
            allObjectRecordList.clear(); //ClearMemory

            // Insert ProductRequired records
            /* PSC_ManageResultsHandler.insertProductRequiredRecords(productRequiredList, woToPsciMap, failedLineErrorMap);
            productRequiredList.clear(); //ClearMemory
            woToPsciMap.clear(); //ClearMemory */

            // Insert ReturnOrderLineItem records
            PSC_ManageResultsHandler.insertReturnOrderLineItemRecords(returnOrderLineItemList, roToPsciMap, failedLineErrorMap);
            returnOrderLineItemList.clear(); //ClearMemory
            roToPsciMap.clear();

            // Insert Opportunity Line Item
            manageResultsHandlerInstance.insertOpportunityLineItemRecords(opportunityLineItemList, opportunityToPsciMap, failedLineErrorMap);
            opportunityLineItemList.clear(); //ClearMemory
            opportunityToPsciMap.clear();

            if(!failedLineErrorMap.isEmpty()){ //If any of the records failed to insert then rollback that particular batch and update lines.
                failedBatchCount++;
                failedRecordsWithBatchNoMap.put(failedBatchCount, failedLineErrorMap);
                recordCountInBatchMap.put(failedBatchCount, psciLines.size());
                Database.rollback(savepoint);
                SvmxDatabase.updateRecord(psciLines);
            }
            else { //Update lines Status to OutputGenerated when all records are saved without any error
                for(ProductServiceCampaignItem pscItem : psciLines) {
                    pscItem.Status = 'OutputGenerated';
                }
                SvmxDatabase.updateRecord(psciLines);
            }
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch() execute() - Error= ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch: execute() - StackTrace= ' + e.getStackTraceString());
            failedBatchCount++;
            errorMessageCaptureFromCatch = errorMessageCaptureFromCatch + 'Error in execute method:\n' + 'Batch Number: ' + failedBatchCount + ' Error Message: ' + e.getMessage() + '\n';
            Database.rollback(savepoint);
            SvmxDatabase.updateRecord(psciLines);
        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug(LoggingLevel.DEBUG, 'PSC_GenerateOutputBatch: finish() - enter;');

        try{
            String logDetails = PSC_ManageResultsHandler.getLogDetails(failedRecordsWithBatchNoMap, recordCountInBatchMap, logRecord.SVMXA360__BatchId__c, totalNoOfRecords, pscRecordId);
            logDetails += errorMessageCaptureFromCatch;
            failedRecordsWithBatchNoMap.clear(); //ClearMemory
            recordCountInBatchMap.clear(); //ClearMemory

            if(logRecord != null){
                logRecord.SVMXA360__CompletedOn__c = DateTime.now();
                logRecord.SVMXA360__LogDetails__c = logDetails.length() > MAX_LOG_LENGTH ? logDetails.substring(0, MAX_LOG_LENGTH) : logDetails;
            }
            logDetails = null; //ClearMemory
            errorMessageCaptureFromCatch = null; //ClearMemory

            if (pscRecord != null) {
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
                Integer totalFailedRecords = Database.countQuery('SELECT count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId AND Status = \'Draft\' AND AssetId != null AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != \'NoDelivery\' WITH SECURITY_ENFORCED');

                //Send email to the email id that is configured in the associated Configuration record
                if(String.isNotBlank(pscRecord.SVMXA360__PSCConfigurationId__r.SVMXA360__Email__c)){
                    String emailBody = PSC_SearchCriteriaHandler.getEmailBodyForPscAdmin(Label.Label_OutputGenerationFor, pscRecord, totalNoOfRecords, totalFailedRecords, logRecord);            
                    
                    Messaging.SingleEmailMessage singleEmailMessageAdmin = new Messaging.SingleEmailMessage();
                    singleEmailMessageAdmin.setSubject(Label.Label_TypeNameofBatchProcess + ' - ' + Label.Label_OutputGenerationFor + ' ' + pscRecord.ProductServiceCampaignName + ' : ' + Label.Label_SuccessFailureLog);
                    singleEmailMessageAdmin.setSaveAsActivity(false);
                    singleEmailMessageAdmin.setHtmlBody(emailBody);
                    singleEmailMessageAdmin.toAddresses = new String[]{pscRecord.SVMXA360__PSCConfigurationId__r.SVMXA360__Email__c};
                    messages.add(singleEmailMessageAdmin);
                }
    
                //Send email to the owner of PSC record if SVMXA360__NotifyPSCOwner__c is checked to true
                if(pscRecord.SVMXA360__NotifyPSCOwner__c){
                    String emailBody = PSC_ManageResultsHandler.getEmailBodyForPSCOwner(pscRecord, totalNoOfRecords, totalFailedRecords, logRecord);            
                    
                    Messaging.SingleEmailMessage singleEmailMessageOwner = new Messaging.SingleEmailMessage();
                    singleEmailMessageOwner.setSubject(Label.Label_OutputRecordsForPSC + ' "' + pscRecord.ProductServiceCampaignName + '" ' + Label.Label_HaveBeenGenerated);
                    singleEmailMessageOwner.setSaveAsActivity(false);
                    singleEmailMessageOwner.setHtmlBody(emailBody);
                    singleEmailMessageOwner.toAddresses = new String[]{pscRecord.Owner.Email};
                    messages.add(singleEmailMessageOwner);
                }
    
                if (!messages.isEmpty()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                }
            }
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch() finish() - Error= ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'PSC_GenerateOutputBatch: finish() - StackTrace= ' + e.getStackTraceString());
            if (logRecord != null) {
                String errorMsg = '\n' + e.getMessage();
                if ((logRecord.SVMXA360__LogDetails__c + errorMsg).length() <= MAX_LOG_LENGTH) {
                    logRecord.SVMXA360__LogDetails__c = logRecord.SVMXA360__LogDetails__c + errorMsg;
                } else {
                    logRecord.SVMXA360__LogDetails__c = logRecord.SVMXA360__LogDetails__c.substring(0, MAX_LOG_LENGTH - errorMsg.length()) + errorMsg;
                }
            }
        }
        finally {
            if(logRecord != null){
                SvmxDatabase.updateRecord(logRecord);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'PSC_GenerateOutputBatch: finish() - exit;');
    }
}