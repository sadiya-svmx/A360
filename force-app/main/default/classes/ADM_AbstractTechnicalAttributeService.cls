/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for technical attribute service implementation. 
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
public abstract class ADM_AbstractTechnicalAttributeService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public ADM_AbstractTechnicalAttributeService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected ADM_AbstractTechnicalAttributeService( RestRequest request, RestResponse response ) {
        super( request, response, 'technicalAttribute' );    
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
                
                when 'getAllTechnicalAttributeMatchRules' {
                    serviceResponse = getAllTechnicalAttributeMatchRules();
                }

                when 'getTechnicalAttributeMatchRuleDetails' {
                    serviceResponse = getTechnicalAttributeMatchRuleDetails(recordId);
                }
                
                when 'saveTechnicalAttributeMatchRule' {
                    serviceResponse = saveTechnicalAttributeMatchRule( (Adm.TechnicalAttributeMatchRule) deserializeRequestTo( Adm.TechnicalAttributeMatchRule.class ) );
                }
                
                when 'validateTechnicalAttributeMatchRule' {
                    serviceResponse = validateTechnicalAttributeMatchRule( (Adm.TechnicalAttributeMatchRule) deserializeRequestTo( Adm.TechnicalAttributeMatchRule.class ) );
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

    public abstract Common.ServiceResponse getAllTechnicalAttributeMatchRules();
    
    public abstract Common.ServiceResponse getTechnicalAttributeMatchRuleDetails( final String recordId );
    
    public abstract Common.ServiceResponse saveTechnicalAttributeMatchRule( final Adm.TechnicalAttributeMatchRule technicalAttributeMatchRule );
    
    public abstract Common.ServiceResponse validateTechnicalAttributeMatchRule(final Adm.TechnicalAttributeMatchRule technicalAttributeMatchRule );
}