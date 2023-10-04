/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides services to create Maintenance Plan and its related records.
 * 
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
public with sharing class MPLN_MaintenancePlanService extends MPLN_AbstractMaintenancePlanService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public MPLN_MaintenancePlanService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public MPLN_MaintenancePlanService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method creates Maintenance Plan and its associated Maintenance Work Rule
     * 
     * @param MaintenancePlanData Maintenance Plan wrapper instance to be created.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful of create Maintenance Plan, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse createMaintenancePlan(MaintenancePlanData maintenancePlanData){  
        
        System.debug( LoggingLevel.DEBUG, 'createMaintenancePlan() - enter' );
        
        return new MPLN_MaintenancePlanTemplateHandler().createMaintenancePlan(maintenancePlanData);
    }

    /**
     * This method creates Maintenance Assets for a given list of assets. This also creates the Maintenance
     * Work Rules associated to the Maintenance Assets if applicable.
     * 
     * @param MaintenancePlanAssetData Maintenance Assets wrapper instance to be created.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful of create Maintenance Assets, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse addMaintenanceAssets(MaintenancePlanAssetData maintenancePlanAssetData){  
        
        System.debug( LoggingLevel.DEBUG, 'addMaintenanceAssets() - enter' );
        
        return new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets(maintenancePlanAssetData);
    }
}