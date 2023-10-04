/***************************************************************************************************
 *                          Copyright (C) 2020 ServiceMax, Inc
 *                                  All rights reserved
 **************************************************************************************************/

/**
 * @brief This trigger prevents user to create duplicate Entitled Service Plan records.
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2021
 */
/***************************************************************************************************
 *    ID        Name                    Date            Comment
 ***************************************************************************************************
 *  A360AM-506 Shashank Panchal      27 April 2021    Created.
 **************************************************************************************************/
trigger EntitledServicePlan_Trigger1 on SVMXA360__EntitledServicePlan__c (before insert, before update) {
    if (trigger.isBefore) {
        if(trigger.isInsert){
            new SCON_ServiceContractPlanTriggerHandler().preventDuplicateESPlan(trigger.new, null);
            new SCON_ServiceContractPlanTriggerHandler().validateDurationESPlan(trigger.new, null);
        }
        if(trigger.isUpdate){
            new SCON_ServiceContractPlanTriggerHandler().preventDuplicateESPlan(trigger.new, trigger.oldMap);
            new SCON_ServiceContractPlanTriggerHandler().validateDurationESPlan(trigger.new, trigger.oldMap);
        }
        
    }
}