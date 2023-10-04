@IsTest
public class COMM_ExpressionUtils_UT {

    static testmethod void testLiteralBuildCriteriaEquals() { 
        
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

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.CreatedDate','Current Record Header','eq',3,'Function','DATETIME'));
        expressionRules[2].relatedObjectDetails = 'Account.User';
        expressionRules[2].literalParameterAPIName = 'CreatedBy.CreatedBy.CreatedDate';
        expressionRules[2].literalRelatedObjectDetails = 'User.User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.AccountId','User','eq',4,'Function','REFERENCE'));
        expressionRules[3].relatedObjectDetails = 'Account.User';
        expressionRules[3].literalParameterAPIName = 'CreatedBy.CreatedBy.AccountId';
        expressionRules[3].literalRelatedObjectDetails = 'User.User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.CreatedDate','User','ne',5,'Function','DATETIME'));
        expressionRules[4].relatedObjectDetails = 'Account.User';
        expressionRules[4].literalParameterAPIName = 'CreatedBy.CreatedBy.CreatedDate';
        expressionRules[4].literalRelatedObjectDetails = 'User.User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.AccountId','Current Record Header','ne',6,'Function','REFERENCE'));
        expressionRules[5].relatedObjectDetails = 'Account.User';
        expressionRules[5].literalParameterAPIName = 'CreatedBy.CreatedBy.AccountId';
        expressionRules[5].literalRelatedObjectDetails = 'User.User';

       


        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Literal Expression';
        expression.description = 'Account Literal Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2 OR 3 OR 4 OR 5 OR 6 ';
        expression.expressionDetailList = expressionRules;

        Account accRecord = (Account) SvmxTestDataFactory.insertSObject('Account', 
                                                                            new Map<String,Object>{
                                                                            'Name' => 'Test Account',
                                                                            'Type' => 'Billing Type'
                                                                            });

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression,accRecord);
        System.assert( criteria.contains('Account.Type =' ) );
        System.assert( criteria.contains('Account.Name =') );
        

        Test.stopTest();
    }

    static testmethod void testLiteralBuildCriteriaLessThanGreaterThan() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => 'Account'
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.CreatedDate','User','lt',1,'Function','DATETIME'));
        expressionRules[0].relatedObjectDetails = 'Account.User';
        expressionRules[0].literalParameterAPIName = 'CreatedBy.CreatedDate';
        expressionRules[0].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedById','Current Record Header','lt',2,'Function','REFERENCE'));
        expressionRules[1].relatedObjectDetails = 'Account';
        expressionRules[1].literalParameterAPIName = 'CreatedBy.CreatedById';
        expressionRules[1].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedById','User','gt',3,'Function','REFERENCE'));
        expressionRules[2].relatedObjectDetails = 'Account';
        expressionRules[2].literalParameterAPIName = 'CreatedBy.CreatedBy.CreatedById';
        expressionRules[2].literalRelatedObjectDetails = 'User.User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.AccountId','User','le',4,'Function','REFERENCE'));
        expressionRules[3].relatedObjectDetails = 'Account.User';
        expressionRules[3].literalParameterAPIName = 'CreatedBy.CreatedBy.AccountId';
        expressionRules[3].literalRelatedObjectDetails = 'User.User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.CreatedDate','User','ge',5,'Function','DATETIME'));
        expressionRules[4].relatedObjectDetails = 'Account.User';
        expressionRules[4].literalParameterAPIName = 'CreatedBy.CreatedBy.CreatedDate';
        expressionRules[4].literalRelatedObjectDetails = 'User.User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.CreatedBy.AccountId','Current Record Header','ge',6,'Function','REFERENCE'));
        expressionRules[5].relatedObjectDetails = 'Account.User';
        expressionRules[5].literalParameterAPIName = 'CreatedBy.CreatedBy.AccountId';
        expressionRules[5].literalRelatedObjectDetails = 'User.User';

        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Literal Expression';
        expression.description = 'Account Literal Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2 OR 3 OR 4 OR 5 OR 6'; 
        expression.expressionDetailList = expressionRules;

        Account accRecord = (Account) SvmxTestDataFactory.insertSObject('Account', 
                                                                            new Map<String,Object>{
                                                                            'Name' => 'Test Account',
                                                                            'Type' => 'Billing Type'
                                                                            });

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression,accRecord);
        System.assert( criteria.contains('Account.CreatedBy.CreatedDate <' ) );
        System.assert( criteria.contains('Account.CreatedBy.AccountId <') );
        

        Test.stopTest();
    }

    static testmethod void testLiteralBuildCriteriaStarts() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => 'Account'
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','starts',1,'Function','STRING'));
        expressionRules[0].relatedObjectDetails = 'Account';
        expressionRules[0].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[0].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Name','User','starts',2,'Function','STRING'));
        expressionRules[1].relatedObjectDetails = 'Account';
        expressionRules[1].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[1].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','contains',3,'Function','STRING'));
        expressionRules[2].relatedObjectDetails = 'Account';
        expressionRules[2].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[2].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Name','Current Record Header','contains',4,'Function','STRING'));
        expressionRules[3].relatedObjectDetails = 'Account';
        expressionRules[3].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[3].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','notcontain',5,'Function','STRING'));
        expressionRules[4].relatedObjectDetails = 'Account';
        expressionRules[4].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[4].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Name','User','notcontain',6,'Function','STRING'));
        expressionRules[5].relatedObjectDetails = 'Account';
        expressionRules[5].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[5].literalRelatedObjectDetails = 'User';

        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Literal Expression';
        expression.description = 'Account Literal Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2 OR 3 OR 4 OR 5 OR 6'; 
        expression.expressionDetailList = expressionRules;

        Account accRecord = (Account) SvmxTestDataFactory.insertSObject('Account', 
                                                                            new Map<String,Object>{
                                                                            'Name' => 'Test Account',
                                                                            'Type' => 'Billing Type'
                                                                            });

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression,accRecord);
        System.assert( criteria.contains('Account.Type ' ) );
        System.assert( criteria.contains('Account.Name ') );
        

        Test.stopTest();
    }

    static testmethod void testLiteralBuildCriteriaINNOTIN() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => 'Account'
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','IN',1,'Function','PICKLIST'));
        expressionRules[0].relatedObjectDetails = 'Account';
        expressionRules[0].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[0].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','IN',2,'Function','PICKLIST'));
        expressionRules[1].relatedObjectDetails = 'Account';
        expressionRules[1].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[1].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','IN',3,'Function','PICKLIST'));
        expressionRules[2].relatedObjectDetails = 'Account';
        expressionRules[2].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[2].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','IN',4,'Function','PICKLIST'));
        expressionRules[3].relatedObjectDetails = 'Account';
        expressionRules[3].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[3].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','IN',5,'Function','PICKLIST'));
        expressionRules[4].relatedObjectDetails = 'Account';
        expressionRules[4].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[4].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','IN',6,'Function','PICKLIST'));
        expressionRules[5].relatedObjectDetails = 'Account';
        expressionRules[5].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[5].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','NOTIN',7,'Function','PICKLIST'));
        expressionRules[6].relatedObjectDetails = 'Account';
        expressionRules[6].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[6].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','NOTIN',8,'Function','PICKLIST'));
        expressionRules[7].relatedObjectDetails = 'Account';
        expressionRules[7].literalParameterAPIName = 'CreatedBy.Name';
        expressionRules[7].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','IN',9,'Function','MULTIPICKLIST'));
        expressionRules[8].relatedObjectDetails = 'Account';
        expressionRules[8].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[8].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','IN',10,'Function','MULTIPICKLIST'));
        expressionRules[9].relatedObjectDetails = 'Account';
        expressionRules[9].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[9].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','IN',11,'Function','MULTIPICKLIST'));
        expressionRules[10].relatedObjectDetails = 'Account';
        expressionRules[10].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[10].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','IN',12,'Function','MULTIPICKLIST'));
        expressionRules[11].relatedObjectDetails = 'Account';
        expressionRules[11].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[11].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','IN',13,'Function','MULTIPICKLIST'));
        expressionRules[12].relatedObjectDetails = 'Account';
        expressionRules[12].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[12].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','IN',14,'Function','MULTIPICKLIST'));
        expressionRules[13].relatedObjectDetails = 'Account';
        expressionRules[13].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[13].literalRelatedObjectDetails = 'User';

        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','User','NOTIN',15,'Function','MULTIPICKLIST'));
        expressionRules[14].relatedObjectDetails = 'Account';
        expressionRules[14].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[14].literalRelatedObjectDetails = 'User';
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Account.Type','Current Record Header','NOTIN',16,'Function','MULTIPICKLIST'));
        expressionRules[15].relatedObjectDetails = 'Account';
        expressionRules[15].literalParameterAPIName = 'CreatedBy.Division';
        expressionRules[15].literalRelatedObjectDetails = 'User';


        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Literal Expression';
        expression.description = 'Account Literal Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14 OR 15 OR 16'; 
        expression.expressionDetailList = expressionRules;

        Account accRecord = (Account) SvmxTestDataFactory.insertSObject('Account', 
                                                                            new Map<String,Object>{
                                                                            'Name' => 'Test Account',
                                                                            'Type' => 'Billing Type'
                                                                            });

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression,accRecord);
        System.assert( criteria.contains('Account.Type ' ) );
        
        Test.stopTest();
    }

    static testmethod void testBuildCriteriaEquals() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
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

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('Type =') );
        System.assert( criteria.contains('Rating =') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaNullOperators() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','','isnull',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','','isnotnull',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('Type = null OR Rating != null') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaInvalidOperator() { 
        
        Test.startTest();
        try {
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','cos',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaInvalidField() { 
        
        Test.startTest();
        try {
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','eq',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'RatingType','Hot','cos',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.advancedExpression = '1 OR 2';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        

        Test.stopTest();
    }


    static testmethod void testBuildCriteriaNotEquals() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        system.debug('expressionRec = '+expressionRec);                                                                                                                
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore','ne',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','ne',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        system.debug('Expresssion = '+expression);
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('AND') );
        System.assert( criteria.contains('Type <>') );
        System.assert( criteria.contains('Rating <>') );

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaInNotInOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        system.debug('expressionRec = '+expressionRec);                                                                                                                
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Type','Bangalore,Mumbai','in',1,'Value','Picklist'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Rating','Hot','notin',2,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        system.debug('Expresssion = '+expression);
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('Type IN (') );
        System.assert( criteria.contains('Rating NOT IN (') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaNumberEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        system.debug('expressionRec = '+expressionRec);                                                                                                                
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'AnnualRevenue','20','eq',1,'Value','Currency'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','ne',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        system.debug('Expresssion = '+expression);
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('NumberOfEmployees <> 30') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateTimeEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'eq',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','ne',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        system.debug('Expresssion = '+expression);
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CreatedDate = ') );
        System.assert( criteria.contains('NumberOfEmployees <> 30') );

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateTimeNotEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','ne',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        system.debug('Expresssion = '+expression);
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CreatedDate <>') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Opportunity');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CloseDate',String.ValueOf(Date.Today()),'eq',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CloseDate =') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateNotEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Opportunity');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CloseDate',String.ValueOf(Date.Today()),'ne',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CloseDate <>') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateGreaterOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Opportunity');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CloseDate',String.ValueOf(Date.Today()),'gt',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CloseDate >') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateTimeGreaterOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'gt',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','gt',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CreatedDate >') );
        System.assert( criteria.contains('NumberOfEmployees > 30') );

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateLesserOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity'
                                                                                                                        });
        
        
        system.debug('expressionRec = '+expressionRec);                                                                                                                
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Opportunity');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CloseDate',String.ValueOf(Date.Today()),'lt',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        system.debug('Expresssion = '+expression);
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CloseDate <') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateTimeLesserOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'lt',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','lt',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CreatedDate < ') );
        System.assert( criteria.contains('NumberOfEmployees < 30') );
        
        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateGreaterThanEqualOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Opportunity');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CloseDate',String.ValueOf(Date.Today()),'ge',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CloseDate >=') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateTimeGreaterEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ge',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','ge',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('NumberOfEmployees >= 30') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateLesserThanEqualOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Opportunity');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'ne',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CloseDate',String.ValueOf(Date.Today()),'le',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CloseDate <=') );
        

        Test.stopTest();
    }

    static testmethod void testBuildCriteriaDateTimeLesserEqualsOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'CreatedDate',String.ValueOf(Date.Today()),'le',1,'Value','DateTime'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'NumberOfEmployees','30','le',2,'Value','Number'));
        
        Adm.Expression expression = expressions[0];
        Date todayDate = COMM_ExpressionUtils.getInstance().getFormattedDateValue('2020-06-06');
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('CreatedDate <= ') );
        System.assert( criteria.contains('NumberOfEmployees <= 30') );
        
        Test.stopTest();
    }

    static testmethod void testBuildCriteriaStartContainOperator() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
        
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'AccountNumber','AED','starts',1,'Value','String'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Phone','005','contains',1,'Value','Phone'));
        expressionRules.add(createExpressionDetail(expressionRec.Id,'Industry','USD','notcontain',1,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        Date todayDate = COMM_ExpressionUtils.getInstance().getFormattedDateValue('2020-06-06');
        expression.Name = 'Account Expression';
        expression.advancedExpression = null;
        expression.description = 'Account City Expression';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'COMM-EXPRESSION';
        expression.expressionDetailList = expressionRules;

        String criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
        System.assert( criteria.contains('AccountNumber LIKE') );
        System.assert( criteria.contains('Phone LIKE') );
        System.assert( criteria.contains('(NOT(Industry LIKE') );

        Test.stopTest();
    }
    
    static testmethod void testExpressionUtilMethods() { 

        SVMXA360__CONF_Expression__c expressionAccRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '1 OR 2'
                                                                                                                        });
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionAccRec.id,
                                                  'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'ACC001',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__OperandType__c' => 'Value'}, 1);

        Test.startTest();
            Set<String> setValues = COMM_ExpressionUtils.getInstance().buildStringSetValues('description;content');
            List<SVMXA360__CONF_Expression__c> expressionRecs = new List<SVMXA360__CONF_Expression__c>();
            expressionRecs.add(expressionAccRec);
            List<String> fieldAPINames = COMM_ExpressionUtils.getInstance().fetchSObjectFields(expressionRecs);
            System.assert( setValues.size() == 2);
        Test.stopTest();
    }

    static testmethod void testExpressionUtilMethods_InvaildData() {

        Test.startTest();

        try {
            Set<String> setValues = COMM_ExpressionUtils.getInstance().buildStringSetValues(null);
        } catch(Exception e ){
            System.assert(true);
        }  
        
        try {
            Set<String> setValues = COMM_ExpressionUtils.getInstance().buildStringSetValues('');
        } catch(Exception e ){
            System.assert(true);
        }  
        
        try {
            List<String> setValues = COMM_ExpressionUtils.getInstance().fetchSObjectFields(null);
        } catch(Exception e ){
            System.assert(true);
        }  
        
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
}