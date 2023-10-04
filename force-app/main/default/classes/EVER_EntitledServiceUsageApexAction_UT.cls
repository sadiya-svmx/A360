@IsTest
public class EVER_EntitledServiceUsageApexAction_UT {

    @testSetup public static void setup() {
        EVER_EntitledServiceUsage_UT.setup();
    }
    
    testmethod static void testUpdateConsumedUsage() {
        
        Test.startTest();
        
        List<EVER_EntitledServiceUsageApexAction.ServiceUsageRequest> serviceUsageRequestList = new List<EVER_EntitledServiceUsageApexAction.ServiceUsageRequest>();
        Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), 'EntitledServices' );
        Double count = 1.0;
        for( Entitlement entitlementRecord : [SELECT Id FROM Entitlement WHERE RecordTypeId = :recordTypeId] ) {
            
            EVER_EntitledServiceUsageApexAction.ServiceUsageRequest serviceUsageRequest = new EVER_EntitledServiceUsageApexAction.ServiceUsageRequest();
            serviceUsageRequest.entitledServiceId = entitlementRecord.id;
            serviceUsageRequest.serviceValue = count++;
            serviceUsageRequest.serviceUnit = 'Count';
            serviceUsageRequest.serviceOperation = 'Decrement';
            
            serviceUsageRequestList.add(serviceUsageRequest);
        }
        
        EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(serviceUsageRequestList);
        
        count = 1.0;
        for( Entitlement entitlementRecord : [SELECT Id, SVMXA360__ConsumedServiceCount__c FROM Entitlement WHERE RecordTypeId = :recordTypeId] ) {
            System.assert( entitlementRecord.SVMXA360__ConsumedServiceCount__c == count++, entitlementRecord.SVMXA360__ConsumedServiceCount__c );                                          
        }

        serviceUsageRequestList.get(0).serviceOperation = 'Increment';
        EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(serviceUsageRequestList);
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateConsumedUsage_Amount() {
        
        Test.startTest();
        
        List<EVER_EntitledServiceUsageApexAction.ServiceUsageRequest> serviceUsageRequestList = new List<EVER_EntitledServiceUsageApexAction.ServiceUsageRequest>();
        Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), 'EntitledServices' );
        Double count = 1.0;
        for( Entitlement entitlementRecord : [SELECT Id FROM Entitlement WHERE RecordTypeId = :recordTypeId] ) {
            
            EVER_EntitledServiceUsageApexAction.ServiceUsageRequest serviceUsageRequest = new EVER_EntitledServiceUsageApexAction.ServiceUsageRequest();
            serviceUsageRequest.entitledServiceId = entitlementRecord.id;
            serviceUsageRequest.serviceValue = count++;
            serviceUsageRequest.serviceUnit = 'Amount';
            serviceUsageRequest.serviceOperation = 'Decrement';
            
            serviceUsageRequestList.add(serviceUsageRequest);
        }
        
        EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(serviceUsageRequestList);
        
        count = 1.0;
        for( Entitlement entitlementRecord : [SELECT Id, SVMXA360__ConsumedServiceCount__c FROM Entitlement WHERE RecordTypeId = :recordTypeId] ) {
            System.assert( entitlementRecord.SVMXA360__ConsumedServiceCount__c == 0.0, entitlementRecord.SVMXA360__ConsumedServiceCount__c );                                          
        }

        serviceUsageRequestList.get(0).serviceOperation = 'Increment';
        EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(serviceUsageRequestList);
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateConsumedUsage_InvalidType() {
        
        Test.startTest();
        
        final Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), 'EntitledServices' );
        final Entitlement entitlementRecord = [SELECT Id FROM Entitlement WHERE RecordTypeId = :recordTypeId LIMIT 1];
            
        try {
            EVER_EntitledServiceUsageApexAction.ServiceUsageRequest serviceUsageRequest = new EVER_EntitledServiceUsageApexAction.ServiceUsageRequest();
            serviceUsageRequest.entitledServiceId = entitlementRecord.id;
            serviceUsageRequest.serviceValue = 1.0;
            serviceUsageRequest.serviceUnit = 'Invalid';
            serviceUsageRequest.serviceOperation = 'Decrement';
            
            EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(new List<EVER_EntitledServiceUsageApexAction.ServiceUsageRequest>{serviceUsageRequest});
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            
            EVER_EntitledServiceUsageApexAction.ServiceUsageRequest serviceUsageRequest = new EVER_EntitledServiceUsageApexAction.ServiceUsageRequest();
            serviceUsageRequest.entitledServiceId = entitlementRecord.id;
            serviceUsageRequest.serviceValue = 1.0;
            serviceUsageRequest.serviceUnit = 'Count';
            serviceUsageRequest.serviceOperation = 'Invalid';
            
            EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(new List<EVER_EntitledServiceUsageApexAction.ServiceUsageRequest>{serviceUsageRequest});
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateConsumedUsage_InvalidArgument() {
        
        Test.startTest();
        
        try {
            EVER_EntitledServiceUsageApexAction.updateEntitledServiceUsage(null);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
}