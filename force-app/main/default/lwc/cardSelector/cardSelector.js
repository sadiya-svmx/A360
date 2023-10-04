import { LightningElement, api } from 'lwc';

export default class cardSelector extends LightningElement {
    @api steptypeslist;

    handleCheckBoxChange (event) {
        this.dispatchEvent(
            new CustomEvent('wizardstepselected', {
                detail: {
                    value: event.target.value,
                }
            })
        );
    }
}