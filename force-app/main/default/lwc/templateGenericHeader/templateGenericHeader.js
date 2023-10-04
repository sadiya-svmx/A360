import { LightningElement, api } from 'lwc';
import { AVAILABLE_ACTIONS_FLOW_FOOTER } from 'c/utils';
/**
 * Generic sObject aware that passes down the specified sObject map to base runtime component
 * must specifiy all public properties defined in *meta.xml file
 */
export default class TemplateGenericHeader extends LightningElement {
    // pagelayout to retrive
    @api developerName = '';

    /**
     * header input/output(read & modify) record collection/its always a single record
     * but for consistency, keeping it as []
     */
    @api headerRecordData = [];
    @api availableActions = [];

    showPrevious = false;
    showNext = false;

    connectedCallback () {
        this.availableActions.forEach(action => {
            if (action === AVAILABLE_ACTIONS_FLOW_FOOTER.BACK) {
                this.showPrevious = true;
            } else if (action === AVAILABLE_ACTIONS_FLOW_FOOTER.NEXT) {
                this.showNext = true;
            }
        });
    }
}