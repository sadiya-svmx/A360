@IsTest
public class ExpressionRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/expression/v1/' + method + '/';
        if((httpMethod == 'GET' || httpMethod == 'DELETE') && argument != ''){
            req.requestURI += argument+'/';
        }
        if(httpMethod == 'POST'){
            req.requestBody = Blob.valueOf(argument);
        }
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.addParameter('objectName', param );
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    @testSetup public static void setup() {
        ADM_ExpressionHandler_UT.setup();
    }
    
    static testmethod void testGetAllExpressions() {
        
        Test.startTest();
        
        createRestContext('getAllExpressions', 'GET', '', '');
        ExpressionRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetExpressions() {
        
        Test.startTest();
        
        createRestContext('getExpressions', 'GET', 'Account', '');
        ExpressionRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }

    static testmethod void testGetExpressionDetail() {
        
        Test.startTest();
        List<SVMXA360__CONF_Expression__c> expressions = [SELECT Id FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressions.size() == 1);
        createRestContext('getExpressionDetail', 'GET', '', expressions[0].Id);
        ExpressionRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetExpressionsByType() {
        Test.startTest();
        List<SVMXA360__CONF_Expression__c> expressions = [SELECT Id, SVMXA360__ExpressionType__c FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressions.size() == 1);
        createRestContext('getExpressionsByType', 'GET', 'Account', '');
        if(req != null){
            req.addParameter('expressionType', expressions[0].SVMXA360__ExpressionType__c);
        }
        ExpressionRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();    
    }

    static testmethod void testGetExpressionsByTypeInvalidObject() {
        Test.startTest();
        List<SVMXA360__CONF_Expression__c> expressions = [SELECT Id, SVMXA360__ExpressionType__c FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressions.size() == 1);
        createRestContext('getExpressionsByType', 'GET', '', '');
        if(req != null){
            req.addParameter('expressionType', expressions[0].SVMXA360__ExpressionType__c);
        }
        ExpressionRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();    
    }
    
    static testmethod void testGetExpressionWithDetails() {
        
        Test.startTest();
        List<SVMXA360__CONF_Expression__c> expressions = [SELECT Id FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressions.size() == 1);
        createRestContext('getExpressionWithDetails', 'GET', '', expressions[0].Id);
        ExpressionRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }

    static testmethod void testSaveExpression() {
        
        
        List<SVMXA360__CONF_Expression__c> expressions = [SELECT Id FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressions.size() == 1);
        createRestContext('getExpressionWithDetails', 'GET', '', expressions[0].Id);
        ExpressionRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        Test.startTest();

        object requestObject = (object)deserializedResponse.get('data');
        createRestContext('saveExpression', 'POST', '',JSON.serialize(requestObject));
		ExpressionRestInterface.doPost();	
        responseStr = res.responseBody.toString(); 
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }

    static testmethod void testDeleteExpression() {
        
        Test.startTest();
        List<SVMXA360__CONF_Expression__c> expressions = [SELECT Id FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressions.size() == 1);
        createRestContext('deleteExpression', 'DELETE', '', expressions[0].Id);
        ExpressionRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testDoGet_ExpressioninvalidMethod() {
        
        Test.startTest();
        
        createRestContext('', 'GET', '', '');
        ExpressionRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.BAD_REQUEST, res.statusCode);
        
        Test.stopTest();
    }

    static testmethod void testDoGet_Unsupported() {
        
        Test.startTest();
        
        createRestContext('Unsupported', 'GET', '', '');
        ExpressionRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.NOT_FOUND, res.statusCode);
        
        Test.stopTest();
    }
}