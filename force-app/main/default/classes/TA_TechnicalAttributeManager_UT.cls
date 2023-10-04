@IsTest
public class TA_TechnicalAttributeManager_UT {
    
    @testSetup public static void setup() {

        final List<Product2> productRecordList = (List<Product2>) SvmxTestDataFactory.insertSObjectList('Product2', 5);
        
        //Insert Asset
        Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 331',
            'ProductCode' => 'SPA500',
            'IsActive' => true,
            'Family' => 'Batteries',
            'StockKeepingUnit' => 'Solar 331'
        });
        
        Account account = new Account(Name = 'Test_Account123');
        insert account;
        
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test_Contact123', 'AccountId' => account.Id });
        
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Solar Panel 331',
            'Product2Id' => productRecord.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });
    
        final List<SVMXA360__CONF_PicklistDefinition__c> picklistDefList = (List<SVMXA360__CONF_PicklistDefinition__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_PicklistDefinition__c', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
            
            picklistDefList.get(index).Name = 'Test Picklist-'+index;
           
            picklistDefList.get(index).SVMXA360__DeveloperName__c = 'Test_Picklist_Name'+index;
            picklistDefList.get(index).SVMXA360__Description__c = 'Description Text';
            picklistDefList.get(index).SVMXA360__Values__c = 'Test1;Test2;Test3;Test4;';
            picklistDefList.get(index).SVMXA360__DefaultValue__c = 'Test1';
            picklistDefList.get(index).SVMXA360__Type__c = 'Technical Attribute';
            
        }
        insert picklistDefList;

        final List<SVMXA360__SM_TA_TechnicalAttribute__c> attributeList = (List<SVMXA360__SM_TA_TechnicalAttribute__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__SM_TA_TechnicalAttribute__c', 10);
        
        for( Integer index = 0; index < 10; index++ ) {
            attributeList.get(index).Name = 'Test_Attribute_'+index;
            attributeList.get(index).SVMXA360__DeveloperName__c = 'Test_Attribute_'+index;
            attributeList.get(index).SVMXA360__DefaultValue__c ='Default Value-'+index;
            attributeList.get(index).SVMXA360__Unit__c = 'Watt';
            attributeList.get(index).SVMXA360__MaximumValue__c = 40+index;
            attributeList.get(index).SVMXA360__MinimumValue__c = 5+index;
            attributeList.get(index).SVMXA360__IsReadonly__c = false;
            attributeList.get(index).SVMXA360__IsRequired__c = false;
            attributeList.get(index).SVMXA360__Message__c = 'Attribute Error Message';
            attributeList.get(index).SVMXA360__HelpText__c = 'Attribute Help Text';
            if( index < 5) {
                attributeList.get(index).SVMXA360__DataType__c = 'Picklist';
                attributeList.get(index).SVMXA360__PicklistDefinitionId__c = picklistDefList.get(Math.mod(index, 5)).Id;
            } else {
                attributeList.get(index).SVMXA360__DataType__c = 'Text';
            }            
        }
        insert attributeList;     
        
        final List<SVMXA360__SM_TA_Template__c> templateList = (List<SVMXA360__SM_TA_Template__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__SM_TA_Template__c', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
            
            templateList.get(index).Name = 'Test Template-'+index;
           
            templateList.get(index).SVMXA360__DeveloperName__c = 'Test_Template_Name'+index;
            templateList.get(index).SVMXA360__Description__c = 'Description Text';
            templateList.get(index).SVMXA360__Status__c = 'Draft';
            templateList.get(index).Name = 'Test'+index;
            templateList.get(index).SVMXA360__CategorySequenceJSON__c = null;
            
        }
        insert templateList;

        final List<SVMXA360__SM_TA_Category__c> categoryList = (List<SVMXA360__SM_TA_Category__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__SM_TA_Category__c', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
            
            categoryList.get(index).Name = 'Test Category-'+index;
           
            categoryList.get(index).SVMXA360__DeveloperName__c = 'Test_Category_Name'+index;
            categoryList.get(index).SVMXA360__Description__c = 'Description Text';
            
        }
        insert categoryList;

        final List<SVMXA360__SM_TA_TemplateItem__c> templateItemList = (List<SVMXA360__SM_TA_TemplateItem__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__SM_TA_TemplateItem__c', 5);
        
        for( Integer index = 0; index < 5; index++ ) {
           
            templateItemList.get(index).SVMXA360__DeveloperName__c = 'Test_TemplateItem_Name'+index;
            templateItemList.get(index).SVMXA360__TemplateId__c = templateList[0].id;
            templateItemList.get(index).SVMXA360__AttributeId__c = attributeList[2].id;
            templateItemList.get(index).SVMXA360__CategoryId__c = categoryList[0].id;
            
        }
        insert templateItemList;
        

        //List<SVMXA360__SM_TA_TemplateAssociation__c> associationList = (List<SVMXA360__SM_TA_TemplateAssociation__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__SM_TA_TemplateAssociation__c', 5);
        List<SVMXA360__SM_TA_TemplateAssociation__c> associationList =  new List<SVMXA360__SM_TA_TemplateAssociation__c>();
        for( Integer index = 0; index < 5; index++ ) {
            SVMXA360__SM_TA_TemplateAssociation__c association = new SVMXA360__SM_TA_TemplateAssociation__c();
            association.SVMXA360__TemplateId__c = templateList[0].Id;
            association.SVMXA360__ProductId__c = productRecord.Id;
            association.SVMXA360__ProductFamily__c = 'Batteries';
            associationList.add(association);
            
        }
        insert associationList;
        
        //Inserting template match rules
        final List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = (List<SVMXA360__CONF_TA_TemplateMatchRule__c >) SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_TA_TemplateMatchRule__c', 6);
        List<SVMXA360__CONF_TA_TemplateMatchRule__c > masterRecList = new List<SVMXA360__CONF_TA_TemplateMatchRule__c >();
        for( Integer index = 0; index < 3; index++ ) {
            matchRuleList.get(index).SVMXA360__Description__c  = 'Test_MatchRule_Name'+index;
            matchRuleList.get(index).SVMXA360__RuleType__c  = 'Master';
            matchRuleList.get(index).SVMXA360__RuleName__c  = 'Account'+index;
            matchRuleList.get(index).SVMXA360__Sequence__c  = index;
            matchRuleList.get(index).SVMXA360__AdvancedCriteria__c = '1';
            matchRuleList.get(index).SVMXA360__MatchRuleCriteria__c = 'SVMXA360__ProductFamily__c=Asset.Product2.Family';
            masterRecList.add(matchRuleList[index]);
        }
        matchRuleList.get(2).SVMXA360__MatchRuleCriteria__c = 'SVMXA360__ProductId__c=Asset.Product2Id';
        
        insert masterRecList;
        
        Integer detailIndex = 0;
        List<SVMXA360__CONF_TA_TemplateMatchRule__c > detailRecList = new List<SVMXA360__CONF_TA_TemplateMatchRule__c >();
        for( Integer index = 0; index < 3; index++ ) {
            
            detailIndex = index+3;
            matchRuleList.get(detailIndex).SVMXA360__MatchRuleMaster__c = masterRecList[index].id;
            matchRuleList.get(detailIndex).SVMXA360__RuleType__c = 'Detail';
            matchRuleList.get(detailIndex).SVMXA360__Sequence__c = index;
            matchRuleList.get(detailIndex).SVMXA360__ReferenceFieldsLabel__c = 'Asset Name';
            matchRuleList.get(detailIndex).SVMXA360__FieldApiName__c  = 'Product2.Family';
            matchRuleList.get(detailIndex).SVMXA360__OperandFieldApiName__c  = 'SVMXA360__ProductFamily__c';
            matchRuleList.get(detailIndex).SVMXA360__ObjectApiName__c  = 'Asset';
            matchRuleList.get(detailIndex).SVMXA360__OperandObjectApiName__c   = 'SVMXA360__SM_TA_TemplateAssociation__c';
            matchRuleList.get(detailIndex).SVMXA360__FieldDataType__c   = 'String';
            detailRecList.add(matchRuleList.get(detailIndex));
        }
        matchRuleList.get(5).SVMXA360__FieldApiName__c  = 'Product2Id';
        matchRuleList.get(5).SVMXA360__OperandFieldApiName__c  = 'SVMXA360__ProductId__c';
        insert detailRecList;
        
        //Category sequence 
        List<TechAttr.TechAttrTemplateCategorySequence> techAttrTemplateCategorySequences = new List<TechAttr.TechAttrTemplateCategorySequence>();

        TechAttr.TechAttrTemplateCategorySequence categorySequence = new TechAttr.TechAttrTemplateCategorySequence();
        categorySequence.developerName = 'Category 1';
        categorySequence.sequence =1;
        categorySequence.categoryId = categoryList[0].id;
        techAttrTemplateCategorySequences.add(categorySequence);
        
        templateList[0].SVMXA360__CategorySequenceJSON__c =JSON.serializePretty(techAttrTemplateCategorySequences);
        
         //Update template status and category sequence
        templateList[0].SVMXA360__Status__c = 'Active';
        update templateList[0];
        
        associationList[0].SVMXA360__ProductId__c = productRecord.Id; //Template to get matched
        update associationList[0];
        
        //Insert Asset Technical Attributes
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTANumber1 = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => attributeList[2].Id,
            'SVMXA360__TemplateItemId__c' => templateItemList[0].Id,
            'SVMXA360__Value__c' => 'Testing',
            'SVMXA360__PreviousValue__c' => 'Previous Value',
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1,
            'SVMXA360__Source__c' => 'Web',
            'SVMXA360__PreviousCapturedOn__c' => Datetime.now() - 1,
            'SVMXA360__PreviousCapturedBy__c' => UserInfo.getUserId()
        });

        assetTANumber1.SVMXA360__Value__c = 'New Value';
        assetTANumber1.SVMXA360__PreviousValue__c = 'Testing';
        update assetTANumber1;
        

        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTANumber = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => attributeList[5].Id,
            'SVMXA360__Value__c' => '105.5',
            'SVMXA360__NumberValue__c' => 105.5,
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1
        });

        assetTANumber.SVMXA360__Value__c = '333.44';
        assetTANumber.SVMXA360__PreviousValue__c = '105.5';
        update assetTANumber;

        final List<SVMXA360__CONF_UserGroup__c> groupList = (List<SVMXA360__CONF_UserGroup__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_UserGroup__c', 10);
        
        for( Integer index = 0; index < 10; index++ ) {
            
            groupList.get(index).Name = 'Test Group-'+index;
           
            groupList.get(index).SVMXA360__DeveloperName__c = 'Test_Group_Name'+index;
            groupList.get(index).SVMXA360__Description__c = 'Group Description Text';
            groupList.get(index).SVMXA360__Active__c = true;
        }
        insert groupList;
    }

    testmethod static void testGetAttributesHistoryList() {
        Test.startTest();
        list<Asset> aRecord = [select id from asset limit 1];
        list<SVMXA360__SM_TA_AssetTechnicalAttribute__c> assetTechAttribute = [select id from SVMXA360__SM_TA_AssetTechnicalAttribute__c limit 1];
        list<SVMXA360__SM_TA_AssetTechnicalAttribute__c> attr = [select id, SVMXA360__Value__c from SVMXA360__SM_TA_AssetTechnicalAttribute__c];
        attr[0].SVMXA360__Value__c = '200';
        update attr[0];
        TechAttr.AttributeHistoryFilter request = new TechAttr.AttributeHistoryFilter();
        request.objectId = aRecord[0].id;
        request.objectName = 'Asset';
        request.startDate = dateTime.now();
        request.endDate = dateTime.now().addDays(1);
        request.rowlimit = 30;
        request.attributeIdList = new List<string>();
        request.attributeIdList.add(assetTechAttribute[0].id);
        Common.ServiceResponse resp = TA_TechnicalAttribute_LS.fetchAllAttributes(aRecord[0].id, 'Asset');
        system.assertEquals(resp.success, true);
        resp = TA_TechnicalAttribute_LS.fetchAttributesHistoryList(JSON.serialize(request));
        system.assertEquals(resp.success, true);
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributes() {
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Test';
        jsonReq.sortField = 'Name';
        jsonReq.sortOrder = 'ASC';
        
        TechAttr.TechnicalAttributes technicalAttributes = TA_TechnicalAttributeManager.getInstance().getAllTechnicalAttributes(jsonReq);
        
        System.assert( technicalAttributes != null );
        System.assert( technicalAttributes.technicalAttributeList!=null);
        Test.stopTest();
    }
    
    testmethod static void testGetAllTechnicalAttributes_InvalidParam() {
        
        Test.startTest();
        try {
            
           TechAttr.TechnicalAttributes technicalAttributes = TA_TechnicalAttributeManager.getInstance().getAllTechnicalAttributes(null);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributeWithDetails() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
        final TechAttr.TechnicalAttribute technicalAttribute = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails(technicalAttributeRecords[0].Id);
        
        System.assert( technicalAttribute != null );
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributeWithDetails_InvalidParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails('23232');
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributeWithDetails_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    testmethod static void testGetAllTemplateAssociations() {
        
        Test.startTest();
        List<SVMXA360__SM_TA_Template__c> templateList = [Select Id from SVMXA360__SM_TA_Template__c limit 1];
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId = templateList[0].Id;        
        List<SVMXA360__SM_TA_TemplateAssociation__c> associationList= TA_TechnicalAttributeManager.getInstance().getAllTemplateAssociations(jsonReq);
        
        System.assert( associationList!= null );
        System.assert( associationList.size() > 0);
        Test.stopTest();
    }
    
    testmethod static void testGetAllTemplateAssociations_InvalidParam() {
        
        Test.startTest();
        try {
           Config.FilterCriteria jsonReq = new Config.FilterCriteria();
           List<SVMXA360__SM_TA_TemplateAssociation__c> associationList= TA_TechnicalAttributeManager.getInstance().getAllTemplateAssociations(jsonReq );
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        Test.stopTest();
    }
    
    testmethod static void testGetAllTemplateAssociations_NullParam() {
        
        Test.startTest();
        try {
            
            List<SVMXA360__SM_TA_TemplateAssociation__c> associationList= TA_TechnicalAttributeManager.getInstance().getAllTemplateAssociations(null);
            
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testGetPicklistDefinitionDetails() {

        Test.startTest();
        final List<SVMXA360__CONF_PicklistDefinition__c> picklistRecords = [SELECT Id FROM SVMXA360__CONF_PicklistDefinition__c];
        
        Config.PicklistDefinition picklistDefinition = TA_TechnicalAttributeManager.getInstance().getPicklistDefinitionDetails(picklistRecords[0].Id);
        
        System.assert( picklistDefinition != null );
        Test.stopTest();
    }

    testmethod static void testGetPicklistDefinitionDetails_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().getPicklistDefinitionDetails(' ');
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttribute() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
        TechAttr.TechnicalAttribute technicalAttribute = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails(technicalAttributeRecords[0].Id);
        
        technicalAttribute = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttribute(technicalAttribute);
        
        System.assert( technicalAttribute != null );
        Test.stopTest();
    }

    testmethod static void testSaveNewTechnicalAttribute() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
        TechAttr.TechnicalAttribute technicalAttribute = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails(technicalAttributeRecords[0].Id);
        technicalAttribute.id = null;
        technicalAttribute.developerName = 'Test_Dev_Name-22';
        technicalAttribute = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttribute(technicalAttribute);
        
        System.assert( technicalAttribute != null );
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttribute_NullParam() {

        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().saveTechnicalAttribute(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttributes_NullParam() {

        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributes(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT  ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testSavePicklistDefinitions_NullParam() {

        Test.startTest();
        try {
            List<Config.PicklistDefinition> picklistDefinitions = new List<Config.PicklistDefinition>();
            TA_TechnicalAttributeManager.getInstance().savePicklistDefinitions (picklistDefinitions);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER   ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeleteCheckOnRelatedTA() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
        TA_TechnicalAttributeManager.getInstance().deleteCheckOnRelatedTA(technicalAttributeRecords[0].Id);

        List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecordList = [Select Id from SVMXA360__SM_TA_TechnicalAttribute__c where Id = :technicalAttributeRecords[0].Id];
        System.assert( technicalAttributeRecordList== null || technicalAttributeRecordList.size() == 0 );
        Test.stopTest();
    }

    testmethod static void testDeleteCheckOnRelatedTA_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteCheckOnRelatedTA(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttribute() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
        TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttribute(technicalAttributeRecords[0].Id);

        List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecordList = [Select Id from SVMXA360__SM_TA_TechnicalAttribute__c where Id = :technicalAttributeRecords[0].Id];
        System.assert( technicalAttributeRecordList== null || technicalAttributeRecordList.size() == 0 );
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttribute_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttribute(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttributes_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributes(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeletePicklistDefinition() {
        
        Test.startTest();
        final List<SVMXA360__CONF_PicklistDefinition__c> picklistDefinitionList = [SELECT Id FROM SVMXA360__CONF_PicklistDefinition__c];
            
        TA_TechnicalAttributeManager.getInstance().deletePicklistDefinition(picklistDefinitionList[0].Id);

        List<SVMXA360__CONF_PicklistDefinition__c> picklistDefinitionRecords = [Select Id from SVMXA360__CONF_PicklistDefinition__c where Id = :picklistDefinitionList[0].Id];
        System.assert( picklistDefinitionRecords== null || picklistDefinitionRecords.size() == 0 );
        Test.stopTest();
    }

    testmethod static void testDeletePicklistDefinition_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deletePicklistDefinition(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeletePicklistDefinitions_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deletePicklistDefinitions(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    
    testmethod static void testSaveTechnicalAttributeCategory() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id, SVMXA360__CategorySequenceJSON__c FROM SVMXA360__SM_TA_Template__c];
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
        SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
        TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        techAttrCategory.name = 'Departure';
        techAttrCategory.developername = 'Departure';
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem.developerName = 'temperature';
        taTempItem.defaultValue = '1';
        taTempItem.status = 'Active';
        taTempItem.templateId = templateRecord.Id;
        taTempItem.attributeId = attributeRecord.Id;
        
        technicalAttributeTemplateItems.add(taTempItem);
        techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
        technicalAttributeCategories.add(techAttrCategory);
        
        List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
        TechAttr.TechAttrTemplateCategorySequence seq = new TechAttr.TechAttrTemplateCategorySequence();
        seq.developerName = techAttrCategory.developername;
        seq.sequence = 1;
        seqList.add(seq);

        TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
        technicalAttributeTemplateCategories.templateId = templateRecord.Id;
        
        List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        System.assert( categories[0].id != null );
        Test.stopTest();
    }
    
    testmethod static void testCreateUpdateTechnicalAttributeCategory() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id, SVMXA360__CategorySequenceJSON__c FROM SVMXA360__SM_TA_Template__c];
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
        SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);
        
        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
        TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        techAttrCategory.name = 'Departure';
        techAttrCategory.developername = 'Departure';
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem.developerName = 'temperature';
        taTempItem.defaultValue = '1';
        taTempItem.status = 'Active';
        taTempItem.templateId = templateRecord.Id;
        taTempItem.attributeId = attributeRecord.Id;
        
        technicalAttributeTemplateItems.add(taTempItem);
        techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
        technicalAttributeCategories.add(techAttrCategory);

        TechAttr.TechnicalAttributeCategory techAttrCategory2 = new TechAttr.TechnicalAttributeCategory();

        techAttrCategory2.name = 'Arrival';
        techAttrCategory2.developername = 'Arrival';

        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems2 = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem2 = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem2.developerName = 'Cat2_temperature';
        taTempItem2.defaultValue = '1';
        taTempItem2.status = 'Active';
        taTempItem2.templateId = templateRecord.Id;
        taTempItem2.attributeId = attributeRecord.Id;

        technicalAttributeTemplateItems2.add(taTempItem2);
        techAttrCategory2.technicalAttributeTemplateItems = technicalAttributeTemplateItems2;
        
        technicalAttributeCategories.add(techAttrCategory2);
        
        TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
        technicalAttributeTemplateCategories.templateId = templateRecord.Id;
        
        List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        
        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories2 = new List<TechAttr.TechnicalAttributeCategory>();
        technicalAttributeCategories2.add(categories[0]);

        TechAttr.TechnicalAttributeTemplateCategories techAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        techAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories2;
        techAttributeTemplateCategories.templateId = templateRecord.Id;

        List<TechAttr.TechnicalAttributeCategory> updatedCategories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(techAttributeTemplateCategories);
        System.assert( updatedCategories.size() == 1 );
        Test.stopTest();
    }

    testmethod static void testGetTechnicalAttributeCategory() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
        SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
        TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        techAttrCategory.name = 'Departure';
        techAttrCategory.developername = 'Departure';
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem.developerName = 'temperature';
        taTempItem.defaultValue = '1';
        taTempItem.status = 'Active';
        taTempItem.templateId = templateRecord.Id;
        taTempItem.attributeId = attributeRecord.Id;
        
        technicalAttributeTemplateItems.add(taTempItem);
        techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
        technicalAttributeCategories.add(techAttrCategory);
        
        List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
        TechAttr.TechAttrTemplateCategorySequence seq = new TechAttr.TechAttrTemplateCategorySequence();
        seq.developerName = techAttrCategory.developername;
        seq.sequence = 1;
        seqList.add(seq);

        TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
        technicalAttributeTemplateCategories.templateId = templateRecord.Id;
        
        List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        List<TechAttr.TechnicalAttributeCategory> technicalCategories = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateCategories(templateRecord.Id);
        System.assert( categories[0].id != null );
        System.assert( technicalCategories[0].id != null );
        Test.stopTest();
    }

    testmethod static void testGetCategory_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateCategories(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testSaveCategories_NullParam() {
        
        Test.startTest();
        try {

            TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
            technicalAttributeTemplateCategories.techAttrTemplateCategories = null;
            technicalAttributeTemplateCategories.templateId = null;

            TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testSaveTechAttrCategory_nullName() {
        
        Test.startTest();
        try {
            final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
            final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
            SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
            SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

            List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
            TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
            List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
            
            techAttrCategory.name = null;
            techAttrCategory.developername = 'Departure';
            
            TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
            taTempItem.developerName = 'temperature';
            taTempItem.defaultValue = '1';
            taTempItem.status = 'Active';
            taTempItem.templateId = templateRecord.Id;
            taTempItem.attributeId = attributeRecord.Id;
            
            technicalAttributeTemplateItems.add(taTempItem);
            techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
            technicalAttributeCategories.add(techAttrCategory);
            
            List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
            
            TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
            technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
            technicalAttributeTemplateCategories.templateId = templateRecord.Id;

            List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }
        Test.stopTest();

    }

    testmethod static void testSaveTechAttrCategory_nullAttribute() {
        
        Test.startTest();
        try {
            final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
            final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
            SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
            SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

            List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
            TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
            List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
            
            techAttrCategory.name = 'Departure';
            techAttrCategory.developername = 'Departure';
            
            TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
            taTempItem.developerName = 'temperature';
            taTempItem.defaultValue = '1';
            taTempItem.status = 'Active';
            taTempItem.templateId = templateRecord.Id;
            taTempItem.attributeId = null;
            
            technicalAttributeTemplateItems.add(taTempItem);
            techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
            technicalAttributeCategories.add(techAttrCategory);
            
            List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
            TechAttr.TechAttrTemplateCategorySequence seq = new TechAttr.TechAttrTemplateCategorySequence();
            seq.developerName = techAttrCategory.developername;
            seq.sequence = 1;
            seqList.add(seq);

            TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
            technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
            technicalAttributeTemplateCategories.templateId = templateRecord.Id;

            List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }
        Test.stopTest();

    }

    testmethod static void testSaveTechAttrTempAssociations() {

        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);

        final List<Product2> productRecordList = [SELECT Id FROM Product2];
        Product2 prodRecord = productRecordList.get(0);

        List<TechAttr.TechAttrTemplateAssociation> templateAssociations = new List<TechAttr.TechAttrTemplateAssociation>();
        TechAttr.TechAttrTemplateAssociation tempAssociation = new TechAttr.TechAttrTemplateAssociation();

        tempAssociation.productId = prodRecord.Id;
        tempAssociation.templateId = templateRecord.Id;
        tempAssociation.productFamily = 'Batteries';

        templateAssociations.add(tempAssociation);

        TechAttr.TechAttrTemplateAssociationList techAttrTemplateAssociationList = new TechAttr.TechAttrTemplateAssociationList();
        techAttrTemplateAssociationList.templateAssociations = templateAssociations;

        TechAttr.TechAttrTemplateAssociationList savedTemplateAssociations = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociations(techAttrTemplateAssociationList);

        System.assert( savedTemplateAssociations != null );
        Test.stopTest();

    }

    testmethod static void testSaveTechAttrTempAssociation() {

        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);

        final List<Product2> productRecordList = [SELECT Id FROM Product2];
        Product2 prodRecord = productRecordList.get(0);

        List<TechAttr.TechAttrTemplateAssociation> templateAssociations = new List<TechAttr.TechAttrTemplateAssociation>();
        TechAttr.TechAttrTemplateAssociation tempAssociation = new TechAttr.TechAttrTemplateAssociation();

        tempAssociation.productId = prodRecord.Id;
        tempAssociation.templateId = templateRecord.Id;
        tempAssociation.productFamily = 'Batteries';

        templateAssociations.add(tempAssociation);

        TechAttr.TechAttrTemplateAssociationList techAttrTemplateAssociationList = new TechAttr.TechAttrTemplateAssociationList();
        techAttrTemplateAssociationList.templateAssociations = templateAssociations;

        tempAssociation = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociation(tempAssociation);

        System.assert( tempAssociation != null );
        Test.stopTest();

    }

    testmethod static void testSaveAssociation_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociation(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testSaveAssociations_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociations(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttributeTemplate() {

        Test.startTest();
            TechAttr.TechnicalAttributeTemplate techAttrTemplate = new TechAttr.TechnicalAttributeTemplate();
            techAttrTemplate.name = 'Standard Test Template';
            techAttrTemplate.developerName = 'Standard_Test_Template';
            techAttrTemplate.description = 'Test Description';

            techAttrTemplate = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplate(techAttrTemplate);
            System.assert( techAttrTemplate.id != null );
        
        Test.stopTest();
    }

    testmethod static void testGetTemplate() {
        Test.startTest();
        TechAttr.TechnicalAttributeTemplate techAttrTemplate = new TechAttr.TechnicalAttributeTemplate();
            techAttrTemplate.name = 'Standard Test Template';
            techAttrTemplate.developerName = 'Standard_Test_Template';
            techAttrTemplate.description = 'Test Description';
        
        techAttrTemplate = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplate(techAttrTemplate);

        techAttrTemplate = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateDetails(techAttrTemplate.id);
        
        System.assert( techAttrTemplate != null );
        Test.stopTest();
    }

    testmethod static void testGetTechAttrTempCategories_WithoutCat() {
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id, SVMXA360__CategorySequenceJSON__c FROM SVMXA360__SM_TA_Template__c];
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);

        templateRecord.SVMXA360__CategorySequenceJSON__c = null;
        Database.update(templateRecord);
        
        List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateCategories(templateRecord.Id);
        
        System.assert( categories != null );
        Test.stopTest();
    }

    testmethod static void testGetTemplate_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateDetails(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testGetTemplate_InvalidParam() {
        
        Test.startTest();
        try {
            final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
            SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);
            TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateDetails(attributeRecord.Id);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttributeTemplate() {

        Test.startTest();
            TechAttr.TechnicalAttributeTemplate techAttrTemplate = new TechAttr.TechnicalAttributeTemplate();
            techAttrTemplate.name = 'Standard Test Template';
            techAttrTemplate.developerName = 'Standard_Test_Template';
            techAttrTemplate.description = 'Test Description';

            techAttrTemplate = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplate(techAttrTemplate);
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplate(techAttrTemplate.id);
            System.assert( techAttrTemplate != null );
        
        Test.stopTest();
    }

    testmethod static void testDeleteTemplate_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplate(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeleteTechAttrTempAssociation() {

        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);

        final List<Product2> productRecordList = [SELECT Id FROM Product2];
        Product2 prodRecord = productRecordList.get(0);

        List<TechAttr.TechAttrTemplateAssociation> templateAssociations = new List<TechAttr.TechAttrTemplateAssociation>();
        TechAttr.TechAttrTemplateAssociation tempAssociation = new TechAttr.TechAttrTemplateAssociation();

        tempAssociation.productId = prodRecord.Id;
        tempAssociation.templateId = templateRecord.Id;
        tempAssociation.productFamily = 'Batteries';

        templateAssociations.add(tempAssociation);

        TechAttr.TechAttrTemplateAssociationList techAttrTemplateAssociationList = new TechAttr.TechAttrTemplateAssociationList();
        techAttrTemplateAssociationList.templateAssociations = templateAssociations;

        tempAssociation = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociation(tempAssociation);

        SVMXA360__SM_TA_TemplateAssociation__c tempAssociationRecord = [Select Id from SVMXA360__SM_TA_TemplateAssociation__c LIMIT 1];

        TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateAssociation(tempAssociationRecord.Id);

        System.assert( tempAssociation != null );
        Test.stopTest();

    }

    testmethod static void testDeleteTemplateAssociation_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateAssociation(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttributeTempItem() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
        SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
        TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        techAttrCategory.name = 'Departure';
        techAttrCategory.developername = 'Departure';
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem.developerName = 'temperature';
        taTempItem.defaultValue = '1';
        taTempItem.status = 'Active';
        taTempItem.templateId = templateRecord.Id;
        taTempItem.attributeId = attributeRecord.Id;
        
        technicalAttributeTemplateItems.add(taTempItem);
        techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
        technicalAttributeCategories.add(techAttrCategory);
        
        List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
        TechAttr.TechAttrTemplateCategorySequence seq = new TechAttr.TechAttrTemplateCategorySequence();
        seq.developerName = techAttrCategory.developername;
        seq.sequence = 1;
        seqList.add(seq);

        TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
        technicalAttributeTemplateCategories.templateId = templateRecord.Id;
        
        List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        categories = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateCategories(templateRecord.Id);
        List<String> tempIds = new List<String>();

        for ( TechAttr.TechnicalAttributeCategory category : categories ) {
            for ( TechAttr.TechnicalAttributeTemplateItem tempItem : category.technicalAttributeTemplateItems ) {
                tempIds.add(tempItem.id);
            }
        }
        TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateItem(tempIds);
        System.assert( categories[0].id != null );
        Test.stopTest();
    }

    testmethod static void testCloneTechnicalAttributes() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id FROM SVMXA360__SM_TA_Template__c];
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
        SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
        TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        techAttrCategory.name = 'Departure';
        techAttrCategory.developername = 'Departure';
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem.developerName = 'temperature';
        taTempItem.defaultValue = '1';
        taTempItem.status = 'Active';
        taTempItem.templateId = templateRecord.Id;
        taTempItem.attributeId = attributeRecord.Id;
        
        technicalAttributeTemplateItems.add(taTempItem);
        techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
        technicalAttributeCategories.add(techAttrCategory);
        
        List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
        TechAttr.TechAttrTemplateCategorySequence seq = new TechAttr.TechAttrTemplateCategorySequence();
        seq.developerName = techAttrCategory.developername;
        seq.sequence = 1;
        seqList.add(seq);

        TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
        technicalAttributeTemplateCategories.templateId = templateRecord.Id;
        
        List<TechAttr.TechnicalAttributeCategory> categories = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories(technicalAttributeTemplateCategories);
        categories = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateCategories(templateRecord.Id);
        List<String> tempIds = new List<String>();

        TechAttr.TechnicalAttributeCategory category = categories.get(0);

        for ( TechAttr.TechnicalAttributeTemplateItem tempItem : category.technicalAttributeTemplateItems ) {
            tempItem.developerName = 'temperature_Clone';
            tempItem.id = null;
        }
        
        category = TA_TechnicalAttributeManager.getInstance().cloneTechnicalAttributes(category);
        System.assert( category != null );
        Test.stopTest();
    }

    testmethod static void testCloneTechnicalAttributes_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().cloneTechnicalAttributes(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void deleteTechnicalTempItem_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateItem(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void deleteTempCategoryNullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateCategory(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testSaveTemplate_NullParam() {
        
        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplate(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        Test.stopTest();
    }

    testmethod static void testfetchAttributesForAsset() {

        Test.startTest();
            Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
            List<TechAttr.TechnicalAttributeCategory> catergoryList = TA_TechnicalAttributeManager.getInstance().fetchAttributesForAsset(assetRecord.Id);
            System.assert( !catergoryList.isEmpty() );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveAttributeRecords() {

        Test.startTest();

        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        List<SVMXA360__SM_TA_TemplateItem__c> templateItemList = [Select Id,SVMXA360__AttributeId__c,SVMXA360__AttributeId__r.SVMXA360__DataType__c from SVMXA360__SM_TA_TemplateItem__c ];
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c  assetAttribute = [SELECT Id FROM SVMXA360__SM_TA_AssetTechnicalAttribute__c LIMIT 1];

        TechAttr.AttributeRecordList attributeRecords = new TechAttr.AttributeRecordList();
        List<TechAttr.AttributeRecord> attributeRecordList = new List<TechAttr.AttributeRecord>();

        for (Integer i=1;i<=6;i++) {

            TechAttr.AttributeRecord attributeRecord = new TechAttr.AttributeRecord();
            if ( i == 6) {
                attributeRecord.id = assetAttribute.Id;
                attributeRecord.previousBooleanValue = false;
                attributeRecord.previousCapturedOn = System.Today();
                attributeRecord.previousCapturedBy = UserInfo.getUserId();
                attributeRecord.attributeDataType = 'number';
            }

            if ( i == 1) {
                attributeRecord.attributeDataType = 'Text';
                attributeRecord.value = 'Test-22';
            } 

            if ( i == 2) {
                attributeRecord.attributeDataType = 'number';
                attributeRecord.numberValue = 55.66;
            }

            if (i ==3){
                attributeRecord.attributeDataType = 'boolean';
                attributeRecord.booleanValue = true;
            }

            if ( i == 4) {
                attributeRecord.attributeDataType = 'date';
                attributeRecord.dateValue = System.Today();
            }

            if (i ==5){
                attributeRecord.attributeDataType = 'datetime';
                attributeRecord.datetimeValue = System.now();
            }

            if (i!= 6) {
                attributeRecord.parentRecordId = assetRecord.Id;
                attributeRecord.templateItemId = templateItemList[0].Id;
                attributeRecord.attributeId = templateItemList[0].SVMXA360__AttributeId__c;
                attributeRecord.source = 'Web';
            } 
            attributeRecord.value = 'Test-22';
            attributeRecordList.add(attributeRecord);
        }
        attributeRecords.attributeRecords=attributeRecordList;
        attributeRecords.sourceObjectName='Asset';
        attributeRecords.requestSource='Web';
         
        TechAttr.AttributeRecordList attributes = TA_TechnicalAttributeManager.getInstance().saveAttributeRecords(attributeRecords);
        
        System.assert( attributes != null );
        Test.stopTest();
    }

    testmethod static void testSaveAttributeRecords_InValidParam() {

        Test.startTest();
        try {
            
            Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
            List<SVMXA360__SM_TA_TemplateItem__c> templateItemList = [Select Id,SVMXA360__AttributeId__c,SVMXA360__AttributeId__r.SVMXA360__DataType__c from SVMXA360__SM_TA_TemplateItem__c ];
            
            SVMXA360__SM_TA_AssetTechnicalAttribute__c  assetAttribute = [SELECT Id FROM SVMXA360__SM_TA_AssetTechnicalAttribute__c LIMIT 1];

            TechAttr.AttributeRecordList attributeRecords = new TechAttr.AttributeRecordList();
            List<TechAttr.AttributeRecord> attributeRecordList = new List<TechAttr.AttributeRecord>();

            for (Integer i=1;i<=6;i++) {

                TechAttr.AttributeRecord attributeRecord = new TechAttr.AttributeRecord();
                if ( i == 6) {
                    attributeRecord.id = assetAttribute.Id;
                    attributeRecord.previousBooleanValue = false;
                    attributeRecord.previousCapturedOn = System.Today();
                    attributeRecord.previousCapturedBy = UserInfo.getUserId();
                    attributeRecord.attributeDataType = 'number';
                }

                if ( i == 1) {
                    attributeRecord.attributeDataType = 'Text';
                    attributeRecord.value = 'Test-22';
                } 

                if ( i == 2) {
                    attributeRecord.attributeDataType = 'number';
                    attributeRecord.numberValue = 55.66;
                }

                if (i ==3){
                    attributeRecord.attributeDataType = 'boolean';
                    attributeRecord.booleanValue = true;
                }

                if ( i == 4) {
                    attributeRecord.attributeDataType = 'date';
                    attributeRecord.dateValue = System.Today();
                }

                if (i ==5){
                    attributeRecord.attributeDataType = 'datetime';
                    attributeRecord.datetimeValue = System.now();
                }

                if (i!= 6) {
                    attributeRecord.parentRecordId = assetRecord.Id;
                    attributeRecord.templateItemId = templateItemList[0].Id;
                    attributeRecord.attributeId = templateItemList[0].SVMXA360__AttributeId__c;
                    attributeRecord.source = 'Web';
                } 
                attributeRecord.value = 'Test-22';
                attributeRecordList.add(attributeRecord);
            }
            attributeRecords.attributeRecords=attributeRecordList;
            attributeRecords.requestSource='Web';

            TA_TechnicalAttributeManager.getInstance().saveAttributeRecords(attributeRecords);

            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testSaveAttributeRecords_NullParam() {

        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().saveAttributeRecords(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testCloneTechnicalAttribute() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_Template__c> technicalAttributeTemplateRecords = [SELECT Id, SVMXA360__CategorySequenceJSON__c FROM SVMXA360__SM_TA_Template__c];
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        SVMXA360__SM_TA_Template__c templateRecord = technicalAttributeTemplateRecords.get(0);
        SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = technicalAttributeRecords.get(0);

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = new List<TechAttr.TechnicalAttributeCategory>();
        TechAttr.TechnicalAttributeCategory techAttrCategory = new TechAttr.TechnicalAttributeCategory();
        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        
        techAttrCategory.name = 'Departure';
        techAttrCategory.developername = 'Departure';
        
        TechAttr.TechnicalAttributeTemplateItem taTempItem = new TechAttr.TechnicalAttributeTemplateItem();
        taTempItem.developerName = 'temperature';
        taTempItem.defaultValue = '1';
        taTempItem.status = 'Active';
        taTempItem.templateId = templateRecord.Id;
        taTempItem.attributeId = attributeRecord.Id;
        
        technicalAttributeTemplateItems.add(taTempItem);
        techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
        technicalAttributeCategories.add(techAttrCategory);
        
        List<TechAttr.TechAttrTemplateCategorySequence> seqList = new List<TechAttr.TechAttrTemplateCategorySequence>();
        TechAttr.TechAttrTemplateCategorySequence seq = new TechAttr.TechAttrTemplateCategorySequence();
        seq.developerName = techAttrCategory.developername;
        seq.sequence = 1;
        seqList.add(seq);

        TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories = new TechAttr.TechnicalAttributeTemplateCategories();
        technicalAttributeTemplateCategories.techAttrTemplateCategories = technicalAttributeCategories;
        technicalAttributeTemplateCategories.templateId = templateRecord.Id;
        
        TechAttr.TechnicalAttributeTemplate cloneTemplate = TA_TechnicalAttributeManager.getInstance().cloneTechnicalAttributeTemplate(templateRecord.Id);
        System.assert( cloneTemplate.id != null );
        Test.stopTest();
    }

    testmethod static void testCloneAttributeRecord_NullParam() {

        Test.startTest();
        try {
            TA_TechnicalAttributeManager.getInstance().cloneTechnicalAttributeTemplate(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testGetAttributeHistories() {

        Test.startTest();
        SVMXA360__SM_TA_AssetTechnicalAttribute__c  assetAttribute = [SELECT Id,SVMXA360__Value__c FROM SVMXA360__SM_TA_AssetTechnicalAttribute__c LIMIT 1];

        assetAttribute.SVMXA360__Value__c = '333.44';
        update assetAttribute;

        assetAttribute.SVMXA360__Value__c = '100.000';
        update assetAttribute;

        assetAttribute.SVMXA360__Value__c = '654';
        update assetAttribute;

        TechAttr.AttributeHistoryRequest historyRequest = new TechAttr.AttributeHistoryRequest();
        historyRequest.attributeId = assetAttribute.Id;
        historyRequest.sourceObjectName = 'Asset';
    
        TechAttr.AttributeHistory historyList = TA_TechnicalAttributeManager.getInstance().getAttributeHistories(historyRequest);
        System.assert( historyList != null );
        
        Test.stopTest();
    }

    testmethod static void testGetAttributeHistories_NullParam() {

        Test.startTest();
        try {
            TechAttr.AttributeHistory historyList = TA_TechnicalAttributeManager.getInstance().getAttributeHistories(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testGetAttributeHistories_InvalidParam() {

        Test.startTest();
        try {
            TechAttr.AttributeHistoryRequest historyRequest = new TechAttr.AttributeHistoryRequest();
            TechAttr.AttributeHistory historyList = TA_TechnicalAttributeManager.getInstance().getAttributeHistories(historyRequest);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }

    testmethod static void testGetAllUserGroups() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
            
        List<TechAttr.UserGroup> groupList = TA_TechnicalAttributeManager.getInstance().getAllUserGroups(technicalAttributeRecords[0].Id,'test');
        
        System.assert( groupList != null );
        Test.stopTest();
    }

    testmethod static void testGetAllUserGroups_NullParam() {

        Test.startTest();
        try {            
            TA_TechnicalAttributeManager.getInstance().getAllUserGroups('','test');
            System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
        Test.stopTest();
    }

}