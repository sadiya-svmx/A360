/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a trigger handler class for the Application_Event_Bus_Trigger. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID         Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-1167 Sandeep Dhariwal     	23 Aug 2021     Created.
 *****************************************************************************************************/
public with sharing class SCON_ApplicationEventBusTriggerHandler {

    /**
     * This method is used to publish application event bus platform events.
     *
     * @param pendingEvents Platform Events to be published.
     * @return void.
     */
    
    public static void publishPlatformEvents ( List<SVMXA360__ApplicationEventBus__e> pendingEvents ) {

        System.debug( LoggingLevel.DEBUG, 'publishPlatformEvents() - enter; pendingEvents= ' + pendingEvents + ' ; Start CPU Time = '+Limits.getCPUTime());

        try {

            List<SVMXA360__ApplicationEventBus__e> platformEvents = new List<SVMXA360__ApplicationEventBus__e>();

            for ( SVMXA360__ApplicationEventBus__e event : pendingEvents ) {

                SVMXA360__ApplicationEventBus__e servicemaxEvent = new SVMXA360__ApplicationEventBus__e();
                servicemaxEvent.Type__c = event.Type__c;
                servicemaxEvent.SVMXA360__SourceRecordId__c = event.SVMXA360__SourceRecordId__c;
                servicemaxEvent.SVMXA360__SourceObjectAPIName__c = event.SVMXA360__SourceObjectAPIName__c;
                servicemaxEvent.SVMXA360__Payload__c = event.SVMXA360__Payload__c;
                servicemaxEvent.SVMXA360__OperationType__c = event.SVMXA360__OperationType__c;
                servicemaxEvent.SVMXA360__UserId__c = event.SVMXA360__UserId__c;

                platformEvents.add(servicemaxEvent);

                if ( platformEvents.size() == 3 ) {
                    SCON_ServiceContractPlanHelper.publishPlatformEvents( platformEvents );
                    platformEvents.clear();
                }
            }

            if ( !platformEvents.isEmpty() ) {
                SCON_ServiceContractPlanHelper.publishPlatformEvents( platformEvents );
                platformEvents.clear();
            }

        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'publishPlatformEvents() : Failed to publish platform event. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'publishPlatformEvents() - exit; ' + ' End CPU Time = '+Limits.getCPUTime());
        }
    
    }
}