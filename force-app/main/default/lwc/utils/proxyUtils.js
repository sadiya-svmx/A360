import { areValuesEqual } from './utils';

function isPrimitive (value) {
    return (
        value === null ||
        (typeof value !== 'object' && typeof value !== 'function')
    );
}

function isSymbol (value) {
    return typeof value === 'symbol';
}

const TARGET = Symbol('target');

/**
 *
 * @param {Object} objToObserve - The object to intercept and observe changes to.
 * @param {Function} onChangeCallback - The callback function to invoke when changes are observed
 *                   on the objToObserve
 */
export const getObservableObject = (objToObserve, onChangeCallback) => {
    const propCache = new WeakMap();
    const proxyTarget = Symbol('ProxyTarget');
    const equals = Object.is;

    let _onChangeCallback = onChangeCallback;

    function getOwnPropertyDescriptor (target, property) {
        if (!propCache.has(target)) {
            propCache.set(target, new Map());
        }
        const props = propCache.get(target);

        if (props.has(property)) {
            return props.get(property);
        }

        const prop = Reflect.getOwnPropertyDescriptor(target, property);
        props.set(property, prop);

        return prop;
    }

    function setProperty (target, property, value, receiver, previous) {
        if (!equals(previous, value) || !(property in target)) {
            const descriptor = getOwnPropertyDescriptor(target, property);

            if (descriptor !== undefined && 'set' in descriptor) {
                return Reflect.set(target, property, value, receiver);
            }

            return Reflect.set(target, property, value);
        }

        return true;
    }

    function isSameDescriptor (a, target, property) {
        const b = getOwnPropertyDescriptor(target, property);

        return a !== undefined &&
            b !== undefined &&
            Object.is(a.value, b.value) &&
            (a.writable || false) === (b.writable || false) &&
            (a.enumerable || false) === (b.enumerable || false) &&
            (a.configurable || false) === (b.configurable || false) &&
            a.get === b.get &&
            a.set === b.set;
    }

    function invalidateCachedDescriptor (target, property) {
        if (!propCache.has(target)) {
            return;
        }
        const props = propCache.get(target);
        props.delete(property);
    }

    const handler = {
        get (target, property, receiver) {
            if (isSymbol(property)) {
                if (property === proxyTarget || property === TARGET) {
                    return target;
                }
            }

            const value = Reflect.get(target, property, receiver);

            if (isPrimitive(value) || property === 'constructor') {
                return value;
            }

            // Preserve invariants
            const descriptor = getOwnPropertyDescriptor(target, property);
            if (descriptor && !descriptor.configurable) {
                if (descriptor.set && !descriptor.get) {
                    return undefined;
                }
                if (descriptor.writable === false) {
                    return value;
                }
            }

            return new Proxy(value, handler);
        },
        set (target, property, value, receiver) {
            let _value = value;

            if (_value && _value[proxyTarget] !== undefined) {
                _value = _value[proxyTarget];
            }

            const reflectTarget = target[proxyTarget] || target;
            const previous = reflectTarget[property];
            const hasProperty = property in target;


            if (setProperty(reflectTarget, property, _value, receiver, previous)) {
                if (!equals(previous, _value) || !hasProperty) {
                    _onChangeCallback();
                }

                return true;
            }

            return false;
        },
        defineProperty (target, property, descriptor) {
            if (!isSameDescriptor(descriptor, target, property)) {
                if (!Reflect.defineProperty(target, property, descriptor)) {
                    return false;
                }

                invalidateCachedDescriptor(target, property);
                _onChangeCallback();
            }

            return true;
        },
        deleteProperty (target, property) {
            if (!Reflect.has(target, property)) {
                return true;
            }

            const result = Reflect.deleteProperty(target, property);

            invalidateCachedDescriptor(target, property);
            _onChangeCallback();

            return result;
        }
    };

    const proxy = new Proxy(objToObserve, handler);

    _onChangeCallback = _onChangeCallback.bind(proxy);

    return proxy;
};

getObservableObject.target = proxy => proxy[TARGET] || proxy;


/**
 *
 * @param {Object} classToObserve - The class to intercept and observe changes to, including
 *                   properties defined in the class's prototype.
 * @param {Function} onChangeCallback - The callback function to invoke when changes are observed
 *                   on the classToObserve
 */
export const getObservableClass = (classToObserve, onChangeCallback) => {
    const propCache = new WeakMap();
    const proxyTarget = Symbol('ProxyTarget');
    //const equals = Object.is;
    const equals = areValuesEqual;

    let _onChangeCallback = onChangeCallback;

    function getOwnPropertyDescriptor (target, property) {
        if (!propCache.has(target)) {
            propCache.set(target, new Map());
        }
        const props = propCache.get(target);

        if (props.has(property)) {
            return props.get(property);
        }

        const prop =
            // Check for immediately defined properties
            Reflect.getOwnPropertyDescriptor(target, property) ||

            // Fallback to properties defined in the prototype
            Reflect.getOwnPropertyDescriptor(
                Reflect.getPrototypeOf(target),
                property
            );

        props.set(property, prop);

        return prop;
    }

    function setProperty (target, property, value, receiver, previous) {
        if (!equals(previous, value) || !(property in target)) {
            const descriptor = getOwnPropertyDescriptor(target, property);

            if (descriptor !== undefined && 'set' in descriptor) {
                return Reflect.set(target, property, value, receiver);
            }

            return Reflect.set(target, property, value);
        }

        return true;
    }

    function isSameDescriptor (a, target, property) {
        const b = getOwnPropertyDescriptor(target, property);

        return a !== undefined &&
            b !== undefined &&
            Object.is(a.value, b.value) &&
            (a.writable || false) === (b.writable || false) &&
            (a.enumerable || false) === (b.enumerable || false) &&
            (a.configurable || false) === (b.configurable || false) &&
            a.get === b.get &&
            a.set === b.set;
    }

    function invalidateCachedDescriptor (target, property) {
        if (!propCache.has(target)) {
            return;
        }
        const props = propCache.get(target);
        props.delete(property);
    }

    const handler = {
        get (target, property, receiver) {
            if (isSymbol(property)) {
                if (property === proxyTarget || property === TARGET) {
                    return target;
                }
            }

            const value = Reflect.get(target, property, receiver);

            if (property === 'constructor' || isPrimitive(value)) {
                return value;
            }

            // Preserve invariants
            const descriptor = getOwnPropertyDescriptor(target, property);
            if (descriptor && !descriptor.configurable) {
                if (descriptor.set && !descriptor.get) {
                    return undefined;
                }
                if (descriptor.writable === false) {
                    return value;
                }
            }

            return new Proxy(value, handler);
        },
        set (target, property, value, receiver) {
            let _value = value;

            if (_value && _value[proxyTarget] !== undefined) {
                _value = _value[proxyTarget];
            }

            const reflectTarget = target[proxyTarget] || target;
            const previous = reflectTarget[property];
            const hasProperty = property in target;

            if (setProperty(reflectTarget, property, _value, receiver, previous)) {
                if (!equals(previous, _value) || !hasProperty) {
                    _onChangeCallback(
                        property,
                        _value
                    );
                }

                return true;
            }

            return false;
        },
        defineProperty (target, property, descriptor) {
            if (!isSameDescriptor(descriptor, target, property)) {
                if (!Reflect.defineProperty(target, property, descriptor)) {
                    return false;
                }

                invalidateCachedDescriptor(target, property);
                _onChangeCallback(property);
            }

            return true;
        },
        deleteProperty (target, property) {
            if (!Reflect.has(target, property)) {
                return true;
            }

            const result = Reflect.deleteProperty(target, property);

            invalidateCachedDescriptor(target, property);
            _onChangeCallback(property);

            return result;
        }
    };

    const proxy = new Proxy(classToObserve, handler);

    _onChangeCallback = _onChangeCallback.bind(proxy);

    return proxy;
};

getObservableClass.target = proxy => proxy[TARGET] || proxy;