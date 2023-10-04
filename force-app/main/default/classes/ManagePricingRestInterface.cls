/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a REST endpoint for services areound calculating prices of Product Consumed, 
 * Work Order Line Items and Expense records
 * @urlMapping '/pcal/pricingengine/*'
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/***************************************************************************************************
 *    ID        Name                    Date            Comment
 ***************************************************************************************************
 *              Shashank Panchal       21 Dec 2020     Created.
 **************************************************************************************************/
@RestResource(urlMapping='/pcal/workorder/*')
global with sharing class ManagePricingRestInterface {
    @HttpPost
    global static void doPost() {
		System.debug( LoggingLevel.INFO, 'doPost - enter; request = ' + RestContext.request.toString());
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            new PCAL_ManagePricingService(req, res).invokeMethod(COMM_SvmxRestBase.HTTP_METHOD_POST);
        }
        catch(Exception e) {
            System.debug( LoggingLevel.ERROR, 'doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.INFO, 'doPost - exit' );
        }
    }
}