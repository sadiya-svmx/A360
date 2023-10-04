@IsTest
public class MappingRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/mapping/v1/' + method + '/';
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
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
    }
    
    static testmethod void testGetAllObjectMappings() {
        
        Test.startTest();
        
        createRestContext('getAllObjectMappings', 'GET', '', '');
        MappingRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingsByHeaderObject() {
        
        Test.startTest();
        
        createRestContext('getObjectMappingsByHeaderObject', 'GET', '', '');
        MappingRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByHeaderObject() {
        
        Test.startTest();
        
        createRestContext('getObjectValueMappingsByHeaderObject', 'GET', '', '');
        MappingRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMappings() {
        List<Adm.ObjectMapping> objectMappings = ADM_ObjectMappingManager.getInstance().getAllObjectMappingsWithDetails();

        Test.startTest();
        
        createRestContext('saveObjectMappings', 'POST', '', JSON.serialize(objectMappings));
        MappingRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }

    static testmethod void testDeleteObjectMapping() {
        List<SVMXA360__CONF_ObjectMapping__c> mappings = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c LIMIT 1];
        Test.startTest();
        
        createRestContext('deleteObjectMapping', 'DELETE', '', mappings[0].id);
        MappingRestInterface.doDelete();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testDoGet_MappinginvalidMethod() {
        
        Test.startTest();
        
        createRestContext('', 'GET', '', '');
        MappingRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.BAD_REQUEST, res.statusCode);
        
        Test.stopTest();
    }

    static testmethod void testDoGet_Unsupported() {
        
        Test.startTest();
        
        createRestContext('Unsupported', 'GET', '', '');
        MappingRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.NOT_FOUND, res.statusCode);
        
        Test.stopTest();
    }
}