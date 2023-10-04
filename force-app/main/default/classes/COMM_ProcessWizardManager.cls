/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to log wizard step usage.
 *
 * @author Anbu Venkatachalam
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Anbu Venkatachalam           07 December 2021    Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class COMM_ProcessWizardManager {
	
	private static COMM_ProcessWizardManager instance;

	/**
	 * Public static method to create instance.
	 */
	public static COMM_ProcessWizardManager getInstance() {

		try {
			if (instance == null) {
				instance = new COMM_ProcessWizardManager();
			}
		} finally {
			System.debug( LoggingLevel.FINE, 'getInstance() - exit');
		}

		return instance;
	}

	/**
	 * Private constructor to restrict creation of this class instance.
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	private COMM_ProcessWizardManager() {
	}

	/**
	 * This method is used to fetch step dependency usage log.
	 * @param sourceRecordId Fetch all dependency based on source record id.
	 */

	public List<SVMXA360__COMM_StepUsageLog__c> getWizardStepUsageLogBySourceRecord(String sourceRecordId) {
		System.debug(LoggingLevel.DEBUG, 'COMM_ProcessWizardManager.getWizardStepUsageLogBySourceRecord() - entered');
		List<SVMXA360__COMM_StepUsageLog__c> stepDependencyUsageLog = new List<SVMXA360__COMM_StepUsageLog__c>();
		try {

			if ( String.isBlank(sourceRecordId) ) {
				System.debug(LoggingLevel.INFO, 'getWizardStepUsageLogBySourceRecord() : Missing input.');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
			}
			
            stepDependencyUsageLog = SvmxDatabase.query([SELECT Id, 
															SVMXA360__ProcessWizardStep__c, 
															SVMXA360__SourceRecordId__c, 
															SVMXA360__UniqueId__c 
														FROM SVMXA360__COMM_StepUsageLog__c
														WHERE SVMXA360__Status__c = 'Complete' 
														AND SVMXA360__UniqueId__c LIKE: sourceRecordId+'%'
                                                    ]);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Failed to fetch step dependency log: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'getWizardStepUsageLogBySourceRecord() - exit');
		}
        
        return stepDependencyUsageLog;
	}

	public void setWizardStepUsageLog(List<Common.StepUsageLogRequest> wizardStepUsageList) {
		System.debug(LoggingLevel.DEBUG, 'COMM_ProcessWizardManager.setWizardStepUsageLog() - entered');

		List<SVMXA360__COMM_StepUsageLog__c> addStepUsageLogList = new List<SVMXA360__COMM_StepUsageLog__c>();

		try {
			for (Common.StepUsageLogRequest wizardStepUsage: wizardStepUsageList) {
				SVMXA360__COMM_StepUsageLog__c usageLog = new SVMXA360__COMM_StepUsageLog__c();
				String uniqueId = wizardStepUsage.sourceRecordId + '_' + wizardStepUsage.stepId;
				usageLog.SVMXA360__ProcessWizardStep__c = escapeSingleQuotes(wizardStepUsage.stepId);
				usageLog.SVMXA360__SourceRecordId__c = escapeSingleQuotes(wizardStepUsage.sourceRecordId);
				usageLog.SVMXA360__UniqueId__c = escapeSingleQuotes(uniqueId);
				usageLog.SVMXA360__Status__c = (wizardStepUsage.enabled == true) ? 'Complete' : 'Incomplete';
				addStepUsageLogList.add(usageLog);
			}
			if (addStepUsageLogList.size() > 0) {
				upsertStepUsageLog(addStepUsageLogList);
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Failed to upsert log: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setWizardStepUsageLog() - exit');
		}
	}
	
	@Testvisible
	private void upsertStepUsageLog(List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList) {
		System.debug(LoggingLevel.DEBUG, 'COMM_ProcessWizardManager.upsertStepUsageLog() - entered' + stepUsageLogList);
		Savepoint sPoint = Database.setSavepoint();
		try {
			
			if (stepUsageLogList.size() == 0) {
				System.debug(LoggingLevel.INFO, 'upsertStepUsageLog() : Missing input.');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
			}
			Schema.SObjectField uniqueId = SVMXA360__COMM_StepUsageLog__c.Fields.SVMXA360__UniqueId__c;
			SvmxDatabase.upsertRecord( stepUsageLogList, uniqueId, true );
			
		} catch (SvmxSystem.SvmxNestedException e) {
            Database.rollback( sPoint );            
            System.debug( LoggingLevel.ERROR, 'upsertStepUsageLog() : Failed to upsert usage log. Error= ' + e.getMessage() );
            throw e;
        } catch (Exception e) {
			Database.rollback( sPoint );
			System.debug(LoggingLevel.ERROR, 'Failed to upsert usage log: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'upsertStepUsageLog() - exit');
		}
	}
	
	@Testvisible
	private void deleteStepUsageLog(List<SVMXA360__COMM_StepUsageLog__c> stepUsageLogList) {
		System.debug(LoggingLevel.DEBUG, 'COMM_ProcessWizardManager.deleteStepUsageLog() - entered' + stepUsageLogList);
		Savepoint sPoint = Database.setSavepoint();
		try {
			if (stepUsageLogList.size() == 0) {
				System.debug(LoggingLevel.INFO, 'deleteStepUsageLog() : Missing input.');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
			}

			SvmxDatabase.deleteRecord( stepUsageLogList );

		} catch (SvmxSystem.SvmxNestedException e) {
            Database.rollback( sPoint );            
            System.debug( LoggingLevel.ERROR, 'deleteStepUsageLog() : Failed to delete step usage log. Error= ' + e.getMessage() );
            throw e;
        } catch (Exception e) {
			Database.rollback( sPoint );
			System.debug(LoggingLevel.ERROR, 'Failed to delete usage log: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'deleteStepUsageLog() - exit');
		}
	}

    /* private List<SVMXA360__COMM_StepUsageLog__c> getWizardStepUsageLogByUniqueIds( List<String> uniqueIdList ) {
		return SvmxDatabase.query([SELECT Id FROM SVMXA360__COMM_StepUsageLog__c WHERE SVMXA360__UniqueId__c IN: uniqueIdList]);
	} */

    public List<Common.StepUsageLog> mapStepUsageLog ( List<SVMXA360__COMM_StepUsageLog__c> stepUsageList ) {
       List<Common.StepUsageLog> stepUsageLogList = new List<Common.StepUsageLog>();
        try {
            for (SVMXA360__COMM_StepUsageLog__c stepUsage: stepUsageList) {
                Common.StepUsageLog stepUsageLog = new Common.StepUsageLog();
            
                stepUsageLog.uniqueId = stepUsage.SVMXA360__UniqueId__c;
                stepUsageLog.sourceRecordId = stepUsage.SVMXA360__SourceRecordId__c;
                stepUsageLog.stepId = stepUsage.SVMXA360__ProcessWizardStep__c;         
                stepUsageLogList.add(stepUsageLog);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to map step dependency log: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'mapStepUsageLog() - exit');
        }
        return stepUsageLogList;
    }
	
    private String escapeSingleQuotes(String inputValue) {
		return (!String.isBlank(inputValue)) ? String.escapeSingleQuotes(inputValue) : inputValue;
	}
}