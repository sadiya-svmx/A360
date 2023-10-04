trigger ApplicationUsageDataEvent_Trigger1 on SVMXA360__COMM_ApplicationUsageDataEvent__e(after insert) {
	if (Trigger.isAfter && Trigger.isInsert) {
		COMM_ApplicationUsageDataManager.getInstance().upsertUsageData(Trigger.new);
	}
}