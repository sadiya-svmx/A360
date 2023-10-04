/*                               All rights reserved
*****************************************************************************/

/**
* @brief This trigger processes Technical Attribute TemplateAssociation events. 
*
* @author Karthick Saravanan
* @version 1.0
* @since 2022
*/
/*****************************************************************************************************
*    ID        Name                    Date            Comment
*****************************************************************************************************
* A360AM-1926 Karthick Saravanan      18 Aug 2022      Created.
*****************************************************************************************************/
trigger TA_TemplateAssociation_Trigger1 on SVMXA360__SM_TA_TemplateAssociation__c (before insert, before update) {

    if(trigger.isBefore){
        if(trigger.isInsert){
            new TechnicalAttributeTriggerHandler().preventToUpdateMatchValue(trigger.new, null);
        }
        if(trigger.isUpdate){
            new TechnicalAttributeTriggerHandler().preventToUpdateMatchValue(trigger.new, trigger.oldMap);
        }        
    }
}