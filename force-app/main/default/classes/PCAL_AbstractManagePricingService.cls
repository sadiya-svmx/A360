/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for Price Calculation service implementation.
 * Also provides implementation for invokeMethod which maps to the requested Price Calculation service 
 * implementation. 
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashjank Panchal       21 Dec 2020     Created.
 *****************************************************************************************************/
public abstract class PCAL_AbstractManagePricingService extends COMM_SvmxRestBase {
    
    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public PCAL_AbstractManagePricingService() {
    }

    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected PCAL_AbstractManagePricingService( RestRequest request, RestResponse response ) {
        super( request, response, 'workorder' );    
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
                when 'calculateLinePrice' {
                    //serviceResponse = calculateLinePrice((CalculatePriceApexAction.PriceCalRequest) deserializeRequestTo(CalculatePriceApexAction.PriceCalRequest.class));
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
     * This method is used to calculate the prices for the incoming records
     * 
     * @return Returns list of incoming records with appropriate pricing.
     * 
     * @example GET /services/apexrest/SVMXA360/pcal/workorder/v1/calculateLinePrice
     */
    //public abstract Common.ServiceResponse calculateLinePrice(CalculatePriceApexAction.PriceCalRequest lstInputParams);
}