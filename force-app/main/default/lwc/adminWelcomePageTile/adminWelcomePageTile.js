import { api, LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class AdminWelcomePageTile extends NavigationMixin(LightningElement) {
    @api iconName;
    @api title;
    @api description;
    @api buttonLabel;
    @api buttonUrl;

    handleclick () {
        const { buttonUrl } = this;
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: buttonUrl
            }
        };
        this[NavigationMixin.Navigate](config);
    }
}