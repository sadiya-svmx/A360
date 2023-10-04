/***************************************************************************************************
 *                          Copyright (C) 2021 ServiceMax, Inc
 *                                  All rights reserved
 **************************************************************************************************/

/**
 * @brief This trigger prevents user to validate Recurrence Pattern.
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/***************************************************************************************************
 *    ID        Name                    Date            Comment
 ***************************************************************************************************
 *  A360AM-600 Soumyaranjan Pati     4th June 2021       Created.
 **************************************************************************************************/
trigger MPlan_WorkRuleTemplate_Trigger1 on SVMXA360__MaintenanceWorkRuleTemplate__c (before insert, before update) {
    
    List<SVMXA360__MaintenanceWorkRuleTemplate__c> listMplanWRuleTemplates = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();
    for( SVMXA360__MaintenanceWorkRuleTemplate__c mPlanWRTemplate : Trigger.new ) {
        if ( Trigger.isInsert && String.isNotBlank( mPlanWRTemplate.SVMXA360__RecurrencePattern__c ) ) {
            listMplanWRuleTemplates.add(mPlanWRTemplate);
        } else if ( Trigger.isUpdate && trigger.oldMap.get(mPlanWRTemplate.Id).SVMXA360__RecurrencePattern__c != mPlanWRTemplate.SVMXA360__RecurrencePattern__c) {
            listMplanWRuleTemplates.add(mPlanWRTemplate);
        }
    }

    if ( !listMplanWRuleTemplates.isEmpty() ) {
        Map<String,String> mapRecPatterns =  MPLN_MaintenancePlanTemplateManager.getInstance().checkRecurrencePattern( listMplanWRuleTemplates );
        for (SVMXA360__MaintenanceWorkRuleTemplate__c mplanWRule : listMplanWRuleTemplates) {
            if( mapRecPatterns.containsKey(mplanWRule.SVMXA360__RecurrencePattern__c) && mapRecPatterns.get(mplanWRule.SVMXA360__RecurrencePattern__c).equalsIgnoreCase(System.Label.Error_Invalid_Recurrence_Pattern) ) {
                System.debug( LoggingLevel.ERROR, ' Invalid Recurrence Pattern. ' );
                mplanWRule.SVMXA360__RecurrencePattern__c.addError(mapRecPatterns.get(mplanWRule.SVMXA360__RecurrencePattern__c));
            }
        }
    }
    
}