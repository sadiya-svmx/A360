@IsTest
public class PSC_ManageResultsHandler_UT {

    static Boolean createPricebookEntry = true;

    @IsTest
    static void testGetResultLineStatusWithNull(){
        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        Psc.ResultLineStatus response = new Psc.ResultLineStatus();

        try{
            response = manageResultsHandler.getResultLineStatus(null);
        } catch(Exception e) {
            System.assert(response.isBatchRunning == null);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testGetResultLineStatusWithLine(){
        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecords();
        Psc.ResultLineStatus response = manageResultsHandler.getResultLineStatus(String.valueOf(pscRecord.Id));
        System.assert(response.isBatchRunning == false);
        System.assert(response.casesDelivered == 1);
        System.assert(response.linesDelivered == 1);
        System.assert(response.linesGenerated == 1);
        
        Test.stopTest();
    }

    @IsTest
    static void testGetResultLinesWithNull(){
        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        List<Map<String, Object>> response = new List<Map<String, Object>>();

        try{
            response = manageResultsHandler.getResultLines(null);
        } catch(Exception e) {
            System.assert(response.size() == 0);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testGetResultLines(){
        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecords();

        Psc.ResultLineRequest request = new Psc.ResultLineRequest();
        request.id = pscRecord.Id;
        request.fieldApiNames = new List<String>{'Asset.Name', 'Asset.Location.Name', 'Status'};

        List<Map<String, Object>> response = manageResultsHandler.getResultLines(request);
        System.assert(response.size() == 1);
        
        Test.stopTest();
    }

    @IsTest
    static void testGetAddAssetColumns(){
        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        List<Psc.ColumnInformation> response = manageResultsHandler.getAddAssetColumns();
        System.assert(response.size() > 0);
        
        Test.stopTest();
    }

    @IsTest
    static void testGetAssetRecordsWithData(){
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Test.startTest();
        
        Psc.SearchAssetRequest request = new Psc.SearchAssetRequest();
        request.id = product.Id;
        request.searchKeyword = 'Test';
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        List<Asset> response = manageResultsHandler.getAssetRecords(request);
        System.assert(response != null);
        
        Test.stopTest();
    }

    @IsTest
    static void testGetAssetRecordsWithInvalidRequest(){

        Test.startTest();
        
        Psc.SearchAssetRequest request = new Psc.SearchAssetRequest();
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        List<Asset> response;
        try{
            response = manageResultsHandler.getAssetRecords(request);
        } catch(Exception e){
            System.assert(e.getMessage() == ErrorMessage.MISSING_REQUIRED_PARAMETER);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testInsertUpdatePsciRecordsWithNull(){

        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        try {
            manageResultsHandler.insertUpdatePsciRecords(null);
        } catch (Exception e) {
            System.assert(e.getMessage() == ErrorMessage.INVALID_ARGUMENT);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testInsertUpdatePsciRecordsWithInvalidData(){

        List<ProductServiceCampaignItem> psciRecordList = new List<ProductServiceCampaignItem>();

        ProductServiceCampaignItem psciRecord = new ProductServiceCampaignItem();
        psciRecord.SVMXA360__DeliveryMethod__c = 'Case';
        psciRecordList.add(psciRecord);

        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        try{
            manageResultsHandler.insertUpdatePsciRecords(psciRecordList);
        } catch(Exception e) {
            System.assert(e.getMessage() != null);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testInsertUpdatePsciRecordsWithData(){

        Date todayDate = System.today();
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2)
        });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        List<ProductServiceCampaignItem> psciRecordList = new List<ProductServiceCampaignItem>();

        ProductServiceCampaignItem psciRecord = new ProductServiceCampaignItem();
        psciRecord.ProductServiceCampaignId = pscRecord.Id;
        psciRecord.AssetId = assetRecord.Id;
        psciRecord.SVMXA360__DeliveryMethod__c = 'Case';
        psciRecordList.add(psciRecord);

        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        manageResultsHandler.insertUpdatePsciRecords(psciRecordList);

        List<ProductServiceCampaignItem> psciList = [SELECT Id, SVMXA360__DeliveryMethod__c FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecord.Id];
        System.assert(psciList.size() == 1);
        System.assert(psciList[0].SVMXA360__DeliveryMethod__c == 'Case');
        
        Test.stopTest();
    }

    @IsTest
    static void testInitiateGenerateOutputBatchWithNull(){

        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        try {
            manageResultsHandler.initiateGenerateOutputBatch(null);
        } catch (Exception e) {
            System.assert(e.getMessage() == ErrorMessage.INVALID_ARGUMENT);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testInitiateGenerateOutputBatchWithDummyId(){

        Test.startTest();
        
        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        try {
            manageResultsHandler.initiateGenerateOutputBatch('jf8euf98jfijew');
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testInitiateGenerateOutputBatchForWorkOrder(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(true, false, false, true, false, false);
        String pscRecordId = pscRecord.Id;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM WorkOrder WHERE ProductServiceCampaignId =: pscRecordId') == 1);

        Psc.SearchCriteria response2 = new PSC_SearchCriteriaHandler().getSearchCriteriaStatus(pscRecordId);
        System.assert(response2.status == 'RESULT_LINES_DELIVERED');
    }

    @IsTest
    static void testInitiateGenerateOutputBatchForReturnOrder(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, true, false, true, false, false);
        String pscRecordId = pscRecord.Id;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM ReturnOrder WHERE ProductServiceCampaignId =: pscRecordId') == 1);
    }

    @IsTest
    static void testInitiateGenerateOutputBatchForCase(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, false, true, true, false, false);
        String pscRecordId = pscRecord.Id;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM Case WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId') == 1);
    }

    @IsTest
    static void testInitiateGenerateOutputBatchForOpportunity(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, false, false, true, true, false);
        String pscRecordId = pscRecord.Id;
        Pricebook2 standardPricebook = new Pricebook2( Id = Test.getStandardPricebookId(), IsActive = true );
        Update standardPricebook;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM Opportunity WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId') == 1);

        String str1 = 'This is Test String';
        String str2 = 'This is Second String';
        Integer maxLength = 25;
        String endResult = PSC_ManageResultsHandler.formatName(str1, str2, maxLength);
        System.assert(endResult.length() == 25);
    }

    @IsTest
    static void testInitGenOutBatchForOppntyWithInActivePB(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, false, false, true, true, false);
        String pscRecordId = pscRecord.Id;
        Pricebook2 standardPricebook = new Pricebook2( Id = Test.getStandardPricebookId(), IsActive = false );
        Update standardPricebook;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM Opportunity WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId') == 0);
    }

    @IsTest
    static void testInitGenOutBatchForOppntyWithoutPB(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, false, false, true, true, false);
        pscRecord.SVMXA360__PriceBookId__c = null;
        update pscRecord;
        String pscRecordId = pscRecord.Id;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM Opportunity WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId') == 0);
    }

    @IsTest
    static void testInitGenOutBatchForOpportunityWithError(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        createPricebookEntry = false;
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, false, false, true, true, false);
        String pscRecordId = pscRecord.Id;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM Opportunity WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId') == 0);
    }

    @IsTest
    static void testInitGenOutputForAssetNotification(){

        PSC_ManageResultsHandler manageResultsHandler = new PSC_ManageResultsHandler();
        ProductServiceCampaign pscRecord = createRecordsForBatchClass(false, false, false, true, false, true);
        String pscRecordId = pscRecord.Id;

        Test.startTest();

        manageResultsHandler.initiateGenerateOutputBatch(pscRecordId);
        
        Test.stopTest();

        System.assert(Database.countQuery('SELECT count() FROM SVMXA360__AssetNotification__c WHERE SVMXA360__ProductServiceCampaignId__c =: pscRecordId') == 1);
    }

    static ProductServiceCampaign createRecordsForBatchClass(Boolean forWorkOrder, Boolean forReturnOrder, Boolean forCase, Boolean isActivePscConf, Boolean forOpportunity, Boolean forAssetNoti) {
        Date todayDate = System.today();
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        SVMXA360__CONF_PSCConfiguration__c pscConfiguration = createPscConfiguration(forWorkOrder, forReturnOrder, forCase, isActivePscConf, forOpportunity, forAssetNoti);

        // Pricebook
        Id pricebookId;
        if (forOpportunity) {
            pricebookId = Test.getStandardPricebookId();
            if (createPricebookEntry) {
                PricebookEntry pricebookEntryRecord1 = (PricebookEntry) SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String, Object> {
                    'Pricebook2Id' =>  pricebookId,
                    'IsActive' => true,
                    'UnitPrice' => 1.0,
                    'Product2Id' => product.Id,
                    'UseStandardPrice' => false
                });
            }
        }

        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2),
            'SVMXA360__PSCConfigurationId__c' => pscConfiguration.Id,
            'SVMXA360__PriceBookId__c' => pricebookId
        });

        /* SVMXA360__PSCRequiredParts__c pscRequiredPart = (SVMXA360__PSCRequiredParts__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__PSCRequiredParts__c', 
        new Map<String,Object>{
            'SVMXA360__Quantity__c' => 2.00,
            'SVMXA360__ProductId__c' => product.Id,
            'SVMXA360__ProductServiceCampaignId__c' => pscRecord.Id
        }); */

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        
        Asset assetRecord1 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Asset assetRecord2 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset2',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Asset assetRecord3 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset2',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Asset assetRecord4 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset3',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Asset assetRecord5 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset5',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        if (forWorkOrder) {
            ProductServiceCampaignItem psciRecord1 = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
            new Map<String,Object>{
                'ProductServiceCampaignId' => pscRecord.Id,
                'AssetId' => assetRecord1.Id,
                'SVMXA360__DeliveryMethod__c' => 'WorkOrder',
                'Status' => 'Draft'
            });
        }
        
        if (forReturnOrder) {
            ProductServiceCampaignItem psciRecord2 = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
            new Map<String,Object>{
                'ProductServiceCampaignId' => pscRecord.Id,
                'AssetId' => assetRecord2.Id,
                'SVMXA360__DeliveryMethod__c' => 'ReturnOrder',
                'Status' => 'Draft'
            });
        }
        
        if (forCase) {
            ProductServiceCampaignItem psciRecord3 = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
            new Map<String,Object>{
                'ProductServiceCampaignId' => pscRecord.Id,
                'AssetId' => assetRecord3.Id,
                'SVMXA360__DeliveryMethod__c' => 'Case',
                'Status' => 'Draft'
            });
        }

        if (forOpportunity) {
            ProductServiceCampaignItem psciRecord4 = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
            new Map<String,Object>{
                'ProductServiceCampaignId' => pscRecord.Id,
                'AssetId' => assetRecord4.Id,
                'SVMXA360__DeliveryMethod__c' => 'Opportunity',
                'Status' => 'Draft'
            });
        }

        if (forAssetNoti) {
            ProductServiceCampaignItem psciRecord4 = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
            new Map<String,Object>{
                'ProductServiceCampaignId' => pscRecord.Id,
                'AssetId' => assetRecord5.Id,
                'SVMXA360__DeliveryMethod__c' => 'AssetNotification',
                'Status' => 'Draft'
            });
        }

        return pscRecord;
    }

    static SVMXA360__CONF_PSCConfiguration__c createPscConfiguration(Boolean workOrderMapping, Boolean returnOrderMapping, Boolean caseMapping, Boolean isActive, Boolean forOpportunity, Boolean forAssetNoti) {
        List<PscMappingConfiguration> pscMapConfList = new List<PscMappingConfiguration>();
        PscMappingConfiguration pscMapConf;

        if (workOrderMapping) {
            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'PSC2WORD';
            pscMapConf.targetMappingId = createPscToWorkOrderMapping();
            pscMapConfList.add(pscMapConf);

            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'ASSET2WORD';
            pscMapConf.targetMappingId = createAssetToWorkOrderMapping();
            pscMapConfList.add(pscMapConf);
        }

        if (returnOrderMapping) {
            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'PSC2RORD';
            pscMapConf.targetMappingId = createPscToReturnOrderMapping();
            pscMapConfList.add(pscMapConf);

            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'ASSET2RORD';
            pscMapConf.targetMappingId = createAssetToReturnOrderMapping();
            pscMapConfList.add(pscMapConf);
        }

        if (caseMapping) {
            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'PSC2CASE';
            pscMapConf.targetMappingId = createPscToCaseMapping();
            pscMapConfList.add(pscMapConf);

            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'ASSET2CASE';
            pscMapConf.targetMappingId = createAssetToCaseMapping();
            pscMapConfList.add(pscMapConf);
        }

        if (forOpportunity) {
            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'PSC2OPPNTY';
            pscMapConf.targetMappingId = createPscToOpportunityMapping();
            pscMapConfList.add(pscMapConf);

            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'ASSET2OPPNTYPROD';
            pscMapConf.targetMappingId = createAssetToOppntyProdMapping();
            pscMapConfList.add(pscMapConf);
        }

        if (forAssetNoti) {
            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'PSC2ASSETNOTI';
            pscMapConf.targetMappingId = createPscToAssetNotificationMapping();
            pscMapConfList.add(pscMapConf);

            pscMapConf = new PscMappingConfiguration();
            pscMapConf.targetMappingKey = 'ASSET2ASSETNOTI';
            pscMapConf.targetMappingId = createAssetToAssetNotificationMapping();
            pscMapConfList.add(pscMapConf);
        }

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'PSC_Configuration' AND SobjectType = 'SVMXA360__CONF_PSCConfiguration__c'];
        SVMXA360__CONF_PSCConfiguration__c pscConfiguration = new SVMXA360__CONF_PSCConfiguration__c();
        pscConfiguration.RecordTypeId = rt.Id;
        pscConfiguration.SVMXA360__Active__c = isActive;
        pscConfiguration.Name = 'PscTestConfiguration';
        pscConfiguration.SVMXA360__DeveloperName__c = 'PscTestConfiguration';
        pscConfiguration.SVMXA360__Email__c = 'test@test.com';
        pscConfiguration.SVMXA360__PSCMappingJSON__c = JSON.serialize(pscMapConfList);
        insert pscConfiguration;

        RecordType rtSetting = [SELECT Id FROM RecordType WHERE DeveloperName = 'PSC_Settings' AND SobjectType = 'SVMXA360__CONF_PSCConfiguration__c'];
        SVMXA360__CONF_PSCConfiguration__c pscSetting = (SVMXA360__CONF_PSCConfiguration__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_PSCConfiguration__c', 
        new Map<String,Object>{
            'RecordTypeId' => rtSetting.Id,
            'SVMXA360__Active__c' => true,
            'Name' => 'Default PSC Settings',
            'SVMXA360__DeveloperName__c' => 'Default_PSC_Settings',
            'SVMXA360__SearchBatchSize__c' => 250.0,
            'SVMXA360__DeliveryBatchSize__c' => 1.0,
            'SVMXA360__SearchResultsPerPSC__c' => 500.0,
            'SVMXA360__Scope__c' => 'Global'
        });

        return pscConfiguration;
    }

    static String createPscToWorkOrderMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'PscToWorkOrder',
            'SVMXA360__DeveloperName__c' => 'PscToWorkOrder',
            'SVMXA360__SourceObjectAPIName__c' => 'ProductServiceCampaign',
            'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Product2Id',
            'SVMXA360__TargetFieldAPIName__c' => 'SVMXA360__ProductId__c',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createAssetToWorkOrderMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'Asset_To_Work_Order',
            'SVMXA360__DeveloperName__c' => 'Asset_To_Work_Order',
            'SVMXA360__SourceObjectAPIName__c' => 'Asset',
            'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createPscToReturnOrderMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'PSC_To_ReturnOrder',
            'SVMXA360__DeveloperName__c' => 'PSC_To_ReturnOrder',
            'SVMXA360__SourceObjectAPIName__c' => 'ProductServiceCampaign',
            'SVMXA360__TargetObjectAPIName__c' => 'ReturnOrder',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createAssetToReturnOrderMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'Asset_To_ReturnOrder',
            'SVMXA360__DeveloperName__c' => 'Asset_To_ReturnOrder',
            'SVMXA360__SourceObjectAPIName__c' => 'Asset',
            'SVMXA360__TargetObjectAPIName__c' => 'ReturnOrder',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createPscToCaseMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'PSC_To_Case',
            'SVMXA360__DeveloperName__c' => 'PSC_To_Case',
            'SVMXA360__SourceObjectAPIName__c' => 'ProductServiceCampaign',
            'SVMXA360__TargetObjectAPIName__c' => 'Case',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Product2Id',
            'SVMXA360__TargetFieldAPIName__c' => 'ProductId',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createAssetToCaseMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'AST_CASE_Mapping',
            'SVMXA360__DeveloperName__c' => 'AST_CASE_Mapping',
            'SVMXA360__SourceObjectAPIName__c' => 'Asset',
            'SVMXA360__TargetObjectAPIName__c' => 'Case',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createPscToOpportunityMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'PSC_To_Opportunity',
            'SVMXA360__DeveloperName__c' => 'PSC_To_Opportunity',
            'SVMXA360__SourceObjectAPIName__c' => 'ProductServiceCampaign',
            'SVMXA360__TargetObjectAPIName__c' => 'Opportunity',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => null,
            'SVMXA360__Value__c' => 'FSVMXTOMORROW',
            'SVMXA360__TargetFieldAPIName__c' => 'CloseDate',
            'SVMXA360__Type__c' => 'Function'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'ProductServiceCampaignName',
            'SVMXA360__TargetFieldAPIName__c' => 'Name',
            'SVMXA360__Type__c' => 'Field'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => null,
            'SVMXA360__Value__c' => 'Qualification',
            'SVMXA360__TargetFieldAPIName__c' => 'StageName',
            'SVMXA360__Type__c' => 'Value'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createAssetToOppntyProdMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'ASSET_OppntyProd_Mapping',
            'SVMXA360__DeveloperName__c' => 'ASSET_OppntyProd_Mapping',
            'SVMXA360__SourceObjectAPIName__c' => 'Asset',
            'SVMXA360__TargetObjectAPIName__c' => 'OpportunityLineItem',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'Description',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createPscToAssetNotificationMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'PSC_To_AssetNotification',
            'SVMXA360__DeveloperName__c' => 'PSC_To_AssetNotification',
            'SVMXA360__SourceObjectAPIName__c' => 'ProductServiceCampaign',
            'SVMXA360__TargetObjectAPIName__c' => 'SVMXA360__AssetNotification__c',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'SVMXA360__Description__c',
            'SVMXA360__Type__c' => 'Field'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => null,
            'SVMXA360__Value__c' => 'Critical',
            'SVMXA360__TargetFieldAPIName__c' => 'SVMXA360__Severity__c',
            'SVMXA360__Type__c' => 'Value'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => null,
            'SVMXA360__Value__c' => 'Open',
            'SVMXA360__TargetFieldAPIName__c' => 'SVMXA360__Status__c',
            'SVMXA360__Type__c' => 'Value'
        });

        objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => null,
            'SVMXA360__Value__c' => 'Test_Title',
            'SVMXA360__TargetFieldAPIName__c' => 'SVMXA360__Title__c',
            'SVMXA360__Type__c' => 'Value'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    static String createAssetToAssetNotificationMapping() {
        SVMXA360__CONF_ObjectMapping__c objectMapping = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', 
        new Map<String,Object>{
            'Name' => 'AST_TO_AssetNotification',
            'SVMXA360__DeveloperName__c' => 'AST_TO_AssetNotification',
            'SVMXA360__SourceObjectAPIName__c' => 'Asset',
            'SVMXA360__TargetObjectAPIName__c' => 'SVMXA360__AssetNotification__c',
            'SVMXA360__Type__c' => 'Field Mapping'
        });

        SVMXA360__CONF_ObjectMappingDetail__c objectMappingDetail = (SVMXA360__CONF_ObjectMappingDetail__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', 
        new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => objectMapping.Id,
            'SVMXA360__SourceFieldAPIName__c' => 'Description',
            'SVMXA360__TargetFieldAPIName__c' => 'SVMXA360__Description__c',
            'SVMXA360__Type__c' => 'Field'
        });

        return objectMapping.SVMXA360__DeveloperName__c;
    }

    public class PscMappingConfiguration{
        public String targetMappingKey;
        public String targetMappingId;
    }

    static Adm.Expression createExpression(String expressionName) {
        Adm.ExpressionDetail expDetail = new Adm.ExpressionDetail();
        expDetail.fieldAPIName = 'Status';
        expDetail.operator = 'eq';
        expDetail.operand = 'Installed';
        expDetail.sequence = 1;
        expDetail.operandType = 'Value';
        expDetail.fieldType = 'PICKLIST';

        Adm.Expression expression = new Adm.Expression();
        expression.name = expressionName;
        expression.objectAPIName = 'Asset';
        expression.developerName = expressionName;
        expression.advancedExpression = '1';
        expression.type = 'Standard Expression';
        expression.expressionType = 'PSC-SEARCH-EXPRESSION';
        expression.expressionDetailList = new List<Adm.ExpressionDetail>();
        expression.expressionDetailList.add(expDetail);
        
        return expression;
    }

    static ProductServiceCampaign createRecords() {
        Date todayDate = System.today();
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2)
        });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        ProductServiceCampaignItem psciRecord = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
        new Map<String,Object>{
            'ProductServiceCampaignId' => pscRecord.Id,
            'AssetId' => assetRecord.Id,
            'SVMXA360__DeliveryMethod__c' => 'Case',
            'Status' => 'OutputGenerated'
        });

        return pscRecord;
    }
}