/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods with actual implementation which will be
 * comsumed by the class PSC_SearchCriteria_LS.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          18 Dec 2020     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class PSC_SearchCriteriaHandler {

    private final String NO_CRITERIA = 'NO_CRITERIA';
    private final String CRITERIA_DEFINED = 'CRITERIA_DEFINED';
    private final String RUNNING_SEARCH = 'RUNNING_SEARCH';
    private final String RESULT_LINES_GENERATED = 'RESULT_LINES_GENERATED';
    private final String RESULT_LINES_DELIVERED = 'RESULT_LINES_DELIVERED';
    public static final List<String> BATCH_QUEUED_STATUS_LIST = new List<String> {'Holding', 'Queued'};
    public static final List<String> BATCH_IN_PROGRESS_LIST = new List<String> {'Preparing', 'Processing'};

    private final List<String> PREVIEW_FIELD_NAMES_FOR_ASSET_QUERY = new List<String> { 'Name', 'SerialNumber', 'Location.Name' };

    private static final String PSC_STATUS_INPROGRESS = 'In Progress';

    public static final timeZone userTimeZone = UserInfo.getTimeZone();
    public static final String userTimeZoneDisplayName = userTimeZone.getDisplayName();

    /**
     * This method is used to retrieve current status of the Search Criteria card component for the requested PSC record.
     * 
     * @param pscRecordId Record Id of the PSC record for which the current status needs to be fetched.
     * 
     * @return Returns instance of Psc.SearchCriteria with status and Search Criteria data.
     */
    public Psc.SearchCriteria getSearchCriteriaStatus(final String pscRecordId) {

        System.debug(LoggingLevel.DEBUG, 'getSearchCriteriaStatus() - enter; pscRecordId= ' + pscRecordId);
        
        Psc.SearchCriteria response = new Psc.SearchCriteria();
        
        try {
            if( String.isBlank(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'getSearchCriteriaStatus() : Invalid request parameters. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            List<ProductServiceCampaign> pscRecord = getPscRecord(pscRecordId, 'Product2Id, Product2.Name, SVMXA360__AssetExpressionId__c', null);

            if (pscRecord.isEmpty()) {
                System.debug(LoggingLevel.ERROR, 'getSearchCriteriaStatus() : Record Not Found. pscRecord= ' + pscRecord);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.RECORD_NOT_EXISTS);
            }

            response.id = pscRecordId;
            if (pscRecord[0].SVMXA360__AssetExpressionId__c == null) {
                response.status = NO_CRITERIA;
            } else {
                response.status = CRITERIA_DEFINED;

                if (isSearchResultBatchRunning(pscRecordId)) {
                    response.status = RUNNING_SEARCH;
                    response.expectedRecordCount = getExpectedRecordCount(pscRecordId);
                    response.createdRecordCount = Database.countQuery('SELECT count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId WITH SECURITY_ENFORCED');
                } else if (isResultsAlreadyGenerated(pscRecordId)) {
                    response.status = RESULT_LINES_GENERATED;

                    if (isResultLinesDelivered(pscRecordId)) {
                        response.status = RESULT_LINES_DELIVERED;
                    }
                }

                // get criteria information
                response.expression = new ADM_ExpressionServiceImpl().getExpressionWithDetails(pscRecord[0].SVMXA360__AssetExpressionId__c);
                response.productIdForPsc = pscRecord[0].Product2Id;
                response.productNameForPsc = pscRecord[0].Product2.Name;
            }
        }
        catch(SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'getSearchCriteriaStatus() : Failed to retrueve current status. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getSearchCriteriaStatus() : Failed to retrieve current status. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getSearchCriteriaStatus() - exit; response ' + response);
        }
        
        return response;
    }

    /**
     * This method is used to save Search Criteria for the PSC record.
     * 
     * @param searchCriteria has expressions and productIdForPsc which needs to be saved for current PSC record.
     * 
     * @return Returns instance of Psc.SearchCriteria with Search Criteria and product data.
     */
    public Psc.SearchCriteria saveSearchCriteria(Psc.SearchCriteria searchCriteria) {

        System.debug(LoggingLevel.DEBUG, 'saveSearchCriteria() - enter; searchCriteria= ' + searchCriteria);
        
        Savepoint savepoint;
        Psc.SearchCriteria response = new Psc.SearchCriteria();

        try {
            savepoint = Database.setSavepoint();

            if(searchCriteria == null || searchCriteria.expression == null) {
                System.debug(LoggingLevel.ERROR, 'saveSearchCriteria() : Invalid request parameters. searchCriteria= ' + searchCriteria);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            if (isSearchResultBatchRunning(searchCriteria.id)){
                System.debug(LoggingLevel.ERROR, 'saveSearchCriteria() : Batch is running. pscRecordId= ' + searchCriteria.id);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.BATCH_IN_PROGRESS + ' ' + searchCriteria.id);
            }
            
            response.expression = new ADM_ExpressionServiceImpl().saveExpression(searchCriteria.expression);
            response.productIdForPsc = searchCriteria.productIdForPsc;
            response.id = searchCriteria.id;

            //Update ProductId and Asset Expression field on PSC record
            List<ProductServiceCampaign> pscRecord = SvmxDatabase.query([SELECT Product2Id, SVMXA360__AssetExpressionId__c FROM ProductServiceCampaign WHERE Id =: searchCriteria.id]);
            pscRecord[0].Product2Id = searchCriteria.productIdForPsc;
            pscRecord[0].SVMXA360__AssetExpressionId__c = response.expression.id;
            SvmxDatabase.updateRecord(pscRecord);

            //Delete already generarated records and logs
            deleteAlreadyGeneratedPsciRecords(searchCriteria.id);
        }
        catch(SvmxSystem.SvmxNestedException e) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'saveSearchCriteria() : Failed to save the SearchCriteria. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'saveSearchCriteria() : Failed to save the SearchCriteria. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'saveSearchCriteria() - exit; response ' + response);
        }

        return response;
    }

    /**
     * This method is used to retrieve Results Preview data for the requested PSC record.
     * 
     * @param pscRecordId record id of the PSC record for which Results Preview data need to be fetched.
     * 
     * @return Returns instance of Psc.ResultsPreview with retrieved data.
     */
    public Psc.ResultsPreview getResultsPreview(final String pscRecordId) {

        System.debug(LoggingLevel.DEBUG, 'getResultsPreview() - enter; pscRecordId= ' + pscRecordId);

        Psc.ResultsPreview response = new Psc.ResultsPreview();
        
        try {
            if(String.isBlank(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'getResultsPreview() : Invalid request parameters. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            // Get PSC record
            List<ProductServiceCampaign> pscRecord = getPscRecord(pscRecordId, 'SVMXA360__AssetExpressionId__c, Product2Id', 'SVMXA360__AssetExpressionId__c != null');
            
            if (pscRecord.isEmpty()) {
                System.debug(LoggingLevel.ERROR, 'getResultsPreview() : Record Not Found. pscRecord= ' + pscRecord);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.RECORD_NOT_EXISTS);
            }

            Adm.Expression expression = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(pscRecord[0].SVMXA360__AssetExpressionId__c);
            String whereClauseForAsset = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
            String productIdForAssetQuery = pscRecord[0].Product2Id;

            // Query Asset records based on configured criteria
            List<Asset> assetList = getAssetRecords(PREVIEW_FIELD_NAMES_FOR_ASSET_QUERY, whereClauseForAsset, productIdForAssetQuery, true);

            if (!assetList.isEmpty()) {

                // create preview results list
                response.resultsPreviewDetails = createResultPreviewList(assetList);

                // get count of assets returned based on configured criteria
                response.recordCount = getCountOfAssets(whereClauseForAsset, productIdForAssetQuery);
            } else {
                response.resultsPreviewDetails = new List<Psc.ResultPreviewDetail>();
                response.recordCount = 0;
            }
            // set default column header names for the UI
            response.columnInformations = getColumnNamesForPreview();
            response.maxAllowedSearchResults = getAllowedResultsSettingForSearchResult();
            response.id = pscRecordId;
        }
        catch(SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'getResultsPreview() : Failed to retrieve the Results Preview. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getResultsPreview() : Failed to retrieve the Results Preview. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getResultsPreview() - exit; response ' + response);
        }
        
        return response;
    }

    /**
     * This method is used to initiate PSC_SearchResultBatch batch for the requested PSC record.
     * 
     * @param pscRecordId record id of the PSC record for which PSC_SearchResultBatch batch needs to be initiated.
     * 
     * @return Returns boolean value - true if successfull execution.
     * Otherwise return false if execution fails.
     */
    public Boolean initiateSearchResultBatch(final String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'initiateSearchResultBatch() - enter; pscRecordId= ' + pscRecordId);

        Boolean isBatchInitiatedSuccessfully = false;
        Savepoint savepoint;

        try{
            savepoint = Database.setSavepoint();

            if(String.isBlank(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Invalid request parameters. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            List<String> fieldListForPsc = new List<String>{'Id', 'Status'};
            List<ProductServiceCampaign> pscRecord = getPscRecord(pscRecordId, String.join(fieldListForPsc, ',') , null);
            if (pscRecord.isEmpty()) {
                System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Record Not Found. pscRecord= ' + pscRecord);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.RECORD_NOT_EXISTS);
            }

            if (isResultsAlreadyGenerated(pscRecordId)) {
                System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Search Results already generated for this PSC. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.RESULTS_ALREADY_GENERATED + pscRecordId);
            }

            if(isSearchResultBatchRunning(pscRecordId)){
                System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Batch is already running. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.BATCH_IN_PROGRESS + pscRecordId);
            }

            Integer expectedRecordCount = getExpectedRecordCount(pscRecordId);
            Integer allowedResultsSetting = getAllowedResultsSettingForSearchResult();
            if(expectedRecordCount == 0 || expectedRecordCount > allowedResultsSetting) {
                System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Search Results either zero or exceeding allowed search results. pscRecordId= ' + pscRecordId);
                throw new SvmxSystem.SvmxNestedException(Label.Label_ExceedMaximumAllowedRecords + ' ' + allowedResultsSetting);
            }

            //Initiate the batch
            PSC_SearchResultBatch searchResultBatch = new PSC_SearchResultBatch();
            searchResultBatch.pscRecordId = pscRecordId;
            Integer batchSize = getBatchSizeForSearchResult();
            Id batchId = Database.executeBatch(searchResultBatch, batchSize);

            //Create PSC engine log record
            SVMXA360__PSCEngineLog__c pscEngineLog = new SVMXA360__PSCEngineLog__c();
            pscEngineLog.SVMXA360__ProductServiceCampaignId__c = pscRecordId;
            pscEngineLog.SVMXA360__BatchId__c = batchId;
            pscEngineLog.SVMXA360__LogType__c = 'PSCIGeneration';
            SvmxDatabase.insertRecord(pscEngineLog);

            //Update status field of the PSC record to 'In Progress'
            pscRecord[0].Status = PSC_STATUS_INPROGRESS;
            SvmxDatabase.updateRecord(pscRecord);
            isBatchInitiatedSuccessfully = true;
        }
        catch(SvmxSystem.SvmxNestedException e) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Failed to initiate PSC_SearchResultBatch batch. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Failed to initiate PSC_SearchResultBatch batch. Error= ' + e.getStackTraceString());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'initiateSearchResultBatch() - exit; isBatchInitiatedSuccessfully= ' + isBatchInitiatedSuccessfully);
        }
        
        return isBatchInitiatedSuccessfully;
    }

    private void deleteAlreadyGeneratedPsciRecords(final String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'deleteAlreadyGeneratedPsciRecords() - enter; pscRecordId= ' + pscRecordId);

        List<SVMXA360__PSCEngineLog__c> pscEngineLogList = SvmxDatabase.query([SELECT Id FROM SVMXA360__PSCEngineLog__c WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId]);
        List<ProductServiceCampaignItem> psciRecordList = SvmxDatabase.query([SELECT Id FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId]);
        if(!pscEngineLogList.isEmpty()){
            SvmxDatabase.deleteRecord(pscEngineLogList);
        }
        if(!psciRecordList.isEmpty()){
            List<Id> psciRecordIds = new List<Id>();
            for (ProductServiceCampaignItem psci : psciRecordList) {
                psciRecordIds.add(psci.Id);
            }
            SvmxDatabase.deleteRecord(psciRecordList);
            hardDeletePsciRecords(psciRecordIds);
        }

        System.debug(LoggingLevel.DEBUG, 'deleteAlreadyGeneratedPsciRecords() - exit;');
    }

    @future
    public static void hardDeletePsciRecords(List<Id> psciList) {
        Database.emptyRecycleBin(psciList);
    }

    public Integer getExpectedRecordCount(String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'getExpectedRecordCount() - enter; pscRecordId= ' + pscRecordId);

        Integer expectedRecordCount = 0;
        // Get PSC record
        List<ProductServiceCampaign> pscRecord = getPscRecord(pscRecordId, 'SVMXA360__AssetExpressionId__c, Product2Id', 'SVMXA360__AssetExpressionId__c != null');
            
        if (pscRecord.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'getExpectedRecordCount() : Record Not Found. pscRecord= ' + pscRecord);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.RECORD_NOT_EXISTS);
        }

        Adm.Expression expression = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(pscRecord[0].SVMXA360__AssetExpressionId__c);
        String whereClauseForAsset = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        String productIdForAssetQuery = pscRecord[0].Product2Id;

        expectedRecordCount = getCountOfAssets(whereClauseForAsset, productIdForAssetQuery);

        System.debug(LoggingLevel.DEBUG, 'getExpectedRecordCount() - exit; expectedRecordCount= ' + expectedRecordCount);

        return expectedRecordCount;
    }

    public Boolean isSearchResultBatchRunning(String pscRecordId) {
        System.debug(LoggingLevel.DEBUG, 'isSearchResultBatchRunning() - enter; pscRecordId= ' + pscRecordId);

        if(String.isBlank(pscRecordId)) {
            System.debug(LoggingLevel.ERROR, 'isSearchResultBatchRunning() : Invalid parameter. pscRecordId= ' + pscRecordId);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        List<String> batchStatusInProgressList = new List<String> ();
        batchStatusInProgressList.addAll(BATCH_QUEUED_STATUS_LIST);
        batchStatusInProgressList.addAll(BATCH_IN_PROGRESS_LIST);

        List<String> batchIdList = new List<String> ();

        // collect all the batches related to PSC of type PSCIGeneration
        List<SVMXA360__PSCEngineLog__c> engineLogList = SvmxDatabase.query([SELECT SVMXA360__BatchId__c FROM SVMXA360__PSCEngineLog__c WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId AND SVMXA360__LogType__c = 'PSCIGeneration' AND SVMXA360__BatchId__c != null]);
        for(SVMXA360__PSCEngineLog__c log : engineLogList){
            batchIdList.add(log.SVMXA360__BatchId__c);
        }
        return Test.isRunningTest() ? false : !batchIdList.isEmpty() && Database.countQuery('SELECT count() FROM AsyncApexJob WHERE Id IN : batchIdList AND Status IN : batchStatusInProgressList') > 0 ? true : false;
    }

    private Integer getBatchSizeForSearchResult() {
        System.debug(LoggingLevel.DEBUG, 'getBatchSizeForSearchResult() - enter;');
        
        Integer batchSizeForSearch = 250; //Default value

        Schema.DescribeSobjectResult describeResult = COMM_DescribeManager.getInstance().getObjectDescribe('SVMXA360__CONF_PSCConfiguration__c');
        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosByDeveloperName();
        String recordTypeIdOfSetting =  recordTypeInfoMap.get('PSC_Settings').getRecordTypeId();

        List<SVMXA360__CONF_PSCConfiguration__c> settingConfiguration = SvmxDatabase.query([SELECT SVMXA360__SearchBatchSize__c FROM SVMXA360__CONF_PSCConfiguration__c WHERE SVMXA360__DeveloperName__c = 'Default_PSC_Settings' AND RecordTypeId =: recordTypeIdOfSetting LIMIT 1]);
        if (settingConfiguration != null && !settingConfiguration.isEmpty() && settingConfiguration[0].SVMXA360__SearchBatchSize__c != null) {
            batchSizeForSearch = Integer.valueOf(settingConfiguration[0].SVMXA360__SearchBatchSize__c);
        }

        System.debug(LoggingLevel.DEBUG, 'getBatchSizeForSearchResult() - exit;');

        return batchSizeForSearch;
    }

    private Integer getAllowedResultsSettingForSearchResult() {
        System.debug(LoggingLevel.DEBUG, 'getAllowedResultsSettingForSearchResult() - enter;');
        
        Integer allowedResultsSetting = 500; //Default value

        Id recordTypeIdOfSetting = COMM_RecordTypeManager.getInstance().getRecordTypeId( SVMXA360__CONF_PSCConfiguration__c.getSObjectType(), 'PSC_Settings' );

        List<SVMXA360__CONF_PSCConfiguration__c> settingConfiguration = SvmxDatabase.query([SELECT SVMXA360__SearchResultsPerPSC__c FROM SVMXA360__CONF_PSCConfiguration__c WHERE SVMXA360__DeveloperName__c = 'Default_PSC_Settings' AND RecordTypeId =: recordTypeIdOfSetting LIMIT 1]);
        if (settingConfiguration != null && !settingConfiguration.isEmpty() && settingConfiguration[0].SVMXA360__SearchResultsPerPSC__c != null) {
            allowedResultsSetting = Integer.valueOf(settingConfiguration[0].SVMXA360__SearchResultsPerPSC__c);
        }

        System.debug(LoggingLevel.DEBUG, 'getAllowedResultsSettingForSearchResult() - exit;');

        return allowedResultsSetting;
    }

    private Boolean isResultsAlreadyGenerated(String pscRecordId) {
        Integer psciCount = Database.countQuery('SELECT count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId');
        return psciCount > 0 ? true : false;
    }

    private Boolean isResultLinesDelivered(String pscRecordId) {
        Integer psciCount = Database.countQuery('SELECT count() FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecordId AND SVMXA360__DeliveryMethod__c != null AND SVMXA360__DeliveryMethod__c != \'NoDelivery\' AND Status = \'OutputGenerated\' WITH SECURITY_ENFORCED');
        return psciCount > 0 ? true : false;
    }

    public List<ProductServiceCampaign> getPscRecord(String pscRecordId, String queryFields, String whereClause) {
        System.debug(LoggingLevel.DEBUG, 'getPscRecord() - enter;');

        if(String.isBlank(pscRecordId) || String.isBlank(queryFields)) {
            System.debug(LoggingLevel.ERROR, 'getPscRecord() : Invalid parameter. pscRecordId= ' + pscRecordId + ' ,queryFields= ' + queryFields);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        String query = 'SELECT ' + queryFields + ' FROM ProductServiceCampaign WHERE Id = \'' + String.escapeSingleQuotes(pscRecordId) + '\'';

        if(String.isNotBlank(whereClause)) {
            query = query + ' AND ' + whereClause;
        }

        List<ProductServiceCampaign> pscRecordList = SvmxDatabase.query(query);

        System.debug(LoggingLevel.DEBUG, 'getPscRecord() - exit;');

        return pscRecordList;
    }

    private Integer getCountOfAssets(String whereClauseForAsset, String productIdForAssetQuery) {
        
        Schema.DescribeSobjectResult objectDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        if (! objectDescribe.isAccessible()) {
            System.debug(LoggingLevel.ERROR, 'getCountOfAssets() : Object is not Accessible for query records. Object Name: Asset');
            throw new SvmxSystem.FLSException(ErrorMessage.RESTRICTED_ACCESS + ' Object Name: Asset');
        }

        Map<String, Schema.SObjectField> objectFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('Asset');
        Schema.DescribeFieldResult fieldDescribe = COMM_DescribeManager.getInstance().getFieldDescribe(objectFieldMap.get('Product2Id'));
        if (! fieldDescribe.isAccessible()) {
            System.debug(LoggingLevel.ERROR, 'getCountOfAssets() : Field is not Accessible for query records. Field Name: Product2Id');
            throw new SvmxSystem.FLSException(ErrorMessage.RESTRICTED_ACCESS + ' Field Name: Product2Id');
        }

        String assetQuery = 'SELECT Count() FROM Asset WHERE (' +  whereClauseForAsset + ') ';

        if (String.isNotBlank(productIdForAssetQuery)) {
            assetQuery = assetQuery + ' AND Product2Id = \'' + productIdForAssetQuery + '\'';
        }
        return Database.countQuery(assetQuery);
    }

    public List<Asset> getAssetRecords(List<String> fieldNames, String whereClauseForAsset, String productIdForAssetQuery, Boolean isPreviewResults) {
        String fieldString = String.join(fieldNames, ',');

        String assetQuery = 'SELECT ' + fieldString + ' FROM Asset WHERE (' +  whereClauseForAsset + ') ';

        if (String.isNotBlank(productIdForAssetQuery)) {
            assetQuery = assetQuery + ' AND Product2Id = \'' + String.escapeSingleQuotes(productIdForAssetQuery) + '\'';
        }

        if (isPreviewResults) {
            assetQuery = assetQuery + ' LIMIT 5';
        }

        return SvmxDatabase.query(assetQuery);
    }

    private List<Psc.ResultPreviewDetail> createResultPreviewList(List<Asset> assetList) {
        List<Psc.ResultPreviewDetail> resultPreviewList = new List<Psc.ResultPreviewDetail>();

        for (Asset assetRec : assetList) {
            Psc.ResultPreviewDetail resultPreview = new Psc.ResultPreviewDetail();
            resultPreview.item = assetRec.Name;
            resultPreview.serialNumber = assetRec.SerialNumber;
            resultPreview.location = assetRec.Location.Name;
            resultPreviewList.add(resultPreview);
        }

        return resultPreviewList;
    }

    private List<Psc.ColumnInformation> getColumnNamesForPreview() {
        List<Psc.ColumnInformation> columnList = new List<Psc.ColumnInformation>();

        Psc.ColumnInformation column1 = new Psc.ColumnInformation();
        column1.label = System.Label.Label_Item;
        column1.apiName = 'item';
        column1.dataType = 'STRING';
        columnList.add(column1);

        Psc.ColumnInformation column2 = new Psc.ColumnInformation();
        column2.label = System.Label.Label_SerialNumber;
        column2.apiName = 'serialNumber';
        column2.dataType = 'STRING';
        columnList.add(column2);

        Psc.ColumnInformation column3 = new Psc.ColumnInformation();
        column3.label = System.Label.Label_Location;
        column3.apiName = 'location';
        column3.dataType = 'STRING';
        columnList.add(column3);

        return columnList;
    }

    /**
     * Used to create email body for PSC admin once Search Result batch gets completed
     */ 
    public static String getEmailBodyForPscAdmin(String batchType, ProductServiceCampaign pscRecord, Integer totalNoOfRecord, Integer failureCount, SVMXA360__PSCEngineLog__c pscLog){

        Datetime startedOn = getUserDateTime(pscLog.SVMXA360__StartedOn__c); // converting it to user time zone for email
        Datetime completedOn = getUserDateTime(pscLog.SVMXA360__CompletedOn__c); // converting it to user time zone for email

        String orgBaseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/';
        String pscTitle = pscRecord.ProductServiceCampaignName;
        String pscLogLink = '<a href="' + orgBaseUrl + pscLog.Id + '" target ="__blank">' + orgBaseUrl + pscLog.Id + '</a>';
        String processingTime = String.valueOf(((completedOn).getTime() - (startedOn).getTime()) / (1000 * 60));
        String emailBody = Label.Label_SystemGeneratedEmail + '<br/><br/>';
        emailBody += Label.Label_PscProcessCompleted + '<br/><br/>';
        emailBody += '<b>' + Label.Label_TypeNameofBatchProcess + ': ' + '</b>' + batchType + ' ' + pscTitle + ' ' + '<br/><br/>';
        emailBody += '<b>' + Label.Label_RecordstoProcess + ' ' + '</b>' + totalNoOfRecord + '<br/>';
        emailBody += '<b>' + Label.Label_SuccessForEmail + ' ' + '</b>' + (totalNoOfRecord - failureCount) + '<br/>';
        emailBody += '<b>' + Label.Label_FailedForEmail + ' ' + '</b>' + failureCount + '<br/><br/>';
        emailBody += '<b>' + Label.Label_PSCProcessStartTime + ' ' + '</b>' + startedOn + ' - ' + userTimeZoneDisplayName + '<br/>';
        emailBody += '<b>' + Label.Label_PSCProcessFinishTime + ' ' + '</b>' + completedOn + ' - ' + userTimeZoneDisplayName + '<br/>';
        emailBody += '<b>' + Label.Label_ElapsedTimeInMinutes + ' ' + '</b>' + processingTime + '<br/><br/>';
        emailBody += Label.Label_ReviewTheLogRecord + '<br/>' + pscLogLink + '<br/>';
        return emailBody;
    }

    /**
    * Used to convert gmt time to logged in user time
    */ 
    public static DateTime getUserDateTime(DateTime gmtDateTime){
        return gmtDateTime.addSeconds((userTimeZone.getOffset(gmtDateTime)/1000));
    }
}