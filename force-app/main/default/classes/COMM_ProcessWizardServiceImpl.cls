/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to read & write from wizard step usage log.
 *
 * @author Anbu Venkatachalam
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Anbu Venkatachalam            8 December 2021    Created.
 *****************************************************************************************************/
public with sharing class COMM_ProcessWizardServiceImpl {

    private final COMM_ProcessWizardManager processWizardMgr = COMM_ProcessWizardManager.getInstance();

	public List<Common.StepUsageLog> getStepUsageLog(String sourceRecordId) {
		System.debug(LoggingLevel.DEBUG, 'getStepUsageLog() - enter');

		List<Common.StepUsageLog> stepUsageLogList = new List<Common.StepUsageLog> ();
		try {
			if (String.isBlank(sourceRecordId)){
				System.debug(LoggingLevel.INFO, 'getStepUsageLog() : sourceRecordId is null');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.REQUEST_IS_BLANK);
			}

			List<SVMXA360__COMM_StepUsageLog__c> stepUsageLog = processWizardMgr.getWizardStepUsageLogBySourceRecord(sourceRecordId);

			stepUsageLogList = processWizardMgr.mapStepUsageLog(stepUsageLog);

			System.debug(LoggingLevel.INFO, 'getStepUsageLog() : Get step usage Log');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'getStepUsageLog() : Failed to get usage log. Error= ' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'getStepUsageLog() - exit;');
		}

		return stepUsageLogList;
	}

	public void setWizardStepUsageLog(List<Common.StepUsageLogRequest> wizardStepUsageLogList) {
		System.debug(LoggingLevel.DEBUG, 'setStepUsageLog() - enter');

		try {
			processWizardMgr.setWizardStepUsageLog(wizardStepUsageLogList);
			System.debug(LoggingLevel.INFO, 'setStepUsageLog() : Set step usage Log');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'setStepUsageLog() : Failed to set usage log. Error= ' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setStepUsageLog() - exit;');
		}
	}
}