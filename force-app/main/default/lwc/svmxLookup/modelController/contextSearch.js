import {
    isReferenceField,
    isIdField,
    isSalesforceId,
    isUndefinedOrNull,
    getDisplayValue,
    StaticallyComparable,
    formatDateValue,
    FIELD_DATA_TYPES
} from 'c/utils';

import {
    HEADER,
    GRID,
    subscribe,
    unsubscribe
} from 'c/runtimePubSub';

import { SEARCH_REQUEST } from './search';

export default class ContextSearchModelController extends StaticallyComparable {
    // === PROPERTY: _isSubscribedToContextValue ===
    _isSubscribedToContextValue = false;

    // === PROPERTY: _contextFieldSubscriber ===
    _contextFieldSubscriber = newValue => {
        this.contextValue = newValue;
    };

    // === PROPERTY: _isContextInHeaderSection ===
    _isContextInHeaderSection;

    // === PROPERTY: lookupContext ===
    _lookupContext;
    get lookupContext () {
        return this._lookupContext;
    }

    set lookupContext (value) {
        if (this.lookupContext !== value) {
            this.unsubscribeFromContextFieldUpdates();
            this._lookupContext = value;
            this.subscribeToContextFieldUpdates();
        }
    }

    // === PROPERTY: _contextRecordIdLDS ===
    _contextRecordIdLDS;

    // === PROPERTY: _contextRecordIdApex ===
    _contextRecordIdApex;

    // === PROPERTY: contextRecordId ===
    get contextRecordId () {
        return this._contextRecordIdLDS || this._contextRecordIdApex;
    }

    set contextRecordId (value) {
        if (value == null || isSalesforceId(value)) {
            if (this.mc('schema').isContextObjectUiSupported) {
                this._contextRecordIdLDS = value;
                this._contextRecordIdApex = undefined;
            } else {
                this._contextRecordIdLDS = undefined;
                this._contextRecordIdApex = value;
            }
        }
    }

    // === PROPERTY: contextValue ===
    _contextValue;
    get contextValue () {
        if (isUndefinedOrNull(this._contextValue)) {
            return this.mc('schema').isContextFieldLookup ? null : '';
        }
        return this._contextValue;
    }

    set contextValue (value) {
        this._contextValue = value;

        if (this.contextValue) {
            if (isSalesforceId(this.contextValue)) {
                this.contextRecordId = this.contextValue;
            } else {
                this.generateContextRecordLabel();
            }
        } else {
            this.contextRecordId = this.contextRecord = this.contextRecordLabel = null;
        }

        this.applyContextFilterMetaData();
    }

    // === PROPERTY: _overrideLookupContext ===
    _overrideLookupContext;

    // === PROPERTY: isLookupContextOverridden ===
    isLookupContextOverridden = false;

    // === PROPERTY: contextRecord ===
    // Record data for the "context" (value-side of the context criteria) record in the
    // case of a lookup context field.
    _contextRecord;
    get contextRecord () {
        return this._contextRecord;
    }

    set contextRecord (value) {
        this._contextRecord = value;
        if (this._contextRecord && this.mc('schema').contextReferenceNameField) {
            this.contextRecordLabel =
                getDisplayValue(this._contextRecord, this.mc('schema').contextReferenceNameField);
        }
    }

    // === PROPERTY: contextRecordLabel ===
    // Display label for the context record
    _contextRecordLabel;
    get contextRecordLabel () {
        return this._contextRecordLabel ?? this.contextValue;
    }

    set contextRecordLabel (value) {
        this._contextRecordLabel = value;
        this.applyContextFilterMetaData();
    }

    generateContextRecordLabel () {
        const {
            lookupMatchingFieldDefinition: matchingField
        } = this.mc('schema');

        if (matchingField) {
            const dataType = matchingField.dataType.toUpperCase();

            // eslint-disable-next-line default-case
            switch (dataType) {
                case FIELD_DATA_TYPES.DATE:
                case FIELD_DATA_TYPES.DATETIME:
                case FIELD_DATA_TYPES.TIME:
                    this._contextRecordLabel = formatDateValue(this.contextValue, dataType);
            }
        }
    }

    // === METHOD: applyContextFilterMetaData ===
    applyContextFilterMetaData () {
        // Ensure we're working with the formatted record label prior to applying context filtering
        if (this.contextRecordLabel === this.contextValue) {
            this.generateContextRecordLabel();
        }

        const {
            contextValue,
            contextRecordLabel
        } = this;

        const {
            isContextFieldLookup,
            contextObjectName,
            lookupMatchingField,
            lookupMatchingFieldDefinition: matchingFieldDefinition,
            lookupMatchingFieldTargetObjectApi: matchingFieldTargetObjectApi,
            lookupMatchingFieldLabelApi: matchingFieldLabelApi,
        } = this.mc('schema');

        let field, context;

        // Wait for describe wire to respond with the object/field definition
        if (!matchingFieldDefinition) {
            return;
        }

        if (isReferenceField(matchingFieldDefinition)) {
            if (isContextFieldLookup) {
                if (contextObjectName === matchingFieldTargetObjectApi) {
                    // If match field and context field are both relationship fields AND the lookup
                    // field target type matches the context object type: Use direct Id matching
                    field = lookupMatchingField;
                    context = contextValue;
                } else {
                    // If match field and context field are both relationship fields AND the lookup
                    // field target type does not match the context object type: Use name field
                    // matching
                    field = `${matchingFieldDefinition.relationshipName}.${matchingFieldLabelApi}`;
                    context = contextRecordLabel;
                }
            } else {
                // If match field is a relationship field and the context field is not:
                //  Match against the match field's record name instead.
                field = `${matchingFieldDefinition.relationshipName}.${matchingFieldLabelApi}`;
                context = contextValue;
            }
        } else if (isIdField(matchingFieldDefinition)) {
            if (isContextFieldLookup) {
                if (contextObjectName === this.mc('schema').resolvedTargetObjectApiName) {
                    // If match field is the standard Id field and the context field is a lookup AND
                    //  the context field's target object is the same object that the lookup itself
                    //  points to: Use direct Id matching against the standard Id field
                    field = lookupMatchingField;
                    context = contextValue;
                } else {
                    // If match field is the standard Id field and the context field is a lookup AND
                    //  the context field's target object is NOT the same object that the lookup
                    //  itself points to: Match the name of the record selected in the context field
                    //  against the name of the target object for this lookup.
                    field = matchingFieldLabelApi;
                    context = contextRecordLabel;
                }
            } else {
                // If match field is the standard Id field and the context field is not a lookup:
                //  Match against the Name of the target object associated with the match field,
                //  using the context field value as the filter.
                field = matchingFieldLabelApi;
                context = contextValue;
            }
        } else {
            if (isContextFieldLookup) {
                // If match field is not a lookup or the standard Id field AND the context field is
                //  a lookup: Match against the name of the record in the context lookup.
                field = lookupMatchingField;
                context = contextRecordLabel;
            } else {
                // If match field is not a lookup or the standard Id field AND the context field is
                //  not a lookup: Use direct matching between the two fields.
                field = lookupMatchingField;
                context = contextValue;
            }
        }

        // Apply context filter properties to search request
        this.mc('search').setSearchRequestProperties({
            [SEARCH_REQUEST.LOOKUP_MATCHING_FIELD]: field,
            [SEARCH_REQUEST.LOOKUP_CONTEXT]: context
        });
    }

    // === METHOD: unsubscribeFromContextFieldUpdates ===
    unsubscribeFromContextFieldUpdates () {
        const {
            lookupContext,
            _isContextInHeaderSection: isContextInHeaderSection,
            _contextFieldSubscriber: subscriber
        } = this;

        const {
            _tabName: tabName,
            rowId,
            engineId,
        } = this.mc('staticConfig');

        if (!lookupContext || (!isContextInHeaderSection && (!rowId || !tabName))) {
            return;
        }

        unsubscribe({
            engineId,
            whichSection: isContextInHeaderSection ? HEADER : GRID,
            fieldName: lookupContext,
            rowIndex: isContextInHeaderSection ? null : rowId,
            tabIndex: isContextInHeaderSection ? null : tabName,
            subscriber
        });

        this._isSubscribedToContextValue = false;
    }

    // === METHOD: subscribeToContextFieldUpdates ===
    subscribeToContextFieldUpdates () {
        const {
            lookupContext,
            _isContextInHeaderSection: isContextInHeaderSection,
            _contextFieldSubscriber: subscriber
        } = this;

        const {
            _tabName: tabName,
            rowId,
            engineId
        } = this.mc('staticConfig');

        if (!lookupContext || (!isContextInHeaderSection && (!rowId || !tabName))) {
            return;
        }

        subscribe({
            engineId,
            whichSection: isContextInHeaderSection ? HEADER : GRID,
            fieldName: lookupContext,
            rowIndex: isContextInHeaderSection ? null : rowId,
            tabIndex: isContextInHeaderSection ? null : tabName,
            subscriber
        });

        this._isSubscribedToContextValue = true;
    }
}