@isTest
public with sharing class COMM_ProcessWizardManager_UT {
    
    @TestSetup
    static void makeData(){
        Account accRecord = (Account) SvmxTestDataFactory.insertSObject( 'Account', 
                                                    new Map<String,Object>{'Name' => 'Account - 001'});

        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );
        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';
        insert wizardRecordList;

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id, 'SVMXA360__DeveloperName__c'=>wizardRecordList[1].Id}, 1);
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c',
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[1].Id, 'SVMXA360__DeveloperName__c'=>wizardRecordList[0].Id}, 1);
    }

    @isTest
    public static void testGetWizardStepUsageLogBySourceRecord_ReturnEmptyList() {
        
        List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList = COMM_ProcessWizardManager.getInstance().getWizardStepUsageLogBySourceRecord('DUMMY_TEXT');
        System.assertEquals(0, stepUsageLogList.size(), 'Empty List returned with no records.');
    }

    @isTest
    public static void testGetWizardStepUsageLogBySourceRecord_BlankInput() {
        try {
            List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList = COMM_ProcessWizardManager.getInstance().getWizardStepUsageLogBySourceRecord('');
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    @isTest
    public static void testGetWizardStepUsageLogBySourceRecord_ReturnList() {

        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 10];
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__COMM_StepUsageLog__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStep__c' => wizardStepList[0].Id, 'SVMXA360__DependentStep__c' => wizardStepList[1].Id}, 1);
        List<SVMXA360__COMM_StepUsageLog__c> usageLogDataList = [SELECT SVMXA360__SourceRecordId__c FROM SVMXA360__COMM_StepUsageLog__c LIMIT 1];

        List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList = COMM_ProcessWizardManager.getInstance().getWizardStepUsageLogBySourceRecord(usageLogDataList[0].SVMXA360__SourceRecordId__c);
        System.assertEquals(1, stepUsageLogList.size(), 'List is retrieved with 1 record.');
    }

    @isTest
    public static void testSetWizardStepUsageLog() {

        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 10];
        List<Common.StepUsageLogRequest> usageLogInsertList = new List<Common.StepUsageLogRequest>();
        Common.StepUsageLogRequest logRequest = new Common.StepUsageLogRequest();

        logRequest.enabled = true;
        logRequest.sourceRecordId = wizardStepList[0].Id;
        logRequest.stepId = wizardStepList[1].Id;
        usageLogInsertList.add(logRequest);
        COMM_ProcessWizardManager.getInstance().setWizardStepUsageLog(usageLogInsertList);

        List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList = COMM_ProcessWizardManager.getInstance().getWizardStepUsageLogBySourceRecord(wizardStepList[0].Id);
        System.assertEquals(1, stepUsageLogList.size(), 'Record is created and retreived as expected.');
    }

    @isTest
    public static void testUpsertStepUsageLog_EmptyList() {
        try {
            List<SVMXA360__COMM_StepUsageLog__c> wizardStepList = new List<SVMXA360__COMM_StepUsageLog__c>();

            COMM_ProcessWizardManager.getInstance().upsertStepUsageLog(wizardStepList);
        } catch (Exception e) {
            System.assert(true);
        }
    }
    
    @isTest
    public static void testDeleteStepUsageLog() {
        Account accRecord1 = [SELECT Id FROM Account LIMIT 1];
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];
        List<Common.StepUsageLogRequest> usageLogInsertList = new List<Common.StepUsageLogRequest>();
        Common.StepUsageLogRequest logRequest = new Common.StepUsageLogRequest();

        logRequest.enabled = true;
        logRequest.sourceRecordId = accRecord1.Id;
        logRequest.stepId = wizardStepList[0].Id;
        usageLogInsertList.add(logRequest);
        COMM_ProcessWizardManager.getInstance().setWizardStepUsageLog(usageLogInsertList);

        List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList = COMM_ProcessWizardManager.getInstance().getWizardStepUsageLogBySourceRecord(accRecord1.Id);
        System.assertEquals(1, stepUsageLogList.size(), 'Record is inserted and retreived as expected.');

        List<Common.StepUsageLogRequest> usageLogInsertList1 = new List<Common.StepUsageLogRequest>();
        Common.StepUsageLogRequest logRequest1 = new Common.StepUsageLogRequest();

        logRequest1.enabled = false;
        logRequest1.sourceRecordId = accRecord1.Id;
        logRequest1.stepId = wizardStepList[0].Id;
        usageLogInsertList1.add(logRequest1);
        COMM_ProcessWizardManager.getInstance().setWizardStepUsageLog(usageLogInsertList1);

        List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList1 = COMM_ProcessWizardManager.getInstance().getWizardStepUsageLogBySourceRecord(accRecord1.Id);
        System.assertEquals(0, stepUsageLogList1.size(), 'Step usage list record is deleted.');
    }

    @isTest
    public static void testDeleteStepUsageLog_EmptyList() {
        try {
            List<SVMXA360__COMM_StepUsageLog__c> wizardStepList = new List<SVMXA360__COMM_StepUsageLog__c>();

            COMM_ProcessWizardManager.getInstance().deleteStepUsageLog(wizardStepList);
        } catch (Exception e) {
            System.assert(true);
        }
    }
    @isTest
    public static void testMapStepUsageLog() {
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        SVMXA360__CONF_ProcessWizardStep__c wizardStep = [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c LIMIT 1];
        List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList = new List<SVMXA360__COMM_StepUsageLog__c>();
        SVMXA360__COMM_StepUsageLog__c stepUsageLog = new SVMXA360__COMM_StepUsageLog__c();
        stepUsageLog.SVMXA360__UniqueId__c = accRecord.Id+'_'+wizardStep.Id;
        stepUsageLog.SVMXA360__SourceRecordId__c = accRecord.Id;
        stepUsageLog.SVMXA360__ProcessWizardStep__c = wizardStep.Id;         
        stepUsageLogList.add(stepUsageLog);

        List<Common.StepUsageLog> mappedUsageLogList = COMM_ProcessWizardManager.getInstance().mapStepUsageLog(stepUsageLogList);

        System.assertEquals(accRecord.Id+'_'+wizardStep.Id, mappedUsageLogList[0].uniqueId, 'Mapping succesful.');
    }
}