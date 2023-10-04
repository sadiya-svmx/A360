/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This provides a invocable method which can be used in Flows as Apex Action 
 * to update Depot Locations into Source records. 
 * 
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       10 Aug 2020     Created.
 *****************************************************************************************************/
global with sharing class FindAndUpdateDepotApexAction {

    @InvocableVariable(label='Source records' description='These source records would get updated based on the result of Depot Finder engine which finds the matching Depot Locations.')
    global List<SObject> lstSourceRecords;
    
    @invocableMethod(label='Find and Update Depot' description='Find the matching location and update it in the given source records.' category='Asset 360 Actions')
    global static void updateDepotLocation(List<SObject> lstInputParams){
        try {
            DPOT_ManageDepotService manageDepot = new DPOT_ManageDepotService();
            if (lstInputParams.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }
            manageDepot.updateSourceWithDepotLocation(lstInputParams);
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception' + ex);
            throw ex;
            //log exception in Source record
        }
    }
}