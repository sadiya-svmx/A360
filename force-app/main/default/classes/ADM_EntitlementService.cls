/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/create/update and delete 
 * entitlement rules. 
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
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 *****************************************************************************************************/
public with sharing class ADM_EntitlementService extends ADM_AbstractEntitlementService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_EntitlementService(){}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_EntitlementService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    /**
     * This method is used to retrieve all the entitlement rules.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse getAllEntitlementRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getAllEntitlementRules();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRules() : Failed to retrieve Entitlement Rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
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
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse getAllEntitlementSettings() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getAllEntitlementSettings();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementSettings() : Failed to retrieve Entitlement Settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
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
    override public Common.ServiceResponse getEntitlementRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getEntitlementRules( objectName );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Failed to retrieve entitlement rules. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve entitlement rules for requested entitlement rule id.
     * 
     * @param entitlementRuleId Entitlement rule id for which entitlement rules to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse getEntitlementRule( final String entitlementRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - enter; entitlementRuleId= ' + entitlementRuleId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getEntitlementRule( entitlementRuleId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Failed to retrieve entitlement rules. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to validate requested entitlement rule.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be validated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful validation of the entitlement rule, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse validateEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateEntitlementRule() - enter; entitlementRule= ' + entitlementRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().validateEntitlementRule( entitlementRule );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateEntitlementRule() : Failed to validate entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateEntitlementRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param requestEntitlementRule Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse saveEntitlementRule( final Adm.EntitlementRule requestEntitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - enter; entitlementRule= ' + requestEntitlementRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().saveEntitlementRule( requestEntitlementRule );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
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
     * @param entitlementSettings Entitlement settings wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement settings with saved settings in data, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse saveEntitlementSettings( final Adm.EntitlementSettings entitlementSettings ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - enter; entitlementSettings= ' + entitlementSettings );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().saveEntitlementSettings( entitlementSettings );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save entitlement settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
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
     * @param commonEntitlementSettings Entitlement settings wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement settings with saved settings in data, Otherwise, set it to 'false'.
     * 
     */
    public Common.ServiceResponse saveCommonEntitlementSettings( final Adm.CommonEntitlementSettings commonEntitlementSettings ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveCommonEntitlementSettings() - enter; commonEntitlementSettings= ' + commonEntitlementSettings );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().saveCommonEntitlementSettings( commonEntitlementSettings );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveCommonEntitlementSettings() : Failed to save entitlement settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveCommonEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to update requested entitlement rule sequence and status.
     * 
     * @param entitlementRuleList List of Entitlement rules instance for which sequence and status to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of the entitlement rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse updateEntitlementRulesSequence( final List<Adm.EntitlementRule> entitlementRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateEntitlementRulesSequence() - enter; entitlementRule= ' + entitlementRuleList );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().updateEntitlementRulesSequence( entitlementRuleList );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Failed to update entitlement rule sequence. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateEntitlementRulesSequence() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to delete entitlement rule for requested entitlement id.
     * 
     * @param entitlementRule Entitlement rule with id to be deleted.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of entitlement rules, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse deleteEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - enter; entitlementRule= ' + entitlementRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_EntitlementServiceImpl().deleteEntitlementRule( entitlementRule );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Failed to delete entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve entitlement setting for requested object name.
     * 
     * @param objectName Object Name for which the entitlement settings needs to be fetched.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of entitlement rules, Otherwise, set it to 'false'.
     */
    public Common.ServiceResponse getEntitlementSettings( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - enter; objectName= ' + objectName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getEntitlementSettings( objectName );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementSettings() : Failed to retrieve the entitlement settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve common entitlement setting.
     *
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of entitlement rules, Otherwise, set it to 'false'.
     */
    public Common.ServiceResponse getCommonEntitlementSetting() {
        
        System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() - enter ');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getCommonEntitlementSetting();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getCommonEntitlementSetting() : Failed to retrieve the entitlement settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve unsupported fields for stack ranking.
     *
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with unsupported fields, Otherwise, set it to 'false'.
     */
    public Common.ServiceResponse getUnsupportedStackRankingFields() {
        
        System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - enter ');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getUnsupportedStackRankingFields();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getUnsupportedStackRankingFields() : Failed to retrieve the unsupported fields. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve pricebook assignment rules for requested object name.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with pricebook assignment rules data, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse getAllPricebookAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getAllPricebookAssignmentRules();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPricebookAssignmentRules() : Failed to retrieve pricebook assignment rules. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
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
     * 			successful retrieve with service assignment rule data, Otherwise, set it to 'false'.
     */
    public Common.ServiceResponse getPricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getPricebookAssignmentRule( pricebookAssignmentRuleId );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Failed to retrieve pricebook assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        return serviceResponse;
    }

    /**
     * This method is used to validate requested Pricebook Assignment rule.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment rule wrapper instance to be validated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful validate of the pricebook assignment rule, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse validatePricebookAssignmentRule( final Adm.PricebookAssignmentRule pricebookAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRule() - enter; pricebookAssignmentRule= ' + pricebookAssignmentRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().validatePricebookAssignmentRule( pricebookAssignmentRule );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validatePricebookAssignmentRule() : Failed to validate pricebook assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save requested Pricebook Assignment rule. If Pricebook Assignment id not exists then, 
     * new Pricebook Assignment rule record will be created otherwise, existing Pricebook Assignment rule will be updated.
     * 
     * @param requestPricebookAssignmentRule Pricebook Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the pricebook assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse savePricebookAssignmentRule( final Adm.PricebookAssignmentRule requestPricebookAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - enter; requestPricebookAssignmentRule= ' + requestPricebookAssignmentRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().savePricebookAssignmentRule( requestPricebookAssignmentRule );
        }
        catch( Exception e ) {
            
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
     * @param requestPricebookAssignmentRuleList List of pricebook assignment rules instance for which sequence and status to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of the pricebook assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    public Common.ServiceResponse updatePricebookAssignmentRulesSequence( final List<Adm.PricebookAssignmentRule> requestPricebookAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - enter; requestPricebookAssignmentRuleList= ' + requestPricebookAssignmentRuleList );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().updatePricebookAssignmentRulesSequence( requestPricebookAssignmentRuleList );
        }
        catch( Exception e ) {
            
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
     * This method is used to delete pricebook assignment rule for requested pricebook assignment id.
     * 
     * @param pricebookAssignmentRuleId Pricebook Assignment rule id to be deleted.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of pricebook assignment rule, Otherwise, set it to 'false'.
     */
    public Common.ServiceResponse deletePricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePricebookAssignmentRule() - enter; pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_EntitlementServiceImpl().deletePricebookAssignmentRule( pricebookAssignmentRuleId );
        }
        catch( Exception e ) {
            
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
    override public Common.ServiceResponse getAllServiceAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getAllServiceAssignmentRules();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceAssignmentRules() : Failed to retrieve service assignment rules. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
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
    public Common.ServiceResponse getServiceAssignmentRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getServiceAssignmentRules( objectName );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRules() : Failed to retrieve service assignment rules. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
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
    public Common.ServiceResponse getServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getServiceAssignmentRule( serviceAssignmentRuleId );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Failed to retrieve service assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        return serviceResponse;
    }

    /**
     * This method is used to validate requested Service Assignment rule.
     * 
     * @param serviceAssignmentRule Service Assignment rule wrapper instance to be validated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful validation of the service assignment rule, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse validateServiceAssignmentRule( final Adm.ServiceAssignmentRule serviceAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRule() - enter; serviceAssignmentRule= ' + serviceAssignmentRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().validateServiceAssignmentRule( serviceAssignmentRule );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateServiceAssignmentRule() : Failed to validate service assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save requested Service Assignment rule. If Service Assignment id not exists then, 
     * new Service Assignment rule record will be created otherwise, existing Service Assignment rule will be updated.
     * 
     * @param requestServiceAssignmentRule Service Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the service assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse saveServiceAssignmentRule( final Adm.ServiceAssignmentRule requestServiceAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - enter; requestServiceAssignmentRule= ' + requestServiceAssignmentRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().saveServiceAssignmentRule( requestServiceAssignmentRule );
        }
        catch( Exception e ) {
            
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
     * @param requestServiceAssignmentRuleList List of service assignment rules instance for which sequence and status to be updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful update of the service assignment rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    public Common.ServiceResponse updateServiceAssignmentRulesSequence( final List<Adm.ServiceAssignmentRule> requestServiceAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - enter; requestServiceAssignmentRuleList= ' + requestServiceAssignmentRuleList );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().updateServiceAssignmentRulesSequence( requestServiceAssignmentRuleList );
        }
        catch( Exception e ) {
            
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
     * This method is used to delete service assignment rule for requested service assignment id.
     * 
     * @param serviceAssignmentRuleId Service Assignment rule id to be deleted.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of service assignment rule, Otherwise, set it to 'false'.
     */
    public Common.ServiceResponse deleteServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - enter; serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_EntitlementServiceImpl().deleteServiceAssignmentRule( serviceAssignmentRuleId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Failed to delete service assignment rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve all the entitlement rules with details.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful retrieve with entitlement rules data, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse getAllEntitlementRulesWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().getAllEntitlementRulesWithDetails();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRulesWithDetails() : Failed to retrieve Entitlement Rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save list of entitlement rules. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param requestEntitlementRule Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of the entitlement rule with saved rule in data, Otherwise, set it to 'false'.
     * 
     */
    override public Common.ServiceResponse saveEntitlementRules( final List<Adm.EntitlementRule> requestEntitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRules() - enter; entitlementRule= ' + requestEntitlementRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_EntitlementServiceImpl().saveEntitlementRules( requestEntitlementRule );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRules() : Failed to save entitlement rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}