import {
    VALUE_INPUT_FIELD_CONTEXT,
    FIELD_DATA_TYPES,
    PAGE_ELEMENT_TYPES,
    verifyApiResponse,
    formatString,
    isReadonlySystemField,
    isRequiredField,
    isNotUndefinedOrNull,
    shouldDisableField,
    guid,
    FIELD_API_NAMES,
    PAGE_ELEMENT_STATIC_ACTIONS,
    enableAdvanceLookupSearch,
    sortingSectionElements,
    createActionConfigFromElement,
} from 'c/utils';

import {
    registerRuntimeFieldValueChange,
    registerRuntimeGridValues,
    HEADER,
    GRID,
} from 'c/runtimePubSub';


const isFunction = (value) => typeof value === 'function';
const isNull = (value) => value === null;
const identity = value => value;

export const VALIDATION_RULE_TYPE = {
    REQUIRED: 'REQUIRED',
    DATAVALIDATION: 'DATAVALIDATION'
}

export const VALIDATION_ERROR_TYPE = {
    ERROR: 'ERROR',
    WARNING: 'WARNING'
}

export const ENGINE_ERROR = {
    STATE_INITIALIZE_FAILED: 'STATE_INITIALIZE_FAILED',
    STATE_REINITIALIZE_FAILED: 'STATE_REINITIALIZE_FAILED',
    OBJECT_DESCRIBE_FAILED: 'OBJECT_DESCRIBE_FAILED',
    INVALID_INTENT_CONFIG: 'INVALID_INTENT_CONFIG',
    EXPRESSION_APEX_ERROR: 'EXPRESSION_APEX_ERROR',
}

export const EXPRESSION_EVALUATION_EVENT = {
    ALWAYS: 'Always',
    FIELDCHANGE: 'Field Change',
    ONLOAD: 'On Load'
}

export const newRecordPattern = /^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$/;

export function createAction (
    type,
    payloadCreator = identity,
    metaCreator
) {

    const finalPayloadCreator =
      isNull(payloadCreator) || payloadCreator ===  identity
          ? identity
          // eslint-disable-next-line @lwc/lwc/no-rest-parameter
          : (head, ...args) =>
              (head instanceof Error ? head : payloadCreator(head, ...args));

    const hasMeta = isFunction(metaCreator);
    const typeString = type.toString();

    // eslint-disable-next-line @lwc/lwc/no-rest-parameter
    const actionCreator = (...args) => {
        const payload = finalPayloadCreator(...args);
        const action = { type };

        if (payload instanceof Error) {
            action.error = true;
        }

        if (payload !== undefined) {
            action.payload = payload;
        }

        if (hasMeta) {
            action.meta = metaCreator(...args);
        }

        return action;
    };

    actionCreator.toString = () => typeString;

    return actionCreator;
}

const getCustomButtons = (elements, id, screenType, enableEditTransaction, enableDebugMode) => {
    let editLayout;
    const enableDebug = { ...PAGE_ELEMENT_STATIC_ACTIONS.DEBUG_TRANSACTION, id };
    if (screenType === 'Screen') {
        editLayout = { ...PAGE_ELEMENT_STATIC_ACTIONS.EDIT_SCREEN, id };
    } else {
        editLayout = { ...PAGE_ELEMENT_STATIC_ACTIONS.EDIT_TRANSACTION, id };
    }
    const buttons =
    (elements || []).filter(element => element.type === PAGE_ELEMENT_TYPES.BUTTON);
    const buttonsMap = buttons.map(createActionConfigFromElement);
    if (enableEditTransaction) {
        buttonsMap.push(editLayout);
    }
    if (enableDebugMode) {
        buttonsMap.push(enableDebug);
    }
    return buttonsMap;
}

const configureLookupfieldsInHeaderSections = (sections) => {
    // Collect all the fields
    const fields = sections.reduce((acc, section) => {
        const newAcc = [...acc, ...section.elements];
        return newAcc;
    }, []);

    // Check which fields are lookup configured
    const targetFields = fields.filter(field => {
        return (field.lookupConfigId ||
            field.lookupContext ||
            field.lookupMatchingField ||
            field.overrideLookupContext
        );
    });

    // Check if the marked targetFields have `lookupContext`, if so then get the
    // context-field from the above `fields`-collection
    targetFields.forEach(targetField => {
        if (targetField.lookupContext || targetField.lookupConfigId) {
            const contextField =
                fields.find(field => field.name === targetField.lookupContext) || {};

            const {
                lookupContext,
                lookupMatchingField,
                lookupContextSource,
                lookupConfigId,
                lookupConfigExpressionId,
                overrideLookupContext,
                fieldMetadata: { apiName: fieldName }
            } = targetField;

            // Keeping ES6 guard-rail / default value if lookupContext is not configured
            const {
                fieldMetadata: {
                    dataType: contextDataType,
                    apiName: contextFieldApiName,
                    referenceNameFields: contextFieldReferenceFields,
                    referenceTo: contextFieldReferenceTo
                } = {}
            } = contextField;

            const isContextFieldLookup = (contextDataType === FIELD_DATA_TYPES.REFERENCE);
            const contextObjectName = isContextFieldLookup ?
                contextFieldReferenceTo.toString() : null;

            targetField.meta.advancedSearchConfig = {
                contextValue: contextField.value,
                contextDataType,
                contextFieldApiName,
                contextObjectName,
                contextReferenceNameFields: (contextFieldReferenceFields || '').toString(),
                lookupContext,
                lookupMatchingField,
                lookupContextSource,
                lookupConfigId,
                lookupConfigExpressionId,
                overrideLookupContext,
                isContextFieldLookup,
                fieldName,
                // for header fields, context is always in header
                isContextInHeaderSection: true,
                // since it is a headerSection field
                tabName: null,
            };
            targetField.meta.enableAdvancedSearch = true;
        }
    });
}

const prepareSectionAndElements = (section, fieldsMetadata) => {
    if (section.hideName) {
        section.disableExpandable = true;
    }
    if (section.columns === 1) {
        return section.elements;
    }

    return sortingSectionElements(section.elements, fieldsMetadata);
}

const getHeaderSectionsFieldValue = (headerRecordData, fieldApiname) => {
    if (headerRecordData && headerRecordData[fieldApiname]) {
        return headerRecordData[fieldApiname];
    }

    return null;
}

export const transformPageLayout = (result) => {
    const parsedData = JSON.parse(result);
    if (!verifyApiResponse(parsedData)) {
        return { error: true, message: parsedData.message };
    }
    const {
        data: {
            id,
            name,
            hideName,
            launchDesigner: enableEditTransaction,
            enableDebugMode,
            lines: tabs = [],
            pageHeader: {
                elements = [],
                sections = [],
                objectAPIName: headerObject,
                sourceObjectAPIName: sourceObject,
                screenType,
                transactionType,
                valueMapping,
                fieldMapping
            },
        }
    } = parsedData;

    // Handle custom page layout elements (buttons, etc)
    const buttons = getCustomButtons(
        elements,
        id,
        screenType,
        enableEditTransaction,
        enableDebugMode,
    );

    let childObjects = [];
    const configInfos = {};
    if (isNotUndefinedOrNull(valueMapping) || isNotUndefinedOrNull(fieldMapping)) {
        configInfos.header = {
            mapping: {
                valueMapping,
                fieldMapping
            }
        }
    }
    if (tabs.length) {
        childObjects = tabs.map(tab => {
            if (
                isNotUndefinedOrNull(tab.valueMapping) ||
                isNotUndefinedOrNull(tab.fieldMapping) ||
                isNotUndefinedOrNull(tab.qualifyingCriteria)
            ) {
                configInfos[tab.name] = {
                    mapping: {
                        valueMapping: tab.valueMapping,
                        fieldMapping: tab.fieldMapping,
                    },
                    expression: {
                        visibilityCriteria: tab.visibilityCriteria,
                        qualifyingCriteria: tab.qualifyingCriteria,
                    },
                    sequence: tab.sequence,
                };
            }
            return tab.objectAPIName;
        });
    }

    return {
        name,
        hideName,
        buttons,
        tabs,
        sections,
        screenType,
        transactionType,
        headerObject,
        sourceObject,
        childObjects,
        configInfos,
    };
}

export const transformHeaderFields = (
    sections,
    fieldsMetadata,
    childRecordCount,
    headerObjectName,
    headerRecordData,
    defaultRecordTypes,
    recordTypeInfosByObjectName
) => {
    // Section iterator
    const outputSections = sections.map(section => {
        // Element iterator
        const elements = prepareSectionAndElements(
            section,
            fieldsMetadata[headerObjectName]
        );
        let elementWithTypeFiltered = [];
        if (elements && elements.length > 0) {
            const elementWithType = elements.map(element => {
                const fieldMetadata = fieldsMetadata[headerObjectName][element.name];

                let field = {};
                if (fieldMetadata && element.name === fieldMetadata.apiName) {
                    field = {
                        ...element,
                        fieldMetadata: { ...fieldMetadata },
                        value: getHeaderSectionsFieldValue(
                            headerRecordData,
                            fieldMetadata.apiName
                        ),
                        disabled: section.readOnly || shouldDisableField(fieldMetadata, element),
                        system: isReadonlySystemField(fieldMetadata, element),
                        required: isRequiredField(fieldMetadata, element),
                        isField: true,
                    };

                    if (fieldMetadata.dataType === FIELD_DATA_TYPES.PICKLIST ||
                        fieldMetadata.dataType === FIELD_DATA_TYPES.MULTIPICKLIST) {
                        field.picklistValues = fieldMetadata.picklistValues;
                        field.fieldMetadata.recordTypeId =
                            getHeaderSectionsFieldValue(
                                headerRecordData,
                                FIELD_API_NAMES.RECORD_TYPE_ID
                            );
                        field.fieldMetadata.objectApiName = headerObjectName;
                        field.fieldMetadata.defaultRecordTypeId =
                            defaultRecordTypes[headerObjectName];

                        if (fieldMetadata.controllerFieldName) {
                            field.fieldMetadata.controllerValue =
                                getHeaderSectionsFieldValue(
                                    headerRecordData,
                                    fieldMetadata.controllerFieldName
                                );
                        }
                    }

                    if (fieldMetadata.apiName === FIELD_API_NAMES.CURRENCY_ISO_CODE &&
                        childRecordCount) {
                        field.fieldMetadata.disabled = field.disabled;
                        field.disabled = true;
                    }

                    /**
                     * Handles runtime specific header field experience
                     * E.g. type boolean field, checkbox Vs. combobox, isFormula etc., that
                     * are different from other consumers of the value-input component
                     */
                    field.context = VALUE_INPUT_FIELD_CONTEXT.RUNTIME;
                    if (fieldMetadata.dataType === FIELD_DATA_TYPES.REFERENCE) {
                        // Lookup to query these reference-name-fields against the object
                        field.meta = {
                            objectApiName: fieldMetadata.referenceTo.toString(),
                            referenceNameFields: fieldMetadata.referenceNameFields.toString(),
                            enableAdvancedSearch: enableAdvanceLookupSearch(element),
                            formFillMappingId: element.formFillMappingId,
                        }
                        if (fieldMetadata.apiName === FIELD_API_NAMES.RECORD_TYPE_ID) {
                            // eslint-disable-next-line max-len
                            field.meta.filters = `SObjectType = '${headerObjectName}' AND isActive = true`;
                            field.meta.enableAdvancedSearch = false;
                            field.meta.recordTypeInfos =
								recordTypeInfosByObjectName[headerObjectName];
                        }
                    }
                } else if (element.type === 'Empty Space') {
                    field = {
                        ...element,
                        isField: false,
                        name: guid(),
                    };
                } else {
                    field.shouldIgnoreFromRendering = true;
                }
                return field;
            });

            // Skip field(s) from rendering that user do not have access
            // source of truth is fieldMetadata(does not exists such fields)
            elementWithTypeFiltered = elementWithType.filter(element =>
                !element.shouldIgnoreFromRendering
            );
        }

        return { ...section, elements: [...elementWithTypeFiltered]};
    });

    // Configuring fields(lookup fields)
    configureLookupfieldsInHeaderSections(outputSections);
    return outputSections;
}

export const transformSectionElements = (tab, record, recordTypeInfosByObjectName) => {
    const elements = sortingSectionElements(
        tab.section.elements,
        tab.fieldsMetadata
    );
    let elementWithTypeFiltered = [];
    if (elements && elements.length > 0) {
        const elementWithType = elements.map(element => {
            const fieldMetadata = tab.fieldsMetadata[element.name];

            let field = {};
            if (fieldMetadata && element.name === fieldMetadata.apiName) {
                field = {
                    ...element,
                    fieldMetadata: { ...fieldMetadata },
                    value: record[fieldMetadata.apiName] || null,
                    disabled: tab.section.readOnly || shouldDisableField(fieldMetadata, element),
                    system: isReadonlySystemField(fieldMetadata, element),
                    required: isRequiredField(fieldMetadata, element),
                    isField: true,
                };

                if (fieldMetadata.apiName === FIELD_API_NAMES.CURRENCY_ISO_CODE) {
                    field.disabled = true;
                }

                if (fieldMetadata.dataType === FIELD_DATA_TYPES.PICKLIST ||
                    fieldMetadata.dataType === FIELD_DATA_TYPES.MULTIPICKLIST) {
                    field.picklistValues = fieldMetadata.picklistValues;
                    field.fieldMetadata.recordTypeId =
                        record[FIELD_API_NAMES.RECORD_TYPE_ID];
                    field.fieldMetadata.objectApiName = tab.objectAPIName;
                    field.fieldMetadata.defaultRecordTypeId =
                        tab.defaultRecordTypeId;

                    if (fieldMetadata.controllerFieldName) {
                        field.fieldMetadata.controllerValue =
                            record[fieldMetadata.controllerFieldName];
                    }
                }


                /**
                 * Handles runtime specific header field experience
                 * E.g. type boolean field, checkbox Vs. combobox, isFormula etc., that
                 * are different from other consumers of the value-input component
                 */
                field.context = VALUE_INPUT_FIELD_CONTEXT.RUNTIME;
                if (fieldMetadata.dataType === FIELD_DATA_TYPES.REFERENCE) {
                    // Copy lookup configuration from "column" variant
                    const associatedColumn = tab.elements.find(
                        column => column.fieldName === fieldMetadata.apiName
                    );

                    field.meta = JSON.parse(associatedColumn?.typeAttributes?.meta || '{}');
                    field.meta.objectApiName = field.meta.object;

                    // Stamp tab id and row index onto advanced search config
                    const advancedSearchConfig = field.meta.advancedSearchConfig || {};
                    if (Object.keys(advancedSearchConfig).length) {
                        advancedSearchConfig.tabName = tab.name;
                        advancedSearchConfig.rowIndex = record.Id;
                        if (!Object.prototype.hasOwnProperty.call(
                            advancedSearchConfig,
                            'isContextInHeaderSection'
                        )) {
                            advancedSearchConfig.isContextInHeaderSection = false;
                        }
                    }
                    field.meta.advancedSearchConfig = advancedSearchConfig;

                    if (fieldMetadata.apiName === FIELD_API_NAMES.RECORD_TYPE_ID) {
                        // eslint-disable-next-line max-len
                        field.meta.filters = `SObjectType = '${tab.objectAPIName}' AND isActive = true`;
                        field.meta.enableAdvancedSearch = false;
                        field.meta.recordTypeInfos =
							recordTypeInfosByObjectName[tab.objectAPIName];
                    }
                }
            } else {
                field.shouldIgnoreFromRendering = true;
            }
            return field;
        });

        // Skip field(s) from rendering that user do not have access
        // source of truth is fieldMetadata(does not exists such fields)
        elementWithTypeFiltered = elementWithType.filter(element =>
            !element.shouldIgnoreFromRendering
        );
    }

    if (tab.section.columns === 2) {
        let column = 1;
        let row = 1;
        elementWithTypeFiltered = elementWithTypeFiltered.map(ele => {
            const element = { ...ele, column, row };
            if (column === 2) row++;
            column = column === 1? 2 : 1;
            return element;
        });
    }

    return elementWithTypeFiltered;
}

export const getUpdatedSectionsByRecord = (sections, recordData) => {
    return (sections || []).map(section => {
        const elements = (section.elements || []).map(element => {
            const { fieldMetadata = {}} = element;
            const value = getHeaderSectionsFieldValue(recordData, fieldMetadata.apiName);

            if (fieldMetadata.dataType === FIELD_DATA_TYPES.PICKLIST ||
                fieldMetadata.dataType === FIELD_DATA_TYPES.MULTIPICKLIST) {

                fieldMetadata.recordTypeId =
                    getHeaderSectionsFieldValue(recordData, FIELD_API_NAMES.RECORD_TYPE_ID);

                if (fieldMetadata.controllerFieldName) {
                    fieldMetadata.controllerValue =
                        getHeaderSectionsFieldValue(recordData, fieldMetadata.controllerFieldName);
                }

                return { ...element, value, fieldMetadata };
            }
            return { ...element, value };
        });
        return { ...section, elements };
    });
}

export const getUpdatedTabsByCurrencyCode = (tabs, currencyCode) => {
    return (tabs|| []).map(tab => {
        const elements = (tab.elements || []).map(element => {
            const { type, typeAttributes } = element;
            if (type === 'currency') {
                return {
                    ...element,
                    typeAttributes: {
                        ...typeAttributes, currencyCode
                    }
                }
            }
            return { ...element };
        });
        return { ...tab, elements };
    });
}

export const mungeFormfillIdByFieldNames = (sections) => {
    const formFillIdByName = {};
    (sections || []).forEach(section => {
        (section.elements || []).forEach(element => {
            if (element.formFillMappingId || element.applyMapping === 'Conditional') {
                formFillIdByName[element.name] = {
                    formFillMappingId: element.formFillMappingId,
                    applyMapping: element.applyMapping,
                    expressionBasedMapping: element.expressionBasedMapping,
                    objectApiName: element.meta.objectApiName,
                }
            }
        });
    });
    return formFillIdByName;
}

export const mungeChildFormfillIdByFieldNames = (tabs) => {
    const childformFillIdByName = {};
    (tabs || []).forEach(tab => {
        childformFillIdByName[tab.name] = {};
        ((tab.section || {}).elements || []).forEach(element => {
            if (element.formFillMappingId || element.applyMapping === 'Conditional') {
                const typeEl = tab.elements.find(ele => ele.elementId === element.id);
                const objectApiName = JSON.parse(typeEl.typeAttributes.meta).object;
                childformFillIdByName[tab.name][element.name] = {
                    formFillMappingId: element.formFillMappingId,
                    applyMapping: element.applyMapping,
                    expressionBasedMapping: element.expressionBasedMapping,
                    objectApiName,
                }
            }
        });
    });
    return childformFillIdByName;
}

export const mungeTabsByChildId = (tabs) => {
    const tabsByChildId = {};
    (tabs || []).forEach(tab => {
        tabsByChildId[tab.name] = tab;
    });
    return tabsByChildId;
}

export const omitKeys = (referer, keysToOmit) => {
    (keysToOmit || []).forEach(key => {
        delete referer[key];
    });
    return referer;
}

export const omitElements = (referer, elementsToOmit) => {
    const output = [];
    (referer || []).forEach(element => {
        if (!elementsToOmit.includes(element)) {
            output.push(element);
        }
    });
    return output;
}

export const uniqueArray = (list) => {
    return [...new Set(list)];
}

export const mungeChildRecordData = (childValues, childValuesSequence) => {
    const childRecordData = {};
    Object.keys(childValues).forEach(name => {
        childRecordData[name] = [];
        const recordIds = Object.keys(childValues[name]);
        (childValuesSequence[name] || []).forEach(recId => {
            childRecordData[name].push(childValues[name][recId]);
            recordIds.splice(recordIds.indexOf(recId),1);
        });
        recordIds.forEach(recordId => {
            childRecordData[name].push(childValues[name][recordId]);
        });
    });
    return childRecordData;
}

export const mungeChildValidationResults = (childErrors, i18n) => {
    const childErrorData = {};
    Object.keys(childErrors).forEach(name => {
        const errors = { rows: {}};
        Object.keys(childErrors[name]).forEach(recordId => {
            const missingFields = [];
            const missingFieldMessages = [];
            Object.keys(childErrors[name][recordId]).forEach(fieldName => {
                const errs = childErrors[name][recordId][fieldName];
                (errs || []).forEach(error => {
                    if (error.ruleType === VALIDATION_RULE_TYPE.REQUIRED &&
                        error.validationType === VALIDATION_ERROR_TYPE.ERROR) {
                        missingFields.push(fieldName);
                        missingFieldMessages.push(error.validationMessage);
                    }
                });
            });

            const numRequired = missingFields.length;
            if (numRequired > 0) {
                const newError = {
                    fieldNames: missingFields,
                    messages: missingFieldMessages,
                    title: formatString(
                        numRequired !== 1 ?
                            i18n.rowRequiredMultipleErrors
                            : i18n.rowRequiredSingleError,
                        numRequired
                    )
                };
                errors.rows[recordId] = newError;
            }
        });
        childErrorData[name]= errors;
    });
    return childErrorData;
}

export const mungeChildUpdates = (initialChildValues, childValues, childUpdates) => {
    const deltaChildValues = {};
    Object.keys(childUpdates).forEach(childId => {
        deltaChildValues[childId] = [];
        const childUpdate = childUpdates[childId];
        (childUpdate || []).forEach(recordId => {
            const record = (childValues[childId] || {})[recordId];
            const initialRecord = (initialChildValues[childId] || {})[recordId];
            if (!initialRecord && record) {
                deltaChildValues[childId].push(record);
            } else {
                const deltaRecord = {};
                Object.keys(record || {}).forEach(fieldName => {
                    const newFieldValue = record[fieldName];
                    const initialFieldValue = initialRecord[fieldName];

                    if (typeof newFieldValue !== 'object' &&
                        newFieldValue  !== initialFieldValue
                    ) {
                        deltaRecord[fieldName] = newFieldValue;
                    }
                });
                if (Object.keys(deltaRecord).length) {
                    deltaRecord.Id = record.Id;
                    deltaChildValues[childId].push(deltaRecord);
                }
            }
        });
    });
    return deltaChildValues;
}

export const hasCurrencyFieldInSections = (sections) => {
    let currencyField = false;
    (sections || []).forEach(section => {
        section.elements.forEach(element => {
            if (element.name === FIELD_API_NAMES.CURRENCY_ISO_CODE) {
                currencyField = true;
            }
        });
    });
    return currencyField;
}

export const getUpdatedSectionsByCurrencyCode = (sections, hasLines) => {
    return (sections || []).map(section => {
        const elements = (section.elements || []).map(element => {
            const { fieldMetadata = {}} = element;
            if (fieldMetadata.apiName === FIELD_API_NAMES.CURRENCY_ISO_CODE &&
                !fieldMetadata.disabled) {
                if (hasLines)
                    element.disabled = true;
                else if (!hasLines)
                    element.disabled = false;
            }
            return element ;
        });
        section.elements = elements;
        return section;
    });
}

export const registerInitialValuesWithPubSubModal = (engineId, childRecordData) => {
    Object.keys(childRecordData).forEach(childId => {
        Object.keys(childRecordData[childId]).forEach(recordId => {
            const record = childRecordData[childId][recordId];
            const childKeys = Object.keys(record).filter(key => key !== 'Id');
            childKeys.forEach(childKey => {
                registerRuntimeGridValues({
                    engineId,
                    whichSection: GRID,
                    fieldName: childKey,
                    rowIndex: record.Id,
                    tabIndex: childId,
                    value: record[childKey],
                });
            });
        });
    });
}

export const registerHeaderValuesWithPubSubModal = (engineId, record) => {
    Object.keys(record).forEach(fieldName => {
        registerRuntimeFieldValueChange({
            engineId,
            whichSection: HEADER,
            fieldName,
            value: record[fieldName],
            rowIndex: null,
            tabIndex: null
        });
    })
}

export const registerChildValuesWithPubSubModal = (engineId, record, childId, recordId) => {
    Object.keys(record).forEach(fieldName => {
        registerRuntimeFieldValueChange({
            engineId,
            whichSection: GRID,
            fieldName,
            value: record[fieldName],
            rowIndex: recordId,
            tabIndex: childId,
        });
    })
}