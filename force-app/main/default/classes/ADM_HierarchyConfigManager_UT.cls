@IsTest
public class ADM_HierarchyConfigManager_UT {
    
    @testSetup public static void setup() {

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = 
            (SVMXA360__CONF_HierarchyConfig__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfig__c',
                                                                                 new Map<String,Object>{
                                                                                     'Name' => 'Test Standard Config',
                                                                                     'SVMXA360__DeveloperName__c' => 'Test_Standard_Config',
                                                                                     'IsDefault__c' => true
                                                                                });

        final SVMXA360__CONF_HierarchyConfigDetail__c hierarchyConfigDetail = 
            (SVMXA360__CONF_HierarchyConfigDetail__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfigDetail__c',
                                                                                new Map<String,Object>{
                                                                                    'SVMXA360__EnableDefaultRecordActions__c' => true,
                                                                                    'SVMXA360__EnableSPMWizards__c' => true,
                                                                                    'SVMXA360__HierarchyConfigId__c' => hierarchyConfigRecord.Id,
                                                                                    'SVMXA360__ObjectAPIName__c' => 'Account'
                                                                                });
        
        final SVMXA360__CONF_HierarchyFields__c hierarchyConfigField = 
            (SVMXA360__CONF_HierarchyFields__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyFields__c',
                                                                                new Map<String,Object>{
                                                                                    'SVMXA360__Sequence__c' => 1,
                                                                                    'SVMXA360__HierarchyConfigurationDetailId__c' => hierarchyConfigDetail.Id,
                                                                                    'SVMXA360__FieldAPIName__c' => 'Type'
                                                                                });
        
        String userProfileId = UserInfo.getProfileId();
        final SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccess = 
            (SVMXA360__CONF_HierarchyConfigAccess__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfigAccess__c',
                                                                                new Map<String,Object>{
                                                                                    'SVMXA360__ProfileId__c' => userProfileId,
                                                                                    'SVMXA360__HierarchyConfigId__c' => hierarchyConfigRecord.Id
                                                                                });
                                                                        
                                                                               
    }

    testmethod static void testGetAllHierarchyConfigurations() {
        
        List<Adm.HierarchyConfig> hierarchyConfigList = ADM_HierarchyConfigManager.getInstance().getAllHierarchyConfigurations();
        
        System.assert( hierarchyConfigList != null );
        System.assert( !hierarchyConfigList.isEmpty() );
    }

    testmethod static void testGetHierarchyConfigurationWithDetails() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
            
        final Adm.HierarchyConfig hierarchyConfig = ADM_HierarchyConfigManager.getInstance().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.id);
        
        System.assert( hierarchyConfig != null );
    }

    testmethod static void testGetHierarchyConfigurationDetails_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfigurationWithDetails(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfigurationAccessList_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfigurationAccessList(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfigurationDetailList_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfigurationDetailList(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfigAccessRecords_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfigAccessRecords(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfigDetailRecords_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfigDetailRecords(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfigRecord_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfigRecord(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfiguration_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().getHierarchyConfiguration(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testSaveHierarchyConfiguration() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
            
        Adm.HierarchyConfig hierarchyConfig = ADM_HierarchyConfigManager.getInstance().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.id);

        hierarchyConfig = ADM_HierarchyConfigManager.getInstance().saveHierarchyConfiguration(hierarchyConfig);
        
        System.assert( hierarchyConfig != null );
    }

    testmethod static void testSaveHierarchyConfiguration_InvalidParam() {

        try {
            ADM_HierarchyConfigManager.getInstance().saveHierarchyConfiguration(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }
    }

    testmethod static void testSaveHierarchyConfigurations_InvalidParam() {

        try {
            ADM_HierarchyConfigManager.getInstance().saveHierarchyConfigurations(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }
    }

    testmethod static void testSaveHierarchyConfigDetail_InvalidParam() {

        try {

            ADM_HierarchyConfigManager.getInstance().saveHierarchyConfigDetailAndAccessList(null,null);
            System.assert(false);
        }    
        catch( Exception e ) {
            System.assert(true);
        }
    }

    testmethod static void testSaveHierarchyConfigFieldList_InvalidParam() {

        try {

            ADM_HierarchyConfigManager.getInstance().saveHierarchyConfigFieldList(null,null,null);
            System.assert(false);
        }    
        catch( Exception e ) {
            System.assert(true);
        }
    }

    testmethod static void testGetAssignedProfileDetails() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRec = 
            (SVMXA360__CONF_HierarchyConfig__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfig__c',
                                                                                 new Map<String,Object>{
                                                                                     'Name' => 'Test Default Config',
                                                                                     'SVMXA360__DeveloperName__c' => 'Test_Default_Config',
                                                                                     'SVMXA360__IsDefault__c' => false
                                                                                });

        String userProfileId = UserInfo.getProfileId();
            final SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccess = 
                (SVMXA360__CONF_HierarchyConfigAccess__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfigAccess__c',
                                                                        new Map<String,Object>{
                                                                        'SVMXA360__ProfileId__c' => userProfileId,
                                                                        'SVMXA360__HierarchyConfigId__c' => hierarchyConfigRec.Id
                                                                        });
            
        final List<Adm.ProfileInfo> profileInfo = ADM_HierarchyConfigManager.getInstance().getAssignedProfileDetails(hierarchyConfigRecord.id);
        
        System.assert( profileInfo != null );
    }

    testmethod static void testDeleteHierarchyConfig_InvalidParam() {
        
        try {
            ADM_HierarchyConfigManager.getInstance().deleteHierarchyConfig(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testDeleteHierarchyConfig_InvalidDefaultParam() {
        
        try {
            SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
            ADM_HierarchyConfigManager.getInstance().deleteHierarchyConfig(hierarchyConfigRecord.Id);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
    }

    testmethod static void testDeleteHierarchyConfig() {
        
        SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
        hierarchyConfigRecord.SVMXA360__IsDefault__c = false;
        Database.update(hierarchyConfigRecord);

        ADM_HierarchyConfigManager.getInstance().deleteHierarchyConfig(hierarchyConfigRecord.Id);
            
        List<Adm.HierarchyConfig> hierarchyConfigList = ADM_HierarchyConfigManager.getInstance().getAllHierarchyConfigurations();
        
        System.assert( hierarchyConfigList.isEmpty() );

    }

}