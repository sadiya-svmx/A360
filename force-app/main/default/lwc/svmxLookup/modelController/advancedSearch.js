import { getValue, areObjectsEqual, StaticallyComparable, IS_MOBILE_DEVICE } from 'c/utils';

import { SEARCH_REQUEST, SEARCH_REQUEST_DEFAULTS } from './search';

import SEARCH_FIELDS from '@salesforce/schema/CONF_LookupConfiguration__c.SearchFields__c';

export default class AdvancedSearchModelController extends StaticallyComparable {
    // === PROPERTY: _showAdvancedSearchModal ===
    _showAdvancedSearchModal;

    // === PROPERTY: advancedSearchConfig ===
    _advancedSearchConfig = {};
    get advancedSearchConfig () {
        return this._advancedSearchConfig;
    }

    set advancedSearchConfig (value) {
        if (!areObjectsEqual(this.advancedSearchConfig, value || {})) {
            this._advancedSearchConfig = value;

            // Stamp values into component level properties to set off dependent wires
            this.mc('staticConfig')._tabName = this._advancedSearchConfig.tabName;

            if (this._advancedSearchConfig.rowIndex) {
                this.mc('staticConfig').updateRowId(this._advancedSearchConfig.rowIndex);
            }

            this.mc('contextSearch')._isContextInHeaderSection =
                this._advancedSearchConfig.isContextInHeaderSection;

            this.mc('contextSearch')._overrideLookupContext =
                !!this._advancedSearchConfig.overrideLookupContext;

            this.mc('schema').isContextFieldLookup =
                this._advancedSearchConfig.isContextFieldLookup;

            // Context value must come from the store and cannot be overridden once bound
            if (!this.mc('contextSearch')._isSubscribedToContextValue) {
                this.mc('contextSearch').contextValue = this._advancedSearchConfig.contextValue;
            }

            this.mc('staticConfig').lookupConfigId = this._advancedSearchConfig.lookupConfigId;
            this.mc('schema').lookupMatchingField = this._advancedSearchConfig.lookupMatchingField;
            this.mc('contextSearch').lookupContext = this._advancedSearchConfig.lookupContext;

            this.mc('schema').contextObjectName = this._advancedSearchConfig.contextObjectName;
            this.mc('schema').contextReferenceNameField =
                this._advancedSearchConfig.contextReferenceNameFields;

            this.mc('schema').contextDataType = this._advancedSearchConfig.contextDataType;
        }
    }

    // === PROPERTY: hasAdvancedSearchConfig ===
    get hasAdvancedSearchConfig () {
        return !!(this.advancedSearchConfig && Object.keys(this.advancedSearchConfig).length);
    }

    // === PROPERTY: _advancedSearchColumns ===
    _advancedSearchColumns = [];

    // === METHOD: _resolveAdvancedSearchColumns ===
    _resolveAdvancedSearchColumns () {
        if (this.mc('schema').targetObjectDefinition?.fields) {
            this._advancedSearchColumns = this.mc('schema')._resultFieldApiNames.map(field => {
                const [objectApiName, fieldApiName] = field.split('.');

                const column = {
                    objectApiName,
                    fieldName: field,
                    label: fieldApiName,
                };

                if (this.mc('schema').targetObjectDefinition?.fields) {
                    let resolvedFieldName;
                    if (/__r$/i.test(fieldApiName)) {
                        resolvedFieldName = this.mc('utils').resolveToFieldName(fieldApiName)
                    }
                    const fieldDefinition = this.mc('schema')
                        .targetObjectDefinition.fields[
                            resolvedFieldName || fieldApiName
                        ];

                    if (fieldDefinition) {
                        column.label = fieldDefinition.label;
                    }
                }

                return column;
            });

            const targetObjectFieldsSet = this.mc('schema').getTargetObjectFields();

            this._advancedSearchColumns = this._advancedSearchColumns.filter(item => {
                const fieldName = item.fieldName.split('.')[1];
                return targetObjectFieldsSet.includes(fieldName) ||
                    targetObjectFieldsSet.includes(this.mc('utils').resolveToFieldName(fieldName));
            });
        }
    }

    // === METHOD: modalLookupSelect ===
    modalLookupSelect ({ detail }) {
        this.resetAdvancedSearchSettings();
        if (this.mc('staticConfig').multiple) {
            this.mc('selection').setValueMultiAdd(detail.id);
        } else {
            this.mc('selection').setValue(detail.id);
            this.mc('results')._dropdownVisible = false;
        }
        this.setAdvanceSearchModal(false);
        this.mc('search').searchTerm = '';
        this.mc('ui').focusSearchInput();
        // this.mc('ui').reportValidity();
    }

    // === METHOD: captureCancel ===
    captureCancel () {
        this.setAdvanceSearchModal(false);
        this.resetAdvancedSearchSettings();
        this.mc('search').searchTerm = '';

        if (!IS_MOBILE_DEVICE) {
            this.mc('ui').focusSearchInput();
        }
    }

    // === METHOD: resetAdvancedSearchSettings ===
    resetAdvancedSearchSettings () {
        const shouldContextFilterBeApplied = !!this.mc('schema').lookupMatchingField;
        this.mc('contextSearch').isLookupContextOverridden = !shouldContextFilterBeApplied;

        this.mc('search').setSearchRequestProperties({
            [SEARCH_REQUEST.SEARCH_OPERATOR]:
                SEARCH_REQUEST_DEFAULTS[SEARCH_REQUEST.SEARCH_OPERATOR],
            [SEARCH_REQUEST.APPLY_CONTEXT_FILTER]: shouldContextFilterBeApplied
        });
    }

    // === METHOD: handleAdvancedModalSearch ===
    handleAdvancedModalSearch (event) {
        const {
            searchTerm,
            filterExpression: searchOperator,
            applyContextFilter
        } = event.detail;

        this.mc('contextSearch').isLookupContextOverridden = !applyContextFilter;

        this.mc('search').setSearchRequestProperties({
            [SEARCH_REQUEST.SEARCH_OPERATOR]: searchOperator,
            [SEARCH_REQUEST.APPLY_CONTEXT_FILTER]: applyContextFilter
        });

        this.mc('search').searchTerm = searchTerm;
    }

    // === METHOD: setAdvanceSearchModal ===
    setAdvanceSearchModal (newValue) {
        this._showAdvancedSearchModal = newValue;
        if (!this.mc('staticConfig').multiple) {
            this.getComponent().dispatchEvent(
                new CustomEvent('advmodal', {
                    composed: true,
                    bubbles: true,
                    detail: {
                        value: newValue
                    }
                })
            );
        }
    }

    // === METHOD: handleAdvancedSearchSelect ===
    handleAdvancedSearchSelect (e) {
        if (IS_MOBILE_DEVICE || this.mc('staticConfig').enableAdvancedSearch) {
            if (IS_MOBILE_DEVICE && !this.mc('staticConfig').multiple) {
                this.mc('search').searchTerm = this.mc('selection').selectionLabel;
                this.mc('ui').blurSearchInput();
                this.mc('ui').focusAdvancedSearchModal();
            }

            let searchFields;
            let unAccessedFields;
            if (this.mc('staticConfig').lookupConfig &&
                getValue(this.mc('staticConfig').lookupConfig, SEARCH_FIELDS)
            ) {
                searchFields = getValue(this.mc('staticConfig').lookupConfig, SEARCH_FIELDS)
                    .split(',');
            }

            if (this.mc('schema').targetObjectDefinition?.fields) {
                const targetObjectFieldsSet = this.mc('schema').getTargetObjectFields();
                if (searchFields && searchFields.length > 0) {
                    unAccessedFields = searchFields.filter(item =>
                        !targetObjectFieldsSet.includes(item));
                }
            }

            if (unAccessedFields && unAccessedFields.length > 0) {
                this.setAdvanceSearchModal(false);
                this.mc('utils').handleError(
                    `${this.mc('ui').i18n.noUserFieldPermission} ${unAccessedFields}`
                );
            } else {
                this.setAdvanceSearchModal(true);
            }
        } else {
            e.preventDefault();
            e.stopPropagation();
            this.mc('ui').focusSearchInput();
        }
    }
}