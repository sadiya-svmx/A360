/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This handler class to parse configured expression.
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
public with sharing class ADM_ExpressionHandler {
    /**
     * Private static variables to hold constants.
     */
    private static final String trueValue 	= 'T';
    private static final String trueLabel = 'TRUE';
    private static final String falseLabel = 'FALSE';
    private static final String Function = 'Function';
    private static final String ISNULL = 'ISNULL';
    private static final String NOTNULL = 'NOTNULL';
    private static final String ISNOTNULL = 'ISNOTNULL';
    private static final String TILDE = '~';
 
    // Get instance of COMM_ExpressionUtils and COMM_DescribeManager
    private final COMM_ExpressionUtils expressionUtils = COMM_ExpressionUtils.getInstance();
    private final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();

    // Get instance of CONF_ObjectMappingHandler
    private CONF_ObjectMappingHandler mappingHandler = new CONF_ObjectMappingHandler();
    
    /**
    * This method is used to return list of matching records after applying the given expression.
    */ 
    public List<sObject> matchRecordsForExpression( Set<Id> recordIds, String expressionId) {    
        System.debug( LoggingLevel.DEBUG, 'matchRecordsForExpression() - enter' );
        List<sObject> matchedRecords = new List<sObject>();
        try{
            if( recordIds == null || recordIds.size() == 0 || String.IsBlank(expressionId) ) {
                System.debug( LoggingLevel.ERROR, 'matchRecordsForExpression() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<SVMXA360__CONF_Expression__c> expressionRecs = ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(new Set<Id>{expressionId});
            if(expressionRecs.size() == 0) {
                System.debug( LoggingLevel.ERROR, 'matchRecordsForExpression() : Expressions not found for the given expression Ids' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            String objectName = expressionRecs[0].SVMXA360__ObjectAPIName__c;
            //Get the map of fields
            Map<String, Schema.SObjectField> sObjectFieldResultMap = describeManager.getObjectFieldMap( objectName );
            // Retrieve all the fields used in the expression
            List<String> sObjectFields = expressionUtils.fetchSObjectFields(expressionRecs);
            // Retrieve matched records for matching conditions
            matchedRecords = retrieveSObjectRecords( String.join(sObjectFields,','), objectName, recordIds, expressionRecs[0].SVMXA360__Criteria__c );
        
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'matchRecordsForExpression() : Failed to return match records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'matchRecordsForExpression() : Failed to return match records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'matchRecordsForExpression() - exit');
        }
        return matchedRecords;
    }

    /**
    * This method is used to return list of matching records after applying the respective expression received in the request.
    */ 
    public Map<String,List<Adm.Context>> matchRecordsForExpressions( Map<String,List<Adm.Context>> sObjectContextRecs) {    
        System.debug( LoggingLevel.DEBUG, 'matchRecordsForExpressions() - enter' );
        Map<String,List<Adm.Context>> matchedsObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> matchedRecords;
        try{
            if( sObjectContextRecs.size() == 0 ) {
                System.debug( LoggingLevel.ERROR, 'matchRecordsForExpressions() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            Map<Id,SVMXA360__CONF_Expression__c> expressionRecMap = fetchExpressionDetails(sObjectContextRecs);
            if( expressionRecMap.size() == 0 ) {
                System.debug( LoggingLevel.ERROR, 'matchRecordsForExpressions() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            String objectName = expressionRecMap.values()[0].SVMXA360__ObjectAPIName__c;
            Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = describeManager.getFieldDescribeResults( objectName );
            String queryFields = string.join(expressionUtils.fetchSObjectFields(expressionRecMap.values()),',');
            // Query the records for the record Ids sent as part of the request
            Map<Id,sObject> sObjectRecordsMap = new Map<Id,sObject> (retrieveSObjectRecords( queryFields,objectName,sObjectContextRecs.keyset() )); // Send the list of Ids

            for( String sObjectId : sObjectContextRecs.keySet() ) {
                // Parse method is called for a record to evaluate the expression for list of related records
                matchedRecords = new List<Adm.Context>();
                for(Adm.Context contextRec : sObjectContextRecs.get(sObjectId)) {
                    if( parseExpression(sObjectRecordsMap.get((Id)sObjectId), sObjectFieldResultMap, expressionRecMap.get(contextRec.expressionId),null).equals(trueValue) ) {
                        matchedRecords.add(contextRec);
                    }
                }
                if(matchedRecords.size() > 0) {
                    matchedsObjectContextRecs.put(sObjectId,matchedRecords);
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'matchRecordsForExpressions() : Failed to return match records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'matchRecordsForExpressions() : Failed to return match records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'matchRecordsForExpressions() - exit');
        }
        return matchedsObjectContextRecs;
    }

    /**
    * This method is used to return first matching expression for a record.
    */ 
    public String getFirstQualifiedExpression( final SObject sourceRecord, final List<Id> expressionIds ) {    
        System.debug( LoggingLevel.DEBUG, 'getFirstQualifiedExpression() - enter' );
        String matchedExpression;
        try{
            if( sourceRecord == null ) {
                System.debug( LoggingLevel.ERROR, 'getFirstQualifiedExpression() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            Set<Id> expressionSetIds = new Set<Id>(expressionIds);
            // Refer getObjectMappingWithDetailRecords from ObjectMappingManager
            Map<Id,SVMXA360__CONF_Expression__c> expressionRecMap = 
                new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionSetIds));
            if( expressionRecMap.size() == 0 ) {
                System.debug( LoggingLevel.ERROR, 'getFirstQualifiedExpression() : Expression Records does not exist.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            String objectName = expressionRecMap.values()[0].SVMXA360__ObjectAPIName__c;
            Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = describeManager.getFieldDescribeResults( objectName );
            String queryFields = string.join(expressionUtils.fetchSObjectFields(expressionRecMap.values()),',');
            // Query the records for the record Ids sent as part of the request
            Set<String> sObjectRecIds = new Set<String>{sourceRecord.Id}; 
            sObject sObjectRec = retrieveSObjectRecords( queryFields,objectName,sObjectRecIds )[0];
            
            for( String expressionId : expressionIds ) {
                // Parse method is called for a record to evaluate the expression for list of related records
                if( parseExpression(sObjectRec, sObjectFieldResultMap, expressionRecMap.get(expressionId),null).equals(trueValue) ) {
                    matchedExpression = expressionId;
                    break;
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFirstQualifiedExpression() : Failed to return match records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'getFirstQualifiedExpression() : Failed to return match records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFirstQualifiedExpression() - exit');
        }
        return matchedExpression;
    }

    /**
    * This method is to return the query criteria
    */
    public String parseExpression(SObject sObjRec, Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap, 
    SVMXA360__CONF_Expression__c expressionRec) {
        try {
            if( sObjRec == null || expressionRec == null || sObjectFieldResultMap == null) {
                
            	System.debug( LoggingLevel.ERROR, 'parseExpression() : Invalid arguments. sObjRec= ' + sObjRec + 'sObjectFieldResultMap=' + sObjectFieldResultMap + 'expressionRec=' + expressionRec);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            return parseExpression(sObjRec, sObjectFieldResultMap, expressionRec, null);
        }catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'parseExpression() : Failed to parse Expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'parseExpression() - exit; expressionRec = ' + expressionRec );
        }
    }

    /**
    * This method is used to parse expressions for a record
    */ 
    public String parseExpression( SObject sObjRec, Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap, 
                                    SVMXA360__CONF_Expression__c expressionRec, SObject literalObjRec) {
        String advancedCriteriaClause;
        String parsedExpression;
        Map<String, Map<String, Schema.DescribeFieldResult>> sObjectResultMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        sObjectResultMap.put(expressionRec.SVMXA360__ObjectAPIName__c, sObjectFieldResultMap);
        SVMXA360__CONF_ExpressionDetail__c expressionRule = new SVMXA360__CONF_ExpressionDetail__c();
        Set<String> userReferenceFields =  new Set<String>();
        SObject literalObject;
        SObject userObject;
        try {
            if(String.isNotBlank(expressionRec.SVMXA360__AdvancedExpression__c)) {
                advancedCriteriaClause = formatAdvancedCriteria(expressionRec.SVMXA360__AdvancedExpression__c);
                parsedExpression = advancedCriteriaClause.deleteWhitespace();
            }
            for( integer i = 0; i < expressionRec.Expression_Detail__r.size(); i++ ) {
                expressionRule = expressionRec.Expression_Detail__r[i];
                if (expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase('Function') && string.escapeSingleQuotes(expressionRule.SVMXA360__Operand__c).trim() == 'User') { 
                    userReferenceFields.add(expressionRule.SVMXA360__LiteralParameter__c);
                }
                if (expressionRule.SVMXA360__SourceObjectName__c != null && expressionRule.SVMXA360__SourceObjectName__c.equalsIgnoreCase('User')) { 
                    userReferenceFields.add(expressionRule.SVMXA360__FieldAPIName__c);
                }
            }
            if (userReferenceFields.size() > 0) {
                userObject = mappingHandler.getCurrentUserRecord(userReferenceFields);
            }
            for( integer i = 0; i < expressionRec.Expression_Detail__r.size(); i++ ) {
                expressionRule = expressionRec.Expression_Detail__r[i];
                String objectAPIName = '';
                String lastLevelFieldAPIName = '';
                String operandType = expressionRule.SVMXA360__OperandType__c;
                String value = expressionRule.SVMXA360__Operand__c == null ? expressionRule.SVMXA360__Operand__c : string.escapeSingleQuotes(expressionRule.SVMXA360__Operand__c).trim();
                if(String.isNotBlank(expressionRule.SVMXA360__RelatedObjectDetails__c)) {
                    if(expressionRule.SVMXA360__RelatedObjectDetails__c.contains('.')) {
                        objectAPIName = expressionRule.SVMXA360__RelatedObjectDetails__c .substringAfterLast('.');    
                    } else {
                        objectAPIName =  expressionRule.SVMXA360__RelatedObjectDetails__c; 
                    }
                    lastLevelFieldAPIName = expressionRule.SVMXA360__FieldAPIName__c .substringAfterLast('.');
                    if( !sObjectResultMap.containsKey(objectAPIName) ) {
                    	sObjectResultMap.put(objectAPIName, COMM_DescribeManager.getInstance().getFieldDescribeResults( objectAPIName ));
                    }
                } else {
                    if (expressionRule.SVMXA360__SourceObjectName__c != null && expressionRule.SVMXA360__SourceObjectName__c.equalsIgnoreCase('User')) {
                        objectAPIName =  'User';
                    } else {
                        objectAPIName =  expressionRec.SVMXA360__ObjectAPIName__c;
                    }
                    if( !sObjectResultMap.containsKey(objectAPIName) ) {
                    	sObjectResultMap.put(objectAPIName, COMM_DescribeManager.getInstance().getFieldDescribeResults( objectAPIName ));
                    }
                    lastLevelFieldAPIName = expressionRule.SVMXA360__FieldAPIName__c ;
                }
                // Check if the field is valid
                if(!sObjectFieldResultMap.ContainsKey(lastLevelFieldAPIName) && (String.isNotBlank(objectAPIName) && !sObjectResultMap.get(objectAPIName).ContainsKey(lastLevelFieldAPIName))){
                    System.debug( LoggingLevel.ERROR, 'parseExpression() : Invalid field on expression Rule' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                }
                Schema.DescribeFieldResult fieldResult;
                if (String.isNotBlank(objectAPIName)) {
                    fieldResult = sObjectResultMap.get(objectAPIName).get(lastLevelFieldAPIName);
                } else {
                    fieldResult = sObjectFieldResultMap.get(lastLevelFieldAPIName);
                }
                if (operandType.equalsIgnoreCase('Function') && value == 'User') {
                    literalObject = userObject;
                } else if (operandType.equalsIgnoreCase('Function') && value == 'Current Record Header') {
                    literalObject = literalObjRec;
                }
                if(String.isNotBlank(advancedCriteriaClause)) {
                    // If the advanced criteria is not blank, then replace the value with respective condition
                    parsedExpression = parsedExpression.replace(TILDE+string.valueOf(expressionRule.SVMXA360__Sequence__c.intValue())+TILDE, applyCriteria( sObjRec,userObject,expressionRule,fieldResult,literalObject ));      
                } else {
                    // If the advanced criteria is blank, then add AND between value of each condition
                    if(i==0) {
                        parsedExpression = applyCriteria( sObjRec,userObject,expressionRule,fieldResult,literalObject );
                    } else {
                        parsedExpression = parsedExpression + ' && ' + applyCriteria( sObjRec,userObject,expressionRule,fieldResult,literalObject );
                    }
                }
                parsedExpression = parsedExpression.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
                System.debug( LoggingLevel.DEBUG, 'parseExpression :' + parsedExpression);
            }
            String advancedExpression = '';
            do {
                advancedExpression = parsedExpression;
                parsedExpression  = parsedExpression.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
            }
            while(advancedExpression != parsedExpression);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'parseExpression() : Failed to apply expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'parseExpression() : Failed to apply expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'parseExpression() - exit');
        }
        return parsedExpression;
    }

    /**
    * This method is used to apply expressions for a record
    */ 
    public String applyCriteria( SObject sObjRec, SObject userObject, SVMXA360__CONF_ExpressionDetail__c expressionRule, 
                                  Schema.DescribeFieldResult fieldResult, SObject literalObjRec ) {
        String parsedResult = 'F';
        try {
            Schema.DisplayType fieldType = fieldResult.getType();
            String operator = expressionRule.SVMXA360__Operator__c.ToUpperCase();
            Object objVal;
            SObject sourceObjectRec = getsourceObjectRecord(expressionRule, userObject, sObjRec);
            if (expressionRule.SVMXA360__FieldAPIName__c.contains('.')) {
                objVal = mappingHandler.getValueOfMultiReference(sourceObjectRec, expressionRule.SVMXA360__FieldAPIName__c);
            } else {
                objVal = sourceObjectRec.get(expressionRule.SVMXA360__FieldAPIName__c);    
            }
            // Handle for null and notNull conditions
            if(operator.equals(ISNULL)) {
                if(objVal == null) {
                    parsedResult = trueValue;
                }
            } else if(operator.equals(NOTNULL) || operator.equals(ISNOTNULL)) {
                if(objVal != null) {
                    parsedResult = trueValue;
                }
            } else {
                // Calling processoperators for processing the record for the rule
                parsedResult = processOperators( sourceObjectRec, userObject, expressionRule, fieldType, literalObjRec );
            }
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'applyExpression() : Failed to apply expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'applyExpression() : Failed to apply expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyExpression() - exit');
        }
        return parsedResult;
    }

    /**
    * This method is used to process different operators of the expression rule for a record
    */ 
    private String processOperators( SObject sObjRec, SObject userObject, SVMXA360__CONF_ExpressionDetail__c expressionRule, Schema.DisplayType fieldType, SObject literalObjRec ) {
        String parsedResult;
           switch on expressionRule.SVMXA360__Operator__c.ToUpperCase() {
                
                when 'EQ','NE','GT','LT','LE','GE' {
                    parsedResult = evaluateEqualsGreaterLesserOperators( sObjRec,userObject,expressionRule,fieldType,literalObjRec );
                }
                when 'IN','NOTIN' {
                    parsedResult = evaluateInNotInOperator( sObjRec,userObject,expressionRule,fieldType,literalObjRec );
                }
                when 'STARTS','CONTAINS','NOTCONTAIN' {
                    parsedResult = evaluateStartContainOperators( sObjRec,userObject,expressionRule,fieldType,literalObjRec );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'processOperators() : unsupported operator. operator= ' + expressionRule.SVMXA360__Operator__c.ToUpperCase() );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            } 
        //}
        return parsedResult;
    }

    /**
    * This method is used to evaluate for Equals operators
    */ 
    private String evaluateEqualsGreaterLesserOperators( SObject sObjRec,  SObject userObject, SVMXA360__CONF_ExpressionDetail__c expressionRule, 
                                            Schema.DisplayType fieldType, SObject literalObjRec ) {
        System.debug( LoggingLevel.DEBUG, 'evaluateEqualsInOperator() - enter' );
        String parsedResult = 'F';
        try{
            Object val;
            String operandType = expressionRule.SVMXA360__OperandType__c;
            String value = string.escapeSingleQuotes(expressionRule.SVMXA360__Operand__c).trim();
            String operandValue = string.escapeSingleQuotes(expressionRule.SVMXA360__Operand__c).trim();
            SObject sourceObjectRec = getsourceObjectRecord(expressionRule, userObject, sObjRec);
            if (expressionRule.SVMXA360__FieldAPIName__c.contains('.')) {
                val = mappingHandler.getValueOfMultiReference(sourceObjectRec, expressionRule.SVMXA360__FieldAPIName__c);
            } else {
                val = sourceObjectRec.get(expressionRule.SVMXA360__FieldAPIName__c);    
            }
            String operand = expressionRule.SVMXA360__Operand__c;
            if (expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue  == 'User')) {
                if ( expressionRule.SVMXA360__LiteralParameter__c.contains('.') ) {
                    operand = String.valueOf(mappingHandler.getValueOfMultiReference(literalObjRec, expressionRule.SVMXA360__LiteralParameter__c));
                } else {
                    operand = String.valueOf(literalObjRec.get(expressionRule.SVMXA360__LiteralParameter__c));
                }
            }
            Boolean isDateFormateRequired = operandType.equalsIgnoreCase('value') || (operandType.equalsIgnoreCase('Function') && (operandValue == 'Current Record Header' || operandValue == 'User'));
            if( val == null && !expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('NE') ) {
                return parsedResult;
            }
            switch on fieldType {
                when BOOLEAN {
                    // Processing for Boolean field Type
                    parsedResult = processBooleanOperator( val,operand,expressionRule );
                }
                when CURRENCY,LOCATION,DOUBLE,PERCENT,INTEGER {
                    // Processing for Currency and Location field Type by coverting to decimal
                    if( evaluateGenericNumberOperator( (DOUBLE)val,DOUBLE.valueOf(operand),expressionRule.SVMXA360__Operator__c ) ) {
                        parsedResult = trueValue;
                    }
                }
                // Process for String related field Type 
                when STRING,COMBOBOX,REFERENCE,EMAIL,PICKLIST,MULTIPICKLIST,TEXTAREA,PHONE,ID,URL {
                    val = formatStringField( fieldType,String.ValueOf(val) );
                    if(fieldType == Schema.DisplayType.REFERENCE && operandType.equalsIgnoreCase('value')) {
                        val = expressionUtils.getSObjectForMultiReferenceField(expressionRule.SVMXA360__RelationshipName__c, expressionRule.SVMXA360__RelationshipFieldAPIName__c, sourceObjectRec);
                    }
                    if( evaluateStringOperator( String.Valueof(val),operand,expressionRule.SVMXA360__Operator__c ) ) {
                        parsedResult = trueValue;
                    }
                }
                when TIME {
                    if( evaluateTimeOperator( (TIME)val,Time.newInstance(Integer.ValueOf(operand.substring(0, 2)), Integer.ValueOf(operand.substring(3, 5)), Integer.ValueOf(operand.substring(6, 8)), 00),expressionRule.SVMXA360__Operator__c ) ) {
                        parsedResult = trueValue;
                    }
                }
                when DATETIME {
                    // Process for Datetime field Type 
                    if(expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase(Function) && !(operandValue == 'Current Record Header') && !(operandValue  == 'User')) {
                        parsedResult = processDateFunctions( ((Datetime) val).date(),operand,expressionRule );
                    } else if( evaluateGenericDateTimeOperator( expressionUtils.formatDateTime(String.ValueOf(val)),expressionUtils.formatDateTime(operand),expressionRule.SVMXA360__Operator__c ) ) {
                        parsedResult = trueValue;
                    }
                }
                when DATE {
                    // Process for Date field Type
                    if(expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase(Function) && !(operandValue == 'Current Record Header') && !(operandValue  == 'User')) {
                        parsedResult = processDateFunctions( val,operand,expressionRule );
                    } else if( evaluateGenericDateOperator( Date.valueOf(val),Date.ValueOf(operand),expressionRule.SVMXA360__Operator__c ) ) {
                        parsedResult = trueValue;
                    }
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'evaluateOperators() : unsupported fieldType. fieldType= ' + fieldType );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        } catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'evaluateOperators() : Failed to evaluate for EQ, NE, IN & NOTIN operators. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateOperators() - exit');
        }
        return parsedResult;    
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private String processDateFunctions( Object val, String operand, SVMXA360__CONF_ExpressionDetail__c expressionRule) {
        String parsedResult = 'F';
        if( expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('EQ') ) {
            if( COMM_DateLiteralUtils.isDateInRange(Date.valueOf(val),operand) ) {
                parsedResult = trueValue;
            }
        } else if( expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('NE') ) {
            if( !COMM_DateLiteralUtils.isDateInRange(Date.valueOf(val),operand) ) {
                parsedResult = trueValue;
            }
        } else {
            if( COMM_DateLiteralUtils.isDateInRange(Date.valueOf(val),operand,expressionRule.SVMXA360__Operator__c) ) {
                parsedResult = trueValue;
            }
        }
        return parsedResult;
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private String processBooleanOperator( Object val, String operand, SVMXA360__CONF_ExpressionDetail__c expressionRule) {
        String parsedResult = 'F';
        if(expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('EQ')) {
            if( operand.ToUpperCase().equals(trueLabel) && (boolean)val ) {
                parsedResult = trueValue;
            }
            else if( operand.ToUpperCase().equals(falseLabel) && !(boolean)val ) {
                parsedResult = trueValue;
            }
        } else if(expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('NE')) {
            if( operand.ToUpperCase().equals(trueLabel) && !(boolean)val ) {
                parsedResult = trueValue;
            }
            else if( operand.ToUpperCase().equals(falseLabel) && (boolean)val ) {
                parsedResult = trueValue;
            } 
        }
        return parsedResult;
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private Boolean evaluateStringOperator( String sobjRecVal, String operandVal, String operator) {
        Boolean processCondition = false;
        switch on operator.toUpperCase() {

            when 'EQ' {
                processCondition = (sobjRecVal == operandVal);
            }
            when 'NE' {
                processCondition = (sobjRecVal != operandVal);
            }
            when 'GT' {
                processCondition = (sobjRecVal > operandVal);
            }
            when 'LT' {
                processCondition = (sobjRecVal < operandVal);
            }
            when 'GE' {
                processCondition = (sobjRecVal >= operandVal);
            }
            when 'LE' {
                processCondition = (sobjRecVal <= operandVal);
            }
            when else {
                System.debug( LoggingLevel.ERROR, 'evaluateGenericOperator() : unsupported operator. operator= ' + operator );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
            }
        }
        return processCondition;
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private Boolean evaluateTimeOperator( Time sobjRecVal, Time operandVal, String operator) {
        Boolean processCondition = false;
        switch on operator.toUpperCase() {

            when 'EQ' {
                processCondition = (sobjRecVal == operandVal);
            }
            when 'NE' {
                processCondition = (sobjRecVal != operandVal);
            }
            when 'GT' {
                processCondition = (sobjRecVal > operandVal);
            }
            when 'LT' {
                processCondition = (sobjRecVal < operandVal);
            }
            when 'GE' {
                processCondition = (sobjRecVal >= operandVal);
            }
            when 'LE' {
                processCondition = (sobjRecVal <= operandVal);
            }
            when else {
                System.debug( LoggingLevel.ERROR, 'evaluateGenericOperator() : unsupported operator. operator= ' + operator );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
            }
        }
        return processCondition;
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private Boolean evaluateGenericNumberOperator( Double sobjRecVal, Double operandVal, String operator) {
        Boolean processCondition = false;
        switch on operator.toUpperCase() {

            when 'EQ' {
                processCondition = (sobjRecVal == operandVal);
            }
            when 'NE' {
                processCondition = (sobjRecVal != operandVal);
            }
            when 'GT' {
                processCondition = (sobjRecVal > operandVal);
            }
            when 'LT' {
                processCondition = (sobjRecVal < operandVal);
            }
            when 'GE' {
                processCondition = (sobjRecVal >= operandVal);
            }
            when 'LE' {
                processCondition = (sobjRecVal <= operandVal);
            }
            when else {
                System.debug( LoggingLevel.ERROR, 'evaluateGenericOperator() : unsupported operator. operator= ' + operator );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
            }
        }
        return processCondition;
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private Boolean evaluateGenericDateOperator( Date sobjRecVal, Date operandVal, String operator) {
        Boolean processCondition = false;
        switch on operator.toUpperCase() {

            when 'EQ' {
                processCondition = (sobjRecVal == operandVal);
            }
            when 'NE' {
                processCondition = (sobjRecVal != operandVal);
            }
            when 'GT' {
                processCondition = (sobjRecVal > operandVal);
            }
            when 'LT' {
                processCondition = (sobjRecVal < operandVal);
            }
            when 'GE' {
                processCondition = (sobjRecVal >= operandVal);
            }
            when 'LE' {
                processCondition = (sobjRecVal <= operandVal);
            }
            when else {
                System.debug( LoggingLevel.ERROR, 'evaluateGenericOperator() : unsupported operator. operator= ' + operator );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
            }
        }
        return processCondition;
    }

    /**
    * This method is used to process condition for Equals and Not Equals operators
    */ 
    private Boolean evaluateGenericDateTimeOperator( DateTime sobjRecVal, DateTime operandVal, String operator) {
        Boolean processCondition = false;
        switch on operator.toUpperCase() {

            when 'EQ' {
                processCondition = (sobjRecVal == operandVal);
            }
            when 'NE' {
                processCondition = (sobjRecVal != operandVal);
            }
            when 'GT' {
                processCondition = (sobjRecVal > operandVal);
            }
            when 'LT' {
                processCondition = (sobjRecVal < operandVal);
            }
            when 'GE' {
                processCondition = (sobjRecVal >= operandVal);
            }
            when 'LE' {
                processCondition = (sobjRecVal <= operandVal);
            }
            when else {
                System.debug( LoggingLevel.ERROR, 'evaluateGenericOperator() : unsupported operator. operator= ' + operator );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
            }
        }
        return processCondition;
    }

    /**
    * This method is used to evaluate for Equals operators
    */ 
    private String evaluateInNotInOperator( SObject sObjRec,  SObject userObject, SVMXA360__CONF_ExpressionDetail__c expressionRule, 
                                              Schema.DisplayType fieldType, SObject literalObjRec ) {
        System.debug( LoggingLevel.DEBUG, 'evaluateInNotInOperator() - enter' );
        String parsedResult = 'F';
        try{
            Object objval;
            SObject sourceObjectRec = getsourceObjectRecord(expressionRule, userObject, sObjRec);
            if (expressionRule.SVMXA360__FieldAPIName__c.contains('.')) {
                objval = mappingHandler.getValueOfMultiReference(sourceObjectRec, expressionRule.SVMXA360__FieldAPIName__c);
            } else {
                objval = sourceObjectRec.get(expressionRule.SVMXA360__FieldAPIName__c);    
            }
            String operand = expressionRule.SVMXA360__Operand__c;
            if (expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase('Function') && (expressionRule.SVMXA360__Operand__c == 'Current Record Header' || expressionRule.SVMXA360__Operand__c  == 'User')) {
                if ( expressionRule.SVMXA360__LiteralParameter__c.contains('.') ) {
                    operand = String.valueOf(mappingHandler.getValueOfMultiReference(literalObjRec, expressionRule.SVMXA360__LiteralParameter__c));
                } else {
                    operand = String.valueOf(literalObjRec.get(expressionRule.SVMXA360__LiteralParameter__c));
                }
            }
            // In operator evaluates only for String related field types
            if( fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.COMBOBOX ||
                fieldType == Schema.DisplayType.REFERENCE || fieldType == Schema.DisplayType.EMAIL ||
                fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST ||
                fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PHONE ||
                fieldType == Schema.DisplayType.ID ) {
                Set<String> setValues = expressionUtils.buildStringSetValues(operand);
                String val = formatStringField( fieldType,String.ValueOf(objval) );
                if(fieldType == Schema.DisplayType.REFERENCE && expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase('Value')) {
                    val = expressionUtils.getSObjectForMultiReferenceField(expressionRule.SVMXA360__RelationshipName__c, expressionRule.SVMXA360__RelationshipFieldAPIName__c, sourceObjectRec);
                }
                if( expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('IN') && String.isNotBlank(val) ) {
                    for (String fieldVal : expressionUtils.buildStringSetValues(val)) {
                        if(setValues.contains(fieldVal)) {
                            parsedResult = trueValue;
                            break;
                        }
                    }
                } else if( expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('NOTIN') ) {
                    if( String.isBlank(val) ) {
                        parsedResult = trueValue;
                    } else {
                        parsedResult = trueValue;
                        for (String fieldVal : expressionUtils.buildStringSetValues(val)) {
                            if(setValues.contains(fieldVal)) {
                                parsedResult = 'F';
                                break;
                            }
                        }
                    }
                }
                
            }
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'evaluateInNotInOperator() : Failed to evaluate for IN operator. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateInNotInOperator() - exit');
        }
        return parsedResult;    
    }

    /**
    * This method is used to evaluate for Equals operators
    */ 
    private String evaluateStartContainOperators( SObject sObjRec,  SObject userObject, SVMXA360__CONF_ExpressionDetail__c expressionRule, 
                                                  Schema.DisplayType fieldType, SObject literalObjRec ) {
        System.debug( LoggingLevel.DEBUG, 'evaluateStartContainOperators() - enter' );
        String parsedResult = 'F';
        try{
            Object objVal;
            SObject sourceObjectRec = getsourceObjectRecord(expressionRule, userObject, sObjRec);
            if (expressionRule.SVMXA360__FieldAPIName__c.contains('.')) {
                objVal = mappingHandler.getValueOfMultiReference(sourceObjectRec, expressionRule.SVMXA360__FieldAPIName__c);
            } else {
                objVal = sourceObjectRec.get(expressionRule.SVMXA360__FieldAPIName__c);    
            }
            String val = formatStringField( fieldType,String.ValueOf(objVal) );
            if(String.isBlank(val) && !expressionRule.SVMXA360__Operator__c.equalsIgnoreCase('NOTCONTAIN')) {
                return parsedResult;
            }
            //Only for String Related Date Types
            if( fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.COMBOBOX ||
                fieldType == Schema.DisplayType.REFERENCE || fieldType == Schema.DisplayType.EMAIL ||
                fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST ||
                fieldType == Schema.DisplayType.TEXTAREA || fieldType == Schema.DisplayType.PHONE  ||
                fieldType == Schema.DisplayType.ID || fieldType == Schema.DisplayType.URL) {
                
                String operand = expressionRule.SVMXA360__Operand__c;
                if (expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase('Function') && (expressionRule.SVMXA360__Operand__c == 'Current Record Header' || expressionRule.SVMXA360__Operand__c  == 'User')) {
                    if ( expressionRule.SVMXA360__LiteralParameter__c.contains('.') ) {
                        operand = String.valueOf(mappingHandler.getValueOfMultiReference(literalObjRec, expressionRule.SVMXA360__LiteralParameter__c));
                    } else {
                        operand = String.valueOf(literalObjRec.get(expressionRule.SVMXA360__LiteralParameter__c));
                    }
                }
                String operator = expressionRule.SVMXA360__Operator__c.ToUpperCase();
                if(fieldType == Schema.DisplayType.REFERENCE && expressionRule.SVMXA360__OperandType__c.equalsIgnoreCase('Value')) {
                    val = expressionUtils.getSObjectForMultiReferenceField(expressionRule.SVMXA360__RelationshipName__c, expressionRule.SVMXA360__RelationshipFieldAPIName__c, sourceObjectRec);
            	}
                if( String.isNotBlank(operand) ) {
                    if(operator.equalsIgnoreCase('STARTS') && val.toUpperCase().startsWith(operand.toUpperCase())) {
                        parsedResult = trueValue;
                    }
                    else if(operator.equalsIgnoreCase('CONTAINS') && val.containsIgnoreCase(operand)) {
                        parsedResult = trueValue;
                    }
                    else if( operator.equalsIgnoreCase('NOTCONTAIN') ) {
                        if( String.isBlank(val) ) {
                            parsedResult = trueValue;
                        } else if( !val.containsIgnoreCase(operand) ) {
                            parsedResult = trueValue;
                        } 
                    }
                }
            }
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'evaluateStartContainOperators() : Failed to evaluate for NE operator. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateStartContainOperators() - exit');
        }
        return parsedResult;    
    }

    /**
    * This method is used to construct comma seperated Ids to be used in SOQL Query.
    */ 
    private Map<Id,SVMXA360__CONF_Expression__c> fetchExpressionDetails( Map<String,List<Adm.Context>> sObjectContextRecs ) {
        System.debug( LoggingLevel.DEBUG, 'fetchExpressionDetails() - enter' );
        Set<Id> expressionIds = new Set<Id>();
        Map<Id,SVMXA360__CONF_Expression__c> expressionRecordsMap;
        try{

            for(List<Adm.Context> contextRecList : sObjectContextRecs.values()) {
                for(Adm.Context contextRec : contextRecList) {
                    expressionIds.add(contextRec.expressionId);
                }  
            }
            // Refer getObjectMappingWithDetailRecords from ObjectMappingManager
            expressionRecordsMap = 
                new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionIds));
            
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'fetchExpressionDetails() : Failed to fetch expression details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchExpressionDetails() - exit');
        }
        return expressionRecordsMap;    
    }

    /**
    * This method is used to format advanced criteria.
    */ 
    private String formatAdvancedCriteria( String advancedExpression) {
        System.debug( LoggingLevel.DEBUG, 'formatAdvancedCriteria() - enter' );
        String criteria;
        try{
            // Formatting the advanced expression for evaluation
            criteria = expressionUtils.buildAdvancedCriteria(advancedExpression.toUpperCase());
            criteria = criteria.replaceAll('AND', ' && ');
            criteria = criteria.replaceAll('OR', ' || ');
            criteria = criteria.replaceAll('NOT', ' ! ');
            criteria = ' ' + criteria + ' ';
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'formatAdvancedCriteria() : Failed to format Advanced Criteria. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'formatAdvancedCriteria() - exit');
        }
        return criteria;    
    }

    /**
    * This method is used to format rich text area values.
    */ 
    private String formatStringField( Schema.DisplayType fieldType, String fieldValue) {
        System.debug( LoggingLevel.DEBUG, 'formatStringField() - enter' );
        if( fieldType == Schema.DisplayType.TEXTAREA && String.isNotBlank(fieldValue) ){
            fieldValue = fieldValue.stripHtmlTags();
        }
        return fieldValue;    
    }

    /**
    * This method is used to construct comma seperated Ids to be used in SOQL Query.
    */ 
    private List<SObject> retrieveSObjectRecords( String queryFields, String objectName, Set<String> sObjectIds ) {
        System.debug( LoggingLevel.DEBUG, 'retrieveSObjectRecords() - enter' );
        List<sObject> sObjectRecords = new List<sObject>();
        try{
            //Retreiving the records for provided Ids using svmxDatabase
            sObjectRecords = SvmxDatabase.query(Database.query('Select '+ queryFields +' from '+ objectName +' where ID in :sObjectIds'));
            if(sObjectRecords.size() == 0) {
                System.debug( LoggingLevel.ERROR, 'retrieveSObjectRecords() : Records does not exist' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );    
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveSObjectRecords() : Failed to retrieve records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'retrieveSObjectRecords() : Failed to retrieve records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSObjectRecords() - exit');
        }
        return sObjectRecords;
    }

    /**
    * This method is used to construct comma seperated Ids to be used in SOQL Query.
    */ 
    private List<SObject> retrieveSObjectRecords( String queryFields, String objectName, Set<Id> sObjectIds, String criteria ) {
        System.debug( LoggingLevel.DEBUG, 'retrieveSObjectRecords() - enter' );
        List<sObject> sObjectRecords = new List<sObject>();
        try{
             //Retreiving the records for provided Ids and condition using svmxDatabase
            sObjectRecords = SvmxDatabase.query(Database.query('Select '+ queryFields +' from '+ objectName +' where ID in :sObjectIds' + 
                                                +' And ( ' + criteria +' )'));

            if(sObjectRecords.size() == 0) {
                System.debug( LoggingLevel.ERROR, 'retrieveSObjectRecords() : Records does not exist' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );    
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveSObjectRecords() : Failed to retrieve records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'retrieveSObjectRecords() : Failed to retrieve records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSObjectRecords() - exit');
        }
        return sObjectRecords;
    }

    /**
    * This method to retrieve sourceObjectRecord
    */ 
    private SObject getsourceObjectRecord(SVMXA360__CONF_ExpressionDetail__c expressionRule, SObject userObject, SObject sObjRec) {
        SObject sourceObjectRec;
            if (expressionRule.SVMXA360__SourceObjectName__c != null && expressionRule.SVMXA360__SourceObjectName__c == 'User') {
                sourceObjectRec = userObject;
            } else {
                sourceObjectRec = sObjRec;
            }
        return sourceObjectRec;
    }    

}