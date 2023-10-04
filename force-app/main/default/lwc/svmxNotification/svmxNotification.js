import { LightningElement,api,track } from 'lwc';
import {
    classListMutation,
    debounce } from 'c/utils';
import labelClose from '@salesforce/label/c.AltText_Close';

const i18n = {
    closeAltText: labelClose
};

export default class SvmxNotification extends LightningElement {
    @api notificationCount;
    @api notificationRecords;
    @track groupEl;
    @track canvasEl;
    @track parentEl;
    @track showNotifications = false;
    @api headerValue;
    @api tabOneHeader;
    @track handleEventFire = false;

    get i18n () {
        return i18n;
    }

    handlePositionNotificationPreview (event) {
        const element  = event.target;
        this.scrollHandler = () => { this.closePositionNotificationPreview(); };
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
        this.groupEl = event.target;
        const svgGroup = this.groupEl;
        const tooltipDIV = this.template.querySelector('.svmx-recordNotification_tooltip');
        if (svgGroup) {
            const displayTooltip = debounce(() => {
                this.positionTooltip( svgGroup, tooltipDIV);
            }, 100)
            displayTooltip();
            this.showNotifications = true;
            tooltipDIV.classList.add('slds-transition-show');
            tooltipDIV.classList.add('slds-popover');
            tooltipDIV.classList.add('slds-popover_panel');
            tooltipDIV.classList.add('slds-is-fixed');
            tooltipDIV.classList.remove('slds-hide');
            if (!this.handleEventFire) {
                // eslint-disable-next-line @lwc/lwc/no-async-operation, consistent-return  
                setTimeout(() => {
                    window.addEventListener('click', this._handler =
                    this.closePositionNotificationPreview.bind(this));
                }, 200);
                this.handleEventFire = true;
            }
        }
    }

    handleNotificationPopup (event) {
        event.stopPropagation();
    }

    closePositionNotificationPreview () {
        if (this.parentEl) {
            this.parentEl.style.zIndex = this.parentZIndex;
        }
        const tooltipDIV = this.template.querySelector('.svmx-recordNotification_tooltip');
        if (tooltipDIV) {
            if (this.scrollyElement) {
                this.scrollyElement.removeEventListener('scroll', this.scrollHandler);
            }
            if (this.scrollElement) {
                this.scrollElement.removeEventListener('scroll', this.scrollHandler);
            }
            if (this.scrollablelement) {
                this.scrollableElement.removeEventListener('scroll', this.scrollHandler);
            }
            window.removeEventListener('scroll', this.scrollHandler);
        }
        tooltipDIV.classList.remove('slds-transition-show');
        tooltipDIV.classList.remove('slds-popover');
        tooltipDIV.classList.remove('slds-popover_panel');
        tooltipDIV.classList.remove('slds-is-fixed');
        tooltipDIV.classList.add('slds-hide');
        this.handleEventFire = false;
        window.removeEventListener('click', this._handler);
    }

    positionTooltip (groupEl, tooltipEl) {
        const groupRect = groupEl.getBoundingClientRect();
        const tooltipRect = tooltipEl.getBoundingClientRect();
        this.parentEl = groupEl.closest('th');
        const vpWidth = window.innerWidth;
        let parentRect;

        if ( this.parentEl) {
            parentRect = this.parentEl.getBoundingClientRect();
            this.parentZIndex = this.parentEl.style.zIndex;
            this.parentEl.style.zIndex = 6000;
        } else {
            this.parentEl = groupEl.closest('td');
            parentRect =  this.parentEl?.getBoundingClientRect();
        }
        const newPosition = {
            top: groupRect.top + 28,
            left: groupRect.left + 15
        };
        let nubbinStyle;
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

        let toolTipStyle = 'border: 0.1rem solid #dadada;border-radius: 0.3rem;';
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

}