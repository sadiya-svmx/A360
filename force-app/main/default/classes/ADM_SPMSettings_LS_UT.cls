@isTest
public class ADM_SPMSettings_LS_UT {
    
    @testSetup public static void setup() {        
       	SVMXA360__ApplicationSetting__c settingRec = (SVMXA360__ApplicationSetting__c) SvmxTestDataFactory.insertSObject('SVMXA360__ApplicationSetting__c', 
        new Map<String,Object>{
                 'Name' => 'ENABLE_DEBUG_MODE',
                 'SVMXA360__SettingValue__c' => 'true',
                 'SVMXA360__DeveloperName__c' => 'ENABLE_DEBUG_MODE'
        });
        
        List<Profile> profiles = [SELECT Id FROM Profile ORDER BY Name];
        SVMXA360__ApplicationSettingAccess__c settingAccess = new SVMXA360__ApplicationSettingAccess__c(
            SVMXA360__ApplicationSettingId__c = settingRec.Id,
            SVMXA360__ProfileId__c = profiles[0].Id
        );
        insert settingAccess;
    }

    public static testMethod void testGetDebugSettings (){
   		Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_SPMSettings_LS.retreiveSettingInfo('ENABLE_DEBUG_MODE');
        Test.stopTest();
		System.assertEquals(serviceResponse.success, true);
    }
    
    public static testMethod void testGetDebugSettingsInvalid (){
   		Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_SPMSettings_LS.retreiveSettingInfo('ENABLE_123');
        Test.stopTest();
		System.assertEquals(serviceResponse.success, false);
    }  
    
    public static testMethod void testSaveDebugSettings (){
        Adm.SPMSettingInfo settingInfo = new Adm.SPMSettingInfo();
        settingInfo.name = 'ENABLE_DEBUG_MODE';
        settingInfo.enableDebugMode = false;
        List<Profile> profiles = [SELECT Id FROM Profile ORDER BY Name DESC];
        System.assert(profiles.size() > 1);
        settingInfo.selectedProfileIds = new List<String>{profiles[0].Id, profiles[1].Id};
   		Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_SPMSettings_LS.saveSettingInfo(JSON.serialize(settingInfo));
        Test.stopTest();
		System.assertEquals(serviceResponse.success, true);
    } 
    
    public static testMethod void testSaveDebugSettingsInvalidKey (){
        Adm.SPMSettingInfo settingInfo = new Adm.SPMSettingInfo();
        settingInfo.name = 'ENABLE_123';
        settingInfo.enableDebugMode = false;
   		Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_SPMSettings_LS.saveSettingInfo(JSON.serialize(settingInfo));
        Test.stopTest();
		System.assertEquals(serviceResponse.success, false);
    }  
    
    public static testMethod void testSaveDebugSettingsInvalidArguments (){
        Adm.SPMSettingInfo settingInfo = new Adm.SPMSettingInfo();
        settingInfo.name = 'ENABLE_DEBUG_MODE';
   		Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_SPMSettings_LS.saveSettingInfo(JSON.serialize(settingInfo));
        Test.stopTest();
		System.assertEquals(serviceResponse.success, false);
    }
}