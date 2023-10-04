@isTest
public with sharing class COMM_ProcessWizardService_UT {
    @TestSetup
    static void makeData(){
        Account accRecord = (Account) SvmxTestDataFactory.insertSObject( 'Account', 
                                                    new Map<String,Object>{'Name' => 'Account - 001'});

        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );
        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';
        insert wizardRecordList;

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id, 'SVMXA360__DeveloperName__c'=>wizardRecordList[0].Id}, 1);
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[1].Id, 'SVMXA360__DeveloperName__c'=>wizardRecordList[1].Id}, 1);
    }

    @isTest
    public static void testGetStepUsageLogBySourceRecordId_ReturnEmptyList() {
        Common.ServiceResponse response = new COMM_ProcessWizardService().getStepUsageLogBySourceRecordId('DUMMY_TEXT');
        System.assertEquals(response.success, true, 'Status is success.');
    }

    @isTest
    public static void testGetStepUsageLogBySourceRecordId_BlankInput() {
        Common.ServiceResponse response = new COMM_ProcessWizardService().getStepUsageLogBySourceRecordId('');
        System.assertEquals(response.success, false, 'Status is fail.');
    }

    @isTest
    public static void testGetStepUsageLogBySourceRecordId_ReturnList() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];

        List<Common.StepUsageLogRequest> stepUsageLogList = new List<Common.StepUsageLogRequest> ();
        Common.StepUsageLogRequest stepUsageLog = new Common.StepUsageLogRequest();
        stepUsageLog.enabled = true;
        stepUsageLog.sourceRecordId = accRecord.Id;
        stepUsageLog.stepId = wizardStepList[0].Id;
        stepUsageLogList.add(stepUsageLog);
        
        Common.ServiceResponse response = new COMM_ProcessWizardService().setWizardStepUsageLog(stepUsageLogList);
        System.assertEquals(response.success, true, 'Step usage log record inserted.');

        Common.ServiceResponse response1 = new COMM_ProcessWizardService().getStepUsageLogBySourceRecordId(accRecord.Id);
        System.assertEquals(response1.success, true, 'Success response.');
        System.assertNotEquals(null, response1.data, 'Fetched 1 record.');
    }

    @isTest
    public static void testSetWizardStepUsageLog_EmptySourceId() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];

        List<Common.StepUsageLogRequest> stepUsageLogList = new List<Common.StepUsageLogRequest> ();
        Common.StepUsageLogRequest stepUsageLog = new Common.StepUsageLogRequest();
        stepUsageLog.enabled = true;
        stepUsageLog.sourceRecordId = '';
        stepUsageLog.stepId = wizardStepList[0].Id;
        stepUsageLogList.add(stepUsageLog);
        
        Common.ServiceResponse response = new COMM_ProcessWizardService().setWizardStepUsageLog(stepUsageLogList);
        System.assertEquals(response.success, false, 'Step usage log record failed to insert.');

        Common.ServiceResponse response1 = new COMM_ProcessWizardService().getStepUsageLogBySourceRecordId(accRecord.Id);
        System.assertEquals(response1.success, true, 'Success response.');
        System.assertNotEquals(null, response1.data, 'Fetched 0 record.');
    }
}