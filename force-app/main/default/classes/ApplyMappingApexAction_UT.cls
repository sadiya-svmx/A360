@isTest
public class ApplyMappingApexAction_UT {

    @testSetup public static void setup() {
        CONF_ObjectMappingHandler_UT.setup();
    }
    
    static testmethod void testApplyObjectMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        ApplyMappingApexAction.ApplyMappingRequest applyMappingRequest = new ApplyMappingApexAction.ApplyMappingRequest();
        applyMappingRequest.mappingId = objectMappingRecord.Id;
        applyMappingRequest.sourceSObjectList = new List<SObject>{caseRecord};
        applyMappingRequest.targetSObjectList = new List<SObject>{new WorkOrder()};
        
        List<ApplyMappingApexAction.ApplyMappingRequest> applyMappingRequestList = new List<ApplyMappingApexAction.ApplyMappingRequest>{applyMappingRequest};
        
        List<ApplyMappingApexAction.ApplyMappingResponse>  applyMappingResponseList = ApplyMappingApexAction.applyObjectMapping( applyMappingRequestList );
        
        System.assert( applyMappingResponseList != null );
        System.assert( applyMappingResponseList.size() > 0 );
        
        WorkOrder workOrder = (WorkOrder) applyMappingResponseList.get(0).targetSObjectList.get(0);
        
        System.assert( workOrder.StartDate != null );
        System.assert( workOrder.Subject.equalsIgnoreCase('Sample Subject') );
        System.assert( workOrder.AccountId == caseRecord.AccountId );
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_HeaderChild() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        ApplyMappingApexAction.ApplyMappingRequest applyMappingRequest = new ApplyMappingApexAction.ApplyMappingRequest();
        applyMappingRequest.mappingId = objectMappingRecord.Id;
        applyMappingRequest.sourceSObjectList = new List<SObject>{caseRecord};
        applyMappingRequest.targetSObjectList = new List<SObject>{new WorkOrder(), new WorkOrder() };
        
        List<ApplyMappingApexAction.ApplyMappingRequest> applyMappingRequestList = new List<ApplyMappingApexAction.ApplyMappingRequest>{applyMappingRequest};
        
        List<ApplyMappingApexAction.ApplyMappingResponse>  applyMappingResponseList = ApplyMappingApexAction.applyObjectMapping( applyMappingRequestList );
        
        System.assert( applyMappingResponseList != null );
        System.assert( applyMappingResponseList.size() > 0 );
        System.assert( applyMappingResponseList.get(0).targetSObjectList != null );
        System.assert( applyMappingResponseList.get(0).targetSObjectList.size() == 2 );
        
        WorkOrder workOrder = (WorkOrder) applyMappingResponseList.get(0).targetSObjectList.get(0);
        
        System.assert( workOrder.StartDate != null );
        System.assert( workOrder.Subject.equalsIgnoreCase('Sample Subject') );
        System.assert( workOrder.AccountId == caseRecord.AccountId );
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_CreateTargetRecord() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        ApplyMappingApexAction.ApplyMappingRequest applyMappingRequest = new ApplyMappingApexAction.ApplyMappingRequest();
        applyMappingRequest.mappingId = objectMappingRecord.Id;
        applyMappingRequest.sourceSObjectList = new List<SObject>{caseRecord};
        
        List<ApplyMappingApexAction.ApplyMappingRequest> applyMappingRequestList = new List<ApplyMappingApexAction.ApplyMappingRequest>{applyMappingRequest};
        
        List<ApplyMappingApexAction.ApplyMappingResponse>  applyMappingResponseList = ApplyMappingApexAction.applyObjectMapping( applyMappingRequestList );
        
        System.assert( applyMappingResponseList != null );
        System.assert( applyMappingResponseList.size() > 0 );
        
        WorkOrder workOrder = (WorkOrder) applyMappingResponseList.get(0).targetSObjectList.get(0);
        
        System.assert( workOrder.StartDate != null );
        System.assert( workOrder.Subject.equalsIgnoreCase('Sample Subject') );
        System.assert( workOrder.AccountId == caseRecord.AccountId );
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_InvalidParam() {
        
        Test.startTest();
        
        try {
            ApplyMappingApexAction.applyObjectMapping( null );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            ApplyMappingApexAction.applyObjectMapping( new List<ApplyMappingApexAction.ApplyMappingRequest>() );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
}