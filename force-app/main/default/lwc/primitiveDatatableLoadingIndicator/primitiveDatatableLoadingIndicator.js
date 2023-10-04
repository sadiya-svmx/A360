import labelLoading from '@salesforce/label/c.AltText_Loading';
import { LightningElement } from 'lwc';

const i18n = {
    loading: labelLoading,
};

export default class PrimitiveDatatableLoadingIndicator extends LightningElement {
    get i18n () {
        return i18n;
    }
}