/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for object mapping service implementation.
 * Also provides implementation for invokeMethod which maps to the requested object mapping service implementation. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal        3 Sep 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 * A360TOOL-818 Ramachandra Mohan       28 Oct 2021     Service to validate expressions.
 *****************************************************************************************************/
public abstract class ADM_AbstractExpressionService extends COMM_SvmxRestBase {
    
    public ADM_AbstractExpressionService(){
    }
    
    protected ADM_AbstractExpressionService(RestRequest req, RestResponse res) {
        super(req, res, 'expression');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getAllExpressions' {
                    response = getAllExpressions();
                }
                when 'getAllRuleExpressions' {
                    response = getAllRuleExpressions();
                }
                when 'getAllVisibilityCriterias' {
                    response = getAllVisibilityCriterias();
                }
                when 'getAllConfigurationFilters' {
                    response = getAllConfigurationFilters();
                }
                when 'getExpressions' {
                    Adm.Expression expression = new Adm.Expression();
                    expression.objectAPIName = request.params.get('objectName');              
                    response = getExpressions( expression );
                }
                when 'getExpressionDetail' {
                    Adm.ExpressionDetail expressionDetail = new Adm.ExpressionDetail();
                    expressionDetail.expressionId = recordId;              
                    response = getExpressionDetail( expressionDetail );
                }
                when 'getExpressionWithDetails' {
                    response = getExpressionWithDetails( recordId );
                }
                when 'saveExpression' {                
                    response = saveExpression( (Adm.Expression) deserializeRequestTo( Adm.Expression.class ) );
                }
                when 'validateExpression' {                
                    response = validateExpression( (Adm.Expression) deserializeRequestTo( Adm.Expression.class ) );
                }
                when 'deleteExpression' {  
                    Adm.Expression expression = new Adm.Expression();
                    expression.id = recordId;              
                    response = deleteExpression( expression );
                }
                when 'getAllExpressionsWithDetails' {
                    response = getAllExpressionsWithDetails();
                }
                when 'saveExpressions' {
                    response = saveExpressions((List<Adm.Expression>) deserializeRequestTo( List<Adm.Expression>.class ));
                }
                when 'getExpressionsByType' {
                    String objectAPIName = request.params.get('objectName');  
                    String expressionType = request.params.get('expressionType');  
                    response = getExpressionsByType(objectAPIName, expressionType);
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }
    
    /**
     * This method is used to retrieve all expressions from the Org.
     * 
     * @return Returns list of all expressions.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getAllExpressions/
     */
    public abstract Common.ServiceResponse getAllExpressions();
    
    /**
     * This method is used to retrieve all expressions from the Org.
     * 
     * @return Returns list of all expressions.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getAllRuleExpressions/
     */
    public abstract Common.ServiceResponse getAllRuleExpressions();
    
    /**
     * This method is used to retrieve all Visibility Criterias from the Org.
     * 
     * @return Returns list of all Visibility Criterias.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getAllVisibilityCriterias/
     */
    public abstract Common.ServiceResponse getAllVisibilityCriterias();
    
    /**
     * This method is used to retrieve all Configuration Filters from the Org.
     * 
     * @return Returns list of all Configuration Filters.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getAllConfigurationFilters/
     */
    public abstract Common.ServiceResponse getAllConfigurationFilters();
    
    /**
     * This method is used to retrieve all expressions from the Org for the given request with object name.
     * 
     * @return Returns list of expressions for the provided request.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getExpressions/
     */
    public abstract Common.ServiceResponse getExpressions( final Adm.Expression expression );

    /**
     * This method is used to get the expression detail in the Org for the given request.
     * 
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getExpressionDetail/
     */
    public abstract Common.ServiceResponse getExpressionDetail( final Adm.ExpressionDetail expressionDetail );

    /**
     * This method is used to get the expression detail with rules in the Org for the given request.
     * 
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getExpressionWithDetails/
     */
    public abstract Common.ServiceResponse getExpressionWithDetails( final String expressionId );

    /**
     * This method is used to save the expression in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/expression/v1/saveExpression/
     */
    public abstract Common.ServiceResponse saveExpression( final Adm.Expression expression );

    /**
     * This method is used to deletes the expression in the Org for the given request.
     * 
     * 
     * @example DELETE /services/apexrest/SVMXA360/admin/expression/v1/deleteExpression/
     */
    public abstract Common.ServiceResponse deleteExpression( final Adm.Expression expression );

    /**
     * This method is used to retrieve all expression with details from the Org.
     * 
     * @return Returns list of all expressions.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/expression/v1/getAllExpressionsWithDetails/
     */
    public abstract Common.ServiceResponse getAllExpressionsWithDetails();

    /**
     * This method is used to save list of expressions in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/expression/v1/saveExpressions/
     */
    public abstract Common.ServiceResponse saveExpressions( final List<Adm.Expression> expressions );

    /**
     * This method is used to save list of expressions in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/expression/v1/getExpressionsByType/
     */
    public abstract Common.ServiceResponse getExpressionsByType( final String objectAPIName, final String expressionType );
    
    /**
     * This method is used to validate the expression in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/expression/v1/validateExpression/
     */
    public abstract Common.ServiceResponse validateExpression( final Adm.Expression expression );
}