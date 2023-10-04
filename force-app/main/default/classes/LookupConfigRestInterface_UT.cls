@isTest
public class LookupConfigRestInterface_UT {
    public Static RestRequest req;
    public Static RestResponse res;
    
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
    
    static testmethod void testGetLookupConfiguration_Rest(){
        Test.startTest();
        restUtils('getLookupConfigurations', 'GET', '');
        req.addParameter('objectName', 'Account');
        LookupConfigRestInterface.doGet();
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
	
        Test.stopTest();
    }
    
    static testmethod void testGetLookupConfiguration_InvalidRest(){
        Test.startTest();
        restUtils('xxxxxxxxxxxx', 'GET', '');
        req.addParameter('objectName', 'Account');
        LookupConfigRestInterface.doGet();
		System.assertEquals(res.statusCode, 404);

        Test.stopTest();
    }
    
    Static void restUtils(String endPointUrl, String httpMethod, String serializedRequest){
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/svmx/rest/admin/LookupConfigRestInterface/v1/' + endPointUrl+ '/';
        if((httpMethod == 'GET' || httpMethod == 'DELETE') && serializedRequest != ''){
            req.requestURI += serializedRequest + '/';
        }
        if(httpMethod == 'POST'){
           req.requestBody = Blob.valueOf(serializedRequest);
        }
        System.debug(loggingLevel.Info , 'URL ' + req.requestURI);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        
        RestContext.request = req;
        RestContext.response = res;
    }
}