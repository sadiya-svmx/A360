import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
    isEmptyString,
    normalizeBoolean,
    PAGE_ACTION_TYPES,
    parseErrorMessage,
    verifyApiResponse
} from 'c/utils';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import { getFieldDefinitionsForEntity } from 'c/metadataService';

import labelOK from '@salesforce/label/c.Button_OK';
import labelEditExpression from '@salesforce/label/c.Button_EditExpression';
import labelExpressionDetails from '@salesforce/label/c.Label_ExpressionDetails';

const i18n = {
    ok: labelOK,
    editExpression: labelEditExpression,
    title: labelExpressionDetails
};

const EXPRESSION_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__expressionDetail'
    }
};

export default class WizardExpressionModal extends NavigationMixin(LightningElement) {
    @track _modalOpen = false;
    @track error;
    @track expressionRecord;
    @track expressionEntityDefinition;

    _expressionId;
    expressionEditable = false;

    /**
     * The record id for the expression to display in the modal.
     * @type {string}
     */
    @api
    get expressionId () {
        return this._expressionId;
    }

    set expressionId (value) {
        this._expressionId = value;

        if (this._expressionId !== null && this._expressionId !== undefined) {
            this.getExpressionDetails();
        }
    }

    /**
     * If present, displays the dialog
     * @type {boolean}
     * @default false
     */
    @api
    get modalOpen () {
        return this._modalOpen;
    }
    set modalOpen (newValue) {
        this._modalOpen = normalizeBoolean(newValue);
    }

    /**
     * Title for the modal dialog
     * @type {string}
     * @required
     */
    @api title = i18n.title;

    get i18n () {
        return i18n;
    }

    get expressionName () {
        return this.expressionRecord ? this.expressionRecord.name : '';
    }

    get expressionDescription () {
        return this.expressionRecord ? this.expressionRecord.description : '';
    }

    get expressionDeveloperName () {
        return this.expressionRecord ? this.expressionRecord.developerName : '';
    }

    dispatchModalClosedEvent () {
        this.dispatchEvent(
            new CustomEvent('expressionmodalclosed')
        );
    }

    getExpressionDetails () {
        getExpressionWithDetails({ expressionId: this._expressionId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.expressionRecord = result.data;

                this.getObjectFields(result.data.objectAPIName).then(
                    entityWithFields => {
                        this.expressionEntityDefinition = entityWithFields;
                    }
                );
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    /**
     * Gets the field definitions for the supplied Object API Name
     * @param {String} objectApiName - API Name of the object
     */
    async getObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (error) {
            this.error = parseErrorMessage(error);
        }

        return result;
    }

    handleCancelModal () {
        this.dispatchModalClosedEvent();
    }

    handleEditExpressionClick () {
        const navState = {
            c__actionName: PAGE_ACTION_TYPES.VIEW,
            c__recordId: this._expressionId
        };

        const newExpressionView = Object.assign({}, EXPRESSION_DETAIL_VIEW, { state: navState });
        this[NavigationMixin.GenerateUrl](newExpressionView).then(url => {
            window.open(url, '_blank');
        });
    }
}