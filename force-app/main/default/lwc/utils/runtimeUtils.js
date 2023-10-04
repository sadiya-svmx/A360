import {
    sortObjectArray,
    isEmptyString,
    FIELD_DATA_TYPES,
    OBJECT_ICONS,
    OBJECT_DEFAULT_ICON,
    FIELD_API_NAMES,
    PAGE_ELEMENT_EVENT_TYPES,
} from './utils';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelLabelMissing from '@salesforce/label/c.Label_LabelMissing';
import labelOptionPlaceholder from '@salesforce/label/c.Combo_Placeholder';
import CURRENCY from '@salesforce/i18n/currency';
import TIMEZONE from '@salesforce/i18n/timeZone';
import PRODUCT_CONSUMED_OBJECT from '@salesforce/schema/ProductConsumed';
import WORK_ORDER_LINE_ITEM_OBJECT from '@salesforce/schema/WorkOrderLineItem';

const i18n = {
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    labelMissing: labelLabelMissing
};

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' }
];

export const RUNTIME_CONTEXT = {
    SCREEN_FLOW: 'SCREEN_FLOW',
    TRANSACTION_FLOW: 'TRANSACTION_FLOW',
    TRANSACTION: 'TRANSACTION',
    TRANSACTION_RECORDPAGE: 'TRANSACTION_RECORDPAGE',
};

export const TRANSACTION_TYPE = {
    STANDALONE_EDIT: 'Standalone Edit',
    SOURCE_TO_TARGET: 'Source to Target'
};

export const AVAILABLE_ACTIONS_FLOW_FOOTER = {
    BACK: 'BACK',
    NEXT: 'NEXT',
    PAUSE: 'PAUSE'
};

export const PUBSUB_KEYS = {
    ACTIVE_TAB: 'ACTIVE_TAB'
};

// custom property editor
export const PROPERTY_NAMES = {
    DEVELOPER_NAME: 'developerName',
    RECORD_ID: 'recordId',
    HEADER_RECORD_DATA: 'headerRecordData',
    CHILD1_MODIFIED: 'child1Modified',
    CHILD2_MODIFIED: 'child2Modified',
    CHILD3_MODIFIED: 'child3Modified',
    CHILD4_MODIFIED: 'child4Modified'
}

export const PROPERTY_TYPES = {
    A: 'A',
    B: 'B',
    C: 'C',
    D: 'D',
    H: 'H'
}

export const enableAdvanceLookupSearch = (element) => {
    return !!(
        element.lookupConfigId ||
        element.lookupContext  ||
        element.lookupMatchingField ||
        element.overrideLookupContext
    );
}

export const shouldDisableField = (fieldMetadata, element) => {
    return (element.readOnly || !(fieldMetadata.updateable || fieldMetadata.createable));
}

export const isReadonlySystemField = (fieldMetadata, element) => {
    return (element.readOnly && !fieldMetadata.createable);
}

export const isRequiredField = (fieldMetadata, element) => {
    const systemField = isReadonlySystemField(fieldMetadata, element);
    return (!systemField && (element.required ||
        (!fieldMetadata.nillable && fieldMetadata.dataType !== FIELD_DATA_TYPES.BOOLEAN)));
}

export const getLookupReferenceToObject = fieldDef => {
    if (fieldDef && fieldDef.referenceTo && fieldDef.referenceTo.length > 0) {
        return fieldDef.referenceTo.toString();
    } else if (fieldDef && fieldDef.apiName === FIELD_API_NAMES.RECORD_TYPE_ID ) {
        return 'RecordType';
    }
    return null;
}

export const getLookupReferenceNameFields = (fieldDef) => {
    if (fieldDef && fieldDef.referenceNameFields && fieldDef.referenceNameFields.length > 0) {
        return fieldDef.referenceNameFields.toString();
    } else if (fieldDef && fieldDef.apiName === FIELD_API_NAMES.RECORD_TYPE_ID ) {
        return 'DeveloperName';
    }
    return null;
}

export const transformChildRecordData = pageDetails => {
    const lines = {};
    if (pageDetails && pageDetails.length) {
        pageDetails
            .map(line => ({ [line.uniqueKey]: line.detailRecords }))
            .forEach(item => {
                lines[Object.keys(item)[0]] = Object.values(item)[0];
            });
    }
    return lines;
};

// was added to group those selected records in grid & is no longer required for save
const PAGEDATA_RECORD_PROPS_TO_IGNORE = new Set(['objectApiName', 'isNew']);

const PAGEDATA_RECORD_PROPS_TO_IGNORE_IF_EMPTY = new Set([FIELD_API_NAMES.RECORD_TYPE_ID]);

const PAGEDATA_RECORD_PROPS_TO_IGNORE_BY_SF_OBJECT = new Map([
    [PRODUCT_CONSUMED_OBJECT.objectApiName, new Set([FIELD_API_NAMES.PRODUCT2ID])],
    [WORK_ORDER_LINE_ITEM_OBJECT.objectApiName, new Set([FIELD_API_NAMES.PRODUCT2ID])],
]);

export const transformRecordForSave = (record = {}, objectName) => {
    const sanitizedRecord = {};

    const { type } = record.attributes || {};
    const objectApiName = type
        ? type
        : objectName;

    const sfObjectPropsToDelete =
        PAGEDATA_RECORD_PROPS_TO_IGNORE_BY_SF_OBJECT.get(objectApiName) || new Set();

    for (const prop in record) {
        if (Object.prototype.hasOwnProperty.call(record, prop)) {
            const propertyValue = record[prop];

            // Skip disallowed properties and nested objects (from lookups)
            if (
                PAGEDATA_RECORD_PROPS_TO_IGNORE.has(prop) ||
                (prop !== 'attributes' && propertyValue && typeof propertyValue === 'object')
            ) {
                continue;
            }

            // Skip object-specific disallowed properties
            if (sfObjectPropsToDelete.has(prop)) {
                continue;
            }

            // Skip properties that are not allowed to be null/blank
            if (
                PAGEDATA_RECORD_PROPS_TO_IGNORE_IF_EMPTY.has(prop) &&
                isEmptyString(propertyValue)
            ) {
                continue;
            }

            sanitizedRecord[prop] = propertyValue;
        }
    }

    // add attributes props to sObject in case of flow records and custom action 
    if (
        objectApiName &&
        !Object.prototype.hasOwnProperty.call(sanitizedRecord, "attributes")
    ) {
        sanitizedRecord.attributes = { type: objectApiName };
    }

    return sanitizedRecord;
}

// was added to group those selected records in grid & is no longer required for save
const FLOW_RECORD_PROPS_TO_IGNORE = new Set(['objectApiName']);

const FLOW_UNSUPPORTED_FIELD_TYPES = new Set([
    FIELD_DATA_TYPES.ADDRESS,
    FIELD_DATA_TYPES.LOCATION,
    FIELD_DATA_TYPES.TIME,
]);

export const transformRecordForFlow = (record = {}, fieldsMetaData = {}) => {
    const sanitizedRecord = {};

    for (const prop in record) {
        if (Object.prototype.hasOwnProperty.call(record, prop)) {
            const propertyValue = record[prop];
            const fieldMetadata = fieldsMetaData[prop];

            // Skip disallowed properties and nested objects (from lookups)
            if (
                FLOW_RECORD_PROPS_TO_IGNORE.has(prop) ||
                (prop !== 'attributes' && propertyValue && typeof propertyValue === 'object')
            ) {
                continue;
            }

            // Skip fields with unsupported data types
            if (fieldMetadata && FLOW_UNSUPPORTED_FIELD_TYPES.has(fieldMetadata.dataType)) {
                continue;
            }

            // Skip Id field from new records
            if (record.isNew && prop === 'Id') {
                continue;
            }

            sanitizedRecord[prop] = propertyValue;
        }
    }

    return sanitizedRecord;
};

const _getFieldTypeAttributes = (fieldDef, fieldType, columnDef) => {
    const typeAttributes = {
        label: columnDef.label,
        fieldName: columnDef.fieldName,
        required: columnDef.required,
    };

    if (fieldType === 'textarea' || fieldType === 'boolean') {
        Object.assign(typeAttributes, {
            meta: {
                length: fieldDef.length,
            },
            rowId: { fieldName: 'Id' },
            recordTypeId: { fieldName: FIELD_API_NAMES.RECORD_TYPE_ID },
        });
    }

    // captures picklist values
    if (fieldType === 'picklist' || fieldType === 'multipicklist') {
        Object.assign(typeAttributes, {
            rowId: { fieldName: 'Id' },
            recordTypeId: { fieldName: FIELD_API_NAMES.RECORD_TYPE_ID },
            meta: {
                placeholder: labelOptionPlaceholder,
                options: fieldDef.picklistValues,
                multiple: (fieldType === 'multipicklist'),
            },
        });

        if (fieldDef.controllerFieldName) {
            Object.assign(typeAttributes, {
                controllerValue: { fieldName: fieldDef.controllerFieldName },
            });
        }
    }

    // captures lookup stuffs
    if (fieldType === 'reference') {
        const referenceTo = getLookupReferenceToObject(fieldDef);
        let objectIconName = OBJECT_ICONS[referenceTo.toLowerCase()];

        if (!objectIconName) {
            objectIconName = OBJECT_DEFAULT_ICON;
        }
        Object.assign(typeAttributes, {
            rowId: { fieldName: 'Id' },
            meta: {
                filters: '',
                icon: objectIconName,
                object: referenceTo,
                placeholder: 'Search',
                referenceNameFields: getLookupReferenceNameFields(fieldDef),
            },
        });
    }

    if (fieldType === 'date' || fieldType === 'datetime') {
        Object.assign(typeAttributes, {
            month: '2-digit',
            day: '2-digit',
            year: 'numeric'
        });
    }

    if (fieldType === 'datetime') {
        Object.assign(typeAttributes, {
            timeZone: TIMEZONE,
            hour: '2-digit',
            minute: '2-digit',
        });
    }

    if (fieldType === 'currency') {
        Object.assign(typeAttributes, {
            currencyCode: fieldDef.currencyCode || CURRENCY,
            currencyDisplayAs: 'symbol',
            minimumFractionDigits: fieldDef.scale,
            step: Math.pow(0.1, fieldDef.scale).toFixed(fieldDef.scale)
        });
    }

    if (fieldType === 'double' || fieldType === 'percent') {
        Object.assign(typeAttributes, {
            minimumFractionDigits: fieldDef.scale
        });
    }

    if (fieldType === 'url') {
        Object.assign(typeAttributes, {
            label: { fieldName: columnDef.fieldName },
            target: '_blank'
        });
    }

    return typeAttributes;
}

const _getAdvancedSearchConfig = (
    element,
    fieldsMetadata,
    sortedFields,
    headerFields,
    tab,
    fieldName) => {

    if (enableAdvanceLookupSearch(element)) {
        const {
            lookupContext,
            lookupMatchingField,
            lookupContextSource,
            lookupConfigId,
            lookupConfigExpressionId,
            overrideLookupContext,
        } = element;

        const isContextInHeaderSection = (lookupContextSource === 'PARENT_RECORD');
        const contextField = (
            isContextInHeaderSection ?
                headerFields.find(field => field.name === lookupContext) :
                sortedFields.find(field => field.name === lookupContext)
        ) || {};

        const contextFieldMetaData = (
            isContextInHeaderSection ?
                (contextField || {}).fieldMetadata :
                fieldsMetadata[tab.objectAPIName][(contextField || {}).name]
        ) || {};

        const isContextFieldLookup = contextFieldMetaData.dataType === "REFERENCE";
        const advancedSearchConfig = {
            contextValue: contextField.value,
            contextDataType: contextFieldMetaData.dataType,
            contextFieldApiName: contextFieldMetaData.apiName,
            contextObjectName: isContextFieldLookup
                ? (contextFieldMetaData.referenceTo || '').toString()
                : null,
            contextReferenceNameFields:
                (contextFieldMetaData.referenceNameFields || '').toString(),
            lookupContext,
            lookupMatchingField,
            lookupContextSource,
            lookupConfigId,
            lookupConfigExpressionId,
            overrideLookupContext,
            isContextFieldLookup,
            fieldName,
            isContextInHeaderSection,
            tabName: tab.name,
        };

        return {
            enableAdvancedSearch: true,
            advancedSearchConfig,
        };
    }

    return {};
}


export const castFieldToSupportType = (fieldType) => {
    let type = '';
    switch (fieldType) {
        // standard types
        case 'date':
            type = 'date-local';
            break;
        case 'datetime':
            type = 'date';
            break;
        case 'percent':
        case 'double':
        case 'int':
            type = 'number';
            break;
        // always readonly as its salesforce system field
        case 'ID':
        case 'url':
            type = 'text';
            break;
        // custom types
        case 'boolean':
            type = 'xCheckbox';
            break;
        case 'reference':
            type = 'xLookup';
            break;
        case 'textarea':
            type = 'xTextarea';
            break;
        case 'picklist':
        case 'multipicklist':
            type = 'xPicklist';
            break;
        default:
            type = fieldType;
    }
    return type;
}


const _getInitialWidthByType = (fieldType) => {
    let width = 180;
    switch (fieldType) {
        case 'textarea':
        case 'datetime':
        case 'reference':
            width = 250;
            break;
        case 'date':
            width = 200;
            break;
        default:
            break;
    }
    return width;
}


const _getColumnDefsForSpecificObject = (
    tabs,
    fieldsMetadata,
    headerFields,
    defaultRecordTypes,
    engineId,
    recordTypeInfosByObjectName
) => {

    // tabs iterator
    const tabsWithTypeFields = tabs.map((tab) => {
        //elements iterator
        let elementWithTypeFiltered = [];
        let tabWithSortedElements = {};
        const { elements, extendedEditDisplayColumns } = tab;
        if (elements && elements.length > 0) {
            const sortedElements = sortObjectArray(elements, 'sequence', 'asc');
            tabWithSortedElements = {
                ...tab,
                section: {
                    sequence: 1,
                    columns: extendedEditDisplayColumns || 1,
                    elements: [...elements],
                    disableExpandable: true,
                    readOnly: tab.readOnly
                },
                elements: [...sortedElements],
                fieldsMetadata: fieldsMetadata[tab.objectAPIName],
                defaultRecordTypeId: defaultRecordTypes[tab.objectAPIName],
            };
            const isOptionalField = element => element.name === tab.controllerReferenceField;
            const elementWithType = tabWithSortedElements.elements.map(element => {
                let columnDef = {};
                const fieldMetadata = fieldsMetadata[tab.objectAPIName][element.name];
                const disabled = (tab.readOnly ||
                    (fieldMetadata && shouldDisableField(fieldMetadata, element))
                );
                const isSystem = fieldMetadata && isReadonlySystemField(fieldMetadata, element);
                const isRequired =
					(fieldMetadata &&
						isRequiredField(fieldMetadata, element)) &&
					!isOptionalField(element);
                const isCurrencyIsoCode = !!(fieldMetadata &&
                    fieldMetadata.apiName === FIELD_API_NAMES.CURRENCY_ISO_CODE
                );
                const editable = !(disabled || isSystem || isCurrencyIsoCode);
                // check to see if metadata exists first
                if (fieldMetadata && element.name === fieldMetadata.apiName) {
                    const fieldType = fieldMetadata.dataType.toLowerCase();
                    const type = castFieldToSupportType(fieldType);
                    columnDef = {
                        // if it's a System Field, eliminate field(s) during clone record action
                        systemField: isSystem,
                        editable,
                        required: tab.readOnly ? false: isRequired,
                        fieldName: element.name,
                        label: fieldMetadata.label,
                        type,
                        elementId: element.id,
                    };

                    const width = _getInitialWidthByType(fieldType);
                    if (width) {
                        columnDef.initialWidth = width;
                    }

                    // Get the base Search attributes
                    const typeAttributes = _getFieldTypeAttributes(
                        fieldMetadata,
                        fieldType,
                        columnDef
                    );

                    // Add in advanced search config
                    if (fieldMetadata.dataType === FIELD_DATA_TYPES.REFERENCE) {
                        const advancedSearchConfig = _getAdvancedSearchConfig(
                            element,
                            fieldsMetadata,
                            sortedElements,
                            headerFields,
                            tab,
                            fieldMetadata.apiName
                        );
                        Object.assign(typeAttributes.meta, advancedSearchConfig);
                        typeAttributes.meta.formFillMappingId = element.formFillMappingId;
                        typeAttributes.meta.lookupConfigExpressionId =
                            element.lookupConfigExpressionId;
                        if (fieldMetadata.apiName === FIELD_API_NAMES.RECORD_TYPE_ID) {
                            Object.assign(typeAttributes.meta, {
                                filters: `SObjectType = '${tab.objectAPIName}' AND isActive = true`,
                                recordTypeInfos:
                                    recordTypeInfosByObjectName[
                                        tab.objectAPIName
                                    ],
                            });
                        }
                    }

                    if (fieldMetadata.dataType === FIELD_DATA_TYPES.PICKLIST ||
                        fieldMetadata.dataType === FIELD_DATA_TYPES.MULTIPICKLIST) {
                        Object.assign(typeAttributes.meta, {
                            objectApiName: tab.objectAPIName,
                            fieldApiName: fieldMetadata.apiName,
                            controllerFieldName: fieldMetadata.controllerFieldName,
                            defaultRecordTypeId: defaultRecordTypes[tab.objectAPIName],
                        });
                    }


                    // Assign common attributes
                    Object.assign(typeAttributes, {
                        disabled,
                        editable,
                        fieldType,
                        type,
                    });

                    // Ensure that the type attributes are stringified.
                    if (typeAttributes.meta) {
                        typeAttributes.meta.engineId = engineId;
                        typeAttributes.meta.childId = tab.name;
                        typeAttributes.meta = JSON.stringify(typeAttributes.meta);
                    }

                    columnDef.typeAttributes = typeAttributes;
                } else {
                    columnDef.shouldIgnoreFromRendering = true;
                }

                return columnDef;
            });

            // skip field(s) from rendering that user do not have access
            elementWithTypeFiltered = elementWithType.filter(el => !el.shouldIgnoreFromRendering)

            // add actions column to the last column of datatable
            const rowActions = ROW_ACTIONS.filter(action =>
                (tab.deleteRow && action.name === 'delete') ||
                (tab.addRow && action.name === 'clone') ||
                (action.name === 'edit'));

            if (rowActions.length > 0) {
                elementWithTypeFiltered.splice(elementWithTypeFiltered.length, 0, {
                    type: 'action',
                    fixedWidth: 20,
                    typeAttributes: {
                        rowActions: rowActions,
                        menuAlignment: 'auto'
                    }
                });
            }
        }
        return { ...tabWithSortedElements, elements: [...elementWithTypeFiltered]};
    });

    // render only those child lines with fields 
    return tabsWithTypeFields.filter(tab => tab.elements.length > 0);
}


export const getColumns = (
    tabs,
    fieldsMetadata,
    headerFields,
    defaultRecordTypes,
    engineId,
    recordTypeInfosByObjectName,
) => {
    const sortedTabs = sortObjectArray(tabs, 'sequence', 'asc');
    return _getColumnDefsForSpecificObject(
        sortedTabs,
        fieldsMetadata,
        headerFields,
        defaultRecordTypes,
        engineId,
        recordTypeInfosByObjectName
    );
};

export const cellFormatterByType = (fieldProps = {}) => {
    let formatter;
    switch (fieldProps.fieldType) {
        // checkbox doesn't render a string value
        case 'boolean':
            formatter = 'xCheckbox';
            break;
        // Update render string for multipicklist.
        case 'multipicklist':
        case 'picklist':
            formatter = value => {
                const meta =  fieldProps.meta || '{}';
                const metaObject = typeof meta === 'string' ?
                    JSON.parse(meta) : meta;
                const options = metaObject.options || [];
                if (fieldProps.fieldType === 'multipicklist') {
                    const values = value && typeof value === 'string'
                        ? value.split(';') : value;
                    const labels = (values || []).map(val => {
                        const item = options.filter(ele => ele.value === val);
                        return item.length ? item[0].label : val;
                    });
                    return labels.join(', ');
                }
                const item = options.filter(ele => ele.value === value);
                return item.length ? item[0].label : value;
            }
            break;
        // the cell renderer handles lookup as a special case.
        case 'reference':
            formatter = () => null;
            break;
        case 'textarea':
        default:
            formatter = value => value;
    }
    return formatter;
}

export const privateMethodsForTest = {
    _getAdvancedSearchConfig,
    _getColumnDefsForSpecificObject,
    _getFieldTypeAttributes,
    _getInitialWidthByType
};

export const recordActions = {
    created: 'Created',
    selected: 'Selected',
    modified: 'Modified',
    deleted: 'Deleted',
    new: 'New',
}

export const isFlowContext = (context) => {
    return (
        context === RUNTIME_CONTEXT.SCREEN_FLOW ||
        context === RUNTIME_CONTEXT.TRANSACTION_FLOW
    );
}

export const isTransactionContext = (context) => {
    return (
        context === RUNTIME_CONTEXT.TRANSACTION_FLOW ||
        context === RUNTIME_CONTEXT.TRANSACTION ||
        context === RUNTIME_CONTEXT.TRANSACTION_RECORDPAGE
    );
}

export const isRecordPageContext = (context) => {
    return (
        context === RUNTIME_CONTEXT.TRANSACTION_RECORDPAGE
    );
}

export const transformRecordTypesByPicklist = (picklist) => {
    const { controllerValues = {}, values = []} = picklist;
    const fieldDependencies = {};
    const ctrlValues = Object.keys(controllerValues).reduce((acc, key) => {
        const value = controllerValues[key];
        return { ...acc, [value]: key }
    },
    {}
    );

    let isControllerAsBoolean = false;
    const keys = Object.keys(controllerValues);
    if (keys.length === 2 &&
        keys[0] === 'false' &&
        keys[1] === 'true') {
        isControllerAsBoolean = true;
    }

    const picklistValues = values.map(item => {
        const { label, value, validFor } = item;

        validFor.forEach(index => {
            const controllerValue = ctrlValues[index];
            fieldDependencies[controllerValue] = fieldDependencies[controllerValue] || {};
            fieldDependencies[controllerValue][value] = true;

            if (isControllerAsBoolean && controllerValue === 'false' ) {
                fieldDependencies.null = fieldDependencies.null || {};
                fieldDependencies.null[value] = true;
            }
        });

        return { label, value };
    });

    return { picklistValues, fieldDependencies };
}

export const transformRecordTypes = (data) => {
    const picklists = Object.keys(data.picklistFieldValues || {});
    return picklists.reduce((acc, key) => {
        const picklist = data.picklistFieldValues[key];
        return { ...acc, [key]: transformRecordTypesByPicklist(picklist) };
    },
    {}
    );
}

export const transformObjectDefinition = (objectDef, currencyCode, defaultRecordTypeId) => {
    const objectDefinition = (objectDef || []).reduce((acc, field) => {
        return { ...acc, [field.apiName]: { ...field }};
    },
    {}
    );

    Object.keys(objectDefinition).forEach(key => {
        const field = objectDefinition[key];
        if ((field.dataType === FIELD_DATA_TYPES.PICKLIST ||
            field.dataType === FIELD_DATA_TYPES.MULTIPICKLIST
        ) &&
            field.controllerFieldName &&
            objectDefinition[field.controllerFieldName]) {

            const dependentFields = objectDefinition[field.controllerFieldName]
                .dependentFields || [];
            dependentFields.push(field.apiName);

            objectDefinition[field.controllerFieldName] = {
                ...objectDefinition[field.controllerFieldName],
                dependentFields,
            };
        }
        else if (field.dataType === FIELD_DATA_TYPES.CURRENCY &&
            currencyCode) {
            objectDefinition[key] = { ...field, currencyCode: currencyCode };
        }

        if (key === FIELD_API_NAMES.RECORD_TYPE_ID) {
            objectDefinition[key] = { ...field, defaultRecordTypeId };
        }
    });

    return objectDefinition;
}

export const handleObjectFieldDependencies = (
    newRecord,
    record,
    fieldsMetadata,
    recordTypes,
    updateHandler
) => {
    if (!Object.keys(newRecord || {}).length ||
        !Object.keys(record || {}).length ||
        !Object.keys(fieldsMetadata || {}).length ||
        !Object.keys(recordTypes || {}).length
    ) {
        return;
    }

    const currentRecord = { ...record };
    const fieldName = Object.keys(newRecord)[0];
    const fieldValue = newRecord[fieldName];

    const recursiveUpdateFieldDependencies = (field, controllerValue) => {
        field.dependentFields.forEach(depedentName => {
            const dependentValue = currentRecord[depedentName];
            const valueAsArray = dependentValue && dependentValue.split(";") || dependentValue;
            const fieldDependencies = (recordTypes[depedentName] || {}).fieldDependencies;

            const validValues = [];
            (valueAsArray || []).forEach(value => {
                const isValid = (fieldDependencies[controllerValue] || {})[value];
                if (isValid) {
                    validValues.push(value);
                }
            });

            if (valueAsArray &&
                valueAsArray.length !== validValues.length
            ) {
                const newValue = validValues.length? validValues.join(";") : null;
                currentRecord[depedentName] = newValue;
                if (updateHandler)
                    updateHandler({ [depedentName]: newValue });
            }

            const dependentField = fieldsMetadata[depedentName] || {};
            if (dependentField.dependentFields &&
                dependentField.dependentFields.length) {
                recursiveUpdateFieldDependencies(dependentField, currentRecord[depedentName]);
            }
        });
    }

    if (Object.keys(currentRecord).length &&
        recordTypes) {

        const field = fieldsMetadata[fieldName] || {};
        if (field.dependentFields &&
            field.dependentFields.length) {

            recursiveUpdateFieldDependencies(field, fieldValue);
        }
    }
}

export const sortingSectionElements = (elements, fieldsMetadata) => {
    const sortedElements = sortObjectArray(elements,'sequence','asc');
    sortedElements.forEach(element => {
        const fieldMetadata = fieldsMetadata[element.name];
        if (!fieldMetadata && element.type !== 'Empty Space') {
            const column = element.column;
            const seq = element.sequence;
            sortedElements.forEach(ele => {
                if (ele.column === column &&
                    ele.row>1 &&
                    ele.sequence>seq) {
                    ele.row--;
                }
            });
        }
    });

    return sortedElements;
}

export const createActionConfigFromElement = (element = {}) => {
    const events = element.events || [];

    const intents = {};
    Object.values(PAGE_ELEMENT_EVENT_TYPES).forEach(eventType => {
        intents[eventType] = events.filter(e => e.type === eventType);
    });

    return {
        label: element.title || i18n.labelMissing,
        name: element.id,
        icon: '',
        intents
    };
};

export const filterRecords = (
    keyword,
    displayRecords,
    displayFields,
    selectedRows,
    fieldsMetadata = {},
    resolvedLookup = {}
) => {
    const records = displayRecords.filter(record => {
        let recordMatched = false;
        for (let index = 0; index < displayFields.length; index++) {
            const fieldName = displayFields[index];
            if (fieldName) {
                let value = record[fieldName];
                if (fieldsMetadata[fieldName]?.dataType === FIELD_DATA_TYPES.REFERENCE) {
                    value = resolvedLookup[value] || value;
                }
                if (value) {
                    try {
                        const keywordStr = keyword.replace('*', '\\*');
                        recordMatched =
                            new RegExp(keywordStr, 'gi').test(value) ||
                            selectedRows.includes(record.Id);
                    } catch (e) {
                        console.error(e)
                    }
                }
                if (recordMatched) {
                    break;
                }
            }
        }
        return recordMatched;
    });
    return records;
}