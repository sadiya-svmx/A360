/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief An invocable apex action to clone Case and Work Order SLA Entitlement records.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni           12 Feb 2021       Created.
 *****************************************************************************************************/
global with sharing class CreateSLAApexAction {

    global class CreateSLARequest {
        @InvocableVariable(label='Entitlement Type' description='SLA Entitlement type' required=true)
        global String entitlementType;

        @InvocableVariable(label='Source Records' description='Source SObject record from which fields to be mapped.' required=true)
        global List<SObject> sourceSObjectList;

        @InvocableVariable(label='SLA Record Type Id' description='SLA record type id' required=true)
        global String slaRecordTypeId;
    }

    global class CreateSLAResponse {
        
        @InvocableVariable(label='Target SObject Records After Mapping' description='Target SObject with populated field values.' required=true)
        global List<SObject> targetSObjectList;
    }

    /**
     * This method is to get cloned list of SLA entitled records from Entielement records.
     * 
     * @param List<CreateSLARequest> Entitlement records for which we need to create Entitled SLA records.
     * 
     * @return Returns list of CreateSLAResponse which holds the cloned records.
     */
    @InvocableMethod(label='Perform SLA record clone' description='Apex action to clone entitled records.' category='Asset 360 Actions')
    global static List<CreateSLAResponse> performSLAEntitlementClone( final List<CreateSLARequest> cloneRequestList ) {
        System.debug(LoggingLevel.DEBUG, 'performSLAEntitlementClone - enter.  cloneRequestList - '+ cloneRequestList);

        List<CreateSLAResponse> cloneResponseList;

        try{
            if( cloneRequestList == null || cloneRequestList.size() == 0 ) {
                                            
                System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneList() : Invalid request parameters. cloneRequestList= ' + cloneRequestList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            CreateSLAApexAction.CreateSLAResponse cloneResponse;
            cloneResponseList = new List<CreateSLAApexAction.CreateSLAResponse>();

            for(CreateSLAApexAction.CreateSLARequest cloneRequest : cloneRequestList){
                cloneResponse = new CreateSLAApexAction.CreateSLAResponse();
                cloneResponse.targetSObjectList = new SCON_EntitlementSLAHandler().getSLAEntitlementCloneList( (List<Entitlement>)cloneRequest.sourceSObjectList, cloneRequest.entitlementType, cloneRequest.slaRecordTypeId);
                cloneResponseList.add(cloneResponse);
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performSLAEntitlementClone() : Failed to clone SLA entitled records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'performSLAEntitlementClone() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'performSLAEntitlementClone() - exit; cloneResponseList= ' + cloneResponseList );
        }

        return cloneResponseList;
    }

}