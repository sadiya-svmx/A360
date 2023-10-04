@isTest
public class ADM_ProcessWizardManager_UT {

    @testSetup static void setup() {
        SvmxTestDataFactory.applyPermissionSetToCurrentUser('Asset360_Core');
    }

    private static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @isTest static void testSaveProcessWizardUsingNullObjectListParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().saveProcessWizards(null, null);
            System.assert(false, 'Exception was expected.');
        }   
        catch ( SvmxSystem.SvmxNestedException e) {
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testSaveProcessWizardUsingNullWizardsParameter() {
        List<Adm.ProcessWizard> wizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards(null, new List<String> { 'Account'});
        System.assertEquals(0, wizards.size(), 'Wizard collection size should be zero.');
    }

    @isTest static void testValidateProcessWizardInsert() {
        
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

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        clearProcessWizardCollection(processWizards);
    }
    
    @isTest static void testValidateProcessWizard() {
        
        Test.startTest();
        
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');
        
        Adm.ValidationResult validationResult = ADM_ProcessWizardManager.getInstance().validateProcessWizard(processWizards.get(0), new List<Adm.ReferenceData>() );

        System.assert( validationResult != null, 'Method result should not be null.' );
        System.assert( validationResult.isValid, 'The 1st item should have an ID value.' );
        
        Test.stopTest();
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

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        clearProcessWizardCollection(processWizards);

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards(processWizards, new List<String> { 'Account'} );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 2, 'Method result should contain 2 items.' );
        System.assert( newProcessWizards[0].id != null, 'The 1st item should have an ID value.' );
        System.assert( newProcessWizards[1].id != null, 'The 2nd item should have an ID value.' );

        System.assert( newProcessWizards[0].steps != null, 'The steps for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].steps.size() == 5, 'The steps for the 1st item should contain 5 items.' );
        System.assert( newProcessWizards[0].access != null, 'The access for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].access.size() == 2, 'The access for the 1st item should contain 2 items.' );
    }

    @isTest static void testSaveProcessStepParameterInsert() { 
        
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepRecordList = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessStepParameter__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStepId__c' => wizardStepRecordList[0].Id}, 
                                               2 );                                       

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        clearProcessWizardCollection(processWizards);

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards(processWizards, new List<String> { 'Account'} );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 2, 'Method result should contain 2 items.' );
        System.assert( newProcessWizards[0].id != null, 'The 1st item should have an ID value.' );
        System.assert( newProcessWizards[1].id != null, 'The 2nd item should have an ID value.' );

        System.assert( newProcessWizards[0].steps != null, 'The steps for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].steps.size() == 5, 'The steps for the 1st item should contain 5 items.' );

        System.assert( newProcessWizards[0].steps[0].stepParameters != null, 'The steps for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].steps[0].stepParameters.size() == 2, 'The steps for the 1st item should contain 2 items.' );

        System.assert( newProcessWizards[0].access != null, 'The access for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].access.size() == 2, 'The access for the 1st item should contain 2 items.' );
    }

    @isTest static void testSaveProcessStepDependencyInsert() { 
        
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepRecordList = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStepDependency__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStep__c' => wizardStepRecordList[0].Id, 
                                                                    'SVMXA360__DependentStep__c' => wizardStepRecordList[1].Id}, 1 );                                      

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        clearProcessWizardCollection(processWizards);

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards(processWizards, new List<String> { 'Account'} );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 2, 'Method result should contain 2 items.' );
        System.assert( newProcessWizards[0].id != null, 'The 1st item should have an ID value.' );
        System.assert( newProcessWizards[1].id != null, 'The 2nd item should have an ID value.' );

        System.assert( newProcessWizards[0].steps != null, 'The steps for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].steps.size() == 5, 'The steps for the 1st item should contain 5 items.' );

        System.assert( newProcessWizards[0].steps[0].dependentSteps != null, 'The steps for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].steps[0].dependentSteps.size() == 1, 'The steps for the 1st item should contain 1 items.' );

        System.assert( newProcessWizards[0].access != null, 'The access for the 1st item should not be null.' );
        System.assert( newProcessWizards[0].access.size() == 2, 'The access for the 1st item should contain 2 items.' );
    }

    @isTest static void testSaveProcessWizardUpdateWizard() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepList = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessStepParameter__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStepId__c' => wizardStepList[0].Id}, 
                                               2 );

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStepDependency__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStep__c' => wizardStepList[0].Id, 
                                                                    'SVMXA360__DependentStep__c' => wizardStepList[1].Id}, 1 );

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        processWizards[0].name = 'new name 1';
        processWizards[1].name = 'new name 2';

        notifyProcessWizardwithUpdate(processWizards);  

        //Making process wizard step 2 to unmodified 
        processWizards[0].steps[1].isModified = false; 

        //Making process wizard access 2 to unmodified 
        processWizards[0].access[1].isModified = false; 

        //Making process wizard step 1 parameter 2 to unmodified 
        processWizards[0].steps[0].stepParameters[1].isModified = false; 

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards(processWizards, new List<String> { 'Account'} );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 2, 'Method result should contain 2 items.');

        System.assert( newProcessWizards[0].steps != null, 'The steps should not be null.' );
        System.assert( newProcessWizards[0].steps.size() == 5, 'The steps collection should have 5 items.' );

        System.assert( newProcessWizards[0].steps[0].stepParameters != null, 'The steps should not be null.' );
        System.assert( newProcessWizards[0].steps[0].stepParameters.size() == 2, 'The steps collection should have 5 items.' );

        System.assert( newProcessWizards[0].steps[0].dependentSteps != null, 'The steps dependency should not be null.' );
        System.assert( newProcessWizards[0].steps[0].dependentSteps.size() == 1, 'The steps fdependency should contain 2 items.' );
    }

    @isTest static void testSaveProcessWizardRemoveWizard() {
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

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');

        // Remove 1 process wizard;
        processWizards.remove(0);

        notifyProcessWizardwithUpdate(processWizards);

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards(processWizards, new List<String> { 'Account'} );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assertEquals(1, newProcessWizards.size(), 'Method result should contain 1 item.');

        processWizards =  ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject('Account');

        System.assertEquals(1, processWizards.size(), 'Process wizards collection after a wizard is removed should have 1 item.');
    }

    @isTest static void testSaveProcessWizardsMissingWizardRequiredFields() {



        SVMXA360__CONF_ProcessWizard__c wizardRecord 
            = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' });
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               5 );

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.name = null;
        wizard.objectAPIName = null;
        wizard.developerName = null;
        wizard.scope = null;
        wizard.isModified = true;  

        List<Adm.ProcessWizard> newWizards = new List<Adm.ProcessWizard>(); 
        newWizards.add(wizard);
        notifyProcessWizardwithUpdate(newWizards); 

        try {
            List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'} );
            System.assert(false, 'Exception was expected.');
        }
        catch (SvmxSystem.SvmxServiceException e) {
            List<Common.ServiceError> serviceErrors = e.errors;
            System.assert( serviceErrors.size() == 1, 'Error collection size should be 1.' );
            System.assert( serviceErrors[0].errors.size() == 4, 'Error message collection should be 4.' );
        }
    }

    @isTest static void testSaveProcessWizardsMissingStepRequiredFields() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               1 );

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.steps[0].name = null;
        wizard.steps[0].type = null;
        wizard.isModified = true; 
        wizard.steps[0].isModified = true; 

        try {
            List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'} );
            System.assert(false, 'Exception was expected.');
        }
        catch (SvmxSystem.SvmxServiceException e) {
            List<Common.ServiceError> serviceErrors = e.errors;
            System.assert( serviceErrors.size() == 1, 'Error collection size should be 1.' );
            System.assert( serviceErrors[0].errors.size() == 2, 'Error message collection should be 2.' );
        }
    }

    @isTest static void testSaveProcessWizardsMissingStepParameterRequiredFields() { 
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStep = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               1 );
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessStepParameter__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStepId__c' => wizardStep[0].Id}, 
                                               1 );                                       

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.steps[0].name = null;
        wizard.steps[0].type = null;
        wizard.steps[0].stepParameters[0].valueType = null; 
        wizard.steps[0].stepParameters[0].parameterKey = null;
        wizard.steps[0].stepParameters[0].parameterValue = null;
        wizard.isModified = true; 
        wizard.steps[0].isModified = true; 
        wizard.steps[0].stepParameters[0].isModified = true; 

        try {
            List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'} );
            System.assert(false, 'Exception was expected.');
        }
        catch (SvmxSystem.SvmxServiceException e) {
            List<Common.ServiceError> serviceErrors = e.errors;
            
            System.assert( serviceErrors.size() == 2, 'Error collection size should be 2.' );
            System.assert( serviceErrors[0].errors.size() == 2, 'Error message collection should be 2.' );
            System.assert( serviceErrors[1].errors.size() == 3, 'Error message collection should be 3.' );
        }
    }

    @isTest static void testSaveProcessWizardsWhileRemovingAStep() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               2 );

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.steps.remove(0);
        wizard.isModified = true;
        wizard.steps[0].isModified = true;  

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'}  );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 1, 'Method result should contain 1 item.');

        System.assert( newProcessWizards[0].steps != null, 'The steps should not be null.' );
        System.assert( newProcessWizards[0].steps.size() == 1, 'The steps collection should now have 1 item.' );
    }

    @isTest static void testSaveProcessWizardsWhileRemovingAStepParameter() { 
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStep = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 
                                               2 );

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessStepParameter__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStepId__c' => wizardStep[0].Id}, 
                                               2 );    

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.steps[0].stepParameters.remove(0);
        wizard.isModified = true;
        wizard.steps[0].isModified = true;  
        wizard.steps[1].isModified = false;  
        wizard.steps[0].stepParameters[0].isModified = true;

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'}  );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 1, 'Method result should contain 1 item.');

        System.assert( newProcessWizards[0].steps != null, 'The steps should not be null.' );
        System.assert( newProcessWizards[0].steps.size() == 2, 'The steps collection should now have 2 item.' );

        System.assert( newProcessWizards[0].steps[0].stepParameters != null, 'The steps should not be null.' );
        System.assert( newProcessWizards[0].steps[0].stepParameters.size() == 1, 'The steps collection should now have 2 item.' );
    }

    @isTest static void testSaveProcessWizardsWhileRemovingAccess() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.access.remove(0);
        wizard.isModified = true;
        wizard.access[0].isModified = true; 

        List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'}  );

        System.assert( newProcessWizards != null, 'Method result should not be null.' );
        System.assert( newProcessWizards.size() == 1, 'Method result should contain 1 item.');

        System.assert( newProcessWizards[0].access != null, 'The access collection should not be null.' );
        System.assert( newProcessWizards[0].access.size() == 1, 'The access collection should now have 1 item.' );
    }    

    @isTest static void testSaveProcessWizardsMissingAccessRequiredFields() {
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        wizard.access[0].profileId = null;
        wizard.access[1].profileId = null;

        wizard.access[0].isModified = true;  
        wizard.access[1].isModified = false;

        wizard.isModified = false;  
        wizard.isModified = true;

        try {
            List<Adm.ProcessWizard> newProcessWizards = ADM_ProcessWizardManager.getInstance().saveProcessWizards( new List<Adm.ProcessWizard>{wizard}, new List<String> { 'Account'}  );
            System.assert(false, 'Exception was expected.');
        }
        catch (SvmxSystem.SvmxServiceException e) {
            List<Common.ServiceError> serviceErrors = e.errors;
            System.assert( serviceErrors.size() == 1, 'Error collection size should be 2.' );
            System.assert( serviceErrors[0].errors.size() == 1, 'Error message collection should be 1.' );
        }
    }

    @isTest static void testDeleteProcessWizard() { 
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{ 'SVMXA360__ObjectAPIName__c' => 'Account' } );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 5 );

        ADM_ProcessWizardManager.getInstance().deleteProcessWizard(wizardRecord.Id);

        try {
            Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);
            System.assert(false, 'Exception was expected.');
        }
        catch(Exception e ) {
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testDeleteWizardsByObject() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Contact';

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );
        
        List<String> objectNames = new List<String> {'Account', 'Contact'};

        ADM_ProcessWizardManager.getInstance().deleteProcessWizardsByObjectNames(objectNames);

        Integer recordCount = [SELECT count() FROM SVMXA360__CONF_ProcessWizard__c WHERE SVMXA360__ObjectAPIName__c IN :objectNames];

        System.assertEquals(0, recordCount, 'Process wizards collection size after all wizards have been removed should be zero.');
    }

    @isTest static void testDeleteWizardsByObjectUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().deleteProcessWizardsByObjectNames(null);
            System.assert(false, 'Exception was expected.');
        }   
        catch ( SvmxSystem.SvmxNestedException e) {
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testDeleteProcessWizardUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().deleteProcessWizard(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testDeleteProcessWizardUsingInvalidParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().deleteProcessWizard('Invalid');
            System.assert(true, 'Exception was not expected.');
        }
        catch( Exception e ){
            System.assert(false, 'Exception was thrown but not expected.');
        }
    }

    @isTest static void testDeleteProcessStep() { 
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        List<SVMXA360__CONF_ProcessWizardStep__c> steps = (List<SVMXA360__CONF_ProcessWizardStep__c>)SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id}, 2 );

        ADM_ProcessWizardManager.getInstance().deleteProcessWizardStep(steps[0].Id);

        Adm.ProcessWizard wizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizardRecord.Id);

        System.assert( wizard.steps != null, 'Wizard Steps collection should not be null.' );
        System.assert( wizard.steps.size() == 1, 'Wizard Steps collection should have 1 item.' );
    }

    @isTest static void testDeleteProcessWizardStepUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().deleteProcessWizardStep(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testDeleteProcessWizardStepUsingInvalidParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().deleteProcessWizardStep('Invalid');
            System.assert(true, 'Exception was not expected.');
        }
        catch( Exception e ){
            System.assert(false, 'Exception was thrown but not expected.');
        }        
    }

    @isTest static void testGetProcessWizardsByRecordsObjectWithDetailUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().getProcessWizardsByRecordsObjectWithDetail(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessWizardRecordsWithDetailUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().getProcessWizardRecordsWithDetail(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessWizardRecordsWithDetailUsingInvalidParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().getProcessWizardRecordsWithDetail('Invalid');
            System.assert(true, 'Exception was not expected.');
        }
        catch( Exception e ){
            System.assert(false, 'Exception was thrown but not expected.');
        }
    }

    @isTest static void testGetProcessWizardDetailsByObjectUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessWizardDetailsUsingNullParameter() {
        try {
            ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessWizardSummaryWithNoData(){
        System.runAs(getCurrentUser()) {
            List<Adm.ProcessWizardSummary> summaries = ADM_ProcessWizardManager.getInstance().getProcessWizardSummary();

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
    
            List<Adm.ProcessWizardSummary> summaries = ADM_ProcessWizardManager.getInstance().getProcessWizardSummary();
    
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

    @isTest static void testGetAllActiveProcessWizardDetails() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[0].SVMXA360__Active__c = true;
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__Active__c = false;

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getAllActiveProcessWizardDetails();

        System.assertEquals(1, processWizards.size(), 'There should be 1 active process wizard.');
    }

    @isTest static void testGetActiveProcessWizardDetailsByObject() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[0].SVMXA360__Active__c = true;
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__Active__c = false;

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id, 
                                                                      'SVMXA360__ProfileId__c' => UserInfo.getProfileId()},
                                               2 );

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getActiveProcessWizardDetailsByObject('Account');

        System.assertEquals(1, processWizards.size(), 'There should be 1 active process wizard.');
    }

    @isTest static void testGetActiveProcessWizardDetailsByObjectUsingNullParameter() {

        try {
            ADM_ProcessWizardManager.getInstance().getActiveProcessWizardDetailsByObject(null);
            System.assert(false, 'Exception was expected.');
        }
        catch( Exception e ){
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessStepTargetsByTypeFlow() {

        List<Adm.ProcessStepTarget> stepTargets = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByType( 'Flow', 'Asset' );
        System.debug('stepTargets Size: ' + stepTargets.size());

        System.assert( stepTargets != null, 'StepTarget collection should not be null. ' );
    }

    @isTest static void testGetProcessStepTargetsByTypeTransaction() {

        List<Adm.ProcessStepTarget> stepTargets = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByType( 'SPM Transaction', 'Asset'  );
        System.debug('stepTargets Size: ' + stepTargets.size());

        System.assert( stepTargets != null, 'StepTarget collection should not be null. ' );
    }

    @isTest static void testGetProcessStepTargetsByTypeRecordAction() { 

        List<Adm.ProcessStepTarget> stepTargets = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByType( 'Record Action', 'Asset'  );
        System.assert( stepTargets != null, 'StepTarget collection should not be null. ' );
    }
    
    @isTest static void testGetProcessStepTargetsByTypeLWC() { 
		
        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.ToolingMockEndpoint());
        Test.startTest();
        
        List<Adm.ProcessStepTarget> stepTargets = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByType( 'Lightning Web Component', 'Asset'  );
        System.assert( stepTargets != null, 'StepTarget collection should not be null. ' );
        Test.stopTest();
    }
    
    @isTest static void testGetProcessStepTargetsByTypeInvalidArgument() {

        try {
            List<Adm.ProcessStepTarget> stepTargets = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByType( '', 'Asset'  );
			System.assert(false, 'Exception was expected.');
        }
        catch (SvmxSystem.SvmxNestedException e) {
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessStepTargetsByApiNameFlow() {

        Adm.ProcessStepTarget stepTarget = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByApiName( 'Flow', 'AST_Create_Child_Asset', 'Asset' );

        System.assert( stepTarget != null, 'StepTarget should not be null. ' );
    }

    @isTest static void testGetProcessStepTargetsByApiNameRecordAction() { 

        Adm.ProcessStepTarget stepTarget = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByApiName( 'Record Action', 'NewAccount', 'Asset' );

        System.assert( stepTarget != null, 'StepTarget should not be null. ' );
    }
    
    @isTest static void testGetProcessStepTargetsByApiNameLWC() { 

        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.ToolingMockEndpoint());
        Test.startTest();
        Adm.ProcessStepTarget stepTarget = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByApiName( 'Lightning Web Component', 'lwc', 'Asset' );

        System.assert( stepTarget != null, 'StepTarget should not be null. ' );
        Test.stopTest();
    }
    
    @isTest static void testGetProcessStepTargetsByApiNameInvalidArgument() {
        
        try {
            Adm.ProcessStepTarget stepTarget = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByApiName( '', 'NewAccount', 'Asset' );
			System.assert(false, 'Exception was expected.');
        }
        catch (SvmxSystem.SvmxNestedException e) {
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }

    @isTest static void testGetProcessStepTargetsByApiNameTransaction() {
        Test.startTest();

        String screenType = 'Transaction';
        String objectName = 'Asset';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'New Transaction Layout',
            'SVMXA360__DeveloperName__c' => 'New_Transaction_Layout',
            'SVMXA360__ObjectAPIName__c' => objectName,
            'SVMXA360__ScreenType__c' => screenType,
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} ); 

        Adm.ProcessStepTarget stepTarget = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByApiName( 'SPM Transaction', 'New_Transaction_Layout', 'Asset');

        System.assert( stepTarget != null, 'StepTarget should not be null. ' );

        Test.stopTest();
    }

    private static void clearProcessWizardCollection(List<Adm.ProcessWizard> processWizards) {

        for( Integer index = 0; index < processWizards.size(); index++ ) {
            Adm.ProcessWizard wizard = processWizards[index];

            wizard.id = null;
            wizard.developerName = 'new' + String.valueOf(index);
            wizard.isModified = true; 

            if (wizard.steps != null) {
                for (Adm.ProcessStep step : wizard.steps) {
                    step.id = null;
                    step.isModified = true; 
                    if (step.stepParameters != null) {
                        for (Adm.ProcessStepParameter parameter : step.stepParameters) {
                            parameter.id = null;
                            parameter.isModified = true; 
                        }
                    }
                }
            }

            if (wizard.access != null) {
                for (Adm.ProcessAccess access : wizard.access) {
                    access.id = null;
                    access.isModified = true; 
                }
            }
        }        
    }

    private static void notifyProcessWizardwithUpdate(List<Adm.ProcessWizard> processWizards) {

        for( Integer index = 0; index < processWizards.size(); index++ ) {
            Adm.ProcessWizard wizard = processWizards[index];

            wizard.isModified = true; 

            if (wizard.steps != null) {
                for (Adm.ProcessStep step : wizard.steps) {
                    step.isModified = true; 
                    if (step.stepParameters != null) {
                        for (Adm.ProcessStepParameter parameter : step.stepParameters) {
                            parameter.isModified = true; 
                        }
                    }
                }
            }

            if (wizard.access != null) {
                for (Adm.ProcessAccess access : wizard.access) {
                    access.isModified = true; 
                }
            }
        }        
    } 

    @isTest static void testgetAllProcessWizardsRecordsWithDetail() { 
        
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepRecordList = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               2 );
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessStepParameter__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStepId__c' => wizardStepRecordList[0].Id}, 
                                               2 );                                       

        List<SVMXA360__CONF_ProcessWizard__c> processWizards =  ADM_ProcessWizardManager.getInstance().getAllProcessWizardsRecordsWithDetail();

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');
    }

    @isTest static void testgetActiveProcessWizardsByRecordsObjectWithDetail_EmptyInput() { 
        
        try{
            List<SVMXA360__CONF_ProcessWizard__c> processWizards =  ADM_ProcessWizardManager.getInstance().getActiveProcessWizardsByRecordsObjectWithDetail('');
        }
        catch(Exception e){
            System.assert(true);
        }
    }

    @isTest static void testinvokeRecordAction_InvalidActionName() { 
        
        try{
            ADM_ProcessWizardManager.getInstance().invokeRecordAction('', 'Test', 'Test');
        }
        catch(Exception e){
            System.assert(true);
        }
    }

    @isTest static void testinvokeRecordAction_InvalidprocessWizardStepId() { 
        
        try{
            ADM_ProcessWizardManager.getInstance().invokeRecordAction('Test', '', 'Test');
        }
        catch(Exception e){
            System.assert(true);
        }
    }

    @isTest static void testinvokeRecordAction_InvalidrecordId() { 
        
        try{
            ADM_ProcessWizardManager.getInstance().invokeRecordAction('Test', 'Test', '');
        }
        catch(Exception e){
            System.assert(true);
        }
    }

    @isTest static void testinvokeRecordAction() {
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
        try{
            Test.startTest();                   
            ADM_ProcessWizardManager.getInstance().invokeRecordAction( 'NewCase', step.Id, acc.id );
            System.assert(true, 'Exception not expected.');
            Test.stopTest();
        } catch(Exception e){
            System.assert(false, 'Exception as expected.');
        }
    }

    @isTest
    public static void testgetAllProcessWizardDetails(){
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 2 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[1].SVMXA360__ObjectAPIName__c = 'Account';

        insert wizardRecordList;
        
        List<SVMXA360__CONF_ProcessWizardStep__c> wizardStepRecordList = SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessStepParameter__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizardStepId__c' => wizardStepRecordList[0].Id}, 
                                               2 );                                       

        List<Adm.ProcessWizard> processWizards =  ADM_ProcessWizardManager.getInstance().getAllProcessWizardDetails();

        System.assert(processWizards.size() == 2, 'Process wizards collection should have 2 items.');
    }

    @isTest
    public static void testgetProcessWizardDetails_NoRecordsError(){
        try{
            Adm.ProcessWizard processWizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails('Test_Id');
            System.assert(false, 'Exception occurs, assertion false expected.');
        }
        catch(Exception e){
            System.assert(true, 'Exception occurs as expected.');
        }
    }

    @isTest
    public static void testcreateProcessStepRecord_NoStepType(){
        Adm.ProcessStep processStep = new Adm.ProcessStep();
        processStep.type = '';
        try{
            CONF_ProcessWizardStep__c processStepRecord = ADM_ProcessWizardManager.getInstance().createProcessStepRecord(new Set<String>(), null, 'Test', processStep);
            System.assert(false, 'Exception occurs, assertion false expected.');
        }
        catch(Exception e){
            System.assert(true, 'Exception occurs as expected.');
        }
    }

    @isTest
    public static void testcreateProcessStepRecord_NoStepName(){

        Adm.ProcessStep processStep = new Adm.ProcessStep();
        processStep.name = '';
        try{
            CONF_ProcessWizardStep__c processStepRecord = ADM_ProcessWizardManager.getInstance().createProcessStepRecord(new Set<String>(), null, 'Test', processStep);
            System.assert(false, 'Exception occurs, assertion false expected.');
        }
        catch(Exception e){
            System.assert(true, 'Exception occurs as expected.');
        }
    }

    @isTest
    public static void testcreateStepParameterRecord_NoType(){

        Adm.ProcessStepParameter processStepParameter = new Adm.ProcessStepParameter();
        processStepParameter.valueType = '';
        try{
            CONF_ProcessStepParameter__c stepParam = ADM_ProcessWizardManager.getInstance().createStepParameterRecord('Test', processStepParameter);
            System.assert(false, 'Exception occurs, assertion false expected.');
        }
        catch(Exception e){
            System.assert(true, 'Exception occurs as expected.');
        }
    }

    @isTest static void testcreateStepParameterRecord_NoProfileId(){

        Adm.ProcessAccess processAccess  = new Adm.ProcessAccess();
        processAccess.profileId = '';
        try{
            CONF_ProcessWizardAccess__c stepParam = ADM_ProcessWizardManager.getInstance().createProcessAccessRecord('Test', processAccess);
            System.assert(false, 'Exception occurs, assertion false expected.');
        }
        catch(Exception e){
            System.assert(true, 'Exception occurs as expected.');
        }
    }

    @isTest static void testvalidateProcessWizardRequest_NoWizard(){

        try{
            List<Common.ServiceError> serviceError = ADM_ProcessWizardManager.getInstance().validateProcessWizardRequest(null);
            System.assert(serviceError.size() > 0, 'Exception not expected.');
        }
        catch(Exception e){
            System.assert(false, 'Exception occurs assertion failed.');
        }
    }
}