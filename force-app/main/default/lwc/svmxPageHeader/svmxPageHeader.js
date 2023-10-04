import { LightningElement, api } from "lwc";

import {
    isImageFromStaticResource,
    isSafari,
} from 'c/utils';

export default class SvmxPageHeader extends LightningElement {
    @api isObjectHome = false;
    @api isRecordHome = false;
    @api isInModal = false;
    @api title;
    @api metaTitle;
    @api subTitle;
    @api iconName = 'standard:global_constant';
    @api iconTitle = '';
    @api iconSize = 'medium';

    hasActionSlot = false;

    get pageHeaderClasses () {
        const classes = ['slds-page-header'];
        if (this.isObjectHome) {
            classes.push('slds-page-header_object-home');
        }
        if (this.isRecordHome) {
            classes.push('slds-page-header_record-home');
        }
        return classes.join(' ');
    }

    get actionClasses () {
        const classes = ['slds-page-header__col-actions'];
        if (!this.hasActionSlot) {
            classes.push('slds-is-hidden');
        }
        return classes.join(' ');
    }

    handleActionSlotChange = (event) => {
        const slot = event.target;
        this.hasActionSlot = slot.assignedElements().length !== 0;
    }

    get isImageFromStaticResource () {
        return isImageFromStaticResource(this.iconName);
    }

    get pageHeaderControl () {
        if (this.hasActionSlot) {
            return this.template.querySelector('div.slds-page-header__control');
        }
        return null;
    }

    renderedCallback () {
        // Workaround for Safari repaint bug for action buttons
        if (isSafari && this.hasActionSlot) {
            const pageHeaderInitialDisplay = this.pageHeaderControl.style.display;
            this.pageHeaderControl.style.display = 'none';

            // Necessary to prevent browser from optimizing-out the previous style-change lines
            // eslint-disable-next-line no-unused-expressions
            this.pageHeaderControl.offsetHeight;
            this.pageHeaderControl.style.display = pageHeaderInitialDisplay;
        }
    }
}