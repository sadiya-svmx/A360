/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all Technical attribute modules.
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID         Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1907   Mahima Tarika        14 July 2022      Created.
 A360AM-1859   Jeevika Rao          1 August 2022     Included dynamic field names and enum for Technical Attributes
 *****************************************************************************************************/
public class TechAttr {
    
    //Static string const to hold source record Id field name.
    public final static String assetSourceRecordId      = 'SVMXA360__AssetId__c'; 

    //Static string const to hold Technical Attribute Lookup field name.
    public final static String AttributeIdField           = 'SVMXA360__AttributeId__c';

    //Static string const to hold Template Item Lookup field name.
    public final static String TemplateItemField           = 'SVMXA360__TemplateItemId__c';

    //Static string const to hold Captured By field name.
    public final static String CapturedByField               = 'SVMXA360__CapturedBy__c';  
    
    //Static string const to hold Captured On field name.
    public final static String CapturedOnField           = 'SVMXA360__CapturedOn__c';

    //Static string const to hold source field name.
    public final static String SourceField            = 'SVMXA360__Source__c';

    //Static string const to hold value field name where the technical attribute value will be stored.
    public final static String ValueField            = 'SVMXA360__Value__c';
    
    //Static string const to hold previous value field name
    public final static String PreviousValueField  = 'SVMXA360__PreviousValue__c';
    
    //Static string const to hold Previous Captured By field name.
    public final static String PreviousCapturedByField  = 'SVMXA360__PreviousCapturedBy__c';
    
    //Static string const to hold Previous Captured On field name.
    public final static String PreviousCapturedOnField  = 'SVMXA360__PreviousCapturedOn__c';
    
    //Static string const to hold Boolean Value field name.
    public final static String BooleanValueField  = 'SVMXA360__BooleanValue__c';
    
    //Static string const to hold Previous Boolean Value field name.
    public final static String PreviousBooleanValueField  = 'SVMXA360__PreviousBooleanValue__c';
    
    //Static string const to hold Number Value field name.
    public final static String NumberValueField  = 'SVMXA360__NumberValue__c';
    
    //Static string const to hold Previous Number Value field name.
    public final static String PreviousNumberValueField  = 'SVMXA360__PreviousNumberValue__c';
    
    //Static string const to hold Date Value field name.
    public final static String DateValueField  = 'SVMXA360__DateValue__c';
    
    //Static string const to hold Previous Date Value field name.
    public final static String PreviousDateValueField  = 'SVMXA360__PreviousDateValue__c';
    
    //Static string const to hold Datetime Value field name.
    public final static String DatetimeValueField  = 'SVMXA360__DatetimeValue__c';
    
    //Static string const to hold Previous Datetime Value field name.
    public final static String PreviousDatetimeValueField  = 'SVMXA360__PreviousDatetimeValue__c';
    
    //Static string const to hold Source Record Id field name.
    public final static String SourceRecordIdField  = 'SVMXA360__SourceRecordId__c';
    
    //Static string const to hold Work order Id field name.
    public final static String WorkorderIdField  = 'SVMXA360__WorkOrderId__c';

    //Static string const to hold Time of Occurence field name.
    public final static String TimeofOccurenceField  = 'SVMXA360__TimeOfOccurrence__c';

    //Static string const to hold Last Occurence field name.
    public final static String LastOccurenceField  = 'SVMXA360__LastOccurrence__c';

    
    /**
     * Attributes field name enum.
     */
    public enum AttributeField {
        SourceRecord,
        Attribute,
        TemplateItem,
        CapturedBy,
        CapturedOn,
        Source,
        Value,
        PreviousValue,
        PreviousCapturedBy,
        PreviousCapturedOn,
        BooleanValue,
        PreviousBooleanValue,
        NumberValue,
        PreviousNumberValue,
        DateValue,
        PreviousDateValue,
        DatetimeValue,
        PreviousDatetimeValue,
        SourceRecordId,
        WorkorderId,
        TimeofOccurence,
        LastOccurence
    }
    
    
    /**
     * Technical Attributes field enum to field name map consumed by services to upload Attributes
     */
    public static final Map<AttributeField, String> AttributeFields = new Map<AttributeField, String> {

        //AttributeField.sourceRecord                  => AssetIdField,
        AttributeField.Attribute            => AttributeIdField,
        AttributeField.TemplateItem         => TemplateItemField,
        AttributeField.CapturedBy           => CapturedByField,
        AttributeField.CapturedOn           => CapturedOnField,
        AttributeField.Source               => SourceField,
        AttributeField.Value                => ValueField,
        AttributeField.PreviousValue        => PreviousValueField,
        AttributeField.PreviousCapturedBy   => PreviousCapturedByField,
        AttributeField.PreviousCapturedOn   => PreviousCapturedOnField,
        AttributeField.BooleanValue         => BooleanValueField,
        AttributeField.PreviousBooleanValue => PreviousBooleanValueField,
        AttributeField.NumberValue          => NumberValueField,
        AttributeField.PreviousNumberValue  => PreviousNumberValueField,
        AttributeField.DateValue            => DateValueField,
        AttributeField.PreviousDateValue    => PreviousDateValueField,
        AttributeField.DatetimeValue        => DatetimeValueField,
        AttributeField.PreviousDatetimeValue=> PreviousDatetimeValueField,
        AttributeField.SourceRecordId       => SourceRecordIdField,
        AttributeField.WorkorderId          => WorkorderIdField,
        AttributeField.TimeofOccurence      => TimeofOccurenceField,
        AttributeField.LastOccurence        => LastOccurenceField
    };
    
    /**
     * Public method to retrieve Technical Attributes field map.
     */
    public static Map<AttributeField, String> getAttributeFieldsMap( final String sourceObjectName ) {

        Map<AttributeField, String> attributeFieldsMap = new Map<AttributeField, String>();

        // Retrieve configured fields by source object name.
        switch on sourceObjectName.toLowerCase() {

            when 'asset' {
                attributeFieldsMap.putAll( TechAttr.AttributeFields );
                attributeFieldsMap.put( AttributeField.sourceRecord, assetSourceRecordId );
            }
            /* when 'opportunity' {
                
            }*/
            when else {
                attributeFieldsMap.putAll( TechAttr.AttributeFields );
            }
        }

        return attributeFieldsMap;
    }
    

    /**
     * Base TA  record wrapper
     * TA- Technical Attribute
     */
    public virtual class TARecord {
        
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
    * Wrapper class to hold Technical Attribute's Template records. 
    */
    public class TechnicalAttributeTemplate extends TARecord{
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public string description {get;set;}
        @AuraEnabled public String createdBy {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Template Item records. 
    */
    public class TemplateItem extends TARecord{
        @AuraEnabled public String templateId {get;set;}
        @AuraEnabled public String templateName {get;set;}
        @AuraEnabled public String categoryId {get;set;}
        @AuraEnabled public String categoryName {get;set;}
        @AuraEnabled public String technicalAttribute {get;set;}
        @AuraEnabled public String technicalAttributeName {get;set;}
        @AuraEnabled public String defaultValue {get;set;}
        @AuraEnabled public Boolean isReadonly {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public Double maximumValue {get;set;}
        @AuraEnabled public Double minimumValue {get;set;}
        @AuraEnabled public string message {get;set;}
        @AuraEnabled public String helptext {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public string dateType {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute information. 
    */
    public class TechnicalAttribute extends TARecord {
        @AuraEnabled public String dataType {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String defaultValue {get;set;}
        @AuraEnabled public String unit {get;set;}
        @AuraEnabled public Double maximumValue {get;set;}
        @AuraEnabled public Double minimumValue {get;set;}
        @AuraEnabled public Boolean isReadonly {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String helptext {get;set;}
        @AuraEnabled public string description {get;set;}
        @AuraEnabled public Config.PicklistDefinition picklistDefinition {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Template Item information. 
    */
    public class TechnicalAttributeTemplateItem extends TARecord {
        @AuraEnabled public String attributeId {get;set;}
        @AuraEnabled public String attributeName {get;set;}
        @AuraEnabled public String categoryId {get;set;}
        @AuraEnabled public String defaultValue {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String helpText {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public Boolean isReadOnly {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public Double maximumValue {get;set;}
        @AuraEnabled public Double minimumValue {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String templateId {get;set;}
        @AuraEnabled public String dataType {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public String templateName {get;set;}
        @AuraEnabled public TechnicalAttribute technicalAttribute {get;set;}
        @AuraEnabled public AttributeRecord attributeRecord {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute value information for target object.
	* ex- Asset or Opportunity
    */
    public class AttributeRecord extends TARecord {        
        @AuraEnabled public String parentRecordId {get;set;}
        @AuraEnabled public String templateItemId {get;set;}
        @AuraEnabled public String attributeId {get;set;}
        @AuraEnabled public String attributeDataType {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String previousValue {get;set;}
        @AuraEnabled public String source {get;set;}
        @AuraEnabled public DateTime capturedOn {get;set;}
        @AuraEnabled public String capturedBy {get;set;}
        @AuraEnabled public DateTime previousCapturedOn {get;set;}
        @AuraEnabled public String previousCapturedBy {get;set;}
        @AuraEnabled public Boolean booleanValue {get;set;}
        @AuraEnabled public Boolean previousBooleanValue {get;set;}
        @AuraEnabled public Double numberValue {get;set;}
        @AuraEnabled public Double previousNumberValue {get;set;}
        @AuraEnabled public Date dateValue {get;set;}
        @AuraEnabled public Date previousDateValue {get;set;}
        @AuraEnabled public DateTime datetimeValue {get;set;}
        @AuraEnabled public DateTime previousDatetimeValue {get;set;}
        @AuraEnabled public String sourceRecordId {get;set;}
        @AuraEnabled public String workorderId {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Category information.
    */
    public class TechnicalAttributeCategory extends TARecord {
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public String templateId {get;set;}
        @AuraEnabled public List<TechnicalAttributeTemplateItem> technicalAttributeTemplateItems {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Template Category Items information. 
    */
    public class TechAttrTemplateCategorySequence extends TARecord{
        @AuraEnabled public String categoryId {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Template Categories with items and sequence information. 
    */
    public class TechnicalAttributeTemplateCategories {
        @AuraEnabled public List<TechnicalAttributeCategory> techAttrTemplateCategories {get;set;}
        @AuraEnabled public String templateId {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Template Association information. 
    */
    public class TechAttrTemplateAssociation extends TARecord {
        @AuraEnabled public String productId {get;set;}
        @AuraEnabled public String productFamily {get;set;}
        @AuraEnabled public String templateId {get;set;}
        @AuraEnabled public Map<String, String> customFieldValueMap {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute Template Association List information. 
    */
    public class TechAttrTemplateAssociationList {
        @AuraEnabled public List<TechAttrTemplateAssociation> templateAssociations {get;set;}
    }

    /**
    * Wrapper class to hold reference records of Technical Attribute. 
    */
    public class TechnicalAttributeReference extends TARecord {

        @AuraEnabled public List<TemplateItem> relatedTemplates {get;set;}

        @AuraEnabled public List<Adm.LookupInfo> relatedAssetTechnicalAttributes {get;set;}

        @AuraEnabled public List<Adm.LookupInfo> relatedUserGroups {get;set;}

    }

    /**
     * Wrapper structure to hold list of records and total record count informations for lazy loading.
     * TA - TechnicalAttributes
     */
    public class TechnicalAttributes {
        @AuraEnabled public Integer totalRecordCount { get; set; }

        @AuraEnabled public List<TechnicalAttribute> technicalAttributeList { get; set; }
    }
    
    /**
     * Wrapper structure to hold list of match Rule details - like master rule id, field API name, operand object etc..
     */
    
    public class TemplateMatchRuleDetails extends TARecord {
        @AuraEnabled public String masterRuleid {get; set;}
        @AuraEnabled public String fieldType {get;set;}
        @AuraEnabled public String objectApiName {get;set;}
        @AuraEnabled public String fieldApiName {get;set;}
        @AuraEnabled public Object value {get;set;}
        @AuraEnabled public String operandObject {get;set;}
        @AuraEnabled public List<String> referenceFieldApiNames {get;set;}
    }
    
    /*
    * Wrapper class to hold Asset Attribute RecordList. 
    */
    public class AttributeRecordList {
        @AuraEnabled public String requestSource {get;set;}
        @AuraEnabled public String sourceObjectName {get;set;}
        @AuraEnabled public String targetObjectName {get;set;}
        @AuraEnabled public List<AttributeRecord> attributeRecords {get;set;}
    }

    /*
    * Wrapper class to hold Asset Attribute History RecordList. 
    */
    public class AttributeHistoryRequest {
        @AuraEnabled public String attributeId {get;set;}
        @AuraEnabled public String sourceObjectName {get;set;}
    }

    /*
    * Wrapper class to hold Asset Attribute History RecordList. 
    */
    public class AttributeHistory {
        @AuraEnabled public String attributeId {get;set;}
        @AuraEnabled public List<AttributeHistoryDetail> attributeHistoryDetailList {get;set;}
    }

    /*
    * Wrapper class to hold Asset Attribute History Details. 
    */
    public class AttributeHistoryDetail {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String parentId {get;set;}
        @AuraEnabled public String field {get;set;}
        @AuraEnabled public String dataType {get;set;}
        @AuraEnabled public Boolean isDeleted {get;set;}
        @AuraEnabled public String oldValue {get;set;}
        @AuraEnabled public String newValue {get;set;}
        @AuraEnabled public String createdById {get;set;}
        @AuraEnabled public String createdByName {get;set;}
        @AuraEnabled public DateTime createdDate {get;set;}
        @AuraEnabled public String technicalAttributeId {get;set;}
    }

    public class AttributeHistoryFilter { //Wrapper for filters
        @AuraEnabled public string objectId {get;set;} //This will hold record id of the source record for which the asset attribute history is being viewed like assetRecordId.
        @AuraEnabled public string objectName {get;set;}
        @AuraEnabled public dateTime startDate {get;set;}
        @AuraEnabled public dateTime endDate {get;set;}
        @AuraEnabled public integer rowlimit {get;set;}
        @AuraEnabled public list<String> attributeIdList {get;set;}
    }

    /**
    * Wrapper class to hold User Group Information. 
    */
    public class UserGroup extends TARecord {
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public string description {get;set;}
        @AuraEnabled public Boolean active {get;set;}
    }

    /**
    * Wrapper class to hold User Group Technical Attribute Information. 
    */
    public class UserGroupTechnicalAttribute extends TARecord {
        @AuraEnabled public String technicalAttributeId {get;set;}
        @AuraEnabled public UserGroup userGroup {get;set;}
    }
    
    public class TechnicalAttributeRequest extends SVMXA360.TechnicalAttributeRequest {
        @AuraEnabled public String assetIdentifierFieldAPIName {get;set;}
    }
    
    public class TechnicalAttributeData extends SVMXA360.TechnicalAttributeData {
        
        @AuraEnabled public List<LastOccurrenceTime> lastOccurrenceTimeList {get;set;}
        @AuraEnabled public List<AssetIdentifier> assetIdentifiers {get;set;}
    }
    
    public class AssetIdentifier {
        @AuraEnabled public String identifierName {get;set;}
        @AuraEnabled public String value {get;set;}
    }

    public class LastOccurrenceTime {
        @AuraEnabled public String timeOfOccurence {get;set;}
        @AuraEnabled public String value {get;set;}
    }

    public class LastOccurrenceTimeValue {
        @AuraEnabled public DateTime timeOfOccurence {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    
}