/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides Service layer for managing all the Settings related 
 * 		  to SPM Designer
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
public with sharing class ADM_SPMSettingsService {
	
    public Common.ServiceResponse saveSettingInfo( Adm.SPMSettingInfo sPMSetting ) {
    	System.debug( LoggingLevel.DEBUG, 'saveSettingInfo() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_SPMSettingsManager().saveSettingInfo( sPMSetting );
            System.debug( LoggingLevel.INFO, 'saveSettingInfo() : Debug settings saved successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveSettingInfo() : Failed to save Debug settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveSettingInfo() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    public Common.ServiceResponse retreiveSettingInfo( String settingName ) {
    	System.debug( LoggingLevel.DEBUG, 'retreiveSettingInfo() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_SPMSettingsManager().retreiveSettingInfo( settingName );
            System.debug( LoggingLevel.INFO, 'retreiveSettingInfo() : settings retreived successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retreiveSettingInfo() : Failed to retreive Debug settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retreiveSettingInfo() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}