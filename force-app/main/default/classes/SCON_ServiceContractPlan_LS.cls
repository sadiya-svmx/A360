/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements aura enabled services to perform required 
 * Service Contract plan CRUD operations. These services are invoked directly from 
 * LWC components.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       01 Apr 2021     Created.
 *****************************************************************************************************/
public with sharing class SCON_ServiceContractPlan_LS {

    @AuraEnabled
    public static Common.ServiceResponse getContractLineItemPlans( final String serviceContractId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlans() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractId);
            System.debug( LoggingLevel.INFO, 'getContractLineItemPlans() : Retrieved Applicable Contract Line Products' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlans() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlans() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse getEntitledServicePlans( final String masterRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlans() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(masterRecordId);
            System.debug( LoggingLevel.INFO, 'getEntitledServicePlans() : Retrieved Applicable Contract Line Products' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlans() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlans() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse getContractPriceLineItemPlans( final String masterRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlans() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(masterRecordId);
            System.debug( LoggingLevel.INFO, 'getContractPriceLineItemPlans() : Retrieved Applicable Contract Line Products' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlans() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlans() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getOfferedMPTs( final String masterRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getOfferedMPTs() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getOfferedMPTs(masterRecordId);
            System.debug( LoggingLevel.INFO, 'getOfferedMPTs() : Retrieved Applicable Contract Line Products' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getOfferedMPTs() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getOfferedMPTs() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    
    @AuraEnabled
    public static Common.ServiceResponse getServiceContractPlan( final String masterRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlan() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlan(masterRecordId);
            System.debug( LoggingLevel.INFO, 'getServiceContractPlan() : Retrieved Service Contract Plan Details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlan() : Failed to retrieve records. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlan() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse saveContractLineItemPlan( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractLineItemPlan() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final List<Scon.ContractLineItemPlan> contractLineItemPlans = (List<Scon.ContractLineItemPlan>) JSON.deserializeStrict( requestJson, List<Scon.ContractLineItemPlan>.class );
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlans(contractLineItemPlans);
            System.debug( LoggingLevel.INFO, 'saveContractLineItemPlan() : Saved Entitled Service Plan' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItemPlan() : Failed to save Entitled Service Plan. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItemPlan() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractLineItemPlan() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse saveEntitledServicePlan( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitledServicePlan() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final Scon.EntitledServicePlan entitledServicePlan = (Scon.EntitledServicePlan) JSON.deserializeStrict( requestJson, Scon.EntitledServicePlan.class );
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(entitledServicePlan);
            System.debug( LoggingLevel.INFO, 'saveEntitledServicePlan() : Saved Entitled Service Plan' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledServicePlan() : Failed to save Entitled Service Plan. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledServicePlan() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitledServicePlan() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse saveContractPriceLineItemPlan( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItemPlan() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = (Scon.ContractPriceLineItemPlan) JSON.deserializeStrict( requestJson, Scon.ContractPriceLineItemPlan.class );
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlan);
            System.debug( LoggingLevel.INFO, 'saveContractPriceLineItemPlan() : Saved Contract Price Line Item Plan' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItemPlan() : Failed to save Contract Price Line Item Plan. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItemPlan() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItemPlan() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse saveOfferedMPT( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveOfferedMPT() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final List<Scon.OfferedMaintenancePlanTemplate> offeredMPTs = (List<Scon.OfferedMaintenancePlanTemplate>) JSON.deserializeStrict( requestJson, List<Scon.OfferedMaintenancePlanTemplate>.class );
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().saveOfferedMPTs(offeredMPTs);
            System.debug( LoggingLevel.INFO, 'saveOfferedMPT() : Saved Offered Maintenance Plan Templates' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveOfferedMPT() : Failed to Parse JSON Request. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveOfferedMPT() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveOfferedMPT() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse deleteContractLineItemPlan( final String contractLineItemPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractLineItemPlan() - enter; contractLineItemPlanId= ' + contractLineItemPlanId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            SCON_ServiceContractPlanManager.getInstance().deleteContractLineItemPlan(contractLineItemPlanId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractLineItemPlan() : Failed to delete Applicable Contract Line Product. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractLineItemPlan() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse deleteEntitledServicePlan( final String entitledServicePlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitledServicePlan() - enter; entitledServicePlanId= ' + entitledServicePlanId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            SCON_ServiceContractPlanManager.getInstance().deleteEntitledServicePlan(entitledServicePlanId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledServicePlan() : Failed to delete Entitled Service Plan. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitledServicePlan() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse deleteContractPriceLinePlan( final String contractPriceLinePlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLinePlan() - enter; contractPriceLinePlanId= ' + contractPriceLinePlanId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            SCON_ServiceContractPlanManager.getInstance().deleteContractPriceLinePlan(contractPriceLinePlanId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLinePlan() : Failed to delete Contract Price Line Item Plan. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLinePlan() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteOfferedMPT( final String offeredMPTId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteOfferedMPT() - enter; offeredMPTId= ' + offeredMPTId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            SCON_ServiceContractPlanManager.getInstance().deleteOfferedMPT(offeredMPTId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteOfferedMPT() : Failed to delete offered Maintenance Plan Template. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteOfferedMPT() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse createServiceContract( final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'createServiceContract() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final Scon.ServiceContractPlanRequest sconRequest = (Scon.ServiceContractPlanRequest) JSON.deserializeStrict( requestJson, Scon.ServiceContractPlanRequest.class );
            serviceResponse.data = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
            System.debug( LoggingLevel.INFO, 'createServiceContract() : Created Contract' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Contract. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create contract. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createServiceContract() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse fetchAccountDetails( final String assetId ) {
        
        System.debug( LoggingLevel.DEBUG, 'fetchAccountDetails() - enter; assetId= ' + assetId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            List<Asset> assetRecordList = SvmxDatabase.query( [SELECT Id, AccountId FROM Asset WHERE Id =:assetId] );
            if( assetRecordList[0].AccountId == null) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            serviceResponse.data = assetRecordList[0].AccountId;
            System.debug( LoggingLevel.INFO, 'fetchAccountDetails() : fetched Account details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchAccountDetails() : Failed to fetch Account info. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchAccountDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method used to get the Contract Plans based on matching asset
     * 
     * @return Returns instance of Common.ServiceResponse with Contract Plan Ids
    */
    @AuraEnabled
    public static Common.ServiceResponse fetchMatchingContractPlans( String assetId ){
        
        System.debug(LoggingLevel.DEBUG, 'fetchMatchingContractPlans enter; assetId = '+assetId);
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().fetchMatchingContractPlans(assetId);
            System.debug(LoggingLevel.INFO , ' fetchMatchingContractPlans() : Retrieved Plans successfully');
            
        }
        catch(Exception e){
            
            System.debug(LoggingLevel.ERROR, 'fetchMatchingContractPlans() : Failed to retrieve Plans'+ e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'fetchMatchingContractPlans() - exit');
        }
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getQualifiedAssets( final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'getQualifiedAssets() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final Scon.ServiceContractPlanRequest sconRequest = (Scon.ServiceContractPlanRequest) JSON.deserializeStrict( requestJson, Scon.ServiceContractPlanRequest.class );
            serviceResponse.data = new SCON_ServiceContractPlanHandler().getQualifiedAssets( sconRequest.sourceRecordId, 
                                                                                             sconRequest.locationId,
                                                                                             sconRequest.serviceContractPlanId, 
                                                                                             sconRequest.evaluateForChildAssets);
            System.debug( LoggingLevel.INFO, 'getQualifiedAssets() : Entered' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQualifiedAssets() : Failed to get qualified Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQualifiedAssets() : Failed to get qualified Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQualifiedAssets() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getAssetList( final String accountId, final String searchKeyword, List<String> loadedRowsIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssetList() - enter; searchKeyword= ' + searchKeyword +', accountId = '+accountId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            
            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getAssetList(accountId, searchKeyword, loadedRowsIds);
            System.debug( LoggingLevel.INFO, 'getAssetList() : Retrieved Asset records' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssetList() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetList() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getSCONAuthoringLogs( final String sourceRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getSCONAuthoringLogs() - enter; sourceRecordId= ' + sourceRecordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = SCON_ServiceContractPlanManager.getInstance().getSCONAuthoringLogs(sourceRecordId);
            System.debug( LoggingLevel.INFO, 'getSCONAuthoringLogs() : Retrieved SCON Logs details' );

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSCONAuthoringLogs() : Failed to SCON Logs . Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSCONAuthoringLogs() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteServiceContract( final String serviceContractId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteServiceContract() - enter; serviceContractId= ' + serviceContractId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new SCON_ServiceContractPlanHandler().deleteServiceContract(serviceContractId);
            System.debug( LoggingLevel.INFO, 'deleteServiceContract() : Deleted Service Contract' );

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceContract() : Failed to delete Service Contract . Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceContract() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getAuthoringSummary ( final Id serviceContractId ) {
        System.debug( LoggingLevel.DEBUG, 'getAuthoringSummary() - enter; serviceContractId= ' + serviceContractId );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new SCON_ServiceContractPlanHandler().getAuthoringSummary(serviceContractId);
            System.debug( LoggingLevel.INFO, 'getAuthoringSummary() : Retrieved SCON Authoring Summary' );

        } catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAuthoringSummary() : Failed to fetch AuthoringSummary. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();

        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAuthoringSummary() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse updateServiceContractStatus ( final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'updateServiceContractStatus() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final Scon.ServiceContractDetails sconRequest = (Scon.ServiceContractDetails) JSON.deserializeStrict( requestJson, Scon.ServiceContractDetails.class );
            serviceResponse.data = new SCON_ServiceContractPlanHandler().updateContractStatus(sconRequest);
            System.debug( LoggingLevel.INFO, 'updateServiceContractStatus() : Updated Contract' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateServiceContractStatus() : Failed to update Contract. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateServiceContractStatus() : Failed to update contract. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateServiceContractStatus() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}