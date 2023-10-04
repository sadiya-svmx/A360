import { api, LightningElement, track } from 'lwc';
import { EngineElement }  from 'c/runtimeEngineProvider';
import {
    IS_MOBILE_DEVICE,
    isFlowContext,
    classSet
} from "c/utils";
const DELAY_TIMEOUT = 100;

export default class RuntimeHeader extends EngineElement(LightningElement) {

    @track sections= [];
    @track loading = true;
    @track hasFormError = false;
    @track engineId;
    runtimeContext;

    @api
    reportAllValidity () {
        const sections = [];
        this.template.querySelectorAll('c-runtime-section').forEach(section => {
            sections.push(section.reportAllValidity());
        });
        return sections;
    }

    handleHeaderRecordModified  (event) {
        const { field } = event.detail;
        this.registerFieldValueChange(field);
    }

    registerFieldValueChange (record) {
        const fieldNameList = Object.keys(record || {});
        fieldNameList.forEach(fieldName => {
            this.props.handleHeaderFieldChange(fieldName, record[fieldName]);
        });
        if (this.hasFormError) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.props.applyValidation();
            }, DELAY_TIMEOUT);
        }
    }

    reportValidity = () => {
        return this.hasFormError;
    }

    get showCustomButton () {
        return IS_MOBILE_DEVICE &&  this.customActions.length;
    }

    get isFlowContext () {
        return isFlowContext(this.runtimeContext);
    }

    get fabContainerClass () {
        return classSet('svmx-fab_container')
            .add({ 'svmx-fab_container_flow': this.isFlowContext })
            .toString();
    }

    runtimeEngineUpdate (engineProps) {
        this.loading = engineProps.loadingStatus.LOADING_ENGINE_METADATA;
        this.sections = engineProps.sections;
        this.hasFormError = engineProps.hasError;
        this.engineId = engineProps.engineId;
        this.customActions = engineProps.buttons.filter(button => button.intents)
        this.runtimeContext = engineProps.runtimeContext;
    }
}