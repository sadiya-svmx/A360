/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The intentions of this class is to wrap the common Request and Response structures used by the
 * Apex-backed fallback services for the Ui Api methods that are available through the LWC module.
 * 
 * This class is a modular service layer class for the all Lightning Web Components.
 * This class should not be compile-time dependent on any product-specific code/config so as to
 * promote re-use across all products.
 * Optional dependencies that are resolved at runtime are fine if absolutely necessary.
 *
 * @author Jason Bradley
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jason Bradley          13 August 2021     Created.
 * 
 *****************************************************************************************************/
public inherited sharing class COMM_UiApi_Structs {

    private static final Map<Schema.DisplayType, String> DISPLAY_TYPE_TO_DATA_TYPE =
        new Map<Schema.DisplayType, String> {
            Schema.DisplayType.ADDRESS => 'Address',
            Schema.DisplayType.ANYTYPE => 'AnyType',
            Schema.DisplayType.BASE64 => 'Base64',
            Schema.DisplayType.BOOLEAN => 'Boolean',
            Schema.DisplayType.COMBOBOX => 'ComboBox',
            Schema.DisplayType.CURRENCY => 'Currency',
            Schema.DisplayType.DATACATEGORYGROUPREFERENCE => 'String',
            Schema.DisplayType.DATE => 'Date',
            Schema.DisplayType.DATETIME => 'DateTime',
            Schema.DisplayType.DOUBLE => 'Double',
            Schema.DisplayType.EMAIL => 'Email',
            Schema.DisplayType.ENCRYPTEDSTRING => 'EncryptedString',
            Schema.DisplayType.ID => 'String',
            Schema.DisplayType.INTEGER => 'Int',
            Schema.DisplayType.LOCATION => 'Location',
            Schema.DisplayType.LONG => 'Long',
            Schema.DisplayType.MULTIPICKLIST => 'MultiPicklist',
            Schema.DisplayType.PERCENT => 'Percent',
            Schema.DisplayType.PHONE => 'Phone',
            Schema.DisplayType.PICKLIST => 'Picklist',
            Schema.DisplayType.REFERENCE => 'Reference',
            Schema.DisplayType.STRING => 'String',
            Schema.DisplayType.TEXTAREA => 'TextArea',
            Schema.DisplayType.TIME => 'Time',
            Schema.DisplayType.URL => 'Url'
        };


    // #region uiObjectInfoApi Structs

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_object_info.htm
    public class ObjectInfo {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public String associateEntityType {get; set;}

        @AuraEnabled
        public String associateParentEntity {get; set;}

        @AuraEnabled
        public List<ChildRelationshipInfo> childRelationships {get; set;}

        @AuraEnabled
        public Boolean createable {get; set;}

        @AuraEnabled
        public Boolean custom {get; set;}

        @AuraEnabled
        public Id defaultRecordTypeId {get; set;}

        @AuraEnabled
        public Boolean deletable {get; set;}

        @AuraEnabled
        public Map<String, Object> dependentFields {get; set;}

        @AuraEnabled
        public Boolean feedEnabled {get; set;}

        @AuraEnabled
        public Map<String, FieldInfo> fields {get; set;}

        @AuraEnabled
        public String keyPrefix {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String labelPlural {get; set;}

        @AuraEnabled
        public Boolean layoutable {get; set;}

        @AuraEnabled
        public Boolean mruEnabled {get; set;}

        @AuraEnabled
        public List<String> nameFields {get; set;}

        @AuraEnabled
        public Boolean queryable {get; set;}

        @AuraEnabled
        public Map<Id, RecordTypeInfo> recordTypeInfos {get; set;}

        @AuraEnabled
        public Boolean searchable {get; set;}

        @AuraEnabled
        public ThemeInfo themeInfo {get; set;}

        @AuraEnabled
        public Boolean updateable {get; set;}

        public ObjectInfo(Schema.DescribeSObjectResult sObjectDescribe) {
            this.apiName = sObjectDescribe.getName();
            this.associateEntityType = null;
            this.associateParentEntity = null;
            this.createable = sObjectDescribe.isCreateable();
            this.custom = sObjectDescribe.isCustom();
            this.deletable = sObjectDescribe.isDeletable();
            this.feedEnabled = sObjectDescribe.isFeedEnabled();
            this.keyPrefix = sObjectDescribe.getKeyPrefix();
            this.label = sObjectDescribe.getLabel();
            this.labelPlural = sObjectDescribe.getLabelPlural();
            // this.layoutable = sObjectDescribe.isLayoutable();
            this.mruEnabled = sObjectDescribe.isMruEnabled();
            this.queryable = sObjectDescribe.isQueryable();
            this.searchable = sObjectDescribe.isSearchable();
            this.updateable = sObjectDescribe.isUpdateable();

            populateFieldInfos(this, sObjectDescribe);

            populateChildRelationshipInfos(this, sObjectDescribe);

            populateRecordTypeInfos(this, sObjectDescribe);

            populateThemeInfo(this, sObjectDescribe);
        }
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_field.htm#ui_api_responses_field
    public class FieldInfo {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public Boolean calculated {get; set;}

        @AuraEnabled
        public Boolean compound {get; set;}

        @AuraEnabled
        public String compoundComponentName {get; set;}

        @AuraEnabled
        public String compoundFieldName {get; set;}

        @AuraEnabled
        public String controllerName {get; set;}

        @AuraEnabled
        public List<String> controllingFields {get; set;}

        @AuraEnabled
        public Boolean createable {get; set;}

        @AuraEnabled
        public Boolean custom {get; set;}

        @AuraEnabled
        public String dataType {get; set;}

        @AuraEnabled
        public String extraTypeInfo {get; set;}

        @AuraEnabled
        public Boolean filterable {get; set;}

        @AuraEnabled
        public FilteredLookupInfo filteredLookupInfo {get; set;}

        @AuraEnabled
        public Boolean highScaleNumber {get; set;}

        @AuraEnabled
        public Boolean htmlFormatted {get; set;}

        @AuraEnabled
        public String inlineHelpText {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public Integer length {get; set;}

        @AuraEnabled
        public Boolean nameField {get; set;}

        @AuraEnabled
        public Boolean polymorphicForeignKey {get; set;}

        @AuraEnabled
        public Integer precision {get; set;}

        @AuraEnabled
        public Boolean reference {get; set;}

        @AuraEnabled
        public String referenceTargetField {get; set;}

        @AuraEnabled
        public List<ReferenceToInfo> referenceToInfos {get; set;}

        @AuraEnabled
        public String relationshipName {get; set;}

        @AuraEnabled
        public Boolean required {get; set;}

        @AuraEnabled
        public Boolean searchPrefilterable {get; set;}

        @AuraEnabled
        public Integer scale {get; set;}

        @AuraEnabled
        public Boolean sortable {get; set;}

        @AuraEnabled
        public Boolean unique {get; set;}

        @AuraEnabled
        public Boolean updateable {get; set;}

        public FieldInfo(Schema.DescribeFieldResult fieldDescribe) {
            this.apiName = fieldDescribe.getName();
            this.calculated = fieldDescribe.isCalculated();
            this.compoundFieldName = fieldDescribe.getCompoundFieldName();
            this.compound = String.isNotBlank(this.compoundFieldName);
            this.compoundComponentName = this.compound ? this.apiName : null;
            this.controllerName = String.valueOf(fieldDescribe.getController());
            // this.controllingFields =
            this.createable = fieldDescribe.isCreateable();
            this.custom = fieldDescribe.isCustom();
            this.filterable = fieldDescribe.isFilterable();
            this.highScaleNumber = fieldDescribe.isHighScaleNumber();
            this.htmlFormatted = fieldDescribe.isHtmlFormatted();
            this.inlineHelpText = fieldDescribe.getInlineHelpText();
            this.label = fieldDescribe.getLabel();
            this.length = fieldDescribe.getLength();
            this.nameField = fieldDescribe.isNameField();
            this.polymorphicForeignKey = fieldDescribe.isNamePointing();
            this.precision = fieldDescribe.getPrecision();
            this.relationshipName = fieldDescribe.getRelationshipName();
            this.required = fieldDescribe.isCreateable() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate();
            this.searchPrefilterable = fieldDescribe.isSearchPrefilterable();
            this.scale = fieldDescribe.getScale();
            this.sortable = fieldDescribe.isSortable();
            this.unique = fieldDescribe.isUnique();
            this.updateable = fieldDescribe.isUpdateable();

            this.dataType = DISPLAY_TYPE_TO_DATA_TYPE.get(fieldDescribe.getType());

            if (this.dataType == 'TextArea') {
                if (this.htmlFormatted == true) {
                    this.extraTypeInfo = 'RichTextArea';
                } else {
                    this.extraTypeInfo = 'PlainTextArea';
                }
            }

            this.reference = this.dataType == 'Reference';
            this.referenceTargetField = fieldDescribe.getReferenceTargetField();

            populateLookupInfo(this, fieldDescribe);
            populateReferenceTos(this, fieldDescribe);
        }
    }

    private static void populateFieldInfos(ObjectInfo objectInfo, Schema.DescribeSObjectResult sObjectDescribe) {
        String objectApiName = sObjectDescribe.getName();
        Map<String, Schema.SObjectField> fields = sObjectDescribe.fields.getMap();
        Map<String, FieldInfo> fieldInfos = new Map<String, FieldInfo>();
        List<String> nameFields = new List<String>();

        for (String fieldName : fields.keySet()) {
            String fieldApiName = String.valueOf(fields.get(fieldName));
            Schema.DescribeFieldResult fieldDescribe = COMM_UiApi_Utils.getFieldDescribe(objectApiName, fieldApiName);

            if (fieldDescribe.isAccessible()) {
                FieldInfo fieldInfo = new FieldInfo(fieldDescribe);
                fieldInfos.put(fieldApiName, fieldInfo);

                if (fieldInfo.nameField == true) {
                    nameFields.add(fieldApiName);
                }
            }
        }

        objectInfo.fields = fieldInfos;
        objectInfo.nameFields = COMM_UiApi_Utils.getNameFields(objectApiName);
        objectInfo.dependentFields = new Map<String, Object>();
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_child_relationship.htm#ui_api_responses_child_relationship
    public class ChildRelationshipInfo {
        @AuraEnabled
        public String childObjectApiName {get; set;}

        @AuraEnabled
        public String fieldName {get; set;}

        @AuraEnabled
        public List<String> junctionIdListNames {get; set;}

        @AuraEnabled
        public List<String> junctionReferenceTo {get; set;}

        @AuraEnabled
        public String relationshipName {get; set;}

        public ChildRelationshipInfo(Schema.ChildRelationship childRelationship) {
            this.relationshipName = childRelationship.getRelationshipName();
            this.childObjectApiName = String.valueOf(childRelationship.getChildSObject());
            this.fieldName = String.valueOf(childRelationship.getField());
            this.junctionIdListNames = new List<String>();
            this.junctionReferenceTo = new List<String>();
        }
    }

    private static void populateChildRelationshipInfos(ObjectInfo objectInfo, Schema.DescribeSObjectResult sObjectDescribe) {
        List<Schema.ChildRelationship> childRelationships = sObjectDescribe.getChildRelationships();
        List<ChildRelationshipInfo> childRelationshipInfos = new List<ChildRelationshipInfo>();
        
        if (childRelationships != null) {
            for (Schema.ChildRelationship childRelationship : childRelationships) {
                if (String.isNotBlank(childRelationship.getRelationshipName()) &&
                    COMM_UiApi_Utils.hasAccessToObject(String.valueOf(childRelationship.getChildSObject()))
                ) {
                    ChildRelationshipInfo childRelationshipInfo = new ChildRelationshipInfo(childRelationship);
                    childRelationshipInfos.add(childRelationshipInfo);
                }
            }
        }
        
        objectInfo.childRelationships = childRelationshipInfos;
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_filtered_lookup_info.htm#ui_api_responses_filtered_lookup_info
    public class FilteredLookupInfo {
        @AuraEnabled
        public List<String> controllingFields {get; set;}

        @AuraEnabled
        public Boolean dependent {get; set;}

        @AuraEnabled
        public Boolean optionalFilter {get; set;}

        public FilteredLookupInfo(Schema.FilteredLookupInfo filteredLookupInfo) {
            this.controllingFields = filteredLookupInfo.getControllingFields();
            this.dependent = filteredLookupInfo.isDependent();
            this.optionalFilter = filteredLookupInfo.isOptionalFilter();
        }
    }

    private static void populateLookupInfo(FieldInfo fieldInfo, Schema.DescribeFieldResult fieldDescribe) {
        Schema.FilteredLookupInfo filteredLookupSchemaInfo = fieldDescribe.getFilteredLookupInfo();
        FilteredLookupInfo filteredLookupInfo;

        if (filteredLookupInfo != null) {
            filteredLookupInfo = new FilteredLookupInfo(filteredLookupSchemaInfo);
        }

        fieldInfo.filteredLookupInfo = filteredLookupInfo;
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_reference_to_info.htm#ui_api_responses_reference_to_info
    public class ReferenceToInfo {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public List<String> nameFields {get; set;}

        public ReferenceToInfo(Schema.SObjectType sObjectType) {
            this.apiName = String.valueOf(sObjectType);
            this.nameFields = COMM_UiApi_Utils.getNameFields(this.apiName);
        }
    }

    private static void populateReferenceTos(FieldInfo fieldInfo, Schema.DescribeFieldResult fieldDescribe) {
        List<Schema.SObjectType> referenceTos = fieldDescribe.getReferenceTo();
        List<ReferenceToInfo> referenceToInfos = new List<ReferenceToInfo>();

        if (referenceTos != null) {
            for (Schema.SObjectType referenceTo : referenceTos) {
                if (COMM_UiApi_Utils.hasAccessToObject(String.valueOf(referenceTo))) {
                    ReferenceToInfo referenceToInfo = new ReferenceToInfo(referenceTo);
                    referenceToInfos.add(referenceToInfo);
                }
            }
        }

        fieldInfo.referenceToInfos = referenceToInfos;
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record_type_info.htm#ui_api_responses_record_type_info
    public class RecordTypeInfo {
        @AuraEnabled
        public Boolean available {get; set;}

        @AuraEnabled
        public Boolean defaultRecordTypeMapping {get; set;}

        @AuraEnabled
        public Boolean master {get; set;}

        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public Id recordTypeId {get; set;}

        public RecordTypeInfo(Schema.RecordTypeInfo recordTypeInfo) {
            this.available = recordTypeInfo.isAvailable();
            this.defaultRecordTypeMapping = recordTypeInfo.isDefaultRecordTypeMapping();
            this.master = recordTypeInfo.isMaster();
            this.name = recordTypeInfo.getName();
            this.recordTypeId = recordTypeInfo.getRecordTypeId();
        }
    }

    private static void populateRecordTypeInfos(ObjectInfo objectInfo, Schema.DescribeSObjectResult sObjectDescribe) {
        Map<Id, Schema.RecordTypeInfo> recordTypesById = sObjectDescribe.getRecordTypeInfosById();
        Map<Id, RecordTypeInfo> recordTypeInfosById = new Map<Id, RecordTypeInfo>();
        Id defaultRecordTypeId;

        if (recordTypesById != null) {
            for (Id recordTypeId : recordTypesById.keySet()) {
                Schema.RecordTypeInfo recordType = recordTypesById.get(recordTypeId);
                RecordTypeInfo recordTypeInfo = new RecordTypeInfo(recordType);
                recordTypeInfosById.put(recordTypeId, recordTypeInfo);

                if (recordTypeInfo.defaultRecordTypeMapping == true) {
                    defaultRecordTypeId = recordTypeInfo.recordTypeId;
                }
            }
        }
        
        objectInfo.recordTypeInfos = recordTypeInfosById;
        objectInfo.defaultRecordTypeId = defaultRecordTypeId;
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_theme_info.htm#ui_api_responses_theme_info
    public class ThemeInfo {
        @AuraEnabled
        public String color {get; set;}

        @AuraEnabled
        public String iconUrl {get; set;}
    }

    private static void populateThemeInfo(ObjectInfo objectInfo, Schema.DescribeSObjectResult sObjectDescribe) {
        // TODO: How to resolve this information in apex, and if its even necessary for us?
    }

    // #endregion uiObjectInfoApi Structs

    // #region uiRecordApi Structs
    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record.htm
    public class Record {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public Map<String, RecordCollection> childRelationships {get; set;}

        @AuraEnabled
        public String eTag {get; set;}

        @AuraEnabled
        public Long weakETag {get; set;}

        @AuraEnabled
        public Map<String, FieldValue> fields {get; set;}

        @AuraEnabled
        public Id id {get; set;}

        @AuraEnabled
        public Id lastModifiedById {get; set;}

        @AuraEnabled
        public String lastModifiedDate {get; set;}

        @AuraEnabled
        public Id recordTypeId {get; set;}

        @AuraEnabled
        public RecordTypeInfo recordTypeInfo {get; set;}

        @AuraEnabled
        public String systemModstamp {get; set;}

        public Record(SObject sObjectRecord) {
            Schema.SObjectType sObjectType = sObjectRecord.getSObjectType();
            this.apiName = String.valueOf(sObjectType);
            this.id = sObjectRecord.Id;
            this.eTag = null;
            this.weakETag = null;

            populateFieldValues(this, sObjectRecord);
            populateRecordTypeInfo(this, sObjectRecord);
            populateChildRelationships(this, sObjectRecord);
        }
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record.htm
    public class FieldValue {
        @AuraEnabled
        public String displayValue {get; set;}

        @AuraEnabled
        public Object value {get; set;}
    }

    private static FieldValue getFieldValue(SObject sObjectRecord, String fieldApiName) {
        if (sObjectRecord == null) {
            Exception e = new IllegalArgumentException();
            e.setMessage('SObject record cannot be null.');
            throw e;
        }

        if (String.isBlank(fieldApiName)) {
            Exception e = new IllegalArgumentException();
            e.setMessage('Field api name cannot be blank.');
            throw e;
        }

        Schema.DescribeFieldResult fieldDescribe = COMM_UiApi_Utils.getFieldDescribe(
            String.valueOf(sObjectRecord.getSObjectType()),
            fieldApiName
        );

        if (fieldDescribe == null) {
            Exception e = new NoAccessException();
            e.setMessage('Invalid field api name "' + fieldApiName + '".');
            throw e;
        }

        FieldValue fieldValue = new FieldValue();
        
        Object rawFieldValue = sObjectRecord.get(fieldApiName);
        if (rawFieldValue == null) {
            fieldValue.value = null;
            fieldValue.displayValue = null;
        } else {
            DisplayType fieldType = fieldDescribe.getType();

            switch on fieldType {
                when DATETIME {
                    DateTime typedFieldValue = (DateTime)rawFieldValue;
                    fieldValue.value = typedFieldValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    fieldValue.displayValue = typedFieldValue.format();
                }

                when DATE {
                    Date typedFieldValue = (Date)rawFieldValue;
                    Integer month = typedFieldValue.month();
                    Integer day = typedFieldValue.day();
                    String monthValue = typedFieldValue.month().format();
                    String dayValue = typedFieldValue.day().format();

                    if (month < 10) {
                        monthValue = '0' + monthValue;
                    }

                    if (day < 10) {
                        dayValue = '0' + dayValue;
                    }

                    fieldValue.value = typedFieldValue.year() + '-' + monthValue + '-' + dayValue;
                    fieldValue.displayValue = typedFieldValue.format();
                }

                // No built-in formatting methods. Could use DateTime format + string splicing, but needs some experimentation
                /* when TIME {
                    Time typedFieldValue = (Time)rawFieldValue;
                    fieldValue.value = '';
                    fieldValue.displayValue = '';
                } */

                when BOOLEAN {
                    Boolean typedFieldValue = (Boolean)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                }

                when INTEGER {
                    Integer typedFieldValue = (Integer)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                }

                when LONG {
                    Long typedFieldValue = (Long)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                }

                when DOUBLE, PERCENT {
                    Decimal typedFieldValue = (Decimal)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                }

                when CURRENCY {
                    Decimal typedFieldValue = (Decimal)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                    
                    // No currency formatting Api in Apex
                    // fieldValue.displayValue = 
                }

                when ID, REFERENCE {
                    Id typedFieldValue = (Id)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                }

                when PICKLIST, MULTIPICKLIST {
                    String typedFieldValue = (String)rawFieldValue;
                    fieldValue.value = fieldValue.displayValue = typedFieldValue;
                }

                when STRING, ENCRYPTEDSTRING, COMBOBOX, EMAIL, PHONE, TEXTAREA, URL
                {
                    String typedFieldValue = (String)rawFieldValue;
                    fieldValue.value = typedFieldValue;
                }

                when else {
                    Exception e = new IllegalArgumentException();
                    e.setMessage('Invalid field api name "' + fieldApiName + '". This field type is unsupported "' + fieldType.name() + '".');
                    throw e;
                }
            }
        }

        return fieldValue;
    }

    @TestVisible
    private static void populateFieldValues(Record record, SObject sObjectRecord) {
        record.fields = new Map<String, FieldValue>();
        Set<String> fieldNames = sObjectRecord.getPopulatedFieldsAsMap().keySet();
        for (String fieldApiName : fieldNames) {
            FieldValue fieldValue = getFieldValue(sObjectRecord, fieldApiName);
            record.fields.put(fieldApiName, fieldValue);
        }
        
        record.lastModifiedById = (Id)record.fields.get('LastModifiedById')?.value;
        record.lastModifiedDate = (String)record.fields.get('LastModifiedDate')?.value;
        record.recordTypeId = (Id)record.fields.get('RecordTypeId')?.value;
        record.systemModstamp = (String)record.fields.get('SystemModstamp')?.value;
    }

    @TestVisible
    private static void populateRecordTypeInfo(Record record, SObject sObjectRecord) {
        Id recordTypeId = record.recordTypeId;
        if (String.isNotBlank(recordTypeId)) {
            Schema.DescribeSObjectResult sObjectDescribe = COMM_UiApi_Utils.getObjectDescribe(record.apiName);
            Map<Id, Schema.RecordTypeInfo> recordTypesById = sObjectDescribe.getRecordTypeInfosById();
            Schema.RecordTypeInfo recordTypeSchemaInfo = recordTypesById.get(recordTypeId);
            record.recordTypeInfo = new RecordTypeInfo(recordTypeSchemaInfo);
        }
    }

    @TestVisible
    private static void populateChildRelationships(Record record, SObject sObjectRecord) {
        // Currently not supported to native LWC Ui Api method, no need to implement at this moment
        record.childRelationships = new Map<String, RecordCollection>();
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record_collection.htm#ui_api_responses_record_collection
    public class RecordCollection {
        @AuraEnabled
        public Integer count {get; set;}

        @AuraEnabled
        public String currentPageToken {get; set;}

        @AuraEnabled
        public String currentPageUrl {get; set;}

        @AuraEnabled
        public String nextPageToken {get; set;}

        @AuraEnabled
        public String nextPageUrl {get; set;}

        @AuraEnabled
        public String previousPageToken {get; set;}

        @AuraEnabled
        public String previousPageUrl {get; set;}

        @AuraEnabled
        public List<Record> records {get; set;}

        public RecordCollection(List<SObject> sObjectRecords) {
            this.count = sObjectRecords.size();
            this.records = new List<Record>();
            for (SObject sObjectRecord : sObjectRecords) {
                this.records.add(new Record(sObjectRecord));
            }
        }
    }

    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record_ui.htm
    public class RecordUI {
        // NOTE: Not currently supported as there is no way to obtain this information directly in Apex
        @AuraEnabled
        public Map<String, RecordLayoutSectionUserState> layoutUserStates {get; set;}

        // NOTE: Not currently supported as there is no way to obtain this information directly in Apex
        @AuraEnabled
        public Map<String, Map<String, Map<String, Map<String, RecordLayout>>>> layouts {get; set;}

        @AuraEnabled
        public Map<String, ObjectInfo> objectInfos {get; set;}

        @AuraEnabled
        public Map<Id, Record> records {get; set;}

        public RecordUI(Map<Id, SObject> recordsById) {
            this.layoutUserStates = new Map<String, RecordLayoutSectionUserState>();
            this.layouts = new Map<String, Map<String, Map<String, Map<String, RecordLayout>>>>();

            Set<String> objectApiNames = new Set<String>();
            this.records = new Map<Id, Record>();
            for (Id recordId : recordsById.keySet()) {
                Record record = new Record(recordsById.get(recordId));
                objectApiNames.add(record.apiName);
                this.records.put(recordId, record);
            }

            this.objectInfos = new Map<String, ObjectInfo>();
            for (String objectApiName : objectApiNames) {
                this.objectInfos.put(objectApiName, COMM_UiApi.uiObjectInfoApi_getObjectInfo(objectApiName));
            }
        }
    }

    // Intentionally left out to avoid scaffolding classes that can't currently be used
    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record_layout_section_user_state.htm#ui_api_responses_record_layout_section_user_state
    public class RecordLayoutSectionUserState { }

    // Intentionally left out to avoid scaffolding classes that can't currently be used
    // Reference: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_record_layout.htm#ui_api_responses_record_layout
    public class RecordLayout { }

    // #endregion uiRecordApi Structs
}