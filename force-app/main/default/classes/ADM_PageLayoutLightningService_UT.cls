@isTest
public class ADM_PageLayoutLightningService_UT {

    @testSetup static void pageLayoutTestData(){
        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                                                                    new Map<String,Object>{'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account', 
                                                                                        'SVMXA360__ApplyMapping__c' => 'conditional'});

        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutSection__c', 
                                               new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id}, 
                                               2);
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id, 'SVMXA360__FieldSets__c' => '["fls1","fls2"]', 'SVMXA360__ObjectAPIName__c' => 'Contact',
            					'SVMXA360__ApplyValueMapping__c' => 'conditional'}, 
        2));

        List<sObject> elementList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                              new Map<String,Object>{'SVMXA360__LayoutId__c' => pageLayoutRecord.Id,
                                                  'SVMXA360__Type__c' => 'Button', 'SVMXA360__ApplyMapping__c' => 'conditional'}, 3);

        
        String relatedRecordId;
        for(sObject sobjectRecord : sobjectRecordList){
            if(sobjectRecord.getSObjectType() == SVMXA360__CONF_LayoutSection__c.getSObjectType()){
                elementList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__Type__c' => 'Field'}, 4));
            }else{
                relatedRecordId = sobjectRecord.Id;
                elementList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutRelatedSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__Type__c' => 'Field'}, 4));                
            }
        }

        for(sObject sobjectRecord : elementList){
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_SPMEvent__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutElementId__c' => sobjectRecord.Id}, 1);            
        }
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
        new Map<String,Object>{
                 'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                 'SVMXA360__ObjectAPIName__c' => 'Account',
                 'SVMXA360__HeaderRecordObject__c' => '',
                 'SVMXA360__ExpressionType__c' => 'VISIBILITY-RULE-CRITERIA'
        });
        
        List<sObject> expressionBasedMappingList = new List<sObject> ();
        SVMXA360__CONF_ExpressionBasedMapping__c headerExpMapping = new SVMXA360__CONF_ExpressionBasedMapping__c(
        	SVMXA360__TransactionHeader__c = pageLayoutRecord.Id
        );
        expressionBasedMappingList.add(headerExpMapping);
        
        SVMXA360__CONF_ExpressionBasedMapping__c childExpMapping = new SVMXA360__CONF_ExpressionBasedMapping__c(
        	SVMXA360__TransactionChild__c = relatedRecordId
        );
        expressionBasedMappingList.add(childExpMapping);
        
        SVMXA360__CONF_ExpressionBasedMapping__c elementExpMapping = new SVMXA360__CONF_ExpressionBasedMapping__c(
        	SVMXA360__TransactionElement__c = elementList[0].Id
        );
        expressionBasedMappingList.add(elementExpMapping);
        insert expressionBasedMappingList;
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ExpressionBasedMappingRow__c', 
                                              new Map<String,Object>{'SVMXA360__ExpressionBasedMapping__c' => childExpMapping.Id}, 3);        
    }
    
    public static testMethod void testGetPageLayoutDetails(){

        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        System.assert(pageLayoutList.size() == 1);
		Object responseObject = ADM_PageLayoutLightningService.getPageLayoutDetails(pageLayoutList[0].Id);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }

    static testmethod void testGetPageLayoutDetails_nullRequestJson() { 
        
        Test.startTest();
        
        Object responseObject = ADM_PageLayoutLightningService.getPageLayoutDetails(null);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetPageLayoutDetails_emptyRequest() { 
        
        Test.startTest();
        
        Adm.PageLayout requestPageLayout = new Adm.PageLayout();
        Object responseObject = ADM_PageLayoutLightningService.getPageLayoutDetails(JSON.serialize(requestPageLayout));
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetPageLayoutDetails_invalidPageLayoutId() { 
        
        Test.startTest();
        
        Adm.PageLayout requestPageLayout = new Adm.PageLayout();
        requestPageLayout.id = 'Invalid';
        
        Object responseObject = ADM_PageLayoutLightningService.getPageLayoutDetails(JSON.serialize(requestPageLayout));
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
       
        Test.stopTest();
    }

    public static testMethod void testSavePageLayout(){

        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        System.assert(pageLayoutList.size() == 1);
		Object responseObject = ADM_PageLayoutLightningService.getPageLayoutDetails(pageLayoutList[0].Id);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.startTest();
        object requestObject = (object)deserializedResponse.get('data');
		responseObject = ADM_PageLayoutLightningService.savePageLayout(JSON.serialize(requestObject));
        responseString = responseObject.toString();
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
	
        Test.stopTest();
    }
    
    public static testMethod void testSavePageLayouts(){

        Test.startTest();
        
		List<Adm.PageLayout> pageLayoutList = ADM_PageLayoutManager.getInstance().getAllPageLayoutsWithDetails();
        
        
		pageLayoutList = ADM_PageLayoutManager.getInstance().savePageLayouts( pageLayoutList );
        System.assert(pageLayoutList != null );
        System.assert(pageLayoutList.size() != 0 );
	
        Test.stopTest();
    }

    public static testMethod void testSavePageLayout_Invalid(){
		Test.startTest();
		Object responseObject = ADM_PageLayoutLightningService.savePageLayout(JSON.serialize(''));
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
	
        Test.stopTest();
    }
    
    static testmethod void testGetListOfLayouts(){
        Test.startTest();

        Object responseObject = ADM_PageLayoutLightningService.getAllPageLayouts('');
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }

    static testmethod void testGetLayoutsByObjectNameAndType(){
        Test.startTest();

        String screenType = 'Transaction';
        String objectName = 'Asset';

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'New Transaction Layout',
            'SVMXA360__DeveloperName__c' => 'New_Transaction_Layout',
            'SVMXA360__ObjectAPIName__c' => objectName,
            'SVMXA360__ScreenType__c' => screenType,
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} ); 
    
        Object responseObject = ADM_PageLayoutLightningService.getLayoutsByObjectNameAndType( screenType, objectName);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }

    public static testMethod void testDeletePageLayout(){

        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        System.assert(pageLayoutList.size() == 1);
		Object responseObject = ADM_PageLayoutLightningService.deletePageLayout(pageLayoutList[0].Id);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    public static testMethod void testDeletePageLayout_Invalid(){

        Test.startTest();
		Object responseObject = ADM_PageLayoutLightningService.deletePageLayout(null);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
        Test.stopTest();
    }
    
    public static testMethod void testGetUserInfo(){
        Test.startTest();
		Object responseObject = ADM_PageLayoutLightningService.getUserInfo('');
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);        
        Test.stopTest();
    }
    
    public static testMethod void testGetCustomLabels(){
        Test.startTest();
		Object responseObject = ADM_PageLayoutLightningService.getPageLayoutCustomLabels('');
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);        
        Test.stopTest();        
    }
        
    public static testMethod void testGetAllEntityDefinitions(){
        Test.startTest();
        Object responseObject = ADM_PageLayoutLightningService.getAllEntityDefinitions('');        
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);  
        
		responseObject = ADM_PageLayoutLightningService.getEntityDefinition('');   
		responseObject = ADM_PageLayoutLightningService.getEntityDefinitions('');   
        responseObject = ADM_PageLayoutLightningService.getFieldDefinitions('');        
        responseObject = ADM_PageLayoutLightningService.getFieldDefinitionsList('');        
        
        Test.stopTest();
    }

    public static testMethod void testGetChildRelationships(){
        Test.startTest();
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';     
        Object responseObject = ADM_PageLayoutLightningService.getChildRelationships(JSON.serialize(new List<Common.EntityDefinition>{requestEntityDefinition}));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);  
        Test.stopTest();
    }
    
    static testmethod void testGetMappingsByTarget() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                            'SVMXA360__Type__c' => 'Value Mapping'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        Adm.ObjectMapping objectMappingInfo= new Adm.ObjectMapping();
        objectMappingInfo.targetObjectAPIName = 'Case';
        
        Object responseObject = ADM_PageLayoutLightningService.getMappingsByTarget(JSON.serialize(objectMappingInfo));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);  
        
        Test.stopTest();
    }
    
    static testmethod void testGetMappingsBySourceTarget() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                      'SVMXA360__SourceObjectAPIName__c' => 'Asset'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        Adm.ObjectMapping objectMappingInfo= new Adm.ObjectMapping();
        objectMappingInfo.sourceObjectAPIName = 'Asset';
        objectMappingInfo.targetObjectAPIName = 'Case';
        Object responseObject = ADM_PageLayoutLightningService.getMappingsBySourceTarget(JSON.serialize(objectMappingInfo));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        responseObject = ADM_PageLayoutLightningService.getMappingsBySourceTarget('Case', 'Asset');
        System.assertEquals(responseObject, null);

        Test.stopTest();
    }

    static testmethod void testGetExpressionsByObject() {
		Test.startTest();

        Object responseObject = ADM_PageLayoutLightningService.getExpressionsByObject('Account');
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);        
		Test.stopTest();        
	}

	static testmethod void testFieldSetDefinitions() {
		Test.startTest();
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Account';     
        Object responseObject = ADM_PageLayoutLightningService.getFieldSetDefinitions(JSON.serialize(new List<Common.EntityDefinition>{requestEntityDefinition}));
        String responseString = responseObject.toString();
        System.debug('responseString ' + responseString);
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);        
		Test.stopTest();        
	}


	static testmethod void testFieldSetDefinitions_Failure() {
		Test.startTest();
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Account123';     
        Object responseObject = ADM_PageLayoutLightningService.getFieldSetDefinitions(JSON.serialize(new List<Common.EntityDefinition>{requestEntityDefinition}));
        String responseString = responseObject.toString();
        System.debug('responseString ' + responseString);
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), false);        
		Test.stopTest();        
	}
    
    static testmethod void testGetLookupConfiguration() {
        Test.startTest();
        List<SVMXA360__CONF_Expression__c> expressionRec = [SELECT Id FROM SVMXA360__CONF_Expression__c LIMIT 1];
        System.assert(expressionRec.size() == 1);
        SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord = (SVMXA360__CONF_LookupConfiguration__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_LookupConfiguration__c', 
                                                new Map<String,Object>{'SVMXA360__BasicFilter__c' => expressionRec[0].Id, 'SVMXA360__ObjectAPIName__c' => 'Account'});        
        Adm.LookupConfig lookupConfigInfo = new Adm.LookupConfig();
        lookupConfigInfo.objectAPIName = 'Account';
        lookupConfigInfo.headerRecordObject = null;
        Object responseObject = ADM_PageLayoutLightningService.getLookupConfigurations(JSON.serialize(lookupConfigInfo));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true); 
        
        Test.stopTest();
    }
    
    static testmethod void testGetExpressionByType() {
        Test.startTest();
        Adm.Expression expressionInfo = new Adm.Expression();
        expressionInfo.objectAPIName = 'Account';
        expressionInfo.expressionType = 'VISIBILITY-RULE-CRITERIA';
        Object responseObject = ADM_PageLayoutLightningService.getExpressionsByType(JSON.serialize(expressionInfo));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true); 
        
        Test.stopTest();
    }
    
    static testmethod void testGetExpressionByTypeInvalid() {
        Test.startTest();
        Adm.Expression expressionInfo = new Adm.Expression();
        expressionInfo.objectAPIName = '';
        expressionInfo.expressionType = 'VISIBILITY-RULE-CRITERIA';
        Object responseObject = ADM_PageLayoutLightningService.getExpressionsByType(JSON.serialize(expressionInfo));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), false); 
        
        Test.stopTest();
    }

    static testmethod void testGetAllTags() {
        SVMXA360__CONF_TagDefinition__c tagDefn1 = new SVMXA360__CONF_TagDefinition__c(name='testTag1');
        SVMXA360__CONF_TagDefinition__c tagDefn2 = new SVMXA360__CONF_TagDefinition__c(name='testTag2');
        SVMXA360__CONF_TagDefinition__c tagDefn3 = new SVMXA360__CONF_TagDefinition__c(name='testTag3');
        SVMXA360__CONF_TagDefinition__c tagDefn4 = new SVMXA360__CONF_TagDefinition__c(name='testTag4');

        insert (new List<SVMXA360__CONF_TagDefinition__c>{tagDefn1, tagDefn2, tagDefn3, tagDefn4});
        
        Test.startTest();

        Object responseObject = ADM_PageLayoutLightningService.getAllTags('');
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }
    
   	static testmethod void testGetAllConfigurationFilters() {
        SVMXA360__CONF_ConfigurationFilter__c config1 = new SVMXA360__CONF_ConfigurationFilter__c(SVMXA360__DeveloperName__c='config_1',Name='config1',SVMXA360__ObjectAPIName__c='SVMXA360__CONF_layout__c');
        SVMXA360__CONF_ConfigurationFilter__c config2 = new SVMXA360__CONF_ConfigurationFilter__c(SVMXA360__DeveloperName__c='config_2',Name='config2',SVMXA360__ObjectAPIName__c='SVMXA360__CONF_layout__c');
        SVMXA360__CONF_ConfigurationFilter__c config3 = new SVMXA360__CONF_ConfigurationFilter__c(SVMXA360__DeveloperName__c='config_3',Name='config3',SVMXA360__ObjectAPIName__c='SVMXA360__CONF_layout__c');
        SVMXA360__CONF_ConfigurationFilter__c config4 = new SVMXA360__CONF_ConfigurationFilter__c(SVMXA360__DeveloperName__c='config_4',Name='config4',SVMXA360__ObjectAPIName__c='SVMXA360__CONF_layout__c');
        

        insert (new List<SVMXA360__CONF_ConfigurationFilter__c>{config1, config2, config3, config4});
        
        Test.startTest();

        Object responseObject = ADM_PageLayoutLightningService.getAllConfigurationFilters('SVMXA360__CONF_layout__c');
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }
    
    static testmethod void testGetFilteredConfigurations() {
        
        List<SVMXA360__CONF_ConfigurationFilter__c> configList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ConfigurationFilter__c', 
                                               new Map<String,Object>{'SVMXA360__DeveloperName__c' => 'config_1', 'Name' => 'config1', 'SVMXA360__ObjectAPIName__c' => 'SVMXA360__CONF_layout__c'}, 
                                               1);

        Test.startTest();
        
        Adm.ConfigFilterInputRecord configRecord = new Adm.ConfigFilterInputRecord();
        configRecord.id = configList.get(0).id;
        configRecord.screenType = 'Transaction';
        
        Object responseObject = ADM_PageLayoutLightningService.getFilteredConfigurations(JSON.serialize(configRecord));
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }
    static testmethod void testGetWhereUsedStatus() {
        
        Test.startTest();

        Object responseObject = ADM_PageLayoutLightningService.getWhereUsedStatus('');
        String responseString = responseObject.toString();
		Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }
}