/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for asset management service implementation.
 *
 * @author Hemant Keni
 * @version Spring 22
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni             24 Jan 2022     Created.
 *****************************************************************************************************/
public abstract class MOBAMGT_AbstractAssetManagementService extends COMM_SvmxRestBase {
    
    public MOBAMGT_AbstractAssetManagementService(){ 
    }
    
    protected MOBAMGT_AbstractAssetManagementService(RestRequest req, RestResponse res) {
        super(req, res, 'assetManagement');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getHierarchyTypeRootNode' {
                    response = getHierarchyTypeRootNode(recordId);
                }
                when 'retrieveHierarchyTypeRootNode' {
                    response = retrieveHierarchyTypeRootNode((MobileAmgt.HierarchyRootNodeRequest) deserializeRequestTo( MobileAmgt.HierarchyRootNodeRequest.class ));
                }
                when 'retrieveHierarchyNodes' {
                    response = retrieveHierarchyNodes( (List<MobileAmgt.HierarchyNodesRequest>) deserializeRequestTo( List<MobileAmgt.HierarchyNodesRequest>.class ));
                }
                when 'retrieveSearchedAssets' {
                    response = retrieveSearchedAssets((MobileAmgt.AssetHierarchySearch) deserializeRequestTo( MobileAmgt.AssetHierarchySearch.class ));
                } 
                when 'getHierarchyConfiguration' {
                    response = getHierarchyConfiguration ();
                }
                when 'retrieveTimelineData' {
                    response = retrieveTimelineData( (Amgt.TimelineRequest) deserializeRequestTo( Amgt.TimelineRequest.class  ));
                } 
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }
    
    /**
     * This method is used to retrieve root hierarchy node details with hierarchy type
     * 
     * @return Returns Root hierarchy node details with hierarchy type.
     * 
     * @example GET /services/apexrest/SVMXA360/mobile/assetManagement/v1/getHierarchyTypeRootNode/
     */
    public abstract Common.ServiceResponse getHierarchyTypeRootNode( final Id recordId );

    /**
     * This method is used to retrieve root hierarchy node details with hierarchy type
     * 
     * @return Returns Root hierarchy node details with hierarchy type.
     * 
     * @example GET /services/apexrest/SVMXA360/mobile/assetManagement/v1/retrieveHierarchyTypeRootNode/
     */
    public abstract Common.ServiceResponse retrieveHierarchyTypeRootNode( final MobileAmgt.HierarchyRootNodeRequest retrieveRootNodeRequest );


    /**
     * This method is used to retrieve searched assets in Asset hierarchy.
     * 
     * @return Returns searched assets in Asset hierarchy.
     * 
     * @example GET /services/apexrest/SVMXA360/mobile/assetManagement/v1/retrieveSearchedAssets/
     */
    public abstract Common.ServiceResponse retrieveSearchedAssets( final MobileAmgt.AssetHierarchySearch searchRequest );

    /**
     * This method is used to retrieve Asset hierarchy nodes from the Org.
     * 
     * @return Returns list of Asset hierarchy nodes
     * 
     * @example GET /services/apexrest/SVMXA360/mobile/assetManagement/v1/retrieveHierarchyNodes/
     */
    public abstract Common.ServiceResponse retrieveHierarchyNodes( final List<MobileAmgt.HierarchyNodesRequest> serviceRequestList);

    /**
     * This method is used to retrieve Asset hierarchy nodes from the Org.
     * 
     * @return Returns list of Asset hierarchy nodes
     * 
     * @example GET /services/apexrest/SVMXA360/mobile/assetManagement/v1/getHierarchyConfiguration/
     */
    public abstract Common.ServiceResponse getHierarchyConfiguration();

    /**
     * This method is used to retrieve all Asset timline data from the Org.
     * 
     * @return Returns list of all Asset timeline data.
     * 
     * @example GET /services/apexrest/SVMXA360/mobile/assetManagement/v1/retrieveTimelineData/
     */
    public abstract Common.ServiceResponse retrieveTimelineData( final Amgt.TimelineRequest request );

}