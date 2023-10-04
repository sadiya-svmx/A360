/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is used to update entitlement service usage.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       21 Dec 2020     Created.
 *****************************************************************************************************/
public with sharing class EVER_EntitledServiceUsage {
    
    private static final String DEFAULT_METHOD_OTHER = 'Other';
    
    /**
     * This method is used to increase/decrease an entitled service usage.
     * 
     * @serviceUsageInfo Entitlement service usage information to be updated.
     */
    public void updateConsumedUsage( final Ever.ServiceUsageInfo serviceUsageInfo ) {
        updateConsumedUsageInternal( new List<Ever.ServiceUsageInfo> {serviceUsageInfo}, DEFAULT_METHOD_OTHER );
    }
    
    /**
     * This method is used to increase/decrease an entitled service usage.
     * 
     * @serviceUsageInfo Entitlement service usage information to be updated.
     */
    public void updateConsumedUsage( final Ever.ServiceUsageInfo serviceUsageInfo, final String method ) {
        updateConsumedUsageInternal( new List<Ever.ServiceUsageInfo> {serviceUsageInfo}, method );
    }
    
    /**
     * This method is used to increase/decrease the list of entitled service usages.
     * 
     * @serviceUsageInfoList List of Entitlement service usage information to be updated.
     */
    public void updateConsumedUsage( final List<Ever.ServiceUsageInfo> serviceUsageInfoList ) {
        updateConsumedUsageInternal( serviceUsageInfoList, DEFAULT_METHOD_OTHER );
    }
    
    /**
     * This method is used to increase/decrease the list of entitled service usages.
     * 
     * @serviceUsageInfoList List of Entitlement service usage information to be updated.
     */
    public void updateConsumedUsage( final List<Ever.ServiceUsageInfo> serviceUsageInfoList, final String method ) {
        updateConsumedUsageInternal( serviceUsageInfoList, method );
    }
    
    /**
     * This method is used to increase/decrease the list of entitled service usages.
     * 
     * @serviceUsageInfoList List of Entitlement service usage information to be updated.
     */
    private void updateConsumedUsageInternal( final List<Ever.ServiceUsageInfo> serviceUsageInfoList, final String method ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateConsumedUsageInternal() - enter' );
        
        try {
            // Verify for valid entitlement service record id.
            if( serviceUsageInfoList == null || serviceUsageInfoList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'updateConsumedUsageInternal() : Invalid arguments. serviceUsageRequestList=' + serviceUsageInfoList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );  
            }
            
            final List<String> entitlementIds = new List<String>();
            final Map<String, Ever.ServiceUsageInfo> serviceUsageInfoMap = new Map<String, Ever.ServiceUsageInfo>();
            
            // Get entitlement service ids
            for( Ever.ServiceUsageInfo serviceUsageInfo : serviceUsageInfoList ) {
                
                entitlementIds.add( serviceUsageInfo.entitledServiceId );
                serviceUsageInfoMap.put( serviceUsageInfo.entitledServiceId, serviceUsageInfo );
            }
            
            // Retrieve entitlement service record for requested entitlement id.
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<Entitlement> entitlementRecordList = (List<Entitlement>) SvmxDatabase.query( [SELECT Id, SVMXA360__ConsumedServiceCount__c, SVMXA360__ConsumedServiceAmount__c, SVMXA360__ServiceCountType__c FROM Entitlement WHERE Id IN :entitlementIds ]);
            if( entitlementRecordList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'updateConsumedUsageInternal() : Record not exists. entitlementRecordList=' + entitlementRecordList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS ); 
            }
            
            List<SVMXA360__EntitledServiceHistory__c> entitledServiceHistoryList = new List<SVMXA360__EntitledServiceHistory__c>();
            
            for( Entitlement entitlementRecord : entitlementRecordList ) {
                
                if( !DEFAULT_METHOD_OTHER.equalsIgnoreCase(method) && ( String.isBlank( entitlementRecord.SVMXA360__ServiceCountType__c ) || !entitlementRecord.SVMXA360__ServiceCountType__c.equalsIgnoreCase('Visits') ) ) {
                    continue;
                }
                
                Ever.ServiceUsageInfo serviceUsageInfo = serviceUsageInfoMap.get( entitlementRecord.Id );
                entitlementRecord.SVMXA360__ConsumedServiceCount__c = (entitlementRecord.SVMXA360__ConsumedServiceCount__c == null ) ? 0 : entitlementRecord.SVMXA360__ConsumedServiceCount__c;
                entitlementRecord.SVMXA360__ConsumedServiceAmount__c = (entitlementRecord.SVMXA360__ConsumedServiceAmount__c == null ) ? 0 : entitlementRecord.SVMXA360__ConsumedServiceAmount__c;
                
                SVMXA360__EntitledServiceHistory__c entitledServiceHistory = createEntitledServiceHistory( serviceUsageInfo, method );
                
                // Populate service usage field for requested unit.
                switch on serviceUsageInfo.serviceUnit {
                    
                    // Update service count field for count unit.
                    when Count {
                        
                        if( serviceUsageInfo.serviceOperation == Ever.ServiceOperation.Increment ) {
                            entitlementRecord.SVMXA360__ConsumedServiceCount__c -= serviceUsageInfo.serviceValue;
                        }
                        
                        if( serviceUsageInfo.serviceOperation == Ever.ServiceOperation.Decrement ) {
                            entitlementRecord.SVMXA360__ConsumedServiceCount__c += serviceUsageInfo.serviceValue;
                        }
                    }
                    
                    // Update service amount field for amount unit.
                    when Amount {
                        
                        if( serviceUsageInfo.serviceOperation == Ever.ServiceOperation.Increment ) {
                            entitlementRecord.SVMXA360__ConsumedServiceAmount__c -= serviceUsageInfo.serviceValue;
                        }
                        
                        if( serviceUsageInfo.serviceOperation == Ever.ServiceOperation.Decrement ) {
                            entitlementRecord.SVMXA360__ConsumedServiceAmount__c += serviceUsageInfo.serviceValue;
                        }
                    }
                }
                entitledServiceHistoryList.add(entitledServiceHistory);
            }
            
            // Update service usage.
            SvmxDatabase.updateRecord(entitlementRecordList);
            
            // Insert service usage in entitled service history.
            if( !entitledServiceHistoryList.isEmpty() ) {
                SvmxDatabase.insertRecord(entitledServiceHistoryList);
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConsumedUsageInternal() : Failed to update entitlement service usage. Error' + e.getStackTraceString() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConsumedUsageInternal() : Failed to update entitlement service usage. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateConsumedUsageInternal() - exit' );
        }
    }
    
    /**
     * This method is used to create entitled service history upon increment/decrement of  entitled service usages.
     * 
     * @serviceUsageInfo Entitlement service usage information to be tracked in Audit table of Entitled Service History.
     */
    private SVMXA360__EntitledServiceHistory__c createEntitledServiceHistory( final Ever.ServiceUsageInfo serviceUsageInfo, final String method ) { 
        
        System.debug( LoggingLevel.DEBUG, 'createEntitledServiceHistory() - enter' );
        
        SVMXA360__EntitledServiceHistory__c entitledServiceHistory = new SVMXA360__EntitledServiceHistory__c();
        try {
        
            entitledServiceHistory.SVMXA360__EntitledServiceId__c = serviceUsageInfo.entitledServiceId;
            entitledServiceHistory.SVMXA360__EntitlementVerificationHistoryId__c = serviceUsageInfo.entitlementHistoryId;
            entitledServiceHistory.SVMXA360__Method__c = method;
            entitledServiceHistory.SVMXA360__ServiceCount__c = serviceUsageInfo.serviceValue;
            entitledServiceHistory.SVMXA360__Action__c = serviceUsageInfo.serviceOperation.name();
            if (String.isNotBlank(serviceUsageInfo.sourceRecordId)) {
                Id sourceRecordId = (Id)serviceUsageInfo.sourceRecordId;
                String sObjectType = String.valueOf( sourceRecordId.getSObjectType() );
                if (sObjectType  == String.valueOf(Case.getSObjectType()) ) {
                    entitledServiceHistory.SVMXA360__CaseId__c = sourceRecordId;
                } else if (sObjectType == String.valueOf(WorkOrder.getSObjectType()) ) { 
                    entitledServiceHistory.SVMXA360__WorkOrderId__c = sourceRecordId;
                } else {
                    entitledServiceHistory.SVMXA360__ReturnOrderId__c = sourceRecordId;
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createEntitledServiceHistory() : Failed to update entitlement service usage. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createEntitledServiceHistory() - exit' );
        }
        
        
        return entitledServiceHistory;
    }
}