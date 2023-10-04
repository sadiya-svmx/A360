/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve expression informations from Salesforce Org. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/******************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       	12 May 2020     Created.
 * BLOS-313     Ramachandra Mohan		31 Jul 2020		Implemented new method to retrieve expression detail 
 * 														for requested expression type.
 * A360TOOL-4   Ramachandra Mohan       21 Sep 2020     Methods to support bulk save.
 * A360APP-60   Ramachandra Mohan       03 Nov 2020     Updated query to retrieve all expressions.
 * A360TOOL-818 Ramachandra Mohan       28 Oct 2021     Service to validate expressions.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_ExpressionManager {

    public static final String COMM_EXPRESSION 				= 'COMM-EXPRESSION';
    public static final String EVER_RULE_CRITERIA 			= 'EVER-RULE-CRITERIA';
    public static final String VISIBILITY_RULE_CRITERIA 	= 'VISIBILITY-RULE-CRITERIA';
    public static final String CONFIGURATION_FILTER 		= 'CONFIGURATION-FILTER';
    public static final Set<String> operatorList 		= new Set<String>{'starts','notcontain','contains'};

    public Map<String, List<Common.RecordType>> recordTypeMap = new Map<String, List<Common.RecordType>>();
    
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_ExpressionManager instance;
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private ADM_ExpressionManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_ExpressionManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'ADM_ExpressionManager.getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new ADM_ExpressionManager();
                System.debug( LoggingLevel.INFO, 'ADM_ExpressionManager.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'ADM_ExpressionManager.getInstance() - exit' );
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public List<Adm.Expression> getAllExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllExpressions() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();
        
        try {
            
            // Retrieve all expressions
            final List<SVMXA360__CONF_Expression__c> expressionRecordList = getAllExpressionRecords();
            
            if( expressionRecordList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    expressions.add( createExpression( expressionRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllExpressions() : Retrieved all expressions' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllExpressions() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllExpressions() - exit; expressions.size()= ' + expressions.size() );
        }
        
        return expressions;
    }

    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public List<Adm.Expression> getAllRuleExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllRuleExpressions() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();
        
        try {
            
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getAllRuleExpressionRecords();
            
            if( expressionRecordList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    Adm.Expression expressionWrapper = createExpression( expressionRecord );
                    if(expressionRecord.Expression_Detail__r.size() > 0) {
                        expressionWrapper.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                        for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                            expressionWrapper.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                        }
                    }
                    expressions.add(expressionWrapper);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getAllRuleExpressions() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllRuleExpressions() : Retrieved all expressions' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllRuleExpressions() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllRuleExpressions() - exit; expressions.size()= ' + expressions.size() );
        }
        
        return expressions;
    }
    
    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public List<Adm.Expression> getAllVisibilityCriterias() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllVisibilityCriterias() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();
        
        try {
            
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getAllVisibilityCriteriaRecords();
            
            if( expressionRecordList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    Adm.Expression expressionWrapper = createExpression( expressionRecord );
                    if(expressionRecord.Expression_Detail__r.size() > 0) {
                        expressionWrapper.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                        for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                            expressionWrapper.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                        }
                    }
                    expressions.add(expressionWrapper);
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllVisibilityCriterias() : Retrieved all Visibility Criterias' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllVisibilityCriterias() : Failed to retrieve Visibility Criterias. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllVisibilityCriterias() - exit; expressions.size()= ' + expressions.size() );
        }
        
        return expressions;
    }
    
    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public List<Adm.Expression> getAllConfigurationFilters() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();
        
        try {
            
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getAllConfigurationFilterRecords();
            
            if( expressionRecordList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    Adm.Expression expressionWrapper = createExpression( expressionRecord );
                    if(expressionRecord.Expression_Detail__r.size() > 0) {
                        expressionWrapper.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                        for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                            expressionWrapper.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                        }
                    }
                    expressions.add(expressionWrapper);
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() : Retrieved all Configuration Filters' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationFilters() : Failed to retrieve Configuration Filters. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - exit; expressions.size()= ' + expressions.size() );
        }
        
        return expressions;
    }
    
    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public List<Adm.Expression> getAllExpressionsWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllExpressionsWithDetails() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();
        
        try {
            
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getAllExpressionRecordsWithDetails();
            
            if( expressionRecordList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    Adm.Expression expressionWrapper = createExpression( expressionRecord );
                    if(expressionRecord.Expression_Detail__r.size() > 0) {
                        expressionWrapper.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                        for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                            expressionWrapper.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                        }
                    }
                    expressions.add(expressionWrapper);
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllExpressionsWithDetails() : Retrieved all expressions' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllExpressionsWithDetails() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllExpressionsWithDetails() - exit; expressions.size()= ' + expressions.size() );
        }
        
        return expressions;
    }

    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public Adm.Expression getExpressionsWithDetails(String expressionId) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - enter' );
        
        Adm.Expression expression = new Adm.Expression();
        
        try {

            if( String.IsBlank(expressionId) ) {
                System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            Set<Id> expressionIds = new Set<Id>();
            expressionIds.add(expressionId);
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getExpressionRecordsWithDetails( expressionIds );
            
            if( expressionRecordList.size() > 0 ) {
                // Create expression wrapper for each expression retrieved.
                expression = createExpression( expressionRecordList[0] );
                if( expressionRecordList[0].Expression_Detail__r.size() > 0 ) {
                    expression.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                    for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecordList[0].Expression_Detail__r ) {
                        expression.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                    }
                }
                if(expression.expressionType == 'CONFIGURATION-FILTER') {
                    List<SVMXA360__CONF_ConfigurationFilter__c> configurationFilterList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__FilterCriteriaId__c, SVMXA360__FilterTags__c, SVMXA360__Columns__c FROM SVMXA360__CONF_ConfigurationFilter__c where SVMXA360__FilterCriteriaId__c =: expression.id]);
                    if(configurationFilterList.size() > 0 && configurationFilterList[0].id != null ) {
                        expression.selectedTagsValue = configurationFilterList[0].SVMXA360__FilterTags__c;
                    } else {
                        expression.selectedTagsValue = '';
                    }
                }
                
            } else {
                System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            
            System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() : Retrieved all expressions' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - exit; expression = ' + expression );
        }
        
        return expression;
    }

    /**
     * This method is used to retrieve all the expression headers configured.
     */
    public Map<Id,Adm.Expression> getExpressionsWithDetails(List<String> expressionIds, String objectAPIName) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - enter' );
        
        Adm.Expression expression = new Adm.Expression();
        Map<Id,Adm.Expression> expressionMap = new Map<Id,Adm.Expression>();
        Map<Id,SVMXA360__CONF_Expression__c> expressionRecMap;
        
        try {

            if( expressionIds.isEmpty() && String.isBlank(objectAPIName)) {
                System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            if( !expressionIds.isEmpty() ) {
                expressionRecMap = new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionIds));
            } else {
                expressionRecMap = new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(objectAPIName,COMM_EXPRESSION));
            }
            SVMXA360__CONF_Expression__c expressionRecord = new SVMXA360__CONF_Expression__c();
            for( Id expressionId : expressionRecMap.keyset()) {
                expressionRecord = expressionRecMap.get(expressionId);
                expression = createExpression( expressionRecord );
                if( expressionRecord.Expression_Detail__r.size() > 0 ) {
                    expression.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                    for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                        expression.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                    }
                }
                expressionMap.put(expressionId,expression);
            }
            
            System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() : Retrieved all expressions' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getExpressionsWithDetails() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsWithDetails() - exit; expression = ' + expression );
        }
        
        return expressionMap;
    }

    /**
     * This method is used to retrieve all the expression by object and Type
     */
    public List<Adm.Expression> getExpressionsByType(final String objectAPIName, final String expressionType) {
        System.debug( LoggingLevel.DEBUG, 'getExpressionsByType() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();    

        try {
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getExpressionRecordsWithDetails(objectAPIName,expressionType);

            if( !expressionRecordList.isEmpty() ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    Adm.Expression expressionWrapper = createExpression( expressionRecord );
                    if(expressionRecord.Expression_Detail__r.size() > 0) {
                        expressionWrapper.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                        for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                            expressionWrapper.expressionDetailList.add( createDetailExpression( expressionDetailRecord ) );
                        }
                    }
                    expressions.add(expressionWrapper);
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getExpressionsByType() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsByType() - exit; expression = ' + expressions );
        }
        
        return expressions;
    }

    public Map<Id,Adm.Expression> getExpressionCriteriaDetails(List<String> expressionIds) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() - enter' );
        
        Adm.Expression expression = new Adm.Expression();
        Map<Id,Adm.Expression> expressionMap = new Map<Id,Adm.Expression>();
        Map<Id,SVMXA360__CONF_Expression__c> expressionRecMap;
        
        try {
            
            if( expressionIds.isEmpty()) {
                System.debug( LoggingLevel.ERROR, 'getExpressionCriteriaDetails() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            expressionRecMap = new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionIds));

            SVMXA360__CONF_Expression__c expressionRecord = new SVMXA360__CONF_Expression__c();
            for( Id expressionId : expressionRecMap.keyset()) {
                expressionRecord = expressionRecMap.get(expressionId);
                expression = new Adm.Expression();
                expression.advancedExpression = expressionRecord.SVMXA360__AdvancedExpression__c;
                if( expressionRecord.Expression_Detail__r.size() > 0 ) {
                    expression.expressionDetailList = new List<Adm.ExpressionDetail>(); 
                    for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionRecord.Expression_Detail__r ) {
                        Adm.ExpressionDetail expressionDetailWrapper = new Adm.ExpressionDetail();

                        expressionDetailWrapper.fieldAPIName = expressionDetailRecord.SVMXA360__FieldAPIName__c;
                        expressionDetailWrapper.operator = expressionDetailRecord.SVMXA360__Operator__c;
                        expressionDetailWrapper.operand = expressionDetailRecord.SVMXA360__Operand__c;
                        expressionDetailWrapper.sequence = Integer.Valueof(expressionDetailRecord.SVMXA360__Sequence__c);
                        expressionDetailWrapper.operandType = expressionDetailRecord.SVMXA360__OperandType__c;
                        expressionDetailWrapper.fieldType = expressionDetailRecord.SVMXA360__FieldType__c;
                        expressionDetailWrapper.literalParameterAPIName = expressionDetailRecord.SVMXA360__LiteralParameter__c;
                        expressionDetailWrapper.literalRelatedObjectDetails = expressionDetailRecord.SVMXA360__LiteralRelatedObjectDetails__c;
                        expressionDetailWrapper.relatedObjectDetails = expressionDetailRecord.SVMXA360__RelatedObjectDetails__c;
                        expressionDetailWrapper.relationshipName = expressionDetailRecord.SVMXA360__RelationshipName__c;
                        expressionDetailWrapper.relationshipFieldAPIName = expressionDetailRecord.SVMXA360__RelationshipFieldAPIName__c;
                        expressionDetailWrapper.sourceObjectName = expressionDetailRecord.SVMXA360__SourceObjectName__c;

                        expression.expressionDetailList.add( expressionDetailWrapper );

                    }
                }
                expressionMap.put(expressionId,expression);
            }
            
            System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() : Retrieved all expressions' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getExpressionCriteriaDetails() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionCriteriaDetails() - exit; expression = ' + expression );
        }
        
        return expressionMap;        
    }

    /**
     * This method is used to retrieve all the expression headers configured for an object.
     */
    public List<Adm.Expression> getExpressions( String objectName) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressions() - enter' );
        
        List<Adm.Expression> expressions = new List<Adm.Expression>();
        
        try {
            
            // Retrieve all expressions
            List<SVMXA360__CONF_Expression__c> expressionRecordList = getExpressionRecordsByObject(objectName);
            
            if( expressionRecordList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    expressions.add( createExpression( expressionRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getExpressions() : Retrieved all expressions for an Object' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getExpressions() : Failed to retrieve expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressions() - exit; expressions.size()= ' + expressions.size() );
        }
        
        return expressions;
    }
    
    /**
     * This method is used to retrieve all the expression details configured for an expression.
     */ 
    public List<Adm.ExpressionDetail> getExpressionDetails( String expressionId) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - enter' );
        
        List<Adm.ExpressionDetail> expressionDetails = new List<Adm.ExpressionDetail>();
        
        try {
            
            // Retrieve all expressions
            List<SVMXA360__CONF_ExpressionDetail__c> expressionDetailList = getExpressionDetailRecords(expressionId);
            
            if( expressionDetailList.size() > 0 ) {
                
                // Create expression wrapper for each expression retrieved.
                for( SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord : expressionDetailList ) {
                    expressionDetails.add( createDetailExpression( expressionDetailRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() : Retrieved all expression details' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getExpressionDetail() : Failed to retrieve expression detail. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionDetail() - exit; expressionDetails.size()= ' + expressionDetails.size() );
        }
        
        return expressionDetails;
    }

    /**
     * This method is used to save/update expression and expression details.
     * 
     * @param expression Expresssion with list of expression details to be saved.
     */
    public Adm.Expression saveExpression( Adm.Expression expression ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveExpression() - enter; expression= ' + expression );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid expression informations.
            if( expression == null || expression.name == null || String.isBlank(expression.objectAPIName ) ||
                expression.expressionDetailList == null || expression.expressionDetailList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveExpression() : Invalid request parameters. expression= ' + expression );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            for( Adm.ExpressionDetail expressionDetail : expression.expressionDetailList ) {
                if(expressionDetail.fieldAPIName == null || expressionDetail.operator == null || expressionDetail.sequence == null){
                    System.debug( LoggingLevel.ERROR, 'saveExpression() : Invalid Qualifying Criteria. expression= ' + expression );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_QUALIFYING_CRITERIA );
                }
            }

            Set<String> fieldNamesSet = new Set<String>();
            List<String> fieldNames = new List<String>();
            // Upsert expression record.
            SVMXA360__CONF_Expression__c expressionRecord = (SVMXA360__CONF_Expression__c) SvmxDatabase.upsertRecord(createExpressionRecord(expression));
            
            System.debug( LoggingLevel.INFO, 'saveExpression() : Saved Expression record. Name= ' + expressionRecord.Name );
            
            Map<String, SVMXA360__CONF_ExpressionDetail__c> oldExpressionDetailMap = new Map<String, SVMXA360__CONF_ExpressionDetail__c>();
            
            // Retrieve all existing expression detail records for requested expression. 
            // Retrieve only if the expression exists.
            if( String.isNotBlank( expression.id ) != null ) {
                oldExpressionDetailMap.putAll( [SELECT Id FROM SVMXA360__CONF_ExpressionDetail__c WHERE SVMXA360__ExpressionId__c = :expression.id ]);
            }
            if(expression.expressionType == 'CONFIGURATION-FILTER') {
                List<SVMXA360__CONF_ConfigurationFilter__c> configurationFilterList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__FilterCriteriaId__c, SVMXA360__FilterTags__c, SVMXA360__Columns__c FROM SVMXA360__CONF_ConfigurationFilter__c where SVMXA360__FilterCriteriaId__c =: expressionRecord.id]);
                if(configurationFilterList != null && configurationFilterList.size() > 0 ) {
                    configurationFilterList.get(0).Name = expression.name;
                    configurationFilterList.get(0).SVMXA360__DeveloperName__c = expression.developerName;
                    configurationFilterList.get(0).SVMXA360__ObjectAPIName__c = expression.objectAPIName;
                    configurationFilterList.get(0).SVMXA360__FilterCriteriaId__c = expression.id;
                    configurationFilterList.get(0).SVMXA360__FilterTags__c = expression.selectedTagsValue;
                } else {
                    SVMXA360__CONF_ConfigurationFilter__c newConfigurationFilter = new SVMXA360__CONF_ConfigurationFilter__c();
                    newConfigurationFilter.Name = expressionRecord.name;
                    newConfigurationFilter.SVMXA360__DeveloperName__c = expressionRecord.SVMXA360__DeveloperName__c;
                    newConfigurationFilter.SVMXA360__ObjectAPIName__c = expressionRecord.SVMXA360__ObjectAPIName__c;
                    newConfigurationFilter.SVMXA360__FilterCriteriaId__c = expressionRecord.id;
                    newConfigurationFilter.SVMXA360__FilterTags__c = expression.selectedTagsValue;
                    configurationFilterList.add(newConfigurationFilter);
                }
                SvmxDatabase.upsertRecord(configurationFilterList);
            }
            
            // Verify expression details, throw exception if not exists.
            if( expression.expressionDetailList != null && expression.expressionDetailList.size() > 0 ) {
                
                // Create expression detail sobject for each detail in request
                List<SVMXA360__CONF_ExpressionDetail__c> expressionDetailRecordList = new List<SVMXA360__CONF_ExpressionDetail__c>();
                for( Adm.ExpressionDetail expressionDetail : expression.expressionDetailList ) {

                    String lastObjectAPIName = '';
                    if ( String.isBlank(expressionDetail.relatedObjectDetails) ) {
                        lastObjectAPIName = expression.objectAPIName;
                    } else if (String.isNotBlank(expressionDetail.relatedObjectDetails) && expressionDetail.relatedObjectDetails.contains('.')) {
                        lastObjectAPIName = expressionDetail.relatedObjectDetails.substringAfterLast('.');
                    } else {
                        lastObjectAPIName = expressionDetail.relatedObjectDetails;
                    }

                    if (!recordTypeMap.containsKey(lastObjectAPIName)) {
                        recordTypeMap.put(lastObjectAPIName, COMM_MetadataManager.getInstance().getRecordTypeDetails(lastObjectAPIName));
                    }

                    // Populating the expression Id to the detail wrapper
                    expressionDetail.expressionId = expressionRecord.Id;

                    if(String.isNotBlank(expressionDetail.fieldAPIName) && expressionDetail.sourceObjectName != 'User') {
                        fieldNamesSet.add(expressionDetail.fieldAPIName);    
                    }
                    if (expressionDetail.fieldAPIName.endsWith('RecordTypeId') && expressionDetail.operandType == 'Value') {
                        
                        if ( operatorList.contains(expressionDetail.operator) ) {

                            expressionDetail.relationshipFieldAPIName = 'Name';

                        } else {

                            for (Common.RecordType recordType : recordTypeMap.get(lastObjectAPIName)) {
                            
                                if(recordType.name == expressionDetail.operand ) {
                                    expressionDetail.operand = recordType.developerName;
                                    expressionDetail.relationshipFieldAPIName = 'DeveloperName';
                                    break;
                                } 
                            }

                        }
                        
                    }
                    
                    // Create expression detail sObject
                    SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord = createExpressionDetailSObject( expressionDetail );
                    
                    expressionDetailRecordList.add(expressionDetailRecord);
                    
                    // remove detail record from existing record list if found in request.
                    if( oldExpressionDetailMap.containsKey( expressionDetailRecord.Id ) ) {
                        oldExpressionDetailMap.remove( expressionDetailRecord.Id );
                    }
                }
                
                // Upsert all expression detail records
                expressionDetailRecordList = SvmxDatabase.upsertRecord(expressionDetailRecordList);
                
                System.debug( LoggingLevel.INFO, 'saveExpression() : Saved Expression Detail records. Name= ' + expressionRecord.Id );
                
                // Delete object mapping detail records which is removed in request.
                if( oldExpressionDetailMap.size() > 0 ) {
                    SvmxDatabase.deleteRecord(oldExpressionDetailMap.values());
                }
                
                // Update Id's for expression and expression mapping details in response
                expression.id = expressionRecord.id;
                for( Integer index = 0; index < expressionDetailRecordList.size(); index++ ) {
                    expression.expressionDetailList.get(index).id = expressionDetailRecordList.get(index).id;
                }

                //Populate Comma Seperated Field Names in Expression Fields
                fieldNames.addAll(fieldNamesSet);
                expressionRecord.SVMXA360__ExpressionFields__c = string.join(fieldNames,',');
                expressionRecord.SVMXA360__ExpressionJSON__c = JSON.serialize(expression);
                SvmxDatabase.upsertRecord(expressionRecord);

            } else {
                System.debug( LoggingLevel.ERROR, 'saveExpression() : Invalid request parameters. expression= ' + expression );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveExpression() : Failed to save Expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveExpression() : Failed to save Expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveExpression() - exit; expression= ' + expression );
        }
        
        return expression;
    }
    
    /**
     * This method is used to save/update expression and expression details.
     * 
     * @param expression Expresssion with list of expression details to be saved.
     */
    public List<Adm.Expression> saveExpressions( final List<Adm.Expression> expressionList ) {
        return saveExpressions( expressionList, true );
    }
    
    /**
     * This method is used to save/update expression and expression details.
     * 
     * @param expression Expresssion with list of expression details to be saved.
     */
    public List<Adm.Expression> saveExpressions( final List<Adm.Expression> expressionList, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveExpressions() - enter; expressionList= ' + expressionList );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid expression informations.
            if( expressionList == null || expressionList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveExpressions() : Invalid request parameters. expression= ' + expressionList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            Set<String> fieldNamesSet = new Set<String>();
            List<String> fieldNames = new List<String>();
            
            // Upsert expression record.
            List<SVMXA360__CONF_Expression__c> expressionRecordList = (List<SVMXA360__CONF_Expression__c>) SvmxDatabase.upsertRecord( createExpressionRecords(expressionList), allOrNothing );
            
            Map<Id, SVMXA360__CONF_Expression__c> expressionRecordMap = new Map<Id, SVMXA360__CONF_Expression__c>();
            expressionRecordMap.putAll( expressionRecordList );
            
            Map<String, SVMXA360__CONF_ExpressionDetail__c> oldExpressionDetailMap = new Map<String, SVMXA360__CONF_ExpressionDetail__c>();
            
            // Retrieve all existing expression detail records for requested expression.
            oldExpressionDetailMap.putAll( [SELECT Id FROM SVMXA360__CONF_ExpressionDetail__c WHERE SVMXA360__ExpressionId__c IN :expressionRecordMap.keySet()]);
            
            List<SVMXA360__CONF_ExpressionDetail__c> expressionDetailRecordList = new List<SVMXA360__CONF_ExpressionDetail__c>();
            Map<Id, List<SVMXA360__CONF_ExpressionDetail__c>> expressionDetailRecordListMap = new Map<Id, List<SVMXA360__CONF_ExpressionDetail__c>>();
            for( Integer index = 0; index < expressionList.size(); index++ ) {
                
                final Adm.Expression expression = expressionList.get(index);
                final SVMXA360__CONF_Expression__c expressionRecord = expressionRecordList.get(index);
                final List<SVMXA360__CONF_ExpressionDetail__c> singleExpressionDetailRecordList = new List<SVMXA360__CONF_ExpressionDetail__c>();
                
                expression.id = expressionRecord.id;
                
                // Verify expression details, throw exception if not exists.
                if( expression.expressionDetailList != null && expression.expressionDetailList.size() > 0 ) {
                    
                    // Create expression detail sobject for each detail in request
                    
                    for( Adm.ExpressionDetail expressionDetail : expression.expressionDetailList ) {
                        
                        // Populating the expression Id to the detail wrapper
                        expressionDetail.expressionId = expressionRecord.Id;
                        
                        if(String.isNotBlank(expressionDetail.fieldAPIName)) {
                            fieldNamesSet.add(expressionDetail.fieldAPIName);    
                        }

                        String lastObjectAPIName = '';
                        if ( String.isBlank(expressionDetail.relatedObjectDetails) ) {
                            lastObjectAPIName = expression.objectAPIName;
                        } else if (String.isNotBlank(expressionDetail.relatedObjectDetails) && expressionDetail.relatedObjectDetails.contains('.')) {
                            lastObjectAPIName = expressionDetail.relatedObjectDetails.substringAfterLast('.');
                        } else {
                            lastObjectAPIName = expressionDetail.relatedObjectDetails;
                        }

                        if (!recordTypeMap.containsKey(lastObjectAPIName)) {
                            recordTypeMap.put(lastObjectAPIName, COMM_MetadataManager.getInstance().getRecordTypeDetails(lastObjectAPIName));
                        }
                        
                        if (expressionDetail.fieldAPIName.endsWith('RecordTypeId') && expressionDetail.operandType == 'Value') {
                        
                            if ( operatorList.contains(expressionDetail.operator) ) {

                                expressionDetail.relationshipFieldAPIName = 'Name';
                            
                            } else {

                                for (Common.RecordType recordType : recordTypeMap.get(lastObjectAPIName)) {
                                
                                    if(recordType.name == expressionDetail.operand ) {
                                        expressionDetail.operand = recordType.developerName;
                                        expressionDetail.relationshipFieldAPIName = 'DeveloperName';
                                        break;
                                    } 
                                }

                            }
                        
                        }
                        // Create expression detail sObject
                        SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord = createExpressionDetailSObject( expressionDetail );
                        
                        expressionDetailRecordList.add(expressionDetailRecord);
                        singleExpressionDetailRecordList.add(expressionDetailRecord);
                        
                        // remove detail record from existing record list if found in request.
                        if( oldExpressionDetailMap.containsKey( expressionDetailRecord.Id ) ) {
                            oldExpressionDetailMap.remove( expressionDetailRecord.Id );
                        }
                    }
                    
                    expressionDetailRecordListMap.put( expression.id, singleExpressionDetailRecordList);
                }
            }
            
            // Upsert all expression detail records
            expressionDetailRecordList = SvmxDatabase.upsertRecord(expressionDetailRecordList, allOrNothing);
            
            // Delete object mapping detail records which is removed in request.
            if( oldExpressionDetailMap.size() > 0 ) {
                SvmxDatabase.deleteRecord(oldExpressionDetailMap.values());
            }
            
            for( Adm.Expression expression :  expressionList ) {
                
                final List<SVMXA360__CONF_ExpressionDetail__c> singleExpressionDetailRecordList = expressionDetailRecordListMap.get(expression.id);
                
                // Update Id's for expression and expression mapping details in response
                for( Integer index = 0; index < singleExpressionDetailRecordList.size(); index++ ) {
                    expression.expressionDetailList.get(index).id = singleExpressionDetailRecordList.get(index).id;
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveExpressions() : Failed to save Expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveExpressions() : Failed to save Expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveExpressions() - exit; expressionList= ' + expressionList.size() );
        }
        
        return expressionList;
    }

   /**
     * This method is used to delete expression and expression detail records 
     * for requested expression id.
     */
    public void deleteExpression( String expressionId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteExpression() - enter; expressionId= ' + expressionId );
        
        try {
            // Verify for valid expression id.
            if( String.isBlank( expressionId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Invalid request parameters. expressionId= ' + expressionId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            List<SVMXA360__CONF_ConfigurationFilter__c> configurationFilterList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__FilterCriteriaId__c FROM SVMXA360__CONF_ConfigurationFilter__c where SVMXA360__FilterCriteriaId__c = :String.escapeSingleQuotes(expressionId)]);
            if(configurationFilterList.size() > 0 && configurationFilterList[0].id != null ) {
                SvmxDatabase.deleteRecord(configurationFilterList[0]); 
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_Expression__c WHERE Id = :String.escapeSingleQuotes(expressionId) ] );
            
            System.debug( LoggingLevel.INFO, 'deleteExpression() : Expression and details removed successfully. expressionId= ' + expressionId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to delete expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to delete expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteExpression() - exit');
        }
    }
    
    /**
     * This method is used to validate expression and expression details.
     * 
     * @param expression Expresssion with list of expression details to be validated.
     */
    public Adm.ValidationResult validateExpression( Adm.Expression expression ) {
        return validateExpressions( new List<Adm.Expression>{expression}).get(0);
    }
    
    /**
     * This method is used to validate expression and expression details.
     * 
     * @param expressions List of expresssions with expression details to be validated.
     */
    public List<Adm.ValidationResult> validateExpressions( List<Adm.Expression> expressionList ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateExpressions() - enter');
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            
            for( Adm.Expression expression : expressionList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.Expression );
                validationResults.add( validationResult );
                
                // Verify request for valid expression informations.
                if( expression == null || String.isBlank(expression.objectAPIName ) || expression.expressionDetailList == null || expression.expressionDetailList.size() == 0 ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateExpressions() : Invalid request parameters. expression= ' + expression );
                    validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER);
                    
                    continue;
                }
                
                if( !entityDefinitionMap.containsKey(expression.objectAPIName) ) {
                    
                    try {
                        final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(expression.objectAPIName);
                        entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                    }
                    catch( SvmxSystem.SvmxNestedException e ) {
                        
                        validationResult.setError('Object does not exists: ' + expression.objectAPIName); //TODO Create custom label
                        continue;
                    }
                }
                
                validateCriteria( expression, validationResult, entityDefinitionMap );
            }
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateExpressions() : Failed to validate Expression. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateExpressions() : Failed to validate Expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateExpressions() - exit');
        }
        
        return validationResults;
    }
    
    private Boolean validateCriteria( final Adm.Expression expression, final Adm.ValidationResult validationResult, final Map<String,Common.EntityDefinition> entityDefinitionMap ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateCriteria() - enter; expression= ' + expression );
        
        Boolean isValid = true;
        
        try {
            // Verify expression details, throw exception if not exists.
            if( expression.expressionDetailList == null || expression.expressionDetailList.size() == 0 ) {
                
                isValid = false;
                validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER );
                
                return isValid;
            }
            
            for( Adm.ExpressionDetail expressionDetail : expression.expressionDetailList ) {
                
                if( String.isBlank(expressionDetail.fieldAPIName) || String.isBlank(expressionDetail.operator) || expressionDetail.sequence == null) {
                    
                    isValid = false;
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, ErrorMessage.INVALID_QUALIFYING_CRITERIA, expressionDetail ) );
                    continue;
                }
                
                if( expressionDetail.fieldAPIName.endsWith('RecordTypeId') && expressionDetail.operandType == 'Value' && !operatorList.contains(expressionDetail.operator) ) {
                    
                    String objectAPIName = expression.objectAPIName;
                    if (String.isNotBlank(expressionDetail.relatedObjectDetails) ) {
                        objectAPIName = expressionDetail.relatedObjectDetails.contains('.') ? expressionDetail.relatedObjectDetails.substringAfterLast('.') : expressionDetail.relatedObjectDetails;
                    }
                    
                    if( expressionDetail.relationshipFieldAPIName == 'DeveloperName' ) {
                        
                        if( !COMM_RecordTypeManager.getInstance().hasRecordTypeDeveloperName( objectAPIName, expressionDetail.operand ) ) {
                            
                            isValid = false;
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, 'Object :' + objectAPIName + ', Record Type does not exists :' + expressionDetail.operand, expressionDetail ) );
                            continue;
                        }
                    } else if( expressionDetail.relationshipFieldAPIName == 'Name' ) {
                        
                        if( !COMM_RecordTypeManager.getInstance().hasRecordTypeName( objectAPIName, expressionDetail.operand ) ) {
                            
                            isValid = false;
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, 'Object :' + objectAPIName + ', Record Type does not exists :' + expressionDetail.operand, expressionDetail ) );
                            continue;
                        }
                    }
                }
                
                isValid = validateExpressionFields( expression, expressionDetail, entityDefinitionMap, validationResult );
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateCriteria() - exit; isValid= ' + isValid );
        }
        
        return isValid;
    }
    
    private Boolean validateExpressionFields( final Adm.Expression expression, final Adm.ExpressionDetail expressionDetail, final Map<String,Common.EntityDefinition> entityDefinitionMap, final Adm.ValidationResult validationResult ) {
        
        Boolean isValid = true;
        String fieldAPIName = expressionDetail.fieldAPIName;
        
        Common.EntityDefinition entityDefinition = entityDefinitionMap.get(expression.objectAPIName);
        
        if( String.isNotBlank(expressionDetail.sourceObjectName) && !entityDefinitionMap.containsKey(expressionDetail.sourceObjectName) ) {
            
            try {
                final Common.EntityDefinition sourceEntityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(expressionDetail.sourceObjectName);
                entityDefinitionMap.put( sourceEntityDefinition.apiName, sourceEntityDefinition );
            }
            catch( SvmxSystem.SvmxNestedException e ) {
                
                validationResult.setError('Source Object does not exists: ' + expression.objectAPIName);
                return false;
            }
        }
        
        if( String.isNotBlank(expressionDetail.sourceObjectName) ) {
            entityDefinition = entityDefinitionMap.get(expressionDetail.sourceObjectName);
        }
        
        if( fieldAPIName.indexOf('.') != -1 ) {
            
            final List<String> referenceObjects = expressionDetail.fieldAPIName.split('\\.');
            if( referenceObjects.size() > 0 ) {
                fieldAPIName = referenceObjects[ referenceObjects.size() - 1 ];
            }
            
            for ( String referenceObject : referenceObjects ) {
                
                String objectName = referenceObject;
                
                if ( fieldAPIName != referenceObject ) {
                    
                    if ( referenceObject.endsWith('__r') ) {
                        objectName = referenceObject.replace('__r', '__c');
                    }
                    
                    Common.FieldDefinition fieldDefinition = entityDefinition.fieldDefinitionsByApiName.containsKey(objectName.toLowerCase()) 
                        ? entityDefinition.fieldDefinitionsByApiName.get(objectName.toLowerCase())
                        : entityDefinition.fieldDefinitionsByApiName.get(objectName.toLowerCase() + 'id' );
                    
                    if( fieldDefinition == null ) {
                        
                        isValid = false;
                        System.debug( LoggingLevel.ERROR, 'validateCriteria() - Object : '+ entityDefinition.label + ', Field does not exists : ' + objectName );
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + objectName ) );
                        break;
                    }
                    
                    objectName = fieldDefinition.referenceTo[ fieldDefinition.referenceTo.size() - 1 ];
                    
                    if ( !entityDefinitionMap.containsKey(objectName) ) {
                        
                        try {
                            final Common.EntityDefinition referenceEntityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(objectName);
                            entityDefinitionMap.put( referenceEntityDefinition.apiName, referenceEntityDefinition );
                        }
                        catch( SvmxSystem.SvmxNestedException e ) {
                            
                            isValid = false;
                            System.debug( LoggingLevel.ERROR, 'validateCriteria() - Object does not exists : '+ objectName );
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, 'Object does not exists : '+ objectName ) ); //TODO Create custom label
                            break;
                        }
                    }
                    
                    entityDefinition = entityDefinitionMap.get(objectName);
                }
            }
        }
        
        if( entityDefinition != null ) {
            
            if( !entityDefinition.fieldDefinitionsByApiName.containsKey( fieldAPIName.toLowerCase() ) ) {
                
                System.debug( LoggingLevel.ERROR, 'validateCriteria() - Object : '+ entityDefinition.label + ', Field does not exists : ' + fieldAPIName );
                
                isValid = false;
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + fieldAPIName ) );
            } else {
                
                final Common.FieldDefinition fieldDefinition = entityDefinition.fieldDefinitionsByApiName.get( fieldAPIName.toLowerCase() ); 
                final String objectName = (fieldDefinition.referenceTo != null ) ? fieldDefinition.referenceTo[ fieldDefinition.referenceTo.size() - 1 ] : expression.objectAPIName;
                
                if( String.isNotBlank(expressionDetail.relationshipFieldAPIName) ) {
                    fieldAPIName = expressionDetail.relationshipFieldAPIName;
                }
                
                if ( String.isNotBlank(fieldAPIName) && String.isNotBlank(expressionDetail.operand) && expressionDetail.fieldType == 'REFERENCE' && expressionDetail.fieldAPIName != 'RecordTypeId' && expressionDetail.operandType == 'Value' && expressionDetail.operator == 'eq') {
                    
                    List<SObject> records = SvmxDatabase.query( 'SELECT Id FROM ' + objectName + ' WHERE ' + fieldAPIName + '=\'' + expressionDetail.operand + '\' LIMIT 1' );
                    if ( records.size() == 0 ) {
                        System.debug( LoggingLevel.ERROR, 'validateCriteria() - Object : '+ entityDefinition.label + ', Field does not exists : ' + fieldAPIName );
                        
                        isValid = false;
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, 'Lookup value : ' + expressionDetail.operand + ' does not exists in Target Org for Object ' + objectName ) );
                    }
                }
            }
        }
        
        return isValid;
    }
    
    /**
     * This public method executes the query to return all the expressions 
     */
    public List<SVMXA360__CONF_Expression__c> getAllExpressionRecords() {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c, SVMXA360__Criteria__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__DeveloperName__c, SVMXA360__Type__c, SVMXA360__ExpressionType__c, SVMXA360__HeaderRecordObject__c
                                   FROM SVMXA360__CONF_Expression__c where SVMXA360__ExpressionType__c = :COMM_EXPRESSION order by Name]);
    }

    public List<SVMXA360__CONF_Expression__c> getAllRuleExpressionRecords() {
        
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c, SVMXA360__Criteria__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, 
                                    SVMXA360__Sequence__c, SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelationshipName__c,
                                    SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                    FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c where SVMXA360__ExpressionType__c = :EVER_RULE_CRITERIA order by Name]);
    }
    
    public List<SVMXA360__CONF_Expression__c> getAllVisibilityCriteriaRecords() {
        
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c, SVMXA360__Criteria__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, 
                                    SVMXA360__Sequence__c, SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelationshipName__c,
                                    SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                    FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c where SVMXA360__ExpressionType__c = :VISIBILITY_RULE_CRITERIA order by Name]);
    }
    
    public List<SVMXA360__CONF_Expression__c> getAllConfigurationFilterRecords() {
        
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c, SVMXA360__Criteria__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, 
                                    SVMXA360__Sequence__c, SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelationshipName__c,
                                    SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                    FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c where SVMXA360__ExpressionType__c = :CONFIGURATION_FILTER order by Name]);
    }
    
    /**
     * This public method executes the query to return all the expressions 
     */
    public List<SVMXA360__CONF_Expression__c> getAllExpressionRecordsWithDetails() {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c, SVMXA360__Criteria__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, 
                                    SVMXA360__Sequence__c, SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelationshipName__c, 
                                    SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                    FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c]);
    }

    /**
     * This public method executes the query to return all the expressions for the given expression Ids 
     */
    public List<SVMXA360__CONF_Expression__c> getExpressionRecordsWithDetails(Set<Id> expressionIds) {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__Criteria__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, SVMXA360__Sequence__c, 
                                   SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelationshipName__c, 
                                   SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                   FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c where Id In :expressionIds
                                   OR SVMXA360__DeveloperName__c In :expressionIds]);
    }

    /**
     * This public method executes the query to return all the expressions for the given expression Ids 
     */
    public List<SVMXA360__CONF_Expression__c> getExpressionRecordsWithDetails(List<String> expressionIds) {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__Criteria__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, SVMXA360__Sequence__c, 
                                   SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelationshipName__c, 
                                   SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                   FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c where Id In :expressionIds
                                   OR SVMXA360__DeveloperName__c In :expressionIds]);
    }
    
    /**
     * This public method executes the query to return all the expressions for the given object name and expression type 
     */
    public List<SVMXA360__CONF_Expression__c> getExpressionRecordsWithDetails( final String objectAPIName, final String expressionType ) {
        
        System.debug( LoggingLevel.DEBUG, 'getExpressionRecordsWithDetails() - enter; objectAPIName= ' + objectAPIName + '; expressionType= ' + expressionType );
        
        List<SVMXA360__CONF_Expression__c> expressionList = new List<SVMXA360__CONF_Expression__c>();
        try {
            
            // Verify source object name and expression type.
            if( String.isBlank(objectAPIName) ) {
             
                System.debug( LoggingLevel.ERROR, 'getExpressionRecordsWithDetails() : Invalid request parameters.objectAPIName= ' + objectAPIName + '; expressionType= ' + expressionType );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            if( String.isBlank(expressionType) ) {
                expressionList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__Criteria__c, SVMXA360__HeaderRecordObject__c,
                                   (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, SVMXA360__Sequence__c, 
                                   SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c, SVMXA360__RelationshipName__c, 
                                   SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                    FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                   FROM SVMXA360__CONF_Expression__c where SVMXA360__ObjectAPIName__c = :objectAPIName]);
            } else {
                expressionList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c,
                                    LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__Criteria__c, SVMXA360__HeaderRecordObject__c,
                                    (SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c,  SVMXA360__Operator__c, SVMXA360__Sequence__c, 
                                    SVMXA360__OperandType__c, SVMXA360__FieldType__c, SVMXA360__RelationshipFieldAPIName__c, SVMXA360__RelationshipName__c, 
                                    SVMXA360__RelatedObjectDetails__c, SVMXA360__ReferenceFieldLabel__c, SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c 
                                        FROM Expression_Detail__r order by SVMXA360__Sequence__c) 
                                    FROM SVMXA360__CONF_Expression__c where SVMXA360__ObjectAPIName__c = :objectAPIName AND SVMXA360__ExpressionType__c = :expressionType]);
            }
            
        }
        
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionRecordsWithDetails() : Failed to retrieve expression details. Error= ' + e.getMessage() );
            throw e;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteExpression() : Failed to delete expression. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionRecordsWithDetails() - exit' );
        }
        
        return expressionList;
    }

    /**
     * This public method executes the query to return all the expressions for a given object
     */
    public List<SVMXA360__CONF_Expression__c> getExpressionRecordsByObject(String objectAPIName) {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__AdvancedExpression__c, SVMXA360__Description__c, SVMXA360__ObjectAPIName__c, SVMXA360__Criteria__c,
                                   LastModifiedDate, LastModifiedBy.Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__ExpressionType__c, SVMXA360__HeaderRecordObject__c
                                   FROM SVMXA360__CONF_Expression__c where SVMXA360__ObjectAPIName__c = :objectAPIName AND 
                                   SVMXA360__ExpressionType__c = :COMM_EXPRESSION order by Name]);
    }

    /**
     * This public method executes the query to return all the expression detail for a given expression
     */
    public List<SVMXA360__CONF_ExpressionDetail__c> getExpressionDetailRecords(String expressionId) {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__ExpressionId__c, SVMXA360__FieldAPIName__c,SVMXA360__Operand__c, SVMXA360__Operator__c,SVMXA360__Sequence__c,
                                   SVMXA360__OperandType__c, SVMXA360__FieldType__c,SVMXA360__RelationshipName__c,SVMXA360__RelationshipFieldAPIName__c,SVMXA360__RelatedObjectDetails__c,SVMXA360__ReferenceFieldLabel__c,
                                   SVMXA360__LiteralParameter__c, SVMXA360__LiteralRelatedObjectDetails__c, SVMXA360__SourceObjectName__c
                                   FROM SVMXA360__CONF_ExpressionDetail__c where SVMXA360__ExpressionId__c = :expressionId OR
                                   SVMXA360__ExpressionId__r.SVMXA360__DeveloperName__c = :expressionId order by SVMXA360__Sequence__c]);
    }

    /**
     * This public method executes the query to the expression for a given expressionId
     */
    public List<SVMXA360__CONF_Expression__c> getExpressionRecord(String expressionId) {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__Criteria__c, SVMXA360__ObjectAPIName__c FROM SVMXA360__CONF_Expression__c 
                                   where Id = :expressionId OR SVMXA360__DeveloperName__c = :expressionId]);
    }

    /**
     * This private method is used to create expression detail sobject 
     * for the requested wrapper structure.
     */
    private SVMXA360__CONF_ExpressionDetail__c createExpressionDetailSObject( Adm.ExpressionDetail expressionDetail ) {
        
        System.debug( LoggingLevel.FINE, 'createExpressionDetailSObject() - enter; expressionDetail= ' + expressionDetail );
        
        SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord = new SVMXA360__CONF_ExpressionDetail__c();
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( expressionDetail.fieldAPIName ) || String.isBlank( expressionDetail.operator ) 
                 || expressionDetail.sequence == null || String.isBlank( expressionDetail.fieldType ) ||
                 ( String.isNotBlank( expressionDetail.operator) && ( !expressionDetail.operator.equalsIgnoreCase('isnull') && 
                  !expressionDetail.operator.equalsIgnoreCase('isnotnull') && ( String.isBlank(expressionDetail.operandType) ||
                  String.isBlank(expressionDetail.operand) ) ) ) ) {
                
                System.debug( LoggingLevel.ERROR, 'createExpressionDetailSObject() : Invalid request parameters. expressionDetail= ' + expressionDetail );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            expressionDetailRecord = createExpressionDetailRecord(expressionDetail);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createExpressionDetailSObject() : Failed to create expression detail sobject. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createExpressionDetailSObject() - exit; record= ' + expressionDetailRecord );
        }
        
        return expressionDetailRecord;
    }

    /**
     * Private method to expression record.
     */
    private List<SVMXA360__CONF_Expression__c> createExpressionRecords( List<Adm.Expression> expressionList ) {
        
        List<SVMXA360__CONF_Expression__c> expressionRecordList = new List<SVMXA360__CONF_Expression__c>();
        
        Map<String, Id> developerNameIdMap = new Map<String, Id>();
        List<SVMXA360__CONF_Expression__c> expressions = SvmxDatabase.query([SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Expression__c]);
        for( SVMXA360__CONF_Expression__c expressionRuleRecord :  expressions ) {
            developerNameIdMap.put( expressionRuleRecord.SVMXA360__DeveloperName__c, expressionRuleRecord.id );
        }
        
        for( Adm.Expression expression: expressionList ) {
            
            if( developerNameIdMap.containsKey( expression.developerName ) ) {
                expression.id = developerNameIdMap.get(expression.developerName);
            }
            expressionRecordList.add( createExpressionRecord(expression) );
        }
        return expressionRecordList;
    }
    
    /**
     * Private method to expression record.
     */
    private SVMXA360__CONF_Expression__c createExpressionRecord( Adm.Expression expression ) {
        
        System.debug( LoggingLevel.FINE, 'createExpressionRecord() - enter; expression= ' + expression );
        
        SVMXA360__CONF_Expression__c expressionRecord = new SVMXA360__CONF_Expression__c();
        // Assign id field if object detail already exists. 
        // Assign Master Object id only for new records.
        if( expression.id != null ) {
            expressionRecord.Id = expression.id;
        } 
        
        if( String.isBlank(expression.developerName) ){
            expressionRecord.SVMXA360__DeveloperName__c = COMM_DeveloperName.createDeveloperName(Common.Application.Expression);
        } else {
            expressionRecord.SVMXA360__DeveloperName__c = expression.developerName;
        }
        Integer userLiteralCount = 0;
        Boolean isUserLiteralLHS = false;
        for (Adm.ExpressionDetail detail : expression.expressionDetailList) {
            if(detail.operand == 'User') {
                userLiteralCount++;
            }
            if(detail.sourceObjectName == 'User') {
                isUserLiteralLHS = true;
            }
        }
        //creating dummy sobject for current record header
        SObject objectRecord;
        expressionRecord.Name = expression.Name;
        expressionRecord.SVMXA360__Description__c = expression.description;
        expressionRecord.SVMXA360__ObjectAPIName__c = expression.objectAPIName;
        expressionRecord.SVMXA360__AdvancedExpression__c = expression.advancedExpression;
        expressionRecord.SVMXA360__Type__c = expression.Type;
        expressionRecord.SVMXA360__ExpressionType__c = expression.expressionType;
        expressionRecord.SVMXA360__HeaderRecordObject__c = expression.headerRecordObject;
        expressionRecord.SVMXA360__Criteria__c = expression.criteria;
        if( !SvmxSystem.isRunningPostInstall ) {
            if (expression.headerRecordObject != null || userLiteralCount > 0 || isUserLiteralLHS) {
                COMM_ExpressionUtils.getInstance().savingExpression = true;
                COMM_ExpressionUtils.getInstance().buildCriteria(expression, objectRecord);
                expressionRecord.SVMXA360__Criteria__c = COMM_ExpressionUtils.getInstance().queryClause;
            } else {
            	expressionRecord.SVMXA360__Criteria__c = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
            }
        }
        
        return expressionRecord;
    }

    /**
     * Private method to create expression wrapper from expression record.
     */
    private Adm.Expression createExpression( SVMXA360__CONF_Expression__c expressionRec ) {
        
        Adm.Expression expressionWrapper = new Adm.Expression();
        
        expressionWrapper.id = expressionRec.Id;
        expressionWrapper.name = expressionRec.Name;
        expressionWrapper.objectAPIName = expressionRec.SVMXA360__ObjectAPIName__c;
        expressionWrapper.description = expressionRec.SVMXA360__Description__c;
        expressionWrapper.advancedExpression = expressionRec.SVMXA360__AdvancedExpression__c;
        expressionWrapper.lastModifiedDate = expressionRec.LastModifiedDate;
        expressionWrapper.lastModifiedBy = expressionRec.LastModifiedBy.Name;
        expressionWrapper.type = expressionRec.SVMXA360__Type__c;
        expressionWrapper.developerName = expressionRec.SVMXA360__DeveloperName__c;
        expressionWrapper.expressionType = expressionRec.SVMXA360__ExpressionType__c;
        expressionWrapper.criteria = expressionRec.SVMXA360__Criteria__c;
        expressionWrapper.headerRecordObject = expressionRec.SVMXA360__HeaderRecordObject__c;
        return expressionWrapper;
    }

    /**
     * Public method to create Object mapping record.
     */
    public SVMXA360__CONF_ExpressionDetail__c createExpressionDetailRecord( Adm.ExpressionDetail expressionDetail ) {
        
        System.debug( LoggingLevel.FINE, 'createExpressionDetailRecord() - enter; expressionDetail= ' + expressionDetail );
        
        SVMXA360__CONF_ExpressionDetail__c expressionDetailRecord = new SVMXA360__CONF_ExpressionDetail__c();
        if( expressionDetail.id != null ) {
            expressionDetailRecord.Id = expressionDetail.id;
        } else {
            expressionDetailRecord.SVMXA360__ExpressionId__c = expressionDetail.expressionId;
        }
        
        expressionDetailRecord.SVMXA360__FieldAPIName__c = expressionDetail.fieldAPIName;
        expressionDetailRecord.SVMXA360__Operand__c = expressionDetail.operand;
        expressionDetailRecord.SVMXA360__Operator__c = expressionDetail.operator;
        expressionDetailRecord.SVMXA360__Sequence__c = expressionDetail.sequence;
        expressionDetailRecord.SVMXA360__OperandType__c = expressionDetail.operandType;
        expressionDetailRecord.SVMXA360__FieldType__c = expressionDetail.fieldType;
        expressionDetailRecord.SVMXA360__RelationshipName__c = expressionDetail.relationshipName;
        expressionDetailRecord.SVMXA360__RelationshipFieldAPIName__c = expressionDetail.relationshipFieldAPIName;
        expressionDetailRecord.SVMXA360__RelatedObjectDetails__c = expressionDetail.relatedObjectDetails;
        expressionDetailRecord.SVMXA360__ReferenceFieldLabel__c = expressionDetail.referenceFieldLabel;
        expressionDetailRecord.SVMXA360__LiteralParameter__c = expressionDetail.literalParameterAPIName;
        expressionDetailRecord.SVMXA360__LiteralRelatedObjectDetails__c = expressionDetail.literalRelatedObjectDetails;
        expressionDetailRecord.SVMXA360__SourceObjectName__c = expressionDetail.sourceObjectName;
        
        return expressionDetailRecord;
    }

    /**
     * Private method to create expression wrapper from expression record.
     */
    private Adm.ExpressionDetail createDetailExpression( SVMXA360__CONF_ExpressionDetail__c expressionDetailRec ) {
        
        Adm.ExpressionDetail expressionDetailWrapper = new Adm.ExpressionDetail();
        
        expressionDetailWrapper.id = expressionDetailRec.Id;
        expressionDetailWrapper.name = expressionDetailRec.Name;
        expressionDetailWrapper.expressionId = expressionDetailRec.SVMXA360__ExpressionId__c;
        expressionDetailWrapper.fieldAPIName = expressionDetailRec.SVMXA360__FieldAPIName__c;
        expressionDetailWrapper.operator = expressionDetailRec.SVMXA360__Operator__c;
        expressionDetailWrapper.operand = expressionDetailRec.SVMXA360__Operand__c;
        expressionDetailWrapper.sequence = Integer.Valueof(expressionDetailRec.SVMXA360__Sequence__c);
        expressionDetailWrapper.operandType = expressionDetailRec.SVMXA360__OperandType__c;
        expressionDetailWrapper.fieldType = expressionDetailRec.SVMXA360__FieldType__c;
        expressionDetailWrapper.relationshipName = expressionDetailRec.SVMXA360__RelationshipName__c;
        expressionDetailWrapper.relationshipFieldAPIName = expressionDetailRec.SVMXA360__RelationshipFieldAPIName__c;
        expressionDetailWrapper.relatedObjectDetails = expressionDetailRec.SVMXA360__RelatedObjectDetails__c;
        expressionDetailWrapper.referenceFieldLabel = expressionDetailRec.SVMXA360__ReferenceFieldLabel__c;
        expressionDetailWrapper.literalParameterAPIName = expressionDetailRec.SVMXA360__LiteralParameter__c;
        expressionDetailWrapper.literalRelatedObjectDetails = expressionDetailRec.SVMXA360__LiteralRelatedObjectDetails__c;
        expressionDetailWrapper.sourceObjectName = expressionDetailRec.SVMXA360__SourceObjectName__c;

        return expressionDetailWrapper;
    }
}