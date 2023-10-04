@isTest
public class ADM_PricebookAssignmentRuleManager_UT {
    
    @testSetup public static void setup() {
        
        SVMXA360__CONF_Expression__c expression = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Expression__c', 
                                              new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
                                                'SVMXA360__AdvancedExpression__c' => '1',
                                                'SVMXA360__DeveloperName__c' => 'PR_DeveloperName',
                                                'SVMXA360__HeaderRecordObject__c' => ''});
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => expression.id,
                                                  'SVMXA360__FieldAPIName__c' => 'Status',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'New',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__OperandType__c' => 'Value',
                                                  'SVMXA360__SourceObjectName__c' => null}, 1);
        
        Pricebook2 pricebookRecord = (Pricebook2) SvmxTestDataFactory.insertSObject( 'Pricebook2', 
                                                new Map<String,Object>{'Name' => 'Standard Pricebook'});
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_PricebookAssignmentRule__c', 
                                              new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder', 
                                                                     'SVMXA360__Pricebook__c' => pricebookRecord.id, 
                                                                     'SVMXA360__ExpressionId__c' => expression.id},5);
        
    }

    testmethod static void testGetAllPricebookAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRules('WorkOrder');
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRule() {
        
        Test.startTest();

		List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 5 );
        
     	Adm.PricebookAssignmentRule pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        
        System.assert( pricebookAssignmentRule != null );
        System.assert( pricebookAssignmentRule.id == pricebookAssignmentRuleList.get(0).id );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignment_InvalidParameter() {
        
        Test.startTest();
        
        try {
            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRules(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRules('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRuleRecord('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRuleRecord(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testValidatePricebookAssignmentRule() {

        Test.startTest();

        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : pricebookAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        pricebookAssignmentRule.name = 'Name Pricebook Assignment Rule Update';
        Adm.ValidationResult validationResult = ADM_PricebookAssignmentRuleManager.getInstance().validatePricebookAssignmentRule( pricebookAssignmentRule );
        
        System.assert( validationResult != null );
        System.assert( validationResult.isValid );

        Test.stopTest();
    }
    
    testmethod static void testSavePricebookAssignmentRule() {

        Test.startTest();

        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : pricebookAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        pricebookAssignmentRule.name = 'Name Pricebook Assignment Rule Update';
        pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule.name.equals('Name Pricebook Assignment Rule Update') );

        pricebookAssignmentRule.developerName = 'Pricebook Assignment Rule Developer Name Update';
        pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule.developerName.equals('Pricebook Assignment Rule Developer Name Update') );

        pricebookAssignmentRule.qualifyingCriteria = null;
        pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule != null );

        pricebookAssignmentRule.active = true;
        pricebookAssignmentRule.sequence = null;
        pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule.sequence == 5 );

        Test.stopTest();
    }

    testmethod static void testSavePricebookAssignmentRule_InvalidParams() {

        Test.startTest();
        
        try {
            Adm.PricebookAssignmentRule pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().savePricebookAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
            Adm.PricebookAssignmentRule pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
            pricebookAssignmentRule.objectAPIName = null;
            pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().savePricebookAssignmentRule(pricebookAssignmentRule);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRuleSequence() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        pricebookAssignmentRule.sequence = 1;
        pricebookAssignmentRule.active = true;
                
        pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().updatePricebookAssignmentRulesSequence( new List<Adm.PricebookAssignmentRule>{pricebookAssignmentRule} );
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() != 0 );
        
        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRuleSequence_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_PricebookAssignmentRuleManager.getInstance().updatePricebookAssignmentRulesSequence( new List<Adm.PricebookAssignmentRule>{} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = pricebookAssignmentRuleList.get(0);
        
        ADM_PricebookAssignmentRuleManager.getInstance().deletePricebookAssignmentRule( pricebookAssignmentRule.id );
        
        System.assert( pricebookAssignmentRule != null );
        System.assert( pricebookAssignmentRule.id != null );
        
        pricebookAssignmentRuleList = ADM_PricebookAssignmentRuleManager.getInstance().getAllPricebookAssignmentRules();
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 4 );
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_PricebookAssignmentRuleManager.getInstance().deletePricebookAssignmentRule( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
     	
        Test.stopTest();
    }
}