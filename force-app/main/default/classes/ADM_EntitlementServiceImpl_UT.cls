@IsTest
public class ADM_EntitlementServiceImpl_UT {
    
	@testSetup public static void setup() {
        ADM_EntitlementRuleManager_UT.setup();
        ADM_EntitlementSettingsManager_UT.setup();
        ADM_ServiceAssignmentRuleManager_UT.setup();
        ADM_PricebookAssignmentRuleManager_UT.setup();
    }
    
    testmethod static void testGetAllEntitlementRules() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 5 );
        
        Test.stopTest();
    }
    
    testmethod static void testGetAllEntitlementSettings() {
        
        Test.startTest();
        
        List<Adm.EntitlementSettings> entitlementSettingsList = new ADM_EntitlementServiceImpl().getAllEntitlementSettings();
        
        System.assert( entitlementSettingsList != null );
        System.assert( entitlementSettingsList.size() == 5 );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules() {
        
        Test.startTest();
        
     	List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getEntitlementRules('WorkOrder');
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 5 );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules_InvalidParameter() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().getEntitlementRules('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            new ADM_EntitlementServiceImpl().getEntitlementRules(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 5 );
        
     	Adm.EntitlementRule entitlementRule = new ADM_EntitlementServiceImpl().getEntitlementRule(entitlementRuleList.get(0).id);
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.id == entitlementRuleList.get(0).id );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule_InvalidParameter() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().getEntitlementRule('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            new ADM_EntitlementServiceImpl().getEntitlementRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            new ADM_EntitlementServiceImpl().getEntitlementRule('invalid');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules_Empty() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getEntitlementRules('WorkOrderDetailItem');
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 0 );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
        entitlementRule.id = null;
        entitlementRule.developerName = 'Test Developer Name';
        
        Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
        entitlementRule.expression = expression;

        for (Adm.ExpressionDetail expressionDetail : expression.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        
     	entitlementRule = new ADM_EntitlementServiceImpl().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.id != null );
        
        entitlementRule.name = 'Name Update';
        entitlementRule = new ADM_EntitlementServiceImpl().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.name.equals('Name Update') );
        
        entitlementRule.expression = null;
        entitlementRule = new ADM_EntitlementServiceImpl().saveEntitlementRule( entitlementRule );
        
        System.assert( entitlementRule != null );
        System.assert( entitlementRule.name.equals('Name Update') );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule_ReadOnly() {
        
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        try {
            
            List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            entitlementRule.id = null;
            entitlementRule.developerName = 'Test Developer Name';
            
            Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
            entitlementRule.expression = expression;
            
            new ADM_EntitlementServiceImpl().saveEntitlementRule( entitlementRule );
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
            new ADM_EntitlementServiceImpl().saveEntitlementRule( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings() {
        
        Test.startTest();
        
        List<Adm.EntitlementSettings> entitlementSettingsList = new ADM_EntitlementServiceImpl().getAllEntitlementSettings();
        Adm.EntitlementSettings entitlementSettings = entitlementSettingsList.get(0);
        entitlementSettings.id = null;
        entitlementSettings.developerName = 'Test Developer Name';
        
     	entitlementSettings = new ADM_EntitlementServiceImpl().saveEntitlementSettings( entitlementSettings );
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.id != null );
        
        entitlementSettings.name = 'Name Update';
        entitlementSettings = new ADM_EntitlementServiceImpl().saveEntitlementSettings( entitlementSettings );
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.name.equals('Name Update') );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings_ReadOnly() {
        
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        try {
            
            List<Adm.EntitlementSettings> entitlementSettingsList = new ADM_EntitlementServiceImpl().getAllEntitlementSettings();
            Adm.EntitlementSettings entitlementSettings = entitlementSettingsList.get(0);
            entitlementSettings.id = null;
            entitlementSettings.developerName = 'Test Developer Name';
            
            new ADM_EntitlementServiceImpl().saveEntitlementSettings( entitlementSettings );
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    testmethod static void testSaveCommonEntitlementSettings() {
        
        Id recordTypeId = ADM_EntitlementSettingsManager.getInstance().getRecordTypeInfosByDeveloperName(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSetting = (SVMXA360__CONF_EntitlementSettings__c) SvmxTestDataFactory.createSObject( 'SVMXA360__CONF_EntitlementSettings__c', 
                                                new Map<String,Object>{});
        entitlementSetting.RecordTypeId = recordTypeId;
        entitlementSetting.SVMXA360__DeveloperName__c = 'Developer_Name987';
        insert entitlementSetting;

        Test.startTest();

        Adm.CommonEntitlementSettings entitlementSettings = new ADM_EntitlementServiceImpl().getCommonEntitlementSetting();
        entitlementSettings.adjustVisitCountAssignedObject = 'Case';
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.id != null );

        entitlementSettings = new ADM_EntitlementServiceImpl().saveCommonEntitlementSettings( entitlementSettings );
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.id != null);
        System.assert( entitlementSettings.adjustVisitCountAssignedObject.equals('Case') );
        
        Test.stopTest();
    }

    testmethod static void testGetUnsupportedStackRankingFields() {
        
        Test.startTest();
        
        List<String> fieldList = new ADM_EntitlementServiceImpl().getUnsupportedStackRankingFields();
        
        System.assert( fieldList != null );
        
        Test.stopTest();
    }

    testmethod static void testSaveEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().saveEntitlementSettings( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testSaveCommonEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().saveCommonEntitlementSettings( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testUpdateEntitlementRuleSequence() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.sequence = 1;
        entitlementRule.isActive = true;
                
        entitlementRuleList = new ADM_EntitlementServiceImpl().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() != 0 );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence_ReadOnly() {
        
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        try {
            
            List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            entitlementRule.sequence = 1;
            entitlementRule.isActive = true;
            
            new ADM_EntitlementServiceImpl().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
           
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
            new ADM_EntitlementServiceImpl().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{} );
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
            List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            entitlementRule.id = null;
            
            new ADM_EntitlementServiceImpl().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
     	new ADM_EntitlementServiceImpl().deleteEntitlementRule( entitlementRule );
        
        entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 4 );
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule_ReadOnly() {
        
        Test.startTest();
		Test.setReadOnlyApplicationMode(true);
        
        try {
            List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
            Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
            
            new ADM_EntitlementServiceImpl().deleteEntitlementRule( entitlementRule );
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
            new ADM_EntitlementServiceImpl().deleteEntitlementRule( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
     	
        Test.stopTest();
    }

    testmethod static void testGetAllPricebookAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRule() {
        
        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();

		List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 5 );
        
     	Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        
        System.assert( pricebookAssignmentRule != null );
        System.assert( pricebookAssignmentRule.id == pricebookAssignmentRuleList.get(0).id );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignment_InvalidParameter() {
        
        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        
        try {
            entitlementServiceImpl.getPricebookAssignmentRule('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            entitlementServiceImpl.getPricebookAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testSavePricebookAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();

        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        pricebookAssignmentRule.name = 'Name Pricebook Assignment Rule Update';
        for (Adm.ExpressionDetail expressionDetail : pricebookAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
       }
        pricebookAssignmentRule = entitlementServiceImpl.savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule.name.equals('Name Pricebook Assignment Rule Update') );

        pricebookAssignmentRule.developerName = 'Pricebook Assignment Rule Developer Name Update';
        pricebookAssignmentRule = entitlementServiceImpl.savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule.developerName.equals('Pricebook Assignment Rule Developer Name Update') );

        pricebookAssignmentRule.qualifyingCriteria = null;
        pricebookAssignmentRule = entitlementServiceImpl.savePricebookAssignmentRule( pricebookAssignmentRule );
        System.assert( pricebookAssignmentRule != null );

        Test.stopTest();
    }

    testmethod static void testSavePricebookAssignmentRule_InvalidParams() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        
        try {
            Adm.PricebookAssignmentRule pricebookAssignmentRuleList = entitlementServiceImpl.savePricebookAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
            Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
            pricebookAssignmentRule.objectAPIName = null;
            pricebookAssignmentRule = entitlementServiceImpl.savePricebookAssignmentRule(pricebookAssignmentRule);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRulesSequence() {
        
        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        pricebookAssignmentRule.sequence = 1;
        pricebookAssignmentRule.active = true;
                
        pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().updatePricebookAssignmentRulesSequence( new List<Adm.PricebookAssignmentRule>{pricebookAssignmentRule} );
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() != 0 );
        
        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().updatePricebookAssignmentRulesSequence( new List<Adm.PricebookAssignmentRule>{} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule() {
        
        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = pricebookAssignmentRuleList.get(0);
        
        entitlementServiceImpl.deletePricebookAssignmentRule( pricebookAssignmentRule.id );
        
        System.assert( pricebookAssignmentRule != null );
        System.assert( pricebookAssignmentRule.id != null );
        
        pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        
        System.assert( pricebookAssignmentRuleList != null );
        System.assert( pricebookAssignmentRuleList.size() == 4 );
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule_InvalidParam() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().deletePricebookAssignmentRule( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
     	
        Test.stopTest();
    }
  
    testmethod static void testGetAllServiceAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllServiceAssignmentRules();
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRules() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRule() {
        
        Test.startTest();

		List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 5 );
        
     	Adm.ServiceAssignmentRule serviceAssignmentRule = new ADM_EntitlementServiceImpl().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        
        System.assert( serviceAssignmentRule != null );
        System.assert( serviceAssignmentRule.id == serviceAssignmentRuleList.get(0).id );
        
        Test.stopTest();
    }

    testmethod static void testGeServiceAssignment_InvalidParameter() {
        
        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        try {
            entitlementServiceImpl.getServiceAssignmentRules('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            entitlementServiceImpl.getServiceAssignmentRules(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            entitlementServiceImpl.getServiceAssignmentRule('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            entitlementServiceImpl.getServiceAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testSaveServiceAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = entitlementServiceImpl.getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : serviceAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
       }
        serviceAssignmentRule.name = 'Name Service Assignment Rule Update';
        serviceAssignmentRule = entitlementServiceImpl.saveServiceAssignmentRule( ServiceAssignmentRule );
        System.assert( serviceAssignmentRule.name.equals('Name Service Assignment Rule Update') );

        Test.stopTest();
    }

    testmethod static void testSaveServiceAssignmentRule_InvalidParams() {

        Test.startTest();
        
        try {
            Adm.ServiceAssignmentRule serviceAssignmentRule = new ADM_EntitlementServiceImpl().saveServiceAssignmentRule(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence() {
        
        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = entitlementServiceImpl.getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.sequence = 1;
        serviceAssignmentRule.active = true;
                
        serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().updateServiceAssignmentRulesSequence( new List<Adm.ServiceAssignmentRule>{serviceAssignmentRule} );
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() != 0 );
        
        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().updateServiceAssignmentRulesSequence( new List<Adm.ServiceAssignmentRule>{} );
            System.assert(false);
        }   
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule() {
        
        Test.startTest();
        
        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = serviceAssignmentRuleList.get(0);
        
        entitlementServiceImpl.deleteServiceAssignmentRule( serviceAssignmentRule.id );
        
        System.assert( serviceAssignmentRule != null );
        System.assert( serviceAssignmentRule.id != null );
        
        serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceAssignmentRuleList != null );
        System.assert( serviceAssignmentRuleList.size() == 4 );
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule_InvalidParam() {
        
        Test.startTest();
        
        try {
            new ADM_EntitlementServiceImpl().deleteServiceAssignmentRule( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
     	
        Test.stopTest();
    }

}