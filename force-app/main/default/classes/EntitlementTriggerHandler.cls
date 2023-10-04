public with sharing class EntitlementTriggerHandler {

    /**
     * This method is used to perform the check on Entitlement prior delete, to ensure there are no related CPLI records assosicated.*
     * @param oldMap Trigger.oldMap - Old map of Entitlement.
     * @return void.
     *
     */
    public static void preventDeletionRelatedES(Map<Id, Entitlement> oldMap) {
        System.debug( LoggingLevel.DEBUG, 'preventDeletionRelatedES() enter - oldMap: ' + oldMap);
        try {
            EVER_EntitledServiceManager.getInstance().deleteCheckOnES( oldMap.KeySet() );
        } catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDeletionRelatedES() : Failed to perform check on ES on deletion based on realted record. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'preventDeletionRelatedES() exit');
        }
    }
}