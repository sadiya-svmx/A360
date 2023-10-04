import {
    PAGE_ELEMENT_EVENT_TYPES,
    PAGE_ELEMENT_ACTION_TYPES,
    isUndefinedOrNull,
    guid,
    transformChildRecordData,
    verifyIsPageDataResponse
} from 'c/utils';

import {
    registerChildValuesWithPubSubModal
} from './utils';

import {
    getUpdatedSectionsByRecord,
    uniqueArray,
    ENGINE_ERROR
} from './utils';


import {
    replaceValues,
    deleteChildLines,
    updateBlockApplication,
    updateUnBlockApplication,
} from './createActions';

import {
    getPageDataPayload,
    geti18nErrorMessage
} from './stateUtils';

export const createOnReturn = (dispatch, getState) => (
    context,
) => {
    const state = getState();
    const {
        headerRecordData,
        childRecordData: detailRecordsRaw
    } = context;

    const {
        headerValues,
        childValues,
        tabsByChildId,
        childUpdates,
        sections,
        engineId
    } = state;

    const childValuesAfter = {};
    const childUpdatesAfter = {};
    Object.keys(childValues).forEach(childId => {
        const records = (detailRecordsRaw || {})[childId] || [];
        const tab = tabsByChildId[childId];

        const udpatedChildValues = { ...childValues[childId] || {}};
        const updatedRecords = [];
        records.forEach(record => {
            const existingRecord = (childValues[childId] || {})[record.Id] || {};
            if (isUndefinedOrNull(record.Id)) {
                record.isNew = true;
                record.Id = guid();
                record[tab.controllerReferenceField] = headerValues.Id;
            }
            udpatedChildValues[record.Id] = {
                ...existingRecord,
                ...record,
            };
            updatedRecords.push(record.Id);
        });
        childUpdatesAfter[childId] = uniqueArray(
            [...(childUpdates[childId] || []), ...updatedRecords]
        );
        childValuesAfter[childId] = udpatedChildValues;
    });

    const udpateHeaderValues = { ...headerValues, ...headerRecordData };
    const updatedSections = getUpdatedSectionsByRecord(sections, udpateHeaderValues);

    dispatch(
        replaceValues(
            udpateHeaderValues,
            childValuesAfter,
            childUpdatesAfter,
            updatedSections,
        ),
    );

    Object.keys(childValuesAfter).forEach(childId => {
        Object.keys(childValuesAfter[childId]).forEach(recordId => {
            registerChildValuesWithPubSubModal(engineId,
                childValuesAfter[childId][recordId], childId, recordId);
        });

    });
};

export const deleteOnReturn = (dispatch, getState) => context => {
    const { childValues } = getState();
    const { childRecordData } = context;

    Object.keys(childValues).forEach(childId => {
        const records = (childRecordData || {})[childId] || [];
        const udpatedChildValues = { ...(childValues[childId] || {}) };

        const updatedRecords = records.map(record => record.Id);
        const deletedRecords = Object.keys(udpatedChildValues).filter(
            updatedId => !updatedRecords.includes(updatedId),
        );
        dispatch(deleteChildLines(childId, deletedRecords));
    });
};

export const executeCustomActionService = async (
    dispatch,
    getState,
    engine,
    intent,
) => {
    const { executeCustomAction } = engine.apis;
    const { actionTarget } = intent;
    if (!executeCustomAction || !actionTarget) {
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.INVALID_INTENT_CONFIG));
    }
    dispatch(updateBlockApplication());
    const pagedata = getPageDataPayload(getState);
    const actionRequest = {
        pagedata,
        actionName: actionTarget,
    };
    let result = null;
    try {
        const actionResponse = await executeCustomAction(actionRequest);
        if (!actionResponse.success) {
            throw new Error(actionResponse.message);
        }

        const pageDataResponse = JSON.parse(actionResponse?.data || {});
        verifyIsPageDataResponse(pageDataResponse);

        const {
            headerRecord,
            pageDetails,
        } = pageDataResponse;

        const headerRecordData = headerRecord;
        const childRecordData = transformChildRecordData(pageDetails);

        result = { headerRecordData, childRecordData };
        createOnReturn(dispatch,getState)(result);
        deleteOnReturn(dispatch,getState)(result);
    } finally {
        await dispatch(updateUnBlockApplication());
    }
    return result;
};

export const executeCustomActionOnButton = (buttonId) => async (
    dispatch,
    getState,
    engine,
// eslint-disable-next-line consistent-return
) => {
    const state = getState();
    if (!state || !engine) {
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
    }
    const { buttons } = state;
    const action = buttons.find(button => button.name === buttonId);
    const intents = action?.intents[PAGE_ELEMENT_EVENT_TYPES.CLICK];

    if (!intents || !intents.length || intents.length > 1) {
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.INVALID_INTENT_CONFIG));
    }

    const intent = intents[0];
    const { actionType } = intent;

    if (actionType === PAGE_ELEMENT_ACTION_TYPES.INVOKE_WEBSERVICE) {
        // eslint-disable-next-line consistent-return
        return executeCustomActionService(
            dispatch,
            getState,
            engine,
            intent
        );
    }

    //place holder for handling custom action as code snippet
    const { codeSnippet } = intent;

    if (!codeSnippet) {
        // eslint-disable-next-line consistent-return
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.INVALID_INTENT_CONFIG));
    }
};