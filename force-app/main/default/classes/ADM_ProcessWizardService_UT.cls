@IsTest
public class ADM_ProcessWizardService_UT {
    
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

        Common.ServiceResponse serviceResponse = new ADM_ProcessWizardService().getAllActiveProcessWizardDetails();
        System.assert(serviceResponse.success);
        
        List<Adm.ProcessWizard> processWizards = (List<Adm.ProcessWizard>) serviceResponse.data;

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

        Common.ServiceResponse serviceResponse = new ADM_ProcessWizardService().getAllActiveProcessWizardDetails();
        System.assert(serviceResponse.success);
        
        List<Adm.ProcessWizard> processWizards = (List<Adm.ProcessWizard>) serviceResponse.data;

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

        Common.ServiceResponse newServiceResponse = new ADM_ProcessWizardService().saveProcessWizards(processWizards, objectAPINames);
        System.assert(newServiceResponse.success);
        
        List<Adm.ProcessWizard> newWizards = (List<Adm.ProcessWizard>) newServiceResponse.data;
        
        System.assert( newWizards != null );
        System.assert( newWizards[0].id != null );
        System.assert( newWizards[0].steps != null );
        System.assert( newWizards[0].steps.size() == 5 );
        System.assert( newWizards[0].access != null );
        System.assert( newWizards[0].access.size() == 2 );

        Test.stopTest();
    }
    
    @isTest static void testValidateProcessWizard() {

        Test.startTest();

        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 1);

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

        Common.ServiceResponse serviceResponse = new ADM_ProcessWizardService().getAllActiveProcessWizardDetails();
        System.assert(serviceResponse.success);
        
        List<Adm.ProcessWizard> processWizards = (List<Adm.ProcessWizard>) serviceResponse.data;

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
        
		final Adm.WizardValidationRequest request = new Adm.WizardValidationRequest();
        request.processWizard = processWizards.get(0);
        request.referenceDatas = new List<Adm.ReferenceData>();
        
        Common.ServiceResponse newServiceResponse = new ADM_ProcessWizardService().validateProcessWizard( request );
        System.assert(newServiceResponse.success);

        Test.stopTest();
    }

    @isTest static void testSaveProcessWizards_NoWizard() {
        List<Adm.ProcessWizard> processWizards = new List<Adm.ProcessWizard>();
        List<String> objectAPINames = new List<String>();

        try{
            Test.startTest();
            Common.ServiceResponse newServiceResponse = new ADM_ProcessWizardService().saveProcessWizards(processWizards, objectAPINames);
            Test.stopTest();
        } catch(Exception e){
            System.assert(true);
        }    
    }
    
    @isTest static void testSaveProcessWizards_NoObjectNames() {
        List<Adm.ProcessWizard> processWizards = new List<Adm.ProcessWizard>();
        Adm.ProcessWizard processWizard = new Adm.ProcessWizard();

        processWizard.id = null;
        processWizard.developerName = 'newWizard';
        processWizard.isModified = true;
        processWizards.add(processWizard);

        List<String> objectAPINames = new List<String>();

        try{
            Test.startTest();
            Common.ServiceResponse newServiceResponse = new ADM_ProcessWizardService().saveProcessWizards(processWizards, objectAPINames);
            Test.stopTest();
        } catch(Exception e){
            System.assert(true);
        }    
    }
}