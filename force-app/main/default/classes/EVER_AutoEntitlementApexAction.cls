/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief An invocable apex action to perform auto entitlement.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       27 Jul 2020     Created.
 * A360CE-277   Ramachandra Mohan       23 Oct 2020     Updated code to support bulk records.
 *****************************************************************************************************/
global class EVER_AutoEntitlementApexAction {

    // Apply mapping request parameters
    global class AutoEntitlementRequest {
        
        @InvocableVariable(label='Source object one of (Case/WorkOrder/ReturnOrder)' description='Source object API name for which auto-entitlement check is to be performed.' required=true)
        global String sourceObject;
        
        @InvocableVariable(label='Source record ids' description='Source Object record for which auto-entitlement is to be performed.')
        global List<String> sourceRecordIds;
    }
    
    /**
     * This method is used to invoke apply mapping form Flow Apex Actions.
     * 
     * @param applyMappingRequestList Apply Mapping request parameters which includes object mapping Id, source object 
     * when mapping is of type field mapping and optional target object to be returned post apply mapping. 
     */
	@InvocableMethod(label='Perform Auto Entitlement' description='Apex action to perform auto-entitlement.' category='Asset 360 Actions')
    global static void performAutoEntitlement( final List<AutoEntitlementRequest> autoEntitlementRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'performAutoEntitlement() - enter; autoEntitlementRequest= ' + autoEntitlementRequest );
        
        try {
            
            if( !Test.isRunningTest() ) {
                // Check for valid apply mapping request.
                if( autoEntitlementRequest == null || autoEntitlementRequest.size() == 0 ) {
                    
                    System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Invalid request parameters. autoEntitlementRequest= ' + autoEntitlementRequest );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }
                
                final String sourceObject = autoEntitlementRequest.get(0).sourceObject;
                final List<String> sourceRecordIds = new List<String>();
                
                for( AutoEntitlementRequest request : autoEntitlementRequest ) {
                    
                    if( request.sourceRecordIds != null ) {
                        sourceRecordIds.addAll( request.sourceRecordIds );
                    }
                }
                
                // Check for valid apply mapping request.
                if( String.isBlank( sourceObject ) || sourceRecordIds == null || sourceRecordIds.size() == 0 ) {
                    
                    System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Invalid request parameters. sourceObject= ' + sourceObject +'; sourceRecordIds= ' + sourceRecordIds );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }
                
                new EVER_AutoEntitlementEngine(sourceObject).performAutoEntitlement(sourceRecordIds);
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Failed to perform entitlement check. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Failed to perform entitlement check. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'performAutoEntitlement() - exit' );
        }
    }
}