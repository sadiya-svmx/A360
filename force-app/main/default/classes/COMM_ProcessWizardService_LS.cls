/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to log usage data analytics from user interface.
 *
 * @author Anbu Venkatachalam
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Anbu Venkatachalam            08 December 2021    Created.
 *****************************************************************************************************/
public with sharing class COMM_ProcessWizardService_LS {
 
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getStepUsageLogBySourceRecordId(String sourceRecordId) {

        System.debug( LoggingLevel.DEBUG, 'getStepUsageLogBySourceRecordId() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new COMM_ProcessWizardService().getStepUsageLogBySourceRecordId(sourceRecordId);
            System.debug( LoggingLevel.INFO, 'getStepUsageLogBySourceRecordId() : Retrieved step usage log' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getStepUsageLogBySourceRecordId() : Failed to retrieve step usage log. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getStepUsageLogBySourceRecordId() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse setWizardStepUsageLog(String requestJson){
        System.debug( LoggingLevel.DEBUG, 'setWizardStepUsageLog() - enter' +  requestJson);
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
			Common.StepUsageLogRequest stepUsageLog = (Common.StepUsageLogRequest) JSON.deserialize(requestJson, Common.StepUsageLogRequest.class);

			List<Common.StepUsageLogRequest> stepUsageLogList = new List<Common.StepUsageLogRequest>();
			stepUsageLogList.add(stepUsageLog);
			serviceResponse = new COMM_ProcessWizardService().setWizardStepUsageLog(stepUsageLogList);
			System.debug(LoggingLevel.INFO, 'setWizardStepUsageLog() : Added wizard step usage log');
		} catch (JSONException e) {
			System.debug(LoggingLevel.ERROR, 'setWizardStepUsageLog() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'setWizardStepUsageLog() : Failed to log wizard step usage. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setWizardStepUsageLog() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

        return serviceResponse;
    }
}