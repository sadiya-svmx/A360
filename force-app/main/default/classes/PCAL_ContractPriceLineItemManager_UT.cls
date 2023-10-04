@IsTest
public class PCAL_ContractPriceLineItemManager_UT{
    
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
            contractLineItemList.get(index).StartDate = Date.Today();
            contractLineItemList.get(index).EndDate = Date.Today().addDays(250);
        }
        insert contractLineItemList;
        
        //Insert entitledServices
        final List<Entitlement> entitledServiceList = (List<Entitlement>) SvmxTestDataFactory.createSObjectList('Entitlement', 2);        
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();

        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];

        for( Integer index = 0; index < 2; index++ ) {
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
            entitledServiceList.get(index).SVMXA360__CaseEntitlementProcessId__c = (slaProcessList!=null) ? slaProcessList[0].Id : null;
            entitledServiceList.get(index).SVMXA360__WorkOrderEntitlementProcessId__c =(slaProcessList!=null) ? slaProcessList[0].Id : null;

        }
        insert entitledServiceList;
        
        
        //Insert contract price line items
        final List<SVMXA360__ContractPriceLineItem__c> contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__ContractPriceLineItem__c', 200);
        
        for( Integer index = 0; index < 200; index++ ) {
            
            contractPriceLineItemList.get(index).SVMXA360__ServiceContractId__c = serviceContractRecordList.get(Math.mod(index, 2)).Id;
            
            contractPriceLineItemList.get(index).SVMXA360__ContractLineId__c = contractLineItemList.get(Math.mod(index, 5)).Id;
            contractPriceLineItemList.get(index).SVMXA360__EntitledServiceId__c = entitledServiceList.get(Math.mod(index, 2)).Id;
            contractPriceLineItemList.get(index).SVMXA360__LineType__c = 'Labor';
            contractPriceLineItemList.get(index).SVMXA360__ProductFamily__c = 'Laptops'+index;
            contractPriceLineItemList.get(index).SVMXA360__EntitledPrice__c = index+10;
            contractPriceLineItemList.get(index).SVMXA360__Surcharge__c = null;
            contractPriceLineItemList.get(index).SVMXA360__EntitledDiscount__c = null;
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
        
        Integer totalCountForLabor = [SELECT count() FROM SVMXA360__ContractPriceLineItem__c where SVMXA360__ServiceContractId__c =: lstServiceContract[0].Id and SVMXA360__LineType__c ='Labor'];
        System.debug('Test method----totalCountForLabor :::'+totalCountForLabor );
        
        List<SVMXA360__ContractPriceLineItem__c > lstContractPriceLineItem = [SELECT Id FROM SVMXA360__ContractPriceLineItem__c ];
        
        Integer limitCount = 20;
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstServiceContract[0].Id;
        jsonReq.id = lstContractPriceLineItem[0].Id;
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Labor';
        jsonReq.sortField = 'SVMXA360__ProductFamily__c';
        jsonReq.sortOrder = 'ASC';
        jsonReq.objectName = '';
        
        Config.ContractPriceLineItems  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItems(jsonReq);
        
        System.assertEquals( totalCountForLabor, objCPLIWrap.totalRecordCount );
        System.assertEquals( limitCount, objCPLIWrap.cpliRecords.size() );
        
        
        Test.stopTest();
    }

    static testmethod void testGetCPLIForContractLine() {
        
        Test.startTest();
        
        //get ContractLineItem
        List<ContractLineItem> lstContractLineItem = new List<ContractLineItem>();
        
        lstContractLineItem.addAll([SELECT Id FROM ContractLineItem]);
        System.debug('Test method----lstContractLineItem:::'+lstContractLineItem);
        
        Integer totalCountForLabor = [SELECT count() FROM SVMXA360__ContractPriceLineItem__c where SVMXA360__ContractLineId__c =: lstContractLineItem[0].Id and SVMXA360__LineType__c ='Labor'];
        System.debug('Test method----totalCountForLabor :::'+totalCountForLabor );
        
        List<SVMXA360__ContractPriceLineItem__c > lstContractPriceLineItem = [SELECT Id FROM SVMXA360__ContractPriceLineItem__c ];
        
        Integer limitCount = 20;
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstContractLineItem[0].Id;
        jsonReq.id = lstContractPriceLineItem[0].Id;
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Labor';
        jsonReq.sortField = 'SVMXA360__ProductFamily__c';
        jsonReq.sortOrder = 'ASC';
        jsonReq.objectName = '';
        
        Config.ContractPriceLineItems  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItems(jsonReq);        
        System.assertEquals( totalCountForLabor, objCPLIWrap.totalRecordCount );        
        
        Test.stopTest();
    }
    
    static testmethod void testGetCPLIForEntitledService() {
        
        Test.startTest();
        
        //get Entitled Service records
        List<Entitlement> lstEntitledService = new List<Entitlement>();
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();
        lstEntitledService.addAll([SELECT Id FROM Entitlement Where RecordTypeId =:recordTypeId]);
        System.debug('Test method----lstEntitledService :::'+lstEntitledService );
        
        Integer totalCountForLabor = [SELECT count() FROM SVMXA360__ContractPriceLineItem__c where SVMXA360__EntitledServiceId__c=: lstEntitledService[0].Id and SVMXA360__LineType__c ='Labor'];
        System.debug('Test method----totalCountForLabor :::'+totalCountForLabor );
        
        List<SVMXA360__ContractPriceLineItem__c > lstContractPriceLineItem = [SELECT Id FROM SVMXA360__ContractPriceLineItem__c ];
        
        Integer limitCount = 20;
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstEntitledService[0].Id;
        jsonReq.id = lstContractPriceLineItem[0].Id;
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Labor';
        jsonReq.sortField = 'SVMXA360__ProductFamily__c';
        jsonReq.sortOrder = 'ASC';
        jsonReq.objectName = '';
        
        Config.ContractPriceLineItems  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItems(jsonReq);        
        System.assertEquals( totalCountForLabor, objCPLIWrap.totalRecordCount );        
        
        Test.stopTest();
    }
    
    static testmethod void testGetCPLIRecoredsInvalidParam() { 
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId='2342dsf4';
        
         try {
            
            Config.ContractPriceLineItems  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItems(jsonReq);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
            
        Test.stopTest();
    }

    static testmethod void testGetCPLIRecoredsWithNull() { 
        
        Test.startTest();
        try {
            
            Config.ContractPriceLineItems  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItems(null);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
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

        Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItemDetails(jsonReq);
        
        System.assert( objCPLIWrap.id== lstContractPriceLineItem[0].Id );
        
        Test.stopTest();
    }
    
    static testmethod void testGetCPLIDetailsInvalidId() {
        
        Test.startTest();
        
        //get SVMXA360__ContractPriceLineItem__c
        List<SVMXA360__ContractPriceLineItem__c> lstContractPriceLineItem = new List<SVMXA360__ContractPriceLineItem__c>();
        
        lstContractPriceLineItem.addAll([SELECT Id FROM SVMXA360__ContractPriceLineItem__c]);
        System.debug('Test method----lstContractPriceLineItem:::'+lstContractPriceLineItem);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        //Id cpliRecordId = lstContractPriceLineItem[0].Id;
        jsonReq.id= lstContractPriceLineItem[0].Id;
        
        delete lstContractPriceLineItem[0];
        
        try {
            
            Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItemDetails(jsonReq);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }

    static testmethod void testGetCPLIDetailsInvalidParam() {
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.id='2342dsf4';
        
        try {
            
            Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItemDetails(jsonReq);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
            
        Test.stopTest();
    }

    static testmethod void testGetCPLIDetailsWithNull() { 
        
        Test.startTest();
        try {
            
            Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItemDetails(null);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    } 

    static testmethod void testSaveContractPriceLineItem() {
        
        Test.startTest();
        
        //get SVMXA360__ContractPriceLineItem__c 
        List<SVMXA360__ContractPriceLineItem__c> lstContractPriceLineItem = new List<SVMXA360__ContractPriceLineItem__c>();
        
        lstContractPriceLineItem.addAll([SELECT Id FROM SVMXA360__ContractPriceLineItem__c]);

        List<ServiceContract> lstServiceContract = [SELECT Id FROM ServiceContract];

        List<ContractLineItem> lstContractLine = [SELECT Id FROM ContractLineItem];

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
        
        Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().saveContractPriceLineItem(jsonReq);
        
        System.assert( objCPLIWrap.id== lstContractPriceLineItem[0].Id );
        System.assert( objCPLIWrap.lineType== jsonReq.lineType );
        
        Test.stopTest();
    }

    static testmethod void testSaveCPLIWithInvalidParam() {
        
        Test.startTest();        

        Config.ContractPriceLineItemDetail  jsonReq = new Config.ContractPriceLineItemDetail();        
        jsonReq.id= '5353654';
        jsonReq.serviceContractId= '1234576';
        jsonReq.lineType= 'Parts';

        try {
            
            Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().saveContractPriceLineItem(jsonReq);            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        Test.stopTest();
    }

    static testmethod void testSaveCPLIWithNullParam() {
        
        Test.startTest();   
        try {
            
            Config.ContractPriceLineItemDetail  objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().saveContractPriceLineItem(null);            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }  
        
        Test.stopTest();
    }

    static testmethod void testDeleteContractPriceLineItem() {
        
        Test.startTest();
        
        //get SVMXA360__ContractPriceLineItem__c
        List<SVMXA360__ContractPriceLineItem__c> lstContractPriceLineItem = new List<SVMXA360__ContractPriceLineItem__c>();
        
        lstContractPriceLineItem.addAll([SELECT Id FROM SVMXA360__ContractPriceLineItem__c]);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.id= lstContractPriceLineItem[1].Id;

        PCAL_ContractPriceLineItemManager.getInstance().deleteContractPriceLineItem(jsonReq.id);  
        
        List<SVMXA360__ContractPriceLineItem__c> contractPriceList = [Select Id from SVMXA360__ContractPriceLineItem__c where Id = :jsonReq.id];
        System.assert( contractPriceList.size() == 0 );
        

        Test.stopTest();
    }


    static testmethod void testDeleteCPLIWithNullParam() {
        
        Test.startTest();   
        try {
            PCAL_ContractPriceLineItemManager.getInstance().deleteContractPriceLineItem(null);  
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetParentRecordValues() {
        
        Test.startTest();
        
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();        
        lstServiceContract.addAll([SELECT Id FROM ServiceContract]);
        System.debug('Test method----lstServiceContract:::'+lstServiceContract);

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.parentId= lstServiceContract[0].Id;
        
        Config.ContractPriceLineItemDetail objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getParentRecordValues(jsonReq);
        System.assert( objCPLIWrap.serviceContractId == lstServiceContract[0].Id );
        
        Test.stopTest();
    }
    
    static testmethod void testGetParentRecordValuesForContractLine() {
        
        Test.startTest();
        
        List<ContractLineItem> lstContractLineItem = new List<ContractLineItem>();        
        lstContractLineItem.addAll([SELECT Id FROM ContractLineItem]);
        System.debug('Test method----lstContractLineItem:::'+lstContractLineItem);

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.parentId= lstContractLineItem[0].Id;
        
        Config.ContractPriceLineItemDetail objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getParentRecordValues(jsonReq);
        System.assert( objCPLIWrap.contractLineId == lstContractLineItem[0].Id );
        
        Test.stopTest();
    }
    
    static testmethod void testGetParentRecordValuesForEntitledService() {
        
        Test.startTest();
        
        List<Entitlement> lstEntitledService = new List<Entitlement>();        
        lstEntitledService.addAll([SELECT Id FROM Entitlement]);
        System.debug('Test method----lstEntitledService :::'+lstEntitledService );

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.parentId= lstEntitledService[0].Id;
        
        Config.ContractPriceLineItemDetail objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getParentRecordValues(jsonReq);
        System.assert( objCPLIWrap.entitledServiceId == lstEntitledService[0].Id );
        
        Test.stopTest();
    }
    
    static testmethod void testGetParentRecordValuesInvalidParam() { 
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId='2342dsf4';
        
         try {
            
            Config.ContractPriceLineItemDetail objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getParentRecordValues(jsonReq);         
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
            
        Test.stopTest();
    }

    static testmethod void testGetParentRecordValuesWithNull() { 
        
        Test.startTest();
        try {
            
            Config.ContractPriceLineItemDetail objCPLIWrap = PCAL_ContractPriceLineItemManager.getInstance().getParentRecordValues(null);      
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
}