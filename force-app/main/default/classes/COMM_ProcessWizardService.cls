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
public with sharing class COMM_ProcessWizardService {
    
    private final COMM_ProcessWizardServiceImpl processWizardServiceImpl = new COMM_ProcessWizardServiceImpl();

    /**
	 * This method fetch the step usage log.
	 *
	 * @return Returns instance of Common.ServiceResponse with success value .
	 * @see COMM_ApplicationUsageDataServiceImpl
	 * @exception SvmxSystem.SvmxNestedException, Exception
	 */
	public Common.ServiceResponse getStepUsageLogBySourceRecordId(String sourceRecordId) {
		System.debug(LoggingLevel.DEBUG, 'getStepUsageLog() - enter');

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			serviceResponse.data = new COMM_ProcessWizardServiceImpl().getStepUsageLog(sourceRecordId);
			System.debug(LoggingLevel.INFO, 'getStepUsageLog() : Get step usage log');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'getStepUsageLog() : Failed to get step usage log. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'getStepUsageLog() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}

	public Common.ServiceResponse setWizardStepUsageLog(List<Common.StepUsageLogRequest> stepUsageLogList) {
		System.debug(LoggingLevel.DEBUG, 'setWizardStepUsageLog() - enter');

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			new COMM_ProcessWizardServiceImpl().setWizardStepUsageLog(stepUsageLogList);
			System.debug(LoggingLevel.INFO, 'setWizardStepUsageLog() : add step usage log');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'setWizardStepUsageLog() : Failed to add step usage log. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setWizardStepUsageLog() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}

/* 	public Common.ServiceResponse addStepUsageLog(List<Common.StepUsageLogRequest> stepUsageLogList) {
		System.debug(LoggingLevel.DEBUG, 'addStepUsageLog() - enter');

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			new COMM_ProcessWizardServiceImpl().addStepUsageLog(stepUsageLogList);
			System.debug(LoggingLevel.INFO, 'addStepUsageLog() : add step usage log');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'addStepUsageLog() : Failed to add step usage log. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'addStepUsageLog() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}

	public Common.ServiceResponse removeStepUsageLog(List<Common.StepUsageLogRequest> stepUsageLogList) {
		System.debug(LoggingLevel.DEBUG, 'removeStepUsageLog() - enter');

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			new COMM_ProcessWizardServiceImpl().removeStepUsageLog(stepUsageLogList);
			System.debug(LoggingLevel.INFO, 'removeStepUsageLog() : remove step usage log');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'removeStepUsageLog() : Failed to remove step usage log. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'removeStepUsageLog() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	} */
}