@IsTest
public class TA_TechnicalAttributeRestInterface_UT {
    private static RestRequest req;
    private static RestResponse res;
    
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
        
        SVMXA360__CONF_PicklistDefinition__c picklistDef = (SVMXA360__CONF_PicklistDefinition__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_PicklistDefinition__c',
        new Map<String, Object> {
            'Name' => 'Install_Status_Values',
            'SVMXA360__DeveloperName__c' => 'Install_Status_Values',
            'SVMXA360__Values__c' => 'New;Closed;',
            'SVMXA360__Type__c' => 'Technical Attribute'
        });
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttribute = (SVMXA360__SM_TA_TechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_TechnicalAttribute__c', 
        new Map<string, Object> {
            'Name' => 'Temperature',
            'SVMXA360__DeveloperName__c' => 'Temperature',
            'SVMXA360__DataType__c' => 'Number',
            'SVMXA360__Unit__c' => 'Celsius'
        });
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttributeBoolean = (SVMXA360__SM_TA_TechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_TechnicalAttribute__c', 
        new Map<string, Object> {
            'Name' => 'Under Control',
            'SVMXA360__DeveloperName__c' => 'Under_Control',
            'SVMXA360__DataType__c' => 'Boolean'
        });
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttributeDate = (SVMXA360__SM_TA_TechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_TechnicalAttribute__c', 
        new Map<string, Object> {
            'Name' => 'Install Date',
            'SVMXA360__DeveloperName__c' => 'Install_Date',
            'SVMXA360__DataType__c' => 'Date'
        });
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttributeDatetime = (SVMXA360__SM_TA_TechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_TechnicalAttribute__c', 
        new Map<string, Object> {
            'Name' => 'Install Datetime',
            'SVMXA360__DeveloperName__c' => 'Install_Datetime',
            'SVMXA360__DataType__c' => 'Datetime'
        });
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttributePicklist = (SVMXA360__SM_TA_TechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_TechnicalAttribute__c', 
        new Map<string, Object> {
            'Name' => 'Install Status',
            'SVMXA360__DeveloperName__c' => 'Install_Status',
            'SVMXA360__DataType__c' => 'Picklist',
            'SVMXA360__PicklistDefinitionId__c' => picklistDef.Id
        });
        
        
        
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTANumber = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => techAttribute.Id,
            'SVMXA360__Value__c' => '105.5',
            'SVMXA360__NumberValue__c' => 105.5,
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1
        });
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTABoolean = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => techAttributeBoolean.Id,
            'SVMXA360__Value__c' => 'true',
            'SVMXA360__BooleanValue__c' => True,
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1
        });
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTADate = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => techAttributeDate.Id,
            'SVMXA360__Value__c' => '2022-08-04',
            'SVMXA360__DateValue__c' => Date.valueOf('2022-08-04'),
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1
        });
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTADatetime = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => techAttributeDatetime.Id,
            'SVMXA360__Value__c' => '2022-08-04 05:13:05',
            'SVMXA360__DatetimeValue__c' => Datetime.valueOf('2022-08-04 05:13:05'),
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1
        });
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTAPicklist = (SVMXA360__SM_TA_AssetTechnicalAttribute__c) SvmxTestDataFactory.insertSObject ('SVMXA360__SM_TA_AssetTechnicalAttribute__c', 
        new Map<string, Object> {
            'SVMXA360__AssetId__c' => assetRecord.Id,
            'SVMXA360__AttributeId__c' => techAttributePicklist.Id,
            'SVMXA360__Value__c' => 'Closed',
            'SVMXA360__PreviousValue__c' => 'New',
            'SVMXA360__CapturedBy__c' => UserInfo.getUserId(),
            'SVMXA360__CapturedOn__c' => Datetime.now() - 1
        });
        
        
        
    }
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/technicalAttribute/v1/' + method + '/';
        if((httpMethod == 'GET' || httpMethod == 'DELETE') && argument != ''){
            req.requestURI += argument+'/';
        }
        if(httpMethod == 'POST'){
            req.requestBody = Blob.valueOf(argument);
        }
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.addParameter('objectName', param );
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    @IsTest
    static  void testInsertTechnicalAttributes() {
        
        Test.startTest();
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        String jsonData = '{"targetObject":null,"source":"External System","objectName":"Asset","attributeList":[{"value":"Perfect","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"","attributeKey":"Filter_condition"},{"value":"50","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Number","attributeKey":"Ink_Level"},{"value":"2022-08-04 05:13:05","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"datetime","attributeKey":"Check_Performed_Datetime"},{"value":"true","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"boolean","attributeKey":"Check_Performed"},{"value":"2022-08-04","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Date","attributeKey":"Check_Performed_Date"}]}';
    
        createRestContext('saveTechnicalAttributes', 'POST', '', jsonData);
        TA_TechnicalAttributeRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    @IsTest
    static  void testUpdateTechnicalAttributes() {
        
        Test.startTest();
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        String jsonData = '{"targetObject":null,"source":"External System","objectName":"Asset","attributeList":[{"value":"102","unit":"Celsius","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Number","attributeKey":"Temperature"},{"value":"false","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Boolean","attributeKey":"Under_Control"}, {"value":"2022-08-04","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Date","attributeKey":"Install_Date"}, {"value":"2022-08-04 05:13:05","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Datetime","attributeKey":"Install_Datetime"},{"value":"In Progress","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Picklist","attributeKey":"Install_Status"},{"value":"In Progress","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Picklist","attributeKey":"Close_Status"}]}';

        createRestContext('saveTechnicalAttributes', 'POST', '', jsonData);
        TA_TechnicalAttributeRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    @IsTest
    static  void testsaveTechnicalAttributesExceptionScenario() {
        
        Test.startTest();
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        String jsonData = '{"targetObject":"Opportunity","source":"External System","objectName":"Opportunity","attributeList":[{"value":"Perfect","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"text","attributeKey":"Filter_condition"}]}';
    
        createRestContext('saveTechnicalAttributes', 'POST', '', jsonData);
        TA_TechnicalAttributeRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    @IsTest
    static  void testUpdateTechnicalAttributesFail() {
        
        Test.startTest();
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        String jsonData = '{"targetObject":null,"source":"External System","objectName":"Asset","attributeList":[{"value":"InvalidDate","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Datetime","attributeKey":"Install_Datetime"}]}';

        createRestContext('saveTechnicalAttributes', 'POST', '', jsonData);
        TA_TechnicalAttributeRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    @IsTest
    static  void testEmptyRequestAndMissingParam() {
        
        Test.startTest();
        
        String jsonData = '{}';

        createRestContext('saveTechnicalAttributes', 'POST', '', jsonData);
        TA_TechnicalAttributeRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        //Missing parameters
        
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        
        jsonData = '{"targetObject":null,"source":"External System","objectName":"Asset","attributeList":[{"value":"","unit":"","recordName":null,"recordId":"'+assetRecord.Id+'","dataType":"Datetime","attributeKey":"Install_Datetime"}]}';


        createRestContext('saveTechnicalAttributes', 'POST', '', jsonData);
        TA_TechnicalAttributeRestInterface.doPost();
        
		responseStr = res.responseBody.toString();
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }
    
    
}