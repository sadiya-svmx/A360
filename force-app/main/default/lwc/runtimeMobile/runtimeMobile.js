import { LightningElement, track, api } from 'lwc';
import {
    mungeChildValidationResults,
} from 'c/runtimeEngine';


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
import rowRequiredMultipleErrors
    from '@salesforce/label/c.Message_RuntimeRowRequiredMultipleErrors';
import rowRequiredSingleError from '@salesforce/label/c.Message_RuntimeRowRequiredSingleError';

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
    itemsFound: labelItemsFound
};

export default class RuntimeMobile extends EngineElement(LightningElement) {

    @track _tabs = [];
    @track loading = true;
    @track _showChildOnly = false;
    @track _activeTab = '';

    get i18n () {
        return i18n;
    }

    get tabs () {
        return this._tabs;
    }

    set tabs (value) {
        const NUM_OF_TABS = value.length;
        const newTabs = [];
        if (!this._showChildOnly) {
            newTabs.push( {
                id: 'header',
                label: 'Overview',
                value: 'Header_Overview',
                showErrorIndicator: false,
                header: true,
            });
        }
        for (let index = 0; index < NUM_OF_TABS; ++index) {
            const errors = (this.validationErrors || {})[value[index].name] || {};
            const showErrorIndicator = !!Object.keys((errors.rows || {})).length;
            const tab = {
                id: value[index].id,
                label: value[index].title,
                value: value[index].name,
                showErrorIndicator,
                header: false,
            };
            newTabs.push(tab);
        }

        this._tabs = newTabs;

        return this._tabs;
    }

    @api
    reportHeaderValidity () {
        let headerResult;
        this.template.querySelectorAll('c-runtime-header').forEach(header => {
            headerResult = header.reportAllValidity();
        });

        return headerResult;
    }

    get classList () {
        return this._activeTab === 'Header_Overview' ? 'svmx-mobile-tab-set' : '';
    }

    handleActive (event) {
        this._activeTab = event.target.value;
    }

    runtimeEngineUpdate (engineProps) {
        this.validationErrors = mungeChildValidationResults(
            engineProps.childValidationResults, i18n
        );
        this._showChildOnly = engineProps.sections.length === 0;
        this.tabs = engineProps.tabs;
        this.engineId = engineProps.engineId;
        this.loading = engineProps.loadingStatus.LOADING_ENGINE_METADATA;
    }
}