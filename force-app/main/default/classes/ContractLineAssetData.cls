global with sharing class ContractLineAssetData {
    
    @AuraEnabled
    @InvocableVariable(label='Asset Record Id' description='The record Id of the Asset Record' required=true)
    global String assetId;
    
    @AuraEnabled
    @InvocableVariable(label='Contract Line Item Start Date' description='Start date of the Contract line item to be created' required=true)
    global Date startDate;
    
    @AuraEnabled
    @InvocableVariable(label='Contract Line Item End Date' description='End date of the Contract line item to be created' required=false)
    global Date endDate;
    
    @AuraEnabled
    @InvocableVariable(label='PricebookEntry Record Id' description='Pricebook Entry Record Id for the Product associated to the Asset' required=false)
    global String pricebookEntryId;
    
    @AuraEnabled
    @InvocableVariable(label='Subscription Id' description='Id of the Subscription object which needs to be copied to one of the CLI field' required=false)
    global String subscriptionId;
    
    @AuraEnabled
    @InvocableVariable(label='Subscription Field Name' description='Field name on Contract Line Item object related to the Subscription object' required=false)
    global String subscriptionFieldName;
    
    @AuraEnabled
    @InvocableVariable(label='Subscription Asset Id' description='Id of the Subscribed Asset which needs to be copied to one of the Contract Line Item field' required=false)
    global String subscribedAssetId;
    
    @AuraEnabled
    @InvocableVariable(label='Subscription Asset Field Name' description='Field name on CLI object related to Subscription object' required=false)
    global String subscribedAssetFieldName;
    
    @AuraEnabled 
    @InvocableVariable global String contractLineItemId;
    
}