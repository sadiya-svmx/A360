/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a entry point for Technical Attributes Rest Services
 * @urlMapping '/technicalAttribute/*'
 *
 * @author Jeevika Rao
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jeevika Rao            30 June 2022     Created.
 *****************************************************************************************************/
 
 @RestResource(urlMapping='/technicalAttribute/*') 
 global with sharing class TA_TechnicalAttributeRestInterface {
     
    @HttpPost
    global static void doPost() {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttributeRestInterface::doPost - enter; request= ' + RestContext.request.toString() );
        
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            new TA_TechnicalAttributeService(req, res).invokeMethod( COMM_SvmxRestBase.HTTP_METHOD_POST );
            
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'TA_TechnicalAttributeRestInterface::doPost() : Failed to process doPost. Error' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttributeRestInterface::doPost - exit' );
        }
    }
 }