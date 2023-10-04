/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete on contract price line item.
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
  *A360CE-395   Karthick Saravanan     07 Dec 2020     Created.
 *****************************************************************************************************/
public class PCAL_ContractPriceLineItem_LS {
    

    /**
     * This method retrieves all available contract price line items for a service contract
     * 
     * @return Returns instance of Common.ServiceResponse with list of all contract price line items for a service contract.
     */
    @AuraEnabled  
    public static Common.ServiceResponse getContractPriceLineItems(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'PCAL_ContractPriceLineItem_LS -getContractPriceLineItems() - enter--'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );
            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );
            
            // Retrieve Contract Price Line Items from manager 
            serviceResponse.data = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItems(inputData);
            System.debug( LoggingLevel.INFO, 'getContractPriceLineItems() : Retrieved contract price line items successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItems() : Failed to retrieve contract price line item. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItems() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves parent record informations for Contract Price Line Item.
     * 
     * @return Returns instance of Common.ServiceResponse with details of parent record informations.
     */
    @AuraEnabled
    public static Common.ServiceResponse getParentRecordValues( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'PCAL_ContractPriceLineItem_LS - getParentRecordValues() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve parent record informations from manager 
            serviceResponse.data = PCAL_ContractPriceLineItemManager.getInstance().getParentRecordValues(inputData);
            System.debug( LoggingLevel.INFO, 'getParentRecordValues() : Retrieved Parent record informations successfully' );

        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Failed to retrieve parent record informations. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getParentRecordValues() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves details for a contract price line item.
     * 
     * @return Returns instance of Common.ServiceResponse with details of contract price line items for a contract price line item.
     */
    @AuraEnabled
    public static Common.ServiceResponse getContractPriceLineItemDetails( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );
            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );
            
            // Retrieve Contract Price Line Items from manager 
            serviceResponse.data = PCAL_ContractPriceLineItemManager.getInstance().getContractPriceLineItemDetails(inputData);
            System.debug( LoggingLevel.INFO, 'getContractPriceLineItems() : Retrieved contract price line items successfully' );

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemDetails() : Failed to retrieve Contract Price Line Item detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    
    /**
     * This method saves the Contract Price Line Item with detail
     * 
     * @return Returns instance of Common.ServiceResponse with Contract Price Line Item information.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveContractPriceLineItem( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItem() - enter --:'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Config.ContractPriceLineItemDetail inputData = (Config.ContractPriceLineItemDetail) JSON.deserializeStrict( requestJson, Config.ContractPriceLineItemDetail.class );            
            serviceResponse.data = PCAL_ContractPriceLineItemManager.getInstance().saveContractPriceLineItem(inputData);
            System.debug( LoggingLevel.INFO, 'saveContractPriceLineItem() : Saved Contract Price Line Item details' +serviceResponse);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItem() : Failed to save Contract Price Line Item detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItem() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method deletes the Contract Price Line Item 
     * 
     * @return Returns instance of Common.ServiceResponse with response of delete Contract Price Line Item.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteContractPriceLineItem( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLineItem() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );
            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );
            
            // Remove Contract Price Line Item from manager 
            PCAL_ContractPriceLineItemManager.getInstance().deleteContractPriceLineItem(inputData.id);
            System.debug( LoggingLevel.INFO, 'deleteContractPriceLineItem() : deleted Contract price line item' );

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLineItem() : Failed to delete Contract price line item. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLineItem() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves CurrencyCode picklist values for a contract price line item.
     * 
     * @return Returns instance of Common.ServiceResponse with details of CurrencyCode picklist values for a contract price line item.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getCurrencyCodeValues( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getCurrencyCodeValues() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );
            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );
            
            // Retrieve Contract Price Line Items from manager 
            serviceResponse.data = COMM_DatabaseUtils.getInstance().getCurrencyCodeValues(inputData);
            System.debug( LoggingLevel.INFO, 'getCurrencyCodeValues() : Retrieved CurrencyCode picklist values successfully' );

        }catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getCurrencyCodeValues() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );  
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getCurrencyCodeValues() : Failed to retrieve CurrencyCode picklist values. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getCurrencyCodeValues() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}