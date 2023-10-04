/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve developer name for given application and process name.
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
public with sharing class ADM_DeveloperNameService {

    public Common.ServiceResponse createDeveloperName( final String application, final String processName ) {
        
        System.debug( LoggingLevel.DEBUG, 'createDeveloperName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            // Verify for valid object mapping configuration.
            if( String.isBlank(application) || String.isBlank(processName) ) {
                
                System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Invalid request parameters. application= ' + application + '; processName= ' + processName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            switch on application.toUpperCase() {
                
                when 'OBJECTMAPPING' {
                    serviceResponse.data = COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping, processName );
                }
                when 'EXPRESSION' {
                    serviceResponse.data = COMM_DeveloperName.createDeveloperName( Common.Application.Expression, processName );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'createDeveloperName() : Application type not supported. Type= ' + application );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
            
            System.debug( LoggingLevel.INFO, 'createDeveloperName() : Created developer name; developerName= ' + serviceResponse.data );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'createDeveloperName() : Failed to create developer name. Error= ' + e.getMessage() );
            throw e;
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

    public Common.ServiceResponse isDeveloperNameAvailable( final String application, final String developerName ) {
        
        System.debug( LoggingLevel.DEBUG, 'isDeveloperNameAvailable() - enter. application=' + application + '; developerName= ' + developerName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            if( String.isBlank(application) || String.isBlank(developerName) ) {
                System.debug( LoggingLevel.ERROR, 'isDeveloperNameAvailable() : Invalid request parameters. application= ' + application + '; developerName= ' + developerName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            Common.Application applicationType;

            switch on application.toUpperCase() {
                
                when 'OBJECTMAPPING' {
                    applicationType = Common.Application.ObjectMapping;
                }
                when 'EXPRESSION' {
                    applicationType = Common.Application.Expression;
                }
                when 'PROCESSWIZARD' {
                    applicationType = Common.Application.ProcessWizard;
                }
                when 'PROCESSWIZARDSTEP' {
                    applicationType = Common.Application.ProcessWizardStep;
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'isDeveloperNameAvailable() : Application type not supported. Type= ' + application );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }

            serviceResponse.data = COMM_DeveloperName.isDeveloperNameAvailable( applicationType, developerName );

            System.debug( LoggingLevel.INFO, 'isDeveloperNameAvailable() : Created developer name; developerName= ' + serviceResponse.data );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'isDeveloperNameAvailable() : SvmxNestedException - Failed to check if developer name is available. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'isDeveloperNameAvailable() : Failed to check if developer name is available. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'isDeveloperNameAvailable() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}