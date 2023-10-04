/***************************************************************************************************
 *                          Copyright (C) 2020 ServiceMax, Inc
 *                                  All rights reserved
 **************************************************************************************************/

/**
 * @brief This trigger prevents user to create duplicate Applicable Contract Line Product records.
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2021
 */
/***************************************************************************************************
 *    ID        Name                    Date            Comment
 ***************************************************************************************************
 *  A360AM-500 Shashank Panchal      27 April 2021    Created.
 **************************************************************************************************/
trigger ContractLineItemPlan_Trigger1 on SVMXA360__ContractLineItemPlan__c (before insert, before update) {
    if (trigger.isBefore) {
        if(trigger.isInsert){
            new SCON_ServiceContractPlanTriggerHandler().preventDuplicateCLIPlan(trigger.new, null);
            new SCON_ServiceContractPlanTriggerHandler().validateDurationCLIPlan(trigger.new, null);
        }
        if(trigger.isUpdate){
            new SCON_ServiceContractPlanTriggerHandler().preventDuplicateCLIPlan(trigger.new, trigger.oldMap);
            new SCON_ServiceContractPlanTriggerHandler().validateDurationCLIPlan(trigger.new, trigger.oldMap);
        }
    }
}