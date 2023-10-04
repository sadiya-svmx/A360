/*                               All rights reserved
*****************************************************************************/

/**
* @brief This Service Contract trigger validates the Start and End date against related Contract Line Items.
*
* @author Hemant Keni
* @version 1.0
* @since 2021
*/
/*****************************************************************************************************
*    ID        Name                    Date            Comment
*****************************************************************************************************
*  A360CE-337 Hemant Keni      3 Feb 2021      Created.
*****************************************************************************************************/
trigger ServiceContract_Trigger1 on ServiceContract (before update) {
    if(trigger.isBefore){
        if(trigger.isUpdate){
            EVER_EntitledServiceTriggerHandler.validateStartAndEndDate(trigger.newMap,trigger.oldMap);
        }
    }
}