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
 *              Anbu Venkatachalam            20 July 2021    Created.
 *****************************************************************************************************/
public with sharing class COMM_ApplicationUsageDataService {
	/**
	 * This method publishes usage data to platform event.
	 *
	 * @return Returns instance of Common.ServiceResponse with success value .
	 * @see COMM_ApplicationUsageDataServiceImpl
	 * @exception SvmxSystem.SvmxNestedException, Exception
	 */
	public Common.ServiceResponse publishUsageData(List<Common.UsageData> usageDataList) {
		System.debug(LoggingLevel.DEBUG, 'publishUsageData() - enter');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			new COMM_ApplicationUsageDataServiceImpl().publishUsageData(usageDataList);
			System.debug(LoggingLevel.INFO, 'publishUsageData() : Published to platform event');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'publishUsageData() : Failed to publish to platform event. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'publishUsageData() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}
}