import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import {
    STEP_TYPES,
    isNotUndefinedOrNull,
    isImageFromStaticResource,
    computeStepIconName,
    populateAttributeForLaunchingWizardStep,
    IS_MOBILE_DEVICE,
} from 'c/utils';

import desktopTemplate from './svmxWizardItem.html';
import mobileTemplate from './svmxWizardItemMobile.html';

import lbl_targetEmpty from '@salesforce/label/c.Message_SPMWizardTargetEmpty';
import lbl_stepCompletionUpdateError from '@salesforce/label/c.Label_StepCompletionUpdateError';
import message_defaultDisableHelpText from '@salesforce/label/c.Message_DefaultDisableHelpText';
import lblNotAvailable from '@salesforce/label/c.Message_NotAvailable';
import messageForIncorrectConfig from '@salesforce/label/c.Messge_WizardIncorrectConfig';
import setWizardStepUsageLog
    from '@salesforce/apex/COMM_ProcessWizardService_LS.setWizardStepUsageLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const i18n = {
    lbl_targetEmpty: lbl_targetEmpty,
    message_defaultDisableHelpText: message_defaultDisableHelpText,
    messageQCNotValid: lblNotAvailable,
    messageForIncorrectConfig: messageForIncorrectConfig,
    lbl_stepCompletionUpdateError: lbl_stepCompletionUpdateError
};
export default class SvmxWizardItem extends NavigationMixin(LightningElement) {
    @track helpText;
    @api wizardItem;
    @api currRecId;
    @api currRecord
    @api showIcons;
    @api objectApiName;
    @api isTrackingOn;
    @api stepDependencyType;
    @track paramMapping = {};
    isLoading = false;
    @wire(CurrentPageReference)
    pageRef;
    _variantError = 'error';

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    get computeWizardItemClassName () {
        let className = 'svmx-wizard-item slds-is-relative ';
        if (this.wizardItem.isVisible === false) {
            if (this.wizardItem.criteriaAction === 'Disable Step') {
                //className = ' disable ';
            } else if (this.wizardItem.showQCError) {
                className = ' pointer';
            } else {
                className = ' pointer slds-hide';
            }
        } else {
            if (!this.wizardItem.target) {
                className = ' nonClicable';
            }
        }
        return className;
    }

    get computedTitle () {
        let title = this.wizardItem.name;
        if (this.wizardItem.isVisible === false) {
            if (this.wizardItem.criteriaAction === 'Disable Step') {
                title = this.wizardItem.criteriaActionHelpText
                    ? this.wizardItem.criteriaActionHelpText: i18n.message_defaultDisableHelpText;
            }
        } else {
            if (!this.wizardItem.target) {
                title = i18n.lbl_targetEmpty;
            } else if (this.wizardItem.helpText) {
                title = this.wizardItem.helpText;
            }
        }
        return title;
    }

    get stepsPending () {
        return this.wizardItem?.pendingDependentSteps;
    }

    get enableCompletion () {
        return this.stepsPending || !this.wizardItem.isVisible;
    }

    get computeTitleClass () {
        let classnames = "slds-hyphenate wizardItemFont slds-p-left_xx-small ";
        if (this.wizardItem.showQCError) {
            classnames += ' svmx-wizard-item-name_error slds-text-color_weak';
        } else {
            classnames += "slds-text-link";
        }
        if ((this.wizardItem.isVisible === false
            && this.wizardItem.criteriaAction === 'Disable Step')
            || this.stepsPending ) {
            classnames += ' disable ';
        }
        return classnames;
    }

    get computeTitleClassMobile () {
        let classNames = 'slds-hyphenate slds-text-body_regular';

        if (this.wizardItem.showQCError) {
            classNames += ' svmx-wizard-item-name_error slds-text-color_weak';
        } else {
            classNames += 'slds-text-link';
        }

        if (
            (this.wizardItem.isVisible === false
                && this.wizardItem.criteriaAction === 'Disable Step'
            ) || this.stepsPending
        ) {
            classNames += ' disable';
        }
        return classNames;
    }

    get computeWizardTooltipClassName () {
        const tooltipBaseClass = [
            "svmx-wizard-item_tooltip",
            'slds-popover',
            'slds-popover_tooltip',
            'slds-nubbin_bottom-left',
            'slds-fall-into-ground'];
        const titleLength = this.computedTitle.length;
        if ( titleLength <= 70) {
            tooltipBaseClass.push ("svmx-wizard-item-tooltip_small");
        } else if (titleLength <= 160) {
            tooltipBaseClass.push ("svmx-wizard-item-tooltip_medium");
        } else if (titleLength <= 255) {
            tooltipBaseClass.push ("svmx-wizard-item-tooltip_large");
        } else {
            tooltipBaseClass.push ("svmx-wizard-item-tooltip_medium");
        }
        return tooltipBaseClass.join(' ');
    }

    get computeWizardItemIconClass () {
        if (this.wizardItem.showQCError) {
            return "slds-p-right_xx-small";
        }
        return "slds-col slds-size_1-of-12 svmx-wizard-item-icon-class ";
    }

    get i18n () {
        return i18n;
    }

    get stepCompleted () {
        return this.wizardItem.stepCompleted === true;
    }

    handleClick (event) {
        event.preventDefault();
        if (this.wizardItem.isVisible === true && !this.stepsPending) {
            this.prepareMapping ();
            const mapping = this.paramMapping
                ? this.paramMapping
                : {};
            const attributes = populateAttributeForLaunchingWizardStep (
                this.wizardItem,
                mapping,
                this.currRecord ? this.currRecord : { id: this.currRecId });
            if ((IS_MOBILE_DEVICE && (this.wizardItem.type === STEP_TYPES.FLOW ||
                    this.wizardItem.type === STEP_TYPES.TRANSACTION)) ||
                    this.wizardItem.openAsModal ||
                    this.wizardItem.type === STEP_TYPES.RECORDACTION) {

                attributes.c__objectApiName = this.objectApiName;
                attributes.c__isTrackingOn = this.isTrackingOn;
                attributes.c__stepComplete = this.stepCompleted;
                attributes.c__stepCompletionEnabled = this.stepDependencyFlag;
                mapping.openAsModal = true;
                if (this.wizardItem.type === STEP_TYPES.RECORDACTION) {
                    attributes.c__stepId = this.wizardItem.id;
                }
                const selectedEvent = new CustomEvent('launchaction',
                    {
                        detail: attributes
                    });
                this.dispatchEvent(selectedEvent);
            } else if (this.wizardItem.type === STEP_TYPES.URL) {
                const pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'SVMXA360__SvmxFlowLauncher'
                    },
                    state: attributes
                };
                this[NavigationMixin.GenerateUrl](pageReference).then (url => {
                    window.open(url,"_blank");
                });
            } else {
                attributes.c__objectApiName = this.objectApiName;
                attributes.c__isTrackingOn = this.isTrackingOn;
                attributes.c__stepComplete = this.stepCompleted;
                attributes.c__stepCompletionEnabled = this.stepDependencyFlag;
                attributes.c__startTime =  new Date().getTime();
                const pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'SVMXA360__SvmxFlowLauncher'
                    },
                    state: attributes
                };
                this[NavigationMixin.Navigate](pageReference);
                localStorage.removeItem("prevScreenDevName");
            }
        }
    }

    prepareMapping () {
        this.paramMapping = {};
        if (this.wizardItem.stepParameters) {
            this.wizardItem.stepParameters.forEach(param =>{
                if (param.valueType ==='Field'
                && this.currRecord
                && this.currRecord.fields[param.parameterValue]
                && isNotUndefinedOrNull(this.currRecord.fields[param.parameterValue].value)) {
                    this.paramMapping[param.parameterKey] =
                        this.currRecord.fields[param.parameterValue].value;
                } else if (param.valueType ==='Value') {
                    this.paramMapping[param.parameterKey] = param.parameterValue;
                }
            });
        }
    }

    get computedIconName () {
        return computeStepIconName(this.wizardItem.iconName, this.wizardItem.type);
    }

    get imageFromStaticResource () {
        return isImageFromStaticResource(this.computedIconName);
    }

    get stepDependencyFlag () {
        return this.stepDependencyType === 'Checklist';
    }

    handleMouseOver () {
        const element = this.template.querySelector('.svmx-wizard-item_tooltip');
        this.showTooltip (element);
    }

    handleMouseOut () {
        const element = this.template.querySelector('.svmx-wizard-item_tooltip');
        this.hideTooltip (element);
    }

    handleMouseOverForError () {
        const element = this.template.querySelector('.svmx-wizard-item_error-popover-body');
        this.showTooltip (element);
    }

    handleMouseOutForError () {
        const element = this.template.querySelector('.svmx-wizard-item_error-popover-body');
        this.hideTooltip (element);
    }

    showTooltip (element) {
        if (element && element.classList) {
            element.classList.remove("slds-fall-into-ground");
            // element.classList.add("slds-rise-from-ground");
            element.classList.add("slds-slide-from-bottom-to-top");
            //element.style.visibility = 'visible';
            element.style.cursor = 'pointer';
        }
    }

    hideTooltip (element) {
        // element.style.visibility = 'hidden';
        if (element && element.classList) {
            element.classList.add("slds-fall-into-ground");
            //element.classList.remove("slds-rise-from-ground");
            element.classList.remove("slds-slide-from-bottom-to-top");
            element.style.cursor = 'auto';
        }
    }

    handleStepCompleteClicked (event) {
        event.stopPropagation();
    }

    handleStepCompleteChange (event) {
        this.isLoading = true;
        const stepCompletionObj = {
            stepId: this.wizardItem.id,
            sourceRecordId: this.currRecId,
            enabled: event.detail.checked ?? event.detail.value
        };

        setWizardStepUsageLog({
            requestJson: JSON.stringify( stepCompletionObj )
        }).then(result => {
            if (result && result.success) {
                this.handleDispatchEvent ('completionstatuschange', {});
                this.isLoading = false;
            } else if (!result.success) {
                this.isLoading = false;
                this.showNotification(lbl_stepCompletionUpdateError, '', this._variantError);
            }
        }).catch( () => {
            this.isLoading = false;
            this.showNotification(lbl_stepCompletionUpdateError, '', this._variantError);
        });
    }

    handleDispatchEvent (eventName, attributes) {
        this.dispatchEvent(
            new CustomEvent(eventName, {
                detail: {
                    value: attributes
                }
            })
        );
    }

    showNotification (title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}