@IsTest
public with sharing class ManagePricingRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;

    static void createRestContext( final String method, final String httpMethod, final String requestBody, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/pcal/workorder/v1/' + method + '/';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testmethod void getPricingData() {
        
        Test.startTest();

        createRestContext('calculateLinePrice', 'POST', '{}', '');
        ManagePricingRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
}