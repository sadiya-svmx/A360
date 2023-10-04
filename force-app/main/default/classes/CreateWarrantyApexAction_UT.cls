@isTest
public with sharing class CreateWarrantyApexAction_UT {
    @TestSetup
    static void makeData(){
        SvmxTestDataFactory.insertSObjectList('Product2', 2);
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'WarrantyTerm',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'AssetWarranty','SVMXA360__DeveloperName__c' => 'MAP001',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetails = SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 2);
        objectMappingDetails.get(0).SVMXA360__TargetFieldAPIName__c = 'SVMXA360__RMA_Required__c';
        objectMappingDetails.get(0).SVMXA360__SourceFieldAPIName__c = 'SVMXA360__RMA_Required__c';
        objectMappingDetails.get(0).SVMXA360__Type__c  = 'Field';
        
        objectMappingDetails.get(1).SVMXA360__TargetFieldAPIName__c = 'SVMXA360__Shipment_Allowed__c';
        objectMappingDetails.get(1).SVMXA360__SourceFieldAPIName__c = 'SVMXA360__Shipment_Allowed__c';
        objectMappingDetails.get(1).SVMXA360__Type__c  = 'Field';

        insert objectMappingDetails;

        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_WarrantyConfig__c', 
                                                    new Map<String,Object>{'SVMXA360__AutoWarrOnCreateAsset__c'=> true, 
                                                    'SVMXA360__EffectiveFromConfig__c'=>'{"Manufacture Date":"InstallDate","Install Date":"InstallDate","Purchase Date":"PurchaseDate"}', 
                                                    'SVMXA360__ObjectMapping__c'=>objectMappingRecord.Id, 'SVMXA360__RuleID__c'=>'Rule001', 
                                                    'SVMXA360__RuleScope__c'=>'Global'});
    }

    @isTest
    static void createWarrantyWithInvalidInputParams() {
        List<CreateWarrantyApexAction.WARR_WarrantyRequest> lstRequest = new List<CreateWarrantyApexAction.WARR_WarrantyRequest>();
        String exceptionMessage = '';
        try{
            CreateWarrantyApexAction.createWarranty(lstRequest);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
            System.assert(ex.getMessage().contains('null or empty'));
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void testwarrantyManagementForSingleAsset() {
        Product2 product = [Select Id from Product2 limit 1];
        Account acc = [Select Id from Account limit 1];
        Contact cont = [Select Id from Contact where AccountId = :acc.Id limit 1];
        Map<String,Object> mapFieldValue = getWarrantyTemplateField();

        WarrantyTerm warrTemplate = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', mapFieldValue);

        Map<String,Object> mapFieldValue1 = new Map<String,Object>();
        mapFieldValue1.put('CoveredProductId', product.Id);
        mapFieldValue1.put('WarrantyTermId', warrTemplate.Id);
        mapFieldValue1.put('CoveredProductFamily', '');
        
        SvmxTestDataFactory.insertSObject('ProductWarrantyTerm', mapFieldValue1);

        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => product.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});
        List<Asset> lstAssets = new List<Asset>();
        lstAssets.add(asst);
        system.assertNotEquals(null, asst);

        List<CreateWarrantyApexAction.WARR_WarrantyRequest> lstRequest = new List<CreateWarrantyApexAction.WARR_WarrantyRequest>();
        CreateWarrantyApexAction.WARR_WarrantyRequest req = new CreateWarrantyApexAction.WARR_WarrantyRequest();
        req.eventType = 'create_event';
        req.lstAssetRecords = lstAssets;
        lstRequest.add(req);
        system.debug('lstRequest = ' + lstRequest);

        CreateWarrantyApexAction.createWarranty(lstRequest);
    }

    @isTest
    static void testwarrantyManagementForBulkAssets() {
        List<Product2> lstProducts = [Select Id from Product2];
        Account acc = [Select Id from Account limit 1];
        Contact cont = [Select Id from Contact where AccountId = :acc.Id limit 1];
        Map<String,Object> mapFieldValue = getWarrantyTemplateField();
        WarrantyTerm warrTemplate = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', mapFieldValue);
        List<ProductWarrantyTerm> lstWarrantyTermProducts = (List<ProductWarrantyTerm>)SvmxTestDataFactory.createSObjectList('ProductWarrantyTerm', new Map<String,Object>{'WarrantyTermId' => warrTemplate.Id}, 2);
        lstWarrantyTermProducts[0].CoveredProductId = lstProducts[0].Id;
        lstWarrantyTermProducts[0].CoveredProductFamily = '';
        
        lstWarrantyTermProducts[1].CoveredProductId = lstProducts[1].Id;
        lstWarrantyTermProducts[1].CoveredProductFamily = '';
        insert lstWarrantyTermProducts;

        List<Asset> lstAssets = SvmxTestDataFactory.createSObjectList('Asset', new Map<String,Object>{'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()}, 2);
        lstAssets[0].Name = 'Test Asset 1';
        lstAssets[0].Product2Id = lstProducts[0].Id;
        lstAssets[1].Name = 'Test Asset 2';
        lstAssets[1].Product2Id = lstProducts[1].Id;
        insert lstAssets;
        system.assertEquals(2, lstAssets.size());

        List<CreateWarrantyApexAction.WARR_WarrantyRequest> lstRequest = new List<CreateWarrantyApexAction.WARR_WarrantyRequest>();
        CreateWarrantyApexAction.WARR_WarrantyRequest req = new CreateWarrantyApexAction.WARR_WarrantyRequest();
        req.eventType = 'create_event';
        req.lstAssetRecords = lstAssets;
        lstRequest.add(req);
        system.debug('lstRequest = ' + lstRequest);

        CreateWarrantyApexAction.createWarranty(lstRequest);
    }

    @isTest
    static void testwarrantyManagementNoMatchingProductTerm() {
        Product2 product = [Select Id from Product2 limit 1];
        Account acc = [Select Id from Account limit 1];
        Contact cont = [Select Id from Contact where AccountId = :acc.Id limit 1];
        Map<String,Object> mapFieldValue = getWarrantyTemplateField();
        SvmxTestDataFactory.insertSObject('WarrantyTerm', mapFieldValue);
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 2','Product2Id' => product.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});
        List<Asset> lstAssets = new List<Asset>();
        lstAssets.add(asst);
        system.assertNotEquals(null, asst);
    }

    @isTest
    static void testwarrantyManagementForAssetWithNoProduct() {
        Product2 product = [Select Id from Product2 limit 1];
        Account acc = [Select Id from Account limit 1];
        Contact cont = [Select Id from Contact where AccountId = :acc.Id limit 1];
        Map<String,Object> mapFieldValue = getWarrantyTemplateField();
        WarrantyTerm warrTemplate = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', mapFieldValue);
        
        mapFieldValue = new Map<String,Object>();
        mapFieldValue.put('CoveredProductId', product.Id);
        mapFieldValue.put('WarrantyTermId', warrTemplate.Id);
        mapFieldValue.put('CoveredProductFamily', '');
        SvmxTestDataFactory.insertSObject('ProductWarrantyTerm', mapFieldValue);

        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 3','AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});
        List<Asset> lstAssets = new List<Asset>();
        lstAssets.add(asst);
        system.assertNotEquals(null, asst);
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