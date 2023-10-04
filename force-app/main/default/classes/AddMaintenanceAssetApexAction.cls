/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief An invocable apex action to Add Maintenance Assets to an existing Maintenance Plan.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID            Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-1254      Manish Kushwah          13 Sep 2021     Created.
 *****************************************************************************************************/
global with sharing class AddMaintenanceAssetApexAction {

    /**
     * This method is to add Maintenance Assets to a given Maintenance Plan Record.
     * 
     * @param AddMaintenanceAssetRequest Request for which we need to create Maintenance Assets to a given Maintenance Plan Record.
     * 
     * @return Returns AddMaintenanceAssetResponse which holds the created Maintenance Assets.
     */
    @InvocableMethod(label='Add Maintenance Assets' description='Apex action to add Maintenance Assets for a given Maintenance Plan' category='Asset 360 Actions')
    global static List<MaintenancePlanAssetData> addMaintenanceAssets( final List<MaintenancePlanAssetData> maintenancePlanAssetDataRequestList) {
        
        System.debug(LoggingLevel.DEBUG, 'addMaintenanceAssets - enter.  MaintenancePlanAssetData - '+ maintenancePlanAssetDataRequestList);

        List<MaintenancePlanAssetData> maintenancePlanAssetDataList = new List<MaintenancePlanAssetData>();

        try {
            if( maintenancePlanAssetDataRequestList == null || maintenancePlanAssetDataRequestList.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'addMaintenanceAssets() : Invalid request parameters. MaintenancePlanAssetData= ' + maintenancePlanAssetDataRequestList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            MaintenancePlanAssetData maintenancePlanAssetDataResponse = new MaintenancePlanAssetData();
            Common.ServiceResponse serviceResponse = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets(maintenancePlanAssetDataRequestList[0]);

            if ( !serviceResponse.success ) {
                throw new SvmxSystem.SvmxNestedException(serviceResponse.message);
            }

            maintenancePlanAssetDataResponse = (MaintenancePlanAssetData) serviceResponse.data;
            maintenancePlanAssetDataList.add(maintenancePlanAssetDataResponse);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'addMaintenanceAssets() : Failed to add Maintenance Assets for a given Maintenance Plan. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'addMaintenanceAssets() : Failed to add Maintenance Assets for a given Maintenance Plan. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'addMaintenanceAssets() - exit; maintenancePlanAssetDataList = ' + maintenancePlanAssetDataList );
        }

        return maintenancePlanAssetDataList;
    }
}