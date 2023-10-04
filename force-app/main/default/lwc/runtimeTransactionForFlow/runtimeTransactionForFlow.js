import { LightningElement, api } from 'lwc';
import { getPageDataForLayout } from 'c/pagedataService';
import {
    parseErrorMessage,
    isNotUndefinedOrNull,
    transformChildRecordData,
    RUNTIME_CONTEXT,
    AVAILABLE_ACTIONS_FLOW_FOOTER,
} from 'c/utils';
import labelLoading from '@salesforce/label/c.AltText_Loading';

const i18n = {
    loading: labelLoading
};

export default class RuntimeTransactionForFlow extends LightningElement {
    // recordId and pagelayout to retrive
    @api recordId;
    @api developerName = '';

    // child tab(s) output only record collection
    @api child1Modified = [];
    @api child2Modified = [];
    @api child3Modified = [];
    @api child4Modified = [];

    // child tab(s) output only user selected record collection
    @api child1Selected = [];
    @api child2Selected = [];
    @api child3Selected = [];
    @api child4Selected = [];

    @api headerRecordData = [];
    @api availableActions = [];
    pageDataConfig = {};

    apiInProgress = false;
    childRecordData = new Map();
    error;
    showPrevious = false;
    showNext = false;
    context = RUNTIME_CONTEXT.TRANSACTION_FLOW;

    get i18n () {
        return i18n;
    }

    connectedCallback () {
        this.initializePageData();
        this.availableActions.forEach(action => {
            if (action === AVAILABLE_ACTIONS_FLOW_FOOTER.BACK) {
                this.showPrevious = true;
            } else if (action === AVAILABLE_ACTIONS_FLOW_FOOTER.NEXT) {
                this.showNext = true;
            }
        });
    }

    initializePageData () {
        this.apiInProgress = true;
        this.getPageData()
            .then(result => {
                if (isNotUndefinedOrNull(result)) {
                    const { data } = result;
                    const parsedData = JSON.parse(data);
                    const { headerRecord, pageDetails, config } = parsedData;
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
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
}