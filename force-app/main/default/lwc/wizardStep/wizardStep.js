import { LightningElement, api, track } from 'lwc';
import {
    isEmptyString,
    isImageFromStaticResource,
    STEP_TYPE_ICONS
} from 'c/utils';

import labelStepProperties from '@salesforce/label/c.Menu_StepProperties';
import labelRemove from '@salesforce/label/c.Menu_Remove';
import labelShowMenuAltText from '@salesforce/label/c.AltText_ShowMenu';

const i18n = {
    stepProperties: labelStepProperties,
    removeStep: labelRemove,
    menuAlText: labelShowMenuAltText
};

const REMOVE_STEP = 'remove';
const STEP_PROPERTIES = 'properties';

const STEP_TYPE_MAP = {
    'Flow': 'Flow',
    'SPM Transaction': 'Transaction',
    'Lightning Web Component': 'Lightning Web Component',
    'url': 'URL'
}

export default class WizardStep extends LightningElement {
    /**
     * This value is used to display the process step name
     * @type {string}
     * @required
     */
    @api stepName;

    /**
     * This value is used to communicate the process step record id for events that are dispatched
     * @type {string}
     * @required
     */
    @api stepId;

    /**
     * This value is used by the component to distinguish the step type
     * @type {string}
     * @required
     */
    @api stepType;

    /**
     * This value is used by the component for custom Icons
     * @type {string}
     * @required
     */
    @api stepIconName;

    /**
     * This dev name value is used for display
     * @type {string}
     */
    @api stepDevName

    /**
     * This value is used by the component to displaying developer name
     * @type {string}
     */
     @api showDevName

     @api searchKey;

    @track focused = false;

    @track
    menuItems = [
        {
            id: 'item-2',
            label: i18n.removeStep,
            value: REMOVE_STEP
        }
    ];

    get computedCardClass () {
        let css = 'slds-card slds-card_boundary step-card';

        if (this.focused) {
            css += ' step-card-is-focused';
        }

        return css;
    }

    get iconName () {
        if (this.stepIconName) {
            return this.stepIconName;
        } else if (this.stepType) {
            return STEP_TYPE_ICONS[this.stepType]
        }
        return null;
    }

    get i18n () {
        return i18n;
    }

    get isSvmxIcon () {
        if (this.iconName) {
            return isImageFromStaticResource(this.iconName)
        }
        return null;
    }

    get stepCardElement () {
        return this.template.querySelector('.step-card');
    }

    get stepTypeMapped () {
        return (STEP_TYPE_MAP[this.stepType]) ? STEP_TYPE_MAP[this.stepType] : this.stepType;
    }

    get stepDevNameFormatted () {
        try {
            const regex = new RegExp(`((${this.sanitizeRegex(this.searchKey)}))`, 'gi');
            return `${this.stepTypeMapped} : ${this.stepDevName.replace(regex, '<mark>$1</mark>')}`;
        } catch (e) {
            return this.searchKey;
        }
    }

    get stepNameFormatted () {
        try {
            const regex = new RegExp(`((${this.sanitizeRegex(this.searchKey)}))`, 'gi');
            return this.stepName.replace(regex, '<mark>$1</mark>');
        } catch (e) {
            return this.searchKey;
        }
    }

    sanitizeRegex (searchString) {
        try {
            return (searchString)
                ? searchString.replace(/[#-.]|[[-^]|[?|{}]/g, '\\$&')
                : searchString;
        } catch (e) {
            return searchString;
        }
    }

    connectedCallback () {
        this.validateRequiredAttributes();
    }

    handleFocus () {
        this.focused = true;
    }

    handleBlur () {
        this.focused = false;
    }

    handleSettingMenuBlur () {
        this.handleFocus();
        this.stepCardElement.focus();
    }

    handleSettingMenuFocus () {
        this.handleFocus();
    }

    handleSettingsMenuSelect (event) {
        switch (event.detail.value) {
            case STEP_PROPERTIES:
                this.dispatchStepPropertiesEvent(this.stepId);
                break;
            case REMOVE_STEP:
                this.dispatchStepRemovedEvent(this.stepId);
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
    }

    handleClick () {
        this.dispatchStepPropertiesEvent(this.stepId);
    }

    dispatchStepPropertiesEvent (stepId) {
        this.dispatchEvent(
            new CustomEvent('propertiesselected', {
                detail: {
                    value: stepId
                }
            })
        );
    }

    dispatchStepRemovedEvent (stepId) {
        this.dispatchEvent(
            new CustomEvent('removeselected', {
                detail: {
                    value: stepId
                }
            })
        );
    }

    validateRequiredAttributes () {
        const { stepId, stepName } = this;

        if (isEmptyString(stepId)) {
            throw new Error(
                `<c-wizard-step> The required step-id attribute value "${stepId}" is invalid.`
            );
        }

        if (isEmptyString(stepName)) {
            throw new Error(
                `<c-wizard-step> The required step-name attribute value "${stepName}" is invalid.`
            );
        }
    }
}