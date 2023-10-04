@isTest
public class AMGT_AssetHierarchyManager_UT {
    
    @testSetup public static void setup() {
        
        ADM_HierarchyConfigManager_UT.setup();
        
		Map<String,Object> newmap = new Map<String,Object>();
        newmap.put('name','testloc');
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

    testmethod static void testGetRootId() {
        Account accountRecord = [SELECT Id FROM Account]; 
        Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootAccountIdForAccount(accountRecord.Id);
        system.assertEquals(true, rootId == accountRecord.Id); 
    }

    testmethod static void testgetRootAssetIdForAsset() {
        List<Asset> asse1t = [select Id from Asset where ParentId=null];
        Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootAssetIdForAsset(asse1t[0].Id);
        system.assertEquals(true, rootId == asse1t[0].Id); 
    }
    
     testmethod static void testgetRootLocationIdForLocation() {
        Schema.Location asse1t = [select Id from Location];
        Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootLocationIdForLocation(asse1t.Id);
        system.assertEquals(true, rootId == asse1t.Id); 
    } 

    testmethod static void testgetRootLocationIdForAsset() {
        List<Asset> asse1t = [select Id from Asset where ParentId=null];
        Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootLocationIdForAsset(asse1t[0].Id);
        system.assertEquals(true, rootId != asse1t[0].Id); 
    } 

    testmethod static void testGetRootId_InvalidParam() {
        
        try {
            Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootAccountIdForAccount(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetRootAccountIdForAsset() {
        List<Asset> assetRecords = [SELECT Id FROM Asset]; 
        Account accountRecord = [SELECT Id FROM Account]; 
        Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootAccountIdForAsset(assetRecords[0].Id);
        system.assertEquals(true, rootId == accountRecord.Id); 
    }

    testmethod static void testGetRootAccountIdForAsset_InvalidParam() {
        
        try {
            Id rootId = AMGT_AssetHierarchyManager.getInstance().getRootAccountIdForAsset(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testgetAccountHierarchyIds() {
        List<String> recordIds = new List<String>();
        Account acc = [select Id,name from Account];
        recordIds.add('\''+acc.id+'\'');
        List<String> accountIds = new List<String>();
        try {
            AMGT_AssetHierarchyManager.getInstance().getAccountHierarchyIds(recordIds,accountIds);
            System.assert(accountIds!=null);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
           System.assert(false );
        }
    }

    testmethod static void testmapHierarchyNode(){
        List<String> fields = new List<String>();
        fields.add('Name');
        Account acc = [select Id,name from Account];
        List<String> accountIds = new List<String>();
        try {
           Amgt.HierarchyNode node =  AMGT_AssetHierarchyManager.mapHierarchyNode(acc,fields,new Map<string,String>());
            System.assert(node!=null);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
           System.debug('error');
        }
    }

  //  public Amgt.HierarchyConfiguration getFallbackAssetHierarchyConfigurations() {
    testmethod static void testgetFallbackAssetHierarchyConfigurations () {
        Amgt.HierarchyConfiguration conf = AMGT_AssetHierarchyManager.getInstance().getFallbackAssetHierarchyConfigurations();
        System.assert(conf != null);
    }

    testmethod static void testGetAccountNodes() {
        List<Id> recordIds = new List<Id>();
        Account accountRecord = [SELECT Id FROM Account]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account.displayIconName = 'site';
        List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.getHierarchyNodes(recordIds,JSON.serialize(configuration), accountRecord.Id, 'Asset Only');
        configuration.account.displayIconName = 'site';
        System.assert( nodes != null );
    }
    
    testmethod static void testGetLocationNodes() {
        List<Id> recordIds = new List<Id>();
        Schema.location accountRecord = [SELECT Id FROM Location]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.getHierarchyNodes(recordIds,JSON.serialize(configuration), accountRecord.Id, 'Asset Only');
        System.assert( nodes != null );
    }
    testmethod static void testgetLocationAssetNodes() {
        List<Id> recordIds = new List<Id>();
        Schema.location accountRecord = [SELECT Id FROM Location]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        List<Object> nodes = AMGT_AssetHierarchy_LS.getAssetNodesForHierarchyRaw(recordIds,JSON.serialize(configuration), accountRecord.Id, 'Location > Asset',false);
        System.assert( nodes != null );
    }

     testmethod static void testgetAccountAssetNodes() {
        List<Id> recordIds = new List<Id>();
        Account accountRecord = [SELECT Id FROM Account]; 
        recordIds.add(accountRecord.Id);
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        configuration.account.displayIconName = 'site';
        List<Object> nodes = AMGT_AssetHierarchy_LS.getAssetNodesForHierarchyRaw(recordIds,JSON.serialize(configuration), accountRecord.Id, 'Account > Asset',false);
        System.assert( nodes != null );
    }

    testmethod static void testgetAssetNodes() {
        List<ID> recordIds = new List<ID>();
        List<Asset> accountRecord = [SELECT Id FROM Asset];
        for (Asset ast: accountRecord){
            recordIds.add(ast.Id);
        }
        Amgt.HierarchyConfiguration configuration = AMGT_AssetHierarchy_LS.getHierarchyConfiguration();
        List<Amgt.HierarchyNode> nodes = AMGT_AssetHierarchy_LS.getHierarchyNodes(recordIds,JSON.serialize(configuration), accountRecord[0].Id, 'Asset Only');
        System.assert( nodes != null );
    }

    testmethod static void testupdateAssets() {
        List<ID> recordIds = new List<ID>();
        List<Asset> assets = [SELECT Id FROM Asset];
        for (Asset ast: assets){
            ast.status = 'Installed';
        }
        List<Amgt.SaveResponse> nodes = AMGT_AssetHierarchy_LS.updateAssetRecords(JSON.serialize(assets));
        System.assert( nodes != null );
        System.assert( nodes[0].success );
    }
    
}