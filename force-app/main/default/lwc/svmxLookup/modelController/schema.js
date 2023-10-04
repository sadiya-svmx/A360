import {
    isReferenceField,
    isObjectSupportedByUiApi,
    getNameFieldsWithPreferredFirst,
    formatString,
    getValue,
    StaticallyComparable
} from 'c/utils';

import { SEARCH_REQUEST } from './search';

import OBJECT_API_NAME from '@salesforce/schema/CONF_LookupConfiguration__c.ObjectAPIName__c';
import FIELD_TO_RETURN from '@salesforce/schema/CONF_LookupConfiguration__c.FieldToReturn__c';
import DISPLAY_FIELDS from '@salesforce/schema/CONF_LookupConfiguration__c.DisplayFields__c';

const DEFAULT_NAME_FIELD = 'Name';

export default class SchemaModelController extends StaticallyComparable {
    // <<<<<< PROPERTY GROUP: Target Schema >>>>>>
    // === PROPERTY: objectApiName ===
    objectApiName;

    // === PROPERTY: fieldApiName ===
    fieldApiName;

    // === PROPERTY: targetObjectApiName ===
    _targetObjectApiName;
    get targetObjectApiName () {
        return this._targetObjectApiName;
    }

    set targetObjectApiName (value) {
        this._targetObjectApiName = value;
        this._resolveTargetObjectApiName();
        this._resolveResultFieldApiNames();
    }

    // === PROPERTY: _resolvedTargetObjectApiNameLDS ===
    _resolvedTargetObjectApiNameLDS;

    // === PROPERTY: _resolvedTargetObjectApiNameApex ===
    _resolvedTargetObjectApiNameApex;

    // === PROPERTY: resolvedTargetObjectApiName ===
    // Resolved API name of the object to search against
    get resolvedTargetObjectApiName () {
        return this._resolvedTargetObjectApiNameLDS || this._resolvedTargetObjectApiNameApex;
    }

    set resolvedTargetObjectApiName (value) {
        // Switch between wire adapters depending on object support availability
        if (isObjectSupportedByUiApi(value)) {
            this._resolvedTargetObjectApiNameLDS = value;
            this._resolvedTargetObjectApiNameApex = undefined;
        } else {
            this._resolvedTargetObjectApiNameLDS = undefined;
            this._resolvedTargetObjectApiNameApex = value;
        }

        this.mc('search').setSearchRequestProperty(
            SEARCH_REQUEST.OBJECT_NAME,
            this.resolvedTargetObjectApiName
        );
    }

    // === METHOD: _resolveTargetObjectApiName ===
    _resolveTargetObjectApiName () {
        // NOTE: Precendence rules used here are intended to match server-side behavior
        if (this.mc('staticConfig').lookupConfig &&
            getValue(this.mc('staticConfig').lookupConfig, OBJECT_API_NAME)
        ) {
            // Target object API from lookup configtakes precedence
            this.resolvedTargetObjectApiName = getValue(
                this.mc('staticConfig').lookupConfig,
                OBJECT_API_NAME
            );
        } else if (this.targetObjectApiName) {
            // Directly populated field api name for label as first fallback
            this.resolvedTargetObjectApiName = this.targetObjectApiName;
        } else if (this.fieldDefinition) {
            // Final fallback is to default to value defined in the schema
            // TODO: Polymorphic lookup support
            this.resolvedTargetObjectApiName = this.fieldDefinition?.referenceToInfos[0].apiName;
        }

        if (this.resolvedTargetObjectApiName) {
            this.mc('debug').initializeDebugger();
        }
    }

    // === PROPERTY: isTargetObjectUiSupported ===
    get isTargetObjectUiSupported () {
        return isObjectSupportedByUiApi(this.resolvedTargetObjectApiName);
    }

    // === PROPERTY: targetObjectDefinition ===
    // Derived object metadata info for target object
    _targetObjectDefinition;
    get targetObjectDefinition () {
        return this._targetObjectDefinition;
    }

    set targetObjectDefinition (value) {
        this._targetObjectDefinition = value;

        if (this.lookupMatchingField) {
            const fieldDefinition =
                this.targetObjectDefinition.fields[this.lookupMatchingField];

            // Validate field api
            if (!fieldDefinition) {
                throw new Error(formatString(
                    this.mc('ui').i18n.invalidFieldApi,
                    this.lookupMatchingField
                ));
            }

            this.lookupMatchingFieldDefinition = fieldDefinition;
        }

        this._resolveTargetDisplayFieldApiNames();
    }

    // === METHOD: getTargetObjectFields ===
    getTargetObjectFields () {
        const targetObjectFieldsSet = [];
        const fields = Object.values(this.targetObjectDefinition.fields);
        const fieldsLength = fields.length;
        for (let index = 0; index < fieldsLength; index++) {
            targetObjectFieldsSet.push(Object.values(fields)[index].apiName);
        }
        return targetObjectFieldsSet;
    }

    // === PROPERTY: targetObjectLabel ===
    get targetObjectLabel () {
        return this.targetObjectDefinition?.label || '';
    }

    // === PROPERTY: targetObjectPluralLabel ===
    get targetObjectPluralLabel () {
        return this.targetObjectDefinition?.pluralLabel || '';
    }

    // === PROPERTY: fieldDefinition ===
    _fieldDefinition;
    get fieldDefinition () {
        return this._fieldDefinition;
    }

    set fieldDefinition (value) {
        this._fieldDefinition = value;

        // Resolve dependent properties
        this._resolveTargetObjectApiName();
        this._resolveTargetLabelApiName();
    }

    // === PROPERTY: targetLabelApiName ===
    _targetLabelApiName;
    _resolvedTargetLabelApiName;
    get targetLabelApiName () {
        return this._resolvedTargetLabelApiName;
    }

    set targetLabelApiName (value) {
        this._targetLabelApiName = value;
        this._resolveTargetLabelApiName();
        this._resolveResultFieldApiNames();
    }

    // === METHOD: _resolveTargetLabelApiName ===
    _resolveTargetLabelApiName () {
        if (this.mc('staticConfig').lookupConfig &&
            getValue(this.mc('staticConfig').lookupConfig, FIELD_TO_RETURN)
        ) {
            // Label field API from lookup config takes precedence
            this._resolvedTargetLabelApiName = getValue(
                this.mc('staticConfig').lookupConfig,
                FIELD_TO_RETURN
            );
        } else if (this._targetLabelApiName) {
            // Directly populated field api name for label as first fallback
            this._resolvedTargetLabelApiName = this._targetLabelApiName;
        } else if (this.fieldDefinition) {
            // First name field from schema as second fallback
            // TODO: Polymorphic lookup support.
            this._resolvedTargetLabelApiName =
                this.fieldDefinition?.referenceToInfos[0].nameFields.join(',');
        } else {
            // Final fallback is to default to the standard Name field
            this._resolvedTargetLabelApiName = DEFAULT_NAME_FIELD;
        }

        // Support for multiple display label fields, comma-separated
        this._resolvedTargetLabelApiName = (this._resolvedTargetLabelApiName || '').split(/, */);
        this.mc('search').setSearchRequestProperty(
            SEARCH_REQUEST.SEARCH_FIELDS,
            this._resolvedTargetLabelApiName
        );
    }

    // === PROPERTY: targetDisplayFieldApiNames ===
    // Additional display fields (primarily for use by the advanced lookup screen)
    _targetDisplayFieldApiNames;
    _resolvedTargetDisplayFieldApiNames;
    get targetDisplayFieldApiNames () {
        return this._resolvedTargetDisplayFieldApiNames || [];
    }

    set targetDisplayFieldApiNames (value) {
        this._targetDisplayFieldApiNames = value;
        this._resolveTargetDisplayFieldApiNames();
    }

    // === METHOD: _resolveTargetDisplayFieldApiNames ===
    _resolveTargetDisplayFieldApiNames () {
        if (this.targetObjectDefinition?.fields) {
            if (this.mc('staticConfig').lookupConfig &&
                getValue(this.mc('staticConfig').lookupConfig, DISPLAY_FIELDS)
            ) {
                this._resolvedTargetDisplayFieldApiNames =
                    getValue(this.mc('staticConfig').lookupConfig, DISPLAY_FIELDS).split(',');
            } else if (this._targetDisplayFieldApiNames) {
                this._resolvedTargetDisplayFieldApiNames =
                    this._targetDisplayFieldApiNames.split(',');
            }

            if (this._resolvedTargetDisplayFieldApiNames) {
                const targetObjectFieldsSet = this.getTargetObjectFields();
                this._resolvedTargetDisplayFieldApiNames = this._resolvedTargetDisplayFieldApiNames
                    .filter(item => targetObjectFieldsSet.includes(item) ||
                        targetObjectFieldsSet.includes(this.mc('utils').resolveToFieldName(item))
                    );
            }
        }

        this._resolveResultFieldApiNames();
    }

    // === PROPERTY: _mandatoryResultFieldApiNames ===
    _mandatoryResultFieldApiNames;

    // === PROPERTY: _resultFieldApiNames ===
    _resultFieldApiNames;

    // === METHOD: _resolveResultFieldApiNames ===
    _resolveResultFieldApiNames () {
        if (this.targetObjectDefinition?.fields) {
            let rawFields = [];

            if (this.targetLabelApiName?.length) {
                rawFields = rawFields.concat(this.targetLabelApiName);
            }

            if (this.targetDisplayFieldApiNames?.length) {
                rawFields = rawFields.concat(this.targetDisplayFieldApiNames);
            }

            const fields = new Set();
            rawFields.forEach(field => {
                let normalizedFieldName = field;
                const fieldDefinition = this.targetObjectDefinition.fields[field];
                if (isReferenceField(fieldDefinition)) {
                    // TODO: Polymorphic lookup support
                    const referenceNameField = fieldDefinition.referenceToInfos[0].nameFields[0];
                    normalizedFieldName =
                        `${fieldDefinition.relationshipName}.${referenceNameField}`;
                }
                fields.add(`${this.resolvedTargetObjectApiName}.${normalizedFieldName}`);
            });

            this._mandatoryResultFieldApiNames = [`${this.resolvedTargetObjectApiName}.Id`];
            this._resultFieldApiNames = Array.from(fields);
        }

        this.mc('advancedSearch')._resolveAdvancedSearchColumns();
    }

    // <<<<<< PROPERTY GROUP: Context Schema >>>>>>
    // === PROPERTY: _contextObjectNameLDS ===
    _contextObjectNameLDS;

    // === PROPERTY: _contextObjectNameApex ===
    _contextObjectNameApex;

    // === PROPERTY: contextObjectName ===
    get contextObjectName () {
        return this._contextObjectNameLDS ?? this._contextObjectNameApex;
    }

    set contextObjectName (value) {
        if (value != null) {
            // Switch between wire adapters depending on object support availability
            if (isObjectSupportedByUiApi(value)) {
                this._contextObjectNameLDS = value;
                this._contextObjectNameApex = undefined;
            } else {
                this._contextObjectNameLDS = undefined;
                this._contextObjectNameApex = value;
            }

            this.mc('contextSearch').applyContextFilterMetaData();
        }
    }

    // === PROPERTY: isContextObjectUiSupported ===
    get isContextObjectUiSupported () {
        return isObjectSupportedByUiApi(this.contextObjectName);
    }

    // === PROPERTY: contextDefaultNameFields ===
    _contextDefaultNameFields;
    get contextDefaultNameFields () {
        return this._contextDefaultNameFields;
    }

    set contextDefaultNameFields (value) {
        this._contextDefaultNameFields = getNameFieldsWithPreferredFirst(
            Array.isArray(value) ? value : [value]
        );
    }

    // === PROPERTY: contextReferenceNameField ===
    _contextReferenceNameField;
    get contextReferenceNameField () {
        return this._contextReferenceNameField;
    }

    set contextReferenceNameField (value) {
        this._contextReferenceNameField = value;
    }

    // === PROPERTY: contextRecordFieldApiNames ===
    get contextRecordFieldApiNames () {
        const fields = new Set();

        if (this.contextObjectName) {
            if (this.contextDefaultNameFields?.length) {
                fields.add(`${this.contextObjectName}.${this.contextDefaultNameFields[0]}`);
            }

            if (this.contextReferenceNameField) {
                fields.add(`${this.contextObjectName}.${this.contextReferenceNameField}`);
            }
        }

        return [...fields];
    }

    // === PROPERTY: contextDataType ===
    _contextDataType;
    get contextDataType () {
        return this._contextDataType || '';
    }

    set contextDataType (value) {
        this._contextDataType = value;
    }

    // === PROPERTY: isContextFieldLookup ===
    _isContextFieldLookup;
    get isContextFieldLookup () {
        return this._isContextFieldLookup;
    }

    set isContextFieldLookup (value) {
        this._isContextFieldLookup = value;
        this.mc('contextSearch').applyContextFilterMetaData();
    }

    // === PROPERTY: lookupMatchingField ===
    _lookupMatchingField;
    get lookupMatchingField () {
        return this._lookupMatchingField;
    }

    set lookupMatchingField (value) {
        this._lookupMatchingField = value;
        this.mc('contextSearch').isLookupContextOverridden = !this.lookupMatchingField;
        this.mc('search').setSearchRequestProperty(SEARCH_REQUEST.APPLY_CONTEXT_FILTER,
            !this.mc('contextSearch').isLookupContextOverridden);
    }

    // === PROPERTY: lookupMatchingFieldDefinition ===
    // Matching field on the target object for the lookup, and the label field api
    _lookupMatchingFieldDefinition;
    get lookupMatchingFieldDefinition () {
        return this._lookupMatchingFieldDefinition;
    }

    set lookupMatchingFieldDefinition (value) {
        this._lookupMatchingFieldDefinition = value;
        this.mc('contextSearch').applyContextFilterMetaData();
    }

    // === PROPERTY: lookupMatchingFieldTargetObjectApi ===
    get lookupMatchingFieldTargetObjectApi () {
        return this.lookupMatchingFieldReferenceTo?.apiName;
    }

    // === PROPERTY: lookupMatchingFieldLabel ===
    get lookupMatchingFieldLabel () {
        return this.lookupMatchingFieldDefinition?.label;
    }

    // === PROPERTY: lookupMatchingFieldReferenceTo ===
    get lookupMatchingFieldReferenceTo () {
        return this.lookupMatchingFieldDefinition &&
            this.lookupMatchingFieldDefinition.referenceToInfos &&
            this.lookupMatchingFieldDefinition.referenceToInfos.length &&
            this.lookupMatchingFieldDefinition.referenceToInfos[0];
    }

    // === PROPERTY: lookupMatchingFieldLabelApi ===
    get lookupMatchingFieldLabelApi () {
        const nameFields = this.lookupMatchingFieldReferenceTo &&
            this.lookupMatchingFieldReferenceTo.nameFields;

        if (!nameFields || nameFields.includes(DEFAULT_NAME_FIELD)) {
            return DEFAULT_NAME_FIELD;
        }

        return nameFields[0];
    }
}