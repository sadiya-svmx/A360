@IsTest
public class ADM_ExpressionManager_UT {

    static testmethod void testgetAllExpressions() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression )
                                                                                                                        });
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        
            List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getAllExpressions();
            System.assert( expressions[0].id != null );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllRuleExpressions() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'EVER-RULE-CRITERIA';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        List<Adm.Expression> expressionList = ADM_ExpressionManager.getInstance().getAllRuleExpressions();
        System.assert( expressionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllVisibilityCriterias() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        //SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'VISIBILITY-RULE-CRITERIA';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        List<Adm.Expression> expressionList = ADM_ExpressionManager.getInstance().getAllVisibilityCriterias();
        System.assert( expressionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllConfigurationFilters() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'CONFIGURATION-FILTER';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        List<Adm.Expression> expressionList = ADM_ExpressionManager.getInstance().getAllConfigurationFilters();
        System.assert( expressionList.size() != 0 );
        
        Test.stopTest();
    }

    static testmethod void testgetAllExpressionsWithDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression )
                                                                                                                        });
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        
            List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getAllExpressionsWithDetails();
            System.assert( expressions[0].id != null );
        
        Test.stopTest();
    }

    static testmethod void testgetExpressionsForObject() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        
            List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
            System.assert( expressions[0].id != null );
        
        Test.stopTest();
    }

    static testmethod void testRetrieveExpression() { 
        
        Test.startTest();
        Set<Id> expressionIds = new Set<Id>();
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        expressionIds.add(expressionRec.Id);
        List<SVMXA360__CONF_Expression__c> expressionRecs = ADM_ExpressionManager.getInstance().getExpressionRecord(expressionRec.Id);
        List<SVMXA360__CONF_Expression__c> expressionRecWithDetails = 
            ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionIds);
        
        System.assert( expressionRecs[0].id != null );
        System.assert( expressionRecWithDetails[0].id != null );
        
        Test.stopTest();
    }

    static testmethod void testgetExpressionDetail() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        
            List<Adm.ExpressionDetail> expressionRules = ADM_ExpressionManager.getInstance().getExpressionDetails(expressionRec.Id);
            System.assert( expressionRules[0].id != null );
        
        Test.stopTest();
    }

    static testmethod void testGetExpressionsWithDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        //SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        Adm.Expression expressionWithDetail = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(expressionRec.Id);
        System.assert( savedExpression.id != null );
        

        Test.stopTest();
    }
	
    static testmethod void testGetExpressionCriteriaForIdsInvalidParam() { 
        
        Test.startTest();
        try {    
            List<String> expressionIds = new List<String>();
            Map<Id,Adm.Expression> expressionMap = ADM_ExpressionManager.getInstance().getExpressionCriteriaDetails(expressionIds);
        } catch(Exception e ){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    static testmethod void testGetExpressionsWithForIdsDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        List<String> expressionIds = new List<String>();
        expressionIds.add(String.ValueOf(expressionRec.Id));
        Map<Id,Adm.Expression> expressionWithDetailMap = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( expressionIds,'Account' );
        System.assert( expressionWithDetailMap.size() == 1 );
        

        Test.stopTest();
    }

    static testmethod void testGetExpressionsWithInvalidParams() { 
        
        Test.startTest();
        
        try {
            Adm.Expression expressionWithDetail = ADM_ExpressionManager.getInstance().getExpressionsWithDetails('');
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            ADM_ExpressionManager.getInstance().deleteExpression('');
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            Adm.Expression expression;
            ADM_ExpressionManager.getInstance().saveExpression(expression);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            List<String> expressionIds = new List<String>();
            ADM_ExpressionManager.getInstance().getExpressionsWithDetails(expressionIds,null);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        
        Test.stopTest();
    }

    static testmethod void testSaveExpression() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        //SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        System.assert( savedExpression.id != null );
        

        Test.stopTest();
    }

    static testmethod void testLiteralSaveExpression() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => 'Account'
                                                                                                                        });
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','eq',1,'Function','STRING'));
        expressionRules[0].relatedObjectDetails = 'Account';
        expressionRules[0].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[0].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Name','User','eq',2,'Function','STRING'));
        expressionRules[1].relatedObjectDetails = 'Account';
        expressionRules[1].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[1].literalRelatedObjectDetails = 'User';
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Literal Expression';
        expression.description = 'Account Literal Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        System.assert( savedExpression.id != null );
        

        Test.stopTest();
    }
    
    static testmethod void testSaveExpressions() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' =>''
                                                                                                                        });
        //SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        List<Adm.Expression> savedExpressions = ADM_ExpressionManager.getInstance().saveExpressions( new List<Adm.Expression>{expression} );
        System.assert( savedExpressions != null );
        System.assert( savedExpressions.size() != 0 );
        System.assert( savedExpressions.get(0).id != null );

        Test.stopTest();
    }

    static testmethod void testDeleteExpression() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
        
        
        ADM_ExpressionManager.getInstance().deleteExpression(expressionRec.Id);
        List<SVMXA360__CONF_Expression__c> expressionList = [Select Id from SVMXA360__CONF_Expression__c where Id = :expressionRec.Id];
        System.assert( expressionList.size() == 0 );

        Test.stopTest();
    }

    public static Adm.ExpressionDetail createExpressionDetail( String expId, String fieldName, String operand,
                                                         String operator, Integer sequence, String operandType, String fieldType) {
        Adm.ExpressionDetail expressionDetail = new Adm.ExpressionDetail();  
        expressionDetail.expressionId = expId;
        expressionDetail.fieldAPIName = fieldName;
        expressionDetail.operand = operand;
        expressionDetail.operator = operator;
        expressionDetail.sequence = sequence;
        expressionDetail.operandType = operandType;
        expressionDetail.fieldType = fieldType;

        return expressionDetail;
    }
    
    static testmethod void testValudateExpressions() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' =>''
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','eq',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        final Adm.ValidationResult validationResult = ADM_ExpressionManager.getInstance().validateExpression( expression );
        System.assert( validationResult != null );
        System.assert( validationResult.isValid );

        Test.stopTest();
    }
}