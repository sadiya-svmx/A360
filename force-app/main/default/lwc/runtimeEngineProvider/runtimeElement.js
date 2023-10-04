/*
    This class middle ware between Redux and Engine
*/
import { LightningElement } from 'lwc';
import { Redux } from 'c/lwcRedux';

const getEngine = (thisArg, callback) =>{
    const eventStore = new CustomEvent('get_runtime_engine', { bubbles: true,
        composed: true,
        detail: (engine)=>{
            callback(engine);
        } })
    thisArg.dispatchEvent(eventStore);
}

export default class RuntimElement extends Redux(LightningElement) {

    engine = null;

    connectedCallback () {
        getEngine(this, (engine) => {
            this.engine = engine;
            super.connectedCallback();
        });
    }

    mapStateToProps (state) {
        if (this.runtimeEngineUpdate && state && !state.blockApplication) {
            this.runtimeEngineUpdate(state);
        }
    }

    mapDispatchToProps () {
        return this.engine.getEngineInterfaces();
    }
}