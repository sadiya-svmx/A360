/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/edit/save/delete Match Rules.
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Mahima Tarika      30 Aug 2022      Created.
 *****************************************************************************************************/
public with sharing class ADM_ApplicationSettings_LS {
    /**
     * This method retrieves application Setting record
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with application setting record.
     */
    @AuraEnabled
    public static Common.ServiceResponse  getApplicationSetting (string developerName) {
        System.debug( LoggingLevel.DEBUG, 'getApplicationSettingRec() - enter; developerName='+developerName);
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_ApplicationSettingsManager.getInstance().getApplicationSetting(developerName);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getApplicationSetting() : Failed to get Match rules. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getApplicationSettingRec() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves application Setting record
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with success msg.
     */
    @AuraEnabled
    public static Common.ServiceResponse  saveApplicationSettingRecord (string jsonRequest) {
        System.debug( LoggingLevel.DEBUG, 'saveApplicationSettingRecord() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.ApplicationSetting wrapperRecord = (Adm.ApplicationSetting)JSON.deserializeStrict( jsonRequest, Adm.ApplicationSetting.class );
            serviceResponse.data = ADM_ApplicationSettingsManager.getInstance().saveApplicationSetting(wrapperRecord);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveApplicationSettingRecord() : Failed to get Match rules. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveApplicationSettingRecord() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }


}