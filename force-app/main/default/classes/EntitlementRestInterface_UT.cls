@IsTest
public class EntitlementRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/entitlement/v1/' + method + '/';
        if( String.isNotBlank(argument)  ) {
            req.requestURI = req.requestURI + argument + '/';
        }
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.addParameter('apiName', param );
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    @testSetup public static void setup() {
        ADM_EntitlementRuleManager_UT.setup();
    }
    
    static testmethod void testGetAllEntitlementRules() {
        
        Test.startTest();
        
        createRestContext('getAllEntitlementRules', 'GET', '', '');
        EntitlementRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntitlementRules() {
        
        Test.startTest();
        
        createRestContext('getEntitlementRules', 'GET', 'WorkOrder', '');
        EntitlementRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testSaveEntitlementRule() {
        
        Test.startTest();
        
        createRestContext('saveEntitlementRule', 'POST', '', '');
        EntitlementRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testUpdateRuleSequence() {
        
        Test.startTest();
        
        createRestContext('updateRuleSequence', 'POST', '', '');
        EntitlementRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteEntitlementRule() {
        
        Test.startTest();
        
        createRestContext('deleteEntitlementRule', 'DELETE', '', 'delete');
        EntitlementRestInterface.doDelete();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testDoGet_invalidMethod() {
        
        Test.startTest();
        
        createRestContext('', 'GET', '', '');
        EntitlementRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.BAD_REQUEST, res.statusCode);
        
        Test.stopTest();
    }
    
    static testmethod void testDoGet_Unsupported() {
        
        Test.startTest();
        
        createRestContext('Unsupported', 'GET', '', '');
        EntitlementRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.NOT_FOUND, res.statusCode);
        
        Test.stopTest();
    }
}