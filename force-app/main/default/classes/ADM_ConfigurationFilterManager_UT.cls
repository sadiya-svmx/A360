@IsTest
public class ADM_ConfigurationFilterManager_UT {
    
    static testmethod void testGetConfigurationFilters() { 
        
        Test.startTest();
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_Layout__c',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => '',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => ''
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('SVMXA360__CONF_Layout__c');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'SVMXA360__TransactionType__c','Source to Target','eq',1,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Transaction List View';
        expression.description = 'Transaction List View';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'CONFIGURATION-FILTER';
        expression.expressionDetailList = expressionRules;
        expression.selectedTagsValue = 'India;USA';

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        List<Adm.ConfigurationFilter> configurationFilterList = ADM_ConfigurationFilterManager.getInstance().getAllConfigurationFilters('SVMXA360__CONF_Layout__c');
        System.assert( configurationFilterList.size() != 0 );
        System.assert( configurationFilterList.get(0).Name == expression.Name);
        
        Test.stopTest();
    }
    static testmethod void testApplyFilter() { 
        
        Test.startTest();

        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'New Transaction Layout',
            'SVMXA360__DeveloperName__c' => 'New_Transaction_Layout',
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__ScreenType__c' => 'Transaction',
            'SVMXA360__SourceObjectAPIName__c' => 'Account',
            'SVMXA360__TransactionType__c' => 'Source to Target',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} );

        SVMXA360__CONF_TagDefinition__c tagDefn1 = new SVMXA360__CONF_TagDefinition__c(name='testTag1');
        SVMXA360__CONF_TagDefinition__c tagDefn2 = new SVMXA360__CONF_TagDefinition__c(name='testTag2');
        SVMXA360__CONF_TagDefinition__c tagDefn3 = new SVMXA360__CONF_TagDefinition__c(name='testTag3');
        SVMXA360__CONF_TagDefinition__c tagDefn4 = new SVMXA360__CONF_TagDefinition__c(name='testTag4');

        insert (new List<SVMXA360__CONF_TagDefinition__c>{tagDefn1, tagDefn2, tagDefn3, tagDefn4});
        
        SVMXA360__CONF_TagElement__c tagElement1 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn1.Id, 
                                                        SVMXA360__EntityId__c	 = pageLayoutRecord.Id);

        SVMXA360__CONF_TagElement__c tagElement2 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn2.Id,
                                                        SVMXA360__EntityId__c	 = pageLayoutRecord.Id);
        SVMXA360__CONF_TagElement__c tagElement3 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn3.Id,
                                                        SVMXA360__EntityId__c	 = pageLayoutRecord.Id);
                                                                                
        insert (new List<SVMXA360__CONF_TagElement__c>{tagElement1, tagElement2, tagElement3});
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_Layout__c',
                                                                                                                        'SVMXA360__HeaderRecordObject__c' => '',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => ''
                                                                                                                        });
        List<Adm.Expression> expressions = ADM_ExpressionManager.getInstance().getExpressions('SVMXA360__CONF_Layout__c');

        List<Adm.ExpressionDetail> expressionRules = new List<Adm.ExpressionDetail>();
        expressionRules.add(createExpressionDetail(expressionRec.Id,'SVMXA360__TransactionType__c','Source to Target','eq',1,'Value','Picklist'));
        
        Adm.Expression expression = expressions[0];
        expression.Name = 'Transaction List View';
        expression.description = 'Transaction List View';
        expression.Type = 'Standard Expression';
        expression.expressionType = 'CONFIGURATION-FILTER';
        expression.expressionDetailList = expressionRules;
        expression.selectedTagsValue = 'testTag1;testTag2';

        Adm.Expression savedExpression = ADM_ExpressionManager.getInstance().saveExpression(expression);
        List<Adm.ConfigurationFilter> configurationFilterList = ADM_ConfigurationFilterManager.getInstance().getAllConfigurationFilters('SVMXA360__CONF_Layout__c');
        System.assert( configurationFilterList.size() != 0 );
        System.assert( configurationFilterList.get(0).Name == expression.Name);

        Adm.ConfigFilterInputRecord configFilterInfo = new Adm.ConfigFilterInputRecord();
        configFilterInfo.id = configurationFilterList[0].id;
        configFilterInfo.screenType = 'Transaction'; 
        List<Adm.PageLayout> transactionList = ADM_ConfigurationFilterManager.getInstance().getFilteredConfigurations(configFilterInfo);

        System.assert( transactionList.size() != 0 );
        System.assert( transactionList.get(0).Name == pageLayoutRecord.Name);
        
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