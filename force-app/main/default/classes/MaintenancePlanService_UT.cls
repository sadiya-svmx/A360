@IsTest
public class MaintenancePlanService_UT {
    @isTest
    static void testGetMaintenaceAssets(){
        Test.startTest();
        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
        SvmxGlobal.SvmxResponse response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == false);
        Test.stopTest();
    }

    @isTest
    static void addMaintenanceAssets(){
        Test.startTest();
        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        SvmxGlobal.SvmxResponse response = MaintenancePlanService.addMaintenanceAssets(maintenancePlanAssetData);
        System.assert(response.success == false);
        Test.stopTest();
    }
}