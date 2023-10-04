/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services related to application configuration services.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan           13 Oct 2021    Created.
 *****************************************************************************************************/
public with sharing  class ADM_AutoConfiguratorService_LS {

    @AuraEnabled
    public static Common.ServiceResponse invokeAutoConfigurator() {
        
        System.debug(LoggingLevel.DEBUG, 'invokeAutoConfigurator() - enter');

		Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

		try {
			if(!Test.isRunningTest()) {
            	ADM_AutoConfiguratorManager.invokeAutoConfigurator();
			}	
		} 
        catch (Exception e) {
            
			System.debug(LoggingLevel.ERROR, 'invokeAutoConfigurator() : Failed to invoke configurator. Error' + e.getStackTraceString());

			serviceResponse.success = false;
			serviceResponse.message = e.getMessage();
		}
        finally {
			System.debug(LoggingLevel.DEBUG, 'invokeAutoConfigurator() - exit; serviceResponse.success= ' + serviceResponse.success);
		}

		return serviceResponse;
    }
}