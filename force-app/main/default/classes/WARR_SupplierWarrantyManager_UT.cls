@IsTest
public class WARR_SupplierWarrantyManager_UT {

    @testSetup public static void setup() {

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

        Asset assetRecord2 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Solar Panel 331',
            'Product2Id' => productRecord.Id,
            'Status' => 'Installed',
            'ParentId' => assetRecord.Id,
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        AssetWarranty assetWarrantyRecord = (AssetWarranty) SvmxTestDataFactory.insertSObject( 'AssetWarranty', 
        new Map<String,Object>{
            'AssetId' => assetRecord2.Id,
            'SVMXA360__SupplierAccountId__c' => account.Id,
            'WarrantyType' => 'Supplier',
            'SVMXA360__SupplierContactId__c' => contact.Id
        });

        Case caseRecord = (Case) SvmxTestDataFactory.insertSObject( 'Case', 
        new Map<String,Object>{
            'AssetId' => assetRecord.Id,
            'AccountId' => account.Id
        });

        ReturnOrder roRecord = (ReturnOrder) SvmxTestDataFactory.insertSObject( 'ReturnOrder', 
        new Map<String,Object>{
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'AccountId' => account.Id
        });
    }

    testmethod static void testGetSupplierWarranties() {

        Test.startTest();
            List<Case> caseRecords = [SELECT Id FROM Case];

            List<Warr.SupplierWarranty> supplierWarranties = WARR_SupplierWarrantyManager.getInstance().getSupplierWarranties(caseRecords[0].Id);

            System.assert( supplierWarranties != null );
        Test.stopTest();
    }

    testmethod static void testGetSupplierWarranties_LS() {

        Test.startTest();
            List<Case> caseRecords = [SELECT Id FROM Case];

            Common.ServiceResponse serviceResponse = WARR_ManageWarranty_LS.getSupplierWarranties(caseRecords[0].Id);

            System.assert( serviceResponse.success = true );
            System.assert( serviceResponse.data != null );
        Test.stopTest();
    }

    testmethod static void testGetSupplierWarranties_LSNull() {

        Test.startTest();
            try {
                Common.ServiceResponse serviceResponse = WARR_ManageWarranty_LS.getSupplierWarranties(null);
            }
            catch( SvmxSystem.SvmxNestedException e ) {
                System.assert(true);
            }
        Test.stopTest();
    }

    testmethod static void testGetSupplierWarranties_RO() {

        Test.startTest();
            List<ReturnOrder> roRecords = [SELECT Id FROM ReturnOrder];

            List<Warr.SupplierWarranty> supplierWarranties = WARR_SupplierWarrantyManager.getInstance().getSupplierWarranties(roRecords[0].Id);

            System.assert( supplierWarranties != null );
        Test.stopTest();
    }

    testmethod static void testGetSupplierWarranties_NullParam() {
        
        Test.startTest();
        try {
            WARR_SupplierWarrantyManager.getInstance().getSupplierWarranties(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        Test.stopTest();
    }
}