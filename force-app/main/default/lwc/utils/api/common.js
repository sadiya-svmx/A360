import labelErrorExpectedPageDataResponse from '@salesforce/label/c.Error_ExpectedPageDataResponse';

/**
 * Checks the structure of the supplied value to determine if it "looks-like" a static field import.
 * @param {*} field The value to inspect.
 */
export function isStaticFieldImport (field) {
    return !!(field && field.objectApiName && field.fieldApiName);
}

/**
 * Converts a given object/field api combination to the same format as static field imports:
 *  EX: { objectApiName: 'Account', fieldApiName: 'ContactId' }
 * @param {string} objectApiName - Api name of the object that contains the target field
 * @param {string || Array[string] || uiApi.Field || Array[uiApi.Field]} fieldApiName - Api name of
 *  the target field
 * @returns {uiApi.Field} - Field in the static field import format
 */
export function convertToStaticFieldFormat (objectApiName, fieldApiName) {
    if (Array.isArray(fieldApiName)) {
        return fieldApiName.map(fieldApiNameEntry =>
            convertToStaticFieldFormat(objectApiName, fieldApiNameEntry));
    } else if (typeof fieldApiName === 'string') {
        let resolvedFieldApiName = fieldApiName;
        if (resolvedFieldApiName.startsWith(`${objectApiName}.`)) {
            resolvedFieldApiName =
                resolvedFieldApiName.substring(
                    objectApiName.length + 1,
                    resolvedFieldApiName.length
                );
        }
        return { objectApiName, fieldApiName: resolvedFieldApiName };
    }
    return fieldApiName;
}

/**
 * Converts a given object/field api combination to its fully-qualified variant: "Account.ContactId"
 * @param {string} objectApiName 
 * @param {string || Array[string] || uiApi.Field || Array[uiApi.Field]} fieldApiName - Api name of
 *  the target field
 * @returns {string} - Fully qualified field api
 */
export function convertToQualifiedFieldFormat (objectApiName, fieldApiName) {
    if (Array.isArray(fieldApiName)) {
        return fieldApiName.map(fieldApiNameEntry =>
            convertToQualifiedFieldFormat(objectApiName, fieldApiNameEntry));
    } else if (fieldApiName.objectApiName && fieldApiName.fieldApiName) {
        return `${objectApiName}.${fieldApiName.fieldApiName}`;
    }

    if (!fieldApiName.startsWith(`${objectApiName}.`)) {
        return `${objectApiName}.${fieldApiName}`;
    }
    return fieldApiName;
}

/**
 * Checks if the specified object or field name is custom
 * @param {string} apiName - The api name of the target entity
 */
export function isCustomObjectOrField (apiName = '') {
    return apiName.toLowerCase().endsWith('__c');
}

/**
 * Checks if the passed value "looks-like" a Salesforce Id.
 * @param {*} value 
 * @return {Boolean} True if the string looks like a Salesforce Id.
 */
export function isSalesforceId (value) {
    return !!value && /^[a-zA-Z0-9]{15}$|^[a-zA-Z0-9]{18}$/.test(value);
}
/**
Returns true if the API response was successful.
@param {Object} resp - The API Response object from a ServiceMax API Callout
@return {Boolean} - True, if the API request successful. Otherwise, false.
**/
export function verifyApiResponse (resp) {
    let success = false;

    if (resp && Object.prototype.hasOwnProperty.call(resp, 'success')) {
        success = resp.success;
    }

    return success;
}

/**
 * Returns true if the response structure is compatible with Config.PageDataResponse (Config.cls)
 * @param {Object} resp - The page data response object from a ServiceMax PageData API Callout.
 * @return {Boolean} - True, if the response structure is compatible with Config.PageDataResponse
 *  (Server-Side -> Config.cls -> PageDataResponse)
 */
export function isPageDataResponse (resp) {
    return !!(
      resp?.headerRecord ||
      resp?.data?.headerRecord
    );
}


/**
 * Throws an exception if the response structure is not compatible with Config.PageDataResponse
 * @param {Object} resp - The page data response object from a ServiceMax PageData API Callout.
 */
export function verifyIsPageDataResponse (resp) {
    if (!isPageDataResponse(resp)) {
        throw new Error(labelErrorExpectedPageDataResponse);
    }
}

/**
 * Verifies that the provided value "looks-like" a Record instance from from uiRecordApi.getRecord
 * or uiRecordApi.getRecordUi. fields and childRelationships properties will always be defined, but
 * may be an empty object. Useful for verifying that the value matches the structure of a Record.
 * @param {*} record The value to inspect.
 */
export function isARecord (record) {
    return record &&
        record.apiName &&
        record.fields;
}

/**
 * Throws an exception if the supplied value isn't a Record instance from the UI API.
 * @param {*} record The value to inspect.
 */
export function validateIsARecord (record) {
    if (!isARecord(record)) {
        // TODO: Custom Label
        throw new Error('The provided value is not a Record from the UI API.');
    }
    return true;
}

/**
 * Returns the ChangeEvent api name for a given object.
 * @param {string} objectName - The api name of the target object to get the ChangeEvent api name
 */
export function getChangeEventApiName (objectName) {
    if (!objectName) {
        throw new Error('Object name cannot be blank.');
    }

    if (objectName.endsWith('__c')) {
        return objectName.replace(/__c$/, '__ChangeEvent');
    }

    return objectName + 'ChangeEvent';
}

/**
 * Converts an array of record id strings to the soql list format.
 * EX: ["id1", "id2"] => "('id1','id2')"
 * @param {array[string]} ids 
 */
export function getSoqlIdList (ids) {
    return `('${(ids || []).join(`','`)}')`;
}