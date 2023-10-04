/**
 */
/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Wrapper structure to cancel a Service Contract via services used by CPQ

 *
 * @author Madhavi Bhattad
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Madhavi Bhattad       16 Sept 2021     Created.
 *****************************************************************************************************/

global with sharing class CancelServiceContractData {

    // The Sales Contract Id in Service Contract
    @AuraEnabled
    @InvocableVariable(label='Sales Contract Id' description='Sales Contract Id in Service Contract' required=true)
    global String salesContractId;

    // The api name of filed having Sales Contract Id in Service Contract
    @AuraEnabled
    @InvocableVariable(label='Sales Contract Id Field APIName' description='Api name of filed having Sales Contract Id in Service Contract' required=true)
    global String salesContractIdFieldAPIName;

    // The End Date to be set on the Service Contract
    @AuraEnabled
    @InvocableVariable(label='Effective EndDate' description='End Date to be set on the Service Contract' required=true)
    global Date effectiveEndDate;
    
    // The reason of cancellation of Contract
    @AuraEnabled
    @InvocableVariable(label='Cancellation Reason' description='The reason of cancellation of Contract' required=false)
    global String cancellationReason;

    // Indicates which field to populate the cancellation reason
    @AuraEnabled
    @InvocableVariable(label='Cancellation Reason Field APIName' description='Indicates which field to populate the cancellation reason' required=false)
    global String cancellationReasonFieldAPIName;
}