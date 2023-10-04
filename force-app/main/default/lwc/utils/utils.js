import { LightningElement } from 'lwc';

export * from './a11yUtils'
export * from './api/index.js';
export * from './cacheUtils.js';
export * from './comparisonUtils.js';
export * from './expression.js';
export * from './usageInsights.js';
export {
    sortObjectArray,
    arraysEqual,
    groupByObject,
} from './arrayUtils';
export {
    addDays,
    addMonths,
    calculateDateDiffInDays,
    formatDateValue,
    formatDateTimeToApexDateString,
    getDateTimeValue,
    getTimeValue,
    TIMEZONE_GMT,
    isValidDate
} from './dateUtils';
export {
    ASSET_HIERARCHY_ORDER,
    ASSET_HIERARCHY_ORDER_TO_ROOT_OBJECT,
    FIELD_DATA_TYPES,
    MAPPING_TYPES,
    VALUE_INPUT_FIELD_CONTEXT,
    PAGE_ACTION_TYPES,
    OPERATOR_TYPES,
    OPERATOR_OPTIONS_BY_TYPE,
    OPERATOR_OPTIONS_BY_FIELD_TYPE,
    OPERATOR_VALUE,
    OPERATOR_MAP,
    DATA_TYPE_ICONS,
    DATE_TIME_FUNCTION_LITERALS,
    UNSUPPORTED_FIELD_TYPES,
    OBJECT_ICONS,
    OBJECT_DEFAULT_ICON,
    TRANSACTION_API_NAME,
    SEARCH_TEXT_OPERATOR_TYPES,
    EXPRESSION,
    STEP_TYPES,
    STEP_TYPE_ICONS,
    STEP_PARAMETER_TYPES,
    FIELD_API_NAMES,
    CUSTOM_FIELD_DATA_TYPES,
    UNSUPPORTED_UI_API_OBJECTS,
    FUNCTION_LITERALS,
    PAGE_ELEMENT_TYPES,
    PAGE_ELEMENT_EVENT_TYPES,
    PAGE_ELEMENT_ACTION_TYPES,
    PAGE_ELEMENT_STATIC_ACTIONS,
    OBJECT_MAPPING_TYPES,
    ROW_ACTION_TYPES,
    MAPPING_TYPE,
    ADMIN_MODULES,
    OPERATION_TYPES,
    UNSUPPORTED_EVENT_FIELDS,
    ASSET_HIERARCHY_LOCALSTORAGE,
    SUPPORTED_USER_FIELDS,
    SUPPORTED_TRANSACTION_FIELDS,
    TEXTOPERATORS
} from './constants';
export {
    isAddressField,
    isBase64Field,
    isBooleanField,
    isComboboxField,
    isCurrencyField,
    isDateField,
    isDatetimeField,
    isDoubleField,
    isEmailField,
    isEncryptedField,
    isIdField,
    isIntegerField,
    isLocationField,
    isLongField,
    isMultiPicklistField,
    isPercentField,
    isPhoneField,
    isPicklistField,
    isReferenceField,
    isStringField,
    isTextAreaField,
    isTimeField,
    isUrlField,
} from './metadataUtils';
export {
    normalizeString,
    normalizeDeveloperName,
    populateExpressionDeveloperName,
    normalizeBoolean,
    normalizeArray,
    normalizeFieldApiName
} from './normalize';
export {
    isIE11,
    isChrome,
    isSafari,
    isFirefox
} from './browser';
export * from './deviceUtils';
export { handleMenuSelection, getPageReference } from './navigationUtils';
export {
    getMappingTypeOptions,
    getFunctionMappingOptions,
    getCompatibleFieldsForFieldMapping,
    executeObjectMapping,
    getFunctionExpressionOptions,
    getLookupFunctionExpressionOptions,
    convertValueToNumber,
    isValidURL,
    isValidEmail,
    isValidPhone,
} from './objectMappingUtils';
export {
    normalizeVariant,
    VARIANT,
    classListMutation,
    PHONE_REGEXP_STRING,
    TEXT_REGEXP_STRING,
    validateExpression,
    copyToClipboard,
    isValidInput
} from './inputUtils';
export * from './element';
export * from './validity';
export { guid } from './guid';
export {
    cellFormatterByType,
    getColumns,
    isReadonlySystemField,
    shouldDisableField,
    isRequiredField,
    getLookupReferenceToObject,
    getLookupReferenceNameFields,
    castFieldToSupportType,
    transformChildRecordData,
    transformRecordForSave,
    transformRecordForFlow,
    RUNTIME_CONTEXT,
    TRANSACTION_TYPE,
    AVAILABLE_ACTIONS_FLOW_FOOTER,
    recordActions,
    isFlowContext,
    isTransactionContext,
    transformRecordTypesByPicklist,
    transformRecordTypes,
    transformObjectDefinition,
    handleObjectFieldDependencies,
    PUBSUB_KEYS,
    PROPERTY_NAMES,
    PROPERTY_TYPES,
    enableAdvanceLookupSearch,
    sortingSectionElements,
    createActionConfigFromElement,
    filterRecords,
    isRecordPageContext,
} from './runtimeUtils';
export { classSet } from './classSet';
export { keyCodes } from './keyboard';
export { InteractingState } from './interacting';
export { FocusState } from './focusState';
export { EventEmitter } from './eventEmitter';
export { getObservableObject, getObservableClass } from './proxyUtils';
export { isElementOverflowingViewport } from './positionUtils';
export { isImageFromStaticResource } from './iconUtils';
export { isInCorrectDetail, getNameField, getNameFieldFromFieldMetadata,
    getObjectNameFromFieldMetadata, LOOKUP_OPERATOR_OPTIONS } from './lookupUtils'
export { queryFocusable } from './queryFocusable';
export { raf } from './raf';
export {
    populateAttributeForLaunchingWizardStep,
    getRelationshipFieldValue,
    computeStepIconName } from './wizardUtils'
export { flatten, flattenById, arrayToTree, getAssetDisplayColumns } from './hierarchyUtils';
export * from './displayToken';

import * as ICON_NAMES from './iconConstants';
export { ICON_NAMES };

import * as ROUTES from './routeConstants';
export { ROUTES };

import * as NAVIGATION_ITEMS from './navigationItems';
export { NAVIGATION_ITEMS };

export function assert (condition, message) {
    // eslint-disable-next-line no-undef
    // eslint-disable-next-line dot-notation
    if (window['process'] && window['process'].env.NODE_ENV !== 'production') {
        if (!condition) {
            throw new Error(message);
        }
    }
}

export { resolveLiterals, dateTimeLiterals } from './literals';
/**
 * Normalize the given error object.
 * @param  {Error | Object} Either a javascript Error or an error emitted from LDS (ErrorResponse).
 * @return {String} A string error message
 */
export const parseErrorMessage = error => {
    let errorMsg = 'Unknown Error';

    if (typeof error === 'string') {
        errorMsg = error;
    } else if (error.message && typeof error.message === 'string') {
        errorMsg = error.message;
    } else if (Array.isArray(error.body) && error.body.length > 0) {
        errorMsg = error.body.map(e => e.message).join(', ');
    } else if (error.body && typeof error.body.message === 'string') {
        errorMsg = error.body.message;
    } else if (error.body?.output?.errors?.length) {
        errorMsg = error.body.output.errors.map(err => {
            const errParts = [];
            if (err.errorCode) {
                errParts.push(err.errorCode);
            }
            errParts.push(err.message);
            return errParts.join(': ');
        }).join('\n');
    }

    return errorMsg;
};

/**
 * Checks if the value provided is null or undefined.
 * @param {*} value 
 * @return {Boolean} True if the value is null or undefined.
 */
export const isUndefinedOrNull = (value) => {
    return value === null || value === undefined;
}

/**
 * Checks if the value provided is not null or undefined.
 * @param {*} value 
 * @return {Boolean} True if the value is not null or undefined
 */
export const isNotUndefinedOrNull = (value) => {
    return !isUndefinedOrNull(value);
}

/**
 * Checks if the value provided is an empty string (null, undefined, and empty string).
 * @param {*} value
 * @return {Boolean} True if the string is empty, null or undefined. Otherwise, returns false.
 */
export const isEmptyString = value => {
    return (
        isUndefinedOrNull(value) ||
        (typeof value === 'string' && value.trim() === '')
    );
};

/**
 * Checks if the value provided is an empty array.
 * @param {*} value
 * @return {Boolean} True if the array is empty. Otherwise, returns false.
 */
export const isEmptyArray = value => {
    return Array.isArray(value) && !value.length;
};

/**
 * Returns true if the given value is a LightningElement.
 * @param {*} value
 */
export function isLightningElement (value) {
    return value && typeof value === 'object' && value instanceof LightningElement;
}

/**
 * Returns true if the given value is a SecureElement.
 * @param {*} value 
 * @returns 
 */
export function isElement (value) {
    return value && typeof value === 'object' && value instanceof Element;
}

/**
 * Formats a string containing placeholder values. Example: formatString('Hi {0}', 'John') will
 * return 'Hi John'.
 * @param {String} str - the string value containing placeholders that will be replaced with
 *                  values provided in the args parameter. 
 * @param  {...any} args - any number of arguments that will be used to in place of the
 *                  placeholders in the str parameter 
 * @return {String} A formatted string where the placeholders have been replaced with the values
 *                  provided in args
 */
/* eslint-disable @lwc/lwc/no-rest-parameter */
export const formatString = (str, ...args) => {
    return str.replace(/{(\d+)}/g, (match, i) => {
        return args[i];
    });
}
/* eslint-enable */

/**
 * Deep clones a given value.
 * @param {*} obj - Value to clone
 * @returns Deep clone of the passed value;
 */
export function deepCopy (obj) {
    if (Object(obj) !== obj) {
        return obj;
    }
    if (obj instanceof Set) {
        return new Set(obj);
    }
    if (obj instanceof Date) {
        return new Date(obj);
    }
    if (typeof obj === 'function') {
        return obj.bind({});
    }
    if (Array.isArray(obj)) {
        const obj2 = [];
        const len = obj.length;
        for (let i = 0; i < len; i++) {
            obj2.push(deepCopy(obj[i]));
        }
        return obj2;
    }
    const result = Object.create({});

    let keys = Object.keys(obj);
    if (obj instanceof Error) {
        keys = Object.getOwnPropertyNames(obj);
    }

    const len = keys.length;
    for (let i = 0; i < len; i++) {
        const key = keys[i];
        result[key] = deepCopy(obj[key]);
    }
    return result;
}

/**
 * Recursively freezes an object, preventing future modifications at any level
 * @param {*} obj - The object or array to freeze
 * @returns - The original value, now recursively frozen
 */
export function deepFreeze (obj) {
    // Retrieve the property names defined on object
    const propNames = Object.getOwnPropertyNames(obj);

    // Freeze properties before freezing self
    // eslint-disable-next-line @lwc/lwc/no-for-of
    for (const name of propNames) {
        const value = obj[name];
        if (value && typeof value === 'object') {
            deepFreeze(value);
        }
    }

    return Object.freeze(obj);
}

/**
 * Returns a recursively frozen deep copy of the given object, preventing future modifications at
 * any level
 * @param {*} obj - The object or array to copy and freeze
 * @returns - The copied value, now recursively frozen
 */
export function frozenDeepCopy (obj) {
    const clonedObj = deepCopy(obj);
    return deepFreeze(clonedObj);
}

export function isRTL () {
    return document.dir === 'rtl';
}

/**
 * Retrieves a nested value from an object given a dot-delimited path string.
 * Short circuits for an early return if the accessed value is ever undefined or null.
 * @param {Object} obj - The object to retrieve the nested value from.
 * @param {string} path - The dot-delimited path to retrieve the target value from.
 */
export function getNestedValue (obj = {}, path = '') {
    const pathParts = path.split('.');
    let value = obj;

    while (pathParts.length && value != null) {
        const pathPart = pathParts.shift();
        if (!isEmptyString(pathPart))
            value = value[pathPart];
    }

    return value;
}

/**
 * Returns the active elements at each shadow root level
 * @returns {Array} Active Elements  at each shadow root level
 */
export function getShadowActiveElements () {
    let activeElement = document.activeElement;
    const shadowActiveElements = [];
    while (
        activeElement &&
        activeElement.shadowRoot &&
        activeElement.shadowRoot.activeElement
    ) {
        shadowActiveElements.push(activeElement);
        activeElement = activeElement.shadowRoot.activeElement;
    }
    if (activeElement) {
        shadowActiveElements.push(activeElement);
    }
    return shadowActiveElements;
}

const DEFAULT_ZINDEX_BASELINE = 9000;
/**
 * Returns the zIndex baseline from slds zIndex variable --lwc-zIndexModal.
 * @returns {Number} zIndex baseline
 */
export function getZIndexBaseline () {
    const value = (
        window.getComputedStyle(document.documentElement) ||
        document.documentElement.style
    ).getPropertyValue('--lwc-zIndexModal');

    const base = parseInt(value, 10);

    return isNaN(base) ? DEFAULT_ZINDEX_BASELINE : base;
}

/**
 * Populates a nested value from an object given a dot-delimited path string.
 * Auto-populates nested objects as necessary along the given path.
 * @param {Object} obj - The object to populate the data into.
 * @param {string} path - The dot-delimited path where the target value should be populated.
 * @param {*} value - The target value to populate.
 */
export function setNestedValue (obj = {}, path = '', value) {
    const pathParts = path.split('.');
    let holder = obj;

    while (pathParts.length > 1) {
        const pathPart = pathParts.shift();

        if (!holder[pathPart]) {
            holder[pathPart] = {};
        }

        holder = holder[pathPart];
    }
    holder[pathParts[0]] = value;

    return value;
}
export function requestAnimationFrameAsPromise () {
    return new Promise(resolve => {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        requestAnimationFrame(() => resolve());
    });
}


/**
* Creates a debounced function that delays invoking `func` until after `delay` milliseconds 
* have elapsed since the last time the debounced function was invoked.
* @param {Function} func - The function to debounce
* @param {Number} delay - The number of milliseconds to delay
* @return {Function} - debounced function
*/
export function debounce (func, delay) {
    let timer;

    return function debounced () {
        const args = Array.prototype.slice.apply(arguments);

        clearTimeout(timer);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        timer = setTimeout(function () {
            func.apply(this, args);
        }, delay);
    };
}

export function timeout (interval) {
    return new Promise(resolve => {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(resolve, interval);
    });
}

export function animationFrame () {
    return new Promise(resolve => {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        window.requestAnimationFrame(resolve);
    });
}

export function chunk (array, argSize = 1) {
    const size = Math.max(Number(argSize), 0);
    const length = array == null ? 0 : array.length
    if (!length || size < 1) {
        return []
    }
    let index = 0
    let resIndex = 0
    const result = new Array(Math.ceil(length / size))

    while (index < length) {
        result[resIndex++] = array.slice(index, (index += size))
    }
    return result
}