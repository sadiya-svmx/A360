import { LightningElement, track, api } from 'lwc';
import { normalizeBoolean } from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';

const TARGET_SELF = '_self';

export default class SvmxFormattedUrl extends NavigationMixin(LightningElement)  {
    isTypeTransaction = false;
    @track _disabled = false;
    @track _target = TARGET_SELF;
    @track isPopoverVisible = false;
    @api showPopover ;
    @api objectApiName;
    @api isInConsole;
    @api rowActions;

    /**
     * Specifies where to open the link. Options include _blank, _parent, _self, and _top.
     * This value defaults to _self.
     * @type {string}
     *
     */
    @api
    get target () {
        return this._target || TARGET_SELF;
    }
    set target (value) {
        this._target = value;
    }

    /**
     * The text to display when the mouse hovers over the link.
     * A link doesn't display a tooltip unless a text value is provided.
     *
     * @type {string}
     *
     */
    @api tooltip;

    /**
     * The text to display in the link.
     * @type {string}
     *
     */
    @api label;
    @api type;

    /**
     * If present, the hyperlink is not shown and the label value is only displayed.
     * @type {boolean}
     * @default false
     */
    @api
    get disabled () {
        return this._disabled || false;
    }

    set disabled (value) {
        this._disabled = normalizeBoolean(value);
    }

    handleMouseOver (event) {
        if (this.showPopover) {
            this.isPopoverVisible = true;
            this.mouseOverEvent = event;
        }
    }


    handleMouseOut () {
        const popoverComponent = this.template.querySelector('c-svmx-record-popover');
        if (popoverComponent) {
            popoverComponent.hidePopover ();
        }
    }

    handlePopoverClose () {
        this.isPopoverVisible = false;
        this.showPopoverCalled = false;
    }

    handleClick (event) {
        event.preventDefault();
        event.stopPropagation();
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.target,
                actionName: 'view',
            },
        };
        if (this.isInConsole) {
            this[NavigationMixin.Navigate](pageRef);
        } else {
            this[NavigationMixin.GenerateUrl](pageRef)
                .then(url => {
                    window.open( url);
                });
        }
    }

    /**
     * The URL to format.
     * @type {string}
     *
     */
    @api value;

    transactionHandleClick () {
        window.history.pushState({}, '', this.value);
        window.location.reload();
    }

    renderedCallback () {
        if (this.isPopoverVisible && !this.showPopoverCalled) {
            this.template.querySelector('c-svmx-record-popover')
                .showPopover (this.target,this.objectApiName,
                    this.mouseOverEvent.target,null,null,null,this.rowActions);
            this.showPopoverCalled = true;
        }
        if (this.type === 'Transaction' && !this.isTypeTransaction) {
            this.isTypeTransaction = true;
        }
    }


}