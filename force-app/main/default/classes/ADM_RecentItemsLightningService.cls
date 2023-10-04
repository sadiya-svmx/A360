/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save Recent Items.
 *
 * @author Jyothsna N
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna N              15 Nov 2021     Created.
 *****************************************************************************************************/
public with sharing class ADM_RecentItemsLightningService {

    /**
     * This method fetches recent items details
     * from the Salesforce Org.
     * @return Returns instance of Common.ServiceResponse with recent items details.
     * @example getRecentItemsDetails();
     */
    @RemoteAction @AuraEnabled
    public static Object getRecentItemsDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getRecentItemsDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse = new ADM_RecentItemsService().getRecentItemsDetails();
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getRecentItemsDetails() : Failed to retrieve recent items. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getRecentItemsDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method performs recent items save.
     */
    @RemoteAction @AuraEnabled
    public static Object saveRecentItem(String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'saveRecentItem() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.RecentItemInfo recentItemsInfo = (Adm.RecentItemInfo) JSON.deserializeStrict( requestJson, Adm.RecentItemInfo.class );
            serviceResponse = new ADM_RecentItemsService().saveRecentItem(recentItemsInfo);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Failed to save recent items. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug( LoggingLevel.DEBUG, 'saveRecentItem() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return JSON.serialize(serviceResponse);
    } 
    
    /**
     * This method delete recent items.
     */
    @RemoteAction @AuraEnabled
    public static Common.ServiceResponse deleteRecentItemsDetails(String requestJson) {

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            List<Adm.RecentItemInfo> recentItemsInfo = (List<Adm.RecentItemInfo>) JSON.deserializeStrict( requestJson, List<Adm.RecentItemInfo>.class );
            ADM_RecentItemsManager.getInstance().deleteRecentItemsDetails(recentItemsInfo);
        
        } catch(Exception e) {
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug( LoggingLevel.DEBUG, 'deleteRecentItemsDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}