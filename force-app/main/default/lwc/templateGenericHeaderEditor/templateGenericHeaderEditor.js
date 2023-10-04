import { LightningElement, api } from 'lwc';
import getAllPageLayouts from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getAllPageLayouts';
import getPageLayoutDetails
    from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getPageLayoutDetails';
import {
    verifyApiResponse,
    parseErrorMessage,
    isEmptyString,
    PROPERTY_NAMES,
    PROPERTY_TYPES,
    isNotUndefinedOrNull
} from 'c/utils';
import labelSearchLayoutPlaceholder from '@salesforce/label/c.Placeholder_SearchLayout';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelSourceObject from '@salesforce/label/c.Label_SourceObject';
import labelRecordCollection from '@salesforce/label/c.Record_Collection';

const i18n = {
    searchLayoutPlaceholder: labelSearchLayoutPlaceholder,
    developerName: labelDeveloperName,
    sourceObject: labelSourceObject,
    recordCollection: labelRecordCollection,
}

export default class TemplateGenericHeaderEditor extends LightningElement {
    @api inputVariables = [];
    @api genericTypeMappings = [];
    @api builderContext = {};

    _layoutObjects = {};
    _error = '';
    listDeveloperNames = [];

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

    @api
    validate () {
        const validity = [];
        // error due to deleted layouts
        if (this.hasError) {
            // fake validity, to retain property modal dialog upon done button click
            validity.push({});
        }

        return validity;
    }

    getGenericTypeMapping (propertyType) {
        const type = this.genericTypeMappings.find(
            ({ typeName }) => typeName === propertyType
        );
        return type && type.typeValue;
    }

    get i18n () {
        return i18n;
    }

    get headerRecordData () {
        return this.getInputVariable(PROPERTY_NAMES.HEADER_RECORD_DATA);
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
                        pageHeader: { objectAPIName: headerObject },
                    },
                } = parsedData;

                layoutObjects[PROPERTY_TYPES.H] = headerObject;
                this._layoutObjects = layoutObjects;
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

    resetSelectedResources () {
        const resources = this.template.querySelectorAll('.svmx-resource_combobox');
        resources.forEach(resource => {
            if (resource.value) {
                resource.value = '';
            }
        });
    }

    handleChangeDeveloperName (event) {
        this.handleChange(event, PROPERTY_NAMES.DEVELOPER_NAME, 'String');
        this.resetSelectedResources();
    }

    handleChangeHeader (event) {
        this.handleChange(event, PROPERTY_NAMES.HEADER_RECORD_DATA, 'reference');
    }
}