/*                               All rights reserved
*****************************************************************************/

/**
* @brief This trigger processes Technical Attribute events. 
*
* @author Karthick Saravanan
* @version 1.0
* @since 2022
*/
/*****************************************************************************************************
*    ID        Name                    Date            Comment
*****************************************************************************************************
* A360AM-1926 Karthick Saravanan      16 June 2022      Created.
*****************************************************************************************************/
trigger TA_TechnicalAttribute_Trigger1 on SVMXA360__SM_TA_TechnicalAttribute__c (before update, before delete) {

    if (trigger.isBefore ) {

        if(trigger.isUpdate) {
            new TechnicalAttributeTriggerHandler().preventToUpdateAttributeDefinition(trigger.new, trigger.oldMap);
        }
        else if(trigger.isDelete){
            if (!TA_TechnicalAttributeManager.skipTriggerExecution) {
                new TechnicalAttributeTriggerHandler().preventDeletionRelatedTA(trigger.oldMap);
            }
        }
    }
}