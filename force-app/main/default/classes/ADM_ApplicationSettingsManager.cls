/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/create Application Settings Record
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Mahima Tarika      5 August 2022      Created
 *****************************************************************************************************/ 
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_ApplicationSettingsManager {
    private static ADM_ApplicationSettingsManager instance;
    public static string technicalAttributeSettingName = 'Apply_Template'; //pass this variable from the applicationSetting_LS class
    public static string TA_UserGroupSettingName = 'User_Group';
    private ADM_ApplicationSettingsManager(){

    }
    public static ADM_ApplicationSettingsManager getInstance () {
        if(instance == null){
            return new ADM_ApplicationSettingsManager();
        } else {
            return instance;
        }
    }
    /**
     * This method is used to create Application Settings Record.
     * 
     * @return Returns application setting record.
     */
    public Adm.ApplicationSetting saveApplicationSetting (Adm.ApplicationSetting wrapperRecord ) {
        SVMXA360__ApplicationSetting__c settingRecord = createApplicationSettingRecordFromWrapper(wrapperRecord);
        svmxDatabase.upsertRecord(settingRecord, SVMXA360__ApplicationSetting__c.fields.SVMXA360__DeveloperName__c, true);
        wrapperRecord.id = settingRecord.id;
        return wrapperRecord;
    }
    /**
     * This method is used to retrieve Application Settings Record.
     * 
     * @return Returns application setting record.
     */
    public Adm.ApplicationSetting getApplicationSetting (string developerName) {
        list<SVMXA360__ApplicationSetting__c> applicationSettingList = new list<SVMXA360__ApplicationSetting__c>();
        if(SVMXA360__ApplicationSetting__c.SObjectType.getDescribe().isAccessible()){
            applicationSettingList = [SELECT Id, SVMXA360__DeveloperName__c,SVMXA360__SettingValue__c, name, SVMXA360__ApplicationModule__c,SVMXA360__ApplicationSubmodule__c  FROM SVMXA360__ApplicationSetting__c WHERE SVMXA360__DeveloperName__c = :developerName];
        }
        Adm.ApplicationSetting appRecord = new Adm.ApplicationSetting();
        if(!applicationSettingList.isEmpty()){
            appRecord  = createApplicationSettingWrapper(applicationSettingList[0]);
        } else if ( developerName == ADM_ApplicationSettingsManager.technicalAttributeSettingName ) {
            appRecord = createDefaultTATemplateRuleSetting();
        } else if (developerName == ADM_ApplicationSettingsManager.TA_UserGroupSettingName ) {
            appRecord = createDefaultTAUserGroupSetting();
        } 
        return appRecord;
    }

    private Adm.ApplicationSetting createApplicationSettingWrapper (SVMXA360__ApplicationSetting__c applicationSettingRec) {
        Adm.ApplicationSetting matchRulePageRec = new Adm.ApplicationSetting();
        matchRulePageRec.id = applicationSettingRec.id;
        matchRulePageRec.developerName = applicationSettingRec.SVMXA360__DeveloperName__c;
        matchRulePageRec.settingValue = applicationSettingRec.SVMXA360__SettingValue__c;
        matchRulePageRec.Name = applicationSettingRec.name;
        matchRulePageRec.module = applicationSettingRec.SVMXA360__ApplicationModule__c;
        matchRulePageRec.subModule = applicationSettingRec.SVMXA360__ApplicationSubmodule__c;
        return matchRulePageRec;
    }

    private SVMXA360__ApplicationSetting__c createApplicationSettingRecordFromWrapper (Adm.ApplicationSetting wrapperRecord) {
        SVMXA360__ApplicationSetting__c settingRecord = new SVMXA360__ApplicationSetting__c();
        settingRecord.Name = wrapperRecord.Name;
        settingRecord.SVMXA360__ApplicationModule__c = wrapperRecord.module;
        settingRecord.SVMXA360__ApplicationSubmodule__c = wrapperRecord.subModule;
        settingRecord.SVMXA360__SettingValue__c = wrapperRecord.settingValue;
        settingRecord.SVMXA360__DeveloperName__c = wrapperRecord.developerName;  
        return settingRecord;
    }



    private Adm.ApplicationSetting createDefaultTATemplateRuleSetting() {
        Adm.ApplicationSetting settingRecord = new Adm.ApplicationSetting();
        settingRecord.Name = ADM_ApplicationSettingsManager.technicalAttributeSettingName.replace('_', '');
        settingRecord.module = 'Technical Attribute';
        settingRecord.subModule = 'Template Matching';
        settingRecord.settingValue = 'First'; 
        settingRecord.developerName = ADM_ApplicationSettingsManager.technicalAttributeSettingName;
        return saveApplicationSetting(settingRecord);
    }

    private Adm.ApplicationSetting createDefaultTAUserGroupSetting() {
        Adm.ApplicationSetting settingRecord = new Adm.ApplicationSetting();
        settingRecord.Name = ADM_ApplicationSettingsManager.TA_UserGroupSettingName.replaceAll('_', ' ');
        settingRecord.module = 'Technical Attribute';
        settingRecord.subModule = 'User Group';
        settingRecord.settingValue = 'false'; 
        settingRecord.developerName = ADM_ApplicationSettingsManager.TA_UserGroupSettingName;
        return saveApplicationSetting(settingRecord);
    }
}