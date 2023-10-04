import { LightningElement, api, track, wire } from 'lwc';
import { IS_MOBILE_DEVICE } from 'c/utils';

import desktopTemplate from './svmxLookup.html';
import mobileTemplate from './svmxLookupMobile.html';

import uiObjectInfoApi_getObjectInfo from
    '@salesforce/apex/COMM_UiApi.uiObjectInfoApi_getObjectInfo';
import uiRecordApi_getRecord from
    '@salesforce/apex/COMM_UiApi.uiRecordApi_getRecord';
import uiRecordApi_getRecordUi from
    '@salesforce/apex/COMM_UiApi.uiRecordApi_getRecordUi';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getRecordUi } from 'lightning/uiRecordApi';

import { generateLookupModelController } from './modelController/index.js';

const MODEL_TO_COMP_PROPERTY_MAPPING = {
    // Public Two-Way Component Props
    'svmxFieldId': '_svmxFieldId',
    'objectApiName': [
        '_objectApiName',
        '_wire_objectInfoLDS_objectApiName'
    ],
    'fieldApiName': '_fieldApiName',
    'label': '_label',
    'debugLabel': '_debugLabel',
    'iconName': '_iconName',
    'placeholder': '_placeholder',
    'required': '_required',
    'readOnly': '_readOnly',
    'variant': '_variant',
    'nestedModal': '_nestedModal',
    'nestedPopover': '_nestedPopover',
    'showRelationshipValue': '_showRelationshipValue',
    'fieldLevelHelp': '_fieldLevelHelp',
    'disabled': '_disabled',
    'targetObjectApiName': '_targetObjectApiName',
    'targetLabelApiName': '_targetLabelApiName',
    'targetDisplayFieldApiNames': '_targetDisplayFieldApiNames',
    'value': '_value',
    'enableAdvancedSearch': '_enableAdvancedSearch',
    'filters': '_filters',
    'recordTypeInfos': '_recordTypeInfos',
    'formFillMappingId': '_formFillMappingId',
    'advancedSearchConfig': '_advancedSearchConfig',
    'rowId': '_rowId',
    'isInCell': '_isInCell',
    'engineId': '_engineId',
    'enableEventPropertyInterface': '_enableEventPropertyInterface',
    'multiple': '_multiple',

    // Private One-Way Component Props
    'editable': 'editable',
    'apiInProgress': 'apiInProgress',
    'resolvedTargetObjectApiName': 'resolvedTargetObjectApiName',
    'targetObjectLabel': 'targetObjectLabel',
    'targetObjectPluralLabel': 'targetObjectPluralLabel',
    'options': 'options',
    'hasHelpMessage': 'hasHelpMessage',
    'helpMessage': 'helpMessage',
    'i18n': 'i18n',
    'computedFormClass': 'computedFormClass',
    'computedLabelClass': 'computedLabelClass',
    'computedTriggerClass': 'computedTriggerClass',
    'computedPillClass': 'computedPillClass',
    'computedDropDownListClass': 'computedDropDownListClass',
    'allowInput': 'allowInput',
    'hasSelectionAndNotInCell': 'hasSelectionAndNotInCell',
    'hasSelectionAndInCell': 'hasSelectionAndInCell',
    'hasSelectionAndReadOnly': 'hasSelectionAndReadOnly',
    'searchTerm': 'searchTerm',
    'searchLabel': 'searchLabel',
    'selectionLabel': 'selectionLabel',
    'lookupMatchingFieldLabel': 'lookupMatchingFieldLabel',
    '_overrideLookupContext': '_overrideLookupContext',
    'contextValue': 'contextValue',
    'contextRecordLabel': 'contextRecordLabel',
    '_showAdvancedSearchModal': '_showAdvancedSearchModal',
    '_advancedSearchColumns': '_advancedSearchColumns',
    'isDebuggingEnabledForApplication': 'isDebuggingEnabledForApplication',

    // Wired One-Way Props
    '_contextObjectNameLDS': '_wire_contextObjectInfoLDS_objectApiName',
    '_contextObjectNameApex': '_wire_contextObjectInfoApex_objectApiName',
    'lookupConfigId': '_wire_lookupConfigRecord_recordId',
    'lookupConfigFields': '_wire_lookupConfigRecord_fields',
    '_contextRecordIdLDS': '_wire_contextRecordLDS_recordId',
    '_contextRecordIdApex': '_wire_contextRecordApex_recordId',
    'contextRecordFieldApiNames': [
        '_wire_contextRecordLDS_fields',
        '_wire_contextRecordApex_fields'
    ],
    '_resolvedTargetObjectApiNameLDS': '_wire_targetObjectInfoLDS_objectApiName',
    '_resolvedTargetObjectApiNameApex': '_wire_targetObjectInfoApex_objectApiName',
    '_valueLDS': '_wire_selectionRecordLDS_recordId',
    '_valueApex': '_wire_selectionRecordApex_recordId',
    '_mandatoryResultFieldApiNames': [
        '_wire_selectionRecordLDS_fields',
        '_wire_selectionRecordApex_fields',
    ],
    '_resultFieldApiNames': [
        '_wire_selectionRecordLDS_optionalFields',
        '_wire_selectionRecordApex_optionalFields',
        '_wire_searchResultRecordsLDS_optionalFields',
        '_wire_searchResultRecordsApex_optionalFields'
    ],
    '_searchResultIdsLDS': '_wire_searchResultRecordsLDS_recordIds',
    '_searchResultIdsApex': '_wire_searchResultRecordsApex_recordIds'
}

export { DEBUG_KEYS } from './modelController/debug';

export default class SvmxLookup extends LightningElement {
    static delegatesFocus = true;
    @track modelController;

    constructor () {
        super();
        this.modelController = generateLookupModelController(
            this,
            MODEL_TO_COMP_PROPERTY_MAPPING
        );
    }

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    connectedCallback () {
        this.modelController.handleComponentConnected();
    }

    disconnectedCallback () {
        this.modelController.handleComponentDisconnected();
    }

    renderedCallback () {
        this.modelController.handleComponentRendered();
    }

    // Unfortunately the LWC compiler needs these @api decorators for each public property,
    // even if the intention is to bind them to a nested model. So there's no route here to
    // decrease this boilerplate beyond this point via Proxy.
    _svmxFieldId;
    @api get svmxFieldId () {
        return this._svmxFieldId;
    }

    set svmxFieldId (value) {
        this.modelController.svmxFieldId = value;
    }

    _objectApiName;
    @api get objectApiName () {
        return this._objectApiName;
    }

    set objectApiName (value) {
        this.modelController.objectApiName = value;
    }

    _fieldApiName;
    @api get fieldApiName () {
        return this._fieldApiName;
    }

    set fieldApiName (value) {
        this.modelController.fieldApiName = value;
    }

    _label;
    @api get label () {
        return this._label;
    }

    set label (value) {
        this.modelController.label = value;
    }

    _debugLabel;
    @api get debugLabel () {
        return this._debugLabel;
    }

    set debugLabel (value) {
        this.modelController.debugLabel = value;
    }

    _iconName;
    @api get iconName () {
        return this._iconName;
    }

    set iconName (value) {
        this.modelController.iconName = value;
    }

    _placeholder;
    @api get placeholder () {
        return this._placeholder;
    }

    set placeholder (value) {
        this.modelController.placeholder = value;
    }

    _required;
    @api get required () {
        return this._required;
    }

    set required (value) {
        this.modelController.required = value;
    }

    _readOnly;
    @api get readOnly () {
        return this._readOnly;
    }

    set readOnly (value) {
        this.modelController.readOnly = value;
    }

    _variant;
    @api get variant () {
        return this._variant;
    }

    set variant (value) {
        this.modelController.variant = value;
    }

    _nestedModal;
    @api get nestedModal () {
        return this._nestedModal;
    }

    set nestedModal (value) {
        this.modelController.nestedModal = value;
    }

    _nestedPopover;
    @api get nestedPopover () {
        return this._nestedPopover;
    }

    set nestedPopover (value) {
        this.modelController.nestedPopover = value;
    }

    _showRelationshipValue;
    @api get showRelationshipValue () {
        return this._showRelationshipValue;
    }

    set showRelationshipValue (value) {
        this.modelController.showRelationshipValue = value;
    }

    _fieldLevelHelp;
    @api get fieldLevelHelp () {
        return this._fieldLevelHelp;
    }

    set fieldLevelHelp (value) {
        this.modelController.fieldLevelHelp = value;
    }

    _disabled;
    @api get disabled () {
        return this.modelController.disabled;
    }

    set disabled (value) {
        this.modelController.disabled = value;
    }

    _targetObjectApiName;
    @api get targetObjectApiName () {
        return this._targetObjectApiName;
    }

    set targetObjectApiName (value) {
        this.modelController.targetObjectApiName = value;
    }

    _targetLabelApiName;
    @api get targetLabelApiName () {
        return this._targetLabelApiName;
    }

    set targetLabelApiName (value) {
        this.modelController.targetLabelApiName = value;
    }

    _targetDisplayFieldApiNames;
    @api get targetDisplayFieldApiNames () {
        return this._targetDisplayFieldApiNames;
    }

    set targetDisplayFieldApiNames (value) {
        this.modelController.targetDisplayFieldApiNames = value;
    }

    _value;
    @api get value () {
        return this._value;
    }

    set value (value) {
        this.modelController.value = value;
    }

    _enableAdvancedSearch;
    @api get enableAdvancedSearch () {
        return this._enableAdvancedSearch;
    }

    set enableAdvancedSearch (value) {
        this.modelController.enableAdvancedSearch = value;
    }

    _filters;
    @api get filters () {
        return this._filters;
    }

    set filters (value) {
        this.modelController.filters = value;
    }

    _recordTypeInfos = [];
    @api get recordTypeInfos () {
        return this._recordTypeInfos;
    }

    set recordTypeInfos (value) {
        this.modelController.recordTypeInfos = value ?? [];
    }

    _formFillMappingId;
    @api get formFillMappingId () {
        return this._formFillMappingId;
    }

    set formFillMappingId (value) {
        this.modelController.formFillMappingId = value;
    }

    _advancedSearchConfig;
    @api get advancedSearchConfig () {
        return this._advancedSearchConfig;
    }

    set advancedSearchConfig (value) {
        this.modelController.advancedSearchConfig = value;
    }

    _rowId;
    @api get rowId () {
        return this._rowId;
    }

    set rowId (value) {
        this.modelController.rowId = value;
    }

    get isEditingChild () {
        return !!this.rowId;
    }

    _isInCell;
    @api get isInCell () {
        return this._isInCell;
    }

    set isInCell (value) {
        this.modelController.isInCell = value;
    }

    _enableEventPropertyInterface;
    @api get enableEventPropertyInterface () {
        return this._enableEventPropertyInterface;
    }

    set enableEventPropertyInterface (value) {
        this.modelController.enableEventPropertyInterface = value;
    }

    @api
    checkValidity () {
        return this.modelController.checkValidity();
    }

    @api
    reportValidity () {
        return this.modelController.reportValidity();
    }

    @api
    getPropertyInterface () {
        return this.modelController.getPropertyInterface();
    }

    _engineId;
    @api get engineId () {
        return this._engineId;
    }

    set engineId (value) {
        this.modelController.engineId = value;
    }

    _multiple;
    @api get multiple () {
        return this._multiple;
    }

    set multiple (value) {
        this.modelController.multiple = value;
    }

    // <<<<<< Passthrough Properties for Template >>>>>>
    editable;
    apiInProgress;
    resolvedTargetObjectApiName;
    targetObjectLabel;
    targetObjectPluralLabel;
    options;
    hasHelpMessage;
    helpMessage;
    i18n;
    computedFormClass;
    computedLabelClass;
    computedTriggerClass;
    computedPillClass;
    computedDropDownListClass;
    allowInput;
    hasSelectionAndNotInCell;
    hasSelectionAndInCell;
    hasSelectionAndReadOnly;
    searchTerm;
    searchLabel;
    selectionLabel;
    lookupMatchingFieldLabel;
    _showAdvancedSearchModal;
    _advancedSearchColumns;
    _overrideLookupContext;
    contextRecordLabel;
    contextValue;
    isDebuggingEnabledForApplication;

    // <<<<<< Passthrough Methods for Template >>>>>>
    handleRootBlur (e) {
        this.modelController.handleRootBlur(e);
    }

    handleRootFocus (e) {
        this.modelController.handleRootFocus(e);
    }

    modalLookupSelect (e) {
        return this.modelController.modalLookupSelect(e);
    }

    modalMultiAddSelect (e) {
        return this.modelController.modalMultiAddSelect(e);
    }

    captureCancel () {
        return this.modelController.captureCancel();
    }

    handleSearchTermClick () {
        return this.modelController.handleSearchTermClick();
    }

    handleSearchTermChange (e) {
        return this.modelController.handleSearchTermChange(e);
    }

    handleMobileSearchCommit (e) {
        return this.modelController.handleMobileSearchCommit(e);
    }

    handleAdvancedModalSearch (e) {
        return this.modelController.handleAdvancedModalSearch(e);
    }

    handleDropdownMouseLeave () {
        return this.modelController.handleDropdownMouseLeave();
    }

    handleDropdownMouseDown (e) {
        return this.modelController.handleDropdownMouseDown(e);
    }

    handlePillFocus () {
        return this.modelController.handlePillFocus();
    }

    handleBlur () {
        return this.modelController.handleBlur();
    }

    handleFocus () {
        return this.modelController.handleFocus();
    }

    handleSelect (e) {
        return this.modelController.handleSelect(e);
    }

    // eslint-disable-next-line consistent-return
    handleAdvancedSearchSelect (e) {
        if (!this.disabled) {
            this.modelController.handleSearchTermClick();
            return this.modelController.handleAdvancedSearchSelect(e);
        }
    }

    handleRemovePill () {
        return this.modelController.handleRemovePill();
    }

    // <<<<<< Wires >>>>>>
    // Derived object metadata info for storage object
    _wire_contextObjectInfoLDS_objectApiName;
    @wire(getObjectInfo, {
        objectApiName: '$_wire_contextObjectInfoLDS_objectApiName',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredContextObjectInfoLDS'
    })
    wiredContextObjectInfoLDS (wiredData) {
        this.modelController.handleWiredContextObjectInfo(wiredData);
    }

    _wire_contextObjectInfoApex_objectApiName;
    @wire(uiObjectInfoApi_getObjectInfo, {
        objectApiName: '$_wire_contextObjectInfoApex_objectApiName',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredContextObjectInfoApex'
    })
    wiredContextObjectInfoApex (wiredData) {
        this.modelController.handleWiredContextObjectInfo(wiredData);
    }

    // Fetch lookup Config record
    _wire_lookupConfigRecord_recordId;
    _wire_lookupConfigRecord_fields;
    @wire(getRecord, {
        recordId: '$_wire_lookupConfigRecord_recordId',
        fields: '$_wire_lookupConfigRecord_fields',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredLookupConfigRecordsLDS'
    })
    wiredLookupConfigRecordsLDS (wiredData) {
        this.modelController.handleWiredLookupConfigRecords(wiredData);
    }

    // Fetch lookup context record
    _wire_contextRecordLDS_recordId;
    _wire_contextRecordLDS_fields;
    @wire(getRecord, {
        recordId: '$_wire_contextRecordLDS_recordId',
        fields: '$_wire_contextRecordLDS_fields',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredLookupContextRecordLDS'
    })
    wiredLookupContextRecordLDS (wiredData) {
        this.modelController.handleWiredLookupContextRecord(wiredData);
    }

    _wire_contextRecordApex_recordId;
    _wire_contextRecordApex_fields;
    @wire(uiRecordApi_getRecord, {
        recordId: '$_wire_contextRecordApex_recordId',
        fields: '$_wire_contextRecordApex_fields',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredLookupContextRecordApex'
    })
    wiredLookupContextRecordApex (wiredData) {
        this.modelController.handleWiredLookupContextRecord(wiredData);
    }

    // Derived object metadata info for storage object
    _wire_objectInfoLDS_objectApiName;
    @wire(getObjectInfo, {
        objectApiName: '$_wire_objectInfoLDS_objectApiName',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredObjectInfoLDS'
    })
    wiredObjectInfoLDS (wiredData) {
        this.modelController.handleWiredObjectInfo(wiredData);
    }

    _wire_targetObjectInfoLDS_objectApiName;
    @wire(getObjectInfo, {
        objectApiName: '$_wire_targetObjectInfoLDS_objectApiName',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredTargetObjectInfoLDS'
    })
    wiredTargetObjectInfoLDS (wiredData) {
        this.modelController.handleWiredTargetObjectInfo(wiredData);
    }

    _wire_targetObjectInfoApex_objectApiName;
    @wire(uiObjectInfoApi_getObjectInfo, {
        objectApiName: '$_wire_targetObjectInfoApex_objectApiName',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredTargetObjectInfoApex'
    })
    wiredTargetObjectInfoApex (wiredData) {
        this.modelController.handleWiredTargetObjectInfo(wiredData);
    }

    // Fetch lookup context record
    _wire_selectionRecordLDS_recordId;
    _wire_selectionRecordLDS_fields;
    _wire_selectionRecordLDS_optionalFields;
    @wire(getRecord, {
        recordId: '$_wire_selectionRecordLDS_recordId',
        fields: '$_wire_selectionRecordLDS_fields',
        optionalFields: '$_wire_selectionRecordLDS_optionalFields',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredSelectionRecordLDS'
    })
    wiredSelectionRecordLDS (wiredData) {
        this.modelController.handleWiredSelectionRecord(wiredData);
    }

    _wire_selectionRecordApex_recordId;
    _wire_selectionRecordApex_fields;
    _wire_selectionRecordApex_optionalFields;
    @wire(uiRecordApi_getRecord, {
        recordId: '$_wire_selectionRecordApex_recordId',
        fields: '$_wire_selectionRecordApex_fields',
        optionalFields: '$_wire_selectionRecordApex_optionalFields',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredSelectionRecordApex'
    })
    wiredSelectionRecordApex (wiredData) {
        this.modelController.handleWiredSelectionRecord(wiredData);
    }

    _wire_searchResultRecordsLDS_recordIds;
    _wire_searchResultRecordsLDS_optionalFields;
    @wire(getRecordUi, {
        recordIds: '$_wire_searchResultRecordsLDS_recordIds',
        optionalFields: '$_wire_searchResultRecordsLDS_optionalFields',
        layoutTypes: 'Compact',
        modes: 'View',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredSearchResultRecordsLDS'
    })
    wiredSearchResultRecordsLDS (wiredData) {
        this.modelController.handleWiredSearchResultRecords(wiredData);
    }

    _wire_searchResultRecordsApex_recordIds;
    _wire_searchResultRecordsApex_optionalFields;
    @wire(uiRecordApi_getRecordUi, {
        recordIds: '$_wire_searchResultRecordsApex_recordIds',
        optionalFields: '$_wire_searchResultRecordsApex_optionalFields',
        // Workaround for gaps in multi-use wire adapter mock support
        wireId: 'wiredSearchResultRecordsApex'
    })
    wiredSearchResultRecordsApex (wiredData) {
        this.modelController.handleWiredSearchResultRecords(wiredData);
    }
}