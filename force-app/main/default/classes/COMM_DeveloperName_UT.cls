@IsTest
public class COMM_DeveloperName_UT {
    
    static testMethod void testCreateDeveloperName() {
        
        Test.startTest();
        
        String developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping );
        System.assert(developerName.equalsIgnoreCase( UserInfo.getOrganizationId()+'MAP000001'));
        
        developerName = COMM_DeveloperName.createDeveloperName( Common.Application.Expression );
        System.assert(developerName.equalsIgnoreCase( UserInfo.getOrganizationId()+'EXP000001'));
        
        developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping, 'Create WorkOrder From Case' );
        System.assert(developerName.equalsIgnoreCase('Create_WorkOrder_From_Case' ));
        
        Test.stopTest();
    }
    
    static testMethod void testCreateDeveloperNames() {
        
        Test.startTest();
        
        List<String> developerNames = COMM_DeveloperName.createDeveloperNames( Common.Application.ObjectMapping, 3 );
        System.assert( developerNames.size() == 3 );
        
        System.assert(developerNames.get(0).equalsIgnoreCase( UserInfo.getOrganizationId()+'MAP000001'));
        System.assert(developerNames.get(1).equalsIgnoreCase( UserInfo.getOrganizationId()+'MAP000002'));
        System.assert(developerNames.get(2).equalsIgnoreCase( UserInfo.getOrganizationId()+'MAP000003'));
        
        Test.stopTest();
    }
    
    static testMethod void testCreateDeveloperName_newSequence() {
        
        Test.startTest();
        
        String developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping );
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{'SVMXA360__DeveloperName__c' => developerName });
        
        developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping );
        
        System.assert( developerName != null );
        System.assert(developerName.equalsIgnoreCase( UserInfo.getOrganizationId()+'MAP000002'), developerName );
        
        Test.stopTest();
    }


    static testMethod void testIsDeveloperNameAvailable() {
        String developerName = 'DevName1';

        Boolean result = COMM_DeveloperName.isDeveloperNameAvailable( Common.Application.ProcessWizard, developerName);

        System.assertEquals(true, result, 'The developer name should be available (not in use).');
    }

    static testMethod void testIsDeveloperNameAvailable_ForExistingRecord() {
        String developerName = 'DevName1';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__DeveloperName__c' => developerName} );

        Boolean result = COMM_DeveloperName.isDeveloperNameAvailable( Common.Application.ProcessWizard, developerName);

        System.assertEquals(false, result, 'The developer name should not be available (already in use).');
    }

    /*
    static testMethod void testCreateDeveloperName_WithProcessName() {
        
        Test.startTest();        
        
        String developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping, 'Create WorkOrder From Case' );
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{'SVMXA360__DeveloperName__c' => developerName });
        {
            Long startTime = DateTime.now().getTime();
            Long endTime = DateTime.now().getTime();
            while ((endTime - startTime) < 500) {
                endTime = DateTime.now().getTime();
            }
        }
        
        
        developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping, 'Create WorkOrder From Case' );
        
        System.assert( developerName != null );
        System.assert(developerName.equalsIgnoreCase( 'Create_WorkOrder_From_Case_1'), developerName );
        
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{'SVMXA360__DeveloperName__c' => developerName });
        
        {
            Long startTime = DateTime.now().getTime();
            Long endTime = DateTime.now().getTime();
            while ((endTime - startTime) < 500) {
                endTime = DateTime.now().getTime();
            }
        }
        
        developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping, 'Create WorkOrder From Case' );
        
        System.assert( developerName != null );
        System.assert(developerName.equalsIgnoreCase( 'Create_WorkOrder_From_Case_2'), developerName );
        
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{'SVMXA360__DeveloperName__c' => developerName });
        
        {
            Long startTime = DateTime.now().getTime();
            Long endTime = DateTime.now().getTime();
            while ((endTime - startTime) < 500) {
                endTime = DateTime.now().getTime();
            }
        }
        
        developerName = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping, 'Create WorkOrder From Case' );
        
        System.assert( developerName != null );
        System.assert(developerName.equalsIgnoreCase( 'Create_WorkOrder_From_Case_3'), developerName );
        
        Test.stopTest();
    }*/
}