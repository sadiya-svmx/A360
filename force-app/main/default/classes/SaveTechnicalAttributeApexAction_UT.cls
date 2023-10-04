@IsTest
public class SaveTechnicalAttributeApexAction_UT {
    
    
    @testSetup public static void setup() {
        
        Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 60000',
            'ProductCode' => 'SPA600',
            'IsActive' => true,
            'Family' => 'Mobile'
        });
        
        Account account = new Account(Name = 'Test_Account123');
        insert account;
        
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test_Contact123', 'AccountId' => account.Id });
        
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset123',
            'Product2Id' => productRecord.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });
    }
    
    @IsTest
    static  void testSaveTechnicalAttributes() {
        
        Test.startTest();
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        TechnicalAttributeData attr = new TechnicalAttributeData();
        attr.attributeKey = 'Filter_condition';
        attr.value = 'Perfect';
        attr.dataType = 'text';
        attr.unit = '';
        attr.recordId = assetRecord.Id;

        TechnicalAttributeRequest req = new TechnicalAttributeRequest();
        req.objectName = 'Asset';
        req.source = 'External System';
        req.attributeList = new List<TechnicalAttributeData>{attr};

        List<TechnicalAttributeRequest> responseList = SaveTechnicalAttributeApexAction.saveTechnicalAttributes(new List<TechnicalAttributeRequest>{req});
        System.assert(responseList != null);
        System.assert(!responseList.isEmpty());
        
        Test.stopTest();
    }
    
    @IsTest
    static  void testSaveTechnicalAttributesException() {
        
        Test.startTest();
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        TechnicalAttributeData attr = new TechnicalAttributeData();
        attr.attributeKey = 'Filter_condition';
        attr.value = 'Perfect';
        attr.dataType = 'text';
        attr.unit = '';
        attr.recordId = null;  //necessary parameters missing

        TechnicalAttributeRequest req = new TechnicalAttributeRequest();
        req.objectName = 'Asset';
        req.source = 'External System';
        req.attributeList = new List<TechnicalAttributeData>{attr};

        try{
            List<TechnicalAttributeRequest> responseList = SaveTechnicalAttributeApexAction.saveTechnicalAttributes(new List<TechnicalAttributeRequest>{req});
        }catch(Exception e){
            System.assert(e.getMessage() != null);
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static  void testEmptyRequest() {
        
        Test.startTest();
        
        try{
            List<TechnicalAttributeRequest> responseList = SaveTechnicalAttributeApexAction.saveTechnicalAttributes(new List<TechnicalAttributeRequest>());
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER) != -1);
        }
        
        Test.stopTest();
    }
}