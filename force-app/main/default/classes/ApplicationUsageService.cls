/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to work with custom setting.
 *
 * @author Anbu Venkatachalam
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Anbu Venkatachalam            02 Sep 2021    Created.
 *****************************************************************************************************/
global with sharing class ApplicationUsageService {
    /**
     * This method is used to set application usage tracking enable flag.
     * 
     * @return SvmxResponse.status specifies true on successful update of the flag value.
     * 
     * @example ApplicationUsageService.setApplicationUsageTracker();
     */

    global static SvmxGlobal.SvmxResponse setApplicationUsageTracker(final Boolean enable) {

        return new CONF_CustomSettingsService().setApplicationUsageTracker( enable );
	}
}