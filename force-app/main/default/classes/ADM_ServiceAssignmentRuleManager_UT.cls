@isTest
public class ADM_ServiceAssignmentRuleManager_UT {

    @testSetup public static void setup() {
        
            SVMXA360__CONF_Expression__c expression = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Expression__c', 
                                                  new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
                                                      'SVMXA360__AdvancedExpression__c' => '1',
                                                      'SVMXA360__DeveloperName__c' => 'SR_DeveloperName',
                                                      'SVMXA360__HeaderRecordObject__c' => ''});
            
            SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                  new Map<String,Object>{'SVMXA360__ExpressionId__c' => expression.id,
                                                      'SVMXA360__FieldAPIName__c' => 'Status',
                                                      'SVMXA360__Operator__c' => 'eq',
                                                      'SVMXA360__Operand__c' => 'New',
                                                      'SVMXA360__Sequence__c' => 1,
                                                      'SVMXA360__OperandType__c' => 'Value',
                                                      'SVMXA360__SourceObjectName__c' => null}, 1);
            
            Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', 
                                                    new Map<String,Object>{'Name' => 'Standard Product'});
            
            SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_EntitledServiceAssignmentRule__c', 
                                                  new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder', 
                                                                         'SVMXA360__ProductId__c' => productRecord.id, 
                                                                         'SVMXA360__ExpressionId__c' => expression.id},5);
            
    }

    testmethod static void testGetAllServiceAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getAllServiceAssignmentRules();
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRule() {
        
        Test.startTest();

		List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 5 );
        
     	Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        
        System.assert( serviceAssignmentRule != null );
        System.assert( serviceAssignmentRule.id == serviceAssignmentRuleList.get(0).id );
        
        Test.stopTest();
    }

    testmethod static void testGeServiceAssignment_InvalidParameter() {
        
        Test.startTest();
        
        try {
            ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRuleRecord(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testValidateServiceAssignmentRule() {

        Test.startTest();

        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : serviceAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        
        serviceAssignmentRule.name = 'Name Service Assignment Rule Update';
        Adm.ValidationResult validationResult = ADM_ServiceAssignmentRuleManager.getInstance().validateServiceAssignmentRule( serviceAssignmentRule );
        
        System.assert( validationResult != null );
        System.assert( validationResult.isValid );

        Test.stopTest();
    }
    
    testmethod static void testSaveServiceAssignmentRule() {

        Test.startTest();

        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : serviceAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        serviceAssignmentRule.name = 'Name Service Assignment Rule Update';
        serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().saveServiceAssignmentRule( ServiceAssignmentRule );
        System.assert( serviceAssignmentRule.name.equals('Name Service Assignment Rule Update') );

        serviceAssignmentRule.developerName = 'Service Assignment Rule Developer Name Update';
        serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().saveServiceAssignmentRule( ServiceAssignmentRule );
        System.assert( serviceAssignmentRule.developerName.equals('Service Assignment Rule Developer Name Update') );

        serviceAssignmentRule.qualifyingCriteria = null;
        serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().saveServiceAssignmentRule( ServiceAssignmentRule );
        System.assert( serviceAssignmentRule != null );

        serviceAssignmentRule.active = true;
        serviceAssignmentRule.sequence = null;
        serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().saveServiceAssignmentRule( serviceAssignmentRule );
        System.assert( serviceAssignmentRule.sequence == 5 );

        Test.stopTest();
    }

    testmethod static void testSaveServiceAssignmentRule_InvalidParams() {

        Test.startTest();
        
        try {
            Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().saveServiceAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
            Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
            serviceAssignmentRule.objectAPIName = null;
            serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().saveServiceAssignmentRule(serviceAssignmentRule);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.sequence = 1;
        serviceAssignmentRule.active = true;
                
        serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().updateServiceAssignmentRulesSequence( new List<Adm.ServiceAssignmentRule>{serviceAssignmentRule} );
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() != 0 );
        
        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_ServiceAssignmentRuleManager.getInstance().updateServiceAssignmentRulesSequence( new List<Adm.ServiceAssignmentRule>{} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = serviceAssignmentRuleList.get(0);
        
        ADM_ServiceAssignmentRuleManager.getInstance().deleteServiceAssignmentRule( serviceAssignmentRule.id );
        
        System.assert( serviceAssignmentRule != null );
        System.assert( serviceAssignmentRule.id != null );
        
        serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 4 );
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_ServiceAssignmentRuleManager.getInstance().deleteServiceAssignmentRule( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
     	
        Test.stopTest();
    }
}