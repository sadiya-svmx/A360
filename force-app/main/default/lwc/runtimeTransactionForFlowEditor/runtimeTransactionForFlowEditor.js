import { LightningElement, api } from 'lwc';
import getAllPageLayouts from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getAllPageLayouts';
import getPageLayoutDetails
    from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getPageLayoutDetails';
import labelSearchLayoutPlaceholder from '@salesforce/label/c.Placeholder_SearchLayout';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelSearchResources from '@salesforce/label/c.Search_Resources';
import labelSourceRecordId from '@salesforce/label/c.Label_SourceRecordId';
import msgChooseRecordVariable from '@salesforce/label/c.Message_Choose_Record_Variable';

import {
    verifyApiResponse,
    parseErrorMessage,
    isNotUndefinedOrNull,
    isEmptyString,
    PROPERTY_NAMES,
    PROPERTY_TYPES,
    sortObjectArray,
} from 'c/utils';

const i18n = {
    searchLayoutPlaceholder: labelSearchLayoutPlaceholder,
    developerName: labelDeveloperName,
    searchResources: labelSearchResources,
    sourceRecordId: labelSourceRecordId,
    valueMissing: msgChooseRecordVariable
}

export default class RuntimeTransactionForFlowEditor extends LightningElement {
    @api inputVariables = [];
    @api builderContext = {};

    _error = '';
    listDeveloperNames = [];

    get i18n () {
        return i18n;
    }

    get developerName () {
        return this.getInputVariable(PROPERTY_NAMES.DEVELOPER_NAME);
    }

    get recordId () {
        return this.getInputVariable(PROPERTY_NAMES.RECORD_ID);
    }

    get recordIdOptions () {
        const { variables = []} = this.builderContext;
        return variables.map(({ name }) => ({
            label: name,
            value: name,
        }));
    }

    get hasDeveloperName () {
        if (!isEmptyString(this.developerName)) {
            return true
        }
        return false;
    }

    get hasError () {
        return !isEmptyString(this.error);
    }

    get error () {
        return this._error;
    }

    // When an admin clicks Done in Flow Builder’s screen editor UI
    // Flow Builder evaluates the validate function in each custom property editor.
    // https://developer.salesforce.com/docs/component-library/documentation/en/lwc
    // lwc.use_flow_custom_property_editor_lwc_example
    @api
    validate () {
        const valid = this.reportValidity();

        const validity = [];
        if (!valid) {
            // fake validity, to retain property modal dialog upon done button click
            validity.push({});
        }

        return validity;
    }

    @api
    reportValidity () {
        const sourceRecordId = this.template.querySelector('[data-field="sourceRecordId"]');
        let valid = true;
        if (sourceRecordId) {
            valid = sourceRecordId.reportValidity();
        }
        return valid;
    }

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

    connectedCallback () {
        this.getListAllPageLayouts();

        if (this.hasDeveloperName) {
            this.loadPageLayoutDetails(this.developerName);
        }
    }

    getListAllPageLayouts () {
        const LAYOUT_TYPE = 'transaction';
        return getAllPageLayouts ({
            requestJson: LAYOUT_TYPE
        })
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

                const sortedTabs = sortObjectArray(tabs, 'sequence', 'asc');
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
                this.handleObjectChange(layoutObjects);
            }
        } else {
            this._error = parsedData.message;
        }
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

    handleChange (event, name, newValueDataType) {
        if (event && event.detail) {
            const newValue = event.detail.value;
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
            // pagelayout callout to get source and target objects for given developerName
            if (name === PROPERTY_NAMES.DEVELOPER_NAME && newValueDataType === 'String') {
                this.loadPageLayoutDetails(newValue);
            }
        }
    }

    handleChangeDeveloperName (event) {
        this.handleChange(event, PROPERTY_NAMES.DEVELOPER_NAME, 'String');
    }

    handleChangeRecordId (event) {
        this.handleChange(event, PROPERTY_NAMES.RECORD_ID, 'reference');
    }
}