import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import { handleMenuSelection } from 'c/utils';
import labelOpenSplitViewLabel from '@salesforce/label/c.AltText_SplitViewOpen';
import labelCloseSplitViewLabel from '@salesforce/label/c.AltText_SplitViewClose';
import adminLayoutResource from '@salesforce/resourceUrl/adminLayout';

const i18n = {
    openSplitView: labelOpenSplitViewLabel,
    closeSplitView: labelCloseSplitViewLabel
};

export default class AdminLayout extends NavigationMixin(LightningElement) {
    @api removeScroll;
    @api isAutoConfigRunning;
    @api cardLess = false;

    _expanded = true;
    mainContent = 'main-content slds-m-left_small';

    get computedAriaExpanded () {
        return (this._expanded) ? 'true' : 'false';
    }

    get computedSplitterClass () {
        let css = 'slds-split-view_container';

        css += (this._expanded) ? ' slds-is-open' : ' slds-is-closed';

        css += ' split-container';

        return css;
    }

    get computedSplitterButtonClass () {
        let css = 'splitter-button slds-split-view__toggle-button';

        css += (this._expanded) ? ' slds-is-open' : ' slds-is-closed';

        return css;
    }

    get mainContentCss () {
        this.mainContent = this.removeScroll ? this.mainContent + ' no-scroll' : this.mainContent;
        return this.cardLess ? this.mainContent : this.mainContent + ' slds-card'
    }

    get splitterButtonAltText () {
        return (this._expanded) ? i18n.closeSplitView : i18n.openSplitView;
    }

    renderedCallback () {
        this.loadStylePromise = Promise.all([
            loadStyle(this, adminLayoutResource)
        ])
            .then(() => {})
            .catch(error => {
                console.error('static resource loadStylePromise error', error);
            });
    }

    handleMenuSelection (event) {
        handleMenuSelection(event, this);
    }

    handleSplitterClick (event) {
        event.stopPropagation();

        this._expanded = !this._expanded;
    }
}