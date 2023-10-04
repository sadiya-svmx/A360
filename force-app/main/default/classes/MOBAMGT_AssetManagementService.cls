/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to retrieve operations 
 * on asset timeline and hierarchy.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        	Name                    Date            Comment
 *****************************************************************************************************
 *              	Hemant Keni            24 Jan 2022    	Created.
 *****************************************************************************************************/
public with sharing class MOBAMGT_AssetManagementService extends MOBAMGT_AbstractAssetManagementService { 

    /**
     * Class constructor to create instance of this class.
     */
    public MOBAMGT_AssetManagementService(){}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public MOBAMGT_AssetManagementService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    /**
     * This method retrieves root hierarchy node with the Hierarchy type from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with root hierarchy node with the Hierarchy type.
     * @see MOBAMGT_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse getHierarchyTypeRootNode(final Id recordId) {

        System.debug( LoggingLevel.DEBUG, 'getHierarchyTypeRootNode() - enter' );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new MOBAMGT_AssetManagementServiceImpl().getHierarchyTypeRootNode(recordId);
            System.debug( LoggingLevel.INFO, 'getHierarchyTypeRootNode() : Retrieved hierarchy configuration list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyTypeRootNode() : Failed to retrieve root node hierarchy. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyTypeRootNode() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves root hierarchy node with the Hierarchy type from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with root hierarchy node with the Hierarchy type.
     * @see MOBAMGT_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse retrieveHierarchyTypeRootNode(final MobileAmgt.HierarchyRootNodeRequest retrieveRootNodeRequest) {

        System.debug( LoggingLevel.DEBUG, 'retrieveHierarchyTypeRootNode() - enter' );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new MOBAMGT_AssetManagementServiceImpl().retrieveHierarchyTypeRootNode(retrieveRootNodeRequest);
            System.debug( LoggingLevel.INFO, 'retrieveHierarchyTypeRootNode() : Retrieved hierarchy configuration list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveHierarchyTypeRootNode() : Failed to retrieve root node hierarchy. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveHierarchyTypeRootNode() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all the asset hierarchy nodes for the given record id
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with all the asset hierarchy nodes.
     * @see MOBAMGT_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse retrieveHierarchyNodes( final List<MobileAmgt.HierarchyNodesRequest> serviceRequestList) {

        System.debug( LoggingLevel.DEBUG, 'retrieveHierarchyNodes() - enter' );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new MOBAMGT_AssetManagementServiceImpl().retrieveHierarchyNodes(serviceRequestList);
            System.debug( LoggingLevel.INFO, 'retrieveHierarchyNodes() : Retrieved hierarchy nodes' );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'retrieveHierarchyNodes() : Failed to retrieve hierarchy nodes. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveHierarchyNodes() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves Searched assets in the Asset hierarchy from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with Searched assets in the Asset hierarchy.
     * @see MOBAMGT_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse retrieveSearchedAssets(final MobileAmgt.AssetHierarchySearch searchRequest) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveSearchedAssets() - enter; searchRequest - '+ searchRequest );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new MOBAMGT_AssetManagementServiceImpl().retrieveSearchedAssets(searchRequest);
            System.debug( LoggingLevel.INFO, 'retrieveSearchedAssets() : Retrieved hierarchy configuration list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveSearchedAssets() : Failed to retrieve root node hierarchy. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSearchedAssets() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves Hierarchy configuration data.
     * 
     * @return Returns instance of Common.ServiceResponse with Hierarchy Configuration data.
     * @see MOBAMGT_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse getHierarchyConfiguration() {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - enter; ');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new MOBAMGT_AssetManagementServiceImpl().getHierarchyConfiguration();
            System.debug( LoggingLevel.INFO, 'getHierarchyConfiguration() : Retrieved hierarchy configuration' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfiguration() : Failed to retrieve hierarchy configuration data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves Timeline data for the given record id from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with Timeline data.
     * @see MOBAMGT_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse retrieveTimelineData( final Amgt.TimelineRequest request ) {

        System.debug( LoggingLevel.DEBUG, 'retrieveTimelineData() - enter' );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new MOBAMGT_AssetManagementServiceImpl().retrieveTimelineData(request);
            System.debug( LoggingLevel.INFO, 'retrieveTimelineData() : Retrieved Asset Timeline data' );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'retrieveTimelineData() : Failed to retrieve Asset Timeline data. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveTimelineData() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}