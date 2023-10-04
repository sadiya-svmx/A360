/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates aura enabled methods for PSC Manage Results Card and
 * Manage Results listing which will be invoked by lwc components.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          28 Dec 2020     Created.
 *****************************************************************************************************/
public with sharing class PSC_ManageResults_LS {

    /**
     * This method is used to retrieve current status of the Manage Results card component for PSC.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful retrieve with status and other data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getResultLineStatus(final String pscRecordId) {
        
        System.debug(LoggingLevel.DEBUG, 'getResultLineStatus() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new PSC_ManageResultsHandler().getResultLineStatus(pscRecordId);
        }
        catch(Exception e) {
            System.debug( LoggingLevel.ERROR, 'getResultLineStatus() : Failed to get ResultLineStatus status. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getResultLineStatus() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve Result Lines for Manage Result Line component for PSC.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful retrieve of Result Lines, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getResultLines(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getResultLines() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Psc.ResultLineRequest request = (Psc.ResultLineRequest) JSON.deserializeStrict(requestJson, Psc.ResultLineRequest.class);
            serviceResponse.data = new PSC_ManageResultsHandler().getResultLines(request);
        }
        catch(System.JSONException e) {
            System.debug(LoggingLevel.ERROR, 'getResultLines() : Failed to deserialize request JSON. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getResultLines() : Failed to get ResultLineStatus status. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getResultLines() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve Add Asset Modal Columns for Manage Result Line component.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful retrieve of Add Asset Modal Columns, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAddAssetColumns() {
        
        System.debug(LoggingLevel.DEBUG, 'getAddAssetColumns() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new PSC_ManageResultsHandler().getAddAssetColumns();
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getAddAssetColumns() : Failed to get AddAssetColumns. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getAddAssetColumns() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve Asset records for Manage Result Line component in the modal.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful fetching of Asset records, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAssetRecords(final String requestJson) {
        
        System.debug(LoggingLevel.DEBUG, 'getAssetRecords() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Psc.SearchAssetRequest searchCriteria = (Psc.SearchAssetRequest) JSON.deserializeStrict(requestJson, Psc.SearchAssetRequest.class);
            serviceResponse.data = new PSC_ManageResultsHandler().getAssetRecords(searchCriteria);
        }
        catch(System.JSONException e) {
            System.debug(LoggingLevel.ERROR, 'getAssetRecords() : Failed to deserialize request JSON. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getAssetRecords() : Failed to fetch Asset records. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getAssetRecords() - exit; serviceResponse.success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to insert/update ProductServiceCampaignItem records for Manage Result Line component.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful insert/update of ProductServiceCampaignItem records, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse insertUpdatePsciRecords(final String requestJson) {
        
        System.debug(LoggingLevel.DEBUG, 'insertUpdatePsciRecords() - enter, requestJson: ' + requestJson);
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            List<ProductServiceCampaignItem> psciRecordList = (List<ProductServiceCampaignItem>) JSON.deserializeStrict(requestJson, List<ProductServiceCampaignItem>.class);
            new PSC_ManageResultsHandler().insertUpdatePsciRecords(psciRecordList);
        }
        catch(System.JSONException e) {
            System.debug(LoggingLevel.ERROR, 'insertUpdatePsciRecords() : Failed to deserialize request JSON. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'insertUpdatePsciRecords() : Failed to insert/update ProductServiceCampaignItem records. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'insertUpdatePsciRecords() - exit; serviceResponse.success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to initiate PSC_GenerateOutputBatch batch for the requested PSC record.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful execution, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse initiateGenerateOutputBatch(final String pscRecordId) {
        
        System.debug(LoggingLevel.DEBUG, 'initiateGenerateOutputBatch() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new PSC_ManageResultsHandler().initiateGenerateOutputBatch(pscRecordId);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'initiateGenerateOutputBatch() : Failed to initiate batch. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'initiateGenerateOutputBatch() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }
}