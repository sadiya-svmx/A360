@IsTest
public class ADM_ExpressionLightningService_UT {
    
    static testmethod void testGetAllExpressions() { 
        
        Test.startTest();
            
            SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression )
                                                                                                                        });
            SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                            new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
            
            
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getAllExpressions();
            System.assert(serviceResponse.success);

            List<Adm.Expression> expressionList = (List<Adm.Expression>) serviceResponse.data;
            System.assert( expressionList[0].id != null );
            System.assert( expressionList.size() == 1 );
            
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
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressions(JSON.serialize(expressionRequest));
            System.assert(serviceResponse.success);
            
            List<Adm.Expression> expressionList = (List<Adm.Expression>) serviceResponse.data;
            System.assert( expressionList[0].id != null );
            System.assert( expressionList.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressionsInvalidParam() { 
        
        Test.startTest();
            
            Adm.Expression expressionRequest = new Adm.Expression();
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressions('{"}');
            System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testGetExpressionsNull() { 
        
        Test.startTest();
            
            Adm.Expression expressionRequest = new Adm.Expression();
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressions(null);
            System.assert(serviceResponse.success == false);
        
        Test.stopTest();
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
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionDetail(JSON.serialize(expressionDetailRequest));
            System.assert(serviceResponse.success);


            List<Adm.ExpressionDetail> expressionDetails = (List<Adm.ExpressionDetail>) serviceResponse.data;
            System.assert( expressionDetails[0].id != null );
            System.assert( expressionDetails.size() == 1 );
            
            Test.stopTest();
    }

    static testmethod void testGetExpressionDetailsInvalidParam() { 
        
        Test.startTest();
            
            Adm.ExpressionDetail expressionDetailRequest = new Adm.ExpressionDetail();
            expressionDetailRequest.expressionId = null;
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionDetail(JSON.serialize('{"}'));
            System.assert(serviceResponse.success == false);
        
        Test.stopTest();
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
            
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionWithDetails(String.ValueOf(expressionRec.Id));
            System.assert(serviceResponse.success);


            Adm.Expression expression = (Adm.Expression) serviceResponse.data;
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
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionsWithDetails(expressionIds,'Account');
            System.assert(serviceResponse.success);


            System.assert( serviceResponse != null );
            
            Test.stopTest();
    } 

    static testmethod void testGetExpressionWithDetailsInvalidParam() { 
        
        Test.startTest();
            
            Adm.ExpressionDetail expressionDetailRequest = new Adm.ExpressionDetail();
            expressionDetailRequest.expressionId = null;
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionWithDetails('{"}');
            System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetExpressionWithDetailsForIdsInvalidParam() { 
        
        Test.startTest();
            
            List<String> expressionIds = new List<String>();
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionsWithDetails(expressionIds,null);
            System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }

    static testmethod void testGetExpressionCriteriaForIds() { 
        
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
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionCriteriaDetails(expressionIds);
            System.assert(serviceResponse.success);


            System.assert( serviceResponse != null );
            
            Test.stopTest();
    }
    
    static testmethod void testGetExpressionCriteriaForIdsInvalidParam() { 
        
        Test.startTest();
            
            List<String> expressionIds = new List<String>();
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.getExpressionCriteriaDetails(expressionIds);
            System.assert(serviceResponse.success == false);
        
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

            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.saveExpression(JSON.serialize(expression));
            System.assert(serviceResponse.success);

            Adm.Expression savedExpression = (Adm.Expression) serviceResponse.data;
            System.assert( savedExpression.id != null );
            System.assert( savedExpression.expressionDetailList.size() == 2 );
            
        Test.stopTest();
    }

    static testmethod void testSaveExpressionInvalidParam() { 
        
        Test.startTest();
            
         
            Adm.Expression expression = new Adm.Expression();
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.saveExpression('{"}');
            System.assert(serviceResponse.success == false);
            
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
            
            Adm.Expression expressionReq = new Adm.Expression();
            expressionReq.id = expressionRec.Id;
            Common.ServiceResponse serviceResponse = ADM_ExpressionLightningService.deleteExpression(JSON.serialize(expressionReq));
            System.assert(serviceResponse.success);
            
            Common.ServiceResponse newServiceResponse = ADM_ExpressionLightningService.deleteExpression('{"}');
            System.assert(newServiceResponse.success == false);

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