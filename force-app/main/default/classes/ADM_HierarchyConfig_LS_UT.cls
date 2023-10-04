@IsTest
public class ADM_HierarchyConfig_LS_UT {
    
    @testSetup public static void setup() {
        ADM_HierarchyConfigManager_UT.setup();
    }

    testmethod static void testGetAllHierarchyConfigurations() {

        Common.ServiceResponse serviceResponse = ADM_HierarchyConfig_LS.getAllHierarchyConfigurations();
        
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
        
        Common.ServiceResponse serviceResponse = ADM_HierarchyConfig_LS.deleteHierarchyConfig(hierarchyConfigRec.Id);
        
        System.assert( serviceResponse.success == true );
    }

    testmethod static void testGetHierarchyConfigWithDetails() {

        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];

        Common.ServiceResponse serviceResponse = ADM_HierarchyConfig_LS.getHierarchyConfigurationWithDetails(hierarchyConfigRecord.Id);
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

    testmethod static void testSaveHierarchyConfiguration() {
        
        final SVMXA360__CONF_HierarchyConfig__c hierarchyConfigRecord = [SELECT Id FROM SVMXA360__CONF_HierarchyConfig__c];
            
        Adm.HierarchyConfig hierarchyConfig = new ADM_AssetManagementServiceImpl().getHierarchyConfigurationWithDetails(hierarchyConfigRecord.id);

        Common.ServiceResponse serviceResponse = ADM_HierarchyConfig_LS.saveHierarchyConfiguration(JSON.serialize(hierarchyConfig));
        
        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

    testmethod static void testSaveHierarchyConfiguration_InvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_HierarchyConfig_LS.saveHierarchyConfiguration( '{{}' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
        
        Test.stopTest();
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
            
        Common.ServiceResponse serviceResponse = ADM_HierarchyConfig_LS.getAssignedProfileDetails(hierarchyConfigRecord.id);

        System.assert( serviceResponse.success == true );
        System.assert( serviceResponse.data != null );
    }

}