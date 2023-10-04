global with sharing class MaintenancePlanAssetData {
    @InvocableVariable(label='Maintenance Plan Record Id' description='The record Id of the Maintenance Plan Record' required=true)
    global String maintenancePlanId;

    @InvocableVariable(label='Maintenance Asset Data List' description='The list of Maintenance Asset Data which needs to be created' required=true)
    global List<MaintenanceAssetData> maintenanceAssetDataList;
}