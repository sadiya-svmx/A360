/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines methods related to auto configurator.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       01 Dec 2021     Created.
 *****************************************************************************************************/
public with sharing class ADM_AutoConfiguratorManager {

    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_AutoConfiguratorManager instance;
    
    /**
     * Static method to retrieve instance of this class. 
     */
    public static ADM_AutoConfiguratorManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'ADM_AutoConfiguratorManager::getInstance() - enter');
        
        try {
            // Create instance of this class if not exists.
            if( instance == null ) {
                instance = new ADM_AutoConfiguratorManager();
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'ADM_AutoConfiguratorManager::getInstance() - exit');
        }
        
        return instance;
    }
    
    @future(callout=true)
    public static void invokeAutoConfigurator() {
        
        System.debug(LoggingLevel.DEBUG, 'invokeAutoConfigurator() - enter');

		try {
            final Common.SforceSessionInfo authInfo = new Common.SforceSessionInfo();
            
            authInfo.acessToken = !Test.isRunningTest()
                ? Page.COMM_AccessProvider.getContent().toString().trim()
                : '';
            authInfo.serviceEndpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/57.0/';
            
            Http httpConnect = new Http();
            HttpRequest request = new HttpRequest();
            final Common.GlobalProperty globalProperty = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName( 'GP803' );
            request.setEndpoint( ( globalProperty.value == null ? 'https://asset360tooling.servicemax.com' : globalProperty.value ) + '/svmx/a360/configurator/seedData/' );
            
            request.setHeader('sforceSessionInfo', JSON.serialize(authInfo) );
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('statusMailId', UserInfo.getUserEmail());
            request.setMethod('GET');
            
            final HttpResponse response = httpConnect.send(request);
            
    		System.debug( LoggingLevel.INFO, 'Response Body: ' + response.getBody() );
            
            CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP802', String.valueOf( System.currentTimeMillis() ) );
		}
        catch(System.CalloutException e) {
            System.debug( LoggingLevel.ERROR, 'invokeAutoConfigurator() : Failed to invoke configurator. Error: ' + e.getMessage() );
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'invokeAutoConfigurator() : Failed to invoke configurator. Error' + e.getMessage());
		}
        finally {
			System.debug(LoggingLevel.DEBUG, 'invokeAutoConfigurator() - exit' );
		}
    }
 
    private ADM_AutoConfiguratorManager() {
        
    }
}