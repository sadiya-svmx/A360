global with sharing class AssetServiceContractPlanData {
    
    @AuraEnabled
    @InvocableVariable(label='Asset Record Id' description='Record Id of the Asset Record' required=false)
    global Id assetId;
    
    @AuraEnabled
    @InvocableVariable(label='Service Contract Plan Record Id' description='Record Id of Service Contract Plan Record' required=false)
    global Id serviceContractPlanId;
}