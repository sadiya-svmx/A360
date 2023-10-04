trigger ServicemaxTags_Trigger1 on SVMXA360__CONF_ServicemaxTags__c (before insert) {
if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ADM_ServicemaxTagTriggerHandler.getInstance().validateDuplicateRecords(trigger.new);
    }
}