/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to fetch enable flag for application usage tracking.
 *
 * @author Anbu Venkatachalam
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Anbu Venkatachalam            02 Sep 2021    Created.
 * A360TOOL-858 Ramachandra Mohan             01 Dec 2021    Service to retrieve/set global property values.
 *****************************************************************************************************/
public with sharing class CONF_CustomSettingsService extends CONF_AbstractCustomSettingsService {

	private final CONF_CustomSettingsManager customSettingMgr = CONF_CustomSettingsManager.getInstance();
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public CONF_CustomSettingsService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public CONF_CustomSettingsService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    public Common.ServiceResponse getApplicationUsageTracker() {
		System.debug(LoggingLevel.DEBUG, 'getApplicationUsageTracker() - enter');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			serviceResponse.data = customSettingMgr.getGlobalPropertyByName( CONF_CustomSettingsManager.NAME_ENABLE_APP_USAGE_TRACKING );
			System.debug(LoggingLevel.INFO, 'getApplicationUsageTracker() : Fetched the flag');

		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'getApplicationUsageTracker() : Failed to retreive flag. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'getApplicationUsageTracker() - exit; serviceResponse.success= ' + serviceResponse.success);
		}
		return serviceResponse;
	}

    public Common.ServiceResponse setApplicationUsageTracker(Boolean enable) {
		System.debug(LoggingLevel.DEBUG, 'setApplicationUsageTracker() - enter');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			String value = enable ? 'true' : 'false';
			customSettingMgr.setGlobalPropertyByName(CONF_CustomSettingsManager.NAME_ENABLE_APP_USAGE_TRACKING, value);
			System.debug(LoggingLevel.INFO, 'setApplicationUsageTracker() : Set application tracker to : '+ String.valueOf(enable));
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'setApplicationUsageTracker() : Failed to set application usage tracker. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setApplicationUsageTracker() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}
    
    override public Common.ServiceResponse getGlobalProperty( final String name ) {
        
		System.debug(LoggingLevel.DEBUG, 'getGlobalProperty() - enter');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			serviceResponse.data = customSettingMgr.getGlobalPropertyByName( name );
		} 
        catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'getGlobalProperty() : Failed to retreive Custom Setting. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		}
        finally {
			System.debug(LoggingLevel.DEBUG, 'getGlobalProperty() - exit; serviceResponse.success= ' + serviceResponse.success);
		}
        
		return serviceResponse;
	}
    
    override public Common.ServiceResponse setGlobalProperty( final String name, final String value ) {
        
		System.debug(LoggingLevel.DEBUG, 'setGlobalProperty() - enter');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			customSettingMgr.setGlobalPropertyByName(name, value);
		} 
        catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'setGlobalProperty() : Failed to set global property. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setGlobalProperty() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
	}
}