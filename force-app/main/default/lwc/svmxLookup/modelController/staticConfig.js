import { StaticallyComparable } from 'c/utils';

import { SEARCH_REQUEST } from './search';

import FIELD_TO_RETURN from '@salesforce/schema/CONF_LookupConfiguration__c.FieldToReturn__c';
import OBJECT_API_NAME from '@salesforce/schema/CONF_LookupConfiguration__c.ObjectAPIName__c';
import DISPLAY_FIELDS from '@salesforce/schema/CONF_LookupConfiguration__c.DisplayFields__c';
import SEARCH_FIELDS from '@salesforce/schema/CONF_LookupConfiguration__c.SearchFields__c';
import DEVELOPER_NAME from
    '@salesforce/schema/CONF_LookupConfiguration__c.DeveloperName__c';
import DISPLAY_NAME from '@salesforce/schema/CONF_LookupConfiguration__c.Name';
import BASIC_FILTER from '@salesforce/schema/CONF_LookupConfiguration__c.BasicFilter__c';
// import SOURCE_VALUES from '@salesforce/schema/CONF_LookupConfiguration__c.';

export default class StaticConfigModelController extends StaticallyComparable {
    // === PROPERTY: svmxFieldId ===
    svmxFieldId;

    // === PROPERTY: _tabName ===
    _tabName;

    // === PROPERTY: rowId ===
    _rowId;
    get rowId () {
        return this._rowId;
    }

    set rowId (value) {
        this.updateRowId(value);
    }

    // === METHOD: updateRowId ===
    updateRowId (value) {
        if (this.rowId !== value) {
            this.mc('contextSearch').unsubscribeFromContextFieldUpdates();
            this._rowId = value;
            this.mc('contextSearch').subscribeToContextFieldUpdates();
        }
    }

    // === PROPERTY: label ===
    label;

    // === PROPERTY: iconName ===
    iconName;

    // === PROPERTY: placeholder ===
    _placeHolder;
    get placeholder () {
        return this._placeHolder || this.mc('ui').i18n.searchPlaceholder;
    }

    set placeholder (value) {
        this._placeHolder = value;
    }

    // === PROPERTY: required ===
    required = false;

    // === PROPERTY: readOnly ===
    readOnly = false;

    // === PROPERTY: editable ===
    get editable () {
        return !this.readOnly;
    }

    // === PROPERTY: variant ===
    variant;

    // === PROPERTY: nestedModal ===
    nestedModal = false;

    // === PROPERTY: nestedPopover ===
    nestedPopover = false;

    // === PROPERTY: showRelationshipValue ===
    showRelationshipValue = false;

    // === PROPERTY: fieldLevelHelp ===
    fieldLevelHelp = '';

    // === PROPERTY: disabled ===
    _disabled = false;
    get disabled () {
        return this._disabled;
    }

    set disabled (value) {
        this._disabled = value;
        if (this.disabled) {
            this.mc('ui').closeDropdown();
        }
    }

    // === PROPERTY: lookupConfigFields ===
    lookupConfigFields = [
        OBJECT_API_NAME,
        FIELD_TO_RETURN,
        DISPLAY_FIELDS,
        SEARCH_FIELDS,
        DEVELOPER_NAME,
        DISPLAY_NAME,
        BASIC_FILTER
    ];

    // === PROPERTY: lookupConfigId ===
    _lookupConfigId;
    get lookupConfigId () {
        return this._lookupConfigId;
    }

    set lookupConfigId (value) {
        this._lookupConfigId = value;
        this.mc('search').setSearchRequestProperty(
            SEARCH_REQUEST.LOOKUP_CONFIG_ID,
            this._lookupConfigId
        );
    }

    // === PROPERTY: lookupConfig ===
    // Lookup configuration record -> Stores previously configured persistent lookup properties
    _lookupConfig;
    get lookupConfig () {
        return this._lookupConfig;
    }

    set lookupConfig (value) {
        this._lookupConfig = value;

        // Resolve dependent properties
        this.mc('schema')._resolveTargetObjectApiName();
        this.mc('schema')._resolveTargetLabelApiName();
        this.mc('schema')._resolveTargetDisplayFieldApiNames();
    }

    // === PROPERTY: formFillMappingId ===
    formFillMappingId;

    // === PROPERTY: enableAdvancedSearch ===
    _enableAdvancedSearch = false;
    get enableAdvancedSearch () {
        return this._enableAdvancedSearch || this.mc('advancedSearch').hasAdvancedSearchConfig;
    }

    set enableAdvancedSearch (value) {
        this._enableAdvancedSearch = value;
    }

    // === PROPERTY: engineId ===
    engineId;

    // === PROPERTY: multiple ===
    multiple = false;

    // === PROPERTY: enableEventPropertyInterface ===
    enableEventPropertyInterface = false;
}