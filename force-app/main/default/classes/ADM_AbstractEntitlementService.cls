/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for entitlement service implementation.
 * Also provides implementation for invokeMethod which maps to the requested entitlement rule service implementation. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       26 Jun 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 * A360TOOL-403 Ramachandra Mohan       25 Feb 2020     REST Service to support Assignment rules.
 *****************************************************************************************************/
public abstract class ADM_AbstractEntitlementService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public ADM_AbstractEntitlementService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected ADM_AbstractEntitlementService( RestRequest request, RestResponse response ) {
        super( request, response, 'entitlement' );    
    }
    
    /**
     * Override method invoked by base rest class with requested method.
     * 
     * @param methodName Method name from the request URL.
     * 
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            // Invoke service for requested method name.
            switch on methodName {
                
                when 'getAllEntitlementRules' {
                    serviceResponse = getAllEntitlementRules();
                }

                when 'getAllEntitlementRulesWithDetails' {
                    serviceResponse = getAllEntitlementRulesWithDetails();
                }
                
                when 'getAllEntitlementSettings' {
                    serviceResponse = getAllEntitlementSettings();
                }
                
                when 'getEntitlementRules' {
                    serviceResponse = getEntitlementRules( request.params.get('apiName') );
                }
                
                when 'getEntitlementRule' {
                    serviceResponse = getEntitlementRule( recordId );
                }
                
                when 'getAllPricebookAssignmentRules' {
                    serviceResponse = getAllPricebookAssignmentRules();
                }
                
                when 'getAllServiceAssignmentRules' {
                    serviceResponse = getAllServiceAssignmentRules();
                }
                
                when 'validateEntitlementRule' {
                    serviceResponse = validateEntitlementRule( (Adm.EntitlementRule) deserializeRequestTo( Adm.EntitlementRule.class ) );
                }
                
                when 'saveEntitlementRule' {
                    serviceResponse = saveEntitlementRule( (Adm.EntitlementRule) deserializeRequestTo( Adm.EntitlementRule.class ) );
                }

                when 'saveEntitlementRules' {
                    serviceResponse = saveEntitlementRules( (List<Adm.EntitlementRule>) deserializeRequestTo( List<Adm.EntitlementRule>.class ) );
                }
                
                when 'saveEntitlementSettings' {
                    serviceResponse = saveEntitlementSettings( (Adm.EntitlementSettings) deserializeRequestTo( Adm.EntitlementSettings.class ) );
                }
                
                when 'validatePricebookAssignmentRule' {
                    serviceResponse = validatePricebookAssignmentRule( (Adm.PricebookAssignmentRule) deserializeRequestTo( Adm.PricebookAssignmentRule.class ) );
                }
                
                when 'savePricebookAssignmentRule' {
                    serviceResponse = savePricebookAssignmentRule( (Adm.PricebookAssignmentRule) deserializeRequestTo( Adm.PricebookAssignmentRule.class ) );
                }
                
                when 'validateServiceAssignmentRule' {
                    serviceResponse = validateServiceAssignmentRule( (Adm.ServiceAssignmentRule) deserializeRequestTo( Adm.ServiceAssignmentRule.class ) );
                }
                
                when 'saveServiceAssignmentRule' {
                    serviceResponse = saveServiceAssignmentRule( (Adm.ServiceAssignmentRule) deserializeRequestTo( Adm.ServiceAssignmentRule.class ) );
                }
                
                when 'updateRuleSequence' {
                    serviceResponse = updateEntitlementRulesSequence( (List<Adm.EntitlementRule>) deserializeRequestTo( List<Adm.EntitlementRule>.class ) );
                }
                
                when 'deleteEntitlementRule' {
                    
                    Adm.EntitlementRule entitlementRule = new Adm.EntitlementRule();
                    entitlementRule.id = recordId;
                    
                    serviceResponse = deleteEntitlementRule( entitlementRule );
                }
                
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method is used to retrieve all entitlement rules from the Org.
     * 
     * @return Returns list of all entitlement rules.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/entitlement/v1/getAllEntitlementRules/
     */
    public abstract Common.ServiceResponse getAllEntitlementRules();
    
    /**
     * This method is used to retrieve all entitlement settings from the Org.
     * 
     * @return Returns list of all entitlement settings.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/entitlement/v1/getAllEntitlementSettings/
     */
    public abstract Common.ServiceResponse getAllEntitlementSettings();
    
    /**
     * This method is used to retrieve entity definition for requested api names.
     * 
     * @param objectName Object name for which entitlement rules to be retrieved.
     * @return Returns List of entitlement rules for requested apiNames.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/entitlement/v1/getEntitlementRules/?apiName="Account"
     */
    public abstract Common.ServiceResponse getEntitlementRules( final String objectName );
    
    /**
     * This method is used to retrieve entity definition for requested entitlement rule id.
     * 
     * @param entitlementRuleId entitlement rule id for which entitlement rules to be retrieved.
     * @return Returns List of entitlement rules for requested entitlement rule id.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/entitlement/v1/getEntitlementRule/01I3B000000SFMq
     */
    public abstract Common.ServiceResponse getEntitlementRule( final String entitlementRuleId );
    
    /**
     * This method is used to validate entitlement rule.
     * 
     * @param entitlementRule Entitlement Rule information to be validated.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/validateEntitlementRule/
     */
    public abstract Common.ServiceResponse validateEntitlementRule( final Adm.EntitlementRule entitlementRule );
    
    /**
     * This method is used to save entitlement rule.
     * 
     * @param entitlementRule Entitlement Rule information to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/saveEntitlementRule/
     */
    public abstract Common.ServiceResponse saveEntitlementRule( final Adm.EntitlementRule entitlementRule );
    
    /**
     * This method is used to save entitlement settings.
     * 
     * @param entitlementSettings Entitlement settings information to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/saveEntitlementSettings/
     */
    public abstract Common.ServiceResponse saveEntitlementSettings( final Adm.EntitlementSettings entitlementSettings );
    
    /**
     * This method is used to retrieve field definitions for requested entity api names.
     * 
     * @param entitlementRule Entitlement Rule list with sequence number to be updated.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/updateRuleSequence/
     */
    public abstract Common.ServiceResponse updateEntitlementRulesSequence( final List<Adm.EntitlementRule> entitlementRuleList );
    
    /**
     * This method is used to retrieve field definitions for requested entity api names.
     * 
     * @param entitlementRule Entitlement Rule with record id to be deleted from the entitlement rule list.
     * 
     * @example DELETE /services/apexrest/SVMXA360/admin/entitlement/v1/deleteEntitlementRule/01I3B000000SFMq/"
     */
    public abstract Common.ServiceResponse deleteEntitlementRule( final Adm.EntitlementRule entitlementRule );

    /**
     * This method is used to retrieve all entitlement rules with details from the Org.
     * 
     * @return Returns list of all entitlement rules.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/entitlement/v1t/getAllEntitlementRulesWithDetails/
     */
    public abstract Common.ServiceResponse getAllEntitlementRulesWithDetails();

    /**
     * This method is used to save entitlement rules.
     * 
     * @param entitlementRule Entitlement Rule information to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/saveEntitlementRules/
     */
    public abstract Common.ServiceResponse saveEntitlementRules( final List<Adm.EntitlementRule> entitlementRule );
    
    /**
     * This method is used to retrieve all pricebook assignment rules.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/getAllPricebookAssignmentRules/
     */
    public abstract Common.ServiceResponse getAllPricebookAssignmentRules();
    
    /**
     * This method is used to validate pricebook assignment rule.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment Rule information to be validated.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/validatePricebookAssignmentRule/
     */
    public abstract Common.ServiceResponse validatePricebookAssignmentRule(final Adm.PricebookAssignmentRule pricebookAssignmentRule );
    
    /**
     * This method is used to save pricebook assignment rule.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment Rule information to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/savePricebookAssignmentRule/
     */
    public abstract Common.ServiceResponse savePricebookAssignmentRule(final Adm.PricebookAssignmentRule pricebookAssignmentRule );
    
    /**
     * This method is used to retrieve all entitled service assignment rules.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/getAllServiceAssignmentRules/
     */
    public abstract Common.ServiceResponse getAllServiceAssignmentRules();
    
    /**
     * This method is used to validate entitled service assignment rule.
     * 
     * @param serviceAssignmentRule Entitled Service Assignment Rule information to be validated.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/validateServiceAssignmentRule/
     */
    public abstract Common.ServiceResponse validateServiceAssignmentRule(final Adm.ServiceAssignmentRule serviceAssignmentRule );
    
    /**
     * This method is used to save entitled service assignment rule.
     * 
     * @param serviceAssignmentRule Entitled Service Assignment Rule information to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/admin/entitlement/v1/saveServiceAssignmentRule/
     */
    public abstract Common.ServiceResponse saveServiceAssignmentRule(final Adm.ServiceAssignmentRule serviceAssignmentRule );
}