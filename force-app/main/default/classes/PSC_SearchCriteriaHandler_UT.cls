@IsTest
public class PSC_SearchCriteriaHandler_UT {
    @IsTest
    static void testGetSearchCriteriaStatusWithNull(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = new Psc.SearchCriteria();
        try {
            response = searchCriteriaHandler.getSearchCriteriaStatus(null);
        }
        catch(Exception e){
            System.assert(response.status == null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetSearchCriteriaStatus(){
        
        Date todayDate = System.today();
        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
                                            new Map<String,Object>{
                                                'ProductServiceCampaignName' => 'TestPSC',
                                                'Type' => 'Recall',
                                                'Status' => 'New',
                                                'StartDate' => todayDate,
                                                'EndDate' => todayDate.addMonths(2)
                                            });

        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.getSearchCriteriaStatus(String.valueOf(pscRecord.Id));
        System.assert(response.status == 'NO_CRITERIA');

        Test.stopTest();
    }

    @IsTest
    static void testGetSearchCriteriaStatusWithNoPSC(){
        
        Date todayDate = System.today();
        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
                                            new Map<String,Object>{
                                                'ProductServiceCampaignName' => 'TestPSC',
                                                'Type' => 'Recall',
                                                'Status' => 'New',
                                                'StartDate' => todayDate,
                                                'EndDate' => todayDate.addMonths(2)
                                            });

        Test.startTest();
        delete pscRecord;
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = new Psc.SearchCriteria();
        try{
            response = searchCriteriaHandler.getSearchCriteriaStatus(String.valueOf(pscRecord.Id));
        }
        catch(Exception e){
            System.assert(response.status == null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetSearchCriteriaStatusPscWithExpression(){
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        Date todayDate = System.today();
        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
                                            new Map<String,Object>{
                                                'ProductServiceCampaignName' => 'TestPSC',
                                                'Type' => 'Recall',
                                                'Status' => 'New',
                                                'StartDate' => todayDate,
                                                'EndDate' => todayDate.addMonths(2)
                                            });

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');

        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response.expression.id != null);

        Psc.SearchCriteria response2 = searchCriteriaHandler.getSearchCriteriaStatus(String.valueOf(pscRecord.Id));
        System.assert(response2.status == 'CRITERIA_DEFINED');

        Test.stopTest();
    }

    @IsTest
    static void testSaveSearchCriteriaWithNull(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = new Psc.SearchCriteria();
        
        try {
            response = searchCriteriaHandler.saveSearchCriteria(null);
        }
        catch(Exception e){
            System.assert(response.expression == null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testSaveSearchCriteria(){
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        Date todayDate = System.today();
        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
                                            new Map<String,Object>{
                                                'ProductServiceCampaignName' => 'TestPSC',
                                                'Type' => 'Recall',
                                                'Status' => 'New',
                                                'StartDate' => todayDate,
                                                'EndDate' => todayDate.addMonths(2)
                                            });

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');

        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response.expression.id != null);

        Test.stopTest();
    }

    @IsTest
    static void testSaveSearchCriteriaWithInvalidProductId(){
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });
        delete product;

        Date todayDate = System.today();
        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
                                            new Map<String,Object>{
                                                'ProductServiceCampaignName' => 'TestPSC',
                                                'Type' => 'Recall',
                                                'Status' => 'New',
                                                'StartDate' => todayDate,
                                                'EndDate' => todayDate.addMonths(2)
                                            });

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');

        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = new Psc.SearchCriteria();
        try {
            response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        } catch (Exception e) {
            System.assert(response.expression == null);
        }

        Test.stopTest();
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

    @IsTest
    static void testGetResultsPreviewWithNull(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.ResultsPreview response = new Psc.ResultsPreview();
        
        try {
            response = searchCriteriaHandler.getResultsPreview(null);
        }
        catch(Exception e){
            System.assert(response.recordCount == null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetResultsPreviewWithoutAssetRecords(){

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

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');
        
        Test.startTest();

        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response.expression.id != null);
        
        Psc.ResultsPreview response2 = searchCriteriaHandler.getResultsPreview(pscRecord.Id);
        System.assert(response2.recordCount == 0);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultsPreviewWithAssetRecords(){

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

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');
        
        Test.startTest();

        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response.expression.id != null);
        
        Psc.ResultsPreview response2 = searchCriteriaHandler.getResultsPreview(pscRecord.Id);
        System.assert(response2.recordCount == 1);

        Test.stopTest();
    }
    
    @IsTest
    static void testGetExpectedRecordCount(){

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

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');
        
        Test.startTest();

        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response.expression.id != null);
        
        Integer recordCount = searchCriteriaHandler.getExpectedRecordCount(pscRecord.Id);
        System.assert(recordCount == 1);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultsPreviewWithInvalidPsc(){

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

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');
        
        Test.startTest();

        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Psc.SearchCriteria response = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response.expression.id != null);
        
        Psc.ResultsPreview response2 = new Psc.ResultsPreview();
        try {
            delete pscRecord;
            response2 = searchCriteriaHandler.getResultsPreview(pscRecord.Id);
        } catch (Exception e) {
            System.assert(response2.recordCount == null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testInitiateSearchResultBatchWithNull(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Boolean response;
        
        try {
            response = searchCriteriaHandler.initiateSearchResultBatch(null);
        }
        catch(Exception e){
            System.assert(e.getMessage() == ErrorMessage.INVALID_ARGUMENT);
        }

        Test.stopTest();
    }

    @IsTest
    static void testInitiateSearchResultBatchWithInvalidPsc(){
        Test.startTest();

        Date todayDate = System.today();
        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2)
        });
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        Boolean response;
        
        try {
            delete pscRecord;
            response = searchCriteriaHandler.initiateSearchResultBatch(pscRecord.Id);
        }
        catch(Exception e){
            System.assert(e.getMessage() == ErrorMessage.RECORD_NOT_EXISTS);
        }

        Test.stopTest();
    }

    @IsTest
    static void testInitiateSearchResultBatch(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        ProductServiceCampaign pscRecord = createDataForBatchClass();
        
        Boolean response = searchCriteriaHandler.initiateSearchResultBatch(pscRecord.Id);
        System.assert(response == true);
        
        Test.stopTest();

        List<ProductServiceCampaignItem> psciRecordList = [SELECT Id FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecord.Id];
        System.assert(psciRecordList.size() == 1);

        Psc.SearchCriteria response2 = searchCriteriaHandler.getSearchCriteriaStatus(String.valueOf(pscRecord.Id));
        System.assert(response2.status == 'RESULT_LINES_GENERATED');
    }

    @IsTest
    static void testInitiateSearchResultBatchWithAlreadyCreatedItems(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        ProductServiceCampaign pscRecord = createDataForBatchClass();
        
        Boolean response = searchCriteriaHandler.initiateSearchResultBatch(pscRecord.Id);
        System.assert(response == true);
        
        Test.stopTest();

        List<ProductServiceCampaignItem> psciRecordList = [SELECT Id FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecord.Id];
        System.assert(psciRecordList.size() == 1);

        try {
            response = searchCriteriaHandler.initiateSearchResultBatch(pscRecord.Id);
        }
        catch(Exception e){
            System.assert(e.getMessage() == ErrorMessage.RESULTS_ALREADY_GENERATED+pscRecord.Id);
        }
    }

    @IsTest
    static void testSaveSearchCriteriaWithPsciRecordsPresent(){
        Test.startTest();
        
        PSC_SearchCriteriaHandler searchCriteriaHandler = new PSC_SearchCriteriaHandler();
        ProductServiceCampaign pscRecord = createDataForBatchClass();
        
        Boolean response = searchCriteriaHandler.initiateSearchResultBatch(pscRecord.Id);
        System.assert(response == true);
        
        Test.stopTest();

        List<ProductServiceCampaignItem> psciRecordList = [SELECT Id FROM ProductServiceCampaignItem WHERE ProductServiceCampaignId =: pscRecord.Id];
        System.assert(psciRecordList.size() == 1);
        
        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.expression = createExpression('TestExpression1');

        Psc.SearchCriteria response1 = searchCriteriaHandler.saveSearchCriteria(searchCriteria);
        System.assert(response1.expression.id != null);
    }

    static ProductServiceCampaign createDataForBatchClass() {
        Date todayDate = System.today();
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        RecordType pscConfRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PSC_Configuration' AND SobjectType = 'SVMXA360__CONF_PSCConfiguration__c'];
        SVMXA360__CONF_PSCConfiguration__c pscConfiguration = new SVMXA360__CONF_PSCConfiguration__c();
        pscConfiguration.RecordTypeId = pscConfRecordType.Id;
        pscConfiguration.SVMXA360__Active__c = true;
        pscConfiguration.Name = 'PscTestConfiguration';
        pscConfiguration.SVMXA360__DeveloperName__c = 'PscTestConfiguration';
        pscConfiguration.SVMXA360__PSCMappingJSON__c = '{[]}';
        pscConfiguration.SVMXA360__Email__c = 'testemail@test.com';
        insert pscConfiguration;

        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2),
            'SVMXA360__PSCConfigurationId__c' => pscConfiguration.Id
        });

        Psc.SearchCriteria searchCriteria = new Psc.SearchCriteria();
        searchCriteria.id = pscRecord.Id;
        searchCriteria.productIdForPsc = product.Id;
        searchCriteria.expression = createExpression('TestExpression');

        Common.ServiceResponse response = PSC_SearchCriteria_LS.saveSearchCriteria(JSON.serialize(searchCriteria));

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

        RecordType rtSetting = [SELECT Id FROM RecordType WHERE DeveloperName = 'PSC_Settings' AND SobjectType = 'SVMXA360__CONF_PSCConfiguration__c'];
        SVMXA360__CONF_PSCConfiguration__c pscSetting = new SVMXA360__CONF_PSCConfiguration__c();
        pscSetting.RecordTypeId = rtSetting.Id;
        pscSetting.SVMXA360__Active__c = true;
        pscSetting.Name = 'Default PSC Settings';
        pscSetting.SVMXA360__DeveloperName__c = 'Default_PSC_Settings';
        pscSetting.SVMXA360__SearchBatchSize__c = 250.0;
        pscSetting.SVMXA360__DeliveryBatchSize__c = 50.0;
        pscSetting.SVMXA360__SearchResultsPerPSC__c = 500.0;
        pscSetting.SVMXA360__Scope__c = 'Global';
        insert pscSetting;

        return pscRecord;
    }
}