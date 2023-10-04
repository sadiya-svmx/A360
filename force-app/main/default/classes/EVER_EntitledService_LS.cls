/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete on entitled services.
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
  *A360CE-364   Karthick Saravanan     04 Jan 2021     Created.
 *****************************************************************************************************/
public with sharing class EVER_EntitledService_LS {

    // Static string variable to hold record type name - EntitledServices
    private static final String RECORD_TYPE_ENTITLED_SERVICE = 'EntitledServices';
    
    /**
     * This method retrieves all available entitled services for a service contract.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all entitled services for a service contract.
     */
    @AuraEnabled  
    public static Common.ServiceResponse getEntitledServices(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledService_LS -getEntitledServices() - enter--'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve entitled services from manager 
            serviceResponse.data = EVER_EntitledServiceManager.getInstance().getEntitledServices(inputData);
            System.debug( LoggingLevel.INFO, 'getEntitledServices() : Retrieved entitled services successfully' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServices() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServices() : Failed to retrieve entitled services. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServices() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves parent record informations for Entitled Service.
     * 
     * @return Returns instance of Common.ServiceResponse with details of parent record informations.
     */
	@AuraEnabled
    public static Common.ServiceResponse getParentRecordValues( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledService_LS - getParentRecordValues() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve parent record informations from manager 
            serviceResponse.data = EVER_EntitledServiceManager.getInstance().getParentRecordValues(inputData);
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
     * This method retrieves details for a Entitled Service record.
     * 
     * @return Returns instance of Common.ServiceResponse with details of Entitled Service.
     */
	@AuraEnabled
    public static Common.ServiceResponse getEntitledServiceDetails( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledService_LS - getEntitledServiceDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve Entitled Service details from manager 
            serviceResponse.data = EVER_EntitledServiceManager.getInstance().getEntitledServiceDetails(inputData);
            System.debug( LoggingLevel.INFO, 'getContractPriceLineItems() : Retrieved Entitled Service details successfully' );

        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceDetails() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() ); 
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceDetails() : Failed to retrieve Entitled Service detail. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the Entitled Service with detail
     * 
     * @return Returns instance of Common.ServiceResponse with Entitled Service information.
     */
	@AuraEnabled
    public static Common.ServiceResponse saveEntitledService( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledService_LS - saveEntitledService() - enter --:'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Ever.EntitledServiceDetail inputData = (Ever.EntitledServiceDetail) JSON.deserializeStrict( requestJson, Ever.EntitledServiceDetail.class );            
            serviceResponse.data = EVER_EntitledServiceManager.getInstance().saveEntitledService(inputData);
            System.debug( LoggingLevel.INFO, 'saveEntitledService() : Saved Entitled Service details' +serviceResponse);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledService() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledService() : Failed to save Entitled Service detail. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitledService() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Entitled Service
     * 
     * @return Returns instance of Common.ServiceResponse with response of Entitled Service.
     */
	@AuraEnabled
    public static Common.ServiceResponse deleteEntitledService( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledService_LS - deleteEntitledService() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Remove Entitled Service Item from manager 
            EVER_EntitledServiceManager.getInstance().deleteEntitledService(inputData.id);
            System.debug( LoggingLevel.INFO, 'deleteEntitledService() : deleted Entitled Service' );

        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledService() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );  
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledService() : Failed to delete Entitled Service. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitledService() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getEntitledServiceRecordTypeId() {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServiceRecordTypeId() - enter;' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();
            
            serviceResponse.data = recordTypeId;
            System.debug( LoggingLevel.INFO, 'getEntitledServiceRecordTypeId() : fetched Record Type Id' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceRecordTypeId() : Failed to fetch Record Type Id. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceRecordTypeId() - exit; serviceResponse= ' + serviceResponse );
        }
        
        return serviceResponse;
    }
}