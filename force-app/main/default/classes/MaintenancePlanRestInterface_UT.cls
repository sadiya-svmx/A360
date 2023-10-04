@IsTest
public with sharing class MaintenancePlanRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;

    static void createRestContext( final String method, final String httpMethod, final String requestBody, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/mpln/v1/' + method + '/';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    @isTest
    static void testCreateMaintenancePlan() {
        
        Test.startTest();

        createRestContext('createMaintenancePlan', 'POST', '{}', '');
        MaintenancePlanRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);

        //Create dummy instance of class
        MPLN_MaintenancePlanService instance = new MPLN_MaintenancePlanService();
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateMaintenancePlan_Exception() {
        
        Test.startTest();
        
        try {
            createRestContext('', 'POST', '{}', '');
            MaintenancePlanRestInterface.doPost();

            String responseStr = res.responseBody.toString();
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
            
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    @isTest
    static void testAddMaintenanceAssets() {
        
        Test.startTest();

        createRestContext('addMaintenanceAssets', 'POST', '{}', '');
        MaintenancePlanRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    @isTest
    static void testMPLN_InvalidMethod() {
        
        Test.startTest();
        
        try {
            createRestContext('invalidPostMethod', 'POST', '{}', '');
            MaintenancePlanRestInterface.doPost();

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