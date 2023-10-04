@IsTest
public class MetadataRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String endPointUrl, final String httpMethod, final Map<String, String> urlParameters) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/metadata/v1/' + endPointUrl + '/';
        System.debug(loggingLevel.Info , 'URL ' + req.requestURI);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;

        if (urlParameters != null) {
            for (String paramName : urlParameters.keySet()) {
                req.addParameter(paramName, urlParameters.get(paramName));
            }
        }
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testmethod void testGetAllEntityDefinitions() {
        
        Test.startTest();
        
        createRestContext('getAllEntityDefinitions', 'GET', new Map<String, String>{'apiNames' => ''});

        MetadataRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions() {
        
        Test.startTest();
        
        createRestContext('getEntityDefinitions', 'GET', new Map<String, String>{'apiNames' => '["Account","Case"]'});
        MetadataRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions() {
        
        Test.startTest();
        
        createRestContext('getFieldDefinitions', 'GET', new Map<String, String>{'apiNames' => '["Account","Case"]'});
        MetadataRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testEmptyMethod() {
        
        Test.startTest();
        
        createRestContext('', 'GET', null);
        MetadataRestInterface.doGet();
        
		System.assert( res.statusCode == COMM_SvmxRestBase.BAD_REQUEST, res.statusCode);
        
        Test.stopTest();
    }
    
    static testmethod void testUnsupported() {
        
        Test.startTest();
        
        createRestContext('Unsupported', 'GET', null);
        MetadataRestInterface.doGet();
        
		System.assert( res.statusCode == COMM_SvmxRestBase.NOT_FOUND, res.statusCode);
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_invalid() {
        
        Test.startTest();
        
        createRestContext('getEntityDefinitions', 'GET', new Map<String, String>{'apiNames' => '[Account","Case"]'});
        MetadataRestInterface.doGet();
        
		System.assert( res.statusCode == COMM_SvmxRestBase.UNPROCESSABLE_ENTITY, res.statusCode);
        
        Test.stopTest();
    }

    static testmethod void testGetFlowByApiName() {
        
        Test.startTest();
        
        createRestContext('getFlowByApiName', 'GET', new Map<String, String>{'flowApiName' => 'pagelayout'});

        MetadataRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }    
}