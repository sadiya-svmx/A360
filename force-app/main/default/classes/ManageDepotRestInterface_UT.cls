@IsTest
public with sharing class ManageDepotRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    @TestSetup
    static void createData(){
        Product2 prod = (Product2) SvmxTestDataFactory.insertSObject('Product2');
        //Location loc = (Location) SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{'Name' => 'Test Location', 'LocationType' => 'Warehouse'});
        //SVMXA360__LocationServices__c locationService1 = (SVMXA360__LocationServices__c) SvmxTestDataFactory.insertSObject('SVMXA360__LocationServices__c', new Map<String,Object>{'SVMXA360__Location__c' => loc.Id, 'SVMXA360__Product__c' => prod.Id});
        //SVMXA360__LocationServices__c locationService2 = (SVMXA360__LocationServices__c) SvmxTestDataFactory.insertSObject('SVMXA360__LocationServices__c', new Map<String,Object>{'SVMXA360__Location__c' => loc.Id, 'SVMXA360__ServiceType__c' => 'Depot'});
    }

    static void createRestContext( final String method, final String httpMethod, final String requestBody, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/depot/returns/v1/' + method + '/';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testmethod void getdepotlocationTest() {
        
        Test.startTest();
        Product2 prod = [Select Id from Product2 limit 1];
        createRestContext('getDepotLocation', 'POST', '[{"recordId": "1","productId": "","productFamily": "","sourceField": "ShipmentType","sourceFieldValue": "Depot","keyField": "SVMXA360__ServiceType__c"},{"recordId": "2","productId":"'+prod.Id+'","productFamily": "","sourceField": "","sourceFieldValue": "","keyField": ""}]', '');
        ManageDepotRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
}