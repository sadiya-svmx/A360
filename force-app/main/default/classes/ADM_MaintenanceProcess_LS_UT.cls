@isTest
public class ADM_MaintenanceProcess_LS_UT {

    @testSetup static void maintenanceProcessTestData(){
        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__SM_MaintenancePlanProcess__c', 
                                          new Map<String,Object>{'Name' => 'Test Process 1232', 'SVMXA360__SM_Description__c' =>
                                              'Process for unit tests', 'SVMXA360__SM_isActive__c' => true, 'SVMXA360__SM_Standard__c' => false},
                                          2);
        
        Group userGroup = new Group(Name='Group 000001', Type='Queue');
        insert userGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject sampleQueue = new QueueSObject(QueueID = userGroup.id, SObjectType = 'WorkOrder');
            insert sampleQueue;
        }
    }
    
    public static testMethod void testGetProcessList(){
        Test.startTest();
		Common.ServiceResponse response = ADM_MaintenanceProcess_LS.getProcessList();
        List<Adm.MaintenacePlanProcess> processList = (List<Adm.MaintenacePlanProcess>)response.data;

		System.assertEquals(processList.size(), 2);
        Test.stopTest();
    }
    
     public static testMethod void testDeleteProcess(){
        List<SVMXA360__SM_MaintenancePlanProcess__c> processList = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE
                                                                   Name = 'Test Process 1232' LIMIT 1]; 
        Test.startTest();
        System.assertEquals(processList.size(), 1);
 		Common.ServiceResponse response = ADM_MaintenanceProcess_LS.deleteProcess(processList[0].Id);
		System.assertEquals(response.success, true);
        Test.stopTest();
    }
    
    public static testMethod void testDeleteProcess_Invalid(){
        Test.startTest();
        String processId;
 		Common.ServiceResponse response = ADM_MaintenanceProcess_LS.deleteProcess(processId);
		System.assertEquals(response.success, false);
        Test.stopTest();
    }
    
    public static testMethod void testGetSObjectSupportedQueues(){
        Test.startTest();
 		Common.ServiceResponse response = ADM_MaintenanceProcess_LS.getSObjectSupportedQueues('');
		System.assertEquals(response.success, false);
        response = ADM_MaintenanceProcess_LS.getSObjectSupportedQueues('WorkOrder');
		System.assertEquals(response.success, true);
        Test.stopTest();        
    }
    
    public static testMethod void testGetProcessDetails(){
        List<SVMXA360__SM_MaintenancePlanProcess__c> processList = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE
                                                                   Name = 'Test Process 1232' LIMIT 1]; 
        System.assertEquals(processList.size(), 1);

        Test.startTest();
        Common.ServiceResponse response = ADM_MaintenanceProcess_LS.getProcessDetails(processList[0].Id);
		System.assertEquals(response.success, true);
 		response = ADM_MaintenanceProcess_LS.getProcessDetails('');
		System.assertEquals(response.success, false);
        Test.stopTest();       

    }
    
    public static testMethod void testSaveProcessDetails(){
        List<SVMXA360__SM_MaintenancePlanProcess__c> processList = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE
                                                                   Name = 'Test Process 1232' LIMIT 1]; 
        System.assertEquals(processList.size(), 1);
        Common.ServiceResponse response = ADM_MaintenanceProcess_LS.getProcessDetails(processList[0].Id);
		System.assertEquals(response.success, true);
        String requestJson = JSON.serialize(response.data);
        Test.startTest();
        response = ADM_MaintenanceProcess_LS.saveProcessDetails('');
        System.assertEquals(response.success, false);
		response = ADM_MaintenanceProcess_LS.saveProcessDetails(requestJson);
        System.assertEquals(response.success, true);
		Test.stopTest();
    }
    
    public static testMethod void testRunProcessEngine(){
        List<SVMXA360__SM_MaintenancePlanProcess__c> processList = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE
                                                                   Name = 'Test Process 1232' LIMIT 1]; 
        System.assertEquals(processList.size(), 1);

        Test.startTest();
        Common.ServiceResponse response = ADM_MaintenanceProcess_LS.runProcessEngine(new List<String>{processList[0].Id});
		System.assertEquals(response.success, true);
        Test.stopTest();       

    }
    
    public static testMethod void testRunProcessEngine_Invalid(){
        Test.startTest();
        Common.ServiceResponse response = ADM_MaintenanceProcess_LS.runProcessEngine(new List<String>());
		System.assertEquals(response.success, false);
        Test.stopTest();   
    }

}