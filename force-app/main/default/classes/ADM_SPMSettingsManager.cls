/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides implementation for managing all the Settings related to 
 * 		  SPM Designer
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        			Name                    Date            Comment
 *****************************************************************************************************
 *    A360ADM-1841          Sachin S                16 Mar 2022     Created.
 *****************************************************************************************************/
public with sharing class ADM_SPMSettingsManager {
    
    public static final String ENABLE_DEBUG_MODE = 'ENABLE_DEBUG_MODE';
    Map<String, String> defaultSPMSettings = new Map<String, String> { ENABLE_DEBUG_MODE => 'false' };

    public Adm.SPMSettingInfo saveSettingInfo( Adm.SPMSettingInfo sPMSetting ) {
		System.debug( LoggingLevel.DEBUG, 'saveDebugSettings() - enter' );
        
        try {
            if(sPMSetting == null || sPMSetting.name == null || sPMSetting.enableDebugMode == null){
                System.debug( LoggingLevel.ERROR, 'saveDebugSettings() : Invalid request parameters. sPMSetting= ' + sPMSetting );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );            
            }
            
            if ( !defaultSPMSettings.containsKey(sPMSetting.name) ) {
                System.debug( LoggingLevel.ERROR, 'saveDebugSettings() : Invalid Setting key. Setting Name= ' + sPMSetting.name );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );                 
            }
            
            SVMXA360__ApplicationSetting__c settingRecord = new SVMXA360__ApplicationSetting__c();
            settingRecord.Name = sPMSetting.name.replace('_', '');
            settingRecord.SVMXA360__ApplicationModule__c = 'SPM';
            settingRecord.SVMXA360__ApplicationSubmodule__c = 'Runtime';
            settingRecord.SVMXA360__SettingValue__c = sPMSetting.enableDebugMode != null ? String.valueOf(sPMSetting.enableDebugMode): null;
            settingRecord.SVMXA360__DeveloperName__c = sPMSetting.name;
            svmxDatabase.upsertRecord(settingRecord, SVMXA360__ApplicationSetting__c.fields.SVMXA360__DeveloperName__c, true);
            sPMSetting.id = settingRecord.Id;
            Map<String, SVMXA360__ApplicationSettingAccess__c> profileAccessRecordMap = new Map<String, SVMXA360__ApplicationSettingAccess__c>();
            for(SVMXA360__ApplicationSettingAccess__c accessRecord :  (List<SVMXA360__ApplicationSettingAccess__c>)SvmxDatabase.query([SELECT Id, SVMXA360__ProfileId__c, 
                                                              SVMXA360__ApplicationSettingId__c 
                                                              FROM SVMXA360__ApplicationSettingAccess__c ])){
            	profileAccessRecordMap.put(accessRecord.SVMXA360__ProfileId__c, accessRecord);
                                                              
            }
                       
            
            List<SVMXA360__ApplicationSettingAccess__c> newAccessRecordList = new List<SVMXA360__ApplicationSettingAccess__c>();
            if ( sPMSetting.selectedProfileIds != null ) {
                for (String profileId : new Set<String>(sPMSetting.selectedProfileIds)) {
                    if(!profileAccessRecordMap.containsKey(profileId)){
                        SVMXA360__ApplicationSettingAccess__c newAccessRecord = new SVMXA360__ApplicationSettingAccess__c();
                        newAccessRecord.SVMXA360__ApplicationSettingId__c = settingRecord.Id;
                        newAccessRecord.SVMXA360__ProfileId__c = profileId;  
                        newAccessRecordList.add(newAccessRecord);
                    } else {
						profileAccessRecordMap.remove(profileId);
                    }
                }
            }
            
            if (!newAccessRecordList.isEmpty()) {
                SvmxDatabase.insertRecord(newAccessRecordList);
            }
            
            if (!profileAccessRecordMap.isEmpty()) {
                SvmxDatabase.deleteRecord(profileAccessRecordMap.values());
            }
        }   
        catch ( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'saveDebugSettings() : Failed to save SPM debug settings. Error' + e.getStackTraceString() );
            throw e;
        }
		finally {
            System.debug( LoggingLevel.DEBUG, 'saveDebugSettings() - exit;' );
        }
		return sPMSetting;        
    }
    
    public Adm.SPMSettingInfo retreiveSettingInfo ( String settingName ) {
       	System.debug( LoggingLevel.DEBUG, 'retreiveSettingInfo() - enter' );
        
        Adm.SPMSettingInfo sPMSetting = new Adm.SPMSettingInfo();

        try {
            if (settingName != null && !defaultSPMSettings.containsKey(settingName)) {
                System.debug( LoggingLevel.ERROR, 'retreiveSettingInfo() : Invalid Setting key. Setting Name= ' + settingName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );            
            } 
                
            sPMSetting.name = settingName;
            sPMSetting.enableDebugMode = Boolean.valueOf(defaultSPMSettings.get(settingName));
            
            List<SVMXA360__ApplicationSetting__c> settingRecordList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__SettingValue__c,
                                                               (SELECT Id, SVMXA360__ProfileId__c 
                                                                FROM 
                                                                SVMXA360__ApplicationSettingAccess__r )
                                                               FROM SVMXA360__ApplicationSetting__c 
                                                               WHERE SVMXA360__DeveloperName__c =: settingName ]);
            if (!settingRecordList.isEmpty()) {
                sPMSetting.id = settingRecordList[0].Id;
                sPMSetting.enableDebugMode = settingRecordList[0].SVMXA360__SettingValue__c != null ? boolean.valueOf(settingRecordList[0].SVMXA360__SettingValue__c): false;
                sPMSetting.selectedProfileIds = new List<String>();
                for (SVMXA360__ApplicationSettingAccess__c accessRecord : settingRecordList[0].SVMXA360__ApplicationSettingAccess__r) {
                    sPMSetting.selectedProfileIds.add(accessRecord.SVMXA360__ProfileId__c);
                }
            }
            
        } 
        catch ( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'retreiveSettingInfo() : Failed to reterive SPM settings. Error' + e.getStackTraceString() );
            throw e;
        }
		finally {
            System.debug( LoggingLevel.DEBUG, 'retreiveSettingInfo() - exit;' );
        }
        
        return sPMSetting;  

    }

    public static Boolean getDebugModeSettings () {
        Boolean enableDebugSetting = false;
        List<SVMXA360__ApplicationSettingAccess__c> sPMAccessRecordList = (List<SVMXA360__ApplicationSettingAccess__c>)SvmxDatabase.query([SELECT SVMXA360__ApplicationSettingId__r.SVMXA360__SettingValue__c 
        FROM SVMXA360__ApplicationSettingAccess__c WHERE SVMXA360__ApplicationSettingId__r.SVMXA360__DeveloperName__c =: ENABLE_DEBUG_MODE AND
        SVMXA360__ProfileId__c =: UserInfo.getProfileId() ]);

        if (!sPMAccessRecordList.isEmpty()) {
            String settingValue = sPMAccessRecordList[0].SVMXA360__ApplicationSettingId__r.SVMXA360__SettingValue__c;
            enableDebugSetting = settingValue != null ? boolean.valueOf(settingValue): false;
        }

        return enableDebugSetting;
    }
}