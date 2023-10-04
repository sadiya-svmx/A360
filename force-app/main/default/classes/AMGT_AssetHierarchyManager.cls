@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
/* sfge-disable ApexFlsViolationRule */
public with sharing class AMGT_AssetHierarchyManager {

    public final static string ACCOUNT = 'account';
    public final static string ASSET = 'asset';
    public final static string LOCATION = 'location';
    public final static string LOCATION_THEN_ASSET = 'Location > Asset';
    public final static string ASSET_ONLY = 'Asset Only';
    public final static string ACCOUNT_THEN_ASSET = 'Account > Asset';

    public static Map<Schema.SObjectType, Schema.DescribeSObjectResult> cachedDescribeObjectName = new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();
    public COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();

    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final AMGT_AssetHierarchyManager instance = new AMGT_AssetHierarchyManager();

    /**
     * Public method to retrieve instance of this class.
     */
    public static AMGT_AssetHierarchyManager getInstance() {
        return instance;
    }

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public AMGT_AssetHierarchyManager(){}

    public Id getRootAccountIdForAccount(Id primaryRecordId) {

        System.debug( LoggingLevel.DEBUG, 'getRootAccountIdForAccount() - enter; primaryRecordId= ' + primaryRecordId );

        Id rootId = primaryRecordId;

        try {

            if( String.isBlank( primaryRecordId ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' primaryRecordId= ' + primaryRecordId );
            }
            List<Account> accounts = SvmxDatabase.query([SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.Parent.ParentId FROM Account WHERE Id = :rootId]);
        
            if (accounts[0].ParentId != null) {
                if (accounts[0].Parent.ParentId != null) {
                    rootId = evaluateRootId(accounts[0], rootId);
                } else {
                    rootId = accounts[0].ParentId;
                }
            } else {
                rootId = accounts[0].Id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getRootAccountIdForAccount() : Failed to retrieve root account. Error=' + e.getMessage() );
            throw e;
        } 
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getRootAccountIdForAccount() : Failed to retrieve Root Account. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRootAccountIdForAccount() - exit; rrootId =' + rootId);
        }

        return rootId;
    }

    public Id evaluateRootId( Account accountRecord, Id rootId) {

        if (accountRecord.Parent.Parent.ParentId != null) {
            if (accountRecord.Parent.Parent.Parent.ParentId != null) {
                if (accountRecord.Parent.Parent.Parent.Parent.ParentId != null) {
                    rootId = getRootAccountIdForAccount(accountRecord.Parent.Parent.Parent.Parent.ParentId);
                } else {
                    rootId = accountRecord.Parent.Parent.Parent.ParentId;
                }
            } else {
                rootId = accountRecord.Parent.Parent.ParentId;
            }
        } else {
            rootId = accountRecord.Parent.ParentId;
        }
        
        return rootId;
    }

    public Id getRootAccountIdForAsset(Id primaryRecordId) {

        System.debug( LoggingLevel.DEBUG, 'getRootAccountIdForAsset() - enter; primaryRecordId= ' + primaryRecordId );

        if( String.isBlank(primaryRecordId) ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' primaryRecordId= ' + primaryRecordId );
        }

        Id rootId = primaryRecordId;

        try {

            List<Asset> primaryAsset = (List<Asset>)SvmxDatabase.query([SELECT Id, AccountId, RootAssetId, RootAsset.AccountId FROM Asset WHERE Id = :primaryRecordId]);
            if(primaryAsset.size() > 0) {
                String rootAccountId = primaryAsset[0].RootAsset.AccountId != null ? getRootAccountIdForAccount(primaryAsset[0].RootAsset.AccountId) : null; 
                String rootAssetId = String.valueOf(primaryAsset[0].RootAssetId);
                rootId = rootAccountId != null && rootAccountId != '' ? rootAccountId : rootAssetId;
            }

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getRootAccountIdForAsset() : Failed to retrieve root account for the asset. Error=' + e.getMessage() );
            throw e;
        } 
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getRootAccountIdForAsset() : Failed to retrieve Root Account for the asset. Error=' + e.getMessage() );
            throw e;
        }

        return rootId;
    }
    
    public String getExpression (List<Adm.Expression> expressions,String buildCriteria){
        buildCriteria = '';
        for(Adm.Expression expression: expressions){
            if (String.isNotBlank(buildCriteria)){
                buildCriteria += ' AND ';
            }
            buildCriteria += ' (' + COMM_ExpressionUtils.getInstance().buildCriteria(expression)+' )';
        }
        return buildCriteria;
    }

    public List<Amgt.HierarchyNode> getAccountNodes(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId) {

        System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - enter; recordIds= ' + recordIds );

        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        Schema.DescribeSobjectResult accountDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Account');
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> accountFieldDescribeMap = accountDescribe.fields.getMap();
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();

        try {
            
            List<String> accountFields = new List<String>();
            Set<String> accountFieldSet = new Set<String>{'Id','Name','ParentId'};
            List<String> assetFields = new List<String>();
            Map<String, String> accountLookupFields = new Map<String, String>();
            Map<String, String> assetLookupFields = new Map<String, String>();
            String buildCriteria = null;
            if(config != null && config.account != null && config.account.fields != null) {
                List<Adm.Expression> expressions = config?.account?.expressions;
                if (expressions != null) {
                    buildCriteria = getExpression(expressions,buildCriteria);
                }
                if (config.account.fields.size() >0){
                    populateHierarchyObjectQueryFields(config?.account?.fields,accountFieldDescribeMap,accountFields,accountFieldSet,accountLookupFields );
                }
                if (-1 == config.account.displayIconName?.indexOf(':') ) {
                    accountFields.add(String.escapeSingleQuotes(config.account.displayIconName));
                    accountFieldSet.add(String.escapeSingleQuotes(config.account.displayIconName));
                }
            }

            if(!accountFields.isEmpty() ) {
                List<String> recordIdList = new List<String>();
                getAccountHierarchyIds(recordIds,recordIdList);
                String qualifyingCriteria = '';
                if (String.isNotBlank(buildCriteria)){
                    qualifyingCriteria += ' AND (' + buildCriteria+' )';
                }
                List<SObject> accountRecords = SvmxDatabase.query(
                    String.format(
                        'SELECT {0} FROM Account WHERE Id IN ({1}) {2} ORDER BY NAME',
                        new List<String> {
                            String.join(new List<String>(accountFieldSet), ', '),
                            String.join(recordIdList, ', '),
                            qualifyingCriteria
                        }
                    )
                );

                if( !accountRecords.isEmpty() ) {
                    for(SObject accountRecord : accountRecords) {
                        Amgt.HierarchyNode theNode = mapHierarchyNode(accountRecord, accountFields, accountLookupFields);
                        if(theNode.Id == primaryRecordId && !nodes.isEmpty()) {
                            nodes.add(0, theNode);
                        } else {
                            nodes.add(theNode);
                        }
                    }
                
                }  
            }
        
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountNodes() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - exit; response.size() =' + nodes.size());
        }
        
        return nodes;
    }

    @testvisible
    private void getAccountHierarchyIds (List<String> recordIds, List<String> accountIds){
        List<Account> accountRecords1 = SvmxDatabase.query(
            String.format(
                'SELECT Id, Name, ParentId,Parent.ParentId,Parent.parent.parentId, Parent.parent.parent.parentId, Parent.Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.Parent.ParentId FROM Account WHERE Id in ({0}) ORDER BY NAME',
                new List<String> {
                    String.join(recordIds, ', ')
                    
                }
            )
        );

        if (accountIds.isEmpty()){
            accountIds.addAll(recordIds);
        }
        boolean isRootIdReached = false;

        if(accountRecords1.size() > 0 ){
            if (accountRecords1[0].parentId != null){
                accountIds.add('\'' +accountRecords1[0].parentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (accountRecords1[0].Parent.ParentId != null){
                accountIds.add('\'' +accountRecords1[0].Parent.ParentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (accountRecords1[0].Parent.parent.parentId != null){
                accountIds.add('\'' +accountRecords1[0].Parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            } 
            if (accountRecords1[0].parent.parent.parent.parentId != null){
                accountIds.add('\'' +accountRecords1[0].parent.parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (accountRecords1[0].parent.parent.parent.parent.parentId != null){
                accountIds.add('\'' +accountRecords1[0].parent.parent.parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (accountRecords1[0].parent.parent.parent.parent.parent.parentId != null){
                accountIds.add('\'' +accountRecords1[0].parent.parent.parent.parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            }

            if (!isRootIdReached) {
                getAccountHierarchyIds (new List<String>{'\'' +accountRecords1[0].parent.parent.parent.parent.parent.parentId+ '\''}, accountIds);
            }
        }
    }

    public List<SObject> getAccountAssetNodesRaw(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId,boolean fetchAssetsOnly) {

        System.debug( LoggingLevel.DEBUG, 'getAccountAssetNodesRaw() - enter; recordIds= ' + recordIds );

        List<SObject> nodes = new List<SObject>();
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();

        try {
            
            List<String> assetFields = new List<String>();
            Set<String> assetFieldsSet = new Set<String>{'Id', 'Name', 'ParentId'};
            Map<String, String> assetLookupFields = new Map<String, String>();
            String assetBuildCriteria = null;
            if(config != null && config.asset != null && config.asset.fields != null) {
                List<Adm.Expression> expressions = config?.asset?.expressions;
                if (expressions != null) {
                    assetBuildCriteria = getExpression(expressions,assetBuildCriteria);
                }
                if (config.asset.fields.size() >0){
                    populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldsSet,assetLookupFields );
                }
                if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                    assetFields.add(String.escapeSingleQuotes(config.asset.displayIconName));
                    assetFieldsSet.add(String.escapeSingleQuotes(config.asset.displayIconName));
                }
            }

            if(!assetFields.isEmpty()) {
                if (String.isNotBlank(assetBuildCriteria)){
                    assetBuildCriteria = ' and '+assetBuildCriteria;
                } else { 
                    assetBuildCriteria = '';
                }
                nodes = SvmxDatabase.query(
                    String.format(
                        'SELECT {0} FROM Asset WHERE AssetLevel = 1 and AccountId in ({1}) {2} ORDER BY NAME', 
                        new List<String> {
                            String.join(new List<String>(assetFieldsSet), ', '),
                            String.join(recordIds, ', '),
                            assetBuildCriteria}
                    )
                );
              
            }
        
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountAssetNodesRaw() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountAssetNodesRaw() - exit; response.size() =' + nodes.size());
        }
        
        return nodes;
    }

    public Id getRootLocationIdForLocation(Id primaryRecordId) {
        Id rootId;
        List<SObject> primaryLocation = SvmxDatabase.query([SELECT Id, RootLocationId FROM Location WHERE Id = :primaryRecordId]);
        if(primaryLocation.size() > 0) {
            rootId = String.valueOf(primaryLocation[0].get('RootLocationId'));
        }
        return rootId;
    }

    public Id getRootLocationIdForAsset(Id primaryRecordId) {
        Id rootId;
        List<Asset> primaryAsset = (List<Asset>)SvmxDatabase.query([SELECT Id, Location.RootLocationId, RootAssetId, RootAsset.Location.RootLocationId FROM Asset WHERE Id = :primaryRecordId]);
        if(primaryAsset.size() > 0) {
            String rootLocationId = String.valueOf(primaryAsset[0].RootAsset.Location.RootLocationId);
            String rootAssetId = String.valueOf(primaryAsset[0].RootAssetId);
            rootId = rootLocationId != null && rootLocationId != '' ? rootLocationId : rootAssetId;
        }
        return rootId;
    }

    public Id getRootAssetLocationIdForAsset(Id primaryRecordId) {
        Id rootId;
        List<Asset> primaryAsset = (List<Asset>)SvmxDatabase.query([SELECT Id, Location.RootLocationId, RootAssetId, RootAsset.LocationId FROM Asset WHERE Id = :primaryRecordId]);
        if(primaryAsset.size() > 0) {
            rootId = String.valueOf(primaryAsset[0].RootAsset.LocationId);
        }
        return rootId;
    }

    public Id getRootAssetAccountIdForAsset(Id primaryRecordId) {
        Id rootId;
        List<Asset> primaryAsset = (List<Asset>)SvmxDatabase.query([SELECT Id, Location.RootLocationId, RootAssetId, RootAsset.AccountId FROM Asset WHERE Id = :primaryRecordId]);
        if(primaryAsset.size() > 0) {
            rootId = String.valueOf(primaryAsset[0].RootAsset.AccountId);
        }
        return rootId;
    }

    public Id getRootAssetIdForAsset(Id primaryRecordId) {
        Id rootId;
        List<Asset> primaryAsset = (List<Asset>)SvmxDatabase.query([SELECT Id, RootAssetId FROM Asset WHERE Id = :primaryRecordId]);
        if(primaryAsset.size() > 0) {
            rootId = String.valueOf(primaryAsset[0].RootAssetId);
        }
        return rootId;
    }

    public List<Amgt.HierarchyNode> getLocationNodes(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId) {
        Schema.DescribeSobjectResult locationDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Location');
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> locationFieldDescribeMap = locationDescribe.fields.getMap();
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> locationFields = new List<String>();
        Set<String> locationFieldSet = new Set<String>{
            'Id',
            'Name',
            'ParentLocationId',
            'RootLocationId'};
        Map<String, String> locationLookupFields = new Map<String, String>();
        String buildCriteria = null;
        if(config != null && config.location != null && config.location.fields != null) {
            List<Adm.Expression> expressions = config?.location?.expressions;
            if (expressions != null) {
                buildCriteria = getExpression(expressions,buildCriteria);
            }
            if (config.location.fields.size() >0){
                populateHierarchyObjectQueryFields(config?.location?.fields,locationFieldDescribeMap,locationFields,locationFieldSet,locationLookupFields );
            }
            if (-1 == config.location.displayIconName?.indexOf(':') ) {
                locationFields.add(String.escapeSingleQuotes(config.location.displayIconName));
                locationFieldSet.add(String.escapeSingleQuotes(config.location.displayIconName));
            }
        }
        if(!locationFields.isEmpty()) {
            List<SObject> locationQuery = getLocationNodesRaw(recordIds, config, primaryRecordId);
            if(locationQuery.size() > 0) {
                for(SObject theLocation : locationQuery) {
                    Amgt.HierarchyNode theNode = mapHierarchyNode(theLocation, locationFields, locationLookupFields);
                    if(theNode.Id == primaryRecordId && !nodes.isEmpty()) {
                        nodes.add(0, theNode);
                    } else {
                        nodes.add(theNode);
                    }
                }
            } 
        }
        
        return nodes;
    }

     public List<sObject> getLocationNodesRaw(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId) {
        Schema.DescribeSobjectResult locationDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Location');
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> locationFieldDescribeMap = locationDescribe.fields.getMap();
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> locationFields = new List<String>();
        Set<String> locationFieldSet = new Set<String>{'Id','Name','ParentLocationId','RootLocationId'};
        Map<String, String> locationLookupFields = new Map<String, String>();
        String buildCriteria = null;
        if(config != null && config.location != null && config.location.fields != null) {
            List<Adm.Expression> expressions = config?.location?.expressions;
            if (expressions != null) {
                buildCriteria = getExpression(expressions,buildCriteria);
            }
            if (config.location.fields.size() >0){
				populateHierarchyObjectQueryFields(config?.location?.fields,locationFieldDescribeMap,locationFields,locationFieldSet,locationLookupFields );

            }
            if (-1 == config.location.displayIconName?.indexOf(':') ) {
                locationFields.add(String.escapeSingleQuotes(config.location.displayIconName));
                locationFieldSet.add(String.escapeSingleQuotes(config.location.displayIconName));
            }
        }
        List<SObject> locationQuery =new List<SObject>();
        if(!locationFields.isEmpty()) {
            String qualifyingCriteria = '';
            if (String.isNotBlank(buildCriteria)){
                qualifyingCriteria += ' AND (' + buildCriteria+' )';
            }
            locationQuery = SvmxDatabase.query(
                String.format(
                    'select {0} from location where RootLocationId in ({1}) {2} order by name',
                    new List<String> {
                        String.join(new List<String>(locationFieldSet), ', '),
                        String.join(recordIds, ', '),
                        qualifyingCriteria
                    }
                )
            );
        }
        
        return locationQuery;
    }

     public List<Amgt.HierarchyNode> getLocationAssetNodes(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId) {
        Schema.DescribeSobjectResult locationDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Location');
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> locationFieldDescribeMap = locationDescribe.fields.getMap();
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> locationFields = new List<String>();
        Set<String> locationFieldSet = new Set<String>();
        locationFieldSet.add('Id');
        locationFieldSet.add('Name');
        locationFieldSet.add('ParentLocationId');
        locationFieldSet.add('RootLocationId');
        Map<String, String> locationLookupFields = new Map<String, String>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{
            'Name',
            'Id',
            'ParentId'
            };
        Map<String, String> assetLookupFields = new Map<String, String>();
        String locationBuildCriteria = null;
        if(config != null && config.location != null && config.location.fields != null) {
            List<Adm.Expression> expressions = config?.location?.expressions;
            if (expressions != null) {
                locationBuildCriteria = getExpression(expressions,locationBuildCriteria);
            }
            if (config.location.fields.size() >0){
                populateHierarchyObjectQueryFields(config?.location?.fields,locationFieldDescribeMap,locationFields,locationFieldSet,locationLookupFields );
            }
            if (-1 == config.location.displayIconName?.indexOf(':') ) {
                locationFields.add(String.escapeSingleQuotes(config.location.displayIconName));
                locationFieldSet.add(String.escapeSingleQuotes(config.location.displayIconName));
            }
        }

        String assetBuildCriteria = null;
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                assetBuildCriteria = getExpression(expressions,assetBuildCriteria);
            }
            if (config.asset.fields.size() >0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields );
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFields.add(config.asset.displayIconName);
                assetFieldSet.add(config.asset.displayIconName);
            }
        }
        if(!locationFields.isEmpty() && !assetFields.isEmpty()) {
            String subquery = 'SELECT {0} FROM Assets WHERE AssetLevel = 1 ';
            if (String.isNotBlank(assetBuildCriteria)){
                subquery += ' AND (' + assetBuildCriteria+' )';
            }
            subquery += ' ORDER BY NAME';
            
            String query = String.format(
                'SELECT  {0}, ({1}) FROM Location WHERE Id IN ({2}) ',
                new List<String> {
                    String.join(new List<String>(locationFieldSet), ', '),
                    String.format(
                        subquery, 
                        new List<String> {String.join(new List<String>(assetFieldSet), ', ')}
                    ),
                    String.join(recordIds, ', ')
                }
            );
            if (String.isNotBlank(locationBuildCriteria)){
                query += ' AND (' + locationBuildCriteria+' )';
            }
            query += ' ORDER BY NAME';
            List<SObject> locationQuery = SvmxDatabase.query(query);
            if(locationQuery.size() > 0) {
                for(SObject theLocation : locationQuery) {
                    Amgt.HierarchyNode theNode = mapHierarchyNode(theLocation, locationFields, locationLookupFields);
                    if(theLocation.getSObjects('Assets') != null && theLocation.getSObjects('Assets').size() > 0) {
                        theNode.detail = new List<Amgt.HierarchyNode>();
                        for(SObject asset : theLocation.getSObjects('Assets')) {
                            theNode.detail.add(mapHierarchyNode(asset, assetFields, assetLookupFields));
                        }
                    }
                    if(theNode.Id == primaryRecordId && !nodes.isEmpty()) {
                        nodes.add(0, theNode);
                    } else {
                        nodes.add(theNode);
                    }
                }
            } 
        }
        return nodes;
    }


     public List<SObject> getLocationAssetNodesRaw(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId) {
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();  
        List<String> assetFields = new List<String>();
        List<SObject> nodes = new List<SObject>();
        Set<String> assetFieldSet = new Set<String>{
            'Name',
            'Id',
            'ParentId'
            };
        Map<String, String> assetLookupFields = new Map<String, String>();
        String assetBuildCriteria = null;
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                assetBuildCriteria = getExpression(expressions,assetBuildCriteria);
            }
            if (config.asset.fields.size() >0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields );
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFields.add(String.escapeSingleQuotes(config.asset.displayIconName));
                assetFieldSet.add(String.escapeSingleQuotes(config.asset.displayIconName));
            }
        }
        if(!assetFieldSet.isEmpty() ) {
            String subquery = 'SELECT {0} FROM Asset WHERE AssetLevel = 1 and LocationId in ({1})';
            if (String.isNotBlank(assetBuildCriteria)){
                subquery += ' AND (' + assetBuildCriteria+' )';
            }
            subquery += ' ORDER BY NAME';
            String query = String.format(
                subquery,
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    String.join(recordIds, ', ')
                }
            );
            nodes = SvmxDatabase.query(query);
        }
        return nodes;
    }

    public List<Amgt.HierarchyNode> getAssetNodes(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId, String order) {
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{
            'Id',
            'Name',
            'ParentId'
        };
        String buildCriteria = null;
        Map<String, String> assetLookupFields = new Map<String, String>();
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                buildCriteria = getExpression(expressions,buildCriteria);
            }
            if (config.asset.fields.size() >0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields);
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFieldSet.add(String.escapeSingleQuotes(config.asset.displayIconName));
                assetFields.add(String.escapeSingleQuotes(config.asset.displayIconName));
            }
        }
        if(!assetFields.isEmpty()) {
            List<SObject> assetQuery = new List<SObject>();
            if(order == ASSET_ONLY) {
                assetQuery = getAssetNodesRaw(recordIds, config, primaryRecordId, order);
                if(assetQuery.size() > 0) {
                    for(SObject theAsset : assetQuery) {
                        Amgt.HierarchyNode theNode = mapHierarchyNode(theAsset, assetFields, assetLookupFields);
                        if(theNode.Id == primaryRecordId && !nodes.isEmpty()) {
                            nodes.add(0, theNode);
                        } else {
                            nodes.add(theNode);
                        }
                    }
                }
            } else {
                assetQuery = getAssetNodesRaw(recordIds, config, primaryRecordId, order);
                if(assetQuery.size() > 0) {
                    for(SObject theAsset : assetQuery) {
                        Amgt.HierarchyNode theNode = mapHierarchyNode(theAsset, assetFields, assetLookupFields);
                        if(theAsset.getSObjects('ChildAssets') != null && theAsset.getSObjects('ChildAssets').size() > 0) {
                            theNode.children = new List<Amgt.HierarchyNode>();
                            for(SObject asset : theAsset.getSObjects('ChildAssets')) {
                                theNode.children.add(mapHierarchyNode(asset, assetFields, assetLookupFields));
                            }
                        }
                        if(theNode.Id == primaryRecordId && !nodes.isEmpty()) {
                            nodes.add(0, theNode);
                        } else {
                            nodes.add(theNode);
                        }
                    }
                }
            } 
        }
        return nodes;
    }

    public List<SObject> fetchAssetsForGivenParentRaw( 
        String parentId,
        String childRelationshipName,
        Amgt.HierarchyConfiguration  config) {
        Id parentRecId = (Id)parentId;
        SObjectType parentObj = parentRecId.getSObjectType();
        Schema.DescribeSObjectResult parentObjDescribe = parentObj.getDescribe();
        String parentObjName = parentObjDescribe.getName();
        List<Schema.ChildRelationship> relationships = parentObjDescribe.getChildRelationships();
        boolean isValidRelationship = false;
        String relationshipName;
        for (Schema.ChildRelationship relationship: relationships) {
            if (relationship.getRelationshipName()!= null 
            && relationship.getRelationshipName().toLowerCase().equals(childRelationshipName.toLowerCase())){
                isValidRelationship = true;
                relationshipName = relationship.getRelationshipName();
                break;
            }
        }
        if (!isValidRelationship){
            throw new AuraHandledException(String.format(System.Label.Error_InvalidChildRelationship,new List<String>{childRelationshipName}));
        }

        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{'Id', 'Name','ParentId'};
        String buildCriteria = null;
        Map<String, String> assetLookupFields = new Map<String, String>();
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                buildCriteria = getExpression(expressions,buildCriteria);
            }
            if (config.asset.fields.size()>0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields,false );
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFieldSet.add(String.escapeSingleQuotes(config.asset.displayIconName));
                assetFields.add(String.escapeSingleQuotes(config.asset.displayIconName));
            }
        }
        List<SObject> assetQuery = new List<SObject>();
        if(!assetFields.isEmpty()) {
            String subQuery = String.format(
                'SELECT {0} FROM {1}',
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    childRelationshipName
                }
            );
            if (String.isNotBlank(buildCriteria)){
                subQuery += ' where ' + buildCriteria+' ';
            }
            subQuery += ' ORDER BY NAME';
            String query = String.format(
                'SELECT id, ({0}) FROM {1} WHERE Id = {2}',
                new List<String> {
                    subQuery,
                    parentObjName,
                    '\''+parentId+'\''
                }
            );
           
            List<SObject> queryResponse = SvmxDatabase.query (query);
            if (!queryResponse.isEmpty() 
                && queryResponse[0].getSObjects(relationshipName) != null) {
                assetQuery = (List<SObject>)queryResponse[0].getSObjects(relationshipName);
            }
        }
        return assetQuery;
    }

    public List<SObject> getAssetNodesRaw(List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId, String order) {
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{'Id', 'Name','ParentId'};
        String buildCriteria = null;
        Map<String, String> assetLookupFields = new Map<String, String>();
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                buildCriteria = getExpression(expressions,buildCriteria);
            }
            if (config.asset.fields.size()>0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields );
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFieldSet.add(String.escapeSingleQuotes(config.asset.displayIconName));
                assetFields.add(String.escapeSingleQuotes(config.asset.displayIconName));
            }
        }
        List<SObject> assetQuery = new List<SObject>();
        if(!assetFields.isEmpty()) {
            String query = String.format(
                'SELECT {0} FROM Asset WHERE {1} IN ({2})',
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    order == ASSET_ONLY ?'RootAssetId':'ParentId',
                    String.join(recordIds, ', ')
                }
            );
            if (String.isNotBlank(buildCriteria)){
                query += ' AND (' + buildCriteria+' )';
            }
            query += ' ORDER BY NAME';
            assetQuery = SvmxDatabase.query (query);
        }
        return assetQuery;
    }

    public List<SObject> getChildAssetNodesRaw(Id parentRecordId, Amgt.HierarchyConfiguration config) {
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{'Id', 'Name','ParentId'};
        Map<String, String> assetLookupFields = new Map<String, String>();
        if(config != null && config.asset != null && config.asset.fields != null) {
            if (config.asset.fields.size()>0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields,false );
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFieldSet.add(String.escapeSingleQuotes(config.asset.displayIconName));
                assetFields.add(String.escapeSingleQuotes(config.asset.displayIconName));
            }
        }
        List<SObject> assetQuery = new List<SObject>();
        if(!assetFields.isEmpty()) {
            String query = String.format(
                'SELECT {0} FROM Asset WHERE ParentId = {1}',
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                        '\''+parentRecordId +'\''
                        }
            );
            query += ' ORDER BY NAME';
            assetQuery = SvmxDatabase.query (query);
        }
        return assetQuery;
    }
    
    public static Amgt.HierarchyNode mapHierarchyNodeId(SObject record, List<String> fields) {
        Amgt.HierarchyNode node = new Amgt.HierarchyNode();
        node.id = record.Id;
        return node;
    }

    public static Amgt.HierarchyNode mapHierarchyNode(SObject record, List<String> fields, Map<String, String> lookupFields) {
        return mapHierarchyNode(record, fields, false, lookupFields);
    }

    public static Amgt.HierarchyNode mapHierarchyNode(SObject record, List<String> fields, Boolean expandByDefault, Map<String, String> lookupFields) {
        Schema.SObjectType type = record.Id.getSObjectType();
        Schema.DescribeSObjectResult describeResult;
        if(cachedDescribeObjectName.containsKey(type)) {
            describeResult = cachedDescribeObjectName.get(type);
        } else {
            describeResult = type.getDescribe(SObjectDescribeOptions.DEFERRED);
            cachedDescribeObjectName.put(type, describeResult);
        }
        Amgt.HierarchyNode node = new Amgt.HierarchyNode();
        node.id = record.Id;
        Map<String,Object> populatedFields = record.getPopulatedFieldsAsMap();
        if(populatedFields.containsKey('ParentId')) {
            node.parentId = String.valueOf(record.get('ParentId'));
        }
        if(populatedFields.containsKey('ParentLocationId')) {
            node.parentId = String.valueOf(record.get('ParentLocationId'));
        }

        node.objectApiName = describeResult.getName().toLowerCase();
        node.expandByDefault = expandByDefault;
        node.name = String.valueOf(record.get('Name'));
        node.url = '/' + record.Id;
        node.fields = fields;
        node.record = JSON.serialize(record);
        node.lookupRecords = new Map<String, Object>();
        for(String lookupField : lookupFields.keySet()) {
            node.lookupRecords.put(lookupField, JSON.serialize(record.getSObject(lookupFields.get(lookupField))));
        }
        return node;
    }

    public Amgt.HierarchyConfiguration getHierarchyConfigurationsForUser() {
        final String profile18 = UserInfo.getProfileId();
        final String profile15 = ((Id)profile18).to15();

        List<SVMXA360__CONF_HierarchyConfigDetail__c> configurationList = SvmxDatabase.query(
            [
                SELECT Id, 
                    Name, 
                    SVMXA360__HierarchyConfigId__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__DisplayIconName__c,
                    SVMXA360__fieldForDisplayIcon__c,
                    SVMXA360__EnableSPMWizards__c,
                    SVMXA360__EnableDefaultRecordActions__c,
                    LastModifiedDate,
                    LastModifiedBy.Name,
                	SVMXA360__FilterCriteria__c,
                	SVMXA360__FilterCriteria__r.Name,
                    SVMXA360__AllowManagingChildAssets__c,
                	SVMXA360__EnableNotification__c,
                	SVMXA360__NotificationFilterCriteria__c,
                	SVMXA360__NotificationFilterCriteria__r.Name,
                    (
                        SELECT Id,
                        SVMXA360__FieldAPIName__c,
                        SVMXA360__HierarchyConfigurationDetailId__c,
                        SVMXA360__Sequence__c
                        FROM Hierarchy_Configuration_Fields__r
                        ORDER BY SVMXA360__Sequence__c
                    )
                FROM SVMXA360__CONF_HierarchyConfigDetail__c 
                WHERE SVMXA360__HierarchyConfigId__c IN (
                    SELECT SVMXA360__HierarchyConfigId__c 
                        FROM SVMXA360__CONF_HierarchyConfigAccess__c
                        WHERE SVMXA360__ProfileId__c = :profile18
                        OR SVMXA360__ProfileId__c = :profile15
                )
            ]);

        return mapConfiguration(configurationList);
    }

    public Amgt.HierarchyConfiguration getDefaultHierarchyConfigurationsForOrg() {
        List<SVMXA360__CONF_HierarchyConfigDetail__c> configurationList = SvmxDatabase.query(
            [
                SELECT Id, 
                    Name, 
                    SVMXA360__HierarchyConfigId__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__DisplayIconName__c,
                    SVMXA360__EnableSPMWizards__c,
                    SVMXA360__EnableDefaultRecordActions__c,
                    SVMXA360__FieldForDisplayIcon__c,
                    LastModifiedDate,
                    LastModifiedBy.Name,
                	SVMXA360__FilterCriteria__c,
                	SVMXA360__FilterCriteria__r.Name,
                    SVMXA360__AllowManagingChildAssets__c,
                	SVMXA360__EnableNotification__c,
                    SVMXA360__NotificationFilterCriteria__c,
                	SVMXA360__NotificationFilterCriteria__r.Name,
                    (
                        SELECT Id,
                        SVMXA360__FieldAPIName__c,
                        SVMXA360__HierarchyConfigurationDetailId__c,
                        SVMXA360__Sequence__c
                        FROM Hierarchy_Configuration_Fields__r
                        ORDER BY SVMXA360__Sequence__c
                    )
                FROM SVMXA360__CONF_HierarchyConfigDetail__c 
                WHERE SVMXA360__HierarchyConfigId__r.SVMXA360__isDefault__c = true
            ]);

        return mapConfiguration(configurationList);
    }

    private static Amgt.HierarchyConfiguration mapConfiguration(List<SVMXA360__CONF_HierarchyConfigDetail__c> configDetails) {
        Amgt.HierarchyConfiguration configuration = new Amgt.HierarchyConfiguration();
        configuration.isEmpty = configDetails.isEmpty();
        for(SVMXA360__CONF_HierarchyConfigDetail__c configDetail : configDetails) {
            Amgt.HierarchyConfigurationDetail detail = new Amgt.HierarchyConfigurationDetail();
            detail.id = String.valueOf(configDetail.Id);
            detail.hierarchyConfigId = configDetail.SVMXA360__HierarchyConfigId__c;
            detail.objectAPIName = configDetail.SVMXA360__ObjectAPIName__c;
            if ( configDetail.SVMXA360__DisplayIconName__c == null) {
                detail.displayIconName = configDetail.SVMXA360__fieldForDisplayIcon__c;
            } else {
                detail.displayIconName = configDetail.SVMXA360__DisplayIconName__c;
            }
            detail.enableSPMWizards = configDetail.SVMXA360__EnableSPMWizards__c;
            detail.defaultRecordActions = configDetail.SVMXA360__EnableDefaultRecordActions__c;
            detail.qualifyingCriteria = configDetail.SVMXA360__FilterCriteria__c;
            detail.qualifyingCriteriaName = configDetail.SVMXA360__FilterCriteria__r.Name;
            detail.enableNotifications = configDetail.SVMXA360__EnableNotification__c;
            detail.allowManagingChildAssets = configDetail.SVMXA360__AllowManagingChildAssets__c;
            detail.notificationCriteria = configDetail.SVMXA360__NotificationFilterCriteria__c;
            detail.notificationCriteriaName = configDetail.SVMXA360__NotificationFilterCriteria__r.Name;
            detail.fields = new List<Amgt.HierarchyConfigurationField>();
            for(SVMXA360__CONF_HierarchyFields__c configField : configDetail.Hierarchy_Configuration_Fields__r) {
                if(configField.SVMXA360__FieldAPIName__c != 'Name') {
                    Amgt.HierarchyConfigurationField field = new Amgt.HierarchyConfigurationField();
                    field.id = configField.Id;
                    field.hierarchyConfigurationDetailId = configField.SVMXA360__HierarchyConfigurationDetailId__c;
                    field.fieldApiName = configField.SVMXA360__FieldAPIName__c;
                    field.sequence = Integer.valueOf(configField.SVMXA360__Sequence__c);
                    detail.fields.add(field);
                }
            }
            String objectName = detail.objectAPIName.toLowerCase();
            if(objectName == ACCOUNT) {
                configuration.account = detail;
            } else if(objectName == ASSET) {
                configuration.asset = detail;
            } else if(objectName == LOCATION) {
                configuration.location = detail;
            }
        }
        return configuration;
    }

     /**
    *  When a user retrieving Hierarchy data does not have access to hierarchy configuration records,
    *   this method provides a default implementation.
    */
    public Amgt.HierarchyConfiguration getFallbackAssetHierarchyConfigurations() {
        Amgt.HierarchyConfiguration configuration = new Amgt.HierarchyConfiguration();
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

        return configuration;
    }

    public String getLocationForAsset (String recordId) {
        String rootAssetId = getRootAssetIdForAsset (recordId);
        return ((List<Asset>)SvmxDatabase.query([select LocationId from Asset where id=:rootAssetId]))[0]?.LocationId;
    }

    public String getAccountForAsset (String recordId) {
        String rootAssetId = getRootAssetIdForAsset (recordId);
        return ((List<Asset>)SvmxDatabase.query([select AccountId from Asset where id=:rootAssetId]))[0]?.AccountId;
    }

    public List<Amgt.HierarchyNode> getAssetParentHierarchy (List<String> recordIds, Amgt.HierarchyConfiguration config, Id primaryRecordId) {
        List<String> assetIds = new List<String>();
        traverseAssetParents(recordIds,assetIds);
        Schema.DescribeSobjectResult locationDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Location');
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> locationFieldDescribeMap = locationDescribe.fields.getMap();
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> locationFields = new List<String>();
        Map<String, String> locationLookupFields = new Map<String, String>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{
            'Id',
            'Name',
            'ParentId'
         };
        Map<String, String> assetLookupFields = new Map<String, String>();

        String assetBuildCriteria = null;
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                assetBuildCriteria = getExpression(expressions,assetBuildCriteria);
            }
            if (config.asset.fields.size() >0){
                populateHierarchyObjectQueryFields(config?.asset?.fields,assetFieldDescribeMap,assetFields,assetFieldSet,assetLookupFields );
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFields.add(config.asset.displayIconName);
                assetFieldSet.add(config.asset.displayIconName);
            }
        }

        String query = String.format(
            'SELECT {0} FROM Asset WHERE Id IN ({1})',
            new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    String.join(assetIds, ', ')
                }
            );
        if (String.isNotBlank(assetBuildCriteria)){
            query += ' AND (' + assetBuildCriteria+' )';
        }
        query += ' ORDER BY NAME';
        List<SObject> assetQuery = SvmxDatabase.query (query);
        if(assetQuery.size() > 0) {
            for(SObject theasset : assetQuery) {
                nodes.add(mapHierarchyNode(theasset, assetFields, assetLookupFields));
            }
        }
        return nodes;
    }

    public void traverseAssetParents (List<String> recordIds, List<String> assetIds) {
        List<Asset> assetRecords = SvmxDatabase.query(
            String.format(
                'SELECT Id, Name, ParentId,Parent.ParentId,Parent.parent.parentId, Parent.parent.parent.parentId, Parent.Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.Parent.ParentId FROM Asset WHERE Id in ({0}) ORDER BY NAME',
                new List<String> {
                    String.join(recordIds, ', ')
                    
                }
            )
        );

        if (assetIds.isEmpty()){
            assetIds.addAll(recordIds);
        }
        boolean isRootIdReached = false;

        if(assetRecords.size() > 0 ){
            if (assetRecords[0].parentId != null){
                assetIds.add('\'' +assetRecords[0].parentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (assetRecords[0].Parent.ParentId != null){
                assetIds.add('\'' +assetRecords[0].Parent.ParentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (assetRecords[0].Parent.parent.parentId != null){
                assetIds.add('\'' +assetRecords[0].Parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            } 
            if (assetRecords[0].parent.parent.parent.parentId != null){
                assetIds.add('\'' +assetRecords[0].parent.parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (assetRecords[0].parent.parent.parent.parent.parentId != null){
                assetIds.add('\'' +assetRecords[0].parent.parent.parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            }
            if (assetRecords[0].parent.parent.parent.parent.parent.parentId != null){
                assetIds.add('\'' +assetRecords[0].parent.parent.parent.parent.parent.parentId+ '\'');
            } else {
                isRootIdReached = true;
            }

            if (!isRootIdReached) {
                traverseAssetParents (new List<String>{'\'' +assetRecords[0].parent.parent.parent.parent.parent.parentId+ '\''}, assetIds);
            }
        }
    }


    public List<Amgt.HierarchyNode> findAssetsOfRelatedParentSOSL (
        String term,
        Amgt.HierarchyConfiguration config,
        String relatedParentId
        ) {
        Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
        Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        List<String> assetFields = new List<String>();
        Set<String> assetFieldSet = new Set<String>{
            'Id',
            'Name',
            'ParentId',
            'LocationId',
            'AccountId',
            'RootAsset.AccountId'
        };
        List<String> whereClause = new List<String>();
        whereClause.add('RootAsset.AccountId=\''+relatedParentId+'\'');
        whereClause.add('RootAsset.Account.ParentId=\''+relatedParentId+'\'');
        whereClause.add('RootAsset.Account.Parent.ParentId=\''+relatedParentId+'\'');
        whereClause.add('RootAsset.Account.Parent.Parent.ParentId=\''+relatedParentId+'\'');
        whereClause.add('RootAsset.Account.Parent.Parent.Parent.ParentId=\''+relatedParentId+'\'');

        List<String> whereInClause = new List<String>();
        whereInClause.add('RootAsset.AccountId in: parentIds');
        whereInClause.add('RootAsset.Account.ParentId in: parentIds');
        whereInClause.add('RootAsset.Account.Parent.ParentId in: parentIds');
        whereInClause.add('RootAsset.Account.Parent.Parent.ParentId in: parentIds');
        whereInClause.add('RootAsset.Account.Parent.Parent.Parent.ParentId in: parentIds');
        
        
        String buildCriteria = null;
        String accountBuildCriteria = null;
        List<String> searchTermClauseList = new List<String>();
        
        Map<String, String> assetLookupFields = new Map<String, String>();
        if(config != null && config.asset != null && config.asset.fields != null) {
            List<Adm.Expression> expressions = config?.asset?.expressions;
            if (expressions != null) {
                buildCriteria = getExpression(expressions,buildCriteria);
            }
            for(Amgt.HierarchyConfigurationField assetField : config?.asset?.fields) {
                if(assetField.fieldAPIName != 'Id' && assetField.fieldAPIName != 'Name' ) {
                    assetFieldSet.add(assetField.fieldApiName);
                    assetFields.add(assetField.fieldApiName);                        
                    Schema.DisplayType type = assetFieldDescribeMap
                        .get(assetField.fieldApiName)
                        .getDescribe()
                        .getType();
                    if(assetFieldDescribeMap.containsKey(assetField.fieldApiName) && 
                        assetFieldDescribeMap
                            .get(assetField.fieldApiName)
                            .getDescribe()
                            .getType() == Schema.DisplayType.REFERENCE
                        ) {
                            assetLookupFields.put(assetField.fieldApiName, assetFieldDescribeMap
                            .get(assetField.fieldApiName)
                            .getDescribe()
                            .getRelationshipName());
                            String refFieldName = getReference(assetField.fieldApiName, '.Name');
                            assetFieldSet.add(refFieldName);
                            assetFields.add(refFieldName);
                    }
                }
            }
            if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                assetFieldSet.add(config.asset.displayIconName);
                assetFields.add(config.asset.displayIconName);
            }
        }
        if(config != null && config.account != null && config.account.fields != null) {
            List<Adm.Expression> expressions = config?.account?.expressions;
            if (expressions != null) {
                accountBuildCriteria = getExpression(expressions,accountBuildCriteria);
            }
        }

        if (!assetFields.isEmpty()) {
            mapData(
                getSearchResultForAsset(term, new List<String>(assetFieldSet),whereClause,buildCriteria,null),
                nodes,
                assetFields,
                assetLookupFields);
            List<Id> parentIds1 = getAccountsAtGivenhLevel(relatedParentId, accountBuildCriteria,5);
            mapData(
                getSearchResultForAsset(term, new List<String>(assetFieldSet),new List<String>{whereInClause[0]},buildCriteria,parentIds1),
                nodes,
                assetFields,
                assetLookupFields);
            List<Id> parentIds2 = getAccountsAtGivenhLevel(relatedParentId, accountBuildCriteria,6);
            mapData(
                getSearchResultForAsset(term, new List<String>(assetFieldSet),whereInClause,buildCriteria,parentIds2),
                nodes,
                assetFields,
                assetLookupFields);
        }
        return nodes;
    }
    private void mapData(
        List<List <sObject>> searchResults,
        List<Amgt.HierarchyNode> nodes,
        List<string> assetFields,
        Map<String, String> assetLookupFields){
        System.debug(searchResults);
        if(searchResults.size() > 0 && searchResults[0].size() > 0){
            for(SObject theasset : searchResults[0]) {
                nodes.add(mapHierarchyNode(theasset, assetFields, assetLookupFields));
            }
        }
    }

    private List<List<SObject>> getSearchResultForAsset (
        String term,
        List<String> assetFieldList,
        List<String> whereClause,
        String buildCriteria,
        List<Id> parentIds
        ) {
        String soslQuery = 'find {*'+escapeSosl(term)+'*} returning ASSET(';
        soslQuery += String.join(assetFieldList, ', ');
        soslQuery += ' where ('+String.join(whereClause, ' or ') +' )';
        if (String.isNotBlank(buildCriteria)){
            soslQuery +=  ' AND (' + buildCriteria+' )';
        }
        soslQuery += ' )';
        System.debug(LoggingLevel.INFO,soslQuery);
        return search.query(soslQuery);
    }

    public List<Amgt.HierarchyNode> findAssetsOfRelatedParent (
        String term,
        Amgt.HierarchyConfiguration config,
        String relatedParentId
        ) {
            Schema.DescribeSobjectResult assetDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Asset');
            Map<String, Schema.SObjectField> assetFieldDescribeMap = assetDescribe.fields.getMap();
            List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
            List<String> assetFields = new List<String>();
            Set<String> assetFieldSet = new Set<String>{
                'Id',
                'Name',
                'ParentId',
                'LocationId',
                'AccountId',
                'RootAsset.LocationId'
            };
            
            String buildCriteria = null;
            List<String> searchTermClauseList = new List<String>();
            String relatedParentType = ((ID)relatedParentId).getSobjectType().getDescribe().getName().toLowerCase();
            Map<String, String> assetLookupFields = new Map<String, String>();
            if(config != null && config.asset != null && config.asset.fields != null) {
                List<Adm.Expression> expressions = config?.asset?.expressions;
                if (expressions != null) {
                    buildCriteria = getExpression(expressions,buildCriteria);
                }
                searchTermClauseList.add( ' Name like \'%'+term+'%\' ');
                for(Amgt.HierarchyConfigurationField assetField : config?.asset?.fields) {
                    if(assetField.fieldAPIName != 'Id' && assetField.fieldAPIName != 'Name' ) {
                        assetFieldSet.add(assetField.fieldApiName);
                        assetFields.add(assetField.fieldApiName);                        
                        Schema.DisplayType type = assetFieldDescribeMap
                            .get(assetField.fieldApiName)
                            .getDescribe()
                            .getType();
                        if(assetFieldDescribeMap.containsKey(assetField.fieldApiName) && 
                            assetFieldDescribeMap
                                .get(assetField.fieldApiName)
                                .getDescribe()
                                .getType() == Schema.DisplayType.REFERENCE
                            ) {
                                assetLookupFields.put(assetField.fieldApiName, assetFieldDescribeMap
                                .get(assetField.fieldApiName)
                                .getDescribe()
                                .getRelationshipName());
                                String refFieldName = getReference(assetField.fieldApiName, '.Name');
                                assetFieldSet.add(refFieldName);
                                assetFields.add(refFieldName);
                                searchTermClauseList.add(  refFieldName+' like \'%'+term+'%\' ');
                                
                        } else if (
                            type == Schema.DisplayType.String 
                            || type == Schema.DisplayType.Picklist
                            || type == Schema.DisplayType.URL 
                            || type == Schema.DisplayType.Email 
                         ) {
                            searchTermClauseList.add(  assetField.fieldApiName+' like \'%'+term+'%\' ');
                        }
                    }
                }
                if (-1 == config.asset.displayIconName?.indexOf(':') ) {
                    assetFieldSet.add(config.asset.displayIconName);
                    assetFields.add(config.asset.displayIconName);
                }
            }

            if (!assetFields.isEmpty()) {
                String condField = (relatedParentType == 'asset')
                                    ? 'RootAssetId'
                                    : 'RootAsset.Location.rootLocationId';
                String query = String.format(
                'SELECT {0} FROM Asset WHERE {1} = {2}',
                new List<String> {
                        String.join(new List<String>(assetFieldSet), ', '),
                        condField,
                        '\''+relatedParentId +'\''
                    }
                );
                String searchtermCriteria = String.join(searchTermClauseList,' or ');
                if (String.isNotBlank(searchtermCriteria)) {
                    query += ' AND (' + searchtermCriteria+' )'; 
                }
                if (String.isNotBlank(buildCriteria)){
                    query += ' AND (' + buildCriteria+' )';
                }
                query += ' LIMIT 100';
                System.debug (query);
                List<SObject> assetQuery = SvmxDatabase.query (query);
                if(assetQuery.size() > 0) {
                    for(SObject theasset : assetQuery) {
                        nodes.add(mapHierarchyNode(theasset, assetFields, assetLookupFields));
                    }
                }
            }
            return nodes;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
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

    private static String getReference(String fieldName, String postfix) {
        String refName = '';
        if (fieldName.endsWith('Id')) {
            refName = fieldName.replace('Id', '') + postfix;
        } else {
            refName = fieldName.replace('__c', '__r') + postfix;
        }
        return refName;
    }


    public List<Amgt.HierarchyNode> fetchFirstFiveLevelAccounts (String rootId,Amgt.HierarchyConfiguration config) {
        System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - enter; rootId= ' + rootId );

        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        Schema.DescribeSobjectResult accountDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Account');        
        Map<String, Schema.SObjectField> accountFieldDescribeMap = accountDescribe.fields.getMap();        

        try {
            
            List<String> accountFields = new List<String>();
            Set<String> accountFieldSet = new Set<String>{
                'Id',
                'Name',
                'ParentId'
            };
            Map<String, String> accountLookupFields = new Map<String, String>();
            String buildCriteria = null;
            if(config != null && config.account != null && config.account.fields != null) {
                List<Adm.Expression> expressions = config?.account?.expressions;
                if (expressions != null) {
                    buildCriteria = getExpression(expressions,buildCriteria);
                }
                if (config.account.fields.size()>0){
                    populateHierarchyObjectQueryFields(config?.account?.fields,accountFieldDescribeMap,accountFields,accountFieldSet,accountLookupFields );
                }
                if (-1 == config.account.displayIconName?.indexOf(':') ) {
                    accountFields.add(config.account.displayIconName);
                    accountFieldSet.add(config.account.displayIconName);
                }
            }

            if(!accountFields.isEmpty() ) {
                List<SObject> accountRecords = fetchFirstFiveLevelAccountsRaw (rootId,config);
                if( !accountRecords.isEmpty() ) {
                    for(SObject accountRecord : accountRecords) {
                        Amgt.HierarchyNode theNode = mapHierarchyNode(accountRecord, accountFields, accountLookupFields);                      
                        nodes.add(theNode);
                    }
                
                }  
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountNodes() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - exit; response.size() =' + nodes.size());
        }
        return nodes;
    }

    public List<sObject> fetchFirstFiveLevelAccountsRaw (String rootId,Amgt.HierarchyConfiguration config) {
        System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - enter; rootId= ' + rootId );
        
        List<sObject> accountRecords = new List<sObject>();
        Schema.DescribeSobjectResult accountDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Account');        
        Map<String, Schema.SObjectField> accountFieldDescribeMap = accountDescribe.fields.getMap();        
        
        try {
            
            List<String> accountFields = new List<String>();
            Set<String> accountFieldSet = new Set<String>{'Id','Name','ParentId'};
            Map<String, String> accountLookupFields = new Map<String, String>();
            String buildCriteria = null;
            if(config != null && config.account != null && config.account.fields != null) {
                List<Adm.Expression> expressions = config?.account?.expressions;
                if (expressions != null) {
                    buildCriteria = getExpression(expressions,buildCriteria);
                }
                if (config.account.fields.size()>0){
                    populateHierarchyObjectQueryFields(config?.account?.fields,accountFieldDescribeMap,accountFields,accountFieldSet,accountLookupFields );
                }
                if (-1 == config.account.displayIconName?.indexOf(':') ) {
                    accountFields.add(config.account.displayIconName);
                    accountFieldSet.add(config.account.displayIconName);
                }
            }
            
            if(!accountFields.isEmpty() ) {
                String qualifyingCriteria = '';
                if (String.isNotBlank(buildCriteria)){
                    qualifyingCriteria += ' AND (' + buildCriteria+' )';
                }
                accountRecords = SvmxDatabase.query(
                    String.format(
                        'select {0} from account where (id={1} or parentId ={1} or Parent.ParentId={1} or Parent.Parent.ParentId={1} or Parent.Parent.Parent.ParentId={1} or Parent.Parent.Parent.Parent.ParentId={1} or Parent.Parent.Parent.Parent.Parent.ParentId={1}) {2}',
                        new List<String> {
                            String.join(new List<String>(accountFieldSet), ', '),
                                '\''+rootId+'\'',
                                qualifyingCriteria
                                }
                    )
                );
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountNodes() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - exit; response.size() =' + accountRecords.size());
        }
        return accountRecords;
    }
    
    private List<Id> getAccountsAtGivenhLevel(String rootId,String buildCriteria,integer level) {
        System.debug( LoggingLevel.DEBUG, 'getAccountsAtGivenhLevel() - enter; rootId= ' + rootId );
        List<Id> nodes = new List<Id>();
        try {
            
            Map<String, String> accountLookupFields = new Map<String, String>();            
            String qualifyingCriteria = '';
            if (String.isNotBlank(buildCriteria)){
                qualifyingCriteria += ' AND (' + buildCriteria+' )';
            }
            String relatedParentCondition = ''; 
            switch on level {
                when 1 {
                    relatedParentCondition = 'ParentId';
                }
                when 2 {
                    relatedParentCondition = 'Parent.ParentId';
                }        
                when 3 {
                    relatedParentCondition = 'Parent.Parent.ParentId';
                }
                when 4 {
                    relatedParentCondition = 'Parent.Parent.Parent.ParentId';
                }
                when 5 {
                    relatedParentCondition = 'Parent.Parent.Parent.Parent.ParentId';
                }
                when 6 {
                    relatedParentCondition = 'Parent.Parent.Parent.Parent.Parent.ParentId';
                }
            }
            List<SObject> accountRecords = SvmxDatabase.query(
                String.format(
                    'select Id from account where {0}={1} {2}',
                    new List<String> {
                        relatedParentCondition,
                        '\''+rootId+'\'',
                        qualifyingCriteria
                    }
                )
            );
            
            if( !accountRecords.isEmpty() ) {
                for(SObject accountRecord : accountRecords) {                      
                    nodes.add(accountRecord.Id);                      
                }                
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountsAtGivenhLevel() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountsAtGivenhLevel() - exit; response.size() =' + nodes.size());
        }
        return nodes;
    }
    

    public List<Amgt.HierarchyNode> fetchfinalFiveLevelAccounts (
            String rootId,
            Amgt.HierarchyConfiguration config) {
        System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - enter; rootId= ' + rootId );

        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode>();
        Schema.DescribeSobjectResult accountDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Account');        
        Map<String, Schema.SObjectField> accountFieldDescribeMap = accountDescribe.fields.getMap();        

        try {
            
            List<String> accountFields = new List<String>();
            Set<String> accountFieldSet = new Set<String>{
                'Id',
                'Name',
                'ParentId'
            };
            Map<String, String> accountLookupFields = new Map<String, String>();
            String buildCriteria = null;
            if(config != null && config.account != null && config.account.fields != null) {
                List<Adm.Expression> expressions = config?.account?.expressions;
                if (expressions != null) {
                    buildCriteria = getExpression(expressions,buildCriteria);
                }
                if (config.account.fields.size()>0){
                    populateHierarchyObjectQueryFields(config?.account?.fields,accountFieldDescribeMap,accountFields,accountFieldSet,accountLookupFields );
                }
                if (-1 == config.account.displayIconName?.indexOf(':') ) {
                    accountFields.add(config.account.displayIconName);
                    accountFieldSet.add(config.account.displayIconName);
                }
            }

            if(!accountFields.isEmpty() ) {
                String qualifyingCriteria = '';
                if (String.isNotBlank(buildCriteria)){
                    qualifyingCriteria += ' AND (' + buildCriteria+' )';
                }
                String rootIdWithBuildCriteria = '\''+rootId+'\'';
                if (String.isNotBlank(buildCriteria)){
                    rootIdWithBuildCriteria += ' where (' + buildCriteria+' )';
                }
                List<Id> parentIds = getAccountsAtGivenhLevel(rootId, buildCriteria,6);
                //(List<Id>) Cache.Org.get(AMGT_AssetHierarchyManager.SixthLevelAccountCache.class, rootIdWithBuildCriteria);
                if (parentIds.size() > 0) {
                    List<SObject> accountRecords = fetchfinalFiveLevelAccountsRaw(rootId,config);
                    if( !accountRecords.isEmpty() ) {   
                        for(SObject accountRecord : accountRecords) {
                            Amgt.HierarchyNode theNode = mapHierarchyNode(accountRecord, accountFields, accountLookupFields);
                            nodes.add(theNode);
                        }
                    }
                }
            }        
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountNodes() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - exit; response.size() =' + nodes.size());
        }
        return nodes;
    }

    public List<sObject> fetchfinalFiveLevelAccountsRaw (
            String rootId,
            Amgt.HierarchyConfiguration config) {
        System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - enter; rootId= ' + rootId );

        List<sObject> accountRecords = new List<sObject>();
        Schema.DescribeSobjectResult accountDescribe = COMM_DescribeManager.getInstance().getObjectDescribe('Account');        
        Map<String, Schema.SObjectField> accountFieldDescribeMap = accountDescribe.fields.getMap();        

        try {
            
            List<String> accountFields = new List<String>();
            Set<String> accountFieldSet = new Set<String>{'Id','Name','ParentId'};
            Map<String, String> accountLookupFields = new Map<String, String>();
            String buildCriteria = null;
            if(config != null && config.account != null && config.account.fields != null) {
                List<Adm.Expression> expressions = config?.account?.expressions;
                if (expressions != null) {
                    buildCriteria = getExpression(expressions,buildCriteria);
                }
                if (config.account.fields.size()>0){
                    populateHierarchyObjectQueryFields(config?.account?.fields,accountFieldDescribeMap,accountFields,accountFieldSet,accountLookupFields );
                }
                if (-1 == config.account.displayIconName?.indexOf(':') ) {
                    accountFields.add(config.account.displayIconName);
                    accountFieldSet.add(config.account.displayIconName);
                }
            }

            if(!accountFields.isEmpty() ) {
                String qualifyingCriteria = '';
                if (String.isNotBlank(buildCriteria)){
                    qualifyingCriteria += ' AND (' + buildCriteria+' )';
                }
                String rootIdWithBuildCriteria = '\''+rootId+'\'';
                if (String.isNotBlank(buildCriteria)){
                    rootIdWithBuildCriteria += ' where (' + buildCriteria+' )';
                }
                List<Id> parentIds = getAccountsAtGivenhLevel(rootId, buildCriteria,6);
                //(List<Id>) Cache.Org.get(AMGT_AssetHierarchyManager.SixthLevelAccountCache.class, rootIdWithBuildCriteria);
                if (parentIds.size() > 0) {
                        accountRecords = Database.query( 
                        String.format(
                            'select {0} from account where (parentId in: parentIds or Parent.ParentId in: parentIds or Parent.Parent.ParentId in: parentIds or Parent.Parent.Parent.ParentId in: parentIds)  {1}',
                            new List<String> {
                                String.join(new List<String>(accountFieldSet), ', '),
                                qualifyingCriteria
                            }
                        )
                    );
                }
            }        
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAccountNodes() : Failed to retrieve Account Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAccountNodes() - exit; response.size() =' + accountRecords.size());
        }
        return accountRecords;
    }
    
    public List<Amgt.NotificationDetails> getNotifications(Id recordId, String order,Amgt.HierarchyConfiguration config) {
        String queryResults;
        List<Asset> assetQuery = new List<Asset>();
        String sobjectName = recordId.getSobjectType().getDescribe().getName().toLowerCase();
        String subquery;
        List<Amgt.NotificationDetails> assetMapQuery = new List<Amgt.NotificationDetails>();
        String assetNotificationBuildCriteria = null;
        if(config != null && config.asset != null) {
            Boolean enableNotifications = config?.asset?.enableNotifications;
            if(enableNotifications != null) {
                if(!enableNotifications) {
                    return assetMapQuery;
                }
                String notificationCriteria = config?.asset?.notificationCriteria;
                if (String.isNotBlank(notificationCriteria)){
                    Map<Id,Adm.Expression> expressions
                        = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( new List<String>{notificationCriteria}, null );
                    assetNotificationBuildCriteria = COMM_ExpressionUtils.getInstance().buildCriteria(expressions.get(notificationCriteria));
                }
            }
        }
        if(assetNotificationBuildCriteria == null ) {
            assetNotificationBuildCriteria = 'SVMXA360__Status__c = \'Open\' AND (SVMXA360__Severity__c  = \'Moderate\' OR SVMXA360__Severity__c  = \'Critical\')';
        }
        String query;
        subquery = 'SELECT Name, SVMXA360__AssetId__c, SVMXA360__AssetId__r.Name, Id, SVMXA360__Description__c, SVMXA360__Title__c, CreatedDate FROM SVMXA360__Asset_Notifications__r where ' + assetNotificationBuildCriteria + ' ORDER BY CreatedDate DESC';
        if (sobjectName == ASSET) {
            List<Asset> primaryAsset = (List<Asset>)SvmxDatabase.query([SELECT Id, RootAssetId  FROM Asset WHERE Id = :recordId]);
            recordId = primaryAsset[0].RootAssetId;
        }
        if(order == ASSET_ONLY || sobjectName == ASSET) {
            query = String.format(
                'SELECT Id, ({0}) FROM Asset WHERE RootAssetId = {1} OR ParentId = {1}',
                new List<String> {
                    subquery,
                        '\'' +recordId+ '\''    
                        }
            );
        }else if (sobjectName == LOCATION || sobjectName == ACCOUNT) {
            if(sobjectName == LOCATION) {
                query = String.format(
                    'SELECT Id, ({0}) FROM Asset WHERE LocationId = {1} AND AssetLevel = 1',
                    new List<String> {
                        subquery,
                            '\'' +recordId+ '\''   
                            }
                );
            } else if(sobjectName == ACCOUNT) {
                query = String.format(
                    'SELECT Id, ({0}) FROM Asset WHERE AccountId = {1} AND AssetLevel = 1',
                    new List<String> {
                        subquery,
                            '\'' +recordId+ '\''   
                            }
                );
            }
        }
        assetQuery = SvmxDatabase.query (query);
        for(Asset record: assetQuery){
            List<Amgt.Notification> notificationRecords = new List<Amgt.Notification>();
            for(SVMXA360__AssetNotification__c notificationRecord : record.SVMXA360__Asset_Notifications__r){
                Amgt.Notification nRecord = new Amgt.Notification();
                nRecord.id = notificationRecord.Id;
                nRecord.description = notificationRecord.SVMXA360__Description__c;
                nRecord.title = notificationRecord.SVMXA360__Title__c == null ? notificationRecord.Name : notificationRecord.SVMXA360__Title__c;
                nRecord.notificationDate = notificationRecord.CreatedDate;
                nRecord.assetName = notificationRecord.SVMXA360__AssetId__r.Name;
                notificationRecords.add(nRecord);
            }
            if (!notificationRecords.isEmpty()){
                Amgt.NotificationDetails notificationDetails = new Amgt.NotificationDetails();
                notificationDetails.assetId = record.Id;
                notificationDetails.assetNotifications = notificationRecords;
                assetMapQuery.add(notificationDetails);
            }
        }
        return assetMapQuery;
    }

    public List<Amgt.SaveResponse> updateAssetRecords (
        List<Asset> records) {
        List<Amgt.SaveResponse> returnResult = new List<Amgt.SaveResponse> ();
        try {
            List<Database.SaveResult> sresults = Database.update(records, false); 
            for (Database.SaveResult result: sresults) {
                Amgt.SaveResponse resp = new Amgt.SaveResponse();
                List<String> errFields = new List<String>();
                if(!result.success) {
                    resp.error = new List<string>();
                    for (Database.Error err: result.getErrors()){
                        resp.error.add(err.getMessage());
                        errFields.addAll(err.getFields());
                    }
                    resp.errorFields = errFields;
    
                }
                resp.success = result.isSuccess();
                resp.id = result.Id;
                returnResult.add(resp);
            }
        } catch (Exception e) {
            throw e;
        }
        return returnResult;
    }

    public String escapeSosl( String text ) {


        String escapedText;

        if ( String.isBlank( text ) ) {

            escapedText = null;

        } else {

            // escape single quotes
            // we do not handle the single quote escaping in the matcher.replaceAll method along with the other escaping because we would end up with incorrect number of slashes
            escapedText = String.escapeSingleQuotes( text ) ;

            // remove special logical operators from the term (case insensitive)
            // these are keywords for SOSL, can't escape them so we exclude them from the search term
            escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );

            // escape reserved characters
            // note, we handled single quotes above already
            // note, we do not handle \, it ends up being overly escaped
            // ? & | ! { } [ ] ( ) ^ ~ * : \ " ' + -
            Pattern myPattern = Pattern.compile( '(\\?|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\(|\\)|\\^|\\~|\\*|\\:|\\"|\\+|\\-)' );
            Matcher myMatcher = myPattern.matcher( escapedText );

            // we need 4 slashes (\\\\\\\\)
            //      ...in apex that translates into a string literal of just 4 (\\\\)
            //      ...once the replaceAll method runs it parses the input as regex, and regex like apex needs slashes escaped so the 4 (\\\\) it received is interpreted as regex literal of 2 (\\)
            //      ...we return the apex literal string with each special character now prefixed with 2 slashes (\\)
            //      ...when Search.query() method parses the escaped string literal we return from here those 2 slashes (\\) get interpreted as 1 slash (\)
            escapedText = myMatcher.replaceAll( '\\\\$1' );

            // collapse repeated whitespace
            escapedText = escapedText.replaceAll( '( )+', ' ' ).trim();

        }

        return escapedText;
    }
private void populateHierarchyObjectQueryFields( 
    List<Amgt.HierarchyConfigurationField> configFields,
    Map<String, Schema.SObjectField> fieldDescribeMap,
    List<String> fields,
    Set<String> fieldsSet,
    Map<String, String> lookupFields) {
    this.populateHierarchyObjectQueryFields(
        configFields,
        fieldDescribeMap,
        fields,
        fieldsSet,
        lookupFields,
        true
    );
}

private void populateHierarchyObjectQueryFields( 
    List<Amgt.HierarchyConfigurationField> configFields,
    Map<String, Schema.SObjectField> fieldDescribeMap,
    List<String> fields,
    Set<String> fieldsSet,
    Map<String, String> lookupFields,
    boolean fetchPicklistLabel) {
    for(Amgt.HierarchyConfigurationField hierarchyField : configFields) {
        if(hierarchyField.fieldAPIName != 'Id' && hierarchyField.fieldAPIName != 'Name') {
            fields.add(hierarchyField.fieldApiName);
            Schema.DisplayType fieldType = fieldDescribeMap
                    .get(hierarchyField.fieldApiName)
                    .getDescribe()
                    .getType();
            if(fieldDescribeMap.containsKey(hierarchyField.fieldApiName) && 
                (fieldType  == Schema.DisplayType.MultiPicklist
                ||fieldType  == Schema.DisplayType.Picklist)
            ) {

                fieldsSet.add(fetchPicklistLabel?String.format('toLabel({0})',new List<String> {hierarchyField.fieldApiName}):hierarchyField.fieldApiName);
            } else if (fieldDescribeMap.containsKey(hierarchyField.fieldApiName)){
                fieldsSet.add(hierarchyField.fieldApiName);
            }
            if(fieldDescribeMap.containsKey(hierarchyField.fieldApiName) && 
                fieldType == Schema.DisplayType.REFERENCE
                ) {
                    lookupFields.put(hierarchyField.fieldApiName, fieldDescribeMap
                    .get(hierarchyField.fieldApiName)
                    .getDescribe()
                    .getRelationshipName());
                    fields.add(getReference(hierarchyField.fieldApiName, '.Name'));
                    fieldsSet.add(getReference(hierarchyField.fieldApiName, '.Name'));
            }
        }
    }
}
}