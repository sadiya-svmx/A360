/**
A string normalization utility for attributes.
@param {String} value - The value to normalize.
@param {Object} config - The optional configuration object.
@param {String} [config.fallbackValue] - The optional fallback value to use if the given value is
                not provided or invalid. Defaults to an empty string.
@param {Array} [config.validValues] - An optional array of valid values. Assumes all input is valid
                if not provided.
@return {String} - The normalized value.
**/
export function normalizeString (value, config = {}) {
    const { fallbackValue = '', validValues, toLowerCase = true } = config;
    let normalized = (typeof value === 'string' && value.trim()) || '';
    normalized = toLowerCase ? normalized.toLowerCase() : normalized;
    if (validValues && validValues.indexOf(normalized) === -1) {
        normalized = fallbackValue;
    }
    return normalized;
}

/**
A boolean normalization utility for attributes.
@param {Any} value - The value to normalize.
@return {Boolean} - The normalized value.
**/
export function normalizeBoolean (value) {
    return typeof value === 'string' || !!value;
}

/**
 * An array normalization utility for returning a valid array.
 * @param {Any} value - The value to normalize
 * @return {Array} - the normalized array
 */
export function normalizeArray (value) {
    if (Array.isArray(value)) {
        return value;
    }
    return [];
}

/**
 * Generates a developer API name from a string value. Removes all non-alphanumeric characters and
 * replaces all spaces with underscores. Also ensures the name starts with a letter.
 * 
 * @param {String} inputValue - The source input value to create the developer name from.
 * @param {Number} [maxLength=40] - The maximum length of the return value.
 * @param {String} [defaultValue=Record1] - The default value if the generated developer name
 *                  results in an empty string.
 * @return {String} A string value in a developer API format.
 */
export const normalizeDeveloperName = (inputValue, maxLength = 40, defaultValue = 'Record1') => {

    let output = '';

    if (inputValue && 0 < inputValue.length) {
        // replace non-alpha characters
        output = inputValue.replace(/[^A-Za-z0-9_\s]/g, '');
        // replace double spaces or underscores with single space
        output = output.trim().replace(/[_|\s]{2,}/, ' ');
        // replace space with underscore
        output = output.replace(/[ ]/g, '_');
        // Prefix string starting with a number with X
        output = output.replace(/^[0-9]/, (match) => { return 'X' + match; });
        // truncate to maxLength
        output = (output.length > maxLength) ? output.substring(0, maxLength) : output;
        // replace ending underscores
        output = output.replace(/[_]+$/, '');
    }

    return (output.length === 0) ? defaultValue : output;
}

/**
 * Generates a Expression developer API name from a string value.
 * 
 * @param {String} inputValue - The source input value to create the developer name from.
 * @param {Number} [maxLength=40] - The maximum length of the return value.
 * @return {String} A string value in a developer API format.
 */
export const populateExpressionDeveloperName = (inputValue, maxLength = 40) => {

    let expDeveloperName = inputValue+JSON.parse(JSON.stringify(new Date()));
    // truncate to maxLength
    expDeveloperName =  (expDeveloperName.length > maxLength) ?
        expDeveloperName.substring(0, maxLength) : expDeveloperName;
    return expDeveloperName;
}

export const normalizeFieldApiName = (fieldApiName) => {
    return  fieldApiName.endsWith("__r")
        ? fieldApiName.replace("__r", "__c")
        : fieldApiName.endsWith("Id") || fieldApiName.endsWith("__c")
            ? fieldApiName
            : fieldApiName + "Id";
}