/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for Configuration Usage service implementation.
 * Also provides implementation for invokeMethod which maps to the requested Configuration Usage service  implementation. 
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
public abstract class ADM_AbstractConfigurationUsageService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public ADM_AbstractConfigurationUsageService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected ADM_AbstractConfigurationUsageService( RestRequest request, RestResponse response ) {
        super( request, response, 'usage' );    
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
                
                when 'getAllConfigurationUsages' {
                    serviceResponse = getAllConfigurationUsages();
                }

                when 'saveConfigurationUsages' {
                    serviceResponse = saveConfigurationUsages( (List<Adm.ConfigurationUsage>) deserializeRequestTo( List<Adm.ConfigurationUsage>.class ) );
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
     * This method is used to retrieve all Configuration Usage  from the Org.
     * 
     * @return Returns list of all Configuration Usage.
     * 
     * @example GET /services/apexrest/SVMXA360/svmx/rest/configuration/usage/getAllConfigurationUsages/
     */
    public abstract Common.ServiceResponse getAllConfigurationUsages();
    
    /**
     * This method is used to save Configuration Usages .
     * 
     * @param configurationUsages List of Configuration Usages to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/svmx/rest/configuration/usage/saveConfigurationUsages/
     */
    public abstract Common.ServiceResponse saveConfigurationUsages( final List<Adm.ConfigurationUsage> configurationUsages );
}