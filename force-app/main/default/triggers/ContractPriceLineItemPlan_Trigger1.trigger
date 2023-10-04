/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This trigger prevents user to create duplicate ContractPriceLineItemPlans.
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-501 Karthick Saravanan      21 April 2021    Created.
 *****************************************************************************************************/
trigger ContractPriceLineItemPlan_Trigger1 on SVMXA360__ContractPriceLineItemPlan__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            SCON_ServiceContractPlanTriggerHandler.preventDuplicateCPLIPlan(trigger.new,null);
        }
        if(trigger.isUpdate){
            SCON_ServiceContractPlanTriggerHandler.preventDuplicateCPLIPlan(trigger.new,trigger.oldMap);
        }        
    }
}