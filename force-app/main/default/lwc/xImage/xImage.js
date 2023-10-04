import { LightningElement, api } from 'lwc';

export default class XImage extends LightningElement {
    @api iconName;
    get isIconImageUrl () {
        return (
            this.iconName
            && this.iconName.includes('/')
        );
    }

    get isSldsIconImage () {
        return (
            this.iconName
            && !this.iconName.includes('/')
            && this.iconName.includes(':')
        );
    }
}