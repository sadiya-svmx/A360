/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * entitlement rule information which will be invoked by lwc components. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       25 Jun 2020     Created.
 *              Sandeep Dhariwal        14 Aug 2020     BLOS-312
 *              Sandeep Dhariwal        10 Dec 2020     A360CE-359
 *****************************************************************************************************/
public with sharing class ADM_EntitlementLightningService {

    /**
     * This method is used to retrieve all the entitlement rules.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllEntitlementRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getAllEntitlementRules();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve all the entitlement settings.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement settings data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllEntitlementSettings() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getAllEntitlementSettings();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve entitlement settings for an object.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement settings data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getEntitlementSettings( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getEntitlementSettings( objectName );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /* This method is used to retrieve common entitlement setting.
    * 
    * @return Returns instance of Common.ServiceResponse with success 'true' on 
    * 			successful retrieve with entitlement settings data, Otherwise, set it to 'false'.
    */
    @AuraEnabled
    public static Common.ServiceResponse getCommonEntitlementSetting() {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getCommonEntitlementSetting();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /* This method is used to retrieve unsupported fields for stack ranking.
    * 
    * @return Returns instance of Common.ServiceResponse with success 'true' on 
    * 			successful retrieve with unsupported fields, Otherwise, set it to 'false'.
    */
    @AuraEnabled
    public static Common.ServiceResponse getUnsupportedStackRankingFields() {
        
        System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getUnsupportedStackRankingFields();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve entitlement rules for requested object name.
     * 
     * @param objectName Object API name for which entitlement rules to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getEntitlementRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getEntitlementRules( objectName );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve entitlement rules for requested entitlement rule id.
     * 
     * @param entitlementRuleId entitlement rule id for which entitlement rules to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getEntitlementRule( final String entitlementRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - enter; entitlementRuleId= ' + entitlementRuleId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getEntitlementRule( entitlementRuleId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param requestJson Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse saveEntitlementRule( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.EntitlementRule entitlementRule = (Adm.EntitlementRule) JSON.deserializeStrict( requestJson, Adm.EntitlementRule.class );
            serviceResponse = new ADM_EntitlementService().saveEntitlementRule( entitlementRule );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save requested entitlement settings. If entitlement id not exists then, 
     * new entitlement settings record will be created otherwise, existing entitlement settings will be updated.
     * 
     * @param requestJson Entitlement settings wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement settings with saved settings in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse saveEntitlementSettings( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.EntitlementSettings entitlementSettings = (Adm.EntitlementSettings) JSON.deserializeStrict( requestJson, Adm.EntitlementSettings.class );
            serviceResponse = new ADM_EntitlementService().saveEntitlementSettings( entitlementSettings );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save requested entitlement settings. If entitlement id not exists then, 
     * new entitlement settings record will be created otherwise, existing entitlement settings will be updated.
     * 
     * @param requestJson Entitlement settings wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement settings with saved settings in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse saveCommonEntitlementSettings( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveCommonEntitlementSettings() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.CommonEntitlementSettings commonEntitlementSettings = (Adm.CommonEntitlementSettings) JSON.deserializeStrict( requestJson, Adm.CommonEntitlementSettings.class );
            serviceResponse = new ADM_EntitlementService().saveCommonEntitlementSettings( commonEntitlementSettings );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveCommonEntitlementSettings() : Failed to save entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveCommonEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to update requested entitlement rule sequence and status.
     * 
     * @param requestJson List of Entitlement rules instance for which sequence and status to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of the entitlement rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse updateRulesSequence( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateRulesSequence() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            List<Adm.EntitlementRule> entitlementRuleList = (List<Adm.EntitlementRule>) JSON.deserializeStrict( requestJson, List<Adm.EntitlementRule>.class );
            serviceResponse = new ADM_EntitlementService().updateEntitlementRulesSequence( entitlementRuleList );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateRulesSequence() : Failed to update entitlement rule sequence. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateRulesSequence() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to delete entitlement rule for requested entitlement id.
     * 
     * @param requestJson Entitlement rule with id to be deleted.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of entitlement rules, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteEntitlementRule( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.EntitlementRule entitlementRule = (Adm.EntitlementRule) JSON.deserializeStrict( requestJson, Adm.EntitlementRule.class );
            new ADM_EntitlementService().deleteEntitlementRule( entitlementRule );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Failed to delete entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to fetch entitlement verification history for requested record id.
     * 
     * @param recordId recordId of either Case, Work Order or return order
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of entitlement rules, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getEntitlementVerficationHistory( final String recordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - enter; recordId= ' + recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            if( String.IsBlank(recordId) ) {
                System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            serviceResponse = new EVER_EntitlementHistory().getEntitlementVerficationHistory( recordId );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Failed to retrieve entitlement history. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to fetch entitlement performed flag for requested record id and object.
     * 
     * @param recordId recordId of either Case, Work Order or return order
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of entitlement rules, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getEntitlementPerformed( final String recordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementPerformed() - enter; recordId= ' + recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            if( String.IsBlank(recordId) ) {
                System.debug( LoggingLevel.ERROR, 'getEntitlementPerformed() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            serviceResponse = new EVER_EntitlementHistory().getEntitlementPerformed( recordId );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementPerformed() : Failed to retrieve entitlement performed information. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementPerformed() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to update source record for requested record id.
     * 
     * @param sourceRecordId Source record id to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of source record, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse updateSourceRecord( final Id sourceRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateSourceRecord() - enter; sourceRecordId= ' + sourceRecordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            sObject sObjRec = sourceRecordId.getSObjectType().newSobject(sourceRecordId);
            SvmxDatabase.updateRecord(sObjRec);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateSourceRecord() : Failed to update source record. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateSourceRecord() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
  
    /**
     * This method is used to retrieve all pricebook assignment rules.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with pricebook assignment rules data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllPricebookAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getAllPricebookAssignmentRules();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve pricebook assignment rule for requested Id.
     * 
     * @param pricebookAssignmentRuleId Record Id for which pricebook assignment rules to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with pricebook assignment rule data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getPricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getPricebookAssignmentRule( pricebookAssignmentRuleId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save requested pricebook assignment rule. If pricebook assignment rule id not exists then, 
     * new pricebook assignment rule record will be created otherwise, existing pricebook assignment rule will be updated.
     * 
     * @param requestJson Pricebook Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the pricebook assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse savePricebookAssignmentRule( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.PricebookAssignmentRule pricebookAssignmentRule = (Adm.PricebookAssignmentRule) JSON.deserializeStrict( requestJson, Adm.PricebookAssignmentRule.class );
            serviceResponse = new ADM_EntitlementService().savePricebookAssignmentRule( pricebookAssignmentRule );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Failed to save pricebook assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to update requested pricebook assignment rule sequence and status.
     * 
     * @param requestJson List of Pricebook Assignment rules instance for which sequence and status to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of the pricebook assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse updatePricebookAssignmentRulesSequence( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = (List<Adm.PricebookAssignmentRule>) JSON.deserializeStrict( requestJson, List<Adm.PricebookAssignmentRule>.class );
            serviceResponse = new ADM_EntitlementService().updatePricebookAssignmentRulesSequence( pricebookAssignmentRuleList );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Failed to update pricebook assignment rule sequence. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to delete pricebook assignment rule for requested pricebook assignment rule id.
     * 
     * @param pricebookAssignmentRuleId Pricebook Assignment rule id to be deleted.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of pricebook assignment rule, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse deletePricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePricebookAssignmentRule() - enter; pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_EntitlementService().deletePricebookAssignmentRule( pricebookAssignmentRuleId );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Failed to delete pricebook assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePricebookAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
  
    /**
     * This method is used to retrieve all service assignment rules.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with service assignment rules data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllServiceAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getAllServiceAssignmentRules();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
  
    /**
     * This method is used to retrieve service assignment rules for requested object name.
     * 
     * @param objectName Object API name for which service assignment rules to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with service assignment rules data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getServiceAssignmentRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getServiceAssignmentRules( objectName );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve service assignment rule for requested Id.
     * 
     * @param serviceAssignmentRuleId Record Id for which service assignment rules to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with service assignment rule data, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse getServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_EntitlementService().getServiceAssignmentRule( serviceAssignmentRuleId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save requested service assignment rule. If entitlement id not exists then, 
     * new service assignment rule record will be created otherwise, existing service assignment rule will be updated.
     * 
     * @param requestJson Service Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the service assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse saveServiceAssignmentRule( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.ServiceAssignmentRule serviceEntitlementRule = (Adm.ServiceAssignmentRule) JSON.deserializeStrict( requestJson, Adm.ServiceAssignmentRule.class );
            serviceResponse = new ADM_EntitlementService().saveServiceAssignmentRule( serviceEntitlementRule );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Failed to save service assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to update requested service assignment rule sequence and status.
     * 
     * @param requestJson List of Service Assignment rules instance for which sequence and status to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of the service assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    @AuraEnabled
    public static Common.ServiceResponse updateServiceAssignmentRulesSequence( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = (List<Adm.ServiceAssignmentRule>) JSON.deserializeStrict( requestJson, List<Adm.ServiceAssignmentRule>.class );
            serviceResponse = new ADM_EntitlementService().updateServiceAssignmentRulesSequence( serviceAssignmentRuleList );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Failed to update service assignment rule sequence. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }


    /**
     * This method is used to delete service assignment rule for requested service assignment rule id.
     * 
     * @param serviceAssignmentRuleId Service Assignment rule id to be deleted.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of service assignment rule, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - enter; serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_EntitlementService().deleteServiceAssignmentRule( serviceAssignmentRuleId );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Failed to delete service assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

}