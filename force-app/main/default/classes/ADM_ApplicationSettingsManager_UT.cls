@IsTest
public class ADM_ApplicationSettingsManager_UT {
    testmethod static void testGetAppSettings() { 
        Common.ServiceResponse serviceResponse = ADM_ApplicationSettings_LS.getApplicationSetting('Apply_Template');
        system.AssertEquals(serviceResponse.success, true);
    }

    testmethod static void testGetAppSettingsForUserGroup() { 
        Common.ServiceResponse serviceResponse = ADM_ApplicationSettings_LS.getApplicationSetting('User_Group');
        system.AssertEquals(serviceResponse.success, true);
    }
    
    testmethod static void testSaveAppSettings() { 
        ADM.ApplicationSetting appRec = new ADM.ApplicationSetting();
        appRec.Name = ADM_ApplicationSettingsManager.technicalAttributeSettingName.replace('_','');
        appRec.module = 'Technical Attribute';
        appRec.subModule = 'Template Matching';
        appRec.settingValue = 'First'; 
        appRec.developerName = ADM_ApplicationSettingsManager.technicalAttributeSettingName;
        Common.ServiceResponse serviceResponse = ADM_ApplicationSettings_LS.saveApplicationSettingRecord(JSON.serialize(appRec));
        system.AssertEquals(serviceResponse.success, true);
        serviceResponse = ADM_ApplicationSettings_LS.saveApplicationSettingRecord(null);
        system.AssertEquals(serviceResponse.success, false);
    }

}