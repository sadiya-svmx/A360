/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is an abstract class which provides methods for custom settings service implementation. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       01 Dec 2021     Created.
 *****************************************************************************************************/
public abstract class CONF_AbstractCustomSettingsService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public CONF_AbstractCustomSettingsService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected CONF_AbstractCustomSettingsService( RestRequest request, RestResponse response ) {
        super( request, response, 'customsettings' );    
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
                
                when 'getGlobalProperty' {
                    serviceResponse = getGlobalProperty(recordId);
                }
                
                when 'setGlobalProperty' {
                    
                    final Common.GlobalProperty globalProperty = (Common.GlobalProperty) deserializeRequestTo( Common.GlobalProperty.class );
                    serviceResponse = setGlobalProperty(globalProperty.name, globalProperty.value);
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
     * This method is used to retrieve Global Setting Information for given name.
     * 
     * @return Returns Custom Setting information
     * 
     * @example GET /services/apexrest/SVMXA360/admin/customsettings/v1/getGlobalProperty/GP800
     */
    public abstract Common.ServiceResponse getGlobalProperty( final String name );
    
    /**
     * This method is used to set Global Setting value.
     * 
     * @return Returns Save result.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/customsettings/v1/setGlobalProperty/
     */
    public abstract Common.ServiceResponse setGlobalProperty( final String name, final String value );
}