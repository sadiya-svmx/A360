import { LightningElement, api } from 'lwc';
import getAllPageLayouts from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getAllPageLayouts';
import getPageLayoutDetails
    from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getPageLayoutDetails';
import {
    verifyApiResponse,
    parseErrorMessage,
    isNotUndefinedOrNull,
    sortObjectArray,
    isEmptyString,
    formatString,
    PROPERTY_NAMES,
    PROPERTY_TYPES,
    asyncSetItemIntoCache,
    asyncGetItemFromCache,
    areObjectsEqual,
} from 'c/utils';
import labelSearchLayoutPlaceholder from '@salesforce/label/c.Placeholder_SearchLayout';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelSourceObject from '@salesforce/label/c.Label_SourceObject';
import labelTargetObjects from '@salesforce/label/c.Label_TargetObjects';
import labelRecordCollection from '@salesforce/label/c.Record_Collection';

const i18n = {
    searchLayoutPlaceholder: labelSearchLayoutPlaceholder,
    developerName: labelDeveloperName,
    sourceObject: labelSourceObject,
    recordCollection: labelRecordCollection,
}

const DELAY_RESOURCE_UPDATE = 300;

export default class TemplateGenericEditor extends LightningElement {
    @api inputVariables = [];
    @api genericTypeMappings = [];
    @api builderContext = {};

    _layoutObjects = {};
    _layoutOptions = {};
    _error = '';
    listDeveloperNames = [];

    showTargetObjectA = false;
    showTargetObjectB = false;
    showTargetObjectC = false;
    showTargetObjectD = false;

    getInputVariable (propertyName) {
        const param = this.inputVariables.find(({ name }) => name === propertyName);
        const valueDataType = param && param.valueDataType;
        // flows that reference developerName with constants should pull the stringValue
        if (isNotUndefinedOrNull(valueDataType) && valueDataType === 'reference') {
            const { constants } = this.builderContext;
            const developerNameReference = constants.find(({ name }) => name === param.value);
            if (developerNameReference) {
                const value = developerNameReference.value;
                return value && value.stringValue;
            }
        }
        return param && param.value;
    }
    // custom property editor screen done button handler
    @api
    validate () {
        const validity = [];
        // error due to deleted layouts
        if (this.hasError) {
            // fake validity, to retain property modal dialog upon done button click
            validity.push({});
        }
        if (this._layoutOptions.hasTabsSequenceChanged) {
            // override cache with latest tabs sequence upon Flow Edit Screen done button
            this.setTabsSequence(this._layoutOptions.key, this._layoutOptions.newTabsSequence);
        }

        return validity;
    }

    getGenericTypeMapping (propertyType) {
        const type = this.genericTypeMappings.find(
            ({ typeName }) => typeName === propertyType
        );
        return type && type.typeValue;
    }

    get targetObjectALabel () {
        return formatString(labelTargetObjects, '1');
    }

    get targetObjectBLabel () {
        return formatString(labelTargetObjects, '2');
    }

    get targetObjectCLabel () {
        return formatString(labelTargetObjects, '3');
    }

    get targetObjectDLabel () {
        return formatString(labelTargetObjects, '4');
    }

    get i18n () {
        return i18n;
    }

    get headerRecordData () {
        return this.getInputVariable(PROPERTY_NAMES.HEADER_RECORD_DATA);
    }

    get child1Modified () {
        return this.getInputVariable(PROPERTY_NAMES.CHILD1_MODIFIED);
    }

    get child2Modified () {
        return this.getInputVariable(PROPERTY_NAMES.CHILD2_MODIFIED);
    }

    get child3Modified () {
        return this.getInputVariable(PROPERTY_NAMES.CHILD3_MODIFIED);
    }

    get child4Modified () {
        return this.getInputVariable(PROPERTY_NAMES.CHILD4_MODIFIED);
    }

    get developerName () {
        return this.getInputVariable(PROPERTY_NAMES.DEVELOPER_NAME);
    }

    get hasDeveloperName () {
        if (!isEmptyString(this.developerName)) {
            return true
        }
        return false;
    }

    get sourceObjectH () {
        return (
            this._layoutObjects[PROPERTY_TYPES.H] ||
            this.getGenericTypeMapping(PROPERTY_TYPES.H)
        );
    }

    get targetObjectA () {
        return (
            this._layoutObjects[PROPERTY_TYPES.A] ||
            this.getGenericTypeMapping(PROPERTY_TYPES.A)
        );
    }

    get targetObjectB () {
        return (
            this._layoutObjects[PROPERTY_TYPES.B] ||
            this.getGenericTypeMapping(PROPERTY_TYPES.B)
        );
    }

    get targetObjectC () {
        return (
            this._layoutObjects[PROPERTY_TYPES.C] ||
            this.getGenericTypeMapping(PROPERTY_TYPES.C)
        );
    }

    get targetObjectD () {
        return (
            this._layoutObjects[PROPERTY_TYPES.D] ||
            this.getGenericTypeMapping(PROPERTY_TYPES.D)
        );
    }

    get resourcesAndElements () {
        const { recordLookups, actionCalls, variables } = this.builderContext;

        const allResources = [...recordLookups, ...actionCalls, ...variables];
        return allResources.map(({ name, label = name }) => ({
            label,
            value: name,
        }));
    }

    get hasError () {
        return !isEmptyString(this.error);
    }

    get error () {
        return this._error;
    }

    connectedCallback () {
        this.getListAllPageLayouts();

        if (this.hasDeveloperName) {
            this.loadPageLayoutDetails(this.developerName);
        }
    }

    getListAllPageLayouts () {
        return getAllPageLayouts ()
            .then(result => {
                const parsedData = JSON.parse(result);
                if (!verifyApiResponse(parsedData)) {
                    this._error = parsedData.message;
                }

                this.listDeveloperNames = this.getListAllDeveloperNames(parsedData.data);
            })
            .catch(error => {
                this._error = parseErrorMessage(error);
            });
    }

    getListAllDeveloperNames (pagelayouts) {
        return pagelayouts.map(pagelayout => {
            return {
                label: pagelayout.name,
                value: pagelayout.developerName,
                secondary: pagelayout.developerName,
            };
        });
    }

    async loadPageLayoutDetails (developerName) {
        const result = await getPageLayoutDetails({
            requestJson: developerName
        });

        const parsedData = JSON.parse(result);
        const layoutObjects = {};
        if (verifyApiResponse(parsedData)) {
            if (parsedData && parsedData?.data) {
                const {
                    data: {
                        lines: tabs = [],
                        pageHeader: { objectAPIName: headerObject }
                    }
                } = parsedData;

                layoutObjects[PROPERTY_TYPES.H] = headerObject;
                // to control ui based on number of tabs configured
                const numberOfTabs = tabs.length;
                switch (numberOfTabs) {
                    case 1:
                        this.showTargetObjectA = true;
                        this.showTargetObjectB = false;
                        this.showTargetObjectC = false;
                        this.showTargetObjectD = false;
                        break;
                    case 2:
                        this.showTargetObjectA = true;
                        this.showTargetObjectB = true;
                        this.showTargetObjectC = false;
                        this.showTargetObjectD = false;
                        break;
                    case 3:
                        this.showTargetObjectA = true;
                        this.showTargetObjectB = true;
                        this.showTargetObjectC = true;
                        this.showTargetObjectD = false;
                        break;
                    case 4:
                        this.showTargetObjectA = true;
                        this.showTargetObjectB = true;
                        this.showTargetObjectC = true;
                        this.showTargetObjectD = true;
                        break;
                    default:
                        this.showTargetObjectA = false;
                        this.showTargetObjectB = false;
                        this.showTargetObjectC = false;
                        this.showTargetObjectD = false;
                        break;
                }

                const sortedTabs = sortObjectArray(tabs, 'sequence', 'asc');
                const newTabsSequence = sortedTabs.map(tab => ({
                    sequence: tab.sequence,
                    objectAPIName: tab.objectAPIName,
                }));
                const key = `flow-${developerName}`;
                const hasTabSequence = await this.hasTabsSequence(key);
                if (!hasTabSequence) {
                    this.setTabsSequence(key, newTabsSequence);
                }
                const hasTabsSequenceChanged = await this.hasTabsSequenceChanged(
                    key,
                    newTabsSequence,
                );
                this._layoutOptions = {
                    hasTabsSequenceChanged,
                    key,
                    newTabsSequence,
                }
                if (hasTabsSequenceChanged) {
                    this.resetSelectedResources(true);
                }
                /**
                 * when layout configured with childTabs < 4 using Account as dummy object
                 * to dispatchTypeChange(typeName & typeValue) event so,
                 * to suppress and overcome the SF Flow Builder required enforcement
                 */
                const DUMMY_OBJECT = { objectAPIName: 'Account' };
                while (sortedTabs.length < 4) {
                    sortedTabs.push(DUMMY_OBJECT);
                }
                sortedTabs.forEach((tab, index) => {
                    layoutObjects[Object.keys(PROPERTY_TYPES)[index]] = tab.objectAPIName;
                });
                this._layoutObjects = layoutObjects;
                this.handleObjectChange(layoutObjects);
            }
        } else {
            this._error = parsedData.message;
        }
    }

    async setTabsSequence (key, newTabsSequence) {
        await asyncSetItemIntoCache(key, newTabsSequence);
    }

    async hasTabsSequence (key) {
        const result = await asyncGetItemFromCache(key) !== null;
        return result;
    }

    async hasTabsSequenceChanged (key, newTabsSequence) {
        if (this.hasTabsSequence()) {
            const oldTabsSequence = await asyncGetItemFromCache (key);

            if (!areObjectsEqual(oldTabsSequence, newTabsSequence)) {
                return true
            }
        }

        return false;
    }

    handleObjectChange (layoutObjectDetails) {
        if (isNotUndefinedOrNull(layoutObjectDetails)) {
            this.dispatchTypeChange(layoutObjectDetails);
        }
    }

    dispatchTypeChange (layoutObjectDetails) {
        for (const typeName in layoutObjectDetails) {
            if (Object.prototype.hasOwnProperty.call(layoutObjectDetails, typeName)) {
                const typeChangedEvent = new CustomEvent(
                    'configuration_editor_generic_type_mapping_changed',
                    {
                        bubbles: true,
                        cancelable: false,
                        composed: true,
                        detail: {
                            typeName,
                            typeValue: layoutObjectDetails[typeName],
                        },
                    },
                );
                this.dispatchEvent(typeChangedEvent);
            }
        }
    }

    dispatchValueChange (name, newValue = '', newValueDataType = 'reference') {
        const valueChangedEvent = new CustomEvent(
            'configuration_editor_input_value_changed',
            {
                bubbles: true,
                cancelable: false,
                composed: true,
                detail: {
                    name,
                    newValue,
                    newValueDataType,
                },
            }
        );
        this.dispatchEvent(valueChangedEvent);
    }

    handleChange (event, name, newValueDataType) {
        if (event && event.detail) {
            const newValue = event.detail.value;
            this.dispatchValueChange(name, newValue, newValueDataType);
            // pagelayout callout to get source and target objects for given developerName
            if (name === PROPERTY_NAMES.DEVELOPER_NAME && newValueDataType === 'String') {
                this.loadPageLayoutDetails(newValue);
            }
        }
    }

    resetSelectedResources (hasTabsSequenceChanged = false) {
        // defer resetSelectedResources until all resources avaiable to query
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const resources = this.template.querySelectorAll('.svmx-resource_combobox');
            for (let i = 0; i < resources.length; i++) {
                if (resources[i].value) {
                    const name = resources[i].getAttribute('data-name');
                    // skip reset resource for headerRecordData on tab sequence change
                    if (hasTabsSequenceChanged && name === PROPERTY_NAMES.HEADER_RECORD_DATA) {
                        continue;
                    }
                    this.dispatchValueChange(name);
                }
            }
        }, DELAY_RESOURCE_UPDATE);
    }

    handleChangeDeveloperName (event) {
        this.handleChange(event, PROPERTY_NAMES.DEVELOPER_NAME, 'String');

        if (this.hasDeveloperName) {
            this._error = '';
            this.resetSelectedResources();
        }
    }

    handleChangeHeader (event) {
        this.handleChange(event, PROPERTY_NAMES.HEADER_RECORD_DATA, 'reference');
    }

    handleChangeChild1 (event) {
        this.handleChange(event, PROPERTY_NAMES.CHILD1_MODIFIED, 'reference');
    }

    handleChangeChild2 (event) {
        this.handleChange(event, PROPERTY_NAMES.CHILD2_MODIFIED, 'reference');
    }

    handleChangeChild3 (event) {
        this.handleChange(event, PROPERTY_NAMES.CHILD3_MODIFIED, 'reference');
    }

    handleChangeChild4 (event) {
        this.handleChange(event, PROPERTY_NAMES.CHILD4_MODIFIED, 'reference');
    }
}