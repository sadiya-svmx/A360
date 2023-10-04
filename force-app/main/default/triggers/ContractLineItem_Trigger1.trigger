/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This trigger processes contract line item event. 
 *
 * @author Madhavi Bhattad
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID           Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-1566  Madhavi Bhattad        24 Nov 2021       Created.
 *****************************************************************************************************/

trigger ContractLineItem_Trigger1 on ContractLineItem (before delete) {
    if (trigger.isBefore) {
        if(trigger.isDelete){
            ContractLineItemTriggerHandler.preventDeletionRelatedCLI(trigger.oldMap);
        }
    }
}