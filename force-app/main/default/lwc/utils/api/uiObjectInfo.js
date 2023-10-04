/**
 * Converts an EntityDefinition representation of object schema data
 * into the Ui Api representation.
 * @param {SVMXA360__Common.EntityDefinition} entityDefinition
 */
export function getObjectInfoFromSVMXEntityDefinition (entityDefinition) {
    if (!entityDefinition || !entityDefinition.apiName) {
        throw new Error('Invalid entity definition.');
    }

    const {
        apiName,
        label,
        custom,
        childDefinitions: childRelationships,
        recordTypeInfos
    } = entityDefinition;

    const fields = {};
    for (let i = 0; i < entityDefinition.fieldDefinitions.length; i++) {
        const field = entityDefinition.fieldDefinitions[i];
        fields[field.apiName] = field;
    }

    return {
        apiName,
        label,
        fields,
        custom,
        childRelationships,
        recordTypeInfos
    };
}

/**
 * Scans through a list of Field Apis for the standard 'Name' field. If found, it is moved to the
 * beginning of the array. Returns a copy of the originally passed array.
 * @param {String[]} nameFields List of field Apis (proper case)
 * @returns List of field Apis, with the 'Name' field placed in front (if found)
 */
export function getNameFieldsWithPreferredFirst (nameFields) {
    if (!nameFields || !Array.isArray(nameFields)) {
        throw new Error('Invalid name fields array');
    }

    const reorderedNameFields = [...nameFields];

    const nameFieldIndex = reorderedNameFields.findIndex(value => value === 'Name');
    if (nameFieldIndex > -1) {
        const nameField = reorderedNameFields.splice(nameFieldIndex, 1);
        reorderedNameFields.unshift(nameField[0]);
    }

    return reorderedNameFields;
}