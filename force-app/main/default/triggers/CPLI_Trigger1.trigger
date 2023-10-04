/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This trigger prevents user to create duplicate CPLI (contract price line item) record. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *  A360CE-350 Karthick Saravanan      28 Jan 2021      Created.
 *****************************************************************************************************/
trigger CPLI_Trigger1 on SVMXA360__ContractPriceLineItem__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            CPLI_TriggerHandler.preventDuplicateCPLI(trigger.new,null);
        }
        if(trigger.isUpdate){
            CPLI_TriggerHandler.preventDuplicateCPLI(trigger.new,trigger.oldMap);
        }        
    }
}