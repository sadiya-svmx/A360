@isTest
public class COMM_UsageAnalytics_LS_UT {

    public static testMethod void testGenerateTransactionUsageAnalytics(){
        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__ScreenType__c'=> 'Transaction','SVMXA360__TransactionType__c' =>'Standalone Edit', 
                                                   'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__DeveloperName__c' => 'standaloneedit123','SVMXA360__FieldSets__c' => '["fls1","fls2"]'});
        SVMXA360__CONF_Layout__c pageLayoutRecord2 = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__ScreenType__c'=> 'Transaction','SVMXA360__TransactionType__c' =>'Source to Target', 
                                                   'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__SourceObjectAPIName__c' => 'Account','SVMXA360__FieldSets__c' => '["fls1","fls2"]',
                                                   'SVMXA360__DeveloperName__c' => 'sourcetotarget123'});  
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Contact',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => ''
                                                                                                                        });
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                                new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                'SVMXA360__FieldAPIName__c' => 'FullName',
                                                'SVMXA360__Operator__c' => 'ne',
                                                'SVMXA360__Operand__c' => 'ACC01',
                                                'SVMXA360__Sequence__c' => 1,
                                                'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                'SVMXA360__RelationshipName__c' => null,
                                                'SVMXA360__RelatedObjectDetails__c' => null,
                                                'SVMXA360__SourceObjectName__c' => null,
                                                'SVMXA360__OperandType__c' => 'Value'}, 1);
        
        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutSection__c', 
                                               new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id,'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
                                                   'SVMXA360__VisibilityCriteriaID__c' => expressionRec.Id},2);
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id, 'SVMXA360__ObjectAPIName__c' => 'Contact',
            'SVMXA360__ControllerReferenceField__c' => 'AccountId', 'SVMXA360__SourceControllerReferenceField__c' => 'AccountId',
            'SVMXA360__SectionSequence__c' => 1, 'SVMXA360__SortBy__c' => '[{"fieldAPIName":"Name","dataType":"NAME","sortingOrder":"desc"},' +
                '{"fieldAPIName":"Name","dataType":"REFERENCE","sortingOrder":"asc", "relationshipName":"Account", "referenceNameFields":["Name"]}]',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]', 'SVMXA360__VisibilityCriteriaID__c' => expressionRec.Id}, 
        1));
        
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord2.Id, 'SVMXA360__ObjectAPIName__c' => 'Contact',
            'SVMXA360__ControllerReferenceField__c' => 'AccountId', 'SVMXA360__SourceControllerReferenceField__c' => 'AccountId',
            'SVMXA360__SectionSequence__c' => 1, 'SVMXA360__SourceObjectAPIName__c' => 'Contact', 'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
            'Name' => 'Contact (Account ID)', 'SVMXA360__SortBy__c' => null}, 
        1));

        for(sObject sobjectRecord : sobjectRecordList){
            if(sobjectRecord.getSObjectType() == SVMXA360__CONF_LayoutSection__c.getSObjectType()){
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'Name','SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 
                                               4);
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'ButtonName', 'SVMXA360__Type__c' => 'Button',
                                                   'SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 
                                               4);
            }else{
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutRelatedSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'Name','SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 
                                               4); 
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutRelatedSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'ButtonName','SVMXA360__Type__c' => 'Button',
												   'SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 
                                               4);
            }
        }
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutId__c' => pageLayoutRecord.Id,'SVMXA360__Type__c' => 'Field',
                                                   'SVMXA360__ElementAPIName__c' => 'Name','SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 
                                               4); 
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutId__c' => pageLayoutRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'ButtonName','SVMXA360__Type__c' => 'Button',
												   'SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 
                                               4);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.NewRelicMockEndPoint());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP605','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'f9c8bd26b72a74ebe814d644c139e3e8FFFFNRAL'}, 1);
        Common.UsageAnalytics usageAnalyticsInput = new Common.UsageAnalytics();
        usageAnalyticsInput.layoutDeveloperName = pageLayoutRecord.SVMXA360__DeveloperName__c;
		Common.ServiceResponse resp = COMM_UsageAnalytics_LS.generateTransactionUsageAnalytics(JSON.serialize(usageAnalyticsInput));
        System.assertEquals(resp.success, true);

        Test.stopTest();
    }
    
    public static testMethod void testExceptionUsageAnalytics(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.NewRelicMockEndPoint());
        Common.UsageAnalytics usageAnalyticsInput = new Common.UsageAnalytics();
		Common.ServiceResponse resp = COMM_UsageAnalytics_LS.generateTransactionUsageAnalytics(JSON.serialize(usageAnalyticsInput));
        System.assertEquals(resp.success, false);

        Test.stopTest();  
    }    
}