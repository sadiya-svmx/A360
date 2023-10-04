import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {
    transformRecordTypesByPicklist,
} from 'c/utils';

const NONE = 'NONE';

export default class ComboboxByRecordType extends LightningElement {
    static delegatesFocus = true;
    @track _items = [];

    @api disabled;
    @api label;
    @api value;
    @api variant;
    @api required;
    @api readOnly;
    @api filterable;
    @api messageWhenValueMissing;
    @api multiple = false;
    @api placeholder;
    @api defaultRecordTypeId;
    @api fieldApiName;
    @api controllerFieldName;
    @api nestedPopover = false;

    _fieldDependencies = {};
    _masterItems = [];
    _picklistOptions = [];
    _recordTypeId;

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$fieldApiName' })
    getPicklistOptions ({ error, data }) {
        if (data) {
            const { picklistValues, fieldDependencies } = transformRecordTypesByPicklist(data);
            this._fieldDependencies = { ...fieldDependencies };
            this._masterItems = [...picklistValues];
            let newItems = [...picklistValues];

            if (this.controllerFieldName) {
                newItems = this.getItemsByControllerValue(newItems, this._controllerValue);
            }

            const valueAsArray = this.value && this.value.split(";") || this.value;
            (valueAsArray || []).forEach(value => {
                const item = newItems.find(el => el.value === value);
                if (!item && value !== NONE) {
                    const picklistOption = (this._picklistOptions || [])
                        .find(el => el.value === value);
                    newItems.unshift({
                        label: picklistOption ? picklistOption.label : value,
                        value: value
                    });
                }
            });

            this._items = [...newItems];
        } else if (error) {
            console.error(error);
        }
    }

    getItemsByControllerValue (items, controllerValue) {
        const validItems = this._fieldDependencies[controllerValue] || {};
        const filterItems = (items || []).reduce((acc, item) => {
            const { value } = item;
            if (validItems[value]) {
                return [...acc, item];
            }
            return [...acc];
        },
        []);
        return filterItems;
    }

    @api
    get items () {
        return this._items;
    }

    set items (newItems = []) {
        this._picklistOptions = [...newItems];

        if (!this.recordTypeId) {
            this._items = [...newItems];
        }
    }

    @api
    get controllerValue () {
        return this._controllerValue;
    }

    set controllerValue (value) {
        this._controllerValue = value;
        if (this.controllerFieldName &&
            this.recordTypeId &&
            Object.keys(this._fieldDependencies).length &&
            this._masterItems.length) {
            const filterItems = this.getItemsByControllerValue(
                this._masterItems,
                this.controllerValue
            );
            this._items = [...filterItems];
        }
    }

    @api
    get recordTypeId () {
        return this._recordTypeId;
    }

    set recordTypeId (value) {
        this._recordTypeId = value;
        if (!value) {
            this._recordTypeId = this.defaultRecordTypeId;
        }
    }

    @api
    checkValidity () {
        return this.template.querySelector('c-combobox').checkValidity();
    }

    @api
    reportValidity () {
        return this.template.querySelector('c-combobox').reportValidity();
    }
}