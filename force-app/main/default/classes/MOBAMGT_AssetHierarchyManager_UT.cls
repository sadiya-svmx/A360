@isTest
public with sharing class MOBAMGT_AssetHierarchyManager_UT {
    
    @testSetup public static void setup() {

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
    static void getHierarchyNodes_inavalidParam1() {
        Boolean isError;
        try {
            MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyNodes(null);
        } catch (Exception e) {
            isError = true;
        }
        System.assert(isError, 'MOBAMGT_AssetHierarchyManager.getHierarchyNodes is accepting invalid parameters');
    }

    @isTest
    static void getHierarchyNodes_location() {

        List<Schema.Location> locationList = (List<Schema.Location>) SvmxDatabase.query([SELECT ID FROM Location Limit 1]);
        Test.startTest();
        
        MobileAmgt.HierarchyNodesRequest request = new MobileAmgt.HierarchyNodesRequest();
        request.recordId = locationList[0].id;
        request.offset = 0;
        request.assetLevel = 1;

        Map<Id, MobileAmgt.HierarchyNode> locationNodeMap = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyNodes(new List<MobileAmgt.HierarchyNodesRequest>{request});

        System.assert((locationNodeMap != null && locationNodeMap.keyset().size() == 1 && locationNodeMap.get(locationList[0].id).totalChildrens == 5), 'Unable to retrieve the location hierarchy nodes');
        Test.stopTest();
    }
    
    @isTest
    static void getHierarchyNodes_asset() {

		final List<Asset> assetRecordList = [SELECT ID FROM Asset LIMIT 5];
        assetRecordList[0].LocationId = null;
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecordList.get(index).ParentId = assetRecordList.get(index - 1).Id;
            assetRecordList.get(index).LocationId = null;
        }
        update assetRecordList;

        Test.startTest();

        MobileAmgt.HierarchyNodesRequest request = new MobileAmgt.HierarchyNodesRequest();
        request.recordId = assetRecordList[0].id;
        request.offset = 0;
        request.assetLevel = 1;

        Map<Id, MobileAmgt.HierarchyNode> assetNodeMap = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyNodes(new List<MobileAmgt.HierarchyNodesRequest>{request});
		
        System.assert((assetNodeMap != null && assetNodeMap.keyset().size() == 1 && assetNodeMap.get(assetRecordList[0].id).totalChildrens == 1), 'Unable to retrieve the asset hierarchy nodes');
        Test.stopTest();
    }
    
    @isTest
    static void getHierarchyNodes_account() {
        List<Account> accountList = (List<Account>) SvmxDatabase.query([SELECT ID FROM Account Limit 1]);

        Test.startTest();

        MobileAmgt.HierarchyNodesRequest request = new MobileAmgt.HierarchyNodesRequest();
        request.recordId = accountList[0].id;
        request.offset = 0;
        request.assetLevel = 1;

        Map<Id, MobileAmgt.HierarchyNode> accountNodeMap = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyNodes(new List<MobileAmgt.HierarchyNodesRequest>{request});
        System.assert((accountNodeMap != null && accountNodeMap.keyset().size() == 1 && accountNodeMap.get(accountList[0].id).totalChildrens == 5), 'Unable to retrieve the Account hierarchy nodes');
        Test.stopTest();
    }
    
    @isTest
    static void getHierarchyTypeRootNode_inavalidParam1() {
        Boolean isError;
        try {
            MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode('');
        } catch (Exception e) {
            isError = true;
        }
        System.assert(isError, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is accepting invalid parameters');
    }
    
    @isTest
    static void getHierarchyTypeRootNode_inavalidParam2() {
        Boolean isError;
        try {
            MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode(null);
        } catch (Exception e) {
            isError = true;
        }
        System.assert(isError, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is accepting invalid parameters');
    }
    
    @isTest
    static void getHierarchyTypeRootNode_Asset() {
        final List<Asset> assetRecordList = [SELECT ID FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }

        update assetRecordList;
        
        Test.startTest();
        MobileAmgt.RootHierarchyNode rootNode = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode(assetRecordList.get(4).Id);
        System.assert(rootNode != null, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning null.');
        System.assert(rootNode.childNodes.size() == 1, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is not able to return the root hierarchy.');
        Test.stopTest();
    }
    
    @isTest
    static void getHierarchyTypeRootNode_Location() {
        List<Schema.Location> locationList = (List<Schema.Location>) SvmxDatabase.query([SELECT ID FROM Location Limit 1]);
        Test.startTest();
        MobileAmgt.RootHierarchyNode rootNode = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode(locationList.get(0).Id);
        System.assert(rootNode != null, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning null.');
        System.assert(rootNode.childNodes.size() == 5 , 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is not able to return the root hierarchy.');
        Test.stopTest();
    }

    // When location is not present on the root asset in case of location_to_asset, fallback to asset_only
    @isTest
    static void getHierarchyTypeRootNode_Location2() {

        final List<Asset> assetRecordList = [SELECT ID FROM Asset LIMIT 5];
        assetRecordList[0].LocationId = null;
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecordList.get(index).ParentId = assetRecordList.get(index - 1).Id;
            assetRecordList.get(index).LocationId = null;
        }
        update assetRecordList;
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.RootHierarchyNode rootNode = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode(assetRecordList[4].Id);
        System.assert(rootNode != null, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning null.');
        System.assert(rootNode.childNodes.size() == 1, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is not able to return the root hierarchy.');
     	System.assert(rootNode.id == assetRecordList[0].Id , 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning the incorrect root id.');
        Test.stopTest();
    }
    
    @isTest
    static void getHierarchyTypeRootNode_asset2() {
        final List<Asset> assetRecordList = [SELECT ID FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.ASSET_ONLY;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.RootHierarchyNode rootNode = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode(assetRecordList.get(4).Id);
        System.assert(rootNode != null, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning null.');
        System.assert(rootNode.childNodes.size() == 1, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is not able to return the root hierarchy.');
        Test.stopTest();
    }
    
    @isTest
    static void getHierarchyTypeRootNode_account() {
        final List<Asset> assetRecordList = [SELECT AccountId FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.ACCOUNT_TO_ASSET;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.RootHierarchyNode rootNode = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyTypeRootNode(assetRecordList.get(4).Id);
        System.assert(rootNode != null, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning null.');
        System.assert(rootNode.childNodes.size() == 1, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is not able to return the root hierarchy.');
        System.assert(rootNode.id ==  assetRecordList[0].AccountId, 'MOBAMGT_AssetHierarchyManager.getHierarchyTypeRootNode is returning the incorrect root id.');
        Test.stopTest();
    }

    @isTest
    static void retrieveHierarchyTypeRootNode_invalidParam() {
        Boolean isError;
        String errorMsg;
        try {
            Test.startTest();
            MOBAMGT_AssetHierarchyManager.getInstance().retrieveHierarchyTypeRootNode(null);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
            errorMsg = e.getMessage();
        }
        System.assert(isError, 'MOBAMGT_AssetHierarchyManager.retrieveHierarchyTypeRootNode is accepting invalid parameters');
    }

    @isTest
    static void retrieveSearchedAssets_invalidParam1(){
        Boolean isError;
        String errorMsg;
        try {
            Test.startTest();
            MOBAMGT_AssetHierarchyManager.getInstance().retrieveSearchedAssets(null);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
            errorMsg = e.getMessage();
        }
        System.assert(isError, 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is accepting invalid parameters');
        System.assert(errorMsg == System.Label.Error_AssetHierarchy_ServerError, 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is accepting invalid parameters');
    }

    @isTest
    static void retrieveSearchedAssets_AssetOnly(){
        final List<Asset> assetRecordList = [SELECT Name FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        System.debug('assetRecordList '+ assetRecordList);
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.ASSET_ONLY;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.AssetHierarchySearch assetHiearchySearchRequest = new MobileAmgt.AssetHierarchySearch();
        assetHiearchySearchRequest.recordId = assetRecordList[3].Id;
        assetHiearchySearchRequest.searchTerm = 'Asset4';
        assetHiearchySearchRequest.hierarchyType = MOBAMGT_AssetHierarchyManager.ASSET_ONLY;
        assetHiearchySearchRequest.actualRootId = assetRecordList[0].Id;
        assetHiearchySearchRequest.assetHierarchyId = assetRecordList[0].Id;

        List<Asset> assetList = MOBAMGT_AssetHierarchyManager.getInstance().retrieveSearchedAssets(assetHiearchySearchRequest);

        System.assert(assetList != null, 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is returning null.');

        Test.stopTest();
    }

    @isTest
    static void retrieveSearchedAssets_LocationToAsset(){
        final List<Asset> assetRecordList = [SELECT Name FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        System.debug('assetRecordList '+ assetRecordList);
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.AssetHierarchySearch assetHiearchySearchRequest = new MobileAmgt.AssetHierarchySearch();
        assetHiearchySearchRequest.recordId = assetRecordList[3].Id;
        assetHiearchySearchRequest.searchTerm = 'Asset4';
        assetHiearchySearchRequest.hierarchyType = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;
        assetHiearchySearchRequest.actualRootId = assetRecordList[0].Id;
        assetHiearchySearchRequest.assetHierarchyId = [Select Id FROM Location LIMIT 1].Id;

        List<Asset> assetList = MOBAMGT_AssetHierarchyManager.getInstance().retrieveSearchedAssets(assetHiearchySearchRequest);

        System.assert(!assetList.isEmpty(), 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is returning null.');

        Test.stopTest();
    }

    @isTest
    static void retrieveSearchedAssets_AccountToAsset(){
        final List<Asset> assetRecordList = [SELECT Name FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        System.debug('assetRecordList '+ assetRecordList);
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.ACCOUNT_TO_ASSET;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.AssetHierarchySearch assetHiearchySearchRequest = new MobileAmgt.AssetHierarchySearch();
        assetHiearchySearchRequest.recordId = assetRecordList[3].Id;
        assetHiearchySearchRequest.searchTerm = 'Asset4';
        assetHiearchySearchRequest.hierarchyType = MOBAMGT_AssetHierarchyManager.ACCOUNT_TO_ASSET;
        assetHiearchySearchRequest.actualRootId = assetRecordList[0].Id;
        assetHiearchySearchRequest.assetHierarchyId = [Select Id FROM Account LIMIT 1].Id;

        List<Asset> assetList = MOBAMGT_AssetHierarchyManager.getInstance().retrieveSearchedAssets(assetHiearchySearchRequest);

        System.assert(assetList != null, 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is returning null.');

        Test.stopTest();
    }

    @isTest
    static void retrieveSearchedAssets_Location(){
        final List<Asset> assetRecordList = [SELECT Name FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        System.debug('assetRecordList '+ assetRecordList);
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;
     	upsert assetHierarchyConfig;

        Test.startTest();
        MobileAmgt.AssetHierarchySearch assetHiearchySearchRequest = new MobileAmgt.AssetHierarchySearch();
        assetHiearchySearchRequest.recordId = [Select Id FROM Location LIMIT 1].Id;
        assetHiearchySearchRequest.searchTerm = 'Location';
        assetHiearchySearchRequest.hierarchyType = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;

        List<Asset> assetList = MOBAMGT_AssetHierarchyManager.getInstance().retrieveSearchedAssets(assetHiearchySearchRequest);

        System.assert(assetList != null, 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is returning null.');

        Test.stopTest();
    }

    @isTest
    static void retrieveSearchedAssets_Account(){
        final List<Asset> assetRecordList = [SELECT Name FROM Asset LIMIT 5];
        // Form the Asset hierarchy
        for(Integer index=1; index<5; index++){
            Asset assetRecord = assetRecordList.get(index);
            assetRecord.ParentId = assetRecordList.get(index - 1).Id;
        }
        update assetRecordList;
        System.debug('assetRecordList '+ assetRecordList);
        
        CONF_CSET_AssetHierarchy__c assetHierarchyConfig = CONF_CSET_AssetHierarchy__c.getInstance();
        assetHierarchyConfig.HierarchyTypeForAsset__c = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;
     	upsert assetHierarchyConfig;

        List<Account> accList = [Select Name FROM Account LIMIT 1];

        Test.startTest();
        MobileAmgt.AssetHierarchySearch assetHiearchySearchRequest = new MobileAmgt.AssetHierarchySearch();

        assetHiearchySearchRequest.recordId = accList[0].Id;
        assetHiearchySearchRequest.searchTerm = accList[0].Name;
        assetHiearchySearchRequest.hierarchyType = MOBAMGT_AssetHierarchyManager.LOCATION_TO_ASSET;

        List<Asset> assetList = MOBAMGT_AssetHierarchyManager.getInstance().retrieveSearchedAssets(assetHiearchySearchRequest);

        System.assert(assetList != null, 'MOBAMGT_AssetHierarchyManager.retrieveSearchedAssets is returning null.');

        Test.stopTest();
    }

    @isTest
    static void getHierarchyConfiguration(){

        Test.startTest();
        MobileAmgt.HierarchyConfiguration hierarchyConfiguration = MOBAMGT_AssetHierarchyManager.getInstance().getHierarchyConfiguration();

        System.assert(hierarchyConfiguration != null, 'MOBAMGT_AssetHierarchyManager.getHierarchyConfiguration is returning null.');

        Test.stopTest();
    }
}