@IsTest
public class ADM_EntitlementSettingsManager_UT {
	@testSetup public static void setup() {
        Id objConfigRecordTypeId = ADM_EntitlementSettingsManager.getInstance().getRecordTypeInfosByDeveloperName(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();

        // Not used SvmxTestDataFactory.insertSObjectList as it does not support RecordTypeId
        List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettingList = SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_EntitlementSettings__c', 
                                              new Map<String,Object>{'SVMXA360__ObjectAPIName__c' => 'WorkOrder'}, 
                                              5);
        for ( SVMXA360__CONF_EntitlementSettings__c entitlementSetting : entitlementSettingList ) {
            entitlementSetting.RecordTypeId = objConfigRecordTypeId;
        }

        insert entitlementSettingList;
    }
    
    testmethod static void testGetAllEntitlementSettings() {
        
        Test.startTest();
        
        List<Adm.EntitlementSettings> entitlementSettingsList = ADM_EntitlementSettingsManager.getInstance().getAllEntitlementSettings();
        
        System.assert( entitlementSettingsList != null );
        System.assert( entitlementSettingsList.size() == 5 );
        
        Test.stopTest();
    }

    testmethod static void testGetAllEntitlementSettings2() {
        //Deleting the records created in the setup audit trail.
        delete [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c LIMIT 100];
        Test.startTest();
        
        List<Adm.EntitlementSettings > entitlementSettingsRecordList = ADM_EntitlementSettingsManager.getInstance().getAllEntitlementSettings();
               
        System.assert( entitlementSettingsRecordList != null );
     	
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementSettings() {
        
        Test.startTest();
        
        Adm.EntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings('WorkOrder');
        System.assert( entitlementSettings != null );
        
        Test.stopTest();
    }
    
    testmethod static void testGetEntitlementSettings_Invalid() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testGetCommonEntitlementSetting() {
        Id recordTypeId = ADM_EntitlementSettingsManager.getInstance().getRecordTypeInfosByDeveloperName(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSetting = (SVMXA360__CONF_EntitlementSettings__c) SvmxTestDataFactory.createSObject( 'SVMXA360__CONF_EntitlementSettings__c', 
                                                new Map<String,Object>{});
        entitlementSetting.RecordTypeId = recordTypeId;
        entitlementSetting.SVMXA360__DeveloperName__c = 'Developer_Name987';
        insert entitlementSetting;

        Test.startTest();
        
        Adm.CommonEntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSetting();
        System.assert( entitlementSettings != null );
        
        Test.stopTest();
    }

    testmethod static void testGetCommonEntitlementSetting_Invalid() {
        Boolean isExceptionThrown = false;

        Test.startTest();
        
        Adm.CommonEntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSetting();
        System.assert( entitlementSettings == null );
        
        Test.stopTest();
    }

    testmethod static void testGetUnsupportedStackRankingFields() {
       
        Test.startTest();
        
        List<String> fieldList  = ADM_EntitlementSettingsManager.getInstance().getUnsupportedStackRankingFields();
        System.assert( fieldList != null );
        
        Test.stopTest();
    }

    testmethod static void testSaveEntitlementSettings() {
        
        Test.startTest();
        
        List<Adm.EntitlementSettings> entitlementSettingsList = ADM_EntitlementSettingsManager.getInstance().getAllEntitlementSettings();
        Adm.EntitlementSettings entitlementSettings = entitlementSettingsList.get(0);
        entitlementSettings.id = null;
        entitlementSettings.developerName = 'Test Developer Name';
        
     	entitlementSettings = ADM_EntitlementSettingsManager.getInstance().saveEntitlementSettings( entitlementSettings );
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.id != null );
        
        entitlementSettings.name = 'Name Update';
        entitlementSettings = ADM_EntitlementSettingsManager.getInstance().saveEntitlementSettings( entitlementSettings );
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.name.equals('Name Update') );
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings_ReadOnly() {
        
        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        
        try {
            
            List<Adm.EntitlementSettings> entitlementSettingsList = ADM_EntitlementSettingsManager.getInstance().getAllEntitlementSettings();
            Adm.EntitlementSettings entitlementSettings = entitlementSettingsList.get(0);
            entitlementSettings.id = null;
            entitlementSettings.developerName = 'Test Developer Name';
            
            ADM_EntitlementSettingsManager.getInstance().saveEntitlementSettings( entitlementSettings );
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitlementSettings_InvalidParam() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementSettingsManager.getInstance().saveEntitlementSettings( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testSaveCommonEntitlementSettings() {
        
        Id recordTypeId = ADM_EntitlementSettingsManager.getInstance().getRecordTypeInfosByDeveloperName(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION
        ).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSetting = (SVMXA360__CONF_EntitlementSettings__c) SvmxTestDataFactory.createSObject( 'SVMXA360__CONF_EntitlementSettings__c', 
                                                new Map<String,Object>{});
        entitlementSetting.RecordTypeId = recordTypeId;
        entitlementSetting.SVMXA360__DeveloperName__c = 'Developer_Name987';
        insert entitlementSetting;

        Test.startTest();

        Adm.CommonEntitlementSettings entitlementSettings = new ADM_EntitlementServiceImpl().getCommonEntitlementSetting();
        entitlementSettings.adjustVisitCountAssignedObject = 'Case';

     	entitlementSettings = ADM_EntitlementSettingsManager.getInstance().saveCommonEntitlementSettings( entitlementSettings );
        
        System.assert( entitlementSettings != null );
        System.assert( entitlementSettings.id != null);
        System.assert( entitlementSettings.adjustVisitCountAssignedObject.equals('Case') );
        
        Test.stopTest();
    }

    testmethod static void testSaveCommonEntitlementSettings_InvalidParam1() {
        
        Test.startTest();
        
        try {
            ADM_EntitlementSettingsManager.getInstance().saveCommonEntitlementSettings( null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    testmethod static void testSaveCommonEntitlementSettings_InvalidParam2() {
        
        Id recordTypeId = ADM_EntitlementSettingsManager.getInstance().getRecordTypeInfosByDeveloperName(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSetting = (SVMXA360__CONF_EntitlementSettings__c) SvmxTestDataFactory.createSObject( 'SVMXA360__CONF_EntitlementSettings__c', 
                                                new Map<String,Object>{});
        entitlementSetting.RecordTypeId = recordTypeId;
        entitlementSetting.SVMXA360__DeveloperName__c = 'Developer_Name987';
        insert entitlementSetting;

        Test.startTest();

        Adm.CommonEntitlementSettings entitlementSettings = new ADM_EntitlementServiceImpl().getCommonEntitlementSetting();
        entitlementSettings.adjustVisitCountAssignedObject = 'Case';
        // Assigning incorrect user id instead of CONF_EntitlementSettings__c record id so that the exception will be thrown while saving the details.
        entitlementSettings.id = UserInfo.getUserId();
        try{
            entitlementSettings = ADM_EntitlementSettingsManager.getInstance().saveCommonEntitlementSettings( entitlementSettings );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testGetAllEntitlementSettingsRecords() {
        
        Test.startTest();
        
        List<SVMXA360__CONF_EntitlementSettings__c > entitlementSettingsRecordList = ADM_EntitlementSettingsManager.getInstance().getAllEntitlementSettingsRecords();
               
        System.assert( entitlementSettingsRecordList != null );
        System.assert( entitlementSettingsRecordList.size() == 5 );
     	
        Test.stopTest();
    }

    @IsTest
    static void testGetEntitlementSettingsRecords() {
        Test.startTest();
        
        List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettingsRecords('WorkOrder');
        System.assert( entitlementSettings != null );
        
        Test.stopTest();
    }

    @IsTest
    static void testGetEntitlementSettingsRecords_InvalidParam() {
        Test.startTest();
        
        try{
            ADM_EntitlementSettingsManager.getInstance().getEntitlementSettingsRecords('');
            System.assert(false);
        }
        catch(Exception e){
            System.assert(true);
        }
        
        
        Test.stopTest();

    }
}