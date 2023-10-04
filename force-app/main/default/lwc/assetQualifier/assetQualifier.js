import { LightningElement, wire, api } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAppNavigationType
    from '@salesforce/apex/COMM_DatabaseUtils.fetchApplicationNavigationType';
import { normalizeBoolean } from 'c/utils';
import ID_FIELD from '@salesforce/schema/WarrantyTerm.Id';
import EXPRESSION_FIELD from '@salesforce/schema/WarrantyTerm.AssetExpression__c';
import ASSET_OBJECT from '@salesforce/schema/Asset';
import txt_AddQualifier from '@salesforce/label/c.Txt_AddQualifier';
import txt_NoQualfier from '@salesforce/label/c.Txt_NoQualfier';
import title_AssetQualifier from '@salesforce/label/c.Title_AssetQualifier';
import title_modalTitle from '@salesforce/label/c.Title_ModalTitle';
import button_Add from '@salesforce/label/c.Button_Add';
import button_Modify from '@salesforce/label/c.Button_Modify';
import button_Remove from '@salesforce/label/c.Button_Remove';
import button_cancel from '@salesforce/label/c.Button_Cancel';
import button_removeAsset from '@salesforce/label/c.button_removeAsset';
import title_toast_error from '@salesforce/label/c.Title_Toast_Error';
import title_removeAssetQualifer from '@salesforce/label/c.Title_RemoveAssetQualifer';
import message_removeAssetQalifier from '@salesforce/label/c.Message_RemoveAssetQualifier';

const i18n = {
    txt_AddQualifier: txt_AddQualifier,
    txt_NoQualfier: txt_NoQualfier,
    title_AssetQualifier: title_AssetQualifier,
    button_Add: button_Add,
    button_Modify: button_Modify,
    button_Remove: button_Remove,
    button_removeAsset: button_removeAsset,
    button_cancel: button_cancel,
    title_toast_error: title_toast_error,
    title_modalTitle: title_modalTitle,
    title_removeAssetQualifer: title_removeAssetQualifer,
    message_removeAssetQalifier: message_removeAssetQalifier
};
export default class assetQualifier extends LightningElement {
    assetObjectApiName = ASSET_OBJECT.objectApiName;
    selectorModalOpen = false;
    qualifierFound = false;
    recordData;
    actionTitle = i18n.button_Add;
    expressionObjId;
    confirmRemove = false;
    _editable;
    @api objectApiName;
    @api recordId;
    @api
    get editable () {
        return this._editable;
    }
    set editable (editable) {
        let editableVal = false;
        if (typeof editable === 'string') {
            try {
                editableVal = JSON.parse(editable);
            } catch (error) {
                editableVal = normalizeBoolean(editable);
            }
        } else {
            editableVal = normalizeBoolean(editable);
        }
        this._editable = editableVal;
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [ID_FIELD, EXPRESSION_FIELD]
    })
    assetRec ({ error, data }) {
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: i18n.title_toast_error,
                    message: error.body.message,
                    variant: 'error'
                })
            );
        } else if (data) {
            this.recordData = data;
            this.expressionObjId =
                data.fields[EXPRESSION_FIELD.fieldApiName].value;
            this.qualifierFound =
                this.expressionObjId &&
                this.expressionObjId !== null &&
                this.expressionObjId !== '';
            if (this.qualifierFound) {
                this.actionTitle = i18n.button_Modify;
            } else {
                this.actionTitle = i18n.button_Add;
            }
        }
    }

    connectedCallback () {
        getAppNavigationType()
            .then(result => {
                if (result && result.data) {
                    if (result.data === 'Console') {
                        this._editable = false;
                    }
                }
            });
    }

    get i18n () {
        return i18n;
    }

    handleClick (event) {
        event.preventDefault();
        this.selectorModalOpen = true;
    }

    handleCloseModal () {
        this.selectorModalOpen = false;
    }

    handleSelected (event) {
        this.selectorModalOpen = false;
        if (
            event.detail.value &&
            event.detail.value.id &&
            this.expressionObjId !== event.detail.value.id
        ) {
            this.updateAssetQualfier(event.detail.value.id);
        } else if (
            event.detail.value &&
            event.detail.value.id &&
            this.expressionObjId === event.detail.value.id
        ) {
            this.template.querySelector('c-expressionpreview').doManualFresh();
        }
    }

    handleRemoveAsset () {
        this.confirmRemove = true;
    }

    handleRemove () {
        this.confirmRemove = false;
        this.updateAssetQualfier(null);
    }

    handleCloseConfirmationModal () {
        this.confirmRemove = false;
    }

    updateAssetQualfier (expressionId) {
        const fields = {};
        fields[EXPRESSION_FIELD.fieldApiName] = expressionId;
        fields[ID_FIELD.fieldApiName] = this.recordId;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.expressionObjId = expressionId;
                return refreshApex(this.recordData);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: i18n.title_toast_error,
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}