import {
    initialize,
    handleHeaderFieldChange,
    handleChildRecordChange,
    handleAddTemporaryChildLine,
    initializeDebugConsole,
    handleAddMultipleLines,
    handleTemporaryChildRecordChange,
    handleCommitTemporaryChildLine,
    save,
    flowRecordAction,
    handleCloneChildLine,
    applyValidation,
    reInitializeState,
    handleIsDebugEnabled,
    generateFormattedExpressionForObject,
    generateFormattedMappingForObject,
} from './actions';

import {
    getInitialState
} from './reducer';

import {
    initializeEngine,
    destroyEngine,
    discardTemporaryChildLine,
    editTemporaryChildLine,
    deleteChildLines,
    selectedChildLines,
} from './createActions';

import {
    executeCustomActionOnButton
} from './customActions';

const engineRef = {};

/*
    This class responsible for creating engine and main interface for engine,
    and keeping store and dispatching actions.

*/

export default class Engine {
    _store = null;
    _apis = null;
    _engineId = null;

    constructor (engineId) {
        this._engineId = engineId;
    }

    initialize (
        store,
        apis,
        developerName,
        headerRecordData,
        pageDataConfig,
        childRecordData,
        context,
    ) {
        this.store = store;
        this.apis = apis;
        this.store.dispatch(initializeEngine(this._engineId, getInitialState()));
        this.store.dispatch(initialize(
            developerName,
            headerRecordData,
            pageDataConfig,
            childRecordData,
            context,
        ));
    }

    uninitialize () {
        this.store.dispatch(destroyEngine(this._engineId));
    }

    set apis (apis) {
        this._apis = apis;
    }

    get apis () {
        return this._apis;
    }

    set store (store) {
        this._store = store;
    }

    get store () {
        return this._store;
    }

    static getInstance (engineId) {
        return engineRef[engineId];
    }

    static createEngine (engineId) {
        engineRef[engineId] = new Engine(engineId);
        return engineRef[engineId];
    }

    static destroyEngine (engineId) {
        if (engineRef[engineId]) {
            engineRef[engineId].uninitialize();
            delete engineRef[engineId];
        }
    }

    saveData () {
        return this.store.dispatch(save());
    }

    dispatchFlowRecords () {
        return this.store.dispatch(flowRecordAction());
    }

    resetEngineState () {
        return this.store.dispatch(reInitializeState());
    }

    getEngineInterfaces () {
        return {
            handleHeaderFieldChange,
            handleChildRecordChange,
            handleAddTemporaryChildLine,
            initializeDebugConsole,
            handleAddMultipleLines,
            handleTemporaryChildRecordChange,
            handleCommitTemporaryChildLine,
            discardTemporaryChildLine,
            editTemporaryChildLine,
            deleteChildLines,
            handleCloneChildLine,
            selectedChildLines,
            applyValidation,
            executeCustomActionOnButton,
            handleIsDebugEnabled,
            generateFormattedExpressionForObject,
            generateFormattedMappingForObject,
        }
    }
}