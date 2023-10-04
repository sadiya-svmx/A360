/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Maintenance Plan Rest Services for CPQ
 * @urlMapping '/mpln/*'
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah      30 Nov 2021     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/mpln/*')
global with sharing class MaintenancePlanRestInterface {
    
    
    @HttpPost
    global static void doPost() {
        
		System.debug( LoggingLevel.DEBUG, 'MaintenancePlanRestInterface::doPost - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new MPLN_MaintenancePlanService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'MaintenancePlanRestInterface::doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'MaintenancePlanRestInterface::doPost - exit' );
        }
    }
}