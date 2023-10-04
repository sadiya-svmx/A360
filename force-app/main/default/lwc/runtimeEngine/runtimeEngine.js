import engineReducer from './reducer';
import Engine from './engine';

const createEngineStore = () => {
    const combinedReducers = window.Redux.combineReducers(engineReducer);
    const middleware = window.Redux.applyMiddleware(window.ReduxThunk.default);
    return window.Redux.createStore(combinedReducers, middleware);
}

const createEngine = (
    engineId,
    store,
    apis,
    developerName,
    headerRecordData,
    pageDataConfig,
    childRecordData,
    context,
) => {
    const engine =  Engine.createEngine(engineId);
    engine.initialize(
        store,
        apis,
        developerName,
        headerRecordData,
        pageDataConfig,
        childRecordData,
        context
    );
    return engine;
}

const deleteEngine = (engineId) => {
    Engine.destroyEngine(engineId);
}

const bindEngineIdToStore = (
    baseStore,
    engineId,
) => {
    const modifiedStore = {
        ...baseStore,
        dispatch: (arg) => {
            if (typeof arg === 'function') {
                const engine = Engine.getInstance(engineId);
                return arg(modifiedStore.dispatch, modifiedStore.getState, engine);
            }

            return baseStore.dispatch({ ...arg, engineId });
        },

        getState: () => {
            const state = baseStore.getState();

            return state.runtimeEngine[engineId];
        },
    };

    return modifiedStore;
};

export * from './utils';

export {
    Engine,
    createEngineStore,
    createEngine,
    bindEngineIdToStore,
    deleteEngine
}