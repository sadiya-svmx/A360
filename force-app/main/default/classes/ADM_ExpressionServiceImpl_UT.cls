@IsTest
public class ADM_ExpressionServiceImpl_UT {
    
    static testmethod void testGetAllExpressions() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression )
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            
            
            List<Adm.Expression> expressions = new ADM_ExpressionServiceImpl().getAllExpressions();
            System.assert( expressions[0].id != null );
            System.assert( expressions.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressions() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            
            Adm.Expression expressionRequest = new Adm.Expression();
            expressionRequest.objectAPIName = 'Account';
            List<Adm.Expression> expressions = new ADM_ExpressionServiceImpl().getExpressions(expressionRequest);
            System.assert( expressions[0].id != null );
            System.assert( expressions.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressionsInvalidParam() { 
        
        Test.startTest();
            
            try {
                Adm.Expression expressionRequest = new Adm.Expression();
                List<Adm.Expression> expressions= new ADM_ExpressionServiceImpl().getExpressions(expressionRequest);
                System.assert(false);
            } catch(Exception e ){
                System.assert(true);
            }
    
    }

    static testmethod void testGetExpressionDetails() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            
            Adm.ExpressionDetail expressionDetailRequest = new Adm.ExpressionDetail();
            expressionDetailRequest.expressionId = expressionRec.Id;
            List<Adm.ExpressionDetail> expressionDetails = new ADM_ExpressionServiceImpl().getExpressionDetail(expressionDetailRequest);
            System.assert( expressionDetails[0].id != null );
            System.assert( expressionDetails.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressionDetailsInvalidParam() { 
        
        Test.startTest();
            
            try {
                Adm.ExpressionDetail expressionDetailRequest = new Adm.ExpressionDetail();
                expressionDetailRequest.expressionId = null;
                List<Adm.ExpressionDetail> expressions= new ADM_ExpressionServiceImpl().getExpressionDetail(expressionDetailRequest);
                System.assert(false);
            } catch(Exception e ){
                System.assert(true);
            }
    
    }

    static testmethod void testGetExpressionWithDetails() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            
            Adm.Expression expression = new ADM_ExpressionServiceImpl().getExpressionWithDetails(String.Valueof(expressionRec.Id));
            System.assert( expression.expressionDetailList[0].id != null );
            System.assert( expression.expressionDetailList.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressionWithDetailsForIds() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            List<String> expressionIds = new List<String>();
            expressionIds.add(String.ValueOf(expressionRec.Id));
            Map<Id,Adm.Expression> expressionMap = new ADM_ExpressionServiceImpl().getExpressionsWithDetails(expressionIds,'Account');
            System.assert( expressionMap.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressionWithDetailsInvalidParam() { 
        
        Test.startTest();
            
            try {
                Adm.ExpressionDetail expressionDetailRequest = new Adm.ExpressionDetail();
                expressionDetailRequest.expressionId = null;
                Adm.Expression expression= new ADM_ExpressionServiceImpl().getExpressionWithDetails(String.Valueof(expressionDetailRequest.expressionId));
                System.assert(false);
            } catch(Exception e ){
                System.assert(true);
            }
    
    }

    static testmethod void testGetExpressionWithDetailsForIdsInvalidParam() { 
        
        Test.startTest();
            
            try {
                List<String> expressionIds = new List<String>();
                Map<Id,Adm.Expression> expressionMap = new ADM_ExpressionServiceImpl().getExpressionsWithDetails(expressionIds,null);
                System.assert(false);
            } catch(Exception e ){
                System.assert(true);
            }
    
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
            
            Adm.Expression expressionReq = new Adm.Expression();
            expressionReq.id = expressionRec.Id;
            new ADM_ExpressionServiceImpl().deleteExpression(expressionReq);
            List<SVMXA360__CONF_Expression__c> expressionList = [Select Id from SVMXA360__CONF_Expression__c where Id = :expressionRec.Id];
            System.assert( expressionList.size() == 0 );
            
            Test.stopTest();
    }
    
    static testmethod void testDeleteExpressionInvalidParam() { 
        
        Test.startTest();
            
            try {
                Adm.Expression expression = new Adm.Expression();
                new ADM_ExpressionServiceImpl().deleteExpression(expression);
                System.assert(false);
            } catch(Exception e ){
                System.assert(true);
            }
    
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

            Adm.Expression savedExpression = new ADM_ExpressionServiceImpl().saveExpression(expression);
            System.assert( savedExpression.id != null );
            System.assert( savedExpression.expressionDetailList.size() == 2 );
            
        Test.stopTest();
    }

    static testmethod void testSaveExpressionInvalidParam() { 
        
        Test.startTest();
            
            try {
                Adm.Expression expression = new Adm.Expression();
                Adm.Expression expressionRec = new ADM_ExpressionServiceImpl().saveExpression(expression);
                System.assert(false);
            } catch(Exception e ){
                System.assert(true);
            }
    
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

    static testmethod void testGetAllExpressionsWithDetails() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            
            List<Adm.Expression> expressionList = new ADM_ExpressionServiceImpl().getAllExpressionsWithDetails();
            System.assert( expressionList[0].id != null );
            System.assert( expressionList.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testSaveExpressions() { 
        
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

            List<Adm.Expression> expressionList = new List<Adm.Expression>();
            expressionList.add(expression);

            List<Adm.Expression> savedExpression = new ADM_ExpressionServiceImpl().saveExpressions(expressionList);
            System.assert( savedExpression[0].id != null );
            System.assert( savedExpression[0].expressionDetailList.size() == 2 );
            
        Test.stopTest();
    }
    
}