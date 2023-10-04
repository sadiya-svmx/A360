@IsTest
public class EVER_AbstractEntitlementEngine_UT {

    @testSetup public static void setup() {
        
        final List<Account> accountRecordList = (List<Account>) SvmxTestDataFactory.insertSObjectList('Account', 5);
        final List<Product2> productRecordList = (List<Product2>) SvmxTestDataFactory.insertSObjectList('Product2', 5);
        final List<Asset> assetRecordList = (List<Asset>) SvmxTestDataFactory.createSObjectList('Asset', 100);
        
        for( Integer index = 0; index < 100; index++ ) {
            
            assetRecordList.get(index).AccountId = accountRecordList.get( Math.mod(index, 5) ).Id;
            assetRecordList.get(index).Product2Id = productRecordList.get( Math.mod(index, 5) ).Id;
        }
        
        insert assetRecordList;
        
        final List<Case> caseRecordList = (List<Case>) SvmxTestDataFactory.insertSObjectList('Case', 
                                                                                       new Map<String,Object>{
                                                                                           'Status' => 'New', 
                                                                                           'SVMXA360__PerformAutoEntitlement__c' => true
                                                                                       }, 200);
        for( Integer index = 0; index < 200; index++ ) {
            
            caseRecordList.get(index).AssetId = assetRecordList.get(Math.mod(index, 100)).Id;
            caseRecordList.get(index).AccountId = accountRecordList.get( Math.mod(index, 5) ).Id;
        }
        
        update caseRecordList;
        
        final List<PricebookEntry> pricebookEntryRecordList = new List<PricebookEntry>();
        final List<ServiceContract> serviceContractRecordList = (List<ServiceContract>) SvmxTestDataFactory.createSObjectList('ServiceContract', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
            
            pricebookEntryRecordList.add(new PricebookEntry( Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productRecordList.get(index).Id, UnitPrice = 10000, IsActive = true));
            
            serviceContractRecordList.get(index).Pricebook2Id = Test.getStandardPricebookId();
            serviceContractRecordList.get(index).AccountId = accountRecordList.get(index).Id;
            serviceContractRecordList.get(index).StartDate = Date.today().addYears(-2);
            serviceContractRecordList.get(index).EndDate = Date.today().addYears(2);
            serviceContractRecordList.get(index).SVMXA360__ContractAuthoringStatus__c = 'InProgress';
        }
        
        insert pricebookEntryRecordList;
        insert serviceContractRecordList;
        
        final List<ContractLineItem> contractLineItemList = (List<ContractLineItem>) SvmxTestDataFactory.createSObjectList('ContractLineItem', 200);
        
        for( Integer index = 0; index < 200; index++ ) {
            
            contractLineItemList.get(index).ServiceContractId = serviceContractRecordList.get(Math.mod(index, 5)).Id;
            contractLineItemList.get(index).PricebookEntryId = pricebookEntryRecordList.get(Math.mod(index, 5)).Id;
            contractLineItemList.get(index).AssetId = assetRecordList.get(Math.mod(index, 100)).Id;
            contractLineItemList.get(index).Discount = 10;
            contractLineItemList.get(index).Quantity = 10;
            contractLineItemList.get(index).StartDate = Date.today().addYears(-2);
            contractLineItemList.get(index).EndDate = Date.today().addYears(2);
        }
        insert contractLineItemList;
        
        final List<AssetWarranty> assetWarrantyList = (List<AssetWarranty>) SvmxTestDataFactory.createSObjectList('AssetWarranty', 200);
        for( Integer index = 0; index < 200; index++ ) {
            assetWarrantyList.get(index).AssetId = assetRecordList.get(Math.mod(index, 100)).Id;
            assetWarrantyList.get(index).WarrantyType = 'Non Standard';
        }
        
        insert assetWarrantyList;
        
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
            entitledServiceList.get(index).StartDate = Date.today().addYears(-1);
            entitledServiceList.get(index).EndDate = Date.today().addYears(1);
            if(index <100){
                entitledServiceList.get(index).SVMXA360__ServiceCountType__c= 'Count';
                entitledServiceList.get(index).SVMXA360__TotalServiceAmount__c = index+5;
                entitledServiceList.get(index).SVMXA360__ServiceAmountAlertThreshold__c =index+1;
            } else { 
                entitledServiceList.get(index).SVMXA360__ServiceCountType__c= 'Amount';
                entitledServiceList.get(index).SVMXA360__TotalServiceCount__c = index+5;
                entitledServiceList.get(index).SVMXA360__ServiceCountAlertThreshold__c =index+1;
            }
            entitledServiceList.get(index).SVMXA360__CaseEntitlementProcessId__c = (slaProcessList!=null) ? slaProcessList[0].Id : null;
            entitledServiceList.get(index).SVMXA360__WorkOrderEntitlementProcessId__c =(slaProcessList!=null) ? slaProcessList[0].Id : null;

        }
        insert entitledServiceList;
        
        //Insert contract price line items
        final List<SVMXA360__ContractPriceLineItem__c> contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__ContractPriceLineItem__c', 10);
        
        for( Integer index = 0; index < 10; index++ ) {
            
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
    
    testmethod static void testRetrieveSourceRecords() {
        
        Test.startTest();
        
        final Map<String,Case> caseRecordMap = new Map<String,Case>();
        caseRecordMap.putAll([SELECT Id FROM Case]);
        
        final List<SObject> caseRecords = new EVER_AutoEntitlementEngine('Case').retrieveSourceRecords( new List<String>(caseRecordMap.keySet()) );
        
        System.assert( caseRecords != null );
        System.assert( caseRecords.size() == 200 );
        
        Test.stopTest();
    }
    
    testmethod static void testRetrieveSourceRecords_InvalidParam() {
        
        Test.startTest();
        
        try {
            new EVER_AutoEntitlementEngine('Case').retrieveSourceRecords( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            new EVER_AutoEntitlementEngine('Case').retrieveSourceRecords( new List<String>() );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testRetrieveEntitlementDate() {
        
        Test.startTest();
        
        final List<id> caseIds = new List<id>();
        final List<Case> caseRecordList = new List<Case>();
        
        for( Case caseRecord : [SELECT Id FROM Case] ) {
            
            caseIds.add(caseRecord.Id);
            caseRecord.SVMXA360__EntitlementDate__c = Date.today();
        }
        
        update caseRecordList;
        
        List<SObject> caseRecords = new EVER_AutoEntitlementEngine('Case').retrieveSourceRecords( caseIds );
        
        System.assert( caseRecords != null );
        System.assert( caseRecords.size() == 200 );
        
        Date entitlementDate = new EVER_AutoEntitlementEngine('Case').retrieveEntitlementDate( caseRecords.get(0) );
        
        System.assert( entitlementDate != null );
        System.assert( entitlementDate == Date.today() );
        
        Test.stopTest();
    }
}