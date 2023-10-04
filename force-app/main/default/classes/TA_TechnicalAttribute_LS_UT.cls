@IsTest
public class TA_TechnicalAttribute_LS_UT {
    
    @testSetup public static void setup() {
        TA_TechnicalAttributeManager_UT.setup();
    }

    
    testmethod static void testGetAllTechnicalAttributes() {
        
        Test.startTest();
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.limitCount = 20;
        jsonReq.queryOffset = 0;
        jsonReq.searchTerm ='Test';
        jsonReq.sortField = 'Name';
        jsonReq.sortOrder = 'desc';
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllTechnicalAttributes(JSON.serialize(jsonReq));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }
    
    testmethod static void testGetAllTechnicalAttributes_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllTechnicalAttributes(null);            
            
        System.assert(serviceResponse.success == false);
        Test.stopTest();
    }
    
    testmethod static void testGetAllTechnicalAttributes_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllTechnicalAttributes('{{}');          
            
        System.assert(serviceResponse.success == false);
        Test.stopTest();
    }
    
    testmethod static void testGetAllTemplateAssociations() {
        
        Test.startTest();
        List<SVMXA360__SM_TA_Template__c> templateList = [Select Id from SVMXA360__SM_TA_Template__c limit 1];
        Config.FilterCriteria jsonReq = new Config.FilterCriteria();
        jsonReq.parentId = templateList[0].Id;
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllTemplateAssociations(JSON.serialize(jsonReq));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }
    
    testmethod static void testGetAllTemplateAssociations_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllTemplateAssociations(null);            
            
        System.assert(serviceResponse.success == false);
        Test.stopTest();
    }
    
    testmethod static void testGetAllTemplateAssociations_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllTemplateAssociations('{{}');          
            
        System.assert(serviceResponse.success == false);
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributeWithDetails() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeWithDetails(technicalAttributeRecords[0].Id);
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributeWithDetails_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeWithDetails('32321');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testGetAllTechnicalAttributeWithDetails_NullParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeWithDetails(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttribute() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        TechAttr.TechnicalAttribute technicalAttribute = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails(technicalAttributeRecords[0].Id);

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttribute(JSON.serialize(technicalAttribute));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttribute_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttribute(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalAttribute_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttribute('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateCategory() {

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

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateCategories(JSON.serialize(technicalAttributeTemplateCategories));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
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

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.cloneTechnicalAttributes(JSON.serialize(techAttrCategory));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testCloneTechnicalAttributes_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.cloneTechnicalAttributes(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testCloneTechnicalAttributes_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.cloneTechnicalAttributes('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalCategory_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateCategories(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTechnicalCategory_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateCategories('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testGetTemplateCategory() {

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

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeTemplateCategories(templateRecord.Id);
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testGetCategories_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeTemplateCategories(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateAssociation() {

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

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociation(JSON.serialize(tempAssociation));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateAssociation_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociation(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateAssociation_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociation('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateAssociations() {

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

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociations(JSON.serialize(techAttrTemplateAssociationList));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateAssociations_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociations(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplateAssociations_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociations('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplate() {
        Test.startTest();
        TechAttr.TechnicalAttributeTemplate techAttrTemplate = new TechAttr.TechnicalAttributeTemplate();
            techAttrTemplate.name = 'Standard Test Template';
            techAttrTemplate.developerName = 'Standard_Test_Template';
            techAttrTemplate.description = 'Test Description';

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplate(JSON.serialize(techAttrTemplate));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testSaveTemplate_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplate(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testGetTemplate() {
        Test.startTest();
        TechAttr.TechnicalAttributeTemplate techAttrTemplate = new TechAttr.TechnicalAttributeTemplate();
            techAttrTemplate.name = 'Standard Test Template';
            techAttrTemplate.developerName = 'Standard_Test_Template';
            techAttrTemplate.description = 'Test Description';
        
        techAttrTemplate = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplate(techAttrTemplate);
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeTemplateDetails(techAttrTemplate.id);
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testGetTemplate_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getTechnicalAttributeTemplateDetails(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveTemplate_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplate('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testDeleteCheckOnRelatedTA() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteCheckOnRelatedTA(technicalAttributeRecords[0].Id);
        
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testDeleteCheckOnRelatedTA_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteCheckOnRelatedTA(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttribute() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttribute(technicalAttributeRecords[0].Id);
        
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testGetWhereUsedDetailsForTA() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getWhereUsedDetails(technicalAttributeRecords[0].Id);
        
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testGetWhereUsedDetailsForTA_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getWhereUsedDetails(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttribute_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttribute(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttributeTemplateItem() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TemplateItem__c> templetItemRecords = [SELECT Id FROM SVMXA360__SM_TA_TemplateItem__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateItems(new list<string>{templetItemRecords[0].Id});
        Common.ServiceResponse serviceResponse1 = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateItem(templetItemRecords[0].Id);
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testDeleteTempAssociation_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateAssociation(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testDeleteTempCategory_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateCategory(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testDeleteTempItems_InvalidParam() {

        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateItems(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testRemoveTechnicalAttributeTemplateCategory() {

        Test.startTest();
        final List<SVMXA360__SM_TA_Category__c> categoriesRecords = [SELECT Id FROM SVMXA360__SM_TA_Category__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateCategory(categoriesRecords[0].Id);
        
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttributeTemplate() {

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
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplate(templateRecord.Id);
        
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testDeleteTechnicalAttributeAssociation() {

        Test.startTest();
        final List<SVMXA360__SM_TA_TemplateAssociation__c> associationRecords = [SELECT Id FROM SVMXA360__SM_TA_TemplateAssociation__c];
        String associationId = associationRecords[0].Id;
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateAssociation(associationId);
        
        System.assert( serviceResponse.success == true );
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
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveAttributeRecords(JSON.serialize(attributeRecords));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testSaveAttributeRecords_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveAttributeRecords(null);
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testSaveAttributeRecords_InvalidParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.saveAttributeRecords('{{}');
        
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }
    
    testmethod static void testfetchAttributesForAsset() {

        Test.startTest();
            Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
            Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.fetchAttributesForAsset(assetRecord.Id);
            System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testCloneTechnicalAttributeTemplate() {

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
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.cloneTechnicalAttributeTemplate(templateRecord.Id);
        
        System.assert( serviceResponse.success == true );
        Test.stopTest();
    }

    testmethod static void testCloneAttributeRecord_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.cloneTechnicalAttributeTemplate(null);
        
        System.assert( serviceResponse.success == false );
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
    
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAttributeHistories(JSON.serialize(historyRequest));
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testGetAttributeHistories_NullParam() {

        Test.startTest();

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAttributeHistories(null);
        System.assert( serviceResponse.success == false );
        Test.stopTest();
    }

    testmethod static void testGetAttributeHistories_InvalidParam() {

        Test.startTest();

        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAttributeHistories('{{}}');
        System.assert( serviceResponse.success == false );

        Test.stopTest();
    }
    testmethod static void testGetAllUserGroups() {
        
        Test.startTest();
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c];
        
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllUserGroups(technicalAttributeRecords[0].Id,'test');
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
        Test.stopTest();
    }
    
    testmethod static void testGetAllUserGroups_NullParam() {
        
        Test.startTest();
        Common.ServiceResponse serviceResponse = TA_TechnicalAttribute_LS.getAllUserGroups(null,null);            
            
        System.assert(serviceResponse.success == false);
        Test.stopTest();
    }
}