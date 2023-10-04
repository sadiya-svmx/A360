/**
 */
/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Wrapper structure to create entitled service to Service Contract or Contract Line Item.

 *
 * @author Karthick
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *             Karthick               16 Sept 2021      Created.
 *****************************************************************************************************/
global class EntitledServiceData {
    
    @AuraEnabled
    @InvocableVariable(label='Service Contract Record Id' description='SFDC record Id of the Service Contract record' required=true)
    global String serviceContractId;

    @AuraEnabled
    @InvocableVariable(label='Contract Line Item Record Id' description='SFDC record Id of the Contract Line Item record' required=false)
    global String contractLineItemId;

    @AuraEnabled
    @InvocableVariable(label='Entitled Service Start Date' description='Start Date of the Entitled Service' required=false)
    global Date startDate;

    @AuraEnabled
    @InvocableVariable(label='Entitled Service End Date' description='End Date of the Entitled Service' required=false)
    global Date endDate;

    @AuraEnabled
    @InvocableVariable(label='Entitled Service Name' description='Name to be used for Entitled Service' required=true)
    global String entitledServiceName;

    @AuraEnabled
    @InvocableVariable(label='Entitled Service Product Record Id' description='Record Id of the Service Product used for Entitled Service' required=true)
    global String serviceProductId;

    @AuraEnabled
    @InvocableVariable(label='Service Unit' description='Service Unit to be used for Entitled Service' required=true)
    global String serviceUnit;

    @AuraEnabled
    @InvocableVariable(label='Total Service Unit' description='Total Service Unit to be used for Entitled Service' required=true)
    global String serviceQty;

    @AuraEnabled
    @InvocableVariable(label='Service Unit Threshold' description='Service Unit Threshold to be used for Entitled Service' required=false)
    global String thresholdAlert;

    @AuraEnabled
    @InvocableVariable(label='Work Order Entitlement Process Id' description='Work Order Entitlement Process to be used for Entitled Service' required=false)
    global String workOrderEntitlementProcess;

    @AuraEnabled
    @InvocableVariable(label='Case Entitlement Process Id' description='Case Entitlement Process to be used for Entitled Service' required=false)
    global String caseEntitlementProcess;

    @AuraEnabled
    @InvocableVariable(label='Subscription Record Id' description='Subscription Record Id to be populated in Entitled Service' required=false)
    global String subscriptionId;

    @AuraEnabled
    @InvocableVariable(label='Subscription Field Name' description='Field name of the Subscription on Entitlement' required=false)
    global String subscriptionFieldName;

    @AuraEnabled
    @InvocableVariable(label='Subscribed Asset Record Id' description='Subscribed Asset Id to be populated in Entitled Service' required=false)
    global String subscribedAssetId;

    @AuraEnabled
    @InvocableVariable(label='Subscribed Asset Field Name' description='Field name of the Subscribed Asset on Entitlement' required=false)
    global String subscribedAssetFieldName;

    @AuraEnabled 
    @InvocableVariable global String entitledServiceId;

}