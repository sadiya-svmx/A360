@IsTest
public class PCAL_ContractPriceLineItem_LS_UT {

    
    @testSetup public static void setup() {
        
        final List<Account> accountRecordList = (List<Account>) SvmxTestDataFactory.insertSObjectList('Account', 5);
        final List<Product2> productRecordList = (List<Product2>) SvmxTestDataFactory.insertSObjectList('Product2', 5);
        
        
        final List<PricebookEntry> pricebookEntryRecordList = new List<PricebookEntry>();
        final List<ServiceContract> serviceContractRecordList = (List<ServiceContract>) SvmxTestDataFactory.createSObjectList('ServiceContract', 2);
        
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
        }
        insert contractLineItemList;
        
        
        //Insert contract price line items
        final List<SVMXA360__ContractPriceLineItem__c> contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__ContractPriceLineItem__c', 200);
        
        for( Integer index = 0; index < 200; index++ ) {
            
            contractPriceLineItemList.get(index).SVMXA360__ServiceContractId__c = serviceContractRecordList.get(Math.mod(index, 2)).Id;
            
            contractPriceLineItemList.get(index).SVMXA360__ContractLineId__c = contractLineItemList.get(Math.mod(index, 5)).Id;
            if(index <100){
                contractPriceLineItemList.get(index).SVMXA360__LineType__c = 'Expense';
                contractPriceLineItemList.get(index).SVMXA360__ProductFamily__c = 'Mobile'+index;
            }
                
            else{               
                contractPriceLineItemList.get(index).SVMXA360__LineType__c = 'Labor';
                contractPriceLineItemList.get(index).SVMXA360__ProductFamily__c = 'Laptops'+index;
            }
                
            
            contractPriceLineItemList.get(index).SVMXA360__EntitledPrice__c = index+10;
            contractPriceLineItemList.get(index).SVMXA360__EntitledDiscount__c= null;
            contractPriceLineItemList.get(index).SVMXA360__Surcharge__c= null;
        }
        insert contractPriceLineItemList;
        
    }
    
    //CPLI - Contract Price Line Items
    static testmethod void testGetContractPriceLineItems() {
        
        Test.startTest();
        
        //get ServiceContract
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();
        
        lstServiceContract.addAll([SELECT Id FROM ServiceContract]);
        System.debug('Test method----lstServiceContract:::'+lstServiceContract);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstServiceContract[0].Id;
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItems(JSON.serialize(jsonReq));
        
        Config.ContractPriceLineItems  objCPLIWrap = (Config.ContractPriceLineItems) serviceResponse.data;
        System.assert(serviceResponse.success);
        
        System.assert( objCPLIWrap.totalRecordCount== 100 );
        System.assert( objCPLIWrap.cpliRecords.size()== 20 );
        System.assert( objCPLIWrap.cpliRecords[0].id != null );
        
        Test.stopTest();
    }
    
    static testmethod void testGetCPLIRecoredsWithSearchValue() {
        
        Test.startTest();
        
        //get ServiceContract
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();
        
        lstServiceContract.addAll([SELECT Id FROM ServiceContract]);
        System.debug('Test method----lstServiceContract:::'+lstServiceContract);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstServiceContract[0].Id;
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm  ='Labor';
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItems(JSON.serialize(jsonReq));
        
        Config.ContractPriceLineItems  objCPLIWrap = (Config.ContractPriceLineItems) serviceResponse.data;
        System.assert(serviceResponse.success);
        
        System.assert( objCPLIWrap.totalRecordCount== 50 );
        System.assert( objCPLIWrap.cpliRecords.size()== 20 );
        System.assert( objCPLIWrap.cpliRecords[0].id != null );
        
        Test.stopTest();
    }
    
    static testmethod void testGetCPLIRecoredsInvalidParam() { 
        
        Test.startTest();
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItems(JSON.serialize(jsonReq));
            
        System.assert(serviceResponse.success == false);
            
        Test.stopTest();
    }
    
    static testmethod void testGetCPLIRecoredsNull() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItems(null);
        
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    //CPLI - Contract Price Line Items
    static testmethod void testGetContractPriceLineItemDetails() {
        
        Test.startTest();
        
        //get SVMXA360__ContractPriceLineItem__c
        List<SVMXA360__ContractPriceLineItem__c> lstContractPriceLineItem = new List<SVMXA360__ContractPriceLineItem__c>();
        
        lstContractPriceLineItem.addAll([SELECT Id FROM SVMXA360__ContractPriceLineItem__c]);
        System.debug('Test method----lstContractPriceLineItem:::'+lstContractPriceLineItem);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.id= lstContractPriceLineItem[0].Id;
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItemDetails(JSON.serialize(jsonReq));
        
        Config.ContractPriceLineItemDetail  objCPLIWrap = (Config.ContractPriceLineItemDetail) serviceResponse.data;
        System.assert(serviceResponse.success);

        
        System.assert( objCPLIWrap.id== lstContractPriceLineItem[0].Id );
        
        Test.stopTest();
    }

    static testmethod void testGetCPLIDetailsInvalidParam() {
        
        Test.startTest();

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.id= '234234';
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItemDetails(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success == false);        

        Test.stopTest();
    }

    static testmethod void testGetCPLIDetailsNull() { 
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.id= null;
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getContractPriceLineItemDetails(JSON.serialize(jsonReq));
        
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    
    static testmethod void testSaveContractPriceLineItem() {
        
        Test.startTest();
        
        //get SVMXA360__ContractPriceLineItem__c 
        List<SVMXA360__ContractPriceLineItem__c> lstContractPriceLineItem = new List<SVMXA360__ContractPriceLineItem__c>();
        
        lstContractPriceLineItem.addAll([SELECT Id FROM SVMXA360__ContractPriceLineItem__c]);
        System.debug('testSaveContractPriceLineItem----lstContractPriceLineItem:::'+lstContractPriceLineItem);

        List<ServiceContract> lstServiceContract = [SELECT Id FROM ServiceContract];

        System.debug('testSaveContractPriceLineItem----lstServiceContract:::'+lstServiceContract);

        List<ContractLineItem> lstContractLine = [SELECT Id FROM ContractLineItem];
        System.debug('testSaveContractPriceLineItem----lstContractLine:::'+lstContractLine);

        Config.ContractPriceLineItemDetail  jsonReq = new Config.ContractPriceLineItemDetail();
        
        jsonReq.id= lstContractPriceLineItem[0].Id;
        jsonReq.serviceContractId= lstServiceContract[0].Id;
        jsonReq.contractLineId= lstContractLine[0].Id;
        jsonReq.entitledServiceId= '';
        jsonReq.lineType= 'Parts';
        jsonReq.productId= '';
        jsonReq.productFamily= 'Laptops';
        jsonReq.price= '66.74';
        jsonReq.surcharge= '';
        jsonReq.discount= '';
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.saveContractPriceLineItem(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success);
        Config.ContractPriceLineItemDetail  objCPLIWrap = (Config.ContractPriceLineItemDetail) serviceResponse.data;

        
        System.assert( objCPLIWrap.id== lstContractPriceLineItem[0].Id );
        System.assert( objCPLIWrap.lineType== jsonReq.lineType );
        
        Test.stopTest();
    }

    static testmethod void testSaveCPLIWithInvalidParam() {
        
        Test.startTest();        

        Config.ContractPriceLineItemDetail  jsonReq = new Config.ContractPriceLineItemDetail();        
        jsonReq.id= '5353654';
        jsonReq.serviceContractId= '1234576';
        jsonReq.contractLineId= '';
        jsonReq.entitledServiceId= '';
        jsonReq.lineType= '';
        jsonReq.productId= '';
        jsonReq.productFamily= 'Mobile';
        jsonReq.price= '';
        jsonReq.surcharge= '65.00';
        jsonReq.discount= '';
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.saveContractPriceLineItem(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

    static testmethod void testSaveCPLIWithNullParam() {
        
        Test.startTest();        
        Config.ContractPriceLineItemDetail  jsonReq = new Config.ContractPriceLineItemDetail();   
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.saveContractPriceLineItem(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testDeleteContractPriceLineItem() {
        
        Test.startTest();
        
        //get SVMXA360__ContractPriceLineItem__c
        List<SVMXA360__ContractPriceLineItem__c> lstContractPriceLineItem = new List<SVMXA360__ContractPriceLineItem__c>();
        
        lstContractPriceLineItem.addAll([SELECT Id FROM SVMXA360__ContractPriceLineItem__c]);
        System.debug('Test method----lstContractPriceLineItem:::'+lstContractPriceLineItem);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.id= lstContractPriceLineItem[1].Id;
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.deleteContractPriceLineItem(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success);

        Test.stopTest();
    }


    static testmethod void testDeleteCPLIWithNullParam() {
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.id= null;
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.deleteContractPriceLineItem(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetParentRecordValues() {
        
        Test.startTest();
        
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();        
        lstServiceContract.addAll([SELECT Id FROM ServiceContract]);
        System.debug('Test method----lstServiceContract:::'+lstServiceContract);

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.parentId= lstServiceContract[0].Id;

        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getParentRecordValues(JSON.serialize(jsonReq));   
        Config.ContractPriceLineItemDetail  objCPLIWrap = (Config.ContractPriceLineItemDetail) serviceResponse.data;
        System.assert(serviceResponse.success);
              
        System.assert( objCPLIWrap.serviceContractId == lstServiceContract[0].Id );
        
        Test.stopTest();
    }
    
    static testmethod void testGetParentRecordValuesInvalidParam() { 
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId='2342dsf4';
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getParentRecordValues(JSON.serialize(jsonReq));           
        System.assert(serviceResponse.success == false);
 
        Test.stopTest();
    }

    static testmethod void testGetParentRecordValuesWithNull() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getParentRecordValues(null);  
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testGetParentRecordValues_InvalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getParentRecordValues('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetCurrencyCodeValues() {
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.objectName='SVMXA360__ContractPriceLineItem__c';

        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getCurrencyCodeValues(JSON.serialize(jsonReq));
        System.assert(serviceResponse.success);              
        
        Test.stopTest();
    }
    
    static testmethod void testGetCurrencyCodeValuesWithNull() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getCurrencyCodeValues(null);  
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testGetCurrencyCodeValues_InvalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = PCAL_ContractPriceLineItem_LS.getCurrencyCodeValues('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
}