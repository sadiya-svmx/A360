import { LightningElement, api } from 'lwc';

import mappingAdminListView from './templates/mappingAdminListView.html';
import expressionAdminListView from './templates/expressionAdminListView.html';
import warrantyRules from './templates/warrantyRules.html';
import automaticRules from './templates/automaticRules.html';
import entitlementSettings from './templates/entitlementSettings.html';
import landingPage from './templates/landingPage.html';
import wizardListView from './templates/wizardListView.html';
import depotFinderRule from './templates/depotFinderRule.html';
import pricebookAssignmentListView from './templates/pricebookAssignmentListView.html';
import serviceAssignmentRules from './templates/serviceAssignmentRules.html';
import entitlementCommonSettings from './templates/entitlementCommmonSettings.html';
import technicalAttributeSettings from './templates/technicalAttributeSettings.html';
import configTemplatesPSC from './templates/pscConfigTemplatesListView.html';
import settingforPSC from './templates/pscSettingPage.html';
import translationworkbench from './templates/translationWorkbench.html';
import featuresettingadmin from './templates/featureSettingAdminView.html';
import timelineAdmin from './templates/timelineAdminListView.html';
import hierarchyConfigListView from './templates/hierarchyConfigListView.html';
import autoConfiguration from './templates/autoConfiguration.html';
import spmCommonSettings from './templates/spmCommonSettings.html';
import templateMatchRuleListView from './templates/templateMatchRuleListView.html';
import mplnAdminProcessListView from './templates/mplnAdminProcessListView.html';

const TEMPLATES = {
    'c-mapping-admin-list-view': mappingAdminListView,
    'c-admin-welcome': landingPage,
    'c-expression-admin-list-view': expressionAdminListView,
    'c-warranty-rules': warrantyRules,
    'c-automatic-rules': automaticRules,
    'c-entitlement-settings': entitlementSettings,
    'c-wizard-admin-list-view': wizardListView,
    'c-depot-finder-rule': depotFinderRule,
    'c-pricebook-assignment-list-view': pricebookAssignmentListView,
    'c-psc-config-admin-list-view': configTemplatesPSC,
    'c-psc-setting-admin-detail': settingforPSC,
    'c-service-assignment-rules': serviceAssignmentRules,
    'c-entitlement-common-settings': entitlementCommonSettings,
    'c-technical-attribute-settings': technicalAttributeSettings,
    'c-translation-workbench': translationworkbench,
    'c-feature-setting-admin': featuresettingadmin,
    'c-asset-timeline-admin-list': timelineAdmin,
    'c-hierarchy-config-list-view': hierarchyConfigListView,
    'c-template-match-rule-list-view': templateMatchRuleListView,
    'c-auto-configuration': autoConfiguration,
    'c-spm-common-settings': spmCommonSettings,
    'c-mpln-admin-process-list-view': mplnAdminProcessListView
};

export default class CenterStage extends LightningElement {
    @api
    tag;

    @api
    attrs = {};

    @api
    children = [];
    template;
    error;
    template;

    get slots () {
        return this.children.map(c => {
            const slotName = c.attrs.slot || 'default';
            return {
                [slotName]: c,
            };
        });
    }

    errorCallback (error) {
        this.error = error;
    }

    render () {
        this.template = TEMPLATES[this.tag]|| landingPage;
        this.hasRendered = false;
        return this.template;
    }

    renderedCallback () {
        const { template } = this;
        if ( this.hasRendered === false ) {
            this.hasRendered = true;

            if (template === landingPage) {
                this.sendLoadPageEvent({ cardLess: true });
            }
            else if ( template === autoConfiguration ) {
                this.sendLoadPageEvent({ isAutoConfigRunning: true });
            }
            else {
                this.sendLoadPageEvent();
            }
        }
    }

    sendLoadPageEvent (detail) {
        this.dispatchEvent(new CustomEvent('loadpage', {
            detail
        }));
    }
}