import { LightningElement, api } from 'lwc';
import { normalizeString, copyToClipboard, IS_MOBILE_DEVICE } from 'c/utils';

import infoAlertTitle from '@salesforce/label/c.Title_AlertInfo';
import warningAlertTitle from '@salesforce/label/c.Title_AlertWarning';
import errorAlertTitle from '@salesforce/label/c.Title_AlertError';
import defaultAlertTitle from '@salesforce/label/c.Title_AlertDefault';

import warningModalTitle from '@salesforce/label/c.Title_ModalWarning';
import errorModalTitle from '@salesforce/label/c.Title_ModalError';
import defaultModalTitle from '@salesforce/label/c.Title_ModalDefault';
import labelErrorEncountered from '@salesforce/label/c.Message_ErrorEncountered';
import labelMoreInformation from '@salesforce/label/c.Label_MoreInformation';

import labelDetails from '@salesforce/label/c.Label_Details';
import labelOK from '@salesforce/label/c.Button_OK';
import labelCopyToClipboard from '@salesforce/label/c.Label_CopyToClipboard';
import altTextClose from '@salesforce/label/c.AltText_Close';
import errorCopyToClipboardUnsupported from '@salesforce/label/c.Error_CopyToClipboardUnsupported';
import alertTemplate from './alert.html';
import alertMobileTemplate from './alertMobile.html';

const i18n = {
    infoAlertTitle,
    warningAlertTitle,
    errorAlertTitle,
    defaultAlertTitle,

    warningModalTitle,
    errorModalTitle,
    defaultModalTitle,

    details: labelDetails,
    ok: labelOK,
    copyToClipboard: labelCopyToClipboard,
    copyToClipboardError: errorCopyToClipboardUnsupported,
    altTextClose: altTextClose,
    labelErrorEncountered,
    labelMoreInformation
};

const DEFAULT_VARIANT = 'info';

export default class Alert extends LightningElement {
    _headerLabel;

    @api errorMessage;
    @api set headerLabel (value) {
        this._headerLabel = value;
    }

    get headerLabel () {
        if (this._headerLabel) {
            return this._headerLabel;
        }

        return i18n[`${this.variant}AlertTitle`] ||
            i18n.defaultAlertTitle;
    }

    _detailsHeaderLabel;
    @api set detailsHeaderLabel (value) {
        this._detailsHeaderLabel = value;
    }

    get detailsHeaderLabel () {
        if (this._detailsHeaderLabel) {
            return this._detailsHeaderLabel;
        }

        return i18n[`${this.variant}ModalTitle`] ||
            i18n.defaultModalTitle;
    }

    _descriptionLabel;
    @api set descriptionLabel (value) {
        this._descriptionLabel = value;
    }

    get descriptionLabel () {
        return this._descriptionLabel;
    }

    get _hasDescription () {
        return !this._hasDescriptionSlot && !!this.descriptionLabel;
    }

    get _descriptionLines () {
        return this.descriptionLabel.split(/\r?\n/g);
    }

    get _descriptionHasMultipleLines () {
        return this._descriptionLines.length > 1;
    }

    get _descriptionFirstLine () {
        let label = this._descriptionLines[0];
        if (this._descriptionHasMultipleLines) {
            label += '…';
        }
        return label;
    }

    @api alternativeText;

    @api isCloseable = false;

    _variant = DEFAULT_VARIANT;
    @api set variant (value) {
        this._variant = normalizeString(
            // TODO: Maintained support for original default variant "base", though no usage found
            // in the codebase. May not be necessary.
            value === 'base' ? 'info' : value, {
                fallbackValue: DEFAULT_VARIANT,
                validValues: [
                    DEFAULT_VARIANT,
                    'warning',
                    'error',
                    'offline'
                ],
            }
        );
    }

    get variant () {
        return this._variant;
    }

    get i18n () {
        return i18n;
    }

    _hasHeaderSlot = false;
    _hasDescriptionSlot = false;

    _isVisible = true;
    handleCloseClick () {
        this._isVisible = false;
    }

    _detailsModalOpen = false;
    handleDetailsClick () {
        this._detailsModalOpen = true;
    }

    handleCloseModalClick () {
        this._detailsModalOpen = false;
    }

    _clipboardErrorVisible = false;
    handleCopyToClipboardClick () {
        this._clipboardErrorVisible = false;
        copyToClipboard(this.descriptionLabel || this.errorMessage)
            .catch(() => {
                this._clipboardErrorVisible = true;
            });
    }

    handleHeaderSlotChange () {
        this._hasHeaderSlot = true;
    }

    handleDescriptionSlotChange () {
        this._hasDescriptionSlot = true;
    }

    render () {
        return IS_MOBILE_DEVICE ? alertMobileTemplate : alertTemplate;
    }

    get computedCssClass () {
        return IS_MOBILE_DEVICE ? `slds-notify slds-notify_toast slds-theme_${this.variant}`
            : `slds-notify slds-notify_alert slds-theme_${this.variant} alert`;
    }

    get computedIconName () {
        return `utility:${this.variant}`;
    }

    handleMoreInformation (event) {
        event.preventDefault();
        this._detailsModalOpen = true;
    }
}