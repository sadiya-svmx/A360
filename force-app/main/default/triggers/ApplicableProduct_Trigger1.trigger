trigger ApplicableProduct_Trigger1 on SVMXA360__ApplicableProduct__c (before insert, before update) {

     if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for( SVMXA360__ApplicableProduct__c applicableProduct : Trigger.new ) {
            applicableProduct.SVMXA360__UniqueKey__c = MPLN_TemplateTriggerHandler.getInstance().generateAPUniqueKey(applicableProduct);
        }
    }

}