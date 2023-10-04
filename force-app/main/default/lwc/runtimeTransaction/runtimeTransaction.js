import { LightningElement, api } from 'lwc';
import { getPageDataForLayout } from 'c/pagedataService';
import {
    parseErrorMessage,
    isNotUndefinedOrNull,
    transformChildRecordData,
    RUNTIME_CONTEXT
} from 'c/utils';
import labelLoading from '@salesforce/label/c.AltText_Loading';

const i18n = {
    loading: labelLoading
};

export default class RuntimeTransaction extends LightningElement {
    @api recordId;
    @api isInModal;
    @api title;
    @api iconName;
    @api recordPageDeveloperName;
    @api objectApiName;
    @api stepId;
    @api stepComplete;
    @api stepCompletionEnabled;
    apiInProgress = false;
    headerRecordData = [];
    pageDataConfig = {};
    childRecordData = {};
    error;
    _developerName;

    get i18n () {
        return i18n;
    }

    get context () {
        return this.recordPageDeveloperName
            ? RUNTIME_CONTEXT.TRANSACTION_RECORDPAGE
            : RUNTIME_CONTEXT.TRANSACTION;
    }

    @api
    get developerName () {
        return this._developerName || this.recordPageDeveloperName;
    }

    set developerName (value) {
        this._developerName = value;
    }

    connectedCallback () {
        if (this.developerName) {
            this.initializePageData();
        }
    }

    get isRecordPageDisplay () {
        return isNotUndefinedOrNull(this.recordPageDeveloperName);
    }

    initializePageData () {
        this.apiInProgress = true;
        this.getPageData()
            .then(result => {
                if (isNotUndefinedOrNull(result)) {
                    const { data } = result;
                    const parsedData = JSON.parse(data);
                    const { headerRecord, pageDetails, config } = parsedData;
                    this.headerRecordData = [headerRecord];
                    this.pageDataConfig = config;
                    this.childRecordData = transformChildRecordData(pageDetails);
                }
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    async getPageData () {
        let result;
        try {
            const resp = await getPageDataForLayout(this.developerName, this.recordId);
            if (resp) {
                result = resp;
            }
        } catch (error) {
            this.error = parseErrorMessage(error);
        }
        return result;
    }

    get hasError () {
        return isNotUndefinedOrNull(this.error);
    }
}