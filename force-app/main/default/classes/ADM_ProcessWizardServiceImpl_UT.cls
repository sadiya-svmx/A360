@IsTest
public class ADM_ProcessWizardServiceImpl_UT {
    
    @isTest static void testGetAllActiveProcessWizardDetails() {

        Test.startTest();

        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 1 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[0].SVMXA360__Active__c = true;

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        List<Adm.ProcessWizard> processWizards =  new ADM_ProcessWizardServiceImpl().getAllActiveProcessWizardDetails();

        System.assert( processWizards != null );
        System.assert( processWizards.size() == 1 );

        Test.stopTest();
    }

    @isTest static void testSaveProcessWizards() {

        Test.startTest();

        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 1 );

        List<String> objectAPINames = new List<String>();
        objectAPINames.add('Account');

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[0].SVMXA360__Active__c = true;

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        List<Adm.ProcessWizard> processWizards =  new ADM_ProcessWizardServiceImpl().getAllActiveProcessWizardDetails();

        processWizards[0].id = null;
        processWizards[0].developerName = 'newWizard';
        processWizards[0].isModified = true;

        for(Adm.ProcessStep step : processWizards[0].steps){
            step.id = null;
            step.processWizardId = null;
            step.isModified = true;
        }

        for(Adm.ProcessAccess access : processWizards[0].access){
            access.id = null;
            access.name = null;
            access.processWizardId = null;
            access.isModified = true;
        }

        List<Adm.ProcessWizard> newWizards = new ADM_ProcessWizardServiceImpl().saveProcessWizards(processWizards, objectAPINames);
        
        System.assert( newWizards != null );
        System.assert( newWizards[0].id != null );
        System.assert( newWizards[0].steps != null );
        System.assert( newWizards[0].steps.size() == 5 );
        System.assert( newWizards[0].access != null );
        System.assert( newWizards[0].access.size() == 2 );

        Test.stopTest();
    }
}