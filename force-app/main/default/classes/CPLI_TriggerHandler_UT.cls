@IsTest
public class CPLI_TriggerHandler_UT{
    
    @testSetup public static void setup() {
        
        final List<Account> accountRecordList = (List<Account>) SvmxTestDataFactory.insertSObjectList('Account', 5);
        final List<Product2> productRecordList = (List<Product2>) SvmxTestDataFactory.insertSObjectList('Product2', 5);
        
        
        final List<PricebookEntry> pricebookEntryRecordList = new List<PricebookEntry>();
        final List<ServiceContract> serviceContractRecordList = (List<ServiceContract>) SvmxTestDataFactory.createSObjectList('ServiceContract', 2);
        
        for( ServiceContract serviceContractRecord : serviceContractRecordList ) {
            serviceContractRecord.EndDate = Date.Today().addDays(250);
            serviceContractRecord.StartDate = Date.Today();
        }

        for( Integer index = 0; index < 2; index++ ) {
            
            pricebookEntryRecordList.add(new PricebookEntry( Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productRecordList.get(index).Id, UnitPrice = 10000, IsActive = true));
            
            serviceContractRecordList.get(index).Pricebook2Id = Test.getStandardPricebookId();
            serviceContractRecordList.get(index).AccountId = accountRecordList.get(index).Id;
        }
        
        insert pricebookEntryRecordList;
        insert serviceContractRecordList;
        
        
        final List<ContractLineItem> contractLineItemList = (List<ContractLineItem>) SvmxTestDataFactory.createSObjectList('ContractLineItem', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
            
            contractLineItemList.get(index).ServiceContractId = serviceContractRecordList.get(Math.mod(index, 2)).Id;
            contractLineItemList.get(index).PricebookEntryId = pricebookEntryRecordList.get(Math.mod(index, 2)).Id;
           
            contractLineItemList.get(index).Discount = 10;
            contractLineItemList.get(index).Quantity = 10;
            contractLineItemList.get(index).StartDate = Date.today();
            contractLineItemList.get(index).EndDate = Date.today().addDays(250);
        }
        insert contractLineItemList;
        
        //Insert entitledServices
        final List<Entitlement> entitledServiceList = (List<Entitlement>) SvmxTestDataFactory.createSObjectList('Entitlement', 5);        
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();

        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];

        for( Integer index = 0; index < 5; index++ ) {
            entitledServiceList.get(index).RecordTypeId = recordTypeId;
            entitledServiceList.get(index).Name = 'Test Entitled Service-'+index;
            entitledServiceList.get(index).AccountId = accountRecordList.get(Math.mod(index, 5)).Id;
            entitledServiceList.get(index).ServiceContractId = serviceContractRecordList.get(Math.mod(index, 2)).Id;            
            entitledServiceList.get(index).ContractLineItemId = contractLineItemList.get(Math.mod(index, 5)).Id;
            entitledServiceList.get(index).StartDate = Date.Today();
            entitledServiceList.get(index).EndDate = Date.Today().addDays(index+1);
            entitledServiceList.get(index).SVMXA360__ServiceCountType__c= 'Hours';
            entitledServiceList.get(index).SVMXA360__TotalServiceCount__c = index+5;
            entitledServiceList.get(index).SVMXA360__ServiceCountAlertThreshold__c =index+1;
            if(index <100){
                entitledServiceList.get(index).SVMXA360__ServiceCountType__c= 'Amount';
                entitledServiceList.get(index).SVMXA360__TotalServiceAmount__c = index+5;
                entitledServiceList.get(index).SVMXA360__ServiceAmountAlertThreshold__c =index+1;
            } else { 
                entitledServiceList.get(index).SVMXA360__ServiceCountType__c= 'Hours';
                entitledServiceList.get(index).SVMXA360__TotalServiceCount__c = index+5;
                entitledServiceList.get(index).SVMXA360__ServiceCountAlertThreshold__c =index+1;
            }
            entitledServiceList.get(index).SVMXA360__CaseEntitlementProcessId__c = (slaProcessList!=null) ? slaProcessList[0].Id : null;
            entitledServiceList.get(index).SVMXA360__WorkOrderEntitlementProcessId__c =(slaProcessList!=null) ? slaProcessList[0].Id : null;

        }
        insert entitledServiceList;
        
        SVMXA360__ContractPriceLineItem__c cpliExpense = 
        (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__Surcharge__c'=>5,
                                                                                                                    'SVMXA360__EntitledPrice__c'=>null,
                                                                                                                    'SVMXA360__EntitledDiscount__c'=>null,
                                                                                                                    'SVMXA360__ServiceContractId__c'=>serviceContractRecordList[0].id,
                                                                                                                    'SVMXA360__LineType__c'=>'Expense',
                                                                                                                    'SVMXA360__ExpenseItem__c'=>'Lodging'});
    }
    
    static testmethod void testPreventDuplicateCPLI() {
        
        Test.startTest();
        
         //get ServiceContract
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);
        
        List<ContractLineItem> contractLineItemList = [SELECT Id FROM ContractLineItem];
        System.debug('----contractLineItemList::'+contractLineItemList);
        
        List<Entitlement> entitlementList= [SELECT Id FROM Entitlement];
        System.debug('----entitlementList::'+entitlementList);
        
        List<Product2> productRecordList= [SELECT Id FROM Product2];
        System.debug('----productRecordList::'+productRecordList);
        
        //CPLI - Contract Price Line Item
        SVMXA360__ContractPriceLineItem__c contractPriceRecord = 
        (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__ServiceContractId__c' => serviceContractRecordList[0].Id,
                                                                                                                      'SVMXA360__ContractLineId__c' => contractLineItemList[0].Id,
                                                                                                                      'SVMXA360__EntitledServiceId__c' => entitlementList[0].Id,
                                                                                                                      'SVMXA360__ProductId__c' => productRecordList[0].Id,
                                                                                                                      'SVMXA360__LineType__c' => 'Labor',
                                                                                                                      'SVMXA360__Surcharge__c' => 35,                                                                                                                      
                                                                                                                      'SVMXA360__EntitledPrice__c'=>null,
                                                                                                                      'SVMXA360__EntitledDiscount__c'=>null});
        System.debug('----contractPriceRecord ::'+contractPriceRecord );
        System.assert( serviceContractRecordList[0].Id == contractPriceRecord.SVMXA360__ServiceContractId__c );
        
        Test.stopTest();
    }
    
    static testmethod void testDuplicateCPLI_Insert() {
        
        Test.startTest();
        
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);
        
        //CPLI - Contract Price Line Item
        SVMXA360__ContractPriceLineItem__c contractPriceRecord = 
        (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__ServiceContractId__c' => serviceContractRecordList[0].Id,
                                                                                                                      'SVMXA360__LineType__c' => 'Parts',
                                                                                                                      'SVMXA360__EntitledPrice__c' => 65,                                                                                                                      
                                                                                                                      'SVMXA360__Surcharge__c'=>null,
                                                                                                                      'SVMXA360__EntitledDiscount__c'=>null});
        
        
        try{
            //Create duplicate record 
            SVMXA360__ContractPriceLineItem__c duplicateCPLIRecord = 
            (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__ServiceContractId__c' => serviceContractRecordList[0].Id,
                                                                                                                          'SVMXA360__LineType__c' => 'Parts',
                                                                                                                          'SVMXA360__EntitledPrice__c' => 85,                                                                                                                          
                                                                                                                          'SVMXA360__Surcharge__c'=>null,
                                                                                                                          'SVMXA360__EntitledDiscount__c'=>null});
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }
    
    static testmethod void testDuplicateCPLI_Update() {
        
        Test.startTest();
        
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);
        
        SVMXA360__ContractPriceLineItem__c cpliExpense = 
        (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__Surcharge__c'=>35,
                                                                                                                    'SVMXA360__EntitledPrice__c'=>null,
                                                                                                                    'SVMXA360__EntitledDiscount__c'=>null,
                                                                                                                    'SVMXA360__ServiceContractId__c'=>serviceContractRecordList[0].id,
                                                                                                                    'SVMXA360__LineType__c'=>'Expense',
                                                                                                                    'SVMXA360__ExpenseItem__c'=>'Gas'});
                                                                                                                    
        
        try{
            SVMXA360__ContractPriceLineItem__c contractPriceRecord = [SELECT Id,SVMXA360__ExpenseItem__c FROM SVMXA360__ContractPriceLineItem__c Where Id =:cpliExpense.Id];
            
            contractPriceRecord.SVMXA360__ExpenseItem__c='Lodging';
            update contractPriceRecord;
            System.assert(false);
        }
        catch(Exception e){            
            System.assert(true);
        }
        Test.stopTest();
    }
    
    static testmethod void testDuplicateCPLI_Update_MulitCurrency() {
        
        Test.startTest();
        
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);
        
        SVMXA360__ContractPriceLineItem__c cpliExpense;
        SVMXA360__ContractPriceLineItem__c cpliExpenseToll;
        SVMXA360__ContractPriceLineItem__c cpliExpensePhone;
        
        cpliExpense = 
            (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__Surcharge__c'=>null,
                                                                                                                        'SVMXA360__EntitledPrice__c'=>70,
                                                                                                                        'SVMXA360__EntitledDiscount__c'=>null,
                                                                                                                        'SVMXA360__ServiceContractId__c'=>serviceContractRecordList[0].id,
                                                                                                                        'SVMXA360__LineType__c'=>'Expense',
                                                                                                                        'SVMXA360__ExpenseItem__c'=>'Gas'});
        
        
        if (UserInfo.isMultiCurrencyOrganization()) { 
            cpliExpenseToll = 
            (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__Surcharge__c'=>null,
                                                                                                                        'SVMXA360__EntitledPrice__c'=>86,
                                                                                                                        'SVMXA360__EntitledDiscount__c'=>null,
                                                                                                                        'SVMXA360__ServiceContractId__c'=>serviceContractRecordList[0].id,
                                                                                                                        'SVMXA360__LineType__c'=>'Expense',
                                                                                                                        'CurrencyIsoCode'=>'USD',
                                                                                                                        'SVMXA360__ExpenseItem__c'=>'Toll'});
        
            cpliExpensePhone = 
            (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__Surcharge__c'=>null,
                                                                                                                        'SVMXA360__EntitledPrice__c'=>96,
                                                                                                                        'SVMXA360__EntitledDiscount__c'=>null,
                                                                                                                        'SVMXA360__ServiceContractId__c'=>serviceContractRecordList[0].id,
                                                                                                                        'SVMXA360__LineType__c'=>'Expense',
                                                                                                                        'CurrencyIsoCode'=>'USD',
                                                                                                                        'SVMXA360__ExpenseItem__c'=>'Phone'});
        }             
        
        try{
            
            if (UserInfo.isMultiCurrencyOrganization() && cpliExpenseToll!=null) {
                SVMXA360__ContractPriceLineItem__c contractPriceRecord = [SELECT Id,SVMXA360__EntitledDiscount__c,SVMXA360__EntitledPrice__c FROM SVMXA360__ContractPriceLineItem__c Where Id =:cpliExpenseToll.Id];
            
                contractPriceRecord.SVMXA360__EntitledDiscount__c=null;
                contractPriceRecord.SVMXA360__EntitledPrice__c=null;
                update contractPriceRecord;
            } else {
                SVMXA360__ContractPriceLineItem__c contractPriceRecord = [SELECT Id,SVMXA360__EntitledDiscount__c,SVMXA360__EntitledPrice__c FROM SVMXA360__ContractPriceLineItem__c Where Id =:cpliExpense.Id];
            
                contractPriceRecord.SVMXA360__EntitledDiscount__c=75;
                contractPriceRecord.SVMXA360__EntitledPrice__c=120;
                update contractPriceRecord;
            }
            
            System.assert(false);
        }
        catch(Exception e){            
            System.assert(true);
        }
        Test.stopTest();
    }

    static testmethod void testValidateDiscountField() {
        
        Test.startTest();
        
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);
        
        try{

            //CPLI - Contract Price Line Item
            SVMXA360__ContractPriceLineItem__c contractPriceRecord = 
            (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__ServiceContractId__c' => serviceContractRecordList[0].Id,
                                                                                                                        'SVMXA360__LineType__c' => 'Parts',
                                                                                                                        'SVMXA360__EntitledPrice__c' => null,                                                                                                                      
                                                                                                                        'SVMXA360__Surcharge__c'=>null,
                                                                                                                        'SVMXA360__EntitledDiscount__c'=>125});
            
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }

    static testmethod void testValidateSurchargeField() {
        
        Test.startTest();
        
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);
        
        try{

            //CPLI - Contract Price Line Item
            SVMXA360__ContractPriceLineItem__c contractPriceRecord = 
            (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__ServiceContractId__c' => serviceContractRecordList[0].Id,
                                                                                                                        'SVMXA360__LineType__c' => 'Parts',
                                                                                                                        'SVMXA360__EntitledPrice__c' => null,                                                                                                                      
                                                                                                                        'SVMXA360__Surcharge__c'=>-20.00,
                                                                                                                        'SVMXA360__EntitledDiscount__c'=>null});
            
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }

    static testmethod void testPreventDuplicateCPLIList() {
        
        Test.startTest();
        
        //Insert contract price line items
        final List<SVMXA360__ContractPriceLineItem__c> contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__ContractPriceLineItem__c', 5);
        
        List<ServiceContract> serviceContractRecordList = [SELECT Id FROM ServiceContract];
        System.debug('----serviceContractRecordList::'+serviceContractRecordList);

        for( Integer index = 0; index < 5; index++ ) {
            
            contractPriceLineItemList.get(index).SVMXA360__ServiceContractId__c = serviceContractRecordList[0].Id;
            
            if(index <2){
                contractPriceLineItemList.get(index).SVMXA360__LineType__c = 'Expense';
                contractPriceLineItemList.get(index).SVMXA360__ProductFamily__c = 'Mobile'+index;
            }
            else{               
                contractPriceLineItemList.get(index).SVMXA360__LineType__c = 'Labor';
                contractPriceLineItemList.get(index).SVMXA360__ProductFamily__c = 'Laptops';
            }
            contractPriceLineItemList.get(index).SVMXA360__EntitledPrice__c = index+10;
            contractPriceLineItemList.get(index).SVMXA360__Surcharge__c = null;
            contractPriceLineItemList.get(index).SVMXA360__EntitledDiscount__c = null;
        }
        
        try{

            insert contractPriceLineItemList;            
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }
}