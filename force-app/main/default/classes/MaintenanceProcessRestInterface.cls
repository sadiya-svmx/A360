/*****************************************************************************
 *                       Copyright (C) 2023 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Maintenance Plan Process Rest Services
 * @urlMapping '/admin/mpln/*'
 *
 * @author Ramachandra Mohan
 * @version 9.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       25 Aug 2023     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/admin/mpln/*')
global with sharing class MaintenanceProcessRestInterface {
    
    @HttpGet
    global static void doGet() {
        
		System.debug( LoggingLevel.DEBUG, 'MaintenanceProcessRestInterface::doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_MaintenanceProcessService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'MaintenanceProcessRestInterface::doGet() : Failed to process doGet. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'MaintenanceProcessRestInterface::doGet - exit' );
        }
    }
    
    @HttpPost
    global static void doPost() {
        
		System.debug( LoggingLevel.DEBUG, 'MaintenanceProcessRestInterface::doPost - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_MaintenanceProcessService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'MaintenanceProcessRestInterface::doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'MaintenanceProcessRestInterface::doPost - exit' );
        }
    }
}