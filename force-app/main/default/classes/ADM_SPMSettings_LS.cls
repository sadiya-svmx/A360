/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Server side controller for lightning component SPMCommonSettings.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        			Name                    Date            Comment
 *****************************************************************************************************
 *    A360ADM-1841          Sachin S                16 Mar 2022     Created.
 *****************************************************************************************************/
public with sharing class ADM_SPMSettings_LS {

	@AuraEnabled
	public static Common.ServiceResponse saveSettingInfo(final String requestJson) {
		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
    	try {
			
            Adm.SPMSettingInfo sPMSetting = (Adm.SPMSettingInfo) JSON.deserializeStrict( requestJson, Adm.SPMSettingInfo.class );
            serviceResponse = new ADM_SPMSettingsService().saveSettingInfo( sPMSetting );

		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'saveSettingInfo() : Failed to save SPM Setting. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'saveSettingInfo() - exit; serviceResponse.success= ' + serviceResponse.success);
		}
		
		return serviceResponse;
    }
    
    @AuraEnabled
	public static Common.ServiceResponse retreiveSettingInfo(final String settingKey) {
		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
    	try {
			
            serviceResponse = new ADM_SPMSettingsService().retreiveSettingInfo( settingKey );

		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'retreiveSettingInfo() : Failed to retreive SPM Setting. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'retreiveSettingInfo() - exit; serviceResponse.success= ' + serviceResponse.success);
		}
		
		return serviceResponse;
    }
}