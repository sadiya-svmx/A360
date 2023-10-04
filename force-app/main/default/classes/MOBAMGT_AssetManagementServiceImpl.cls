/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve Asset Hierarchy data.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni             24 Jan 2022     Created.
 *****************************************************************************************************/
public with sharing class MOBAMGT_AssetManagementServiceImpl { 


    private final MOBAMGT_AssetHierarchyManager hierarchyManager = MOBAMGT_AssetHierarchyManager.getInstance();
    
    private final AMGT_TimeLineManager timelineManager = AMGT_TimeLineManager.getInstance();

    /**
     * Class constructor to create instance of this class.
     */
    public MOBAMGT_AssetManagementServiceImpl(){}


    /**
     * This method retrieves root node details with the hierarchy type
     */
	public MobileAmgt.RootHierarchyNode getHierarchyTypeRootNode(final Id recordId) {
        System.debug( LoggingLevel.FINEST, 'getHierarchyTypeRootNode() - enter; recordId=' + recordId);
        
        MobileAmgt.RootHierarchyNode rootHierarchy = new MobileAmgt.RootHierarchyNode();
        
        try {
            // Retrieve Root node hierarchy.
            rootHierarchy = hierarchyManager.getHierarchyTypeRootNode(recordId);
            System.debug( LoggingLevel.INFO, 'getHierarchyTypeRootNode() : Retrieved root node hierarchy information.');
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyTypeRootNode() : Failed to retrieve hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getHierarchyTypeRootNode() - exit; rootHierarchy = ' + rootHierarchy );
        }
        
        return rootHierarchy;
    }

    /**
     * This method retrieves root node details with the hierarchy type
     */
	public MobileAmgt.RootHierarchyNode retrieveHierarchyTypeRootNode(final MobileAmgt.HierarchyRootNodeRequest retrieveRootNodeRequest) {
        System.debug( LoggingLevel.FINEST, 'retrieveHierarchyTypeRootNode() - enter; retrieveRootNodeRequest=' + retrieveRootNodeRequest);
        
        MobileAmgt.RootHierarchyNode rootHierarchy = new MobileAmgt.RootHierarchyNode();
        
        try {
            // Retrieve Root node hierarchy.
            rootHierarchy = hierarchyManager.retrieveHierarchyTypeRootNode(retrieveRootNodeRequest);
            System.debug( LoggingLevel.INFO, 'retrieveHierarchyTypeRootNode() : Retrieved root node hierarchy information.');
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveHierarchyTypeRootNode() : Failed to retrieve hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'retrieveHierarchyTypeRootNode() - exit; rootHierarchy = ' + rootHierarchy );
        }
        
        return rootHierarchy;
    }

    /**
     * This method retrieves all the hierarchy nodes for the given record ids
     */
	public Map<Id, MobileAmgt.HierarchyNode> retrieveHierarchyNodes( final List<MobileAmgt.HierarchyNodesRequest> serviceRequestList) {
        System.debug( LoggingLevel.FINEST, 'retrieveHierarchyNodes() - enter; serviceRequestList = '+ serviceRequestList);
        
        Map<Id, MobileAmgt.HierarchyNode> expandedNodeMap;
        
        try {
            
            if(serviceRequestList == null || serviceRequestList.isEmpty()) {
                System.debug( LoggingLevel.ERROR, 'retrieveHierarchyNodes() : One or more required parameters are missing. serviceRequestList - '+ serviceRequestList);
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_AssetHierarchy_ServerError );
            }
            // Retrieves all the hierarchy nodes for the given record ids
            expandedNodeMap = hierarchyManager.getHierarchyNodes(serviceRequestList);
            System.debug( LoggingLevel.INFO, 'retrieveHierarchyNodes() : Retrieved all Hierarchy nodes. expandedNodeMap= ' + expandedNodeMap);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveHierarchyNodes() : Failed to retrieve hierarchy nodes. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'retrieveHierarchyNodes() - exit; expandedNodeMap= ' + expandedNodeMap );
        }
        
        return expandedNodeMap;
    }

    /**
     * This method retrieves searched assets.
     */
	public List<Asset> retrieveSearchedAssets(final MobileAmgt.AssetHierarchySearch searchRequest) {
        System.debug( LoggingLevel.FINEST, 'retrieveSearchedAssets() - enter; searchRequest=' + searchRequest);
        
        List<Asset> searchedAssets = new List<Asset>();
        
        try {
            // Retrieve Root node hierarchy.
            searchedAssets = hierarchyManager.retrieveSearchedAssets(searchRequest);
            System.debug( LoggingLevel.INFO, 'retrieveSearchedAssets() : Retrieved searched assets.');
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveSearchedAssets() : Failed to retrieve searched assets. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'retrieveSearchedAssets() - exit; searchedAssets = ' + searchedAssets );
        }
        
        return searchedAssets;
    }

    /**
     * This method retrieves searched assets.
     */
	public MobileAmgt.HierarchyConfiguration getHierarchyConfiguration() {
        System.debug( LoggingLevel.FINEST, 'getHierarchyConfiguration() - enter; ');
        
        MobileAmgt.HierarchyConfiguration hierarchyConfiguration;
        
        try {
            // Retrieve Root node hierarchy.
            hierarchyConfiguration = hierarchyManager.getHierarchyConfiguration();
            System.debug( LoggingLevel.INFO, 'getHierarchyConfiguration() : Retrieved hierarchy configuration data.');
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfiguration() : Failed to retrieve hierarchy confiuration data. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getHierarchyConfiguration() - exit; Hierarchy configuration data = ' + hierarchyConfiguration );
        }
        
        return hierarchyConfiguration;
    }

    /**
     * This method retrieves all the Timeline data for the given parameters.
     */
	public Amgt.TimelineResponse retrieveTimelineData( final Amgt.TimelineRequest timlineRequest ) {
        System.debug( LoggingLevel.FINEST, 'retrieveTimelineData() - enter; timlineRequest = '+ timlineRequest);
        
        Amgt.TimelineResponse timelineResponse;
        
        try {
            // Retrieves the Asset timline data.
            timelineResponse = timelineManager.getTimelineData(timlineRequest);
            System.debug( LoggingLevel.INFO, 'retrieveTimelineData() : Retrieved all Hierarchy nodes. timelineResponse= ' + timelineResponse);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveTimelineData() : Failed to retrieve hierarchy nodes. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'retrieveTimelineData() - exit; timelineResponse= ' + timelineResponse );
        }
        
        return timelineResponse;
    }

}