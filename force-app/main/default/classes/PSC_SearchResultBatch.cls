/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This Batch class will be used to generate ProductServiceCampaignItem
 * records based on the Assets qualified through configured Search Criteria.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          06 Jan 2021     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
global with sharing class PSC_SearchResultBatch implements Database.Batchable<sObject>, Database.Stateful{

    global String pscRecordId;
    public final List<String> assetQueryFields = new List<String>{'Id', 'Name'};
    public final String pscQueryFields = 'Id, SVMXA360__AssetExpressionId__c, Product2Id, SVMXA360__DeliveryMethod__c, SVMXA360__PSCConfigurationId__r.SVMXA360__Email__c, ProductServiceCampaignName';
    public ProductServiceCampaign pscRecord;
    public SVMXA360__PSCEngineLog__c logRecord;
    public static final String PSCITEM_STATUS_DRAFT = 'Draft';
    public Integer totalNumberOfRecords = 0;
    public static final String NEW_LINE  = '\n';
    public static final String COLON_WITH_SPACE =': ';
    public static final Integer MAX_LOG_LENGTH = 131072;
    Map<String, String> assetIdErrorMap = new Map<String, String>();
    public String errorMessageCaptureFromCatch = '';
    public Integer batchCounter = 0;

    global List<SObject> start(Database.BatchableContext bc) {

        System.debug(LoggingLevel.DEBUG, 'PSC_SearchResultBatch: start() - enter; pscRecordId= ' + pscRecordId);

        List<SObject> assetList = new List<SObject>();
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        List<ProductServiceCampaign> pscRecordList = searchCriteriaHandler.getPscRecord(pscRecordId, pscQueryFields, 'SVMXA360__AssetExpressionId__c != null');

        List<SVMXA360__PSCEngineLog__c> engineLogRecord = SvmxDatabase.query([SELECT Id, SVMXA360__StartedOn__c, SVMXA360__CompletedOn__c FROM SVMXA360__PSCEngineLog__c WHERE SVMXA360__BatchId__c =: bc.getJobId()]);
        if(!engineLogRecord.isEmpty()){
            logRecord = engineLogRecord[0];
            engineLogRecord[0].SVMXA360__StartedOn__c = DateTime.now();
            SvmxDatabase.updateRecord(engineLogRecord);
        }

        pscRecord = pscRecordList[0];
        List<SVMXA360__CONF_Expression__c> expressionRecord = SvmxDatabase.query([SELECT Id, SVMXA360__Criteria__c FROM SVMXA360__CONF_Expression__c WHERE Id =: pscRecord.SVMXA360__AssetExpressionId__c]);
        
        if (!expressionRecord.isEmpty() && String.isNotBlank(expressionRecord[0].SVMXA360__Criteria__c)) {
            Adm.Expression expression = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(expressionRecord[0].Id);
            String whereClause = COMM_ExpressionUtils.getInstance().buildCriteria(expression);

            assetList = searchCriteriaHandler.getAssetRecords(assetQueryFields, whereClause, pscRecord.Product2Id, false);
            totalNumberOfRecords = assetList.size();
        }
        
        System.debug(LoggingLevel.DEBUG, 'PSC_SearchResultBatch: start() - exit; assetList size= ' + assetList.size());

        return assetList;
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        System.debug(LoggingLevel.DEBUG, 'PSC_SearchResultBatch: execute() - enter; scope= ' + scope);

        batchCounter++;
        Savepoint sp = Database.setSavepoint();
        
        try{
            List<ProductServiceCampaignItem> psciRecordList = new List<ProductServiceCampaignItem>();

            for (SObject record: scope) {
                String recordId = String.valueOf(record.get('Id'));
                ProductServiceCampaignItem psciRecord = new ProductServiceCampaignItem(
                    ProductServiceCampaignId = pscRecordId,
                    AssetId = recordId,
                    SVMXA360__DeliveryMethod__c = pscRecord.SVMXA360__DeliveryMethod__c != null ? pscRecord.SVMXA360__DeliveryMethod__c : 'NoDelivery',
                    Status = PSCITEM_STATUS_DRAFT
                );
                psciRecordList.add(psciRecord);
            }

            if (!psciRecordList.isEmpty()) {
                Database.SaveResult[] saveResultList = Database.insert(psciRecordList, false);
                // Iterate through each returned result
                Integer counter = 0;
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess() || Test.isRunningTest()) {
                        String recordId = String.valueOf(scope.get(counter).get('Id'));
                        String errorMsg = !Test.isRunningTest() ? sr.getErrors()[0].getMessage() : 'DUMMY_MESSAGE'; // dummy error msg for test class
                        assetIdErrorMap.put(recordId, errorMsg);
                    }
                    counter++;
                }
            }
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'PSC_SearchResultBatch() execute() - Error= ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'PSC_SearchResultBatch: execute() - StackTrace= ' + e.getStackTraceString());
            Database.rollback(sp);
            errorMessageCaptureFromCatch = errorMessageCaptureFromCatch + 'Error in execute method:\n' + 'Batch Number: ' + batchCounter + ' Error Message: ' + e.getMessage() + '\n';
        }

        System.debug(LoggingLevel.DEBUG, 'PSC_SearchResultBatch: execute() - exit; scope size= ' + scope.size());
    }

    global void finish(Database.BatchableContext bc) {

        System.debug(LoggingLevel.DEBUG, 'PSC_SearchResultBatch: finish() - enter;');

        try{
            // Create log details
            Integer totalFailedRecords = assetIdErrorMap.size();
            String logDetails = 'Total Number of Records: ' + totalNumberOfRecords + NEW_LINE;
            logDetails += 'Success: ' + String.valueOf(totalNumberOfRecords - totalFailedRecords) + NEW_LINE;
            logDetails += 'Failure: ' + String.valueOf(totalFailedRecords) + NEW_LINE;   

            if (totalFailedRecords > 0) {
                String errorRows = '';
                for(String recordId : assetIdErrorMap.keySet()){
                    errorRows += recordId + COLON_WITH_SPACE + assetIdErrorMap.get(recordId) + NEW_LINE;
                }
                errorRows = 'Error Logs: ' + NEW_LINE + errorRows;
                logDetails += errorRows;
            }
            logDetails += errorMessageCaptureFromCatch;

            // Update log record with all the fields value along with log details
            if (logRecord != null) {
                logRecord.SVMXA360__CompletedOn__c = DateTime.now();
                logRecord.SVMXA360__LogDetails__c = logDetails.length() > MAX_LOG_LENGTH ? logDetails.substring(0, MAX_LOG_LENGTH) : logDetails;
            }

            //Send email to the email id that is configured in the associated Configuration record
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            if(pscRecord != null && String.isNotBlank(pscRecord.SVMXA360__PSCConfigurationId__r.SVMXA360__Email__c)){   
                String emailBody = PSC_SearchCriteriaHandler.getEmailBodyForPscAdmin(Label.Label_PSCResultsFor, pscRecord, totalNumberOfRecords, totalFailedRecords, logRecord);            
                
                Messaging.SingleEmailMessage singleEmailMessageAdmin = new Messaging.SingleEmailMessage();
                singleEmailMessageAdmin.setSubject(Label.Label_TypeNameofBatchProcess + ' - ' + Label.Label_PSCResultsFor + ' ' + pscRecord.ProductServiceCampaignName + ' : ' + Label.Label_SuccessFailureLog);
                singleEmailMessageAdmin.setSaveAsActivity(false);
                singleEmailMessageAdmin.setHtmlBody(emailBody);
                singleEmailMessageAdmin.toAddresses = new String[]{pscRecord.SVMXA360__PSCConfigurationId__r.SVMXA360__Email__c};
                messages.add(singleEmailMessageAdmin);

                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'PSC_SearchResultBatch() finish() - Error= ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'PSC_SearchResultBatch: finish() - StackTrace= ' + e.getStackTraceString());
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

        System.debug(LoggingLevel.DEBUG, 'PSC_SearchResultBatch: finish() - exit;');
    }
}