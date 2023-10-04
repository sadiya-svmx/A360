/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates aura enabled methods for PSC Search Criteria Card and
 * Criteria definition model which will be invoked by lwc components.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          17 Dec 2020     Created.
 *****************************************************************************************************/
public with sharing class PSC_SearchCriteria_LS {

    /**
     * This method is used to retrieve current status of the Search Criteria card component for PSC.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful retrieve with status and Search Criteria data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getSearchCriteriaStatus(final String pscRecordId) {
        
        System.debug(LoggingLevel.DEBUG, 'getSearchCriteriaStatus() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new PSC_SearchCriteriaHandler().getSearchCriteriaStatus(pscRecordId);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getSearchCriteriaStatus() : Failed to get searchCriteria status. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getSearchCriteriaStatus() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save Search Criteria for PSC.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful save of Search Criteria data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveSearchCriteria(final String requestJson) {
        
        System.debug(LoggingLevel.DEBUG, 'saveSearchCriteria() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Psc.SearchCriteria searchCriteria = (Psc.SearchCriteria) JSON.deserializeStrict(requestJson, Psc.SearchCriteria.class);
            serviceResponse.data = new PSC_SearchCriteriaHandler().saveSearchCriteria(searchCriteria);
        }
        catch(System.JSONException e) {
            System.debug(LoggingLevel.ERROR, 'saveSearchCriteria() : Failed to deserialize request JSON. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'saveSearchCriteria() : Failed to save searchCriteria detail. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'saveSearchCriteria() - exit; serviceResponse.success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to fetch Results Preview for particular PSC.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful retrieval of Results Preview data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getResultsPreview(final String pscRecordId) {
        
        System.debug(LoggingLevel.DEBUG, 'getResultsPreview() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new PSC_SearchCriteriaHandler().getResultsPreview(pscRecordId);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getResultsPreview() : Failed to get Results Preview. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'getResultsPreview() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to initiate PSC_SearchResultBatch batch for the requested PSC record.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     *          successful execution, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse initiateSearchResultBatch(final String pscRecordId) {
        
        System.debug(LoggingLevel.DEBUG, 'initiateSearchResultBatch() - enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.success = new PSC_SearchCriteriaHandler().initiateSearchResultBatch(pscRecordId);
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'initiateSearchResultBatch() : Failed to initiate batch. Error' + e.getStackTraceString());
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'initiateSearchResultBatch() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }
}