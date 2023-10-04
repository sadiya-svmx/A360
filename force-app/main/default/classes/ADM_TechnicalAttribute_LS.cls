/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/edit/save/delete Match Rules.
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Mahima Tarika      30 July 2022      Created.
 *****************************************************************************************************/
public with sharing class ADM_TechnicalAttribute_LS {

    /**
     * This method retrieves all available Match Rules
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Match Rules.
     */
    @AuraEnabled
    public static Common.ServiceResponse  getAllMatchRules () {
        System.debug( LoggingLevel.DEBUG, 'getAllMatchRules() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().getAllTechnicalAttributeMatchRules();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllMatchRules() : Failed to get Match rules. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllMatchRules() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method updates the sequence of master Match Rules or the execution setting
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Match Rules.
     */
    @AuraEnabled
    public static Common.ServiceResponse  saveTemplateRulesSequence (final string jsonRequest) {
        System.debug( LoggingLevel.DEBUG, 'saveTemplateRulesSequence() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            list<Adm.TechnicalAttributeMatchRule> pageData = (list<Adm.TechnicalAttributeMatchRule>)JSON.deserializeStrict( jsonRequest, list<Adm.TechnicalAttributeMatchRule>.class );
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().saveTemplateRulesSequence(pageData);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTemplateRulesSequence() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTemplateRulesSequence() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse  deleteMatchRuleRecord (final string matchRuleId) {
        System.debug( LoggingLevel.DEBUG, 'saveMatchRuleSequenceSettings() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            ADM_TechnicalAttributeManager.getInstance().deleteMatchRuleRecord(matchRuleId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteMatchRuleRecord() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteMatchRuleRecord() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

   @AuraEnabled
    public static Common.ServiceResponse  getTechnicalAttributeTemplateRuleDetail (final string matchRuleId) {
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateRuleDetail() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateRuleDetail(matchRuleId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateRuleDetail() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getMatchRuleDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method updates the sequence of master Match Rules or the execution setting
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Match Rules.
     */
    @AuraEnabled
    public static Common.ServiceResponse  saveTechnicalAttributeTemplateRule (final string jsonRequest) {
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateRule() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.TechnicalAttributeMatchRule pageData = (Adm.TechnicalAttributeMatchRule)JSON.deserializeStrict( jsonRequest, Adm.TechnicalAttributeMatchRule.class );
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateRule(pageData);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateRule() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateRule() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }


}