global with sharing class MaintenanceAssetData {
    @InvocableVariable(label='Asset Record Id' description='The record Id of the Asset Record' required=true)
    @AuraEnabled global String assetId;

    @InvocableVariable(label='Date of the first work order in the next batch' description='The Date of the first work order in the next batch for Maintenance Asset')
    @AuraEnabled global Date dateOfFirstWorkOrderInNextBatch;

    @InvocableVariable(label='Subscribed Asset Id' description='The record Id of the Subscribed Asset Record')
    @AuraEnabled global String subscribedAssetId;

    @InvocableVariable(label='Subscribed Asset Field API Name' description='The Subscribed Asset Field API Name on Maintenance Asset object')
    @AuraEnabled global String subscribedAssetFieldName;

    @InvocableVariable(label='Maintenance Asset Id' description='The Id of the Maintenance Asset record which got created')
    @AuraEnabled global String maintenanceAssetId;
}