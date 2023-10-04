@isTest
public class ADM_ProcessWizardLightningService_UT {

    @testSetup static void setup() {
        SvmxTestDataFactory.applyPermissionSetToCurrentUser('Asset360_Core');
    }

    private static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @isTest static void testGetActiveProcessWizardDetailsByObject() {
        System.runAs(getCurrentUser()) {
            List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 3 );

            wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
            wizardRecordList[0].SVMXA360__Active__c = true;
            wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';
            wizardRecordList[1].SVMXA360__Active__c = true;
            wizardRecordList[2].SVMXA360__ObjectAPIName__c = 'Account';
            wizardRecordList[2].SVMXA360__Active__c = false;
    
            insert wizardRecordList;
    
            String userProfileId = UserInfo.getProfileId();

            SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
            new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id, 'SVMXA360__ProfileId__c' => userProfileId}, 
            1 );
            SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
            new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[1].Id, 'SVMXA360__ProfileId__c' => userProfileId}, 
            1 );

            Adm.ProcessWizard wizard = new Adm.ProcessWizard();
            wizard.objectAPIName = 'Account';
    
            Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getActiveProcessWizardDetailsByObject( JSON.serialize( wizard ) );
            System.assert( serviceResponse.success, 'Service Response should be success.' );
            
            List<Adm.ProcessWizard> wizardList = (List<Adm.ProcessWizard>) serviceResponse.data;
            System.debug('WizardList Size: ' + wizardList.size());

            System.assert( wizardList != null, 'Wizard collection should not be null. ' );
            System.assert( wizardList.size() == 2, 'Wizard collection should have 2 active items.' ); 
        }
    }

    @isTest static void testGetActiveProcessWizardDetailsByObjectEmpty() {

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.objectAPIName = 'Account';

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getActiveProcessWizardDetailsByObject( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        List<Adm.ProcessWizard> wizardList = (List<Adm.ProcessWizard>) serviceResponse.data;
        
        System.assert( wizardList != null, 'Service Response data should not be null.' );
        System.assert( wizardList.size() == 0, 'Wizard collection should have no items.' );        
    }

    @isTest static void testGetActiveProcessWizardDetailsByObjectUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getActiveProcessWizardDetailsByObject( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testGetActiveProcessWizardDetailsByObjectUsingNullRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getActiveProcessWizardDetailsByObject( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testGetActiveProcessWizardDetailsByObjectUsingUnknownObjectName() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        request.objectAPIName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( request ) );
        
        List<Adm.ProcessWizard> wizardList = (List<Adm.ProcessWizard>) serviceResponse.data;
        
        System.assert( wizardList != null, 'Service Response data should not be null.' );
        System.assert( wizardList.size() == 0, 'Wizard collection should have no items.' );
    }

    @isTest static void testGetActiveProcessWizardDetailsByObjectUsingNoObjectApiName() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getActiveProcessWizardDetailsByObject( JSON.serialize( request ) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testGetProcessWizardDetailsByObject() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 3 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[2].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.objectAPIName = 'Account';

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        List<Adm.ProcessWizard> wizardList = (List<Adm.ProcessWizard>) serviceResponse.data;
            
        System.assert( wizardList != null, 'Wizard collection should not be null. ' );
        System.assert( wizardList.size() == 3, 'Wizard collection should have 3 items.' ); 
    }

    @isTest static void testGetProcessWizardDetailsByObjectEmpty() {

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.objectAPIName = 'Account';

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        List<Adm.ProcessWizard> wizardList = (List<Adm.ProcessWizard>) serviceResponse.data;
        
        System.assert( wizardList != null, 'Service Response data should not be null.' );
        System.assert( wizardList.size() == 0, 'Wizard collection should have no items.' );        
    }

    @isTest static void testGetProcessWizardDetailsByObjectUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testGetProcessWizardDetailsByObjectUsingNullRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testGetProcessWizardDetailsByObjectUsingUnknownObjectName() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        request.objectAPIName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( request ) );
        
        List<Adm.ProcessWizard> wizardList = (List<Adm.ProcessWizard>) serviceResponse.data;
        
        System.assert( wizardList != null, 'Service Response data should not be null.' );
        System.assert( wizardList.size() == 0, 'Wizard collection should have no items.' );
    }

    @isTest static void testGetProcessWizardDetailsByObjectUsingNoObjectApiName() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( request ) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testGetProcessWizardDetails() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               3 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;
        
        System.assert( wizardResponse != null, 'Service Response data should not be null.' );
        System.assert( wizardResponse.id != null, 'Wizard should have an ID.' );
        System.assert( wizardResponse.steps != null, 'Wizard Steps collection should not be null.' );
        System.assert( wizardResponse.steps.size() == 5, 'Wizard Steps collection should have 5 items.' );
        System.assert( wizardResponse.access != null, 'Wizard Access collection should not be null.' );
        System.assert( wizardResponse.access.size() == 3, 'Wizard Access collection should have 3 items.' );
    }

    @isTest static void testGetProcessWizardDetailsUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testGetProcessWizardDetailsUsingNullRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testGetProcessWizardDetailsUsingInvalidRecordId() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        request.id = 'Invalid';
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( request ) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testGetProcessWizardDetailsUsingNoRecordId() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( request ) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testDeleteProcessWizard() { 
       
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               5 );
        
        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizard( JSON.serialize( wizard ) );
        System.assertEquals( true, serviceResponse.success, 'Success should be true.' );
        
        Common.ServiceResponse newServiceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assertEquals( true, serviceResponse.success, 'Success should be true.' );
        System.assertEquals( null, serviceResponse.data, 'Response data should be null.' );
    }
    
    @isTest static void testDeleteProcessWizardUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizard( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testDeleteProcessWizardUsingNullRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizard( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testDeleteProcessWizardUsingNullRecordId() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();
        request.id = 'Invalid'; 

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizard( JSON.serialize( request ) );
        System.assertEquals( true, serviceResponse.success, 'Success should be true.' );
    }

    @isTest static void testDeleteProcessWizardUsingNoRecordId() { 
        Adm.ProcessWizard request = new Adm.ProcessWizard();

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizard( JSON.serialize( request ) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testDeleteProcessWizardStep() { 
       
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        List<SVMXA360__CONF_ProcessWizardStep__c> steps = (List<SVMXA360__CONF_ProcessWizardStep__c>)SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               2 );
        
        Adm.ProcessStep step = new Adm.ProcessStep();
        step.id = steps[0].Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardStep( JSON.serialize( step )) ;
        System.assert(serviceResponse.success, 'Success should be true.');
        
        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;

        Common.ServiceResponse newServiceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert(newServiceResponse.success == true, 'Success should be true.');

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) newServiceResponse.data;

        System.assert( wizardResponse.steps != null, 'Wizard Steps collection should not be null.' );
        System.assert( wizardResponse.steps.size() == 1, 'Wizard Steps collection should have 1 item.' );       
    }
    
    @isTest static void testDeleteProcessWizardStepUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardStep( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testDeleteProcessWizardStepUsingNullRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardStep( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testDeleteProcessWizardStepUsingNullRecordId() { 
        Adm.ProcessStep request = new Adm.ProcessStep();
        request.id = 'Invalid'; 

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardStep( JSON.serialize(request) );
        System.assertEquals( true, serviceResponse.success, 'Success should be true.' );
    }

    @isTest static void testDeleteProcessWizardStepUsingNoRecordId() { 
        Adm.ProcessStep request = new Adm.ProcessStep();

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardStep( JSON.serialize(request) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testSaveProcessWizardInsert() { 
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.objectAPIName = 'Account';
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize(wizard) );

        List<Adm.ProcessWizard> processWizards = (List<Adm.ProcessWizard>)serviceResponse.data;

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        clearProcessWizardCollection(processWizards);

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = processWizards;
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize(request) );
        
        List<Adm.ProcessWizard> newProcessWizards = (List<Adm.ProcessWizard>)saveResponse.data;
        
        System.assertEquals(true, saveResponse.success, 'The response should be equal to success.');
        System.assertNotEquals( null, newProcessWizards, 'Method result should not be null.' );
        System.assertEquals( 2, newProcessWizards.size(), 'Method result should contain 2 items.' );
        System.assertNotEquals( null, newProcessWizards[0].id, 'The 1st item should have an ID value.' );
        System.assertNotEquals( null, newProcessWizards[1].id, 'The 2nd item should have an ID value.' );

        System.assertNotEquals( null, newProcessWizards[0].steps, 'The steps for the 1st item should not be null.' );
        System.assertEquals( 5, newProcessWizards[0].steps.size(), 'The steps for the 1st item should contain 5 items.' );
        System.assertNotEquals( null, newProcessWizards[0].access, 'The access for the 1st item should not be null.' );
        System.assertEquals( 2, newProcessWizards[0].access.size(), 'The access for the 1st item should contain 2 items.' );
    }

    @isTest static void testSaveProcessWizardUpdate() { 
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.objectAPIName = 'Account';

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize(wizard) );

        List<Adm.ProcessWizard> processWizards = (List<Adm.ProcessWizard>)serviceResponse.data;

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        processWizards[0].name = 'new name 1';
        processWizards[1].name = 'new name 2';

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = processWizards;
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize(request) );
        
        List<Adm.ProcessWizard> newProcessWizards = (List<Adm.ProcessWizard>)saveResponse.data;
        
        System.assertEquals( true, saveResponse.success, 'The response should be equal to success.');
        System.assertNotEquals( null, newProcessWizards, 'Method result should not be null.' );
        System.assertEquals( 2, newProcessWizards.size(), 'Method result should contain 2 items.' );
        System.assertNotEquals( null, newProcessWizards[0].id, 'The 1st item should have an ID value.' );
        System.assertNotEquals( null, newProcessWizards[1].id, 'The 2nd item should have an ID value.' );

        System.assertNotEquals( null, newProcessWizards[0].steps, 'The steps for the 1st item should not be null.' );
        System.assertEquals( 5, newProcessWizards[0].steps.size(), 'The steps for the 1st item should contain 5 items.' );
        System.assertNotEquals( null, newProcessWizards[0].access, 'The access for the 1st item should not be null.' );
        System.assertEquals( 2, newProcessWizards[0].access.size(), 'The access for the 1st item should contain 2 items.' );
    }

    @isTest static void testSaveProcessWizardUsingNullParameter() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.saveProcessWizards( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testSaveProcessWizardUsingEmptyParameter() {
        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = null;
        request.objectAPINames = new List<String>();

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize(request) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );

        request.objectAPINames = null;
        serviceResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize(request) );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testSaveProcessWizardUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.saveProcessWizards( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testSaveProcessWizardMissingWizardRequiredFields() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               5 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;        

        wizardResponse.name = null;
        wizardResponse.objectAPIName = null;
        wizardResponse.developerName = null;
        wizardResponse.scope = null;
        wizardResponse.isModified = true;
        wizardResponse.referenceId = wizardResponse.id;

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = new List<Adm.ProcessWizard> { wizardResponse };
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize( request ) );

        System.assertEquals( false, saveResponse.success, 'Success should be false.' );
        System.assertEquals( false, String.isBlank(saveResponse.message), 'Response message should not be blank.' );
        System.assertNotEquals( null, saveResponse.errors, 'Response errors should not be null.' );
        System.assertEquals( 1, saveResponse.errors.size(), 'Response errors should contain 1 item.' );
        System.assertEquals( wizardResponse.id, saveResponse.errors[0].referenceId, 'Response error reference id should be equal to value passed into the method argument.' );
        System.assertEquals( 4, saveResponse.errors[0].errors.size(), 'Response errors item should contain 4 messages.' );
    }

    @isTest static void testSaveProcessWizardMissingStepRequiredFields() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               5 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;        

        String refId = wizardResponse.steps[0].id;

        wizardResponse.steps[0].name = null;
        wizardResponse.steps[0].type = null;
        wizardResponse.steps[0].isModified = true;
        wizardResponse.steps[0].referenceId = refId;

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = new List<Adm.ProcessWizard> { wizardResponse };
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize( request ) );

        System.assertEquals( false, saveResponse.success, 'Success should be false.' );
        System.assertEquals( false, String.isBlank(saveResponse.message), 'Response message should not be blank.' );
        System.assertNotEquals( null, saveResponse.errors, 'Response errors should not be null.' );
        System.assertEquals( 1, saveResponse.errors.size(), 'Response errors should contain 1 item.' );
        System.assertEquals( refId, saveResponse.errors[0].referenceId, 'Response error reference id should be equal to value passed into the method argument.' );
        System.assertEquals( 2, saveResponse.errors[0].errors.size(), 'Response errors item should contain 2 messages.' );
    }

    @isTest static void testSaveProcessWizardMissingStepRequiredTargetField() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               5 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;        

        String refId = wizardResponse.steps[0].id;

        wizardResponse.steps[0].target = null;
        wizardResponse.steps[0].isModified = true;
        wizardResponse.steps[0].referenceId = refId;

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = new List<Adm.ProcessWizard> { wizardResponse };
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize( request ) );

        System.assertEquals(false, saveResponse.success, 'Success should be false.' );
        System.assertEquals( false, String.isBlank(saveResponse.message), 'Response message should not be blank.' );
        System.assertNotEquals(null, saveResponse.errors, 'Response errors should not be null.' );
        System.assertEquals( 1, saveResponse.errors.size(), 'Response errors should contain 1 item.' );
        System.assertEquals( refId, saveResponse.errors[0].referenceId, 'Response error reference id should be equal to value passed into the method argument.' );
        System.assertEquals( 1, saveResponse.errors[0].errors.size(), 'Response errors item should contain 1 message.' );
    }

    @isTest static void testSaveProcessWizardMissingAccessRequiredFields() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;        

        String refId = wizardResponse.id;

        wizardResponse.access[0].profileId = null;
        wizardResponse.access[1].profileId = null;
        wizardResponse.referenceId = refId;

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = new List<Adm.ProcessWizard> { wizardResponse };
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize( request ) );

        System.assertEquals( false, saveResponse.success, 'Success should be false.' );
        System.assertEquals( false, String.isBlank(saveResponse.message), 'Response message should not be blank.' );
        System.assertNotEquals( null, saveResponse.errors, 'Response errors should not be null.' );
        System.assertEquals( 1, saveResponse.errors.size(), 'Response errors should contain 1 item.' );
        System.assertEquals( refId, saveResponse.errors[0].referenceId, 'Response error reference id should be equal to value passed into the method argument.' );
        System.assertEquals( 1, saveResponse.errors[0].errors.size(), 'Response errors item should contain 1 message.' );
    }

    @isTest static void testSaveProcessWizardWhileRemovingAStep() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               2 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;        
        wizardResponse.steps.remove(0);

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = new List<Adm.ProcessWizard> { wizardResponse };
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize( request ) );
        
        List<Adm.ProcessWizard> newProcessWizards = (List<Adm.ProcessWizard>)saveResponse.data;

        System.assertNotEquals( null, newProcessWizards, 'Method result should not be null.' );
        System.assertEquals( 1, newProcessWizards.size(), 'Method result should contain 1 item.');

        System.assertNotEquals( null, newProcessWizards[0].steps, 'The steps should not be null.' );
        System.assertEquals( 1, newProcessWizards[0].steps.size(), 'The steps collection should now have 1 item.' );
    }

    @isTest static void testSaveProcessWizardWhileRemovingAccess() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.id = wizardRecord.Id;
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetails( JSON.serialize( wizard ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );

        Adm.ProcessWizard wizardResponse = (Adm.ProcessWizard) serviceResponse.data;        
        wizardResponse.access.remove(0);

        Adm.ProcessWizardSaveRequest request = new Adm.ProcessWizardSaveRequest();
        request.wizards = new List<Adm.ProcessWizard> { wizardResponse };
        request.objectAPINames = new List<String> { 'Account' };

        Common.ServiceResponse saveResponse = ADM_ProcessWizardLightningService.saveProcessWizards( JSON.serialize( request ) );
        
        List<Adm.ProcessWizard> newProcessWizards = (List<Adm.ProcessWizard>)saveResponse.data;

        System.assertNotEquals( null, newProcessWizards, 'Method result should not be null.' );
        System.assertEquals( 1, newProcessWizards.size(), 'Method result should contain 1 item.');

        System.assertNotEquals( null, newProcessWizards[0].access, 'The steps should not be null.' );
        System.assertEquals( 1, newProcessWizards[0].access.size(), 'The steps collection should now have 1 item.' );
    }

    @isTest static void testGetProcessWizardSummaryWithNoData(){
        System.runAs(getCurrentUser()) {
            Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardSummary();
            System.assert( serviceResponse.success, 'Service Response should be success.' );
    
            List<Adm.ProcessWizardSummary> summaries = (List<Adm.ProcessWizardSummary>) serviceResponse.data;
    
            System.assertNotEquals( null, summaries, 'Summaries should not be null' );
            System.assertEquals( 0, summaries.size(), 'Summaries count should be zero.' );
        }
    }

    @isTest static void testGetProcessWizardSummary(){
        System.runAs(getCurrentUser()) {
            List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 3 );

            wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
            wizardRecordList[0].SVMXA360__Active__c = true;
    
            wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Contact';
            wizardRecordList[1].SVMXA360__Active__c = false;
    
            wizardRecordList[2].SVMXA360__ObjectAPIName__c = 'Opportunity';
            wizardRecordList[2].SVMXA360__Active__c = true;
    
            insert wizardRecordList;
    
            Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessWizardSummary();
            System.assert( serviceResponse.success, 'Service Response should be success.' );
            
            List<Adm.ProcessWizardSummary> summaries = (List<Adm.ProcessWizardSummary>) serviceResponse.data;
    
            System.assertNotEquals( null, summaries, 'Summaries should not be null' );
            System.assertEquals( 3, summaries.size(), 'Summaries shoudl contain 3 items.' );
    
            System.assertEquals(1, summaries[0].activeWizards, 'Account Active Wizards count should be 1.');
            System.assertEquals(0, summaries[0].inactiveWizards, 'Account Inactive Wizards count should be 0.');
            System.assertEquals(0, summaries[1].activeWizards, 'Contact Active Wizards count should be 0.');
            System.assertEquals(1, summaries[1].inactiveWizards, 'Contact Inactive Wizards count should be 1.');
            System.assertEquals(1, summaries[2].activeWizards, 'Opportunity Active Wizards count should be 1.');
            System.assertEquals(0, summaries[2].inactiveWizards, 'Opportunity Inactives Wizards count should be 0.');
    
            System.assertEquals('Account', summaries[0].objectAPIName, 'Object API Name should be Account.');
            System.assertNotEquals(null, summaries[0].lastModifiedDate, 'Account Last Modified Date should not be null.');
            System.assertNotEquals(null, summaries[0].lastModifiedBy, 'Account Last Modified By should not be null.');
    
            System.assertEquals('Contact', summaries[1].objectAPIName, 'Object API Name should be Contact.');
            System.assertNotEquals(null, summaries[1].lastModifiedDate, 'Contact Last Modified Date should not be null.');
            System.assertNotEquals(null, summaries[1].lastModifiedBy, 'Contact Last Modified By should not be null.');
    
            System.assertEquals('Opportunity', summaries[2].objectAPIName, 'Object API Name should be Opportunity.');
            System.assertNotEquals(null, summaries[2].lastModifiedDate, 'Opportunity Last Modified Date should not be null.');
            System.assertNotEquals(null, summaries[2].lastModifiedBy, 'Opportunity Last Modified By should not be null.');
        }

    }


    @isTest static void testDeleteProcessWizardsByObjectNames() { 
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Contact';

        insert wizardRecordList;

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );

        List<String> objectNames = new List<String> {'Account', 'Contact'};
        
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardsByObjectNames( JSON.serialize( objectNames ) );
        System.assertEquals( true, serviceResponse.success, 'Success should be true.' );

        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        wizard.objectAPIName = 'Account';

        Common.ServiceResponse accountServiceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( wizard ) );
        System.assertEquals( true, accountServiceResponse.success, 'Success should be true.' );
        System.assertEquals( new List<Adm.ProcessWizard>(), accountServiceResponse.data, 'Response data should be empty list.' );

        wizard.objectAPIName = 'Contact';

        Common.ServiceResponse contactServiceResponse = ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject( JSON.serialize( wizard ) );
        System.assertEquals( true, contactServiceResponse.success, 'Success should be true.' );
        System.assertEquals( new List<Adm.ProcessWizard>(), contactServiceResponse.data, 'Response data should be empty list.' );

    }
    
    @isTest static void testDeleteProcessWizardsByObjectNamesUsingInvalidRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardsByObjectNames( '{"}' );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }
    
    @isTest static void testDeleteProcessWizardsByObjectNamesUsingNullRequestJson() { 
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardsByObjectNames( null );
        System.assertEquals( false, serviceResponse.success, 'Success should be false.' );
    }

    @isTest static void testDeleteProcessWizardsByObjectNamesUsingInvalidObjectName() { 
        List<String> request = new List<String> { 'Invalid'};

        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.deleteProcessWizardsByObjectNames( JSON.serialize( request ) );
        System.assertEquals( true, serviceResponse.success, 'Success should be true.' );
    }

    @isTest static void testGetProcessStepTargetsByTypeFlow() {
        Map<String, Object> params = new Map<String, Object>{
            'stepTypeName' => 'Flow',
            'objectApiName' => 'Asset'
        };
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessStepTargetsByType( JSON.serialize( params ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        List<Adm.ProcessStepTarget> stepTargets = (List<Adm.ProcessStepTarget>) serviceResponse.data;
        System.debug('stepTargets Size: ' + stepTargets.size());

        System.assert( stepTargets != null, 'StepTarget collection should not be null. ' );
    }

    @isTest static void testGetProcessStepTargetsByTypeTransaction() {
        Map<String, Object> params = new Map<String, Object>{
            'stepTypeName' => 'SPM Transaction',
            'objectApiName' => 'Asset'
        };
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessStepTargetsByType( JSON.serialize( params ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        List<Adm.ProcessStepTarget> stepTargets = (List<Adm.ProcessStepTarget>) serviceResponse.data;
        System.debug('stepTargets Size: ' + stepTargets.size());

        System.assert( stepTargets != null, 'StepTarget collection should not be null. ' );
    }

    @isTest static void testGetProcessStepTargetsByApiNameFlow() {
        Map<String, Object> params = new Map<String, Object>{
            'stepTypeName' => 'Flow',
            'objectApiName' => 'Asset',
            'targetApiName' => 'AST_Create_Child_Asset'
        };
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessStepTargetsByApiName( JSON.serialize( params ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        Adm.ProcessStepTarget stepTarget = (Adm.ProcessStepTarget) serviceResponse.data;

        System.assert( stepTarget != null, 'StepTarget should not be null. ' );
    }

    @isTest static void testGetProcessStepTargetsByApiNameTransaction() {
        Test.startTest();

        String screenType = 'Transaction';
        String objectName = 'Asset';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'New Transaction Layout',
            'SVMXA360__DeveloperName__c' => 'New_Transaction_Layout',
            'SVMXA360__ObjectAPIName__c' => objectName,
            'SVMXA360__ScreenType__c' => screenType} ); 

        Map<String, Object> params = new Map<String, Object>{
            'stepTypeName' => 'Transaction',
            'targetApiName' => 'New_Transaction_Layout',
            'objectApiName' => 'Asset'
        };
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.getProcessStepTargetsByApiName( JSON.serialize( params ) );
        System.assert( serviceResponse.success, 'Service Response should be success.' );
        
        Adm.ProcessStepTarget stepTarget = (Adm.ProcessStepTarget) serviceResponse.data;

        System.assert( stepTarget != null, 'StepTarget should not be null. ' );

        Test.stopTest();
    }

    @isTest static void testinvokeRecordActionWithParamValueAsValue() {
        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.ToolingMockEndpoint());

        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SVMXA360__CONF_ProcessWizardStep__c step = (SVMXA360__CONF_ProcessWizardStep__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizardStep__c', new Map<String,Object>{   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                        'SVMXA360__Target__c'=>'NewCase',
                        'SVMXA360__Type__c'=>'Record Action'
                    });
        SVMXA360__CONF_ProcessStepParameter__c param = (SVMXA360__CONF_ProcessStepParameter__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessStepParameter__c', new Map<String,Object>{
                                                'SVMXA360__ProcessWizardStepId__c' => step.Id,
                                                'SVMXA360__ParameterKey__c'=>'Subject',
                                                'SVMXA360__ParameterValue__c'=>'Test case',
                                                'SVMXA360__ValueType__c'=>'Value'
                                            }
                                             );
        Account acc = (Account) SvmxTestDataFactory.insertSObject( 'Account'); 
        Test.startTest();                           
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.invokeRecordAction( 'NewCase', step.Id, acc.id );
        System.assert(serviceResponse.success, 'Service Response should be success.');
        Test.stopTest();
    }

    @isTest static void testinvokeRecordActionWithParamValueAsField() {
        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.ToolingMockEndpoint());

        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SVMXA360__CONF_ProcessWizardStep__c step = (SVMXA360__CONF_ProcessWizardStep__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizardStep__c', new Map<String,Object>{   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                        'SVMXA360__Target__c'=>'NewCase',
                        'SVMXA360__Type__c'=>'Record Action'
                    });
        SVMXA360__CONF_ProcessStepParameter__c param = (SVMXA360__CONF_ProcessStepParameter__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessStepParameter__c', new Map<String,Object>{
                                                'SVMXA360__ProcessWizardStepId__c' => step.Id,
                                                'SVMXA360__ParameterKey__c'=>'Subject',
                                                'SVMXA360__ParameterValue__c'=>'Name',
                                                'SVMXA360__ValueType__c'=>'Field'
                                            }
                                             );
        Account acc = (Account) SvmxTestDataFactory.insertSObject( 'Account',  new Map<String,Object>{   'Name' => 'Some Test name'
                    });
        Test.startTest();                      
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.invokeRecordAction( 'NewCase', step.Id, acc.id );
        System.assert(serviceResponse.success, 'Service Response should be success.');
        Test.stopTest();
    }

    @isTest static void testinvokeRecordActionWithMissingParams() {
        Test.startTest();
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SVMXA360__CONF_ProcessWizardStep__c step = (SVMXA360__CONF_ProcessWizardStep__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizardStep__c', new Map<String,Object>{   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                        'SVMXA360__Target__c'=>'NewCase',
                        'SVMXA360__Type__c'=>'Record Action'
                    });
        SVMXA360__CONF_ProcessStepParameter__c param = (SVMXA360__CONF_ProcessStepParameter__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessStepParameter__c', new Map<String,Object>{
                                                'SVMXA360__ProcessWizardStepId__c' => step.Id,
                                                'SVMXA360__ParameterKey__c'=>'Subject',
                                                'SVMXA360__ParameterValue__c'=>'Test case',
                                                'SVMXA360__ValueType__c'=>'Value'
                                            }
                                             );
        Account acc = (Account) SvmxTestDataFactory.insertSObject( 'Account');                            
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.invokeRecordAction( null, step.Id, acc.id );
        System.assert( !serviceResponse.success, 'Service Response should be failure.' );
        Test.stopTest();
    }


    @isTest static void testinvokeRecordActionWithInvalidActionName() {
        Test.startTest();
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SVMXA360__CONF_ProcessWizardStep__c step = (SVMXA360__CONF_ProcessWizardStep__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizardStep__c', new Map<String,Object>{   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                        'SVMXA360__Target__c'=>'nameSomeAction',
                        'SVMXA360__Type__c'=>'Record Action'
                    });
        SVMXA360__CONF_ProcessStepParameter__c param = (SVMXA360__CONF_ProcessStepParameter__c)SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessStepParameter__c', new Map<String,Object>{
                                                'SVMXA360__ProcessWizardStepId__c' => step.Id,
                                                'SVMXA360__ParameterKey__c'=>'Subject',
                                                'SVMXA360__ParameterValue__c'=>'Test case',
                                                'SVMXA360__ValueType__c'=>'Value'
                                            }
                                             );
        Account acc = (Account) SvmxTestDataFactory.insertSObject( 'Account');                            
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardLightningService.invokeRecordAction( null, step.Id, acc.id );
        System.assert( !serviceResponse.success, 'Service Response should be failure.' );
        Test.stopTest();
    }


    private static void clearProcessWizardCollection(List<Adm.ProcessWizard> processWizards) {

        for( Integer index = 0; index < processWizards.size(); index++ ) {
            Adm.ProcessWizard wizard = processWizards[index];

            wizard.id = null;
            wizard.isModified = true;
            wizard.developerName = 'new' + String.valueOf(index);

            if (wizard.steps != null) {
                for (Adm.ProcessStep step : wizard.steps) {
                    step.id = null;
                    wizard.isModified = true;
                }
            }

            if (wizard.access != null) {
                for (Adm.ProcessAccess access : wizard.access) {
                    access.id = null;
                    wizard.isModified = true;
                }
            }
        }        
    }
}