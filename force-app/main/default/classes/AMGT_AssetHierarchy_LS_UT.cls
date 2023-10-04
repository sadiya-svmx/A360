@isTest
private class AMGT_AssetHierarchy_LS_UT {

    @testSetup public static void setup() {
        
        ADM_HierarchyConfigManager_UT.setup();

        final Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');
        Schema.Location loc = new Schema.Location();
        loc.name='test';
        insert(loc);
        final List<Asset> assetRecordList = (List<Asset>) SvmxTestDataFactory.createSObjectList('Asset', 5);
        for( Integer index = 0; index < 5; index++ ) {
            assetRecordList.get(index).AccountId = accountRecord.Id;
            assetRecordList.get(index).LocationId = loc.Id;
        }
        insert assetRecordList;
    }

    @isTest
    private static void testGetRootId() {
        Id rootId = AMGT_AssetHierarchy_LS.getRootId(null, null, false); 
        system.assertEquals(true, rootId == null);
    }

    @isTest
    private static void testGetHierarchyNodes() {
        Exception captor;
        try{
            List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.getHierarchyNodes(null, null, null, null); 
        } 
        catch(Exception e) {
            captor = e;
        }
        system.assertEquals(true, captor != null);
    }

    testmethod static void testGetRootId_AccountAssetOrder() {
        Account accountRecord = [SELECT Id FROM Account]; 
        Id rootId = AMGT_AssetHierarchy_LS.getRootId(accountRecord.Id, 'Account > Asset', false);
        system.assertEquals(true, rootId == accountRecord.Id); 
    }

    testmethod static void testGetRootId_AccountAssetOrderWithAsset() {
        List<Asset> assetRecords = [SELECT Id FROM Asset]; 
        Account accountRecord = [SELECT Id FROM Account]; 
        Id rootId = AMGT_AssetHierarchy_LS.getRootId(assetRecords[0].Id, 'Account > Asset', false);
        system.assertEquals(true, rootId == accountRecord.Id); 
    }

    testmethod static void testGetHierarchyConfiguration() {
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        System.assert( configuration != null );
    }

    testmethod static void testGetHierarchyNodes_Account() {
        List<Id> recordIds = new List<Id>();
        Account accountRecord = [SELECT Id FROM Account]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.getHierarchyNodes(recordIds,JSON.serialize(configuration), accountRecord.Id, 'Asset Only');
        System.assert( nodes != null );
    }

    testmethod static void testfetchFirstFiveLevelAccounts_Account() {
        List<Id> recordIds = new List<Id>();
        Account accountRecord = [SELECT Id FROM Account]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.fetchFirstFiveLevelAccounts(accountRecord.Id,JSON.serialize(configuration));
        System.assert( nodes != null );
    }

    testmethod static void testfetchfinalFiveLevelAccounts_Account() {
        List<Id> recordIds = new List<Id>();
        Account accountRecord = [SELECT Id FROM Account]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.fetchfinalFiveLevelAccounts(accountRecord.Id,JSON.serialize(configuration));
        System.assert( nodes != null );
    }

    testmethod static void testgetHierarchyNodesNotification() {
        List<Id> recordIds = new List<Id>();
        List<Asset> assetRecords = [SELECT Id FROM Asset]; 
        recordIds.add(assetRecords[0].Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();

        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        List<Amgt.NotificationDetails> nodes = AMGT_AssetHierarchy_LS.getHierarchyNodesNotification(recordIds, 'Asset Only', JSON.serialize(configuration));
        System.assert( nodes != null );
    }

    testmethod static void testfindAssetsOfRelatedParent() {
        List<Id> recordIds = new List<Id>();
        List<Asset> assetRecords = [SELECT Id FROM Asset]; 
        recordIds.add(assetRecords[0].Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();

        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        String timeinMillis = '123456789';
        Schema.Location loc = [select Id from Location];
        Amgt.SearchResult nodes = AMGT_AssetHierarchy_LS.findAssetsOfRelatedParent('test', JSON.serialize(configuration),loc.Id,timeinMillis);
        System.assert( nodes != null );
        System.assert( nodes.timestampInMills == timeinMillis );
    }

    testmethod static void testfindAssetsOfRelatedParent_Account() {
        List<Id> recordIds = new List<Id>();
        List<Asset> assetRecords = [SELECT Id FROM Asset]; 
        recordIds.add(assetRecords[0].Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();

        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        String timeinMillis = '123456789';
        Account loc = [select Id from Account];
        Amgt.SearchResult nodes = AMGT_AssetHierarchy_LS.findAssetsOfRelatedParent('test', JSON.serialize(configuration),loc.Id,timeinMillis);
        System.assert( nodes != null );
        System.assert( nodes.timestampInMills == timeinMillis );
    }

    testmethod static void testgetAssetHierarchyByRelatedParent() {
        List<Id> recordIds = new List<Id>();
        List<Asset> assetRecords = [SELECT Id FROM Asset]; 
        recordIds.add(assetRecords[0].Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        String timeinMillis = '123456789';
        Schema.Location loc = [select Id from Location];
        Amgt.HierarchyNode nodes = AMGT_AssetHierarchy_LS.getAssetHierarchyByRelatedParent(assetRecords[0].Id, JSON.serialize(configuration),loc.Id,'Location > Asset');
        System.assert( nodes != null );
    }

    testmethod static void testfetchAssetsForGivenParentRaw() {
        Schema.Location loc = [select Id from Location];
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        String timeinMillis = '123456789';
        List<SObject> nodes = AMGT_AssetHierarchy_LS.fetchAssetsForGivenParentRaw(loc.Id,'Assets', JSON.serialize(configuration),'1234');
        System.assert( nodes != null );
    }

    testmethod static void testNegativefetchAssetsForGivenParentRaw() {
        Schema.Location loc = [select Id from Location];
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account = createConfigurationDetail('account', 'standard:account', true, true);
        configuration.asset = createConfigurationDetail('asset', 'standard:asset_object', true, true);
        configuration.location = createConfigurationDetail('location', 'standard:location', true, true);

        configuration.location.fields.add(createConfigurationField('LocationType', 1));
        configuration.location.fields.add(createConfigurationField('VisitorAddressId', 2));
        configuration.location.fields.add(createConfigurationField('IsInventoryLocation', 3));

        configuration.asset.fields.add(createConfigurationField('SerialNumber', 1));
        configuration.asset.fields.add(createConfigurationField('Product2Id', 2));
        configuration.asset.fields.add(createConfigurationField('InstallDate', 3));
        configuration.asset.fields.add(createConfigurationField('Status', 4));
        configuration.asset.fields.add(createConfigurationField('RecordTypeId', 5));

        configuration.account.fields.add(createConfigurationField('Type', 1));

        configuration.account.displayIconName = 'site';
        String timeinMillis = '123456789';
        try{
            List<SObject> nodes = AMGT_AssetHierarchy_LS.fetchAssetsForGivenParentRaw(loc.Id,'Assets1234', JSON.serialize(configuration),'1234');
            System.assert( nodes != null );
        } catch(Exception e) {
            System.assert(e.getMessage()!= null,'Error message is null');
        }
       
    }

    private static Amgt.HierarchyConfigurationDetail createConfigurationDetail( String objectName, String iconName, Boolean enableSPMWizards, Boolean defaultRecordActions) {
        Amgt.HierarchyConfigurationDetail config = new Amgt.HierarchyConfigurationDetail();

        config.objectApiName = objectName;
        config.displayIconName = iconName;
        config.enableSPMWizards = enableSPMWizards;
        config.defaultRecordActions = defaultRecordActions;
        config.fields = new List<Amgt.HierarchyConfigurationField>();

        return config;
    }

    private static Amgt.HierarchyConfigurationField createConfigurationField( String fieldApiName, Integer sequence) {
        Amgt.HierarchyConfigurationField config = new Amgt.HierarchyConfigurationField();

        config.fieldApiName = fieldApiName;
        config.sequence = sequence;

        return config;
    }


}