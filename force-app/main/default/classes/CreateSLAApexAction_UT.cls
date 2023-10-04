@isTest
public with sharing class CreateSLAApexAction_UT {
    @testSetup
    public static void setup() {
        
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

        final List<Entitlement> entitledServiceList = (List<Entitlement>) SvmxTestDataFactory.createSObjectList('Entitlement', 5);        
        Id recordTypeId = getRecordTypeId('EntitledServices');
        Id caseSLAPrcocessId;
        Id workOrderSLAProcessId;

        List<SlaProcess> slaProcessList = [Select SobjectType from SlaProcess where IsActive=true];

        if(!slaProcessList.isEmpty()){
            for(SlaProcess process : slaProcessList){
                if(process.SobjectType == 'Case'){
                    caseSLAPrcocessId = process.Id;
                } else if(process.SobjectType == 'WorkOrder'){
                    workOrderSLAProcessId = process.Id;
                }
            }
        }

        for( Integer index = 0; index < 5; index++ ) {
            Entitlement entitlementRecord = entitledServiceList.get(index);
            entitlementRecord.RecordTypeId = recordTypeId;
            entitlementRecord.Name = 'Test Entitled Service-'+index;
            entitlementRecord.AccountId = accountRecordList.get(Math.mod(index, 5)).Id;
            entitlementRecord.ServiceContractId = serviceContractRecordList.get(Math.mod(index, 2)).Id;            
            entitlementRecord.ContractLineItemId = contractLineItemList.get(Math.mod(index, 5)).Id;
            entitlementRecord.StartDate = Date.Today();
            entitlementRecord.EndDate = Date.Today().addDays(index+1);
            entitlementRecord.SVMXA360__ServiceCountType__c= 'Hours';
            entitlementRecord.SVMXA360__TotalServiceCount__c = index+5;
            entitlementRecord.SVMXA360__ServiceCountAlertThreshold__c =index+1;
            entitlementRecord.SVMXA360__ServiceCountType__c= 'Amount';
            entitlementRecord.SVMXA360__TotalServiceAmount__c = index+5;
            entitlementRecord.SVMXA360__ServiceAmountAlertThreshold__c =index+1;
            entitlementRecord.SVMXA360__CaseEntitlementProcessId__c = caseSLAPrcocessId;
            entitlementRecord.SVMXA360__WorkOrderEntitlementProcessId__c = workOrderSLAProcessId;
        }

        insert entitledServiceList;
    }

    @isTest
    static void performSLAEntitledClone_Case(){

        Id entitledServiceRecordTypeId = getRecordTypeId('EntitledServices');
        List<Entitlement> entitlementList = [SELECT Name, RecordTypeId, AccountId, AssetId, AssetWarrantyId, BusinessHoursId, CasesPerEntitlement, SVMXA360__ConsumedServiceAmount__c,
            SVMXA360__ConsumedServiceCount__c, ContractLineItemId, EndDate, SVMXA360__EntitledServiceProductId__c, SVMXA360__EntitledServiceId__c,
            IsPerIncident, LocationId, RemainingCases, RemainingWorkOrders, SVMXA360__ServiceAmountAlertThreshold__c, ServiceContractId,
            SVMXA360__ServiceCountAlertThreshold__c, SVMXA360__ServiceCountType__c, StartDate, SvcApptBookingWindowsId, SVMXA360__TotalServiceAmount__c,
            SVMXA360__TotalServiceCount__c, Type, WorkOrdersPerEntitlement, SlaProcessId, SVMXA360__CaseEntitlementProcessId__c, SVMXA360__WorkOrderEntitlementProcessId__c
            FROM Entitlement WHERE RecordTypeId =: entitledServiceRecordTypeId LIMIT 5];

        List<CreateSLAApexAction.CreateSLARequest> cloningRequestList = new List<CreateSLAApexAction.CreateSLARequest>();

        Id slaRecordTypeId = getRecordTypeId('SLA');

        CreateSLAApexAction.CreateSLARequest cloningRequest;
        for(Entitlement entitlementRecord : entitlementList){
            cloningRequest = new CreateSLAApexAction.CreateSLARequest();
            cloningRequest.entitlementType = 'Case';
            cloningRequest.sourceSObjectList = new List<Sobject> { entitlementRecord };
            cloningRequest.slaRecordTypeId = slaRecordTypeId;
            cloningRequestList.add(cloningRequest);
        }

        Test.startTest();
        
        List<CreateSLAApexAction.CreateSLAResponse> cloneResponseList = CreateSLAApexAction.performSLAEntitlementClone(cloningRequestList);
        System.assert(cloneResponseList != null);
        System.assert(cloneResponseList.size() == cloningRequestList.size());

        Test.stopTest();

    }

    @isTest
    static void performSLAEntitledClone_WorkOrder(){

        Id entitledServiceRecordTypeId = getRecordTypeId('EntitledServices');
        List<Entitlement> entitlementList = [SELECT Name, RecordTypeId, AccountId, AssetId, AssetWarrantyId, BusinessHoursId, CasesPerEntitlement, SVMXA360__ConsumedServiceAmount__c,
            SVMXA360__ConsumedServiceCount__c, ContractLineItemId, EndDate, SVMXA360__EntitledServiceProductId__c, SVMXA360__EntitledServiceId__c,
            IsPerIncident, LocationId, RemainingCases, RemainingWorkOrders, SVMXA360__ServiceAmountAlertThreshold__c, ServiceContractId,
            SVMXA360__ServiceCountAlertThreshold__c, SVMXA360__ServiceCountType__c, StartDate, SvcApptBookingWindowsId, SVMXA360__TotalServiceAmount__c,
            SVMXA360__TotalServiceCount__c, Type, WorkOrdersPerEntitlement, SlaProcessId, SVMXA360__CaseEntitlementProcessId__c, SVMXA360__WorkOrderEntitlementProcessId__c
            FROM Entitlement WHERE RecordTypeId =: entitledServiceRecordTypeId LIMIT 5];

        List<CreateSLAApexAction.CreateSLARequest> cloningRequestList = new List<CreateSLAApexAction.CreateSLARequest>();

        Id slaRecordTypeId = getRecordTypeId('SLA');

        CreateSLAApexAction.CreateSLARequest cloningRequest;
        for(Entitlement entitlementRecord : entitlementList){
            cloningRequest = new CreateSLAApexAction.CreateSLARequest();
            cloningRequest.entitlementType = 'Work Order';
            cloningRequest.sourceSObjectList = new List<Sobject> { entitlementRecord };
            cloningRequest.slaRecordTypeId = slaRecordTypeId;
            cloningRequestList.add(cloningRequest);
        }

        Test.startTest();

        List<CreateSLAApexAction.CreateSLAResponse> cloneResponseList = CreateSLAApexAction.performSLAEntitlementClone(cloningRequestList);
        System.assert(cloneResponseList != null);
        System.assert(cloneResponseList.size() == cloningRequestList.size());

        Test.stopTest();

    }

    @isTest
    static void performSLAEntitledClone_negative(){

        Test.startTest();

        Boolean isExceptionThrown = false;
        try{
            CreateSLAApexAction.performSLAEntitlementClone(null);
        }
        catch(Exception e){
            isExceptionThrown = true;
        }
        
        System.assert(isExceptionThrown);

        Test.stopTest();

    }

    private static Id getRecordTypeId(String recordTypeName){
        return Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }
}