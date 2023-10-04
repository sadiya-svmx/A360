/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is a service layer class for LookupFilter component.  
 * for lookup filter component.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni          17 August 2020     Created.
 * A360ENG-539  Jason Bradley        29 Jan 2021        Added SOSL interface for Lookup Field. Greatly
 *                                                      reduces upfront metadata info necessary to
 *                                                      execute the search, and is more efficient for
 *                                                      text searching in general.
 *****************************************************************************************************/
public with sharing class COMM_LookupFilterLightningService {
    
    @AuraEnabled
    public static Common.ServiceResponse getLookupConfigData(String lookupConfigId, String objectName,
    String referenceNameField) {

        System.debug( LoggingLevel.DEBUG, 'getLookupConfigData() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new COMM_LookupModalController().getLookupConfigColumns(lookupConfigId, objectName, referenceNameField);
            System.debug( LoggingLevel.INFO, 'getLookupConfigData() : Retrieved lookup configuration details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getLookupConfigData() : Failed to retrieve lookup configuration detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigData() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getFilteredRecords(String requestJson) {
        System.debug( LoggingLevel.DEBUG, 'getFilteredRecords() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Config.LookupFilterCriteria filterCriteria = (Config.LookupFilterCriteria) JSON.deserializeStrict(requestJson, Config.LookupFilterCriteria.class);
            serviceResponse = new COMM_LookupModalController().getFilteredRecords(filterCriteria);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getFilteredRecords() : Failed to retrieve lookup records. Error' + e.getStackTraceString());
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getFilteredRecords() - exit; success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getMatchingRecords(String requestJson) {
        System.debug( LoggingLevel.DEBUG, 'getMatchingRecords() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Config.LookupFilterCriteria filterCriteria = (Config.LookupFilterCriteria) JSON.deserializeStrict(requestJson, Config.LookupFilterCriteria.class);
            serviceResponse = new COMM_LookupModalController().getFilteredRecords(filterCriteria);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getMatchingRecords() : Failed to retrieve lookup records. Error' + e.getStackTraceString());
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getMatchingRecords() - exit; success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getMatchingRecordIds(String requestJson) {
        System.debug(LoggingLevel.DEBUG, 'getMatchingRecordIds() - enter; requestJson= ' + requestJson);
        
        Common.Serviceresponse serviceResponse = new Common.ServiceResponse();

        try {
            Config.LookupFilterCriteria filterCriteria = (Config.LookupFilterCriteria) JSON.deserializeStrict(requestJson, Config.LookupFilterCriteria.class);
            serviceResponse = new COMM_LookupModalController().getMatchingRecordIds(filterCriteria);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getMatchingRecordIds() : Failed to retrieve lookup record ids. Error' + e.getStackTraceString());
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getMatchingRecordIds() - exit; success= ' + serviceResponse.success);
        }

        return serviceResponse;
    }
}