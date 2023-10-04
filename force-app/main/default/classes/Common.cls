/******************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace have definitions which are consumed across all classes.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/******************************************************************************************************
 *    ID        	Name                    Date            Comment
 ******************************************************************************************************
 *              	Ramachandra Mohan       12 May 2020     Created.
 * A360APP-15   	Ramachandra Mohan       21 Oct 2020     Updated User object in whitelist.
 * A360ADM-442  	Ramachandra Mohan       24 Oct 2020     Removed User object from whitelist.
 * A360TOOL-86  	Ramachandra Mohan       27 Oct 2020     Added Entitlement object in whitelist.
 * A360ENG-886  	Jason Bradley           25 Feb 2021     Added EntityDefinition.fieldDefinitionsByApiName.
 * A360TOOL-404 	Ramachandra Mohan       01 Mar 2021     Added Service Appointment object in whitelist.
 * A360ENG-1000 	Sachin S                27 Apr 2021     Added FieldDefinition.compountFieldName.
 * A360TOOL-535 	Ramachandra Mohan       06 Jun 2021     Added english in supported language.
 * A360AM-1098  	Ramachandra Mohan       13 Jul 2021     Added Maintenance Asset to whitelist.
 * A360AM-1094  	Jaysukh Patel           03 Sep 2021     Extended global SvmxResponse to ServiceResponse 
 *                                                      and SvmxError to ServiceError
 * A360ADM-1657 	Ramachandra Mohan       12 Oct 2021     Change app usage default value to false.
 * A360TOOL-858 	Ramachandra Mohan       01 Dec 2021     New global settings to respect auto configurator status.
 * A360TOOL-1116 	Ramachandra Mohan		26 Apr 2022     Added ProductServiceCampaignItem to whitelist object.
 * A360TOOL-1271 	Ramachandra Mohan		13 Sep 2022     Added TimeSheet and TimeSheetEntry  to whitelist object.
 *****************************************************************************************************/
public class Common {
    
    public static final Set<String> BlacklistCustomObjects = new Set<String> {
        'svmxa360__conf_objectmapping__c',
        'svmxa360__conf_objectmappingdetail__c',
        'svmxa360__conf_expression__c',
        'svmxa360__conf_expressiondetail__c',
        'svmxa360__conf_layout__c',
        'svmxa360__conf_layoutsection__c',
        'svmxa360__conf_layoutelement__c',
        'svmxa360__conf_layoutrelatedsection__c',
        'svmxa360__conf_warrantyconfig__c',
        'svmxa360__conf_cset_globalproperties__c',
        'svmxa360__entitlementverificationhistory__c',
        'svmxa360__conf_entitlementrule__c',
        'svmxa360__conf_entitlementsettings__c',
        'svmxa360__conf_layout__c',
        'svmxa360__conf_layoutelement__c',
        'svmxa360__conf_layoutrelatedsection__c',
        'svmxa360__conf_layoutsection__c',
        'svmxa360__conf_adminpage__c',
        'svmxa360__conf_depotfinderrule__c',
        'svmxa360__conf_lookupconfiguration__c',
        'svmxa360__conf_processwizard__c',
        'svmxa360__conf_processwizardaccess__c',
        'svmxa360__conf_processwizardstep__c',
        'svmxa360__applicationlog__c',
        'svmxa360__conf_pscconfiguration__c',
        'svmxa360__pscenginelog__c',
        'svmxa360__conf_pricebookassignmentrule__c',
        'svmxa360__conf_entitledserviceassignmentrule__c',
		'svmxa360__conf_warrantyconfig__c',
        'svmxa360__entitledservicehistory__c',
        'svmxa360__conf_processstepparameter__c', 
        'svmxa360__conf_timelineconfigaccess__c',
        'svmxa360__conf_timelineconfigdetail__c',
        'svmxa360__conf_timelineconfig__c',
        'svmxa360__conf_servicemaxtags__c',
		'svmxa360__conf_spmevent__c',
		'svmxa360__conf_tagtranslation__c',
        'svmxa360__conf_hierarchyconfig__c',
        'svmxa360__conf_hierarchyconfigaccess__c',
        'svmxa360__conf_hierarchyconfigdetail__c',
        'svmxa360__conf_hierarchyfields__c'
    };

    public static final Set<String> WhitelistTaskFields = new Set<String> {
        'calldurationinseconds',
        'callobject',
        'calldisposition',
        'calltype',
        'description',
        'isrecurrence',
        'createdbyid',
        'createddate',
        'id',
        'lastmodifieddate',
        'activitydate',
        'email',
        'lastmodifiedbyid',
        'phone',
        'priority',
        'recurrenceinterval',
        'isreminderset',
        'recurrenceregeneratedtype',
        'status',
        'subject',
        'tasksubtype',
        'type',
        'whatid',
        'ownerid',
        'whoid'
    };

    public static final Set<String> WhitelistEventFields = new Set<String> {
        'isalldayevent',
        'createdbyid',
        'createddate', 
        'id',
        'lastmodifieddate',
        'activitydate',
        'description',
        'durationinminutes',
        'email',
        'enddatetime',
        'eventsubtype',
        'lastmodifiedbyid',
        'location',
        'phone',
        'isprivate',
        'isreminderset',
        'isrecurrence2',
        'showas',
        'startdatetime',
        'subject',
        'activitydatetime',
        'type',
        'whatid',
        'ownerid',
        'whoid'
    };
    
    public static final Map<String,String> DefaultAllowedCoreObjects = new Map<String,String> {
        'GP001' 					=> 'account',
        'GP002' 					=> 'asset',
        'GP003'						=> 'assetwarranty',
        'GP004' 					=> 'case',
        'GP005' 					=> 'contact',
        'GP006'						=> 'contractlineitem',
        'GP007'						=> 'expense',
        'GP008' 					=> 'location',
        'GP009' 					=> 'product2',
        'GP010'						=> 'productitem',
        'GP011' 					=> 'pricebook2',
        'GP012'						=> 'pricebookentry',
        'GP013'						=> 'productconsumed',
        'GP014'						=> 'producttransfer',
        'GP015'						=> 'productrequest',
        'GP016' 					=> 'productrequestlineitem',
        'GP017'						=> 'productwarrantyterm',
        'GP018' 					=> 'recordtype',
        'GP019'						=> 'returnorder',
        'GP020' 					=> 'returnorderlineitem',
        'GP021' 					=> 'shipment',
        'GP022'						=> 'servicecontract',
        'GP023'						=> 'warrantyterm',
        'GP024' 					=> 'workorder',
        'GP025' 					=> 'workorderlineitem',
        'GP026'						=> 'productrequired',
        'GP027'						=> 'worktype',
        'GP028'						=> 'opportunity',
        'GP029'						=> 'entitlement',
        'GP030'						=> 'productservicecampaign',
        'GP031'						=> 'serviceappointment',
        'GP032'						=> 'opportunitylineitem',
        'GP033'						=> 'assetrelationship',
        'GP034'						=> 'serviceresource',
        'GP035'						=> 'assetdowntimeperiod',
        'GP036'						=> 'maintenanceasset',
        'GP037'						=> 'workplan',
        'GP038'						=> 'workstep',
        'GP039'						=> 'productservicecampaignitem',
        'GP040'						=> 'timesheet',
        'GP041'						=> 'timesheetentry'
    };
        
    public static final Map<String,String> DefaultSupportedLanguages = new Map<String,String> {
        'GP500' 					=> 'fr',
        'GP501' 					=> 'ja',
        'GP502'						=> 'es',
        'GP503' 					=> 'it',
        'GP504' 					=> 'pt_BR',
        'GP505'						=> 'nl_NL',
        'GP506'						=> 'de',
        'GP507' 					=> 'fi',
        'GP508'						=> 'en_US',
		'GP509'						=> 'zh_CN'
    };
        
    public static final Map<String,String> DefaultAppUsageTrackingSettings = new Map<String,String> {
        'GP600' 					=> 'false',
        'GP605' 					=> ''
    };
    
    public static final Map<String,String> DefaultConfigurationUsageSettings = new Map<String,String> {
        'GP601'						=> 'ToDo', // Status
        'GP602'						=> '', // Success/Error message
        'GP603'						=> '', // Last executed timestamp
        'GP604'						=> '' // Sucessful last executed timestamp
    };
        
    public static final Map<String,String> DefaultApplicationConfigSettings = new Map<String,String> {
        'GP800' 					=> 'false',
        'GP801'						=> 'TODO',
        'GP802'						=> '',
        'GP803'						=> 'https://asset360tooling.servicemax.com'
    };
        
    public static final Map<String, List<String> > AllowedConfigCoreObjects = new Map<String, List<String> > {
        'Expression'		=> new List<String>{ 'Event', 'Task' },
        'AssetTimeline'     => new List<String>{ 'Event', 'Task' }
    };
    
    public static final Set<String> WhitelistStandardObjects = new Set<String>( CONF_CustomSettingsManager.getInstance().getAllowedCoreObjects() );
     
    /**
     * Wrapper to hold Global property custom settings
     */
    public virtual class GlobalProperty {
        
        // String instance variable to hold id from custom setting.
        @AuraEnabled public String id {get;set;}
        
        // String instance variable to hold key from custom setting.
        @AuraEnabled public String key {get;set;}
        
        // String instance variable to hold name from custom setting.
        @AuraEnabled public String name {get;set;}
        
        // String instance variable to hold value from custom setting.
        @AuraEnabled public String value {get;set;}
    }
    
    /**
     * A wrapper class used to populate service response.
     */
    public class ServiceResponse extends SvmxGlobal.SvmxResponse{
    }

    /**
     * A wrapper class used for Errors from Services.
     */
    public class ServiceError extends SvmxGlobal.SvmxError{
    }

    /**
     * A wrapper class used for Errors from Services.
     */
    public class ServiceErrorDetail {
        // String instance variable to hold error message detail .
        @AuraEnabled public String detail {get;set;}
    }

    /**
     * A wrapper class used for DML results.
     */
    public class DatabaseResult {

        // Instance variable to hold Sobject success results
        @AuraEnabled public List<SObject> sObjectList {get;set;}

        // Instance variable to hold DML errors
        @AuraEnabled public List<ServiceError> errors {get;set;}
    }
    
    public class ChildDefinition implements Comparable {
        
        // String instance variable to hold object label
        @AuraEnabled public String label {get;set;}
        
        // String instance variable to hold object API name.
        @AuraEnabled public String apiName {get;set;}
        
        // String instance variable to hold lookup field label
        @AuraEnabled public String lookupFieldLabel {get;set;}
        
        // String instance variable to hold lookup field name.
        @AuraEnabled public String lookupFieldName {get;set;}
        
        // Boolean instance variable to indicates custom object or not.
        @AuraEnabled public Boolean customLookupField {get;set;}
        
        // String instance variable to hold field relationship name.
        @AuraEnabled public String relationshipName {get;set;}

        public Integer compareTo( Object compareTo ) {
            return label.compareTo(((ChildDefinition) compareTo).label);
        }
    }

    public virtual class RecordType {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Stores name of RecordType
        @AuraEnabled public String name {get;set;}

        // Stores the developer Name of the RecordType 
        @AuraEnabled public String developerName {get;set;}
    }

    /**
     * Wrapper class to hold Remote site settings details. 
     */
    public class RemoteSiteSettingsDetails {

        // component dependency records
        @AuraEnabled public List<RemoteSiteSettings> records {get;set;}    
         
    }

    public virtual class RemoteSiteSettings {
        // Remote site settings Id
        @AuraEnabled public String id {get;set;}
        
        // Remote site settings name
        @AuraEnabled public String siteName {get;set;}

        // Remote site settings end point url
        @AuraEnabled public String endPointUrl {get;set;}

        // Remote site settings status
        @AuraEnabled public Boolean isActive {get;set;}
    }
    
    public class EntityDefinition implements Comparable {
        
        // String instance variable to hold object label
        @AuraEnabled public String label {get;set;}
        
        // String instance variable to hold object API name.
        @AuraEnabled public String apiName {get;set;}
        
        // Boolean instance variable to indicates custom object or not.
        @AuraEnabled public Boolean custom {get;set;}
        
        // List variable to hold list of Child relationships.
        @AuraEnabled public List<ChildDefinition> childDefinitions {get;set;}
            
        // List variable to hold list of field definitions.
        @AuraEnabled public List<FieldDefinition> fieldDefinitions {get;set;}

        // List variable to hold list of field definitions.
        @AuraEnabled public List<FieldSetDefinition> fieldSetDefinitions {get;set;}

        // Field definitions indexed by field api name (lower-cased)
        public transient Map<String, FieldDefinition> fieldDefinitionsByApiName {get;set;}

        // Map variable to hold map of recordTypeInfos
        @AuraEnabled public List<RecordTypeDefinition> recordTypeInfos {get;set;}
        
        public EntityDefinition(){
            fieldDefinitions = new List<FieldDefinition>();
            fieldDefinitionsByApiName = new Map<String, FieldDefinition>();
            childDefinitions = new List<ChildDefinition>();
            recordTypeInfos = new List<RecordTypeDefinition>();
            fieldSetDefinitions = new List<FieldSetDefinition>();
        }
        
        public Integer compareTo( Object compareTo ) {
            return label.compareTo(((EntityDefinition) compareTo).label);
        }
    }
    
    public class FieldDefinition implements Comparable {
        
        // String instance variable to hold field label
        @AuraEnabled public String label {get;set;}
        
        // String instance variable to hold field API name.
        @AuraEnabled public String apiName {get;set;}
        
        // String instance variable to hold field API name with namespace.
        @AuraEnabled public String localName {get;set;}
        
        // String instance variable to hold field data type.
        @AuraEnabled public String dataType {get;set;}
        
        // String instance variable to hold controller field name.
        @AuraEnabled public String controllerFieldName {get;set;}
        
        // Boolean instance variable to indicate dependent picklist field or not.
        @AuraEnabled public Boolean dependentPicklist {get;set;}
        
        // Boolean instance variable to indicate custom field or not.
        @AuraEnabled public Boolean custom {get;set;}
        
        // Boolean instance variable to indicate field is updateable or not.
        @AuraEnabled public Boolean updateable {get;set;}
        
        // Boolean instance variable to indicate field is createable or not.
        @AuraEnabled public Boolean createable {get;set;}
        
        // Boolean instance variable to indicate field is calculated or not.
        @AuraEnabled public Boolean calculated {get;set;}
        
        // Boolean instance variable to indicate field is filterable or not.
        @AuraEnabled public Boolean filterable {get;set;}
        
        // Boolean instance variable to indicate field is idLookup or not.
        @AuraEnabled public Boolean idLookup {get;set;}
        
        // Boolean instance variable to indicate field is unique or not.
        @AuraEnabled public Boolean unique {get;set;}
        
        // Boolean instance variable to indicate field is nillable or not.
        @AuraEnabled public Boolean nillable {get;set;}
        
        // Boolean instance variable to indicate field is nameField or not.
        @AuraEnabled public Boolean nameField {get;set;}
        
        // Boolean instance variable to indicate field is autoNumber or not.
        @AuraEnabled public Boolean autoNumber {get;set;}
        
        // Boolean instance variable to indicate field is htmlFormatted or not.
        @AuraEnabled public Boolean htmlFormatted {get;set;}
        
        // Integer instance variable to hold field length.
        @AuraEnabled public Integer length {get;set;}
        
        // Integer instance variable to hold field scale.
        @AuraEnabled public Integer scale {get;set;}
        
        // Integer instance variable to hold field digits.
        @AuraEnabled public Integer digits {get;set;}
        
        // Integer instance variable to hold field precision.
        @AuraEnabled public Integer precision {get;set;}
        
        // String instance variable to hold field relationship name if the field data type is reference.
        @AuraEnabled public String relationshipName {get;set;}
        
        // String instance variable to hold field reference Name Field if the field data type is reference.
        @AuraEnabled public List<String> referenceNameFields {get;set;}
        
        // String instance variable to hold reference object name if the field data type is reference.
        @AuraEnabled public List<String> referenceTo {get;set;}
            
        // List of picklist value if the field is of type picklist.
        @AuraEnabled public List<PicklistValue> picklistValues {get;set;}
            
        // String instance variable to hold compound field name for compound sub fields.
        @AuraEnabled public String compoundFieldName {get;set;}  

        public Integer compareTo( Object compareTo ) {
            return label.compareTo(((FieldDefinition) compareTo).label);
        }
    }

    public class FieldSetDefinition implements Comparable {
        @AuraEnabled public String apiName {get;set;}    
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String description {get;set;} //Optional, introduced for Designer 2.0
        
        public FieldSetDefinition(String apiName, String label, String description){
            this.apiName = apiName;
            this.label = label;
            this.description = description;
        }

        public Integer compareTo( Object compareTo ) {
            return label.compareTo(((EntityDefinition) compareTo).label);
        }
    }

    public class FlowDefinition implements Comparable {
        
        // String instance variable to hold field ActiveVersionId
        @AuraEnabled public String activeVersionId {get;set;}
        
        // String instance variable to hold field API name.
        @AuraEnabled public String apiName {get;set;}
        
        // String instance variable to hold field Builder
        @AuraEnabled public String builder {get;set;}
        
        // String instance variable to hold field Description
        @AuraEnabled public String description {get;set;}
        
        // String instance variable to hold field Durable Id
        @AuraEnabled public String durableId {get;set;}
        
        // String instance variable to hold field Installed Package Name
        @AuraEnabled public String installedPackageName {get;set;}
        
        // Boolean instance variable to indicate field is active or not.
        @AuraEnabled public Boolean isActive {get;set;}
        
        // Boolean instance variable to indicate field is out of date or not.
        @AuraEnabled public Boolean isOutOfDate {get;set;}
        
        // Boolean instance variable to indicate field is a template or not.
        @AuraEnabled public Boolean isTemplate {get;set;}
        
        // String instance variable to hold field Label
        @AuraEnabled public String label {get;set;}
        
        // String instance variable to hold field Latest Version Id
        @AuraEnabled public String latestVersionId {get;set;}
        
        // String instance variable to hold field Manageable State
        @AuraEnabled public String manageableState {get;set;}
        
        // String instance variable to hold field Namespace Prefix
        @AuraEnabled public String namespacePrefix {get;set;}
        
        // String instance variable to hold field Process Type.
        @AuraEnabled public String processType {get;set;}
        
        // String instance variable to hold field Trigger Type.
        @AuraEnabled public String triggerType {get;set;}
        
        public Integer compareTo( Object compareTo ) {
            return label.compareTo(((FlowDefinition) compareTo).label);
        }
    }

    /**
     * Wrapper class to hold LWC details. 
     */
    public class QuickActionDefinitionDetails {

        // LWC records
        @AuraEnabled public List<QuickActionDefinition> records {get;set;}    
         
    }

    /**
     * Wrapper class to hold QuickAction information. 
     */
    public class QuickActionDefinition {
        
        // Returns the unique ID for the action.
        @AuraEnabled public String id {get;set;}
        
        // The quick action label.
        @AuraEnabled public String label {get;set;}
        
        // The quick action name.
        @AuraEnabled public String name {get;set;}

        // The quick action type.
        @AuraEnabled public String type {get;set;}

        // The quick action targe object type.
        @AuraEnabled public String targetSobjectType {get;set;}

         // The quick action developername.
        @AuraEnabled public String developerName {get;set;}
        

    }

    public class UsageAnalytics {
        public String eventType {get;set;}
        public String type {get;set;}
        public String region {get;set;}
        public String timezone {get;set;}
        public String userType {get;set;}
        public String layoutDeveloperName {get;set;}
        public String headerObject {get;set;}
        public String childObjects {get;set;}
        public Integer childCount {get;set;}
        public Decimal wizardHandOverTime {get;set;}
        public Decimal layoutLoadTime {get;set;}
        public Decimal layoutSaveTime {get;set;} 
        public String layoutUsageType {get;set;} 
        public String layoutType {get;set;} 
        public String transactionType {get;set;} 
        public Integer dynamicSectionsCount {get;set;} 
        public Integer autoFillMappingCount {get;set;}
        public Integer contextualFilterCount {get;set;}
        public Boolean fieldSetUsage {get;set;}
        public Integer customButtonsCount {get;set;}
        public Integer numberOfFieldsInHeader {get;set;}
        public Integer numberOfFieldsInChild {get;set;}
        public String numberOfRecordsInChildTab {get;set;}
        public Integer numberOfRecordsAcrossChildren {get;set;}
        public Integer numberOfLookupsConfiguredInHeader {get;set;}
        public Integer numberOfLookupsConfiguredInChild {get;set;}
        public String organizationId {get;set;}
        public String recordId {get;set;}
        public String userId {get;set;}
        public String wizardStepId {get;set;}
        public String flowName {get;set;}

    }

    public class RecordTypeDefinition {
        // String instance variable to hold Developer Name
        @AuraEnabled public String developerName {get;set;}

        // String instance variable to hold Name
        @AuraEnabled public String name {get;set;}

        // String instance variable to hold RecordTypeId
        @AuraEnabled public String recordTypeId {get;set;}

        // Boolean instance variable to hold isActive
        @AuraEnabled public Boolean isActive {get;set;}

        // Boolean instance variable to hold isAvailable
        @AuraEnabled public Boolean isAvailable {get;set;}

        // Boolean instance variable to hold isDefaultRecordTypeMapping
        @AuraEnabled public Boolean isDefaultRecordTypeMapping {get;set;}

        // Boolean instance variable to hold isMaster
        @AuraEnabled public Boolean isMaster {get;set;}

    }
    
    public class PicklistValue {
        
        // String instance variable to hold pivklist label
        @AuraEnabled public String label {get;set;}
        
        // String instance variable to hold picklist value.
        @AuraEnabled public String value {get;set;}
    }
    
    /**
     * Wrapper class to hold Profile information. 
     */
    public class Profile {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // Profile description.
        @AuraEnabled public String description {get;set;}
        
        // Profile name
        @AuraEnabled public String name {get;set;}
        
        // The category of user license
        @AuraEnabled public String userType {get;set;}
        
        // ID of the UserLicense associated with this profile.
        @AuraEnabled public String userLicenseId {get;set;}

        // The timestamp for when the current user last viewed a record related to this profile.
        @AuraEnabled public Datetime lastReferencedDate {get;set;}

        // The timestamp for when the current user last viewed this profile.
        @AuraEnabled public Datetime lastViewedDate {get;set;}
        
    }

    /**
     * Wrapper class to hold LWC details. 
     */
    public class LWCRecordDetails {

        // LWC records
        @AuraEnabled public List<LWCRecord> records {get;set;}    
         
    }
    public class LWCRecord {

        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // LWC developer name
        @AuraEnabled public String developerName {get;set;}
        
        // LWC full name
        @AuraEnabled public String fullName {get;set;}
        
        // where LWC is exposed or not
        @AuraEnabled public Boolean isExposed {get;set;}

        // LWC master label
        @AuraEnabled public String masterLabel {get;set;}

        // LWC namespacePrefix
        @AuraEnabled public String namespacePrefix {get;set;}

        // LWC targetConfigs
        @AuraEnabled public String targetConfigs {get;set;}
         
    }

    /**
     * Wrapper class to hold LWC Resource details. 
     */
    public class LWCResourceDetails {

        // LWC Resource records
        @AuraEnabled public List<LWCResource> records {get;set;}    
         
    }
    public class LWCResource {

        // Salesforce lightningComponentBundleId 
        @AuraEnabled public String lightningComponentBundleId {get;set;}
        
        // LWC source details
        @AuraEnabled public String source {get;set;}
        
        // LWC format
        @AuraEnabled public String format {get;set;}

        // LWC ManageableState
        @AuraEnabled public String manageableState {get;set;} 

        // LWC FilePath
        @AuraEnabled public String filePath {get;set;} 
         
    }

    /**
    * Wrapper class to hold Flow Records 
    */
    public class FlowRecords {

        // Flow Page records
        @AuraEnabled public List<FlowRecord> records {get;set;}    
         
    }
    public class FlowRecord {

        // Flow id
        @AuraEnabled public String id {get;set;}
        
        // Flow Process Type
        @AuraEnabled public String processType {get;set;}
        
        // Flow Status
        @AuraEnabled public String status {get;set;}

        // Flow master label
        @AuraEnabled public String masterLabel {get;set;}

        // Flow last modified adte
        @AuraEnabled public Datetime lastModifiedDate {get;set;} 
         
    }

    /**
     * Wrapper class to hold component dependency details. 
     */
    public class ComponentDependencyDetails {

        // component dependency records
        @AuraEnabled public List<ComponentDependency> records {get;set;}    
         
    }

    /**
     * Wrapper class to hold component dependency. 
     */

    public class ComponentDependency {

        // salesfore metadataComponentName
        @AuraEnabled public String metadataComponentName {get;set;}
        
        // salesfore metadataComponentType
        @AuraEnabled public String metadataComponentType {get;set;}
        
        // salesfore RefMetadataComponentName
        @AuraEnabled public String refMetadataComponentName {get;set;}

        // salesfore RefMetadataComponentType
        @AuraEnabled public String refMetadataComponentType {get;set;}
        
        // salesfore metadataComponentId
        @AuraEnabled public String metadataComponentId {get;set;}

        // salesfore metadataComponentId
        @AuraEnabled public String refMetadataComponentId {get;set;}
         
    }

        /**
     * Wrapper class to hold Flexi Page Records 
     */
    public class FlexiPageRecords {

        // Flexi Page records
        @AuraEnabled public List<FlexiPageRecord> records {get;set;}    
         
    }
    public class FlexiPageRecord {

        // Flexi page id 
        @AuraEnabled public String id {get;set;}
        
        // Type
        @AuraEnabled public String type {get;set;}
        
        // Developer Name
        @AuraEnabled public String developerName {get;set;}

        // Master Label
        @AuraEnabled public String masterLabel {get;set;}

        // entity id
        @AuraEnabled public String entityDefinitionId {get;set;} 

        // last modified date
        @AuraEnabled public Datetime lastModifiedDate {get;set;} 
        
        // NamespacePrefix
        @AuraEnabled public String namespacePrefix {get;set;} 
         
    }

    /**
     * Wrapper class to hold Entity details. 
     */
    public class EntityDetails {
      
        @AuraEnabled public String objectAPIName {get;set;} 
        @AuraEnabled public String objectLabel {get;set;}    
      
    }

    /**
     * Supported developer name type enums.
     */
    public enum Application { Expression, ObjectMapping, ProcessWizard, ProcessWizardStep }

    public class UsageData {
        @AuraEnabled public String uniqueId {get;set;} 
        @AuraEnabled public String appName {get;set;} 
        @AuraEnabled public String actionRecordId {get;set;} 
        @AuraEnabled public String actionDeveloperName {get;set;} 
        @AuraEnabled public String actionName {get;set;} 
        @AuraEnabled public String sourceRecordId {get;set;} 
        @AuraEnabled public String objectApiName {get;set;} 
        @AuraEnabled public String status {get;set;} 
        @AuraEnabled public Long epochStartTime {get;set;} 
        @AuraEnabled public Long epochEndTime {get;set;} 
    }
    
    public class SforceSessionInfo {

        /** The acess token. */
        @AuraEnabled public String acessToken;
        
        /** The service endpoint. */
        @AuraEnabled public String serviceEndpoint;
    }

    public class StepUsageLog {
        @AuraEnabled public String uniqueId {get;set;} 
        @AuraEnabled public String sourceRecordId {get;set;} 
        @AuraEnabled public String stepId {get;set;} 
    }

    public class StepUsageLogRequest {
        @AuraEnabled public Boolean enabled {get;set;} 
        @AuraEnabled public String sourceRecordId {get;set;} 
        @AuraEnabled public String stepId {get;set;} 
    }

    public class RequestOption {
        @AuraEnabled public Boolean isCreateActivityLogs {get;set;} 
        @AuraEnabled public String operationType {get;set;} 
    }
}