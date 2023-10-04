import { LightningElement, track, api } from "lwc";
import RuntimeElement from './runtimeElement';

export default class RuntimeEngineProvider extends LightningElement {
  @track loadCompleted;
  @api engine;
  async connectedCallback () {
      this.template.addEventListener(
          "get_runtime_engine",
          this.handleGetRuntimeEngine.bind(this)
      );
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.loadCompleted = true;
  }

  handleGetRuntimeEngine (event) {
      event.stopPropagation();
      const callback = event.detail;
      callback(this.engine);
  }
}

export const EngineElement = () => {
    return RuntimeElement
}