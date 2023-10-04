import { normalizeString } from './normalize';

// eslint-disable-next-line max-len
export const PHONE_REGEXP_STRING = '^([\\+][0-9]{1,3})?[ \\.\\-]?([\\(]{1}[0-9]{1,6}[\\)])?(( ?[0-9][ \\.\\-\\/]?){3,20})((x|ext|extension|m|mell|mellék)[ ]?[0-9]{1,4})?$';

export const TEXT_REGEXP_STRING = '^.*\\S.*$';

export const VARIANT = {
    STANDARD: 'standard',
    LABEL_HIDDEN: 'label-hidden',
    LABEL_STACKED: 'label-stacked',
    LABEL_INLINE: 'label-inline',
};

/**
A variant normalization utility for attributes.
@param {Any} value - The value to normalize.
@return {String} - The normalized value.
**/
export function normalizeVariant (value) {
    return normalizeString(value, {
        fallbackValue: VARIANT.STANDARD,
        validValues: [
            VARIANT.STANDARD,
            VARIANT.LABEL_HIDDEN,
            VARIANT.LABEL_STACKED,
            VARIANT.LABEL_INLINE,
        ],
    });
}

/**
 * A utility to modify an elements classlist by using a configuration object.
 * @param {*} classList - a collection of css class tokens
 * @param {*} config - a configuration object
 */
export function classListMutation (classList, config) {
    Object.keys(config).forEach(key => {
        if (typeof key === 'string' && key.length) {
            if (config[key]) {
                classList.add(key);
            } else {
                classList.remove(key);
            }
        }
    });
}

/**
 * A utility to validate logical expressions
 * @param {*} totalNumberOfRows - Total number of rows the expression has
 * @param {*} value - The value to be validated
 */
export function validateExpression (totalNumberOfRows, value) {
    if (!value) { return true;} // Blank expressions will get defaulted to 1 AND 2 AND etc . . . 
    // Create three stacks, one for parens, one for conditions, one for the integer values
    const openParenStack = [];
    const closedParenStack = [];
    const conditionStack = [];
    const valueStack = [];

    // Put the value to lower case so we ignore case (also using the i flag), and split an capture
    // the parts of the Expression using a Regex
    const regxToSplit = new RegExp(/(or|and)(?!\\w)|([()])|(\d+)/gi);
    const copyOfValue = value.toLowerCase();
    const tokenizedValues = copyOfValue.split(regxToSplit);

    // Iterate through the tokens, and put them on their correct stack. 
    // Fail if invalid order or token is found.
    let invalidTokenFound = false;
    let invalidTokenOrder = false;
    let invalidTautology = false;
    let invalidMixedOperatorsWithNoParens = false;
    let hasAndOperators = false;
    let hasOrOperators = false;
    let previousValidToken;
    let previousValidValue;
    tokenizedValues.forEach(token => {
        const trimToken = token ? token.trim() : token;
        // Push open parens and closed parens on to stacks, and then validate they are balanced.
        if (trimToken === '(') {
            openParenStack.push(trimToken);
            previousValidToken = trimToken;
        } else if (trimToken === ')') {
            closedParenStack.push(trimToken);
            if (previousValidToken !== undefined) {
                if (previousValidToken === '(') {
                    invalidTokenOrder = true;
                    return;
                }
            }
            previousValidToken = trimToken;
        } else if (trimToken === 'and' || trimToken === 'or') {
            conditionStack.push(trimToken);
            if (trimToken === 'and') {
                hasAndOperators = true;
            } else if (trimToken === 'or') {
                hasOrOperators = true;
            }
            if (previousValidToken !== undefined) {
                if (isNaN(Number(previousValidToken) ||
                previousValidToken !== '(' ||
                previousValidToken !== ')')) {
                    invalidTokenOrder = true;
                    return;
                }
            }
            previousValidToken = trimToken;
        } else if (trimToken === "" || trimToken === " " || trimToken === undefined) {
            // ignore these tokens
        } else if (!isNaN(Number(trimToken))) {
            valueStack.push(Number(trimToken));
            if (previousValidToken !== undefined) {
                if (previousValidToken !== 'and' &&
                previousValidToken !== 'or' &&
                previousValidToken !== '(' &&
                previousValidToken !== ')') {
                    invalidTokenOrder = true;
                    return;
                }
            }
            if (previousValidValue !== undefined) {
                if (previousValidValue === trimToken &&
                    (previousValidToken !== undefined &&
                        (previousValidToken === 'and' || previousValidToken === 'or'))) {
                    invalidTautology = true;
                    return;
                }
            }
            previousValidToken = trimToken;
            previousValidValue = trimToken;
        } else {
            invalidTokenFound = true;
        }
    });

    if (hasAndOperators
        && hasOrOperators
        && openParenStack.length === 0
        && closedParenStack.length === 0) {
        invalidMixedOperatorsWithNoParens = true;
    }

    // Check to make sure that all rows are being used.
    const maxValue = [...new Set(valueStack)].length;
    const allValuesUsed = maxValue === totalNumberOfRows;

    // Check to make sure that there is a condition for every pair of Integer values
    const validAmountOfConditions = conditionStack.length > 0
        ? conditionStack.length === valueStack.length - 1
        : valueStack.length === 1;

    // Finally, check to make sure that every row is utilized in the expression.
    let valueValidation = valueStack;
    for (let i = 1; i <= totalNumberOfRows; i++) {
        valueValidation = valueValidation.filter(numberToken => numberToken !== i);
    }

    return !invalidTokenFound
        && openParenStack.length === closedParenStack.length
        && valueValidation.length === 0
        && allValuesUsed
        && validAmountOfConditions
        && !invalidTautology
        && !invalidTokenOrder
        && !invalidMixedOperatorsWithNoParens;
}

/**
 * Utility that copies the provided string to the clipboard.
 * @param {*} value - The string to copy to the clipboard.
 * @return {Promise} - Null-value, represents the error-state after calling this function.
 */
export function copyToClipboard (value) {
    if (navigator.clipboard && navigator.clipboard.readText) {
        return navigator.clipboard.writeText(value);
    }

    // Fallback logic using document.execCommand
    const copyTargetElement = document.createElement('textarea');
    copyTargetElement.style = [
        'position: fixed',
        'top: -10rem',
        'height: 1px',
        'width: 1px',
    ].join(';');

    copyTargetElement.value = value;
    document.body.appendChild(copyTargetElement);

    copyTargetElement.select();
    const copySuccess = document.execCommand('copy');
    copyTargetElement.remove();

    return copySuccess ? Promise.resolve() : Promise.reject();
}

/**
 * Utility that check and report input component validity.
 * @param {*} inputComponentList - Input component list for the validity check.
 * @return Boolean - true or false - represents the validity-state of the component.
 */
export function isValidInput (inputComponentList) {
    const isValid = [...inputComponentList].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    return isValid;
}