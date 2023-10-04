import labelContains from '@salesforce/label/c.Label_Contains';
import labelStartsWith from '@salesforce/label/c.Label_StartsWith';
import labelEndsWith from '@salesforce/label/c.Label_EndsWith';
import labelExactMatch from '@salesforce/label/c.Label_ExactMatch';

import { OPERATOR_VALUE } from './constants';

const NAME_FIELD = 'Name';
const STR_OBJECT = 'object';

export const LOOKUP_OPERATOR_OPTIONS = [
    {
        value: OPERATOR_VALUE.CONTAINS,
        label: labelContains
    },
    {
        value: OPERATOR_VALUE.STARTS_WITH,
        label: labelStartsWith
    },
    {
        value: OPERATOR_VALUE.ENDS_WITH,
        label: labelEndsWith
    },
    {
        value: OPERATOR_VALUE.EXACT_MATCH,
        label: labelExactMatch
    }
];

export const isInCorrectDetail = (fieldInfo) => {
    if ( typeof fieldInfo !== STR_OBJECT
      || !Array.isArray(fieldInfo.referenceToInfos)
      || fieldInfo.referenceToInfos.length <= 0
      || typeof fieldInfo.referenceToInfos[0] !== STR_OBJECT ) {
        return true;
    }
    return false;
};

export const getNameField = (nameFieldsList) => {
    if (!Array.isArray(nameFieldsList) || nameFieldsList.length <= 0) {
        return '';
    }

    if (nameFieldsList.includes(NAME_FIELD)) {
        return NAME_FIELD;
    }

    return nameFieldsList[0];
}

export const getNameFieldFromFieldMetadata = (fieldInfo) => {
    if (isInCorrectDetail(fieldInfo)) {
        return '';
    }
    return getNameField(fieldInfo.referenceToInfos[0].nameFields);
}

export const getObjectNameFromFieldMetadata = (fieldInfo) => {

    if (isInCorrectDetail(fieldInfo)) {
        return '';
    }
    return fieldInfo.referenceToInfos[0].apiName;
}

export const getReferenceObjectNameFromFieldInfo = (fieldInfo) => {

    if ( typeof fieldInfo !== STR_OBJECT
        || !Array.isArray(fieldInfo.referenceTo)
        || fieldInfo.referenceTo.length <= 0
    ) {
        return '';
    }
    return fieldInfo.referenceTo[0];
}