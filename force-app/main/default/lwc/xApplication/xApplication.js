/* eslint-disable no-unused-expressions */
export * from './intents';

// Public Symbols
export const InitApplication = Symbol.for('@@xApplication.InitApplication@@');
export const RegisterApplication = Symbol.for('@@xApplication.RegisterApplication@@');
export const RegisterComponent = Symbol.for('@@xApplication.RegisterComponent@@');
export const ApplicationId = Symbol.for('@@xApplication.ApplicationId@@');
export const ComponentRegistered = Symbol.for('@@xApplication.ComponentRegistered@@');

// Private Symbols
const ApplicationInitialized = Symbol.for('@@xApplication.ApplicationInitialized@@');
const RequestListener = Symbol.for('@@xApplication.RequestListener@@');
const RequestCallbackPromise = Symbol.for('@@xApplication.RequestCallbackPromise@@');

const APPLICATION_ID_REQUEST_EVENT = 'requestapplicationid';

export const ApplicationMixin = BaseClass => class extends BaseClass {
    _queuedIdHandlers = [];

    [InitApplication] () {
        if (!this[ApplicationInitialized]) {
            this.addEventListener(APPLICATION_ID_REQUEST_EVENT, this[RequestListener].bind(this));
            this[ApplicationInitialized] = true;
        }
    }

    [RegisterApplication] (applicationId) {
        this[ApplicationId] = applicationId;

        if (this._queuedIdHandlers?.length) {
            this._queuedIdHandlers.forEach(handler => {
                handler(this[ApplicationId]);
            });

            this._queuedIdHandlers = [];
        }
    }

    [RequestListener] (e) {
        e.preventDefault();
        e.stopPropagation();

        if (this[ApplicationId]) {
            e.detail?.(this[ApplicationId]);
        } else if (e.detail && typeof e.detail === 'function') {
            this._queuedIdHandlers.push(e.detail);
        }
    }
};

export const ComponentMixin = BaseClass => class extends BaseClass {
    async [RegisterComponent] () {
        if (!this[RequestCallbackPromise]) {
            let callback;
            this[RequestCallbackPromise] = new Promise(resolve => {
                callback = resolve;
            });

            this.dispatchEvent(
                new CustomEvent(
                    APPLICATION_ID_REQUEST_EVENT,
                    {
                        detail: callback,
                        bubbles: true,
                        composed: true
                    }
                )
            );

            const applicationId = await this[RequestCallbackPromise];
            delete this[RequestCallbackPromise];

            this[ApplicationId] = applicationId;
            this[ComponentRegistered]?.();
            return applicationId;
        }

        await this[RequestCallbackPromise];
        return this[ApplicationId];
    }
};