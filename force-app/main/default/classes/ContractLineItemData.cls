global with sharing class ContractLineItemData {
    
    @AuraEnabled
    @InvocableVariable(label='Service Plan Product Id' description='Service Plan Product on Service Contract Plan Record' required=false)
    global String servicePlanProductId;
    
    @AuraEnabled
    @InvocableVariable(label='Service Contract Record Id' description='The record Id of the Service Contract Record' required=true)
    global String serviceContractId;
    
    @AuraEnabled
    @InvocableVariable(label='List of Assets to be added to the Service Contract' description='Details of the Assets to be added to the Service Contract' required=true)
    global List<ContractLineAssetData> assetDataList;

    @AuraEnabled
    @InvocableVariable(label='Look on Applicable Contract Line Product Id' description='The Boolean variable to look on Applicable Contract Line Product Id' required=false)
    global Boolean isCLIPlanProductId;
}