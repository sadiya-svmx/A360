/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This trigger processes entitlement event. 
 *
 * @author Madhavi Bhattad
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID           Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-1576  Madhavi Bhattad        30 Nov 2021       Created.
 *****************************************************************************************************/

trigger Entitlement_Trigger1 on Entitlement (before delete) {
    if (trigger.isBefore) {
        if(trigger.isDelete){
            EntitlementTriggerHandler.preventDeletionRelatedES(trigger.oldMap);
        }
    }
}