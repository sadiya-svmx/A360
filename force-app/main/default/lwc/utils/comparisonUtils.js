/**
 * Used to denote a class whose defined set of internal properties will not change during runtime.
 */
export class StaticallyComparable {}

/**
 * 
 * @param {object} value - Value to retrieve comparable properties from.
 * @returns An array of all comparable property names. When <value> does not extend
 *  StaticallyComparable, returns the result of Object.keys.
 */
export function getComparableProperties (value) {
    if (!value) {
        return [];
    }

    if (value instanceof StaticallyComparable) {
        return getComparablePropertiesForClassInstance(value);
    }

    return Object.keys(value);
}

const EXCLUDED_COMPARABLE_PROPERTIES = new Set([
    'constructor',
    'hasOwnProperty',
    'isPrototypeOf',
    'propertyIsEnumerable',
    'toString',
    '__defineGetter__',
    '__defineSetter__',
    '__lookupGetter__',
    '__lookupSetter__'
]);

// Cache values previously referenced by getComparableProperties to prevent unnecessary recalcs
const ENUMERABLE_CLASS_PROPERTIES_CACHE = new WeakMap();

/**
 * Returns an array of all comparable property names in classInstance.
 * @param {object} classInstance - Value to retrieve the comparable properties from.
 * @returns An array of all comparable property names.
 */
export function getComparablePropertiesForClassInstance (classInstance) {
    if (classInstance == null || typeof classInstance !== 'object') {
        return [];
    }

    const classConstructor = classInstance.constructor;
    if (classConstructor && ENUMERABLE_CLASS_PROPERTIES_CACHE.has(classConstructor)) {
        return ENUMERABLE_CLASS_PROPERTIES_CACHE.get(classConstructor);
    }

    // Get descriptors for directly stored properties
    let allPropertyDescriptors = Object.getOwnPropertyDescriptors(classInstance);

    // Get descriptors for properties stored in prototype (ex: getters in ES6 classes)
    const instancePrototype = Object.getPrototypeOf(classInstance);
    if (instancePrototype != null) {
        allPropertyDescriptors = {
            ...allPropertyDescriptors,
            ...Object.getOwnPropertyDescriptors(instancePrototype)
        };
    }

    // Filter out properties that are excluded, or return a function.
    const comparableProperties = Object.entries(allPropertyDescriptors)
        .filter(propertyDescriptorEntry => {
            const [ propertyDescriptorName, propertyDescriptor ] = propertyDescriptorEntry;

            return !EXCLUDED_COMPARABLE_PROPERTIES.has(propertyDescriptorName) &&
                (
                    typeof propertyDescriptor.value !== 'function' ||
                    propertyDescriptor.get != null
                );
        })

        // Remap to property names
        .map(propertyDescriptorEntry => propertyDescriptorEntry[0]);

    ENUMERABLE_CLASS_PROPERTIES_CACHE.set(classConstructor, comparableProperties);

    return comparableProperties;
}

/**
 * Returns the data type of the target value as a string. Mostly the same behavior as "typeof",
 *  with the addition of 'array' when Array.isArray(val) === true and 'null' for null.
 * @param {*} val 
 * @returns Datatype of the target value as a string.
 */
export function getTypeAsString (val) {
    let valType = typeof val;
    if (val == null) {
        valType = 'null';
    } else if (Array.isArray(val)) {
        valType = 'array';
    }
    return valType;
}

/**
 * Checks value equality between two objects. Supports nested values.
 * @param {object} obj1 - First object to check
 * @param {object} obj2 - Second object to check
 */
export function areObjectsEqual (obj1, obj2) {
    const obj1Props = getComparableProperties(obj1);
    const obj2Props = getComparableProperties(obj2);

    if (obj1Props.length !== obj2Props.length) {
        return false;
    }

    for (let i = 0; i < obj1Props.length; i++) {
        const propName = obj1Props[i];

        const val1 = obj1[propName],
            val2 = obj2[propName];

        if (!areValuesEqual(val1, val2)) {
            return false;
        }
    }

    return true;
}

/**
 * Ccalculates the shallow value differences between two objects.
 * @param {object} obj1 - First object to compare
 * @param {object} obj2 - Second object to compare
 */
export function getDifferencesBetweenObjects (obj1, obj2) {
    const obj1Props = getComparableProperties(obj1);
    const obj2Props = getComparableProperties(obj2);
    const allProps = [...new Set([...obj1Props, ...obj2Props])];

    const differences = {};

    allProps.forEach(propName => {
        const val1 = obj1[propName],
            val2 = obj2[propName];
        if (!areValuesEqual(val1, val2)) {
            differences[propName] = {
                old: val1,
                new: val2
            };
        }
    });

    return differences;
}

/**
 * Checks value equality between two arrays. Supports nested values.
 * @param {object} arr1 - First array to check
 * @param {object} arr2 - Second array to check
 */
export function areArraysEqual (arr1, arr2) {
    if (!Array.isArray(arr1) || !Array.isArray(arr2)) {
        return false;
    }

    if (arr1.length !== arr2.length) {
        return false;
    }

    for (let i = 0; i < arr1.length; i++) {
        if (!areValuesEqual(arr1[i], arr2[i])) {
            return false;
        }
    }

    return true;
}

/**
 * Checks value equality between any two values. Supports nested values.
 * @param {object} val1 - First value to check
 * @param {object} val2 - Second value to check
 */
export function areValuesEqual (val1, val2) {
    const type1 = getTypeAsString(val1);
    const type2 = getTypeAsString(val2);

    if (type1 !== type2) {
        return false;
    }

    if (type1 === 'array') {
        return areArraysEqual(val1, val2);
    } else if (type1 === 'object') {
        return areObjectsEqual(val1, val2);
    } else if (type1 === 'function') {
        return val1.toString() === val2.toString();
    }

    return val1 === val2;
}