/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements service to retrieve/create/update and delete 
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
 *              Sandeep Dhariwal        16 Dec 2020     A360CE-357
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 *****************************************************************************************************/
public with sharing class ADM_EntitlementServiceImpl {

    /**
     * Instance variable to hold entitlement rule manager.
     */
    private final ADM_EntitlementRuleManager entitlementRuleManager = ADM_EntitlementRuleManager.getInstance();

    /**
     * Instance variable to hold entitlement settings manager.
     */
    private final ADM_EntitlementSettingsManager entitlementSettingsManager = ADM_EntitlementSettingsManager.getInstance();

    /**
     * Instance variable to hold service assignment rule manager.
     */
    private final ADM_ServiceAssignmentRuleManager serviceAssignmentRuleManager = ADM_ServiceAssignmentRuleManager.getInstance();
  
   /**
     * Instance variable to hold pricebook assignment rule manager.
     */
    private final ADM_PricebookAssignmentRuleManager pricebookAssignmentRuleManager = ADM_PricebookAssignmentRuleManager.getInstance();

    
    /**
     * This method is used to retrieve all the entitlement rules.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public List<Adm.EntitlementRule> getAllEntitlementRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - enter' );
        
        List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        
        try {
            entitlementRuleList = entitlementRuleManager.getAllEntitlementRules();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRules() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - exit; entitlementRuleList.size()= ' + entitlementRuleList.size() );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to retrieve all the entitlement settings.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public List<Adm.EntitlementSettings> getAllEntitlementSettings() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - enter' );
        
        List<Adm.EntitlementSettings> entitlementSettingsList = new List<Adm.EntitlementSettings>();
        
        try {
            entitlementSettingsList = entitlementSettingsManager.getAllEntitlementSettings();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementSettings() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementSettings() - exit; entitlementSettingsList.size()= ' + entitlementSettingsList.size() );
        }
        
        return entitlementSettingsList;
    }

    /**
     * This method is used to retrieve all the entitlement settings.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public Adm.EntitlementSettings getEntitlementSettings( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - enter' );
        
        Adm.EntitlementSettings entitlementSettings = new Adm.EntitlementSettings();
        
        try {
            entitlementSettings = entitlementSettingsManager.getEntitlementSettings(objectName);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementSettings() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - exit; entitlementSettingsList.size()= ' + entitlementSettings);
        }
        
        return entitlementSettings;
    }
    
    /**
     * This method is used to retrieve all the entitlement settings.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public Adm.CommonEntitlementSettings getCommonEntitlementSetting() {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementSettings() - enter' );
        
        Adm.CommonEntitlementSettings entitlementSettings = new Adm.CommonEntitlementSettings();
        
        try {
            entitlementSettings = entitlementSettingsManager.getCommonEntitlementSetting();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getCommonEntitlementSetting() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getCommonEntitlementSetting() - exit; entitlementSettingsList.size()= ' + entitlementSettings);
        }
        
        return entitlementSettings;
    }

    /**
     * This method is used to retrieve all the unsupported fields for stack ranking.
     * 
     * @return Returns List of all unsupported fields.
     */
    public List<String> getUnsupportedStackRankingFields() {
        
        System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - enter' );

        List<String> unsupportedFields = new List<String>();
        
        try {
            unsupportedFields = entitlementSettingsManager.getUnsupportedStackRankingFields();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getUnsupportedStackRankingFields() : Failed to retrieve unsupported fields. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getUnsupportedStackRankingFields() - exit; unsupportedFields.size()= ' + unsupportedFields);
        }
        
        return unsupportedFields;
    }

    /**
     * This method is used to retrieve entitlement rules for requested object name.
     * 
     * @param objectName Object API name for which entitlement rules to be retrieved.
     * 
     * @return Returns List of Entitlement rules for requested object.
     */
    public List<Adm.EntitlementRule> getEntitlementRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - enter' );
        
        List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        
        try {
            
            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRuleList = entitlementRuleManager.getEntitlementRules( objectName );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Failed to retrueve Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - exit; entitlementRuleList.size()= ' + entitlementRuleList.size() );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to retrieve entitlement rules for requested entitlement rule id.
     * 
     * @param entitlementRuleId Entitlemenr Rule id for which entitlement rules to be retrieved.
     * 
     * @return Returns Entitlement rules for requested entitlement rule id.
     */
    public Adm.EntitlementRule getEntitlementRule( final String entitlementRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - enter; entitlementRuleId= ' + entitlementRuleId );
        
        Adm.EntitlementRule entitlementRule = new Adm.EntitlementRule();
        
        try {
            
            // Verify request for valid objectName.
            if( String.isBlank( entitlementRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Invalid request parameters. entitlementRuleId= ' + entitlementRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRule = entitlementRuleManager.getEntitlementRule( entitlementRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Failed to retrueve Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - exit; entitlementRule= ' + entitlementRule );
        }
        
        return entitlementRule;
    }
    
    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be validated.
     * 
     * @return Returns Adm.ValidationResul with validation details.
     */
    public Adm.ValidationResult validateEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateEntitlementRule() - enter; entitlementRule= ' + entitlementRule );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( entitlementRule == null || entitlementRule.name == null || String.isBlank( entitlementRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'validateEntitlementRule() : Invalid request parameters. entitlementRule= ' + entitlementRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            validationResult = entitlementRuleManager.validateEntitlementRule( entitlementRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'validateEntitlementRule() : Failed to validate Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateEntitlementRule() : Failed to validate Entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateEntitlementRule() - exit; validationResult= ' + validationResult );
        }
        
        return validationResult;
    }
    
    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.EntitlementRule with created/updated record details.
     */
    public Adm.EntitlementRule saveEntitlementRule( final Adm.EntitlementRule requestEntitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - enter; entitlementRule= ' + requestEntitlementRule );
        
        Adm.EntitlementRule entitlementRule;
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( requestEntitlementRule == null || requestEntitlementRule.name == null || String.isBlank( requestEntitlementRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Invalid request parameters. requestEntitlementRule= ' + requestEntitlementRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRule = entitlementRuleManager.saveEntitlementRule( requestEntitlementRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save Entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - exit; entitlementRule= ' + entitlementRule );
        }
        
        return entitlementRule;
    }
    
    /**
     * This method is used to save requested entitlement settings. If entitlement id not exists then, 
     * new entitlement settings record will be created otherwise, existing entitlement settings will be updated.
     * 
     * @param entitlementSettings Entitlement settings wrapper instance to be created/updated.
     * 
     * @return Returns Adm.EntitlementSettings with created/updated record details.
     */
    public Adm.EntitlementSettings saveEntitlementSettings( final Adm.EntitlementSettings entitlementSettings ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - enter; entitlementRule= ' + entitlementSettings );
        
        Adm.EntitlementSettings responseEntitlementSettings;
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( entitlementSettings == null || String.isBlank( entitlementSettings.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Invalid request parameters. entitlementSettings= ' + entitlementSettings );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            responseEntitlementSettings = entitlementSettingsManager.saveEntitlementSettings( entitlementSettings );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save Entitlement settings. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementSettings() : Failed to save Entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementSettings() - exit; entitlementSettings= ' + responseEntitlementSettings );
        }
        
        return responseEntitlementSettings;
    }
    
    /**
     * This method is used to save requested entitlement settings. If entitlement id not exists then, 
     * new entitlement settings record will be created otherwise, existing entitlement settings will be updated.
     * 
     * @param commonEntitlementSettings Entitlement settings wrapper instance to be created/updated.
     * 
     * @return Returns Adm.EntitlementSettings with created/updated record details.
     */
    public Adm.CommonEntitlementSettings saveCommonEntitlementSettings( final Adm.CommonEntitlementSettings commonEntitlementSettings ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveCommonEntitlementSettings() - enter; entitlementRule= ' + commonEntitlementSettings );
        
        Adm.CommonEntitlementSettings responseEntitlementSettings;
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( commonEntitlementSettings == null || ( commonEntitlementSettings.adjustServiceThreshold == true && String.isBlank(commonEntitlementSettings.adjustVisitCountAssignedObject) )) {
             
                System.debug( LoggingLevel.ERROR, 'saveCommonEntitlementSettings() : Invalid request parameters. entitlementSettings= ' + commonEntitlementSettings );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            responseEntitlementSettings = entitlementSettingsManager.saveCommonEntitlementSettings( commonEntitlementSettings );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveCommonEntitlementSettings() : Failed to save Entitlement settings. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveCommonEntitlementSettings() : Failed to save Entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveCommonEntitlementSettings() - exit; responseEntitlementSettings= ' + responseEntitlementSettings );
        }
        
        return responseEntitlementSettings;
    }

    /**
     * This method is used to update requested entitlement rule sequence and active status.
     * 
     * @param requentEntitlementRuleList List of Entitlement rule instance for which sequence and active status to be updated.
     * 
     * @return Returns List<Adm.EntitlementRule> with updated record details.
     */
    public List<Adm.EntitlementRule> updateEntitlementRulesSequence( final List<Adm.EntitlementRule> requentEntitlementRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateEntitlementRulesSequence() - enter; requentEntitlementRuleList= ' + requentEntitlementRuleList );
        
        List<Adm.EntitlementRule> entitlementRuleList;
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( requentEntitlementRuleList == null || requentEntitlementRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Invalid request parameters. requentEntitlementRuleList= ' + requentEntitlementRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRuleList = entitlementRuleManager.updateEntitlementRulesSequence( requentEntitlementRuleList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Failed to update Entitlement Rule sequence and active status. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Failed to update Entitlement Rule sequence and active status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateEntitlementRulesSequence() - exit; entitlementRuleList= ' + entitlementRuleList );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to delete entitlement rule for requested entitlement id.
     * 
     * @param entitlementRuleId Entitlement rule record id to be deleted.
     */
    public void deleteEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - enter; entitlementRule= ' + entitlementRule );
        
        try {
            // Verify for valid entitlement rule id.
            if( entitlementRule == null || String.isBlank( entitlementRule.id ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Invalid request parameters. entitlementRule= ' + entitlementRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRuleManager.deleteEntitlementRule( entitlementRule.id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Failed to delete Entitlement rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Failed to delete entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - exit');
        }
    }

    /**
     * This method is used to retrieve all pricebook assignment rules.
     * 
     * 
     * @return Returns List of pricebook Assignment rules.
     */
    public List<Adm.PricebookAssignmentRule> getAllPricebookAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - enter' );
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new List<Adm.PricebookAssignmentRule>();
        
        try {
            
            pricebookAssignmentRuleList = pricebookAssignmentRuleManager.getAllPricebookAssignmentRules();
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPricebookAssignmentRules() : Failed to retrueve Pricebook Assignment Rules. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPricebookAssignmentRules() : Failed to retrieve Pricebook Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - exit; pricebookAssignmentRuleList.size()= ' + pricebookAssignmentRuleList.size() );
        }
        
        return pricebookAssignmentRuleList;
    }

    /**
     * This method is used to retrieve service assignment rule for record Id.
     * 
     * @param pricebookAssignmentRuleId Record Id for which service assignment rule to be retrieved.
     * 
     * @return Returns Service Assignment rule for requested Id.
     */
    public Adm.PricebookAssignmentRule getPricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - enter' );
        
        Adm.PricebookAssignmentRule pricebookAssignmentRule = new Adm.PricebookAssignmentRule();
        
        try {
            
            // Verify request for valid pricebookAssignmentRuleId.
            if( String.isBlank( pricebookAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Invalid request parameters. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            pricebookAssignmentRule = pricebookAssignmentRuleManager.getPricebookAssignmentRule( pricebookAssignmentRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Failed to retrueve Pricebook Assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Failed to retrieve Pricebook Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - exit; pricebookAssignmentRule = ' + pricebookAssignmentRule );
        }
        
        return pricebookAssignmentRule;
    }

    /**
     * This method is used to validated requested pricebook assignment rule
     * 
     * @param requestPricebookAssignmentRule Pricebook Assignment rule wrapper instance to be validated.
     * 
     * @return Returns Adm.ValidationResult with validation details.
     */
    public Adm.ValidationResult validatePricebookAssignmentRule( final Adm.PricebookAssignmentRule pricebookAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRule() - enter; pricebookAssignmentRule= ' + pricebookAssignmentRule );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            
            // Verify request for valid pricebook assignment rule informations.
            if( pricebookAssignmentRule == null || pricebookAssignmentRule.name == null || String.isBlank( pricebookAssignmentRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'validatePricebookAssignmentRule() : Invalid request parameters. pricebookAssignmentRule= ' + pricebookAssignmentRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            validationResult = pricebookAssignmentRuleManager.validatePricebookAssignmentRule( pricebookAssignmentRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'validatePricebookAssignmentRule() : Failed to validate pricebook assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validatePricebookAssignmentRule() : Failed to validate pricebook assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRule() - exit; validationResult= ' + validationResult );
        }
        
        return validationResult;
    }
    
    /**
     * This method is used to save requested pricebook assignment rule. If pricebook assignment rule id not exists then, 
     * new pricebook assignment rule record will be created otherwise, existing pricebook assignment rule will be updated.
     * 
     * @param requestPricebookAssignmentRule Pricebook Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.PricebookAssignmentRule with created/updated record details.
     */
    public Adm.PricebookAssignmentRule savePricebookAssignmentRule( final Adm.PricebookAssignmentRule requestPricebookAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - enter; requestPricebookAssignmentRule= ' + requestPricebookAssignmentRule );
        
        Adm.PricebookAssignmentRule pricebookAssignmentRule;
        
        try {
            
            // Verify request for valid pricebook assignment rule informations.
            if( requestPricebookAssignmentRule == null || requestPricebookAssignmentRule.name == null || String.isBlank( requestPricebookAssignmentRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Invalid request parameters. requestPricebookAssignmentRule= ' + requestPricebookAssignmentRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            pricebookAssignmentRule = pricebookAssignmentRuleManager.savePricebookAssignmentRule( requestPricebookAssignmentRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Failed to save pricebook assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Failed to save pricebook assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - exit; pricebookAssignmentRule= ' + pricebookAssignmentRule );
        }
        
        return pricebookAssignmentRule;
    }

    /**
     * This method is used to update requested Pricebook Assignment rule sequence and active status.
     * 
     * @param requestPricebookAssignmentRuleList List of Pricebook Assignment rule instance for which sequence and active status to be updated.
     * 
     * @return Returns List<Adm.PricebookAssignmentRule> with updated record details.
     */
    public List<Adm.PricebookAssignmentRule> updatePricebookAssignmentRulesSequence( final List<Adm.PricebookAssignmentRule> requestPricebookAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - enter; requestPricebookAssignmentRuleList= ' + requestPricebookAssignmentRuleList );
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList;
        
        try {
            
            // Verify request for valid pricebook assignment rule informations.
            if( requestPricebookAssignmentRuleList == null || requestPricebookAssignmentRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Invalid request parameters. requestPricebookAssignmentRuleList= ' + requestPricebookAssignmentRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            pricebookAssignmentRuleList = pricebookAssignmentRuleManager.updatePricebookAssignmentRulesSequence( requestPricebookAssignmentRuleList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Failed to update pricebook assignment Rule sequence and active status. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Failed to update pricebook assignment Rule sequence and active status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - exit; pricebookAssignmentRuleList= ' + pricebookAssignmentRuleList );
        }
        
        return pricebookAssignmentRuleList;
    }

    /**
     * This method is used to delete pricebook assignment rule for requested id.
     * 
     * @param pricebookAssignmentRuleId Pricebook Assignment rule Id to be deleted.
     */
    public void deletePricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePricebookAssignmentRule() - enter; pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        
        try {
            // Verify for valid pricebook assignment rule id.
            if( String.isBlank( pricebookAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Invalid request parameters. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            pricebookAssignmentRuleManager.deletePricebookAssignmentRule( pricebookAssignmentRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Failed to delete pricebook assignment rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Failed to delete pricebook assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePricebookAssignmentRule() - exit');
        }
    }
  
    /**
     * This method is used to retrieve all service assignment rules.
     * 
     * @return Returns List of Service Assignment rules.
     */
    public List<Adm.ServiceAssignmentRule> getAllServiceAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - enter' );
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new List<Adm.ServiceAssignmentRule>();
        
        try {
            
            serviceAssignmentRuleList = serviceAssignmentRuleManager.getAllServiceAssignmentRules();
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceAssignmentRules() : Failed to retrieve Service Assignment Rules. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceAssignmentRules() : Failed to retrieve Service Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - exit; serviceAssignmentRuleList.size()= ' + serviceAssignmentRuleList.size() );
        }
        
        return serviceAssignmentRuleList;
    }

    /**
     * This method is used to retrieve service assignment rules for requested object name.
     * 
     * @param objectName Object API name for which service assignment rules to be retrieved.
     * 
     * @return Returns List of Service Assignment rules for requested object.
     */
    public List<Adm.ServiceAssignmentRule> getServiceAssignmentRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - enter' );
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new List<Adm.ServiceAssignmentRule>();
        
        try {
            
            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRules() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            serviceAssignmentRuleList = serviceAssignmentRuleManager.getServiceAssignmentRules( objectName );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRules() : Failed to retrueve Service Assignment Rules. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRules() : Failed to retrieve Service Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - exit; serviceAssignmentRuleList.size()= ' + serviceAssignmentRuleList.size() );
        }
        
        return serviceAssignmentRuleList;
    }

    /**
     * This method is used to retrieve service assignment rule for record Id.
     * 
     * @param serviceAssignmentRuleId Record Id for which service assignment rule to be retrieved.
     * 
     * @return Returns Service Assignment rule for requested Id.
     */
    public Adm.ServiceAssignmentRule getServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - enter' );
        
        Adm.ServiceAssignmentRule serviceAssignmentRule = new Adm.ServiceAssignmentRule();
        
        try {
            
            // Verify request for valid serviceAssignmentRuleId.
            if( String.isBlank( serviceAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Invalid request parameters. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            serviceAssignmentRule = serviceAssignmentRuleManager.getServiceAssignmentRule( serviceAssignmentRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Failed to retrueve Service Assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Failed to retrieve Service Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - exit; serviceAssignmentRule = ' + serviceAssignmentRule );
        }
        
        return serviceAssignmentRule;
    }

    /**
     * This method is used to save requested service assignment rule. If service assignment rule id not exists then, 
     * new service assignment rule record will be created otherwise, existing service assignment rule will be updated.
     * 
     * @param requestServiceAssignmentRule Service Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.ServiceAssignmentRule with created/updated record details.
     */
    public Adm.ValidationResult validateServiceAssignmentRule( final Adm.ServiceAssignmentRule serviceAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRule() - enter; serviceAssignmentRule= ' + serviceAssignmentRule );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            
            // Verify request for valid service assignment rule informations.
            if( serviceAssignmentRule == null || serviceAssignmentRule.name == null || String.isBlank( serviceAssignmentRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'validateServiceAssignmentRule() : Invalid request parameters. serviceAssignmentRule= ' + serviceAssignmentRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            validationResult = serviceAssignmentRuleManager.validateServiceAssignmentRule( serviceAssignmentRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'validateServiceAssignmentRule() : Failed to validate service assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateServiceAssignmentRule() : Failed to validate service assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRule() - exit; validationResult= ' + validationResult );
        }
        
        return validationResult;
    }
    
    /**
     * This method is used to save requested service assignment rule. If service assignment rule id not exists then, 
     * new service assignment rule record will be created otherwise, existing service assignment rule will be updated.
     * 
     * @param requestServiceAssignmentRule Service Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.ServiceAssignmentRule with created/updated record details.
     */
    public Adm.ServiceAssignmentRule saveServiceAssignmentRule( final Adm.ServiceAssignmentRule requestServiceAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - enter; requestServiceAssignmentRule= ' + requestServiceAssignmentRule );
        
        Adm.ServiceAssignmentRule serviceAssignmentRule;
        
        try {
            
            // Verify request for valid service assignment rule informations.
            if( requestServiceAssignmentRule == null || requestServiceAssignmentRule.name == null || String.isBlank( requestServiceAssignmentRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Invalid request parameters. requestServiceAssignmentRule= ' + requestServiceAssignmentRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            serviceAssignmentRule = serviceAssignmentRuleManager.saveServiceAssignmentRule( requestServiceAssignmentRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Failed to save service assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Failed to save service assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - exit; serviceAssignmentRule= ' + serviceAssignmentRule );
        }
        
        return serviceAssignmentRule;
    }

    /**
     * This method is used to update requested service Assignment rule sequence and active status.
     * 
     * @param requestServiceAssignmentRuleList List of service Assignment rule instance for which sequence and active status to be updated.
     * 
     * @return Returns List<Adm.ServiceAssignmentRule> with updated record details.
     */
    public List<Adm.ServiceAssignmentRule> updateServiceAssignmentRulesSequence( final List<Adm.ServiceAssignmentRule> requestServiceAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - enter; requestServiceAssignmentRuleList= ' + requestServiceAssignmentRuleList );
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList;
        
        try {
            
            // Verify request for valid service assignment rule informations.
            if( requestServiceAssignmentRuleList == null || requestServiceAssignmentRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Invalid request parameters. requestServiceAssignmentRuleList= ' + requestServiceAssignmentRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            serviceAssignmentRuleList = serviceAssignmentRuleManager.updateServiceAssignmentRulesSequence( requestServiceAssignmentRuleList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Failed to update service assignment Rule sequence and active status. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Failed to update service assignment Rule sequence and active status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - exit; serviceAssignmentRuleList= ' + serviceAssignmentRuleList );
        }
        
        return serviceAssignmentRuleList;
    }

    /**
     * This method is used to delete service assignment rule for requested id.
     * 
     * @param serviceAssignmentRuleId Service Assignment rule Id to be deleted.
     */
    public void deleteServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - enter; serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
        
        try {
            // Verify for valid service assignment rule id.
            if( String.isBlank( serviceAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Invalid request parameters. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            serviceAssignmentRuleManager.deleteServiceAssignmentRule( serviceAssignmentRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Failed to delete service assignment rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Failed to delete service assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - exit');
        }
    }

    /**
     * This method is used to retrieve all the entitlement rules with details.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public List<Adm.EntitlementRule> getAllEntitlementRulesWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() - enter' );
        
        List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        
        try {
            entitlementRuleList = entitlementRuleManager.getAllEntitlementRulesWithDetails();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRulesWithDetails() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() - exit; entitlementRuleList.size()= ' + entitlementRuleList.size() );
        }
        
        return entitlementRuleList;
    }

    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.EntitlementRule with created/updated record details.
     */
    public List<Adm.EntitlementRule> saveEntitlementRules( final List<Adm.EntitlementRule> requestEntitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRules() - enter; entitlementRule= ' + requestEntitlementRule );
        
        List<Adm.EntitlementRule> entitlementRule = new List<Adm.EntitlementRule>();
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( requestEntitlementRule == null || requestEntitlementRule.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveEntitlementRules() : Invalid request parameters. requestEntitlementRule= ' + requestEntitlementRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRule = entitlementRuleManager.saveEntitlementRules( requestEntitlementRule );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRules() : Failed to save Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRules() : Failed to save Entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementRules() - exit; entitlementRule= ' + entitlementRule );
        }
        
        return entitlementRule;
    }
    
}