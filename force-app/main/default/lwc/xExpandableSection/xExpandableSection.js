import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import expandableSectionResource from '@salesforce/resourceUrl/xExpandableSection';

export default class xExpandableSection extends LightningElement {
    @api disabled = false;
    @api title;
    @api disableExpandable = false;
    @api noHeaderHighlight;
    @api isEmptyContent = false;
    @api isNested = false;
    @api sectionPadding = "slds-p-around_small";
    @api headerStyleOverride = '';
    @api showExpandedSectionPopover = false;
    @api sectionId;

    _isCollapsed = false;
    @api
    set isCollapsed (collapsed) {
        this._isCollapsed = collapsed;
    }
    get isCollapsed () {
        return this._isCollapsed;
    }

    get isExpanded () {
        return !this._isCollapsed;
    }

    get sectionClasses () {
        const cssClasses = ['slds-section'];
        if (!this._isCollapsed) {
            cssClasses.push('slds-is-open');
        }
        if (this.isCollapsed && this.isNested) {
            cssClasses.push('svmx-is-closed');
        }
        if (this.disableExpandable) {
            cssClasses.push('svmx-expandable-section_negative-margin');
        }
        if (this.noHeaderHighlight) {
            cssClasses.push('slds-m-top_none slds-m-bottom_none');
        }
        return cssClasses.join(' ');
    }

    loadStylePromise;
    renderedCallback () {
        this.loadStylePromise = Promise.all([
            loadStyle(this, expandableSectionResource)
        ])
            .then(() => {})
            .catch(error => {
                console.error('staticresource for expandableSection load error', error);
            });
    }

    disconnectedCallback () {
        clearTimeout(this.loadStylePromise);
    }

    handleExpand (event) {
        if (!this.disabled) {
            this._isCollapsed = !this._isCollapsed;
            // nested sections
            if (this.isNested) {
                const wrapperElement = event.target.closest('div.slds-section');
                wrapperElement.classList.toggle('svmx-is-closed')
            }
        }
    }

    showSectionPopover (event) {
        const targetId = event.currentTarget.getAttribute('data-sectionid');
        this.dispatchEvent(
            new CustomEvent('showsectionpopover', {
                detail: {
                    value: targetId,
                }
            })
        );
    }

    hideSectionPopover (event) {
        const targetId = event.currentTarget.getAttribute('data-sectionid');
        this.dispatchEvent(
            new CustomEvent('hidesectionpopover', {
                detail: {
                    value: targetId,
                }
            })
        );
    }

    get computeHeaderSectionClass () {
        return this.noHeaderHighlight
            // eslint-disable-next-line max-len
            ? "slds-button slds-button_reset slds-accordion__summary-action slds-p-vertical_none slds-m-vertical_none"
            : "slds-button slds-section__title-action";
    }

    get computeSectionClassName () {
        const cssClasses = ['slds-section__content', `${this.sectionPadding}`];
        if (this.disableExpandable) {
            cssClasses.push('slds-p-top_none');
        }
        return cssClasses.join(' ');
    }
}