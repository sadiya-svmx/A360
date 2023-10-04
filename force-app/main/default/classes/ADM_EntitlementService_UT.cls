@IsTest
public class ADM_EntitlementService_UT {
	
    @testSetup public static void setup() {
        ADM_EntitlementRuleManager_UT.setup();
        ADM_EntitlementSettingsManager_UT.setup();
        ADM_ServiceAssignmentRuleManager_UT.setup();
        ADM_PricebookAssignmentRuleManager_UT.setup();
    }
    
    testmethod static void testGetAllEntitlementRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getAllEntitlementRules();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetAllEntitlementSettings() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getAllEntitlementSettings();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getEntitlementRules('WorkOrder');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules_Invalid() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getEntitlementRules('');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    testmethod static void testGetCommonEntitlementSetting() {
        Id recordTypeId = ADM_EntitlementSettingsManager.getInstance().getRecordTypeInfosByDeveloperName(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSetting = (SVMXA360__CONF_EntitlementSettings__c) SvmxTestDataFactory.createSObject( 'SVMXA360__CONF_EntitlementSettings__c', 
                                                new Map<String,Object>{});
        entitlementSetting.RecordTypeId = recordTypeId;
        entitlementSetting.SVMXA360__DeveloperName__c = 'Developer_Name987';
        insert entitlementSetting;

        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getCommonEntitlementSetting();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetCommonEntitlementSetting_Invalid() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getCommonEntitlementSetting();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.data == null);
        System.assert( serviceResponse.success == true);
        
        Test.stopTest();
    }

    testmethod static void testGetUnsupportedStackRankingFields() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getUnsupportedStackRankingFields();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.data != null);
        System.assert( serviceResponse.success == true);
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getEntitlementRule(entitlementRule.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule_Invalid() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getEntitlementRule('');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    testmethod static void testValidateEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.id = null;
        entitlementRule.developerName = 'Test Developer Name';
        
        Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
        for (Adm.ExpressionDetail expressionDetail : expression.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';
        }
        entitlementRule.expression = expression;
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().validateEntitlementRule( entitlementRule );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.id = null;
        entitlementRule.developerName = 'Test Developer Name';
        
        Adm.Expression expression = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails().get(0);
        for (Adm.ExpressionDetail expressionDetail : expression.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';
        }
        entitlementRule.expression = expression;
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveEntitlementRule( entitlementRule );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule_InvalidParam() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveEntitlementRule( null );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings() {
        
        Test.startTest();
        
        List<Adm.EntitlementSettings> entitlementSettingsList = new ADM_EntitlementServiceImpl().getAllEntitlementSettings();
        Adm.EntitlementSettings entitlementSettings = entitlementSettingsList.get(0);
        entitlementSettings.id = null;
        entitlementSettings.developerName = 'Test Developer Name';
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveEntitlementSettings( entitlementSettings );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveEntitlementSettings( null );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
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

        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveCommonEntitlementSettings( entitlementSettings );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        System.assert( serviceResponse.data != null );
        
        Test.stopTest();
    }

    testmethod static void testSaveCommonEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveCommonEntitlementSettings( null );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testUpdateEntitlementRuleSequence() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        entitlementRule.sequence = 1;
        entitlementRule.isActive = true;
                
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{entitlementRule} );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().updateEntitlementRulesSequence( new List<Adm.EntitlementRule>{} );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().deleteEntitlementRule( entitlementRule );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 4 );
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule_InvalidParam() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = new ADM_EntitlementService().deleteEntitlementRule( null );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testGetAllPricebookAssignmentRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getAllPricebookAssignmentRules();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRule() {
        
        Test.startTest();

		List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getPricebookAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testValidatePricebookAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : pricebookAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';
        }
        pricebookAssignmentRule.name = 'Name Pricebook Assignment Rule Update';

        Common.ServiceResponse serviceResponse  = new ADM_EntitlementService().validatePricebookAssignmentRule( pricebookAssignmentRule );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );

        Test.stopTest();
    }
    
    testmethod static void testSavePricebookAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : pricebookAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';
        }
        pricebookAssignmentRule.name = 'Name Pricebook Assignment Rule Update';

        Common.ServiceResponse serviceResponse  = new ADM_EntitlementService().savePricebookAssignmentRule( pricebookAssignmentRule );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );

        Test.stopTest();
    }

    testmethod static void testSavePricebookAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().savePricebookAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = pricebookAssignmentRuleList.get(0);
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().deletePricebookAssignmentRule( pricebookAssignmentRule.id );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRulesSequence() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = pricebookAssignmentRuleList.get(0);
        pricebookAssignmentRule.sequence = 1;
        pricebookAssignmentRule.active = true;
                
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().updatePricebookAssignmentRulesSequence( new List<Adm.PricebookAssignmentRule>{pricebookAssignmentRule} );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().updatePricebookAssignmentRulesSequence( new List<Adm.PricebookAssignmentRule>{} );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().deletePricebookAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    testmethod static void testGetAllServiceAssignmentRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getAllServiceAssignmentRules();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRules_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getServiceAssignmentRules(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRule() {
        
        Test.startTest();

		List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getServiceAssignmentRules('WorkOrder');
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().getServiceAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testValidateServiceAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = entitlementServiceImpl.getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.name = 'Name Service Assignment Rule Update';

        for (Adm.ExpressionDetail expressionDetail : ServiceAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';
        }

        Common.ServiceResponse serviceResponse  = new ADM_EntitlementService().validateServiceAssignmentRule( ServiceAssignmentRule );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );

        Test.stopTest();
    }
    
    testmethod static void testSaveServiceAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = entitlementServiceImpl.getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.name = 'Name Service Assignment Rule Update';

        for (Adm.ExpressionDetail expressionDetail : ServiceAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';
        }

        Common.ServiceResponse serviceResponse  = new ADM_EntitlementService().saveServiceAssignmentRule( ServiceAssignmentRule );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );

        Test.stopTest();
    }

    testmethod static void testSaveServiceAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().saveServiceAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence() {
        
        Test.startTest();
        
        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = entitlementServiceImpl.getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = entitlementServiceImpl.getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.sequence = 1;
        serviceAssignmentRule.active = true;
                
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().updateServiceAssignmentRulesSequence( new List<Adm.ServiceAssignmentRule>{serviceAssignmentRule} );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().updateServiceAssignmentRulesSequence( new List<Adm.ServiceAssignmentRule>{} );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = serviceAssignmentRuleList.get(0);
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().deleteServiceAssignmentRule( serviceAssignmentRule.id );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_EntitlementService().deleteServiceAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
}