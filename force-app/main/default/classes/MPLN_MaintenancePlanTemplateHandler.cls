/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Actual implementation for AuraEnabled, Maintenance Plan  Automation flow and 
 * Miantenance Plan CPQ service
 * 
 * 
 *
 * @author Jaysukh Patel
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jaysukh Patel           10 May 2021     Created.
 *              Manish Kushwah          11 May 2021     Added new method getAssetList - A360AM-556
 *              Soumyaranjan Pati       11 May 2021     Updated code for A360AM-554
 *              Manish Kushwah          17 May 2021     Added status check in the query for methods getMaintenanceAssets and getAssetList
 *              Manish Kushwah          20 May 2021     Added new method executeMaintenancePlan and its related methods
 *              Manish Kushwah          24 May 2021     Methods getMaintenanceAssets, executeMaintenancePlan are updated for source Location
 *              Manish Kushwah          25 May 2021     Methods getMaintenanceAssets, executeMaintenancePlan are updated for source ServiceContract
 * A360AM-627   Manish Kushwah          27 May 2021     Methods getMaintenanceAssets, executeMaintenancePlan are udpated for Asset Status values
 * A360AM-670   Jaysukh Patel           3 June 2021.    Removed Obsolete status check for asset query in getMaintenanceAssets method
 *                                      4 June 2021     Query changes for assetStatus getAssetList
 * A360AM-370   Jaysukh Patel           23 Jul 2021     Updated method getMaintenanceAssets definition (for new wrapper) and added code to include parent and child for asset
 * A360AM-1094  Jaysukh Patel           25 Aug 2021     addMaintenanceAssets service implementation for CPQ use case
 * A360AM-1087  Manish Kushwah          26 Aug 2021     createMaintenancePlan service for CPQ
 * A360AM-1254  Jaysukh Patel           18 Sep 2021     updated implimentation with new wrapper - MaintenancePlanData
 * A360AM-1514  Manish Kushwah          16 Nov 2021     Support of Criteria/Condition Based Maintenance Work Rule in Flows, MP Authoring and CPQ APIs.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class MPLN_MaintenancePlanTemplateHandler {

    private final Integer FREQUENCY_VALUE = 1; // TODO - Hardcoded field value for this release. Next release will remove it once these fields are not required by Salesforce
    private final String FREQUENCY_TYPE_VALUE = 'Days'; // TODO - Hardcoded field value for this release. Next release will remove it once these fields are not required by Salesforce
    private final String MAINTENANCE_PLAN = 'Parent is Maintenance Plan';
    private final String MAINTENANCE_ASSET = 'Parent is Maintenance Asset';
    private final List<String> mWorkRuleTemplateFieldList = new List<String>{
        'Name', 'SVMXA360__RecurrencePattern__c', 'SVMXA360__SortOrder__c', 'SVMXA360__TemplateType__c',
        'SVMXA360__WorkTypeId__c', 'SVMXA360__ApplicableProductId__c', 'SVMXA360__MaintenancePlanTemplateId__c',
        'SVMXA360__Type__c', 'SVMXA360__RecordsetFilterCriteriaId__c'
    };
    private final List<String> mPlanTemplateFieldList = new List<String>{
        'Name', 'SVMXA360__DoesAutoGenerateWorkOrders__c', 'SVMXA360__Description__c', 'SVMXA360__DoesGenerateUponCompletion__c',
        'SVMXA360__GenerationHorizon__c', 'SVMXA360__GenerationTimeframe__c', 'SVMXA360__GenerationTimeframeType__c',
        'SVMXA360__MaintenancePlanDuration__c', 'SVMXA360__MaintenancePlanUnitOfTime__c', 'SVMXA360__MaintenanceWindowEndDays__c',
        'SVMXA360__MaintenanceWindowStartDays__c', 'SVMXA360__SvcApptGenerationMethod__c', 'SVMXA360__WorkOrderGenerationMethod__c',
        'SVMXA360__WorkTypeId__c', 'SVMXA360__IsActive__c'
    };
    Map<Id, Id> productIdApplicableProductIdMap = new Map<Id, Id>();
    Map<String, Id> productFamilyApplicableProductIdMap = new Map<String, Id>();
    public Boolean isAuthoring = false;
    private ServiceContract serviceContract = null;
    private final Integer REQUIRED_DML_ROW_COUNT = 2; //Deducting 2 from count to create/update Failure Authoring Log record

    private Map<String, Schema.SObjectField> mWorkRuleFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenanceWorkRule');
    private Map<String, Schema.SObjectField> mPlanFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenancePlan');
    private final String TYPE_FIELD = 'Type';
    private final String RECORDSET_FILTER_CRITERIA_FIELD = 'RecordsetFilterCriteriaId';
    private final String MP_STATUS_ACTIVE_VALUE = 'Active';
    private final String MP_STATUS_DRAFT_VALUE = 'Draft';
    private final String FREQUENCY_FIELD = 'Frequency';
    private final String FREQUENCY_TYPE_FIELD = 'FrequencyType';

    public MPLN_MaintenancePlanTemplateHandler() {
    }

    public MPLN_MaintenancePlanTemplateHandler(Boolean isAuthoring) {
        this.isAuthoring = isAuthoring;
    }

    public List<Mpln.MaintenanceAssetInformation> getMaintenanceAssets(final Mpln.MaintenanceAssetRequest maintenanceAssetRequest){

        System.debug(LoggingLevel.DEBUG , 'MPLN_MaintenancePlanTemplateHandler - getMaintenanceAssets enter');

        final String templateId = null;
        final String sourceRecordId = null;
        final List<String> assetStatusValues = null;
        final Boolean includeChildAssets = null;

        List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = new List<Mpln.MaintenanceAssetInformation>();
        
        List<Asset> assetList = new List<Asset>();
		List<SVMXA360__ApplicableProduct__c> applicableProductList = new List<SVMXA360__ApplicableProduct__c>();
        List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        Set<Id> assetIds = new Set<Id>();
        
        Map<String, SVMXA360__ApplicableProduct__c > product2IdApplicableProductMap = new  Map<String, SVMXA360__ApplicableProduct__c>();
        Map<String, SVMXA360__ApplicableProduct__c > product2FamilyMap = new  Map<String, SVMXA360__ApplicableProduct__c>();

        try{
            
            if( maintenanceAssetRequest == null ){
                System.debug(LoggingLevel.ERROR, 'getMaintenanceAssets Invalid request, maintenanceAssetRequest '+ maintenanceAssetRequest );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
            templateId = maintenanceAssetRequest.templateId;
            sourceRecordId = maintenanceAssetRequest.sourceRecordId;
            assetStatusValues =  maintenanceAssetRequest.assetStatusValues;
            includeChildAssets = maintenanceAssetRequest.includeChildAssets;

            System.debug(LoggingLevel.DEBUG , 'getMaintenanceAssets  maintenanceAssetRequest input'+ ' templateId: '+ templateId + ' sourceRecordId: '+ sourceRecordId + ' assetStatusValues: ' + assetStatusValues + ' includeChildAssets: '+ includeChildAssets);

            if(String.isBlank( templateId ) || String.isBlank( sourceRecordId ) ){
                System.debug(LoggingLevel.ERROR, 'getMaintenanceAssets Invalid argument, templateId or sourceRecordId '+ sourceRecordId + 'or '+ templateId);
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
            if (includeChildAssets == null) {
                includeChildAssets = false;
            }

            String objectAPIName = COMM_DescribeManager.getInstance().getObjectDescribeById( sourceRecordId ).getName();

            applicableProductList = SvmxDatabase.query ([Select Id, SVMXA360__ProductId__c, SVMXA360__ProductFamily__c, SVMXA360__WorkTypeId__c, SVMXA360__WorkTypeId__r.Name from SVMXA360__ApplicableProduct__c where SVMXA360__MaintenancePlanTemplateId__c =: templateId]);
                
            for(SVMXA360__ApplicableProduct__c applicableProduct : applicableProductList ){
                
                if( String.isNotBlank(applicableProduct.SVMXA360__ProductId__c)){
                    product2IdApplicableProductMap.put(applicableProduct.SVMXA360__ProductId__c,applicableProduct);
                }
                else if(String.isNotBlank(applicableProduct.SVMXA360__ProductFamily__c) ){
                    product2FamilyMap.put(applicableProduct.SVMXA360__ProductFamily__c, applicableProduct );
                }
            }

            contractLineItemList = SvmxDatabase.query([SELECT AssetId FROM ContractLineItem WHERE ServiceContractId =: sourceRecordId AND Status != 'Expired' AND ServiceContract.Status != 'Expired']);

            for (ContractLineItem contractLineItemRecord : contractLineItemList) {
                assetIds.add(contractLineItemRecord.AssetId);
            }
            
            if (assetStatusValues != null && assetStatusValues.size() > 0) {
                assetList = SvmxDatabase.query([SELECT  Id, Name, Product2Id, ProductFamily, ParentId, RootAssetId FROM Asset WHERE ( Id =: sourceRecordId OR Id IN: assetIds OR AccountId =: sourceRecordId OR LocationId =: sourceRecordId ) AND Status IN: assetStatusValues ORDER BY Name]);
            } else {
                assetList = SvmxDatabase.query([SELECT  Id, Name, Product2Id, ProductFamily, ParentId, RootAssetId FROM Asset WHERE ( Id =: sourceRecordId OR Id IN: assetIds OR AccountId =: sourceRecordId OR LocationId =: sourceRecordId ) ORDER BY Name]);
            }

            if ('Asset'.equalsIgnoreCase(objectAPIName) && !assetList.isEmpty() && includeChildAssets) {
                Asset currentAsset = assetList[0];
                String currentAssetId = currentAsset.id;
                Boolean isRootAsset = currentAsset.ParentId == null ? true : false;
                String query = 'SELECT  Id, Name, Product2Id, ProductFamily, ParentId, RootAssetId FROM Asset WHERE';
                String assetWhereClause = ''; 
                if (assetStatusValues != null && !assetStatusValues.isEmpty() ) {
                    assetWhereClause = assetWhereClause + '(Status IN: assetStatusValues) AND ';
                }
                if (isRootAsset) {
                    assetWhereClause = assetWhereClause + '(RootAssetId =: currentAssetId AND Id !=: currentAssetId ) ORDER BY Name';
                } else {
                    assetWhereClause = assetWhereClause + '(ParentId =: currentAssetId AND Id !=: currentAssetId ) ORDER BY Name';
                }
                query = query + assetWhereClause;
                assetList.addAll( (List<Asset>) SvmxDatabase.query( Database.query(query)) );
            }

            for(Asset asset : assetList ){
    
                if(product2IdApplicableProductMap.containsKey(asset.Product2Id)){
                    
                    maintenanceAssetList.add( createMaintenanceAssetReference( asset, product2IdApplicableProductMap.get(asset.Product2Id) ));
    
                }else if(product2FamilyMap.containsKey(asset.ProductFamily)){
    
                    maintenanceAssetList.add( createMaintenanceAssetReference( asset, product2FamilyMap.get(asset.ProductFamily) ));
                }
            }
        }catch(Exception e){
			    
            System.debug(LoggingLevel.ERROR, 'getMaintenanceAssets() : Failed to retrieve Maintenance Assets'+ e.getStackTraceString() );           
            throw e;
        }
        finally{
            System.debug(LoggingLevel.DEBUG , 'MPLN_MaintenancePlanTemplateHandler - getMaintenanceAssets exit');
        }
        return maintenanceAssetList;
        
    }
    
    /**
     * This method is used to retrieve Asset record list for 
     * the requested search keyword.
     */
    public List<Mpln.AssetInformation> getAssetList( String searchKeyword , List<String> assetStatusValues, List<String> loadedRowsIds) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssetList() - enter: searchKeyword= ' + searchKeyword + ' assetStatusValues: ' + assetStatusValues );
        
        List<Mpln.AssetInformation> assets = new List<Mpln.AssetInformation>();
        
        try {

            if( String.isBlank(searchKeyword) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' searchKeyword= ' + searchKeyword );
            }

            List<Asset> assetRecords = new List<Asset>();
            searchKeyword = '%' + String.escapeSingleQuotes(searchKeyword) + '%';
            loadedRowsIds = ( loadedRowsIds == null ) ? new List<String>() : loadedRowsIds;
            if ( assetStatusValues != null && !assetStatusValues.isEmpty() ) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                assetRecords = SvmxDatabase.query([SELECT Id, Name, AccountId, Account.Name, toLabel(Status), product2Id, SerialNumber FROM Asset WHERE Id NOT IN: loadedRowsIds AND Status IN: assetStatusValues AND (Name LIKE: searchKeyword OR SerialNumber LIKE: searchKeyword) ORDER BY Name LIMIT 100]);
            } else {
                /* sfge-disable-next-line ApexFlsViolationRule */
                assetRecords = SvmxDatabase.query([SELECT Id, Name, AccountId, Account.Name, toLabel(Status), product2Id, SerialNumber FROM Asset WHERE Id NOT IN: loadedRowsIds AND (Name LIKE: searchKeyword OR SerialNumber LIKE: searchKeyword) ORDER BY Name LIMIT 100]);
            }
            assets = buildAssetInformations(assetRecords);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssetList() : Failed to retrieve Asset records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssetList() : Failed to retrieve Asset records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetList() - exit; assets= ' + assets );
        }
        
        return assets;
    }

    /**
     * This method used to get the Account Ids based on Associated Locations
     * 
     */
    public List<Id> getLocationAccounts( final String locationId ){

        List<Id> returnListOfAccounts =  new List<Id>();
        
        try{
            
            if(String.isBlank( locationId ) ){
                System.debug(LoggingLevel.ERROR, 'getLocationAccounts Invalid argument locationId '+ locationId );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
        /* sfge-disable-next-line ApexFlsViolationRule */ 
        List<AssociatedLocation> listAssociatedLocation = SvmxDatabase.query([Select  Id, ParentRecordId from AssociatedLocation where LocationId = : locationId]);

        for (AssociatedLocation aLocation : listAssociatedLocation) {
            returnListOfAccounts.add(aLocation.ParentRecordId);
        }
             
        }catch(Exception e){
			    
            System.debug(LoggingLevel.ERROR, 'getLocationAccounts() : Failed to retrieve Accounts '+ e.getStackTraceString() );           
            throw e;
        }
        finally{
            System.debug(LoggingLevel.DEBUG , 'MPLN_MaintenancePlanTemplateHandler - getLocationAccounts exit');
        }

        return returnListOfAccounts;

    }

    /*
    * This method is used to create Maintenance Plan and related objects data
    */
    public MaintenancePlan executeMaintenancePlan( Mpln.MaintenancePlanRequest request ) {
        
        System.debug(LoggingLevel.DEBUG, 'executeMaintenancePlan() - enter; request= ' + request );

        // Check for null and throw exception
        if(request == null) {
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        String sourceRecordId = request.sourceRecordId;
        String templateId = request.templateId;
        MaintenancePlan maintenancePlanRecord = request.maintenancePlanRecord;
        List<MaintenanceAsset> maintenanceAssetRecords = request.maintenanceAssetRecords;
        List<MaintenanceWorkRule> maintenanceWorkRuleList = new List<MaintenanceWorkRule>();

        Savepoint savepoint = Database.setSavepoint();
        try {

            // Check for null and throw exception
            if(sourceRecordId == null || templateId == null) {
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            if (isAuthoring) {
                serviceContract = (ServiceContract) SvmxDatabase.query([SELECT Name, StartDate, AccountId FROM ServiceContract WHERE Id =: sourceRecordId])[0];
            }

            // Insert Maintenance Plan and if maintenancePlanRecord is null then populate the data from template and then insert
            maintenancePlanRecord = insertMaintenancePlanRecord(maintenancePlanRecord, templateId, sourceRecordId);

            // Insert Maintenance Asset Records and if maintenanceAssetRecords is null then populate the data in it and then insert
            if (maintenancePlanRecord != null) {
                maintenanceAssetRecords = insertMaintenanceAsset(maintenancePlanRecord, maintenanceAssetRecords, templateId, sourceRecordId);
            }
            
            // Populate maps from Applicable Product
            populateMapValuesFromApplicableProduct(templateId);

            // Create map of Asset id and Maintenance Asset Id
            Map<Id, Id> assetIdMaintenanceAssetIdMap = new Map<Id, Id>();
            for (MaintenanceAsset mAsset : maintenanceAssetRecords) {
                assetIdMaintenanceAssetIdMap.put(mAsset.AssetId, mAsset.Id);
            }
            maintenanceAssetRecords.clear(); //Clear heap memory

            // Fetch Maintenance Work Rule Template records and populate maintenanceWorkRuleList and appProductIdWorkRuleListMap
            String queryString = 'SELECT ' + String.join(mWorkRuleTemplateFieldList, ',') + ' FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__MaintenancePlanTemplateId__c = \'' + String.escapeSingleQuotes(templateId) + '\'' + ' AND SVMXA360__TemplateType__c != null';
            Map<Id, List<SVMXA360__MaintenanceWorkRuleTemplate__c>> appProductIdWorkRuleListMap = new Map<Id, List<SVMXA360__MaintenanceWorkRuleTemplate__c>>();
            List<SVMXA360__MaintenanceWorkRuleTemplate__c> mWorkRuleTemplateList = SvmxDatabase.query(queryString);

            Set<String> recordsetFilterCriteriaIdSet = new Set<String>();
            for (SVMXA360__MaintenanceWorkRuleTemplate__c mWorkRuleTemplate : mWorkRuleTemplateList) {
                if (String.isNotBlank(mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c)) {
                    recordsetFilterCriteriaIdSet.add(mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c);
                }
            }
            List<RecordsetFilterCriteria> recordsetFilterCriteriaList = SvmxDatabase.query([SELECT Id FROM RecordsetFilterCriteria WHERE Id IN: recordsetFilterCriteriaIdSet]);
            recordsetFilterCriteriaIdSet.clear();
            for (RecordsetFilterCriteria objRecordsetFilterCriteria : recordsetFilterCriteriaList) {
                recordsetFilterCriteriaIdSet.add(objRecordsetFilterCriteria.Id);
            }

            for (SVMXA360__MaintenanceWorkRuleTemplate__c mWorkRuleTemplate : mWorkRuleTemplateList) {
                if (mWorkRuleTemplate.SVMXA360__TemplateType__c == 'Maintenance Plan Template') {
                    MaintenanceWorkRule maintenanceWorkRuleRecord = buildMaintenanceWorkRule(maintenancePlanRecord, mWorkRuleTemplate, maintenancePlanRecord.Id, MAINTENANCE_PLAN);
                    maintenanceWorkRuleList.add(maintenanceWorkRuleRecord);
                } else {
                    if (mWorkRuleTemplate.SVMXA360__Type__c == 'CriteriaValue' && (!recordsetFilterCriteriaIdSet.contains(mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c) || !mWorkRuleFieldMap.containsKey(RECORDSET_FILTER_CRITERIA_FIELD))) {
                        continue;
                    }
                    if (!appProductIdWorkRuleListMap.containsKey(mWorkRuleTemplate.SVMXA360__ApplicableProductId__c)) {
                        appProductIdWorkRuleListMap.put(mWorkRuleTemplate.SVMXA360__ApplicableProductId__c, new List<SVMXA360__MaintenanceWorkRuleTemplate__c>());
                    }
                    appProductIdWorkRuleListMap.get(mWorkRuleTemplate.SVMXA360__ApplicableProductId__c).add(mWorkRuleTemplate);
                }
            }

            // Query Asset records for which Maintenance Assts are created.
            List<Asset> assetList = SvmxDatabase.query([SELECT Id, Product2Id, ProductFamily FROM Asset WHERE Id IN: assetIdMaintenanceAssetIdMap.keyset()]);

            // Based on Asset get applicableProductId and then based on applicableProductId get related Work Rule Template List and then populate MaintenanceWorkRule
            for (Asset assetRecord : assetList) {
                Id applicableProductId = null;
                if (productIdApplicableProductIdMap.containsKey(assetRecord.Product2Id)) {
                    applicableProductId = productIdApplicableProductIdMap.get(assetRecord.Product2Id);
                } else if (productFamilyApplicableProductIdMap.containsKey(assetRecord.ProductFamily)) {
                    applicableProductId = productFamilyApplicableProductIdMap.get(assetRecord.ProductFamily);
                }

                if (String.isNotBlank(applicableProductId) && appProductIdWorkRuleListMap.containsKey(applicableProductId)) {
                    List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList = appProductIdWorkRuleListMap.get(applicableProductId);
                    String parentId = assetIdMaintenanceAssetIdMap.get(assetRecord.Id);
                    List<MaintenanceWorkRule> maintenanceWorkRuleForMAssetList = buildMaintenanceWorkRuleList(maintenancePlanRecord, workRuleTemplateList, parentId, MAINTENANCE_ASSET);
                    maintenanceWorkRuleList.addAll(maintenanceWorkRuleForMAssetList);
                }
            }

            //Clear heap memory
            assetList.clear();
            appProductIdWorkRuleListMap.clear();
            productIdApplicableProductIdMap.clear();
            productFamilyApplicableProductIdMap.clear();

            // Insert Maintenance Work Rule
            if ( !maintenanceWorkRuleList.isEmpty() ) {
                if (isAuthoring && maintenanceWorkRuleList.size() > getRemainingDmlRowCount()) {
                    throw new SvmxSystem.SvmxNestedException('Number of Maintenance Work Rule exceeds the DML limit');
                }
                SvmxDatabase.insertRecord(maintenanceWorkRuleList);
            }
        }
        catch(SvmxSystem.SvmxNestedException e) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'executeMaintenancePlan() : Failed to process Maintenance Plan. Error= ' + e.getMessage());
            throw e;
        }
        catch(Exception e) {
            Database.rollback(savepoint);
            System.debug(LoggingLevel.ERROR, 'executeMaintenancePlan() : Failed to process Maintenance Plan. Error= ' + e.getMessage());
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'executeMaintenancePlan() - exit; maintenancePlan= ' + maintenancePlanRecord);
        }

        return maintenancePlanRecord;
    }

    private MaintenancePlan insertMaintenancePlanRecord(MaintenancePlan maintenancePlanRecord, String templateId, Id sourceRecordId) {

        Schema.SObjectType sObjectTypeInstance = sourceRecordId.getSobjectType();

        // Copy data from template to Maintenance Plan if maintenancePlanRecord is null
        if (maintenancePlanRecord == null) {
            maintenancePlanRecord = populateMaintenancePlanRecord(templateId);

            if ( sObjectTypeInstance == Schema.Asset.getSObjectType() ) {
                List<Asset> assetRecord = SvmxDatabase.query([SELECT AccountId, LocationId FROM Asset WHERE Id =: sourceRecordId]);

                if (!assetRecord.isEmpty()) {
                    maintenancePlanRecord.AccountId = assetRecord[0].AccountId;
                    maintenancePlanRecord.LocationId = assetRecord[0].LocationId;
                }
            }
        }

        /*
        //Check for invalid template
        if ( isTemplateInvalidCheck( templateId ) ) {
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.TEMPLATE_WITHOUT_WORK_RULE + '- templateId: ' + templateId);
        }
        */

        // TODO - Hardcoded field value for this release. Next release will remove it once these fields are not required by Salesforce
        if (!mPlanFieldMap.isEmpty() && mPlanFieldMap.containsKey(FREQUENCY_FIELD) && mPlanFieldMap.containsKey(FREQUENCY_TYPE_FIELD)) {
            maintenancePlanRecord.put(FREQUENCY_FIELD, FREQUENCY_VALUE);
            maintenancePlanRecord.put(FREQUENCY_TYPE_FIELD, FREQUENCY_TYPE_VALUE);
        }

        // Update field values
        if (!isAuthoring && maintenancePlanRecord.StartDate > Date.today()) {
            maintenancePlanRecord.SVMXA360__SM_Status__c = MP_STATUS_DRAFT_VALUE;
        } else {
            maintenancePlanRecord.SVMXA360__SM_Status__c = MP_STATUS_ACTIVE_VALUE;
        }
        maintenancePlanRecord.SVMXA360__MaintenancePlanTemplateId__c = templateId;
        maintenancePlanRecord.SVMXA360__Source__c = String.valueOf( sObjectTypeInstance );
        maintenancePlanRecord.AccountId = ( sObjectTypeInstance == Schema.Account.getSObjectType() ) ? sourceRecordId : maintenancePlanRecord.AccountId;
        maintenancePlanRecord.LocationId = ( sObjectTypeInstance == Schema.Location.getSObjectType() ) ? sourceRecordId : maintenancePlanRecord.LocationId;
        maintenancePlanRecord.ServiceContractId = ( sObjectTypeInstance == Schema.ServiceContract.getSObjectType() ) ? sourceRecordId : maintenancePlanRecord.ServiceContractId;

        // Insert Maintenance Plan
        if ( maintenancePlanRecord != null ) {
            SvmxDatabase.insertRecord(maintenancePlanRecord);
        }

        return maintenancePlanRecord;
    }

    private List<MaintenanceAsset> insertMaintenanceAsset(MaintenancePlan maintenancePlanRecord, List<MaintenanceAsset> maintenanceAssetRecords, String templateId, String sourceRecordId) {

        // get Maintenance Assets if maintenanceAssetRecords is null or blank
        if (maintenanceAssetRecords == null || maintenanceAssetRecords.size() == 0) {
            Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
            maintenanceAssetRequest.templateId = templateId;
            maintenanceAssetRequest.sourceRecordId = sourceRecordId;
            List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = getMaintenanceAssets(maintenanceAssetRequest);
            maintenanceAssetRecords = buildMaintenanceAssetList(maintenanceAssetList, maintenancePlanRecord);
        } else {
            // Create new instance and populate data in it.
            List<MaintenanceAsset> newMaintenanceAssetList = new List<MaintenanceAsset>();
            for (MaintenanceAsset mAsset : maintenanceAssetRecords) {
                MaintenanceAsset maintenanceAssetInstance = new MaintenanceAsset();
                maintenanceAssetInstance.AssetId = mAsset.AssetId;
                maintenanceAssetInstance.NextSuggestedMaintenanceDate = mAsset.NextSuggestedMaintenanceDate;
                maintenanceAssetInstance.MaintenancePlanId = maintenancePlanRecord.Id;
                maintenanceAssetInstance.WorkTypeId = mAsset.WorkTypeId;
                newMaintenanceAssetList.add(maintenanceAssetInstance);
            }
            maintenanceAssetRecords = newMaintenanceAssetList;
        }
        // Insert Maintenance Assets
        if ( !maintenanceAssetRecords.isEmpty() ) {
            if (isAuthoring && maintenanceAssetRecords.size() > getRemainingDmlRowCount()) {
                throw new SvmxSystem.SvmxNestedException('Number of Maintenance Assets exceeds the DML limit');
            }
            SvmxDatabase.insertRecord(maintenanceAssetRecords);
        }

        return maintenanceAssetRecords;
    }

    private void populateMapValuesFromApplicableProduct(String templateId) {

        // Fetch Applicable Product records and create maps
        productIdApplicableProductIdMap = new Map<Id, Id>();
        productFamilyApplicableProductIdMap = new Map<String, Id>();
        List<SVMXA360__ApplicableProduct__c> applicableProductList = SvmxDatabase.query([SELECT Id, SVMXA360__ProductId__c, SVMXA360__ProductFamily__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: templateId]);
        for(SVMXA360__ApplicableProduct__c applicableProduct : applicableProductList){
            if(String.isNotBlank(applicableProduct.SVMXA360__ProductId__c)){
                productIdApplicableProductIdMap.put(applicableProduct.SVMXA360__ProductId__c,applicableProduct.Id);
            }
            else if(String.isNotBlank(applicableProduct.SVMXA360__ProductFamily__c)){
                productFamilyApplicableProductIdMap.put(applicableProduct.SVMXA360__ProductFamily__c, applicableProduct.Id);
            }
        }
    }

    private MaintenancePlan populateMaintenancePlanRecord(String templateId) {

        String queryString = 'SELECT ' + String.join(mPlanTemplateFieldList, ',') + ' FROM SVMXA360__MaintenancePlanTemplate__c WHERE Id = \'' + String.escapeSingleQuotes(templateId) + '\'';
        List<SVMXA360__MaintenancePlanTemplate__c> mPlanTemplate = SvmxDatabase.query(queryString);

        if (mPlanTemplate.isEmpty()) {
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.RECORD_NOT_EXISTS);
        }
        if ( !mPlanTemplate[0].SVMXA360__IsActive__c ) {
            throw new SvmxSystem.SvmxNestedException(System.Label.Error_MplanTemplateNotActive);
        }
        MaintenancePlan maintenancePlanRecord = buildMaintenancePlanFromTemplate(mPlanTemplate[0]);

        return maintenancePlanRecord;
    }

    private MaintenancePlan buildMaintenancePlanFromTemplate(SVMXA360__MaintenancePlanTemplate__c mPlanTemplate) {

        Date startDate = Date.today();
        Date endDate = null;
        Integer duration = Integer.valueOf(mPlanTemplate.SVMXA360__MaintenancePlanDuration__c);
        String unitOfTime = mPlanTemplate.SVMXA360__MaintenancePlanUnitOfTime__c;

        MaintenancePlan maintenancePlanRecord = new MaintenancePlan();
        if (isAuthoring && serviceContract != null) {
            maintenancePlanRecord.MaintenancePlanTitle = formatName(serviceContract.Name, mPlanTemplate.Name, 255);
            maintenancePlanRecord.StartDate = serviceContract.StartDate;
            maintenancePlanRecord.NextSuggestedMaintenanceDate = serviceContract.StartDate;
            maintenancePlanRecord.AccountId = serviceContract.AccountId;
            startDate = serviceContract.StartDate;
        } else {
            maintenancePlanRecord.MaintenancePlanTitle = mPlanTemplate.Name + '_Plan';
            maintenancePlanRecord.StartDate = startDate;
            maintenancePlanRecord.NextSuggestedMaintenanceDate = startDate;
        }
        if (duration != null && String.isNotBlank(unitOfTime)) {
            endDate = COMM_DateLiteralUtils.calculateEndDate(startDate, duration, unitOfTime);
        }
        maintenancePlanRecord.EndDate = endDate;
        maintenancePlanRecord.DoesAutoGenerateWorkOrders = mPlanTemplate.SVMXA360__DoesAutoGenerateWorkOrders__c;
        maintenancePlanRecord.DoesGenerateUponCompletion = mPlanTemplate.SVMXA360__DoesGenerateUponCompletion__c;
        maintenancePlanRecord.GenerationHorizon = Integer.valueOf(mPlanTemplate.SVMXA360__GenerationHorizon__c);
        maintenancePlanRecord.GenerationTimeframe = Integer.valueOf(mPlanTemplate.SVMXA360__GenerationTimeframe__c);
        maintenancePlanRecord.GenerationTimeframeType = mPlanTemplate.SVMXA360__GenerationTimeframeType__c;
        maintenancePlanRecord.MaintenanceWindowEndDays = Integer.valueOf(mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c);
        maintenancePlanRecord.MaintenanceWindowStartDays = Integer.valueOf(mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c);
        maintenancePlanRecord.SvcApptGenerationMethod = mPlanTemplate.SVMXA360__SvcApptGenerationMethod__c;
        maintenancePlanRecord.WorkOrderGenerationMethod = mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c;
        maintenancePlanRecord.WorkTypeId = mPlanTemplate.SVMXA360__WorkTypeId__c;

        return maintenancePlanRecord;
    }

    private String formatName(String firstString, String secondString, Integer nameValueLength) {
        String name = firstString + ' - ' + secondString;
        if (String.isNotBlank(name) && name.length() > nameValueLength) {
            Integer adjustedCharLength = name.length() - nameValueLength;
            name = firstString + ' - ' + secondString.substring(0, secondString.length() - adjustedCharLength);
        }
        return name;
    }

    private List<MaintenanceAsset> buildMaintenanceAssetList(List<Mpln.MaintenanceAssetInformation> maintenanceAssetList, MaintenancePlan maintenancePlanRecord) {
        List<MaintenanceAsset> maintenanceAssetRecords = new List<MaintenanceAsset>();

        for (Mpln.MaintenanceAssetInformation maintenanceAssetRecord : maintenanceAssetList) {
            MaintenanceAsset maintenanceAssetInstance = new MaintenanceAsset();
            maintenanceAssetInstance.AssetId = maintenanceAssetRecord.assetId;
            maintenanceAssetInstance.NextSuggestedMaintenanceDate = maintenancePlanRecord.NextSuggestedMaintenanceDate;
            maintenanceAssetInstance.MaintenancePlanId = maintenancePlanRecord.Id;
            maintenanceAssetInstance.WorkTypeId = maintenanceAssetRecord.workTypeId;
            maintenanceAssetRecords.add(maintenanceAssetInstance);
        }

        return maintenanceAssetRecords;
    }

    private MaintenanceWorkRule buildMaintenanceWorkRule(MaintenancePlan maintenancePlanRecord, SVMXA360__MaintenanceWorkRuleTemplate__c mWorkRuleTemplate, String parentId, String parentType) {

        MaintenanceWorkRule maintenanceWorkRuleRecord = new MaintenanceWorkRule();
        if (parentType == MAINTENANCE_PLAN) {
            maintenanceWorkRuleRecord.ParentMaintenancePlanId = parentId;
        } else if (parentType == MAINTENANCE_ASSET) {
            maintenanceWorkRuleRecord.ParentMaintenanceRecordId = parentId;
        }
        maintenanceWorkRuleRecord.Title = mWorkRuleTemplate.Name;
        maintenanceWorkRuleRecord.RecurrencePattern = mWorkRuleTemplate.SVMXA360__RecurrencePattern__c;
        maintenanceWorkRuleRecord.SortOrder = Integer.valueOf(mWorkRuleTemplate.SVMXA360__SortOrder__c);
        maintenanceWorkRuleRecord.WorkTypeId = mWorkRuleTemplate.SVMXA360__WorkTypeId__c;
        maintenanceWorkRuleRecord.NextSuggestedMaintenanceDate = maintenancePlanRecord.NextSuggestedMaintenanceDate;
        if (mWorkRuleFieldMap.containsKey(TYPE_FIELD) && mWorkRuleFieldMap.containsKey(RECORDSET_FILTER_CRITERIA_FIELD)) {
            maintenanceWorkRuleRecord.put(TYPE_FIELD, mWorkRuleTemplate.SVMXA360__Type__c);
            maintenanceWorkRuleRecord.put(RECORDSET_FILTER_CRITERIA_FIELD, mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c);
        }

        return maintenanceWorkRuleRecord;
    }

    private List<MaintenanceWorkRule> buildMaintenanceWorkRuleList(MaintenancePlan maintenancePlanRecord, List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList, String parentId, String parentType) {
        
        List<MaintenanceWorkRule> maintenanceWorkRuleList = new List<MaintenanceWorkRule>();
        if(workRuleTemplateList != null && !workRuleTemplateList.isEmpty()) {
            for(SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRecord : workRuleTemplateList) {
                maintenanceWorkRuleList.add(buildMaintenanceWorkRule(maintenancePlanRecord, workRuleTemplateRecord, parentId, parentType));
            }
        }

        return maintenanceWorkRuleList;
    }
    
    private List<Mpln.AssetInformation> buildAssetInformations( final List<Asset> assetInformationRecords ) {
        
        final List<Mpln.AssetInformation> assetInformationList = new List<Mpln.AssetInformation>();
        if( assetInformationRecords != null && !assetInformationRecords.isEmpty() ) {
            
            for( Asset assetInformationRecord : assetInformationRecords ) {
                assetInformationList.add( buildAssetInformation(assetInformationRecord) );
            }
        }
        
        return assetInformationList;
    }

    private Mpln.AssetInformation buildAssetInformation( final Asset assetInformationRecord ) {
        
        final Mpln.AssetInformation assetInformation = new Mpln.AssetInformation();
        assetInformation.id = assetInformationRecord.id;
        assetInformation.name = assetInformationRecord.Name;
        assetInformation.accountId = assetInformationRecord.AccountId;
        assetInformation.accountName = assetInformationRecord.Account.Name;
        assetInformation.serialNumber = assetInformationRecord.SerialNumber;
        assetInformation.status = assetInformationRecord.Status;
        assetInformation.productId = assetInformationRecord.product2Id;
        return assetInformation;
    }

    private Mpln.MaintenanceAssetInformation createMaintenanceAssetReference(Asset asset ,SVMXA360__ApplicableProduct__c applicableProduct ){
        Mpln.MaintenanceAssetInformation maintenanceAsset = new Mpln.MaintenanceAssetInformation();
        maintenanceAsset.assetId = asset.Id;
        maintenanceAsset.assetName = asset.Name;
        maintenanceAsset.workTypeId = applicableProduct.SVMXA360__WorkTypeId__c;
        maintenanceAsset.workTypeName = applicableProduct.SVMXA360__WorkTypeId__r.Name;
        return maintenanceAsset;
    }

    /* Commented for this release and may be until Salesforce remove the required check for Frequency and Frequency Type field or PM Confirmation
    private Boolean isTemplateInvalidCheck(String templateId){

        Boolean isTemplateInvalid = false;
        templateId = String.escapeSingleQuotes(templateId);

        AggregateResult[] aggregateResultArray = (Test.isRunningTest()) 
            ? [SELECT COUNT(Id) RecordCount FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: templateId AND SVMXA360__TemplateType__c = 'Maintenance Plan Template']
            : [SELECT COUNT(Id) RecordCount FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: templateId AND SVMXA360__TemplateType__c = 'Maintenance Plan Template' WITH SECURITY_ENFORCED];
        if( aggregateResultArray != null && aggregateResultArray.size() > 0 && aggregateResultArray[0].get('RecordCount') != null ) {
            if (Integer.valueOf(aggregateResultArray[0].get('RecordCount')) == 0) {
                isTemplateInvalid = true;
            }
        }

        return isTemplateInvalid;
    }
    */
    
    //CPQ service implimentation

    public Common.ServiceResponse addMaintenanceAssets(MaintenancePlanAssetData maintenancePlanAssetData) {
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        serviceResponse.success = true;
        Savepoint sp = Database.setSavepoint();
        try {
            if (maintenancePlanAssetData == null) {
                System.debug(LoggingLevel.ERROR, 'addMaintenanceAssets Invalid request, maintenancePlanAssetData: '+ maintenancePlanAssetData );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
            if (maintenancePlanAssetData.maintenanceAssetDataList == null || String.isBlank(maintenancePlanAssetData.maintenancePlanId) ) {
                System.debug(LoggingLevel.ERROR, 'addMaintenanceAssets Invalid parameter, maintenancePlanAssetData.maintenanceAssetDataList: '+ maintenancePlanAssetData.maintenanceAssetDataList + ' maintenancePlanAssetData.maintenancePlanId: '+ maintenancePlanAssetData.maintenancePlanId);
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            String maintenancePlanId = maintenancePlanAssetData.maintenancePlanId;
            List<MaintenancePlan> maintenancePlanList = SvmxDatabase.query([SELECT id,SVMXA360__MaintenancePlanTemplateId__c,NextSuggestedMaintenanceDate from MaintenancePlan where Id =: maintenancePlanId]);
            MaintenancePlan maintenancePlan = maintenancePlanList != null && !maintenancePlanList.isEmpty() ? maintenancePlanList[0] : null;
            
            if (maintenancePlan == null) {
                throw new SvmxSystem.SvmxNestedException ( 'Not found any valid maintenancePlan for Id : ' + maintenancePlanId);
            }
            if (maintenancePlan.SVMXA360__MaintenancePlanTemplateId__c == null) {
                throw new SvmxSystem.SvmxNestedException ( 'There is no valid associate maintenance template for maintenancePlan : ' + maintenancePlanId);
            }
            // Hold the request data with assetId Map
            Map<String,MaintenanceAssetData> assetIdMaintenanceAssetDataMap = new Map<String,MaintenanceAssetData>();
            for(MaintenanceAssetData maintenanceAssetData : maintenancePlanAssetData.maintenanceAssetDataList){
                if (String.isNotBlank(maintenanceAssetData.assetId)) {
                    assetIdMaintenanceAssetDataMap.put(maintenanceAssetData.assetId,maintenanceAssetData );
                }
            }
            //request data validation
            if (assetIdMaintenanceAssetDataMap.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException ( 'Not found any valid assets in request');
            }

            //get all asset which id present id request 
            List<Asset> assetList = getAssets(new List<String> (assetIdMaintenanceAssetDataMap.keyset()));
            if (assetList == null || assetList.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException ( 'Requested assets not exist in org');
            }

            //Querying applicable product associated with template
            List<SVMXA360__ApplicableProduct__c> applicableProductList = SvmxDatabase.query ([Select Id, SVMXA360__ProductId__c, SVMXA360__ProductFamily__c, SVMXA360__WorkTypeId__c, SVMXA360__WorkTypeId__r.Name from SVMXA360__ApplicableProduct__c where SVMXA360__MaintenancePlanTemplateId__c =: maintenancePlan.SVMXA360__MaintenancePlanTemplateId__c]);
            //buld or calculate the maintenance Asset reference for requested assets
            List<MaintenanceAsset> maintenanceAssetList = getMaintenanceAssets(assetList, applicableProductList, maintenancePlan, assetIdMaintenanceAssetDataMap);

            if (maintenanceAssetList.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException ( 'No maintenanceAsset to create for this request');
            }
            
            // All record should be inserted, if there is any error , trascation should be rollback
            List<Database.SaveResult> srList =  Database.insert(maintenanceAssetList, false) ;
            List<Common.ServiceError> serviceErrors = getServiceErrors(srList,maintenanceAssetList);

            if (!serviceErrors.isEmpty()) {
                SvmxSystem.SvmxServiceException svmxServiceException = new SvmxSystem.SvmxServiceException();
                svmxServiceException.errors = serviceErrors; 
                throw svmxServiceException;
            }

            //Holding assetId with created MaintenanceAsset Id to return back in response
            Map<Id, Id> assetIdMaintenanceAssetIdMap = new Map<Id, Id>();
            for (MaintenanceAsset maintenanceAsset : maintenanceAssetList) {
                assetIdMaintenanceAssetIdMap.put(maintenanceAsset.AssetId, maintenanceAsset.Id);
            }

            // Workrule calculation
            List<SVMXA360__MaintenanceWorkRuleTemplate__c> maintenanceWorkRuleTemplateList = getMaintenanceWorkRuleTemplates(maintenancePlan.SVMXA360__MaintenancePlanTemplateId__c);
            List<MaintenanceWorkRule> maintenanceWorkRuleList = new List<MaintenanceWorkRule>();
            if (!maintenanceWorkRuleTemplateList.isEmpty()) {
                maintenanceWorkRuleList.addAll( getMaintenanceWorkRuleForAsset(assetList, applicableProductList, maintenancePlan, maintenanceWorkRuleTemplateList, assetIdMaintenanceAssetIdMap) );
            }
    
            if (!maintenanceWorkRuleList.isEmpty()) {
                SvmxDatabase.insertRecord(maintenanceWorkRuleList);
            }

            serviceResponse.data = buildResponse(maintenancePlanAssetData, assetIdMaintenanceAssetIdMap);

        } catch (SvmxSystem.SvmxServiceException e) {
            serviceResponse.success = false;
            serviceResponse.errors = e.errors;
            serviceResponse.message = System.Label.Error_MaintenanceAssetCreationFailed;
            Database.rollback(sp);
        } 
        catch ( SvmxSystem.SvmxNestedException e ) {
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            Database.rollback(sp);

        } catch (Exception e) {
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            Database.rollback(sp);
        }
        
        return serviceResponse;
    }

    private List<Common.ServiceError> getServiceErrors(List<Database.SaveResult> srList, List<MaintenanceAsset> maintenanceAssetList){
        Integer count = 0;
        List<Common.ServiceError> serviceErrors = new List<Common.ServiceError>();
        for (Database.SaveResult sr: srList) {
            if (!sr.isSuccess()) {
                Common.ServiceError serviceError = new Common.ServiceError();
                serviceError.referenceId = maintenanceAssetList[count].assetId;
                String message = '';
                for(Database.Error err : sr.getErrors()) {
                    message = message + err.getMessage() + err.getStatusCode() + ';';
                }
                serviceError.message = message;
                serviceErrors.add(serviceError);
            }
            count ++;
        }
        return serviceErrors;
    }
    // build response send back maintenanceAsset Id for MaintenanceAssetData 
    private MaintenancePlanAssetData buildResponse (MaintenancePlanAssetData maintenancePlanAssetData, Map<Id, Id> assetIdMaintenanceAssetIdMap){
        
        for(MaintenanceAssetData maintenanceAssetData : maintenancePlanAssetData.maintenanceAssetDataList){
            if (assetIdMaintenanceAssetIdMap.containsKey(Id.valueOf(maintenanceAssetData.assetId)) ) {
                maintenanceAssetData.maintenanceAssetId = assetIdMaintenanceAssetIdMap.get(Id.valueOf(maintenanceAssetData.assetId));
            }
        }
        return maintenancePlanAssetData;
    }

    //building maintenanceAsset reference for asset
    private List<MaintenanceAsset> getMaintenanceAssets(List<Asset> assetList , List<SVMXA360__ApplicableProduct__c>  applicableProductList, MaintenancePlan maintenancePlan , Map<String,MaintenanceAssetData> assetIdMaintenanceAssetDataMap){
        List<MaintenanceAsset> maintenanceAssetList = new List<MaintenanceAsset>();
        Map<String, SVMXA360__ApplicableProduct__c > product2IdApplicableProductMap = new  Map<String, SVMXA360__ApplicableProduct__c>();
        Map<String, SVMXA360__ApplicableProduct__c > product2FamilyMap = new  Map<String, SVMXA360__ApplicableProduct__c>();
        Map<String, Schema.SObjectField> fieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenanceAsset');//all field name will be in lower case 
        for(SVMXA360__ApplicableProduct__c applicableProduct : applicableProductList ){
            
            if( String.isNotBlank(applicableProduct.SVMXA360__ProductId__c)){
                product2IdApplicableProductMap.put(applicableProduct.SVMXA360__ProductId__c,applicableProduct);
            }
            else if(String.isNotBlank(applicableProduct.SVMXA360__ProductFamily__c) ){
                product2FamilyMap.put(applicableProduct.SVMXA360__ProductFamily__c, applicableProduct );
            }
        }
        for(Asset asset : assetList ){
    
            if(product2IdApplicableProductMap.containsKey(asset.Product2Id)){
                
                maintenanceAssetList.add( createMaintenanceAssetSobjectReference( asset, product2IdApplicableProductMap.get(asset.Product2Id), maintenancePlan, assetIdMaintenanceAssetDataMap, fieldMap));

            }else if(product2FamilyMap.containsKey(asset.ProductFamily)){

                maintenanceAssetList.add( createMaintenanceAssetSobjectReference( asset, product2FamilyMap.get(asset.ProductFamily), maintenancePlan, assetIdMaintenanceAssetDataMap, fieldMap ));
            } else {
                maintenanceAssetList.add( createMaintenanceAssetSobjectReference( asset, new SVMXA360__ApplicableProduct__c() , maintenancePlan, assetIdMaintenanceAssetDataMap, fieldMap ));
            }
        }
        return maintenanceAssetList;
    }

    private MaintenanceAsset createMaintenanceAssetSobjectReference(Asset asset , SVMXA360__ApplicableProduct__c applicableProduct, MaintenancePlan maintenancePlan , Map<String,MaintenanceAssetData> assetIdMaintenanceAssetDataMap, Map<String, Schema.SObjectField> fieldMap ){
        
        MaintenanceAssetData maintenanceAssetData = assetIdMaintenanceAssetDataMap.get(asset.Id);

        MaintenanceAsset maintenanceAsset = new MaintenanceAsset();
        maintenanceAsset.put('assetId', asset.Id);
        maintenanceAsset.put('maintenancePlanId', maintenancePlan.id);
        if (applicableProduct.SVMXA360__WorkTypeId__c != null) {
            maintenanceAsset.put('workTypeId', applicableProduct.SVMXA360__WorkTypeId__c);
        }
        if (maintenanceAssetData.dateOfFirstWorkOrderInNextBatch != null) {
            maintenanceAsset.put('nextSuggestedMaintenanceDate', maintenanceAssetData.dateOfFirstWorkOrderInNextBatch);
        }
        if (String.isNotBlank(maintenanceAssetData.subscribedAssetId) && String.isNotBlank(maintenanceAssetData.subscribedAssetFieldName) && fieldMap.containsKey(maintenanceAssetData.subscribedAssetFieldName.toLowerCase())) {
            maintenanceAsset.put(maintenanceAssetData.subscribedAssetFieldName, maintenanceAssetData.subscribedAssetId);
        }
        return maintenanceAsset;
    }

    private List<Asset> getAssets(List<String> assetIds){
        return SvmxDatabase.query([SELECT  Id, Name, Product2Id, ProductFamily, ParentId, RootAssetId FROM Asset WHERE Id IN: assetIds]);
    }

    private List<SVMXA360__MaintenanceWorkRuleTemplate__c> getMaintenanceWorkRuleTemplates(String templateId){
        String queryString = 'SELECT ' + String.join(mWorkRuleTemplateFieldList, ',') + ' FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__MaintenancePlanTemplateId__c = \'' + String.escapeSingleQuotes(templateId) + '\'' + ' AND SVMXA360__TemplateType__c = \'Applicable Product\'';
        return SvmxDatabase.query(queryString);
    }

    private List<MaintenanceWorkRule> getMaintenanceWorkRuleForAsset(List<Asset> assetList, List<SVMXA360__ApplicableProduct__c>  applicableProductList,MaintenancePlan maintenancePlan , List<SVMXA360__MaintenanceWorkRuleTemplate__c> maintenanceWorkRuleTemplateList,  Map<Id, Id> assetIdMaintenanceAssetIdMap ){
        List<MaintenanceWorkRule> maintenanceWorkRuleList = new List<MaintenanceWorkRule>();
        Map<Id, Id> productIdApplicableProductIdMap2 = new Map<Id, Id>();
        Map<String, Id> productFamilyApplicableProductIdMap2 = new Map<String, Id>();
        Set<String> recordsetFilterCriteriaIdSet = new Set<String>();
        for (SVMXA360__MaintenanceWorkRuleTemplate__c mWorkRuleTemplate : maintenanceWorkRuleTemplateList) {
            if (String.isNotBlank(mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c)) {
                recordsetFilterCriteriaIdSet.add(mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c);
            }
        }
        List<RecordsetFilterCriteria> recordsetFilterCriteriaList = SvmxDatabase.query([SELECT Id FROM RecordsetFilterCriteria WHERE Id IN: recordsetFilterCriteriaIdSet]);
        recordsetFilterCriteriaIdSet.clear();
        for (RecordsetFilterCriteria objRecordsetFilterCriteria : recordsetFilterCriteriaList) {
            recordsetFilterCriteriaIdSet.add(objRecordsetFilterCriteria.Id);
        }
        
        for(SVMXA360__ApplicableProduct__c applicableProduct : applicableProductList){
            if(String.isNotBlank(applicableProduct.SVMXA360__ProductId__c)){
                productIdApplicableProductIdMap2.put(applicableProduct.SVMXA360__ProductId__c,applicableProduct.Id);
            }
            else if(String.isNotBlank(applicableProduct.SVMXA360__ProductFamily__c)){
                productFamilyApplicableProductIdMap2.put(applicableProduct.SVMXA360__ProductFamily__c, applicableProduct.Id);
            }
        }
        Map<Id, List<SVMXA360__MaintenanceWorkRuleTemplate__c>> appProductIdWorkRuleListMap = new Map<Id, List<SVMXA360__MaintenanceWorkRuleTemplate__c>>();
        for (SVMXA360__MaintenanceWorkRuleTemplate__c mWorkRuleTemplate : maintenanceWorkRuleTemplateList) {
            if (mWorkRuleTemplate.SVMXA360__TemplateType__c == 'Applicable Product') {
                if (mWorkRuleTemplate.SVMXA360__Type__c == 'CriteriaValue' && (!recordsetFilterCriteriaIdSet.contains(mWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c) || !mWorkRuleFieldMap.containsKey(RECORDSET_FILTER_CRITERIA_FIELD))) {
                    continue;
                }
                if (!appProductIdWorkRuleListMap.containsKey(mWorkRuleTemplate.SVMXA360__ApplicableProductId__c)) {
                    appProductIdWorkRuleListMap.put(mWorkRuleTemplate.SVMXA360__ApplicableProductId__c, new List<SVMXA360__MaintenanceWorkRuleTemplate__c>());
                }
                appProductIdWorkRuleListMap.get(mWorkRuleTemplate.SVMXA360__ApplicableProductId__c).add(mWorkRuleTemplate);   
            }
        }
        // Based on Asset get applicableProductId and then based on applicableProductId get related Work Rule Template List and then populate MaintenanceWorkRule
        for (Asset assetRecord : assetList) {
            Id applicableProductId = null;
            if (productIdApplicableProductIdMap2.containsKey(assetRecord.Product2Id)) {
                applicableProductId = productIdApplicableProductIdMap2.get(assetRecord.Product2Id);
            } else if (productFamilyApplicableProductIdMap2.containsKey(assetRecord.ProductFamily)) {
                applicableProductId = productFamilyApplicableProductIdMap2.get(assetRecord.ProductFamily);
            }

            if (String.isNotBlank(applicableProductId) && appProductIdWorkRuleListMap.containsKey(applicableProductId)) {
                List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList = appProductIdWorkRuleListMap.get(applicableProductId);
                String parentId = assetIdMaintenanceAssetIdMap.get(assetRecord.Id);
                List<MaintenanceWorkRule> maintenanceWorkRuleForMAssetList = buildMaintenanceWorkRuleList(maintenancePlan, workRuleTemplateList, parentId, MAINTENANCE_ASSET);
                maintenanceWorkRuleList.addAll(maintenanceWorkRuleForMAssetList);
            }
        }
        return maintenanceWorkRuleList;
    }

    // Method Implementation for CPQ
    public Common.ServiceResponse createMaintenancePlan(MaintenancePlanData maintenancePlanData) {
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        serviceResponse.success = true;
        Savepoint savePoint = Database.setSavepoint();

        try {

            // check for valid request
            if (maintenancePlanData == null) {
                System.debug(LoggingLevel.ERROR, 'createMaintenancePlan Invalid request, maintenancePlanData: '+ maintenancePlanData);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            // check for valid request
            if (!isValidsObjectTypeId(maintenancePlanData.sourceRecordId, Schema.Account.SObjectType) || maintenancePlanData.startDate == null || maintenancePlanData.maintenancePlanTemplateProductId == null) {
                System.debug(LoggingLevel.ERROR, 'createMaintenancePlan Invalid parameter, maintenancePlanData: '+ maintenancePlanData);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // check for valid request
            if ((String.isBlank(maintenancePlanData.subscriptionId) && String.isNotBlank(maintenancePlanData.subscriptionFieldName)) || (String.isNotBlank(maintenancePlanData.subscriptionId) && String.isBlank(maintenancePlanData.subscriptionFieldName))) {
                System.debug(LoggingLevel.ERROR, 'createMaintenancePlan Invalid parameter, maintenancePlanData: '+ maintenancePlanData);
                throw new SvmxSystem.SvmxNestedException('Both request parameters subscriptionId and subscriptionFieldName must have value. One of the parameter is missing value.');
            }

            // Query Maintenance Plan Template record based on maintenancePlanTemplateProductId in the request
            String queryString = 'SELECT ' + String.join(mPlanTemplateFieldList, ',') + ' FROM SVMXA360__MaintenancePlanTemplate__c WHERE SVMXA360__MaintenancePlanTemplateProductId__c = \'' + String.escapeSingleQuotes(maintenancePlanData.maintenancePlanTemplateProductId) + '\' AND SVMXA360__IsActive__c = true';
            List<SVMXA360__MaintenancePlanTemplate__c> mPlanTemplate = SvmxDatabase.query(queryString);

            if (mPlanTemplate.isEmpty()) {
                System.debug(LoggingLevel.ERROR, 'createMaintenancePlan: No Maintenance Plan Template record exist for given maintenancePlanTemplateProductId, maintenancePlanData: '+ maintenancePlanData);
                throw new SvmxSystem.SvmxNestedException('No Maintenance Plan Template record exist for given maintenancePlanTemplateProductId');
            }

            if (mPlanTemplate.size() > 1) {
                System.debug(LoggingLevel.ERROR, 'createMaintenancePlan: Found multiple Maintenance Plan Template records for given maintenancePlanTemplateProductId, maintenancePlanData: '+ maintenancePlanData);
                throw new SvmxSystem.SvmxNestedException('Found multiple Maintenance Plan Template records for given maintenancePlanTemplateProductId');
            }

            // copy data from template to Maintenance Plan and insert MaintenancePlan
            MaintenancePlan maintenancePlanRecord = insertMaintenancePlan(mPlanTemplate[0], maintenancePlanData);

            // query Maintenance Work Rule Template and populate MaintenanceWorkRule for MaintenancePlan
            queryString = 'SELECT ' + String.join(mWorkRuleTemplateFieldList, ',') + ' FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__MaintenancePlanTemplateId__c = \'' + String.escapeSingleQuotes(mPlanTemplate[0].Id) + '\'' + ' AND SVMXA360__TemplateType__c = \'Maintenance Plan Template\'';
            List<SVMXA360__MaintenanceWorkRuleTemplate__c> mWorkRuleTemplateList = SvmxDatabase.query(queryString);
            List<MaintenanceWorkRule> maintenanceWorkRuleList = new List<MaintenanceWorkRule>();
            for (SVMXA360__MaintenanceWorkRuleTemplate__c mWorkRuleTemplate : mWorkRuleTemplateList) {
                MaintenanceWorkRule maintenanceWorkRuleRecord = buildMaintenanceWorkRule(maintenancePlanRecord, mWorkRuleTemplate, maintenancePlanRecord.Id, MAINTENANCE_PLAN);
                maintenanceWorkRuleList.add(maintenanceWorkRuleRecord);
            }

            // Insert Maintenance Work Rule
            if ( !maintenanceWorkRuleList.isEmpty() ) {
                SvmxDatabase.insertRecord(maintenanceWorkRuleList);
            }

            // populate created MaintenancePlan Id in the response
            maintenancePlanData.maintenancePlanId = maintenancePlanRecord.Id;
            serviceResponse.data = maintenancePlanData;
        }
        catch (SvmxSystem.SvmxNestedException e) {
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            Database.rollback(savePoint);
        }
        catch (Exception e) {
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            Database.rollback(savePoint);
        }

        return serviceResponse;
    }

    private MaintenancePlan insertMaintenancePlan(SVMXA360__MaintenancePlanTemplate__c mPlanTemplate, MaintenancePlanData maintenancePlanData) {

        Map<String, Schema.SObjectField> fieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenancePlan');//all field names is in lower case
        Date startDate = maintenancePlanData.startDate;
        Date endDate;
        Integer duration = mPlanTemplate.SVMXA360__MaintenancePlanDuration__c != null ? Integer.valueOf(mPlanTemplate.SVMXA360__MaintenancePlanDuration__c) : null;
        String unitOfTime = mPlanTemplate.SVMXA360__MaintenancePlanUnitOfTime__c;

        if (duration != null && String.isNotBlank(unitOfTime)) {
            endDate = COMM_DateLiteralUtils.calculateEndDate(startDate, duration, unitOfTime);
        }

        MaintenancePlan maintenancePlanRecord = buildMaintenancePlanFromTemplate(mPlanTemplate, maintenancePlanData, endDate, 'Account');

        if (String.isNotBlank(maintenancePlanData.subscriptionFieldName) && String.isNotBlank(maintenancePlanData.subscriptionId) && fieldMap.containsKey(maintenancePlanData.subscriptionFieldName.toLowerCase())) {
            maintenancePlanRecord.put(maintenancePlanData.subscriptionFieldName, maintenancePlanData.subscriptionId);
        }

        if (maintenancePlanRecord != null) {
            SvmxDatabase.insertRecord(maintenancePlanRecord);
        }

        return maintenancePlanRecord;
    }

    private MaintenancePlan buildMaintenancePlanFromTemplate(SVMXA360__MaintenancePlanTemplate__c mPlanTemplate, MaintenancePlanData maintenancePlanData, Date endDate, String source) {
        // Populate data in MaintenancePlan record
        MaintenancePlan maintenancePlanRecord = new MaintenancePlan();
        maintenancePlanRecord.AccountId = maintenancePlanData.sourceRecordId;
        maintenancePlanRecord.SVMXA360__MaintenancePlanTemplateId__c = mPlanTemplate.Id;
        maintenancePlanRecord.SVMXA360__Source__c = source;
        maintenancePlanRecord.MaintenancePlanTitle = maintenancePlanData.maintenancePlanTitle;
        maintenancePlanRecord.NextSuggestedMaintenanceDate = maintenancePlanData.dateOfFirstWorkOrderInNextBatch != null ? maintenancePlanData.dateOfFirstWorkOrderInNextBatch : maintenancePlanData.startDate;
        maintenancePlanRecord.StartDate = maintenancePlanData.startDate;
        maintenancePlanRecord.EndDate = endDate;
        maintenancePlanRecord.DoesAutoGenerateWorkOrders = mPlanTemplate.SVMXA360__DoesAutoGenerateWorkOrders__c;
        maintenancePlanRecord.DoesGenerateUponCompletion = mPlanTemplate.SVMXA360__DoesGenerateUponCompletion__c;
        maintenancePlanRecord.GenerationHorizon = Integer.valueOf(mPlanTemplate.SVMXA360__GenerationHorizon__c);
        maintenancePlanRecord.GenerationTimeframe = Integer.valueOf(mPlanTemplate.SVMXA360__GenerationTimeframe__c);
        maintenancePlanRecord.GenerationTimeframeType = mPlanTemplate.SVMXA360__GenerationTimeframeType__c;
        maintenancePlanRecord.MaintenanceWindowEndDays = Integer.valueOf(mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c);
        maintenancePlanRecord.MaintenanceWindowStartDays = Integer.valueOf(mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c);
        maintenancePlanRecord.SvcApptGenerationMethod = mPlanTemplate.SVMXA360__SvcApptGenerationMethod__c;
        maintenancePlanRecord.WorkOrderGenerationMethod = mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c;
        maintenancePlanRecord.WorkTypeId = mPlanTemplate.SVMXA360__WorkTypeId__c;
        if (!mPlanFieldMap.isEmpty() && mPlanFieldMap.containsKey(FREQUENCY_FIELD) && mPlanFieldMap.containsKey(FREQUENCY_TYPE_FIELD)) {
            maintenancePlanRecord.put(FREQUENCY_FIELD, FREQUENCY_VALUE);
            maintenancePlanRecord.put(FREQUENCY_TYPE_FIELD, FREQUENCY_TYPE_VALUE);
        }
        maintenancePlanRecord.SVMXA360__SM_Status__c = MP_STATUS_ACTIVE_VALUE;

        return maintenancePlanRecord;
    }

    public void authorMaintenancePlan(SVMXA360__ApplicationEventBus__e event) {

        System.debug(LoggingLevel.INFO, 'authorMaintenancePlan - enter');

        try {
            if (event != null && String.isNotBlank(event.SVMXA360__Payload__c) && String.isNotBlank(event.SVMXA360__SourceRecordId__c)) {
            
                List<String> payLoadItems = event.SVMXA360__Payload__c.split(';');
    
                if (payLoadItems.size() == 2) {
    
                    // Create request for calling method executeMaintenancePlan
                    Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
                    request.sourceRecordId = event.SVMXA360__SourceRecordId__c;
                    request.templateId = payLoadItems[0];
    
                    // Calling method executeMaintenancePlan
                    MaintenancePlan maintenancePlan = executeMaintenancePlan(request);
    
                    // If MaintenancePlan creation is successfull, then create success MPLN Authoring Log
                    if (maintenancePlan != null && maintenancePlan.Id != null) {
                        MPLN_AuthoringLogManager.getInstance().createSuccessLog(event, maintenancePlan);
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'authorMaintenancePlan() : Failed to execute authorMaintenancePlan. Error= ' + e.getMessage());
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'authorMaintenancePlan() - exit;');
        }
    }

    private Integer getRemainingDmlRowCount() {
        return Limits.getLimitDmlRows() - Limits.getDMLRows() - REQUIRED_DML_ROW_COUNT;
    }

    private Boolean isValidsObjectTypeId(String inputId, SObjectType sObjectType) {
        return ( String.isNotBlank(inputId) && inputId instanceOf ID && ID.valueOf(inputId).getSobjectType() == sObjectType) ? true : false;
    }
}