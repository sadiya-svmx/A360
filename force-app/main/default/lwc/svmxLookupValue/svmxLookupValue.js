import { LightningElement, api } from 'lwc';

export default class SvmxLookup extends LightningElement {
    @api label;
    @api icon = '';
    @api isCell = false;
    @api editable = false;

    get hasIcon () {
        return this.icon !== '' && this.icon !== undefined;
    }

    get cellClassnames () {
        const classes = [
            'svmx-cell-edit',
            'slds-cell-edit',
            'slds-grid',
        ];
        return classes.join(' ');
    }

    handleClick () {
        this.dispatchEvent(
            new CustomEvent('editcell', {
                composed: true,
                bubbles: true,
            })
        );
    }
}