import { LightningElement, api } from 'lwc';
import {
    ComponentMixin, RegisterComponent, ComponentRegistered, ApplicationId,
    lockPageScroll, unlockPageScroll
} from 'c/xApplication';

import {
    normalizeBoolean, IS_MOBILE_DEVICE, guid,isEmptyString,isNotUndefinedOrNull
} from 'c/utils';
import desktopTemplate from './modalDialog.html';
import mobileTemplate from './modalDialogMobile.html';

import labelClose from '@salesforce/label/c.AltText_Close';

const i18n = {
    closeAltText: labelClose
};

const OPEN_MODAL_IDS_PER_APPLICATION = new Map();
const getOpenModalIdsForApplication = (applicationId = 'ALL') => {
    let openModalIdsForApplication = OPEN_MODAL_IDS_PER_APPLICATION.get(applicationId);
    if (!openModalIdsForApplication) {
        openModalIdsForApplication = new Set();
        OPEN_MODAL_IDS_PER_APPLICATION.set(applicationId, openModalIdsForApplication);
    }
    return openModalIdsForApplication;
};

let wereAnyModalsOpen = false;
const respondToModalStateChange = (applicationId) => {
    const openModalIdsForApplication = getOpenModalIdsForApplication(applicationId);
    const areAnyModalsOpen = openModalIdsForApplication.size > 0;
    if (areAnyModalsOpen !== wereAnyModalsOpen) {
        if (areAnyModalsOpen) {
            lockPageScroll(applicationId);
        } else {
            unlockPageScroll(applicationId);
        }
    }
    wereAnyModalsOpen = areAnyModalsOpen;
};

const signalModalOpened = (applicationId, modalId) => {
    const openModalIdsForApplication = getOpenModalIdsForApplication(applicationId);
    openModalIdsForApplication.add(modalId);
    respondToModalStateChange(applicationId);
};

const signalModalClosed = (applicationId, modalId) => {
    const openModalIdsForApplication = getOpenModalIdsForApplication(applicationId);
    openModalIdsForApplication.delete(modalId);
    respondToModalStateChange(applicationId);
};

export default class ModalDialog extends ComponentMixin(LightningElement) {
    @api title;
    @api size = '';
    @api closeButtonStyle = 'slds-modal__close slds-button_icon-inverse';
    @api modalContentId = 'modal-content';
    @api modalHeaderId = 'modal-header';
    @api sectionClass;
    @api nestedModal = false;
    @api relativeToViewport = false;
    @api relativeToDebugpanel = false;
    @api showFooter = false;
    @api headLess = false;
    @api expandHeightToViewport = false;
    @api noFooter = false;
    isWindowPopEventAttached = false;

    _internalId = guid();

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    connectedCallback () {
        this[RegisterComponent]();
    }

    [ComponentRegistered] () {
        this.updateApplicationState();
    }

    updateApplicationState () {
        const applicationId = this[ApplicationId];

        if (applicationId) {
            if (this.isOpen) {
                signalModalOpened(applicationId, this._internalId);
            } else {
                signalModalClosed(applicationId, this._internalId);
            }
        }
    }

    disconnectedCallback () {
        const applicationId = this[ApplicationId];
        if (applicationId) {
            signalModalClosed(applicationId, this._internalId);
        }
        document.body.style.overflow = 'visible';
    }

    _isOpen;
    @api get isOpen () {
        return this._isOpen;
    }

    set isOpen (newValue) {
        this._isOpen = normalizeBoolean(newValue);

        this.updateApplicationState();

        if (this.isOpen) {
            this.dispatchModelOpened();
            document.body.style.overflow = 'hidden';
            if (!this.isWindowPopEventAttached) {
                // reset when active history changes E.g. browser back button click
                window.onpopstate = () => {
                    document.body.style.overflow = 'visible';
                };
                this.isWindowPopEventAttached = true;
            }
        } else {
            document.body.style.overflow = 'visible';
        }
    }

    get i18n () {
        return i18n;
    }

    get computedClassForRelativeRendering () {
        const modalClasses = ['slds-modal__container'];
        switch (this.size.toUpperCase()) {
            case 'LARGE':
            case 'LARGE_FIXED':
                if (this.relativeToViewport) {
                    modalClasses.push('svmx-modal_large');
                }
                break;
            case 'MEDIUM':
            case 'MEDIUM_FIXED':
                if (this.relativeToViewport) {
                    modalClasses.push('svmx-modal_medium');
                }
                break;
            case 'SMALL':
            case 'SMALL_FIXED':
                if (this.relativeToViewport) {
                    modalClasses.push('svmx-modal_small');
                }
                break;
            case 'X_SMALL':
                if (this.relativeToViewport) {
                    modalClasses.push('svmx-modal_x_small');
                }
                break;
            default:
                if (this.relativeToViewport) {
                    modalClasses.push('svmx-modal_small');
                }
                break;
        }
        if (this.relativeToViewport) {
            modalClasses.push('svmx-modal-container');
        }
        if (this.expandHeightToViewport) {
            modalClasses.push('smvx-modal_expand-height-to-viewport');
        }
        return modalClasses.join(' ');
    }

    get modalStyle () {
        const modalClasses = [
            'svmx-modal',
            'slds-modal',
            'slds-fade-in-open'
        ];
        switch (this.size.toUpperCase()) {
            case 'LARGE':
            case 'LARGE_FIXED':
                modalClasses.push('slds-modal_large');
                break;
            case 'MEDIUM':
            case 'MEDIUM_FIXED':
                modalClasses.push('slds-modal_medium');
                break;
            case 'SMALL':
            case 'SMALL_FIXED':
            case 'X_SMALL':
                modalClasses.push('slds-modal_small');
                break;
            default:
                break;
        }
        if (this.nestedModal && !this.size.toUpperCase().includes('SMALL')) {
            modalClasses.push('nestedModalMedium');
        }
        if (this.relativeToDebugpanel) {
            modalClasses.push('svmx-modal_override');
        }
        return modalClasses.join(' ');
    }

    get modalSectionStyle () {
        const sectionClasses = ['slds-modal__content'];
        if (!IS_MOBILE_DEVICE) {
            sectionClasses.push('slds-p-around_medium');
        }
        if (this.sectionClass) {
            sectionClasses.push(this.sectionClass);
        }
        switch (this.size.toUpperCase()) {
            case 'LARGE_FIXED':
            case 'SMALL_FIXED':
            case 'MEDIUM_FIXED':
                sectionClasses.push('svmx-modal-content_fixed-height');
                break;
            case 'MIN_HEIGHT':
                sectionClasses.push('svmx-modal-content_min-height');
                break;
            default:
                break;
        }

        return sectionClasses.join(' ');
    }

    get modalHeaderStyle () {
        const cssClasses = ['slds-modal__header'];
        if (this.headLess) {
            cssClasses.push('slds-modal__header_empty');
        }
        return cssClasses.join(' ');
    }

    get backdropStyle () {
        const cssClasses = ['slds-backdrop slds-backdrop_open'];
        if (this.relativeToDebugpanel) {
            cssClasses.push('svmx-backdrop');
        }
        return cssClasses.join(' ');
    }

    get hasTitle () {
        return isNotUndefinedOrNull(this.title) && !isEmptyString(this.title);
    }

    handleClose () {
        this.dispatchEvent(
            new CustomEvent('modalclosed', {
                detail: {
                    value: this.modalHeaderId
                }
            })
        );
    }

    dispatchModelOpened () {
        this.dispatchEvent(
            new CustomEvent('modalopened', {
                detail: {
                    value: this.modalHeaderId
                }
            })
        );
    }
}