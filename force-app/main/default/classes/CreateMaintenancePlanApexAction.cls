/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief An invocable apex action to create Maintenance Plan.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID            Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-572       Manish Kushwah          21 May 2021     Created.
 * A360AM-1254      Jaysukh Patel           18 Sep 2021     updated implimentation with new wrapper - MaintenancePlanData 
 *****************************************************************************************************/
global with sharing class CreateMaintenancePlanApexAction {

    /**
     * This method is to create Maintenance Plan, Maintenance Assets and Maintenance Work Rules for a given Source Record and Maintenance Plan Template Record.
     * 
     * @param CreateMaintenancePlanRequest Request for which we need to create Maintenance Plan, Maintenance Assets and Maintenance Work Rules.
     * 
     * @return Returns CreateMaintenancePlanResponse which holds the created Maintenance Plan.
     */
    @InvocableMethod(label='Create Maintenance Plan' description='Apex action to create Maintenance Plan for a given Source' category='Asset 360 Actions')
    global static List<MaintenancePlanData> createMaintenancePlan( final List<MaintenancePlanData> maintenancePlanDataList) {

        System.debug(LoggingLevel.DEBUG, 'createMaintenancePlan - enter.  maintenancePlanDataList - '+ maintenancePlanDataList);

        try{
            if( maintenancePlanDataList == null || maintenancePlanDataList.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'createMaintenancePlan() : Invalid request parameters. maintenancePlanDataList= ' + maintenancePlanDataList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            MaintenancePlan maintenancePlan = null;

            if (String.isBlank(maintenancePlanDataList[0].operationType) || maintenancePlanDataList[0].operationType.toUpperCase() == 'FOR-TEMPLATE') {

                Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
                request.sourceRecordId = maintenancePlanDataList[0].sourceRecordId;
                request.templateId = maintenancePlanDataList[0].maintenancePlanTemplateId;
                request.maintenancePlanRecord = maintenancePlanDataList[0].sourceMaintenancePlan;
                request.maintenanceAssetRecords = maintenancePlanDataList[0].sourceMaintenanceAssetList;

                maintenancePlan = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan( request );

            } else if (maintenancePlanDataList[0].operationType.toUpperCase() == 'FOR-PRODUCT') {

                MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
                maintenancePlanData.sourceRecordId = maintenancePlanDataList[0].sourceRecordId;
                maintenancePlanData.dateOfFirstWorkOrderInNextBatch = maintenancePlanDataList[0].dateOfFirstWorkOrderInNextBatch;
                maintenancePlanData.maintenancePlanTemplateProductId = maintenancePlanDataList[0].maintenancePlanTemplateProductId;
                maintenancePlanData.maintenancePlanTitle = maintenancePlanDataList[0].maintenancePlanTitle;
                maintenancePlanData.startDate = maintenancePlanDataList[0].startDate;
                maintenancePlanData.subscriptionFieldName = maintenancePlanDataList[0].subscriptionFieldName;
                maintenancePlanData.subscriptionId = maintenancePlanDataList[0].subscriptionId;

                Common.ServiceResponse serviceResponse = new MPLN_MaintenancePlanTemplateHandler().createMaintenancePlan(maintenancePlanData);

                if ( !serviceResponse.success ) {
                    throw new SvmxSystem.SvmxNestedException(serviceResponse.message);
                }

                maintenancePlanData = (MaintenancePlanData) serviceResponse.data;
                maintenancePlan = new MaintenancePlan(Id = maintenancePlanData.maintenancePlanId);
            }
            
            maintenancePlanDataList[0].maintenancePlanId = maintenancePlan.id;
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createMaintenancePlan() : Failed to Create Maintenance Plan for a given Source. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createMaintenancePlan() : Failed to Create Maintenance Plan for a given Source. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createMaintenancePlan() - exit; maintenancePlanDataList = ' + maintenancePlanDataList );
        }

        return maintenancePlanDataList;
    }
}