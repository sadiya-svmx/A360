@IsTest
public class PSC_SearchCriteria_LS_UT {

    @IsTest
    static void testGetSearchCriteriaStatusWithNull(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_SearchCriteria_LS.getSearchCriteriaStatus(null);
        System.assert(response.success == false);

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
        
        Common.ServiceResponse response = PSC_SearchCriteria_LS.getSearchCriteriaStatus(String.valueOf(pscRecord.Id));
        System.assert(response.success == true);

        Psc.SearchCriteria data = (Psc.SearchCriteria) response.data;
        System.assert(data.status == 'NO_CRITERIA');

        Test.stopTest();
    }

    @IsTest
    static void testSaveSearchCriteriaWithNull(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_SearchCriteria_LS.saveSearchCriteria(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testSaveSearchCriteriaWithInvalidJSON(){
        Test.startTest();
        
        String dummyJson = 'dummy';
        Common.ServiceResponse response = PSC_SearchCriteria_LS.saveSearchCriteria(dummyJson);
        System.assert(response.success == false);

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
        searchCriteria.expression = createExpression();

        Test.startTest();
        
        Common.ServiceResponse response = PSC_SearchCriteria_LS.saveSearchCriteria(JSON.serialize(searchCriteria));
        System.assert(response.success == true);

        Test.stopTest();
    }

    static Adm.Expression createExpression() {
        Adm.ExpressionDetail expDetail = new Adm.ExpressionDetail();
        expDetail.fieldAPIName = 'Status';
        expDetail.operator = 'eq';
        expDetail.operand = 'Installed';
        expDetail.sequence = 1;
        expDetail.operandType = 'Value';
        expDetail.fieldType = 'PICKLIST';

        Adm.Expression expression = new Adm.Expression();
        expression.name = 'TestExpression';
        expression.objectAPIName = 'Asset';
        expression.developerName = 'TestExpression';
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
        
        Common.ServiceResponse response = PSC_SearchCriteria_LS.getResultsPreview(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultsPreview(){

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
        searchCriteria.expression = createExpression();
        
        Test.startTest();

        Common.ServiceResponse response = PSC_SearchCriteria_LS.saveSearchCriteria(JSON.serialize(searchCriteria));
        System.assert(response.success == true);
        
        Common.ServiceResponse response2 = PSC_SearchCriteria_LS.getResultsPreview(pscRecord.Id);
        System.assert(response2.success == true);

        Psc.ResultsPreview data = (Psc.ResultsPreview) response2.data;
        System.assert(data.recordCount == 0);

        Test.stopTest();
    }

    @IsTest
    static void testInitiateSearchResultBatchWithNull(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_SearchCriteria_LS.initiateSearchResultBatch(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testInitiateSearchResultBatch(){
        Test.startTest();
        
        ProductServiceCampaign pscRecord = createDataForBatchClass();
        Common.ServiceResponse response = PSC_SearchCriteria_LS.initiateSearchResultBatch(pscRecord.Id);
        System.assert(response.success == true);

        Test.stopTest();
    }

    static ProductServiceCampaign createDataForBatchClass() {
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
        searchCriteria.expression = createExpression();

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

        return pscRecord;
    }
}