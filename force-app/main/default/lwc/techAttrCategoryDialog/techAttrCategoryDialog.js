import { LightningElement, api, track } from 'lwc';

import labelCreateGroup from '@salesforce/label/c.Label_CreateGroup';
import labelName from '@salesforce/label/c.Label_Name';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelDuplicateGroup from '@salesforce/label/c.Message_DuplicateGroupFound';
import labelFieldRequired from '@salesforce/label/c.Message_FieldRequired';
import labelDuplicateDeveloper from '@salesforce/label/c.Error_Duplicate_Developer_Name';
import labelCloneGroup from '@salesforce/label/c.Button_CloneGroup';

import {
    deepCopy,
    normalizeDeveloperName,
    parseErrorMessage,
    isEmptyString
} from 'c/utils';

const i18n = {
    createGroup: labelCreateGroup,
    name: labelName,
    developerName: labelDeveloperName,
    description: labelDescription,
    cancel: labelCancel,
    save: labelSave,
    duplicateGroup: labelDuplicateGroup,
    fieldRequired: labelFieldRequired,
    duplicateDeveloper: labelDuplicateDeveloper,
    cloneGroup: labelCloneGroup
}

export default class TechAttrCategoryDialog extends LightningElement {

    @track _categoryRecord = this.initializeCategoryRecord();
    @track _modalOpen = false;
    @track error;
    @track headerName = i18n.createGroup;

    @api categories = [];
    @api templateDeveloperName = null;

    /**
    * If present, displays the step configuration dialog
    * @type {boolean}
    * @default false
    */
    @api
    get modalOpen () {
        return this._modalOpen;
    }
    set modalOpen (newValue) {
        this._modalOpen = newValue;
    }

    /**
    * This value represents how wizards are ordered when displayed among other wizards.
    * @type {number}
    */
    @api
    get sequence () {
        return this._categoryRecord ? this._categoryRecord.sequence : undefined;
    }

    set sequence (newValue) {
        if (this._categoryRecord) {
            this._categoryRecord.sequence = newValue;
        }
    }

    /**
     * This value represents a record from the SVMXA360__SM_TA_Category__c object.
     * @type {object}
     */
    @api
    get categoryRecord () {
        if (!this._categoryRecord) {
            this._categoryRecord = this.initializeCategoryRecord();
        }

        return this._categoryRecord;
    }
    set categoryRecord (newValue) {
        if (!newValue) {
            this._categoryRecord = null;
            return;
        }

        this._categoryRecord = deepCopy(newValue);
    }

    /**
     * This value represents a record from the SVMXA360__SM_TA_Category__c object.
     * @type {object}
     */
    @api
    get headerLabel () {
        return this.headerName;
    }
    set headerLabel (newValue) {
        if (!newValue) {
            this.headerName = null;
            return;
        }

        this.headerName = deepCopy(newValue);
    }

    get i18n () {
        return i18n;
    }

    get isNewRecord () {
        return !this._categoryRecord || isEmptyString(this._categoryRecord.id);
    }

    get developerNameEditable () {
        return this.isNewRecord;
    }

    get developerNameInput () {
        return this.template.querySelector('.svmx-template-category_devname');
    }

    handleTextInputChange (fieldName, value) {
        let newValue = value;
        if (newValue) {
            newValue = value.trim();
        }

        this._categoryRecord[fieldName] = newValue;
    }

    getCategoryIndexByName (inputName,categoryList) {
        return categoryList.findIndex(
            category => category.name.toLowerCase() === inputName.toLowerCase()
        );
    }

    getCategoryIndexBySequence (inputVal,categoryList) {
        return categoryList.findIndex(
            category => category.sequence === inputVal
        );
    }

    getCategoryIndexByDeveloperName (inputName,categoryList) {
        return categoryList.findIndex(
            category => category.developerName === inputName
        );
    }

    get disableSave () {
        if ( !this._categoryRecord.name || !this._categoryRecord.developerName || this.error ) {
            return true;
        }
        return false;
    }

    handleCategoryNameChanged (event) {
        let changeValue = true;
        this.error = null;
        const nameValue = event.target.value.trim();
        if (!this._categoryRecord.developerName && this.categories) {
            const nameIndex = this.getCategoryIndexByName(nameValue,this.categories);
            if ( nameIndex > -1 ) {
                this.error = i18n.duplicateGroup;
                changeValue = false;
            }
        } else if (this.categories) {
            const categoryCopyList = deepCopy(this.categories);
            const dataIndex =
                this.getCategoryIndexByDeveloperName(this._categoryRecord.developerName,
                    categoryCopyList);
            if (dataIndex > -1) {
                categoryCopyList.splice(dataIndex,1);
            }
            if ( categoryCopyList && categoryCopyList.length > 0 ) {
                const nameDataIndex =
                    this.getCategoryIndexByName(nameValue,categoryCopyList);
                if ( nameDataIndex > -1 ) {
                    this.error = i18n.duplicateGroup;
                    changeValue = false;
                }
            }
        }
        if (changeValue) {
            this.handleTextInputChange('name', event.target.value);
        }
    }

    handleCategoryNameBlur () {

        if ( this.isNewRecord && !this._categoryRecord.developerName
                && !isEmptyString(this._categoryRecord.name) ) {
            const maxLength = this.developerNameInput.maxLength;

            const developerName = this.templateDeveloperName + '_' + this._categoryRecord.name;

            this._categoryRecord.developerName = this.getNewDeveloperName(
                developerName,
                maxLength
            );

            this.developerNameInput.value = this._categoryRecord.developerName;
        }
    }

    handleDescriptionChanged (event) {
        this.handleTextInputChange('description', event.target.value);
    }

    handleDeveloperNameChanged (event) {
        this.error = null;
        this.handleTextInputChange('developerName', event.target.value);
    }

    handleSave () {
        try {
            this.error = null;
            if ( this.categories ) {
                if ( this.headerName === i18n.cloneGroup) {
                    const nameIndex = this.getCategoryIndexByName(this._categoryRecord.name,
                                                                this.categories);
                    if ( nameIndex > -1 ) {
                        this.error = i18n.duplicateGroup;
                    }
                }
                const categoryCopyList = deepCopy(this.categories);
                const seqIndex =
                    this.getCategoryIndexBySequence(this._categoryRecord.sequence,categoryCopyList);
                if (seqIndex > -1) {
                    categoryCopyList.splice(seqIndex,1);
                }
                if ( categoryCopyList && categoryCopyList.length > 0 ) {
                    const dupCategories =
                        this.getMatchingCategories(
                            categoryCopyList,
                            this._categoryRecord.developerName
                        );
                    if (dupCategories && dupCategories.length > 0) {
                        this.error =
                            i18n.duplicateDeveloper + ' - ' + dupCategories[0].name;
                    }
                }
            }
            if ( !this.error ) {
                this.dispatchChangeEvent(Object.assign({}, this._categoryRecord));
                this.clearState();
            }

        } catch (error) {
            this.error = parseErrorMessage(error);
        }
    }

    handleCancelModal () {
        this.dispatchModalClosedEvent();
        this.clearState();
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

    dispatchModalClosedEvent () {
        this.dispatchEvent(
            new CustomEvent('categoryconfigclosed')
        );
    }

    clearState () {
        this._categoryRecord = this.initializeCategoryRecord();
        this.error = null;
    }

    getNewDeveloperName (categoryName, maxLength) {
        let developerName = normalizeDeveloperName(categoryName, maxLength, '');

        const matchingCategories = this.getMatchingCategories(this.categories, developerName);

        if (matchingCategories && matchingCategories.length > 0) {
            const matchCount = matchingCategories.length + 1;

            const adjustedMaxLength =
                maxLength - matchCount.toString().length;

            developerName = developerName
                .substring(0, adjustedMaxLength)
                .concat(matchCount);
        }
        return developerName;
    }

    getMatchingCategories ( categoryList, developerName ) {
        const duplicateCategories = (categoryList && categoryList.length > 0) ?
            categoryList.filter(category =>
                category.developerName.startsWith(developerName)
            ) : [];
        return duplicateCategories;
    }

    initializeCategoryRecord () {
        return {
            id: null,
            description: null,
            developerName: null,
            name: null,
            sequence: null,
            technicalAttributeTemplateItems: []
        };
    }
}