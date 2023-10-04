import { LightningElement, api, track } from 'lwc';

import {
    isEmptyString,
    isNotUndefinedOrNull,
    isUndefinedOrNull,
} from 'c/utils';

import labelActionTitle from '@salesforce/label/c.Label_SCONActionTitle';
import labelActionType from '@salesforce/label/c.Label_SCONActionType';
import labelFromPlan from '@salesforce/label/c.Label_SCONFromPlan';
import labelFromAccount from '@salesforce/label/c.Label_SCONFromAccount';
import labelSearchResources from '@salesforce/label/c.Search_Resources';
import labelRequiredFieldMessage from '@salesforce/label/c.Label_RequiredFieldMessage';
import labelSourceRecordId from '@salesforce/label/c.Label_SourceRecordId';
import labelSourceRecordIdDesc from '@salesforce/label/c.Label_SourceRecordIdDescription';
import labelServiceContractName from '@salesforce/label/c.Label_ServiceContractName';
import labelStartDate from '@salesforce/label/c.Label_ServiceContractStartDate';
import labelSCONPlanId from '@salesforce/label/c.Label_SCONPlanId';
import labelSCONPlanIdDesc from '@salesforce/label/c.Label_SCONPlanIdDescription';
import labelSCONEndDate from '@salesforce/label/c.Label_SCONEndDate';
import labelSCONDesc from '@salesforce/label/c.Label_ServiceContractDescription';
import labelSCONDescHelpText from '@salesforce/label/c.Label_SCONDecriptionHelpText';
import labelSCONLocationId from '@salesforce/label/c.Label_SCONLocationId';
import labelSCONLocationIdDesc from '@salesforce/label/c.Label_SCONLocationIdDescription';
import labelSCONChildAssets from '@salesforce/label/c.Label_SCONChildAssets';
import labelSCONChildAssetsDesc from '@salesforce/label/c.Label_SCONChildAssetsDescription';
import labelSCONBulkCLI from '@salesforce/label/c.Label_SCONBulkCLI';
import labelSCONBulkCLIDesc from '@salesforce/label/c.Label_SCONBulkCLIDescription';
import labelSCONPlanvsAsset from '@salesforce/label/c.Label_SCONPlanvsAsset';
import labelSCONPlanvsAssetDesc from '@salesforce/label/c.Label_SCONPlanvsAssetDescription';
import labelSCONAccountId from '@salesforce/label/c.Label_SCONAccountId';
import labelSCONPlanProductId from '@salesforce/label/c.Label_SCONPlanProductId';
import labelSCONPricebookId from '@salesforce/label/c.Label_SCONPricebookId';
import labelSCONSalesField from '@salesforce/label/c.Label_SCONSalesField';
import labelSCONSalesFieldDesc from '@salesforce/label/c.Label_SCONSalesFieldDesc';
import labelSCONSalesFieldValue from '@salesforce/label/c.Label_SCONSalesFieldValue';
import labelSCONSalesFieldValueDesc from '@salesforce/label/c.Label_SCONSalesFieldValueDesc';

import labelSCONAccountIdHelpText from '@salesforce/label/c.Label_SCONAccountIdHelpText';
import LabelSCONNameHelpText from '@salesforce/label/c.Label_SCONNameHelpText';
import LabelSCONStartDateHelpText from '@salesforce/label/c.Label_SCONStartDateHelpText';
import LabelSCONPlanProductIdHelpText from '@salesforce/label/c.Label_SCONPlanProductIdHelpText';
import LabelSCONPriceBookIdHelpText from '@salesforce/label/c.Label_SCONPriceBookIdHelpText';
import LabelSCONEndDateHelpText from '@salesforce/label/c.Label_SCONEndDateHelpText';
import label_IsCLIPlanProductId from '@salesforce/label/c.Label_IsCLIPlanProductId';
import label_IsCLIPlanProductIdHelpText from '@salesforce/label/c.Label_IsCLIPlanProductIdHelpText';

const i18n = {
    title: labelActionTitle,
    actionType: labelActionType,
    fromPlan: labelFromPlan,
    fromAccount: labelFromAccount,
    searchResources: labelSearchResources,
    requiredFieldMsg: labelRequiredFieldMessage,
    sourceRecordId: labelSourceRecordId,
    sourceRecordIdDesc: labelSourceRecordIdDesc,
    sconName: labelServiceContractName,
    startDate: labelStartDate,
    sconPlanId: labelSCONPlanId,
    sconPlanIdDesc: labelSCONPlanIdDesc,
    endDate: labelSCONEndDate,
    description: labelSCONDesc,
    descriptionHelpText: labelSCONDescHelpText,
    locationId: labelSCONLocationId,
    locationIdDesc: labelSCONLocationIdDesc,
    childAssets: labelSCONChildAssets,
    childAssetsDesc: labelSCONChildAssetsDesc,
    bulkCLI: labelSCONBulkCLI,
    bulkCLIDesc: labelSCONBulkCLIDesc,
    assetVSPlanList: labelSCONPlanvsAsset,
    assetVSPlanListDesc: labelSCONPlanvsAssetDesc,
    accountId: labelSCONAccountId,
    planProductId: labelSCONPlanProductId,
    pricebookId: labelSCONPricebookId,
    salesContractField: labelSCONSalesField,
    salesContractFieldHelpText: labelSCONSalesFieldDesc,
    salesContractId: labelSCONSalesFieldValue,
    salesContractIdHelpText: labelSCONSalesFieldValueDesc,
    accountIdHelpText: labelSCONAccountIdHelpText,
    sconNameHelpText: LabelSCONNameHelpText,
    startDateHelpText: LabelSCONStartDateHelpText,
    planProductIdHelpText: LabelSCONPlanProductIdHelpText,
    pricebookIdHelpText: LabelSCONPriceBookIdHelpText,
    endDateHelpText: LabelSCONEndDateHelpText,
    isCLIPlanProductId: label_IsCLIPlanProductId,
    isCLIPlanProductIdHelpText: label_IsCLIPlanProductIdHelpText,
}

export default class ServiceContractActionFlowEditor extends LightningElement {
    @api
    inputVariables;

    @api
    builderContext;

    @track serviceContractProperties = [
        {   label: this.i18n.sourceRecordId,
            propertyName: 'sourceRecordId',
            dataType: 'String',
            helpText: this.i18n.sourceRecordIdDesc,
            required: true,
        },
        {   label: this.i18n.sconName,
            propertyName: 'serviceContractName',
            dataType: 'String',
            helpText: this.i18n.sconName,
            required: true,
        },
        {   label: this.i18n.startDate,
            propertyName: 'serviceContractStartDate',
            dataType: 'Date',
            helpText: this.i18n.startDate,
            required: true,
        },
        {   label: this.i18n.sconPlanId,
            propertyName: 'serviceContractPlanId',
            dataType: 'String',
            helpText: this.i18n.sconPlanIdDesc,
            required: true,
        },
        {   label: this.i18n.endDate,
            propertyName: 'serviceContractEndDate',
            dataType: 'Date',
            helpText: this.i18n.endDate,
            required: false,
        },
        {   label: this.i18n.description,
            propertyName: 'serviceContractDescription',
            dataType: 'String',
            helpText: this.i18n.descriptionHelpText,
            required: false,
        },
        {   label: this.i18n.locationId,
            propertyName: 'locationId',
            dataType: 'String',
            helpText: this.i18n.locationIdDesc,
            required: false,
        },
        {   label: this.i18n.childAssets,
            propertyName: 'evaluateForChildAssets',
            dataType: 'Boolean',
            helpText: this.i18n.childAssetsDesc,
            required: false,
        },
        {   label: this.i18n.bulkCLI,
            propertyName: 'createBulkContractLines',
            dataType: 'Boolean',
            helpText: this.i18n.bulkCLIDesc,
            required: false,
        },
        {   label: this.i18n.assetVSPlanList,
            propertyName: 'assetServiceContractPlanList',
            dataType: 'Apex',
            helpText: this.i18n.assetVSPlanListDesc,
            required: false,
        },
    ];

    @track cpqProperties=[
        {   label: this.i18n.accountId,
            propertyName: 'sourceRecordId',
            dataType: 'String',
            helpText: this.i18n.accountIdHelpText,
            required: true,
        },
        {   label: this.i18n.sconName,
            propertyName: 'serviceContractName',
            dataType: 'String',
            helpText: this.i18n.sconNameHelpText,
            required: true,
        },
        {   label: this.i18n.startDate,
            propertyName: 'serviceContractStartDate',
            dataType: 'Date',
            helpText: this.i18n.startDateHelpText,
            required: true,
        },
        {   label: this.i18n.planProductId,
            propertyName: 'servicePlanProductId',
            dataType: 'String',
            helpText: this.i18n.planProductIdHelpText,
            required: true,
        },
        {   label: this.i18n.isCLIPlanProductId,
            propertyName: 'isCLIPlanProductId',
            dataType: 'Boolean',
            helpText: this.i18n.isCLIPlanProductIdHelpText,
            required: false,
            customType: true,
        },
        {   label: this.i18n.pricebookId,
            propertyName: 'pricebookId',
            dataType: 'String',
            helpText: this.i18n.pricebookIdHelpText,
            required: false,
        },
        {   label: this.i18n.endDate,
            propertyName: 'serviceContractEndDate',
            dataType: 'Date',
            helpText: this.i18n.endDateHelpText,
            required: false,
        },
        {   label: this.i18n.description,
            propertyName: 'serviceContractDescription',
            dataType: 'String',
            helpText: this.i18n.descriptionHelpText,
            required: false,
        },
        {   label: this.i18n.salesContractField,
            propertyName: 'salesContractIdFieldName',
            dataType: 'String',
            helpText: this.i18n.salesContractFieldHelpText,
            required: false,
        },
        {   label: this.i18n.salesContractId,
            propertyName: 'salesContractId',
            dataType: 'String',
            helpText: this.i18n.salesContractIdHelpText,
            required: false,
        },
    ];
    selectedAction='FOR-PRODUCT';

    _initialized = false;
    renderedCallback () {
        if (!this._initialized) {
            //Set default operation type
            const param = this.inputVariables.find(({ name }) => name === 'operationType');
            if (isUndefinedOrNull(param?.value)) {
                this.dispatchFlowEvent('operationType',this.selectedAction,'String');
            }
            this._initialized = true;
        }
    }


    get actionTypeOptions () {
        return [
            {   label: this.i18n.fromPlan,
                value: 'FOR-PRODUCT' },
            {   label: this.i18n.fromAccount,
                value: 'FOR-SERVICE-CONTRACT-PLAN' },
        ];
    }

    get operationTypeValue () {
        const param = this.inputVariables.find(({ name }) => name === 'operationType');
        return param?.value === 'FOR-SERVICE-CONTRACT-PLAN' ?
            'FOR-SERVICE-CONTRACT-PLAN' : 'FOR-PRODUCT';
    }

    get isLookUpOnCLIPlanProduct () {
        const param = this.inputVariables.find(({ name }) => name === 'isCLIPlanProductId');
        return (param?.value);
    }

    get i18n () {
        return i18n;
    }

    get actionProperties () {
        let properties = [];
        let actionPropertyList = [];
        if (this.operationTypeValue === 'FOR-PRODUCT') {
            actionPropertyList = this.cpqProperties;
        } else if (this.operationTypeValue === 'FOR-SERVICE-CONTRACT-PLAN') {
            actionPropertyList = this.serviceContractProperties;
        }
        if (actionPropertyList?.length > 0) {
            properties = actionPropertyList.map((element) => {
                return {
                    field: element,
                    value: this.getInputVariable(element.propertyName),
                    options: this.getOptionValues(element.dataType),
                };
            });
        }
        return properties;
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

    getOptionValues (dataType) {
        if (isEmptyString(dataType))  return [];
        const variables = this.builderContext.variables;
        const valueOptions = variables.map(item => {
            return {
                label: item.name,
                value: item.name,
                dataType: item.dataType
            };
        });

        if (dataType === 'All')
            return valueOptions;

        const dateValues = valueOptions.filter(row => row.dataType === dataType);
        return dateValues;

    }

    handleToggleChange (event) {
        this.selectedAction = event.detail.value;
        this.dispatchFlowEvent('operationType',this.selectedAction,'String');

        let actionPropertyList = [];
        if (this.selectedAction === 'FOR-PRODUCT') {
            actionPropertyList = this.cpqProperties;
        } else if (this.selectedAction === 'FOR-SERVICE-CONTRACT-PLAN') {
            actionPropertyList = this.serviceContractProperties;
        }
        this.clearActionProperties(actionPropertyList);
    }

    clearActionProperties (propertyList) {
        if (propertyList?.length > 0) {
            propertyList.forEach(property => {
                this.dispatchFlowEvent(property.propertyName,null,'reference');
            });
        }
    }

    handleCLIPlanProductToggle (event) {
        const isCLIPlanProductIdVal = event.target.checked;
        this.dispatchFlowEvent('isCLIPlanProductId',isCLIPlanProductIdVal,'Boolean');
    }

    dispatchFlowEvent (name,newValue,dataType) {
        const valueChangedEvent = new CustomEvent(
            'configuration_editor_input_value_changed',
            {
                bubbles: true,
                cancelable: false,
                composed: true,
                detail: {
                    name: name,
                    newValue: newValue,
                    newValueDataType: dataType,
                },
            }
        );
        this.dispatchEvent(valueChangedEvent);
    }

    handleChange (event) {
        const propertyName = event.target.dataset.field;
        const value = event.target.value;
        this.dispatchFlowEvent(propertyName,value,'reference');
    }


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
        let isValid = true;
        isValid = [...this.template.querySelectorAll(
            '.svmx-action-property-editor')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        return isValid;
    }
}