/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for technical attribute match rule Services
 * @urlMapping '/admin/technicalAttribute/*'
 *
 * @author Ramachandra Mohan
 * @version 7.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       05 Sep 2022     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/admin/technicalAttribute/*')
global class TechnicalAttributeRestInterface {

    @HttpGet
    global static void doGet() {
        
		System.debug( LoggingLevel.DEBUG, 'doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_TechnicalAttributeService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

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

            new ADM_TechnicalAttributeService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doPost - exit' );
        }
    }
}