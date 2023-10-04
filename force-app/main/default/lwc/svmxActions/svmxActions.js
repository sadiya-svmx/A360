import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { EngineElement }  from 'c/runtimeEngineProvider';

import labelComplete from '@salesforce/label/c.Label_Complete';
import labelFailed from '@salesforce/label/c.Label_Failed';
import labelViewHiddenActions from '@salesforce/label/c.Link_ViewHiddenActions';
import labelInvalidActionType from '@salesforce/label/c.Label_InvalidActionType';
import labelTooManyIntents from '@salesforce/label/c.Error_OnlyOneActionIntentSupported';
import svmxActionsTemplate from './svmxActions.html';
import svmxActionsMobileTemplate from './svmxActionsMobile.html';
import messageRuntimeFieldsMissing from '@salesforce/label/c.Message_RequiredFieldMissing';

import {
    RUNTIME_CONTEXT,
    ROUTES,
    PAGE_ELEMENT_STATIC_ACTIONS,
    IS_MOBILE_DEVICE,
    debounce,
    isFlowContext,
    classSet
} from 'c/utils';

const i18n = {
    complete: labelComplete,
    failed: labelFailed,
    viewHiddenActions: labelViewHiddenActions,
    invalidActionType: labelInvalidActionType,
    tooManyIntents: labelTooManyIntents,
    errorFieldsMissing: messageRuntimeFieldsMissing,
};

export default class SvmxActions extends EngineElement(LightningElement)  {
    @api reportValidity = () => ({});

    @api maxButtonsVisible = 3;
    @track loading = true;
    @track gridOnly = false;

    get customActions () {
        return this.actions.filter(button => button.intents)
    }

    get staticActions () {
        return this.actions.filter(button => !button.intents)
    }

    get _visibleActions () {
        return this.customActions.slice(0, this.maxButtonsVisible);
    }

    get _hiddenActions () {
        // union of custom + static actions
        return this.customActions
            .slice(this.maxButtonsVisible, this.actions.length)
            .concat(this.staticActions);
    }

    get _hasHiddenActions () {
        return this._hiddenActions.length > 0;
    }

    get computedInputClass () {
        const cssClasses = ['svmx-actions_button-group'];

        if (this.gridOnly) {
            cssClasses.push('slds-var-m-bottom_small');
        }

        return cssClasses.join(' ');
    }

    _handleFAButtonClick (event) {
        event.stopPropagation();
        this.template.querySelector('.svmx-fab-dropdown_overlay').style.display = 'block';

        this.touchHandler = debounce(() => {
            this.template.querySelector('.svmx-fab-dropdown_overlay').style.display = 'none';
            window.removeEventListener('touchend',this.touchHandler);
            window.removeEventListener('click',this.touchHandler);
        }, 200);

        window.addEventListener('touchend', this.touchHandler);
        window.addEventListener('click', this.touchHandler);
    }

    async _handleActionClick (e) {
        const actionName = e?.currentTarget?.dataset?.actionName;
        const action = this.actions
            .concat(this.staticActions)
            .find(actionConfig => actionConfig.name === actionName);
        if (
            action.name === PAGE_ELEMENT_STATIC_ACTIONS.EDIT_SCREEN.name ||
            action.name === PAGE_ELEMENT_STATIC_ACTIONS.EDIT_TRANSACTION.name
        ) {
            let url;
            if (this.context === RUNTIME_CONTEXT.SCREEN_FLOW) {
                url = `${ROUTES.LAYOUT_EDITOR}#/editor/${action.id}`;
            } else {
                url = `${ROUTES.TRANSACTION_EDITOR}#/editor/${action.id}`;
            }
            window.open(url, '_blank');
            return;
        } else if (
            action.name === PAGE_ELEMENT_STATIC_ACTIONS.DEBUG_TRANSACTION.name
        ) {
            await this.props.handleIsDebugEnabled(true);
            this.dispatchEvent(new CustomEvent('showconsole'));
            return;
        }
        await this.props.applyValidation();
        const validity = this.reportValidity();

        if (validity && IS_MOBILE_DEVICE) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: i18n.errorFieldsMissing,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }

        if (actionName && !validity) {
            this._fireActionIntents(action);
        }
    }

    async _fireActionIntents (action) {
        const toastConfig = {};

        try {
            await this.props.executeCustomActionOnButton(action.name);
            toastConfig.variant = 'success';
            toastConfig.title = `${action.label} ${i18n.complete}`;
        } catch (e) {
            toastConfig.variant = 'error';
            toastConfig.title = `${action.label} ${i18n.failed}`;
            toastConfig.message = e?.body?.message || e.message;
        } finally {
            this.dispatchEvent(new ShowToastEvent(toastConfig));
        }
    }

    get hasActions () {
        return this?.actions?.length > 0;
    }

    get _i18n () {
        return i18n;
    }

    get isFlowContext () {
        return isFlowContext(this.runtimeContext);
    }

    get fabDropdownClass () {
        return classSet('slds-has-dividers_bottom-space svmx-fab_dropdown')
            .add({ 'svmx-fab_dropdown_flow': this.isFlowContext })
            .toString();
    }

    render () {
        return IS_MOBILE_DEVICE ? svmxActionsMobileTemplate : svmxActionsTemplate;
    }

    runtimeEngineUpdate (engineProps) {
        this.actions = engineProps.buttons;
        this.gridOnly = engineProps.sections.length === 0;
        this.context = engineProps.runtimeContext;
        this.loading = engineProps.loadingStatus.LOADING_ENGINE_METADATA;
        this.runtimeContext = engineProps.runtimeContext;
    }
}