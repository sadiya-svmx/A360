/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates aura enabled methods for creation and managing Maintenance plan process 
 * using custom LWC pages.
 * 
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                23 May 2023     Created.
 *****************************************************************************************************/
public with sharing class ADM_MaintenanceProcess_LS {
    
    @AuraEnabled
    public static Common.ServiceResponse getProcessList () {
        System.debug( LoggingLevel.DEBUG, 'getProcessList() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().getProcessList();

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProcessList() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessList() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;        
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteProcess (String processId) {
        System.debug( LoggingLevel.DEBUG, 'deleteProcess() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            ADM_MaintenanceProcessManager.getInstance().deleteProcess(processId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcess() : Failed to delete record. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcess() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;  
    }

    @AuraEnabled
    public static Common.ServiceResponse runProcessEngine (List<String> processIds) {
        System.debug( LoggingLevel.DEBUG, 'runProcessEngine() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            ADM_MaintenanceProcessManager.getInstance().runProcessEngine(processIds);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'runProcessEngine() : Failed to run engine. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'runProcessEngine() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;  
    }

    @AuraEnabled
    public static Common.ServiceResponse getSObjectSupportedQueues(String objectAPIName){
        System.debug( LoggingLevel.DEBUG, 'getSObjectSupportedQueues() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().getSObjectSupportedQueues(objectAPIName);
        } catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'getSObjectSupportedQueues() : Failed to retrieve Queues. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSObjectSupportedQueues() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse; 
    }

    @AuraEnabled
    public static Common.ServiceResponse getProcessDetails(String processId){
        System.debug( LoggingLevel.DEBUG, 'getProcessDetails() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().getProcessDetails(processId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProcessDetails() : Failed to retreive record. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;         
    }

    @AuraEnabled
    public static Common.ServiceResponse saveProcessDetails(String requestJson){
        System.debug( LoggingLevel.DEBUG, 'saveProcessDetails() - enter; requestJson= ' + requestJson );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            Adm.MaintenancePlanProcessDetail processDetail = (Adm.MaintenancePlanProcessDetail) JSON.deserializeStrict( requestJson, Adm.MaintenancePlanProcessDetail.class );
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().saveProcessDetails(processDetail);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessDetails() : Failed to save process record. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}