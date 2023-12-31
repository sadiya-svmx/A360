import { LightningElement, api } from 'lwc';
import labelUpdateSelectedItems from '@salesforce/label/c.Message_UpdateSelectedItems';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelApply from '@salesforce/label/c.Button_Apply';
import { InteractingState, formatString } from 'c/utils';

const i18n = {
    updateSelectedItems: labelUpdateSelectedItems,
    cancel: labelCancel,
    apply: labelApply,
};

export default class PrimitiveDatatableIeditPanel extends LightningElement {
    @api visible;
    @api rowKeyValue;
    @api colKeyValue;
    @api editedValue;
    @api columnDef;
    @api isMassEditEnabled = false;
    @api numberOfSelectedRows;

    connectedCallback () {
        this.interactingState = new InteractingState({
            duration: 10,
            debounceInteraction: true,
        });
        this.interactingState.onleave(() => this.handlePanelLoosedFocus());
    }

    get computedStyle () {
        const styleHash = {
            'z-index': 1000,
            'background-color': 'white',
            'margin-top': '1px',
        };

        styleHash.display = this.visible ? 'block' : 'none';

        return Object.keys(styleHash)
            .map(styleProp => `${styleProp}:${styleHash[styleProp]}`)
            .join(';');
    }

    get inputKey () {
        return this.rowKeyValue + this.colKeyValue;
    }

    get massEditCheckboxLabel () {
        return formatString(i18n.updateSelectedItems, this.numberOfSelectedRows);
    }

    get applyLabel () {
        return i18n.apply;
    }

    get cancelLabel () {
        return i18n.cancel;
    }

    get required () {
        return (
            this.columnDef.typeAttributes &&
            this.columnDef.typeAttributes.required
        );
    }

    handleFormStartFocus () {
        this.interactingState.enter();

        if (this.isMassEditEnabled) {
            // on mass edit the panel dont loses the focus with the keyboard.
            this.focusLastElement();
        } else {
            this.triggerEditFinished({
                reason: 'tab-pressed-prev',
            });
        }
    }

    handleFormEndsFocus () {
        this.interactingState.enter();

        if (this.isMassEditEnabled) {
            // on mass edit the panel dont loses the focus with the keyboard.
            this.focus();
        } else {
            this.triggerEditFinished({
                reason: 'tab-pressed-next',
            });
        }
    }

    triggerEditFinished (detail) {
        detail.rowKeyValue = detail.rowKeyValue || this.rowKeyValue;
        detail.colKeyValue = detail.colKeyValue || this.colKeyValue;

        const event = new CustomEvent('ieditfinished', {
            detail,
        });
        this.dispatchEvent(event);
    }

    @api
    focus () {
        const elem = this.inputableElement;
        this.interactingState.enter();

        if (elem) {
            elem.focus();
        }
    }

    get inputableElement () {
        return this.template.querySelector('.dt-type-edit-factory');
    }

    @api
    get value () {
        return this.inputableElement.value;
    }

    @api
    get validity () {
        return this.inputableElement.validity;
    }

    @api
    get isMassEditChecked () {
        return (
            this.isMassEditEnabled &&
            this.template.querySelector('[data-mass-selection="true"]').checked
        );
    }

    @api
    getPositionedElement () {
        return this.template.querySelector('section');
    }

    handleTypeElemBlur () {
        if (this.visible && !this.template.activeElement) {
            this.interactingState.leave();
        }
    }

    handleTypeElemFocus () {
        this.interactingState.enter();
    }

    handleEditFormSubmit (event) {
        event.preventDefault();
        event.stopPropagation();

        if (!this.isMassEditEnabled) {
            this.processSubmission();
        }

        return false;
    }

    handleCellKeydown (event) {
        const { keyCode } = event;

        if (keyCode === 27) {
            // Esc key
            event.stopPropagation();
            this.cancelEdition();
        }
    }

    handlePanelLoosedFocus () {
        if (this.visible) {
            this.triggerEditFinished({
                reason: 'loosed-focus',
            });
        }
    }

    focusLastElement () {
        this.template.querySelector('[data-form-last-element="true"]').focus();
    }

    processSubmission () {
        if (this.validity.valid) {
            this.triggerEditFinished({ reason: 'submit-action' });
        } else {
            this.inputableElement.showHelpMessageIfInvalid();
        }
    }

    cancelEdition () {
        this.triggerEditFinished({
            reason: 'edit-canceled',
        });
    }

    handleMassCheckboxChange (event) {
        const customEvent = new CustomEvent('masscheckboxchange', {
            detail: {
                checked: event.detail.checked,
            },
        });

        this.dispatchEvent(customEvent);
    }
}