/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete expressions.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       12 May 2020     Created.
 *****************************************************************************************************/
public class ADM_ExpressionLightningService {
    /**
     * This method retrieves all available Expressions 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Expression information.
     */
	@AuraEnabled
    public static Common.ServiceResponse getAllExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllExpressions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ExpressionMappingService().getAllExpressions();
            System.debug( LoggingLevel.INFO, 'getAllExpressions() : Retrieved expression list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllExpressions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves all available Expressions for an object
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Expression information for an object.
     */
	@AuraEnabled
    public static Common.ServiceResponse getExpressions( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.Expression expression = (Adm.Expression) JSON.deserializeStrict( requestJson, Adm.Expression.class );
            serviceResponse = new ADM_ExpressionMappingService().getExpressions(expression);
            System.debug( LoggingLevel.INFO, 'getExpressions() : Retrieved expression list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves all available expression detail for an expression
     * 
     * @return Returns instance of Common.ServiceResponse with list of all expression detail information for an expression.
     */
	@AuraEnabled
    public static Common.ServiceResponse getExpressionDetail( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.ExpressionDetail expressionDetail = (Adm.ExpressionDetail) JSON.deserializeStrict( requestJson, Adm.ExpressionDetail.class );
            serviceResponse = new ADM_ExpressionMappingService().getExpressionDetail(expressionDetail);
            System.debug( LoggingLevel.INFO, 'getExpressionDetail() : Retrieved expression details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionDetail() : Failed to retrieve expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves the available expression with detail for an expression
     * 
     * @return Returns instance of Common.ServiceResponse with expression information for an expression.
     */
	@AuraEnabled
    public static Common.ServiceResponse getExpressionWithDetails( final String expressionId) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ExpressionMappingService().getExpressionWithDetails(expressionId);
            System.debug( LoggingLevel.INFO, 'getExpressionWithDetails() : Retrieved expression details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionWithDetails() : Failed to retrieve expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves the available expression with detail for an expression for list of expression Ids
     * 
     * @return Returns instance of Common.ServiceResponse with expression information for an expression.
     */
	@AuraEnabled
    public static Common.ServiceResponse getExpressionsWithDetails( final List<String> expressionIds, final String objectAPIName) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ExpressionMappingService().getExpressionsWithDetails( expressionIds,objectAPIName );
            System.debug( LoggingLevel.INFO, 'getExpressionsWithDetails() : Retrieved expression details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Failed to retrieve expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves the minimal expression details required for runtime execution
     * 
     * @return Returns instance of Common.ServiceResponse with expression information for an expression.
     */
	@AuraEnabled
    public static Common.ServiceResponse getExpressionCriteriaDetails( final List<String> expressionIds) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ExpressionMappingService().getExpressionCriteriaDetails( expressionIds );
            System.debug( LoggingLevel.INFO, 'getExpressionCriteriaDetails() : Retrieved expression details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionCriteriaDetails() : Failed to retrieve expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the expression with detail
     * 
     * @return Returns instance of Common.ServiceResponse with expression information for an expression.
     */
	@AuraEnabled
    public static Common.ServiceResponse saveExpression( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'saveExpression() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.Expression expression = (Adm.Expression) JSON.deserializeStrict( requestJson, Adm.Expression.class );
            serviceResponse = new ADM_ExpressionMappingService().saveExpression(expression);
            System.debug( LoggingLevel.INFO, 'saveExpression() : Saved expression details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveExpression() : Failed to save expression detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveExpression() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the expression 
     * 
     * @return Returns instance of Common.ServiceResponse with response of delete expression.
     */
	@AuraEnabled
    public static Common.ServiceResponse deleteExpression( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteExpression() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.Expression expression = (Adm.Expression) JSON.deserializeStrict( requestJson, Adm.Expression.class );
            serviceResponse = new ADM_ExpressionMappingService().deleteExpression(expression);
            System.debug( LoggingLevel.INFO, 'deleteExpression() : Saved expression details' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to delete expression. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteExpression() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}