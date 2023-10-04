/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/create/update and delete 
 * Translation Service. 
 *
 * @author Sathya Pachaiappan
 * @version 1.0
 * @since 2021
 */
public with sharing class ADM_ApplicationConfigService extends ADM_AbstractApplicationConfigService{


     /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_ApplicationConfigService(){}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_ApplicationConfigService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method is used to retrieve all Translations from the Org.
     * 
     * @return Returns list of all SVMX Config Translations.
     * 
     * @example GET /services/apexrest/SVMXA360/svmx/rest/appconfig/getAllConfigTranslations/
     */
    override public Common.ServiceResponse getAllConfigTranslations(){
        System.debug( LoggingLevel.DEBUG, 'getAllConfigTranslations() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ApplicationConfigServiceImpl().getAllConfigTranslations();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigTranslations() : Failed to retrieve Translation Settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigTranslations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;

    }
    
    /**
     * This method is used to save Translations.
     * 
     * @param confTranslations List of SVMX config translations to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/svmx/rest/appconfig/saveConfigTranslations/
     */
    override public Common.ServiceResponse saveConfigTranslations( final List<Adm.SvmxTranslations> confTranslations ){
        System.debug( LoggingLevel.DEBUG, 'saveConfigTranslations() - enter; confTranslations= ' + confTranslations );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ApplicationConfigServiceImpl().saveConfigTranslations( confTranslations );
            serviceResponse.success = true;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTranslations() : Failed to save Config translations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigTranslations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save Translations.
     * 
     * @param confTranslations List of SVMX config translations to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/svmx/rest/appconfig/validateTranslations/
     */
    override public Common.ServiceResponse validateTranslations( final Adm.TranslationValidationRequest translationValidationRequest ){
        System.debug( LoggingLevel.DEBUG, 'validateTranslation() - enter; translationValidationRequest= ' + translationValidationRequest );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ApplicationConfigServiceImpl().validateTranslations( translationValidationRequest );
            serviceResponse.success = true;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTranslation() : Failed to validate Config translations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateTranslation() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
}