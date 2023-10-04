public with sharing class ContractLineItemTriggerHandler {

    /**
     * This method is used to perform the check on Contract Line Item prior delete, to ensure there are no related ES or CPLI records assosicated.*
     * @param oldMap Trigger.oldMap - Old map of Contract Line Item.
     * @return void.
     *
     */
    public static void preventDeletionRelatedCLI(Map<Id, ContractLineItem> oldMap) {
        System.debug( LoggingLevel.DEBUG, 'preventDeletionRelatedCLI() enter - oldMap: ' + oldMap);
        try {
            CLI_ContractLinesHandler.getInstance().deleteCheckOnCLI( oldMap.KeySet() );
        } catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDeletionRelatedCLI() : Failed to perform check on CLI on deletion based on realted record. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'preventDeletionRelatedCLI() exit');
        }
    }
}