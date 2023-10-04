/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to retrieve/save/delete operations 
 * on technical attribute match rule.
 *
 * @author Ramachandra Mohan
 * @version 7.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       05 Sep 2022     Created.
 *****************************************************************************************************/
public class ADM_TechnicalAttributeService extends ADM_AbstractTechnicalAttributeService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_TechnicalAttributeService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_TechnicalAttributeService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method retrieves all available technical attribute match rules 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all technical attribute match rules information.
     */
    override public Common.ServiceResponse getAllTechnicalAttributeMatchRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeMatchRules() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().getAllTechnicalAttributeMatchRules();
            System.debug( LoggingLevel.INFO, 'getAllTechnicalAttributeMatchRules() : Retrieved Technical attribute match rules.' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTechnicalAttributeMatchRules() : Failed to retrieve technical attribute match rules. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeMatchRules() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse getTechnicalAttributeMatchRuleDetails( final String recordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeMatchRuleDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateRuleDetail( recordId );
            System.debug( LoggingLevel.INFO, 'getTechnicalAttributeMatchRuleDetails() : Retrieved technical attribute match rule detail successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeMatchRuleDetails() : Failed to retrieve technical attribute match rule detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeMatchRuleDetails() : Failed to retrieve technical attribute match rule detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeMatchRuleDetail() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse saveTechnicalAttributeMatchRule( final Adm.TechnicalAttributeMatchRule technicalAttributeMatchRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeMatchRule() - enter; technicalAttributeMatchRule= ' + technicalAttributeMatchRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateRule( technicalAttributeMatchRule );
            System.debug( LoggingLevel.INFO, 'saveTechnicalAttributeMatchRule() : Saved technical attribute match rule successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeMatchRule() : Failed to save technical attribute match rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeMatchRule() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to validate technical attribute match rule against the Org.
     * 
     * @param technicalAttributeMatchRule Instance of Adm.TechnicalAttributeMatchRule for which detail to be validated.
     * @return Returns   instance of Common.ServiceResponse with validation details. 
     * 
     */
    
    override public Common.ServiceResponse validateTechnicalAttributeMatchRule( final Adm.TechnicalAttributeMatchRule technicalAttributeMatchRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateTechnicalAttributeMatchRule() - enter; technicalAttributeMatchRule=' + technicalAttributeMatchRule );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_TechnicalAttributeManager.getInstance().validateTechnicalAttributeMatchRule( technicalAttributeMatchRule );
            System.debug( LoggingLevel.INFO, 'validateTechnicalAttributeMatchRule() : Validated technical attribute match rule successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTechnicalAttributeMatchRule() : Failed to validate technical attribute match rule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateTechnicalAttributeMatchRule() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}