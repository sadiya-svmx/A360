/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all ADM modules.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 *              Daniel Peter            29 June 2020    Updated.
 *              Soumyaranjan Pati       12th Jan 2021   Updated for PSC
 * A360CE-746   Ramachandra Mohan       28 Mar 2021     Include Fully Consumed Services.
 *              Adam Daw                02 June 2021    Include TimelineConfig Objects.
 * A360TOOL-818 Ramachandra Mohan       28 Oct 2021     Created validate result structure.
 *****************************************************************************************************/
public class Adm {

    /* public transaction variable to capture recent items */
    public static Boolean isRecentItemTransaction = false;
    
    /**
     * Base Hierarchy record wrapper
     */
    public virtual class AdmRecord {
        
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
     * Base ApplicationSetting record wrapper
     */
    public virtual class ApplicationSetting {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Record name
        @AuraEnabled public String name {get;set;}
        
        // Record last modified date.
        @AuraEnabled public String developerName {get;set;}
        
        // Record last modified user.
        @AuraEnabled public String settingValue {get;set;}

        // Record last modified user.
        @AuraEnabled public String module {get;set;}

        // Record last modified user.
        @AuraEnabled public String subModule {get;set;}

        @AuraEnabled public String ruleName {get; set;}
    }
    
    /**
     * Wrapper class to hold object mapping header informations. 
     */
    public virtual class ObjectMapping {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Object mapping name
        @AuraEnabled public String name {get;set;}
        
        // Object mapping type
        @AuraEnabled public String mappingType {get;set;}
        
        // Object mapping external Id
        @AuraEnabled public String developerName {get;set;}
        
        // Object mapping description.
        @AuraEnabled public String description {get;set;}
        
        // Object mapping description.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Object mapping last modified user.
        @AuraEnabled public String lastModifiedBy {get;set;}
        
        // Source Object API name from which the fields values to be assigned.
        @AuraEnabled public String sourceObjectAPIName {get;set;}
        
        // Target Object API name to which field values to be assigned
        @AuraEnabled public String targetObjectAPIName {get;set;}

        // message stores the query exception if any
        @AuraEnabled public String message {get;set;}
        
        // List of object mapping details which holds field mapping informations.
        @AuraEnabled public List<ObjectMappingDetail> objectMappingDetails {get;set;}

        // Stores header record Object name of the object mapping
        @AuraEnabled public String headerRecordObject {get;set;}
    }
    
    /**
     * Wrapper class to hold object mapping detail.
     */
    public class ObjectMappingDetail {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Supported mapping type is one of Field, Value & Function.
        @AuraEnabled public String mappingType {get;set;}
        
        // Field from which value to be assigned.
        @AuraEnabled public String sourceFieldAPIName {get;set;}
        
        // Field to which the value to be assigned.
        @AuraEnabled public String targetFieldAPIName {get;set;}
        
        // Field value when the mapping is of type Value & Function.
        @AuraEnabled public String value {get;set;}

        // Literal Field to which the value to be assigned.
        @AuraEnabled public String literalParameterAPIName {get;set;}

        // Field to store sequence of object details for related picklist value
        @AuraEnabled public String relatedObjectDetails {get;set;}

        // Field to store field reference label
        @AuraEnabled public String referenceFieldLabel {get;set;}

        // hasError will be true if detail has invalid field apiName
        @AuraEnabled public Boolean hasError {get;set;}

        // To store error
        @AuraEnabled public String errorMessage {get;set;}
    }

    public class ExpressionDetail {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Expression Id (Parent Id)
        @AuraEnabled public String expressionId {get;set;}
        
        // Stores Title of the Expression detail
        @AuraEnabled public String name {get;set;}
        
        // Stores field name of the Expression detail
        @AuraEnabled public String fieldAPIName {get;set;}
        
        // Stores operator of the Expression detail
        @AuraEnabled public String operator {get;set;}
        
        // Stores operand of the Expression detail
        @AuraEnabled public String operand {get;set;}

        // Stores sequence of the Expression detail
        @AuraEnabled public Integer sequence {get;set;}

        // Stores the operand type of the Expression detail
        @AuraEnabled public String operandType {get;set;}

        // Stores the field type of the Expression detail
        @AuraEnabled public String fieldType {get;set;}

        // Stores the relationship name from the source object
        @AuraEnabled public String relationshipName {get;set;}

        // Stores the relationship field API name on the target object
        @AuraEnabled public String relationshipFieldAPIName {get;set;}

        // Stores the related object details of the target object
        @AuraEnabled public String relatedObjectDetails {get;set;}

         //  Field to store field reference label
         @AuraEnabled public String referenceFieldLabel {get;set;}

        // Literal Field to which the value to be assigned.
        @AuraEnabled public String literalParameterAPIName {get;set;}

        // Stores the related object details of the literal object
        @AuraEnabled public String literalRelatedObjectDetails {get;set;}

        // Stores the source object name
        @AuraEnabled public String sourceObjectName {get;set;}
    }
    
    public virtual class Expression {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Stores Title of the Expression
        @AuraEnabled public String name {get;set;}
        
        // Stores Object name of the Expression
        @AuraEnabled public String objectAPIName {get;set;}
        
        // Stores Description of the Expression
        @AuraEnabled public String description {get;set;}
        
        // Stores Advanced expression
        @AuraEnabled public String advancedExpression {get;set;}

        // Stores selected tag values for expression
        @AuraEnabled public String selectedTagsValue {get;set;}

        // Stores the last modified date of the expression or detail
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Object mapping last modified user.
        @AuraEnabled public String lastModifiedBy {get;set;}

        // Stores the type of the expression 
        @AuraEnabled public String type {get;set;}

        // Stores the type of the expression 
        @AuraEnabled public String expressionType {get;set;}

        // Stores the developer Name of the expression 
        @AuraEnabled public String developerName {get;set;}

        // Stores the criteria of the expression 
        @AuraEnabled public String criteria {get;set;}  

        // Stores the expression details.
        @AuraEnabled public List<ExpressionDetail> expressionDetailList {get;set;}

        // Stores header record Object name of the Expression
        @AuraEnabled public String headerRecordObject {get;set;}
    }

    public virtual class ConfigurationFilter {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Stores Title of the configuration filter
        @AuraEnabled public String name {get;set;}
        
        // Stores Object name of the configuration filter
        @AuraEnabled public String objectAPIName {get;set;}

        // Stores the developer Name of the configuration filter 
        @AuraEnabled public String developerName {get;set;}

        // Stores the expression id associated with configuration filter 
        @AuraEnabled public String filterCriteriaId {get;set;}
    }

    public class ConfigurationUsage {

        // Configuration Usage Id
        @AuraEnabled public String id {get;set;}
        
        // Entity Type
        @AuraEnabled public String entityType {get;set;}

        // Entity Id
        @AuraEnabled public String entityId {get;set;}
        
        // Entity Name
        @AuraEnabled public String entityName {get;set;}

        // Entity Label
        @AuraEnabled public String entityLabel {get;set;}

        // Configuration id
        @AuraEnabled public String configurationId {get;set;} 
         
    }

    public virtual class ConfigFilterInputRecord {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Stores Title of the configuration filter
        @AuraEnabled public String screenType {get;set;}
    }

    public class Context {
        @AuraEnabled public String sObjectRecId {get;set;}
        @AuraEnabled public String expressionId {get;set;}
    }
    
    public virtual class PageLayout {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public Boolean launchDesigner {get;set;}
        @AuraEnabled public Boolean enableDebugMode {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean hideName {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String lastModifiedBy {get;set;}
        @AuraEnabled public String lastModifiedDate {get;set;}
        @AuraEnabled public PageHeader pageHeader {get;set;}        
        @AuraEnabled public List<PageDetail> lines {get;set;}
        @AuraEnabled public List<String> tags {get;set;}
    }

    public class PageHeader {
        @AuraEnabled public String objectAPIName {get;set;}
        @AuraEnabled public String sourceObjectAPIName {get;set;}
        @AuraEnabled public String applyMapping {get;set;} //Always Or Conditional
        @AuraEnabled public ExpressionBasedMapping expressionBasedMapping {get;set;} //Always Or Conditional
        @AuraEnabled public String fieldMapping {get;set;}
        @AuraEnabled public String fieldMappingName {get;set;}
        @AuraEnabled public String qualifyingCriteria {get;set;}
        @AuraEnabled public String screenType {get;set;}
        @AuraEnabled public String transactionType {get;set;}
        @AuraEnabled public String valueMapping {get;set;}
        @AuraEnabled public String valueMappingName {get;set;}
        @AuraEnabled public List<String> fieldSets {get;set;}
        @AuraEnabled public List<pageSection> sections {get;set;}
		@AuraEnabled public List<PageElement> elements {get;set;}
        @AuraEnabled public List<String> tags {get;set;}
    }

    public class PageSection {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean hideName {get;set;}
        @AuraEnabled public Integer columns {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public Boolean readOnly {get;set;}
        @AuraEnabled public String visibilityCriteria {get;set;}
        @AuraEnabled public String visibilityCriteriaName {get;set;}
        @AuraEnabled public String evaluationEvent {get;set;}
        @AuraEnabled public List<PageElement> elements {get;set;}
        
    }

    public class PageDetail {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String objectAPIName {get;set;}
        @AuraEnabled public String sourceObjectAPIName {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public Boolean addRow {get;set;}
        @AuraEnabled public Boolean deleteRow {get;set;}
        @AuraEnabled public Boolean readOnly {get;set;}
        @AuraEnabled public Boolean allowZeroLines {get;set;}
        @AuraEnabled public String sortBy {get;set;}
        @AuraEnabled public String presentationType {get;set;}
        @AuraEnabled public String controllerReferenceField {get;set;}
        @AuraEnabled public String sourceControllerReferenceField {get;set;}
        @AuraEnabled public String fieldMapping {get;set;}
        @AuraEnabled public String fieldMappingName {get;set;}
        @AuraEnabled public String valueMapping {get;set;}
        @AuraEnabled public String valueMappingName {get;set;}
        @AuraEnabled public List<String> fieldSets {get;set;}
        @AuraEnabled public String qualifyingCriteria {get;set;}
        @AuraEnabled public String qualifyingCriteriaName {get;set;}
        @AuraEnabled public String visibilityCriteria {get;set;}
        @AuraEnabled public String visibilityCriteriaName {get;set;}
        @AuraEnabled public String evaluationEvent {get;set;}
        @AuraEnabled public boolean selectableGrid {get;set;}
        @AuraEnabled public Integer extendedEditDisplayColumns {get;set;}
        @AuraEnabled public String multiAddSearchField {get;set;}
        @AuraEnabled public List<PageElement> elements {get;set;}
        @AuraEnabled public String applyValueMapping {get;set;} //Always Or Conditional
        @AuraEnabled public ExpressionBasedMapping expressionBasedValueMapping {get;set;} //Always Or Conditional

    }

    public class PageElement {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean readOnly {get;set;}
        @AuraEnabled public Boolean required {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public Integer row {get;set;}
        @AuraEnabled public Integer column {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String lookupConfigId {get;set;}
        @AuraEnabled public String lookupConfigName {get;set;}
        @AuraEnabled public String lookupContext {get;set;}
        @AuraEnabled public String lookupContextSource {get;set;}
        @AuraEnabled public String lookupMatchingField {get;set;}
        @AuraEnabled public String lookupConfigExpressionId {get;set;}
        @AuraEnabled public String formFillMappingId {get;set;}
        @AuraEnabled public String formFillMappingName {get;set;}
        @AuraEnabled public Boolean overrideLookupContext {get;set;}
		@AuraEnabled public String title {get;set;}
        @AuraEnabled public List<PageEvent> events {get;set;}
        @AuraEnabled public String applyMapping {get;set;} //Always Or Conditional
        @AuraEnabled public ExpressionBasedMapping expressionBasedMapping {get;set;} //Always Or Conditional
    }
    
    public class PageEvent {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String actionType {get;set;}
        @AuraEnabled public String actionTarget {get;set;} 
    }

    public class ExpressionBasedMapping {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String mappingType {get;set;}
        @AuraEnabled public List<ExpressionMappingRow> rows {get;set;}
    }

    public class ExpressionMappingRow {
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public String expressionId {get;set;}
        @AuraEnabled public String expressionName {get;set;}
        @AuraEnabled public String expressionDeveloperName {get;set;}
        @AuraEnabled public String mappingId {get;set;}
        @AuraEnabled public String mappingName {get;set;}
        @AuraEnabled public String mappingDeveloperName {get;set;}
    }
    
    public virtual class LookupConfig {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String basicFilterId {get;set;}
        @AuraEnabled public Expression basicFilter {get;set;}
        @AuraEnabled public Boolean defaultLookup {get;set;}
        @AuraEnabled public String displayFields {get;set;}
        @AuraEnabled public String searchFields {get;set;}
        @AuraEnabled public String extendedFields {get;set;}
        @AuraEnabled public String fieldToReturn {get;set;}
        @AuraEnabled public String objectAPIName {get;set;}
        @AuraEnabled public String defaultOperator {get;set;}
        @AuraEnabled public Integer recordsPerPage {get;set;}
        @AuraEnabled public String lastModifiedBy {get;set;}
        @AuraEnabled public String lastModifiedDate {get;set;}
        // Stores header record Object name of the lookup configuration
        @AuraEnabled public String headerRecordObject {get;set;}
    }

    public class SPMSettingInfo {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public boolean enableDebugMode {get; set;}
        @AuraEnabled public List<String> selectedProfileIds {get; set;}
    }
    
    /**
     * Wrapper class to hold entitlement base informations. 
     */
    public virtual class EntitlementBase {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Entitlement rule/settings name
        @AuraEnabled public String name {get;set;}
        
        // Unique developer name used as external id
        @AuraEnabled public String developerName {get;set;}
        
        // Object API name for which entitlement rule configured.
        @AuraEnabled public String objectAPIName {get;set;}
        
        // Entitlement rule covered by Account or Product
        @AuraEnabled public String coveredBy {get;set;}
        
        // Entitlement asset API name
        @AuraEnabled public String assetAPIName {get;set;}
        
        // Entitlement account API name
        @AuraEnabled public String accountAPIName {get;set;}
         
        // While performing entitlement check whether to include parent asset or not.
        @AuraEnabled public Boolean includeParentAsset {get;set;}
        
        // While performing entitlement check whether to include root asset or not.
        @AuraEnabled public Boolean includeRootAsset {get;set;}
        
        // While performing entitlement check whether to match account or not.
        @AuraEnabled public Boolean matchAccount {get;set;}
         
        // Entitlement last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Entitlement last modified by user.
        @AuraEnabled public String lastModifiedBy {get;set;}
        
        // Entitlement default billing type.
        @AuraEnabled public String defaultBillingType {get;set;}
    }
    
    /**
     * Wrapper class to hold entitlement rule informations. 
     */
    public virtual class EntitlementRule extends EntitlementBase {
        
        // Entitlement rule description
        @AuraEnabled public String description {get;set;}
        
        // Entitlement rule sequence
        @AuraEnabled public Integer sequence {get;set;}
        
        // Entitlement rule resolution method, one of Use Warranty/Use Contract/Multiple Coverage.
        @AuraEnabled public String resolutionMethod {get;set;}
        
        // Entitlement rule active status.
        @AuraEnabled public Boolean isActive {get;set;}
        
        // While performing entitlement check whether to consider warranties or not.
        @AuraEnabled public Boolean checkWarranties {get;set;}
        
        // While performing entitlement check whether to consider contracts or not.
        @AuraEnabled public Boolean checkContracts {get;set;}
        
        // While performing entitlement check whether to match contact or not.
        @AuraEnabled public Boolean matchContact {get;set;}
        
        // While performing entitlement check match configured warranty types.
        @AuraEnabled public String warrantyTypes {get;set;}

        // Entitlement rule qualification criteria.
        @AuraEnabled public Expression expression {get;set;}
    }
    
    /**
     * Wrapper class to hold entitlement settings informations. 
     */
    public class EntitlementSettings extends EntitlementBase {
        
        // Entitlement settings Scope
        @AuraEnabled public String Scope {get;set;} 
        
        // While performing entitlement check whether allow override settings or not.
        @AuraEnabled public Boolean allowOverrideSettings {get;set;}
        
        // While performing entitlement check whether to include futur entitlement or not.
        @AuraEnabled public Boolean futureEntitlements {get;set;}

        // While performing entitlement number of months shown in futur entitlement.
        @AuraEnabled public Decimal futureEntitlementDuration {get;set;}

        // While performing entitlement check whether to include expired entitlement or not.
        @AuraEnabled public Boolean expiredEntitlements {get;set;}

        // While performing entitlement number of months shown in Expired entitlement.
        @AuraEnabled public Decimal expiredEntitlementDuration {get;set;}

        // While performing entitlement check whether to include Fully Consumed Services or not.
        @AuraEnabled public Boolean fullyConsumedServices {get;set;}

        // While performing entitlement check whether to include On Hold Service contracts or not.
        @AuraEnabled public Boolean onHoldEntitlements {get;set;}
    }    

    /**
     * Wrapper class to hold common entitlement settings informations. 
     */
    public class CommonEntitlementSettings extends EntitlementBase {
        
        // When checked, will apply Entitled Service based on entitlement rule criteria.
        @AuraEnabled public Boolean assignEntitledService {get;set;} 

        // When Checked, if the the Entitled Service is populated on Case or Return Order, the corresponding Work Order Entitlement will be populated.
        @AuraEnabled public Boolean inheritServiceOnWorkOrder {get;set;}

        // When Checked, if the the Entitled Service is populated on Return Order from Case or Work Order, the corresponding Work Order Entitlement will be populated.
        @AuraEnabled public Boolean inheritServiceOnReturnOrder {get;set;}

        // Apply Service Contract and Asset Warranty Pricebook when it exists and apply Pricebook Assignment Rule when no pricebook is defined.
        @AuraEnabled public Boolean assignPricebook {get;set;}

        // Adjust Service Threshold (Visits) on Assignment
        @AuraEnabled public Boolean adjustServiceThreshold {get;set;}
        
        // Automatically increment or decrement Remaining Visit count when the Entitled Service is assigned to the selected object.
        @AuraEnabled public String adjustVisitCountAssignedObject {get;set;}
        
        // Apply Stack Ranking when multiple warranties or contracts are found during entitlement process.
        @AuraEnabled public Boolean applyStackRanking {get;set;}

        // API Name of contract field upon which stack ranking will be applied.
        @AuraEnabled public String contractStackRankingAPIName {get;set;}

        // The order in which stack ranking will be applied on contract field.
        @AuraEnabled public String contractStackRankingOrder {get;set;}

        // API Name of warranty field upon which stack ranking will be applied.
        @AuraEnabled public String warrantyStackRankingAPIName {get;set;}

        // The order in which stack ranking will be applied on warranty field.
        @AuraEnabled public String warrantyStackRankingOrder {get;set;}
    } 

    public class UserInfo {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String dateFormat {get;set;}
        @AuraEnabled public String timeZoneOffSet {get;set;}
        @AuraEnabled public String timeFormat {get;set;}
        @AuraEnabled public String thousandSepartor {get;set;}
        @AuraEnabled public String decimalSeparator {get;set;}
        @AuraEnabled public String userCurrency {get;set;}
        @AuraEnabled public String svmxNameSpace {get;set;}
        @AuraEnabled public String organizationId {get;set;}
        @AuraEnabled public String organizationName {get;set;}
        @AuraEnabled public String organizationType {get;set;}
        @AuraEnabled public String userLocale {get;set;}
        @AuraEnabled public String userType {get; set;}
        @AuraEnabled public String userTimeZoneName {get; set;}
        
    }
  
    /**
     * Wrapper class to hold Admin Pages
     */
    public virtual class AdminPage {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String pageType {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String targetType {get;set;}
        @AuraEnabled public String targetDeveloperName {get;set;}
        @AuraEnabled public String parameters {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public Boolean isActive {get;set;}
        @AuraEnabled public List<AdminPage> children {get;set;}
    }

    /**
     * Wrapper class to hold the Process Wizard Summary used by the Wizard List View
     */
    public class ProcessWizardSummary implements Comparable {
        
        // Wizard Object API Name.
        @AuraEnabled public String objectAPIName {get;set;}

        // Most Recent Datetime a wizard was changed for the Object
        @AuraEnabled public Datetime lastModifiedDate {get;set;}

        // Name of user who last modified a wizard for the Object.
        @AuraEnabled public String lastModifiedBy {get;set;}

        // Number of Active Wizards for the Object Name.
        @AuraEnabled public Integer activeWizards {get;set;}

        // Number of Inactive Wizards for the Object Name.
        @AuraEnabled public Integer inactiveWizards {get;set;}

        // Method to use for sorting this object in a List.
        public Integer compareTo( Object compareTo ) {
            return objectAPIName.compareTo(((ProcessWizardSummary) compareTo).objectAPIName);
        }
    }

    /**
     * Wrapper class to hold Process Wizard information.
     */
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public virtual class ProcessWizard {

        // True if the Wizard is active, otherwise false.
        @AuraEnabled public Boolean active {get;set;}
        
        // Description for the wizard.
        @AuraEnabled public String description {get;set;}

        // Unique developer name used as external id
        @AuraEnabled public String developerName {get;set;}

        // Salesforce record Id.
        @AuraEnabled public String id {get;set;}

        // Wizard last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}

        // Name of user who last modified the wizard.
        @AuraEnabled public String lastModifiedBy {get;set;}

        // Wizard name.
        @AuraEnabled public String name {get;set;}

        // Wizard Object API Name.
        @AuraEnabled public String objectAPIName {get;set;}

        // Wizard Scope.
        @AuraEnabled public String scope {get;set;}

        // Wizard sequence (order).
        @AuraEnabled public Integer sequence {get;set;}

        // Wizard Expression ID (criteria to run the wizard).
        @AuraEnabled public String expressionId {get;set;}

        // Wizard Expression Name (criteria to run the wizard).
        @AuraEnabled public String expressionName {get;set;}
        
        // Expression Developer Name (criteria to run the wizard).
        @AuraEnabled public String expressionDeveloperName {get;set;}

        // Reference Identifier - used by the API Requests and 
        //   Responses to map errors to specific request parameters.
        @AuraEnabled public String referenceId {get;set;} 

        // List of Steps for a Process Wizard.
        @AuraEnabled public List<ProcessStep> steps {get;set;}

        // List of Profiles for a Process Wizard.
        @AuraEnabled public List<ProcessAccess> access {get;set;}

        // Property to be used in the process wizard section of the record pages for visibility
        @AuraEnabled public Boolean isVisible {get;set;}

        // Property specifies process wizard record is modified or not 
        @AuraEnabled public Boolean isModified {get;set;}

        // Property specifies process wizard step dependency type
        @AuraEnabled public String stepDependencyType {get;set;}
    }

    /**
     * Wrapper class used in to save process wizards.
     */
    public class ProcessWizardSaveRequest {
        @AuraEnabled public List<ProcessWizard> wizards { get;set; }

        @AuraEnabled public List<String> objectAPINames { get; set; }
    }

    /**
     * Wrapper class to hold Process Step information. 
     */
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public class ProcessStep {

        // Salesforce record Id.
        @AuraEnabled public String id {get;set;}

        // Step last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}

        // Name of user who last modified the step.
        @AuraEnabled public String lastModifiedBy {get;set;}

        // Step Name.
        @AuraEnabled public String name {get;set;}

        // Namespace of the target object (ex: Flow).
        @AuraEnabled public String namespace {get;set;}

        // Unique value of the process the step executes (ex: Flow Id).
        @AuraEnabled public String target {get;set;}

        // Type of the Step (ex "Flow" or "Application").
        @AuraEnabled public String type {get;set;}

        // Salesforce ID for the Expression (criteria to display the step).
        @AuraEnabled public String expressionId {get;set;} 

        // Expression Name (criteria to display the step).
        @AuraEnabled public String expressionName {get;set;}
        
        // Expression Developer Name (criteria to display the step).
        @AuraEnabled public String expressionDeveloperName {get;set;}

        // Parent Wizard Salesforce record ID.
        @AuraEnabled public String processWizardId {get;set;} 

        // Reference Identifier - used by the API Requests and 
        //   Responses to map errors to specific request parameters.
        @AuraEnabled public String referenceId {get;set;}

        // Tooltip or Help Text for the Step
        @AuraEnabled public String helpText {get;set;}

        // Step sequence (order).
        @AuraEnabled public Integer sequence {get;set;}

        // Action to take when the criteria doesn't match the step (Ex: Disable or Hide)
        @AuraEnabled public String criteriaAction {get;set;}

        // Help text to display when the criteria doesn't match the step
        @AuraEnabled public String criteriaActionHelpText {get;set;}

        // Property to be used in the process wizard section of the record pages for visibility
        @AuraEnabled public Boolean isVisible {get;set;}

        // Property to be used in the Process wizard step to decide whether to launch the flow as modal
        @AuraEnabled public Boolean openAsModal {get;set;}

        // List of Steps for a Process Wizard.
        @AuraEnabled public List<ProcessStepParameter> stepParameters {get;set;}  

        // Property specifies process wizard step record is modified or not 
        @AuraEnabled public Boolean isModified {get;set;}
      
        @AuraEnabled public String iconName {get;set;}

        // Property to hold Wizard Dependent flag value.
        @AuraEnabled public Boolean stepDependencyFlag {get;set;}

        // Property to hold Wizard Dependent steps in semicolon delimited value.
        @AuraEnabled public List<DependentStep> dependentSteps {get;set;}

        // Property to hold Wizard step developer name in semicolon delimited value.
        @AuraEnabled public String developerName {get;set;}
    }

    /**
     * Wrapper class to hold input parameters for a Process Step.
     */
    public class ProcessStepParameter{   
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Field value when the mapping is of type Value & Function.
        @AuraEnabled public String valueType {get;set;}
        
        // Field from which parameter key to be assigned.
        @AuraEnabled public String parameterKey {get;set;}
        
        // Field from which value to be assigned.
        @AuraEnabled public String parameterValue {get;set;}

        // Property specifies wizard step parameter record is modified or not 
        @AuraEnabled public Boolean isModified {get;set;}

        // Reference Identifier - used by the API Requests and 
        //   Responses to map errors to specific request parameters.
        @AuraEnabled public String referenceId {get;set;}

        // Parent Wizard Salesforce record ID.
        @AuraEnabled public String processWizardStepId {get;set;} 
    }

    /**
     * Wrapper class to hold input parameters for Recent Items.
     */
    public class RecentItemInfo{   
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Field value to store configuration id
        @AuraEnabled public String configurationId {get;set;}
        
        // Field value to store configuration name
        @AuraEnabled public String configurationName{get;set;}
        
        // Field value to store configuration developer name
        @AuraEnabled public String configurationDeveloperName {get;set;}

        // Field value to store configuration type
        @AuraEnabled public String configurationType {get;set;}

        // Field value to store configuration date
        @AuraEnabled public Datetime configurationDate {get;set;}

        // Field value to store object api name
        @AuraEnabled public String objectApiName {get;set;}
    }

    //Wrapper class to store Where Used Details
    public class WhereUsedInfo  {
        @AuraEnabled public String moduleName {get;set;}
        @AuraEnabled public String subModuleName {get;set;}
        @AuraEnabled public String moduleNameValue {get;set;}
        @AuraEnabled public String subModuleNameValue {get;set;}
        @AuraEnabled public String lastExecutionDateTime {get;set;}
        @AuraEnabled public List<ConfigurationTemplate> configurationTemplates {get;set;}
    }

    public class ConfigurationTemplate  {
        @AuraEnabled public String configurationName {get;set;}
        @AuraEnabled public String configurationDeveloperName {get;set;}
        @AuraEnabled public String configurationId {get;set;}
        @AuraEnabled public String configurationObject {get;set;}
        @AuraEnabled public List<SectionTemplate> sectionTemplates {get;set;}
    }

    public class SectionTemplate  {
        @AuraEnabled public String sectionName {get;set;}
        @AuraEnabled public String sectionType {get;set;}
        @AuraEnabled public String fieldMapping {get;set;}
        @AuraEnabled public String valueMapping {get;set;}
        @AuraEnabled public String formFillMapping {get;set;}
    }

    public class WhereUsedInputRecord {
        @AuraEnabled public String moduleType {get;set;}
        @AuraEnabled public String configurationId {get;set;}
        @AuraEnabled public String configDeveloperName {get;set;}
        @AuraEnabled public String configType {get;set;}

    }

    public class WhereUsedTransaction {
        @AuraEnabled public List<SVMXA360__CONF_Layout__c> transactionList {get;set;}
        @AuraEnabled public List<SVMXA360__CONF_LayoutRelatedSection__c> relatedSectionList {get;set;}
        @AuraEnabled public List<SVMXA360__CONF_LayoutElement__c> layoutElementList {get;set;}
        @AuraEnabled public List<SVMXA360__CONF_LayoutSection__c> sectionList {get;set;}
        @AuraEnabled public List<SVMXA360__CONF_ExpressionBasedMappingRow__c> exprBasedMappingList {get;set;}
        @AuraEnabled public String screenType {get;set;}
        @AuraEnabled public String moduleType {get;set;}
        @AuraEnabled public String configType {get;set;}
    }

    public class PscMappingConfiguration {
        public String targetMappingKey {get;set;}
        public String targetMappingId {get;set;}
    }
    /**
     * Wrapper class to hold Process Step Target information. 
     */
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public class ProcessStepTarget {

        // Id of the record
        @AuraEnabled public String id {get;set;}
        // Name or Label for the target.
        @AuraEnabled public String label {get;set;}
        // ApiName for the target.
        @AuraEnabled public String apiName {get;set;}
        // Namespace Prefix for the target.
        @AuraEnabled public String namespacePrefix {get;set;}
    }

    /**
     * Wrapper class to hold Process Step Target Request information. 
     */
    @SuppressWarnings('PMD.ExcessivePublicCount')
    public class ProcessStepTargetRequest {

        // The Step type name that is selected
        @AuraEnabled public String stepTypeName {get;set;}
        // ObjectApiName for the target.
        @AuraEnabled public String objectApiName {get;set;}
        // TargetApiName for the target.
        @AuraEnabled public String targetApiName {get;set;}
    }

    /**
     * Wrapper class to hold Profile information for a Process Wizard.
     */
    public class ProcessAccess {
        // Salesforce record Id.
        @AuraEnabled public String id {get;set;}

        // Access Record last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}

        // Name of user who last modified the access record.
        @AuraEnabled public String lastModifiedBy {get;set;}

        // Name of the access record.
        @AuraEnabled public String name {get;set;}

        // Parent Wizard Salesforce record ID.
        @AuraEnabled public String processWizardId {get;set;} 

        // Salesforce record ID of the Salesforce Profile used to restrict access to the Wizard. 
        @AuraEnabled public String profileId {get;set;}

        // Property specifies process wizard access record is modified or not 
        @AuraEnabled public Boolean isModified {get;set;} 
    }    

    /**
     * Wrapper class for custom label translation tags.
     */
    public class CustomLabel {
        public String key {get;set;}
        public String value {get;set;}
        
        public CustomLabel(String key, String value){
            this.key = key;
            this.value = value;
        }
    }

    /**
     * Wrapper class to hold Product information. 
     */
    public class LookupInfo {
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}

        // Salesforce record name
        @AuraEnabled public String name {get;set;}
    }

    /**
     * Wrapper class to hold Key value information. 
     */
    public class KeyValueInfo {
        // String key
        @AuraEnabled public String key {get;set;}

        // String value
        @AuraEnabled public String value {get;set;}
    }

    /**
     * Wrapper class to hold Service Assignment Rule informations. 
     */
    public class ServiceAssignmentRule {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Service Assignment Rule name
        @AuraEnabled public String name {get;set;}
        
        // Record last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Record last modified user.
        @AuraEnabled public String lastModifiedBy {get;set;}
        
        // Unique developer name used as external id
        @AuraEnabled public String developerName {get;set;}

        // description of the rule
        @AuraEnabled public String description {get;set;}
        
        // Object API name for which service assignment rule configured.
        @AuraEnabled public String objectAPIName {get;set;}
        
        // Service Assignment rule qualification criteria.
        @AuraEnabled public Expression qualifyingCriteria {get;set;}
        
        // Holds the product info.
        @AuraEnabled public LookupInfo product {get;set;}

        // Assignment rule active status.
        @AuraEnabled public Boolean active {get;set;}

        // Stores sequence of the Expression detail
        @AuraEnabled public Integer sequence {get;set;}
    }

    /**
     * Wrapper class to hold Pricebbok Assignment Rule informations. 
     */
    public class PricebookAssignmentRule {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Service Assignment Rule name
        @AuraEnabled public String name {get;set;}
        
        // Record last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Record last modified user.
        @AuraEnabled public String lastModifiedBy {get;set;}
        
        // Unique developer name used as external id
        @AuraEnabled public String developerName {get;set;}

        // description of the rule
        @AuraEnabled public String description {get;set;}
        
        // Object API name for which service assignment rule configured.
        @AuraEnabled public String objectAPIName {get;set;}
        
        // Service Assignment rule qualification criteria.
        @AuraEnabled public Expression qualifyingCriteria {get;set;}
        
        // Holds the pricebook info.
        @AuraEnabled public LookupInfo pricebook {get;set;}

        // Indicates whether the record is Active.
        @AuraEnabled public Boolean active {get;set;}

        // Stores sequence of the Expression detail
        @AuraEnabled public Integer sequence {get;set;}
         
    }

    /**
     * Wrapper class to hold PSC Configuration informations. 
     */
    public class PSCConfigurations {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // PSC name
        @AuraEnabled public String name {get;set;}

        // PSC Developer name
        @AuraEnabled public String developerName {get;set;}

        // description of the PSC
        @AuraEnabled public String description {get;set;}

        // Indicates whether the record is Active.
        @AuraEnabled public Boolean isActive {get;set;}

        // last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}

        // Search Results Per PSC.
        @AuraEnabled public Decimal searchResultPerPSC {get;set;}

        // Delivery Batch Size.
        @AuraEnabled public Decimal deliveryBatch {get;set;}

        // Search Batch Size.
        @AuraEnabled public Decimal searchBatch {get;set;}

        // Email address.
        @AuraEnabled public String emailId {get;set;}

        // Mapping JSON.
        @AuraEnabled public String mappingJson {get;set;}
         
    }

    /**
     * Wrapper class to hold Process Wizard. 
     */
    public class WizardRequest {

        // List of Process Wizard.
        @AuraEnabled public List<ProcessWizard> wizardList {get;set;}

        // List of Object Api Names.
        @AuraEnabled public List<String> objectApiNameList {get;set;}
    }

    public class TranslationTag {
        @AuraEnabled public string language {get;set;}
        @AuraEnabled public string context {get;set;}
        @AuraEnabled public string contextLabel {get;set;}
        @AuraEnabled public string masterText {get;set;}
        @AuraEnabled public string translatedValue {get;set;}
        @AuraEnabled public string tagId {get;set;}
    }

    public class Option {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public Boolean isDefault {get;set;} 
        @AuraEnabled public Boolean selected {get;set;} 
    }

    /**
     * Wrapper class to hold information of Hierarchy Configuration Detail. 
     */
    public class HierarchyConfigField extends AdmRecord{

        // Parent Hierarchy Configuration Detail Id
        @AuraEnabled public String hierarchyConfigDetailId {get;set;}

        // Field API Name
        @AuraEnabled public String fieldAPIName {get;set;}

        // Sequence of the field
        @AuraEnabled public Integer sequence {get;set;}
    }

    /**
     * Wrapper class to hold information of Hierarchy Configuration Detail. 
     */
    public class HierarchyConfigDetail extends AdmRecord{

        // Parent Hierarchy Configuration Id
        @AuraEnabled public String hierarchyConfigId {get;set;}

        // Object Name
        @AuraEnabled public String objectAPIName {get;set;}

        // To indicate if the default record actions are enabled
        @AuraEnabled public Boolean defaultRecordActions {get;set;}

        // Display Icon Name
        @AuraEnabled public String displayIconName {get;set;}

        // To indicate if the SPM wizards actions are enabled
        @AuraEnabled public Boolean enableSPMWizards {get;set;}

        //field api name that stores the display icon name
        @AuraEnabled public String fieldForDisplayIconName {get;set;}
        
        //field api name that store expression 
        @AuraEnabled public String qualifyingCriteria {get;set;}
        
        //field name that store expression name
        @AuraEnabled public String qualifyingCriteriaName {get;set;}
        
        // To indicate if the Notifications are enabled
        @AuraEnabled public Boolean enableNotifications {get;set;}
        
        //field api name that store notification expression 
        @AuraEnabled public String notificationCriteria {get;set;}
        
        //field name that store notification expression name
        @AuraEnabled public String notificationCriteriaName {get;set;}

        // List of the associated field records
        @AuraEnabled public List<HierarchyConfigField> hierarchyConfigFieldList {get;set;}

        // To indicate if the Allow Managing Child Assets are enabled
        @AuraEnabled public Boolean allowManagingChildAssets {get;set;}
    }

    /**
     * Wrapper class to hold information of Hierarchy Configuration Access. 
     */
    public class HierarchyConfigAccess extends AdmRecord{

        // Parent Hierarchy Configuration Id
        @AuraEnabled public String hierarchyConfigId {get;set;}

        // Profile Id to which access is provided
        @AuraEnabled public String profileId {get;set;}

        // Profile Name to which access is provided
        @AuraEnabled public String profileName {get;set;}
    }

    /**
     * Wrapper class to hold information of Hierarchy Configuration. 
     */
    public class HierarchyConfig extends AdmRecord{

        // Description
        @AuraEnabled public String description {get;set;}

        // Developer Name
        @AuraEnabled public String developerName {get;set;}

        // To indicate if it's the default configuration
        @AuraEnabled public Boolean defaultConfiguration {get;set;}

        // List of the associated detail records
        @AuraEnabled public List<HierarchyConfigDetail> hierarchyConfigDetailList {get;set;}

        // List of the associated access records
        @AuraEnabled public List<HierarchyConfigAccess> hierarchyConfigAccessList {get;set;}
    }

    /**
     * Wrapper class to hold information of Hierarchy Configuration Detail. 
     */
    public class TimelineConfigDetail extends AdmRecord{

        // Parent Hierarchy Configuration Id
        @AuraEnabled public String timelineConfigId {get;set;}

        // Object Name
        @AuraEnabled public String objectLabel {get;set;}

        // Object Name
        @AuraEnabled public String objectAPIName {get;set;}

        // To indicate if we should show the default matching records on load
        @AuraEnabled public Boolean showMatchingOnLoad {get;set;}

        // Display Icon Name
        @AuraEnabled public String iconName {get;set;}

        // HEX value for background colour
        @AuraEnabled public String backgroundColor {get;set;}

        // To indicate the order of the details in the config
        @AuraEnabled public Decimal sequence {get;set;}

        // Display Field Name
        @AuraEnabled public String displayFieldAPIName {get;set;}

        // Source Field Name
        @AuraEnabled public String sourceFieldAPIName {get;set;}

        // Start Date Field Name
        @AuraEnabled public String startDateFieldAPIName {get;set;}

        // End Date Field Name
        @AuraEnabled public String endDateFieldAPIName {get;set;}

         // Start Date Field Name
         @AuraEnabled public String startDateFieldLabel {get;set;}

         // End Date Field Name
         @AuraEnabled public String endDateFieldLabel {get;set;}

        // Expression Id 
        @AuraEnabled public String qualifyingCriteria {get;set;}

        // Expression Name
        @AuraEnabled public String qualifyingCriteriaName {get;set;}
    }

    /**
     * Wrapper class to hold information of Timeline Configuration Access. 
     */
    public class TimelineConfigAccess extends AdmRecord{

        // Parent Hierarchy Configuration Id
        @AuraEnabled public String timelineConfigId {get;set;}

        // Profile Id to which access is provided
        @AuraEnabled public String profileId {get;set;}

        // Profile Name to which access is provided
        @AuraEnabled public String profileName {get;set;}
    }

    /**
     * Wrapper class to hold information of Timeline Configuration. 
     */
    public class TimelineConfig extends AdmRecord{

        // Description
        @AuraEnabled public String description {get;set;}

        // Developer Name
        @AuraEnabled public String developerName {get;set;}

        // To indicate if it's the default configuration
        @AuraEnabled public Boolean isDefault {get;set;}

        // List of the associated detail records
        @AuraEnabled public List<TimelineConfigDetail> timelineConfigDetailList {get;set;}

        // List of the associated access records
        @AuraEnabled public List<TimelineConfigAccess> timelineConfigAccessList {get;set;}
    }

    /**
     * Wrapper class to hold object mapping error message. 
     */
    public class MappingErrorMessage {

        // boolean variable to store if any error
        @AuraEnabled public Boolean hasError {get;set;}

        // To store error
        @AuraEnabled public String errorMessage {get;set;}
    }

    /**
    * Wrapper class to hold profile information of Hierarchy Configuration. 
    */
    public class ProfileInfo{

        // Profile Id
        @AuraEnabled public String profileId {get;set;}

        // Profile Name
        @AuraEnabled public String profileName {get;set;}

        // HierarchyConfig Names
        @AuraEnabled public List<String> hierarchyConfigNames {get;set;}

    }

    /**
    * Wrapper class to hold profile information of Timeline Configuration. 
    */
    public class TimelineProfileInfo{

        // Description
        @AuraEnabled public String profileId {get;set;}

        // Profile Name
        @AuraEnabled public String profileName {get;set;}

        // Developer Name
        @AuraEnabled public List<String> timelineConfigNames {get;set;}

    }

    public class ServicemaxTag {
         @AuraEnabled public List<SvmxTranslations> translations {get;set;}
    }

    public class SvmxTranslations extends AdmRecord {
        @AuraEnabled public String translationId {get;set;}
        @AuraEnabled public String masterText {get;set;}
        @AuraEnabled public String context {get;set;}
        @AuraEnabled public List<SvmxLanguageValues> languageValues  {get;set;}
    }

    public class SvmxLanguageValues {
        @AuraEnabled public String translatedValueId {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String lastModifiedDate {get;set;}
        @AuraEnabled public String lastModifiedBy {get;set;}
    }
    
    public enum ConfigurationType {
        Expression,
        Mapping,
        Transactions,
        ScreenDesigner,
        LookupConfig,
        Wizard,
        EntitlementRule,
        ServiceAssignmentRule,
        PricebookAssignmentRule,
        AssetHierarchy,
        AssetTimeline,
        ProductServiceCampaign,
        Translation,
        TechnicalAttribute,
        MaintenancePlanProcess
    }
    
    public enum SourceOrigin {
        Admin,
        RunTime
    }
    
    public class ConfigurationData {
        
        // String instance variable to hold configuration name.
        public String name;
        
        // String instance variable to hold configuration developer name.
        public String developerName;
        
        // String instance variable to hold translation tag.
        public String tag;
    }
    
    public class ReferenceData {
        
        // Enum instance variable to hold Configuration Type.
        public ConfigurationType configType;
        
        // List of selected configuration developer names.
        public List<ConfigurationData> configDataList;
    }
    
    public virtual class ValidationRequest {
        public List<ReferenceData> referenceDatas;
    }
    
    public class PageLayoutValidationRequest extends ValidationRequest {
        public PageLayout pageLayout;
    }
    
    public class WizardValidationRequest extends ValidationRequest {
        public ProcessWizard processWizard;
    }
    
    public class PscValidationRequest extends ValidationRequest {
        public PSCConfigurations pscConfiguration;
    }
    
    public class TimelineValidationRequest extends ValidationRequest {
        public TimelineConfig timelineConfig;
    }
    
    public class HierarchyValidationRequest extends ValidationRequest {
        public HierarchyConfig hierarchyConfig;
    }
    
    public class TranslationValidationRequest extends ValidationRequest {
        public List<SvmxTranslations> svmxTranslations;
    }
    
    public class MaintenaceProcessValidationRequest extends ValidationRequest {
        public MaintenancePlanProcessDetail maintenacePlanProcess;
    }
    
    public class ValidationResult {
        
        // Boolean variable represents the validation status.
        public Boolean isValid;
        
        // String instance variable to hold error messages.
        public String error;
        
        // Object instence to hold error data.
        public Object errorData;
        
        // Enum instance variable to hold Configuration Type.
        public ConfigurationType configType;
        
        // String instance variable to hold list of child validation results.
        public List<ValidationResult> detailResults;
        
        public ValidationResult() {
            this.isValid = true;
        }
        
        public ValidationResult( final ConfigurationType configType ) {
            
            this.isValid = true;
            this.configType = configType;
        }
        
        public ValidationResult( final ConfigurationType configType, final String error ) {
            this(configType, error, null);
        }
        
        public ValidationResult( final ConfigurationType configType, final String error, final Object errorData ) {
            
            this.isValid = false;
            this.configType = configType;
            this.error = error;
            this.errorData = errorData;
        }
        
        public void setError( final String error ) {
            
            this.isValid = false;
            this.error = error;
        }
        
        public void addDetailResult( final ValidationResult detailResult ) {
            
            if( detailResults == null ) {
                detailResults = new List<ValidationResult>();
            }
            this.isValid = false;
            detailResults.add(detailResult);
        }
        
        public void addAllDetailResult( final List<ValidationResult> validationResults ) {
            
            if( detailResults == null ) {
                detailResults = new List<ValidationResult>();
            }
            this.isValid = false;
            detailResults.addAll(validationResults);
        }
    }

    /**
    * Wrapper class to hold card information which is visible on admin welcome page. 
    */
    public class WelcomePageCard {

        // Card Caption
        @AuraEnabled public String cardCaption {get;set;}

        // Card Description
        @AuraEnabled public String cardDescription {get;set;}

        // Card Icon
        @AuraEnabled public String cardIcon {get;set;}

        // Card Button Label
        @AuraEnabled public String cardButtonLabel {get;set;}

        // Card Button URL
        @AuraEnabled public String cardURL {get;set;}

        // Card Order Number
        @AuraEnabled public Integer cardOrderNumber {get;set;}
    }

    public class DependentStep {
        @AuraEnabled public Boolean isModified {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String dependentStepId {get;set;}
        @AuraEnabled public String dependentStepName {get;set;}
        @AuraEnabled public String referenceId {get;set;}
    }

    /**
    * Wrapper class to hold Technical Attribute information. 
    */
    public class TechnicalAttribute extends AdmRecord {
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
        @AuraEnabled public PicklistDefinition picklistDefinition {get;set;}
    }

    /**
    * Wrapper class to hold Picklist Definition information. 
    */
    public class PicklistDefinition extends AdmRecord {
        @AuraEnabled public String developerName {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String values  {get;set;}
        @AuraEnabled public String defaultValue  {get;set;}
    }

    /**
    * Wrapper class to hold reference records of Technical Attribute. 
    */
    public class TechnicalAttributeReference extends AdmRecord {

        @AuraEnabled public List<LookupInfo> relatedPicklists {get;set;}

        @AuraEnabled public List<LookupInfo> relatedTemplateItems {get;set;}

        @AuraEnabled public List<LookupInfo> relatedAssetTechnicalAttributes {get;set;}

    }

    public class FeatureParameter {
        public String key {get; set;}
        public Object value {get; set;}
        
        public FeatureParameter (String key, Object value){
            this.key = key;
            this.value = value;
        }
    }

    public class TechnicalAttributeMatchRule extends AdmRecord {
        @AuraEnabled public Decimal sequence {get; set;}
        @AuraEnabled public string description {get; set;}
        @AuraEnabled public string ruleName {get; set;}
        @AuraEnabled public string ruleCriteria {get; set;}
        @AuraEnabled public string advancedCriteria {get; set;}
        @AuraEnabled public string selectionCondition {get; set;}
        @AuraEnabled public string developerName {get; set;}
        @AuraEnabled public list<TechnicalAttributeMatchRuleDetails> matchRuleDetails {get; set;}
    }

    public class TechnicalAttributeMatchRuleDetails {
        @AuraEnabled public string id {get; set;}
        @AuraEnabled public Decimal sequence {get; set;}
        @AuraEnabled public string objectAPIName {get; set;}
        @AuraEnabled public string objectFieldAPIName {get; set;}
        @AuraEnabled public string operandObjectAPIName {get; set;}
        @AuraEnabled public string operandFieldAPIName {get; set;}
        @AuraEnabled public string relatedObjectDetails {get; set;}
        @AuraEnabled public string referenceFieldLabel {get; set;}
        @AuraEnabled public string operator {get; set;}
        @AuraEnabled public string fieldType {get; set;}
    }

    public virtual class MaintenacePlanProcess {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public boolean isActive {get; set;}
        @AuraEnabled public boolean isDefault {get; set;}
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        @AuraEnabled public DateTime lastRan {get;set;}
        @AuraEnabled public String lastRunStatus {get;set;}
    }

    public class MaintenancePlanProcessDetail extends MaintenacePlanProcess {
        @AuraEnabled public String assignTo {get; set;}
        @AuraEnabled public String assignToObject {get; set;}
        @AuraEnabled public String assignToValue {get; set;}
        @AuraEnabled public Decimal nDaysBefore {get; set;}
        @AuraEnabled public String developerName {get; set;}
        @AuraEnabled public String assetToWOMappingId {get; set;}
        @AuraEnabled public String mPlanToWOMappingId {get; set;}
        @AuraEnabled public String sendFailureEmail {get; set;}
        @AuraEnabled public String sendSuccessEmail {get; set;}
        @AuraEnabled public String runAt {get; set;}
        @AuraEnabled public String timeZone {get; set;}
        @AuraEnabled public DateTime lastRunDate {get; set;}
        @AuraEnabled public String lastRunStatus {get; set;}
        @AuraEnabled public String recurrencePattern {get; set;}
        @AuraEnabled public Boolean detailLogNotification {get; set;}
	}

}