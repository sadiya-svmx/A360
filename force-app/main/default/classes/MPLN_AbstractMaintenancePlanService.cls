/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for Maintenance Plan service implementation.
 * Also provides implementation for invokeMethod which maps to the requested mpln service implementation. 
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah      30 Nov 2021     Created.
 *****************************************************************************************************/
public abstract class MPLN_AbstractMaintenancePlanService extends COMM_SvmxRestBase {
    
    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public MPLN_AbstractMaintenancePlanService() {
    }

    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected MPLN_AbstractMaintenancePlanService(RestRequest req, RestResponse res) {
        super(req, res, 'mpln');
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

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'createMaintenancePlan' {                
                    response = createMaintenancePlan( (MaintenancePlanData) deserializeRequestTo( MaintenancePlanData.class ) );
                }
                when 'addMaintenanceAssets' {                
                    response = addMaintenanceAssets( (MaintenancePlanAssetData) deserializeRequestTo( MaintenancePlanAssetData.class ) );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }

    /**
     *   This method creates Maintenance Plan and its associated Maintenance Work Rule
     *   for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/mpln/v1/createMaintenancePlan/
     */
    public abstract Common.ServiceResponse createMaintenancePlan( final MaintenancePlanData maintenancePlanData );

    /**
     *   This method creates Maintenance Assets for a given list of assets. This also creates the Maintenance 
     *   Work Rules associated to the Maintenance Assets if applicable.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/mpln/v1/addMaintenanceAssets/
     */
    public abstract Common.ServiceResponse addMaintenanceAssets( final MaintenancePlanAssetData maintenancePlanAssetData );
}