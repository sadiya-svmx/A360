@isTest
public class EVER_EntitledServiceUsage_UT {

    @testSetup public static void setup() {
        
        final Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');

        Id caseEntitlementProcessId;
        Id workOrderEntitlementProcessId;

        List<SlaProcess> slaProcessList = [SELECT SobjectType FROM SlaProcess LIMIT 50];

        for(SlaProcess process : slaProcessList){
            if(process.SobjectType == 'Case'){
                caseEntitlementProcessId = process.Id;
            } else if(process.SobjectType == 'WorkOrder'){
                workOrderEntitlementProcessId = process.Id;
            }
        }

        final List<Entitlement> entitlementRecordList = (List<Entitlement>) SvmxTestDataFactory.createSObjectList('Entitlement', 
                                                                                       new Map<String,Object>{
                                                                                           'AccountId' => accountRecord.Id,
                                                                                           'SVMXA360__ServiceCountType__c' => 'Visits',
                                                                                           'SVMXA360__ConsumedServiceCount__c' => 0, 
                                                                                           'SVMXA360__ConsumedServiceAmount__c' => 0, 
                                                                                           'SVMXA360__TotalServiceCount__c' => 10,
                                                                                           'SVMXA360__CaseEntitlementProcessId__c' => caseEntitlementProcessId,
                                                                                           'SVMXA360__WorkOrderEntitlementProcessId__c' => workOrderEntitlementProcessId
                                                                                       }, 5);

        Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), 'EntitledServices' );
        for( Entitlement entitlement : entitlementRecordList ) {
            entitlement.RecordTypeId = recordTypeId;
        }
        
        SvmxDatabase.insertRecord(entitlementRecordList);
    }
    
    testmethod static void testUpdateConsumedUsage_Count() {
        
        Test.startTest();
        
        Entitlement entitlementRecord = [SELECT Id FROM Entitlement LIMIT 1];
        
        Ever.ServiceUsageInfo serviceUsageInfo = new Ever.ServiceUsageInfo();
        serviceUsageInfo.entitledServiceId = entitlementRecord.id;
        serviceUsageInfo.serviceValue = 5.0;
        serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Count;
        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Decrement;
        
        new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfo);
        
        entitlementRecord = [SELECT Id, SVMXA360__ConsumedServiceCount__c FROM Entitlement WHERE id = :entitlementRecord.id LIMIT 1];
        
        System.assert( entitlementRecord.SVMXA360__ConsumedServiceCount__c == 5, entitlementRecord.SVMXA360__ConsumedServiceCount__c );
        
        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Increment;
        new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfo);
        
        entitlementRecord = [SELECT Id, SVMXA360__ConsumedServiceCount__c FROM Entitlement WHERE id = :entitlementRecord.id LIMIT 1];
        
        System.assert( entitlementRecord.SVMXA360__ConsumedServiceCount__c == 0, entitlementRecord.SVMXA360__ConsumedServiceCount__c );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateConsumedUsage_Amount() {
        
        Test.startTest();
        
        Entitlement entitlementRecord = [SELECT Id FROM Entitlement LIMIT 1];
        
        Ever.ServiceUsageInfo serviceUsageInfo = new Ever.ServiceUsageInfo();
        serviceUsageInfo.entitledServiceId = entitlementRecord.id;
        serviceUsageInfo.serviceValue = 5.0;
        serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Amount;
        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Decrement;
        
        new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfo);
        
        entitlementRecord = [SELECT Id, SVMXA360__ConsumedServiceAmount__c FROM Entitlement WHERE id = :entitlementRecord.id LIMIT 1];
        
        System.assert( entitlementRecord.SVMXA360__ConsumedServiceAmount__c == 5, entitlementRecord.SVMXA360__ConsumedServiceAmount__c );
        
        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Increment;
        new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfo);
        
        entitlementRecord = [SELECT Id, SVMXA360__ConsumedServiceAmount__c FROM Entitlement WHERE id = :entitlementRecord.id LIMIT 1];
        
        System.assert( entitlementRecord.SVMXA360__ConsumedServiceAmount__c == 0, entitlementRecord.SVMXA360__ConsumedServiceAmount__c );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateConsumedUsage_List() {
        
        Test.startTest();
        
        List<Ever.ServiceUsageInfo> serviceUsageInfoList = new List<Ever.ServiceUsageInfo>();
        Double count = 1.0;
        Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), 'EntitledServices' );
        for( Entitlement entitlementRecord : [SELECT Id FROM Entitlement WHERE RecordTypeId = :recordTypeId ] ) {
            
            Ever.ServiceUsageInfo serviceUsageInfo = new Ever.ServiceUsageInfo();
            serviceUsageInfo.entitledServiceId = entitlementRecord.id;
            serviceUsageInfo.serviceValue = count++;
            serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Count;
            serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Decrement;
            
            serviceUsageInfoList.add(serviceUsageInfo);
        }
 
        new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfoList);
        
        count = 1.0;
        for( Entitlement entitlementRecord : [SELECT Id, SVMXA360__ConsumedServiceCount__c FROM Entitlement WHERE RecordTypeId = :recordTypeId] ) {
            System.assert( entitlementRecord.SVMXA360__ConsumedServiceCount__c == count++, entitlementRecord.SVMXA360__ConsumedServiceCount__c );
        }
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateConsumedUsage_InvalidArgument() {
        
        Test.startTest();
        
        try {
            Ever.ServiceUsageInfo serviceUsageInfo = null;
            new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfo);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            new EVER_EntitledServiceUsage().updateConsumedUsage(new List<Ever.ServiceUsageInfo>());
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            
            new EVER_EntitledServiceUsage().updateConsumedUsage( new Ever.ServiceUsageInfo() );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
}