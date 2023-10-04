/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Page layout Rest Services with 
 * @urlMapping '/admin/LookupConfigRestInterface/*'
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Jun 2020     Created.
 *              Sathish Kumar DB        16 Feb 2021     A360TOOL-394
 *****************************************************************************************************/
@RestResource(urlMapping='/admin/LookupConfigRestInterface/*')
global with sharing class LookupConfigRestInterface {

    @HttpGet
    global static void doGet() {

        try {

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_LookupConfigService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

        }
        catch(Exception ex){
            System.debug( LoggingLevel.ERROR, 'doGet() : Failed to process doGet. Error' + ex.getStackTraceString() );
        }
    }

    @HttpPost
    global static void doPost() {

        try {

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_LookupConfigService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch(Exception ex){
            System.debug( LoggingLevel.ERROR, 'doPost() : Failed to process doPost. Error' + ex.getStackTraceString() );
        }
    }
}