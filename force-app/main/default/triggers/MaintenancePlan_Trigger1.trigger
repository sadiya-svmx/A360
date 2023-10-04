trigger MaintenancePlan_Trigger1 on SVMXA360__SM_MaintenancePlan__c (before insert, before update, before delete) {
	
    if (Trigger.isBefore) {
        if(Trigger.isDelete) {
            List<String> mplanIds = new List<String>();
            for( SVMXA360__SM_MaintenancePlan__c mplan : Trigger.old ) {
                mplanIds.add(mplan.Id);
            }
            MPLN_ConditionBasedMPlanManager.getInstance().deleteRecords(mplanIds);
        }
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            for ( SVMXA360__SM_MaintenancePlan__c mplan : Trigger.new ){
                if (mplan.SVMXA360__Status__c == 'Canceled' && 
                    (Trigger.isInsert || (Trigger.isUpdate && 
                    Trigger.oldMap.get(mplan.Id).SVMXA360__Status__c != mplan.SVMXA360__Status__c))) {
                    mplan.SVMXA360__CanceledOn__c = System.today();
                    mplan.SVMXA360__CanceledBy__c = Userinfo.getUserId();
                }
            }
        }
    }
    
}