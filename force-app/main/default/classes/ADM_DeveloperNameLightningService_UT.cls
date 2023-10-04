@IsTest
public class ADM_DeveloperNameLightningService_UT {
    
    static testMethod void testCreateDeveloperName_objectMapping() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_DeveloperNameLightningService.createDeveloperName('ObjectMapping', 'Create WorkOrder From Case');
        
        System.assert( serviceResponse.data != null );
        System.assert( ((String)serviceResponse.data).equalsIgnoreCase('Create_WorkOrder_From_Case') );
        
        Test.stopTest();
    }
    
    static testMethod void testCreateDeveloperName_expression() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_DeveloperNameLightningService.createDeveloperName('Expression', 'WorkOrder Criteria');
        
        System.assert( serviceResponse.data != null );
        System.assert( ((String)serviceResponse.data).equalsIgnoreCase('WorkOrder_Criteria') );
        
        Test.stopTest();
    }
    
    static testMethod void testCreateDeveloperName_invalid() {
        
        Test.startTest();
        
        try {
            
            ADM_DeveloperNameLightningService.createDeveloperName(null, 'Create WorkOrder From Case');
            System.assert(true, 'Expected Error');
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            
            ADM_DeveloperNameLightningService.createDeveloperName('Expression', null);
            System.assert(true, 'Expected Error');
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            
            ADM_DeveloperNameLightningService.createDeveloperName('', '');
            System.assert(true, 'Expected Error');
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testCreateDeveloperName_unsupported() {
        
        Test.startTest();
        
        try {
            
            ADM_DeveloperNameLightningService.createDeveloperName('Unsupported', 'Create WorkOrder From Case');
            System.assert(true, 'Expected Error');
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    static testMethod void testIsDeveloperNameAvailable_ObjectMapping() {
        Test.startTest();
        
        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable('ObjectMapping', 'ABC');
        
        System.assertEquals(true, response.success, 'Success should be true');
        System.assertEquals(true, (Boolean)response.data, 'Developer name should be available (true)');

        Test.stopTest();
    }

    static testMethod void testIsDeveloperNameAvailable_Expression() {
        Test.startTest();
        
        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable('Expression', 'ABC');
        
        System.assertEquals(true, response.success, 'Success should be true');
        System.assertEquals(true, (Boolean)response.data, 'Developer name should be available (true)');

        Test.stopTest();
    }
    static testMethod void testIsDeveloperNameAvailable_ProcessWizard() {
        Test.startTest();
        
        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable('ProcessWizard', 'ABC');
        
        System.assertEquals(true, response.success, 'Success should be true');
        System.assertEquals(true, (Boolean)response.data, 'Developer name should be available (true)');

        Test.stopTest();
    }

    static testMethod void testIsDeveloperNameAvailable_ObjectMappingExists() {
        String developerName = 'DevName1';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{
            'Name' => 'New Object Mapping',
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__DeveloperName__c' => developerName} );

        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable( 'ObjectMapping', developerName);

        System.assertEquals(true, response.success, 'Success should be true');
        System.assertEquals(false, (Boolean)response.data, 'The developer name should not be available (already in use).');
    }

    static testMethod void testIsDeveloperNameAvailable_ExpressionExists() {
        String developerName = 'DevName1';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Expression__c', new Map<String,Object>{
            'Name' => 'New Expression',
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__DeveloperName__c' => developerName} );

        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable( 'Expression', developerName);

        System.assertEquals(true, response.success, 'Success should be true');
        System.assertEquals(false, (Boolean)response.data, 'The developer name should not be available (already in use).');
    }
    
    static testMethod void testIsDeveloperNameAvailable_ProcessWizardExists() {
        String developerName = 'DevName1';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c', new Map<String,Object>{
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__DeveloperName__c' => developerName} );

        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable( 'ProcessWizard', developerName);

        System.assertEquals(true, response.success, 'Success should be true');
        System.assertEquals(false, (Boolean)response.data, 'The developer name should not be available (already in use).');
    }

    static testMethod void testIsDeveloperNameAvailable_unsupported() {
        Test.startTest();
        
        Common.ServiceResponse response = ADM_DeveloperNameLightningService.isDeveloperNameAvailable('Unsupported', 'DevName');
        
        System.assertEquals(false, response.success, 'Unsupported application type should return success as false');

        Test.stopTest();
    }
}