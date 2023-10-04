@IsTest
public class ADM_EntitlementLightningService_UT {
    
	@testSetup public static void setup() {
        ADM_EntitlementRuleManager_UT.setup();
        ADM_EntitlementSettingsManager_UT.setup();
        ADM_ServiceAssignmentRuleManager_UT.setup();
        ADM_PricebookAssignmentRuleManager_UT.setup();
    }
    
    testmethod static void testGetAllEntitlementRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getAllEntitlementRules();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetAllEntitlementSettings() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getAllEntitlementSettings();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getEntitlementRules('WorkOrder');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRules_Invalid() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getEntitlementRules('');
        
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
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getCommonEntitlementSetting();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetCommonEntitlementSetting_WithoutCommonSetting() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getCommonEntitlementSetting();
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data == null );
        
        Test.stopTest();
    }

    testmethod static void testGetUnsupportedStackRankingFields() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getUnsupportedStackRankingFields();
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        
        Test.stopTest();
    }

    testmethod static void testGetEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getEntitlementRule(entitlementRule.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementRule_Invalid() {
        
        Test.startTest();
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getEntitlementRule('');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
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
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveEntitlementRule( JSON.serialize(entitlementRule) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementRule_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveEntitlementRule( '{{}' );
        
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
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveEntitlementSettings( JSON.serialize(entitlementSettings) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveEntitlementSettings( '{{}' );
        
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

        Adm.CommonEntitlementSettings entitlementSettings = new ADM_EntitlementServiceImpl().getCommonEntitlementSetting();

        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveCommonEntitlementSettings( JSON.serialize(entitlementSettings) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }

    testmethod static void testSaveCommonEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveCommonEntitlementSettings( '{{}' );
        
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
                
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.updateRulesSequence( JSON.serialize(new List<Adm.EntitlementRule>{entitlementRule}) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateEntitlementRuleSequence_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.updateRulesSequence( '{{}' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule() {
        
        Test.startTest();
        
        List<Adm.EntitlementRule> entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        Adm.EntitlementRule entitlementRule = entitlementRuleList.get(0);
        
     	Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.deleteEntitlementRule( JSON.serialize(entitlementRule) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        entitlementRuleList = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        
        System.assert( entitlementRuleList != null );
        System.assert( entitlementRuleList.size() == 4 );
        
        Test.stopTest();
    }
    
    testmethod static void testDeleteEntitlementRule_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.deleteEntitlementRule( '{{}' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testGetEntitlementPerformed() {
        
        Test.startTest();
        
        Case caseRecord = [Select Id from Case where Status = 'New' limit 1];
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getEntitlementPerformed( caseRecord.Id );
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testgetEntitlementVerficationHistory() {
        
        Test.startTest();
        
        Case caseRecord = [Select Id from Case where Status = 'New' limit 1];
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getEntitlementVerficationHistory( caseRecord.Id );
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetAllPricebookAssignmentRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getAllPricebookAssignmentRules();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRule() {
        
        Test.startTest();

		List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetPricebookAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getPricebookAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testSavePricebookAssignmentRule() {

        Test.startTest();

        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        for (Adm.ExpressionDetail expressionDetail : PricebookAssignmentRule.qualifyingCriteria.expressionDetailList) {
            expressionDetail.relatedObjectDetails = '';   
        }
        pricebookAssignmentRule.name = 'Name Pricebook Assignment Rule Update';

        Common.ServiceResponse serviceResponse  = ADM_EntitlementLightningService.savePricebookAssignmentRule( JSON.serialize(pricebookAssignmentRule) );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );

        Test.stopTest();
    }

    testmethod static void testSavePricebookAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.savePricebookAssignmentRule( '{{}' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testUpdatePricebookAssignmentRulesSequence() {
        
        Test.startTest();
        
        ADM_EntitlementServiceImpl entitlementServiceImpl = new ADM_EntitlementServiceImpl();
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = entitlementServiceImpl.getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = entitlementServiceImpl.getPricebookAssignmentRule(pricebookAssignmentRuleList.get(0).id);
        pricebookAssignmentRule.sequence = 1;
        pricebookAssignmentRule.active = true;
                
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.updatePricebookAssignmentRulesSequence( JSON.serialize(new List<Adm.PricebookAssignmentRule>{pricebookAssignmentRule}) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdatePricebookAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.updatePricebookAssignmentRulesSequence( '{{}' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testDeletePricebookAssignmentRule() {
        
        Test.startTest();
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        Adm.PricebookAssignmentRule pricebookAssignmentRule = pricebookAssignmentRuleList.get(0);
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.deletePricebookAssignmentRule( pricebookAssignmentRule.id );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
  
    testmethod static void testGetAllServiceAssignmentRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getAllServiceAssignmentRules();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRules() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getServiceAssignmentRules('WorkOrder');
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRules_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getServiceAssignmentRules(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRule() {
        
        Test.startTest();

		List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getServiceAssignmentRules('WorkOrder');
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetServiceAssignmentRule_Invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.getServiceAssignmentRule(null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
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

        Common.ServiceResponse serviceResponse  = ADM_EntitlementLightningService.saveServiceAssignmentRule( JSON.serialize(ServiceAssignmentRule) );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );

        Test.stopTest();
    }

    testmethod static void testSaveServiceAssignmentRule_Invalid() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.objectAPIName = null;
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveServiceAssignmentRule(JSON.serialize(ServiceAssignmentRule));
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testSaveServiceAssignmentRule_NullParameter() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.saveServiceAssignmentRule( '{{}' );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testUpdateServiceAssignmentRulesSequence() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRule(serviceAssignmentRuleList.get(0).id);
        serviceAssignmentRule.sequence = 1;
        serviceAssignmentRule.active = true;
                
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.updateServiceAssignmentRulesSequence( JSON.serialize(new List<Adm.ServiceAssignmentRule>{serviceAssignmentRule}) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    testmethod static void testUpdateServiceAssignmentRulesSequence_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.updateServiceAssignmentRulesSequence( '{{}' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    testmethod static void testDeleteServiceAssignmentRule() {
        
        Test.startTest();
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new ADM_EntitlementServiceImpl().getServiceAssignmentRules('WorkOrder');
        Adm.ServiceAssignmentRule serviceAssignmentRule = serviceAssignmentRuleList.get(0);
        
        Common.ServiceResponse serviceResponse = ADM_EntitlementLightningService.deleteServiceAssignmentRule( serviceAssignmentRule.id );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
}