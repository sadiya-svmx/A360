@isTest
public class ADM_EntitlementRuleManager_UT {

    @testSetup public static void setup() {
        
        SVMXA360__CONF_Expression__c expression = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Expression__c', 
                                              new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder','SVMXA360__AdvancedExpression__c' => '1',
                                              'SVMXA360__HeaderRecordObject__c' => ''});
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => expression.id,
                                                  'SVMXA360__FieldAPIName__c' => 'Status',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'New',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__OperandType__c' => 'Value',
                                                  'SVMXA360__SourceObjectName__c' => null}, 1);
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_EntitlementRule__c', 
                                              new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder', 'SVMXA360__Expression__c' => expression.id, 
                                                  'SVMXA360__AssetAPIName__c' => 'AssetId', 'SVMXA360__AccountAPIName__c' => 'AccountId' }, 
                                              5);
        
        Case caseRecord = (Case) SvmxTestDataFactory.insertSObject( 'Case', 
                                                    new Map<String,Object>{'Origin' => 'Phone','Priority' => 'Medium','Status' => 'New'});

        SVMXA360__EntitlementVerificationHistory__c entitlementHistoryRecord = (SVMXA360__EntitlementVerificationHistory__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__EntitlementVerificationHistory__c', 
                                                                                new Map<String,Object>{'SVMXA360__CaseId__c' => caseRecord.Id,
                                                                                    'SVMXA360__EntitlementDate__c' => Date.Today(),
                                                                                    'SVMXA360__EntitledBy__c' => 'Asset',
                                                                                    'SVMXA360__VerificationMode__c' => 'Auto'});
    }
    
    testmethod static void testGetAllEntitlementRules() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 5 );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules() {
        
        Test.startTest();
        
     	List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getEntitlementRules('WorkOrder');
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 5 );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules_InvalidParameter() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRules('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRules(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule() {
        
        Test.startTest();

		List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 5 );
        
     	Adm.EntitlementRule entitlementRule = ADM_EntitlementRuleManager.getInstance().getEntitlementRule(entitlementRuleList.get(0).id);
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.id == entitlementRuleList.get(0).id );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule_InvalidParameter() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRule('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRule('invalid');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
                
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules_Empty() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getEntitlementRules('WorkOrderDetailItem');
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 0 );
        
        Test.stopTest();
    }
    
    testmethod static void testValidateEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.id = null;
        entitlementRule.isActive = true;
        entitlementRule.sequence = null;
        entitlementRule.developerName = 'Test Developer Name';
        
        Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
        for (Adm.ExpressionDetail expressionDetail : expression.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        entitlementRule.expression = expression;
        
     	Adm.ValidationResult validationResult = ADM_EntitlementRuleManager.getInstance().validateEntitlementRule( entitlementRule );
        
        System.assert( validationResult != null );
        System.assert( validationResult.isValid );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.id = null;
        entitlementRule.isActive = true;
        entitlementRule.sequence = null;
        entitlementRule.developerName = 'Test Developer Name';
        
        Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
        for (Adm.ExpressionDetail expressionDetail : expression.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        entitlementRule.expression = expression;
        
     	entitlementRule = ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.id != null );
        System.assert( entitlementRule.sequence == 5, entitlementRule.sequence );
        
        entitlementRule.name = 'Name Update';
        entitlementRule = ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.name.equals('Name Update') );
        System.assert( entitlementRule.sequence == 5 );
        
        entitlementRule.expression = null;
        entitlementRule = ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.name.equals('Name Update') );
        System.assert( entitlementRule.sequence == 5 );
        
        entitlementRule.isActive = false;
        entitlementRule = ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.sequence == null );
        
        entitlementRule.isActive = true;
        entitlementRule = ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.sequence == 5 );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRules() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        
        
        for( Integer index = 0; index <  entitlementRuleList.size(); index++ ) {
            
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(index);
                
            entitlementRule.id = null;
            entitlementRule.isActive = true;
            entitlementRule.sequence = null;
            entitlementRule.developerName = 'TestDeveloperName' + index;
            
            final Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
            expression.id = null;
            expression.developerName = 'TestDeveloperName' + index;
            for(Adm.ExpressionDetail detail : expression.expressionDetailList ) {
                detail.id = null;
                detail.relatedObjectDetails = '';
            }
            entitlementRule.expression = expression;
        }
        
     	entitlementRuleList = ADM_EntitlementRuleManager.getInstance().saveEntitlementRules( entitlementRuleList );
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() != 0 );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule_ReadOnly() {
        
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        try {
            
            List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            entitlementRule.id = null;
            entitlementRule.developerName = 'Test Developer Name';
            
            Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
            for (Adm.ExpressionDetail expressionDetail : expression.expressionDetailList) {
                expressionDetail.relatedObjectDetails = '';   
            }
            entitlementRule.expression = expression;
            
            ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( entitlementRule );
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().saveEntitlementRule( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.sequence = 1;
        entitlementRule.isActive = true;
                
        entitlementRuleList = ADM_EntitlementRuleManager.getInstance().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() != 0 );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence_ReadOnly() {
        
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        try {
            
            List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            entitlementRule.sequence = 1;
            entitlementRule.isActive = true;
            
            ADM_EntitlementRuleManager.getInstance().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
           
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence_MissingParam() {
        
        Test.startTest();
        
        try {
            List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            entitlementRule.id = null;
            
            ADM_EntitlementRuleManager.getInstance().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
     	ADM_EntitlementRuleManager.getInstance().deleteEntitlementRule( entitlementRule.id );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.id != null );
        
        entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 4 );
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule_ReadOnly() {
        
        Test.startTest();
		Test.setReadOnlyApplicationMode(true);
        
        try {
            List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            
            ADM_EntitlementRuleManager.getInstance().deleteEntitlementRule( entitlementRule.id );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().deleteEntitlementRule( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
     	
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRuleRecords() {
        
        Test.startTest();
        
        List<SVMXA360__CONF_EntitlementRule__c > entitlementRuleRecordList = ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecords('WorkOrder');
               
        System.assert( entitlementRuleRecordList != null );
        System.assert( entitlementRuleRecordList.size() == 5 );
     	
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRuleRecords_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecords(null);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecords('');
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRuleRecord() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecord(entitlementRule.id);
               
        System.assert( entitlementRuleRecord != null );
        System.assert( entitlementRuleRecord.id == entitlementRule.id );
     	
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRuleRecord_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecord(null);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecord('');
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementRuleManager.getInstance().getEntitlementRuleRecord('invalid');
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
}