/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This handler class contains utility methods for expression.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       25 May 2020     Created.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class COMM_ExpressionUtils {
    /***
     * Private static string constant to hold comma.
     */
    private static final String comma 	= ',';
    private static final String TILDE = '~';

    /**
     * Private static variable to hold instance of this class.
     */
    private static COMM_ExpressionUtils instance;

    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private CONF_ObjectMappingHandler mappingHandler = new CONF_ObjectMappingHandler();

    /**
     * Public string to store the criteria of Expression 
     */
    public string queryClause = '';
    public string expressionClause = '';
    public Boolean savingExpression = false;

    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private COMM_ExpressionUtils(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static COMM_ExpressionUtils getInstance() {
        
        System.debug( LoggingLevel.FINE, 'COMM_ExpressionUtils.getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new COMM_ExpressionUtils();
                System.debug( LoggingLevel.INFO, 'COMM_ExpressionUtils.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'COMM_ExpressionUtils.getInstance() - exit' );
        }
        
        return instance;
    }

    /**
    * This method is to return the query criteria
    */
    public String buildCriteria(Adm.Expression expression) {
        try {
            if( expression == null ) {
                
            	System.debug( LoggingLevel.ERROR, 'buildCriteria() : Invalid arguments. expression= ' + expression );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            return buildCriteria(expression, null);
        }catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'buildCriteria() : Failed to build Criteria. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildCriteria() - exit; expression = ' + expression );
        }
    }

    /**
    * This method is to return the query criteria
    */
    public String buildCriteria(Adm.Expression expression, SObject literalSObject) {
        String queryWhereClause;
        String advancedCriteriaClause = '';
        try {
            Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
            Set<String> userReferenceFields =  new Set<String>();
            Set<String> headerReferenceFields = new Set<String>();
            SObject literalObject;
            SObject userObject;

            if(String.isNotBlank(expression.advancedExpression)) {
                advancedCriteriaClause = buildAdvancedCriteria(string.escapeSingleQuotes(expression.advancedExpression.toUpperCase())); 
                queryWhereClause = advancedCriteriaClause;
                queryClause = advancedCriteriaClause;
            }

            // Gather reference fields for User and Current Record Header for pre-querying
            for (Integer i = 0; i < expression.expressionDetailList.size(); i++) {
                Adm.ExpressionDetail expressionDetail = expression.expressionDetailList[i];
                    if (expressionDetail.sourceObjectName == 'User') {
                        userReferenceFields.add(expressionDetail.fieldAPIName);
                    }
                    if (expressionDetail.sourceObjectName == 'User' && expressionDetail.fieldType == 'REFERENCE') {
                        userReferenceFields.add(expressionDetail.relationshipName + '.' + expressionDetail.relationshipFieldAPIName);
                    }
                if (expression.expressionDetailList[i].operandType.equalsIgnoreCase('Function')) {
                    String expressionOperand = String.escapeSingleQuotes(expressionDetail.operand).trim();
                    switch on expressionOperand {
                        when 'User' {
                            userReferenceFields.add(expressionDetail.literalParameterAPIName);
                        }

                        when 'Current Record Header' {
                            if (expressionDetail.literalParameterAPIName.indexOf('.') > -1) {
                                headerReferenceFields.add(expressionDetail.literalParameterAPIName);
                            }
                        }
                    }
                }
            }  
            if (!userReferenceFields.isEmpty()) {
                userObject = mappingHandler.getCurrentUserRecord(userReferenceFields);
            }

            if (literalSObject != null && !headerReferenceFields.isEmpty()) {
                literalSObject = mappingHandler.getRecordWithMultiReferenceFields(literalSObject, headerReferenceFields);
            }

            for( integer i = 0; i < expression.expressionDetailList.size(); i++ ) {
                String objectAPIName = '';
                String lastLevelFieldAPIName = '';
                String fieldAPIName = '';
                String operandType = expression.expressionDetailList[i].operandType;
                String value = expression.expressionDetailList[i].operand == null ? expression.expressionDetailList[i].operand : string.escapeSingleQuotes(expression.expressionDetailList[i].operand).trim();
                if (expression.expressionDetailList[i].sourceObjectName == 'User' && expression.expressionDetailList[i].fieldType == 'REFERENCE') {
                    fieldAPIName = expression.expressionDetailList[i].fieldAPIName;
                }
                if(String.isNotBlank(expression.expressionDetailList[i].relatedObjectDetails)) {
                    if(expression.expressionDetailList[i].relatedObjectDetails.contains('.')) {
                    	objectAPIName = expression.expressionDetailList[i].relatedObjectDetails.substringAfterLast('.');
                    }
                    else {
                    	objectAPIName = expression.expressionDetailList[i].relatedObjectDetails;  
                    }
                    lastLevelFieldAPIName = expression.expressionDetailList[i].fieldAPIName.substringAfterLast('.');
                    if( !sObjectResultMap.containsKey(objectAPIName) ) {
                    	sObjectResultMap.put(objectAPIName, COMM_DescribeManager.getInstance().getFieldDescribeResults( objectAPIName ));
                    }                         
                } else {
                    if (expression.expressionDetailList[i].sourceObjectName == 'User') {
                        objectAPIName = 'User';
                    } else {
                        objectAPIName = expression.objectAPIName;
                    }
                    if( !sObjectResultMap.containsKey(objectAPIName) ) {
                    	sObjectResultMap.put(objectAPIName, COMM_DescribeManager.getInstance().getFieldDescribeResults( objectAPIName ));
                    }
                    lastLevelFieldAPIName = expression.expressionDetailList[i].fieldAPIName;
                }
                if(!sObjectResultMap.get(objectAPIName).ContainsKey(lastLevelFieldAPIName) && (String.isNotBlank(objectAPIName) && !sObjectResultMap.get(objectAPIName).ContainsKey(lastLevelFieldAPIName))){
                    System.debug( LoggingLevel.ERROR, 'buildCriteria() : Invalid field on expression Rule' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                }
                Schema.DescribeFieldResult fieldDescribeResult = sObjectResultMap.get(objectAPIName).get(lastLevelFieldAPIName);
                if (operandType.equalsIgnoreCase('Function') && value == 'User') {
                    literalObject = userObject;
                } else if (operandType.equalsIgnoreCase('Function') && value == 'Current Record Header') {
                    literalObject = literalSObject;
                }
                Adm.ExpressionDetail expressionDetail = expression.expressionDetailList[i];
                String expressionRuleClause = buildQueryClause( expression.expressionDetailList[i],fieldDescribeResult,literalObject);
                if (expression.expressionDetailList[i].sourceObjectName == 'User' && !savingExpression) {
                    ADM_ExpressionHandler expressionHandler= new ADM_ExpressionHandler();

                    expression.expressionDetailList[i].fieldAPIName = expression.expressionDetailList[i].fieldType == 'REFERENCE' ? fieldAPIName : expression.expressionDetailList[i].fieldAPIName;
                    String parsedExpression = expressionHandler.applyCriteria( null,userObject,ADM_ExpressionManager.getInstance().createExpressionDetailRecord(expression.expressionDetailList[i]),fieldDescribeResult,literalObject );
                    //creating dummy clause to make where clause queryeable when user literal is configured on LHS of expression detail.
                    if (parsedExpression == 'T') {
                        expressionRuleClause = 'CreatedById != null';
                    } else if (parsedExpression == 'F') {
                        expressionRuleClause = 'CreatedById = null';
                    }
                } else if (expression.expressionDetailList[i].sourceObjectName == 'User' && savingExpression) {
                    //creating dummy clause to make where clause queryeable when user literal is configured on LHS of expression detail on saving expression.
                    expressionRuleClause = 'CreatedById != null';
                }
                if(String.isNotBlank(advancedCriteriaClause)) {
                    queryWhereClause = queryWhereClause.replace( TILDE+String.valueof(expression.expressionDetailList[i].sequence)+TILDE, expressionRuleClause); 
                    queryClause =  queryClause.replace(TILDE+String.valueof(expression.expressionDetailList[i].sequence)+TILDE, expressionClause);
                } else {
                    if(i==0) { 
                        queryWhereClause = expressionRuleClause;
                        queryClause = expressionClause;
                    } else {
                        queryWhereClause = queryWhereClause + ' AND ' + expressionRuleClause;
                        queryClause = queryClause + ' AND ' + expressionClause;
                    }
                }
            }
            verifyQueryClause ( queryWhereClause,expression.objectAPIName );
            return queryWhereClause;
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'buildCriteria() : Failed to build Criteria. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildCriteria() - exit; expression = ' + expression );
        }  
        
    }

    /**
    * This method is to format advanced criteria
    */
    public void verifyQueryClause( String queryWhereClause, String objectName ) {
        try {
            System.debug( LoggingLevel.DEBUG, 'queryWhereClause :' + queryWhereClause);
            if( String.isNotBlank(queryWhereClause) && String.isNotBlank(objectName) ) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                SvmxDatabase.query(Database.query('Select Id from '+ objectName +' where ' + queryWhereClause + ' limit 0'));
            }
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'verifyQueryClause() : Invalid Query Clause. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }

    /**
    * This method is to format advanced criteria
    */
    public String buildAdvancedCriteria( String advancedExpression ) {
        try {
            String advancedCriteria = '';
            for(String splitExp : advancedExpression.splitByCharacterTypeCamelCase()) {
                String valueAfterTrim = splitExp.trim();
                if(valueAfterTrim != NULL && valueAfterTrim.length() > 0) {
                    if(valueAfterTrim.isNumeric()) {
                        valueAfterTrim =  TILDE+valueAfterTrim+TILDE;
                    }
                    advancedCriteria += valueAfterTrim + ' ';
                }
            }
            return advancedCriteria;  
        }  catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'buildAdvancedCriteria() : Failed to build advanced Criteria. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildAdvancedCriteria() - exit; advancedExpression = ' + advancedExpression );
        }  
    }
    
    /**
    * This method is to build query clause
    */
    private String buildQueryClause( Adm.ExpressionDetail expressionRule, Schema.DescribeFieldResult fieldResult, SObject literalSObject ) {
        String value;
        try {
            String operator = string.escapeSingleQuotes(expressionRule.operator);
            if(!String.isBlank(expressionRule.operand)) {
                value = string.escapeSingleQuotes(expressionRule.operand).trim();
            }
            String field = string.escapeSingleQuotes(expressionRule.fieldAPIName);

            field = getFieldCriteria(expressionRule, field);

            if (operator.equalsIgnoreCase('isnull')) {
                expressionClause = field + ' = null';
                return field + ' = null';
            }
            if (operator.equalsIgnoreCase('isnotnull')) {
                expressionClause = field + ' != null';
                return field + ' != null';
            }

            return processOperators( expressionRule,fieldResult.getType(),literalSObject );
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'buildQueryClause() : Failed to build query Clause. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildQueryClause() - exit; expressionRule = ' + expressionRule );
        } 
        
    }

    /**
    * This method is evaluate different operators
    */
    private String processOperators( Adm.ExpressionDetail expressionRule, Schema.DisplayType fieldType, SObject literalSObject) {
        String queryClause;
        try {
            switch on expressionRule.operator.toLowerCase() {
                when 'eq','ne','in','notin' {
                    queryClause = evaluateEqualsInOperators( expressionRule,fieldType,literalSObject );
                }
                when 'gt','lt','ge','le' {
                    queryClause = evaluateGreaterLesserOperators( expressionRule,fieldType,literalSObject );
                }
                when 'starts','contains','notcontain' {
                    queryClause = evaluateStartContainOperators( expressionRule,fieldType,literalSObject );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'processOperators() : unsupported operator. operator= ' + expressionRule.operator );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            } 
            return queryClause;
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'processOperators() : Failed to process operators. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'processOperators() - exit; operator = ' + expressionRule.operator );
        } 
    }

    /**
    * This method is returns equals, not equals, In and Notin operators 
    */
    private String evaluateEqualsInOperators( Adm.ExpressionDetail expressionRule, Schema.DisplayType fieldType, SObject literalObject) {
        String clause;
        String value = string.escapeSingleQuotes(expressionRule.operand).trim();
        String operandValue = value;
        String field = expressionRule.fieldAPIName;
        String operandType = expressionRule.operandType;
        Boolean isDateFormateRequired = operandType.equalsIgnoreCase('value') || (operandType.equalsIgnoreCase('Function') && (value == 'Current Record Header' || value == 'User'));
        try {
            if(fieldType == Schema.DisplayType.REFERENCE && operandType.equalsIgnoreCase('value')) {
                field = expressionRule.relationshipName + '.' + expressionRule.relationshipFieldAPIName;
            }
            field = getFieldCriteria(expressionRule, field);
            if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.COMBOBOX ||
                fieldType == Schema.DisplayType.REFERENCE || fieldType == Schema.DisplayType.EMAIL ||
                fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST ||
                fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PHONE || 
                fieldType == Schema.DisplayType.URL) {
                String fieldValue = formatCommaSeperatedValues(value);
                clause = processStringOperators(fieldValue,expressionRule.operator,field,fieldType,literalObject,operandType,expressionRule.literalParameterAPIName);
            } else {
                if (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User')) {
                    value = null;
                    if ( expressionRule.literalParameterAPIName.contains('.') && literalObject != null) {
                        value = String.valueOf(mappingHandler.getValueOfMultiReference(literalObject, expressionRule.literalParameterAPIName));
                    } else if(literalObject != null){
                        value = String.valueOf(literalObject.get(expressionRule.literalParameterAPIName));
                    }
                    //setting dummy values in case of null for literal for dummy query validation.
                    if ( value == null && savingExpression ) {
                        value = getDummmyVauleForDatatype(fieldType);    
                    }
                    value = value == null ? value : string.escapeSingleQuotes(value).trim();
                }
                if( (fieldType == Schema.DisplayType.DATE || fieldType == Schema.DisplayType.DATETIME ) && value != null
                    && operandType.equalsIgnoreCase('Function')  && operandValue != 'Current Record Header' && operandValue != 'User') {
                        value = getSalesforceDateFunction(value);
                }
                if (fieldType == Schema.DisplayType.TIME && value != null && !value.endsWith('Z')) {
                    value = value + 'Z';
                }
                if(expressionRule.operator.equalsIgnoreCase('eq')) {
                    clause = field + ' = ' + value;
                    if(fieldType == Schema.DisplayType.DATE && isDateFormateRequired && value != null) {
                        clause = field + ' = ' +  String.Valueof(getFormattedDateValue(value)).removeEnd(' 00:00:00');
                    } else if(fieldType == Schema.DisplayType.DATETIME && isDateFormateRequired && value != null) {
                        clause = field + ' = ' +  getFormattedDateTimeValue(value);
                    } 
                }
                else if(expressionRule.operator.equalsIgnoreCase('ne')) {
                    clause = field + ' <> ' + value;
                    if(fieldType == Schema.DisplayType.DATE && isDateFormateRequired && value != null) {
                        clause = field + ' <> ' +  String.Valueof(getFormattedDateValue(value)).removeEnd(' 00:00:00');
                    } else if(fieldType == Schema.DisplayType.DATETIME && isDateFormateRequired && value != null) {
                        clause = field + ' <> ' +  getFormattedDateTimeValue(value);
                    }
                }
                if (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User')) { 
                    if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('eq')) {
                        expressionClause = field + ' = {$CRH.' + expressionRule.literalParameterAPIName + '}';     
                    } else if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('ne')) {
                        expressionClause = field + ' <> {$CRH.' + expressionRule.literalParameterAPIName + '}';     
                    } else if ( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('eq')) {
                        expressionClause = field + ' = {$User.' + expressionRule.literalParameterAPIName + '}';  
                    } else if ( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('ne')) {
                        expressionClause = field + ' <> {$User.' + expressionRule.literalParameterAPIName + '}';  
                    }
                } else {
                    expressionClause = clause;
                }
            }
            system.debug('Clause = '+clause);
            return clause;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'evaluateEqualsInOperators() : Failed to process equals operator. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateEqualsInOperators() - exit; operator = ' + expressionRule.operator );
        } 
    }

    /**
    * This method is returns process Greater and Lesser operators 
    */ 
    private String evaluateGreaterLesserOperators(Adm.ExpressionDetail expressionRule, Schema.DisplayType fieldType, SObject literalObject) {
        String clause;
        String value = string.escapeSingleQuotes(expressionRule.operand).trim();
        String operandValue = value;
        String field = expressionRule.fieldAPIName;
        String operandType = expressionRule.operandType;
        try {
            if(fieldType == Schema.DisplayType.REFERENCE && operandType.equalsIgnoreCase('value')) {
                field = expressionRule.relationshipName + '.' + expressionRule.relationshipFieldAPIName;
            }
            field = getFieldCriteria(expressionRule, field);
             
            Boolean isDateFormateRequired = operandType.equalsIgnoreCase('value') || (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User'));
            if (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User')) {
                value = null;
                if ( expressionRule.literalParameterAPIName.contains('.') && literalObject != null) {
                    value = String.valueOf(mappingHandler.getValueOfMultiReference(literalObject, expressionRule.literalParameterAPIName));
                } else if (literalObject != null){
                    value = String.valueOf(literalObject.get(expressionRule.literalParameterAPIName));
                }
                //setting dummy values in case of null for literal for dummy query validation.
                if ( value == null && savingExpression ) {
                    value = getDummmyVauleForDatatype(fieldType);    
                }
                value = value == null ? value : string.escapeSingleQuotes(value).trim();
            }
            if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.COMBOBOX ||
                fieldType == Schema.DisplayType.REFERENCE || fieldType == Schema.DisplayType.EMAIL ||
                fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST ||
                fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PHONE ||
                fieldType == Schema.DisplayType.URL) {
                value = value == null ? '\'\'' : '\'' + value.trim() + '\'';
            }
            if( (fieldType == Schema.DisplayType.DATE || fieldType == Schema.DisplayType.DATETIME && value != null) && 
                operandType.equalsIgnoreCase('Function') && operandValue != 'Current Record Header' && operandValue != 'User') {
                value = getSalesforceDateFunction(value);
            }
            if(fieldType == Schema.DisplayType.REFERENCE && operandType.equalsIgnoreCase('value')) {
                field = expressionRule.relationshipName + '.' + expressionRule.relationshipFieldAPIName;
            }
            if (fieldType == Schema.DisplayType.TIME && value != null && !value.endsWith('Z')) {
                value = value + 'Z';
            }
            switch on expressionRule.operator.ToUpperCase() {
                when 'GT' {
                    clause = field + ' > ' + value;
                    if(fieldType == Schema.DisplayType.DATE && isDateFormateRequired && value != null) {
                        clause = field + ' > ' +  String.Valueof(getFormattedDateValue(value)).removeEnd(' 00:00:00');
                    } else if(fieldType == Schema.DisplayType.DATETIME && isDateFormateRequired && value != null) {
                        clause = field + ' > ' +  getFormattedDateTimeValue(value);
                    } 
                }
                when 'LT' {
                    clause = field + ' < ' + value;
                    if(fieldType == Schema.DisplayType.DATE && isDateFormateRequired && value != null) {
                        clause = field + ' < ' +  String.Valueof(getFormattedDateValue(value)).removeEnd(' 00:00:00');
                    } else if(fieldType == Schema.DisplayType.DATETIME && isDateFormateRequired && value != null) {
                        clause = field + ' < ' +  getFormattedDateTimeValue(value);
                    }
                }
                when 'GE' {
                    clause = field + ' >= ' + value;
                    if(fieldType == Schema.DisplayType.DATE && isDateFormateRequired && value != null) {
                        clause = field + ' >= ' +  String.Valueof(getFormattedDateValue(value)).removeEnd(' 00:00:00');
                    } else if(fieldType == Schema.DisplayType.DATETIME && isDateFormateRequired && value != null) {
                        clause = field + ' >= ' +  getFormattedDateTimeValue(value);
                    } 
                }
                when 'LE' {
                    clause = field + ' <= ' + value;
                    if(fieldType == Schema.DisplayType.DATE && isDateFormateRequired && value != null) {
                        clause = field + ' <= ' +  String.Valueof(getFormattedDateValue(value)).removeEnd(' 00:00:00');
                    } else if(fieldType == Schema.DisplayType.DATETIME && isDateFormateRequired && value != null) {
                        clause = field + ' <= ' +  getFormattedDateTimeValue(value);
                    } 
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'evaluateGreaterLesserOperators() : unsupported operator. operator= ' + expressionRule.operator );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
            if (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User')) {
                if(value == null){
                    return field + ' != null ';
                }
                if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('GT')) {
                    expressionClause = field + ' > {$CRH.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('LT')) {
                    expressionClause = field + ' < {$CRH.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('GE')) {
                    expressionClause = field + ' >= {$CRH.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('LE')) {
                    expressionClause = field + ' <= {$CRH.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('GT')) {
                    expressionClause = field + ' > {$User.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('LT')) {
                    expressionClause = field + ' < {$User.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('GE')) {
                    expressionClause = field + ' >= {$User.' + expressionRule.literalParameterAPIName + '}';     
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('LE')) {
                    expressionClause = field + ' <= {$User.' + expressionRule.literalParameterAPIName + '}';     
                }
            } else {
                expressionClause = clause;
            }    
                
            return clause;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'evaluateGreaterLesserOperators() : Failed to process greater lesser operator. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateGreaterLesserOperators() - exit; operator = ' + expressionRule.operator );
        } 
    }

    /**
    * This method is returns process Start and Contain operators 
    */ 
    private String evaluateStartContainOperators(Adm.ExpressionDetail expressionRule, Schema.DisplayType fieldType, SObject literalObject) {
        String clause;
        String value = string.escapeSingleQuotes(expressionRule.operand).trim();
        String operandValue = value;
        String field = expressionRule.fieldAPIName;
        String operator = expressionRule.operator;
        String operandType = expressionRule.operandType;
        try {
            if (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User')) {
                value = null;
                if ( expressionRule.literalParameterAPIName.contains('.') && literalObject != null) {
                    value = String.valueOf(mappingHandler.getValueOfMultiReference(literalObject, expressionRule.literalParameterAPIName));
                } else if(literalObject != null){
                    value = String.valueOf(literalObject.get(expressionRule.literalParameterAPIName));
                }
                //setting dummy values in case of null for literal for dummy query validation.
                if ( value == null && savingExpression ) {
                    value = getDummmyVauleForDatatype(fieldType);    
                }
                value = value == null ? value : string.escapeSingleQuotes(value).trim();
            }
            if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.COMBOBOX ||
                fieldType == Schema.DisplayType.REFERENCE || fieldType == Schema.DisplayType.EMAIL ||
                fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST ||
                fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PHONE ||
                fieldType == Schema.DisplayType.URL) {
                if(fieldType == Schema.DisplayType.REFERENCE && operandType.equalsIgnoreCase('value')) {
                    field = expressionRule.relationshipName + '.' + expressionRule.relationshipFieldAPIName;
                }
                if(expressionRule.sourceObjectName == 'User') {
                    field = '{$User.' + field + '}';
                }
                if(operator.equalsIgnoreCase('starts')) {
                    clause = field + ' LIKE \'' + value + '%\'';
                }
                else if(operator.equalsIgnoreCase('contains')) {
                    clause = field + ' LIKE \'%' + value + '%\'';
                }
                else if(operator.equalsIgnoreCase('notcontain')) {
                    clause = ' (NOT(' + field + ' LIKE \'%' + value + '%\'))';
                }
            }
            if (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User')) {
                if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('starts')) { 
                    expressionClause = field + ' LIKE \'{$CRH.' + expressionRule.literalParameterAPIName + '}%\'';  
                } else if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('contains')) { 
                    expressionClause = field + ' LIKE \'%{$CRH.' + expressionRule.literalParameterAPIName + '}%\'';   
                } else if( operandValue == 'Current Record Header' && expressionRule.operator.equalsIgnoreCase('notcontain')) {  
                    expressionClause = ' (NOT(' + field + ' LIKE \'%{$CRH.' + expressionRule.literalParameterAPIName + '}%\'))';   
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('starts')) { 
                    expressionClause = field + ' LIKE \'{$User.' + expressionRule.literalParameterAPIName + '}%\'';  
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('contains')) { 
                    expressionClause = field + ' LIKE \'%{$User.' + expressionRule.literalParameterAPIName + '}%\'';   
                } else if( operandValue == 'User' && expressionRule.operator.equalsIgnoreCase('notcontain')) {  
                    expressionClause = ' (NOT(' + field + ' LIKE \'%{$User.' + expressionRule.literalParameterAPIName + '}%\'))';   
                }
            } else {
                expressionClause =  clause;
            }
            return clause;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'evaluateStartContainOperators() : Failed to process start contain operator. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateStartContainOperators() - exit; operator = ' + operator );
        } 
    }

    /**
    * This method is used to process different operators of the expression rule for a String related data type
    */ 
    private String processStringOperators( String fieldValue, String operator, String field, Schema.DisplayType fieldType, SObject literalObject, String operandType, String literalParameterAPIName ) {
        String parsedResult;
        String clause;
        String operandValue = fieldValue;
        try {
            if (operandType.equalsIgnoreCase('Function') && (operandValue.containsIgnoreCase('Current Record Header') || (operandValue.containsIgnoreCase('User')))) {
                fieldValue = null;
                if ( literalParameterAPIName.contains('.') && literalObject != null) {
                    fieldValue = String.valueOf(mappingHandler.getValueOfMultiReference(literalObject, literalParameterAPIName));
                } else if (literalObject != null){
                    fieldValue = String.valueOf(literalObject.get(literalParameterAPIName));
                }
                //setting dummy values in case of null for literal for dummy query validation.
                if ( fieldValue == null && savingExpression ) {
                    fieldValue = getDummmyVauleForDatatype(fieldType);    
                }
                fieldValue = fieldValue == null ? '\'\'' : '\'' + fieldValue.trim() + '\'';
            }
            if (operator.equalsIgnoreCase('IN') || (operator.equalsIgnoreCase('EQ') && fieldValue.contains(comma))) {
                if ( fieldType == Schema.DisplayType.MULTIPICKLIST ) {
                    clause = field + ' INCLUDES ('  + fieldValue  + ')';
                } else {
                    clause = field + ' IN ('  + fieldValue  + ')';
                }
            } else if (operator.equalsIgnoreCase('NOTIN') || (operator.equalsIgnoreCase('NE') && fieldValue.contains(comma))) {
                if( fieldType == Schema.DisplayType.MULTIPICKLIST ) {
                    clause = field + ' EXCLUDES ('  + fieldValue  + ')';
                } else {
                    clause = field + ' NOT IN ('  + fieldValue  + ')';
                }
            } else if (operator.equalsIgnoreCase('EQ')) {
                clause = field + ' = '  + fieldValue;
            } else if (operator.equalsIgnoreCase('NE')) {
                clause = field + ' <> '  + fieldValue;
            }
            if (operandType.equalsIgnoreCase('Function') && (operandValue.containsIgnoreCase('Current Record Header') || (operandValue.containsIgnoreCase('User')))) { 
                if (operandValue.containsIgnoreCase('Current Record Header')) {
                    if (operator.equalsIgnoreCase('IN') || (operator.equalsIgnoreCase('EQ') && fieldValue.contains(comma))) {
                        if ( fieldType == Schema.DisplayType.MULTIPICKLIST ) {
                            expressionClause = field + ' INCLUDES ({$CRH.'  + literalParameterAPIName  + '})';
                        } else {
                            expressionClause = field + ' IN ({$CRH.'  + literalParameterAPIName  + '})';
                        }
                    } else if (operator.equalsIgnoreCase('NOTIN') || (operator.equalsIgnoreCase('NE') && fieldValue.contains(comma))) {
                        if( fieldType == Schema.DisplayType.MULTIPICKLIST ) {
                            expressionClause = field + ' EXCLUDES ({$CRH.'  + literalParameterAPIName  + '})';
                        } else {
                            expressionClause = field + ' NOT IN ({$CRH.'  + literalParameterAPIName  + '})';
                        }
                    } else if (operator.equalsIgnoreCase('EQ')) {
                        expressionClause = field + ' = {$CRH.'  + literalParameterAPIName + '}';
                    } else if (operator.equalsIgnoreCase('NE')) {
                        expressionClause = field + ' <> {$CRH.'  + literalParameterAPIName + '}';
                    }
                } else if (operandValue.containsIgnoreCase('User')) {
                    if (operator.equalsIgnoreCase('IN') || (operator.equalsIgnoreCase('EQ') && fieldValue.contains(comma))) {
                        if ( fieldType == Schema.DisplayType.MULTIPICKLIST ) {
                            expressionClause = field + ' INCLUDES ({$User.'  + literalParameterAPIName  + '})';
                        } else {
                            expressionClause = field + ' IN ({$User.'  + literalParameterAPIName  + '})';
                        }
                    } else if (operator.equalsIgnoreCase('NOTIN') || (operator.equalsIgnoreCase('NE') && fieldValue.contains(comma))) {
                        if( fieldType == Schema.DisplayType.MULTIPICKLIST ) {
                            expressionClause = field + ' EXCLUDES ({$User.'  + literalParameterAPIName  + '})';
                        } else {
                            expressionClause = field + ' NOT IN ({$User.'  + literalParameterAPIName  + '})';
                        }
                    } else if (operator.equalsIgnoreCase('EQ')) {
                        expressionClause = field + ' = {$User.'  + literalParameterAPIName + '}';
                    } else if (operator.equalsIgnoreCase('NE')) {
                        expressionClause = field + ' <> {$User.'  + literalParameterAPIName + '}';
                    }
                }
            } else {
                expressionClause = clause;
            }
            return clause;
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'processStringOperators() : Failed to process the operator. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'processStringOperators() - exit; fieldValue = ' + fieldValue );
        } 
    }

    /**
    * This method is returns formatted Date 
    */ 
    public Date getFormattedDateValue(String dateValue) {
        try {
            dateValue = dateValue.replace('.', '/').replace('-', '/').replace('\\', '/').replace(' ', '/');
            String[] stringDate = dateValue.split('/');
            Integer yearVal = Integer.valueOf(stringDate[0]);
            Integer monthVal = Integer.valueOf(stringDate[1]);
            Integer dateVal = Integer.valueOf(stringDate[2]);
            return date.newInstance( yearVal,monthVal,dateVal ); 
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getFormattedDateValue() : Failed to process the date. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFormattedDateValue() - exit; dateValue = ' + dateValue );
        } 
    } 
    
    /**
    * This method is returns formatted DateTime 
    */ 
    public String getFormattedDateTimeValue(String dateTimeValue) {
        try {
            datetime expressionDateTimeValue = formatDateTime(dateTimeValue);
            String monthValue = expressionDateTimeValue.month().format();
            String dateValue = expressionDateTimeValue.day().format();
            String hh = expressionDateTimeValue.hour().format();
            String mm = expressionDateTimeValue.minute().format();
            String ss = expressionDateTimeValue.second().format();
            if (integer.valueOf(monthValue) < 10) {
                monthValue = '0' + monthValue;
            }
            if (integer.valueOf(dateValue) < 10) {
                dateValue = '0' + dateValue;
            }
            if (integer.valueOf(hh) < 10) {
                hh = '0' + hh;
            }
            if (integer.valueOf(mm) < 10) {
                mm = '0' + mm;
            }
            if (integer.valueOf(ss) < 10) {
                ss = '0' + ss;
            }
            return expressionDateTimeValue.year() + '-' + monthValue + '-' + dateValue + 'T' + hh + ':' + mm + ':' + ss + 'Z';
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getFormattedDateTimeValue() : Failed to process the date. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFormattedDateTimeValue() - exit; dateValue = ' + dateTimeValue );
        } 
    }

    /**
    * This method is returns formatted DateTime 
    */ 
    public DateTime formatDateTime(String dateTimeValue) {
        dateTimeValue = dateTimeValue.replace('.', '/').replace('-', '/').replace('\\', '/').replace(' ', '/').replace('T', '/').replace(':', '/');
        String[] stringDate = dateTimeValue.split('/');
        Integer yearVal = Integer.valueOf(stringDate[0]);
        Integer monthVal = Integer.valueOf(stringDate[1]);
        Integer dateVal = Integer.valueOf(stringDate[2]);
        Integer hh = 0;
        Integer mm = 0;
        Integer ss = 0;
        if(stringDate.size() > 3) {
            hh = Integer.valueOf(stringDate[3]);
        }
        if(stringDate.size() > 4) {
            mm = Integer.valueOf(stringDate[4]);
        }
        if(stringDate.size() > 5) {
            ss = Integer.valueOf(stringDate[5]);
        }
        system.debug('yearVal = '+yearVal + '  monthVal = '+monthVal + '  dateVal = '+dateVal+'  hh = '+hh+'  mm = '+mm+'  ss = '+ss);
        return datetime.newInstance( yearVal,monthVal,dateVal,hh,mm,ss );
    }
    
    /**
    * This method is returns formatted comma seperated values 
    */ 
    public String formatCommaSeperatedValues(String value) {
        try {
            String fieldValue = '';
            for (String val : value.split(',')) {
                fieldValue += '\'' + val.trim() + '\',';
            }
            fieldValue = fieldValue.subString(0, fieldValue.length()-1);
            return fieldValue;
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'formatCommaSeperatedValues() : Failed to process the comma seperated values. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'formatCommaSeperatedValues() - exit; value = ' + value );
        } 
    }

    /**
    * This method is used to construct comma seperated Ids to be used in SOQL Query.
    */ 
    public Set<String> buildStringSetValues( String operand ) {
        System.debug( LoggingLevel.DEBUG, 'buildDoubleSetValues() - enter' );
        Set<String> setValues = new Set<String>();
        try{
            if( operand == null) {
                System.debug( LoggingLevel.ERROR, 'buildStringSetValues() : Invalid argument. operand= ' + operand );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            for(string str : operand.split(';')) {
                setValues.add(str);
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'buildDoubleSetValues() : Failed to build comma seperated Ids. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'buildDoubleSetValues() : Failed to build comma seperated Ids. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildDoubleSetValues() - exit');
        }
        return setValues;    
    }

    /**
    * This method is used to construct comma seperated Ids to be used in SOQL Query.
    */ 
    public List<String> fetchSObjectFields( List<SVMXA360__CONF_Expression__c> expressionRecords) {
        System.debug( LoggingLevel.DEBUG, 'buildDoubleSetValues() - enter' );
        Set<String> fieldAPINames = new Set<String>{'Id'};
        try{
            // Adding API names of all the expression Rules
            for(SVMXA360__CONF_Expression__c expressionRec : expressionRecords) {
                for(SVMXA360__CONF_ExpressionDetail__c expressionRule : expressionRec.Expression_Detail__r) {
                    if (expressionRule.SVMXA360__SourceObjectName__c == null) {
                        fieldAPINames.add(expressionRule.SVMXA360__FieldAPIName__c);
                        if(String.isNotBlank(expressionRule.SVMXA360__RelationshipName__c) && 
                            String.isNotBlank(expressionRule.SVMXA360__RelationshipFieldAPIName__c)) {
                            fieldAPINames.add(expressionRule.SVMXA360__RelationshipName__c + '.' + expressionRule.SVMXA360__RelationshipFieldAPIName__c);
                        }
                    }
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'buildDoubleSetValues() : Failed to build comma seperated Ids. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'buildDoubleSetValues() : Failed to build comma seperated Ids. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildDoubleSetValues() - exit');
        }
        return new List<String>(fieldAPINames);    
    }

    /**
    * This method is returns equivalent Salesforce Date function name 
    */ 
    public String getSalesforceDateFunction(String value) {
        if( value.equalsIgnoreCase('FSVMXNOW') ||  value.equalsIgnoreCase('FSVMXTODAY') ) {
            value = 'TODAY';
        } else if( value.equalsIgnoreCase('FSVMXTOMORROW') ) {
            value = 'TOMORROW';
        } else if( value.equalsIgnoreCase('FSVMXYESTERDAY') ) {
            value = 'YESTERDAY';
        }
        return value;
    }
   
    /**
    * This method is returns getSObject string for multi reference field 
    */ 
    public String getSObjectForMultiReferenceField(String relationshipName, String relationshipFieldAPIName, SObject sObj) {
        String getSObjectValue;
        SObject tempObject;
        if(relationshipName.contains('.')) {
            for (String obj : relationshipName.split('\\.') ) {
                if (tempObject != NULL) {
                	tempObject = tempObject.getSObject(obj);   
                } else {
                    tempObject = sObj.getSObject(obj);  
                }
            }
        	getSObjectValue = (String) tempObject.get(relationshipFieldAPIName);   
        } else {
          	getSObjectValue = (String) sObj.getSObject(relationshipName).get(relationshipFieldAPIName);  
        }
        return getSObjectValue;
    }

    /**
    * This method returns dummy value based on datatype
    */ 
    public String getDummmyVauleForDatatype(Schema.DisplayType fieldType) {
        String dummyValue;

        if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.COMBOBOX ||
            fieldType == Schema.DisplayType.EMAIL ||
            fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST ||
            fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PHONE ||
            fieldType == Schema.DisplayType.URL) {
                dummyValue = 'Test Default Value';
            } else if (fieldType == Schema.DisplayType.TIME) {
                dummyValue = '00:30:00.000';
            } else if (fieldType == Schema.DisplayType.DATE) {
                dummyValue = String.valueOf(Date.today());
            } else if (fieldType == Schema.DisplayType.DATETIME) {
                dummyValue = String.valueOf(DateTime.now());
            } else if (fieldType == Schema.DisplayType.PERCENT || fieldType == Schema.DisplayType.INTEGER ||
                fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY ) {
                    dummyValue = '123';
            } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                dummyValue = 'false';
            }
        
        return dummyValue;
    }

    /**
    * This method returns field criteria for user literal 
    */ 
    private String getFieldCriteria(Adm.ExpressionDetail expressionRule, String field) {
        if(expressionRule.sourceObjectName == 'User') {
            field = '{$User.' + field + '}';
        }
        return field;
    }
        
}