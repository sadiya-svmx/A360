/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is a wrapper for the Mobile Asset hierarchy.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID            Name                    Date                    Comment
 *****************************************************************************************************
 *                 Hemant Keni              22 Novemeber 2021       Created.
 *  A360MOB-252    Hemant Keni              24 January 2022         Added the class for the Asset 
 *                                                                  management mobile rest request
 *****************************************************************************************************/
public with sharing class MobileAmgt {

    public virtual class HierarchyNode extends Amgt.HierarchyNodeBase{ 

        @AuraEnabled
        public Boolean hasChildren { get; set; }

        @AuraEnabled
        public Integer totalChildrens { get; set; }

        @AuraEnabled
        public Boolean hasOpenNotifications {get; set;}

        @AuraEnabled
        public Map<String, Object> fields { get; set;}

        @AuraEnabled
        public List<HierarchyNode> childNodes { get; set; }
    }

    public virtual class RootHierarchyNode extends HierarchyNode{  

        @AuraEnabled
        public String hierarchyType { get; set; }

        @AuraEnabled
        public Id assetHierarchyId { get; set; }

        // Currently, we are supporting Asset hierarchy till 8 levels only.
        // So, in some cases, root node won't be an actual root node.
        // rootNodeParentId will contain the root nodes parent Id.
        @AuraEnabled
        public Id rootNodeParentId { get; set;}
        
        @AuraEnabled
        public Integer assetLevel {get; set;}

        @AuraEnabled
        public HierarchyConfiguration hierarchyconfiguration {get; set;}

        @AuraEnabled
        public Id actualRootId {get; set;}

    }

    public virtual class HierarchyServiceRequest {

        @AuraEnabled
        public Id recordId { get; set; }

        @AuraEnabled
        public HierarchyConfiguration hierarchyConfiguration {get; set;}
    }

    public virtual class HierarchyNodesRequest extends HierarchyServiceRequest{

        @AuraEnabled
        public Integer offset { get; set; }

        @AuraEnabled
        public Integer assetLevel {get; set;}

    }

    public virtual class HierarchyRootNodeRequest extends HierarchyServiceRequest {

    }


    public class HierarchyConfiguration {

        @AuraEnabled public HierarchyConfigurationDetail accountHierarchyConfig { get; set; }

        @AuraEnabled public HierarchyConfigurationDetail assetHierarchyConfig { get; set; }

        @AuraEnabled public HierarchyConfigurationDetail locationHierarchyConfig { get; set; }

        public Boolean isEmpty { get; set; }

    } 

    public class HierarchyConfigurationDetail {

        @AuraEnabled public String objectAPIName { get; set; }

        @AuraEnabled public String displayIconName { get; set; }

        @AuraEnabled public String qualifyingCriteria {get;set;}
        
        @AuraEnabled public String qualifyingCriteriaName {get;set;}

        @AuraEnabled public Boolean enableNotifications {get;set;}
        
        @AuraEnabled public String notificationCriteriaId {get;set;}

        @AuraEnabled public String notificationCriteriaName {get;set;}

        @AuraEnabled public String notificationCriteriaCondition {get;set;}

        @AuraEnabled public List<Adm.Expression> expressions { get; set; }
    }

    public virtual class AssetHierarchySearch {
        @AuraEnabled
        public String searchTerm { get; set; }

        @AuraEnabled
        public Id assetHierarchyId { get; set; }

        @AuraEnabled
        public Id recordId { get; set; }

        @AuraEnabled
        public Id actualRootId { get; set; }

        @AuraEnabled
        public String hierarchyType { get; set; }

    }
}