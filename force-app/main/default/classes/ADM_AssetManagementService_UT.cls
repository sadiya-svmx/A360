@IsTest
public class ADM_AssetManagementService_UT {
    
    @testSetup public static void setup() {
        ADM_HierarchyConfigManager_UT.setup();
    }

    testmethod static void testGetAllHierarchyConfigurations() {

        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().getAllHierarchyConfigurations();
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

    testmethod static void testDeleteHierarchyConfig() {

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRec = 
        (SVMXA360__CONF_HierarchyConfig__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfig__c',
                                                                             new Map<String,Object>{
                                                                                 'Name' => 'Test Default Config',
                                                                                 'SVMXA360__DeveloperName__c' => 'Test_Default_Config',
                                                                                 'SVMXA360__IsDefault__c' => false
                                                                            });
        
        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().deleteHierarchyConfig(hierarchyConfigRec.Id);
        
        System.assert( serviceResponse.success == true );
    }

    testmethod static void testDeleteHierarchyConfig_InvalidParam() {

        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().deleteHierarchyConfig(null);
        
        System.assert( serviceResponse.success == false );
    }

    testmethod static void testGetHierarchyConfigWithDetails() {

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];

        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.Id);
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

    testmethod static void testGetHierarchyConfigDetails_InvalidParam() {

        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().getHierarchyConfigurationWithDetails(null);
        
        System.assert( serviceResponse.success == false );
    }

    testmethod static void testSaveHierarchyConfiguration() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
            
        Adm.HierarchyConfig hierarchyConfig = new ADM_AssetManagementServiceImpl().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.id);

        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().saveHierarchyConfiguration(hierarchyConfig);
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

    testmethod static void testSaveHierarchyConfiguration_InvalidParam() {
        
        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().saveHierarchyConfiguration(null);
        
        System.assert( serviceResponse.success == false );
    }

    testmethod static void testGetAssignedProfileDetails() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigDataRec = 
            (SVMXA360__CONF_HierarchyConfig__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfig__c',
                                                                                 new Map<String,Object>{
                                                                                     'Name' => 'Test Default Service Config',
                                                                                     'SVMXA360__DeveloperName__c' => 'Test_Default_Serv_Config',
                                                                                     'SVMXA360__DefaultConfig__c' => false
                                                                                });

        String userProfileId = UserInfo.getProfileId();
            final SVMXA360__CONF_HierarchyConfigAccess__c hierarchyConfigAccess = 
                (SVMXA360__CONF_HierarchyConfigAccess__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_HierarchyConfigAccess__c',
                                                                        new Map<String,Object>{
                                                                        'SVMXA360__ProfileId__c' => userProfileId,
                                                                        'SVMXA360__HierarchyConfigId__c' => hierarchyConfigDataRec.Id
                                                                        });
            
        Common.ServiceResponse serviceResponse = new ADM_AssetManagementService().getAssignedProfileDetails(hierarchyConfigRecord.id);

        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

}