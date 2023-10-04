import {
    transformHeaderFields,
    transformPageLayout,
    mungeFormfillIdByFieldNames,
    mungeChildFormfillIdByFieldNames,
    mungeTabsByChildId,
    hasCurrencyFieldInSections,
    ENGINE_ERROR,
    EXPRESSION_EVALUATION_EVENT
} from './utils';

import {
    loadHeaderValues,
    loadPageDataConfig,
    loadChildValues,
    loadMetaData,
    updateHeaderRecord,
    updateChildRecord,
    updateBlockApplication,
    updateUnBlockApplication,
    updateHeaderCurrency,
    updateHeaderFieldValue,
    addTemporaryChildLine,
    commitTemporaryChildLine,
    updateTemporaryChildRecord,
    updateValidationResults,
    updateEngineError,
    cloneChildLine,
    resetEngineState,
    updateDynamicSections,
    updateLoadCompleted,
    updateIsDebugEnabled,
    updateUserActivity,
} from './createActions';

import {
    formatString,
    getColumns,
    guid,
    FIELD_API_NAMES,
    isFlowContext,
    transformObjectDefinition,
    handleObjectFieldDependencies,
    transformChildRecordData,
    verifyIsPageDataResponse,
    deepCopy,
    verifyApiResponse,
    evaluateExpressions,
    TRANSACTION_TYPE,
    normalizeFieldApiName,
    isNotUndefinedOrNull,
    isReferenceField,
    isEmptyString,
} from 'c/utils';

import {
    geti18nErrorMessage,
    getPageDataPayload,
    getChildValuesByPageData,
    formFillRequired,
    childFormFillRequired,
    childValueMappingRequired,
    hasMapping,
    getChildRecord,
    applyObjectMapping,
    mungeChildRecordDataByTabs,
    dispatchHeaderRecord,
    dispatchChildRecords,
    getChildValidationResults,
    getHeaderdValidationResults,
    hasChildLines,
    applyValueMapping,
    getMappingDetailsByIds,
    getRecordTypeById,
    getExpressionDetailsByIds,
    getFormattedExpressionForObject,
    getFormattedMappingForObject,
    getObjectDescribesByName,
    getExpressionBasedMappingId,
} from './stateUtils';

// load actions
export const applyValidation = () => async (
    dispatch,
    getState,
    engine
) => {
    const state = getState();
    if (!dispatch || !state || !engine) {
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
    }
    const { getComponentValiditionResults, geti18n } = engine.apis;
    const {
        tabs,
        childValues,
    } = state;
    const i18n = geti18n();
    const inputValidationResults = getComponentValiditionResults();
    const childValidationResults = getChildValidationResults(tabs,childValues,i18n);
    const headerValidationResults = getHeaderdValidationResults(inputValidationResults,i18n);
    const zeroLineValidationResults = [];
    tabs.forEach(tab => {
        const childRecords = childValues[tab.name] || {};
        if (!tab.allowZeroLines && !Object.keys(childRecords).length) {
            zeroLineValidationResults.push(
                formatString(
                    i18n.allowZeroLineError,
                    tab.name
                ));
        }
    });

    await dispatch(updateValidationResults({
        headerValidationResults,
        childValidationResults,
        zeroLineValidationResults
    }));
}

export const applyDynamicSections = (eventType) => async (
    dispatch,
    getState,
    engine
) => {
    const state = getState();
    if (!dispatch || !state || !engine) {
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
    }
    const {
        loadStaticResources,
        getExpressionDetails,
        getRecords
    } = engine.apis;
    const {
        masterSections,
        sections,
        masterTabs,
        tabs,
        headerValues,
        expressionById,
        objectDescribes,
        headerObjectName,
        transactionType,
        isDebugEnabled,
    } = state;

    const objectDescribe = objectDescribes[headerObjectName] || {};
    const i18n = engine.apis.geti18n();
    const sectionRules = masterSections.filter(section =>
        section.evaluationEvent !== null &&
        section.visibilityCriteria !== null
    );
    const tabRules = masterTabs.filter(tab =>
        tab.evaluationEvent !== null &&
        tab.visibilityCriteria !== null
    );
    if (sectionRules.length || tabRules.length) {
        await loadStaticResources();

        const userActivity = [];
        const _visibleSections = [];
        const _visibleTabs = [];
        const _dynamicSectionFields = [];
        let _expressionById = {};
        const expressionIdsForSections = sectionRules
            .map(s => s.visibilityCriteria)
            .filter(expId => !expressionById[expId]);
        const expressionIdsForTabs = tabRules
            .map(s => s.visibilityCriteria)
            .filter(expId => !expressionById[expId]);
        const expressionIds = [...expressionIdsForSections, ...expressionIdsForTabs];

        if (expressionIds.length) {
            // eslint-disable-next-line no-await-in-loop
            const result = await getExpressionDetails(expressionIds);
            if (!verifyApiResponse(result)) {
                throw new Error(geti18nErrorMessage(ENGINE_ERROR.EXPRESSION_APEX_ERROR))
            }
            _expressionById = deepCopy(result.data);
            const fieldsNotPresent = [];
            Object.keys(_expressionById).forEach(key => {
                const fields = _expressionById[key]
                    .expressionDetailList
                    .filter(exp => exp.sourceObjectName !== 'User')
                    .map(exp => exp.fieldAPIName);
                fields.forEach(fieldName => {
                    const fName =
                    (fieldName.split('.').length >1)
                        ? normalizeFieldApiName(fieldName.split('.')[0])
                        : fieldName;
                    _dynamicSectionFields.push(fName);
                    if (!Object.prototype.hasOwnProperty.call(headerValues, fName)) {
                        fieldsNotPresent.push(objectDescribe[fName]?.label || fName);
                    }
                });
            });
            // throw error when header doesn't have field value of expression
            if (fieldsNotPresent.length && transactionType === TRANSACTION_TYPE.STANDALONE_EDIT) {
                throw new Error(
                    formatString(i18n.labelExpressionFieldNotFound, fieldsNotPresent.join()),
                );
            }
        }

        // eslint-disable-next-line guard-for-in
        for (const sectionIndex in masterSections) {
            const section = masterSections[sectionIndex];

            if (section.visibilityCriteria &&
                section.evaluationEvent === eventType ||
                section.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ALWAYS) {
                const expressionDetails = expressionById[section.visibilityCriteria] ||
                    _expressionById[section.visibilityCriteria];
                if (expressionDetails) {
                    // eslint-disable-next-line no-await-in-loop
                    const result = await evaluateExpressions(
                        expressionDetails.expressionDetailList,
                        headerValues,
                        expressionDetails.advancedExpression,
                        async (recordId, fields ) => {
                            return getRecords(recordId, fields);
                        },
                        objectDescribe
                    )
                    if (result) {
                        _visibleSections.push(section);
                    }
                    userActivity.push({
                        actionType: 'expression',
                        referenceId: `${section.visibilityCriteria}_${section.id}`,
                        Id: guid(),
                    });
                }
            } else if (sections.findIndex(sec => sec.id === section.id) !== -1) {
                _visibleSections.push(section);
            }
        }

        // eslint-disable-next-line guard-for-in
        for (const tabIndex in masterTabs) {
            const tab = masterTabs[tabIndex];

            if (tab.visibilityCriteria &&
                tab.evaluationEvent === eventType ||
                tab.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ALWAYS) {
                const expressionDetails = expressionById[tab.visibilityCriteria] ||
                    _expressionById[tab.visibilityCriteria];
                if (expressionDetails) {
                    // eslint-disable-next-line no-await-in-loop
                    const result = await evaluateExpressions(
                        expressionDetails.expressionDetailList,
                        headerValues,
                        expressionDetails.advancedExpression,
                        async (recordId, fields ) => {
                            return getRecords(recordId, fields);
                        },
                        objectDescribe
                    )
                    if (result) {
                        _visibleTabs.push(tab);
                    }
                    userActivity.push({
                        actionType: 'expression',
                        referenceId: `${tab.visibilityCriteria}_${tab.id}`,
                        Id: guid(),
                    });
                }
            } else if (tabs.findIndex(tb => tb.id === tab.id) !== -1) {
                _visibleTabs.push(tab);
            }
        }

        await dispatch(updateDynamicSections({
            sections: _visibleSections,
            tabs: _visibleTabs,
            expressionById: _expressionById,
            dynamicSectionsExpressionFields: _dynamicSectionFields,
        }));

        if (
            userActivity.length > 0 &&
            (eventType === EXPRESSION_EVALUATION_EVENT.ONLOAD ||
            (eventType === EXPRESSION_EVALUATION_EVENT.FIELDCHANGE &&
                isDebugEnabled))
        ) {
            await dispatch(
                updateUserActivity({
                    userActivity,
                }),
            );
        }
    }

}

export const initializeHeader = (headerRecordData, headerObject) => async (
    dispatch,
) => {
    const currencyCode = (headerRecordData || {})[FIELD_API_NAMES.CURRENCY_ISO_CODE];
    await dispatch(loadHeaderValues(headerRecordData, currencyCode, headerObject));
}

export const initializeConfig = (pageDataConfig) => async (
    dispatch,
) => {
    await dispatch(loadPageDataConfig(pageDataConfig));
}

export const initializeChild = (childRecordData, tabs, context) => async (
    dispatch
) => {
    let childRecords = childRecordData;
    if (isFlowContext(context)) {
        childRecords = mungeChildRecordDataByTabs(tabs, childRecordData);
    }
    const { childValues, childValuesSequence } = getChildValuesByPageData(childRecords);
    await dispatch(loadChildValues(childValues, childValuesSequence));
}

export const getMappingIds = (configInfos, isFormFill) => {
    const mappingIds = [];
    Object.values(configInfos).forEach(configs => {
        for (const config in configs) {
            if (isFormFill) {
                const { applyMapping, expressionBasedMapping, formFillMappingId } = configs[config];
                if (applyMapping === 'Conditional') {
                    const { rows = []} = expressionBasedMapping ?? {};
                    rows.forEach(row => {
                        if (row.mappingId) {
                            mappingIds.push(row.mappingId);
                        }
                    });
                } else if (formFillMappingId) {
                    mappingIds.push(formFillMappingId);
                }
            } else if (
                Object.prototype.hasOwnProperty.call(configs, config) &&
                config === 'mapping'
            ) {
                const mapping = configs[config];
                // eslint-disable-next-line guard-for-in
                for (const key in mapping) {
                    const value = mapping[key];
                    if (value) {
                        mappingIds.push(value);
                    }
                }
            }
        }
    });

    return mappingIds;
}

export const initializeDebugConsole = () => async (dispatch, getState, engine) => {
    try {
        const state = getState();

        if (!dispatch || !state || !engine) {
            throw new Error(
                geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED),
            );
        }

        await dispatch(updateBlockApplication());
        const {
            configInfosByObject,
            objectApiNamesWithLabel,
            sourceObjectName,
            formFillByFieldNames,
            childFormFillByFieldNames,
            sections,
            tabs,
            pageDataConfig
        } = state;

        // Force retrieval and pre-cache of object mapping details
        if (hasMapping(configInfosByObject)) {
            const mappingIds = getMappingIds(configInfosByObject);
            await getMappingDetailsByIds(
                dispatch,
                getState,
                engine,
                mappingIds,
            );
        }
        // Force retrieval expression based mapping details
        const expressionBasedMappingId = pageDataConfig?.headerMappingInfo?.mappingId;
        if (expressionBasedMappingId) {
            await getMappingDetailsByIds(dispatch, getState, engine, [
                expressionBasedMappingId,
            ]);
        }

        // Force retrieval and pre-cache of header and child lookup formfill mapping details
        let formFillMappingInfoByName = {};
        if (hasMapping(formFillByFieldNames)) {
            formFillMappingInfoByName.headerLookups = formFillByFieldNames;
        }

        if (hasMapping(childFormFillByFieldNames)) {
            formFillMappingInfoByName = {
                ...formFillMappingInfoByName,
                ...childFormFillByFieldNames
            };
        }

        if (Object.keys(formFillMappingInfoByName).length) {
            const mappingIds = getMappingIds(formFillMappingInfoByName, true);
            await getMappingDetailsByIds(dispatch, getState, engine, mappingIds);
        }

        // Force object describe retrieval for mapping
        const objectApiNamesToDescribe = new Set();
        if (isNotUndefinedOrNull(sourceObjectName) && !objectApiNamesWithLabel[sourceObjectName]) {
            objectApiNamesToDescribe.add(sourceObjectName);
        }

        // Force retrieval of lookup filter expression details
        const expressionIdsToRetrieve = new Set();

        // Loop through header lookups for target object names and condition expression ids
        if (sections?.length) {
            sections.forEach(section => {
                section.elements.forEach(element => {
                    if (element.type === 'Field' && isReferenceField(element.fieldMetadata)) {
                        element.fieldMetadata.referenceTo.forEach(
                            referenceTo => objectApiNamesToDescribe.add(referenceTo)
                        );

                        if (element.lookupConfigExpressionId) {
                            expressionIdsToRetrieve.add(element.lookupConfigExpressionId);
                        }
                    }
                });
            });
        }

        // Loop through child lookups for target object names and condition expression ids
        if (tabs?.length) {
            tabs.forEach(tab => {
                tab.elements.forEach(element => {
                    if (element.type === 'xLookup' && element.typeAttributes?.meta?.length) {
                        const lookupMeta = JSON.parse(element.typeAttributes.meta);
                        if (lookupMeta.object) {
                            // lookup field can contains multiple references as below
                            // Work Order,Work Order Line Item,Work Type, so we can take only first
                            // example Product Required object, parent record id
                            objectApiNamesToDescribe.add(lookupMeta.object.split(',')[0]);
                        }

                        if (lookupMeta.lookupConfigExpressionId) {
                            expressionIdsToRetrieve.add(lookupMeta.lookupConfigExpressionId);
                        }
                    }
                });
            });
        }

        // Retrieve and pre-cache requested object describes
        if (objectApiNamesToDescribe.size) {
            await getObjectDescribesByName(
                dispatch, getState, engine, [...objectApiNamesToDescribe]
            );
        }

        // Retrieve and pre-cache requested expressions
        if (expressionIdsToRetrieve.size) {
            await getExpressionDetailsByIds(
                dispatch, getState, engine, [...expressionIdsToRetrieve]
            );
        }
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

// Middleware function to expose display formatted expression generation logic elsewhere
// NOTE: The output of this utility is intended to be used with the displayTokenSequence component
/**
 * 
 * @param {String} objectApiName - Name of object to evaluate the expression relative to
 * @param {Id} expressionId - Id of the expression to evaluate
 * @returns {DisplayTokenSequence.TokenSequence} - To be displayed by svmx/displayTokenSequence
 */
export const generateFormattedExpressionForObject = (
    objectApiName,
    expressionId
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        await dispatch(updateBlockApplication());
        return await getFormattedExpressionForObject(
            dispatch, getState, engine, objectApiName, expressionId
        );
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const generateFormattedMappingForObject = (
    objectApiName,
    expressionId
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        await dispatch(updateBlockApplication());
        return await getFormattedMappingForObject(
            dispatch, getState, engine, objectApiName, expressionId
        );
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const getNameField = (headerObjectFieldDefinition) => {
    const fieldsDef = headerObjectFieldDefinition[Object.keys(headerObjectFieldDefinition)[0]];
    return Object.keys(fieldsDef).find(fieldDef => fieldsDef[fieldDef].nameField);
}

export const initialize = (
    developerName,
    headerRecordData,
    pageDataConfig,
    childRecordData,
    context,
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const i18n = engine.apis.geti18n();
        const { getPageLayoutDetails, getObjectDescribe } = engine.apis;
        const pageLayoutDetails = await getPageLayoutDetails(developerName);
        const { error, message, ...pageLayout } = transformPageLayout(pageLayoutDetails);
        if (error) {
            throw new Error(message);
        }
        const {
            name,
            hideName,
            buttons,
            screenType,
            transactionType,
            headerObject,
            sourceObject,
            childObjects,
            tabs,
            sections,
            configInfos,
        } = pageLayout;

        const objectAPINames = [headerObject, ...childObjects];

        const resp = await getObjectDescribe(objectAPINames);
        if (!resp || !resp.data) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.OBJECT_DESCRIBE_FAILED, engine));
        }

        await dispatch(initializeHeader(headerRecordData, headerObject));
        await dispatch(initializeConfig(pageDataConfig));
        await dispatch(initializeChild(childRecordData, tabs, context));

        const { currencyCode, headerValues, childValues, engineId } = getState();
        const objectAPINamesWithFieldDefinition = {};
        const defaultRecordTypes = {};
        const childFieldsMetaData = {};
        const recordTypeInfosByObjectName = {};
        const objectApiNamesWithLabel = {};

        resp.data.forEach(entity => {
            objectAPINamesWithFieldDefinition[entity.apiName] =
                entity.fieldDefinitions;

            const recordTypeInfos = Array.isArray(entity.recordTypeInfos) ?
                entity.recordTypeInfos
                :
                [entity.recordTypeInfos];
            const defaultRecordType = recordTypeInfos.find(info =>
                info.isDefaultRecordTypeMapping &&
                    info.isActive
            );
            defaultRecordTypes[entity.apiName] =
                (defaultRecordType || {}).recordTypeId;
            objectApiNamesWithLabel[entity.apiName] = entity.label;
            recordTypeInfosByObjectName[entity.apiName] = recordTypeInfos;
        });

        const headerObjectFieldDefinition = {
            [headerObject]: transformObjectDefinition(
                objectAPINamesWithFieldDefinition[headerObject],
                currencyCode,
                defaultRecordTypes[headerObject],
            )
        }

        for (const key in objectAPINamesWithFieldDefinition) {
            if (childObjects.includes(key)) {
                childFieldsMetaData[key] = transformObjectDefinition(
                    objectAPINamesWithFieldDefinition[key],
                    currencyCode,
                    defaultRecordTypes[key],
                );
            }
        }

        const childRecordCount = hasChildLines(childValues);
        const headerSections =  transformHeaderFields(
            sections,
            headerObjectFieldDefinition,
            childRecordCount,
            headerObject,
            headerValues,
            defaultRecordTypes,
            recordTypeInfosByObjectName
        );
        const hasCurrencyField = hasCurrencyFieldInSections(headerSections);
        const headerFields = headerSections.reduce((acc, section) => {
            const newAcc = [...acc, ...section.elements];
            return newAcc
        }, []);

        const childTabs = getColumns(tabs,
            childFieldsMetaData,
            headerFields,
            defaultRecordTypes,
            engineId,
            recordTypeInfosByObjectName
        );
        const objectDescribes = { ...headerObjectFieldDefinition,...childFieldsMetaData };
        const nameField = getNameField(headerObjectFieldDefinition);
        const nameValue = headerValues[nameField];

        const formFillByFieldNames = mungeFormfillIdByFieldNames(headerSections);
        const childFormFillByFieldNames = mungeChildFormfillIdByFieldNames(childTabs);
        const tabsByChildId = mungeTabsByChildId(childTabs);
        const fieldsNotPresent = [];
        const detailsFieldsNotPresent = {};
        if (transactionType === TRANSACTION_TYPE.STANDALONE_EDIT) {
            headerSections.forEach(section => {
                section.elements.forEach(element => {
                    const fieldName = element.name;
                    if (!Object.prototype.hasOwnProperty.call(headerValues, fieldName) &&
                        element.type === 'Field') {
                        fieldsNotPresent.push(element.fieldMetadata?.label || fieldName);
                    }
                });
            });

            tabs.forEach(tab => {
                const childRecords = Object.values(childValues[tab.name] || {});
                if (childRecords.length) {
                    tab.elements.forEach(element => {
                        const fieldName = element.name;
                        if (!Object.prototype.hasOwnProperty.call(childRecords[0], fieldName) &&
                            element.type === 'Field') {
                            const fieldsMetadata = tabsByChildId[tab.name]?.fieldsMetadata || {};
                            detailsFieldsNotPresent[tab.name] =
                                detailsFieldsNotPresent[tab.name] || [];
                            detailsFieldsNotPresent[tab.name]
                                .push(fieldsMetadata[fieldName]?.label || fieldName);
                        }
                    });
                }
            });
        }

        await dispatch(loadMetaData({
            name,
            nameValue,
            hideName,
            buttons,
            screenType,
            transactionType,
            masterSections: deepCopy(headerSections),
            sections: deepCopy(headerSections),
            masterTabs: deepCopy(childTabs),
            tabs: deepCopy(childTabs),
            objectDescribes,
            configInfos,
            headerObjectName: headerObject,
            sourceObjectName: sourceObject,
            defaultRecordTypes,
            objectApiNamesWithLabel,
            recordTypeInfosByObjectName,
            formFillByFieldNames,
            childFormFillByFieldNames,
            tabsByChildId,
            developerName,
            context,
            hasCurrencyField,
        }));

        const detailsErrorCount = Object.keys(detailsFieldsNotPresent).length;
        if (fieldsNotPresent.length || detailsErrorCount) {
            let errorMessage = fieldsNotPresent.length ?
                `${i18n.labelHeader} - [${fieldsNotPresent.join()}]` : '';
            errorMessage += fieldsNotPresent.length && detailsErrorCount ? ',': '';
            errorMessage += detailsErrorCount ? ' '+i18n.labelDetails + ' - ': '';
            Object.keys(detailsFieldsNotPresent).forEach(key =>{
                errorMessage += ` [${key} - ${detailsFieldsNotPresent[key].join()}]`;
            });

            throw new Error(formatString(i18n.labelPageloutFieldNotFound, errorMessage));
        }
        await dispatch(applyDynamicSections(EXPRESSION_EVALUATION_EVENT.ONLOAD));
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
    } finally {
        await dispatch(updateLoadCompleted());
    }
};

export const reInitializeState = () => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_REINITIALIZE_FAILED));
        }
        await dispatch(updateBlockApplication());
        const  {
            initialHeaderValues,
            initialChildValues,
            initialChildValuesSequence
        } = getState();

        await dispatch(resetEngineState({
            headerValues: deepCopy(initialHeaderValues),
            childValues: deepCopy(initialChildValues),
            childValuesSequence: deepCopy(initialChildValuesSequence),
        }));

    }  finally {
        await dispatch(updateUnBlockApplication());
    }
}

export const handleHeaderFieldDependencies = (fieldName, value)  => async (
    dispatch,
    getState,
    engine
) => {
    const {
        objectDescribes,
        headerValues,
        headerObjectName,
        defaultRecordTypes
    } = getState();

    const objectDescribe = objectDescribes[headerObjectName] || {};
    const recordTypeId = headerValues[FIELD_API_NAMES.RECORD_TYPE_ID] ||
        defaultRecordTypes[headerObjectName];

    if (Object.keys(headerValues).length &&
        recordTypeId) {

        const field = objectDescribe[fieldName] || {};
        if (field.dependentFields &&
            field.dependentFields.length) {
            const udpatedValues = {};
            const recordTypeInfo = await getRecordTypeById (
                dispatch,
                getState,
                engine,
                headerObjectName,
                recordTypeId
            );

            handleObjectFieldDependencies(
                { [fieldName]: value },
                headerValues,
                objectDescribe,
                recordTypeInfo,
                (updatedRecord) => {
                    Object.assign(udpatedValues, updatedRecord);
                });
            await dispatch(updateHeaderRecord(udpatedValues));
        }
    }
};

export const handleChildFieldDependencies = (childId, recordId, fieldName, value)  => async (
    dispatch,
    getState,
    engine
) => {
    const {
        objectDescribes,
        defaultRecordTypes,
        tabsByChildId
    } = getState();

    const objectName = (tabsByChildId[childId] || {}).objectAPIName;
    const childValues = getChildRecord(childId,recordId, getState);

    const objectDescribe = objectDescribes[objectName] || {};
    const recordTypeId = childValues[FIELD_API_NAMES.RECORD_TYPE_ID] ||
        defaultRecordTypes[objectName];

    if (Object.keys(childValues).length &&
        recordTypeId) {

        const field = objectDescribe[fieldName] || {};
        if (field.dependentFields &&
            field.dependentFields.length) {
            const udpatedValues = {};
            const recordTypeInfo = await getRecordTypeById (
                dispatch,
                getState,
                engine,
                objectName,
                recordTypeId
            );

            handleObjectFieldDependencies(
                { [fieldName]: value },
                childValues,
                objectDescribe,
                recordTypeInfo,
                (updatedRecord) => {
                    Object.assign(udpatedValues, updatedRecord);
                });
            await dispatch(updateChildRecord(childId, recordId, udpatedValues));
        }
    }
};

export const handleTemporaryChildFieldDependencies = (
    childId,
    recordId,
    fieldName,
    value
)  => async (
    dispatch,
    getState,
    engine
) => {
    const {
        objectDescribes,
        defaultRecordTypes,
        tabsByChildId,
        temporaryChildValues
    } = getState();

    const objectName = (tabsByChildId[childId] || {}).objectAPIName;
    const childValues = (temporaryChildValues[childId] || {})[recordId] || {};

    const objectDescribe = objectDescribes[objectName] || {};
    const recordTypeId = childValues[FIELD_API_NAMES.RECORD_TYPE_ID] ||
        defaultRecordTypes[objectName];

    if (Object.keys(childValues).length &&
        recordTypeId) {

        const field = objectDescribe[fieldName] || {};
        if (field.dependentFields &&
            field.dependentFields.length) {
            const udpatedValues = {};
            const recordTypeInfo = await getRecordTypeById (
                dispatch,
                getState,
                engine,
                objectName,
                recordTypeId
            );

            handleObjectFieldDependencies(
                { [fieldName]: value },
                childValues,
                objectDescribe,
                recordTypeInfo,
                (updatedRecord) => {
                    Object.assign(udpatedValues, updatedRecord);
                });
            await dispatch(updateTemporaryChildRecord(childId, recordId, udpatedValues));
        }
    }
};

export const applyLookupFormFill = (fieldName, value) => async (
    dispatch,
    getState,
    engine
) => {
    const {
        formFillByFieldNames,
        headerObjectName,
        headerValues,
        defaultRecordTypes,
    } = getState();

    const {
        formFillMappingId,
        applyMapping,
    } = formFillByFieldNames[fieldName] ?? {};
    let formFillConfigId = '';
    if (applyMapping === 'Conditional') {
        formFillConfigId = await getExpressionBasedMappingId(
            dispatch,
            getState,
            engine,
            null,
            fieldName,
            value,
        );
    } else {
        formFillConfigId = formFillMappingId
    }
    if (!formFillConfigId) return;

    const i18n = engine.apis.geti18n();
    const recordTypeId = headerValues[FIELD_API_NAMES.RECORD_TYPE_ID] ||
        defaultRecordTypes[headerObjectName];

    try {
        const updatedValues = await applyObjectMapping(
            dispatch,
            getState,
            engine,
            headerObjectName,
            recordTypeId,
            formFillConfigId,
            value,
            headerValues,
            headerValues,
            fieldName,
            true
        );
        await dispatch(updateHeaderRecord(updatedValues));
    } catch (e) {
        const error = `${i18n.labelAutofillMapping} ${e.message}`;
        throw new Error(error);
    }
}

export const applyChildLookupFormFill = (childId, recordId, fieldName, value) => async (
    dispatch,
    getState,
    engine
) => {
    const {
        childFormFillByFieldNames,
        headerValues,
        defaultRecordTypes,
        tabsByChildId,
    } = getState();

    const {
        formFillMappingId,
        applyMapping,
    } = (childFormFillByFieldNames[childId] || {})[fieldName];

    let formFillConfigId = '';
    if (applyMapping === 'Conditional') {
        formFillConfigId = await getExpressionBasedMappingId(
            dispatch,
            getState,
            engine,
            childId,
            fieldName,
            value,
        );
    } else {
        formFillConfigId = formFillMappingId;
    }
    if (!formFillConfigId) return;

    const objectName = (tabsByChildId[childId] || {}).objectAPIName;
    const childValue = getChildRecord(childId,recordId, getState);
    const i18n = engine.apis.geti18n();
    const recordTypeId = childValue[FIELD_API_NAMES.RECORD_TYPE_ID] ||
        defaultRecordTypes[objectName];

    try {
        const updatedValues = await applyObjectMapping(
            dispatch,
            getState,
            engine,
            objectName,
            recordTypeId,
            formFillConfigId,
            value,
            childValue,
            headerValues,
            childId
        );
        await dispatch(updateChildRecord(childId,recordId, updatedValues));
    } catch (e) {
        const error = `${i18n.labelAutofillMapping} ${e.message}`;
        throw new Error(error);
    }
}

export const applyTemporaryChildLookupFormFill = (childId, recordId, fieldName, value) => async (
    dispatch,
    getState,
    engine
) => {
    const {
        childFormFillByFieldNames,
        headerValues,
        defaultRecordTypes,
        tabsByChildId,
        temporaryChildValues,
    } = getState();

    const {
        formFillMappingId,
        applyMapping,
    } = (childFormFillByFieldNames[childId] || {})[fieldName];

    let formFillConfigId = '';
    if (applyMapping === 'Conditional') {
        formFillConfigId = await getExpressionBasedMappingId(
            dispatch,
            getState,
            engine,
            childId,
            fieldName,
            value,
        );
    } else {
        formFillConfigId = formFillMappingId
    }
    if (!formFillConfigId) return;

    const objectName = (tabsByChildId[childId] || {}).objectAPIName;
    const childValue = (temporaryChildValues[childId] || {})[recordId] || {};
    const i18n = engine.apis.geti18n();
    const recordTypeId = childValue[FIELD_API_NAMES.RECORD_TYPE_ID] ||
        defaultRecordTypes[objectName];

    try {
        const updatedValues = await applyObjectMapping(
            dispatch,
            getState,
            engine,
            objectName,
            recordTypeId,
            formFillConfigId,
            value,
            childValue,
            headerValues,
            childId
        );
        await dispatch(updateTemporaryChildRecord(childId,recordId, updatedValues));
    } catch (e) {
        const error = `${i18n.labelAutofillMapping} ${e.message}`;
        throw new Error(error);
    }
}

export const handleCommitTemporaryChildLine= (
    childId,
    recordId,
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const {
            hasError,
        } = state;
        await dispatch(updateBlockApplication());
        await dispatch(commitTemporaryChildLine(childId,recordId));
        if (hasError) {
            await dispatch(applyValidation());
        }
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
}

export const handleIsDebugEnabled = (
    isDebugEnabled,
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        await dispatch(updateIsDebugEnabled({
            isDebugEnabled,
        }));
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
}

export const handleHeaderFieldChange = (
    fieldName,
    value
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const {
            hasError,
            dynamicSectionsExpressionFields,
        } = state;
        await dispatch(updateBlockApplication());
        await dispatch(updateHeaderFieldValue(fieldName, value));
        const doFormFill = formFillRequired(fieldName,getState);
        if (doFormFill && value) {
            await dispatch(applyLookupFormFill(fieldName, value));
        }

        await dispatch(handleHeaderFieldDependencies(fieldName, value));
        if (fieldName === FIELD_API_NAMES.CURRENCY_ISO_CODE && value) {
            await dispatch(updateHeaderCurrency({ currencyCode: value }));
        }
        if (dynamicSectionsExpressionFields.includes(fieldName)) {
            await dispatch(applyDynamicSections(EXPRESSION_EVALUATION_EVENT.FIELDCHANGE));
        }
        if (hasError) {
            await dispatch(applyValidation());
        }
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const handleChildRecordChange = (
    childId,
    recordId,
    fieldName,
    value
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        let newValue = value;
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const {
            hasError
        } = state;

        const recordIds = Array.isArray(recordId) ? recordId: [recordId];
        await dispatch(updateBlockApplication());
        const doFormFill = childFormFillRequired(childId,fieldName,getState);

        // eslint-disable-next-line guard-for-in
        for (const index in recordIds) {
            const rowId = recordIds[index];
            // Avoid Erroring out FIELD_INTEGRITY_EXCEPTION : Quantity must be nonzero
            if (fieldName === FIELD_API_NAMES.QUANTITY && isEmptyString(newValue)) {
                newValue = null;
            }
            // eslint-disable-next-line no-await-in-loop
            await dispatch(updateChildRecord(childId,rowId,{ [fieldName]: newValue }));
            if (doFormFill && newValue) {
                // eslint-disable-next-line no-await-in-loop
                await dispatch(applyChildLookupFormFill(childId,rowId,fieldName,newValue));
            }
            // eslint-disable-next-line no-await-in-loop
            await dispatch(handleChildFieldDependencies(childId,rowId,fieldName,newValue));

        }
        if (hasError) {
            await dispatch(applyValidation());
        }
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const handleTemporaryChildRecordChange = (
    childId,
    recordId,
    fieldName,
    value
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        await dispatch(updateBlockApplication());
        await dispatch(updateTemporaryChildRecord(childId,recordId,{ [fieldName]: value }));
        const doFormFill = childFormFillRequired(childId,fieldName,getState);
        if (doFormFill && value) {
            await dispatch(applyTemporaryChildLookupFormFill(childId,recordId,fieldName,value));
        }
        await dispatch(handleTemporaryChildFieldDependencies(childId,recordId,fieldName,value));
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const handleAddTemporaryChildLine = (
    childId,
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const { tabsByChildId } = state;
        const tab = tabsByChildId[childId];
        const i18n = engine.apis.geti18n();
        await dispatch(updateBlockApplication());

        let conditionalMappingId = '';
        if (tab.applyValueMapping === 'Conditional') {
            conditionalMappingId = await getExpressionBasedMappingId(
                dispatch,
                getState,
                engine,
                childId,
                undefined,
                undefined,
            );
        }

        let valueMapping = {};
        if (childValueMappingRequired(childId,getState) || !isEmptyString(conditionalMappingId)) {
            try {
                valueMapping = await applyValueMapping(
                    dispatch,
                    getState,
                    engine,
                    childId,
                    conditionalMappingId,
                );
            } catch (e) {
                const error = `${i18n.labelValueMapping} ${e.message}`;
                throw new Error(error);
            }
        }

        const { payload } = dispatch(
            addTemporaryChildLine(childId, valueMapping),
        );

        // eslint-disable-next-line consistent-return
        return payload.recordId;
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const handleAddMultipleLines = (
    childId,
    lookupIds,
    fieldName
) => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const i18n = engine.apis.geti18n();
        await dispatch(updateBlockApplication());
        let valueMapping = {};
        if (childValueMappingRequired(childId,getState)) {
            try {
                valueMapping = await applyValueMapping(
                    dispatch,
                    getState,
                    engine,
                    childId,
                );
            } catch (e) {
                const error = `${i18n.labelValueMapping} ${e.message}`;
                throw new Error(error);
            }
        }

        for (const index in lookupIds) {
            if (Object.prototype.hasOwnProperty.call(lookupIds, index)) {
                const lookupId = lookupIds[index];
                const { payload } = dispatch(
                    addTemporaryChildLine(childId, valueMapping),
                );
                const recordId = payload.recordId;
                // eslint-disable-next-line no-await-in-loop
                await dispatch(updateTemporaryChildRecord(
                    childId,
                    recordId,
                    { [fieldName]: lookupId }
                ));

                const doFormFill = childFormFillRequired(childId,fieldName,getState);
                if (doFormFill && lookupId) {
                    // eslint-disable-next-line no-await-in-loop
                    await dispatch(applyTemporaryChildLookupFormFill(
                        childId,
                        recordId,
                        fieldName,
                        lookupId
                    ));
                }

                // eslint-disable-next-line no-await-in-loop
                await dispatch(handleCommitTemporaryChildLine(childId,recordId));
            }
        }
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
};

export const handleCloneChildLine = (
    childId,
    sourceRecordId,
)=> async (
    dispatch,
    getState,
    engine
) => {
    const state = getState();
    if (!dispatch || !state || !engine) {
        throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
    }
    const newRecordId = guid();
    const { payload } = dispatch(
        cloneChildLine(childId, sourceRecordId, newRecordId),
    );
    // eslint-disable-next-line consistent-return
    return payload;
};

export const save = () => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        const { saveRecords } = engine.apis;
        await dispatch(updateBlockApplication());
        await dispatch(updateEngineError({ error: null }));
        await dispatch(applyValidation());
        const  {
            hasError,
            headerObjectName,
        } = getState();

        if (hasError) {
            // eslint-disable-next-line consistent-return
            return  { success: false };
        }
        const pageData = getPageDataPayload(getState);
        const result = await saveRecords(pageData);
        const pageDataResponse = result?.data || {};
        verifyIsPageDataResponse(pageDataResponse);

        const {
            headerRecord,
            pageDetails,
        } = pageDataResponse;

        const headerRecordData = headerRecord;
        const childRecordData = transformChildRecordData(pageDetails);
        const recordId = headerRecordData?.Id;
        const currencyCode = (headerRecordData || {})[FIELD_API_NAMES.CURRENCY_ISO_CODE];
        await dispatch(loadHeaderValues(headerRecordData, currencyCode));

        const { childValues, childValuesSequence } = getChildValuesByPageData(childRecordData);
        await dispatch(loadChildValues(childValues, childValuesSequence));

        await dispatch(resetEngineState({}));
        // eslint-disable-next-line consistent-return
        return {
            success: true,
            recordId,
            headerObjectName
        };
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
}

export const flowRecordAction = () => async (
    dispatch,
    getState,
    engine
) => {
    try {
        const state = getState();
        if (!dispatch || !state || !engine) {
            throw new Error(geti18nErrorMessage(ENGINE_ERROR.STATE_INITIALIZE_FAILED));
        }
        await dispatch(updateBlockApplication());
        await dispatch(updateEngineError({ error: null }));
        await dispatch(applyValidation());
        const  {
            hasError,
        } = getState();

        if (hasError) {
            // eslint-disable-next-line consistent-return
            return  { success: false };
        }

        dispatchHeaderRecord(getState,engine);
        dispatchChildRecords(getState,engine);
        // eslint-disable-next-line consistent-return
        return { success: true };
    } catch (e) {
        await dispatch(updateEngineError({ error: e }));
        throw e;
    } finally {
        await dispatch(updateUnBlockApplication());
    }
}