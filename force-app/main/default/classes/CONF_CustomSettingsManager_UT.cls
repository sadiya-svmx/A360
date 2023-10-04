@isTest
public class CONF_CustomSettingsManager_UT {

    @testSetup 
    static void setup() {
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'SVMXA360__Key__c' => 'ALLOWED_CORE_OBJECT'}, 10);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
    }
    
    testmethod static void testGetAllGlobalProperties() {
        
        Test.startTest();
        
        Map<String,List<Common.GlobalProperty>> allGlobalPropertiesMap = CONF_CustomSettingsManager.getInstance().getAllGlobalProperties();
        System.assert( allGlobalPropertiesMap.size() != 0 );
        
        Test.stopTest();
    }
    
    testmethod static void testGetAllowedCoreObjects() {
        
        Test.startTest();
        
        List<String> allowedCoreObjects = CONF_CustomSettingsManager.getInstance().getAllowedCoreObjects();
        System.assert( allowedCoreObjects.size() == 10, allowedCoreObjects.size() );
        
        Test.stopTest();
    }
    
    testmethod static void testGetGlobalPropertyValues() {
        
        Test.startTest();
        
        List<SVMXA360__CONF_CSET_GlobalProperties__c> allowedCoreObjects = CONF_CustomSettingsManager.getInstance().getGlobalPropertyValues('ALLOWED_CORE_OBJECT');
        System.assert( allowedCoreObjects.size() == 10, allowedCoreObjects.size() );
        
        Test.stopTest();
    }
    
    testmethod static void testGetGlobalPropertyValues_invalidParameter() {
        
        Test.startTest();
            
        try {
            CONF_CustomSettingsManager.getInstance().getGlobalPropertyValues('');
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            CONF_CustomSettingsManager.getInstance().getGlobalPropertyValues(null);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    @isTest
    public static void testGetGlobalPropertyByNameWithValue(){
        Test.startTest();
        Common.GlobalProperty response = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName('GP600');
        System.assertEquals(response.value, 'true', 'Custom setting value is set true.');
       Test.stopTest();
    }

    @isTest
    public static void testGetGlobalPropertyByNameWithNoValue(){
        Test.startTest();
        try{
            Common.GlobalProperty response = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName(null);
        }catch(Exception e){
            System.assert(true);
        }
       Test.stopTest();
    }

    @isTest
    public static void testGetGlobalPropertyByDummyValue(){
        Test.startTest();
        try{
            Common.GlobalProperty response = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName('DUMMY');
        }catch(Exception e){
            System.assert(true);
        }
       Test.stopTest();
    }

    @isTest
    public static void testSetApplicationUsageTrackingwithFalse(){
        Test.startTest();
        CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName ( CONF_CustomSettingsManager.NAME_ENABLE_APP_USAGE_TRACKING, 'false' );
        Common.GlobalProperty response = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName('GP600');
        System.assertEquals(response.value, 'false', 'Custom setting value is set false.');
       Test.stopTest();
    }

    @isTest
    public static void testSaveRecordActionExtensionClass(){
        Test.startTest();
        CONF_CustomSettingsManager.getInstance().saveRecordActionExtensionClass('Test Class');
        Common.GlobalProperty response = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName('REC_ACTION');
        System.assertEquals(response.value, 'Test Class', 'Class name set in value.');
       Test.stopTest();
    }
    
    testmethod static void testAddGlobalProperty() {
        
        Test.startTest();
        
        Common.GlobalProperty globalProperty = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName('GP600');
        System.assert( globalProperty != null );
        
        globalProperty.name = 'TEST';
        globalProperty.key = 'ALLOWED_CORE_OBJECT';
        
        String orgId = UserInfo.getOrganizationId();
        String todayDate = String.valueOf( System.today() );
        Blob encryptionData = Blob.valueOf(orgId + todayDate);
        
        Blob encryptionKey = Crypto.generateAesKey(128);
        Blob encryptedData = Crypto.encrypt('AES128', encryptionKey, Blob.valueOf('Asset 360 DataIV'), encryptionData) ;
        
        globalProperty = CONF_CustomSettingsManager.getInstance().addGlobalProperty(globalProperty, encryptionKey, encryptedData);
        
        System.assert( globalProperty != null );
        System.assert( globalProperty.id != null );
        
        Test.stopTest();
    }
}