/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/create/update and delete 
 * LookuoConfiguration. 
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Aug 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 *****************************************************************************************************/
public with sharing class ADM_LookupConfigService extends ADM_AbstractLookupConfigService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_LookupConfigService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_LookupConfigService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    public Common.ServiceResponse getLookupConfigDetail( final String lookupConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getLookupConfigDetail() - enter; lookupConfigId ' + lookupConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_LookupConfigManager().getLookupConfigDetail(lookupConfigId);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getLookupConfigDetail() : Failed to retrieve LookupConfiguration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigDetail() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    override public Common.ServiceResponse getLookupConfigurations( final String objectName, final String headerObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - enter; objectName ' + objectName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_LookupConfigManager().getLookupConfigurations(objectName, headerObject);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getLookupConfigurations() : Failed to retrieve LookupConfigurations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    public Common.ServiceResponse saveLookupConfig( final Adm.LookupConfig lookupConfig ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveLookupConfig() - enter; lookupConfig ' + lookupConfig );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_LookupConfigManager().saveLookupConfig(lookupConfig);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveLookupConfig() : Failed to save LookupConfigurations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveLookupConfig() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    public Common.ServiceResponse deleteLookupConfig( final String lookupConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteLookupConfig() - enter; lookupConfigId ' + lookupConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_LookupConfigManager().deleteLookupConfig(lookupConfigId);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteLookupConfig() : Failed to delete LookupConfiguration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteLookupConfig() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    override public Common.ServiceResponse getAllLookupConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllLookupConfigurations() - enter;' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_LookupConfigManager().getAllLookupConfigurations();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllLookupConfigurations() : Failed to retrieve LookupConfigurations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllLookupConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    override public Common.ServiceResponse saveLookupConfigurations( final List<Adm.LookupConfig> lookupConfigList ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveLookupConfigurations() - enter; lookupConfigList ' + lookupConfigList );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_LookupConfigManager().saveLookupConfigurations(lookupConfigList);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, ' saveLookupConfigurations() : Failed to save LookupConfigurations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveLookupConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse validateLookupConfiguration( final Adm.LookupConfig lookupConfig ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateLookupConfiguration() - enter; lookupConfig ' + lookupConfig );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_LookupConfigManager().validateLookupConfiguration(lookupConfig);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, ' validateLookupConfiguration() : Failed to validate LookupConfigurations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateLookupConfiguration() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}