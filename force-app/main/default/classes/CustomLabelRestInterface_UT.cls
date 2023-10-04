@IsTest
public class CustomLabelRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String method, final String httpMethod ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/label/v1/' + method + '/';
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testmethod void testGetEntitlementCustomLabels() {
        
        Test.startTest();
        
        createRestContext('getEntitlementCustomLabels', 'GET');
        CustomLabelRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
}