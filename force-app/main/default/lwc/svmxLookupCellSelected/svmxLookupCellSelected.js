import { LightningElement, api, track, wire } from 'lwc';
// TODO: Replace with
// -> import queryRecords from '@salesforce/apex/CONF_QueryLightningService.queryRecords';
import getLookupValue from '@salesforce/apex/COMM_MetadataLightningService.getLookupList';

import labelNoResultsFound from '@salesforce/label/c.Label_NoResultsFound';
import { setResolvedLookupState, getResolvedLookupValue } from 'c/runtimePubSub';
import { isUndefinedOrNull } from 'c/utils';

const i18n = {
    noResults: labelNoResultsFound
};

// TODO: Refactor to use wire service, as in svmxLookup component: JIRA# A360ENG-843
export default class SvmxLookup extends LightningElement {
    // If the icon label is unkown, all of the following properties are requried.
    @api objName;
    @api iconName;
    @api referenceNameFields = 'Name';
    @api editable = false;
    @api engineId;

    get i18n () {
        return i18n;
    }

    // If the label is already known, set it here.
    // As long as $value is not set, the @wire should not get called.
    _label;
    @api
    get label () {
        return this._label;
    }

    set label (newLabel) {
        this._label = newLabel;
    }

    _value;
    _wireValue;
    @api
    get value () {
        return this._value;
    }

    set value (newValue) {
        this._value = newValue;
        this._label = getResolvedLookupValue(this.engineId, newValue);
        if (isUndefinedOrNull(this._label)) {
            this._wireValue = newValue;
        }
    }

    // Track if the label is ready to render
    get hasLabel () {
        return this._label !== '';
    }

    @track _error;
    get hasError () {
        return typeof this._error === 'object';
    }

    // onload selectItem for given value and objName
    @wire(getLookupValue, {
        recordId: '$_wireValue',
        objectName: '$objName',
        fields: '$referenceNameFields'
    })
    wiredLookupValue ({ error, data }) {
        if (data && data.length > 0) {
            this._label = this.generateLabel(data[0]);
            setResolvedLookupState(this.engineId, this.value, this._label);
        } else if (error) {
            this._error = error;
        }
    }

    generateLabel (record) {
        let label = this.referenceNameFields.split(',')[0];
        this.referenceNameFields.split(',').forEach(field => {
            const fieldName = field.trim();
            let value;

            //logic to handle relationhships in queries
            if (fieldName.indexOf('.') > -1) {
                fieldName.split('.').forEach(item => {
                    value = value ? value[item] : record[item];
                });
            } else {
                value = record[field];
            }
            label = label.replace(field, value);
        });
        return label;
    }
}