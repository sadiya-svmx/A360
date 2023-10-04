/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete Pagelayouts.
 *
 * @author Jyothsna N
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna N              15 Nov 2020     Created.
 *****************************************************************************************************/
public with sharing class ADM_RecentItemsService {

    public ADM_RecentItemsService(){}
    
    /**
     * This method fetches recent item details.
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with recent items details for requested id.
     */
    public Common.ServiceResponse getRecentItemsDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getRecentItemsDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_RecentItemsServiceImpl().getRecentItemsDetails();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getRecentItemsDetails() : Failed to retrieve recent items. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecentItemsDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }  

    /**
     * This method saves recent items info
     */
    public Common.ServiceResponse saveRecentItem(Adm.RecentItemInfo recentItemInfo) {
        System.debug( LoggingLevel.DEBUG, 'saveRecentItem() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_RecentItemsServiceImpl().saveRecentItem(recentItemInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Failed to save recent items. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveRecentItem() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }
}