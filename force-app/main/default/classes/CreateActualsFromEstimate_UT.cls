@isTest
public class CreateActualsFromEstimate_UT {
    @TestSetup
    static void dataSetup(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id estimateRecTypeId = SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Estimate').getRecordTypeId();
        Id depotRecTypeId = SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Depot').getRecordTypeId();
    	Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');    
        PricebookEntry standardPricebookEntry = (PricebookEntry)SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String,Object>{
            'IsActive'=>true, 
            'Pricebook2Id'=>standardPricebookId, 
            'Product2Id'=>product.Id, 
            'UnitPrice'=>200, 
            'UseStandardPrice'=>false
        });
        WorkOrder workOrderDepot = new WorkOrder(
            Priority = 'Medium', 
            Pricebook2Id=standardPricebookId, 
            RecordTypeId=depotRecTypeId    
        );
        insert workOrderDepot;
        WorkOrder workOrderDepot2 = new WorkOrder(
            Priority = 'Low', 
            Pricebook2Id=standardPricebookId, 
            RecordTypeId=depotRecTypeId    
        );
        insert workOrderDepot2;
        WorkOrder workOrderDepot3 = new WorkOrder(
            Priority = 'High', 
            Pricebook2Id=standardPricebookId, 
            RecordTypeId=depotRecTypeId    
        );
        insert workOrderDepot3;
        WorkOrderLineItem laborLineItem = new WorkOrderLineItem(
            PricebookEntryId=standardPricebookEntry.Id, 
            WorkOrderId=workOrderDepot3.Id, 
            SVMXA360__LineType__c='Labor');
        insert laborLineItem;
        WorkOrder workOrderEstimate = new WorkOrder(
            Priority = 'Medium', 
            Pricebook2Id=standardPricebookId, 
            RecordTypeId=estimateRecTypeId,
            ParentWorkOrderId=workOrderDepot.Id,
            Status='Approved'
        );
        insert workOrderEstimate;
        
        ProductConsumed productConsumed = new ProductConsumed();
        productConsumed.PricebookEntryId = standardPricebookEntry.Id;
        productConsumed.QuantityConsumed = 0;
        productConsumed.WorkOrderId = workOrderEstimate.Id;
        insert productConsumed;
        
        Expense expenseAirfare = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{
            'TransactionDate'=> Date.today(), 
            'Amount'=> 50, 
            'WorkOrderId' => workOrderEstimate.Id, 
            'SVMXA360__ExpenseItem__c'=>'Airfare'
        });
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(PricebookEntryId=standardPricebookEntry.Id, WorkOrderId=workOrderEstimate.Id, SVMXA360__LineType__c='Labor');
        insert workOrderLineItem;
        WorkOrder workOrderEstimate2 = new WorkOrder(
            Priority = 'Medium', 
            Pricebook2Id=standardPricebookId, 
            RecordTypeId=estimateRecTypeId,
            ParentWorkOrderId=workOrderDepot3.Id,
            Status='Approved'
        );
        insert workOrderEstimate2;
        
        ProductConsumed productConsumed2 = new ProductConsumed();
        productConsumed2.PricebookEntryId = standardPricebookEntry.Id;
        productConsumed2.QuantityConsumed = 0;
        productConsumed2.WorkOrderId = workOrderEstimate2.Id;
        insert productConsumed2;
        
        Expense expenseAirfare2 = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{
            'TransactionDate'=> Date.today(), 
            'Amount'=> 50, 
            'WorkOrderId' => workOrderEstimate2.Id, 
            'SVMXA360__ExpenseItem__c'=>'Airfare'
        });
        WorkOrderLineItem workOrderLineItem2 = new WorkOrderLineItem(PricebookEntryId=standardPricebookEntry.Id, WorkOrderId=workOrderEstimate2.Id, SVMXA360__LineType__c='Labor');
        insert workOrderLineItem2;
    }

    public static testMethod void test_CreateActualsFromEstimate_Valid(){
        Id depotRecTypeId = SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Depot').getRecordTypeId();
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE RecordTypeId = :depotRecTypeId AND Priority = 'Medium' LIMIT 1];

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateActualsFromEstimate';
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

    public static testMethod void test_CreateActualsFromEstimate_CancelExistingLabor(){
        Integer canceledWoliCount = 0;
        Id depotRecTypeId = SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Depot').getRecordTypeId();
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE RecordTypeId = :depotRecTypeId AND Priority = 'High' LIMIT 1];
        
    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateActualsFromEstimate';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = wo;
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = [SELECT Id, CreatedDate, SVMXA360__LineType__c, PricebookEntryId, WorkOrderId, Status FROM WorkOrderLineItem WHERE WorkOrderId = :wo.Id];
        System.assertEquals(laborDetail.detailRecords.isEmpty(), false);
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
        for(SvmxGlobal.SvmxPageDetail pgDetail : responseDetails){
            String uniqueKey = pgDetail.uniqueKey;
            switch on uniqueKey {
                when 'Labor/Travel' {
                    for(SObject sobj : pgDetail.detailRecords){
                        WorkOrderLineItem laborWoli = (WorkOrderLineItem)sobj;
                        if(laborWoli.Status == 'Canceled'){
                            canceledWoliCount++;
                        }
                    }
                }
                when else{}
            }
        }
        System.assertEquals(responseDetails.isEmpty(), false);
        System.assertEquals(1, canceledWoliCount);
        test.stopTest();
    }

    public static testMethod void test_CreateActualsFromEstimate_NoEstimate(){
        Id depotRecTypeId = SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Depot').getRecordTypeId();
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE RecordTypeId = :depotRecTypeId AND Priority = 'Low' LIMIT 1];

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateActualsFromEstimate';
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

    public static testMethod void test_CreateActualsFromEstimate_Exception(){
        Account acc = new Account();

    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'CreateActualsFromEstimate';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = acc;
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