/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Scheduler class for running the maintenance  .
 * 
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                11 July 2023     Created.
 *****************************************************************************************************/
global with sharing class MPLN_ProcessScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
		List<SVMXA360__SM_MaintenancePlanProcess__c> processList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__SM_Standard__c, SVMXA360__RecurrencePattern__c, SVMXA360__SM_RunAt__c,  
                        SVMXA360__SM_TimeZone__c, SVMXA360__SM_LastRunDate__c FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE SVMXA360__SM_isActive__c = True]);
        
        List<CronTrigger> processScheduler = SvmxDatabase.query([SELECT Id, CronExpression, NextFireTime From CronTrigger WHERE Id =: sc.getTriggerId()]);
        DateTime currentFireTime = processScheduler.isEmpty() ? System.now() : processScheduler[0].NextFireTime.addHours(-1); //GMT
        Map<String, SVMXA360__SM_MaintenancePlanProcess__c> scheduleJobProcessMap = new Map<String, SVMXA360__SM_MaintenancePlanProcess__c>();
        List<String> qualifiedProcessIds = new List<String>();
        List<SVMXA360__SM_MaintenancePlanProcess__c> processToUpdateList = new List<SVMXA360__SM_MaintenancePlanProcess__c>();

        try {
            for (SVMXA360__SM_MaintenancePlanProcess__c processRec : processList) {
                if ( processRec.SVMXA360__RecurrencePattern__c != null ) {
                    Date lastRunDateTime = processRec.SVMXA360__SM_LastRunDate__c != null ? 
                                           processRec.SVMXA360__SM_LastRunDate__c.dateGMT() :
                                           null;
                    DateTime nextScheduleDateTime = COMM_RecurrenceRuleHelper.getNextDateFromRRule(processRec.SVMXA360__RecurrencePattern__c, lastRunDateTime);
                    if (nextScheduleDateTime != null) {    
                        Integer runAt = processRec.SVMXA360__SM_RunAt__c != null ? Integer.valueOf(processRec.SVMXA360__SM_RunAt__c): 0 ;
                        Time offSetTime = Time.newInstance(0, 0, 0, 0).addHours(runAt);
                        nextScheduleDateTime = Datetime.newInstance(nextScheduleDateTime.date(), offSetTime);
                		DateTime nextScheduleDateTimeLocal = DateTime.valueOfGMT(nextScheduleDateTime.format('yyyy-MM-dd HH:mm:ss', processRec.SVMXA360__SM_TimeZone__c));
                        DateTime currentFireTimeLocal = DateTime.valueOfGMT(currentFireTime.format('yyyy-MM-dd HH:mm:ss',  processRec.SVMXA360__SM_TimeZone__c));                       
                        System.debug(LoggingLevel.INFO, ' currentFireTime '  + currentFireTime);
                        System.debug(LoggingLevel.INFO, ' nextScheduleDateTimeLocal '  + nextScheduleDateTimeLocal);
                        if ( Test.isRunningTest() || nextScheduleDateTimeLocal <= currentFireTimeLocal) {
                            qualifiedProcessIds.add(processRec.Id);
                        	System.debug(LoggingLevel.INFO, ' nextScheduleDateTimeLocal '  + nextScheduleDateTimeLocal);
                            processRec.SVMXA360__SM_LastRunDate__c = DateTime.valueOf(nextScheduleDateTimeLocal.format('yyyy-MM-dd HH:mm:ss', 'GMT'));
                            processToUpdateList.add(processRec);
                        }

                    }
                }
            }

            MPLN_ProcessBatch mplnProcessBatch = new MPLN_ProcessBatch(qualifiedProcessIds); 
            Database.executeBatch(mplnProcessBatch, 50);
            
            if (!processToUpdateList.isEmpty()) {
				SvmxDatabase.insertRecord( processToUpdateList );            
            }
       	}
        catch(Exception e) {
            System.debug( LoggingLevel.ERROR, e.getMessage() );
        }
    }
}