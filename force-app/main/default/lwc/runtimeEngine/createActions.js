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
    UPDATE_FORMATTED_EXPRESSION_FOR_OBJECT,
    UPDATE_FORMATTED_MAPPING_FOR_OBJECT,
    UPDATE_USER_INFO,
    REPLACE_VALUES,
    UPDATE_ENGINE_ERROR,
    REINITIALIZE_ENGINE_STATE,
    UPDATE_DYNAMIC_SECTIONS,
    UPDATE_LOAD_COMPLETED,
    UPDATE_IS_DEBUG_ENABLED,
    UPDATE_USER_ACTIVITY,
} from './actionNames';

import {
    createAction,
} from './utils';

import {
    guid,
} from 'c/utils';

// create actions
export const initializeEngine = createAction(
    INITIALIZE_ENGINE,
    (engineId, initialState) => ({ engineId, initialState }),
);
export const destroyEngine = createAction(DESTROY_ENGINE);
export const loadHeaderValues = createAction(
    LOAD_HEADER_VALUES,
    (data, currencyCode, headerObject) => ({ data, currencyCode, headerObject }),
);
export const loadPageDataConfig = createAction(
    LOAD_PAGE_DATA_CONFIG,
    config => ({ config }),
);
export const loadChildValues = createAction(
    LOAD_CHILD_VALUES,
    (data, sequence) => ({ childRecords: data, childValuesSequence: sequence }),
);
export const loadMetaData = createAction(LOAD_META_DATA);
export const loadDebugConsoleMetaData = createAction(LOAD_DEBUG_CONSOLE_META_DATA);
export const updateHeaderRecord = createAction(
    UPDATE_HEADER_RECORD,
    (record) => ({ record }));
export const updateChildRecord = createAction(
    UPDATE_CHILD_RECORD,
    (childId,recordId,record) => ({ childId,recordId,record }));
export const updateHeaderSections = createAction(UPDATE_HEADER_SECTIONS);
export const updateRecordTypes = createAction(UPDATE_RECORD_TYPES);
export const updateBlockApplication = createAction(UPDATE_BLOCK_APPLICATION);
export const updateUnBlockApplication = createAction(UPDATE_UN_BLOCK_APPLICATION);
export const updateHeaderCurrency = createAction(UPDATE_HEADER_CURRENCY);
export const updateHeaderFieldValue = createAction(
    UPDATE_HEADER_FIELD,
    (fieldName, value) => {
        const v =
        value === '' || value === undefined || value === null ? null : value;
        return { fieldName, value: v };
    },
);
export const addTemporaryChildLine = createAction(
    ADD_TEMPORARY_CHILD_LINE,
    (childId, valueMapping) => ({
        childId,
        recordId: guid(),
        valueMapping,
    }),
);
export const editTemporaryChildLine = createAction(
    EDIT_TEMPORARY_CHILD_LINE,
    (childId, recordId) => ({
        childId,
        recordId
    }),
);
export const commitTemporaryChildLine = createAction(
    COMMIT_TEMPORARY_CHILD_LINE,
    (childId, recordId) => ({
        childId,
        recordId
    }),
);
export const discardTemporaryChildLine = createAction(
    DISCARD_TEMPORARY_CHILD_LINE,
    (childId, recordId) => ({ childId, recordId }),
);
export const updateTemporaryChildRecord = createAction(
    UPDATE_TEMPORARY_CHILD_RECORD,
    (childId,recordId,record) => ({ childId,recordId,record }));
export const deleteChildLines = createAction(
    DELETE_CHILD_RECORDS,
    (childId, recordIds) => ({ childId, recordIds }),
);
export const cloneChildLine = createAction(
    CLONE_CHILD_LINE,
    (childId, sourceRecordId, recordId) => ({
        childId,
        sourceRecordId,
        recordId
    }),
);
export const selectedChildLines = createAction(
    SELECTED_CHILD_LINES,
    (childId, selectedIds) => ({
        childId,
        selectedIds
    }),
);

export const updateValidationResults = createAction(UPDATE_VALIDATION_RESULTS);

export const updateObjectMapping = createAction(UPDATE_OBJECT_MAPPING);
export const updateObjectMappings = createAction(UPDATE_OBJECT_MAPPINGS);
export const updateCompleteObjectDescribes = createAction(UPDATE_COMPLETE_OBJECT_DESCRIBES);
export const updateExpressionDetails = createAction(UPDATE_EXPRESSION_DETAILS);
export const updateFormattedExpressionForObject =
    createAction(UPDATE_FORMATTED_EXPRESSION_FOR_OBJECT);
export const updateFormattedMappingForObject =
    createAction(UPDATE_FORMATTED_MAPPING_FOR_OBJECT);
export const updateUserInfo = createAction(UPDATE_USER_INFO);
export const replaceValues = createAction(
    REPLACE_VALUES,
    (
        headerValues,
        childValues,
        childUpdates,
        sections,
    ) => {
        const keys = [
            'childValues',
            'childUpdates',
        ];

        const otherData = [
            childValues,
            childUpdates,
        ].reduce((acc, data, idx) => {
            if (!data) return acc;
            return {
                ...acc,
                [keys[idx]]: data,
            };
        }, {});
        return {
            ...otherData,
            headerValues,
            sections,
        };
    },
);
export const updateEngineError = createAction(UPDATE_ENGINE_ERROR);
export const updateLoadCompleted = createAction(UPDATE_LOAD_COMPLETED);

export const resetEngineState = createAction(REINITIALIZE_ENGINE_STATE);
export const updateDynamicSections = createAction(UPDATE_DYNAMIC_SECTIONS);
export const updateIsDebugEnabled = createAction(UPDATE_IS_DEBUG_ENABLED);
export const updateUserActivity = createAction(UPDATE_USER_ACTIVITY);