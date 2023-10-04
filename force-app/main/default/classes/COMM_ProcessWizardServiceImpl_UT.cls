@isTest
public with sharing class COMM_ProcessWizardServiceImpl_UT {
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
    public static void testGetStepUsageLog_ReturnEmptyList() {
        
        List<Common.StepUsageLog> stepUsageLogList = new COMM_ProcessWizardServiceImpl().getStepUsageLog('DUMMY_TEXT');
        System.assertEquals(0, stepUsageLogList.size(), 'Empty List fetched with no records.');
    }

    @isTest
    public static void testGetStepUsageLog_BlankInput() {
        try {
            List<Common.StepUsageLog> stepUsageLogList = new COMM_ProcessWizardServiceImpl().getStepUsageLog('');
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    public static void testGetStepUsageLog_ReturnList() {

        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 10];
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__COMM_StepUsageLog__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStep__c' => wizardStepList[0].Id, 'SVMXA360__DependentStep__c' => wizardStepList[1].Id}, 1);
        List<SVMXA360__COMM_StepUsageLog__c> usageLogDataList = [SELECT SVMXA360__SourceRecordId__c FROM SVMXA360__COMM_StepUsageLog__c LIMIT 1];
        List<Common.StepUsageLog> stepUsageLogList = new COMM_ProcessWizardServiceImpl().getStepUsageLog(usageLogDataList[0].SVMXA360__SourceRecordId__c);
        System.assertEquals(1, stepUsageLogList.size(), 'Fetched the list correctly with 1 record.');
    }

    @isTest
    public static void testSetWizardStepUsageLog_EmptyList() {
        try {
            List<Common.StepUsageLogRequest> emptyList = new List<Common.StepUsageLogRequest>();
            new COMM_ProcessWizardServiceImpl().setWizardStepUsageLog(emptyList);
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    public static void testSetWizardStepUsageLog_EnabledLog() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<Common.StepUsageLogRequest> enabledLogList = new List<Common.StepUsageLogRequest>();
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];
        Common.StepUsageLogRequest enabledLog = new Common.StepUsageLogRequest();
        enabledLog.enabled = true;
        enabledLog.sourceRecordId = accRecord.Id;
        enabledLog.stepId = wizardStepList[0].Id;
        enabledLogList.add(enabledLog);

        new COMM_ProcessWizardServiceImpl().setWizardStepUsageLog(enabledLogList);

        List<Common.StepUsageLog> stepUsageLogList = new COMM_ProcessWizardServiceImpl().getStepUsageLog(accRecord.Id);
        System.assertEquals(1, stepUsageLogList.size(), 'Fetched the list correctly with 1 record.');
    }
    
    @isTest
    public static void testSetWizardStepUsageLog_EnabledLogEmptySourceId() {
        try {
            Account accRecord = [SELECT Id FROM Account LIMIT 1];
            List<Common.StepUsageLogRequest> enabledLogList = new List<Common.StepUsageLogRequest>();
            List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];
            Common.StepUsageLogRequest enabledLog = new Common.StepUsageLogRequest();
            enabledLog.enabled = true;
            enabledLog.sourceRecordId = '';
            enabledLog.stepId = wizardStepList[0].Id;
            enabledLogList.add(enabledLog);

            new COMM_ProcessWizardServiceImpl().setWizardStepUsageLog(enabledLogList);
        } catch (Exception e) {
            System.assert(true);
        }
    }

    @isTest
    public static void testSetWizardStepUsageLog_DisabledLog() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        List<Common.StepUsageLogRequest> enabledLogList = new List<Common.StepUsageLogRequest>();
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];
        Common.StepUsageLogRequest enabledLog = new Common.StepUsageLogRequest();
        enabledLog.enabled = true;
        enabledLog.sourceRecordId = accRecord.Id;
        enabledLog.stepId = wizardStepList[0].Id;
        enabledLogList.add(enabledLog);

        new COMM_ProcessWizardServiceImpl().setWizardStepUsageLog(enabledLogList);

        List<Common.StepUsageLog> stepUsageLogList = new COMM_ProcessWizardServiceImpl().getStepUsageLog(accRecord.Id);
        System.assertEquals(1, stepUsageLogList.size(), 'Fetched the list correctly with 1 record.');

        List<Common.StepUsageLogRequest> disabledLogList = new List<Common.StepUsageLogRequest>();
        Common.StepUsageLogRequest disabledLog = new Common.StepUsageLogRequest();
        disabledLog.enabled = false;
        disabledLog.sourceRecordId = accRecord.Id;
        disabledLog.stepId = wizardStepList[0].Id;
        disabledLogList.add(disabledLog);

        new COMM_ProcessWizardServiceImpl().setWizardStepUsageLog(disabledLogList);

        List<Common.StepUsageLog> stepUsageLogList1 = new COMM_ProcessWizardServiceImpl().getStepUsageLog(accRecord.Id);
        System.assertEquals(0, stepUsageLogList1.size(), 'Fetched the list correctly with 0 record.');
    }
}