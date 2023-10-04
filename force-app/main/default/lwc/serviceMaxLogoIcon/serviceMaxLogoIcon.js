import { LightningElement, api } from 'lwc';
import { ICON_NAMES } from 'c/utils';

export default class ServiceMaxLogoIcon extends LightningElement {
    @api titleText='';
    @api alternativeText='';
    @api iconSize='large';

    get iconName () {
        return ICON_NAMES.SVMXLOGO;
    }
}