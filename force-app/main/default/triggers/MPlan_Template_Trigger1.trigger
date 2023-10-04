trigger MPlan_Template_Trigger1 on SVMXA360__MaintenancePlanTemplate__c (before insert, before update) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for( SVMXA360__MaintenancePlanTemplate__c mPlanTemplate : Trigger.new ) {
            MPLN_TemplateTriggerHandler.getInstance().validateMPlanTemplateRecords(mPlanTemplate);
        }
    }
}