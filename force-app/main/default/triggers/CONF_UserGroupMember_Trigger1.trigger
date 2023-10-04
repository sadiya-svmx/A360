/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This trigger prevents user to create/update user group member record without user detail. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-2253 Sandeep Dhariwal      17 Nov 2022      Created.
 *****************************************************************************************************/
trigger CONF_UserGroupMember_Trigger1 on SVMXA360__CONF_UserGroupMember__c (before insert, before update) {
    if(trigger.isBefore){
        UserGroupMemberTriggerHandler.checkUserRecord(trigger.new);       
    }
}