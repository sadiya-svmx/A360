/***************************************************************************************************
 *                          Copyright (C) 2020 ServiceMax, Inc
 *                                  All rights reserved
 **************************************************************************************************/

/**
 * @brief This trigger prevents user to create duplicate Offered Maintenance Plan Template records.
 *
 * @author Karthick
 * @version 1.0
 * @since 2021
 */
/***************************************************************************************************
 *    ID        Name                    Date            Comment
 ***************************************************************************************************
 *  A360AM-1137 Karthick               04 Aug 2021    Created.
 **************************************************************************************************/
trigger OfferedMaintenancePlanTemplate_Trigger1 on SVMXA360__OfferedMaintenancePlanTemplate__c (before insert) {
    if (trigger.isBefore) {
        if(trigger.isInsert){
            new SCON_ServiceContractPlanTriggerHandler().preventDuplicateOfferedMPT(trigger.new, null);
        }
    }
}