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
 *              Anbu Venkatachalam            13 Oct 2021    Created.
 * A360TOOL-858 Ramachandra Mohan             01 Dec 2021    Service to retrieve global property values.
 *****************************************************************************************************/
public with sharing class CONF_CustomSettingsService_LS {
    
    /**
	 * This method publish usage data to platform event.
	 *
	 * @return Returns generic response with success flag true/false.
	 */

	@AuraEnabled
	public static Common.ServiceResponse setApplicationUsageTracker(final String enableFlag) {
		System.debug(LoggingLevel.DEBUG, 'setApplicationUsageTracker() - enter; enableFlag= ' + enableFlag);

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			
			if(String.isBlank(enableFlag)){
				throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
			}
            
			serviceResponse = new CONF_CustomSettingsService().setApplicationUsageTracker( enableFlag == 'true' );
			System.debug(LoggingLevel.INFO, 'setApplicationUsageTracker() : set application tracker flag.');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'setApplicationUsageTracker() : set application tracker flag. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'setApplicationUsageTracker() - exit; serviceResponse.success= ' + serviceResponse.success);
		}
		
		return serviceResponse;
	}

    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getApplicationUsageTracker(){
        System.debug(LoggingLevel.DEBUG, 'getApplicationUsageTracker() - enter;');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			serviceResponse = new CONF_CustomSettingsService().getApplicationUsageTracker();
			System.debug(LoggingLevel.INFO, 'getApplicationUsageTracker() : get application tracker flag.');
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'getApplicationUsageTracker() : get application tracker flag. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		} finally {
			System.debug(LoggingLevel.DEBUG, 'getApplicationUsageTracker() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse getGlobalProperty( final String name ) {
        
        System.debug(LoggingLevel.DEBUG, 'getGlobalProperty() - enter;');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			serviceResponse = new CONF_CustomSettingsService().getGlobalProperty( String.escapeSingleQuotes(name) );
		} 
        catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'getGlobalProperty() : Failed to retireve global property. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		}
        finally {
			System.debug(LoggingLevel.DEBUG, 'getGlobalProperty() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
    }
}