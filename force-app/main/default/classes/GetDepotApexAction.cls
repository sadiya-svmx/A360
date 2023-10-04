/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This provides a invocable method which can be used in Flows as Apex Action 
 * to get all the matching Depot Locations.
 * 
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       03 Sept 2020     Created.
 *****************************************************************************************************/

 global with sharing class GetDepotApexAction {

    @InvocableMethod(label='Find Depots' description='Find the matching location for the given source records.' category='Asset 360 Actions')
    global static List<DepotFinderResponse> getDepotLocations(List<DepotFinderRequest> lstReturnRequest){
        List<DepotFinderResponse> lstResponse = new List<DepotFinderResponse>();
        try {
            if (lstReturnRequest.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }
            lstResponse = (new DPOT_ManageDepotServiceImpl()).getDepotLocation(lstReturnRequest);
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception' + ex);
            throw ex;
            //log exception in Source record
        }
        return lstResponse;
    }
}