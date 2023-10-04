/* eslint-disable @lwc/lwc/no-for-of */
/* eslint-disable no-await-in-loop */
/* eslint-disable no-unused-expressions */
import { LightningElement, api, track } from 'lwc';
import {
    ROUTES,
    PAGE_ACTION_TYPES,
    NAVIGATION_ITEMS,
    TRANSACTION_TYPE,
    isNotUndefinedOrNull,
    guid,
    sortObjectArray,
    formatString,
} from 'c/utils';

import {
    getDebugSymbol,
    registerDebugStateSubscriber,
    DEBUG_INSTANCE_ID_PROPNAME
} from 'c/runtimePubSub';

import { DEBUG_KEYS as LOOKUP_DEBUG_KEYS } from 'c/svmxLookup';
import labelMappingHeader from '@salesforce/label/c.Label_Mapping_Header';
import labelValueMappingChild from '@salesforce/label/c.Label_Value_Mapping_Child';
import labelRelatedLists from '@salesforce/label/c.Label_RelatedLists';
import labelSections from '@salesforce/label/c.Label_Sections';
import altTextClose from '@salesforce/label/c.AltText_Close';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelLookupFields from '@salesforce/label/c.Label_LookupFields';
import labelDebugConsole from '@salesforce/label/c.Label_DebugConsole';
import labelObject from '@salesforce/label/c.Label_Object';
import labelOnChange from '@salesforce/label/c.Label_OnChange';
import labelOnLoad from '@salesforce/label/c.Label_OnLoad';
import labelEnabled from '@salesforce/label/c.Label_Enabled';
import labelDisabled from '@salesforce/label/c.Label_Disabled';
import labelHeaderChange from '@salesforce/label/c.Label_HeaderChange';
import labelRelatedListAddChange from '@salesforce/label/c.Label_RelatedListAddChange';
import labelLines from '@salesforce/label/c.Label_Lines';
import labelLine from '@salesforce/label/c.Label_Line';

import { EngineElement } from 'c/runtimeEngineProvider';

import {
    ComponentMixin,
    RegisterComponent,
    ComponentRegistered,
    ApplicationId,
} from 'c/xApplication';

const i18n = {
    labelDebugConsole,
    altTextClose,
    labelDeveloperName,
    labelObject,
    labelOnChange,
    labelOnLoad,
    labelLookupFields,
    labelEnabled,
    labelDisabled,
    labelHeaderChange,
    labelRelatedListAddChange,
    labelLines,
    labelLine,
};

export const EXPRESSION_EVALUATION_EVENT = {
    ALWAYS: 'Always',
    FIELDCHANGE: 'Field Change',
    ONLOAD: 'On Load',
};

export const ACTION_TYPE = {
    MAPPING: 'mapping',
    EXPRESSION: 'expression',
    LOOKUP: 'lookup',
    VALUE_MAPPING: 'value_mapping'
};

const DELAY_UI_UPDATE = 50;

export default class RuntimeDebugConsole extends ComponentMixin(EngineElement(LightningElement)) {
    @api pageTitle = '';
    @track _cards = [];
    _userActivityLog = {};
    _evaluateOnLoad = true;
    _evaluateOnFieldChange = true;

    get i18n () {
        return i18n;
    }

    async handleHideConsole () {
        await this.props.handleIsDebugEnabled(false);
        this.dispatchEvent(new CustomEvent('hideconsole'));
    }

    async connectedCallback () {
        super.connectedCallback();
        this[RegisterComponent]();
        await this.props.initializeDebugConsole();
        await this.initializeMappingHeaderCards();
        await this.initializeExpressionHeaderCards();
        await this.initializeExpressionChildCards();
        await this.updateLookupCards();
        await this.logUserActivity();
        this.initialized = true;
    }

    renderedCallback () {
        if (this.cards.length > 0) {
            const lastCardGroup = this.cards[this.cards.length - 1];
            const lastCardId = lastCardGroup.cards[lastCardGroup.cards.length - 1]?.id;
            if (lastCardId) {
                this.scrollToLogTail(lastCardId);
            }
        }
    }

    async logUserActivity () {
        const engineProps = this._engineProps;
        for (const activity of engineProps.userActivity) {
            if (!this._userActivityLog[activity.Id]) {
                this._userActivityLog[activity.Id] = true;
                if (activity.actionType === ACTION_TYPE.EXPRESSION) {
                    const section = engineProps.masterSections.find(
                        sec =>
                            `${sec.visibilityCriteria}_${sec.id}` ===
                            activity.referenceId,
                    );

                    if (section) {
                        const card = await this.createExpressionCard(
                            engineProps,
                            [section],
                            true,
                        );
                        this._cards.push({
                            id: guid(),
                            isExpression: true,
                            title: labelSections,
                            cards: card,
                        });
                        this.scrollToLogTail(card[0].id);
                    }
                }
                const isValueMapping =
                    activity.actionType === ACTION_TYPE.VALUE_MAPPING
                        ? true
                        : false;
                const isHeaderMapping = activity.isHeaderMapping ?? false;
                if (activity.actionType === ACTION_TYPE.MAPPING || isValueMapping) {
                    const [ mappingId, triggerSource ] = activity.referenceId.split('_');
                    const section = engineProps.masterTabs.find(
                        tab => tab.name === triggerSource,
                    );

                    let title = labelValueMappingChild;
                    let subtitle;
                    const { mappedRecordData } = activity;

                    // Handle processing that is specific to lookup value mapping cards
                    if (isValueMapping) {
                        const { tabsByChildId } = engineProps;

                        if (isHeaderMapping) {
                            subtitle = triggerSource;
                            title = labelHeaderChange;
                        } else {
                            subtitle = tabsByChildId[triggerSource].title;
                            title = labelRelatedListAddChange;
                        }
                    }

                    const mapping = this._objectMappingById[mappingId];
                    if (mapping) {
                        const card = await this.createMappingCard(
                            mapping,
                            isHeaderMapping,
                            EXPRESSION_EVALUATION_EVENT.FIELDCHANGE,
                            section,
                            mappedRecordData
                        );

                        if (subtitle) {
                            card.cardTitle = subtitle;
                        }

                        this._cards.push({
                            id: guid(),
                            isMapping: true,
                            isValueMapping,
                            title,
                            cards: [card],
                        });
                        this.scrollToLogTail(card.id);
                    }
                }
            }
        }
    }

    scrollToLogTail (id) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const debugConsoleCard = this.template.querySelector(
                `c-runtime-debug-console-card`,
            );
            debugConsoleCard?.scrollIntoCard(id);
        }, DELAY_UI_UPDATE);
    }

    lookupOnChangeDebugSymbol;
    lookupDebugData;
    [ComponentRegistered] () {
        const applicationId = this[ApplicationId];
        this.lookupOnChangeDebugSymbol = getDebugSymbol(
            applicationId,
            LOOKUP_DEBUG_KEYS.ON_CHANGE,
        );

        registerDebugStateSubscriber(
            this.lookupOnChangeDebugSymbol,
            lookupDebugData => {
                this.lookupDebugData = lookupDebugData;
                this.updateLookupCards();
            },
        );
    }

    handleCheckboxOnLoad (event) {
        this._evaluateOnLoad = event.target.checked;
    }

    handleCheckboxOnChange (event) {
        this._evaluateOnFieldChange = event.target.checked;
    }

    getEvaluationItem (item) {
        if (this._evaluateOnLoad && this._evaluateOnFieldChange) {
            return (
                item.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ALWAYS ||
                item.evaluationEvent === EXPRESSION_EVALUATION_EVENT.FIELDCHANGE ||
                item.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ONLOAD
            );
        } else if (this._evaluateOnLoad) {
            return (
                item.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ONLOAD ||
                item.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ALWAYS
            );
        } else if (this._evaluateOnFieldChange) {
            return (
                item.evaluationEvent ===
                    EXPRESSION_EVALUATION_EVENT.FIELDCHANGE ||
                item.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ALWAYS
            );
        }
        return false;
    }

    get headerObjectLabel () {
        return this._objectApiNamesWithLabel?.[this._headerObjectName];
    }

    get cards () {
        const prepareCard = [];
        this._cards.forEach(cardGroup => {
            const cards = cardGroup.cards.filter(card => this.getEvaluationItem(card));
            if (cards.length) {
                prepareCard.push({
                    ...cardGroup,
                    cards,
                });
            }
        });
        return prepareCard;
    }

    lookupCardGroup;
    async updateLookupCards (lookupDetails = this.lookupDebugData) {
        const lookupCards = [];

        if (lookupDetails?.length) {
            for (const lookupDetailsEntry of lookupDetails) {
                lookupCards.push(await this.createLookupCard(lookupDetailsEntry));
            }
        }

        if (!this.lookupCardGroup) {
            this.lookupCardGroup = {
                id: guid(),
                isLookup: true,
                title: labelLookupFields
            };
            this._cards.push(this.lookupCardGroup);
        }

        this.lookupCardGroup.cards = lookupCards;
        this.lookupCardGroup.hasCards = lookupCards?.length > 0;

        const lookupCardGroupIndex = this._cards.findIndex(card => card.isLookup);

        // Move lookup card group to end of debug list
        if (lookupCardGroupIndex > -1 && lookupCardGroupIndex !== this._cards.length - 1) {
            this._cards.splice(
                this._cards.length - 1,
                0,
                this._cards.splice(lookupCardGroupIndex, 1)[0]
            );
        }

        // Force debug list rerender
        this._cards = [...this._cards];
    }

    async createLookupCard (lookupDetails = {}) {
        // Populate general card details
        const lookupCard = {
            id: guid(),
            name: lookupDetails[DEBUG_INSTANCE_ID_PROPNAME],
            actionType: ACTION_TYPE.LOOKUP,
            hidden: false,
            evaluationEvent: EXPRESSION_EVALUATION_EVENT.FIELDCHANGE,
            ...lookupDetails
        };

        // Determine which subsections are used/visible
        lookupCard.hasLookupFilterData = !!lookupCard.lookupConfigId;
        lookupCard.hasContextFilterData =
            !!lookupCard.contextMatchingField &&
            !!lookupCard.contextMatchingValueField;
        lookupCard.hasAutofillMappingData = !!lookupCard.formFillMappingId;

        lookupCard.hasNoAdditionalConfiguration =
            !lookupCard.hasLookupFilterData &&
            !lookupCard.hasContextFilterData &&
            !lookupCard.hasAutofillMappingData;

        // Populate header/tab identifier
        lookupCard.cardTitle = lookupCard.tabName ?
            `${lookupCard.tabName}: ${lookupCard.fieldLabel}` :
            `${lookupCard.fieldLabel}`;

        // Populate data related to lookup filter configuration
        if (lookupCard.hasLookupFilterData) {
            const baseUrl = ROUTES.SETUP_HOME;
            const urlParams = [
                'c__isLookupEditor=true',
                `c__recordId=${lookupCard.lookupConfigId}`,
                `c__objectName=${lookupCard.objectApiName}`,
            ].join('&');
            lookupCard.url = `${baseUrl}?${urlParams}`;
        }

        if (lookupCard.searchFields?.length) {
            const objectDescribe = this._engineProps.objectDescribes[
                lookupCard.objectApiName
            ];

            let searchFields = lookupCard.searchFields.split(/, */g);
            searchFields = searchFields.map(searchField => {
                const searchFieldDescribe = objectDescribe?.[searchField];
                if (searchFieldDescribe) {
                    return searchFieldDescribe.label;
                }
                return searchField;
            });
            lookupCard.searchFields = searchFields.join(', ');
        }

        if (lookupCard.conditionExpressionId) {
            const formattedExpression = await this.formatExpression(
                lookupCard.objectApiName,
                lookupCard.conditionExpressionId
            );

            lookupCard.conditionExpression = formattedExpression;
        }

        // Populate data related to lookup context filtering configuration
        if (lookupCard.hasContextFilterData) {
            lookupCard.isLookupContextOverriddenLabel = lookupCard.canLookupContextBeOverridden
                ? i18n.labelEnabled
                : i18n.labelDisabled;
        }

        // Populate data related to lookup autofill configuration
        if (lookupCard.hasAutofillMappingData) {
            const autofillMapping = this._objectMappingById[
                lookupCard.formFillMappingId
            ];

            if (autofillMapping) {
                const mappingId = autofillMapping.id;
                const targetObjectAPIName = autofillMapping.targetObjectAPIName;
                autofillMapping.sourceObject = this._objectApiNamesWithLabel[
                    autofillMapping.sourceObjectAPIName
                ];
                autofillMapping.hasSourceObjectAPIName = isNotUndefinedOrNull(
                    autofillMapping.sourceObjectAPIName
                );
                autofillMapping.targetObject = this._objectApiNamesWithLabel[targetObjectAPIName];
                const baseUrl = ROUTES.MAPPING_EDITOR;
                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                    `c__recordId=${autofillMapping.id}`,
                    `c__mappingType=${autofillMapping.mappingType}`,
                    `c__currentItem=${NAVIGATION_ITEMS.MAPPING_EDITOR}`,
                ].join('&');
                autofillMapping.url = `${baseUrl}?${urlParams}`;
                autofillMapping.data = await this.getMappingData (targetObjectAPIName, mappingId);

                lookupCard.autofillMapping = autofillMapping;
                lookupCard.hasLoadedAutofillMappingData = true;
            } else {
                lookupCard.hasLoadedAutofillMappingData = false;
            }
        }

        return lookupCard;
    }

    async getMappingData (targetObjectAPIName, mappingId) {
        const data = await this.formatMapping(
            targetObjectAPIName,
            mappingId,
        ) || [];
        return sortObjectArray(data, 'fieldName', 'asc');
    }

    async createMappingCard (mapping, isHeader, evaluationEvent, section, mappedRecordData) {
        // construct url
        const mappingType = mapping.mappingType;
        const mappingId = mapping.id;
        const objectMappingDetails = mapping.objectMappingDetails;
        const baseUrl = ROUTES.MAPPING_EDITOR;
        const urlParams = [
            `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
            `c__recordId=${mappingId}`,
            `c__mappingType=${mappingType}`,
            `c__currentItem=${NAVIGATION_ITEMS.MAPPING_EDITOR}`,
        ].join('&');
        const url = `${baseUrl}?${urlParams}`;

        const recordsDataJson = {};
        const engineProps = this._engineProps;

        if (isHeader) {
            // Stamp header record data for JSON download
            const headerValues = engineProps.headerValues ?? {};
            const headerRecord = objectMappingDetails.reduce((acc, mappingDetail) => {
                const { targetFieldAPIName } = mappingDetail;
                return {
                    ...acc,
                    [targetFieldAPIName]: headerValues[targetFieldAPIName],
                };
            }, {});
            recordsDataJson.headerRecord = headerRecord;
        } else if (mappedRecordData) {
            // Stamp single child record data for JSON download
            recordsDataJson[section.name] = mappedRecordData;
        } else {
            // Stamp multiple child record data for JSON download
            const childRecordSequence = engineProps.childValuesSequence[section.name] ?? [];
            const childRecords = engineProps.childValues[section.name] ?? {};
            const temporaryChildRecords =
                engineProps.temporaryChildValues[section.name] ?? {};

            const allChildRecordsForTab = { ...childRecords, ...temporaryChildRecords };

            const childRecordData = childRecordSequence.map(
                childId => allChildRecordsForTab[childId]
            );

            // Scan for uncommitted child records (extended edit) to append to download list
            const committedChildRecordIds = new Set(childRecordSequence);
            Object.keys(temporaryChildRecords).forEach(temporaryChildRecordId => {
                if (!committedChildRecordIds.has(temporaryChildRecordId)) {
                    childRecordData.push(temporaryChildRecords[temporaryChildRecordId]);
                }
            });

            recordsDataJson[section.name] = childRecordData;
        }

        const { sourceObjectAPIName, targetObjectAPIName } = mapping;
        const data = await this.getMappingData(targetObjectAPIName, mappingId);
        const mappingCard = {
            name: mapping.name,
            actionType: ACTION_TYPE.MAPPING,
            isHeader,
            isMapping: true,
            sourceObject: this._objectApiNamesWithLabel[sourceObjectAPIName],
            sourceObjectAPIName: sourceObjectAPIName,
            hasSourceObjectAPIName: isNotUndefinedOrNull(sourceObjectAPIName),
            targetObject: this._objectApiNamesWithLabel[targetObjectAPIName],
            targetObjectAPIName: targetObjectAPIName,
            developerName: mapping.developerName,
            id: guid(),
            url,
            evaluationEvent,
            data,
            recordsDataJson: JSON.stringify(recordsDataJson),
        };
        return mappingCard;
    }

    async initializeMappingHeaderCards () {
        const engineProps = this._engineProps;
        const expressionBasedMappingId = engineProps?.pageDataConfig?.headerMappingInfo?.mappingId;
        const HEADER = 'header';
        const configInfosByObject = Object.keys(this._configInfosByObject);
        if (!configInfosByObject.includes(HEADER) && !expressionBasedMappingId) {
            this._cards.push({
                id: guid(),
                isMappingNotApplied: true,
                title: labelMappingHeader,
                cards: [
                    { evaluationEvent: EXPRESSION_EVALUATION_EVENT.ONLOAD },
                ],
            });
        } else {
            for (const key of configInfosByObject) {
                if (key === HEADER) {
                    const headerMapping = this._configInfosByObject[key].mapping;
                    if (headerMapping.valueMapping) {
                        const card = await this.createMappingCard(
                            this._objectMappingById[headerMapping.valueMapping],
                            true,
                            EXPRESSION_EVALUATION_EVENT.ONLOAD,
                        );
                        this._cards.push({
                            id: guid(),
                            isMapping: true,
                            title: labelMappingHeader,
                            cards: [card],
                        });
                    }
                    if (headerMapping.fieldMapping) {
                        const card = await this.createMappingCard(
                            this._objectMappingById[headerMapping.fieldMapping],
                            true,
                            EXPRESSION_EVALUATION_EVENT.ONLOAD
                        );
                        this._cards.push({
                            id: guid(),
                            isMapping: true,
                            title: labelMappingHeader,
                            cards: [card],
                        });
                    }
                }
            }
            if (expressionBasedMappingId) {
                const card = await this.createMappingCard(
                    this._objectMappingById[expressionBasedMappingId],
                    true,
                    EXPRESSION_EVALUATION_EVENT.ONLOAD,
                );
                this._cards.push({
                    id: guid(),
                    isMapping: true,
                    title: labelMappingHeader,
                    cards: [card],
                });
            }
        }
    }

    async initializeMappingChildCards (engineProps, section) {
        const result = await this.createMappingCard(
            engineProps.objectMappingById[section.fieldMapping],
            false,
            EXPRESSION_EVALUATION_EVENT.ONLOAD,
            section
        );
        return result;
    }

    async initializeExpressionHeaderCards () {
        const engineProps = this._engineProps;
        this._developerName = engineProps.developerName;

        // header sections: expressions
        const headerCards = await this.initializeHeaderExpressions(engineProps);
        const sortedHeaderCards = sortObjectArray(headerCards, 'sequence', 'asc');
        if (sortedHeaderCards.length > 0) {
            this._cards.push({
                id: guid(),
                isExpression: true,
                title: labelSections,
                cards: sortedHeaderCards,
            });
        }
    }

    async initializeExpressionChildCards () {
        const engineProps = this._engineProps;
        this._developerName = engineProps.developerName;

        // related lists: expressions
        const childCards = await this.initializeChildExpressions(engineProps);
        if (childCards.length > 0) {
            this._cards.push({
                id: guid(),
                isExpression: true,
                title: labelRelatedLists,
                cards: childCards,
            });
        }
    }

    async initializeHeaderExpressions (engineProps) {
        // header sections: expression details
        if (engineProps.masterSections.length > 0) {
            return this.createExpressionCard(
                engineProps,
                engineProps.masterSections,
                true,
                true,
            );
        }
        return [];
    }

    async initializeChildExpressions (engineProps) {
        // related lists: expression details
        if (engineProps.masterTabs.length > 0) {
            return this.createExpressionCard(
                engineProps,
                engineProps.masterTabs,
                false,
                true,
            );
        }
        return [];
    }

    async createExpressionCard (engineProps, sections, isHeader, isOnload) {
        const expressions = [];
        for (const section of sections) {
            let sec = {};
            if (section.visibilityCriteria) {
                sec = await this.getExpressionInfo(
                    engineProps,
                    section,
                    isHeader,
                );
            } else {
                sec = {
                    id: guid(),
                    sequence: section.sequence,
                    name: isHeader ? section.name : section.title,
                    actionType: ACTION_TYPE.EXPRESSION,
                    isExpression: true,
                    hidden: false,
                    isHeader,
                    hasRule: false,
                    objectAPIName: engineProps.headerObjectName,
                    evaluationEvent: EXPRESSION_EVALUATION_EVENT.ONLOAD,
                    isEvaluationEventAlways: false,
                }
            }

            if (!isHeader) {
                // capture qc for the tab
                const qc = {};
                let qcDetails = {}
                const hasQualifyingCriteria = section.qualifyingCriteria? true: false;
                const initialChildRecords = engineProps.initialChildValues[section.name] || {};
                const initialChildRecordsCount = Object.keys(initialChildRecords).length;
                qc.hasQualifyingCriteria = hasQualifyingCriteria;
                if (initialChildRecordsCount === 1) {
                    qc.childRecordsCountLines = formatString(
                        i18n.labelLine,
                        initialChildRecordsCount,
                    );
                } else {
                    qc.childRecordsCountLines = formatString(
                        i18n.labelLines,
                        initialChildRecordsCount,
                    );
                }
                if (hasQualifyingCriteria) {
                    qcDetails = await this.getExpressionInfo(
                        engineProps,
                        section,
                        isHeader,
                        true,
                    );
                }

                // capture field mapping details for the tab
                const fieldMapping = {};
                let mappingDetails = {}
                const hasFieldMapping = section.fieldMapping? true: false;
                fieldMapping.hasFieldMapping = hasFieldMapping;
                if (hasFieldMapping) {
                    mappingDetails = await this.initializeMappingChildCards(
                        engineProps,
                        section,
                    );
                }
                sec = { ...sec, ...qc, ...fieldMapping, qcDetails, mappingDetails };
            }
            expressions.push(sec);
        }

        return this.getExpressionDetails(expressions, isOnload);
    }

    async getExpressionInfo (engineProps, section, isHeader, isQualifyingCriteria = false) {
        let sec = {};
        // construct url
        const expressionType = 'visibility_criteria';
        const recordId = isQualifyingCriteria
            ? section.qualifyingCriteria
            : section.visibilityCriteria;
        const baseUrl = ROUTES.EXPRESSION_EDITOR;
        const objectName = engineProps.transactionType === TRANSACTION_TYPE.STANDALONE_EDIT
            ? section.objectAPIName
            : section.sourceObjectAPIName;
        const urlParams = [
            `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
            `c__objectName=${objectName}`,
            `c__recordId=${recordId}`,
            `c__expressionType=${expressionType}`,
            `c__currentItem=${NAVIGATION_ITEMS.EXPRESSION_EDITOR}`,
        ].join('&');
        const url = `${baseUrl}?${urlParams}`;
        const visibleSection = isHeader
            ? engineProps.sections.find(s => s.id === section.id)
            : engineProps.tabs.find(s => s.id === section.id);

        if (isQualifyingCriteria) {
            const formattedExpression = await this.formatExpression(objectName, recordId);
            const qualifyingCriteriaName = section.qualifyingCriteriaName;
            sec = {
                qualifyingCriteriaName,
                developerName: qualifyingCriteriaName.replace(' ', '_'),
                formattedExpression,
                url,
            };
        } else {
            sec = {
                id: guid(),
                sequence: section.sequence,
                referenceId: section.visibilityCriteria,
                sectionId: section.id,
                name: isHeader ? section.name : section.title,
                isExpression: true,
                actionType: ACTION_TYPE.EXPRESSION,
                hidden: isNotUndefinedOrNull(visibleSection) ? false : true,
                isHeader,
                hasRule: true,
                objectAPIName: engineProps.headerObjectName,
                visibilityCriteriaName: section.visibilityCriteriaName,
                developerName: section.visibilityCriteriaName.replace(' ', '_'),
                evaluationEvent: section.evaluationEvent,
                isEvaluationEventAlways:
                    section.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ALWAYS,
                isEvaluationEventOnload:
                    section.evaluationEvent === EXPRESSION_EVALUATION_EVENT.ONLOAD,
                isEvaluationEventFieldChange:
                    section.evaluationEvent === EXPRESSION_EVALUATION_EVENT.FIELDCHANGE,
                url,
            };
        }

        return sec;
    }

    hasItemLoggedInUserActivity (id) {
        return this._engineProps.userActivity.find(
            activity =>
                activity.referenceId === id &&
                activity.actionType === ACTION_TYPE.EXPRESSION,
        );
    }

    async getExpressionDetails (parsedExpressions, isOnload) {
        const cards = [];

        for (const parsedExpression of parsedExpressions) {
            if (parsedExpression.referenceId) {
                const itemLogged = this.hasItemLoggedInUserActivity(
                    `${parsedExpression.referenceId}_${parsedExpression.sectionId}`,
                );

                if (itemLogged) {
                    if (isOnload) {
                        this._userActivityLog[itemLogged.Id] = true;
                    }
                    const formattedExpression = await this.formatExpression(
                        parsedExpression.objectAPIName,
                        parsedExpression.referenceId
                    );

                    cards.push({
                        ...parsedExpression,
                        formattedExpression,
                    });
                }

            } else {
                cards.push(parsedExpression);
            }
        }

        return cards;
    }

    async formatExpression (objectApiName, expressionId) {
        return this.props.generateFormattedExpressionForObject(
            objectApiName,
            expressionId
        );
    }

    async formatMapping (objectApiName, mappingId) {
        return this.props.generateFormattedMappingForObject(
            objectApiName,
            mappingId
        );
    }

    async runtimeEngineUpdate (engineProps) {
        this._engineProps = engineProps;
        this._objectMappingById = engineProps.objectMappingById;
        this._configInfosByObject = engineProps.configInfosByObject;
        this._objectApiNamesWithLabel = engineProps.objectApiNamesWithLabel;
        this._isSourceToTarget = engineProps.transactionType === TRANSACTION_TYPE.SOURCE_TO_TARGET;

        this._headerObjectName = engineProps.headerObjectName;
        this._objectDescribes = engineProps.objectDescribes;
        this._recordTypeInfosByObjectName = engineProps.recordTypeInfosByObjectName;

        if (this.initialized) {
            await this.logUserActivity(engineProps);
        }
    }
}