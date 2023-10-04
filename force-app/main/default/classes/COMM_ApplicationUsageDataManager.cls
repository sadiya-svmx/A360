/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to log usage data analytics.
 *
 * @author Anbu Venkatachalam
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Anbu Venkatachalam            20 August 2021    Created.
 *****************************************************************************************************/
public with sharing class COMM_ApplicationUsageDataManager {
	
	private static COMM_ApplicationUsageDataManager instance;

	/**
	 * Public static method to create instance of Logger.
	 */
	public static COMM_ApplicationUsageDataManager getInstance() {

		try{
			if(instance == null){
				instance = new COMM_ApplicationUsageDataManager();
			}
		}finally{
			System.debug( LoggingLevel.FINE, 'getInstance() - exit');
		}

		return instance;
	}

	/**
	 * Private constructor to restrict creation of this class instance.
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	private COMM_ApplicationUsageDataManager() {
	}

	/**
	 * This method is used to publish message to the event bus.
	 * @param message Message to be logged in the application log.
	 */
	public void publishUsageData(List<Common.UsageData> usageDataList) {
		System.debug(LoggingLevel.DEBUG, 'COMM_ApplicationUsageDataManager.publishUsageData() - entered');

		List<SVMXA360__COMM_ApplicationUsageDataEvent__e> usageDataEventList = new List<SVMXA360__COMM_ApplicationUsageDataEvent__e>();

		try {
			
			Common.GlobalProperty propResponse = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName( CONF_CustomSettingsManager.NAME_ENABLE_APP_USAGE_TRACKING );
			if(!'true'.equalsIgnoreCase(propResponse.value)){
				System.debug(LoggingLevel.INFO, 'publishUsageData() : Tracking is disabled');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.FEATURE_DISABLED);
			}

			for (Common.UsageData usageDataItem : usageDataList) {
				SVMXA360__COMM_ApplicationUsageDataEvent__e usageDataRecord = new SVMXA360__COMM_ApplicationUsageDataEvent__e();
				usageDataRecord.SVMXA360__UniqueId__c = escapeSingleQuotes(usageDataItem.uniqueId);
				usageDataRecord.SVMXA360__ActionRecordId__c = escapeSingleQuotes(usageDataItem.actionRecordId);
				usageDataRecord.SVMXA360__ActionDeveloperName__c = escapeSingleQuotes(usageDataItem.actionDeveloperName);
				usageDataRecord.SVMXA360__ActionName__c = escapeSingleQuotes(usageDataItem.actionName);
				usageDataRecord.SVMXA360__SourceRecordId__c = escapeSingleQuotes(usageDataItem.sourceRecordId);
				usageDataRecord.SVMXA360__ObjectApiName__c = escapeSingleQuotes(usageDataItem.objectApiName);
				usageDataRecord.SVMXA360__Status__c = escapeSingleQuotes(usageDataItem.status);
				usageDataRecord.SVMXA360__ApplicationName__c = escapeSingleQuotes(usageDataItem.appName);
				usageDataRecord.SVMXA360__UserId__c = UserInfo.getUserId();
				usageDataRecord.SVMXA360__EpochStartTime__c = (Long)usageDataItem.epochStartTime;
				usageDataRecord.SVMXA360__EpochEndTime__c = (Long)usageDataItem.epochEndTime;
				usageDataEventList.add(usageDataRecord);
			}

			if (usageDataEventList.size() > 0) {
				List<Database.SaveResult> saveResults = EventBus.publish(usageDataEventList);

				for (Database.SaveResult sr : saveResults) {
					if (!sr.isSuccess()) {
						for (Database.Error error : sr.getErrors()) {
							System.debug(LoggingLevel.ERROR, 'Failed to publish event: ' + error.getStatusCode() + ' - ' + error.getMessage());
						}
					}
				}
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Failed to publish event: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'publish() - exit');
		}
	}

	public void upsertUsageData(List<SVMXA360__COMM_ApplicationUsageDataEvent__e> usageDataEventList) {
		System.debug(LoggingLevel.DEBUG, 'COMM_ApplicationUsageDataManager.upsertUsageData() - entered' + usageDataEventList);
		try {
			Map<String, SVMXA360__COMM_ApplicationUsageData__c> usageDataMap = new Map<String, SVMXA360__COMM_ApplicationUsageData__c>();
			for (SVMXA360__COMM_ApplicationUsageDataEvent__e usageDataEventItem : usageDataEventList) {

				SVMXA360__COMM_ApplicationUsageData__c usageData = usageDataMap.get(usageDataEventItem.SVMXA360__UniqueId__c);
				if(usageData == null){
					usageData = new SVMXA360__COMM_ApplicationUsageData__c();
				}
				usageDataMap.put(usageDataEventItem.SVMXA360__UniqueId__c, mapUsageData(usageData, usageDataEventItem));
			}

			List<SVMXA360__COMM_ApplicationUsageData__c> usageList = usageDataMap.values();
			System.debug(LoggingLevel.DEBUG, 'COMM_ApplicationUsageDataManager.upsertUsageData() - upsert load size: ' + usageList.size());
			
			final SObjectAccessDecision decision = Security.stripInaccessible( AccessType.UPSERTABLE, usageList );

			if (usageList.size() > 0 && decision.getRemovedFields().isEmpty() ) {
				Schema.SObjectField uniqueId = SVMXA360__COMM_ApplicationUsageData__c.Fields.SVMXA360__UniqueId__c;
				List<Database.UpsertResult> upsertResults = Database.upsert(usageList, uniqueId, false);
				for (Database.UpsertResult ur : upsertResults) {
					if (!ur.isSuccess()) {
						for (Database.Error error : ur.getErrors()) {
							System.debug(LoggingLevel.ERROR, 'Failed to upsert usage data: ' + error.getStatusCode() + ' - ' + error.getMessage());
						}
					}
				}				
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Failed to upsert usage data: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'upsert() - exit');
		}
	}

	private SVMXA360__COMM_ApplicationUsageData__c mapUsageData (SVMXA360__COMM_ApplicationUsageData__c usageData, SVMXA360__COMM_ApplicationUsageDataEvent__e usageDataEventItem){
		usageData.SVMXA360__UniqueId__c = usageDataEventItem.SVMXA360__UniqueId__c;
		if(usageDataEventItem.SVMXA360__Status__c == null) {
			usageData.SVMXA360__ActionName__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__ActionName__c);
			usageData.SVMXA360__ActionDeveloperName__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__ActionDeveloperName__c);
			usageData.SVMXA360__ActionRecordId__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__ActionRecordId__c);
			usageData.SVMXA360__ApplicationName__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__ApplicationName__c);
			usageData.SVMXA360__StartTime__c = (usageDataEventItem.SVMXA360__EpochStartTime__c != null) ? DateTime.newInstance((Long)usageDataEventItem.SVMXA360__EpochStartTime__c) : null;
			usageData.SVMXA360__EpochStartTime__c = usageDataEventItem.SVMXA360__EpochStartTime__c;
			usageData.SVMXA360__UserId__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__UserId__c);
			usageData.SVMXA360__ObjectApiName__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__ObjectApiName__c);
			usageData.SVMXA360__SourceRecordId__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__SourceRecordId__c);
		}else {
			usageData.SVMXA360__Status__c = escapeSingleQuotes(usageDataEventItem.SVMXA360__Status__c);
			usageData.SVMXA360__EndTime__c = (usageDataEventItem.SVMXA360__EpochEndTime__c != null) ? DateTime.newInstance((Long)usageDataEventItem.SVMXA360__EpochEndTime__c) : null;
			usageData.SVMXA360__EpochEndTime__c = usageDataEventItem.SVMXA360__EpochEndTime__c;
		}
		return usageData;
	}

	private String escapeSingleQuotes(String inputValue){
		if(!String.isBlank(inputValue)){
			return String.escapeSingleQuotes(inputValue);
		}
		return inputValue;
	}
}