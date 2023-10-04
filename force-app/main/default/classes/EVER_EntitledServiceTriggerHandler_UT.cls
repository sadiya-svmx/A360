@isTest
public with sharing class EVER_EntitledServiceTriggerHandler_UT {
    
    @testSetup public static void setup() {
        final Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');
        final Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2');

        final PricebookEntry pricebookEntryRecord = new PricebookEntry( Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productRecord.Id, UnitPrice = 10000, IsActive = true);
        final ServiceContract serviceContractRecord = (ServiceContract) SvmxTestDataFactory.createSObject('ServiceContract');

        serviceContractRecord.Pricebook2Id = Test.getStandardPricebookId();
        serviceContractRecord.AccountId = accountRecord.Id;

        insert pricebookEntryRecord;
        insert serviceContractRecord;

        final ContractLineItem contractLineItemRecord = (ContractLineItem) SvmxTestDataFactory.createSObject('ContractLineItem');
 
        contractLineItemRecord.ServiceContractId = serviceContractRecord.Id;
        contractLineItemRecord.PricebookEntryId = pricebookEntryRecord.Id;
        contractLineItemRecord.EndDate = System.today();
        contractLineItemRecord.EndDate = System.today();
        contractLineItemRecord.Discount = 10;
        contractLineItemRecord.Quantity = 10;

        insert contractLineItemRecord;
    }

    @isTest
    static void testValidateStartAndEndDate_Positive(){
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract LIMIT 1];
        
        Test.startTest();

        Date startDate = System.today().addDays(-2);
        Date endDate = System.today().addDays(4);

        serviceContractRecordList.get(0).Startdate = startDate;
        serviceContractRecordList.get(0).Enddate = endDate;

        update serviceContractRecordList;

        serviceContractRecordList = [SELECT Startdate, Enddate FROM ServiceContract LIMIT 1];

        System.assert(serviceContractRecordList.get(0).StartDate == startDate);
        System.assert(serviceContractRecordList.get(0).EndDate == endDate);

        Test.stopTest();
    }

    @isTest
    static void testValidateStartAndEndDate_negative1(){
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract LIMIT 1];
        
        Test.startTest();

        Date startDate = System.today().addDays(2);
        Date endDate = System.today().addDays(-4);

        serviceContractRecordList.get(0).Startdate = startDate;
        serviceContractRecordList.get(0).Enddate = endDate;

        Boolean isExceptionThrown = false;

        try{
            update serviceContractRecordList;
        }catch(Exception e){
            isExceptionThrown = true;
        }

        System.assert(isExceptionThrown);

        Test.stopTest();
    }

    @isTest
    static void testValidateStartAndEndDate_negative2(){
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract LIMIT 1];
        
        Test.startTest();

        Date startDate = System.today().addDays(-2);
        Date endDate = System.today().addDays(-2);

        serviceContractRecordList.get(0).Startdate = startDate;
        serviceContractRecordList.get(0).Enddate = endDate;

        Boolean isExceptionThrown = false;

        try{
            update serviceContractRecordList;
        }catch(Exception e){
            isExceptionThrown = true;
        }

        System.assert(isExceptionThrown);

        Test.stopTest();
    }
}