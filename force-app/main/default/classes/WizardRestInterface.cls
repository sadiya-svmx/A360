/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for wizard Rest Services
 * @urlMapping '/admin/wizard/*'
 *
 * @author Sathish Kumar DB
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sathish Kumar DB       01 Feb 2021     Created.
 *****************************************************************************************************/
@RestResource(urlMapping='/admin/wizard/*')
global class WizardRestInterface {

    @HttpGet
    global static void doGet() {
        
		System.debug( LoggingLevel.DEBUG, 'doGet - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_ProcessWizardService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_GET );

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

            new ADM_ProcessWizardService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );

        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doPost - exit' );
        }
    }
    
    @HttpDelete
    global static void doDelete() {

        System.debug( LoggingLevel.DEBUG, 'doDelete - enter; request= ' + RestContext.request.toString() );
        
        try{

            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;

            new ADM_ProcessWizardService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_DELETE );

        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'doDelete() : Failed to process doDelete. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'doDelete - exit' );
        }
    }
}