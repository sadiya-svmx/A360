/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief global service class for mainteanance plan service for CPQ use case
 * 
 *
 * @author Jaysukh Patel
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jaysukh Patel           25 Aug 2021    Created.
 * A360AM-1094  Jaysukh Patel           25 Aug 2021    addMaintenanceAssets service for CPQ use case
 * A360AM-1087  Manish Kushwah          26 Aug 2021    createMaintenancePlan service for CPQ 
 *****************************************************************************************************/
global with sharing class MaintenancePlanService {

    /**
     * This method creates MaintenancePlan and it's associated MaintenanceWorkRules 
     * for given MaintenancePlanTemplateProductId assocaited MaintenancePlanTemplate 
     */
    global static SvmxGlobal.SvmxResponse createMaintenancePlan(MaintenancePlanData maintenancePlanData) {
        return new MPLN_MaintenancePlanTemplateHandler().createMaintenancePlan(maintenancePlanData);
    }

    /**
     * This method creates MaintenanceAssets and it's associated MaintenanceWorkRules for 
     * given maintenancePlan and asset and based on associated MaintenancePlan Template creteria
     */
    global static SvmxGlobal.SvmxResponse addMaintenanceAssets(MaintenancePlanAssetData maintenancePlanAssetData) {
        return new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets(maintenancePlanAssetData);
    }
}