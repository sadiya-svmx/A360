/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all Entitlement modules.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       09 Jul 2020     Created.
 *              Sandeep Dhariwal        30 Dec 2020     A360CE-398
 *****************************************************************************************************/
public with sharing class Ever {

    /**
     * Static string const to hold verification mode auto entitlement.
     */
    public static final String VERIFICATION_MODE_AUTO       = 'Auto';

    /**
     * Static string const to hold verification mode manual entitlement.
     */
    public static final String VERIFICATION_MODE_MANUAL     = 'Manual';

    /**
     * Static string const to hold source record Asset field name.
     */
    public final static String AssetIdField                 = 'AssetId';

    /**
     * Static string const to hold source record Asset field name for return order.
     */
    public final static String ReturnOrderAssetIdField      = 'SVMXA360__AssetId__c';

    /**
     * Static string const to hold source record Account field name.
     */
    public final static String AccountIdField               = 'AccountId';

    /**
     * Static string const to hold source record Contact field name.
     */
    public final static String ContactIdField               = 'ContactId';

    /**
     * Static string const to hold source record Entitlement lookup field name.
     */
    public final static String EntitlementIdField           = 'EntitlementId';

    /**
     * Static string const to hold source record Entitlement lookup field name.
     */
    public final static String ReturnOrderEntitlementIdField            = 'SVMXA360__EntitlementId__c';

    /**
     * Static string const to hold source record Entitlement Date field name.
     */
    public final static String EntitlementDateField         = 'SVMXA360__EntitlementDate__c';

    /**
     * Static string const to hold source record is entitlement performed checkbox field name.
     */
    public final static String IsEntitlementPerformedField  = 'SVMXA360__IsEntitlementPerformed__c';

    /**
     * Static string const to hold source record Perform auto entitlement checkbox field name.
     */
    public final static String PerformAutoEntitlementField  = 'SVMXA360__PerformAutoEntitlement__c';

    /**
     * Static string const to hold source record Entitlement Notes field name.
     */
    public final static String EntitlementNotesField        = 'SVMXA360__EntitlementNotes__c';

    /**
     * Static string const to hold source record Service Contract lookup field name.
     */
    public final static String ServiceContractIdField       = 'ServiceContractId';

    /**
     * Static string const to hold source record Service Contract lookup field name.
     */
    public final static String ReturnOrderServiceContractIdField        = 'SVMXA360__ServiceContractId__c';

    /**
     * Static string const to hold source record Asset Warranty lookup field name.
     */
    public final static String AssetWarrantyIdField         = 'AssetWarrantyId';

    /**
     * Static string const to hold source record Asset Warranty lookup field name.
     */
    public final static String ReturnOrderAssetWarrantyIdField      = 'SVMXA360__AssetWarrantyId__c';

    /**
     * Static string const to hold billing type.
     */
    public final static String BillingTypeField                     = 'SVMXA360__BillingType__c';

    /**
     * Static string const to hold WorkOrder Pricebook.
     */
    public final static String WorkOrderPricebook                   = 'Pricebook2Id';

    /**
     * Static string const to hold Entitled service Id.
     */
    public final static String EntitledServiceField                 = 'SVMXA360__EntitledServiceId__c';

    /**
     * Static string const to hold source record Service Contract lookup field name.
     */
    public final static String ContractLineItemIdField       		= 'SVMXA360__ContractLineItemId__c';

    /**
     * Entitlement field name enums.
     */
    public enum EntitlementField {
        Asset,
        Account,
        Contact,
        EntitlementDate,
        Entitlement,
        IsEntitlementPerformed,
        PerformAutoEntitlement,
        EntitlementNotes,
        ServiceContract,
        AssetWarranty,
        BillingType,
        EntitledService,
        Pricebook,
        ContractLineItem
    }

    /**
     * Coverage status enums
     */
    public enum CoverageStatus {
        NoCoverage,
        OneContract,
        OneWarranty,
        OneContractEntitlement,
        OneContractMultipleEntitlements,
        BothContractWarranty,
        MultipleContracts,
        MultipleWarranties
    }

    /**
     * Coverage type enums. Contract/Warranty/Entitlement
     */
    public enum CoverageType {
        Contract,
        Warranty,
        Entitlement
    }

    /**
     * Case entitlement field enum to field name map consumed by entitlement engine.
     */
    public static final Map<EntitlementField, String> EntitlementFields = new Map<EntitlementField, String> {

        EntitlementField.Asset                  => AssetIdField,
        EntitlementField.Account                => AccountIdField,
        EntitlementField.Contact                => ContactIdField,
        EntitlementField.EntitlementDate        => EntitlementDateField,
        EntitlementField.IsEntitlementPerformed => IsEntitlementPerformedField,
        EntitlementField.PerformAutoEntitlement => PerformAutoEntitlementField,
        EntitlementField.EntitlementNotes       => EntitlementNotesField,
        EntitlementField.ServiceContract        => ServiceContractIdField,
        EntitlementField.AssetWarranty          => AssetWarrantyIdField,
        EntitlementField.BillingType            => BillingTypeField,
        EntitlementField.EntitledService        => EntitledServiceField,
        EntitlementField.ContractLineItem       => ContractLineItemIdField
    };

    /**
     * Public method to retrieve entitlement field map.
     */
    public static Map<EntitlementField, String> getEntitlementFieldsMap( final String sourceObjectName ) {

        Map<EntitlementField, String> entitlementFieldsMap = new Map<EntitlementField, String>();

        // Retrieve configured fields by source object name.
        switch on sourceObjectName.toLowerCase() {

            when 'case' {
                entitlementFieldsMap.putAll( Ever.EntitlementFields );
                entitlementFieldsMap.put( EntitlementField.Entitlement, EntitlementIdField );
            }
            when 'workorder' {
                entitlementFieldsMap.putAll( Ever.EntitlementFields );

                entitlementFieldsMap.put( EntitlementField.Pricebook, WorkOrderPricebook );
                entitlementFieldsMap.put( EntitlementField.Entitlement, EntitlementIdField );
            }
            when 'returnorder' {

                entitlementFieldsMap.putAll( Ever.EntitlementFields );

                entitlementFieldsMap.put( EntitlementField.Asset, ReturnOrderAssetIdField );
                entitlementFieldsMap.put( EntitlementField.AssetWarranty, ReturnOrderAssetWarrantyIdField );
                entitlementFieldsMap.put( EntitlementField.ServiceContract, ReturnOrderServiceContractIdField );
                entitlementFieldsMap.put( EntitlementField.EntitledService, ReturnOrderEntitlementIdField );
            }
            when else {
                System.debug( LoggingLevel.DEBUG, 'getEntitlementFieldsMap() : Object not configured in Entitlement setting. sourceObjectName= ' + sourceObjectName  );
            }
        }

        return entitlementFieldsMap;
    }

    public class EntitlementHistory {

        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // String variable to hold entitlement history name
        @AuraEnabled public String name {get;set;}

        // String variable to hold Case id
        @AuraEnabled public String caseId {get;set;}

        // String variable to hold Work Order id
        @AuraEnabled public String workOrderId {get;set;}

        // String variable to hold Return Order id
        @AuraEnabled public String returnOrderId {get;set;}

        // String variable to hold Tracked At Asset/Account/Parent Asset/Root Asset
        @AuraEnabled public String trackedAt {get;set;}

        // String variable to hold Covered By Asset/Account
        @AuraEnabled public String entitledBy {get;set;}

        // String variable to hold source asset id
        @AuraEnabled public String assetId {get;set;}

        // String variable to hold covered entitlement id
        @AuraEnabled public String entitlementId {get;set;}

        // String variable to hold covered asset warranty id
        @AuraEnabled public String assetWarrantyId {get;set;}

        // String variable to hold covered service contract id
        @AuraEnabled public String serviceContractId {get;set;}

        // String variable to hold Entitlement Note (Same as source entitlement note)
        @AuraEnabled public String entitlementNotes {get;set;}

        // String variable to hold verification mode (Auto/Manual)
        @AuraEnabled public String verificationMode {get;set;}

        // Boolean variable to indicate multiple coverage found or not
        @AuraEnabled public Boolean multipleCoverages {get;set;}

        // Boolean variable to indicate multiple entitlement found or not
        @AuraEnabled public Boolean multipleEntitlement {get;set;}

        // Date variable to hold coverage start date
        @AuraEnabled public Date startDate {get;set;}

        // Date variable to hold coverage end date
        @AuraEnabled public Date endDate {get;set;}

        // Date variable to hold entitlement date from source.
        @AuraEnabled public Date entitlementDate {get;set;}

        // Date variable to hold Warranty Name from source.
        @AuraEnabled public String assetWarrantyName {get;set;}

        // Date variable to hold Contract Name from source.
        @AuraEnabled public String serviceContractName {get;set;}

        // Date variable to hold Entitlement Name from source.
        @AuraEnabled public String entitlementtName {get;set;}

        // To store the warranty term details
        @Auraenabled public WarrantyTerm warrantyTerm {get;set;}

        // To store the Total Service Count
        @Auraenabled public Decimal totalService {get;set;}

        // To store the Consumed Service Count
        @Auraenabled public Decimal consumedService {get;set;}

        // To store the remaining hours
        @Auraenabled public Integer remainingHours {get;set;}

        // To store the Billing type
        @Auraenabled public String billingType {get;set;}

        // To store the Billing type
        @Auraenabled public String serviceCountType {get;set;}

        // String variable to hold Entitled Service id
        @AuraEnabled public String entitledServiceId {get;set;}

        // String variable to hold Entitled Service name
        @AuraEnabled public String entitledServiceName {get;set;}

        // String variable to hold Currency ISO Code
        @AuraEnabled public String currencyISOCode {get;set;}
    }

    public class WarrantyTerm {

        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // String variable to hold coverage name
        @AuraEnabled public String name {get;set;}
    }

    /**
     * Inner class to hold coverage informations.
     */
    public virtual class CoverageInfo implements Comparable {

        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // String variable to hold coverage name
        @AuraEnabled public String name {get;set;}

        // String variable to hold asset Id
        @AuraEnabled public String assetId {get;set;}

        // String variable to hold tracked By (Account/Asset/Parent Asset/Root Asset)
        @AuraEnabled public String trackedBy {get;set;}

        // String variable to hold label of tracked By (Account/Asset/Parent Asset/Root Asset)
        @AuraEnabled public String trackedByLabel {get;set;}

        // String variable to hold account Id
        @AuraEnabled public String accountId {get;set;}

        // String variable to hold contact Id
        @AuraEnabled public String contactId {get;set;}

        // String variable to hold Service Contract Id
        @AuraEnabled public String serviceContractId {get;set;}

        // String variable to hold Contract Line Item Id
        @AuraEnabled public String contractLineItemId {get;set;}

        // String variable to hold entitled service Id.
        @AuraEnabled public String entitledServiceId {get;set;}

        // String variable to hold entitled service name.
        @AuraEnabled public String entitledServiceName {get;set;}

        // Stores Service Product Id of the Entitled Service
        @AuraEnabled public String serviceProductId {get;set;}

        // Stores Service Product Name of the Entitled Service
        @AuraEnabled public String serviceProductName {get;set;}

        // Stores Service type of the Entitled Service
        @AuraEnabled public String serviceType {get;set;}

        // Date variable to hold Coverage start date
        @AuraEnabled public Date startDate {get;set;}

        // Date variable to hold Coverage end date
        @AuraEnabled public Date endDate {get;set;}

        // String variable to hold coverge type
        @AuraEnabled public String coverageType {get;set;}

        // String variable to hold warranty type
        @AuraEnabled public String warrantyType {get;set;}

        // Double variable to hold service alert threshold
        @AuraEnabled public Double serviceAlertThreshold {get;set;}

        // Double variable to hold total service
        @AuraEnabled public Double totalService {get;set;}

        // Double variable to hold consumed service
        @AuraEnabled public Double consumedService {get;set;}

        // Double variable to hold remaining days
        @AuraEnabled public Integer remainingDays {get;set;}

        // String variable to hold warranty term Info
        @AuraEnabled public WarrantyTerm warrantyTerm {get;set;}

        // Coverage Service Contract Id
        @AuraEnabled public List<CoverageInfo> entitlements {get;set;}
        
        // Coverage Service Contract Id
        @AuraEnabled public List<CoverageInfo> contractPriceLineItems {get;set;}
        
        // String variable to hold line type
        @AuraEnabled public String lineType {get;set;}

        // String variable to hold Product Name
        @AuraEnabled public String productName {get;set;}

        // String variable to hold product Family
        @AuraEnabled public String productFamily {get;set;}

        // String variable to hold discount
        @AuraEnabled public Double entitledDiscount {get;set;}

        // String variable to hold Price
        @AuraEnabled public Double entitledPrice {get;set;}

        // String variable to hold surcharge percent
        @AuraEnabled public Double surcharge {get;set;}
        
        // String variable to hold Expense Item
        @AuraEnabled public String expenseItem {get;set;}
        
        // String variable to hold currency code
        @AuraEnabled public String currencyCode {get;set;}
        
        // String variable to hold Pricebook Id
        @AuraEnabled public String pricebookId {get;set;}

        // Value of Stack Ranking field
        @AuraEnabled public Object stackRankingFieldValue {get;set;}

        public Integer compareTo( Object compareTo ) {

            Integer compareValue = 0;
            final CoverageInfo compareToCoverageInfo = (CoverageInfo) compareTo;

            if (this.endDate > compareToCoverageInfo.endDate) {
                compareValue = 1;
            }

            if (this.endDate < compareToCoverageInfo.endDate) {
                compareValue = -1;
            }

            return compareValue;
        }
    }

    /**
     * Inner class to hold Service Coverage request/responses.
     */
    public class ServiceCoverage {

        // Boolean variable to hold Multiple Coverages.
        public Boolean multipleCoverages {get;set;}

        // Boolean variable to hold Multiple Entitlements.
        public Boolean multipleEntitlements {get;set;}

        // String variable to hold Covered By (Account/Asset)
        @AuraEnabled public String coveredBy {get;set;}

        // String variable to hold user entitlement notes.
        @AuraEnabled public String entitlementNotes {get;set;}

        // String variable to hold selected Billing Type.
        @AuraEnabled public String billingType {get;set;}

        // CoverageInfo instance to hold selected Coverage ( One of Contract/Warranty/Entitlement)
        @AuraEnabled public CoverageInfo selectedCoverage {get;set;}

        // List of Coverage info to hole contract list.
        @AuraEnabled public List<CoverageInfo> contractList {get;set;}

        // List of Coverage info to hole warranty list.
        @AuraEnabled public List<CoverageInfo> warrantyList {get;set;}

        // Currency Code of the Source Record.
        @AuraEnabled public String currencyISOCode {get;set;}

        // Qualified service assignment rule.
        public Adm.ServiceAssignmentRule serviceAssignmentRule {get;set;}

        public ServiceCoverage() {

            multipleCoverages = false;
            multipleEntitlements = false;

            contractList = new List<CoverageInfo>();
            warrantyList = new List<CoverageInfo>();
        }
    }

    public enum ServiceOperation {
        Increment,
        Decrement
    }

    public enum ServiceUnit {
        Count,
        Amount
    }

    public class ServiceUsageInfo {

        @AuraEnabled public String sourceRecordId {get;set;}
        @AuraEnabled public String entitlementHistoryId {get;set;}
        @AuraEnabled public String entitledServiceId {get;set;}
        @AuraEnabled public Double serviceValue {get;set;}
        @AuraEnabled public ServiceUnit serviceUnit {get;set;}
        @AuraEnabled public ServiceOperation serviceOperation {get;set;}
    }


    /**
     * Wrapper structure to hold list of entitled service records and total record count informations for lazy loading.
     */
    public class EntitledService {

        // Stores the total record count.
        @AuraEnabled public Integer totalRecordCount { get; set; }
        // Stores the Entitled Service details.
        @AuraEnabled public List<EntitledServiceDetail> entitledServiceDetailList { get; set; }
    }


    /**
     * Wrapper structure to hold Entitled Service details.
     */
    public class EntitledServiceDetail extends CoverageInfo {

        // Service Contract Name
        @AuraEnabled public String serviceContractName {get;set;}

        // Contract Line Id (Parent Id)
        @AuraEnabled public String contractLineId {get;set;}

        // Contract Line Item Name
        @AuraEnabled public String contractLineName {get;set;}

        // Stores Asset Name of the Entitled Service
        @AuraEnabled public String assetName {get;set;}

        // Stores Account Name of the Entitled Service
        @AuraEnabled public String accountName {get;set;}

        // Stores status of the Entitled Service
        @AuraEnabled public String status {get;set;}

        // Double variable to hold Remaining Service Count of the Entitled Service
        @AuraEnabled public Double remainingService {get;set;}

        // String variable to hold operatingHoursId
        @AuraEnabled public String operatingHoursId {get;set;}

        // String variable to hold operatingHoursName
        @AuraEnabled public String operatingHoursName {get;set;}

        // CaseEntitlementProcessId
        @AuraEnabled public String caseEntitlementProcessId {get;set;}

        // CaseEntitlementProcessName
        @AuraEnabled public String caseEntitlementProcessName {get;set;}

        //WorkOrder Entitlement Process Id
        @AuraEnabled public String workOrderEntitlementProcessId {get;set;}

        //WorkOrder Entitlement Process Name
        @AuraEnabled public String workOrderEntitlementProcessName {get;set;}

    }
}