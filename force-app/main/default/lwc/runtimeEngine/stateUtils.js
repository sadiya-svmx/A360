/* eslint-disable @lwc/lwc/no-for-of */
import {
    formatString,
    normalizeBoolean,
    isNotUndefinedOrNull,
    isUndefinedOrNull,
    guid,
    FIELD_API_NAMES,
    recordActions,
    isFlowContext,
    isRecordPageContext,
    transformRecordForSave,
    transformRecordForFlow,
    executeObjectMapping,
    isTransactionContext,
    verifyApiResponse,
    OPERATOR_MAP,
    MAPPING_TYPE,
    FUNCTION_LITERALS,
    normalizeFieldApiName,
    createDisplayTokenSequence,
    sortObjectArray,
    evaluateExpressions,
    isSalesforceId,
} from 'c/utils';

import {
    newRecordPattern,
    VALIDATION_RULE_TYPE,
    VALIDATION_ERROR_TYPE,
    ENGINE_ERROR,
} from './utils';

import {
    updateRecordTypes,
    updateObjectMapping,
    updateObjectMappings,
    updateCompleteObjectDescribes,
    updateExpressionDetails,
    updateFormattedExpressionForObject,
    updateFormattedMappingForObject,
    updateUserInfo,
    updateUserActivity,
} from './createActions';

import labelToday from '@salesforce/label/c.Picklist_Today';
import labelTomorrow from '@salesforce/label/c.Picklist_Tomorrow';
import labelYesterday from '@salesforce/label/c.Picklist_Yesterday';
import labelNow from '@salesforce/label/c.Picklist_Now';
import labelField from '@salesforce/label/c.Picklist_Field';
import labelValue from '@salesforce/label/c.Picklist_Value';
import labelFunction from '@salesforce/label/c.Picklist_Function';
import labelCurrentRecord from '@salesforce/label/c.Label_CurrentRecord';
import labelCurrentRecordHeader from '@salesforce/label/c.Label_CurrentRecordHeader';
import labelUser from '@salesforce/label/c.Label_User';

const MAP_VALUE_LABEL = {
    labelToday,
    labelTomorrow,
    labelYesterday,
    labelNow,
    labelCurrentRecordHeader,
    labelCurrentRecord,
    labelUser,
}

//local state utils
export const geti18nErrorMessage = (errorId, engine) => {
    const i18n = engine && engine.apis.geti18n();
    const errorHandler = {
        [ENGINE_ERROR.STATE_INITIALIZE_FAILED]: () => 'engine is fail to initialize state',
        [ENGINE_ERROR.OBJECT_DESCRIBE_FAILED]: () => i18n.ObjectDescribeFailed,
    }
    if (errorHandler[errorId]) {
        return errorHandler[errorId]();
    }
    return 'unknown error';
}

export const getPageDataPayload = (getState) => {
    const {
        developerName,
        headerValues,
        childValues,
        tabsByChildId,
        headerObjectName,
        runtimeContext,
        childDeletes,
    } = getState();
    const headerRecord = transformRecordForSave(
        headerValues,
        headerObjectName
    );

    const pageDetails = [];
    Object.keys(childValues || {}).forEach((childId) => {
        const tab = tabsByChildId[childId] || {};
        const pageDetail = {
            uniqueKey: childId,
            detailRecords: [],
            deleteIds: [],
        };
        Object.keys(childValues[childId] || {}).forEach(rowId => {
            const record = childValues[childId][rowId];
            pageDetail.detailRecords.push(transformRecordForSave(record, tab.objectAPIName));
        });

        (childDeletes[childId] || []).forEach(record => {
            pageDetail.deleteIds.push(record.Id);
        });
        pageDetails.push(pageDetail);
    });

    return {
        pageLayoutId: developerName,
        headerRecord,
        pageDetails: pageDetails,
        actionType: (isFlowContext(runtimeContext) || isRecordPageContext(runtimeContext))
            ? 'quicksave' : null
    };
}

export const getChildValuesByPageData = (childRecordData) => {
    const childRecords = {};
    const childRecordsSequence = {};
    const keys = Object.keys(childRecordData || {});
    (keys || []).forEach (key => {
        childRecordsSequence[key] = childRecordsSequence[key] || [];
        childRecords[key] = childRecords[key] || {};
        const records = childRecordData[key];
        (records || []).forEach(record => {
            const sRecord = { ...record };
            if (!sRecord.Id) {
                sRecord.isNew = true;
                sRecord.Id = guid();
            }
            childRecords[key][sRecord.Id] = sRecord;
            childRecordsSequence[key].push(sRecord.Id);
        });
    });
    return { childValues: childRecords, childValuesSequence: childRecordsSequence };
}

export const formFillRequired = (fieldName, getState) => {
    const { formFillByFieldNames } = getState();
    const { formFillMappingId, applyMapping } = formFillByFieldNames[fieldName] ?? {};

    return !!formFillMappingId || applyMapping === 'Conditional';
};

export const childFormFillRequired = (
    childId,
    fieldName,
    getState,
) => {
    const { childFormFillByFieldNames } = getState();
    const formFillByChildId = childFormFillByFieldNames[childId] ?? {};
    const { formFillMappingId, applyMapping } = formFillByChildId[fieldName] ?? {};

    return !!formFillMappingId || applyMapping === 'Conditional';
};

export const hasMapping = (mapping = {}) => {
    if (Object.keys(mapping).length > 0) {
        return true;
    }

    return false;
};

export const childValueMappingRequired = (
    childId,
    getState,
) => {
    const { tabsByChildId, runtimeContext } = getState();

    return !!(tabsByChildId[childId] || {}).valueMapping && isTransactionContext(runtimeContext);
};

export const getChildRecord = (
    childId,
    recordId,
    getState,
) => {
    const { childValues } = getState();

    const record = (childValues[childId] || {})[recordId] || {};
    return record;
}

export const getRecordTypeById = async (dispatch, getState, engine, objectName, recordTypeId) => {
    const { getRecordTypes } = engine.apis;
    const { recordTypes } = getState();
    let recordTypeInfo;
    if (((recordTypes || {})[objectName] || {})[recordTypeId]) {
        recordTypeInfo = recordTypes[objectName][recordTypeId];
    } else if (recordTypeId) {
        recordTypeInfo = await getRecordTypes(objectName, recordTypeId);
        await dispatch(updateRecordTypes({
            objectName,
            recordTypeId,
            recordTypeInfo
        }));
    }
    return recordTypeInfo;
}

const getObjectMappingById = async (dispatch, getState, engine, mappingId) => {
    const { getObjectMappingDetails, getRecordTypeDetails } = engine.apis;
    const { objectMappingById } = getState();
    let mappingConfig;

    async function getRecordTypeDetailsMap (objectName) {
        const recordTypeMap = new Map();
        if (objectName) {
            try {
                const resolvedRecordTypes = await getRecordTypeDetails(objectName);
                if (resolvedRecordTypes) {
                    const resolvedRecordTypesData = JSON.parse(resolvedRecordTypes).data;
                    resolvedRecordTypesData.forEach(record => {
                        recordTypeMap.set(record.developerName,record.id);
                        recordTypeMap.set(record.name,record.id);
                    });
                }
            } catch (error) {
                throw new Error(error);
            }
        }
        return recordTypeMap
    }

    if (objectMappingById[mappingId]) {
        mappingConfig = objectMappingById[mappingId];
    } else {
        const result = await getObjectMappingDetails(mappingId);
        // resolve the record type id
        if (verifyApiResponse(result)) {
            const objectMappingDetails = [];
            // eslint-disable-next-line guard-for-in
            //let resolvedRecordTypeId = recordTypeMap.get(resolvedRecordTypeId);
            for (const index in result.data.objectMappingDetails) {
                if (result.data.objectMappingDetails[index]) {
                    const config = result.data.objectMappingDetails[index];
                    const { targetFieldAPIName, value, mappingType } = config;
                    if (targetFieldAPIName  === 'RecordTypeId' && mappingType === 'Value'
                        && !isSalesforceId(value)) {
                        // eslint-disable-next-line no-await-in-loop
                        const recordTypeMap = await
                        getRecordTypeDetailsMap(result.data.targetObjectAPIName);
                        objectMappingDetails.push({ ...config, value: recordTypeMap.get(value) });
                    } else {
                        objectMappingDetails.push(config);
                    }
                }
            }
            result.data.objectMappingDetails = objectMappingDetails;
            mappingConfig = result.data;
            await dispatch(updateObjectMapping({
                mappingId,
                mappingConfig
            }));
        }
    }
    return mappingConfig;
}

const getObjectMappingByIds = async (dispatch, getState, engine, mappingIds) => {
    const { getObjectMappingsWithDetailsByIds } = engine.apis;
    const { objectMappingById } = getState();
    let mappingConfigs = {};
    const mappingIdsToRequestDetails = [];
    mappingIds.forEach(mappingId => {
        if (objectMappingById[mappingId]) {
            mappingConfigs[mappingId] = objectMappingById[mappingId];
        } else {
            mappingIdsToRequestDetails.push(mappingId);
        }
    });
    if (mappingIdsToRequestDetails.length > 0) {
        const result = await getObjectMappingsWithDetailsByIds(mappingIdsToRequestDetails);
        if (verifyApiResponse(result)) {
            const data = result.data;
            mappingConfigs = { ...mappingConfigs, ...data };
            await dispatch(updateObjectMappings({
                mappingIds,
                mappingConfigs
            }));
        }
    }
    return mappingConfigs;
}

export const getObjectDescribesByName = async (dispatch, getState, engine, objectApiNames) => {
    const { getObjectDescribe } = engine.apis;
    let { completeObjectDescribes } = getState();
    const objectApiNamesToRequest = [];

    objectApiNames.forEach(objectApiName => {
        if (!completeObjectDescribes[objectApiName]) {
            objectApiNamesToRequest.push(objectApiName);
        }
    });

    if (objectApiNamesToRequest.length > 0) {
        const result = await getObjectDescribe(objectApiNamesToRequest);
        if (verifyApiResponse(result)) {
            const data = result.data;
            const newObjectsByApiName = {};
            data.forEach(newObject => {newObjectsByApiName[newObject.apiName] = newObject});

            await (dispatch(updateCompleteObjectDescribes({
                objectApiNames,
                completeObjectDescribes: newObjectsByApiName
            })));
        } else {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.OBJECT_DESCRIBE_FAILED, engine));
        }
    }

    // Re-retrieve from store to get post-processed properties
    const objectDescribesByName = {};
    completeObjectDescribes = getState().completeObjectDescribes;
    objectApiNames.forEach(objectApiName => {
        objectDescribesByName[objectApiName] = completeObjectDescribes[objectApiName];
    });
    return objectDescribesByName;
}

const getUserInfoDetails = async (dispatch, getState, engine) => {
    const { getUserInfo } = engine.apis;
    const { userInfo } = getState();
    let userInfoDetails;
    if (userInfo) {
        userInfoDetails = userInfo;
    } else {
        const result = await getUserInfo();
        const parsedData = JSON.parse(result);
        if (verifyApiResponse(parsedData)) {
            userInfoDetails = parsedData.data;
            await dispatch(updateUserInfo({
                userInfo: userInfoDetails
            }));
        }
    }
    return userInfoDetails;
}

export const applyObjectMapping = async (
    dispatch,
    getState,
    engine,
    objectName,
    recordTypeId,
    mappingId,
    sourceRecordId,
    currentRecord,
    HeaderRecord,
    tabName,
    isHeaderMapping
) => {
    const { getRecords } = engine.apis;
    const { objectDescribes, headerObjectName, transactionType, isDebugEnabled } = getState();
    const objectDescribe = objectDescribes[objectName] || {};
    const recordTypeInfo = await getRecordTypeById(
        dispatch,
        getState,
        engine,
        objectName,
        recordTypeId,
    );
    const mappingConfig = await getObjectMappingById(
        dispatch,
        getState,
        engine,
        mappingId
    );
    const userInfo = await getUserInfoDetails(
        dispatch,
        getState,
        engine
    );

    const updatedValues = await executeObjectMapping(
        mappingConfig,
        userInfo,
        objectDescribe,
        sourceRecordId,
        recordTypeInfo,
        currentRecord,
        HeaderRecord,
        async (recordId, fields ) => {
            return getRecords(recordId, fields);
        },
        transactionType,
        objectDescribes[headerObjectName]
    );

    if (isDebugEnabled) {
        await dispatch(updateUserActivity({
            userActivity: [{
                actionType: 'value_mapping',
                referenceId: `${mappingId}_${tabName ?? ''}`,
                Id: guid(),
                mappedRecordData: {
                    ...updatedValues,
                    Id: currentRecord?.Id
                },
                isHeaderMapping,
            }],
        }));
    }

    return updatedValues;
}

const deleteSystemFields = (fields, clonedRow) => {
    const cleanRow = {};
    const fieldMap = new Map();
    fields.forEach(field => {
        fieldMap.set(field.fieldName, field.systemField);
    });
    Object.keys(clonedRow).forEach(field => {
        // cloning all fields and filtering out systemfield(s) configured in pagelayout
        if (field !== 'attributes' && !fieldMap.get(field)) {
            cleanRow[field] = clonedRow[field];
        }
    });
    return cleanRow;
}

export const generateRecord = (state, childId, recordId, valueMapping) => {
    const { tabsByChildId, currencyCode, headerValues } = state;
    const tab = tabsByChildId[childId];

    let newRow = {};
    newRow.isNew = true;
    newRow.Id = recordId;
    newRow.attributes = { 'type': tab.objectAPIName };

    const columns  = tab.elements;
    (columns || []).forEach(column => {
        if (Object.prototype.hasOwnProperty.call(column, 'fieldName')) {
            const { typeAttributes } = column;
            if (typeAttributes.fieldType === 'boolean') {
                newRow[column.fieldName] = false;
            } else {
                newRow[column.fieldName] = null;
            }
        }
    });

    newRow = { ...newRow, ...valueMapping };
    newRow[tab.controllerReferenceField] = headerValues.Id;
    if (currencyCode) {
        newRow[FIELD_API_NAMES.CURRENCY_ISO_CODE] = currencyCode;
    }
    return newRow;
}

export const cloneRecord = (state, childId, recordId, fromRecord) => {
    const { tabsByChildId, headerValues } = state;
    const tab = tabsByChildId[childId];

    const cleanRecord = deleteSystemFields(tab.elements, fromRecord);

    // add props needed to track line edit and save
    cleanRecord.isNew = true;
    cleanRecord.Id = recordId;
    cleanRecord.attributes = fromRecord.attributes || { 'type': tab.objectAPIName };
    if (fromRecord.RecordTypeId) {
        cleanRecord.RecordTypeId = fromRecord.RecordTypeId;
    }
    cleanRecord[tab.controllerReferenceField] = headerValues.Id;
    return cleanRecord;
}

export const mungeChildRecordDataByTabs = (tabs, childRecordData) => {
    const childRecords = {};
    // eslint-disable-next-line guard-for-in
    for (const childKey in childRecordData) {
        const matches = childKey.match(/\d+/g);
        if (matches) {
            const childIndex = matches.map(Number);
            const tabFilter = (tabs || []).filter(tab => tab.sequence === childIndex[0]);
            if (tabFilter.length) {
                const tab = tabFilter[0];
                childRecords[tab.name] = childRecordData[childKey];
            } else {
                childRecords[childKey] = childRecordData[childKey];
            }
        } else {
            childRecords[childKey] = childRecordData[childKey];
        }
    }
    return childRecords;
}

const dispatchFlowEventCollection = (engine, propertyName,
    records, objectDescribe, childRecord) => {
    if (!Array.isArray(records)) {
        return;
    }

    const { flowRecords } = engine.apis;

    const payload = records.reduce((acc, record) => {
        const rec = transformRecordForFlow(record,objectDescribe);
        return [...acc,rec];
    }, []);

    flowRecords(propertyName, payload, childRecord);
}

export const dispatchHeaderRecord = (getState, engine) => {
    const {
        headerValues,
        headerObjectName,
        objectDescribes
    } = getState();
    const objectDescribe = objectDescribes[headerObjectName];
    const stateData = getState();
    const childRecord = Object.entries(stateData.childValues)
    .filter(([key]) => Object.prototype.hasOwnProperty.call(stateData.childValidationResults, key))
    .map(([key, value]) => ({ name: key, length: Object.keys(value).length }));

    dispatchFlowEventCollection(
        engine,
        'headerRecordData',
        [headerValues],
        objectDescribe,
        childRecord
    );
}

export const dispatchChildRecords = (getState, engine) => {
    const {
        childValues,
        selectedChildValues,
        tabsByChildId,
        headerValues,
        objectDescribes,
        childDeletes,
    } = getState();

    Object.keys(tabsByChildId).forEach(childId => {
        const tab = tabsByChildId[childId];
        const objectDescribe = objectDescribes[tab.objectAPIName];

        const recordsToDispatch = {};

        Object.keys(childValues[childId] || {}).forEach(recordId => {
            let propertyToDispatch;
            const record = childValues[childId][recordId];
            // provide temp Id to records created by custom action on fly to track row edit
            if (!record.Id) {
                record.isNew = true;
                record.Id = guid();
                record[tab.controllerReferenceField] = headerValues.Id;
            }
            const isNewRecord = newRecordPattern.test(record.Id);
            if (isNewRecord) {
                propertyToDispatch = `child${tab.sequence}${recordActions.new}`;
                if (isUndefinedOrNull(recordsToDispatch[propertyToDispatch])) {
                    recordsToDispatch[propertyToDispatch] = [];
                }
                recordsToDispatch[propertyToDispatch].push(record);
            } else {
                propertyToDispatch = `child${tab.sequence}${recordActions.modified}`;
                if (isUndefinedOrNull(recordsToDispatch[propertyToDispatch])) {
                    recordsToDispatch[propertyToDispatch] = [];
                }
                recordsToDispatch[propertyToDispatch].push(record);
            }
        });

        // dispatch modified and new records
        for (const propertyName in recordsToDispatch) {
            if (Object.prototype.hasOwnProperty.call(recordsToDispatch, propertyName)) {
                dispatchFlowEventCollection(
                    engine,
                    propertyName,
                    recordsToDispatch[propertyName],
                    objectDescribe,
                );
            }
        }

        // dispatch selected records
        if ((selectedChildValues[childId] || []).length) {
            const selectedRecords = [];
            selectedChildValues[childId].forEach(recordId => {
                selectedRecords.push(childValues[childId][recordId]);
            })
            dispatchFlowEventCollection(
                engine,
                `child${tab.sequence}${recordActions.selected}`,
                selectedRecords,
                objectDescribe,
            );
        }

        // dispatch deleted records
        if ((childDeletes[childId] || []).length) {
            dispatchFlowEventCollection(
                engine,
                `child${tab.sequence}${recordActions.deleted}`,
                childDeletes[childId],
                objectDescribe,
            );
        }
    });

}

export const getValidationErrorCount = (
    validationResults,
    childValidationResults,
    zeroLineValidationResults
) => {
    let errorCount = 0;
    errorCount = Object.keys(validationResults).length;
    Object.keys(childValidationResults).forEach(childId => {
        Object.keys(childValidationResults[childId] || {}).forEach(recordId => {
            errorCount +=  Object.keys(childValidationResults[childId][recordId] || {}).length;
        });
    });
    errorCount += zeroLineValidationResults.length;
    return errorCount;
}

export const getChildValidationResults = (tabs,childValues,i18n) => {
    const validationResults = {};
    tabs.forEach(tab => {
        validationResults[tab.name] = {};
        const requiredColumns = tab.elements.filter(column => {
            return (column.required && !column.systemField);
        }).map(({ fieldName, label }) => {
            return {
                fieldName,
                label,
            };
        });

        const childValuesByRecordId = childValues[tab.name] || {};
        Object.keys(childValuesByRecordId).forEach(recordId => {
            const record = childValuesByRecordId[recordId];
            requiredColumns.forEach(field => {
                const { fieldName, label } = field;
                if (record[fieldName] === null ||
                    record[fieldName] === undefined ||
                    record[fieldName] === '') {
                    validationResults[tab.name][recordId] =
                        validationResults[tab.name][recordId] || {};
                    validationResults[tab.name][recordId][fieldName]= [{
                        ruleType: VALIDATION_RULE_TYPE.REQUIRED,
                        validationType: VALIDATION_ERROR_TYPE.ERROR,
                        validationMessage: formatString(
                            i18n.cellRequired,
                            label
                        ),
                    }];
                }
            });
        });
    });

    return validationResults;
}

export const getHeaderdValidationResults = (validationResultsBySection,i18n) => {
    const validationResults = {};
    (validationResultsBySection || []).forEach(section => {
        section.forEach(field => {
            if (!field.validity && field.required ||
                !field.validity && !field.required) {
                validationResults[field.name] = [{
                    ruleType: VALIDATION_RULE_TYPE.REQUIRED,
                    validationType: VALIDATION_ERROR_TYPE.ERROR,
                    validationMessage: formatString(
                        i18n.cellRequired,
                        field.name
                    ),
                }];
            }
        });
    });

    return validationResults;
}

export const hasChildLines = (childValues) => {
    let lines = 0;
    Object.keys(childValues) .forEach(childId => {
        lines += Object.keys(childValues[childId] || {}).length;
    });
    return lines > 0;
}

export const getMappingDetailsByIds = async (
    dispatch,
    getState,
    engine,
    mappingIds,
) => {
    const mapping = await getObjectMappingByIds(
        dispatch,
        getState,
        engine,
        mappingIds
    );

    return mapping;
}

export const getExpressionDetailsByIds = async (
    dispatch,
    getState,
    engine,
    expressionIds
) => {
    const { getExpressionDetails } = engine.apis;
    const { expressionById } = getState();
    let expressionDetailsById = {};
    const expressionIdsToRequest = [];

    expressionIds.forEach(expressionId => {
        if (expressionById[expressionId]) {
            expressionDetailsById[expressionId] = expressionById[expressionId];
        } else {
            expressionIdsToRequest.push(expressionId);
        }
    });

    if (expressionIdsToRequest.length > 0) {
        const result = await getExpressionDetails(expressionIdsToRequest);
        if (verifyApiResponse(result)) {
            const data = result.data;
            expressionDetailsById = { ...expressionDetailsById, ...data };

            await (dispatch(updateExpressionDetails({
                expressionIds,
                expressionDetailsById
            })));
        }
    }

    return expressionDetailsById;
}

export const resolveCompoundFieldPathToLabelPath = async (
    dispatch,
    getState,
    engine,
    rootObjectApiName,
    compoundFieldPath,
    operand,
    sourceDelimiter = '.',
    targetDelimiter = ' > '
) => {
    const fieldParts = compoundFieldPath.split(sourceDelimiter);

    // Shorthand function to change the current object describe pointer
    let currentObjectDescribe;
    const repointObjectDescribe = async objectApiName => {
        const objectDescribesByName = await getObjectDescribesByName(
            dispatch, getState, engine, [objectApiName]
        );
        currentObjectDescribe = objectDescribesByName[objectApiName];
    };

    // Replace each part of the path with the associated field label
    await repointObjectDescribe(rootObjectApiName);
    for (let i = 0; i < fieldParts.length; i++) {
        // Normalize to non-relationship form (Lookup__r > Lookup__c OR Account > AccountId)
        let normalizedPathPart;
        if (i < fieldParts.length - 1) {
            normalizedPathPart = normalizeFieldApiName(fieldParts[i]);
        } else {
            normalizedPathPart = fieldParts[i];
        }

        // Replace current path part with the associated label
        const fieldDescribe = currentObjectDescribe.fieldDefinitionsByApiName[normalizedPathPart];
        fieldParts[i] = fieldDescribe.label;

        // No need to look for the related object for the final path part
        if (i < fieldParts.length - 1) {
            // Update current object pointer
            const fieldReferenceTo = fieldDescribe.referenceTo[0];

            // eslint-disable-next-line no-await-in-loop
            await repointObjectDescribe(fieldReferenceTo);
        }
    }

    let mappedBy;
    if (operand === FUNCTION_LITERALS.USER) {
        mappedBy = currentObjectDescribe.label;
    } else if (operand === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
        // eslint-disable-next-line max-len
        mappedBy = `${FUNCTION_LITERALS.CURRENTRECORDHEADER}(${currentObjectDescribe.label})`;
    }

    // prefix root object to field parts mappedBy, while resolving RHS
    if (mappedBy) {
        fieldParts.unshift(mappedBy);
    }

    return fieldParts.join(targetDelimiter);
};

export const getFormattedExpressionForObject = async (
    dispatch,
    getState,
    engine,
    objectApiName,
    expressionId
) => {
    const { formattedExpressionsByObject, headerObjectName } = getState();
    let formattedExpression = formattedExpressionsByObject[objectApiName]?.[expressionId];

    if (!formattedExpression) {
        const expressionDetailsById = await getExpressionDetailsByIds(
            dispatch, getState, engine, [expressionId]
        );
        const expressionDetails = expressionDetailsById[expressionId];

        const expressionDetailList = expressionDetails.expressionDetailList;
        const advancedExpression = expressionDetails.advancedExpression
            ? expressionDetails.advancedExpression
            : '1';

        // Replace each expression detail index in advanced expression with formatted detail
        const advancedExpressionTokens = advancedExpression
            .replaceAll(/ *([()]) */g, ' $1 ')
            .split(/ +/g)
            .filter(token => token.length);

        const expressionTokenSequences = [];
        for (let i = 0; i < expressionDetailList.length; i++) {
            const displayTokenSequence = createDisplayTokenSequence();
            expressionTokenSequences.push(displayTokenSequence);

            const expressionDetail = expressionDetailList[i];
            const {
                operandType, sourceObjectName, fieldAPIName, literalParameterAPIName,
                operand, operator
            } = expressionDetail;

            // Resolve labels for left-hand side of expression
            // eslint-disable-next-line no-await-in-loop
            const leftSide = await resolveCompoundFieldPathToLabelPath(
                dispatch, getState, engine, sourceObjectName ?? objectApiName, fieldAPIName
            );

            const operatorLabel = OPERATOR_MAP[operator].toUpperCase().replaceAll(' ', '_');

            let rightSide;
            if (operandType === MAPPING_TYPE.FUNCTION) {
                if (operand.startsWith('FSVMX')) {
                    // Must be using a Date literal (FSVMXTODAY -> Today)
                    const trimPrefix = operand.substring(5);
                    rightSide = trimPrefix[0] + trimPrefix.slice(1).toLowerCase();
                } else {
                    // Resolve label for right-hand side of expression, after determining the object
                    let rightSideObjectApiName;
                    if (operand === FUNCTION_LITERALS.USER) {
                        rightSideObjectApiName = operand;
                    } else if (operand === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
                        rightSideObjectApiName = headerObjectName;
                    }

                    // eslint-disable-next-line no-await-in-loop
                    rightSide = await resolveCompoundFieldPathToLabelPath(
                        dispatch,
                        getState,
                        engine,
                        rightSideObjectApiName,
                        literalParameterAPIName,
                        operand,
                    );
                }
            } else if (operandType === MAPPING_TYPE.VALUE) {
                if (operand != null) {
                    rightSide = `${operand}`;
                }
            }

            displayTokenSequence.add(leftSide);
            displayTokenSequence.add(operatorLabel).weak();
            if (rightSide) {
                displayTokenSequence.add(rightSide);
            }
            displayTokenSequence.last().terminator();
        }

        formattedExpression = createDisplayTokenSequence();
        for (const token of advancedExpressionTokens) {
            if (!isNaN(token)) {
                // Numerical token, meaning we should inject the subsequence for this expression
                const subsequenceIndex = (+token) - 1;
                formattedExpression.addFromSequence(
                    expressionTokenSequences[subsequenceIndex]
                );
            } else if (token?.toUpperCase() === 'AND' || token?.toUpperCase() === 'OR') {
                // Logical operator token, should be displayed as its own line
                formattedExpression
                    .add(OPERATOR_MAP[token.toLowerCase()].toUpperCase())
                    .weak()
                    .singleLine();
            } else if (token === '(') {
                formattedExpression.add(token).rightPadding(false);
            } else if (token === ')') {
                formattedExpression.last().terminator(false);
                formattedExpression.add(token).leftPadding(false).terminator();
            }
        }

        // Dispatch formatted expression in store
        await (dispatch(updateFormattedExpressionForObject({
            objectApiName,
            expressionId,
            formattedExpression
        })));
    }

    return formattedExpression;
};

export const mapToFieldName = async (
    dispatch,
    getState,
    engine,
    mappingDetail,
    objectApiName,
    targetObjectAPIName
) => {
    const {
        mappingType,
        sourceFieldAPIName = '',
        targetFieldAPIName,
        literalParameterAPIName,
        value,
    } = mappingDetail;

    let mappedBy = mappingType;
    let mappedTo = value;
    const { recordTypeInfosByObjectName } = getState();
    if (mappingType === MAPPING_TYPE.FUNCTION) {
        if (value.startsWith('FSVMX')) {
            mappedBy = labelFunction;
            const trimPrefix = value.substring(5);
            const valueFormatted = trimPrefix[0] + trimPrefix.slice(1).toLowerCase();
            mappedTo = MAP_VALUE_LABEL[`label${valueFormatted}`];
        } else {
            const valueLabel = `label${value.replace(/\s+/g, '')}`;
            mappedBy = `${labelFunction} > ${MAP_VALUE_LABEL[valueLabel]}`;
            mappedTo = await resolveCompoundFieldPathToLabelPath(
                dispatch,
                getState,
                engine,
                objectApiName,
                literalParameterAPIName,
            );
            // prefix resolved field label with object name
            if (value === FUNCTION_LITERALS.CURRENTRECORD) {
                mappedTo = `${targetObjectAPIName}: ${mappedTo}`;
            } else {
                mappedTo = `${objectApiName}: ${mappedTo}`;
            }
        }
    } else if (mappingType === MAPPING_TYPE.VALUE) {
        mappedBy = labelValue;
        mappedTo = `${value}`;
        if (isNotUndefinedOrNull(value) && typeof normalizeBoolean(value) === 'boolean') {
            const str = value.toLowerCase();
            mappedTo = str[0].toUpperCase() + str.slice(1);
        }
        if (targetFieldAPIName === FIELD_API_NAMES.RECORD_TYPE_ID) {
            const recordTypeInfos = recordTypeInfosByObjectName[objectApiName];
            recordTypeInfos.forEach(recordTypeInfo => {
                if (recordTypeInfo.recordTypeId === value) {
                    mappedTo = recordTypeInfo.name;
                }
            });
        }
    } else if (mappingType === MAPPING_TYPE.FIELD) {
        mappedBy = labelField;
        mappedTo = await resolveCompoundFieldPathToLabelPath(
            dispatch,
            getState,
            engine,
            objectApiName,
            sourceFieldAPIName,
        );
        mappedTo = `${objectApiName}: ${mappedTo}`;
    }

    return {
        mappedBy,
        mappedTo,
    };
}

export const getFormattedMappingForObject = async (
    dispatch,
    getState,
    engine,
    objectApiName,
    mappingId
) => {
    const { formattedMappingsByObject } = getState();
    let formattedMapping = formattedMappingsByObject[objectApiName]?.[mappingId];

    if (!formattedMapping) {
        const mappingDetailsById = await getMappingDetailsByIds(
            dispatch, getState, engine, [mappingId]
        );
        const mapping = mappingDetailsById[mappingId];
        const {
            objectMappingDetails: mappingDetails,
            sourceObjectAPIName,
            targetObjectAPIName,
            headerRecordObject,
        } = mapping;

        formattedMapping = await Promise.all(mappingDetails.map(async (mappingDetail, id) => {
            const { targetFieldAPIName, value } = mappingDetail;
            const fieldName = await resolveCompoundFieldPathToLabelPath(
                dispatch,
                getState,
                engine,
                objectApiName,
                targetFieldAPIName,
            );
            // Resolve label for right-hand side of mapping, after determining the object
            let rightSideObjectApiName = sourceObjectAPIName ?? targetObjectAPIName;
            if (value === FUNCTION_LITERALS.USER) {
                rightSideObjectApiName = value;
            } else if (value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
                rightSideObjectApiName = headerRecordObject;
            } else if (value === FUNCTION_LITERALS.CURRENTRECORD) {
                rightSideObjectApiName = targetObjectAPIName;
            }
            const { mappedBy, mappedTo } = await mapToFieldName(
                dispatch,
                getState,
                engine,
                mappingDetail,
                rightSideObjectApiName,
                targetObjectAPIName
            );
            return {
                id: id + 1,
                fieldName,
                fieldApiName: targetFieldAPIName,
                mappedBy,
                mappedTo,
            };
        }));

        await (dispatch(updateFormattedMappingForObject({
            objectApiName,
            mappingId,
            formattedMapping
        })));
    }

    return formattedMapping;
}

export const applyValueMapping = async (
    dispatch,
    getState,
    engine,
    childId,
    conditionalMappingId
) => {
    const { getRecords } = engine.apis;
    const {
        tabsByChildId,
        headerValues,
        objectDescribes,
        transactionType,
        headerObjectName,
        isDebugEnabled
    } = getState();
    const tab = tabsByChildId[childId];
    const valueMappingId = tab.valueMapping ?? conditionalMappingId;
    const objectName = (tabsByChildId[childId] || {}).objectAPIName;

    const mappingConfig = await getObjectMappingById(
        dispatch,
        getState,
        engine,
        valueMappingId,
    );
    const userInfo = await getUserInfoDetails(
        dispatch,
        getState,
        engine
    );

    let recordTypeId = tab.defaultRecordTypeId;
    if (mappingConfig) {
        const mappedRecordType = mappingConfig.objectMappingDetails
            .filter(item => item.targetFieldAPIName === FIELD_API_NAMES.RECORD_TYPE_ID);
        if (mappedRecordType.length) {
            recordTypeId = mappedRecordType[0].value;
        }
    }

    const recordTypeInfo = await getRecordTypeById(
        dispatch,
        getState,
        engine,
        objectName,
        recordTypeId,
    );

    const currentRecord = { [FIELD_API_NAMES.RECORD_TYPE_ID]: recordTypeId };
    const updatedValues = await executeObjectMapping(
        mappingConfig,
        userInfo,
        tab.fieldsMetadata,
        null,
        recordTypeInfo,
        currentRecord,
        headerValues,
        async (Id, fields ) => {
            return getRecords(Id, fields);
        },
        transactionType,
        objectDescribes[headerObjectName],
        true
    );

    if (isDebugEnabled) {
        await dispatch(updateUserActivity({
            userActivity: [{
                actionType: 'mapping',
                referenceId: `${valueMappingId}_${childId ?? ''}`,
                Id: guid(),
                mappedRecordData: {
                    ...updatedValues,
                    Id: currentRecord?.Id
                }
            }],
        }));
    }

    return updatedValues;
}

export const getExpressionBasedMappingId = async (
    dispatch,
    getState,
    engine,
    childId,
    fieldName,
    value,
) => {
    const { objectDescribes, headerObjectName } = getState();
    let expressionBasedMapping = '';
    let objectApiName = '';
    let conditionalMappingId = '';
    let record;

    if (fieldName === undefined && value === undefined) { // child value_mapping
        const { tabsByChildId, headerValues } = getState();
        const tab = tabsByChildId[childId];
        record = headerValues;
        expressionBasedMapping = tab.expressionBasedValueMapping;
    } else if (!childId) { // header formfill_mapping
        const { formFillByFieldNames } = getState();
        const formFillByField = formFillByFieldNames[fieldName] ?? {};
        expressionBasedMapping = formFillByField.expressionBasedMapping;
        objectApiName = formFillByField.objectApiName;
    } else { // child formfill_mapping
        const { childFormFillByFieldNames } = getState();
        const childFormFillByField = (childFormFillByFieldNames[childId] || {})[fieldName];
        expressionBasedMapping = childFormFillByField.expressionBasedMapping;
        objectApiName = childFormFillByField.objectApiName;
    }

    const { rows = []} = expressionBasedMapping ?? {};
    const expressionIdsToRetrieve = new Set();
    const rowsBySequence = sortObjectArray(rows, 'sequence', 'asc');
    rowsBySequence.forEach(row => {
        if (row.expressionId) {
            expressionIdsToRetrieve.add(row.expressionId);
        }
    });
    // Retrieve and pre-cache requested expressions
    if (expressionIdsToRetrieve.size) {
        // eslint-disable-next-line no-await-in-loop
        const expressionDetailsById = await getExpressionDetailsByIds(
            dispatch,
            getState,
            engine,
            [...expressionIdsToRetrieve],
        );
        let objectDescribe = {};
        if (fieldName === undefined && value === undefined) {
            objectDescribe = objectDescribes[headerObjectName];
        } else {
            const objectDescribesByName = await getObjectDescribesByName(
                dispatch,
                getState,
                engine,
                [objectApiName],
            );
            objectDescribe =
                objectDescribesByName?.[objectApiName]
                    ?.fieldDefinitionsByApiName;
        }

        // eslint-disable-next-line @lwc/lwc/no-for-of
        for (const expressionId of expressionIdsToRetrieve) {
            const expressionDetails = expressionDetailsById[expressionId];
            if (expressionDetails) {
                const { expressionDetailList } = expressionDetails;
                // eslint-disable-next-line no-await-in-loop
                const result = await evaluateExpressions(
                    expressionDetailList,
                    record,
                    expressionDetails.advancedExpression,
                    async (recId, fields) => {
                        return engine.apis.getRecords(recId, fields);
                    },
                    objectDescribe,
                    value,
                    objectApiName,
                );
                if (result) {
                    const foundRow = rows.find(
                        row => row.expressionId === expressionId,
                    );
                    if (foundRow) {
                        conditionalMappingId = foundRow.mappingId;
                    }
                    break;
                }
            }
        }
    }

    return conditionalMappingId;
};