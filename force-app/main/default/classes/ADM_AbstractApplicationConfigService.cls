/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for Translation service implementation.
 * Also provides implementation for invokeMethod which maps to the requested Translation service  implementation. 
 *
 * @author Sathya sundaram Pachaiappan
 * @version 1.0
 * @since 2020 going on 2021
 */
public abstract class ADM_AbstractApplicationConfigService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public ADM_AbstractApplicationConfigService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected ADM_AbstractApplicationConfigService( RestRequest request, RestResponse response ) {
        super( request, response, 'appconfig' );    
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
                
                when 'getAllConfigTranslations' {
                    serviceResponse = getAllConfigTranslations();
                }

                when 'saveConfigTranslations' {
                    serviceResponse = saveConfigTranslations( (List<Adm.SvmxTranslations>) deserializeRequestTo( List<Adm.SvmxTranslations>.class ) );
                }
                
                when 'validateTranslations' {
                    
                    final Adm.TranslationValidationRequest translationValidationRequest = (Adm.TranslationValidationRequest) deserializeRequestTo( Adm.TranslationValidationRequest.class);                
                    serviceResponse = validateTranslations( translationValidationRequest );
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
     * This method is used to retrieve all svmx translations  from the Org.
     * 
     * @return Returns list of all SVMX Config Translations.
     * 
     * @example GET /services/apexrest/SVMXA360/svmx/rest/appconfig/getAllConfigTranslations/
     */
    public abstract Common.ServiceResponse getAllConfigTranslations();
    
    /**
     * This method is used to save svmx translations .
     * 
     * @param confTranslations List of SVMX config translations to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/svmx/rest/appconfig/saveConfigTranslations/
     */
    public abstract Common.ServiceResponse saveConfigTranslations( final List<Adm.SvmxTranslations> confTranslations );
    
    /**
     * This method is used to validate svmx translation.
     * 
     * @param conf Translation of SVMX config translations to be validated.
     * 
     * @example POST /services/apexrest/SVMXA360/svmx/rest/appconfig/validateTranslations/
     */
    public abstract Common.ServiceResponse validateTranslations( final Adm.TranslationValidationRequest translationValidationRequest );
}