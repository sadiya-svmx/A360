@isTest
public class CONF_CustomAction_UT {
    @TestSetup
    static void pricingSetup(){
    	CalculatePriceApexAction_UT.createData();
    }
    
    public static testMethod void test_InvalidCustomAction(){
    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'InvalidAction';
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        System.assertEquals(response.success, false);
        test.stopTest();
    }
    
    public static testMethod void test_WorkOrderPricingService_InvalidWorkOrderId(){
    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'WorkOrderPricingService';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = new WorkOrder();
        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = [SELECT Id, TransactionDate, Amount, WorkOrderId, SVMXA360__ExpenseItem__c FROM Expense];
        System.assertEquals(laborDetail.detailRecords.size() > 0, true);
        for(sObject expRec : laborDetail.detailRecords){
            expRec.put('WorkOrderId', null);
        }
        pageData.pageDetails =  new List<SvmxGlobal.SvmxPageDetail>{laborDetail};
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        System.assertEquals(response.success, false);
        test.stopTest();
    }

    public static testMethod void test_WorkOrderPricingService_Valid(){
    	test.startTest();
        SvmxGlobal.ActionRequest actionReq = new SvmxGlobal.ActionRequest();
        actionReq.actionName = 'WorkOrderPricingService';
        SvmxGlobal.SvmxPageData pageData = new SvmxGlobal.SvmxPageData();
        pageData.headerRecord = new WorkOrder();
        pageData.pageDetails = new List<SvmxGlobal.SvmxPageDetail>();

        SvmxGlobal.SvmxPageDetail laborDetail = new SvmxGlobal.SvmxPageDetail();
        laborDetail.uniqueKey = 'Labor/Travel';
        laborDetail.detailRecords = [Select Id, SVMXA360__LineType__c, PricebookEntryId, WorkOrderId from WorkOrderLineItem];
        System.assertEquals(laborDetail.detailRecords.size() > 0, true);
        pageData.pageDetails.add(laborDetail);
        
        SvmxGlobal.SvmxPageDetail productConsumed = new SvmxGlobal.SvmxPageDetail();
        productConsumed.uniqueKey = 'Product Consumed';
        productConsumed.detailRecords = [Select Id, PricebookEntryId, QuantityConsumed, WorkOrderId from ProductConsumed];
		System.assertEquals(productConsumed.detailRecords.size() > 0, true);
        pageData.pageDetails.add(productConsumed);        

        SvmxGlobal.SvmxPageDetail expense = new SvmxGlobal.SvmxPageDetail();
        expense.uniqueKey = 'Expense';
        expense.detailRecords = [SELECT Id, TransactionDate, Amount, WorkOrderId, SVMXA360__ExpenseItem__c FROM Expense];
		System.assertEquals(expense.detailRecords.size() > 0, true);
        pageData.pageDetails.add(expense); 
        
        actionReq.pageData = pageData;
        String requestJson = JSON.serialize(actionReq);
        SvmxGlobal.SvmxResponse response = CONF_CustomAction.executeAction(requestJson);
        test.stopTest();
    }
}