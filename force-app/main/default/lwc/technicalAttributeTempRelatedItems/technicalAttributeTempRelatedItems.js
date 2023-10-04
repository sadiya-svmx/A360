import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTechnicalAttributeTemplateCategories
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getTechnicalAttributeTemplateCategories';
import saveTechnicalAttributeTemplateCategories
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateCategories';
import saveTechnicalAttributeTemplateAssociations
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociations';
import getTechnicalAttributeTemplateDetails
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getTechnicalAttributeTemplateDetails';
import deleteTechnicalAttributeTemplate
    from '@salesforce/apex/TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplate';
import cloneTechnicalAttributes
    from '@salesforce/apex/TA_TechnicalAttribute_LS.cloneTechnicalAttributes';

import labelAttributeGroups from '@salesforce/label/c.Label_AttributeGroupsRequired';
import labelAddGroup from '@salesforce/label/c.Label_AddGroup';
import labelEditGroup from '@salesforce/label/c.Label_EditGroup';
import labelAddAttribute from '@salesforce/label/c.Label_AddAttribute';
import labelMatchValue from '@salesforce/label/c.Label_MatchValue';
import labelMatchValues from '@salesforce/label/c.Label_MatchValues';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelPrevious from '@salesforce/label/c.Button_Previous';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelNext from '@salesforce/label/c.Button_Next';
import labelFinish from '@salesforce/label/c.Button_Finish';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteGroup from '@salesforce/label/c.Button_DeleteGroup';
import labelAttributeGroupMsg from '@salesforce/label/c.Message_DeleteAttributeGroup';
import labelGroupCreatedUpdated from '@salesforce/label/c.Message_GroupCreatedUpdated';
import labelMatchValueCreatedUpdated from '@salesforce/label/c.Label_MatchValueCreatedUpdated';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelTemplateDeleteMessage from '@salesforce/label/c.Message_TemplateDeleteMessage';
import labelTemplateDeleteMessageSuccess
    from '@salesforce/label/c.Message_TemplateDeleteMessageSuccess';
import labelDeleteTechnicalAttributeTemplate
    from '@salesforce/label/c.Message_DeleteTechnicalAttributeTemplate';
import labelEmptyGroup from '@salesforce/label/c.Message_EmptyGroup';
import labelRemoveGroup from '@salesforce/label/c.Label_RemoveGroup';
import labelReorderWizards from '@salesforce/label/c.Label_ReorderWizards';
import labelGroupOrder from '@salesforce/label/c.Title_GroupOrder';
import labelCloneGroup from '@salesforce/label/c.Button_CloneGroup';

import {
    parseErrorMessage,
    sortObjectArray,
    verifyApiResponse,
    deepCopy,
    isEmptyString,
    guid
} from 'c/utils';

const i18n = {
    attributeGroups: labelAttributeGroups,
    addGroup: labelAddGroup,
    editGroup: labelEditGroup,
    addAttribute: labelAddAttribute,
    delete: labelDelete,
    previous: labelPrevious,
    cancel: labelCancel,
    next: labelNext,
    finish: labelFinish,
    confirm: labelConfirm,
    deleteGroup: labelDeleteGroup,
    attributeGroupMsg: labelAttributeGroupMsg,
    matchValue: labelMatchValue,
    matchValues: labelMatchValues,
    groupCreatedUpdated: labelGroupCreatedUpdated,
    matchValueCreatedUpdated: labelMatchValueCreatedUpdated,
    save: labelSave,
    loading: labelLoading,
    templateDeleteMessage: labelTemplateDeleteMessage,
    deleteTechnicalAttributeTemplate: labelDeleteTechnicalAttributeTemplate,
    templateDeleteMessageSuccess: labelTemplateDeleteMessageSuccess,
    emptyGroup: labelEmptyGroup,
    removeGroup: labelRemoveGroup,
    reorderGroups: labelReorderWizards,
    groupOrder: labelGroupOrder,
    cloneGroup: labelCloneGroup
}

export default class TechnicalAttributeTempRelatedItems extends NavigationMixin (LightningElement) {

    @api recordId;
    @api viewUpdateMode;
    @api actionType;

    @track categoryData = [];
    @track apiInProgress = false;
    @track error;
    @track matchValueList = [];
    @track matchValueRecords = [];

    cloneAction;
    newCategoryConfigOpen;
    existingCategoryConfigOpen;
    techAttrDialogOpen;
    booleanTrue = true;
    showAttributeGroupSection = false;
    showMatchValueSection = false;
    categoryInfoChanged = false;
    deleteTemplateDialog = false;
    templateDeveloperName;
    categoryAdded = false;
    newCategoryDeveloperName = null;
    reorderGroupOpen;

    @wire(getTechnicalAttributeTemplateDetails, { templateId: '$recordId' })
    wiredTemplate ({ data }) {
        if (data) {
            this.templateDeveloperName = data.data.developerName;
        }
    }

    connectedCallback () {
        this.cloneAction = this.actionType;
        this.getTemplateCategories();
        this.showAttributeGroupSection = true;

    }

    renderedCallback () {

        if ( this.categoryAdded ) {
            const changedDiv =
                this.getCategoryElementByDeveloperName(this.newCategoryDeveloperName);

            changedDiv.scrollIntoView({
                behavior: "smooth",
                block: "center",
                inline: "nearest" });

            this.categoryAdded = false;
        }
    }

    getTemplateCategories () {
        this.apiInProgress = true;
        this.categoryData = [];
        getTechnicalAttributeTemplateCategories({ templateId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.error = null;
                this.categoryData = JSON.parse(JSON.stringify(result.data));
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    get i18n () {
        return i18n;
    }

    get emptyGroup () {
        if (this.categoryData.length > 0) {
            return false;
        }

        return true;
    }

    get disableFinishBtn () {
        return !(this.matchValueList.length > 0)
    }

    get categories () {
        if (!this.categoryData || this.categoryData.length === 0) {
            return null;
        }

        return sortObjectArray(
            this.categoryData,
            'sequence',
            'asc'
        );
    }

    get showFooterSection () {
        if ( this.categoryInfoChanged || !this.viewUpdateMode ) {
            return true;
        }
        return false;
    }

    get viewUpdate () {
        return this.viewUpdateMode;
    }

    handleAddCategory () {
        const configDialog = this.template.querySelector('.categoryConfig');

        configDialog.sequence = this.nextCategorySequenceNumber;

        this.newCategoryConfigOpen = true;
    }

    handleEditCategory (event) {
        const configDialog = this.template.querySelector(
            '.existingCategoryConfig'
        );
        const targetdeveloperName = event.currentTarget.getAttribute('data-developer');
        configDialog.categoryRecord = this.getCategoryByDeveloperName(
            targetdeveloperName
        );
        configDialog.headerLabel = i18n.editGroup;

        this.existingCategoryConfigOpen = true;
    }

    handleAddAttribute (event) {
        const techAttrDialog = this.template.querySelector(
            '.technicalAttributeDialog'
        );
        const targetdeveloperName = event.currentTarget.getAttribute('data-developer');
        techAttrDialog.categoryRecord = this.getCategoryByDeveloperName(
            targetdeveloperName
        );

        techAttrDialog.templateRecordId = this.recordId;
        techAttrDialog.templateDeveloperName = this.templateDeveloperName;
        techAttrDialog.fetchRecords();
        this.techAttrDialogOpen = true;
    }

    getCategoryIndexByDeveloperName (developerName) {
        return this.categoryData.findIndex(
            category => category.developerName === developerName
        );
    }

    getCategoryByDeveloperName (developerName) {
        const dataIndex = this.getCategoryIndexByDeveloperName(developerName);

        if (dataIndex > -1) {
            return this.categoryData[dataIndex];
        }

        return null;
    }

    handleNewCategoryConfigChanged (event) {
        const newCategory = event.detail.value;

        this.categoryData.push(Object.assign({}, newCategory));

        this.categoryInfoChanged = true;

        this.categoryAdded = true;

        this.newCategoryDeveloperName = newCategory.developerName;

        this.handleNewCategoryConfigClosed();

    }

    handleCategoryConfigChanged (event) {
        const categoryRec = event.detail.value;

        const dataIndex = this.getCategoryIndexByDeveloperName(
            categoryRec.developerName
        );

        this.categoryData.splice(dataIndex, 1, categoryRec);

        this.categoryInfoChanged = true;

        this.handleCategoryConfigClosed();

    }

    getCategoryElementByDeveloperName (developerName) {
        return this.template.querySelector(`[data-id='${developerName}']`);
    }

    handleNewCategoryConfigClosed () {
        this.newCategoryConfigOpen = false;
    }

    handleCategoryConfigClosed () {
        this.existingCategoryConfigOpen = false;
        this.techAttrDialogOpen = false;
    }

    confirmDeleteGroup (event) {
        const targetdeveloperName = event.currentTarget.getAttribute('data-developer');
        const dataIndex = this.getCategoryIndexByDeveloperName(
            targetdeveloperName
        );

        this.categoryData.splice(dataIndex, 1);
        this.categoryInfoChanged = true;
    }

    handleTemplateDeleteCancelModal () {
        this.deleteTemplateDialog = false;
    }

    handleNext () {
        this.newCategoryConfigOpen = false;
        this.existingCategoryConfigOpen = false;
        this.apiInProgress = true;
        this.error = null;
        this.validateGroupData();
        if ( !this.error ) {
            saveTechnicalAttributeTemplateCategories({
                requestJson: this.saveRequest ()
            })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }
                    this.getTemplateCategories();
                    if ( this.viewUpdateMode ) {
                        this.showMatchValueSection = false;
                    } else {
                        this.showMatchValueSection = true;
                        this.showAttributeGroupSection = false;
                    }
                    this.categoryInfoChanged = false;
                    const evt = new ShowToastEvent({
                        title: i18n.groupCreatedUpdated,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally( () => {
                    this.apiInProgress = false;
                });
        }
    }

    handleMatchValuePrevious () {
        this.showMatchValueSection =false;
        this.showAttributeGroupSection =true;
        this.matchValueList = [];
    }

    validateGroupData () {
        if ( this.categoryData ) {
            this.categoryData.forEach(row => {
                if ( row.technicalAttributeTemplateItems.length === 0 ) {
                    this.error = i18n.emptyGroup + ' - ' + row.name;
                    this.apiInProgress = false;
                }
            })
        }
    }

    handleAddAssociation (event) {
        this.matchValueList = JSON.parse(JSON.stringify(event.detail.associations));
    }

    handleRemoveAssociation (event) {
        this.matchValueList = JSON.parse(JSON.stringify(event.detail.associations));
    }

    handleCancel () {
        if ( this.viewUpdateMode ) {
            this.categoryInfoChanged = false;
            this.getTemplateCategories();
        } else {
            this.deleteTemplateDialog = true;
        }
    }

    confirmDeleteTemplate () {
        this.deleteTemplateRecord();
    }

    deleteTemplateRecord () {
        this.apiInProgress = true;
        deleteTechnicalAttributeTemplate({ templateId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const evt = new ShowToastEvent({
                    title: i18n.templateDeleteMessageSuccess,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.error = null;
                this.redirectToTemplateList();
                this.deleteTemplateDialog = false;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    handleBack () {

    }

    handlePrevious () {
        this.dispatchEvent(
            new CustomEvent('showtemplatesection')
        );
    }

    handleCancelMatchValue () {
        this.deleteTemplateDialog = true;
    }

    handleFinish () {
        const associationRecords = this.prepareAssociationsRequestJSON(this.matchValueList);
        const recordToSave = {
            templateAssociations: associationRecords
        }
        this.apiInProgress = true;
        saveTechnicalAttributeTemplateAssociations({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const evt = new ShowToastEvent({
                    title: i18n.matchValueCreatedUpdated,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.redirectToTemplateList();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    redirectToTemplateList () {
        const pageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SVMXA360__SM_TA_Template__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        };

        this[NavigationMixin.GenerateUrl](pageRef)
            .then(url => { window.open( url, '_self' ); });
    }

    prepareAssociationsRequestJSON (records) {
        const associations = [];
        if (records?.length > 0) {
            records.forEach(record => {
                const requestJson = {};
                const fieldValueMap = {};
                if ( !isEmptyString (record.Id)) {
                    delete record.SVMXA360__TemplateId__c;
                }
                Object.keys(record).forEach(field => {
                    const fieldName = field.toLowerCase();
                    if (fieldName === 'id' || fieldName.endsWith("__c")) {
                        fieldValueMap[field] = !isEmptyString(record[field]) ?
                            record[field].toString() : '';
                    }
                });
                requestJson.customFieldValueMap = fieldValueMap;
                associations.push(requestJson);
            });
        }
        return associations;
    }

    saveRequest () {
        const request = {
            techAttrTemplateCategories: this.categoryData,
            templateId: this.recordId
        }
        return JSON.stringify(request);
    }

    get nextCategorySequenceNumber () {
        const currentTopSequence = this.categoryData.reduce(
            (highestSequence, category) => {
                let topSequence = highestSequence;
                if (category.sequence > topSequence) {
                    topSequence = category.sequence;
                }
                return topSequence;
            },
            0
        );

        return currentTopSequence + 1;
    }

    handleReorderGroups () {
        this.reorderGroupOpen = true;
    }

    handleGroupOrderClosed () {
        this.reorderGroupOpen = false;
    }

    get groupOrderOptions () {
        if (this.categories && this.categories.length > 0) {
            const options = this.categories.map(category => {
                return {
                    label: category.name,
                    value: category.developerName
                };
            });
            return options;
        }

        return [];
    }

    handleGroupOrderChange (event) {
        const orderedGroupValues = event.detail.value;

        const orderedCategories = [];

        for (let i = 0; i < orderedGroupValues.length; i++) {
            const group = this.getCategoryByDeveloperName(
                orderedGroupValues[i]
            );

            if (group) {
                group.sequence = i + 1;
                orderedCategories.push(group);
            }

        }

        if ( orderedCategories && orderedCategories.length > 0 ) {
            this.categoryData = deepCopy(orderedCategories);
        }

        this.categoryInfoChanged = true;

        this.handleGroupOrderClosed();
    }

    handleCloneGroup (event) {
        const targetdeveloperName = event.currentTarget.getAttribute('data-developer');
        const categoryRec = this.getCategoryByDeveloperName(
            targetdeveloperName
        );

        const cloneCategoryRec = deepCopy(categoryRec);
        let devName = categoryRec.developerName + '_clone';
        let truncDevName = devName.slice(0,45);
        let uniqueId = guid();
        let truncUniqueId = uniqueId.substring(0,34);
        cloneCategoryRec.developerName = truncDevName + '-' + truncUniqueId;
        cloneCategoryRec.id = null;
        cloneCategoryRec.name = categoryRec.name + ' clone';
        cloneCategoryRec.sequence = this.nextCategorySequenceNumber;

        let templateItems = [];
        templateItems = cloneCategoryRec?.technicalAttributeTemplateItems;
        let count = 0;

        if ( templateItems.length > 0 ) {
            templateItems.forEach(row =>{
                devName = 'clone_' + row.developerName;
                truncDevName = devName.slice(0,45);
                uniqueId = guid();
                truncUniqueId = uniqueId.substring(0,34);
                row.developerName = truncDevName + '-' + uniqueId;
                row.id = null;
                count = count + 1;
            })
        }

        if ( count === templateItems.length ) {
            this.cloneAttributeRecords( cloneCategoryRec );
        }

    }

    cloneAttributeRecords (cloneCategoryRec) {
        this.apiInProgress = true;
        cloneTechnicalAttributes({ jsonRequest: JSON.stringify(cloneCategoryRec) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.error = null;
                const configDialog = this.template.querySelector('.categoryConfig');
                configDialog.categoryRecord = result.data;
                configDialog.headerLabel = i18n.cloneGroup;
                this.newCategoryConfigOpen = true;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }
}