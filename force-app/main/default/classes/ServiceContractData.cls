/**
 */
/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Wrapper structure to create Service Contract from given product scon plan.

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
global class ServiceContractData {
    
    @AuraEnabled
    @InvocableVariable(label='Account Record Id' description='The record Id of the Account Record' required=true)
    global String accountId;

    @AuraEnabled
    @InvocableVariable(label='Start Date' description='The Start Date of the Service Contract and related records' required=true)
    global Date startDate;

    @AuraEnabled
    @InvocableVariable(label='Service Contract End Date' description='End Date of the Service Contract' required=false)
    global Date endDate;

    @AuraEnabled
    @InvocableVariable(label='Pricebook Record Id' description='Pricebook to be used for Service Contract' required=false)
    global String pricebookId;

    @AuraEnabled
    @InvocableVariable(label='Service Plan Product Record Id' description='Record Id of the Service Product Plan in Service Contract Plan' required=true)
    global String servicePlanProductId;

    @AuraEnabled
    @InvocableVariable(label='Look on Applicable Contract Line Product Id' description='The Boolean variable to look on Applicable Contract Line Product Id' required=false)
    global Boolean isCLIPlanProductId;

    @AuraEnabled
    @InvocableVariable(label='Service Contract Name' description='The name of the Service Contract to be created' required=true)
    global String serviceContractName;

    @AuraEnabled
    @InvocableVariable(label='Service Contract Description' description='The description of the Service Contract to be created' required=false)
    global String description;

    @AuraEnabled
    @InvocableVariable(label='Sales Contract Record Id' description='Sales Contract Id to be populated in Service Contract' required=false)
    global String salesContractId;

    @AuraEnabled
    @InvocableVariable(label='Sales Contract Field Name' description='Field name of the Sales Contract on Service Contract' required=false)
    global String salesContractIdFieldName;

    @AuraEnabled 
    @InvocableVariable global String serviceContractId;

}