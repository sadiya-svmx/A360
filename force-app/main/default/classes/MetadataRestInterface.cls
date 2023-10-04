/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for metadata Rest Services with 
 * @urlMapping '/admin/metadata/*'
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       23 Jun 2020     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/admin/metadata/*')
global with sharing class MetadataRestInterface {

    @HttpGet
    global static void doGet() {
        
		System.debug( LoggingLevel.DEBUG, 'doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new COMM_MetadataService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'doGet() : Failed to process doGet. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doGet - exit' );
        }
    }
}