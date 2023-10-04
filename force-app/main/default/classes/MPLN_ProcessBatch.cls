/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A batch apex class for processing maintainance plans
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                07 Jan 2023     Created.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
/* sfge-disable ApexFlsViolationRule */
global with sharing class MPLN_ProcessBatch implements Database.Batchable<sObject>, Database.Stateful {

	List<MPLN_ProcessHandler.ProcessLogger> processLoggerList;
	List<SVMXA360__SM_MaintenancePlanProcess__c> timeQualifiedProcessList;
	SVMXA360__SM_MaintenancePlanProcess__c defaultMPProcess;
	Map<String, SVMXA360__SM_MaintenancePlanProcess__c> mPlanProcessMap;
	Set<String> timeQualifiedProcessIds;
	
	global MPLN_ProcessBatch(List<String> processIds) {
		timeQualifiedProcessIds = new Set<String>(processIds);
		processLoggerList = new List<MPLN_ProcessHandler.ProcessLogger>();
		mPlanProcessMap = new Map<String, SVMXA360__SM_MaintenancePlanProcess__c>();
		timeQualifiedProcessList = new List<SVMXA360__SM_MaintenancePlanProcess__c>();
		for (SVMXA360__SM_MaintenancePlanProcess__c mplanProcessRec : (List<SVMXA360__SM_MaintenancePlanProcess__c>)SvmxDatabase.query([SELECT Id, Name, SVMXA360__SM_Standard__c, SVMXA360__SM_MappingAssettoWOId__c, SVMXA360__SM_MappingAssettoWOId__r.Name, SVMXA360__SM_MappingMPlantoWOId__c, SVMXA360__SM_MappingMPlantoWOId__r.Name, SVMXA360__SM_AssignTo__c, 
													SVMXA360__SM_SendFailureEmailTo__c, SVMXA360__SM_SendSuccessEmailTo__c, SVMXA360__SM_AssignToValue__c, SVMXA360__SM_AssignToObjectAPIName__c, SVMXA360__SM_DaysInAdvance__c FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE Id IN : timeQualifiedProcessIds])) {
			if (mplanProcessRec.SVMXA360__SM_Standard__c == true) {
				defaultMPProcess = mplanProcessRec;
			}

			timeQualifiedProcessList.add(mplanProcessRec);
		}							
	}

	global Iterable<sObject>  start(Database.BatchableContext bC){
		String query = 'SELECT Id, Name, SVMXA360__Account__c, SVMXA360__CanceledBy__c, SVMXA360__CanceledOn__c, SVMXA360__CancellationReason__c, SVMXA360__MaintenancePlanProcessId__c, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__c, ' +
					   ' SVMXA360__Description__c, SVMXA360__EndDate__c, SVMXA360__Location__c, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__c, CreatedById, LastModifiedById, OwnerId, SVMXA360__MaintenancePlanTemplate__c, SVMXA360__ServiceContract__c, ' +
					   ' SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__r.Name, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__r.Name, ' +
					   ' SVMXA360__MaintenancePlanProcessId__r.Name, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignTo__c, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToValue__c, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToObjectAPIName__c , SVMXA360__StartDate__c, ' +
					   ' SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_DaysInAdvance__c, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_SendFailureEmailTo__c, SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_SendSuccessEmailTo__c , '+
					   ' SVMXA360__Status__c, SVMXA360__WorkType__c FROM SVMXA360__SM_MaintenancePlan__c WHERE (SVMXA360__MaintenancePlanProcessId__c = null OR SVMXA360__MaintenancePlanProcessId__c IN:timeQualifiedProcessIds) AND SVMXA360__Status__c = \'Active\'' + 
            		   ' AND SVMXA360__StartDate__c <= TODAY AND SVMXA360__EndDate__c >= TODAY ORDER BY SVMXA360__MaintenancePlanProcessId__c';
		
      	return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bC, List<sObject> scope){
		Boolean isSuccess = true;
		String errorStr = '';
		try{ 
			List<SVMXA360__SM_MaintenancePlan__c> mplanList = new List<SVMXA360__SM_MaintenancePlan__c>();

			for (SVMXA360__SM_MaintenancePlan__c mplanRec : (List<SVMXA360__SM_MaintenancePlan__c>)scope) {
                if (mplanRec.SVMXA360__MaintenancePlanProcessId__c == null) {
                    if(defaultMPProcess != null && timeQualifiedProcessIds.contains(defaultMPProcess.Id)){
                        mplanRec.SVMXA360__MaintenancePlanProcessId__r = defaultMPProcess;
                        mPlanProcessMap.put(mplanRec.SVMXA360__MaintenancePlanProcessId__c, mplanRec.SVMXA360__MaintenancePlanProcessId__r);
                    	mplanList.add(mplanRec);
                    }
                } else {
                    mPlanProcessMap.put(mplanRec.SVMXA360__MaintenancePlanProcessId__c, mplanRec.SVMXA360__MaintenancePlanProcessId__r);
                    mplanList.add(mplanRec);                    
                }
			}
			processLoggerList.addAll(new MPLN_ProcessHandler().processMaintenancePlans(mplanList));	
		}	        
		catch(Exception ex){
            isSuccess = false;
			errorStr = 'Exception: Type - ' + ex.getTypeName() + '; Line No. - ' + ex.getLineNumber() + '; Cause - ' + ex.getCause() + '; Message - ' + ex.getMessage()+ '; Stack Trace - ' + ex.getStackTraceString();
            system.debug(LoggingLevel.ERROR, errorStr);
        }
		finally{
			if(!isSuccess){
				for (SVMXA360__SM_MaintenancePlan__c mplanRec : (List<SVMXA360__SM_MaintenancePlan__c>)scope) {
					MPLN_ProcessHandler.ProcessLogger logObj = new MPLN_ProcessHandler.ProcessLogger();
					logObj.processId = mplanRec.SVMXA360__MaintenancePlanProcessId__c;
					logObj.processName = mplanRec.SVMXA360__MaintenancePlanProcessId__r.Name;
					logObj.planId = mplanRec.Id;
					logObj.planName = mplanRec.Name;
					logObj.status = 'Exception';
					logObj.strLogger = errorStr;
					processLoggerList.add(logObj);
				}
			}
		}			        
    }

	global void finish(Database.BatchableContext bC){
		Boolean isException = false;
		Map<String, List<MPLN_ProcessHandler.ProcessLogger>> processMPlanMap = new Map<String, List<MPLN_ProcessHandler.ProcessLogger>>();
		List<SVMXA360__ApplicationLog__c> applicationLogList = new List<SVMXA360__ApplicationLog__c>();
		List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
		Map<String, String> processLogMap = new Map<String, String>();
		try{
			if( !processLoggerList.isEmpty() ) {
				for(MPLN_ProcessHandler.ProcessLogger processLoggerRec : processLoggerList){
					List<MPLN_ProcessHandler.ProcessLogger> tempProcessLoggerList = new List<MPLN_ProcessHandler.ProcessLogger>();
					if (processMPlanMap.containsKey(processLoggerRec.processId)) {
						tempProcessLoggerList = processMPlanMap.get(processLoggerRec.processId);
					} 
					tempProcessLoggerList.add(processLoggerRec);
					processMPlanMap.put(processLoggerRec.processId, tempProcessLoggerList);

				}
			}

			for(String processKey : processMPlanMap.keySet()){
				Integer pmPlansCount = 0;
				List<MPLN_ProcessHandler.ProcessLogger> processLoggerList = new List<MPLN_ProcessHandler.ProcessLogger>();
				List<String> lstEmailIDs = new List<String>();
				String processStatus = 'Success';
				SVMXA360__ApplicationLog__c applicationLogRec = new SVMXA360__ApplicationLog__c();
				applicationLogRec.SVMXA360__ApplicationName__c = 'Maintenance Process';
				applicationLogRec.SVMXA360__LogType__c = 'Info';
				applicationLogRec.SVMXA360__SourceRecordId__c = processKey;

				if (processMPlanMap.containsKey(processKey)) {
					processLoggerList = processMPlanMap.get(processKey);
				}
				if (mPlanProcessMap.containsKey(processKey)) {
					timeQualifiedProcessIds.remove(processKey);
					SVMXA360__SM_MaintenancePlanProcess__c processRec = mPlanProcessMap.get(processKey);
					String strSummary = 'NOTE: THIS IS A SYSTEM GENERATED EMAIL. PLEASE DO NOT REPLY TO THIS MESSAGE.' + '\n\n' + 
					'Processing of Maintenance Plans has been completed with the following results: '+ '\n' + 'Maintenance Process: ' + 
					processRec.Name + '\n' + 'Number of Maintenance Plans Reviewed: ' + ' ' + processLoggerList.size()+ '\n';

					for (MPLN_ProcessHandler.ProcessLogger processLoggerRec : processLoggerList){
						strSummary += '\n\n' + 	'Maintenance Plan: ' + ' ' + processLoggerRec.planName;
						strSummary += processLoggerRec.strLogger;
						if (processLoggerRec.status != null && processLoggerRec.status == 'Exception'){
							processStatus = 'Failed';
						}
					}
					if(processStatus == 'Failed' && processRec.SVMXA360__SM_SendFailureEmailTo__c != null){
						lstEmailIDs.add(processRec.SVMXA360__SM_SendFailureEmailTo__c);
					}else if (processStatus == 'Success' && processRec.SVMXA360__SM_SendSuccessEmailTo__c != null) {
						lstEmailIDs.add(processRec.SVMXA360__SM_SendSuccessEmailTo__c);
					}
					processLogMap.put(processKey, strSummary);
					applicationLogList.add(applicationLogRec);
					processRec.SVMXA360__SM_LastRunStatus__c = processStatus;
					processRec.SVMXA360__SM_LastRunDate__c = System.now();
					if (!lstEmailIDs.isEmpty()){
						Messaging.SingleEmailMessage objSingleEmailMsg = new Messaging.SingleEmailMessage();
						objSingleEmailMsg.setToAddresses(lstEmailIDs);
						objSingleEmailMsg.setSenderDisplayName('ServiceMax');
						objSingleEmailMsg.setSubject('ServiceMax' + ': ' + 'Preventive Maintenance Process Run');
						objSingleEmailMsg.setBccSender(false);
						objSingleEmailMsg.setUseSignature(false);			
						objSingleEmailMsg.setPlainTextBody(strSummary);
						messageList.add(objSingleEmailMsg);	
					}
				}
			}

			Map<String, ContentVersion> processContentVersionMap = new Map<String, ContentVersion>();
			if (!applicationLogList.isEmpty()){
				SvmxDatabase.insertRecord(applicationLogList);
				for (SVMXA360__ApplicationLog__c applicationLogRec : applicationLogList) {
					if (processLogMap.containsKey(applicationLogRec.SVMXA360__SourceRecordId__c)) {
						ContentVersion cvRec = new ContentVersion();
						cvRec.VersionData = Blob.valueof(processLogMap.get(applicationLogRec.SVMXA360__SourceRecordId__c));
						cvRec.Title = 'Maintenance Plan Completion Log';
						cvRec.PathOnClient = 'Maintenance Plan Completion Log';
						cvRec.IsMajorVersion = false;
						processContentVersionMap.put(applicationLogRec.Id, cvRec);
						//contentVersionList.add(cvRec);
					}
				}
			}

			if (!processContentVersionMap.isEmpty()) {
				SvmxDatabase.insertRecord(processContentVersionMap.values());
				Map<String, String> contentVersionLogIdMap = new Map<String, String>();
				Set<Id> contentVersionIds = new Set<Id>();
				for (String appLogId : processContentVersionMap.keySet()) {
					ContentVersion cvRec = processContentVersionMap.get(appLogId);
					contentVersionLogIdMap.put(cvRec.Id,appLogId);
					contentVersionIds.add(cvRec.Id);
				}

				List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();

				for (ContentVersion contentVersionRec : (List<ContentVersion>)SvmxDatabase.query(Database.query('SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds'))){
					ContentDocumentLink cDocLink = new ContentDocumentLink();
					if (contentVersionLogIdMap.containsKey(contentVersionRec.Id)) {
						cDocLink.ContentDocumentId = contentVersionRec.ContentDocumentId;
						cDocLink.LinkedEntityId = contentVersionLogIdMap.get(contentVersionRec.Id);
						cDocLink.ShareType = 'V';
						contentDocumentLinkList.add(cDocLink);
					}
				}

				if (!contentDocumentLinkList.isEmpty()) {
					SvmxDatabase.insertRecord(contentDocumentLinkList);
				}

			}
			Messaging.sendEmail(messageList);   
		}
		catch(SvmxSystem.SvmxNestedException e ) {
			isException = true;
			System.debug( LoggingLevel.ERROR, e.getMessage() );
		}
		catch(EmailException e) {   
			isException = true;
			System.debug( LoggingLevel.ERROR, e.getMessage());
		}
		catch(DMLException e) {   
			isException = true;
			System.debug( LoggingLevel.ERROR, e.getMessage());
		}
		catch(Exception e) {
			isException = true;
			System.debug( LoggingLevel.ERROR, e.getMessage() );
		}
		finally {
			for (SVMXA360__SM_MaintenancePlanProcess__c processRec : timeQualifiedProcessList) {
				if (isException) {
					processRec.SVMXA360__SM_LastRunStatus__c = 'Failed';
				} else if (mPlanProcessMap.containsKey(processRec.Id)) {
					processRec.SVMXA360__SM_LastRunStatus__c = mPlanProcessMap.get(processRec.Id).SVMXA360__SM_LastRunStatus__c;
				} else {
					processRec.SVMXA360__SM_LastRunStatus__c = 'No Plans';
				}
				processRec.SVMXA360__SM_LastRunDate__c = System.now();					
			}

			if (!timeQualifiedProcessList.isEmpty()) {
				SvmxDatabase.updateRecord(timeQualifiedProcessList);
			}
			System.debug( LoggingLevel.DEBUG, 'MPLN_ProcessBatch Processed - exit;');
		}
		
    }    
}