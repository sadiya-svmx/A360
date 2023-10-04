@IsTest
public class EVER_EntitledServiceManager_UT{
    
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
        final List<Entitlement> entitledServiceList = (List<Entitlement>) SvmxTestDataFactory.createSObjectList('Entitlement', 200);        
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();

        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];

        for( Integer index = 0; index < 200; index++ ) {
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
        
    }

    static testmethod void testGetEntitledServices() {
        
        Test.startTest();
        
        //get ServiceContract
        List<ServiceContract> lstServiceContract = new List<ServiceContract>();
        
        lstServiceContract.addAll([SELECT Id FROM ServiceContract]);
        System.debug('Test method----lstServiceContract:::'+lstServiceContract);
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();
        Integer totalCount = [SELECT count() FROM Entitlement where ServiceContractId =: lstServiceContract[0].Id and RecordTypeId =:recordTypeId];
        System.debug('Test method----totalCount:::'+totalCount);

        Integer limitCount = 20;

        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess];
        System.debug('Test method----slaProcessList:::'+slaProcessList);
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        
        jsonReq.parentId= lstServiceContract[0].Id;
        jsonReq.id = null;
        jsonReq.limitCount = limitCount;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Entitled';
        jsonReq.sortField = 'Name';
        jsonReq.sortOrder = 'ASC';
        jsonReq.objectName = '';
        
        Ever.EntitledService  objEntitledServices = EVER_EntitledServiceManager.getInstance().getEntitledServices(jsonReq);
        System.assertEquals( totalCount, objEntitledServices.totalRecordCount );
        System.assertEquals( limitCount, objEntitledServices.entitledServiceDetailList.size() );
        
        Test.stopTest();
    }
    
    
    static testmethod void testGetEntitledServicesInvalidParam() { 
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId='2342dsf4';        
        try {
            
            Ever.EntitledService  objEntitledServices = EVER_EntitledServiceManager.getInstance().getEntitledServices(jsonReq);            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
            
        Test.stopTest();
    }

    static testmethod void testGetEntitledServicesWithNull() { 
        
        Test.startTest();
        try {
            
            Ever.EntitledService  objEntitledServices = EVER_EntitledServiceManager.getInstance().getEntitledServices(null);             
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
        
        Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getParentRecordValues(jsonReq);
        System.assert( objEntitledServiceDetails.serviceContractId == lstServiceContract[0].Id );
        
        Test.stopTest();
    }

    static testmethod void testGetParentRecordValuesForContractLine() {
        
        Test.startTest();
        
        List<ContractLineItem> lstContractLineItem = new List<ContractLineItem>();        
        lstContractLineItem.addAll([SELECT Id FROM ContractLineItem]);
        System.debug('Test method----lstContractLineItem:::'+lstContractLineItem);

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.parentId= lstContractLineItem[0].Id;
        
        Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getParentRecordValues(jsonReq);
        System.assert( objEntitledServiceDetails.contractLineId == lstContractLineItem[0].Id );
        
        Test.stopTest();
    }
    
    
    static testmethod void testGetParentRecordValuesInvalidParam() { 
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId='2342dsf4';
        
         try {
            
            Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getParentRecordValues(jsonReq);           
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
            
        Test.stopTest();
    }

    static testmethod void testGetParentRecordValuesWithNull() { 
        
        Test.startTest();
        try {
            
            Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getParentRecordValues(null);           
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntitledServiceDetails() {
        
        Test.startTest();
        
        //get Entitlement
        List<Entitlement> lstEntitlement = new List<Entitlement>();
        
        lstEntitlement.addAll([SELECT Id FROM Entitlement]);
        System.debug('Test method----lstEntitlement:::'+lstEntitlement);
        
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();        
        jsonReq.id= lstEntitlement[0].Id;
        Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getEntitledServiceDetails(jsonReq);        
        System.assert( objEntitledServiceDetails.id== lstEntitlement[0].Id );        
        Test.stopTest();
    }

    static testmethod void testGetEntitledServiceDetailsInvalidParam() {
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.id='2342dsf4';
        
        try {
            
            Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getEntitledServiceDetails(jsonReq);            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
            
        Test.stopTest();
    }

    static testmethod void testGetEntitledServiceDetailsWithNull() { 
        
        Test.startTest();
        try {
            
            Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().getEntitledServiceDetails(null);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    } 
    
    static testmethod void testSaveEntitledService() {
        
        Test.startTest();
        
        List<Entitlement> lstEntitlement = [SELECT Id FROM Entitlement];
        List<Account> lstAccount = [SELECT Id FROM Account];
        List<ServiceContract> lstServiceContract = [SELECT Id FROM ServiceContract];
        List<ContractLineItem> lstContractLine = [SELECT Id FROM ContractLineItem];
        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];

        Ever.EntitledServiceDetail jsonReq = new Ever.EntitledServiceDetail();
        jsonReq.id =lstEntitlement[0].Id;
        jsonReq.accountId =lstAccount[0].Id;
        jsonReq.contractLineId =lstContractLine[0].Id;
        jsonReq.serviceContractId =lstServiceContract[0].Id;
        jsonReq.name ='Test Entitled Service-1';
        jsonReq.caseEntitlementProcessId =slaProcessList!=null ? slaProcessList[0].Id : null;
        jsonReq.workOrderEntitlementProcessId =slaProcessList!=null ? slaProcessList[0].Id : null;
        jsonReq.startDate =Date.Today();
        jsonReq.endDate =Date.Today().addDays(3);
        jsonReq.serviceType='Amount';
        jsonReq.serviceAlertThreshold =8;
        jsonReq.totalService =27;
        Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().saveEntitledService(jsonReq);
        
        System.assert( objEntitledServiceDetails.id== lstEntitlement[0].Id );
        System.assert( objEntitledServiceDetails.name== jsonReq.name );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveEntitledService_Hours() {
        
        Test.startTest();
        
        List<Entitlement> lstEntitlement = [SELECT Id FROM Entitlement];
        List<Account> lstAccount = [SELECT Id FROM Account];
        List<ServiceContract> lstServiceContract = [SELECT Id FROM ServiceContract];
        List<ContractLineItem> lstContractLine = [SELECT Id FROM ContractLineItem];
        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];

        Ever.EntitledServiceDetail jsonReq = new Ever.EntitledServiceDetail();
        jsonReq.id =lstEntitlement[0].Id;
        jsonReq.accountId =lstAccount[0].Id;
        jsonReq.contractLineId =lstContractLine[0].Id;
        jsonReq.serviceContractId =lstServiceContract[0].Id;
        jsonReq.name ='Test Entitled Service-1';
        jsonReq.caseEntitlementProcessId =slaProcessList!=null ? slaProcessList[0].Id : null;
        jsonReq.workOrderEntitlementProcessId =slaProcessList!=null ? slaProcessList[0].Id : null;
        jsonReq.startDate =Date.Today();
        jsonReq.endDate =Date.Today().addDays(3);
        jsonReq.serviceType='Hours';
        jsonReq.serviceAlertThreshold =8;
        jsonReq.totalService =27;
        Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().saveEntitledService(jsonReq);
        
        System.assert( objEntitledServiceDetails.id== lstEntitlement[0].Id );
        System.assert( objEntitledServiceDetails.name== jsonReq.name );
        
        Test.stopTest();
    }

    static testmethod void testSaveEntitledServiceInvalidParam() {
        
        Test.startTest();        

        Ever.EntitledServiceDetail jsonReq = new Ever.EntitledServiceDetail();
        jsonReq.accountId ='34233';
        jsonReq.serviceContractId ='234242';
        jsonReq.name ='Test Entitled Service-2';
        jsonReq.startDate =Date.Today();
        jsonReq.endDate =Date.Today().addDays(3);
        jsonReq.serviceAlertThreshold =8;
        jsonReq.totalService =27;

        try {
            
            Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().saveEntitledService(jsonReq);           
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        Test.stopTest();
    }

    static testmethod void testSaveEntitledServiceWithNullParam() {
        
        Test.startTest();   
        try {
            
            Ever.EntitledServiceDetail  objEntitledServiceDetails = EVER_EntitledServiceManager.getInstance().saveEntitledService(null);            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }  
        
        Test.stopTest();
    }

    static testmethod void testDeleteEntitledService() {
        Test.startTest();

        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();
        List<Entitlement> lstEntitlement = [SELECT Id, RecordType.Name FROM Entitlement 
            WHERE RecordTypeId = :recordTypeId];

        Config.FilterCriteria jsonReq = new Config.FilterCriteria();

        jsonReq.id= lstEntitlement[0].Id;
        EVER_EntitledServiceManager.getInstance().deleteEntitledService(jsonReq.id);  

        List<Entitlement> entitlementList = [Select Id from Entitlement where Id = :jsonReq.id];
        System.assert( entitlementList.size() == 0 );

        Test.stopTest();
    }


    static testmethod void testDeleteEntitledServiceInvalidParam() {
        
        Test.startTest();

        try {
            EVER_EntitledServiceManager.getInstance().deleteEntitledService('242143');   
        } catch(Exception e ){
            System.assert(true);
        }
        Test.stopTest();
    }

    static testmethod void testDeleteEntitledServiceNullParam() {
        
        Test.startTest();
        try {
            EVER_EntitledServiceManager.getInstance().deleteEntitledService(null); 
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    } 

    static testmethod void testDeleteESHavingCPLI() {

        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();
        List<Entitlement> lstEntitlement = [SELECT Id, RecordType.Name FROM Entitlement 
            WHERE RecordTypeId = :recordTypeId];

        SVMXA360__ContractPriceLineItem__c cpli = new SVMXA360__ContractPriceLineItem__c();
        cpli.SVMXA360__EntitledServiceId__c = lstEntitlement[0].Id;
        cpli.SVMXA360__EntitledDiscount__c = 10;
        insert cpli;

        Test.startTest();
        try {
            EVER_EntitledServiceManager.getInstance().deleteEntitledService(lstEntitlement[0].Id);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        Test.stopTest();
    }

}