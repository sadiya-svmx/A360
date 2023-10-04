/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates aura enabled methods for Applicable Product and
 * Maintenance Work Rule Template components which will be invoked by LWC components.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          08 Apr 2021     Created.
 *              Soumyaranjan Pati       14 Apr 2021     Updated code for Work rule service
 *              Manish Kushwah          16 Apr 2021     Added getProductList service
 *              Jaysukh Patel           10 May 2021     Added getMaintenanceAssets LS service
 *              Manish Kushwah          11 May 2021     Added getAssetList service - A360AM-556
 *              Soumyaranjan Pati       11 May 2021     Updated code for A360AM-554
 * A360AM-627   Manish Kushwah          27 May 2021     Updated getMaintenanceAssets and getAssetList service for Asset Status values
 * A360AM-370   Jaysukh Patel           26 Jul 2021     Updated getMaintenanceAssets method definantion with string type to support multiple request parameter
 *****************************************************************************************************/
public with sharing class MPLN_MaintenancePlanTemplate_LS {

    @AuraEnabled
    public static Common.ServiceResponse getAllApplicableProducts( final String maintenancePlanTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllApplicableProducts() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = MPLN_MaintenancePlanTemplateManager.getInstance().getAllApplicableProducts(maintenancePlanTemplateId);
            System.debug( LoggingLevel.INFO, 'getAllApplicableProducts() : Retrieved Applicable Products' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllApplicableProducts() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllApplicableProducts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getApplicableProduct( final String applicableProductId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getApplicableProduct() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = MPLN_MaintenancePlanTemplateManager.getInstance().getApplicableProduct(applicableProductId);
            System.debug( LoggingLevel.INFO, 'getApplicableProduct() : Retrieved Applicable Product' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getApplicableProduct() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getApplicableProduct() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse saveApplicableProducts( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveApplicableProducts() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final List<Mpln.ApplicableProduct> applicableProducts = (List<Mpln.ApplicableProduct>) JSON.deserializeStrict( requestJson, List<Mpln.ApplicableProduct>.class );
            
            serviceResponse.data = MPLN_MaintenancePlanTemplateManager.getInstance().saveApplicableProducts(applicableProducts);
            System.debug( LoggingLevel.INFO, 'saveApplicableProducts() : Saved Applicable Products' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveApplicableProducts() : Failed to save Applicable Products. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveApplicableProducts() : Failed to save Applicable Products. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveApplicableProducts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteApplicableProduct( final String applicableProductId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteApplicableProduct() - enter; applicableProductId= ' + applicableProductId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            MPLN_MaintenancePlanTemplateManager.getInstance().deleteApplicableProduct(applicableProductId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteApplicableProduct() : Failed to delete Applicable Product. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteApplicableProduct() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getProductList( final String searchKeyword ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProductList() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = MPLN_MaintenancePlanTemplateManager.getInstance().getProductList(searchKeyword);
            System.debug( LoggingLevel.INFO, 'getProductList() : Retrieved Product records' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProductList() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProductList() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse getAssetList( final String searchKeyword , final List<String> assetStatusValues, List<String> loadedRowsIds) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssetList() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = new MPLN_MaintenancePlanTemplateHandler().getAssetList(searchKeyword, assetStatusValues, loadedRowsIds);
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

    /**
     * This method is used to retrieve all Maintenance WorkRule Templates records associated with 
     * the particular Maintenance Plan Template.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllMaintenanceWorkRuleTemplates( final String maintenancePlanTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceWorkRuleTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = MPLN_MaintenancePlanTemplateManager.getInstance().getAllMaintenanceWorkRuleTemplates(maintenancePlanTemplateId);
            System.debug( LoggingLevel.INFO, 'getAllMaintenanceWorkRuleTemplates() : Retrieved all Maintenance WorkRule Templates' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllMaintenanceWorkRuleTemplates() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceWorkRuleTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method used to deletes the Maintenance WorkRule Template 
     * 
     * @return Returns instance of Common.ServiceResponse with response of delete Maintenance WorkRule Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse deleteMaintenanceWorkRuleTemplate( final String workRuleTemplateId) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteMaintenanceWorkRuleTemplate() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            MPLN_MaintenancePlanTemplateManager.getInstance().deleteMaintenanceWorkRuleTemplate(workRuleTemplateId);
            System.debug( LoggingLevel.INFO, 'deleteMaintenanceWorkRuleTemplate() : deleted Maintenance WorkRule Templates details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteMaintenanceWorkRuleTemplate() : Failed to delete Maintenance WorkRule Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteMaintenanceWorkRuleTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method for upsert the Maintenance WorkRule Template
     * 
     * @return Returns instance of Common.ServiceResponse with response of  Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse saveMaintenanceWorkRuleTemplate( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'saveMaintenanceWorkRuleTemplate() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            final List<Mpln.WorkRuleTemplate> workRuleTemplate = (List<Mpln.WorkRuleTemplate>) JSON.deserializeStrict( requestJson, List<Mpln.WorkRuleTemplate>.class );
            MPLN_MaintenancePlanTemplateManager.getInstance().saveMaintenanceWorkRuleTemplate(workRuleTemplate);
            System.debug( LoggingLevel.INFO, 'saveMaintenanceWorkRuleTemplate() : Upsert details' );
        }
        catch(System.JSONException e) {
            System.debug( LoggingLevel.ERROR, 'saveMaintenanceWorkRuleTemplate() : Failed to Upsert Maintenance WorkRule Templates. JSONException' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveMaintenanceWorkRuleTemplate() : Failed to Upsert Maintenance WorkRule Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveMaintenanceWorkRuleTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    /**
     * This method used to get maintenace Asset based on input sourceRecord id and Maintenace Plan Templated Id
     * 
     * @return Returns instance of Common.ServiceResponse with generated/claculated Maintenance Assets references
	*/
    @AuraEnabled
    public static Common.ServiceResponse getMaintenanceAssets(String requestJson){
        
        System.debug(LoggingLevel.DEBUG, 'MPLN_MaintenancePlanTemplate_LS - getMaintenanceAssets() enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            
            Mpln.MaintenanceAssetRequest maintenanceAssetRequest  = (Mpln.MaintenanceAssetRequest) JSON.deserializeStrict( requestJson, Mpln.MaintenanceAssetRequest.class );
            serviceResponse.data = new MPLN_MaintenancePlanTemplateHandler().getMaintenanceAssets(maintenanceAssetRequest);
            System.debug(LoggingLevel.INFO , ' getMaintenanceAssets() : Retrieved Maintenance Assets successfully');
            
        }
        catch( JSONException e){

            System.debug(LoggingLevel.ERROR, 'getMaintenanceAssets() : Failed to retrieve Maintenance Assets'+ e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;

        }
        catch( Exception e){
            
            System.debug(LoggingLevel.ERROR, 'getMaintenanceAssets() : Failed to retrieve Maintenance Assets'+ e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'MPLN_MaintenancePlanTemplate_LS - getMaintenanceAssets() exit');
        }
        return serviceResponse;
    }
    /**
     * This method used to get the Account Ids based on Associated Locations
     * 
     * @return Returns instance of Common.ServiceResponse with Account Ids
	*/
    @AuraEnabled
    public static Common.ServiceResponse getLocationAccounts( String locationId ){
        
        System.debug(LoggingLevel.DEBUG, 'MPLN_MaintenancePlanTemplate_LS - getLocationAccounts() enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            
            serviceResponse.data = new MPLN_MaintenancePlanTemplateHandler().getLocationAccounts(locationId);
            System.debug(LoggingLevel.INFO , ' getLocationAccounts() : Retrieved Accounts successfully');
            
        }
        catch(Exception e){
            
            System.debug(LoggingLevel.ERROR, 'getLocationAccounts() : Failed to retrieve Accounts'+ e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'MPLN_MaintenancePlanTemplate_LS - getLocationAccounts() exit');
        }
        return serviceResponse;
    }
    /**
     * This method used to calculate the Enddate with a given Startdate, duration and unit
     * 
     * @return Returns instance of Common.ServiceResponse Enddate
	*/
    @AuraEnabled
    public static Common.ServiceResponse calculateEndDate( final Date startDate, final Integer duration, final String unitOfTime ){
        
        System.debug(LoggingLevel.DEBUG, 'MPLN_MaintenancePlanTemplate_LS - calculateEndDate() enter');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            
            serviceResponse.data = COMM_DateLiteralUtils.calculateEndDate( startDate, duration, unitOfTime );
            System.debug(LoggingLevel.INFO , ' calculateEndDate() : Retrieved Enddate successfully');
            
        }
        catch(Exception e){
            
            System.debug(LoggingLevel.ERROR, 'calculateEndDate() : Failed to retrieve Enddate'+ e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            
        }
        finally {
            System.debug(LoggingLevel.DEBUG, 'MPLN_MaintenancePlanTemplate_LS - calculateEndDate() exit');
        }
        return serviceResponse;
    }
}