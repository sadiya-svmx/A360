/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Configuration Usage Rest Services
 * @urlMapping 'admin/configuration/usage/*'
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna Nagapudi      25 Aug 2022     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/admin/configuration/usage/*')
global with sharing class ConfigurationUsageRestInterface {
	@HttpGet
    global static void doGet() {
        
		System.debug( LoggingLevel.DEBUG, 'doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_ConfigurationUsageService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'doGet() : Failed to process doGet. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doGet - exit' );
        }
    }

    @HttpPost
    global static void doPost() {

        System.debug( LoggingLevel.DEBUG, 'doPost - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_ConfigurationUsageService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doPost - exit' );
        }
    }
    
}