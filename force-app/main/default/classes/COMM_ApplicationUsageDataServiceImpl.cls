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
public with sharing class COMM_ApplicationUsageDataServiceImpl {
	private final COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();

	/**
	 * This method retrieves admin pages
	 */
	public void publishUsageData(List<Common.UsageData> usageDataList) {
		System.debug(LoggingLevel.DEBUG, 'publishUsageData() - enter');

		try {
			if (usageDataList == null){
				System.debug(LoggingLevel.INFO, 'publishUsageData() : Input is null');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.REQUEST_IS_BLANK);
			}
			if (usageDataList.size() == 0) {
				System.debug(LoggingLevel.INFO, 'publishUsageData() : Usage list is empty');
				throw new SvmxSystem.SvmxNestedException(ErrorMessage.REQUEST_IS_BLANK);
			}

			appUsageDataMgr.publishUsageData(usageDataList);
			System.debug(LoggingLevel.INFO, 'publishUsageData() : Published to platform event');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'publishUsageData() : Failed to publish to platform event. Error= ' + e.getStackTraceString());
			throw e;
		} finally {
			System.debug(LoggingLevel.DEBUG, 'publishUsageData() - exit;');
		}
	}
}