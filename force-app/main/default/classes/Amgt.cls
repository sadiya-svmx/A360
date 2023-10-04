/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across asset management modules.
 *
 * @author Ryan Follmer
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ryan Follmer            10 December 2020  Created.
 * A360AM-592  Ryan Follmer             28 May 2021     Added support for showMatchingRecordsOnLoad
 *****************************************************************************************************/

public with sharing class Amgt {

    /**
     * Wrapper class to hold the request information for timeline data
     */
    public virtual class TimelineRequest {
        @AuraEnabled public String parentRecordId { get; set; }
        
        @AuraEnabled public String fieldApiName { get; set; }

        @AuraEnabled public Date startDate { get; set; }

        @AuraEnabled public Date endDate { get; set; }

        @AuraEnabled public List<String> objectApiNameList { get; set; }

        @AuraEnabled public Boolean isMobileRequest { get; set; }
    }

    public virtual class TimelineResponse {
        // Salesforce record Id for the source record having timeline results.
        @AuraEnabled public String id {get;set;}

        // Display Name of the source record having timeline results.
        @AuraEnabled public String displayName {get;set;}

        // Display Name of the source record having timeline results.
        @AuraEnabled public String configDevloperName {get;set;}

        // Map variable to hold a collection of Types to Show based on the configurations for the timeline.
        @AuraEnabled public Map<String, TimelineTypeToShow> typesToShow { get;set; }

        // List variable to hold list of Timeline Results.
        @AuraEnabled public List<Timeline> timelineResults { get;set; }

        public TimelineResponse(){
            timelineResults = new List<Timeline>();
            typesToShow = new Map<String, TimelineTypeToShow>();
        }
    }

    public virtual class TimelineTypeToShow {
        // Object Label 
        @AuraEnabled public String label { get;set; }
        @AuraEnabled public String objectApiName {get;set;}
        @AuraEnabled public String expressionName { get;set; }
        @AuraEnabled public String iconName { get;set; }
        @AuraEnabled public Decimal sequence { get;set; }
        @AuraEnabled public Boolean isTimespanEvent { get;set; }
        // Indicates the timeline component should show records for this object type on initial load.
        @AuraEnabled public Boolean showMatchingRecordsOnLoad { get; set; }
    }

    /**
     * Wrapper class to hold Timeline data. 
     */
    public virtual class Timeline {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Record Display Name
        @AuraEnabled public String displayName {get;set;}
        
        // Record start date
        @AuraEnabled public Object startDate {get;set;}
        
        // Record end date (if configured)
        @AuraEnabled public Object endDate {get;set;}
        
        // Object API name
        @AuraEnabled public String objectAPIName {get;set;}

        // Object Label for the record
        @AuraEnabled public String objectLabel {get;set;}

        // Background Color to use when displaying a record band.
        @AuraEnabled public String backgroundColor {get;set;}

        // Icon Name to use when displaying a timeline item.
        @AuraEnabled public String iconName {get;set;}

        // Display Sequence of the record on the timeline.
        @AuraEnabled public Integer sequence {get;set;}

        // Display Sequence of the record on the timeline.
        @AuraEnabled public String uniqueName {get;set;}

        // Record retrieved for the Timeline Result
        @AuraEnabled public Object record { get; set; }

         // expression name for the record (objectAPIname_expressionName)
        @AuraEnabled public String expressionName {get;set;}
    }

    public class HierarchyConfiguration {

        @AuraEnabled public HierarchyConfigurationDetail account { get; set; }

        @AuraEnabled public HierarchyConfigurationDetail asset { get; set; }

        @AuraEnabled public HierarchyConfigurationDetail location { get; set; }

        public Boolean isEmpty { get; set; }

    }

    public class HierarchyConfigurationDetail {
        @AuraEnabled public String id { get; set; }
        
        @AuraEnabled public String hierarchyConfigId { get; set; }

        @AuraEnabled public String objectAPIName { get; set; }

        @AuraEnabled public String displayIconName { get; set; }

        @AuraEnabled public Boolean enableSPMWizards { get; set; }

        @AuraEnabled public Boolean defaultRecordActions { get; set; }
        
        @AuraEnabled public String qualifyingCriteria {get;set;}
        
        @AuraEnabled public String qualifyingCriteriaName {get;set;}
        
        @AuraEnabled public Boolean enableNotifications {get;set;}
        
        @AuraEnabled public String notificationCriteria {get;set;}
        
        @AuraEnabled public String notificationCriteriaName {get;set;}

        @AuraEnabled public List<HierarchyConfigurationField> fields { get; set; }
        
        @AuraEnabled public List<Adm.Expression> expressions { get; set; }

        @AuraEnabled public Boolean allowManagingChildAssets {get;set;}

    }

    public class HierarchyConfigurationField {
        @AuraEnabled public String id { get; set; }

        @AuraEnabled public String hierarchyConfigurationDetailId { get; set; }
        
        @AuraEnabled public String fieldApiName { get; set; }

        @AuraEnabled public Integer sequence { get; set; }

    }

    public class RootIdRequest {
        @AuraEnabled public Id primaryRecordId { get; set; }
        
        @AuraEnabled public String order { get; set; }
    }

    public virtual class HierarchyNodeBase { 
        @AuraEnabled
        public string id { get; set; }

        @AuraEnabled
        public Boolean expandByDefault { get; set; }

        @AuraEnabled
        public string name { get; set; }
    }

    public virtual class HierarchyNode extends HierarchyNodeBase{ 

        @AuraEnabled
        public string parentId { get; set; }

        @AuraEnabled
        public string objectApiName { get; set; }

        @AuraEnabled
        public string url { get; set; }

        @AuraEnabled
        public string record { get; set; }

        @AuraEnabled
        public Map<String, Object> lookupRecords { get; set; }
    
        @AuraEnabled
        public List<HierarchyNode> detail { get; set; }
    
        @AuraEnabled
        public List<HierarchyNode> children { get; set; }

        @AuraEnabled
        public List<String> fields { get; set; }
        
    }

    public virtual class HierarchyNodeField {
        @AuraEnabled
        public string fieldApiName { get; set; }

        @AuraEnabled
        public Object value { get; set; }
    }
    
    public class NotificationDetails {
        @AuraEnabled
        public string assetId { get; set; }
        
        @AuraEnabled
        public List<Notification> assetNotifications { get; set; }
    }
  
    public class Notification {
        @AuraEnabled
        public string name { get; set; }
        
        @AuraEnabled
        public string id { get; set; }
        
        @AuraEnabled
        public string description { get; set; }
        
        @AuraEnabled
        public string title { get; set; }
        
        @AuraEnabled
        public dateTime notificationDate { get; set; }
        
        @AuraEnabled
        public string assetName { get; set; }
    }

    public virtual class SearchResult{
        @AuraEnabled
        public string timestampInMills { get; set; }

        @AuraEnabled
        public List<HierarchyNode> result { get; set; }
    }

    public virtual class SaveResponse{
        @AuraEnabled
        public List<string> error { get; set; }

        @AuraEnabled
        public List<string> errorFields { get; set; }

        @AuraEnabled
        public boolean success { get; set; }

        @AuraEnabled
        public string id { get; set; }
    }

    public virtual class TimelineCategory {
        @AuraEnabled
        public string categoryType { get; set; }

        @AuraEnabled
        public string label { get; set; }
    }
}