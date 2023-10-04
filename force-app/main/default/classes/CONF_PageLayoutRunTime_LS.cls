/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides aura enabled services for run time lightning web components
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                08 Dec 2020     Created.
 *****************************************************************************************************/
public with sharing class CONF_PageLayoutRunTime_LS {

   
    /**
     * This method fetches pagelayout details for the requested Id 
     * from the Salesforce Org.
     * @param String Id of the pagelayout to be fetched
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     * @example getPageLayoutDetails('<PageLayoutID>');
     */
    @AuraEnabled
    public static Object getPageLayoutDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            if(String.isBlank(requestJson)){
                System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Invalid request' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );                
            }
            boolean translationRequired = true;
            serviceResponse = new ADM_PageLayoutService().getPageLayoutDetails(requestJson, translationRequired);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches Record Type details by object name
     * from the Salesforce Org.
     * @param String object name to fetch record type details
     * @return Returns instance of Common.ServiceResponse with record type details for requested object name.
     */
    @AuraEnabled
    public static Object getRecordTypeDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            if(String.isBlank(requestJson)){
                System.debug( LoggingLevel.ERROR, 'getRecordTypeDetails() : Invalid request' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );                
            }
            serviceResponse = new ADM_PageLayoutService().getRecordTypeDetails(requestJson);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getRecordTypeDetails() : Failed to retrieve Record Type details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches Record Type details by object name
     * from the Salesforce Org.
     * @param String object name to fetch record type details
     * @return Returns instance of Common.ServiceResponse with record type details for requested object name.
     */
    @AuraEnabled
    public static Object getObjectRecordTypeDetails( final List<String> objectAPINames ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            if(objectAPINames == null || objectAPINames.size() == 0){
                System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeDetails() : Invalid request' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );                
            }
            serviceResponse = new ADM_PageLayoutService().getObjectRecordTypeDetails(objectAPINames);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeDetails() : Failed to retrieve Record Type details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches all the page layouts available in the
     * Salesforce Org.
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     * @example getAllPageLayouts();
     */
    @AuraEnabled
    public static Object getAllPageLayouts( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            boolean translationRequired = true;
            serviceResponse = new ADM_PageLayoutService().getAllPageLayouts(requestJson, translationRequired);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayouts() : Failed to retrieve List of Page Layouts. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }


    /**
     * This method is used to retrieve run time data for page layout configured.
     * 
     * @param requestJson Config.PageDataRequest wrapper with run time request information.
     */
    @AuraEnabled
    public static Common.ServiceResponse getPageData( final String requestJson ) {
                
        System.debug( LoggingLevel.DEBUG, 'getPageData() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
                
        try {
            
            Config.PageDataRequest pageDataRequest = (Config.PageDataRequest) JSON.deserializeStrict( requestJson, Config.PageDataRequest.class );
            Object data = new CONF_PageLayoutHandler().getPageData(pageDataRequest);
            serviceResponse.data = JSON.serialize(data);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageData() : Failed to retrieve run time page data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPageData() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

   /**
     * This method is used to retrieve child object record after applying mapping
     * 
     * @param requestJson Config.PageDataRequest wrapper with run time request information.
     */
    @AuraEnabled
    public static Common.ServiceResponse getNewChildRecord( final String requestJson ) {
                
        System.debug( LoggingLevel.DEBUG, 'getNewChildRecord() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
                
        try {
            
            Config.PageDataRequest pageDataRequest = (Config.PageDataRequest) JSON.deserializeStrict( requestJson, Config.PageDataRequest.class );
            serviceResponse.data = new CONF_PageLayoutHandler().getNewChildRecord(pageDataRequest);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getNewChildRecord() : Failed to retrieve run time page data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getNewChildRecord() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }  


        /**
     * This method is used to retrieve run time data for page layout configured.
     * 
     * @param requestJson Config.PageDataRequest wrapper with run time request information.
     */
    @AuraEnabled
    public static Common.ServiceResponse savePageData( final String requestJson ) {
                
        System.debug( LoggingLevel.DEBUG, 'savePageData() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
                
        try {
            
            Config.PageDataRequest pageDataRequest = (Config.PageDataRequest) JSON.deserializeStrict( requestJson, Config.PageDataRequest.class );
            object data = new CONF_PageLayoutHandler().savePageData(pageDataRequest);
            serviceResponse.data = JSON.serialize(data);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageData() : Failed to retrieve run time page data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePageData() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve run time data for page layout configured.
     * 
     * @param requestJson Config.PageDataRequest wrapper with run time request information.
     */
    @AuraEnabled
    public static Common.ServiceResponse sendToNewRelic( final String requestJson ) {
                
        System.debug( LoggingLevel.DEBUG, 'sendToNewRelic() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
                
        try {
            CONF_ApplicationMonitorManager.logUsage(requestJson);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageData() : Failed to retrieve run time page data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Internal server error
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePageData() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}