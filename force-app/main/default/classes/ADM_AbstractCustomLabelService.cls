/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for custom label service implementation.
 * Also provides implementation for invokeMethod which maps to the requested custom label service implementation. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       13 Aug 2021     Created.
 *****************************************************************************************************/
public abstract class ADM_AbstractCustomLabelService extends COMM_SvmxRestBase {
    
    protected ADM_AbstractCustomLabelService() {
    }
	/**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected ADM_AbstractCustomLabelService( RestRequest request, RestResponse response ) {
        super( request, response, 'label' );    
    }
    
    /**
     * Override method invoked by base rest class with requested method.
     * 
     * @param methodName Method name from the request URL.
     * 
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            // Invoke service for requested method name.
            switch on methodName {
                
                when 'getEntitlementCustomLabels' {
                    serviceResponse = getEntitlementCustomLabels();
                }
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve entitlement custom labels.
     * 
     * @example GET /services/apexrest/SVMXA360/ever/label/v1/getEntitlementCustomLabels/
     */
    public abstract Common.ServiceResponse getEntitlementCustomLabels();
}