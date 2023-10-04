import {
    STEP_TYPES,
    STEP_TYPE_ICONS,
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    guid } from './utils';

/**
 * populates AttributeForLaunchingWizardStep the wizard step 
 * @param {object} wizardItem - Wizard Step's detail
 * @param {object} mapping - Wizard Step's Param details
 * @param {String} recordId - Object recordId
 * @param {Boolean} launchAsPreview - opens the step in new browser tab
 * @returns {object} attributes - attributes for launching wizardStep
 */
export function populateAttributeForLaunchingWizardStep (
    wizardItem,
    mapping,
    currentRecord,
    launchAsPreview=false ) {

    let actionName;
    switch (wizardItem.type) {
        case STEP_TYPES.FLOW:
            actionName = wizardItem.namespace
                ? `${wizardItem.namespace}__${wizardItem.target}`
                : wizardItem.target;
            break;
        case STEP_TYPES.TRANSACTION:
            actionName = "SVMXA360:runtimeTransaction";
            mapping.developerName = wizardItem.target;
            mapping.isInModal = wizardItem.openAsModal;
            mapping.title = wizardItem.name;
            mapping.iconName = computeStepIconName (wizardItem.iconName, wizardItem.type);
            break;
        case STEP_TYPES.LWC:
            actionName = wizardItem.namespace
                ? `${wizardItem.namespace}:${wizardItem.target}`
                : 'c:' + wizardItem.target;
            break;
        case STEP_TYPES.URL:
            actionName = wizardItem.target;
            // eslint-disable-next-line no-case-declarations
            const urlPathKeys = actionName.match(/{\w*\.?\w*}/gm);
            if (urlPathKeys && urlPathKeys.length > 0) {
                urlPathKeys.forEach(field => {
                    const fieldApiName = field.replace('{','').replace('}','');
                    if (!fieldApiName.includes('.')) {
                        const fieldValue = currentRecord.fields[fieldApiName].value;
                        actionName = actionName.replace(field,fieldValue);
                    } else {
                        const fieldApiNames = fieldApiName.split('.');
                        const relationshipFieldName = fieldApiNames
                            .splice(fieldApiNames.length-1);
                        const fieldrefValue = getRelationshipFieldValue(
                            fieldApiNames.join("."),
                            relationshipFieldName,
                            currentRecord);
                        actionName = actionName.replace(field,fieldrefValue);
                    }
                });
            }
            break;
        case STEP_TYPES.RECORDACTION:
            actionName = wizardItem.target;
            break;
        default:
            break;

    }
    const attributes = {
        c__objectRecordId: currentRecord ? currentRecord.id: '',
        c__stepId: wizardItem.id,
        c__actionName: actionName,
        c__actionType: wizardItem.type,
        c__currentTimeStamp: new Date().getTime(),
        c__OpenAsModal: false,
        c__wizardStepName: wizardItem.name,
        c__wizardStepIcon: computeStepIconName (wizardItem.iconName, wizardItem.type),
        c__mapping: JSON.stringify(mapping)
    }
    attributes.c__uniqueStepGuid =  !launchAsPreview ? guid() : '';
    return attributes;
}

export function getRelationshipFieldValue (relationshipName, fieldName, objRecord) {
    if (isUndefinedOrNull(relationshipName)
            || isUndefinedOrNull(objRecord)
            || relationshipName === '') {
        if (isNotUndefinedOrNull(objRecord)
                && objRecord.fields
                && objRecord.fields[fieldName]) {
            return objRecord.fields[fieldName].value;
        }
        return null;
    }
    const relatedObjs = relationshipName.split('.');
    const currRelatedObj = relatedObjs.splice(0, 1);
    let record;
    if (objRecord.fields && objRecord.fields[currRelatedObj]) {
        record = objRecord.fields[currRelatedObj].value;
    }
    return getRelationshipFieldValue(relatedObjs.join('.'), fieldName, record);
}

export function computeStepIconName (iconName, type) {
    let computedIconName ;
    if (isNotUndefinedOrNull(iconName)) {
        computedIconName = iconName;
    } else {
        computedIconName = STEP_TYPE_ICONS [type]
    }
    if (isUndefinedOrNull(computedIconName)) {
        computedIconName = 'standard:template';
    }
    return computedIconName;
}