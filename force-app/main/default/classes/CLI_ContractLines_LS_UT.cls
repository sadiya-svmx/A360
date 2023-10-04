@isTest
public class CLI_ContractLines_LS_UT {
    @testSetup public static void setup() {
        
        final List<Account> accountRecordList = (List<Account>) SvmxTestDataFactory.insertSObjectList('Account', 5);
        final List<Product2> productRecordList = (List<Product2>) SvmxTestDataFactory.insertSObjectList('Product2', 5);
        
        
        final List<PricebookEntry> pricebookEntryRecordList = new List<PricebookEntry>();
        final List<ServiceContract> serviceContractRecordList = (List<ServiceContract>) SvmxTestDataFactory.createSObjectList('ServiceContract', 2);
        
        for( Integer index = 0; index < 2; index++ ) {
            
            pricebookEntryRecordList.add(new PricebookEntry( Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productRecordList.get(index).Id, UnitPrice = 10000, IsActive = true));
            
            serviceContractRecordList.get(index).Pricebook2Id = Test.getStandardPricebookId();
            serviceContractRecordList.get(index).AccountId = accountRecordList.get(index).Id;
            serviceContractRecordList.get(index).StartDate = Date.today().addDays(-2);
            serviceContractRecordList.get(index).EndDate = Date.today().addDays(250);
        }
        
        insert pricebookEntryRecordList;
        insert serviceContractRecordList;
        
        
        final List<ContractLineItem> contractLineItemList = (List<ContractLineItem>) SvmxTestDataFactory.createSObjectList('ContractLineItem', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
            
            contractLineItemList.get(index).ServiceContractId = serviceContractRecordList.get(Math.mod(index, 2)).Id;
            contractLineItemList.get(index).PricebookEntryId = pricebookEntryRecordList.get(Math.mod(index, 2)).Id;
           
            contractLineItemList.get(index).Discount = 10;
            contractLineItemList.get(index).Quantity = 10;
            contractLineItemList.get(index).StartDate = Date.today().addDays(-2);
            contractLineItemList.get(index).EndDate = Date.today().addDays(250);
        }
        insert contractLineItemList;
        
    }

    static testmethod void testGetContractLines() {
        
        Test.startTest();
        
        //get ServiceContract
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();
        
        lstServiceContract.addAll([SELECT Id FROM ServiceContract]);
        System.debug('Test method----lstServiceContract:::'+lstServiceContract);

        Integer totalCount = [SELECT count() FROM contractLineItem where ServiceContractId =: lstServiceContract[0].Id];
        System.debug('Test method----totalCount:::'+totalCount);

        Integer limitCount = 20;

        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess];
        System.debug('Test method----slaProcessList:::'+slaProcessList);
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstServiceContract[0].Id;
        jsonReq.id = null;
        jsonReq.limitCount = limitCount;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Product2';
        jsonReq.sortField = 'LineItemNumber';
        jsonReq.sortOrder = 'ASC';

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines(JSON.serialize(jsonReq));

        Scon.ContractLineItems  obj = (Scon.ContractLineItems) serviceResponse.data;
        System.assert(serviceResponse.success);
        
        System.assertEquals( totalCount, obj.totalRecordCount );
        Test.stopTest();
    }
    
    
    static testmethod void testGetContractLinesInvalidParam() { 
        
        Test.startTest();

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines(JSON.serialize(jsonReq));            
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

    static testmethod void testGetContractLinesWithNull() { 
        
        Test.startTest();

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines(null);        
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    } 

    static testmethod void testGetContractLines_InvalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetCLIRecords() {
        
        Test.startTest();
        
        List<ContractLineItem> lstContractLineItem = new List<ContractLineItem>();
        
        lstContractLineItem.addAll([SELECT Id,serviceContractId FROM ContractLineItem]);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.id= lstContractLineItem[0].Id;
        jsonReq.parentId = lstContractLineItem[0].serviceContractId;
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines(JSON.serialize(jsonReq));        
        Scon.ContractLineItems  obj = (Scon.ContractLineItems) serviceResponse.data;
        System.assert(serviceResponse.success);        
        //System.assert( obj.id == lstContractLineItem[0].Id );

        Test.stopTest();
    }

    static testmethod void testGetCLIRecordsDetailsInvalidParam() {
        
        Test.startTest();

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.id='2342dsf4';
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines(JSON.serialize(jsonReq));   
        System.assert(serviceResponse.success == false); 

        Test.stopTest();
    }

    static testmethod void testGetCLIRecordsDetailsWithNull() { 
        
        Test.startTest();

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines(null);   
        System.assert(serviceResponse.success == false); 

        Test.stopTest();
    }
    
    static testmethod void testGetCLIRecordsDetails_InvalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.getContractLines('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testDeleteCLI() {
        
        Test.startTest();
        
        List<contractLineItem> lstCLI = [SELECT Id FROM contractLineItem];
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.id= lstCLI[0].Id;

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.deleteCLIRecord(JSON.serialize(jsonReq));   
        System.assert(serviceResponse.success);

        Test.stopTest();
    }

    static testmethod void testDeleteCLIHavingES() {

        Test.startTest();

        List<contractLineItem> lstCLI = [SELECT Id, ServiceContract.AccountId FROM contractLineItem];

        Entitlement entitlement = new Entitlement();
        entitlement.Name = 'ES 01';
        entitlement.AccountId = lstCLI[0].ServiceContract.AccountId;
        entitlement.ContractLineItemId = lstCLI[0].Id;
        insert entitlement;

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.id= lstCLI[0].Id;

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.deleteCLIRecord(JSON.serialize(jsonReq));   
        System.assert(!serviceResponse.success);
        System.assert(serviceResponse.message.contains(Label.Message_CLIDeleteErrorForEs));

        Test.stopTest();
    }

    static testmethod void testDeleteCLIHavingCPLI() {

        Test.startTest();

        List<contractLineItem> lstCLI = [SELECT Id, ServiceContract.AccountId FROM contractLineItem];

        SVMXA360__ContractPriceLineItem__c cpli = new SVMXA360__ContractPriceLineItem__c();
        cpli.SVMXA360__ContractLineId__c = lstCLI[0].Id;
        cpli.SVMXA360__EntitledDiscount__c = 10;
        insert cpli;

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.id= lstCLI[0].Id;

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.deleteCLIRecord(JSON.serialize(jsonReq));   
        System.assert(!serviceResponse.success);
        System.assert(serviceResponse.message.contains(Label.Message_CLIDeleteErrorForCPLI));

        Test.stopTest();
    }

    static testmethod void testDeleteCLIHavingChild() {

        Test.startTest();

        List<contractLineItem> lstCLI = [SELECT Id, ServiceContract.AccountId FROM contractLineItem];

        Entitlement entitlement = new Entitlement();
        entitlement.Name = 'ES 01';
        entitlement.AccountId = lstCLI[0].ServiceContract.AccountId;
        entitlement.ContractLineItemId = lstCLI[0].Id;
        insert entitlement;

        SVMXA360__ContractPriceLineItem__c cpli = new SVMXA360__ContractPriceLineItem__c();
        cpli.SVMXA360__ContractLineId__c = lstCLI[0].Id;
        cpli.SVMXA360__EntitledDiscount__c = 10;
        insert cpli;

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.id= lstCLI[0].Id;

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.deleteCLIRecord(JSON.serialize(jsonReq));   
        System.assert(!serviceResponse.success);
        System.assert(serviceResponse.message.contains(Label.Message_CLIDeleteError));

        Test.stopTest();
    }

    static testmethod void testDeleteCLI_InvalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.deleteCLIRecord('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testDeleteCLINullParam() {
        
        Test.startTest();   

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.deleteCLIRecord(null);   
        System.assert(serviceResponse.success == false); 

        Test.stopTest();
    }

    testmethod static void testSaveContractLineItem() {
        final ServiceContract serviceContract = [SELECT Id FROM ServiceContract LIMIT 1];
        final PricebookEntry pBERecord = [SELECT ID, Pricebook2Id FROM PricebookEntry LIMIT 1];
        serviceContract.Pricebook2Id = pBERecord.Pricebook2Id;
        update serviceContract;

        Scon.ContractLineItemRecord cliRecord = new Scon.ContractLineItemRecord();
        cliRecord.priceBookEntryId = pBERecord.Id;
        cliRecord.listPrice = 50;
        cliRecord.serviceContractId = serviceContract.Id;
        cliRecord.quantity = 2;
        cliRecord.UnitPrice = 40;
        final String requestJson = JSON.serialize(new List<Scon.ContractLineItemRecord> { cliRecord } ); 
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.saveContractLineItem(requestJson);

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }

    testmethod static void testSaveContractLineItem_InvalidParam() {
        final Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.saveContractLineItem(null);

        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }

    testmethod static void testSaveContractLineItem_InvalidRequestJson() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.saveContractLineItem('{"}');
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

    testmethod static void testSaveContractLineItem_MisingParam() {
        Scon.ContractLineItemRecord cliRecord = new Scon.ContractLineItemRecord();
        final String requestJson = JSON.serialize(new List<Scon.ContractLineItemRecord> { cliRecord } ); 
        Common.ServiceResponse serviceResponse = CLI_ContractLines_LS.saveContractLineItem(requestJson);

        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
}