import { LightningElement, api, track } from 'lwc';

import { guid, normalizeString, IS_MOBILE_DEVICE, IS_TABLET_DEVICE } from 'c/utils';

import labelSave from '@salesforce/label/c.Button_Save';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import messageRuntimeResolveErrors from '@salesforce/label/c.Message_RuntimeResolveErrors';
import altTextResolveError from '@salesforce/label/c.AltText_ResolveError';
import labelNextButton from '@salesforce/label/c.Button_Next';
import labelNextPrevious from '@salesforce/label/c.Button_Previous';
import labelMarkAsCompleteToolTip from '@salesforce/label/c.Message_RuntimeMarkAsCompleteToolTip';
import labelMarkAsComplete from '@salesforce/label/c.Message_RuntimeMarkAsComplete';

import svmxFormFooterTemplate from './svmxFormFooter.html';
import svmxFormFooterMobileTemplate from './svmxFormFooterMobile.html';
import svmxFormFooterMobileWithActionBarTemplate from './svmxFormFooterMobileWithActionBar.html';

const i18n = {
    save: labelSave,
    cancel: labelCancel,
    resolveErrors: messageRuntimeResolveErrors,
    errorAltText: altTextResolveError,
    next: labelNextButton,
    previous: labelNextPrevious,
    tooltip: labelMarkAsCompleteToolTip,
    markAsComplete: labelMarkAsComplete,
}

const ALIGNMENT_CENTER = 'center';
const ALIGNMENT_RIGHT = 'right';
const ALIGNMENT_LEFT = 'left';

const DEFAULT_ALIGNMENT = ALIGNMENT_CENTER;

export default class SvmxFormFooter extends LightningElement {
    @api isSticky = false;
    @api isFlowContext = false;
    @api isRecordPageDisplay = false;
    @api shouldSaveDisabled = false;
    @api isDocked = false;
    @api isInModal = false;
    @api title;
    @api subTitle;
    @api footerClass = '';

    @api isConfirmHidden = false;
    @api isConfirmDisabled = false;
    @api confirmLabel = i18n.save;
    @api confirmAriaHelp = i18n.save;

    @api cancelLabel = i18n.cancel;
    @api cancelAriaHelp = i18n.cancel;
    @api showPrevious = false;
    @api markAsComplete = false;
    @api showMarkAsComplete = false;

    @api withActionBar = false;

    _hasError = false;
    _showToolTip = false;
    @api
    get hasError () {
        return this._hasError;
    }

    set hasError (value) {
        if (value !== this._hasError) {
            this._hasError = value;

            // Initially display the error popover when the error icon is enabled
            this._showErrorPopover = value;
        }
    }

    @api errors = [];
    @api errorHeader = i18n.resolveErrors;
    @api errorAriaHelp = i18n.errorAltText;
    @track _showErrorPopover = false;

    // Specifies the content alignment: 'left', 'center', or 'right'
    _alignment = DEFAULT_ALIGNMENT;
    @api
    get alignment () {
        return this._alignment;
    }

    set alignment (value) {
        this._alignment = normalizeString(value, {
            toLowerCase: true,
            fallbackValue: DEFAULT_ALIGNMENT,
            validValues: [
                DEFAULT_ALIGNMENT,
                ALIGNMENT_LEFT,
                ALIGNMENT_RIGHT
            ]
        });
    }

    _hasSlot = false;

    _accessibilityId = guid();

    get i18n () {
        return i18n;
    }

    render () {
        if (IS_MOBILE_DEVICE) {
            if (this.withActionBar) {
                return svmxFormFooterMobileWithActionBarTemplate;
            }
            return svmxFormFooterMobileTemplate;
        }
        return svmxFormFooterTemplate;
    }

    handleConfirm () {
        this.dispatchEvent(new CustomEvent('confirm'));
    }

    handleCancel () {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleSave () {
        this.dispatchEvent(new CustomEvent('save'));
    }

    handleNext () {
        this.dispatchEvent(new CustomEvent('next'));
    }

    handlePrevious () {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleSlotChange () {
        this._hasSlot = true;
    }

    handleErrorIconClick () {
        this._showErrorPopover = !this._showErrorPopover;
    }

    handleErrorPopoverHide () {
        this._showErrorPopover = false;
    }

    handleMouseOver () {
        this._showToolTip = true;
    }

    handleMouseOut () {
        this._showToolTip = false;
    }

    handleStepCompleteChange (event) {
        const { checked } = event.target;

        this.dispatchEvent(
            new CustomEvent('stepcomplete', {
                detail: {
                    value: checked
                }
            })
        );
    }

    get getMarkAsComplete () {
        return this.markAsComplete === 'true' || this.markAsComplete === true;
    }

    get titleSize () {
        if (this.isFlowContext && this.showPrevious) {
            return IS_TABLET_DEVICE() ? "8" : "4";
        }
        return IS_TABLET_DEVICE() ? "10" : "8";
    }

    get saveButtonSize () {
        if (this.isFlowContext && this.showPrevious) {
            return IS_TABLET_DEVICE() ? "3" : "6";
        }
        return IS_TABLET_DEVICE() ? "1" : "2";
    }

    // Dynamic CSS
    get dockedFormFooterClassList () {
        const classes = ['svmx-footer'];

        if (this.isSticky) {
            classes.push('svmx-footer_sticky');
        } else if (this.isDocked) {
            classes.push('slds-docked-form-footer');
        } else if (this.isInModal) {
            classes.push('slds-modal__footer');
        } else {
            classes.push('svmx-footer_inline');
        }

        classes.push(`flex-align_${this._alignment}`);

        if (this.footerClass) {
            classes.push(this.footerClass);
        }

        return classes.join(' ');
    }

    get popoverClassList () {
        const buttons = this.querySelectorAll('lightning-button') || [];
        const classes = [
            'svmx-form-footer_error-popover',
            'slds-popover',
            'slds-popover_error',
        ];

        if (this.alignment === ALIGNMENT_RIGHT) {
            classes.push('slds-nubbin_bottom-right');
            if (buttons.length === 1)
                classes.push('svmx-popover-margin-right-small');
            else
                classes.push('svmx-popover-margin-right-medium');
        } else {
            classes.push('slds-nubbin_bottom-left');
        }

        return classes.join(' ');
    }

    // Accessibility Ids
    get ariaErrorPopoverBodyId () {
        return `footer-error-popover-body-${this._accessibilityId}`;
    }

    get ariaErrorPopoverHeadingId () {
        return `footer-error-popover-heading-${this._accessibilityId}`;
    }
}