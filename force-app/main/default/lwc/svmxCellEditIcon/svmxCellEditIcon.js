import { LightningElement, api } from 'lwc';
import labelEdit from '@salesforce/label/c.Button_Edit';

const i18n = {
    edit: labelEdit
};

export default class SvmxCellEditIcon extends LightningElement {
    @api disabled;

    get i18n () {
        return i18n;
    }
}