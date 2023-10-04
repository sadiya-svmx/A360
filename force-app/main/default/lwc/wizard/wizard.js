import { LightningElement, api } from 'lwc';
import { sortObjectArray } from 'c/utils';

import labelShowMenuAltText from '@salesforce/label/c.AltText_ShowMenu';
import labelAddStep from '@salesforce/label/c.AltText_AddStep';
import labelWizardProperties from '@salesforce/label/c.Menu_WizardProperties';
import labelClone from '@salesforce/label/c.Menu_Clone';
import labelDelete from '@salesforce/label/c.Menu_Delete';
import labelMoveToActive from '@salesforce/label/c.Menu_MoveToActive';
import labelMoveToInactive from '@salesforce/label/c.Menu_MoveToInactive';
import labelReorderSteps from '@salesforce/label/c.Menu_ReorderSteps';

const i18n = {
    addStep: labelAddStep,
    clone: labelClone,
    delete: labelDelete,
    menuAlText: labelShowMenuAltText,
    moveToActive: labelMoveToActive,
    moveToInactive: labelMoveToInactive,
    reorderSteps: labelReorderSteps,
    wizardProperties: labelWizardProperties
};

const WIZARD_PROPERTIES = 'properties';
const REORDER_STEPS = 'reorder_steps';
const ACTIVATE_WIZARD = 'activate';
const INACTIVATE_WIZARD = 'inactivate';
const CLONE_WIZARD = 'clone';
const DELETE_WIZARD = 'delete';

export default class Wizard extends LightningElement {
    @api wizard;
    @api expandedSections;
    @api searchKey;

    get menuItems () {
        const defaultItems = [
            {
                id: 'item-1',
                label: i18n.wizardProperties,
                value: WIZARD_PROPERTIES
            }
        ];

        const reorderStep = {
            id: 'item-2',
            label: i18n.reorderSteps,
            value: REORDER_STEPS
        };

        if (this.wizard && this.wizard.steps && this.wizard.steps.length > 1 ) {
            if (this.searchKey?.length === 0) {
                defaultItems.push(reorderStep);
            }
        }

        const activeItems = [
            {
                id: 'item-3',
                label: i18n.moveToInactive,
                value: INACTIVATE_WIZARD
            },
            {
                id: 'item-4',
                label: i18n.clone,
                value: CLONE_WIZARD
            },
            {
                id: 'item-5',
                label: i18n.delete,
                value: DELETE_WIZARD
            }
        ];

        const inactiveItems = [
            {
                id: 'item-3',
                label: i18n.moveToActive,
                value: ACTIVATE_WIZARD
            },
            {
                id: 'item-4',
                label: i18n.clone,
                value: CLONE_WIZARD
            },
            {
                id: 'item-5',
                label: i18n.delete,
                value: DELETE_WIZARD
            }
        ];

        return this.wizard && this.wizard.active
            ? defaultItems.concat(activeItems)
            : defaultItems.concat(inactiveItems);
    }

    get i18n () {
        return i18n;
    }

    get orderedSteps () {
        if (this.wizard && this.wizard.steps && this.wizard.steps.length > 0) {
            return sortObjectArray(
                this.wizard.steps,
                'sequence',
                'asc'
            );
        }

        return [];
    }
    /**
     * method determines if the dev name of wizard should be displayed on search
     */
    get showWizardDevName () {
        // const steps = Array.isArray(this.wizard?.steps) ? this.wizard.steps : [];
        // const stepVisibilityCount = steps.filter(s => {return s.isVisible === false;}).length;
        return this.searchKey?.length >= 3;
    }
    /**
     * method determines if the dev name of step should be displayed on search
     */
    get showStepDevName () {
        const steps = Array.isArray(this.wizard?.steps) ? this.wizard.steps : [];
        const stepVisibilityCount = steps.filter(s => {return s.isVisible === false;}).length;
        return this.searchKey?.length >= 3 && stepVisibilityCount >= 0;
    }

    get wizardDevName () {
        try {
            const regex = new RegExp(`((${this.sanitizeRegex(this.searchKey)}))`, 'gi');
            return this.wizard.developerName.replace(regex, '<mark>$1</mark>');
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

    handleAddStep () {
        this.dispatchEvent(
            new CustomEvent('addstep', {
                detail: {
                    value: this.wizard
                }
            })
        );
    }

    handleStepPropertiesSelected (event) {
        this.dispatchEvent(
            new CustomEvent('steppropertiesselected', {
                detail: {
                    wizardReferenceId: this.wizard.referenceId,
                    stepReferenceId: event.detail.value
                }
            })
        );
    }

    handleSettingsMenuSelect (event) {
        switch (event.detail.value) {
            case WIZARD_PROPERTIES:
                this.dispatchWizardPropertiesEvent(this.wizard);
                break;
            case REORDER_STEPS:
                this.dispatchWizardReorderEvent(this.wizard);
                break;
            case ACTIVATE_WIZARD:
                this.dispatchActivateWizardEvent(this.wizard);
                break;
            case INACTIVATE_WIZARD:
                this.dispatchInactivateWizardEvent(this.wizard);
                break;
            case CLONE_WIZARD:
                this.dispatchCloneWizardEvent(this.wizard);
                break;
            case DELETE_WIZARD:
                this.dispatchDeleteWizardEvent(this.wizard);
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
    }

    handleStepRemoved (event) {
        this.dispatchEvent(
            new CustomEvent('stepremoved', {
                detail: {
                    wizardReferenceId: this.wizard.referenceId,
                    stepReferenceId: event.detail.value
                }
            })
        );
    }

    dispatchWizardPropertiesEvent (wizard) {
        this.dispatchEvent(
            new CustomEvent('wizardproperties', {
                detail: {
                    value: wizard
                }
            })
        );
    }

    dispatchWizardReorderEvent (wizard) {
        this.dispatchEvent(
            new CustomEvent('wizardreorder', {
                detail: {
                    value: wizard
                }
            })
        );
    }

    dispatchActivateWizardEvent (wizard) {
        this.dispatchEvent(
            new CustomEvent('activatewizard', {
                detail: {
                    value: wizard
                }
            })
        );
    }

    dispatchInactivateWizardEvent (wizard) {
        this.dispatchEvent(
            new CustomEvent('inactivatewizard', {
                detail: {
                    value: wizard
                }
            })
        );
    }

    dispatchCloneWizardEvent (wizard) {
        this.dispatchEvent(
            new CustomEvent('clonewizard', {
                detail: {
                    value: wizard
                }
            })
        );
    }

    dispatchDeleteWizardEvent (wizard) {
        this.dispatchEvent(
            new CustomEvent('deletewizard', {
                detail: {
                    value: wizard
                }
            })
        );
    }
}