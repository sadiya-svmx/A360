@IsTest
public class ADM_AssetManagementServiceImpl_UT {
    
    @testSetup public static void setup() {
        ADM_HierarchyConfigManager_UT.setup();
    }

    testmethod static void testGetAllHierarchyConfigurations() {
        
        List<Adm.HierarchyConfig> hierarchyConfigList = new ADM_AssetManagementServiceImpl().getAllHierarchyConfigurations();
        
        System.assert( hierarchyConfigList != null );
        System.assert( !hierarchyConfigList.isEmpty() );
    }

    testmethod static void testDeleteHierarchyConfig() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRec = 
        (SVMXA360__CONF_HierarchyConfig__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfig__c',
                                                                             new Map<String,Object>{
                                                                                 'Name' => 'Test Default Config',
                                                                                 'SVMXA360__DeveloperName__c' => 'Test_Default_Config',
                                                                                 'SVMXA360__IsDefault__c' => false
                                                                            });
            
        new ADM_AssetManagementServiceImpl().deleteHierarchyConfig(hierarchyConfigRec.Id);

        try {
            Adm.HierarchyConfig hierarchyConfig = new ADM_AssetManagementServiceImpl().getHierarchyConfigurationWithDetails(hierarchyConfigRec.Id);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS ) != -1 );
        }
    }

    testmethod static void testDeleteHierarchyConfig_InvalidParam() {
        
        try {
            new ADM_AssetManagementServiceImpl().deleteHierarchyConfig(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }

    testmethod static void testGetHierarchyConfigurationWithDetails() {

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
        
        Adm.HierarchyConfig hierarchyConfig = new ADM_AssetManagementServiceImpl().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.Id);
        
        System.assert( hierarchyConfig != null );
    }

    testmethod static void testSaveHierarchyConfiguration() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
            
        Adm.HierarchyConfig hierarchyConfig = new ADM_AssetManagementServiceImpl().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.id);

        hierarchyConfig = new ADM_AssetManagementServiceImpl().saveHierarchyConfiguration(hierarchyConfig);
        
        System.assert( hierarchyConfig != null );
    }

    testmethod static void testGetAssignedProfileDetails() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigDataRec = 
            (SVMXA360__CONF_HierarchyConfig__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfig__c',
                                                                                 new Map<String,Object>{
                                                                                     'Name' => 'Test Default Impl Config',
                                                                                     'SVMXA360__DeveloperName__c' => 'Test_Default_Impl_Config',
                                                                                     'SVMXA360__DefaultConfig__c' => false
                                                                                });

        String userProfileId = UserInfo.getProfileId();
            final SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccess = 
                (SVMXA360__CONF_HierarchyConfigAccess__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfigAccess__c',
                                                                        new Map<String,Object>{
                                                                        'SVMXA360__ProfileId__c' => userProfileId,
                                                                        'SVMXA360__HierarchyConfigId__c' => hierarchyConfigDataRec.Id
                                                                        });
            
        List<Adm.ProfileInfo> profileList = new ADM_AssetManagementServiceImpl().getAssignedProfileDetails(hierarchyConfigRecord.id);

        System.assert( !profileList.isEmpty() );
    }

}