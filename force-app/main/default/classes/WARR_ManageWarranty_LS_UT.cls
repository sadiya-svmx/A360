@isTest
public with sharing class WARR_ManageWarranty_LS_UT {
    
    @isTest
    static void getWarrantyConfigurationRecordTest() {
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_WarrantyConfig__c', 
                                                new Map<String,Object>{'SVMXA360__AutoWarrOnCreateAsset__c'=> true, 
                                                'SVMXA360__EffectiveFromConfig__c'=>'{"Manufacture Date":"InstallDate","Install Date":"InstallDate","Purchase Date":"PurchaseDate"}', 
                                                'SVMXA360__RuleID__c'=>'Rule001', 'SVMXA360__RuleScope__c'=>'Global'});
        SVMXA360__CONF_WarrantyConfig__c configRecord = WARR_ManageWarranty_LS.getWarrantyConfigurationRecord();
        System.assert(configRecord!=null);
    }

    @isTest
    static void getObjectMappingsTest() {
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'WarrantyTerm',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'AssetWarranty','SVMXA360__DeveloperName__c' => 'MAP001',
                                                                                    'Name' => 'MAP001', 'SVMXA360__Type__c' => 'Field Mapping'});
        
        Map<String,String> mapObjectMappings = WARR_ManageWarranty_LS.getObjectMappings();
        System.assertEquals(1, mapObjectMappings.size());
    }

    @isTest
    static void getCoverageValuesOfWarrantyTermTest() {
        Map<String,String> mapPicklistValues = new Map<String,String>();
        mapPicklistValues = WARR_ManageWarranty_LS.getCoverageValuesOfWarrantyTerm();
        System.assert(mapPicklistValues!=null);
    }

    @isTest
    static void getDateFieldsOfAssetTest() {
        Map<String,String> mapDateFields = new Map<String,String>();
        mapDateFields = WARR_ManageWarranty_LS.getDateFieldsOfAsset();
        System.assert(mapDateFields!=null);
    }

    @isTest
    static void updateRecordTest() {
        SVMXA360__CONF_WarrantyConfig__c config = new SVMXA360__CONF_WarrantyConfig__c();
        config.SVMXA360__AutoWarrOnCreateAsset__c = true;
        config.SVMXA360__AutoWarrOnCreateAsset__c = true;
        config.SVMXA360__RuleScope__c = 'Global';
        config.SVMXA360__RuleID__c = 'WARR_RULE'; 
        SVMXA360__CONF_WarrantyConfig__c result = (SVMXA360__CONF_WarrantyConfig__c)WARR_ManageWarranty_LS.updateRecord(config);
        System.assert(result!=null);
    }

    @isTest
    static void getMatchingWarrantyTermRecordsTest() {
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        Contact cont = (Contact)SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => product.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});
        List<WarrantyTerm> lstWarrantyTerms = WARR_ManageWarranty_LS.getMatchingWarrantyTermRecords(asst.Id);
        System.assertEquals(0, lstWarrantyTerms.size());
    }

    @isTest
    static void getUnmatchedWarrantyTermRecordsTest() {
        List<String> lstWarrantyTermIds = new List<String>();
        List<WarrantyTerm> lstWarrantyTerms = WARR_ManageWarranty_LS.getUnmatchedWarrantyTermRecords(lstWarrantyTermIds);
        System.assertEquals(0, lstWarrantyTerms.size());
    }

    @isTest
    static void searchWarrantyTermRecordsTest() {
        List<WarrantyTerm> lstWarrantyTermIds = new List<WarrantyTerm>();
        //lstWarrantyTermIds = (List<WarrantyTerm>) SvmxTestDataFactory.insertSObjectList('WarrantyTerm', 2);
        List<WarrantyTerm> lstWarrantyTerms = WARR_ManageWarranty_LS.searchWarrantyTermRecords(lstWarrantyTermIds, 'default');
        System.assert(lstWarrantyTerms != null);
    }

    @isTest
    static void getAssetRecordTest() {
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        Contact cont = (Contact)SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => product.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});
        Asset assetRecord = WARR_ManageWarranty_LS.getAssetRecord(asst.Id);
        System.assert(assetRecord != null);
    }

    @isTest
    static void createManualWarrantyTest() {
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        Contact cont = (Contact)SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => product.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});
        Map<String,Object> mapFieldValue = getWarrantyTemplateField();
        WarrantyTerm warrTemplate = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', mapFieldValue);
        AssetWarranty assetWarranty = WARR_ManageWarranty_LS.createManualWarranty(JSON.serialize(warrTemplate), asst);
        System.assert(assetWarranty != null);
    }

    static Map<String,Object> getWarrantyTemplateField(){
        Map<String,Object> mapFieldValue = new Map<String,Object>();
        mapFieldValue.put('EffectiveStartDate', 'Install Date');
        mapFieldValue.put('WarrantyDuration', 1);
        mapFieldValue.put('ExpensesCoveredDuration', 1);
        mapFieldValue.put('LaborCoveredDuration', 1);
        mapFieldValue.put('PartsCoveredDuration', 1);
        mapFieldValue.put('IsActive', true);
        mapFieldValue.put('LaborCovered', 50);
        mapFieldValue.put('PartsCovered', 50);
        mapFieldValue.put('WarrantyUnitOfTime', 'Years');
        mapFieldValue.put('ExpensesCoveredUnitOfTime', 'Years');
        mapFieldValue.put('LaborCoveredUnitOfTime', 'Years');
        mapFieldValue.put('PartsCoveredUnitOfTime', 'Years');
        return mapFieldValue;
    }
}