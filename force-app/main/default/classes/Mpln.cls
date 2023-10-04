/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across Maintenance Plan Template feature.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          08 Apr 2021     Created.
 *              Manish Kushwah          16 Apr 2021     Added new wrapper class ProductInformation.
 *              Jaysukh Patel			10 May 2021.    Added new wrapper class MaintenanceAsset
 *              Manish Kushwah          11 May 2021     Added new wrapper class AssetInformation - A360AM-556
 * A360AM-572   Manish Kushwah          21 May 2021     Added new wrapper class MaintenancePlanRequest and changed class name from MaintenanceAsset to MaintenanceAssetInformation
 * A360AM-370   Jaysukh Patel           26 Jul 2021     Added new wrapper class MaintenanceAssetRequest to support multiple paramter
 *                                                      Added new variable includeChildAssets in class MaintenanceAssetRequest
 *****************************************************************************************************/
public with sharing class Mpln {

    /**
     * Base MP Template record wrapper
     */
    public virtual class MplnTemplateRecord {
        
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
     * Wrapper class to hold Applicable Product records associated to the Maintenace Plan Template. 
     */
    public class ApplicableProduct extends MplnTemplateRecord {

        // Associated Maintenance Plan Template Id
        @AuraEnabled public String maintenancePlanTemplateId {get;set;}

        // Associated Maintenance Plan Template Name
        @AuraEnabled public String maintenancePlanTemplateName {get;set;}

        // Associated Work Type Id
        @AuraEnabled public String workTypeId {get;set;}

        // Associated Work Type Name
        @AuraEnabled public String workTypeName {get;set;}

        // Product Family for the Template
        @AuraEnabled public String productFamily {get;set;}

        // Associated Product Id
        @AuraEnabled public String productId {get;set;}
        
        // Associated Product name
        @AuraEnabled public String productName {get;set;}
    }

    /**
     * Wrapper class to hold Work Rule Template records associated to the Maintenace Plan Template. 
     */
    public class WorkRuleTemplate extends MplnTemplateRecord {

        // Associated Maintenance Plan Template Id
        @AuraEnabled public String maintenancePlanTemplateId {get;set;}

        // Associated Maintenance Plan Template Name
        @AuraEnabled public String maintenancePlanTemplateName {get;set;}

        // Associated Applicable Product Id
        @AuraEnabled public String applicableProductId {get;set;}

        // Associated Applicable Product Name
        @AuraEnabled public String applicableProductName {get;set;}

        // Associated Work Type Id
        @AuraEnabled public String workTypeId {get;set;}

        // Associated Work Type Name
        @AuraEnabled public String workTypeName {get;set;}

        // Indicate the type of Work Rule Template
        @AuraEnabled public String templateType {get;set;}

        // Recurrence Pattern
        @AuraEnabled public String recurrencePattern {get;set;}

        // Sort Order
        @AuraEnabled public Integer sortOrder {get;set;}

        // Indicate the type of Work Rule: Calender or Criteria Based
        @AuraEnabled public String type {get;set;}

        // Associated Recordset Filter Criteria Id
        @AuraEnabled public String recordsetFilterCriteriaId {get;set;}

        // Associated Recordset Filter Criteria Display Name
        @AuraEnabled public String recordsetFilterCriteriaName {get;set;}
    }

    /**
     * Wrapper class to hold Product information. 
     */
    public class ProductInformation {

        // Product id
        @AuraEnabled public String id {get;set;}

        // Product name
        @AuraEnabled public String name {get;set;}

        // Product Family
        @AuraEnabled public String productFamily {get;set;}

        // Indicate Product is active or not
        @AuraEnabled public Boolean isActive {get;set;}

        // Product Description
        @AuraEnabled public String description {get;set;}
    }

    /**
     * Wrapper class to hold Maintenance Asset information 
     */
    public class MaintenanceAssetInformation {

        //Associated Asset salesforce ID 
        @AuraEnabled public String id;
        
        //Associated Maintenenace Tempalte Id
        @AuraEnabled public String mplnTemplateId;

        //Associated Asset salesforce ID 
        @AuraEnabled public String assetId;
        
        //Associated Asset Name
        @AuraEnabled public String assetName;

        //Associated Product Id
        @AuraEnabled public String productId;
        
        //Associated WorkType salesforce Id
        @AuraEnabled public String workTypeId;
        
        //Associated Work Type Name
        @AuraEnabled public String workTypeName;
	
	//ApplicableProduct associated to workrule
        @AuraEnabled public String applicableProduct;
        
        // Date of the first work order in the next batch
        @AuraEnabled public Date nextSuggestedMaintenanceDate;

        //Associated Work Rules
        @AuraEnabled public List<WorkRuleInformation> workRules;
    }
    
    /**
     * Wrapper class to hold Asset information. 
     */
    public class AssetInformation {

        // Asset id
        @AuraEnabled public String id {get;set;}

        // Asset name
        @AuraEnabled public String name {get;set;}

        // Asset's Account Id
        @AuraEnabled public String accountId {get;set;}

        // Asset's Account Name
        @AuraEnabled public String accountName {get;set;}

        // Asset's Serial Number
        @AuraEnabled public String serialNumber {get;set;}

        // Asset's Status
        @AuraEnabled public String status {get;set;}

        // Asset's ProductId
        @AuraEnabled public String productId {get;set;}
    }

    /*
    * Wrapper class for request which will be used for Maintenance Plan and its related objects records creation
    */
    public class MaintenancePlanRequest {

        // Source Record Id for which Maintenance Plan needs to be created
        @AuraEnabled public String sourceRecordId;

        // MP Template Id which will be used for Maintenance Plan creation
        @AuraEnabled public String templateId;

        // Maintenance Plan record which will be created
        @AuraEnabled public MaintenancePlan maintenancePlanRecord;

        // Associated Maintenance Asset records which will be created
        @AuraEnabled public List<MaintenanceAsset> maintenanceAssetRecords;
    }

    public class MaintenanceAssetRequest {

        //MP Template Id which will be used for Maintenance Plan creation
        @AuraEnabled public String templateId;

        // Source Record Id for which Maintenance Plan needs to be created
        @AuraEnabled public String sourceRecordId;

        //Asset status to be include to create Maintenance Plan
        @AuraEnabled public List<String> assetStatusValues;

        // Is need to include child asset
        @AuraEnabled public Boolean includeChildAssets;

        //criteria to filter assets
        @AuraEnabled public String assetCriteria;

    }

    public class MaintenanceWorkRuleRequest {

        //MP Template Id which will be used for Maintenance Plan creation
        @AuraEnabled public String templateId;

        //List of selected assets productIds
        @AuraEnabled public List<String> productIds;
    }

    public class TechnicalAttributeInfo {
        //Id of Technical Attribute
        @AuraEnabled public String id;

        //Name of Technical Attribute
        @AuraEnabled public String name;

        //Datatype of Technical Attribute
        @AuraEnabled public String dataType;

        //Default value for Technical Attribute
        @AuraEnabled public String defaultValue;

        //picklist values Technical Attribute
        @AuraEnabled public List<String> picklistValues;

    }

    public class  ProductWorkRuleInfo {

        //Asset's Product Id
        @AuraEnabled public String productId;

        //Product name
        @AuraEnabled public String productName;
	
	    //Applicable ProductId associated to workrule
        @AuraEnabled public String applicableProduct;
        
        //List of work rule information
        @AuraEnabled public List<WorkRuleInformation> workRuleInformation;
    }
    
    public class WorkRuleInformation {	
    	
	//WorkRule Id
        @AuraEnabled public String workRuleId;
	
        //WorkRule Title
        @AuraEnabled public String workRuleTitle;

        //workType associated to workrule
        @AuraEnabled public String workTypeId;

        //workType associated to workrule
        @AuraEnabled public String workType;

        //Sort Order
        @AuraEnabled public Decimal sortOrder ;

        //Advanced Expression
        @AuraEnabled public String advancedExpression;
	
	    //Attribute Template
        @AuraEnabled public String attributeTemplate;

        //asset conditions associated to workrule
         @AuraEnabled public List<ConditionTypeInfo> detail;

    }

    public class ConditionTypeInfo {
	
	//Asset Condition RecordId
        @AuraEnabled public String id;
	
        //Asset Condition type like Frequecny/time/criteria
        @AuraEnabled public String conditionType;

        //used to form Condition Defination
        @AuraEnabled public String conditionDefination;

        //used to store condition index
        @AuraEnabled public Integer sequence;

        //used to store criteria object details
        @AuraEnabled public CriteriaInfo criteria;

        //used to store frequency object details
        @AuraEnabled public FrequencyInfo frequency;

        //used to store recurrence pattren
        @AuraEnabled public String recurrenceRule;
    }

    public virtual class CriteriaInfo {

        //operator selected for asset condition
        @AuraEnabled public String operator;

        //attribute selected on add workrule
        @AuraEnabled public String attribute;

        //attribute selected on add workrule
        @AuraEnabled public String attributeName;

        //attribute value(operand) selected on add workrule
        @AuraEnabled public String attributeValue;

        //attribute datatype selected on add workrule
        @AuraEnabled public String attributeDatatype;

        //attribute to store lookup label to display lookupname on UI
        @AuraEnabled public String attributeLookUpLabel;

        //attribute datatype selected on add workrule
        @AuraEnabled public String attributeCategory;

        //threshold selected on add workrule
        @AuraEnabled public Decimal threshold;    
    }

    public class FrequencyInfo extends CriteriaInfo {

        //startAt captured on add workrule
        @AuraEnabled public String startAt;

        //stopat captured on add workrule
        @AuraEnabled public String stopAt;
    }
}