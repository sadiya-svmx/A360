/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Service Contract Rest Services
 * @urlMapping '/ever/entitlement/*'
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       06 Apr 2021     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/ever/entitlement/*')
global with sharing class EverEntitlementRestInterface {
    
	@HttpGet
    global static void doGet() {
        
		System.debug( LoggingLevel.DEBUG, 'EverEntitlementRestInterface::doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new EVER_EntitlementService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'EverEntitlementRestInterface::doGet() : Failed to process doGet. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'EverEntitlementRestInterface::doGet - exit' );
        }
    }
    
    @HttpPost
    global static void doPost() {
        
		System.debug( LoggingLevel.DEBUG, 'EverEntitlementRestInterface::doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new EVER_EntitlementService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'EverEntitlementRestInterface::doGet() : Failed to process doGet. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'EverEntitlementRestInterface::doGet - exit' );
        }
    }
}