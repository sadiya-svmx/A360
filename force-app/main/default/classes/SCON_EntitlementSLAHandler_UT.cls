@isTest
public with sharing class SCON_EntitlementSLAHandler_UT {
    @testSetup
    public static void setup() {
        
        CreateSLAApexAction_UT.setup();
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

        Id slaRecordTypeId = getRecordTypeId('SLA');

        Test.startTest();
        
        List<Entitlement> cloneResponseList = new SCON_EntitlementSLAHandler().getSLAEntitlementCloneList( entitlementList, 'Case', slaRecordTypeId);
        System.assert(cloneResponseList != null);
        System.assert(cloneResponseList.size() == entitlementList.size());

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

        Id slaRecordTypeId = getRecordTypeId('SLA');

        Test.startTest();

        List<Entitlement> cloneResponseList = new SCON_EntitlementSLAHandler().getSLAEntitlementCloneList(entitlementList, 'WorkOrder', slaRecordTypeId);
        System.assert(cloneResponseList != null);
        System.assert(cloneResponseList.size() == entitlementList.size());

        Test.stopTest();

    }

    @isTest
    static void performSLAEntitledClone_negative(){

        Test.startTest();

        Boolean isExceptionThrown = false;
        try{
            new SCON_EntitlementSLAHandler().getSLAEntitlementCloneList( null, null, null );
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