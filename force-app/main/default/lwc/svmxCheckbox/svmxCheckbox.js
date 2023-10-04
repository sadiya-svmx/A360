import { LightningElement, api } from 'lwc';

export default class SvmxCheckbox extends LightningElement {
    @api value;
    @api rowId;
    @api fieldName;
    @api disabled;

    handleChange (event) {
        // show the updated value on UI
        const { checked } = event.target;

        // notify change to the datatable
        const eventToDispatch = new CustomEvent('checkboxchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                rowId: this.rowId,
                value: checked,
                fieldName: this.fieldName
            }
        });
        this.dispatchEvent(eventToDispatch);
    }
}