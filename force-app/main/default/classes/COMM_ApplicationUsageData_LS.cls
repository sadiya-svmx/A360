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
 *              Anbu Venkatachalam            20 July 2021    Created.
 *****************************************************************************************************/
public with sharing class COMM_ApplicationUsageData_LS {
	/**
	 * This method publish usage data to platform event.
	 *
	 * @return Returns generic response with success flag true/false.
	 */

	@AuraEnabled
	public static Common.ServiceResponse publishUsageData(final String requestJson) {
		System.debug(LoggingLevel.DEBUG, 'publishUsageData() - enter; requestJson= ' + requestJson);

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			Common.UsageData usageData = (Common.UsageData) JSON.deserialize(requestJson, Common.UsageData.class);

			List<Common.UsageData> usageDataList = new List<Common.UsageData>();
			usageDataList.add(usageData);
			serviceResponse = new COMM_ApplicationUsageDataService().publishUsageData(usageDataList);
			System.debug(LoggingLevel.INFO, 'publishUsageData() : Published to platform event');
		} catch (JSONException e) {
			System.debug(LoggingLevel.ERROR, 'publishUsageData() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'publishUsageData() : Failed to publish to event. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'publishUsageData() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}
}