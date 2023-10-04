import {
    getObservableClass,
    getDifferencesBetweenObjects,
    StaticallyComparable
} from 'c/utils';

function getModelState (modelController) {
    const modelState = {};
    modelController.passthroughs.forEach((_subModelName, propertyName) => {
        modelState[propertyName] = modelController[propertyName];
    });
    return modelState;
}

function notifyPropertyChanged (compInstance, mappingForProperty, newValue) {
    if (typeof mappingForProperty === 'string') {
        compInstance[mappingForProperty] = newValue;
    } else if (Array.isArray(mappingForProperty)) {
        mappingForProperty.forEach(mappingEntry => {
            compInstance[mappingEntry] = newValue;
        });
    } else if (typeof mappingForProperty === 'function') {
        mappingForProperty.call(compInstance, newValue);
    }
}

function notifyModelChanged (modelController, propertiesChanged) {
    Object.keys(propertiesChanged || {}).forEach(propertyName => {
        const newPropertyValue = propertiesChanged[propertyName].new;
        const mappingForProperty = modelController.propertyMapping[propertyName];
        if (mappingForProperty) {
            notifyPropertyChanged(
                modelController.getComponent(),
                mappingForProperty,
                newPropertyValue
            );
        }
    });
}

// TODO: Look into using Symbols for submodel keys to prevent external code from directly accessing
// submodels.

/**
 * Creates a wrapper model around each of the sub-models, with specific properties acting
 * as "passthrough" properties for accessibility. Properties that are not "passthrough" should
 * be treated as private by external code.
 * @param {*} compInstance - LWC component instance to attach to.
 * @param {*} compPropertyMapping - Property mapping configuration between the model and
 *  component-level properties.
 */
export function generateModelController (compInstance, compPropertyMapping = {}, subModelMap = {}) {
    if (!compInstance) {
        throw new Error('Reference to the component instance must be passed.');
    }

    // eslint-disable-next-line prefer-const
    let modelController;

    let previousModelState = {};
    const modelChangedCallback = () => {
        const newModelState = getModelState(modelController);
        const modelDifferences = getDifferencesBetweenObjects(previousModelState, newModelState);
        previousModelState = newModelState;
        notifyModelChanged(modelController, modelDifferences);
    };

    modelController = {
        getComponent: () => (compInstance),
        modelChangedCallback,
        propertyMapping: compPropertyMapping
    };

    // Wire all submodel definitions into the top-level model controller
    for (const subModelName in subModelMap) {
        if (Object.prototype.hasOwnProperty.call(subModelMap, subModelName)) {
            const subModel = subModelMap[subModelName];

            addSubModel(
                modelController,
                subModelName,
                subModel,
                modelChangedCallback
            );
        }
    }

    // Originally wrote a Proxy implementation for this, but it appears that @wire input listeners
    // can't detect changes to proxied properties. Instead, a getter/setter is defined directly
    // on the root modelController for each passthrough property.
    modelController.passthroughs.forEach((subModelName, propertyName) => {
        Object.defineProperty(modelController, propertyName, {
            get () {
                const subModel = this[subModelName];
                const passthroughPropertyValue = subModel[propertyName];

                if (typeof passthroughPropertyValue === 'function') {
                    const originalFunction = passthroughPropertyValue;
                    return function () {
                        return originalFunction.apply(
                            subModel,
                            Array.prototype.slice.call(arguments)
                        );
                    };
                }

                return passthroughPropertyValue;
            },

            set (value) {
                const subModel = this[subModelName];
                subModel[propertyName] = value;
            },

            enumerable: true,
            configurable: false
        });
    });

    // Trigger change handler to bind initial values
    notifyModelChanged(modelController,
        getDifferencesBetweenObjects({}, getModelState(modelController))
    );

    return modelController;
}

function addSubModel (modelController, subModelName, subModel, modelChangedCallback) {
    if (!(subModel instanceof StaticallyComparable)) {
        throw new Error(
            `Invalid submodel definition. Must be an instance of utils.StaticallyComparable`
        );
    }

    let passthroughs = modelController.passthroughs;
    if (!passthroughs) {
        modelController.passthroughs = passthroughs = new Map();
    }

    const subModelPropertiesForPassthrough = new Set(
        Object.keys(subModel).concat(
            Object.getOwnPropertyNames(subModel.constructor.prototype)
        )
    );

    subModelPropertiesForPassthrough.delete('constructor');

    subModelPropertiesForPassthrough.forEach(property => {
        if (passthroughs.has(property)) {
            throw new Error(
                `Duplicate submodel key found: ${subModelName}.${property}.` +
                `Submodel property names must be unique across all submodels.`
            )
        }
        passthroughs.set(property, subModelName);
    });

    Object.defineProperty(subModel, 'getComponent', {
        enumerable: false,
        configurable: false,
        writable: false,
        value: () => modelController.getComponent()
    });

    Object.defineProperty(subModel, 'mc', {
        enumerable: false,
        configurable: false,
        writable: false,
        value: (modelName) => modelController[modelName]
    });

    //modelController[subModelName] = getObservableClass(subModel, modelChangedCallback);
    Object.defineProperty(modelController, subModelName, {
        enumerable: false,
        configurable: false,
        writable: false,
        value: getObservableClass(subModel, modelChangedCallback)
    });
}