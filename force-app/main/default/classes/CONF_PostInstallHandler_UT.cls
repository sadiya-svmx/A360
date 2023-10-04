@IsTest
public class CONF_PostInstallHandler_UT {

    private static String jsonData = '{"version":"1.0","mappingList":[{"targetObjectAPIName":"ProductRequest","sourceObjectAPIName":"WorkOrder","objectMappingDetails":[{"value":null,"targetFieldAPIName":"WorkOrderId","sourceFieldAPIName":"Id","mappingType":"Field","id":null},{"value":null,"targetFieldAPIName":"DestinationLocationId","sourceFieldAPIName":"LocationId","mappingType":"Field","id":null},{"value":null,"targetFieldAPIName":"CaseId","sourceFieldAPIName":"CaseId","mappingType":"Field","id":null},{"value":null,"targetFieldAPIName":"AccountId","sourceFieldAPIName":"AccountId","mappingType":"Field","id":null},{"value":"Draft","targetFieldAPIName":"Status","sourceFieldAPIName":null,"mappingType":"Value","id":null}],"name":"Work Order To Product Request - A360","mappingType":"Field Mapping","lastModifiedDate":"2020-10-22T12:44:19.000Z","lastModifiedBy":"CS Dev","id":null,"developerName":"WORD_PRRQ_Mapping","description":"Mapping to create new Product Request from Work Order","version":"1.0"},{"targetObjectAPIName":"Asset","sourceObjectAPIName":null,"objectMappingDetails":[{"value":"Installed","targetFieldAPIName":"Status","sourceFieldAPIName":null,"mappingType":"Value","id":null}],"name":"Copy of Asset Installation - A360","mappingType":"Value Mapping","lastModifiedDate":"2020-10-22T12:44:19.000Z","lastModifiedBy":"CS Dev","id":null,"developerName":"Copy_of_Asset_Installation_A360","description":"Mapping to update Asset to installed","version":"1.0"}]}';
    
    testmethod static void testFreshInstall() {
        
        Test.startTest();
        
        SvmxTooling.ConfigurationData configurationData = (SvmxTooling.ConfigurationData) JSON.deserialize(jsonData, SvmxTooling.ConfigurationData.class);
        
        String testJsonData = JSON.serialize(configurationData);
		TOOL_AbstractDataHandler.testJsonData = testJsonData;
        
        SvmxSystem.isRunningPostInstall = true;
        TOOL_ImportDataHandler importDataHandler = new TOOL_ImportDataHandler( false, null );
        importDataHandler.processConfigurationData();
        
        List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappings();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 2, objectMappingList.size() );
        
        Test.stopTest();
    }

    testmethod static void testUpgradeInstall() {
        
        Test.startTest();
        
        SvmxTooling.ConfigurationData configurationData = (SvmxTooling.ConfigurationData) JSON.deserialize(jsonData, SvmxTooling.ConfigurationData.class);
        
        // TODO change versions for header and records here if required
        configurationData.setVersion('2.0');
        configurationData.mappingList.get(0).setVersion('2.0');
        // 
        String testJsonData = JSON.serialize(configurationData);
		TOOL_AbstractDataHandler.testJsonData = testJsonData;
        
        SvmxSystem.isRunningPostInstall = true;
        TOOL_ImportDataHandler importDataHandler = new TOOL_ImportDataHandler( true, '1.0' );
        importDataHandler.processConfigurationData();
        
        List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappings();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 2, objectMappingList.size() );
        
        Test.stopTest();
    }
    
    testmethod static void testlongUpgrade() {
        
        Test.startTest();
        
        jsonData = '{"version":"2.0","mappingList":[{"targetObjectAPIName":"ProductRequest","sourceObjectAPIName":"WorkOrder","objectMappingDetails":[{"value":null,"targetFieldAPIName":"WorkOrderId","sourceFieldAPIName":"Id","mappingType":"Field","id":null},{"value":null,"targetFieldAPIName":"DestinationLocationId","sourceFieldAPIName":"LocationId","mappingType":"Field","id":null},{"value":null,"targetFieldAPIName":"CaseId","sourceFieldAPIName":"CaseId","mappingType":"Field","id":null},{"value":null,"targetFieldAPIName":"AccountId","sourceFieldAPIName":"AccountId","mappingType":"Field","id":null},{"value":"Draft","targetFieldAPIName":"Status","sourceFieldAPIName":null,"mappingType":"Value","id":null}],"name":"Work Order To Product Request - A360","mappingType":"Field Mapping","lastModifiedDate":"2020-10-22T12:44:19.000Z","lastModifiedBy":"CS Dev","id":null,"developerName":"WORD_PRRQ_Mapping","description":"Mapping to create new Product Request from Work Order","version":"1.0"},{"targetObjectAPIName":"Asset","sourceObjectAPIName":null,"objectMappingDetails":[{"value":"Installed","targetFieldAPIName":"Status","sourceFieldAPIName":null,"mappingType":"Value","id":null}],"name":"Copy of Asset Installation - A360","mappingType":"Value Mapping","lastModifiedDate":"2020-10-22T12:44:19.000Z","lastModifiedBy":"CS Dev","id":null,"developerName":"Copy_of_Asset_Installation_A360","description":"Mapping to update Asset to installed","version":"2.0"},{"targetObjectAPIName":"AssetWarranty","sourceObjectAPIName":"WarrantyTerm","objectMappingDetails":[{"value":null,"targetFieldAPIName":"LaborCovered","sourceFieldAPIName":"LaborCovered","mappingType":"Field","id":null}],"name":"Copy of Asset Installation - A360","mappingType":"Value Mapping","lastModifiedDate":"2020-10-22T12:44:19.000Z","lastModifiedBy":"CS Dev","id":null,"developerName":"DEFAULT_Warranty_Term_to_Asset_Warranty","description":"Mapping between Warranty Term and Asset Warranty","version":"3.0"},{"targetObjectAPIName":"WorkOrderLineItem","sourceObjectAPIName":"WorkOrder","objectMappingDetails":[{"value":null,"targetFieldAPIName":"WorkOrderId","sourceFieldAPIName":"Id","mappingType":"Field","id":null}],"name":"Work Order to Work Order Line Items - A360","mappingType":"Field Mapping","lastModifiedDate":"2020-10-23T04:10:17.000Z","lastModifiedBy":"CS Dev","id":null,"developerName":"WORD_WOLI_Mapping","description":"Mapping to create new labor Work Order Line Item from Work Order","version":"4.0"}]}';
        SvmxTooling.ConfigurationData configurationData = (SvmxTooling.ConfigurationData) JSON.deserialize(jsonData, SvmxTooling.ConfigurationData.class);
        
        String testJsonData = JSON.serialize(configurationData);
		TOOL_AbstractDataHandler.testJsonData = testJsonData;
        
        SvmxSystem.isRunningPostInstall = true;
        TOOL_ImportDataHandler importDataHandler = new TOOL_ImportDataHandler( true, '1.0' );
        importDataHandler.processConfigurationData();
        
        List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappings();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 4, objectMappingList.size() );
        
        Test.stopTest();
    }
}