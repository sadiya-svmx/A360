import {
    INITIALIZE_ENGINE,
    DESTROY_ENGINE,
    LOAD_HEADER_VALUES,
    LOAD_PAGE_DATA_CONFIG,
    LOAD_CHILD_VALUES,
    UPDATE_HEADER_SECTIONS,
    LOAD_META_DATA,
    LOAD_DEBUG_CONSOLE_META_DATA,
    UPDATE_HEADER_FIELD,
    UPDATE_HEADER_RECORD,
    UPDATE_CHILD_RECORD,
    UPDATE_RECORD_TYPES,
    UPDATE_BLOCK_APPLICATION,
    UPDATE_UN_BLOCK_APPLICATION,
    UPDATE_HEADER_CURRENCY,
    ADD_TEMPORARY_CHILD_LINE,
    EDIT_TEMPORARY_CHILD_LINE,
    COMMIT_TEMPORARY_CHILD_LINE,
    DISCARD_TEMPORARY_CHILD_LINE,
    UPDATE_TEMPORARY_CHILD_RECORD,
    DELETE_CHILD_RECORDS,
    CLONE_CHILD_LINE,
    SELECTED_CHILD_LINES,
    UPDATE_VALIDATION_RESULTS,
    UPDATE_OBJECT_MAPPING,
    UPDATE_OBJECT_MAPPINGS,
    UPDATE_COMPLETE_OBJECT_DESCRIBES,
    UPDATE_EXPRESSION_DETAILS,
    UPDATE_USER_INFO,
    REPLACE_VALUES,
    UPDATE_ENGINE_ERROR,
    REINITIALIZE_ENGINE_STATE,
    UPDATE_DYNAMIC_SECTIONS,
    UPDATE_LOAD_COMPLETED,
    UPDATE_USER_ACTIVITY,
    UPDATE_IS_DEBUG_ENABLED,
    UPDATE_FORMATTED_EXPRESSION_FOR_OBJECT,
    UPDATE_FORMATTED_MAPPING_FOR_OBJECT,
} from './actionNames';

import {
    getUpdatedSectionsByRecord,
    getUpdatedTabsByCurrencyCode,
    transformSectionElements,
    newRecordPattern,
    omitKeys,
    omitElements,
    uniqueArray,
    getUpdatedSectionsByCurrencyCode,
    registerInitialValuesWithPubSubModal,
    registerChildValuesWithPubSubModal,
    registerHeaderValuesWithPubSubModal,
} from './utils';

import {
    RUNTIME_CONTEXT,
    deepCopy,
    transformObjectDefinition,
} from 'c/utils';

import {
    generateRecord,
    cloneRecord,
    getValidationErrorCount,
    hasChildLines,
} from './stateUtils';

export const getInitialState = () => ({
    name: null,
    initialHeaderValues: {},
    headerValues: {},
    pageDataConfig: {},
    childValues: {},
    childValuesSequence: {},
    initialChildValues: {},
    currencyCode: null,
    loadingStatus: {
        LOADING_ENGINE_METADATA: true,
        LOADING_HEADER: true,
        LOADING_CHILDLINE: true,
        API_IN_PROGRESS: true,
    },
    picklistValues: {},
    headerRecordUpdated: false,
    lookupConfigsByFieldNames: {},
    childLookupConfigsByFieldNames: {},
    formFillByFieldNames: {},
    childFormFillByFieldNames: {},
    lookupValuesByFieldNames: {},
    childUpdates: {},
    childDeletes: {},
    childFieldSequenceById: {},
    childLookupValues: {},
    saveStatus: false,
    saveEnabled: true,
    hasUserChanges: false,
    recordTypes: {},
    recordTypeInfosByObjectName: {},
    objectApiNamesWithLabel: {},
    masterSections: [],
    sections: [],
    masterTabs: [],
    tabs: [],
    title: '',
    transactionType: '',
    temporaryChildValues: {},
    temporaryChildSections: {},
    childChangeStatus: {},
    headerFieldEvents: {},
    childFieldEvents: {},
    headerFieldEventsStatus: {},
    childFieldEventsStatus: {},
    buttons: [],
    pageEvents: {},
    childEventsByChildId: {},
    codeSnippetsById: {},
    isLinkedSFM: false,
    objectDescribes: {},
    completeObjectDescribes: {},
    blockApplication: false,
    tabsByChildId: {},
    runtimeContext: RUNTIME_CONTEXT.TRANSACTION_FLOW,
    developerName: null,
    selectedChildValues: {},
    childValidationResults: {},
    headerValidationResults: {},
    hasError: false,
    errorCount: 0,
    objectMappingById: {},
    userInfo: null,
    zeroLineErrors: [],
    hasHeaderCurrencyField: false,
    engineError: null,
    temporaryChildDraftValues: {},
    initialChildValuesSequence: {},
    expressionById: {},
    formattedExpressionsByObject: {},
    formattedMappingsByObject: {},
    dynamicSectionsExpressionFields: [],
    isDebugEnabled: false,
    userActivity: []
});

const ACTION_HANDLERS = {
    [REINITIALIZE_ENGINE_STATE]: (state, { payload }) => {
        if (payload.headerValues) {
            registerHeaderValuesWithPubSubModal(state.engineId, payload.headerValues);
        }
        if (payload.childValues) {
            registerHeaderValuesWithPubSubModal(state.engineId, payload.childValues);
        }
        const { sections } = state;
        const updatedSections = payload.headerValues ?
            getUpdatedSectionsByRecord(sections, payload.headerValues)
            : sections;
        return {
            ...state,
            ...payload,
            sections: updatedSections,
            headerRecordUpdated: false,
            childUpdates: {},
            childDeletes: {},
            hasUserChanges: false,
            engineError: null,
            zeroLineErrors: [],
            selectedChildValues: {},
            childValidationResults: {},
            headerValidationResults: {},
            hasError: false,
            errorCount: 0,
        };
    },
    [LOAD_HEADER_VALUES]: (
        state,
        { payload }
    ) => {
        //cloning header record to avoid any side impact on flow records back to flow runtime
        const cloneHeaderRecord = deepCopy(payload.data);
        if (
            payload.headerObject &&
            !Object.prototype.hasOwnProperty.call(cloneHeaderRecord, "attributes")
        ) {
            cloneHeaderRecord.attributes
                = { type: payload.headerObject };
        }
        registerHeaderValuesWithPubSubModal(state.engineId, cloneHeaderRecord);
        return {
            ...state,
            headerValues: deepCopy(payload.data),
            initialHeaderValues: deepCopy(payload.data),
            currencyCode: payload.currencyCode,
            loadingStatus: {
                ...state.loadingStatus,
                LOADING_HEADER: false,
            },
        };
    },
    [LOAD_PAGE_DATA_CONFIG]: (
        state,
        { payload }
    ) => {
        return {
            ...state,
            pageDataConfig: deepCopy(payload.config),
            loadingStatus: {
                ...state.loadingStatus,
                LOADING_HEADER: false,
            },
        };
    },
    [LOAD_CHILD_VALUES]: (
        state,
        { payload }
    ) => {
        registerInitialValuesWithPubSubModal(state.engineId, payload.childRecords);
        return {
            ...state,
            childValues: deepCopy(payload.childRecords),
            childValuesSequence: deepCopy(payload.childValuesSequence),
            initialChildValuesSequence: deepCopy(payload.childValuesSequence),
            initialChildValues: deepCopy(payload.childRecords),
            loadingStatus: {
                ...state.loadingStatus,
                LOADING_CHILDLINE: false,
            },
        };
    },
    [LOAD_META_DATA]: (
        state,
        { payload }
    ) => ({
        ...state,
        name: payload.name,
        nameValue: payload.nameValue,
        hideName: payload.hideName,
        masterSections: payload.masterSections,
        sections: payload.sections,
        masterTabs: payload.masterTabs,
        tabs: payload.tabs,
        objectDescribes: payload.objectDescribes,
        headerObjectName: payload.headerObjectName,
        sourceObjectName: payload.sourceObjectName,
        defaultRecordTypes: payload.defaultRecordTypes,
        objectApiNamesWithLabel: payload.objectApiNamesWithLabel,
        recordTypeInfosByObjectName: payload.recordTypeInfosByObjectName,
        transactionType: payload.transactionType,
        configInfosByObject: payload.configInfos,
        screenType: payload.screenType,
        buttons: payload.buttons,
        formFillByFieldNames: payload.formFillByFieldNames,
        childFormFillByFieldNames: payload.childFormFillByFieldNames,
        tabsByChildId: payload.tabsByChildId,
        runtimeContext: payload.context,
        developerName: payload.developerName,
        hasHeaderCurrencyField: payload.hasCurrencyField,
    }),
    [LOAD_DEBUG_CONSOLE_META_DATA]: (
        state,
        { payload }
    ) => ({
        ...state,
        objectApiNamesWithLabel: {
            ...state.objectApiNamesWithLabel,
            ...payload.objectApiNamesWithLabel
        },
    }),
    [UPDATE_HEADER_SECTIONS]: (
        state,
        { payload },
    ) => ({
        ...state,
        sections: payload.sections,
    }),
    [UPDATE_HEADER_FIELD]: (
        state,
        { payload },
    ) => {
        const { fieldName, value } = payload;
        const { sections } = state;
        const updatedHeaderValues = { ...state.headerValues,[fieldName]: value };
        const updatedSections = getUpdatedSectionsByRecord(sections, updatedHeaderValues);
        registerHeaderValuesWithPubSubModal(state.engineId, { [fieldName]: value });
        return {
            ...state,
            headerValues: updatedHeaderValues,
            sections: updatedSections,
            headerRecordUpdated: true,
            hasUserChanges: true,
        };
    },
    [UPDATE_HEADER_RECORD]: (
        state,
        { payload },
    ) => {
        const { record } = payload;
        const { sections } = state;
        const updatedHeaderValues = { ...state.headerValues, ...record };
        const updatedSections = getUpdatedSectionsByRecord(sections, updatedHeaderValues);
        registerHeaderValuesWithPubSubModal(state.engineId, record);
        return {
            ...state,
            headerValues: updatedHeaderValues,
            sections: updatedSections,
            headerRecordUpdated: true,
            hasUserChanges: true,
        };
    },
    [UPDATE_CHILD_RECORD]: (
        state,
        { payload },
    ) => {
        const { childId, recordId, record } = payload;
        if (!state.childValues[childId]?.[recordId]) {
            return state;
        }
        registerChildValuesWithPubSubModal(state.engineId, record, childId, recordId);
        return {
            ...state,
            childValues: {
                ...state.childValues,
                [childId]: {
                    ...(state.childValues[childId] || {}),
                    [recordId]: {
                        ...(state.childValues[childId] || {})[recordId] || {},
                        ...record,
                    }
                }
            },
            childUpdates: {
                ...state.childUpdates,
                [childId]: uniqueArray([...(state.childUpdates[childId] || []), recordId])
            },
            hasUserChanges: true,
        };
    },
    [UPDATE_IS_DEBUG_ENABLED]: (
        state,
        { payload },
    ) => {
        return {
            ...state,
            isDebugEnabled: payload.isDebugEnabled,
        };
    },
    [UPDATE_RECORD_TYPES]: (
        state,
        { payload }
    ) => ({
        ...state,
        recordTypes: {
            ...state.recordTypes,
            [payload.objectName]: {
                ...((state.recordTypes || {})[payload.objectName] || {}),
                [payload.recordTypeId]: payload.recordTypeInfo,
            }
        }
    }),
    [UPDATE_BLOCK_APPLICATION]: (
        state,
    ) => ({
        ...state,
        blockApplication: true,
    }),
    [UPDATE_UN_BLOCK_APPLICATION]: (
        state,
    ) => ({
        ...state,
        blockApplication: false,
    }),
    [UPDATE_HEADER_CURRENCY]: (
        state,
        { payload },
    ) => {
        const { currencyCode } = payload;
        const { tabs } = state;
        const updatedTabs = getUpdatedTabsByCurrencyCode(tabs, currencyCode);

        return {
            ...state,
            currencyCode,
            tabs: updatedTabs,
        };
    },
    [ADD_TEMPORARY_CHILD_LINE]: (
        state,
        { payload },
    ) => {
        const { childId, recordId, valueMapping } = payload;
        const { tabsByChildId, recordTypeInfosByObjectName } = state;
        const tab = tabsByChildId[childId];
        const newRecord = generateRecord(state, childId, recordId, valueMapping);
        const elements = transformSectionElements(
            tabsByChildId[childId],
            newRecord,
            recordTypeInfosByObjectName,
        );
        registerChildValuesWithPubSubModal(state.engineId, newRecord, childId, recordId);
        return {
            ...state,
            temporaryChildValues: {
                ...state.temporaryChildValues,
                [childId]: {
                    ...state.temporaryChildValues[childId],
                    [recordId]: newRecord,
                },
            },
            temporaryChildSections: {
                ...state.temporaryChildSections,
                [childId]: [{ ...tab.section, elements: [...elements], id: 'id' }],
            },
            temporaryChildDraftValues: {},
        };
    },
    [EDIT_TEMPORARY_CHILD_LINE]: (
        state,
        { payload },
    ) => {
        const { childId, recordId } = payload;
        const { tabsByChildId, childValues, recordTypeInfosByObjectName } = state;
        const tab = tabsByChildId[childId];
        const record = childValues[childId][recordId];
        const elements = transformSectionElements(tab, record, recordTypeInfosByObjectName);
        return {
            ...state,
            temporaryChildValues: {
                ...state.temporaryChildValues,
                [childId]: {
                    ...state.temporaryChildValues[childId],
                    [recordId]: record,
                },
            },
            temporaryChildSections: {
                ...state.temporaryChildSections,
                [childId]: [
                    { ...tab.section, title: tab.title, elements: [...elements], id: 'id' }
                ],
            },
            temporaryChildDraftValues: record,
        };
    },
    [COMMIT_TEMPORARY_CHILD_LINE]: (
        state,
        { payload },
    ) => {
        const { childId, recordId } = payload;
        const {
            childValues,
            temporaryChildValues,
            hasHeaderCurrencyField,
            sections,
        } = state;
        const { [recordId]: blah, ...others } = temporaryChildValues[childId];

        const updatedChildValues = {
            ...childValues,
            [childId]: {
                ...(childValues[childId] || {}),
                [recordId]: temporaryChildValues[childId][recordId],
            },
        }

        let updatedSections = sections;
        if (hasHeaderCurrencyField) {
            const hasLines = hasChildLines(updatedChildValues);
            updatedSections = getUpdatedSectionsByCurrencyCode(sections,hasLines);
        }
        registerChildValuesWithPubSubModal(
            state.engineId,
            temporaryChildValues[childId][recordId],
            childId,
            recordId
        );
        return {
            ...state,
            sections: updatedSections,
            childValues: updatedChildValues,
            childUpdates: {
                ...state.childUpdates,
                [childId]: uniqueArray([...(state.childUpdates[childId] || []), recordId])
            },
            temporaryChildValues: {
                ...state.temporaryChildValues,
                [childId]: others,
            },
            temporaryChildSections: {
                ...state.temporaryChildSections,
                [childId]: [],
            },
            temporaryChildDraftValues: {},
            hasUserChanges: true,
        };
    },
    [DISCARD_TEMPORARY_CHILD_LINE]: (
        state,
        { payload },
    ) => {
        const { childId, recordId } = payload;
        const {
            temporaryChildValues,
            temporaryChildDraftValues,
        } = state;
        const { [recordId]: blah, ...others } = temporaryChildValues[childId] || {};
        registerChildValuesWithPubSubModal(
            state.engineId,
            temporaryChildDraftValues,
            childId,
            recordId
        );
        return {
            ...state,
            temporaryChildValues: {
                ...state.temporaryChildValues,
                [childId]: others,
            },
            temporaryChildSections: {
                ...state.temporaryChildSections,
                [childId]: [],
            },
            temporaryChildDraftValues: {},
        };
    },
    [UPDATE_TEMPORARY_CHILD_RECORD]: (
        state,
        { payload },
    ) => {
        const { childId, recordId, record } = payload;
        const { temporaryChildValues, temporaryChildSections } = state;
        const exisitingRecord = (temporaryChildValues[childId] || {})[recordId] || {};
        const updatedRecord = { ...exisitingRecord, ...record };
        const sections = temporaryChildSections[childId] || [];
        const updatedSections = getUpdatedSectionsByRecord(sections, updatedRecord);
        registerChildValuesWithPubSubModal(state.engineId, record, childId, recordId);
        return {
            ...state,
            temporaryChildValues: {
                ...state.temporaryChildValues,
                [childId]: {
                    ...(state.temporaryChildValues[childId] || {}),
                    [recordId]: updatedRecord
                }
            },
            temporaryChildSections: {
                ...state.temporaryChildSections,
                [childId]: updatedSections,
            },
        };
    },
    [DELETE_CHILD_RECORDS]: (
        state,
        { payload },
    ) => {
        const { childId, recordIds } = payload;
        const recIds = Array.isArray(recordIds) ? recordIds : [recordIds];
        const { childValues,
            selectedChildValues,
            childUpdates,
            hasHeaderCurrencyField,
            sections,
            childValuesSequence,
        } = state;
        const recordIdsToDelete = (recIds || []).filter(
            (recId) => !newRecordPattern.test(recId),
        );
        const deletedRecords = (recordIdsToDelete || []).map(recId => {
            return childValues[childId][recId];
        });

        const updatedChildValues = {
            ...childValues,
            [childId]: omitKeys(childValues[childId], recIds),
        };
        let updatedSections = sections;
        if (hasHeaderCurrencyField) {
            const hasLines = hasChildLines(updatedChildValues);
            updatedSections = getUpdatedSectionsByCurrencyCode(sections, hasLines);
        }

        return {
            ...state,
            sections: updatedSections,
            childDeletes: {
                ...state.childDeletes,
                [childId]: [
                    ...(state.childDeletes[childId] || []),
                    ...deletedRecords,
                ],
            },
            childValues: updatedChildValues,
            childUpdates: {
                ...state.childUpdates,
                [childId]: omitElements(childUpdates[childId] || [],recIds),
            },
            selectedChildValues: {
                ...state.selectedChildValues,
                [childId]: omitElements(selectedChildValues[childId] || [],recIds),
            },
            childValuesSequence: {
                ...state.childValuesSequence,
                [childId]: omitElements(childValuesSequence[childId] || [],recIds),
            },
            hasUserChanges: true,
        };
    },
    [CLONE_CHILD_LINE]: (
        state,
        { payload }
    ) => {
        const { childId, sourceRecordId, recordId } = payload;
        const { childValues } = state;
        const fromRecord = childValues[childId][sourceRecordId];
        const newRecord = cloneRecord(state, childId, recordId, fromRecord);

        return {
            ...state,
            childValues: {
                ...childValues,
                [childId]: {
                    ...childValues[childId],
                    [recordId]: newRecord,
                },
            },
            hasUserChanges: true,
        };
    },
    [SELECTED_CHILD_LINES]: (
        state,
        { payload },
    ) => {
        const { childId, selectedIds } = payload;
        const recordIds = Array.isArray(selectedIds) ? selectedIds : [selectedIds];
        return {
            ...state,
            selectedChildValues: {
                ...state.selectedChildValues,
                [childId]: recordIds,
            },
        };
    },
    [UPDATE_VALIDATION_RESULTS]: (
        state,
        { payload },
    ) => {
        const errorCount = getValidationErrorCount(
            payload.headerValidationResults,
            payload.childValidationResults,
            payload.zeroLineValidationResults
        );
        return {
            ...state,
            headerValidationResults: payload.headerValidationResults,
            childValidationResults: payload.childValidationResults,
            zeroLineErrors: payload.zeroLineValidationResults,
            hasError: !!(errorCount > 0),
            errorCount: errorCount,
        };
    },
    [UPDATE_OBJECT_MAPPING]: (
        state,
        { payload },
    ) => ({
        ...state,
        objectMappingById: {
            ...state.objectMappingById,
            [payload.mappingId]: payload.mappingConfig,
        }
    }),
    [UPDATE_OBJECT_MAPPINGS]: (
        state,
        { payload },
    ) => ({
        ...state,
        objectMappingById: {
            ...state.objectMappingById,
            ...payload.mappingConfigs,
        }
    }),
    [UPDATE_COMPLETE_OBJECT_DESCRIBES]: (
        state,
        { payload },
    ) => {
        const { currencyCode } = state;

        const newObjectDescribes = deepCopy(payload.completeObjectDescribes);
        const fieldDescribesByObjectName = {};
        const objectApiNamesWithLabel = {};
        const recordTypeInfosByObjectName = {};

        // eslint-disable-next-line guard-for-in
        for (const objectApiName in newObjectDescribes) {
            const objectDescribe = newObjectDescribes[objectApiName];

            const fieldDefinitionsByApiName = {};
            objectDescribe.fieldDefinitions.forEach(fieldDefinition => {
                fieldDefinitionsByApiName[fieldDefinition.apiName] = fieldDefinition;
            });
            objectDescribe.fieldDefinitionsByApiName = fieldDefinitionsByApiName;

            const recordTypeInfos = Array.isArray(objectDescribe.recordTypeInfos) ?
                objectDescribe.recordTypeInfos : [objectDescribe.recordTypeInfos];

            recordTypeInfosByObjectName[objectDescribe.apiName] = recordTypeInfos;

            const defaultRecordType = recordTypeInfos.find(
                info => info.isDefaultRecordTypeMapping && info.isActive
            );

            fieldDescribesByObjectName[objectApiName] = transformObjectDefinition(
                objectDescribe.fieldDefinitions,
                currencyCode,
                defaultRecordType?.recordTypeId
            );

            objectApiNamesWithLabel[objectApiName] = objectDescribe.label;
        }

        return {
            ...state,
            completeObjectDescribes: {
                ...state.completeObjectDescribes,
                ...newObjectDescribes
            },
            objectDescribes: {
                ...state.objectDescribes,
                ...fieldDescribesByObjectName
            },
            objectApiNamesWithLabel: {
                ...state.objectApiNamesWithLabel,
                ...objectApiNamesWithLabel
            },
            recordTypeInfosByObjectName: {
                ...state.recordTypeInfosByObjectName,
                ...recordTypeInfosByObjectName
            }
        };
    },
    [UPDATE_EXPRESSION_DETAILS]: (
        state,
        { payload },
    ) => ({
        ...state,
        expressionById: {
            ...state.expressionById,
            ...payload.expressionDetailsById
        }
    }),
    [UPDATE_FORMATTED_EXPRESSION_FOR_OBJECT]: (
        state,
        { payload },
    ) => {
        const { formattedExpressionsByObject } = state;

        return {
            ...state,
            formattedExpressionsByObject: {
                ...state.formattedExpressionsByObject,
                [payload.objectApiName]: {
                    ...(formattedExpressionsByObject[payload.objectApiName] ?? {}),
                    [payload.expressionId]: payload.formattedExpression
                }
            }
        }
    },
    [UPDATE_FORMATTED_MAPPING_FOR_OBJECT]: (
        state,
        { payload },
    ) => {
        const { formattedMappingsByObject } = state;

        return {
            ...state,
            formattedMappingsByObject: {
                ...state.formattedMappingsByObject,
                [payload.objectApiName]: {
                    ...(formattedMappingsByObject[payload.objectApiName] || {}),
                    [payload.mappingId]: payload.formattedMapping
                }
            }
        }
    },
    [UPDATE_USER_INFO]: (
        state,
        { payload },
    ) => ({
        ...state,
        userInfo: payload.userInfo,
    }),
    [REPLACE_VALUES]: (
        state,
        { payload },
    ) => ({
        ...state,
        ...payload,
    }),
    [UPDATE_ENGINE_ERROR]: (
        state,
        { payload },
    ) => ({
        ...state,
        engineError: payload.error,
    }),
    [UPDATE_DYNAMIC_SECTIONS]: (
        state,
        { payload },
    ) =>  {
        const {
            headerValues
        } = state;
        const updatedSections = getUpdatedSectionsByRecord(payload.sections, headerValues);
        return ({
            ...state,
            sections: updatedSections,
            tabs: payload.tabs,
            expressionById: {
                ...state.expressionById,
                ...(payload.expressionById || {}),
            },
            dynamicSectionsExpressionFields: uniqueArray([
                ...state.dynamicSectionsExpressionFields,
                ...(payload.dynamicSectionsExpressionFields),
            ]),
        })
    },
    [UPDATE_USER_ACTIVITY]: (
        state,
        { payload },
    ) =>  {
        return ({
            ...state,
            userActivity: [
                ...state.userActivity,
                ...(payload.userActivity || []),
            ],
        });
    },
    [UPDATE_LOAD_COMPLETED]: (
        state,
    ) => ({
        ...state,
        loadingStatus: {
            ...state.loadingStatus,
            LOADING_ENGINE_METADATA: false,
        },
    }),
}

const META_ACTION_HANDLERS = {
    [INITIALIZE_ENGINE]: (state, action) => ({
        ...state,
        [action.payload.engineId]: {
            ...(action.payload.initialState
                ? action.payload.initialState
                : getInitialState()),
            engineId: action.payload.engineId,
        },
    }),
    [DESTROY_ENGINE]: (state, action) => {
        const { [action.engineId]: blah, ...remainingState } = state;
        return remainingState;
    },
};

const reducer = (state, action) => {
    if (!state) {
        return getInitialState();
    }
    const { type, engineId } = action;
    if (type !== INITIALIZE_ENGINE && !state[engineId]) {
        return state;
    }

    const metaHandler = META_ACTION_HANDLERS[action.type];
    if (metaHandler) {
        return metaHandler(state, action);
    }

    const handler = ACTION_HANDLERS[action.type];
    if (!handler) {
        return state;
    }

    const engineState = handler(state[action.engineId], action);

    return {
        ...state,
        [action.engineId]: engineState,
    };
};

export default {
    runtimeEngine: reducer
}