/*                               All rights reserved
*****************************************************************************/

/**
* @brief This Service Contract Plan trigger validates the duration against related child plans.
*
* @author Karthick Saravanan
* @version 1.0
* @since 2021
*/
/*****************************************************************************************************
*    ID        Name                    Date            Comment
*****************************************************************************************************
*  A360AM-927 Karthick Saravanan      21 June 2021      Created.
*****************************************************************************************************/
trigger ServiceContractPlan_Trigger1 on SVMXA360__ServiceContractPlan__c (before insert, before update) {

    if (trigger.isBefore ) {

        if (trigger.isInsert) {
                new SCON_ServiceContractPlanTriggerHandler().preventDuplicateProductPlan(trigger.new, null);
        }

        else if(trigger.isUpdate) {
            new SCON_ServiceContractPlanTriggerHandler().preventDuplicateProductPlan(trigger.new, trigger.oldMap);
            new SCON_ServiceContractPlanTriggerHandler().validateDurationOfContractPlan(trigger.new, trigger.oldMap);
        }
    }
}