/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is a Lightning service manager class for the mobile Asset hierarchy component.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni       22 Novemeber 2021     Created.
 *              Hemant Keni       10 January   2022     [A360MOB-175] - Root asset is not displayed in the hierarchy, tree always start from 1 level down.
 *****************************************************************************************************/
public with sharing class MOBAMGT_AssetHierarchyManager {

    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final MOBAMGT_AssetHierarchyManager INSTANCE = new MOBAMGT_AssetHierarchyManager();

    /**
     * Private static variable to hold instance of describe manager which will be consumed to 
     * retrieve entity and field definitions.
     */
    public static final COMM_DescribeManager DESCRIBE_MANAGER = COMM_DescribeManager.getInstance();

    /**
     * Private static variable to hold the maximu number of parent allowed in SOQL.
     */
    public static final Integer MAX_PARENT_LEVEL_IN_SOQL = 4;

    /**
     * public static instance variable to hold location_to_asset hierarchy type
     */
    public static final String LOCATION_TO_ASSET = 'location_to_asset';

    /**
     * public static instance variable to hold asset_only hierarchy type
     */
    public static final String ASSET_ONLY = 'asset_only';

    /**
     * public static instance variable to hold account_to_asset hierarchy type
     */
    public static final String ACCOUNT_TO_ASSET = 'account_to_asset';

    /**
     * Private static instance variable to hold the maximum number of asset hierarchy levels allowed in mobile
     */
    public static final Integer MAX_ROOT_PARENT_LEVEL = 8;

    /**
     * Private static instance variable to hold the default asset notification criteria.
     */
    private static final String DEFAULT_ASSET_NOTIFICATION_CRITERIA = 'SVMXA360__Status__c = \'Open\' AND SVMXA360__Severity__c IN (\'Moderate\', \'Critical\')';

    /**
     * Public method to retrieve instance of this class.
     */
    public static MOBAMGT_AssetHierarchyManager getInstance() {
        return INSTANCE;
    }

    /**
     * This method retrieves hierarchy type root node.
     * 
     * @param recordId - Record id whose hierarchy type root node we want to fetch.
     * 
     * @return - Returns MobileAmgt.RootHierarchyNode.
     */
    public MobileAmgt.RootHierarchyNode getHierarchyTypeRootNode(Id recordId){
        System.debug( LoggingLevel.DEBUG, 'getHierarchyTypeRootNode() - enter; recordId - ' + recordId);

        MobileAmgt.RootHierarchyNode rootNode;
        try {
            if(recordId == null){
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            MobileAmgt.HierarchyRootNodeRequest rootNodeHierarchyRequest = new MobileAmgt.HierarchyRootNodeRequest();
            rootNodeHierarchyRequest.recordId = recordId;

            rootNode = retrieveHierarchyTypeRootNode(rootNodeHierarchyRequest);
        } catch(SvmxSystem.SvmxNestedException ex) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyTypeRootNode() : Failed to retrieve Hierarchy type root node. Error= ' + ex.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_BadConfig );
        } catch(Exception ex) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyTypeRootNode() : Failed to retrieve Hierarchy type root node. Error= ' + ex.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyTypeRootNode() - Exit;');
        }

        return rootNode;

    }
    /**
     * This method retrieves hierarchy type root node.
     * 
     * @param retrieveRootNodeRequest - Wrapper that contains Record id whose hierarchy type root node we want to fetch and 
     *                                  the hierarchy configuration for the user.
     * 
     * @return - Returns MobileAmgt.RootHierarchyNode.
     */
    public MobileAmgt.RootHierarchyNode retrieveHierarchyTypeRootNode(MobileAmgt.HierarchyRootNodeRequest retrieveRootNodeRequest){
        System.debug( LoggingLevel.DEBUG, 'retrieveHierarchyTypeRootNode() - enter; retrieveRootNodeRequest - ' + retrieveRootNodeRequest);
        
        MobileAmgt.RootHierarchyNode rootNode;
        try{
            
            if(retrieveRootNodeRequest == null || retrieveRootNodeRequest.recordId == null){
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            Id recordId = retrieveRootNodeRequest.recordId;

            String sobjectName = String.valueOf(recordId.getSObjectType()).toLowerCase();
            String hierarchyType = getHierarchyType(sobjectName);

            if(sobjectName == 'location'){
                // When loading the hierarchy from Location, return the Assets hierarchy belong to that location.
                return getLocationRootNode(retrieveRootNodeRequest);
            }
            Id assetHierarchyId = getAssetHierarchyId(recordId);

            // Get the asset root hierarchy
            List<MobileAmgt.HierarchyNode> hierarchyNodes = getRootHierarchy(assetHierarchyId, MAX_ROOT_PARENT_LEVEL, retrieveRootNodeRequest.hierarchyConfiguration);
            if(hierarchyNodes != null && !hierarchyNodes.isEmpty()){
                Id rootAssetId = hierarchyNodes.get(hierarchyNodes.size()-1).Id;
                List<Asset> parentAssetList = (List<Asset>) SvmxDatabase.query([SELECT Name, Location.Name, Account.Name, ParentId, AssetLevel, RootAssetId FROM Asset WHERE Id = : rootAssetId LIMIT 1]);

                if(!parentAssetList.isEmpty()){
                    //Get the root node details
                    switch on hierarchyType {
                        when 'location_to_asset' {
                            rootNode = getLocationToAssetHierarchyNode(parentAssetList[0]);
                        }
                        when 'asset_only'{
                            rootNode = getAssetOnlyHierarchyNode(parentAssetList[0]);
                        }
                        when 'account_to_asset' {
                            rootNode = getAccountToAssetHierarchyNode(parentAssetList[0]);
                        }
                        when else{
                            throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
                        }
                    }
                    rootNode.hierarchyconfiguration = retrieveRootNodeRequest.hierarchyConfiguration;
                    MobileAmgt.HierarchyNode childHierarchyNode = formRootHierarchy(hierarchyNodes, retrieveRootNodeRequest.hierarchyConfiguration);
                    rootNode.childNodes = childHierarchyNode != null ? (new List<MobileAmgt.HierarchyNode> { childHierarchyNode }) : null;
                    rootNode.assetHierarchyId = assetHierarchyId;
                    rootNode.rootNodeParentId = parentAssetList[0].ParentId;
                    rootNode.assetLevel = parentAssetList[0].AssetLevel;
                    rootNode.actualRootId = parentAssetList[0].RootAssetId;
                    Boolean enableNotifications = retrieveRootNodeRequest.hierarchyConfiguration ?. assetHierarchyConfig ?. enableNotifications;
                    if(enableNotifications == true){
                        populateOpenNotificationsOnRootNode(rootNode);
                    }
                }
            }

        } catch(SvmxSystem.SvmxNestedException ex) {
            System.debug( LoggingLevel.ERROR, 'retrieveHierarchyTypeRootNode() : Failed to retrieve Hierarchy type root node. Error= ' + ex.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_BadConfig );
        } catch(Exception ex) {
            System.debug( LoggingLevel.ERROR, 'retrieveHierarchyTypeRootNode() : Failed to retrieve Hierarchy type root node. Error= ' + ex.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
        } finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveHierarchyTypeRootNode() - Exit;');
        }

        return rootNode;
    }

    public List<Asset> retrieveSearchedAssets(final MobileAmgt.AssetHierarchySearch searchRequest){
        List<Asset> assetList;

        try {
            if (searchRequest == null || String.isEmpty(searchRequest.searchTerm) || String.isEmpty(searchRequest.hierarchyType) || searchRequest.recordId == null) {
                System.debug( LoggingLevel.ERROR, 'One or more required parameters are missing. searchRequest ' + searchRequest);
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
            }
    
            String searchTerm = String.escapeSingleQuotes(searchRequest.searchTerm);
            String hierarchyType = String.escapeSingleQuotes(searchRequest.hierarchyType);

            String objectType = String.valueOf(searchRequest.recordId.getSObjectType()).toLowerCase();
            String filterClause = ' WHERE ';

            if (objectType == 'location') {
                filterClause += ' LocationId =\'' + searchRequest.recordId + '\' AND Name LIKE \'%' +searchTerm+ '%\' ';
            } else if (objectType == 'account') {
                filterClause += ' AccountId =\'' + searchRequest.recordId + '\' AND Name LIKE \'%' +searchTerm+ '%\' ';
            } else if (objectType == 'workorder' || objectType == 'asset') {
                if (searchRequest.actualRootId == null || searchRequest.assetHierarchyId == null) {
                    System.debug( LoggingLevel.ERROR, 'One or more required parameters are missing. searchRequest ' + searchRequest);
                    throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
                }
                if (hierarchyType == LOCATION_TO_ASSET){
                    filterClause += ' RootAsset.LocationId =\'' + searchRequest.assetHierarchyId + '\' AND Name LIKE \'%' +searchTerm+ '%\' ';
                } else if (hierarchyType == ACCOUNT_TO_ASSET){
                    filterClause += ' AccountId =\'' + searchRequest.assetHierarchyId + '\' AND Name LIKE \'%' +searchTerm+ '%\' ';
                } else if (hierarchyType == ASSET_ONLY) {
                    filterClause += 'RootAssetId =\'' +searchRequest.actualRootId+ '\' AND Name LIKE \'%' +searchTerm+ '%\' ';
                }
            }
            System.debug(LoggingLevel.DEBUG, 'filterClause '+ filterClause);
            assetList = (List<Asset>) SvmxDatabase.query('Select Name, Status FROM Asset '+ filterClause + ' ORDER BY Name ASC LIMIT 1000');
        } catch(Exception ex){
            System.debug( LoggingLevel.ERROR, 'retrieveSearchedAssets() : Failed to retrieve Hierarchy type root node. Error= ' + ex.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
        }

        return assetList;
    }

    /**
     * This method retrieves initial hierarchy of the given location record id.
     * 
     * @param locationId - Location id whose root hierarchy we want to fetch
     * 
     * @return - Returns MobileAmgt.RootHierarchyNode for the given location id.
     */
    private MobileAmgt.RootHierarchyNode getLocationRootNode(MobileAmgt.HierarchyRootNodeRequest retrieveRootNodeRequest){
        System.debug( LoggingLevel.DEBUG, 'getLocationRootNode() - enter; retrieveRootNodeRequest - ' + retrieveRootNodeRequest);

        Id locationId = retrieveRootNodeRequest.recordId;

        if(locationId == null){
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }

        MobileAmgt.RootHierarchyNode rootNode = new MobileAmgt.RootHierarchyNode();
        List<Schema.Location> locationList =  (List<Schema.Location>) SvmxDatabase.query([SELECT Name, RootLocationId FROM Location WHERE Id =: locationId LIMIT 1]);

        if(locationList.isEmpty()){
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
        }

        rootNode.id = locationId;
        rootNode.name = locationList[0].Name;
        rootNode.actualRootId = locationList[0].RootLocationId;
        rootNode.hierarchyconfiguration = retrieveRootNodeRequest.hierarchyConfiguration;

        MobileAmgt.HierarchyNodesRequest hierarchyRequest = new MobileAmgt.HierarchyNodesRequest();
        hierarchyRequest.recordId = locationId;
        hierarchyRequest.offset = 0;
        hierarchyRequest.assetLevel = 1;
        hierarchyRequest.hierarchyConfiguration = rootNode.hierarchyconfiguration;

        // Get the Asset hierarchy node for the given location.
        Map<Id, MobileAmgt.HierarchyNode> locationNodeMap = getHierarchyNodes(new List<MobileAmgt.HierarchyNodesRequest> {hierarchyRequest} );
        
        if(locationNodeMap != null && !locationNodeMap.isEmpty()){
            MobileAmgt.HierarchyNode locationExpandedNode = locationNodeMap.get(locationId);
            rootNode.childNodes = populateChildrenCount( (locationExpandedNode != null ? locationExpandedNode.childNodes : null),  rootNode.hierarchyconfiguration);
        }
        rootNode.hierarchyType = LOCATION_TO_ASSET;

        String buildCriteria = getAssetHierarchyExpressions(hierarchyRequest.hierarchyConfiguration );

        String childAssetCountClause = 'LocationId =\''+locationId+'\' AND AssetLevel =1';
        AggregateResult[] aggregateResultList = getAssetAggregrateResult('LocationId', childAssetCountClause, buildCriteria);

        rootNode.totalChildrens = aggregateResultList.isEmpty() ? 0 : (Integer) aggregateResultList[0].get('expr0');
        rootNode.rootNodeParentId = locationId;

        Boolean enableNotifications = rootNode.hierarchyConfiguration ?. assetHierarchyConfig ?. enableNotifications;
        if(enableNotifications == true){
            populateOpenNotificationsOnRootNode(rootNode);
        }

        System.debug( LoggingLevel.DEBUG, 'getLocationRootNode() - exit');
        return rootNode;
    }

    private MobileAmgt.RootHierarchyNode populateOpenNotificationsOnRootNode(MobileAmgt.RootHierarchyNode rootNode){
        System.debug( LoggingLevel.DEBUG, 'populateOpenNotificationsOnRootNode() - Enter; childNodes - ' + rootNode);

        if(rootNode == null){
            System.debug( LoggingLevel.ERROR, 'populateOpenNotificationsOnRootNode() : One or more required parameters are missing. rootNode - '+ rootNode );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );  
        }


        List<Id>  hierarchyNodeIds = (rootNode.childNodes == null || rootNode.childNodes.isEmpty())
                                        ? null
                                        : extractChildNodeIds(rootNode.childNodes);

        if(hierarchyNodeIds != null && !hierarchyNodeIds.isEmpty()){

            String assetNotificationcriteria = getAssetNotificationCriteria(rootNode.hierarchyconfiguration);
            String assetNotificationQuery = 'SELECT ID FROM SVMXA360__Asset_Notifications__r WHERE ' + assetNotificationcriteria + ' ORDER BY CreatedDate DESC LIMIT 1';

            String assetWhereClasue = 'WHERE ID IN (\'' + String.join(hierarchyNodeIds, '\',\'') + '\')';
    
            List<Asset> assetList = (List<Asset>) SvmxDatabase.query(
                String.format(
                    'SELECT ({0}) from Asset {1}',
                    new List<String> {
                        assetNotificationQuery,
                        assetWhereClasue
                    }
                )
            );

            Map<Id, Asset> assetMap = new Map<Id, Asset>(assetList);
            if(assetMap != null && !assetMap.isEmpty()) {
                populateOpenNotification(rootNode.childNodes, assetMap);
            }
        }

        System.debug( LoggingLevel.DEBUG, 'populateOpenNotificationsOnRootNode() - Exit; childNodes - ' + rootNode);

        return rootNode;
    }

    private String getAssetNotificationCriteria(MobileAmgt.HierarchyConfiguration hierarchyConfiguration){
        System.debug( LoggingLevel.DEBUG, 'getAssetNotificationCriteria() - Enter; hierarchyConfiguration - ' + hierarchyConfiguration);
        String notificationCriteria;

        if(hierarchyConfiguration != null && hierarchyConfiguration.assetHierarchyConfig != null){
            notificationCriteria = getAssetNotificationCriteria(hierarchyConfiguration.assetHierarchyConfig);
        } else {
            notificationCriteria = getDefaultAssetOpenNotificationCriteria();
        }

        System.debug( LoggingLevel.DEBUG, 'getAssetNotificationCriteria() - Exit; notificationCriteria - ' + notificationCriteria);
        return notificationCriteria;
    }

    private String getAssetNotificationCriteria(MobileAmgt.HierarchyConfigurationDetail hierarchyConfigurationDetail){
        System.debug( LoggingLevel.DEBUG, 'getAssetNotificationCriteria() - Enter; hierarchyConfigurationDetail - ' + hierarchyConfigurationDetail);
        String notificationCriteria;

        if(hierarchyConfigurationDetail != null && hierarchyConfigurationDetail.enableNotifications == true && String.isNotEmpty(hierarchyConfigurationDetail.notificationCriteriaId)){
            String qualifyingCriteria = hierarchyConfigurationDetail.notificationCriteriaId;
            Map<Id,Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( new List<String>{qualifyingCriteria}, null );
            notificationCriteria = COMM_ExpressionUtils.getInstance().buildCriteria(expressions.get(qualifyingCriteria));
        } else {
            notificationCriteria = getDefaultAssetOpenNotificationCriteria();
        }
        System.debug( LoggingLevel.DEBUG, 'getAssetNotificationCriteria() - Exit; notificationCriteria - ' + notificationCriteria);
        return notificationCriteria;
    }

    private MobileAmgt.HierarchyNode populateOpenNotificationsOnHierarchyNode(MobileAmgt.HierarchyNode hierarchyNode, Map<Id, Asset> assetMap){
        System.debug( LoggingLevel.DEBUG, 'populateOpenNotificationsOnHierarchyNode() - Enter; hierarchyNode - ' + hierarchyNode);

        if(hierarchyNode == null || hierarchyNode.childNodes == null || hierarchyNode.childNodes.isEmpty() || assetMap == null || assetMap.isEmpty()){
            System.debug( LoggingLevel.ERROR, 'populateOpenNotificationsOnRootNode() : One or more required parameters are missing. hierarchyNode - '+ hierarchyNode );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );  
        }

        populateOpenNotification(hierarchyNode.childNodes, assetMap);

        System.debug( LoggingLevel.DEBUG, 'populateOpenNotificationsOnHierarchyNode() - Exit; hierarchyNode - ' + hierarchyNode);

        return hierarchyNode;
    }

    private List<Id> extractChildNodeIds(List<MobileAmgt.HierarchyNode> childNodes){
        System.debug( LoggingLevel.DEBUG, 'extractChildNodeIds() - Enter; childNodes - ' + childNodes);
        if(childNodes == null || childNodes.isEmpty()){
            return null;
        }

        List<Id> recordIds = new List<Id>();

        for(MobileAmgt.HierarchyNode hierarchynode : childNodes) {
            if(hierarchynode != null){
                if(hierarchynode.id != null) {
                    recordIds.add(hierarchynode.id);
                }
                List<Id> childIdList = extractChildNodeIds(hierarchynode.childNodes);
                if(childIdList != null && !childIdList.isEmpty()){
                    recordIds.addAll(childIdList);
                }
            }
        }
        System.debug( LoggingLevel.DEBUG, 'extractChildNodeIds() - exit; recordIds - ' + recordIds);
        return recordIds;
    }

    private void populateOpenNotification(List<MobileAmgt.HierarchyNode> childNodes, Map<Id, Asset> assetMap){
        System.debug( LoggingLevel.DEBUG, 'populateOpenNotification() - Enter; childNodes - '+ childNodes + ' assetMap - '+ assetMap);
        if(childNodes != null && !childNodes.isEmpty()){
            for(MobileAmgt.HierarchyNode hierarchyNode : childNodes) {
                Asset assetNode = assetMap.get(hierarchyNode.id);
                hierarchyNode.hasOpenNotifications = assetNode.Asset_Notifications__r.size() > 0;
                populateOpenNotification(hierarchyNode.childNodes, assetMap);
            }
        }
    }

    /**
     * This method retrieves MobileAmgt.RootHierarchyNode with the root node details.
     * 
     * @param rootAsset - Top level asset whose root node details needs to be fetch
     * 
     * @return - Returns MobileAmgt.RootHierarchyNode with the root node details. E.g. Location name and id.
     */
    private MobileAmgt.RootHierarchyNode getLocationToAssetHierarchyNode(Asset rootAsset){
        System.debug( LoggingLevel.DEBUG, 'getLocationToAssetHierarchyNode() - enter; rootAsset - ' + rootAsset);
        MobileAmgt.RootHierarchyNode rootNode = new MobileAmgt.RootHierarchyNode();
        if(rootAsset != null){
            // If the location is present on the Asset then consider that Location and form the hierarchy 
            // for that location else fallback to the Asset_only hierarchy.
            if(rootAsset.LocationId != null){
                rootNode.name = rootAsset.Location.Name;
                rootNode.id = rootAsset.LocationId;
            } else {
                return getAssetOnlyHierarchyNode(rootAsset);
            }
        }
        rootNode.hierarchyType = LOCATION_TO_ASSET;
        System.debug( LoggingLevel.DEBUG, 'getLocationToAssetHierarchyNode() - exit');
        return rootNode;
    }

    /**
     * This method retrieves the selected asset record id for the initial asset hierachy screen.
     * 
     * @param recordId - Top level asset whose root node details needs to be fetch
     * 
     * @return - Returns id of the selected asset for the initial asset hierachy screen.
     */
    private Id getAssetHierarchyId(Id recordId){
        System.debug( LoggingLevel.DEBUG, 'getAssetHierarchyId() - enter; recordId - ' + recordId);
        Id assetHierarchyId;
        if(recordId != null){
            String sobjectName = String.valueOf(recordId.getSObjectType()).toLowerCase();
            if(sobjectName == 'workorder'){
                List<WorkOrder> workOrderList = (List<WorkOrder>) SvmxDatabase.query([SELECT AssetId FROM WorkOrder WHERE ID =: recordId LIMIT 1]);
                if(workOrderList.isEmpty()){
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                }

                WorkOrder primaryRecord = workOrderList[0];
                if(primaryRecord == null){
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                }

                if(primaryRecord.AssetId == null){
                    throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_BadConfig );
                }
                assetHierarchyId = primaryRecord.AssetId;
            } else {
                assetHierarchyId = recordId;
            }
        }
        System.debug( LoggingLevel.DEBUG, 'getAssetHierarchyId() - exit');
        return assetHierarchyId;
    }

    /**
     * This method forms the childNodes hierarchy and returns the MobileAmgt.HierarchyNode.
     * 
     * @param hierarchyNodeList - List of Hierarchy nodes
     * 
     * @return - Returns MobileAmgt.HierarchyNode that will contain all the childNodes
     */
    private MobileAmgt.HierarchyNode formRootHierarchy(List<MobileAmgt.HierarchyNode> hierarchyNodeList, MobileAmgt.HierarchyConfiguration hierarchyconfiguration){
        MobileAmgt.HierarchyNode hierarchyNode;
        if(hierarchyNodeList != null && !hierarchyNodeList.isEmpty()){
            // We get the hierarchy asset node list in the the reverse order(child-to-parent). 
            // So we are reversing teh list first.
            List<MobileAmgt.HierarchyNode> assetHierarchyNodeList = reverseHierarchyNodeList(hierarchyNodeList);
            //  Get the hierarchy nodes that matches the criteria.
            assetHierarchyNodeList = getHierarchyNodesByCriteria(assetHierarchyNodeList, hierarchyconfiguration);

            if(assetHierarchyNodeList != null && assetHierarchyNodeList.size() > 0) {

                hierarchyNode = assetHierarchyNodeList.get(0);
                for(Integer index = 0; index < assetHierarchyNodeList.size() -1; index++) {
                    // Form the hierarchy of child nodes
                    assetHierarchyNodeList[index].childNodes = new List<MobileAmgt.HierarchyNode>{ assetHierarchyNodeList[index+1] };
                }
            }
        }
        return hierarchyNode;
    }

    /**
     * This method reverese the list.
     * 
     * @param hierarchyNodeList - List of MobileAmgt.HierarchyNode(Asset Hierarchy nodes)
     * 
     * @return - Returns the lit in reverse order.  List of MobileAmgt.HierarchyNode(Asset Hierarchy nodes) from top parent to child.
     */
    private List<MobileAmgt.HierarchyNode> reverseHierarchyNodeList(List<MobileAmgt.HierarchyNode> hierarchyNodeList) {
        System.debug( LoggingLevel.DEBUG, 'reverseHierarchyNodeList() - enter; roothierarchyNodeListAsset - ' + hierarchyNodeList);
        if(hierarchyNodeList == null || hierarchyNodeList.isEmpty()){
            return null;
        }

        List<MobileAmgt.HierarchyNode> hierarchyNodeListToReturn = new List<MobileAmgt.HierarchyNode>();
        for(Integer i=hierarchyNodeList.size()-1; i > -1; i--){
            hierarchyNodeListToReturn.add(hierarchyNodeList[i]);
        }

        System.debug( LoggingLevel.DEBUG, 'reverseHierarchyNodeList() - exit; hierarchyNodeListToReturn - ' + hierarchyNodeListToReturn);
        return hierarchyNodeListToReturn;
    } 

    /**
     * This method filters the Asst hierarchy nodes that matches the criteria.
     * 
     * @param hierarchyNodes - List of Asset hierarchy nodes(MobileAmgt.HierarchyNode) from top parent to child
     * @param hierarchyconfiguration - Hierarchy configuration done by the admin in config screen
     * 
     * @return - Filters the Asset hierarchy nodes based on the criteria configured by the admin.
     */
    private List<MobileAmgt.HierarchyNode> getHierarchyNodesByCriteria(List<MobileAmgt.HierarchyNode> hierarchyNodes, MobileAmgt.HierarchyConfiguration hierarchyconfiguration) {
        System.debug( LoggingLevel.DEBUG, 'getHierarchyNodesByCriteria() - enter; hierarchyNodes - ' + hierarchyNodes + ' ; hierarchyconfiguration - '+ hierarchyconfiguration);
        List<MobileAmgt.HierarchyNode> hierarchyNodesToReturn = new List<MobileAmgt.HierarchyNode>();
        if(hierarchyNodes == null || hierarchyNodes.size() == 0){
            return null;
        }
        
        List<Id> assetIdList = new List<Id>();
        for(MobileAmgt.HierarchyNode assetNode : hierarchyNodes) {
            assetIdList.add(assetNode.id);
        }

        String assetWhereClause = ' WHERE ID IN (\'' + String.join(assetIdList, '\',\'') + '\') ';

        String buildCriteria = getAssetHierarchyExpressions(hierarchyConfiguration);
        if(String.isNotEmpty(buildCriteria)) {
            assetWhereClause += ' AND ' + buildCriteria;
        }

        System.debug( LoggingLevel.DEBUG, 'getHierarchyNodesByCriteria() -  assetWhereClause - ' + assetWhereClause);
        List<Asset> hierarchyAssets = (List<Asset>) SvmxDatabase.query('SELECT Id from Asset '+ assetWhereClause);
        hierarchyNodesToReturn = getFilteredHierarchyNodes(hierarchyNodes, hierarchyAssets);

        System.debug( LoggingLevel.DEBUG, 'getHierarchyNodesByCriteria() - exit; hierarchyNodesToReturn - ' + hierarchyNodesToReturn);
        return hierarchyNodesToReturn;
    }

    /**
     * This method filters the Asst hierarchy nodes that matches the criteria.
     * 
     * @param hierarchyNodes - List of Asset hierarchy nodes(MobileAmgt.HierarchyNode) from top parent to child
     * @param hierarchyAssets - List of assets that matched the criteria.
     * 
     * @return - Returns the filtered list of hierarchy nodes that matched the asset hierarchy criteria.
     */
    private List<MobileAmgt.HierarchyNode> getFilteredHierarchyNodes(List<MobileAmgt.HierarchyNode> hierarchyNodes, List<Asset> hierarchyAssets){
        System.debug( LoggingLevel.DEBUG, 'getFilteredHierarchyNodes() - enter; hierarchyNodes - ' + hierarchyNodes + ' ; hierarchyAssets - '+ hierarchyAssets);
        List<MobileAmgt.HierarchyNode> hierarchyNodesToReturn = new List<MobileAmgt.HierarchyNode>();

        if(hierarchyNodes == null || hierarchyNodes.size() == 0 || hierarchyAssets == null || hierarchyAssets.size() == 0) {
            return null;
        }
        for(MobileAmgt.HierarchyNode hierarchyNode : hierarchyNodes) {
            Boolean isAssetMeetCriteria = false;
            for(Asset assetNode : hierarchyAssets) {
                if(hierarchyNode.id == assetNode.id) {
                    isAssetMeetCriteria = true;
                    hierarchyNode.expandByDefault = true;
                    hierarchyNodesToReturn.add(hierarchyNode);
                    break;
                }
            }
            if(!isAssetMeetCriteria) {
                break;
            }
        }

        if(hierarchyNodesToReturn.size() > 0) {
            hierarchyNodesToReturn[ hierarchyNodesToReturn.size() - 1 ].expandByDefault = false;
        }
        System.debug( LoggingLevel.DEBUG, 'getFilteredHierarchyNodes() - exit; hierarchyNodesToReturn - ' + hierarchyNodesToReturn);
        return hierarchyNodesToReturn;
    }

    /**
     * This method retrieves MobileAmgt.RootHierarchyNode with the root node details.
     * 
     * @param rootAsset - Top level asset whose root node details needs to be fetch
     * 
     * @return - Returns MobileAmgt.RootHierarchyNode with the root node details. E.g. Account name and id.
     */
    private MobileAmgt.RootHierarchyNode getAccountToAssetHierarchyNode(Asset rootAsset){
        System.debug( LoggingLevel.DEBUG, 'getAccountToAssetHierarchyNode() - enter; rootAsset - ' + rootAsset);
        MobileAmgt.RootHierarchyNode rootNode = new MobileAmgt.RootHierarchyNode();
        if(rootAsset != null){
            // If the Account is present on the Asset then consider that Account and form the hierarchy for that Account 
            // else fallback to the Asset_only hierarchy.
            if(rootAsset.AccountId != null){
                rootNode.name = rootAsset.Account.Name;
                rootNode.id = rootAsset.AccountId;
            } else {
                return getAssetOnlyHierarchyNode(rootAsset);
            }
        }
        rootNode.hierarchyType = ACCOUNT_TO_ASSET;
        System.debug( LoggingLevel.DEBUG, 'getAccountToAssetHierarchyNode() - exit');
        return rootNode;
    }

    /**
     * This method retrieves MobileAmgt.RootHierarchyNode with the root node details.
     * 
     * @param rootAsset - Top level asset whose root node details needs to be fetch
     * 
     * @return - Returns MobileAmgt.RootHierarchyNode with the root node details. E.g. Asset name and id.
     */
    private MobileAmgt.RootHierarchyNode getAssetOnlyHierarchyNode(Asset rootAsset){
        MobileAmgt.RootHierarchyNode rootNode = new MobileAmgt.RootHierarchyNode();
        if(rootAsset != null){
            rootNode.name = rootAsset.Name;
            rootNode.id = rootAsset.Id;
        }
        rootNode.hierarchyType = ASSET_ONLY;
        return rootNode;
    }

    /**
     * This method retrieves hierarchy nodes.
     * 
     * @param recordIdVsOffsetMap - Map of Record id vs offset, whose hierarchy we want to fetch.
     * 
     * @return - Returns MobileAmgt.HierarchyNode list for teh given records.
     */
    public Map<Id, MobileAmgt.HierarchyNode> getHierarchyNodes( final List<MobileAmgt.HierarchyNodesRequest> hierarchyRequestList ) {
        System.debug( LoggingLevel.DEBUG, 'getHierarchyNodes() - enter; hierarchyRequestList - ' + hierarchyRequestList);
        Map<Id, MobileAmgt.HierarchyNode> expandedNodeMap = new Map<Id, MobileAmgt.HierarchyNode>();
        
        try { 
            if( hierarchyRequestList == null || hierarchyRequestList.isEmpty()) {
                System.debug( LoggingLevel.ERROR, 'retrieveHierarchyNodes() : One or more required parameters are missing. hierarchyRequestList - '+ hierarchyRequestList);
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
            }

            for(MobileAmgt.HierarchyNodesRequest hierarchyRequest : hierarchyRequestList){
                String sobjectName = String.valueOf(hierarchyRequest.recordId.getSObjectType()).toLowerCase();
                if (sobjectName == AMGT_AssetHierarchyManager.LOCATION) { 
                    expandedNodeMap.put(hierarchyRequest.recordId, getLocationAssetNode(hierarchyRequest));
                } else if (sobjectName == AMGT_AssetHierarchyManager.ASSET) { 
                    expandedNodeMap.put(hierarchyRequest.recordId, getAssetNodes(hierarchyRequest));
                } else if (sobjectName == AMGT_AssetHierarchyManager.ACCOUNT) { 
                    expandedNodeMap.put(hierarchyRequest.recordId, getAccountAssetNodes(hierarchyRequest));
                }
            }
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyNodes() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException(System.Label.Error_AssetHierarchy_ServerError);
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyNodes() - exit; response.size() =' + expandedNodeMap.keyset());
        }

        return expandedNodeMap;
    }


    /**
     * This method retrieves Asset hierarchy nodes of Location record.
     * 
     * @param recordIds - Location record id whose Asset hierarchy we want to fetch.
     * @param offset - Records in a order starting from. This is used for the pagination.
     * 
     * @return - Returns Asset hierarchy nodes of Location record.
     */
    public MobileAmgt.HierarchyNode getLocationAssetNode( final MobileAmgt.HierarchyNodesRequest hierarchyRequest) {
        System.debug( LoggingLevel.DEBUG, 'getLocationAssetNode() - enter; hierarchyRequest - '+ hierarchyRequest);
        MobileAmgt.HierarchyNode expandedNode = new MobileAmgt.HierarchyNode();

        final Id recordId = hierarchyRequest.recordId;
        final Integer offset = hierarchyRequest.offset;
        final Integer assetLevel = (hierarchyRequest.assetLevel == null || hierarchyRequest.assetLevel == 0)
                                    ? 1
                                    : hierarchyRequest.assetLevel;

        if(recordId == null || offset == null || offset < 0 || offset > 20001) {
            System.debug( LoggingLevel.ERROR, 'getLocationAssetNode() : One or more required parameters are missing. recordId = ' + recordId + '; offset = '+ offset);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        String buildCriteria = getAssetHierarchyExpressions(hierarchyRequest.hierarchyConfiguration);

        Set<String> assetFieldSet = new Set<String>();
        assetFieldSet.add('Name');
        assetFieldSet.add('Status');

        String childAssetWhereClause = '';
        String assetWhereClause = 'WHERE LocationId = \''+ recordId + '\' AND AssetLevel = '+  assetLevel;
        if (String.isNotBlank(buildCriteria)){
            childAssetWhereClause = 'WHERE '+ buildCriteria;
            assetWhereClause += ' AND '+ buildCriteria;
        }

        String childAssetsQuery = 'SELECT Id FROM ChildAssets ' +childAssetWhereClause+ ' LIMIT 1 ';
        String assetNotificationcriteria = getAssetNotificationCriteria(hierarchyRequest.hierarchyConfiguration ?. assetHierarchyConfig);
        String openNotificationsQuery = 'SELECT ID FROM SVMXA360__Asset_Notifications__r WHERE ' + assetNotificationcriteria + ' ORDER BY CreatedDate DESC LIMIT 1';

        List<Asset> locationAssets = (List<Asset>) SvmxDatabase.query(
            String.format(
                'SELECT {0}, ({1}), ({2}) from Asset {3} ORDER BY NAME  LIMIT 50 OFFSET {4}',
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    childAssetsQuery,
                    openNotificationsQuery,
                    assetWhereClause,
                    String.valueOf(offset)
                }
            )
        );

        if(!locationAssets.isEmpty()) {
            String childAssetCountClause = 'LocationId =\''+recordId+'\' AND AssetLevel =' +assetLevel;
            AggregateResult[] aggregateResultList = getAssetAggregrateResult('LocationId', childAssetCountClause, buildCriteria);
    

            List<MobileAmgt.HierarchyNode> nodes = new List<MobileAmgt.HierarchyNode> ();
            Map<Id, Asset> locationAssetMap = new Map<Id, Asset>();
            for(Asset assetObj : locationAssets) {
                nodes.add(getAssetHierarchyNode(assetObj));
                locationAssetMap.put(assetObj.Id, assetObj);
            }
            populateChildrenCount(nodes, hierarchyRequest.hierarchyConfiguration);
            expandedNode.childNodes = nodes;
            populateOpenNotificationsOnHierarchyNode(expandedNode, locationAssetMap);
            expandedNode.totalChildrens = aggregateResultList.isEmpty() ? 0 : (Integer) aggregateResultList[0].get('expr0');
            expandedNode.hasChildren = expandedNode.totalChildrens > 0;
            expandedNode.id = recordId;
        }
        System.debug( LoggingLevel.DEBUG, 'getLocationAssetNode() - exit');
        return expandedNode;
    }

    /**
     * This method retrieves Asset hierarchy nodes of Asset record.
     * 
     * @param recordIds - Asset record id whose Asset hierarchy we want to fetch.
     * 
     * @return - Returns Asset hierarchy nodes of Asset record.
     */
    public MobileAmgt.HierarchyNode getAssetNodes( final MobileAmgt.HierarchyNodesRequest hierarchyRequest) {
        System.debug( LoggingLevel.DEBUG, 'getAssetNodes() - enter; hierarchyRequest - '+ hierarchyRequest);
        MobileAmgt.HierarchyNode expandedNode = new MobileAmgt.HierarchyNode();

        final Id recordId = hierarchyRequest.recordId;
        final Integer offset = hierarchyRequest.offset;

        if(recordId == null || offset == null || offset < 0 || offset > 20001) {
            System.debug( LoggingLevel.ERROR, 'getAssetNodes() : One or more required parameters are missing. recordId = ' + recordId + '; offset = '+ offset);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        String buildCriteria = getAssetHierarchyExpressions(hierarchyRequest.hierarchyConfiguration);

        Set<String> assetFieldSet = new Set<String>();
        assetFieldSet.add('Name');
        assetFieldSet.add('Status');
        assetFieldSet.add('AssetLevel');

        String childAssetWhereClause = '';
        String assetWhereClause = 'WHERE ParentId = \''+ recordId + '\'';
        if (String.isNotBlank(buildCriteria)){
            childAssetWhereClause = 'WHERE '+ buildCriteria;
            assetWhereClause += ' AND '+ buildCriteria;
        }

        String childAssetsQuery = 'SELECT Id FROM ChildAssets ' +childAssetWhereClause+ ' LIMIT 1 ';
        String assetNotificationcriteria = getAssetNotificationCriteria(hierarchyRequest.hierarchyConfiguration ?. assetHierarchyConfig);
        String openNotificationsQuery = 'SELECT ID FROM SVMXA360__Asset_Notifications__r WHERE ' + assetNotificationcriteria + ' ORDER BY CreatedDate DESC LIMIT 1';

        List<Asset> assetList = (List<Asset>) SvmxDatabase.query(
            String.format(
                'SELECT {0}, ({1}), ({2}) from Asset {3} ORDER BY NAME  LIMIT 50 OFFSET {4}',
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    childAssetsQuery,
                    openNotificationsQuery,
                    assetWhereClause,
                    String.valueOf(offset)
                }
            )
        );

        if(!assetList.isEmpty()) {
            String assetCountQuery = 'Select ParentId, count(Id) FROM Asset WHERE ParentId =\''+ recordId + '\' ';
            Integer parentAssetLevel = (assetList[0].AssetLevel - 1) <= 0 ? 1 :  (assetList[0].AssetLevel - 1);

            String childAssetCountClause = 'ParentId =\''+recordId+'\'';
            AggregateResult[] aggregateResultList = getAssetAggregrateResult('ParentId', childAssetCountClause, buildCriteria);

            List<MobileAmgt.HierarchyNode> nodes = new List<MobileAmgt.HierarchyNode> ();
            Map<Id, Asset> assetMap = new Map<Id, Asset>();
            for(Asset assetObj : assetList) {
                nodes.add(getAssetHierarchyNode(assetObj));
                assetMap.put(assetObj.id, assetObj);
            }
            populateChildrenCount(nodes, hierarchyRequest.hierarchyConfiguration);
            expandedNode.childNodes = nodes;
            populateOpenNotificationsOnHierarchyNode(expandedNode, assetMap);
            expandedNode.totalChildrens = aggregateResultList.isEmpty() ? 0 : (Integer) aggregateResultList[0].get('expr0');
            expandedNode.hasChildren = expandedNode.totalChildrens > 0;
            expandedNode.id = recordId;
        }

        System.debug( LoggingLevel.DEBUG, 'getAssetNodes() - exit');
        return expandedNode;
    }

    /**
     * This method retrieves Asset hierarchy nodes of Account record.
     * 
     * @param recordIds - Account record id whose Asset hierarchy we want to fetch.
     * 
     * @return - Returns Asset hierarchy nodes of Account record.
     */
    public MobileAmgt.HierarchyNode getAccountAssetNodes(final MobileAmgt.HierarchyNodesRequest hierarchyRequest) {
        System.debug( LoggingLevel.DEBUG, 'getAccountAssetNodes() - enter; hierarchyRequest - '+ hierarchyRequest);
        MobileAmgt.HierarchyNode expandedNode = new MobileAmgt.HierarchyNode();

        final Id recordId = hierarchyRequest.recordId;
        final Integer offset = hierarchyRequest.offset;

        if(recordId == null || offset == null || offset < 0 || offset > 20001) {
            System.debug( LoggingLevel.ERROR, 'getAccountAssetNodes() : One or more required parameters are missing. recordId = ' + recordId + '; offset = '+ offset);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        final Integer assetLevel = (hierarchyRequest.assetLevel == null || hierarchyRequest.assetLevel == 0)
                                    ? 1
                                    : hierarchyRequest.assetLevel;

        String buildCriteria = getAssetHierarchyExpressions(hierarchyRequest.hierarchyConfiguration);

        Set<String> assetFieldSet = new Set<String>();
        assetFieldSet.add('Name');
        assetFieldSet.add('Status');

        String childAssetWhereClause = '';
        String assetWhereClause = 'WHERE AccountId = \''+ recordId + '\' AND AssetLevel = '+  assetLevel;
        if (String.isNotBlank(buildCriteria)){
            childAssetWhereClause = 'WHERE '+ buildCriteria;
            assetWhereClause += ' AND '+ buildCriteria;
        }

        String childAssetsQuery = 'SELECT Id FROM ChildAssets ' +childAssetWhereClause+ ' LIMIT 1 ';
        String assetNotificationcriteria = getAssetNotificationCriteria(hierarchyRequest.hierarchyConfiguration ?. assetHierarchyConfig);
        String openNotificationsQuery = 'SELECT ID FROM SVMXA360__Asset_Notifications__r WHERE ' + assetNotificationcriteria + ' ORDER BY CreatedDate DESC LIMIT 1';

        List<Asset> accountAssets = (List<Asset>) SvmxDatabase.query(
            String.format(
                'SELECT {0}, ({1}), ({2}) from Asset {3} ORDER BY NAME  LIMIT 50 OFFSET {4}',
                new List<String> {
                    String.join(new List<String>(assetFieldSet), ', '),
                    childAssetsQuery,
                    openNotificationsQuery,
                    assetWhereClause,
                    String.valueOf(offset)
                }
            )
        );
                                    
        if(!accountAssets.isEmpty()) {

            String childAssetCountClause = 'AccountId =\''+recordId+'\' AND AssetLevel =' +assetLevel;
            AggregateResult[] aggregateResultList = getAssetAggregrateResult('AccountId', childAssetCountClause, buildCriteria);

            List<MobileAmgt.HierarchyNode> nodes = new List<MobileAmgt.HierarchyNode> ();
            Map<Id, Asset> accountAssetMap = new Map<Id, Asset>();
            for(Asset assetObj : accountAssets) {
                MobileAmgt.HierarchyNode assetNode = getAssetHierarchyNode(assetObj);
                nodes.add(assetNode);
                accountAssetMap.put(assetObj.id, assetObj);
            }
            populateChildrenCount(nodes, hierarchyRequest.hierarchyConfiguration);
            expandedNode.childNodes = nodes;
            populateOpenNotificationsOnHierarchyNode(expandedNode, accountAssetMap);
            expandedNode.totalChildrens = aggregateResultList.isEmpty() ? 0 : (Integer) aggregateResultList[0].get('expr0');
            expandedNode.hasChildren = expandedNode.totalChildrens > 0;
            expandedNode.id = recordId;
        }

        System.debug( LoggingLevel.DEBUG, 'getAccountAssetNodes() - exit');
        return expandedNode;
    }

    /**
     * This method returns the MobileAmgt.HierarchyNode of given asset record.
     * 
     * @param assetObj - Asset record whose MobileAmgt.HierarchyNode we want.
     * 
     * @return - Extracts the details from the Asset record and then returns Asset hierarchy node.
     */
    public MobileAmgt.HierarchyNode getAssetHierarchyNode(Asset assetObj){
        System.debug( LoggingLevel.DEBUG, 'getAssetHierarchyNode() - enter; assetObj - '+ assetObj);
        MobileAmgt.HierarchyNode theNode;
        if(assetObj != null){
            theNode = (MobileAmgt.HierarchyNode) mapHierarchyNode(assetObj, new List<String>{'Status'});
            List<SObject> childAssets = assetObj.getSObjects('ChildAssets');
            if(childAssets != null && !childAssets.isEmpty()){
                theNode.hasChildren = true;
            }
        }

        System.debug( LoggingLevel.DEBUG, 'getAssetHierarchyNode() - exit');
        return theNode;
    }

    /**
     * This method retrieves hierarchy nodes.
     * 
     * @param recordId - Record id whose hierarchy we want to fetch.
     * 
     * @return - Returns hierarchy nodes of Asset.
     */
    public List<MobileAmgt.HierarchyNode> getRootHierarchy(Id recordId){
        System.debug( LoggingLevel.DEBUG, 'getRootHierarchy() - enter; recordId - '+ recordId);
        List<MobileAmgt.HierarchyNode> nodes = new List<MobileAmgt.HierarchyNode> ();
        try { 
            if( recordId == null) {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }

            List<Asset> selectedAssetList = (List<Asset>) SvmxDatabase.query([SELECT Name, AssetLevel FROM Asset WHERE Id = : recordId LIMIT 1]);
            if(selectedAssetList.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }

            nodes = getRootHierarchy(selectedAssetList.get(0).Id, MAX_ROOT_PARENT_LEVEL, null);

            return nodes;
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getRootHierarchy() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getRootHierarchy() - exit; response.size() =' + nodes.size());
        }
    }

    /**
     * This method retrieves hierarchy nodes.
     * 
     * @param recordId - Record id whose hierarchy we want to fetch.
     * @param requiredLevel - Maximum parent level that needs to fetch.
     * 
     * @return - Returns hierarchy nodes of Asset.
     */
    public List<MobileAmgt.HierarchyNode> getRootHierarchy(String recordId, Integer requiredLevel, MobileAmgt.HierarchyConfiguration hierarchyConfiguration){
        System.debug( LoggingLevel.DEBUG, 'getRootHierarchy() - enter; requiredLevel - '+ requiredLevel + ' ; recordId - '+ recordId);
        List<MobileAmgt.HierarchyNode> nodeList = new List<MobileAmgt.HierarchyNode>();
        if(requiredLevel == null || requiredLevel < 0) {
            throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
        }

        Integer initialLevel = requiredLevel > MAX_PARENT_LEVEL_IN_SOQL ? MAX_PARENT_LEVEL_IN_SOQL : requiredLevel;
        nodeList.addAll(getParentNodes(recordId, initialLevel));

        Integer remainingLevel = requiredLevel - initialLevel;

        if(remainingLevel > 0 && nodeList.size() == MAX_PARENT_LEVEL_IN_SOQL + 1){
            MobileAmgt.HierarchyNode parentNode = nodeList.get(MAX_PARENT_LEVEL_IN_SOQL);

            List<MobileAmgt.HierarchyNode> parentNodeList = getParentNodes(parentNode.Id, (remainingLevel > 4) ? 4 : remainingLevel);
            if(parentNodeList != null && parentNodeList.size() > 1){
                if(parentNodeList[0].Id == parentNode.id){
                    parentNodeList.remove(0);
                    nodeList.addAll(parentNodeList);
                }
            }
        }
        populateChildrenCount(nodeList, hierarchyConfiguration);

        System.debug( LoggingLevel.DEBUG, 'getRootHierarchy() - exit');
        return nodeList;
    }

    public List<MobileAmgt.HierarchyNode> populateChildrenCount(List<MobileAmgt.HierarchyNode> nodeList, MobileAmgt.HierarchyConfiguration hierarchyConfiguration){
        System.debug( LoggingLevel.DEBUG, 'populateChildrenCount() - enter');
        if(nodeList == null || nodeList.isEmpty()){
            return nodeList;
        }
        
        Map<Id, MobileAmgt.HierarchyNode> hierarchyNodeMap = new Map<Id, MobileAmgt.HierarchyNode>();
        for(MobileAmgt.HierarchyNode node : nodeList){
            hierarchyNodeMap.put(node.id, node);
        }

        String buildCriteria = getAssetHierarchyExpressions(hierarchyConfiguration);

        String childAssetCountClause = 'ParentId IN (\''+ String.join( new List<Id>(hierarchyNodeMap.keySet()), '\',\'')  +'\') ';
        AggregateResult[] aggregateResultList = getAssetAggregrateResult('ParentId', childAssetCountClause, buildCriteria);

        if(!aggregateResultList.isEmpty()){
            Map<Id, Integer> idVsChildCountMap = new Map<Id, Integer>();
            for(AggregateResult aggrResult : aggregateResultList){
                idVsChildCountMap.put((Id)aggrResult.get('ParentId'), (Integer)aggrResult.get('expr0'));
            }

            for(Id nodeId : hierarchyNodeMap.keySet()){
                MobileAmgt.HierarchyNode node = hierarchyNodeMap.get(nodeId);
                Integer totalChildren = idVsChildCountMap.get(nodeId);
                if(totalChildren == null || totalChildren == 0){
                    node.totalChildrens = 0;
                    node.hasChildren = false;
                } else {
                    node.totalChildrens = totalChildren;
                    node.hasChildren = true;
                }
            }
            nodeList = hierarchyNodeMap.values();
        }
        
        System.debug( LoggingLevel.DEBUG, 'populateChildrenCount() - exit'+ nodeList);
        return nodeList;
    }

    /**
     * This method retrieves parent hierarchy nodes.
     * 
     * @param recordId - Record id whose parent hierarchy we want to fetch.
     * @param requiredLevel - Maximum parent level that needs to fetch.
     * 
     * @return - Returns parent hierarchy nodes of Asset.
     */
    public List<MobileAmgt.HierarchyNode> getParentNodes(String recordId, Integer requiredLevel){
        System.debug( LoggingLevel.DEBUG, 'getParentNodes() - enter; assetRecord - ' +recordId + ' ; requiredLevel - '+ requiredLevel);
        List<MobileAmgt.HierarchyNode> nodeList = new List<MobileAmgt.HierarchyNode>();

        String parentFieldQuery = '';
        String parentField = '';
        List<String> parentFieldList = new List<String>{'Name', 'Status'};


        // Code to form the parent query. E.g. Parent.Name, Parent.Status, Parent.Parent.Name, Parent.Parent.Status ...
        for(Integer count=0; count<requiredLevel; count++){
            parentField = 'Parent.' + parentField;
            for(String fieldName : parentFieldList){
                parentFieldQuery += parentField + fieldName + ',';
            }
        }

        List<Asset> assetList = (List<Asset>) SvmxDatabase.query('SELECT '+ parentFieldQuery + ' Name, Status FROM Asset WHERE ID =\''+String.escapeSingleQuotes(recordId) + '\' LIMIT 1');
        if(!assetList.isEmpty()){
            Asset assetRecord = assetList.get(0);
            nodeList.addAll(getParentNode(assetRecord));
        }
        System.debug( LoggingLevel.DEBUG, 'getParentNodes() - exit');
        return nodeList;
    }

    /**
     * This method retrieves parent hierarchy nodes.
     * 
     * @param assetRecord - Returns the parent Hierarchy node.
     * 
     * @return - Returns parent hierarchy nodes of Asset.
     */
    public List<MobileAmgt.HierarchyNode> getParentNode(Asset assetRecord) {
        System.debug( LoggingLevel.DEBUG, 'getParentNode() - enter; assetRecord - ' +assetRecord);
        List<MobileAmgt.HierarchyNode> nodeList = new List<MobileAmgt.HierarchyNode>();
        List<MobileAmgt.HierarchyNode> parentNodes = new List<MobileAmgt.HierarchyNode>();

        if (assetRecord != null) {
            Map<String,Object> assetFieldsMap = assetRecord.getPopulatedFieldsAsMap();
            if(assetFieldsMap.containsKey('ParentId')){
                nodeList.add(mapHierarchyNode(assetRecord, new List<String>{'Status', 'ParentId'}, true));
                parentNodes = getParentNode(assetRecord.Parent);
            } else {
                nodeList.add(mapHierarchyNode(assetRecord, new List<String>{'Status'}, true));
            }
        }

        if(parentNodes != null && !parentNodes.isEmpty()){
            nodeList.addAll(getParentNode(assetRecord.Parent));
        }
        System.debug( LoggingLevel.DEBUG, 'getParentNode() - exit; assetRecord - ' +assetRecord.Name);
        return nodeList;
    }

    public String getParentFieldQuery(List<String> parentFieldList, Integer requiredLevel){
        System.debug( LoggingLevel.DEBUG, 'getParentFieldQuery() - enter; parentFieldList - ' +parentFieldList + ' requiredLevel '+ requiredLevel);
        String parentField = '';
        String parentFieldQuery = '';

        if(parentFieldList == null || parentFieldList.isEmpty()){
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }
        // Code to form the parent query. E.g. Parent.Name, Parent.Status, Parent.Parent.Name, Parent.Parent.Status ...
        for(Integer count=0; count<requiredLevel; count++){
            parentField = 'Parent.' + parentField;
            for(String fieldName : parentFieldList){
                parentFieldQuery += parentField + fieldName + ',';
            }
        }
        System.debug( LoggingLevel.DEBUG, 'getParentFieldQuery() - exit');
        return parentFieldQuery;
    }

    public String getHierarchyType(String objectName){
        System.debug( LoggingLevel.DEBUG, 'getHierarchyType() - enter; objectName - ' +objectName);
        String hierarchyType;
        try{
            if(String.isEmpty(objectName)){
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            SVMXA360__CONF_CSET_AssetHierarchy__c assetHierarchyConfig = SVMXA360__CONF_CSET_AssetHierarchy__c.getInstance();
            if(objectName == AMGT_AssetHierarchyManager.ASSET) {
                hierarchyType = assetHierarchyConfig.HierarchyTypeForAsset__c;
            } else if(objectName == 'workorder'){
                hierarchyType = assetHierarchyConfig.HierarchyTypeForWorkOrder__c;
            } else if(objectName == AMGT_AssetHierarchyManager.LOCATION){
                hierarchyType = LOCATION_TO_ASSET;
            }
            if(!isValidHierarchyType(hierarchyType)){
                hierarchyType = LOCATION_TO_ASSET;
            }    
        } catch(Exception e){
            System.debug( LoggingLevel.ERROR, 'getHierarchyType() : Failed to retrieve Root Id. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyType() - exit;' );
        }

        return hierarchyType;
    }

    private boolean isValidHierarchyType(String hierarchyType){
        return String.isNotEmpty(hierarchyType) && (hierarchyType == LOCATION_TO_ASSET || hierarchyType == ASSET_ONLY || hierarchyType == ACCOUNT_TO_ASSET);
    }

    public static MobileAmgt.HierarchyNode mapHierarchyNode(SObject record, List<String> fields) {
        return mapHierarchyNode(record, fields, false);
    }

    /**
     * This method forms the Hierarchy node from the record.
     * 
     * @param record - Hierarchy node record
     * @param fields - Records in a order starting from. This is used for the pagination.
     * @param expandByDefault - MobileAmgt.HierarchyNode should be expanded or not.
     * 
     * @return - Returns MobileAmgt.HierarchyNode.
     */
    public static MobileAmgt.HierarchyNode mapHierarchyNode(SObject record, List<String> fields, Boolean expandByDefault) {
        MobileAmgt.HierarchyNode node = new MobileAmgt.HierarchyNode();
        node.id = record.Id;
        node.expandByDefault = expandByDefault;
        node.name = String.valueOf(record.get('Name'));
        if(fields != null && !fields.isEmpty()){
            Map<String, Object> fieldsMap = new Map<String, Object>();
            for(String fieldName : fields){
                fieldsMap.put(fieldName, record.get(fieldName));
            }
            node.fields = fieldsMap;
        }

        return node;
    }

    /**
     * This method extracts the hierarchy Configuration record details with respect to the user profile
     * 
     * @return - Returns MobileAmgt.HierarchyConfiguration - Asset Hierarchy configuration configured for the user.
     */
    public MobileAmgt.HierarchyConfiguration getHierarchyConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - enter;' );
        MobileAmgt.HierarchyConfiguration configuration = new MobileAmgt.HierarchyConfiguration();
        try {
            configuration = getHierarchyConfigurationsForUser();

            if (configuration.isEmpty) {

                // Retrieve CONF_HierarchyConfigDetail__c records that marked as the default configuration
                configuration = getDefaultHierarchyConfigurationsForOrg();

                // When there are no configurations for the user AND there are no configurations defined as the "default", then use the fallback configuration.
                if (configuration.isEmpty) {
                    configuration = getFallbackAssetHierarchyConfigurations();
                }
            }

            if (configuration.assetHierarchyConfig != null) {
                configuration.assetHierarchyConfig.expressions = getExpressionsFromHierarchyConfig(configuration.assetHierarchyConfig);
            }
            if (configuration.accountHierarchyConfig != null) {
                configuration.accountHierarchyConfig.expressions = getExpressionsFromHierarchyConfig(configuration.accountHierarchyConfig);
            }
            if (configuration.locationHierarchyConfig != null) {
                configuration.locationHierarchyConfig.expressions = getExpressionsFromHierarchyConfig(configuration.locationHierarchyConfig);
            }
        } 
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfiguration() : Failed to retrieve hierarchy configuration. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - exit;' );
        }
        return configuration;
    }
    
    /**
     * This method extracts the hierarchy Configuration record details with respect to the user profile
     * 
     * @return - Returns MobileAmgt.HierarchyConfiguration - CONF_HierarchyConfigDetail__c records that marked as the default configuration
     */
    private MobileAmgt.HierarchyConfiguration getHierarchyConfigurationsForUser() {
        final String profile18 = UserInfo.getProfileId();
        final String profile15 = ((Id)profile18).to15();

        List<SVMXA360__CONF_HierarchyConfigDetail__c> configurationList = SvmxDatabase.query(
            [
                SELECT
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__DisplayIconName__c,
                    SVMXA360__fieldForDisplayIcon__c,
                    SVMXA360__FilterCriteria__c,
                	SVMXA360__FilterCriteria__r.Name,
                    SVMXA360__EnableNotification__c,
                	SVMXA360__NotificationFilterCriteria__c,
                	SVMXA360__NotificationFilterCriteria__r.Name,
                    SVMXA360__NotificationFilterCriteria__r.Criteria__c
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

    /**
     * This method extracts the hierarchy Configuration record details which is amrked as default. 
     * 
     * @return - Returns MobileAmgt.HierarchyConfiguration - CONF_HierarchyConfigDetail__c records that marked as the default configuration
     */
    private MobileAmgt.HierarchyConfiguration getDefaultHierarchyConfigurationsForOrg() {
        List<SVMXA360__CONF_HierarchyConfigDetail__c> configurationList = SvmxDatabase.query(
            [
                SELECT
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__DisplayIconName__c,
                    SVMXA360__fieldForDisplayIcon__c,
                    SVMXA360__FilterCriteria__c,
                	SVMXA360__FilterCriteria__r.Name,
                    SVMXA360__EnableNotification__c,
                	SVMXA360__NotificationFilterCriteria__c,
                	SVMXA360__NotificationFilterCriteria__r.Name,
                    SVMXA360__NotificationFilterCriteria__r.Criteria__c
                FROM SVMXA360__CONF_HierarchyConfigDetail__c 
                WHERE SVMXA360__HierarchyConfigId__r.isDefault__c = true
            ]);

        return mapConfiguration(configurationList);
    }

    /**
     * This method extracts the details from the list of CONF_HierarchyConfigDetail__c and returns Hierarchy configuration details.
     * 
     * @param configDetails - List of CONF_HierarchyConfigDetail__c records for the current user.
     * 
     * @return - Returns Hierarchy configuration details.
     */
    private MobileAmgt.HierarchyConfiguration mapConfiguration(List<SVMXA360__CONF_HierarchyConfigDetail__c> configDetails) {
        MobileAmgt.HierarchyConfiguration configuration = new MobileAmgt.HierarchyConfiguration();
        configuration.isEmpty = configDetails.isEmpty();
        for(SVMXA360__CONF_HierarchyConfigDetail__c configDetail : configDetails) {
            MobileAmgt.HierarchyConfigurationDetail detail = new MobileAmgt.HierarchyConfigurationDetail();
            detail.objectAPIName = configDetail.SVMXA360__ObjectAPIName__c;
            detail.qualifyingCriteria = configDetail.SVMXA360__FilterCriteria__c;
            detail.qualifyingCriteriaName = configDetail.SVMXA360__FilterCriteria__r.Name;
            detail.enableNotifications = configDetail.SVMXA360__EnableNotification__c;
            detail.notificationCriteriaId = configDetail.SVMXA360__NotificationFilterCriteria__c;
            detail.notificationCriteriaName = configDetail.SVMXA360__NotificationFilterCriteria__r ?. Name;
            detail.notificationCriteriaCondition = configDetail.SVMXA360__NotificationFilterCriteria__r ?. SVMXA360__Criteria__c;
            if(detail.objectAPIName.equalsIgnoreCase('account')) {
                detail.displayIconName = String.isEmpty(configDetail.SVMXA360__DisplayIconName__c)
                                            ? 'standard:account'
                                            : configDetail.SVMXA360__DisplayIconName__c;
                configuration.accountHierarchyConfig = detail;
            } else if(detail.objectAPIName.equalsIgnoreCase('asset')) {
                detail.displayIconName = String.isEmpty(configDetail.SVMXA360__DisplayIconName__c)
                                            ? 'standard:asset_object'
                                            : configDetail.SVMXA360__DisplayIconName__c;
                configuration.assetHierarchyConfig = detail;
            } else if(detail.objectAPIName.equalsIgnoreCase('location')) {
                detail.displayIconName = String.isEmpty(configDetail.SVMXA360__DisplayIconName__c)
                                            ? 'standard:location'
                                            : configDetail.SVMXA360__DisplayIconName__c;
                configuration.locationHierarchyConfig = detail;
            }
        }
        return configuration;
    }

    /**
    *  When a user retrieving Hierarchy data does not have access to hierarchy configuration records,
    *  this method provides a default implementation.
    */
    private MobileAmgt.HierarchyConfiguration getFallbackAssetHierarchyConfigurations() {
        MobileAmgt.HierarchyConfiguration configuration = new MobileAmgt.HierarchyConfiguration();
        configuration.accountHierarchyConfig = createConfigurationDetail('account', 'standard:account');
        configuration.assetHierarchyConfig = createConfigurationDetail('asset', 'standard:asset_object');
        configuration.locationHierarchyConfig = createConfigurationDetail('location', 'standard:location');
        return configuration;
    }

    /**
    *  This method creates the hierarchy configuration details(MobileAmgt.HierarchyConfigurationDetail) from the given parameters
    * 
    * @param objectName - Object api name.
    *
    * @param iconName - Configured icon name in the Asset hierarchy.
    */
    private MobileAmgt.HierarchyConfigurationDetail createConfigurationDetail( String objectName, String iconName) {
        MobileAmgt.HierarchyConfigurationDetail config = new MobileAmgt.HierarchyConfigurationDetail();
        config.objectApiName = objectName;
        config.displayIconName = iconName;
        config.enableNotifications = true;
        return config;
    }

    private AggregateResult[] getAssetAggregrateResult(String groupByFieldName, String intialWhereClause, String configuredBuildCriteria){
        System.debug( LoggingLevel.DEBUG, 'getAssetAggregrateResult() - enter; groupByFieldName - ' +groupByFieldName+ ' ; intialWhereClause - ' +intialWhereClause+
            ' ; configuredBuildCriteria - ' +configuredBuildCriteria);

        if (String.isEmpty(groupByFieldName) || String.isEmpty(intialWhereClause)) {
            System.debug( LoggingLevel.ERROR, 'getAssetAggregrateResult() : One or more required parameters are missing');
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }

        String whereClause = 'WHERE ' + intialWhereClause + (String.isNotEmpty(configuredBuildCriteria) ? ' AND '+ configuredBuildCriteria  : '');
        String securityPredicate = Test.isRunningTest() ? '' : 'WITH SECURITY_ENFORCED';

        List<AggregateResult> aggregateResultList = (List<AggregateResult>)Database.query(
            String.format(
                'SELECT {0} from Asset {1} {2} GROUP BY {3} LIMIT 10000',
                new List<String> {
                    groupByFieldName + ', count(ID)',
                    whereClause,
                    securityPredicate,
                    groupByFieldName
                }
            )
        );

        System.debug( LoggingLevel.DEBUG, 'getAssetAggregrateResult() - exit;');
        return aggregateResultList;
    }

    /**
    *  This method returns the default asset open notification criteria string.
    */
    private String getDefaultAssetOpenNotificationCriteria(){
        System.debug( LoggingLevel.DEBUG, 'getDefaultAssetOpenNotificationCriteria() - enter;');
        String assetOpenNotificationCriteria;
        List<SVMXA360__CONF_Expression__c> hierarchyNotificationExpressionRecord = SvmxDatabase.query([SELECT SVMXA360__Criteria__c
                                                               FROM SVMXA360__CONF_Expression__c WHERE 
                                                               SVMXA360__DeveloperName__c = 'ASTN_Open_Asset_Notifications' LIMIT 1]);
        if(hierarchyNotificationExpressionRecord.isEmpty() || String.isEmpty(hierarchyNotificationExpressionRecord[0].SVMXA360__Criteria__c)) {
            assetOpenNotificationCriteria = DEFAULT_ASSET_NOTIFICATION_CRITERIA;
        } else {
            assetOpenNotificationCriteria = hierarchyNotificationExpressionRecord[0].SVMXA360__Criteria__c;
        }

        System.debug( LoggingLevel.DEBUG, 'getDefaultAssetOpenNotificationCriteria() - exit; assetOpenNotificationCriteria - '+ assetOpenNotificationCriteria);
        return assetOpenNotificationCriteria;
    }

    /**
     * This method extracts the list of expression details from the HierarchyConfigurationDetail.
     * 
     * @param hierarchyConfigDetail - Hierarchy configuration detail.
     * 
     * @return - Returns the list of expression details.
     */
    private List<Adm.Expression> getExpressionsFromHierarchyConfig ( MobileAmgt.HierarchyConfigurationDetail hierarchyConfigDetail) {
        List<Adm.Expression> admExpressionList;
        if(hierarchyConfigDetail != null && String.isNotEmpty(hierarchyConfigDetail.qualifyingCriteria)) {
            Adm.Expression admExpression = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(hierarchyConfigDetail.qualifyingCriteria);
            if(admExpression  != null){
                admExpressionList = new List<Adm.Expression> { admExpression };
            }
        }

        return admExpressionList;
    }

    /**
     * This method extracts the list of expression from the HierarchyConfiguration.
     * 
     * @param hierarchyConfigDetail - Hierarchy configuration.
     * 
     * @return - Returns the list of expressions.
     */
    private string getAssetHierarchyExpressions(MobileAmgt.HierarchyConfiguration hierarchyConfiguration) {
        String buildCriteria;

        List<Adm.Expression> expressionList = hierarchyConfiguration ?. assetHierarchyConfig ?. expressions;
        if(expressionList != null && !expressionList.isEmpty()) {
            buildCriteria = expressionList[0].criteria;
        }

        return buildCriteria;
    }
}