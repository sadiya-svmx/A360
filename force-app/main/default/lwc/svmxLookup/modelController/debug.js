import {
    StaticallyComparable,
    getValue
} from 'c/utils';

import {
    getDebugSymbol,
    pushDebugSnapshot,
    isDebuggingEnabled,
    registerDebuggingEnabledSubscriber,
    deregisterDebuggingEnabledSubscriber
} from 'c/runtimePubSub';

export const DEBUG_KEYS = {
    ON_CHANGE: 'Lookup - On Change'
};

const MAX_SNAPSHOTS_PER_INST = 1;

import FIELD_TO_RETURN from '@salesforce/schema/CONF_LookupConfiguration__c.FieldToReturn__c';
import OBJECT_API_NAME from '@salesforce/schema/CONF_LookupConfiguration__c.ObjectAPIName__c';
import DISPLAY_FIELDS from '@salesforce/schema/CONF_LookupConfiguration__c.DisplayFields__c';
import SEARCH_FIELDS from '@salesforce/schema/CONF_LookupConfiguration__c.SearchFields__c';
import DEVELOPER_NAME from
    '@salesforce/schema/CONF_LookupConfiguration__c.DeveloperName__c';
import DISPLAY_NAME from '@salesforce/schema/CONF_LookupConfiguration__c.Name';
import BASIC_FILTER from '@salesforce/schema/CONF_LookupConfiguration__c.BasicFilter__c';
// import SOURCE_VALUES from '@salesforce/schema/CONF_LookupConfiguration__c.';

export default class DebugModelController extends StaticallyComparable {
    // === PROPERTY: isDebuggingEnabledForApplication ===
    isDebuggingEnabledForApplication = false;

    // === PROPERTY: debuggingEnabledSubscriber ===
    debuggingEnabledSubscriber = value => {
        this.mc('debug').isDebuggingEnabledForApplication = value;
    };

    // === METHOD: subscribeToDebugModeUpdates ===
    subscribeToDebugModeUpdates () {
        const { engineId } = this.mc('staticConfig');
        registerDebuggingEnabledSubscriber(
            engineId, this.debuggingEnabledSubscriber
        );
    }

    // === METHOD: unsubscribeFromDebugModeUpdates ===
    unsubscribeFromDebugModeUpdates () {
        const { engineId } = this.mc('staticConfig');
        deregisterDebuggingEnabledSubscriber(
            engineId, this.debuggingEnabledSubscriber
        );
    }

    // === PROPERTY: debugLabel ===
    debugLabel;

    // === PROPERTY: filterConfigDebugSymbol ===
    filterConfigDebugSymbol;

    // === PROPERTY: contextFilterDebugSymbol ===
    contextFilterDebugSymbol;

    // === PROPERTY: autofillMappingDebugSymbol ===
    autofillMappingDebugSymbol;

    // === PROPERTY: debugInstanceId ===
    debugInstanceId;

    // === PROPERTY: debuggerInitialized ===
    debuggerInitialized;

    // === METHOD: generateDebugInstanceId ===
    generateDebugInstanceId () {
        const {
            svmxFieldId,
            _tabName: tabName,
            rowId
        } = this.mc('staticConfig');

        const {
            resolvedTargetObjectApiName: targetObjectApiName,
            objectApiName,
            fieldApiName
        } = this.mc('schema');

        const instanceIdKeys = [];
        if (tabName) {
            instanceIdKeys.push(tabName);
        }

        if (rowId) {
            instanceIdKeys.push(rowId);
        }

        if (svmxFieldId) {
            instanceIdKeys.push(svmxFieldId);
        } else if (objectApiName && fieldApiName) {
            instanceIdKeys.push(objectApiName, fieldApiName);
        } else if (targetObjectApiName) {
            instanceIdKeys.push(targetObjectApiName);
        }

        return instanceIdKeys.join('.');
    }

    // === METHOD: initializeDebugger ===
    initializeDebugger () {
        if (this.debuggerInitialized) {
            return;
        }

        const debugInstanceId = this.generateDebugInstanceId();
        if (!debugInstanceId.length) {
            return;
        }

        const engineId = this.mc('staticConfig').engineId;

        this.lookupChangeDebugSymbol =
            getDebugSymbol(engineId, DEBUG_KEYS.ON_CHANGE, true, MAX_SNAPSHOTS_PER_INST);

        this.debuggerInitialized = true;
        this.debugInstanceId = debugInstanceId;

        this.mc('debug').isDebuggingEnabledForApplication = isDebuggingEnabled(engineId);
        this.subscribeToDebugModeUpdates();
    }

    // === METHOD: getChangeDebugSnapshot ===
    getChangeDebugSnapshot () {
        const snapshot = {
            fieldLabel: this.debugLabel || this.mc('staticConfig').label,
            tabName: this.mc('staticConfig')._tabName,
            rowId: this.mc('staticConfig').rowId
        };

        if (!snapshot.fieldLabel) {
            snapshot.fieldLabel = this.mc('schema').targetObjectLabel;
        }

        if (this.mc('staticConfig').lookupConfigId && this.mc('staticConfig').lookupConfig) {
            snapshot.lookupConfigId = this.mc('staticConfig').lookupConfigId;
            snapshot.lookupFilterName =
                getValue(this.mc('staticConfig').lookupConfig, DISPLAY_NAME);
            snapshot.developerName = getValue(this.mc('staticConfig').lookupConfig, DEVELOPER_NAME);
            snapshot.objectApiName =
                getValue(this.mc('staticConfig').lookupConfig, OBJECT_API_NAME);
            snapshot.objectLabel = this.mc('schema').targetObjectLabel;
            snapshot.fieldsReturned =
                getValue(this.mc('staticConfig').lookupConfig, FIELD_TO_RETURN);
            snapshot.searchFields = getValue(this.mc('staticConfig').lookupConfig, SEARCH_FIELDS);
            snapshot.displayFields = getValue(this.mc('staticConfig').lookupConfig, DISPLAY_FIELDS);
            snapshot.conditionExpressionId =
                getValue(this.mc('staticConfig').lookupConfig, BASIC_FILTER);
            snapshot.sourceValues = '';
        }

        snapshot.canLookupContextBeOverridden = this.mc('contextSearch')._overrideLookupContext;
        snapshot.isLookupContextOverridden = this.mc('contextSearch').isLookupContextOverridden;
        snapshot.contextMatchingField = this.mc('schema').lookupMatchingField;
        snapshot.contextMatchingValueField = this.mc('contextSearch').lookupContext;
        snapshot.foundMatch = this.mc('results').searchResultIds?.length > 0;

        if (this.mc('staticConfig').formFillMappingId) {
            snapshot.formFillMappingId = this.mc('staticConfig').formFillMappingId;
        }

        return snapshot;
    }

    // === METHOD: pushChangeDebugSnapshot ===
    pushChangeDebugSnapshot () {
        if (this.lookupChangeDebugSymbol) {
            const snapshot = this.getChangeDebugSnapshot();
            pushDebugSnapshot(this.lookupChangeDebugSymbol, this.debugInstanceId, snapshot);
        }
    }
}