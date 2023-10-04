import {
    isReferenceField,
    formatString,
    getDisplayValue,
    OPERATOR_VALUE,
    StaticallyComparable,
    getUiRecord
} from 'c/utils';

import { SEARCH_REQUEST } from './search';

import getMatchingRecordIds from
    '@salesforce/apex/COMM_LookupFilterLightningService.getMatchingRecordIds';

export default class UtilsModelController extends StaticallyComparable {
    // === PROPERTY: error ===
    error;

    // === METHOD: generateDisplayLabelForRecord ===
    generateDisplayLabelForRecord (record) {
        let labels = [];
        if (record && this.mc('schema').targetLabelApiName?.length &&
            this.mc('schema').targetObjectDefinition?.fields
        ) {

            labels = this.mc('schema').targetLabelApiName.map(field => {
                let normalizedFieldName = field;
                const fieldDefinition = this.mc('schema').targetObjectDefinition.fields[field];
                if (isReferenceField(fieldDefinition)) {
                    // TODO: Polymorphic lookup support
                    const referenceNameField = fieldDefinition.referenceToInfos[0].nameFields[0];
                    normalizedFieldName =
                        `${fieldDefinition.relationshipName}.${referenceNameField}`;
                }
                return getDisplayValue(record, normalizedFieldName)
            })
                // Remove blank labels
                .filter(label => (label || '').trim().length);
        }

        const primary = labels.shift();
        const secondary = labels.join(' • ');

        return { primary, secondary };
    }

    // === METHOD: resolveLookupRecordByName ===
    async resolveLookupRecordByName (value) {
        try {
            const response = await getMatchingRecordIds({
                requestJson: JSON.stringify({
                    [SEARCH_REQUEST.OBJECT_NAME]: this.mc('schema').resolvedTargetObjectApiName,
                    [SEARCH_REQUEST.SEARCH_OPERATOR]: OPERATOR_VALUE.EXACT_MATCH,
                    [SEARCH_REQUEST.LOOKUP_CONTEXT]: value,
                    [SEARCH_REQUEST.LOOKUP_MATCHING_FIELD]: this.mc('schema').targetLabelApiName[0],
                    [SEARCH_REQUEST.APPLY_CONTEXT_FILTER]: true
                })
            });

            const data = await this.handleApexResponse(response);
            if (data && data.length) {
                this.mc('selection').setValue(data[0]);
            } else {
                throw new Error(formatString(
                    this.mc('ui').i18n.noRecordWithFieldEqualTo,
                    this.mc('schema').resolvedTargetObjectApiName,
                    this.mc('schema').targetLabelApiName[0],
                    value
                ));
            }
        } catch (err) {
            this.handleError(err);
        }
    }

    // === METHOD: generateRelatedLabel ===
    generateRelatedLabel (record) {
        if (!this.mc('staticConfig').showRelationshipValue) {
            return '';
        }

        let label = '';
        this.mc('schema').targetLabelApiName.forEach(field => {
            const fieldName = field.trim();
            label = label.replace(field, getDisplayValue(record, fieldName));
        });
        return label;
    }

    // === METHOD: dispatchCloseEvent ===
    dispatchCloseEvent () {
        this.getComponent().dispatchEvent(
            new CustomEvent('close', {
                composed: true,
                bubbles: true,
            })
        );
    }

    // === PROPERTY: publicProperties ===
    publicProperties = [
        'objectApiName',
        'fieldApiName',
        'label',
        'iconName',
        'placeholder',
        'required',
        'readOnly',
        'variant',
        'nestedModal',
        'nestedPopover',
        'showRelationshipValue',
        'fieldLevelHelp',
        'disabled',
        'targetObjectApiName',
        'targetLabelApiName',
        'targetDisplayFieldApiNames',
        'value',
        'enableAdvancedSearch',
        'filters',
        'recordTypeInfos',
        'advancedSearchConfig',
        'rowId',
        'isInCell'
    ];

    // === PROPERTY: componentGetter ===
    componentGetter;

    // === PROPERTY: propertyInterface ===
    propertyInterface;

    // === METHOD: getPropertyInterface ===
    getPropertyInterface () {
        if (!this.propertyInterface) {
            this.propertyInterface = {};
            this.publicProperties.forEach(publicPropertyName => {
                const setterName = 'set' + publicPropertyName.charAt(0).toUpperCase() +
                    publicPropertyName.slice(1);

                this.propertyInterface[setterName] = val => {
                    const comp = this.componentGetter();
                    if (comp) {
                        comp[publicPropertyName] = val;
                    }
                };
            });
        }
        return this.propertyInterface;
    }

    // === METHOD: fireChangeEvent ===
    fireChangeEvent (newValue = '') {
        if (this.mc('ui').isConnected) {
            let detail;
            if (this.mc('staticConfig').multiple) {
                detail = newValue?.map(selectedRow => {
                    return {
                        fieldApiName: this.mc('schema').fieldApiName,
                        label: this.mc('utils').generateDisplayLabelForRecord(
                            getUiRecord(selectedRow)
                        ),
                        rowId: this.mc('staticConfig').rowId,
                        value: selectedRow.Id,
                        propertyInterface: this.mc('staticConfig').enableEventPropertyInterface ?
                            this.getPropertyInterface() : null
                    };
                });
            } else {
                detail = {
                    fieldApiName: this.mc('schema').fieldApiName,
                    label: this.mc('selection').selectionLabel,
                    rowId: this.mc('staticConfig').rowId,
                    value: newValue,
                    propertyInterface: this.mc('staticConfig').enableEventPropertyInterface ?
                        this.getPropertyInterface() : null
                };
            }

            this.getComponent().dispatchEvent(
                new CustomEvent('lookupselect', {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail
                })
            );

            if (this.mc('staticConfig').nestedPopover && this.mc('ui')._lookupSearch) {
                this.dispatchCloseEvent();
            }
        }
    }

    // === METHOD: handleApexResponse ===
    handleApexResponse (response) {
        return new Promise((resolve, reject) => {
            if (response) {
                if (response.success) {
                    resolve(response.data);
                } else {
                    reject(response.message);
                }
            }
        });
    }

    // === METHOD: handleError ===
    handleError (e) {
        this.error = e;
        this.dispatchErrorEvent(this.error);
    }

    // === METHOD: resolveToFieldName ===
    resolveToFieldName (relationshipName) {
        let fieldName = relationshipName || '';

        // Resolve custom field relationship name to field name
        fieldName = fieldName.replace(/__r$/i, '__c');

        // Resolve standard field relationship name to field name
        if (!/__c$/i.test(fieldName)) {
            fieldName += 'Id';
        }

        return fieldName;
    }

    // === METHOD: dispatchErrorEvent ===
    dispatchErrorEvent (error) {
        if (this.mc('ui').isConnected) {
            this.getComponent().dispatchEvent(
                new CustomEvent('error', {
                    composed: true,
                    bubbles: true,
                    detail: error
                })
            );
        }
    }
}