/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Service Contract Rest Services
 * @urlMapping '/scon/*'
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Karthick Saravanan     10 Nov 2021      Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/scon/*')
global with sharing class ServiceContractRestInterface {
    
    
    @HttpPost
    global static void doPost() {
        
		System.debug( LoggingLevel.DEBUG, 'ServiceContractRestInterface::doPost - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new SCON_ServiceContractService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'ServiceContractRestInterface::doPost() : Failed to process doGet. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'ServiceContractRestInterface::doPost - exit' );
        }
    }
}