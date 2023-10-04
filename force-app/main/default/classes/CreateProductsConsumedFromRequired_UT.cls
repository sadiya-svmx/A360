@isTest
public class CreateProductsConsumedFromRequired_UT {
    @TestSetup
    static void dataSetup(){
        Id standardPricebookId = Test.getStandardPricebookId();
    	Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');    
        PricebookEntry standardPricebookEntry = (PricebookEntry)SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String,Object>{
            'IsActive'=>true, 
            'Pricebook2Id'=>standardPricebookId, 
            'Product2Id'=>product.Id, 
            'UnitPrice'=>200, 
            'UseStandardPrice'=>false
        });
        WorkOrder workOrder = new WorkOrder(Priority = 'Medium', Pricebook2Id=standardPricebookId);
        insert workOrder;
        WorkOrder workOrderNoProductRequired = new WorkOrder(Priority = 'Low', Pricebook2Id=standardPricebookId);
        insert workOrderNoProductRequired;
        WorkOrder workOrderNoPricebook = new WorkOrder(Priority = 'Low');
        insert workOrderNoPricebook;
        ProductRequired productRequired = new ProductRequired(ParentRecordId=workOrder.Id, Product2Id=product.Id, QuantityRequired=1);
        insert productRequired;
    }

    public static testMethod void test_CreateProductsConsumedFromRequired_Valid(){
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE Pricebook2Id != null AND Priority = 'Medium' LIMIT 1];

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateProductsConsumedFromRequired';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = wo;
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = new List<sObject>();
        System.assertEquals(laborDetail.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(laborDetail);
        
        SvmxGlobal.SvmxPageDetail productConsumed = new SvmxGlobal.SvmxPageDetail();
        productConsumed.uniqueKey = 'Product Consumed';
        productConsumed.detailRecords = new List<sObject>();
		System.assertEquals(productConsumed.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(productConsumed);        

        SvmxGlobal.SvmxPageDetail expense = new SvmxGlobal.SvmxPageDetail();
        expense.uniqueKey = 'Expense';
        expense.detailRecords = new List<sObject>();
		System.assertEquals(expense.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(expense); 
        
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        SvmxGlobal.SvmxPageData responseData = (SvmxGlobal.SvmxPageData)JSON.deserialize(String.valueOf(response.data), SvmxGlobal.SvmxPageData.class);
        List<SvmxGlobal.SvmxPageDetail> responseDetails = responseData.pageDetails;
        System.assertEquals(responseDetails.isEmpty(), false);
        test.stopTest();
    }

    public static testMethod void test_CreateProductsConsumedFromRequired_NoPricebook(){
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE Pricebook2Id = null LIMIT 1];

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateProductsConsumedFromRequired';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = wo;
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = new List<sObject>();
        System.assertEquals(laborDetail.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(laborDetail);
        
        SvmxGlobal.SvmxPageDetail productConsumed = new SvmxGlobal.SvmxPageDetail();
        productConsumed.uniqueKey = 'Product Consumed';
        productConsumed.detailRecords = new List<sObject>();
		System.assertEquals(productConsumed.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(productConsumed);        

        SvmxGlobal.SvmxPageDetail expense = new SvmxGlobal.SvmxPageDetail();
        expense.uniqueKey = 'Expense';
        expense.detailRecords = new List<sObject>();
		System.assertEquals(expense.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(expense); 
        
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        System.assertEquals(response.success, false);
        test.stopTest();
    }

    public static testMethod void test_CreateProductsConsumedFromRequired_NoPricebookEntry(){
        WorkOrder wo = [SELECT Id, Pricebook2Id FROM WorkOrder WHERE Pricebook2Id != null AND Priority = 'Medium' LIMIT 1];
        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :wo.Pricebook2Id];
        delete pbeList;

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateProductsConsumedFromRequired';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = wo;
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = new List<sObject>();
        System.assertEquals(laborDetail.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(laborDetail);
        
        SvmxGlobal.SvmxPageDetail productConsumed = new SvmxGlobal.SvmxPageDetail();
        productConsumed.uniqueKey = 'Product Consumed';
        productConsumed.detailRecords = new List<sObject>();
		System.assertEquals(productConsumed.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(productConsumed);        

        SvmxGlobal.SvmxPageDetail expense = new SvmxGlobal.SvmxPageDetail();
        expense.uniqueKey = 'Expense';
        expense.detailRecords = new List<sObject>();
		System.assertEquals(expense.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(expense); 
        
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        System.assertEquals(response.success, false);
        test.stopTest();
    }

    public static testMethod void test_CreateProductsConsumedFromRequired_NoProductRequired(){
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE Pricebook2Id != null AND Priority = 'Low' LIMIT 1];

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateProductsConsumedFromRequired';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = wo;
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = new List<sObject>();
        System.assertEquals(laborDetail.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(laborDetail);
        
        SvmxGlobal.SvmxPageDetail productConsumed = new SvmxGlobal.SvmxPageDetail();
        productConsumed.uniqueKey = 'Product Consumed';
        productConsumed.detailRecords = new List<sObject>();
		System.assertEquals(productConsumed.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(productConsumed);        

        SvmxGlobal.SvmxPageDetail expense = new SvmxGlobal.SvmxPageDetail();
        expense.uniqueKey = 'Expense';
        expense.detailRecords = new List<sObject>();
		System.assertEquals(expense.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(expense); 
        
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        System.assertEquals(response.success, false);
        test.stopTest();
    }

    public static testMethod void test_CreateProductsConsumedFromRequired_Exception(){
        WorkOrder wo = new WorkOrder();

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateProductsConsumedFromRequired';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = wo;
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = new List<sObject>();
        System.assertEquals(laborDetail.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(laborDetail);
        
        SvmxGlobal.SvmxPageDetail productConsumed = new SvmxGlobal.SvmxPageDetail();
        productConsumed.uniqueKey = 'Product Consumed';
        productConsumed.detailRecords = new List<sObject>();
		System.assertEquals(productConsumed.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(productConsumed);        

        SvmxGlobal.SvmxPageDetail expense = new SvmxGlobal.SvmxPageDetail();
        expense.uniqueKey = 'Expense';
        expense.detailRecords = new List<sObject>();
		System.assertEquals(expense.detailRecords.isEmpty(), true);
        pageData.pageDetails.add(expense); 
        
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        System.assertEquals(response.success, false);
        test.stopTest();
    }
}