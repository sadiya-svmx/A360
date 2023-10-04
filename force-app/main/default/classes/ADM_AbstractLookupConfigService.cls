/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for Lookup Config service implementation.
 * Also provides implementation for invokeMethod which maps to the requested Lookup Config service implementation. 
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Jun 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 *****************************************************************************************************/
public abstract class ADM_AbstractLookupConfigService extends COMM_SvmxRestBase {
    public ADM_AbstractLookupConfigService(){
    }
    
    protected ADM_AbstractLookupConfigService(RestRequest req, RestResponse res) {
        super(req, res, 'LookupConfigRestInterface');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {

                when 'getLookupConfigurations' {
                    response = getLookupConfigurations( request.params.get('objectName'), request.params.get('headerObject') );
                }
                when 'getAllLookupConfigurations' {
                    response = getAllLookupConfigurations();
                }
                when 'saveLookupConfigurations' {
                    response = saveLookupConfigurations( (List<Adm.LookupConfig>) deserializeRequestTo( List<Adm.LookupConfig>.class ) );
                }
                when 'validateLookupConfiguration' {
                    response = validateLookupConfiguration( (Adm.LookupConfig) deserializeRequestTo( Adm.LookupConfig.class ) );
                }

                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }

    public abstract Common.ServiceResponse getLookupConfigurations(String objectApiName, String headerObject);

    public abstract Common.ServiceResponse getAllLookupConfigurations();

    public abstract Common.ServiceResponse saveLookupConfigurations(final List<Adm.LookupConfig> lookupConfigList);
    
    public abstract Common.ServiceResponse validateLookupConfiguration( Adm.LookupConfig lookupConfig );

}