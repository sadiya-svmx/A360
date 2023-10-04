/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines lightning services to retrieve developer name for given 
 * application and process name.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       02 Jun 2020     Created.
 *****************************************************************************************************/
public with sharing class ADM_DeveloperNameLightningService {

    /**
     * This method is used to create developer name for given application and process name.
     * 
     * @returns Returns newly generated developer name.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse createDeveloperName( final String application, final String processName ) {
        
        System.debug( LoggingLevel.DEBUG, 'createDeveloperName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Create developer name for given process name.
            serviceResponse = new ADM_DeveloperNameService().createDeveloperName(application, String.escapeSingleQuotes(processName) );
            System.debug( LoggingLevel.INFO, 'createDeveloperName() : Created developer name.' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createDeveloperName() : Failed to create developer name. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createDeveloperName() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to check if the given developer name is not being used for the given Application type.
     */
    @AuraEnabled
    public static Common.ServiceResponse isDeveloperNameAvailable( final String application, final String developerName ){

        System.debug( LoggingLevel.DEBUG, 'isDeveloperNameAvailable() - enter. application=' + application + '; developerName= ' + developerName );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_DeveloperNameService().isDeveloperNameAvailable( application, String.escapeSingleQuotes(developerName) );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'isDeveloperNameAvailable() : Failed to check for the developer name. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'isDeveloperNameAvailable() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}