/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This trigger processes application event bus event. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID           Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-1167  Sandeep Dhariwal        20 Aug 2021       Created.
 *****************************************************************************************************/

trigger ApplicationEventBus_Trigger1 on SVMXA360__ApplicationEventBus__e (after insert) {

    SVMXA360__ApplicationEventBus__e event = Trigger.New[0];
    List<SVMXA360__ApplicationEventBus__e> pendingEvents = new List<SVMXA360__ApplicationEventBus__e>();

    if ( Trigger.New.size() > 1 ) {

        for (Integer i=1; i<Trigger.New.size(); i++) {
            pendingEvents.add(Trigger.New[i]);
        }
    }

    try {
        
        if (event.Type__c == 'MPLNAuthoring') {

            new MPLN_MaintenancePlanTemplateHandler(true).authorMaintenancePlan(event);

        } else {
            Scon.platformEventRequest eventRequest = (Scon.PlatformEventRequest) JSON.deserializeStrict( event.SVMXA360__Payload__c, Scon.PlatformEventRequest.class );

            if ( event.SVMXA360__OperationType__c == 'Delete' ) {
                new SCON_ServiceContractPlanHandler().deleteServiceContractCoverages( eventRequest.recordIds, event.SVMXA360__UserId__c, 
                                                                                      eventRequest.parentSCONLogRecordId, 
                                                                                      eventRequest.serviceContractId);
            }
            else {
                new SCON_ServiceContractPlanHandler().createContractLineItems( eventRequest.assetServiceContractPlanIdMap, true, 
                                                                            eventRequest.serviceContractPlanId, 
                                                                            eventRequest.serviceContractRecord, 
                                                                            event.SVMXA360__UserId__c, 
                                                                            eventRequest.parentSCONLogRecordId);
            }
        }

        if ( !pendingEvents.isEmpty() ) {
            SCON_ApplicationEventBusTriggerHandler.publishPlatformEvents(pendingEvents);
        }
    }
    catch( SvmxSystem.SvmxNestedException e ) {

        if (event.Type__c == 'MPLNAuthoring') {
            MPLN_AuthoringLogManager.getInstance().createFailureLog(event, e.getMessage());
        }

        if ( !pendingEvents.isEmpty() ) {
            SCON_ApplicationEventBusTriggerHandler.publishPlatformEvents(pendingEvents);
        }

        System.debug( LoggingLevel.ERROR, 'ApplicationEventBus_Trigger1() : Failed to execute ApplicationEventBus_Trigger1. Error= ' + e.getMessage() );
        throw e;
    }
    catch( Exception e ) {

        if (event.Type__c == 'MPLNAuthoring') {
           MPLN_AuthoringLogManager.getInstance().createFailureLog(event, e.getMessage());
        }

        if ( !pendingEvents.isEmpty() ) {
            SCON_ApplicationEventBusTriggerHandler.publishPlatformEvents(pendingEvents);
        }
        
        System.debug( LoggingLevel.ERROR, 'ApplicationEventBus_Trigger1() : Failed to execute ApplicationEventBus_Trigger1. Error= ' + e.getMessage() );
        throw e;
    }
    finally {
        System.debug( LoggingLevel.DEBUG, 'ApplicationEventBus_Trigger1() - exit;');
    }

}