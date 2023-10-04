/*****************************************************************************
 *                       Copyright (C) 2023 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for Maintenance Plan Process
 * service implementation. 
 *
 * @author Ramachandra Mohan
 * @version 9.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       25 Aug 2023     Created.
 *****************************************************************************************************/
public abstract class ADM_AbstractMaintenanceProcessService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public ADM_AbstractMaintenanceProcessService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected ADM_AbstractMaintenanceProcessService( RestRequest request, RestResponse response ) {
        super( request, response, 'mpln' );    
    }
    
    /**
     * Override method invoked by base rest class with requested method.
     * 
     * @param methodName Method name from the request URL.
     * 
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            // Invoke service for requested method name.
            switch on methodName {
                
                when 'getAllMaintenancePlanProcesses' {
                    serviceResponse = getAllMaintenanceProcesses();
                }

                when 'getMaintenancePlanProcessDetail' {
                    serviceResponse = getMaintenanceProcessDetail(recordId);
                }
                
                when 'saveMaintenancePlanProcess' {
                    serviceResponse = saveMaintenanceProcess( (Adm.MaintenancePlanProcessDetail) deserializeRequestTo( Adm.MaintenancePlanProcessDetail.class ) );
                }
                
                when 'validateMaintenancePlanProcess' {
                    serviceResponse = validateMaintenanceProcess( (Adm.MaintenaceProcessValidationRequest) deserializeRequestTo( Adm.MaintenaceProcessValidationRequest.class ) );
                }
                
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    public abstract Common.ServiceResponse getAllMaintenanceProcesses();
    public abstract Common.ServiceResponse getMaintenanceProcessDetail( final String recordId );
    public abstract Common.ServiceResponse saveMaintenanceProcess( final Adm.MaintenancePlanProcessDetail maintenacePlanProcess );
    public abstract Common.ServiceResponse validateMaintenanceProcess( final Adm.MaintenaceProcessValidationRequest mplnValidationRequest );
}