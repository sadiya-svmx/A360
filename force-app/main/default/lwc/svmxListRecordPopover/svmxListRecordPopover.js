import {
    LightningElement,
    api,
    track } from 'lwc';
import {
    classListMutation,
    debounce,
    requestAnimationFrameAsPromise } from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';

import svmxRecordPopoverCss from '@salesforce/resourceUrl/svmxRecordPopoverCss';
import labelCloseAltText from '@salesforce/label/c.AltText_Close';
import labelLocation from '@salesforce/label/c.Label_Location';
import labelSubject from '@salesforce/label/c.Label_Subject';
import labelAssignedTo from '@salesforce/label/c.Label_AssignedTo';
import labelNoSubject from '@salesforce/label/c.Label_NoSubject';
import labelStart from '@salesforce/label/c.Label_Start';
import labelEnd from '@salesforce/label/c.Label_End';
import labelName from '@salesforce/label/c.Label_Name';
import labelDueDate from '@salesforce/label/c.Label_DueDate';
import labelPriority from '@salesforce/label/c.Label_Priority';
import labelRelatedTo from '@salesforce/label/c.Label_RelatedTo';

const i18n = {
    closeAltText: labelCloseAltText,
    subject: labelSubject,
    assignedTo: labelAssignedTo,
    noSubject: labelNoSubject,
    location: labelLocation,
    start: labelStart,
    end: labelEnd,
    name: labelName,
    dueDate: labelDueDate,
    priority: labelPriority,
    relatedTo: labelRelatedTo
};

const closeTooltip = (that) =>  {
    that.isMouseOver = false;
    that.objrecordId = null;
    that.objRecord = null;
    that.objectApiName = null;
    that.showRecordPreview = false;
    if (that.parentEl) {
        that.parentEl.style.zIndex = that.parentZIndex;
    }
    const tooltipDIV = that.template.querySelector('.svmx-recordPopover_tooltip');

    if (tooltipDIV) {
        if (that.scrollyElement) {
            that.scrollyElement.removeEventListener('scroll', that.scrollHandler);
        }
        if (that.scrollElement) {
            that.scrollElement.removeEventListener('scroll', that.scrollHandler);
        }
        if (that.scrollablelement) {
            that.scrollableElement.removeEventListener('scroll', that.scrollHandler);
        }
        window.removeEventListener('scroll', that.scrollHandler);
        classListMutation(tooltipDIV.classList, {
            'slds-transition-hide': !that.isMouseOver,
            'slds-transition-show': that.isMouseOver
        });
        that.dispatchEvent(
            new CustomEvent('close', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: { close: true },
            })
        );
    }
}

export default class SvmxListRecordPopover extends LightningElement {

    @track objrecordId;
    @track objectApiName;
    @track recordId;
    @track isMouseOver;
    @track showRecordPreview ;
    @track objRecord;
    @track error;
    @track groupEl;
    @track canvasEl;
    @track parentEl;
    @track showEventPreview;
    @track showTaskPreview;
    @track actions;

    @api numberOfCols = 2;
    @api recordIconName = '';
    @track recordList =[];


    renderedCallback () {
        if (!this.init && !window.svmxPopoverStyleLoaded) {
            this.loadStylePromise = Promise.all([
                loadStyle(this, svmxRecordPopoverCss)
            ]).then(() => {
                this.init = true;
                window.svmxPopoverStyleLoaded = true;
            })
                .catch(error => {
                    this.init = true;
                    console.error('static resource loadStylePromise error', error);
                });
        }
    }

    disconnectedCallback () {
        clearTimeout(this.loadStylePromise);
    }

    @api
    showListPopover (
        recordList,
        element,
        containingElement) {
        this.recordList = recordList;
        this.scrollHandler = () => { closeTooltip(this); };
        window.addEventListener('scroll', this.scrollHandler);
        this.scrollyElement = element?.closest('.slds-scrollable_y');
        if (this.scrollyElement) {
            this.scrollyElement.addEventListener('scroll', this.scrollHandler);
        }
        this.scrollElement = element?.closest('.slds-scrollable');
        if (this.scrollElement) {
            this.scrollElement.addEventListener('scroll', this.scrollHandler);
        }
        this.scrollableElement = element?.closest('.slds-scrollable_x');
        if (this.scrollablelement) {
            this.scrollableElement.addEventListener('scroll', this.scrollHandler);
        }
        this.groupEl = element;
        this.canvasEl = containingElement;
        window.clearTimeout(this.mouseOverTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.mouseOverTimeout = setTimeout(() => this.openTooltipWithTimer(), 100);
    }

    openTooltipWithTimer () {
        requestAnimationFrameAsPromise().then(() => {
            this.isMouseOver = true;
            this.showRecordPreview = true;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => this.handleRecordFormLoad(), 200);
        });
    }

    @api
    hideListPopover () {
        const that = this;
        window.clearTimeout(that.mouseOutTimeout);
        window.clearTimeout(that.mouseOverTimeout);
        that.closeTooltipWithTimer();
    }

    closeTooltipWithTimer () {
        const that = this;
        window.clearTimeout(that.mouseOutTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        that.mouseOutTimeout = setTimeout(() => closeTooltip(that), 100);
    }

    get i18n () {
        return i18n;
    }

    positionTooltip (groupEl, tooltipEl) {
        let canvasRect;
        if (this.canvasEl) {
            canvasRect = this.canvasEl.getBoundingClientRect();
        }
        const groupRect = groupEl.getBoundingClientRect();
        const tooltipRect = tooltipEl.getBoundingClientRect();

        const potentialTooltipRect = {
            width: tooltipRect.width,
            height: tooltipRect.height,
            top: groupRect.top,
            right: groupRect.x + tooltipRect.width,
            bottom: groupRect.y + tooltipRect.height,
            left: groupRect.left,
            x: groupRect.left,
            y: groupRect.top,
        };
        const newPosition = {
            top: groupRect.top + 28,
            left: groupRect.left + 15
        };
        let nubbinStyle;
        if (this.canvasEl) {
            const iconWidth = 34;
            let nubbinHorizontalType = 'left';
            let nubbinVerticalType = 'top';

            const tooltipOverFlow = this.detectOverflow(potentialTooltipRect, canvasRect);
            if (tooltipOverFlow.top > 0) {
                // move tooltip to the bottom vertically
                newPosition.top = this.canvasEl.top;
            }
            if (tooltipOverFlow.bottom > 0) {
                // move tooltip to the top vertically
                newPosition.top = groupRect.top - tooltipRect.height - 8;
                nubbinVerticalType = 'bottom';
            }
            if (tooltipOverFlow.left > 0) {
                // move tooltip to the right horizontally
                newPosition.left = canvasRect.left;
            }
            if (tooltipOverFlow.right > 0) {
                // move tooltip to the left horizontally
                nubbinHorizontalType = 'right';

                newPosition.left = groupRect.left+ iconWidth  - tooltipRect.width;
            }

            nubbinStyle = nubbinVerticalType +
    (nubbinHorizontalType ? '-' + nubbinHorizontalType : '');
        }

        let toolTipStyle = '';
        Object.keys(newPosition).forEach((key) => {
            toolTipStyle += key.toString() + ':' + newPosition[key].toString() + 'px;';
        });
        tooltipEl.setAttribute('style', toolTipStyle);

        classListMutation(tooltipEl.classList, {
            'slds-nubbin_top': nubbinStyle === 'top',
            'slds-nubbin_top-left': nubbinStyle === 'top-left',
            'slds-nubbin_top-right': nubbinStyle === 'top-right',
            'slds-nubbin_bottom-left': nubbinStyle === 'bottom-left',
            'slds-nubbin_bottom-right': nubbinStyle === 'bottom-right',
            'slds-nubbin_left': nubbinStyle === 'left',
            'slds-nubbin_right': nubbinStyle === 'right'
        });
    }

    detectOverflow (referenceRect, boundaryRect) {
        const overflowOffsets = {
            top: boundaryRect.top - referenceRect.top,
            bottom: referenceRect.bottom - boundaryRect.bottom,
            left: boundaryRect.left - referenceRect.left ,
            right: referenceRect.right - boundaryRect.right,
        };
        return overflowOffsets;
    }

    handleRecordFormLoad () {
        const tooltipRect = this
            .template
            .querySelector('.svmx-recordPopover_record-preview-container')
            .getBoundingClientRect();
            if (tooltipRect.height > 0) {
                this.positionRecordPreview();
            }
    }

    positionRecordPreview () {
        const svgGroup = this.groupEl;
        const tooltipDIV = this.template.querySelector('.svmx-recordPopover_tooltip');
        if (svgGroup) {
            const displayTooltip = debounce(() => {
                this.positionTooltip( svgGroup, tooltipDIV);
                classListMutation(tooltipDIV.classList, {
                    'slds-transition-hide': !this.isMouseOver,
                    'slds-transition-show': this.isMouseOver
                });
            }, 100)

            displayTooltip();
        }
    }

    handleMouseOver (event) {
        const recordId = event.currentTarget.dataset.recordId;
        const objectApiName = event.currentTarget.dataset.objectApiName;
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (recordId,objectApiName,
                event.currentTarget, null, event.target.title);
    }

    handleMouseOut () {
        const popoverComponent = this.template.querySelector('c-svmx-record-popover');
        if (popoverComponent) {
            popoverComponent.hidePopover ();
        }
    }

    get tooltipEl () {
        return this.template.querySelector('c-svmx-record-popover');
    }

    handleCloseTooltip () {
        this.hideListPopover ();
    }

    handleScroll (event) {
        event.stopPropagation();
    }
}