@IsTest
public class ADM_LookupConfigService_UT {
    
	@testSetup public static void setup() {
        
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
    
    static testmethod void testGetLookupConfigurations() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_LookupConfigService().getAllLookupConfigurations();
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        List<Adm.LookupConfig> lookupConfigList = (List<Adm.LookupConfig>) serviceResponse.data;
        
        System.assert( lookupConfigList != null );
        System.assert( lookupConfigList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetLookupConfigDetail() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_LookupConfigService().getAllLookupConfigurations();
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        List<Adm.LookupConfig> lookupConfigList = (List<Adm.LookupConfig>) serviceResponse.data;
        
        System.assert( lookupConfigList != null );
        System.assert( lookupConfigList.size() != 0 );
        
        serviceResponse = new ADM_LookupConfigService().getLookupConfigDetail(lookupConfigList.get(0).id);
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveLookupConfigurations() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_LookupConfigService().getAllLookupConfigurations();
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        List<Adm.LookupConfig> lookupConfigList = (List<Adm.LookupConfig>) serviceResponse.data;
        
        System.assert( lookupConfigList != null );
        System.assert( lookupConfigList.size() != 0 );
        
        serviceResponse = new ADM_LookupConfigService().getLookupConfigDetail(lookupConfigList.get(0).id);
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Adm.LookupConfig lookupConfig = (Adm.LookupConfig) serviceResponse.data;
        
        serviceResponse = new ADM_LookupConfigService().saveLookupConfig(lookupConfig);
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        serviceResponse = new ADM_LookupConfigService().saveLookupConfigurations( new List<Adm.LookupConfig> {lookupConfig});
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
    
    static testmethod void testValidateLookupConfiguration() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_LookupConfigService().getAllLookupConfigurations();
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        List<Adm.LookupConfig> lookupConfigList = (List<Adm.LookupConfig>) serviceResponse.data;
        
        System.assert( lookupConfigList != null );
        System.assert( lookupConfigList.size() != 0 );
        
        serviceResponse = new ADM_LookupConfigService().getLookupConfigDetail(lookupConfigList.get(0).id);
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Adm.LookupConfig lookupConfig = (Adm.LookupConfig) serviceResponse.data;
        
        serviceResponse = new ADM_LookupConfigService().validateLookupConfiguration(lookupConfig);
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
        
        Test.stopTest();
    }
}