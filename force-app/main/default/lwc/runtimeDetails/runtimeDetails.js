import { LightningElement, api, track } from 'lwc';

import {
    formatString,
    cellFormatterByType,
    isFlowContext,
    classSet,
    isNotUndefinedOrNull
} from 'c/utils';

import {
    mungeChildRecordData,
    mungeChildValidationResults
} from 'c/runtimeEngine';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { EngineElement }  from 'c/runtimeEngineProvider';

import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelAllowZeroLineError from '@salesforce/label/c.Message_AllowZeroLineError';
import labelAdd from '@salesforce/label/c.Button_Add';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelFilter from '@salesforce/label/c.Label_Search';
import labelItemsFound from '@salesforce/label/c.Label_FilterRecordsFound';
import labelRemoved from '@salesforce/label/c.Label_Removed';
import rowRequiredMultipleErrors
    from '@salesforce/label/c.Message_RuntimeRowRequiredMultipleErrors';
import rowRequiredSingleError from '@salesforce/label/c.Message_RuntimeRowRequiredSingleError';
import labelAddinCatalog from '@salesforce/label/c.Button_AddIn';
import labelAddnotinCatalog from '@salesforce/label/c.Button_AddNotIn';
import label_Catalog from '@salesforce/label/c.Label_Catalog';

const i18n = {
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    noResults: labelNoResults,
    loading: labelLoading,
    allowZeroLineError: labelAllowZeroLineError,
    add: labelAdd,
    edit: labelEdit,
    rowRequiredMultipleErrors,
    rowRequiredSingleError,
    filter: labelFilter,
    itemsFound: labelItemsFound,
    removed: labelRemoved,
    addInCatalog: labelAddinCatalog,
    addNotInCatalog: labelAddnotinCatalog,
    labelCatalog: label_Catalog,
};


export default class RuntimeDetails extends EngineElement(LightningElement) {
    @api childId;

    @track records = [];
    @track tab = {};
    @track extendedEdit = {};

    runtimeContext;

    formatFieldValue (element, value) {
        let formattedValue = value;
        if (element.type === 'xPicklist') {
            formattedValue = cellFormatterByType(element.typeAttributes)(value)
        } else if (element.type === 'xCheckbox') {
            formattedValue = isNotUndefinedOrNull(value) ? value.toString() : '';
        }  else if (element.type === 'date' && value) {
            formattedValue = value.includes('+0000') ?  value.replace('+0000', 'Z') : value;
        }
        return formattedValue;
    }

    groupDisplayElementByType (element) {
        const elementType = {};
        switch (element.type) {
            case 'date':
            case 'date-local':
                elementType.dateTimeType = true;
                break;
            case 'xLookup':
                elementType.lookupType = true;
                break;
            case 'currency':
            case 'number':
                elementType.numberType = true;
                break;
            case 'phone':
                elementType.phoneType = true;
                break;
            default:
                elementType.textType = true;
                break;
        }
        return elementType;
    }

    getTypeMetaObject (element) {
        return element.typeAttributes?.meta ? JSON.parse(element.typeAttributes.meta) : {};
    }

    getElementDisplayAttributes (element) {
        return {
            meta: this.getTypeMetaObject(element),
            typeAttributes: element.typeAttributes,
            ...this.groupDisplayElementByType(element),
        };
    }

    get displayRows () {
        const result = this.records.map(record => {
            const displayElements = [];
            const elements = this.tab.elements.filter(ele => ele.type !== 'action');
            for (let index = 0; index<elements.length && index<4; index++) {
                const element = elements[index];
                displayElements.push({
                    id: element.fieldName,
                    label: element.label,
                    value: this.formatFieldValue(element, record[element.fieldName]),
                    ...this.getElementDisplayAttributes(element),
                })
            }
            return  {
                key: record.Id,
                hasError: Object.keys(
                    (((this.validationErrors[this.childId] || {}).rows || {})[record.Id] || {}))
                    .length ? true : false,
                displayElements,
                ...(displayElements.length ? displayElements[0] : {}),
            };
        });
        return result;
    }

    reportValidity = () => {
        return this.hasFormError;
    }

    async handleAddLineItem () {
        const recordId  = await this.props.handleAddTemporaryChildLine(this.childId);
        if (recordId) {
            this.displayExtendedEdit(this.tab, { Id: recordId }, 'add');
        }
    }

    displayExtendedEdit (tab, record, action) {
        this.extendedEdit.showExtendedEdit = true;
        this.extendedEdit.rowIndex = record.Id;
        this.extendedEdit.tabIndex = tab.name;
        this.extendedEdit.title = `${action==='add'?i18n.add : i18n.edit} ${tab.title}`;
        this.extendedEdit.editRecord = !(action ==='add');
    }

    updateExtendedEdit (record, firstRecord, lastRecord) {
        this.extendedEdit = { ...this.extendedEdit };
        this.extendedEdit.rowIndex = record.Id;
        this.extendedEdit.firstRecord = firstRecord;
        this.extendedEdit.lastRecord = lastRecord;
    }

    handleRowSelect (event) {
        const recordId = event.currentTarget.getAttribute("data-key");
        this.props.editTemporaryChildLine(this.childId,recordId);
        this.displayExtendedEdit(this.tab, { Id: recordId }, 'edit');
        const curIndex = this.records.findIndex(record => record.Id === recordId);
        this.extendedEdit.firstRecord = curIndex === 0;
        this.extendedEdit.lastRecord = curIndex + 1 === this.records.length;
    }

    async applyMultiSelect (event) {
        event.preventDefault();
        const selectedIds = event.detail.map(selectedRecord => selectedRecord.value);
        await this.props.handleAddMultipleLines(
            this.tab.name,
            selectedIds,
            this.tab.multiAddSearchField
        );
    }

    handleExtendedEditCancel () {
        this.extendedEdit = {};
    }

    get hasCustomActions () {
        return this?.customActions?.length > 0;
    }

    get isFlowContext () {
        return isFlowContext(this.runtimeContext);
    }

    get fabContainerClass () {
        return classSet('svmx-fab_container')
            .add({ 'svmx-fab_container_flow': this.isFlowContext })
            .toString();
    }

    async handleRecordNavigation (counter) {
        const curIndex = this.records.findIndex(record => record.Id === this.extendedEdit.rowIndex);
        if (curIndex !== -1 &&
            (curIndex + counter) >= 0 &&
            (curIndex + counter) < this.records.length) {
            const goToIndex = curIndex + counter;
            await this.props.handleCommitTemporaryChildLine(
                this.extendedEdit.tabIndex,
                this.extendedEdit.rowIndex
            );
            const nextRecord = this.records[goToIndex];
            this.props.editTemporaryChildLine(this.childId,nextRecord.Id);
            this.updateExtendedEdit(nextRecord,
                goToIndex === 0,
                goToIndex + 1 === this.records.length
            );
        }
    }

    handleNext = async () => {
        await this.handleRecordNavigation(1);
    }

    handlePrevious = async () => {
        await this.handleRecordNavigation(-1);
    }

    handleClone = () => {
        this.props.handleCloneChildLine(this.childId, this.extendedEdit.rowIndex);
        this.handleExtendedEditCancel();
    }

    handleDelete = () => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: `${this.childId} ${i18n.removed}`,
                variant: 'info',
            })
        );

        this.props.deleteChildLines(this.childId,this.extendedEdit.rowIndex);
        this.handleExtendedEditCancel();
    }

    runtimeEngineUpdate (engineProps) {
        const tabs = engineProps.tabs;
        this.hasFormError = engineProps.hasError;
        this.runtimeContext = engineProps.runtimeContext;
        const childRecordData = mungeChildRecordData(
            engineProps.childValues,
            engineProps.childValuesSequence);

        const tabFilter = (tabs || []).filter(t => t.name === this.childId);
        if (tabFilter.length) {
            // Tab multi-add config
            const tab = tabFilter[0];
            tab.enableMultiAdd = !!tab.multiAddSearchField;
            tab.labelAddItem = `+ ${i18n.add} ${tab.title}`;

            tab.labelMultiAddItem = formatString(
                '+ ' + i18n.addInCatalog,
                tab.title
            );

            if (tab.enableMultiAdd) {
                tab.elements.forEach(column => {
                    if (column.fieldName === tab.multiAddSearchField) {
                        tab.multiAddConfig = JSON.parse(column?.typeAttributes?.meta || '{}');
                        tab.multiAddConfig.debugLabel = column?.typeAttributes?.label;
                    }
                });
            }
            this.tab = tab;

            // Tab child record data
            this.records = childRecordData[this.childId];
        }

        this.customActions = engineProps.buttons.filter(button => button.intents)
        this.validationErrors = mungeChildValidationResults(
            engineProps.childValidationResults, i18n
        );
    }
}