@IsTest
public class ConfigurationUsageRestInterface_UT {
    private static RestRequest req;
    private static RestResponse res;
    private static String jsonData = ' [{"entityType": "RecordPage","entityLabel" : "A360 - Work Order Record Page","entityName" : "SVMXA360__WorkOrderRecordPage"}]';

    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/configuration/usage/v1/' + method + '/';
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

    static testmethod void testGetAllConfigurationUsages() {
        
        Test.startTest();
        
        createRestContext('getAllConfigurationUsages', 'GET', '', '');
        ConfigurationUsageRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }


    static testmethod void testSaveConfigurationUsages() {
        
        Test.startTest();
        
        
        createRestContext('saveConfigurationUsages', 'POST', '', jsonData);
        ConfigurationUsageRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }

}