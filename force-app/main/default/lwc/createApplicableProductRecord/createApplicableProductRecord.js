import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import WARRANTYTERM_NAME_FIELD from '@salesforce/schema/WarrantyTerm.WarrantyTermName';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelAddProductTitle from '@salesforce/label/c.Title_ApplicableProduct';
import labelNewAddProduct from '@salesforce/label/c.Label_NewApplicableProduct';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelApplicableProductCreation
    from '@salesforce/label/c.Message_ApplicableWarrantyCreatedSuccess';
import labelSave from '@salesforce/label/c.Button_Save';
import labelSaveAndNew from '@salesforce/label/c.Button_SaveAndNew';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelReviewError from '@salesforce/label/c.Error_ReviewErrors';
import labelProductFamilyExists from '@salesforce/label/c.Error_ProductFamilyExists';

const i18n = {
    title: labelAddProductTitle,
    addNewProduct: labelNewAddProduct,
    product: labelProduct,
    productFamily: labelProductFamily,
    applicableProductCreation: labelApplicableProductCreation,
    save: labelSave,
    saveAndNew: labelSaveAndNew,
    cancel: labelCancel,
    reviewError: labelReviewError,
    productFamilyExists: labelProductFamilyExists
}

export default class CreateApplicableProductRecord extends NavigationMixin(LightningElement) {
    @api parentId;
    productVisible = false;
    productFamilyVisible = false;
    fromSaveAndNew = false;
    @track error;

    @wire(getRecord, {
        recordId: "$parentId",
        fields: [WARRANTYTERM_NAME_FIELD]
    })
    record;

    get nameField () {
        return this.record.data
            ? getFieldValue(this.record.data, WARRANTYTERM_NAME_FIELD)
            : '';
    }

    get i18n () {
        return i18n;
    }

    handleProductChange (event) {
        const value = event.detail.value[0];
        if ( value ) {
            this.productFamilyVisible = true;
        } else {
            this.productFamilyVisible = false;
        }
    }

    handleProductFamilyChange (event) {
        const value = event.detail.value[0];
        if ( value ) {
            this.productVisible = true;
        } else {
            this.productVisible = false;
        }
    }

    handleSuccess (event) {
        if (this.fromSaveAndNew) {
            this.allowReset(event);
            this.productVisible = false;
            this.productFamilyVisible = false;
            this.fromSaveAndNew = false;
        } else {
            this.closeAndRefresh();
        }
        const evt = new ShowToastEvent({
            title: this.i18n.applicableProductCreation,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleError (event) {
        const message = event.detail.detail;
        if ( message.indexOf('UniquenessCheck') >= 0 ) {
            this.error = this.i18n.productFamilyExists;
        } else {
            this.error = message;
        }
    }

    handleSubmit (event) {
        this.error = null;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.WarrantyTermId = this.parentId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSaveAndNew () {
        this.fromSaveAndNew = true;
    }

    allowReset () {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    closeAndRefresh () {
        const refreshPageEvent = new CustomEvent('closeandrefreshpage');
        this.dispatchEvent(refreshPageEvent);
    }
}