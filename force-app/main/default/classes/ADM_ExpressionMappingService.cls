/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to retrieve/save/delete operations 
 * on expressions.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       07 May 2020     Created.
 *              Sathish Kumar DB       02 Feb 2021     A360TOOL-327
 * A360TOOL-818 Ramachandra Mohan       28 Oct 2021     Service to validate expressions.
 *****************************************************************************************************/
public class ADM_ExpressionMappingService extends ADM_AbstractExpressionService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_ExpressionMappingService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_ExpressionMappingService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method retrieves all available Expressions 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Expression information.
     * @see ADM_ExpressionServiceImpl
     */
    override public Common.ServiceResponse getAllExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllExpressions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ExpressionServiceImpl().getAllExpressions();
            System.debug( LoggingLevel.INFO, 'getAllExpressions() : Retrieved object mapping list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllExpressions() : Failed to expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllExpressions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves all available Expressions 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Expression information.
     * @see ADM_ExpressionServiceImpl
     */
    override public Common.ServiceResponse getAllRuleExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllRuleExpressions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ExpressionServiceImpl().getAllRuleExpressions();
            System.debug( LoggingLevel.INFO, 'getAllRuleExpressions() : Retrieved expression list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllRuleExpressions() : Failed to expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllRuleExpressions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves all available Visibility Criterias 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Visibility Criterias.
     * @see ADM_ExpressionServiceImpl
     */
    override public Common.ServiceResponse getAllVisibilityCriterias() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllVisibilityCriterias() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ExpressionServiceImpl().getAllVisibilityCriterias();
            System.debug( LoggingLevel.INFO, 'getAllVisibilityCriterias() : Retrieved Visibility Criterias' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllVisibilityCriterias() : Failed to retrieve Visibility Criterias. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllVisibilityCriterias() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves all available Configuration Filters 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Configuration Filters.
     * @see ADM_ExpressionServiceImpl
     */
    override public Common.ServiceResponse getAllConfigurationFilters() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ExpressionServiceImpl().getAllConfigurationFilters();
            System.debug( LoggingLevel.INFO, 'getAllConfigurationFilters() : Retrieved Configuration Filters' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationFilters() : Failed to retrieve Configuration Filters. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve expression for requested object.
     * 
     * @param expression Instance of Adm.Expression with expression object name for which 
     *             expression information to be retrieved.
     * @return Returns   instance of Common.ServiceResponse with list of expression information 
     * @see ADM_ExpressionServiceImpl
     * 
   * @example getExpressions({objectName:'Account'});
     */
    
    override public Common.ServiceResponse getExpressions( final Adm.Expression expression ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().getExpressions( expression );
            System.debug( LoggingLevel.INFO, 'getExpressions() : Retrieved expressions successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve expression detail for given expression.
     * 
     * @param expression Instance of Adm.ExpressionDetail with expression Id for which 
     *             expression detail information to be retrieved.
     * @return Returns   instance of Common.ServiceResponse with list of expression information 
     * @see ADM_ExpressionServiceImpl
     * 
   * @example getExpressionDetail({expressionId:'15JKIFGHTNL90123'});
     */
    
    override public Common.ServiceResponse getExpressionDetail( final Adm.ExpressionDetail expressionDetail ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().getExpressionDetail( expressionDetail );
            System.debug( LoggingLevel.INFO, 'getExpressionDetail() : Retrieved expressions successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionDetail() : Failed to retrieve expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionDetail() : Failed to retrieve expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve expression detail for given expression.
     * 
     * @param expressionDetail Instance of Adm.ExpressionDetail with expression Id for which 
     *             expression detail information to be retrieved.
     * @return Returns   instance of Common.ServiceResponse with expression information 
     * @see ADM_ExpressionServiceImpl
     * 
   * @example getExpressionWithDetails({expressionId:'15JKIFGHTNL90123'});
     */
    
    override public Common.ServiceResponse getExpressionWithDetails( final String expressionId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().getExpressionWithDetails( expressionId );
            System.debug( LoggingLevel.INFO, 'getExpressionWithDetails() : Retrieved expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionWithDetails() : Failed to expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve expression detail for given list of expression Ids.
     * 
     * @param expressionIds List of expression Ids for which 
     *             expression detail information to be retrieved.
     * @return Returns   instance of Common.ServiceResponse with expression information 
     * 
   * @example getExpressionsWithDetails({expressionIds:'15JKIFGHTNL90123','15JKIFGHTNL90124'});
     */
    
    public Common.ServiceResponse getExpressionsWithDetails( final List<String> expressionIds, final String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().getExpressionsWithDetails( expressionIds,objectAPIName );
            System.debug( LoggingLevel.INFO, 'getExpressionsWithDetails() : Retrieved expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Failed to expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves the minimal expression details required for runtime execution 
     * for given list of expression ids
     * 
     * @param expressionIds List of expression Ids for which 
     *             expression detail information to be retrieved.
     * @return Returns   instance of Common.ServiceResponse with expression information 
     * 
     * @example getExpressionCriteriaDetails({expressionIds:'15JKIFGHTNL90123','15JKIFGHTNL90124'});
     */
    
    public Common.ServiceResponse getExpressionCriteriaDetails( final List<String> expressionIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().getExpressionCriteriaDetails( expressionIds );
            System.debug( LoggingLevel.INFO, 'getExpressionCriteriaDetails() : Retrieved expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionCriteriaDetails() : Failed to expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all the expressions for a requested object and expression type
     * @param objectAPIName API name of the object for which expressions to be retrieved.
     * @param expressionType Type of exression to be retrieved
     * @return Returns  instance of Common.ServiceResponse with expression information 
     * 
     * @example getExpressionsByType('Account', 'Visibity-Criteria-Expressions');
     */
    
    override public Common.ServiceResponse getExpressionsByType( final String objectAPIName, final String expressionType ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionsByType() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().getExpressionsByType( objectAPIName,  expressionType);
            System.debug( LoggingLevel.INFO, 'getExpressionsByType() : Retrieved expressions successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsByType() : Failed to expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsByType() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve expression detail for given expression.
     * 
     * @param expression Instance of Adm.expression for which 
     *             expression detail information will be saved.
     * @return Returns   instance of Common.ServiceResponse with expression information 
     * @see ADM_ExpressionServiceImpl
     * 
   * @example saveExpression(expression Information);
     */
    
    override public Common.ServiceResponse saveExpression( final Adm.Expression expression ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveExpression() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().saveExpression( expression );
            System.debug( LoggingLevel.INFO, 'saveExpression() : Saved expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveExpression() : Failed to save expression. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveExpression() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve expression detail for given expression.
     * 
     * @param expression Instance of Adm.expression for which 
     *             expression will be deleted.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_ExpressionServiceImpl
     * 
   * @example deleteExpression(expression Information);
     */
    
    override public Common.ServiceResponse deleteExpression( final Adm.Expression expression ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteExpression() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_ExpressionServiceImpl().deleteExpression( expression );
            System.debug( LoggingLevel.INFO, 'deleteExpression() : Deleted expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to delete expression. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteExpression() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all available Expression with details 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Expression information.
     * @see ADM_ExpressionServiceImpl
     */
    override public Common.ServiceResponse getAllExpressionsWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllExpressionsWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ExpressionServiceImpl().getAllExpressionsWithDetails();
            System.debug( LoggingLevel.INFO, 'getAllExpressionsWithDetails() : Retrieved object mapping list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllExpressionsWithDetails() : Failed to expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllExpressionsWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save list of expressions in org.
     * 
     * @param expression Instance of Adm.expression for which 
     *             expression detail information will be saved.
     * @return Returns   instance of Common.ServiceResponse with expression information 
     * @see ADM_ExpressionServiceImpl
     * 
   * @example saveExpression(expression Information);
     */
    
    override public Common.ServiceResponse saveExpressions( final List<Adm.Expression> expressions ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveExpressions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().saveExpressions( expressions );
            System.debug( LoggingLevel.INFO, 'saveExpressions() : Saved expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveExpressions() : Failed to save expression. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveExpressions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to validate expression against the Org.
     * 
     * @param expression Instance of Adm.expression for which detail to be validated.
     * @return Returns   instance of Common.ServiceResponse with validation details. 
     * @see ADM_ExpressionServiceImpl
     * 
     * @example validateExpression(expression Information);
     */
    
    override public Common.ServiceResponse validateExpression( final Adm.Expression expression ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateExpression() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ExpressionServiceImpl().validateExpression( expression );
            System.debug( LoggingLevel.INFO, 'validateExpression() : Saved expression successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateExpression() : Failed to validate expression. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateExpression() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}