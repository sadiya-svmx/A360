@IsTest
public with sharing class ServiceContractRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;

    static void createRestContext( final String method, final String httpMethod, final String requestBody, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/scon/v1/' + method + '/';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testmethod void testCreateServiceContract() {
        
        Test.startTest();

        createRestContext('createServiceContract', 'POST', '{}', '');
        ServiceContractRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testCreateServiceContract_Exception() {
        
        Test.startTest();
        
        try {
            createRestContext('', 'POST', '{}', '');
            ServiceContractRestInterface.doPost();

            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
            
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }
    
    static testmethod void testCreateContractLineItems() {
        
        Test.startTest();

        createRestContext('createContractLineItems', 'POST', '{}', '');
        ServiceContractRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testCreateEntitledServices() {
        
        Test.startTest();

        createRestContext('createEntitledService', 'POST', '{}', '');
        ServiceContractRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testCancelServiceContract() {
        
        Test.startTest();

        createRestContext('cancelServiceContract', 'POST', '{}', '');
        ServiceContractRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testSCON_InvalidMethod() {
        
        Test.startTest();
        
        try {
            createRestContext('invalidPostMethod', 'POST', '{}', '');
            ServiceContractRestInterface.doPost();

            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
            
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }        
        Test.stopTest();
    }
}