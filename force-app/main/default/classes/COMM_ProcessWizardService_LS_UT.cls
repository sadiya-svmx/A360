@isTest
public with sharing class COMM_ProcessWizardService_LS_UT {
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
        Common.ServiceResponse response = COMM_ProcessWizardService_LS.getStepUsageLogBySourceRecordId('DUMMY_TEXT');
        System.assertEquals(response.success, true, 'Status is success.');
    }

    @isTest
    public static void testGetStepUsageLogBySourceRecordId_BlankInput() {
        Common.ServiceResponse response = COMM_ProcessWizardService_LS.getStepUsageLogBySourceRecordId('');
        System.assertEquals(response.success, false, 'Status is fail.');
    }

    @isTest
    public static void testGetStepUsageLogBySourceRecordId_ReturnList() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];

        Common.StepUsageLogRequest jsonReq = new Common.StepUsageLogRequest();

        jsonReq.enabled= true;
        jsonReq.sourceRecordId = accRecord.Id;
        jsonReq.stepId = wizardStepList[0].Id;

        Common.ServiceResponse response = COMM_ProcessWizardService_LS.setWizardStepUsageLog(JSON.serialize(jsonReq));
        System.assertEquals(response.success, true, 'Step usage log record inserted.');

        Common.ServiceResponse response1 = COMM_ProcessWizardService_LS.getStepUsageLogBySourceRecordId(accRecord.Id);
        System.assertEquals(response1.success, true, 'Step usage log record fetched.');
    }

    @isTest
    public static void testSetWizardStepUsageLog_EmptyJSONRequest() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];

        Common.ServiceResponse response = COMM_ProcessWizardService_LS.setWizardStepUsageLog('');
        System.assertEquals(response.success, false, 'Step usage log record inserted.');
    }
}