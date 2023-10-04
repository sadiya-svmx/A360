import { LightningElement, api } from 'lwc';
import {
    sortObjectArray,
    isNotUndefinedOrNull,
    groupByObject,
    deepCopy,
    IS_MOBILE_DEVICE,
    IS_PHONE_DEVICE,
} from 'c/utils';

import runtimeSectionTemplate from './runtimeSection.html'
import runtimeSectionMobileTemplate from './runtimeSectionMobile.html';

export default class RuntimeSection extends LightningElement {
    // Internal vars to track the sections & validations
    _sections = [];
    _validationBySection = {};
    _isPhoneDevice = false;

    // Prepare output record for save action
    _outputRecord = {};

    connectedCallback () {
        // Adding this listener as an anonymous function it somehow bypasses a known salesforce
        // issue where multiple connects cause a listener to lose it's context.
        this.addEventListener('inputvalidity', (event) => {
            const { detail } = event;
            const sectionId = this.findSectionIdByField(detail.fieldId);
            if (!isNotUndefinedOrNull(sectionId)) return;
            if (!(sectionId in this._validationBySection)) {
                this._validationBySection[sectionId] = [];
            }

            const field = this._validationBySection[sectionId].find(item =>
                item.name === detail.name
            );

            if (field) {
                field.validity = detail.validity;
            } else {
                this._validationBySection[sectionId].push({
                    name: detail.name,
                    required: detail.required,
                    validity: detail.validity === undefined ? true : detail.validity,
                });
            }

            this.dispatchAllValidity();
        });
    }

    disconnectedCallback () {
        this._sections = [];
        this._validationBySection = {};
    }

    get hasSections () {
        return (this._sections.length > 0);
    }

    @api engineId;

    @api
    get sections () {
        return this._sections;
    }

    set sections (newValue) {
        if (!this._isPhoneDevice)
            this._isPhoneDevice = IS_PHONE_DEVICE();
        if (newValue.length > 0) {
            const parsedSections = deepCopy(newValue);
            const sortedSections = sortObjectArray(parsedSections, 'sequence', 'asc');
            this._sections = sortedSections.map(section => {
                const columns = this._isPhoneDevice ? 1 : section.columns;
                section.columnWidth = (12 / columns);
                section.showTitle = true;
                if (section.elements.length > 0) {
                    let sortedElements = sortObjectArray(section.elements,'sequence','asc');
                    sortedElements = sortedElements.map(ele => {
                        ele.classes = '';
                        if (ele.system && this._isPhoneDevice) {
                            ele.classes = 'slds-border_bottom';
                        }
                        return ele;
                    });
                    const objectGroup = groupByObject(
                        sortedElements,
                        element => element.row
                    );
                    const groupedElements = Array.from(
                        objectGroup,
                        ([name, value]) => ({ key: `section-column-${name}`, elements: [...value]})
                    );
                    let emptyIndex = 0;
                    const sortedElementsByRow = (groupedElements || []).map(item => {
                        const { elements = []} = item;
                        if (elements.length < columns && elements.length) {
                            const index = elements[0].column === 1 ? 1 : 0;
                            elements.splice(index, 0, {
                                type: 'Empty Space',
                                isField: false,
                                name: 'Empty Space' + emptyIndex,
                                id: 'Empty Space' + emptyIndex,
                            });
                        }
                        emptyIndex++;
                        return item;
                    });

                    return {
                        ...section,
                        hasElements: true,
                        elementsByRow: sortedElementsByRow,
                    };
                }
                return {
                    ...section,
                    hasElements: false,
                };
            });
            if (this._sections.length) {
                this._sections[0].showTitle = false;
            }
        }
        return this._sections;
    }

    handleValueChange (event) {
        const fieldApiname = event.target.getAttribute('data-field-apiname');
        const field = { [fieldApiname]: event.target.value };
        this._outputRecord = Object.assign(this._outputRecord, field);

        const eventRecordUpdate = new CustomEvent('recordmodified', {
            detail: {
                record: this._outputRecord,
                field,
            }
        });
        this.dispatchEvent(eventRecordUpdate);
    }

    render () {
        return IS_MOBILE_DEVICE ? runtimeSectionMobileTemplate : runtimeSectionTemplate;
    }

    @api
    reportAllValidity () {
        const inputs = [];
        this.template.querySelectorAll('c-value-input').forEach(input => {
            input.reportValidity();
            inputs.push(input.getValidityReport());
        });

        this.dispatchAllValidity();
        return inputs;
    }

    findSectionIdByField (fieldId) {
        let sectionId;
        this._sections.forEach(section => {
            const found = section.elements.find(element => {
                return (element.id === fieldId);
            });
            if (isNotUndefinedOrNull(found)) {
                sectionId = section.id;
            }
        });
        return sectionId;
    }

    dispatchAllValidity () {
        let formTotal = 0;
        let requiredTotal = 0;
        Object.keys(this._validationBySection).forEach(key => {
            const section = this._validationBySection[key];
            formTotal += section.filter(item => (!item.validity && !item.required)).length;
            requiredTotal += section.filter(item => (!item.validity && item.required)).length;
        });

        this.dispatchEvent(
            new CustomEvent('sectionvalidate', {
                detail: {
                    form: formTotal,
                    required: requiredTotal,
                },
            })
        );
    }
}