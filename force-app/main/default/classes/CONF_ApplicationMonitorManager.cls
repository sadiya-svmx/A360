/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides New Relic integration service for tracking usage data
 *
 * @author Sachin S
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                05 Sep 2022     Created.
 *****************************************************************************************************/
public class CONF_ApplicationMonitorManager {
    
     /**
     * This method sends usage data to new relic using http  
     * @param String usagedata to be logged in new relic
     * @return Returns response from new relic.
     * @example logUsage('[{"eventType": "SPMRuntime", "Type": "Transaction", "DeveloperName": "Test123"}]');
     */
    @future(callout=true)
    public static void logUsage (String usageData) {
        
        System.debug( LoggingLevel.FINEST, 'logUsage() - enter' );
        
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://insights-collector.newrelic.com/v1/accounts/3552021/events');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            final Common.GlobalProperty globalProperty = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName( 'GP605' );
            req.setHeader('X-Insert-Key', globalProperty.value);
            req.setBody(usageData);
            System.debug(usageData);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            parseResponse(res.getBody());
            
            System.debug( LoggingLevel.FINE, 'logUsage() : Usage data successfully logged to newrelic.' );
        }
        catch(System.CalloutException ex) {
            System.debug( LoggingLevel.ERROR, 'logUsage() : Failed to invoke newrelic. Error: ' + ex.getMessage() );
        }
        catch(Exception ex) {
            System.debug( LoggingLevel.ERROR, 'logUsage() : Failed to invoke newrelic. Error: ' + ex.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'logUsage() - exit' );
        }
    }
    
    private static void parseResponse (String responseStr) {
        
        System.debug(LoggingLevel.INFO, 'Response Body ' + responseStr);
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
		JSONParser parser = JSON.createParser(responseStr);
		while (parser.nextToken() != null) {
       		if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if (fieldName == 'success') {
                    serviceResponse.success = parser.getText() != null ? boolean.valueOf(parser.getText()) : false;
                    /*
                      To Do: Create Application log for the log request on failure.
                     */
                } else if (fieldName == 'uuid') {
                    serviceResponse.data = JSON.serialize(parser.getText());
                }
        	}
        }
    }
}