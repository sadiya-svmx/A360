/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete operstions 
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
public with sharing class ADM_ExpressionServiceImpl {
    
    private final ADM_ExpressionManager expressionManager = ADM_ExpressionManager.getInstance();
    
    /**
     * This method retrieves all expressions configured and populates 
     * information it to the expression wrapper.
     */
	public List<Adm.Expression> getAllExpressions() {
        System.debug( LoggingLevel.FINEST, 'getAllExpressions() - enter');
        
        List<Adm.Expression> expressionList = new List<Adm.Expression>();
        
        try {
            // Retrieve expression information from expression manager.
            expressionList = expressionManager.getAllExpressions();
            System.debug( LoggingLevel.INFO, 'getAllExpressions() : Retrieved all expression information. expressionList.size()= ' + expressionList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllExpressions() - exit; expressionList.size()= ' + expressionList.size() );
        }
        
        return expressionList;
    }
    
    /**
     * This method retrieves all expressions configured and populates 
     * information it to the expression wrapper.
     */
	public List<Adm.Expression> getAllRuleExpressions() {
        System.debug( LoggingLevel.FINEST, 'getAllRuleExpressions() - enter');
        
        List<Adm.Expression> expressionList = new List<Adm.Expression>();
        
        try {
            // Retrieve expression information from expression manager.
            expressionList = expressionManager.getAllRuleExpressions();
            System.debug( LoggingLevel.INFO, 'getAllRuleExpressions() : Retrieved all expression information. expressionList.size()= ' + expressionList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllRuleExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllRuleExpressions() - exit; expressionList.size()= ' + expressionList.size() );
        }
        
        return expressionList;
    }
    
    /**
     * This method retrieves all Visibility Criterias configured and populates 
     * information it to the expression wrapper.
     */
	public List<Adm.Expression> getAllVisibilityCriterias() {
        System.debug( LoggingLevel.FINEST, 'getAllVisibilityCriterias() - enter');
        
        List<Adm.Expression> expressionList = new List<Adm.Expression>();
        
        try {
            // Retrieve expression information from expression manager.
            expressionList = expressionManager.getAllVisibilityCriterias();
            System.debug( LoggingLevel.INFO, 'getAllVisibilityCriterias() : Retrieved all Visibility Criterias. expressionList.size()= ' + expressionList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllVisibilityCriterias() : Failed to retrieve Visibility Criterias. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllVisibilityCriterias() - exit; expressionList.size()= ' + expressionList.size() );
        }
        
        return expressionList;
    }
    
    /**
     * This method retrieves all Configuration Filters configured and populates 
     * information it to the expression wrapper.
     */
	public List<Adm.Expression> getAllConfigurationFilters() {
        System.debug( LoggingLevel.FINEST, 'getAllConfigurationFilters() - enter');
        
        List<Adm.Expression> expressionList = new List<Adm.Expression>();
        
        try {
            // Retrieve expression information from expression manager.
            expressionList = expressionManager.getAllConfigurationFilters();
            System.debug( LoggingLevel.INFO, 'getAllConfigurationFilters() : Retrieved all Configuration Filters. expressionList.size()= ' + expressionList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationFilters() : Failed to retrieve Configuration Filters. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllConfigurationFilters() - exit; expressionList.size()= ' + expressionList.size() );
        }
        
        return expressionList;
    }
    
    /**
     * This method retrieves all expressions configured for an object and populates 
     * information it to the expression wrapper.
     */
    public List<Adm.Expression> getExpressions(Adm.Expression expressionRequest) {
        System.debug( LoggingLevel.FINEST, 'getExpressions() - enter');
        
        List<Adm.Expression> expressionList = new List<Adm.Expression>();
        
        try {
              if( expressionRequest == null || String.isBlank( expressionRequest.objectAPIName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getExpressions() : Invalid arguments. expressionRequest = ' + expressionRequest);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expressionList = expressionManager.getExpressions(expressionRequest.objectAPIName);
            System.debug( LoggingLevel.INFO, 'getExpressions() : Retrieved all expression information. expressionList.size()= ' + expressionList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressions() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getExpressions() - exit; expressionList.size()= ' + expressionList.size() );
        }
        
        return expressionList;
    }
    
    /**
     * This method retrieves the expression detail configured for an expression and populates 
     * information it to the expression detail wrapper.
     */
    public List<Adm.ExpressionDetail> getExpressionDetail(Adm.ExpressionDetail expressionDetailRequest) {
        System.debug( LoggingLevel.FINEST, 'getExpressionDetail() - enter');
        
        List<Adm.ExpressionDetail> expressionDetails = new List<Adm.ExpressionDetail>();
        
        try {
              if( expressionDetailRequest == null || String.isBlank( expressionDetailRequest.expressionId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getExpressionDetail() : Invalid arguments. expressionDetailRequest = ' + expressionDetailRequest);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expressionDetails = expressionManager.getExpressionDetails(expressionDetailRequest.expressionId);
            System.debug( LoggingLevel.INFO, 'getExpressionDetail() : Retrieved all expression detail information. expressionDetails.size()= ' + expressionDetails.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionDetail() : Failed to retrieve expression details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getExpressionDetail() - exit; expressionDetails.size()= ' + expressionDetails.size() );
        }
        
        return expressionDetails;
    }

    /**
     * This method retrieves the expression with details configured for an expression and populates 
     * information it to the expression wrapper.
     */
    public Adm.Expression getExpressionWithDetails(String expressionId) {
        System.debug( LoggingLevel.FINEST, 'getExpressionWithDetails() - enter');
        
        Adm.Expression expression = new Adm.Expression();
        
        try {
              if( String.isBlank( expressionId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getExpressionWithDetails() : Invalid arguments. expressionId = ' + expressionId);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expression = expressionManager.getExpressionsWithDetails(expressionId);
            System.debug( LoggingLevel.INFO, 'getExpressionWithDetails() : Retrieved the expression with the detail information. expression = ' + expression );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionWithDetails() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getExpressionWithDetails() - exit; expressionDetails = ' + expression );
        }
        
        return expression;
    }

    /**
     * This method retrieves the expression with details configured for a list of expression Ids and populates 
     * information it to the expression wrapper.
     */
    public Map<Id,Adm.Expression> getExpressionsWithDetails(List<String> expressionIds, String objectAPIName) {
        System.debug( LoggingLevel.FINEST, 'getExpressionsWithDetails() - enter');
        
        Map<Id,Adm.Expression> expressionMap = new Map<Id,Adm.Expression>();
        
        try {
              if( expressionIds.isEmpty() && String.isBlank(objectAPIName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Invalid arguments. expressionIds = ' + expressionIds);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expressionMap = expressionManager.getExpressionsWithDetails( expressionIds,objectAPIName );
            System.debug( LoggingLevel.INFO, 'getExpressionsWithDetails() : Retrieved the expression with the detail information. expressionMap = ' + expressionMap );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getExpressionsWithDetails() - exit; expressionDetails = ' + expressionMap );
        }
        
        return expressionMap;
    }

    /**
     * This method retrieves the expression with details configured for a list of expression Ids and populates 
     * information it to the expression wrapper.
     */
    public List<Adm.Expression> getExpressionsByType(final String objectAPIName, final String expressionType) {
        System.debug( LoggingLevel.FINEST, 'getExpressionsByType() - enter');
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();    
        
        try {
            // Retrieve expression information from expression manager.
            expressions = expressionManager.getExpressionsByType( objectAPIName, expressionType );
            System.debug( LoggingLevel.INFO, 'getExpressionsByType() : Retrieved the expression with the detail information. expressions = ' + expressions );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsByType() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getExpressionsByType() - exit; expressionDetails = ' + expressions );
        }
        
        return expressions;
    }

    /**
     * This method retrieves the minimal expression details required for runtime execution 
     * for given list of expression ids
     * 
     */
    public Map<Id,Adm.Expression> getExpressionCriteriaDetails(List<String> expressionIds) {
        System.debug( LoggingLevel.FINEST, 'getExpressionCriteriaDetails() - enter');
        
        Map<Id,Adm.Expression> expressionMap = new Map<Id,Adm.Expression>();
        
        try {
              if( expressionIds.isEmpty() ) {
                
                System.debug( LoggingLevel.ERROR, 'getExpressionCriteriaDetails() : Invalid arguments. expressionIds = ' + expressionIds);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expressionMap = expressionManager.getExpressionCriteriaDetails( expressionIds );
            System.debug( LoggingLevel.INFO, 'getExpressionCriteriaDetails() : Retrieved the expression with the detail information. expressionMap = ' + expressionMap );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionCriteriaDetails() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getExpressionCriteriaDetails() - exit; expressionDetails = ' + expressionMap );
        }
        
        return expressionMap;
    }

    /**
     * This method saves the expression with details for an expression and populates 
     * information it to the expression wrapper.
     */
    public Adm.Expression saveExpression( Adm.Expression expression ) {
        System.debug( LoggingLevel.FINEST, 'saveExpression() - enter');
        
        Adm.Expression expressionRec = new Adm.Expression();
        
        try {
              if( expression == null || String.isBlank( expression.Name ) || String.isBlank( expression.objectAPIName ) ||
                  String.isBlank( expression.expressionType ) ) {
                
                System.debug( LoggingLevel.ERROR, 'saveExpression() : Invalid arguments. expressionRequest = ' + expression);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expressionRec = expressionManager.saveExpression(expression);
            System.debug( LoggingLevel.INFO, 'saveExpression() : Retrieved the expression with the detail information. expression = ' + expression );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveExpression() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveExpression() - exit; expressionDetails = ' + expression );
        }
        
        return expressionRec;
    }

    /**
     * This method is used to delete requested object mapping information.
     */
    public void deleteExpression( final Adm.Expression expression ) {
        
        System.debug( LoggingLevel.FINEST, 'deleteExpression() - enter; expression= ' + expression );
        
        try {
            
            // Verify for valid expression id to perform delete operation.
            if( expression == null || expression.id == null ) {
                
                System.debug( LoggingLevel.ERROR, 'deleteExpression() : Invalid request parameters. expression= ' + expression );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            expressionManager.deleteExpression( expression.id );
            System.debug( LoggingLevel.INFO, 'deleteExpression() : deleted Object Mapping; expression= ' + expression.id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to save Delete Expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to Delete Expression. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deleteExpression() - exit; expression= ' + expression );
        }
    }

    /**
     * This method retrieves all expression with details configured and populates 
     * information it to the expression wrapper.
     */
	public List<Adm.Expression> getAllExpressionsWithDetails() {
        System.debug( LoggingLevel.FINEST, 'getAllExpressionsWithDetails() - enter');
        
        List<Adm.Expression> expressionList = new List<Adm.Expression>();
        
        try {
            // Retrieve expression information from expression manager.
            expressionList = expressionManager.getAllExpressionsWithDetails();
            System.debug( LoggingLevel.INFO, 'getAllExpressionsWithDetails() : Retrieved all expression information. expressionList.size()= ' + expressionList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllExpressionsWithDetails() : Failed to retrieve expressions. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllExpressionsWithDetails() - exit; expressionList.size()= ' + expressionList.size() );
        }
        
        return expressionList;
    }

    /**
     * This method saves list of expressions with details and populates 
     * information it to the expression wrapper.
     */
    public List<Adm.Expression> saveExpressions( List<Adm.Expression> expressionList ) {
        System.debug( LoggingLevel.FINEST, 'saveExpressions() - enter');
        
        List<Adm.Expression> expressionRec = new List<Adm.Expression>();
        
        try {
              if( expressionList == null || expressionList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'saveExpressions() : Invalid arguments. expressionRequest = ' + expressionList);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            expressionRec = expressionManager.saveExpressions(expressionList);
            System.debug( LoggingLevel.INFO, 'saveExpressions() : Retrieved the expression with the detail information. expression = ' + expressionList );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveExpressions() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveExpressions() - exit; expressionDetails = ' + expressionRec );
        }
        
        return expressionRec;
    }
    
    /**
     * This method saves the expression with details for an expression and populates 
     * information it to the expression wrapper.
     */
    public Adm.ValidationResult validateExpression( Adm.Expression expression ) {
        System.debug( LoggingLevel.FINEST, 'validateExpression() - enter');
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
              if( expression == null || String.isBlank( expression.Name ) || String.isBlank( expression.objectAPIName ) ||
                  String.isBlank( expression.expressionType ) ) {
                
                System.debug( LoggingLevel.ERROR, 'validateExpression() : Invalid arguments. expressionRequest = ' + expression);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            // Retrieve expression information from expression manager.
            validationResult = expressionManager.validateExpression(expression);
            System.debug( LoggingLevel.INFO, 'validateExpression() : Retrieved the expression with the detail information. expression = ' + expression );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateExpression() : Failed to retrieve expression with details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateExpression() - exit; expressionDetails = ' + expression );
        }
        
        return validationResult;
    }
}