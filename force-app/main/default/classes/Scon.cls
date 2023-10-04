/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all SCON business modules.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 *****************************************************************************************************/
public class Scon {

    /**
     * Base plan record wrapper
     */
    public virtual class SconPlanRecord {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Record name
        @AuraEnabled public String name {get;set;}
        
        // Record last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Record last modified user.
        @AuraEnabled public String lastModifiedBy {get;set;}
    }
    
    /**
     * Wrapper class to hold Service Contract template informations. 
     */
    public class ServiceContractPlan extends SconPlanRecord {
        
        // Service Contract template term duration
        @AuraEnabled public Integer duration {get;set;}
        
        // Service Contract template term unit
        @AuraEnabled public String unitOfTime {get;set;}
        
        // Pricebook ID
        @AuraEnabled public String pricebookId {get;set;}
        
        // Description
        @AuraEnabled public String description {get;set;}
        
        // Special Terms
        @AuraEnabled public String specialTerms {get;set;}
        
        // Is Active
        @AuraEnabled public Boolean isActive {get;set;}

        // Service Contract Plan currency Iso Code
        @AuraEnabled public String currencyIsoCode {get;set;}
        
        // Service Contract line templates
        @AuraEnabled public List<ContractLineItemPlan> contractLineItemPlans {get;set;}
        
        // Service Contract entitled service templates
        @AuraEnabled public List<EntitledServicePlan> entitledServicePlans {get;set;}
        
        // Service Contract Price Line Plans
        @AuraEnabled public List<ContractPriceLineItemPlan> contractPriceLineItemPlans {get;set;}

        // Offered Maintenance Plan Template
        @AuraEnabled public List<OfferedMaintenancePlanTemplate> offeredMaintenancePlanTemplates {get;set;}
    }
    
    public class ContractLineItemPlan extends SconPlanRecord {
        
        // Service Contract line duration
        @AuraEnabled public Integer duration {get;set;}
        
        // Service Applicable Contract Line Product term unit
        @AuraEnabled public String unitOfTime {get;set;}
        
        // Service Contract Plan Id
        @AuraEnabled public String serviceContractPlanId {get;set;}
        
        // Service Contract Plan name
        @AuraEnabled public String serviceContractPlanName {get;set;}
        
        // Service Applicable Contract Line Product ProductId
        @AuraEnabled public String productId {get;set;}
        
        // Service Applicable Contract Line Product Product name
        @AuraEnabled public String productName {get;set;}
        
        // Service Applicable Contract Line Product Product Family
        @AuraEnabled public String productFamily {get;set;}
        
        // Service Applicable Contract Line Product discount
        @AuraEnabled public Double discount {get;set;}
        
        // Service Contract line entitled service templates
        @AuraEnabled public List<EntitledServicePlan> entitledServicePlans {get;set;}
        
        // Service Contract line Contract Price Line Plans
        @AuraEnabled public List<ContractPriceLineItemPlan> contractPriceLineItemPlans {get;set;}
    }
    
    public virtual class EntitledServicePlan extends SconPlanRecord {

        // String variable to hold plan type
        @AuraEnabled public String planType {get;set;}
        
        // String variable to hold asset Id
        @AuraEnabled public String assetId {get;set;}
        
        // String variable to hold asset name
        @AuraEnabled public String assetName {get;set;}
        
        // String variable to hold account Id
        @AuraEnabled public String accountId {get;set;}
        
        // String variable to hold account name
        @AuraEnabled public String accountName {get;set;}
        
        // String variable to hold Service Contract template Id
        @AuraEnabled public String serviceContractPlanId {get;set;}
        
        // String variable to hold Service Contract template Name
        @AuraEnabled public String serviceContractPlanName {get;set;}
        
        // String variable to hold Applicable Contract Line Product Id
        @AuraEnabled public String contractLineItemPlanId {get;set;}
        
        // String variable to hold Applicable Contract Line Product Name
        @AuraEnabled public String contractLineItemPlanName {get;set;}
        
        // Stores Service Product Id of the Entitled Service 
        @AuraEnabled public String serviceProductId {get;set;}
        
        // Stores Service Product Id of the Entitled Service name
        @AuraEnabled public String serviceProductName {get;set;}
        
        // Stores Service Unit of the Entitled Service 
        @AuraEnabled public String serviceUnit {get;set;}
        
       	// Service Contract line duration
        @AuraEnabled public Integer duration {get;set;}
        
        // Service Contract line template term unit
        @AuraEnabled public String unitOfTime {get;set;}
        
        // Double variable to hold service alert threshold
        @AuraEnabled public Double serviceAlertThreshold {get;set;}
        
        // Double variable to hold total service
        @AuraEnabled public Double totalService {get;set;}
        
        // Double variable to hold Operating Hours
        @AuraEnabled public String operatingHoursId {get;set;}
        
        // Double variable to hold Operating Hours name
        @AuraEnabled public String operatingHoursName {get;set;}
        
        // Case Entitlement ProcessId
        @AuraEnabled public String caseEntitlementProcessId {get;set;}
        
        // Case Entitlement Process Name
        @AuraEnabled public String caseEntitlementProcessName {get;set;}

        //WorkOrder Entitlement Process Id
        @AuraEnabled public String workOrderEntitlementProcessId {get;set;}
        
        //WorkOrder Entitlement Process Name
        @AuraEnabled public String workOrderEntitlementProcessName {get;set;}
        
        // Service Contract line Contract Price Line Plans
        @AuraEnabled public List<ContractPriceLineItemPlan> contractPriceLineItemPlans {get;set;}
    }
    
    public class ContractPriceLineItemPlan extends SconPlanRecord {

        // String variable to hold plan type
        @AuraEnabled public String planType {get;set;}
        
        // String variable to hold Service Contract plan Id
        @AuraEnabled public String serviceContractPlanId {get;set;}
        
        // String variable to hold Service Contract plan Name
        @AuraEnabled public String serviceContractPlanName {get;set;}
        
        // String variable to hold Applicable Contract Line Product Id
        @AuraEnabled public String contractLineItemPlanId {get;set;}
        
        // String variable to hold Applicable Contract Line Product Name
        @AuraEnabled public String contractLineItemPlanName {get;set;}
        
        // String variable to hold Entitled Service Plan Id
        @AuraEnabled public String entitledServicePlanId {get;set;}
        
        // String variable to hold Entitled Service Plan Name
        @AuraEnabled public String entitledServicePlanName {get;set;}

        // Contract Price Line template ProductId
        @AuraEnabled public String productId {get;set;}
        
        // Contract Price Line template Product Name
        @AuraEnabled public String productName {get;set;}

		// Contract Price Line template Product Family
        @AuraEnabled public String productFamily {get;set;}

        // Contract Price Line type
        @AuraEnabled public String lineType {get;set;}

		// Contract Price Line discount
        @AuraEnabled public Double entitledDiscount {get;set;}
        
        // Contract Price Line entitles Price
        @AuraEnabled public Double entitledPrice {get;set;}

		// Contract Price Line Surcharge
        @AuraEnabled public Double surcharge {get;set;}

        // Contract Price Line Expense Item
        @AuraEnabled public String expenseItem {get;set;}
        
        // Contract Price Line unique key
        @AuraEnabled public String uniqueKey {get;set;}

        // Contract Price Line currency Iso Code
        @AuraEnabled public String currencyIsoCode {get;set;}
    }

    public class ServiceContractPlanRequest{

        // String variable to hold source record Id
        @AuraEnabled public String sourceRecordId {get;set;}

        // String variable to hold plan Id
        @AuraEnabled public String serviceContractPlanId {get;set;}

        // String variable to hold location Id
        @AuraEnabled public String locationId {get;set;}

        // String variable to hold priceBook Id
        @AuraEnabled public String pricebookId {get;set;}

        // String variable to hold Sales Contract Id
        @AuraEnabled public String salesContractId {get;set;}

        // String variable to hold Sales Contract field Name
        @AuraEnabled public String salesContractIdFieldName {get;set;}

        // String variable to hold contract name
        @AuraEnabled public String serviceContractName {get;set;}

        // String variable to hold description of the contract
        @AuraEnabled public String serviceContractDescription {get;set;}

        // String variable to hold the start date of the contract
        @AuraEnabled public Date serviceContractStartDate {get;set;}

        // String variable to hold the end date of the contract
        @AuraEnabled public Date serviceContractEndDate {get;set;}

        // Boolean variable to hold create contract for parent and child assets
        @AuraEnabled public Boolean evaluateForChildAssets {get;set;}

        // Boolean variable to hold create bulk create contract lines
        @AuraEnabled public Boolean createBulkContractLines {get;set;}

        // Map to hold map of asset and Service Contract Plan
        @AuraEnabled public Map <Id,Id> assetServiceContractPlanIdMap {get;set;}
    
    }

    public class ServiceContractResponse{

        // Holds Service Centract Info
        @AuraEnabled public ServiceContract serviceContractRecord {get;set;}

        // Holds info of the parent authoring log to be created
        @AuraEnabled public SVMXA360__SCONAuthoringLog__c parentAuthoringLog {get;set;}
    }

    public class ServiceContractPlanApexActionRequest{

        // String variable to hold source record Id
        @AuraEnabled public String sourceRecordId {get;set;}

        // String variable to hold plan Id
        @AuraEnabled public String serviceContractPlanId {get;set;}

        // String variable to hold location Id
        @AuraEnabled public String locationId {get;set;}

        // String variable to hold contract name
        @AuraEnabled public String serviceContractName {get;set;}

        // String variable to hold description of the contract
        @AuraEnabled public String serviceContractDescription {get;set;}

        // String variable to hold the start date of the contract
        @AuraEnabled public Date serviceContractStartDate {get;set;}

        // Boolean variable to hold create contract for parent and child assets
        @AuraEnabled public Boolean evaluateForChildAssets {get;set;}

        // Boolean variable to hold create bulk create contract lines
        @AuraEnabled public Boolean createBulkContractLines {get;set;}

        // Map to hold map of asset and Service Contract Plan
        @AuraEnabled public List<AssetServiceContractPlan> assetServiceContractPlanList {get;set;}
    
    }

    public class AssetServiceContractPlan {

        // String variable to hold Asset Id
        @AuraEnabled public Id assetId {get;set;}
        
        // String variable to hold Service Contract plan Id
        @AuraEnabled public Id serviceContractPlanId {get;set;}
    }

    public class OfferedMaintenancePlanTemplate extends SconPlanRecord {

        // String variable to hold Service Contract plan Id
        @AuraEnabled public String serviceContractPlanId {get;set;}
        
        // String variable to hold Service Contract plan Name
        @AuraEnabled public String serviceContractPlanName {get;set;}
        
        // String variable to hold Maintenance plan template Id
        @AuraEnabled public String maintenancePlanTemplateId {get;set;}
        
        // String variable to hold Maintenance plan template Name
        @AuraEnabled public String maintenancePlanTemplateName {get;set;}
        
        // Description
        @AuraEnabled public String description {get;set;}
        
        // Is Active
        @AuraEnabled public Boolean isActive {get;set;}
    }

    public class PlatformEventRequest {

        // Map to hold map of asset and Service Contract Plan
        @AuraEnabled public Map <Id,Id> assetServiceContractPlanIdMap {get;set;}

        // Variable to hold Ids of the record
        @AuraEnabled public List<Id> recordIds {get;set;}

        // String variable to hold plan Id
        @AuraEnabled public String serviceContractPlanId {get;set;}

        // String variable to hold plan SCON Id
        @AuraEnabled public String serviceContractId {get;set;}

        // Variable to hold Service Contract Record
        @AuraEnabled public ServiceContract serviceContractRecord {get;set;}

        // Variable to hold Id of the parent SCON Authoring Log Record
        @AuraEnabled public String parentSCONLogRecordId {get;set;}
    
    }

    public class QualifiedAssets {

        // Map to hold list of qualified assets
        @AuraEnabled public List<Asset> qualifiedAssetList {get;set;}

        // Number of records that would be created if authoring is performed
        @AuraEnabled public Integer recordCount {get;set;}

    }

    public class ServiceContractDeleteResponse{

        // Holds Service Centract Info
        @AuraEnabled public ServiceContract serviceContractRecord {get;set;}

        // Holds info of the parent authoring log to be created
        @AuraEnabled public SVMXA360__SCONAuthoringLog__c parentAuthoringLog {get;set;}

        // Status of the deletion 
        @AuraEnabled public String deletionStatus {get;set;}

    }

    public class AuthoringSummaryDetails {
        // Number of batch executed 
        @AuraEnabled public Integer totalNumberOfBatchesExecuted {get;set;}

        // Total number of batches
        @AuraEnabled public Integer totalNumberOfBatches {get;set;}

        // List to hold Authoring Batch log of failed records 
        @AuraEnabled public List<SVMXA360__SCONAuthoringLog__c> authoringLogOfFailedBatches {get;set;}
    }

    public class LogMessage{

        // Holds the number of assets processed
        @AuraEnabled public Integer assetsProcessed {get;set;}

        // Holds the number of contract line items created
        @AuraEnabled public Integer contractLineItemsCreated {get;set;}

        // Holds the number of entitled services created
        @AuraEnabled public Integer entitledServicesCreated {get;set;}

        // Holds the number of contract price line items created
        @AuraEnabled public Integer contractPriceLineItemsCreated {get;set;}

        // Holds the number of contract line items created
        @AuraEnabled public Integer contractLineItemsDeleted {get;set;}

        // Holds the number of entitled services created
        @AuraEnabled public Integer entitledServicesDeleted {get;set;}

        // Holds the number of contract price line items created
        @AuraEnabled public Integer contractPriceLineItemsDeleted {get;set;}

        // Holds the error message
        @AuraEnabled public String errors {get;set;}

    }

    public class ContractLineItemResponse{

        // Holds the list of Contract Line Item
        @AuraEnabled public List<ContractLineItem> contractLineItemList {get;set;}

        // Holds the Ids of qualifying Applicable Contract Line Products
        @AuraEnabled public Set<String> qualifyingDefinitionIds {get;set;}

        // Holds the Map of Applicable Contract Line Products
        @AuraEnabled public Map<String, ContractLineItemPlan> contractLineItemPlanIdMap {get;set;}

        // Holds the Map of Asset Id and Contract Asset Data
        @AuraEnabled public Map<Id,ContractLineAssetData> contractLineAssetDataMap {get;set;}

    }

    public class ContractLineItemRecord extends SconPlanRecord {

        // Contract Line Item quantity
        @AuraEnabled public Decimal quantity {get;set;}

        // Service Contract Id
        @AuraEnabled public String serviceContractId {get;set;}

        // Contract Line Item ProductId
        @AuraEnabled public String productId {get;set;}

        // Contract Price Line Product Name
        @AuraEnabled public String productName {get;set;}

        // Contract Line Item PriceBookEntryId
        @AuraEnabled public String priceBookEntryId {get;set;}

        // Contract Line Item discount
        @AuraEnabled public Double discount {get;set;}

        // Contract Line Item listPrice
        @AuraEnabled public Double listPrice {get;set;}

        // Contract Line Item unitPrice
        @AuraEnabled public Double unitPrice {get;set;}

        // Contract Line Item AssetId
        @AuraEnabled public String assetId {get;set;}

        // Contract Line Item Asset Name
        @AuraEnabled public string assetName { get; set; }  

        // Contract Line Item startDate
        @AuraEnabled public Date startDate {get;set;}

        // Contract Line Item endDate
        @AuraEnabled public Date endDate {get;set;}

        // Contract Line Item Number
        @AuraEnabled public string lineItemNumber { get; set; }

        // Contract Line Item Status
        @AuraEnabled public string status { get; set; }
    }

    /**
     * Wrapper structure to hold list of records and total record count informations for lazy loading.
     * cli - Contract Line Items
    */
    public class ContractLineItems {
        @AuraEnabled public Integer totalRecordCount { get; set; }

        @AuraEnabled public List<ContractLineItemRecord> cliRecords{ get; set; }
    }
    
    /**
     * Wrapper class to hold Service Contract information.
     */
    public class ServiceContractDetails extends SconPlanRecord {
        
        // Service Contract Availability Status
        @AuraEnabled public String authoringStatus {get;set;}
        
        // Service Contract Canceled On
        @AuraEnabled public Date canceledOn {get;set;}
        
         // Service Contract Status Notes
         @AuraEnabled public String statusNotes {get;set;}
    }

}