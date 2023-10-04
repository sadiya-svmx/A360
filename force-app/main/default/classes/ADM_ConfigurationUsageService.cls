/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/create/update and delete 
 * Configuration Usage Service. 
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
public with sharing class ADM_ConfigurationUsageService extends ADM_AbstractConfigurationUsageService{


    /**
    * Class constructor to create instance of this class. This constructor is 
    * invoked by lightning services.
    */
   public ADM_ConfigurationUsageService(){}
   
   /**
    * Class constructor to create instance of this class. This constructor is 
    * invoked by rest interfaces.
    */
   public ADM_ConfigurationUsageService( RestRequest request, RestResponse response ){
       super(request, response);
   }

   /**
    * This method is used to retrieve all Configuration Usage from the Org.
    * 
    * @return Returns list of all Configuration Usage.
    * 
    * @example GET /services/apexrest/SVMXA360/svmx/rest/configuration/usage/getAllConfigurationUsages/
    */
   override public Common.ServiceResponse getAllConfigurationUsages(){
       System.debug( LoggingLevel.DEBUG, 'getAllConfigurationUsages() - enter' );
       
       Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
       
       try {
           serviceResponse.data = ADM_ConfigurationUsageManager.getInstance().getAllConfigurationUsages();
       }
       
       catch( Exception e ) {
           
           System.debug( LoggingLevel.ERROR, 'getAllConfigurationUsages() : Failed to retrieve Translation Settings. Error' + e.getStackTraceString() );
           
           serviceResponse.success = false;
           serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
       }
       
       finally {
           System.debug( LoggingLevel.DEBUG, 'getAllConfigurationUsages() - exit; serviceResponse.success ' + serviceResponse.success );
       }
       
       return serviceResponse;

   }
   
   /**
    * This method is used to save Configuration Usage.
    * 
    * @param confTranslations List of Configuration Usage to be saved.
    * 
    * @example POST /services/apexrest/SVMXA360/svmx/rest/configuration/usage/saveConfigTranslations/
    */
   override public Common.ServiceResponse saveConfigurationUsages( final List<Adm.ConfigurationUsage> configurationUsages ){
       System.debug( LoggingLevel.DEBUG, 'saveConfigurationUsages() - enter; configurationUsages= ' + configurationUsages );
       
       Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
       
       try {
           serviceResponse.data = ADM_ConfigurationUsageManager.getInstance().saveConfigurationUsages( configurationUsages );
           serviceResponse.success = true;
       }
       catch( Exception e ) {
           
           System.debug( LoggingLevel.ERROR, 'saveConfigurationUsages() : Failed to save Config translations. Error' + e.getStackTraceString() );
           
           serviceResponse.success = false;
           serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
       }
       finally {
           System.debug( LoggingLevel.DEBUG, 'saveConfigurationUsages() - exit; serviceResponse.success ' + serviceResponse.success );
       }
       
       return serviceResponse;
   }
}