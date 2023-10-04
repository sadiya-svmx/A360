/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all PSC modules.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          17 Dec 2020     Created.
 *****************************************************************************************************/
public with sharing class Psc {

    public class SearchCriteria {

        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // current status for the search criteria card
        @AuraEnabled public String status {get;set;}

        // product id configured for PSC
        @AuraEnabled public String productIdForPsc {get;set;}

        // product Name configured for PSC
        @AuraEnabled public String productNameForPsc {get;set;}

        // Expression and Expression details configured for PSC
        @AuraEnabled public Adm.Expression expression {get;set;}

        // Number of expected records to be created
        @AuraEnabled public Integer expectedRecordCount {get;set;}

        // Created record count for the PSC
        @AuraEnabled public Integer createdRecordCount {get;set;}
    }

    public class ResultsPreview {
        // Salesforce record Id of PSC record
        @AuraEnabled public String id {get;set;}
        
        // Record Count for the Results Preview
        @AuraEnabled public Integer recordCount {get;set;}

        // Column Info for the Results Preview
        @AuraEnabled public List<ColumnInformation> columnInformations {get;set;}

        // Results Preview records for configured search criteria
        @AuraEnabled public List<ResultPreviewDetail> resultsPreviewDetails {get;set;}

        // Maximum allowed Search Results that can be created from PSC search
        @AuraEnabled public Integer maxAllowedSearchResults {get;set;}
    }

    public class ResultPreviewDetail {
        // Name of the Asset
        @AuraEnabled public String item {get;set;}

        // Serial Number of the Asset
        @AuraEnabled public String serialNumber {get;set;}

        // Location Name of the Asset
        @AuraEnabled public String location {get;set;}
    }

    public class ColumnInformation {
        // Label of the Field/Column
        @AuraEnabled public String label {get;set;}

        // API name of the Field/Column
        @AuraEnabled public String apiName {get;set;}

        // Data Type of the Field/Column
        @AuraEnabled public String dataType {get;set;}

        // API name of the related object if dataType is REFERENCE
        @AuraEnabled public String relatedObjectName {get;set;}

        // API name of the Name field of the related Object
        @AuraEnabled public String relatedNameField {get;set;}
    }

    public class ResultLineRequest {

        // id of the PSC record
        @AuraEnabled public String id {get;set;}

        // List of field API names of the object
        @AuraEnabled public List<String> fieldApiNames {get;set;}
    }

    public class ResultLineStatus {
        // Indicate the batch process is running or not
        @AuraEnabled public Boolean isBatchRunning {get;set;}

        // Total Lines which are created from defined Search Criteria
        @AuraEnabled public Integer linesGenerated {get;set;}

        // Total Lines which are delivered for some output
        @AuraEnabled public Integer linesDelivered {get;set;}

        // Total number of Cases which are created as part of this PSC process
        @AuraEnabled public Integer casesDelivered {get;set;}

        // Total number of Work Orders which are created as part of this PSC process
        @AuraEnabled public Integer workOrderDelivered {get;set;}

        // Total number of Return Orders which are created as part of this PSC process
        @AuraEnabled public Integer returnOrderDelivered {get;set;}

        // Total number of Opportunities which are created as part of this PSC process
        @AuraEnabled public Integer opportunityDelivered {get;set;}

        // Total number of Asset Notifications which are created as part of this PSC process
        @AuraEnabled public Integer assetNotificationDelivered {get;set;}

        // Number of lines taken for the output delivery
        @AuraEnabled public Integer totalLinesForDelivery {get;set;}
    }

    public class SearchAssetRequest {

        // Id of the product record for which assests needs to be searched
        @AuraEnabled public String id {get;set;}

        // search keyword which will be used for searching Asset records
        @AuraEnabled public String searchKeyword {get;set;}
    }
}