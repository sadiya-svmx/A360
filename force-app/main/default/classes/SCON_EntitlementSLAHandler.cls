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
public with sharing class SCON_EntitlementSLAHandler {

    /**
     * Private static variable to hold instance of Case object Label.
     */
    private static final String CASE_LABEL = COMM_DescribeManager.getInstance().getObjectDescribe('Case').getLabel();

    /**
     * Private static variable to hold instance of Work Order object Label.
     */
    private static final String WORKORDER_LABEL = COMM_DescribeManager.getInstance().getObjectDescribe('WorkOrder').getLabel();

    public SCON_EntitlementSLAHandler(){}

    /**
     * This method is to get the cloned records for SLA entitlement.
     * 
     * @param entitlementList Entitlement records that needs to be cloned.
     * @param entitlementType Case Entitlement type or Work Order Entitlement type.
     * @param slaRecordTypeId SLA record type id.
     * 
     * @return Returns list of cloned SLA entitlement record.
     */
    public List<Entitlement> getSLAEntitlementCloneList( final List<Entitlement> entitlementList, final String entitlementType, final String slaRecordTypeId ) {
        
        System.debug( LoggingLevel.Debug, 'getSLAEntitlementCloneList() - enter' );
        System.debug( LoggingLevel.Debug, 'entitlementList - ' + entitlementList );
        System.debug( LoggingLevel.Debug, 'entitlementType - ' + entitlementType );
        System.debug( LoggingLevel.Debug, 'slaRecordTypeId - ' + slaRecordTypeId );

        List<Entitlement> resultEntitlementList = new List<Entitlement>();

        try{
    
            if( entitlementList != null && String.isNotBlank(entitlementType) && String.isNotBlank(slaRecordTypeId) ) {
                
                String caseApiName = String.valueOf( Case.getSObjectType() );
                String workOrderApiName = String.valueOf( WorkOrder.getSObjectType() );

                for(Entitlement entitlementRecord : entitlementList){
                    resultEntitlementList.add(getSLAEntitlementCloneRecord(entitlementRecord, entitlementType, slaRecordTypeId));
                }
            }
            else{
                System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneList() : Missing request parameters. entitlementList = ' + entitlementList + ' , entitlementType = ' + entitlementType + ' , slaRecordTypeId ' + slaRecordTypeId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneList() : Failed to clone SLA entitled records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneList() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.Debug, 'getSLAEntitlementCloneList() - Exit. resultEntitlementList ' + resultEntitlementList );
        }

        return resultEntitlementList;
    }

    /**
     * This method is to get the cloned record for SLA entitlement.
     * 
     * @param entitlementRecord Entitlement record that needs to be cloned.
     * 
     * @return Returns cloned SLA entitlement record.
     */
    private Entitlement getSLAEntitlementCloneRecord( final Entitlement entitlementRecord, final String entitlementType, final String slaRecordTypeId ){

        System.debug( LoggingLevel.Debug, 'getSLAEntitlementCloneRecord() - Exit. entitlementRecord ' + entitlementRecord );

        Entitlement newEntitlementSLARecord = new Entitlement();

        try{

            if(entitlementRecord != null){

                if( String.valueOf( Case.getSObjectType() ).equalsIgnoreCase( entitlementType ) ) {
                    newEntitlementSLARecord.Name = entitlementRecord.Name + ' - ' + CASE_LABEL;
                    newEntitlementSLARecord.SlaProcessId = entitlementRecord.SVMXA360__CaseEntitlementProcessId__c;
                } else if( String.valueOf( WorkOrder.getSObjectType() ).equalsIgnoreCase( entitlementType ) ) {
                    newEntitlementSLARecord.Name = entitlementRecord.Name + ' - ' + WORKORDER_LABEL;
                    newEntitlementSLARecord.SlaProcessId = entitlementRecord.SVMXA360__WorkOrderEntitlementProcessId__c;
                }

                newEntitlementSLARecord.RecordTypeId = slaRecordTypeId;
                
                newEntitlementSLARecord.AccountId = entitlementRecord.AccountId;
                newEntitlementSLARecord.AssetId = entitlementRecord.AssetId;
                newEntitlementSLARecord.AssetWarrantyId = entitlementRecord.AssetWarrantyId;
                newEntitlementSLARecord.BusinessHoursId = entitlementRecord.BusinessHoursId;
                newEntitlementSLARecord.CasesPerEntitlement = entitlementRecord.CasesPerEntitlement;
                newEntitlementSLARecord.SVMXA360__ConsumedServiceAmount__c = entitlementRecord.SVMXA360__ConsumedServiceAmount__c;
                newEntitlementSLARecord.SVMXA360__ConsumedServiceCount__c = entitlementRecord.SVMXA360__ConsumedServiceCount__c;
                newEntitlementSLARecord.ContractLineItemId = entitlementRecord.ContractLineItemId;
                newEntitlementSLARecord.EndDate = entitlementRecord.EndDate;
                newEntitlementSLARecord.SVMXA360__EntitledServiceProductId__c = entitlementRecord.SVMXA360__EntitledServiceProductId__c;
                newEntitlementSLARecord.SVMXA360__EntitledServiceId__c = entitlementRecord.Id;
                newEntitlementSLARecord.IsPerIncident = entitlementRecord.IsPerIncident;
                newEntitlementSLARecord.LocationId = entitlementRecord.LocationId;
                newEntitlementSLARecord.RemainingCases = entitlementRecord.RemainingCases;
                newEntitlementSLARecord.RemainingWorkOrders = entitlementRecord.RemainingWorkOrders;
                newEntitlementSLARecord.SVMXA360__ServiceAmountAlertThreshold__c = entitlementRecord.SVMXA360__ServiceAmountAlertThreshold__c;
                newEntitlementSLARecord.ServiceContractId = entitlementRecord.ServiceContractId;
                newEntitlementSLARecord.SVMXA360__ServiceCountAlertThreshold__c = entitlementRecord.SVMXA360__ServiceCountAlertThreshold__c;
                newEntitlementSLARecord.SVMXA360__ServiceCountType__c = entitlementRecord.SVMXA360__ServiceCountType__c;
                newEntitlementSLARecord.StartDate = entitlementRecord.StartDate;
                newEntitlementSLARecord.SvcApptBookingWindowsId = entitlementRecord.SvcApptBookingWindowsId;
                newEntitlementSLARecord.SVMXA360__TotalServiceAmount__c = entitlementRecord.SVMXA360__TotalServiceAmount__c;
                newEntitlementSLARecord.SVMXA360__TotalServiceCount__c = entitlementRecord.SVMXA360__TotalServiceCount__c;
                newEntitlementSLARecord.Type = entitlementRecord.Type;
                newEntitlementSLARecord.WorkOrdersPerEntitlement = entitlementRecord.WorkOrdersPerEntitlement;

            }
            else{
                System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneRecord() : Missing request parameter. entitlementRecord= ' + entitlementRecord );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneRecord() : Failed to clone SLA entitled records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSLAEntitlementCloneRecord() : Failed to perform apply mapping. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.Debug, 'getSLAEntitlementCloneRecord() - Exit. newEntitlementSLARecord ' + newEntitlementSLARecord );
        }

        return newEntitlementSLARecord;
    }
}