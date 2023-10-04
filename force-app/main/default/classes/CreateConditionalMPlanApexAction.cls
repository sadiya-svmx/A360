/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief An invocable apex action to create conditional maintenance Plan.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID            Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-2487      Sachin S                18 July 2023     Created.
 *****************************************************************************************************/
global with sharing class CreateConditionalMPlanApexAction {

    global class MaintenancePlanInfo {
        @InvocableVariable (label='Conditional Maintenanace Plan' description='The Asset360 Maintenance Plan to be created' required=true)
        global SVMXA360__SM_MaintenancePlan__c conditionalMPlanRecord;

        @InvocableVariable (label='Maintenance Asset Info' description='Maintenance Asset Info in JSON' required=true)
        global String maintenanceAssetsJSON;
    }

    /**
     * This method is to create Maintenance Plan, Maintenance Assets and Maintenance Work Rules for a given Source Record and Maintenance Plan Template Record.
     * 
     * @param CreateMaintenancePlanRequest Request for which we need to create Maintenance Plan, Maintenance Assets and Maintenance Work Rules.
     * 
     * @return Returns CreateMaintenancePlanResponse which holds the created Maintenance Plan.
     */
    @InvocableMethod(label='Create Conditional Maintenance Plan' description='Apex action to create Conditional Maintenance Plan for a given Source' category='Asset 360 Actions')
    global static List<String> createMaintenancePlan( List<MaintenancePlanInfo> maintenancePlanInfo ) {
        
        List<String> maintenancePlanIds = new List<String>();
        System.debug(LoggingLevel.INFO, 'createMaintenancePlan() - enter; maintenancePlanInfo= ' + maintenancePlanInfo );

        Savepoint sp = Database.setSavePoint();
        try {
            if (maintenancePlanInfo.isEmpty() || maintenancePlanInfo[0].conditionalMPlanRecord == null) {
                System.debug( LoggingLevel.ERROR, 'createMaintenancePlan() : Invalid arguments. request = ' + maintenancePlanInfo);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }     
            
            String newRecordId = new MPLN_ConditionBasedMPlanManager().saveMaintenancePlan(maintenancePlanInfo[0].conditionalMPlanRecord, maintenancePlanInfo[0].maintenanceAssetsJSON);
            maintenancePlanIds.add(newRecordId);
        }  
        catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'createMaintenancePlan() : Failed to create Maintenance Plan. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'createMaintenancePlan() - exit; maintenancePlanInfo = ' + maintenancePlanInfo );
        }  

        return maintenancePlanIds;
    }
}