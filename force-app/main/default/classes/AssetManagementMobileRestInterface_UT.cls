@isTest
public with sharing class AssetManagementMobileRestInterface_UT {
    
    private static RestRequest req;
    private static RestResponse res;

    static void createRestContext( final String method, final String httpMethod, final Map<String, String> paramMap, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/mobile/assetManagement/v1/' + method + '/';
        if((httpMethod == 'GET') && String.isNotEmpty(argument)){
            req.requestURI += argument+'/';
        }
        if(httpMethod == 'POST'){
            req.requestBody = Blob.valueOf(argument);
        }
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        if(paramMap != null && !paramMap.isEmpty()){
            for(String mapKey : paramMap.keySet()){
                req.addParameter(mapKey, paramMap.get(mapKey));
            }
            
        }
        
        RestContext.request = req;
        RestContext.response = res;
    }

    static void setupData() {

        final Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');
        List<Asset> assetRecordList = (List<Asset>) SvmxTestDataFactory.createSObjectList('Asset', 5);
        Schema.Location loc = (Schema.Location)SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{'Name' => 'Test Location', 'ExternalReference' => 'test123'});
        for( Integer index = 0; index < 5; index++ ) {
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.AccountId = accountRecord.Id;
            assetRecord.LocationId = loc.Id;
        }
        insert assetRecordList;
    }

    @isTest
    static void getHierarchyTypeRootNode() {
        setupData();
        List<Asset> assetList = [SELECT ID FROM Asset LIMIT 5];
        createRestContext('getHierarchyTypeRootNode', 'GET', null, assetList.get(3).id);
        
        Test.startTest();
        AssetManagementMobileRestInterface.doGet();

        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);

        System.assertEquals(deserializedResponse.get('success'), true, 'Unable to fetch the hierarchy type root node.');
        Test.stopTest();
    }

    @isTest
    static void getHierarchyTypeRootNode_invalidParam() {
        createRestContext('getHierarchyTypeRootNode', 'GET', null, '');
        
        Test.startTest();
        AssetManagementMobileRestInterface.doGet();

        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);

        System.assertEquals(deserializedResponse.get('success'), false, 'getHierarchyTypeRootNode method is accepting the incorrect parameters.');
        Test.stopTest();
    }

    @isTest
    static void getHierarchyConfiguration() {
        createRestContext('getHierarchyConfiguration', 'GET', null, '');
        
        Test.startTest();
        AssetManagementMobileRestInterface.doGet();

        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);

        System.assertEquals(deserializedResponse.get('success'), true, 'Unable to fetch the hierarchy configuration.');
        Test.stopTest();
    }
}