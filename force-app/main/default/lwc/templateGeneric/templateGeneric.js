import { LightningElement, api } from 'lwc';
import { AVAILABLE_ACTIONS_FLOW_FOOTER } from 'c/utils';
/**
 * Generic sObject aware that passes down the specified sObject map to base runtime component
 * must specifiy all public properties defined in *meta.xml file
 */
export default class TemplateGeneric extends LightningElement {
    // pagelayout to retrive
    @api developerName = '';

    /**
     * header input/output(read & modify) record collection/its always a single record
     * but for consistency, keeping it as []
     */
    @api headerRecordData = [];

    // child tab(s) output only modified record collection
    @api child1Modified = [];
    @api child2Modified = [];
    @api child3Modified = [];
    @api child4Modified = [];

    // child tab(s) output only create record collection
    @api child1New = [];
    @api child2New = [];
    @api child3New = [];
    @api child4New = [];

    // child tab(s) output only user selected record collection
    @api child1Selected = [];
    @api child2Selected = [];
    @api child3Selected = [];
    @api child4Selected = [];

    // child tab(s) output only delete record collection
    @api child1Deleted = [];
    @api child2Deleted = [];
    @api child3Deleted = [];
    @api child4Deleted = [];

    @api availableActions = [];

    /**
     * Map object to eliminate the sObject specific and retain the remembers insertion order
     * while dispatching modified record set on same property from base runtime
     */
    childRecordData = new Map();
    showPrevious = false;
    showNext = false;

    connectedCallback () {
        this.childRecordData.child1 = this.child1Modified;
        this.childRecordData.child2 = this.child2Modified;
        this.childRecordData.child3 = this.child3Modified;
        this.childRecordData.child4 = this.child4Modified;

        this.availableActions.forEach(action => {
            if (action === AVAILABLE_ACTIONS_FLOW_FOOTER.BACK) {
                this.showPrevious = true;
            } else if (action === AVAILABLE_ACTIONS_FLOW_FOOTER.NEXT) {
                this.showNext = true;
            }
        });
    }
}