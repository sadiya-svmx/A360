import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldDefinitionsForEntity } from 'c/metadataService';
import title_toast_error from '@salesforce/label/c.Title_Toast_Error';
import labelSettings from '@salesforce/label/c.Label_Settings';
import { isEmptyString, verifyApiResponse } from 'c/utils';

const i18n = {
    settings: labelSettings,
    title_toast_error: title_toast_error
};
export default class expressionpreview extends NavigationMixin(
    LightningElement
) {
    _expressionRecId;
    expressionName;
    expressionDevName;
    expressionDesc;
    selectedRecord;
    selectedEntityDefinition;
    editMode;
    editModeType = 'read';

    @api editable;

    @api
    get expressionRecordId () {
        return this._expressionRecId;
    }

    set expressionRecordId (value) {
        this._expressionRecId = value;
        this.getExpressionDetails();
    }

    @api
    doManualFresh () {
        this.getExpressionDetails();
    }

    get i18n () {
        return i18n;
    }

    getExpressionDetails () {
        if (this._expressionRecId) {
            getExpressionWithDetails({ expressionId: this._expressionRecId })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: i18n.title_toast_error,
                                message: i18n.title_toast_error,
                                variant: 'error'
                            })
                        );
                        return;
                    }
                    this.selectedRecord = result.data;
                    this.expressionDevName = this.selectedRecord.developerName;
                    this.expressionName = this.selectedRecord.name;
                    this.expressionDesc = this.selectedRecord.description;
                    this.getObjectFields(result.data.objectAPIName).then(
                        entityWithFields => {
                            this.selectedEntityDefinition = entityWithFields;
                            this.editMode = false;
                        }
                    );
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: i18n.title_toast_error,
                            message: error,
                            variant: 'error'
                        })
                    );
                });
        }

    }

    handleOpenInNewWindow (event) {
        event.preventDefault();
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__component',
            attributes: {
                componentName: 'SVMXA360__expressionDetail'
            },
            state: {
                c__actionName: 'view',
                c__recordId: this._expressionRecId
            }
        }).then(url => {
            window.open(url, '_blank');
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
        } catch (err) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: i18n.title_toast_error,
                    message: err,
                    variant: 'error'
                })
            );
        }

        return result;
    }
}