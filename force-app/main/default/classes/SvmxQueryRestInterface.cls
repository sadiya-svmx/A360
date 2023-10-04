/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for data Rest Services
 * @urlMapping '/common/data/*'
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni             31 March 2022     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/common/data/*')
global with sharing class SvmxQueryRestInterface {

    @HttpPost
    global static void doPost() {

        System.debug( LoggingLevel.DEBUG, 'doPost - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new COMM_SvmxQueryService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doPost - exit' );
        }
    }
    
}