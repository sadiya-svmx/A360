/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all Config modules.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 * 				Ramachandra Mohan       01 Jul 2020     New structure to populate filter criteria request.
 * 			    Karthick Saravanan      15 Dec 2020     Updated filter criteria class to have fields for pagination and lazy loading feature. 
 * 			    Karthick Saravanan      15 Dec 2020     Added ContractPriceLineItems structure to hold records and total record count for lazy loading.
 *              Karthick Saravanan      28 Dec 2020     Added ContractPriceLineItemDetail structure to  hold contract price line item details.
 * A360ENG-539  Jason Bradley           29 Jan 2021     Added LookupFilterCriteria utility methods to stamp defaults (stampDefaults) and to stamp fields from CONF_LookupConfiguration__c (stampLookupConfiguration). Added getContextFilter to simplify/unify dependent logic. Also added simple validation function (isValid).
 * A360ENG-539  Jason Bradley           3  Feb 2021     Added LookupFilterCriteria.hasSelectFields and hasSearchFields utility functions for more granular validation control.
 *****************************************************************************************************/
public class Config {
    
    /**
     * Wrapper structure to populate filter criteria request.
     */
    public virtual class FilterCriteria {
        
        // Id field for which records to be filtered.
        @AuraEnabled public String id {get;set;}
        
        // Search term for which record name field to be filtered.
        @AuraEnabled public String searchTerm {get;set;}
        
        // Object name for which records to be retrieved.
        @AuraEnabled public String objectName {get;set;}
        
        // Optional where clause while retrieving records.
        @AuraEnabled public String whereClause {get;set;}
        
        // Number of records to be retrieved.
        @AuraEnabled public Integer limitCount {get; set;}
        
        // List of fields to be queried.
        @AuraEnabled public List<String> fields {
            get {
                if (this.fields == null && String.isNotBlank(this.objectName)) {
                    this.fields = COMM_DescribeManager.getInstance().getNameFields(this.objectName);
                }

                return this.fields;
            }

            set {
                this.fields = value;
            }
        }

        // Parent Id field for which records to be filtered.
        @AuraEnabled public String parentId {get;set;}

        // sort field for which field to be sorted.
        @AuraEnabled public String sortField {get;set;}
        
        //  sort order for which order to be sorted
        @AuraEnabled public String sortOrder {get;set;}

        // query offset for lazy loading or pagination
        @AuraEnabled public Integer queryOffset {get;set;}

        // Stores list of lookup config developer name.
        @AuraEnabled public List<String> developerNames {get;set;}
        
    }

    public class LookupFilterCriteria extends FilterCriteria{
        
        // Id of CONF_LookupConfiguration__c record.
        @AuraEnabled public String lookupConfigId {get;set;}

        // Search operator like as Equals, starts with, contains etc.
        @AuraEnabled public String searchOperator {get;set;}

        // List of search fields.
        @AuraEnabled public List<String> lstSearchInFields {
            get {
                if (this.lstSearchInFields == null && String.isNotBlank(this.objectName)) {
                    List<String> nameFields = COMM_DescribeManager.getInstance().getNameFields(this.objectName);
                    List<String> nameFieldsLowerCase = new List<String>();
                    for (String nameField : nameFields) {
                        nameFieldsLowerCase.add(nameField.toLowerCase());
                    }

                    this.lstSearchInFields = nameFieldsLowerCase;
                }

                return this.lstSearchInFields;
            }

            set {
                this.lstSearchInFields = value;
            }
        }
        
        //Context filter field name.
        @AuraEnabled public String lookupMatchingField {get; set;}

        //Context filter field value
        @AuraEnabled public String lookupContext {get; set;}

        // Need to apply the context filter or not.
        @AuraEnabled public Boolean applyContextFilter {get; set;}

        //NameField of Object
        @AuraEnabled public String referenceNameField {get; set;}

        @AuraEnabled public SObject headerRecordData {get; set;}

        // Performs simple validation of config properties, returning true if all are valid.
        public Boolean isValid() {
            return String.isNotBlank(this.objectName) && this.hasSearchFields();
        }

        public Boolean hasSelectFields() {
            return this.fields != null && !this.fields.isEmpty();
        }

        public Boolean hasSearchFields() {
            return this.lstSearchInFields != null && !this.lstSearchInFields.isEmpty();
        }

        // TODO: Hook this into the constructor to apply automatically. Leaving this call-as-needed
        // for now to avoid unexpected side-effects.
        // Assigns default values to all properties (including dependent ones)
        public void stampDefaults() {
            if (this.limitCount == null) {
                this.limitCount = 20;
            }

            if (this.fields == null) {
                if (this.referenceNameField != null) {
                    this.fields = String.escapeSingleQuotes( this.referenceNameField ).split(',');
                }
            }

            if (this.lstSearchInFields == null) {
                if (this.referenceNameField != null) {
                    this.lstSearchInFields = String.escapeSingleQuotes( this.referenceNameField ).toLowerCase().split(',');
                }
            }

            if (this.searchTerm == null) {
                this.searchTerm = '';
            }
        }

        // Stamps field values from the incoming lookup configuration record onto this instance,
        // with minor additional post-processing.
        public void stampLookupConfiguration(SVMXA360__CONF_LookupConfiguration__c lookupConfig) {
            if (lookupConfig == null) {
                return;
            }

            if (lookupConfig.SVMXA360__RecordsPerPageReturn__c != null) {
                this.limitCount = Integer.valueOf(lookupConfig.SVMXA360__RecordsPerPageReturn__c);
            }

            if (String.isNotBlank(lookupConfig.SVMXA360__ObjectAPIName__c)) {
                this.objectName = lookupConfig.SVMXA360__ObjectAPIName__c;
            }

            if (String.isNotBlank(lookupConfig.SVMXA360__DisplayFields__c)) {
                this.fields = lookupConfig.SVMXA360__DisplayFields__c.split(',');
            }

            if (lookupConfig.SVMXA360__BasicFilter__c != null) {
                this.whereClause = COMM_ExpressionUtils.getInstance().buildCriteria(
                    ADM_ExpressionManager.getInstance().getExpressionsWithDetails(
                        lookupConfig.SVMXA360__BasicFilter__c
                    ),
                    this.headerRecordData
                );
            }

            if (String.isNotBlank(this.whereClause)) {
                this.whereClause = '(' + this.whereClause + ')';
            }

            if (String.isNotBlank(lookupConfig.SVMXA360__SearchFields__c)) {
                this.lstSearchInFields = lookupConfig.SVMXA360__SearchFields__c.toLowerCase()
                    .replace(' ', '').split(',');
            }

            if (String.isNotBlank(lookupConfig.SVMXA360__FieldToReturn__c)) {
                List<String> fieldsToReturn = new List<String>();
                if (lookupConfig.SVMXA360__FieldToReturn__c.indexOf(',') > -1) {
                    fieldsToReturn.addAll(lookupConfig.SVMXA360__FieldToReturn__c.split(','));
                } else {
                    fieldsToReturn.add(lookupConfig.SVMXA360__FieldToReturn__c);
                }

                List<String> returnFieldNotBlankConditions = new List<String>();
                for (String fieldToReturn : fieldsToReturn) {
                    if (!this.fields.contains(fieldToReturn)) {
                        this.fields.add(fieldToReturn);
                    }

                    String returnFieldNotBlankCondition = fieldToReturn + ' != \'\'';
                    returnFieldNotBlankConditions.add(returnFieldNotBlankCondition);
                }


                if (String.isNotBlank(this.whereClause)) {
                    this.whereClause += ' AND ' + String.join(returnFieldNotBlankConditions, ' AND ');
                } else {
                    this.whereClause = String.join(returnFieldNotBlankConditions, ' AND ');
                }
            }
        }
        
        public String getContextFilter() {
            String filterClause = '';

            String lookupContextValue = String.isNotBlank(this.lookupContext) ? this.lookupContext : null;

            if (this.applyContextFilter == true &&
                String.isNotBlank(this.lookupMatchingField)) {
                Common.FieldDefinition fieldDefinition = COMM_MetadataManager.getInstance().getFieldDefinition(
                    this.objectName,
                    this.lookupMatchingField,
                    true
                );
                String matchingFieldDataType = fieldDefinition.dataType;
                if (matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.Double.name()) || matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.Percent.name())
                    || matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.Currency.name()) || matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.Integer.name()) 
                    || matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.Boolean.name()) || matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.Date.name())
                    || matchingFieldDataType.equalsIgnoreCase( Schema.DisplayType.DateTime.name())) {
                        filterClause = String.escapeSingleQuotes(this.lookupMatchingField) + '= ' + lookupContextValue;
                } else {
                    lookupContextValue = lookupContextValue != null ? '\'' + String.escapeSingleQuotes(lookupContextValue) + '\'' : null;
                    filterClause = String.escapeSingleQuotes(this.lookupMatchingField) + '= ' + lookupContextValue ;
                } 
            }
            return filterClause;
        }

        public void resolveReferenceSearchFieldsToNameFields() {
            if (this.lstSearchInFields != null && String.isNotBlank(this.objectName)) {
                Map<String, Schema.DescribeFieldResult> fieldDescribes = COMM_DescribeManager.getInstance().getFieldDescribeResults(this.objectName);

                List<String> resolvedSearchFields = new List<String>();
                for (String searchField : this.lstSearchInFields) {
                    Schema.DescribeFieldResult fieldDescribe = fieldDescribes.get(searchField);
                    if (fieldDescribe != null && fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                        searchField = COMM_DescribeManager.getInstance().getReferenceNameField(fieldDescribe);
                    }
                    resolvedSearchFields.add(searchField);
                }
                this.lstSearchInFields = resolvedSearchFields;
            }
        }
    }
    
    public class DataValidationResult {
        
        //Indicates validation result success true/false.
        @AuraEnabled public Boolean success {get;set;}
        
        // List of errors in case of failure.
        @AuraEnabled public List<String> errors {get;set;}
        
        public DataValidationResult() {
            
            success = true;
            errors = new List<String>();
        }
    }
    
    /**
     * Wrapper structure for runtime page data request.
     */
    public class PageDataRequest {
        @AuraEnabled public String transactionType;
        @AuraEnabled public String pageLayoutId;
        @AuraEnabled public String sourceRecordId;
        @AuraEnabled public String targetRecordId;
        @AuraEnabled public String recordId;
        @AuraEnabled public sObject headerRecord;
        @AuraEnabled public List<PageDetail> pageDetails;
        @AuraEnabled public String detailLineId;
        @AuraEnabled public String actionType;
    }

    public class PageDetail {
        @AuraEnabled public String uniqueKey;
        @AuraEnabled public List<sObject> detailRecords;
        @AuraEnabled public List<String> deleteIds;
    }

    /**
     * Wrapper structure for runtime page data response.
     */
    public class PageDataResponse {
        @AuraEnabled public sObject headerRecord;
        @AuraEnabled public PageConfig config;
        @AuraEnabled public List<PageDetail> pageDetails;
    }

    /**
     *  Runtime evaluated PageConfig details.s
     */
    public class PageConfig {
        @AuraEnabled public ExpressionMapping headerMappingInfo;
    }

    public class ExpressionMapping {
        @AuraEnabled public String expressionId;
        @AuraEnabled public String mappingId;
        public ExpressionMapping (String expression, String mapping) {
            this.expressionId = expression;
            this.mappingId = mapping;
        }
    }

    /**
     * Wrapper structure to hold list of records and total record count informations for lazy loading.
     * cpli - Contract Price Line Items
     */
    public class ContractPriceLineItems {   
        @AuraEnabled   
        public Integer totalRecordCount { get; set; }   
        @AuraEnabled   
        public List<SVMXA360__ContractPriceLineItem__c> cpliRecords{ get; set; }   
        public ContractPriceLineItems (Integer count,List<SVMXA360__ContractPriceLineItem__c> cpliRecords) {   
            this.totalRecordCount = count;   
            this.cpliRecords= cpliRecords;   
        }   
    } 

    /**
     * Wrapper structure to hold contract price line item details.
     */
    public class ContractPriceLineItemDetail {   
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // Stores name of the Contract Price Detail
        @AuraEnabled public String name {get;set;}

        // Service Contract Id (Parent Id)
        @AuraEnabled public String serviceContractId {get;set;}
        
        // Service Contract Name
        @AuraEnabled public String serviceContractName {get;set;}

        // Contract Line Id (Parent Id)
        @AuraEnabled public String contractLineId {get;set;}
        
        // Contract Line Item Name
        @AuraEnabled public String contractLineName {get;set;}

        // Entitlement Id (Parent Id)
        @AuraEnabled public String entitledServiceId {get;set;}
        
        // Entitled Service Name
        @AuraEnabled public String entitledServiceName {get;set;}

        // Stores line type of the Contract Price Detail
        @AuraEnabled public String lineType {get;set;}

        // Stores expense item of the Contract Price Detail
        @AuraEnabled public String expenseItem {get;set;}

        // Stores product id of the Contract Price Detail
        @AuraEnabled public String productId {get;set;}
        
        // Stores product name of the Contract Price Detail
        @AuraEnabled public String productName {get;set;}

        // Stores product family of the Contract Price Detail
        @AuraEnabled public String productFamily {get;set;}

        // Stores entiteld price value of the Contract Price Detail
        @AuraEnabled public string price {get;set;}

        // Stores surcharge value of the Contract Price Detail
        @AuraEnabled public string surcharge {get;set;}

        // Stores discount value of the Contract Price Detail
        @AuraEnabled public string discount {get;set;}

        // Stores Currency ISO Code of the Contract Price Detail
        @AuraEnabled public string currencyIsoCode {get;set;}

    }

    /**
    * Wrapper class to hold Picklist Definition information. 
    */
    public class PicklistDefinition {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        @AuraEnabled public String lastModifiedBy {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String values  {get;set;}
        @AuraEnabled public String defaultValue  {get;set;}
    }
}