@isTest
public class ADM_LookupConfigLightningService_UT {

    @testSetup static void lookupConfigTestData(){

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
        new Map<String,Object>{
                 'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                 'SVMXA360__ObjectAPIName__c' => 'Account',
                 'SVMXA360__HeaderRecordObject__c' => ''
        });
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(ADM_ExpressionManager_UT.createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(ADM_ExpressionManager_UT.createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);

        SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord = (SVMXA360__CONF_LookupConfiguration__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_LookupConfiguration__c', 
                                                new Map<String,Object>{'SVMXA360__BasicFilter__c' => expressionRec.Id, 'SVMXA360__ObjectAPIName__c' => 'Account'});
    }    

    public static testMethod void testGetLookupConfigDetail(){
        Test.startTest();
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [SELECT Id FROM SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        System.assert(lookupConfigList.size() == 1);
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(lookupConfigList[0].Id);
		System.assertEquals(serviceResponse.success, true);
        Test.stoptest();
    }

    static testmethod void testGetLookupConfigDetail_nullRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(null);
		System.assertEquals(serviceResponse.success, false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetLookupConfigDetail_emptyRequest() { 
        
        Test.startTest();
        
        Adm.PageLayout requestPageLayout = new Adm.PageLayout();
        Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(JSON.serialize(requestPageLayout));
        System.assertEquals(serviceResponse.success, false);
        
        Test.stopTest();
    }

    static testmethod void testGetLookupConfigDetail_invalidPageLayoutId() { 
        
        Test.startTest();
        
        Adm.PageLayout requestPageLayout = new Adm.PageLayout();
        requestPageLayout.id = 'Invalid';
        Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(JSON.serialize(requestPageLayout));
		System.assertEquals(serviceResponse.success, false);
       
        Test.stopTest();
    }

    public static testMethod void testSaveLookupConfig(){

        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [SELECT Id FROM SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        System.assert(lookupConfigList.size() == 1);
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(lookupConfigList[0].Id);
		System.assertEquals(serviceResponse.success, true);
        Adm.LookupConfig lookConfig = (Adm.LookupConfig)serviceResponse.data;
        
        System.assertEquals(lookConfig.basicFilterId != null, true);
		lookConfig.basicFilter = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(lookConfig.basicFilterId);
        
        Test.startTest();
		serviceResponse = ADM_LookupConfigLightningService.saveLookupConfig(JSON.serialize(lookConfig));
		System.assertEquals(serviceResponse.success, true);
	
        Test.stopTest();
    }

    public static testMethod void testSaveLookupConfig_Invalid(){
		Test.startTest();
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.saveLookupConfig(JSON.serialize(''));
		System.assertEquals(serviceResponse.success, false);
	
        Test.stopTest();
    }

    public static testMethod void testSaveLookupConfig_nullObject(){
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [SELECT Id FROM SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        System.assert(lookupConfigList.size() == 1);
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(lookupConfigList[0].Id);
		System.assertEquals(serviceResponse.success, true);
        Adm.LookupConfig lookConfig = (Adm.LookupConfig)serviceResponse.data;
        lookConfig.objectAPIName = null;
            
		Test.startTest();
		serviceResponse = ADM_LookupConfigLightningService.saveLookupConfig(JSON.serialize(lookConfig));
		System.assertEquals(serviceResponse.success, false);
	
        Test.stopTest();
    }
    
    public static testMethod void testSaveLookupConfig_removeExpression(){
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [SELECT Id FROM SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        System.assert(lookupConfigList.size() == 1);
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigDetail(lookupConfigList[0].Id);
		System.assertEquals(serviceResponse.success, true);
        Adm.LookupConfig lookConfig = (Adm.LookupConfig)serviceResponse.data;
            
		Test.startTest();
		serviceResponse = ADM_LookupConfigLightningService.saveLookupConfig(JSON.serialize(lookConfig));
		System.assertEquals(serviceResponse.success, true);
	
        Test.stopTest();
    }
    
    static testmethod void testGetLookupConfigurations(){
        Test.startTest();
		ADM_LookupConfigManager lookupConfigInstance = ADM_LookupConfigManager.getInstance();
        Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigurations('Account', null);
		System.assertEquals(serviceResponse.success, true);

        Test.stopTest();
    }

    static testmethod void testGetLookupConfigurations_invalid(){
        Test.startTest();

        Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.getLookupConfigurations('', '');
		System.assertEquals(serviceResponse.success, false);

        Test.stopTest();
    }
    
    public static testMethod void testDeleteLookupConfig(){

        Test.startTest();
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [SELECT Id FROM SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        System.assert(lookupConfigList.size() == 1);
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.deleteLookupConfig(lookupConfigList[0].Id);
		System.assertEquals(serviceResponse.success, true);
        Test.stopTest();
    }
    
    public static testMethod void testDeleteLookupConfig_Invalid(){

        Test.startTest();
		Common.ServiceResponse serviceResponse = ADM_LookupConfigLightningService.deleteLookupConfig(null);
		System.assertEquals(serviceResponse.success, false);
        Test.stopTest();
    }
}