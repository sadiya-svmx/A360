/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete LookupConfigurations.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Aug 2020     Created.
 *****************************************************************************************************/
public with sharing class ADM_LookupConfigLightningService {

    @AuraEnabled
    public static Common.ServiceResponse getLookupConfigDetail( final String lookupConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getLookupConfigDetail() - enter; lookupConfigId= ' + lookupConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_LookupConfigService().getLookupConfigDetail( lookupConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigDetail() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getLookupConfigurations( final String objectName, final String headerObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - enter; objectName= ' + objectName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_LookupConfigService().getLookupConfigurations( objectName, headerObject );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse saveLookupConfig( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveLookupConfig() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.LookupConfig lookupConfig = (Adm.LookupConfig) JSON.deserializeStrict( requestJson, Adm.LookupConfig.class );
            serviceResponse = new ADM_LookupConfigService().saveLookupConfig( lookupConfig );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveLookupConfig() : Failed to save lookupconfig. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveLookupConfig() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteLookupConfig( final String lookupConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteLookupConfig() - enter; lookupConfigId= ' + lookupConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_LookupConfigService().deleteLookupConfig( lookupConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteLookupConfig() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}