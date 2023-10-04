/*****************************************************************************
 *                       Copyright (C) 2023 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/validate and save 
 * Maintenance Plan Process. 
 *
 * @author Ramachandra Mohan
 * @version 9.0
 * @since 2023
 */
public with sharing class ADM_MaintenanceProcessService extends ADM_AbstractMaintenanceProcessService {


    /**
    * Class constructor to create instance of this class. This constructor is 
    * invoked by lightning services.
    */
   public ADM_MaintenanceProcessService(){}
   
   /**
    * Class constructor to create instance of this class. This constructor is 
    * invoked by rest interfaces.
    */
   public ADM_MaintenanceProcessService( RestRequest request, RestResponse response ){
       super(request, response);
   }

   /**
    * This method is used to retrieve all Maintenace Plan Process from the Org.
    * 
    * @return Returns list of all Maintenace Plan Process.
    * 
    * @example GET /services/apexrest/SVMXA360/svmx/rest/admin/mpln/v1/getAllMaintenanceProcesses/
    */
    override public Common.ServiceResponse getAllMaintenanceProcesses(){
        System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceProcesses() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().getProcessList();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllMaintenanceProcesses() : Failed to retrieve Maintenance Plan Processes. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceProcesses() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
        
    }

    /**
    * This method is used to retrieve Maintenace Plan Process detail from the Org.
    * 
    * @param recordId MaintenacePlanProcess record id for which details to be retrieved.
    * @return Returns Maintenace Plan Process detail for requested record id.
    * 
    * @example GET /services/apexrest/SVMXA360/svmx/rest/admin/mpln/v1/getMaintenanceProcessDetail/
    */
    override public Common.ServiceResponse getMaintenanceProcessDetail( final String recordId  ) {
        
        System.debug( LoggingLevel.DEBUG, 'getMaintenanceProcessDetail() - enter; recordId= ' + recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().getProcessDetails( recordId );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getMaintenanceProcessDetail() : Failed to retrieve Maintenance Plan Process detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getMaintenanceProcessDetail() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

   /**
    * This method is used to save Maintenace Plan Process.
    * 
    * @param maintenacePlanProcess Adm.MaintenacePlanProcess instance to be saved.
    * 
    * @example POST /services/apexrest/SVMXA360/svmx/rest/admin/mpln/v1/saveMaintenanceProcess/
    */
    override public Common.ServiceResponse saveMaintenanceProcess( final Adm.MaintenancePlanProcessDetail maintenacePlanProcess ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveMaintenanceProcess() - enter; maintenacePlanProcess= ' + maintenacePlanProcess );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().saveProcessDetails( maintenacePlanProcess );
            serviceResponse.success = true;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveMaintenanceProcess() : Failed to save maintenace Plan Process. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveMaintenanceProcess() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse validateMaintenanceProcess( final Adm.MaintenaceProcessValidationRequest mplnValidationRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateMaintenanceProcess() - enter; mplnValidationRequest= ' + mplnValidationRequest );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_MaintenanceProcessManager.getInstance().validateMaintenanceProcess( mplnValidationRequest.maintenacePlanProcess, mplnValidationRequest.referenceDatas );
            serviceResponse.success = true;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateMaintenanceProcess() : Failed to save maintenace Plan Process. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateMaintenanceProcess() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}