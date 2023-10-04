import { LightningElement,api,wire,track } from 'lwc';
import { parseErrorMessage,isNotUndefinedOrNull, isUndefinedOrNull } from 'c/utils';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelNext from '@salesforce/label/c.Button_Next';
import labelSave from '@salesforce/label/c.Button_Save';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelSelectRecordType from '@salesforce/label/c.Label_SelectRecordDtype';
const sldsCategories =[
    'standard',
    'custom',
    'utility',
    'doctype',
    'action'
];
const i18n = {
    labelNext: labelNext,
    labelSave: labelSave,
    labelCancel: labelCancel,
    labelSelectRecordType: labelSelectRecordType
};

export default class XCreateRecord extends LightningElement {
    @api objectApiName;
    @api prefillValues = {};
    @api noHeader = false;
    @track fields = [];
    @track recordTypes=[];
    @track title;
    @track recordIconName;
    @track selectedRecordType;
    @track showForm;
    @track defaultRecordType;
    @track masterRecordType;
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfosWire ({ error, data }) {
        if (data) {
            this.objectInfo = data;
            this.title = this.objectInfo.label;
            if (this.objectInfo.recordTypeInfos) {
                Object.keys(this.objectInfo.recordTypeInfos).forEach(key =>{
                    if (this.objectInfo.recordTypeInfos[key].available
                        && this.objectInfo.recordTypeInfos[key].name.toLowerCase() !== 'master') {
                        if (this.objectInfo.recordTypeInfos[key].defaultRecordTypeMapping) {
                            this.defaultRecordType
                                = this.objectInfo.recordTypeInfos[key].recordTypeId;
                        }
                        this.recordTypes.push({
                            'label': this.objectInfo.recordTypeInfos[key].name,
                            'value': this.objectInfo.recordTypeInfos[key].recordTypeId
                        });
                    } else {
                        this.masterRecordType = this.objectInfo.recordTypeInfos[key].recordTypeId;
                    }
                })
            }
            if (this.objectInfo.fields) {
                Object.keys(this.objectInfo.fields).forEach(key =>{
                    if (this.objectInfo.fields[key].updateable) {
                        const fieldDef = JSON.parse(JSON.stringify(this.objectInfo.fields[key]));
                        fieldDef.prefillValue = this.prefillValues[fieldDef.apiName];
                        if (fieldDef.apiName === 'Name') {
                            this.fields.splice(0,0,fieldDef);
                        } else {
                            this.fields.push(fieldDef);
                        }
                    }
                })
            }
            const iconurl = data?.themeInfo?.iconUrl;
            if (isNotUndefinedOrNull (iconurl)) {
                const iconNames = iconurl.split('/');
                const sldsnames = iconNames.pop().split('_');
                sldsnames.pop();
                const sldscategory = iconNames.pop();
                if (sldsCategories.includes(sldscategory)) {
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    this.recordIconName = `${sldscategory}:${sldsnames.join('_')}`;
                } else {
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    this.recordIconName = 'custom:custom12';
                }
            } else {
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this.recordIconName = 'custom:custom12';
            }
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    get hasRecordTypes () {
        return !this.showForm && this.recordTypes.length > 0;
    }

    get i18n () {
        return i18n;
    }

    handleOnchangeRecordType (event) {
        this.selectedRecordType = event.detail.value;
        this.fields.forEach( field => {
            if (field.apiName === 'RecordTypeId') {
                field.prefillValue = this.selectedRecordType;
            }
        });
    }

    handleSelectRecordType () {
        this.fields.forEach( field => {
            if (field.apiName === 'RecordTypeId'
                && isUndefinedOrNull(field.prefillValue)) {
                    if (isNotUndefinedOrNull(this.defaultRecordType)) {
                        field.prefillValue = this.defaultRecordType;
                        this.selectedRecordType = this.defaultRecordType;
                    } else {
                        field.prefillValue = this.masterRecordType;
                        this.selectedRecordType = this.masterRecordType;
                    }
            }
        });
        const currRecordType = this.selectedRecordType;
        const index = this.recordTypes.findIndex(recordType => recordType.value === currRecordType);
        const recordTypeLabel = index === -1 ? 'Master' : this.recordTypes[index].label;
        this.dispatchEvent(
            new CustomEvent('recordtypeselected', {
                detail: {
                    value: recordTypeLabel
                }
            })
        );
        this.showForm = true;
    }

    handleCancelRecord () {
        this.dispatchEvent(
            new CustomEvent('modalclosed', {})
        );
    }

    handleRecordSuccess (event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record created successfully.',
                variant: 'success'
            })
        );
        this.dispatchEvent(
            new CustomEvent('recordcreated', {
                detail: {
                    value: event.detail.id
                }
            })
        );
    }

}