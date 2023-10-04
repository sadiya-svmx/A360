import { LightningElement, api, track } from 'lwc';

import labelAttributeName from '@salesforce/label/c.Label_AttributeName';
import labelType from '@salesforce/label/c.Label_Type';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelReadOnly from '@salesforce/label/c.Label_ReadOnly';
import labelDeleteItem from '@salesforce/label/c.Label_DeleteItem';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelEdit from '@salesforce/label/c.Btn_Edit';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelDeleteTemplateItem from '@salesforce/label/c.Message_DeleteTemplateItem';
import labelHelpText from '@salesforce/label/c.Label_HelpText';

import {
    deepCopy
} from 'c/utils';

const i18n = {
    attributeName: labelAttributeName,
    type: labelType,
    description: labelDescription + '(' + labelHelpText + ')',
    required: labelRequired,
    readOnly: labelReadOnly,
    deleteItem: labelDeleteItem,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteTemplateItem: labelDeleteTemplateItem,
    edit: labelEdit,
    delete: labelDelete
}

export default class TemplateItemListView extends LightningElement {

    @api category;

    @track error;

    templateItemOpen = false;
    deleteModalDialogOpen = false;
    selectedRecord;

    get templateItems () {
        return this.category?.technicalAttributeTemplateItems;
    }

    get i18n () {
        return i18n;
    }

    handleEditItem (event) {
        const targetdeveloperName = event.currentTarget.getAttribute('data-developer');
        this.handleItem(targetdeveloperName);
    }

    handleItem (developerName) {
        const configDialog = this.template.querySelector(
            '.templateItemConfig'
        );

        const tempItemRecord = this.getTemplateItemDeveloperName(
            developerName,
            this.category.technicalAttributeTemplateItems
        );

        configDialog.templateItemRecord = tempItemRecord;
        configDialog.fetchAttributeDetails(tempItemRecord.attributeId);

        this.templateItemOpen = true;
    }

    handleTemplateItemChanged (event) {
        const templateItemRec = event.detail.value;
        const cloneCategory = deepCopy(this.category);

        const dataIndex = this.getTemplateItemIndex(
            templateItemRec.developerName,
            cloneCategory.technicalAttributeTemplateItems
        );

        cloneCategory.technicalAttributeTemplateItems.splice(dataIndex, 1, templateItemRec);

        const changedDiv = this.getTemplateElementByAttribute(templateItemRec.attributeId);

        changedDiv.classList.add('svmx-background');

        this.dispatchChangeEvent(Object.assign({}, cloneCategory));
        this.handleTemplateItemClosed();
    }

    getTemplateElementByAttribute (attributeId) {
        return this.template.querySelector(`[data-id='${attributeId}']`);
    }

    handleTemplateItemClosed () {
        this.templateItemOpen = false;
    }

    dispatchChangeEvent (changedValue) {
        this.dispatchEvent(
            new CustomEvent('categoryconfigchanged', {
                detail: {
                    value: changedValue
                }
            })
        );
    }

    handleOnselect ( event ) {
        const selectedDeveloperName = event.target.dataset.name;
        const selectedItemLabel = event.detail.value;

        if ( selectedItemLabel === 'edit' ) {
            this.handleItem(selectedDeveloperName);
        }
        else if ( selectedItemLabel === 'delete' ) {
            this.selectedRecord = this.getTemplateItemDeveloperName(
                selectedDeveloperName,
                this.category.technicalAttributeTemplateItems
            );
            this.deleteModalDialogOpen = true;
        }
    }

    handleDelete () {
        const cloneCategory = deepCopy(this.category);
        const dataIndex = this.getTemplateItemIndex(
            this.selectedRecord.developerName,
            cloneCategory.technicalAttributeTemplateItems
        );
        cloneCategory.technicalAttributeTemplateItems.splice(dataIndex, 1);
        this.dispatchChangeEvent(Object.assign({}, cloneCategory));
        this.deleteModalDialogOpen = false;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    getTemplateItemIndex (developerName, templateItemRecs) {
        return templateItemRecs.findIndex(
            tempItem => tempItem.developerName === developerName
        );

    }

    getTemplateItemDeveloperName (developerName, templateItemRecs) {
        const dataIndex = this.getTemplateItemIndex(developerName,templateItemRecs);
        if (dataIndex > -1) {
            return templateItemRecs[dataIndex];
        }

        return null;
    }

    onDragStart ( event ) {
        this.dragStart = event.target.dataset.seq;
        event.target.classList.add("drag");
    }

    onDragOver ( event ) {
        event.preventDefault();
        return false;
    }

    // eslint-disable-next-line consistent-return
    onDrop ( event ) {
        event.stopPropagation();
        const currentIndex = this.dragStart;
        const newIndex = event.target.dataset.seq;
        if (currentIndex === newIndex || newIndex === '') {
            return false;
        }
        const cloneCategory = deepCopy(this.category);
        const targetRec = cloneCategory.technicalAttributeTemplateItems.splice(currentIndex, 1)[0];
        cloneCategory.technicalAttributeTemplateItems.splice(newIndex, 0, targetRec);
        let count = 1;
        cloneCategory.technicalAttributeTemplateItems.forEach( rec => {
            rec.sequence = count;
            count++;
        });
        this.dispatchChangeEvent(Object.assign({}, cloneCategory));
    }
}