/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for Depot Finder service implementation.
 * Also provides implementation for invokeMethod which maps to the requested Depot Finder service implementation. 
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashjank Panchal       28 Aug 2020     Created.
 *****************************************************************************************************/
public abstract class DPOT_AbstractManageDepotService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public DPOT_AbstractManageDepotService() {
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected DPOT_AbstractManageDepotService( RestRequest request, RestResponse response ) {
        super( request, response, 'returns' );    
    }
    
    /**
     * Override method invoked by base rest class with requested method.
     * @param methodName Method name from the request URL.
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {        
        System.debug( LoggingLevel.INFO, 'invokeMethod() - enter; methodName = ' + methodName );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            switch on methodName {   
                when 'getDepotLocation' {
                    serviceResponse = getDepotLocation((List<DepotFinderRequest>) deserializeRequestTo(List<DepotFinderRequest>.class));
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName = ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }
        finally {
            System.debug( LoggingLevel.INFO, 'invokeMethod() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method is used to retrieve the matching location.
     * 
     * @return Returns list of all matching locations/depots.
     * 
     * @example GET /services/apexrest/SVMXA360/depot/returns/v1/getdepotlocation
     */
    public abstract Common.ServiceResponse getDepotLocation(List<DepotFinderRequest> lstReturnRequest);
}