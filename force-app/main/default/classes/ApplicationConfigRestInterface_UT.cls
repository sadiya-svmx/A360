@IsTest
public class ApplicationConfigRestInterface_UT {
    private static RestRequest req;
    private static RestResponse res;
    private static String jsonData = ' [{"masterText": "Return Order Management","context" : "wizardTitle","key" : "Return Order Management_wizardTitle","languageValues" : [{"name" : "fi","value" : "Palautustilaus Management"},{"name" : "de","value" : "Verwaltung von Rückgabeaufträgen"}, {"name" : "nl","value" : "Beheer van retourorders"}]}]';
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/appconfig/v1/' + method + '/';
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

    static testmethod void testGetAllConfigTranslations() {
        
        Test.startTest();
        
        createRestContext('getAllConfigTranslations', 'GET', '', '');
        ApplicationConfigRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }


    static testmethod void testSaveConfigTranslations() {
        
        Test.startTest();
        
        
        createRestContext('saveConfigTranslations', 'POST', '', jsonData);
        ApplicationConfigRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }

}