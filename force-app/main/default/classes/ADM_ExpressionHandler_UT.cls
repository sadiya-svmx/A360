@IsTest
public class ADM_ExpressionHandler_UT {
    
    @testSetup public static void setup() {
        
        SVMXA360__CONF_Expression__c expressionAccRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '1 OR 2',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionAccRec.id,
                                                  'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'ACC001',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                  'SVMXA360__RelationshipName__c' => null,
                                                  'SVMXA360__RelatedObjectDetails__c' => null,
                                                  'SVMXA360__LiteralRelatedObjectDetails__c' => null,
                                                  'SVMXA360__LiteralParameter__c' => null,
                                                  'SVMXA360__SourceObjectName__c' => null,
                                                  'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                  new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionAccRec.id,
                                                      'SVMXA360__FieldAPIName__c' => 'Name',
                                                      'SVMXA360__Operator__c' => 'eq',
                                                      'SVMXA360__Operand__c' => 'Test Account Expression Handler',
                                                      'SVMXA360__Sequence__c' => 2,
                                                      'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                      'SVMXA360__RelationshipName__c' => null,
                                                      'SVMXA360__RelatedObjectDetails__c' => null,
                                                      'SVMXA360__LiteralRelatedObjectDetails__c' => null,
                                                      'SVMXA360__LiteralParameter__c' => null,
                                                      'SVMXA360__SourceObjectName__c' => null,
                                                      'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = (Account) SvmxTestDataFactory.insertSObject('Account', 
                                                        new Map<String,Object>{
                                                        'Name' => 'Test Account Expression Handler',
                                                        'AccountNumber' => 'ACC001'
                                                        });

        Opportunity oppRec = (Opportunity) SvmxTestDataFactory.insertSObject('Opportunity', 
                                                        new Map<String,Object>{
                                                        'Name' => 'Test Opportunity Expression Handler'
                                                        });
        
        
    }

    testmethod static void testMatchingRecordsforExpression() {
        
        Test.startTest();
        
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('Account');
        Adm.Expression expression = expressions[0];
        Account acc = [Select Id from Account where Name = 'Test Account Expression Handler'];
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = acc.Id;
        cntxt.expressionId = expression.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(acc.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
                
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testQualifiedExpression() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'NOTCONTAIN',
                                                'SVMXA360__Operand__c' => '005',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC002';
        update accRec;

        Test.startTest();
        List<Id> expressionIds = new List<Id>();
        expressionIds.add(expressionRec.Id);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        String matchedExpression = handler.getFirstQualifiedExpression(accRec,expressionIds);
        System.assert( matchedExpression != null );
        
        Test.stopTest();
    }

    testmethod static void testQualifiedExpression_InvaildData() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'NOTCONTAINS',
                                                'SVMXA360__Operand__c' => '005',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        
        Test.startTest();
        try {
            List<Id> expressionIds = new List<Id>();
            expressionIds.add(accRec.Id);
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            String matchedExpression = handler.getFirstQualifiedExpression(accRec,expressionIds);
        } catch(Exception e ){
            System.assert(true);
        }   
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsforExpressionCriteria() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__Criteria__c' => 'NumberOfEmployees <> 30',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.NumberOfEmployees = 10;
        update accRec;

        Test.startTest();
        Set<Id> accRecordIds = new Set<Id>();
        accRecordIds.add(accRec.Id);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        List<sObject> matchedRecords = handler.matchRecordsForExpression(accRecordIds,expressionRec.Id);
                
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterString() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'gt',
                                                'SVMXA360__Operand__c' => 'ACC01',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select AccountNumber from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC02';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotEqualString() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'ACC01',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select AccountNumber from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC02';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testLiteralMatchingRecordsNotEqualString() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => 'Account'
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CreatedBy.Name',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'User',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => 'User',
                                                'SVMXA360__OperandType__c' => 'Function',
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__LiteralParameter__c' => 'CreatedBy.Name',
                                                'SVMXA360__LiteralRelatedObjectDetails__c' => 'User'}, 1);
        
        Account accRec = [Select AccountNumber, CreatedBy.Name from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC02';
        update accRec;

        Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( 'Account' );
        
        Test.startTest();
        
        Set<Id> expressionIds = new Set<Id>();
        expressionIds.add(expressionRec.Id);
        Map<Id,SVMXA360__CONF_Expression__c> expressionRecordsMap = new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionIds));
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        String matchedRecords = handler.parseExpression( accRec,sObjectFieldResultMap,expressionRecordsMap.get(expressionRec.Id));                                               
        System.assert( matchedRecords != null );
        
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLessThanString() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'lt',
                                                'SVMXA360__Operand__c' => 'ACC02',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select AccountNumber from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC01';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanEqualString() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'ge',
                                                'SVMXA360__Operand__c' => 'ACC02',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select AccountNumber from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC02';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLessThanEqualString() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'le',
                                                'SVMXA360__Operand__c' => 'ACC02',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select AccountNumber from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC02';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotEquals() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.NumberOfEmployees = 10;
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsEquals() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'eq',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.NumberOfEmployees = 30;
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords != null );
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThan() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'gt',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.NumberOfEmployees = 30;
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 0 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanEqual() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'ge',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.NumberOfEmployees = 30;
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLessThanEqual() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'le',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.NumberOfEmployees = 20;
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsInOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'in',
                                                'SVMXA360__Operand__c' => 'ACC001',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__LiteralRelatedObjectDetails__c' => null,
                                                'SVMXA360__LiteralParameter__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC001';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotInOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'notin',
                                                'SVMXA360__Operand__c' => 'ACC001',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__LiteralRelatedObjectDetails__c' => null,
                                                'SVMXA360__LiteralParameter__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC002';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsStartsOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'STARTS',
                                                'SVMXA360__Operand__c' => 'ACC',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC002';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsContainsOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'CONTAINS',
                                                'SVMXA360__Operand__c' => '002',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC002';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotContainsOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'NOTCONTAIN',
                                                'SVMXA360__Operand__c' => '005',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC002';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsIsNullOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'ISNULL',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id, AccountNumber from Account where Name = 'Test Account Expression Handler'];
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 0 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsIsNotNullOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                'SVMXA360__Operator__c' => 'ISNOTNULL',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        accRec.AccountNumber = 'ACC002';
        update accRec;

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotEqualsDateTime() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CreatedDate',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => String.valueof( system.NOW() ),
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id,createdDate from Account where Name = 'Test Account Expression Handler'];
        system.debug('createdDate = '+accRec.createdDate);

        system.debug('String.valueof( system.NOW() ) = '+String.valueof( system.NOW() ));

        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanDateTime() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CreatedDate',
                                                'SVMXA360__Operator__c' => 'gt',
                                                'SVMXA360__Operand__c' => String.valueof( system.NOW().addDays(-1) ),
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id,createdDate from Account where Name = 'Test Account Expression Handler'];
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanEqualDateTime() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CreatedDate',
                                                'SVMXA360__Operator__c' => 'ge',
                                                'SVMXA360__Operand__c' => String.valueof( system.NOW().addDays(-1) ),
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id,createdDate from Account where Name = 'Test Account Expression Handler'];
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLesserThanDateTime() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CreatedDate',
                                                'SVMXA360__Operator__c' => 'lt',
                                                'SVMXA360__Operand__c' => String.valueof( system.NOW().addDays(1) ),
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id,createdDate from Account where Name = 'Test Account Expression Handler'];
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLessThanEqualsDateTime() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CreatedDate',
                                                'SVMXA360__Operator__c' => 'le',
                                                'SVMXA360__Operand__c' => String.valueof( system.NOW().addDays(1) ),
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Account accRec = [Select Id,createdDate from Account where Name = 'Test Account Expression Handler'];
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = accRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(accRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsEqualsDate() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'eq',
                                                'SVMXA360__Operand__c' => String.valueof( Date.Today() ),
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotEqualsDateValue() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => String.valueof( Date.Today().addDays(1) ),
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanDateValue() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'gt',
                                                'SVMXA360__Operand__c' => String.valueof( Date.Today() ),
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today().addDays(1);
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanEqualDateValue() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'ge',
                                                'SVMXA360__Operand__c' => String.valueof( Date.Today() ),
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today().addDays(1);
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLesserThanDateValue() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'lt',
                                                'SVMXA360__Operand__c' => String.valueof( Date.Today().addDays(1) ),
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsLesserThanEqualDateValue() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'le',
                                                'SVMXA360__Operand__c' => String.valueof( Date.Today().addDays(1) ),
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsEqualsDateFunction() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'eq',
                                                'SVMXA360__Operand__c' => 'FSVMXTODAY',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsNotEqualsDateFunction() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'FSVMXTOMORROW',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsGreaterThanDateFunction() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Opportunity',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'CloseDate',
                                                'SVMXA360__Operator__c' => 'gt',
                                                'SVMXA360__Operand__c' => 'FSVMXYESTERDAY',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        oppRec.CloseDate = Date.Today();
        update oppRec;
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = oppRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(oppRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingBooleanOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'SVMXA360__CheckContracts__c',
                                                'SVMXA360__Operator__c' => 'eq',
                                                'SVMXA360__Operand__c' => 'TRUE',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRec = (SVMXA360__CONF_EntitlementRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_EntitlementRule__c', 
                                                new Map<String,Object>{
                                                'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                'SVMXA360__CheckContracts__c' => true
                                                });
        
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = entitlementRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(entitlementRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingBooleanNETrueOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'SVMXA360__CheckContracts__c',
                                                'SVMXA360__Operator__c' => 'eq',
                                                'SVMXA360__Operand__c' => 'FALSE',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRec = (SVMXA360__CONF_EntitlementRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_EntitlementRule__c', 
                                                new Map<String,Object>{
                                                'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                'SVMXA360__CheckContracts__c' => false
                                                });
        
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = entitlementRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(entitlementRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingBooleanFalseOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'SVMXA360__CheckContracts__c',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'TRUE',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRec = (SVMXA360__CONF_EntitlementRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_EntitlementRule__c', 
                                                new Map<String,Object>{
                                                'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                'SVMXA360__CheckContracts__c' => false
                                                });
        
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = entitlementRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(entitlementRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingBooleanFalseNEOperator() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'SVMXA360__CheckContracts__c',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'FALSE',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRec = (SVMXA360__CONF_EntitlementRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_EntitlementRule__c', 
                                                new Map<String,Object>{
                                                'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                'SVMXA360__CheckContracts__c' => true
                                                });
        
        
        Test.startTest();
        Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
        List<Adm.Context> contextList = new List<Adm.Context>();
        Adm.Context cntxt = new Adm.Context();
        cntxt.sObjectRecId = entitlementRec.Id;
        cntxt.expressionId = expressionRec.id;
        contextList.add(cntxt);
        sObjectContextRecs.put(entitlementRec.Id,contextList);
        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
        Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        System.assert( matchedRecords.size() == 1 );
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecords_InvalidData() {
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'SVMXA360__CheckContracts__c',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'FALSE',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        Test.startTest();
        try {
            Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
            List<Adm.Context> contextList = new List<Adm.Context>();
            Adm.Context cntxt = new Adm.Context();
            cntxt.sObjectRecId = expressionRec.Id;
            cntxt.expressionId = expressionRec.id;
            contextList.add(cntxt);
            sObjectContextRecs.put(expressionRec.Id,contextList);
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        } catch(Exception e ){
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testMatchingRecords_InvalidOpData() {
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'SVMXA360__CheckContracts__c',
                                                'SVMXA360__Operator__c' => 'GREATERLESSTHAN',
                                                'SVMXA360__Operand__c' => 'FALSE',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Function'}, 1);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRec = (SVMXA360__CONF_EntitlementRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_EntitlementRule__c', 
                                                new Map<String,Object>{
                                                'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                'SVMXA360__CheckContracts__c' => true
                                                });
        Test.startTest();
        try {
            Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
            List<Adm.Context> contextList = new List<Adm.Context>();
            Adm.Context cntxt = new Adm.Context();
            cntxt.sObjectRecId = entitlementRec.Id;
            cntxt.expressionId = expressionRec.id;
            contextList.add(cntxt);
            sObjectContextRecs.put(entitlementRec.Id,contextList);
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        } catch(Exception e ){
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testMatchingRecords_InvalidOperatorData() {
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_EntitlementRule__c',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        
        SVMXA360__CONF_EntitlementRule__c entitlementRec = (SVMXA360__CONF_EntitlementRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_EntitlementRule__c', 
                                                new Map<String,Object>{
                                                'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                'SVMXA360__CheckContracts__c' => true
                                                });
        Test.startTest();
        try {
            Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
            List<Adm.Context> contextList = new List<Adm.Context>();
            Adm.Context cntxt = new Adm.Context();
            cntxt.sObjectRecId = entitlementRec.Id;
            cntxt.expressionId = expressionRec.id;
            contextList.add(cntxt);
            sObjectContextRecs.put(entitlementRec.Id,contextList);
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            Map<String,List<Adm.Context>> matchedRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
        } catch(Exception e ){
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testMatchingRecordsforExpressionCriteria_InvalidData() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__Criteria__c' => 'NumberOfEmployees <> 30',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        Test.startTest();

        try {
            Set<Id> accRecordIds = new Set<Id>();
            accRecordIds.add(expressionRec.Id);
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            List<sObject> matchedRecords = handler.matchRecordsForExpression(accRecordIds,expressionRec.Id);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecordsforExpressionCriteria_InvalidExpData() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__Criteria__c' => 'NumberOfEmployees <> 30',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'NumberOfEmployees',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);

        Account accRec = [Select Id from Account where Name = 'Test Account Expression Handler'];
        
        Test.startTest();

        try {
            Set<Id> accRecordIds = new Set<Id>();
            accRecordIds.add(accRec.Id);
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            List<sObject> matchedRecords = handler.matchRecordsForExpression(accRecordIds,accRec.Id);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testParseExpression_InvalidData() {

        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__Criteria__c' => 'NumberOfEmployees <> 30',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'customField',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => '30',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);

        Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( 'Account' );
        
        Test.startTest();
        Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
        try {
            Set<Id> expressionIds = new Set<Id>();
            expressionIds.add(expressionRec.Id);
            Map<Id,SVMXA360__CONF_Expression__c> expressionRecordsMap = new Map<Id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(expressionIds));
            ADM_ExpressionHandler handler = new ADM_ExpressionHandler();
            String matchedRecords = handler.parseExpression( oppRec,sObjectFieldResultMap,expressionRecordsMap.get(expressionRec.Id) );
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testMatchingRecords_InvalidParams() {

        ADM_ExpressionHandler handler = new ADM_ExpressionHandler();

        Test.startTest();

        try {
            Map<String,List<Adm.Context>> matchingRecords = handler.matchRecordsForExpressions(null);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            Map<String,List<Adm.Context>> sObjectContextRecs = new Map<String,List<Adm.Context>>();
            Map<String,List<Adm.Context>> matchingRecords = handler.matchRecordsForExpressions(sObjectContextRecs);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            String qualifiedRecords = handler.getFirstQualifiedExpression(null,null);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            Opportunity oppRec = [Select Id,CloseDate from Opportunity where Name = 'Test Opportunity Expression Handler'];
            String qualifiedRecords = handler.getFirstQualifiedExpression(oppRec,null);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            String qualifiedRecords = handler.parseExpression(null,null,null);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }

        try {
            List<sObject> matchingRecords = handler.matchRecordsForExpression(null,null);
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
}