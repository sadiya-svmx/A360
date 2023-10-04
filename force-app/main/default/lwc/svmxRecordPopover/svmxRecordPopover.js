import {
    LightningElement,
    api,
    track,
    wire } from 'lwc';
import {
    classListMutation,
    debounce,
    requestAnimationFrameAsPromise,
    isNotUndefinedOrNull,
    isEmptyString } from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

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

const sldsCategories =[
    'standard',
    'custom',
    'utility',
    'doctype',
    'action'
]

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

export default class SvmxRecordPopover extends LightningElement {

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

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfoAsset ({  data }) {
        if (data ) {
            if (isEmptyString(this.recordIconName)) {
                const iconurl = data?.themeInfo?.iconUrl;
                if (isNotUndefinedOrNull (iconurl)) {
                    const iconNames = iconurl.split('/');
                    const sldsnames = iconNames.pop().split('_');
                    sldsnames.pop();
                    const sldscategory = iconNames.pop();
                    if (sldsCategories.includes(sldscategory)) {
                        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                        this.recordIconName = `${sldscategory}:${sldsnames.join('_')}`;
                    } else {
                        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                        this.recordIconName = 'custom:custom12';
                    }
                } else {
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    this.recordIconName = 'custom:custom12';
                }
            }
        }
    }

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
    showPopover (
        recordId,
        objectApiName,
        element,
        containingElement,
        popoverTitle,
        mouseOverRecord,
        rowActions,
        screenX,
        screenY) {
        this.scrollHandler = () => { closeTooltip(this); };
        window.addEventListener('scroll', this.scrollHandler);
        this.popoverTitle = popoverTitle;
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
        this.actions = rowActions;
        this.mouseX = screenX;
        this.mouseY = screenY;
        window.clearTimeout(this.mouseOverTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.mouseOverTimeout = setTimeout(() => this.openTooltipWithTimer(
            objectApiName,
            recordId,
            mouseOverRecord), 300);
    }

    openTooltipWithTimer (
        objectApiName,
        recordId,
        mouseOverRecord
    ) {
        requestAnimationFrameAsPromise().then(() => {
            this.isMouseOver = true;
            this.showEventPreview = objectApiName.toUpperCase() === 'EVENT';
            this.showTaskPreview = objectApiName.toUpperCase() === 'TASK';
            if (recordId
                && (objectApiName
                && (this.showEventPreview
                || this.showTaskPreview))) {
                this.showRecordPreview = false;
                this.objRecord = mouseOverRecord?.record;
                this.positionRecordPreview();
            } else {
                this.recordId = recordId;
                this.objectApiName = objectApiName;
                this.showRecordPreview = true;
            }
        });
    }

    @api
    hidePopover () {
        const that = this;
        window.clearTimeout(that.mouseOutTimeout);
        window.clearTimeout(that.mouseOverTimeout);
        that.closeTooltipWithTimer();
    }

    closeTooltipWithTimer () {
        const that = this;
        window.clearTimeout(that.mouseOutTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        that.mouseOutTimeout = setTimeout(() => closeTooltip(that), 300);
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
        this.parentEl = groupEl.closest('th');
        const vpWidth = window.innerWidth;
        let parentRect;

        if ( this.parentEl) {
            parentRect = this.parentEl.getBoundingClientRect();
            this.parentZIndex = this.parentEl.style.zIndex;
            this.parentEl.style.zIndex = 9200;
        } else {
            this.parentEl = groupEl.closest('td');
            parentRect =  this.parentEl?.getBoundingClientRect();
        }
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
            if (this.mouseX && this.mouseX >0) {
                const overallWidth = canvasRect.x+canvasRect.width;
                const tooltipwidth = this.mouseX+tooltipRect.width;
                // eslint-disable-next-line max-len
                newPosition.left = this.mouseX-20;//subtract 20px to show nubin on mouse clicked co-ordinate
                //check if the tooltip is going out of timeline element
                if (overallWidth < tooltipwidth) {
                    nubbinHorizontalType = 'left';
                }
            }

            nubbinStyle = nubbinVerticalType +
    (nubbinHorizontalType ? '-' + nubbinHorizontalType : '');
        } else {
            newPosition.top = (groupRect.top-(tooltipRect.height/2))+10;
            // eslint-disable-next-line no-constant-condition
            if (newPosition.top < tooltipRect.height/2 && false) {
                nubbinStyle = 'bottom-left';
                newPosition.top = groupRect.top+(tooltipRect.height+10);
                if (parentRect && parentRect.width < groupRect.width ) {
                    newPosition.left = parentRect.left+(parentRect.width/2);
                } else {
                    newPosition.left = groupRect.left+(groupRect.width/2);
                }
            } else {
                let leftDiff = 0;
                if (parentRect) {
                    leftDiff = groupRect.left - parentRect.left;
                }
                let groupWidth = groupRect.width;
                if (leftDiff >0) {
                    groupWidth = groupRect.width+leftDiff;
                }
                if (parentRect && parentRect.width < groupWidth) {
                    newPosition.left = parentRect.left+(parentRect.width+10);
                } else {
                    newPosition.left = groupRect.left+(groupRect.width+10);
                }
                if (vpWidth && vpWidth <= (newPosition.left+tooltipRect.width)) {
                    newPosition.left =
    (parentRect?parentRect.left:groupRect.left)-tooltipRect.width-10;
                    nubbinStyle = 'right';
                } else {
                    nubbinStyle = 'left';
                }
            }
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

    handleRecordFormLoad (event) {
        if (event && event.target && event.target.recordId) {
            const tooltipRect
    = this
        .template
        .querySelector('.svmx-recordPopover_record-preview-container')
        .getBoundingClientRect();

            const recordId = event.target.recordId;

            if (tooltipRect.height > 0) {
                this.positionRecordPreview(recordId);
            }
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

    handleRecordFormError () {

    }

    get computedRecordUrl () {
        return `/${this.recordId}`;
    }

    get  fullDisplayName () {
        return this.popoverTitle
            ? this.popoverTitle
            : this.groupEl?.label;
    }

    handleTooltipMouseEnter () {
        window.clearTimeout(this.mouseOutTimeout);
    }

    handleTooltipMouseLeave () {
        closeTooltip(this);
    }

    handleCloseTooltip () {
        this.hidePopover ();
    }
}