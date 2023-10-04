import { isUndefinedOrNull } from "./utils"
import TIMEZONE from "@salesforce/i18n/timeZone";

function isBuffer (obj) {
    return obj &&
      obj.constructor &&
      (typeof obj.constructor.isBuffer === 'function') &&
      obj.constructor.isBuffer(obj)
}

function keyIdentity (key) {
    return key
}

export function flattenById (target, opts) {
    // eslint-disable-next-line no-param-reassign
    opts = opts || {}

    const delimiter = '.'
    const maxDepth = opts.maxDepth
    const transformKey = opts.transformKey || keyIdentity
    const output = {}

    function step (object, prev, currentDepth) {
        // eslint-disable-next-line no-param-reassign
        currentDepth = currentDepth || 1
        // eslint-disable-next-line consistent-return
        Object.keys(object).forEach(function (key) {
            const value = object[key]
            const isarray = opts.safe && Array.isArray(value)
            const type = Object.prototype.toString.call(value)
            const isbuffer = isBuffer(value)
            const isobject = (
                type === '[object Object]' ||
          type === '[object Array]'
            )
            if (Number.isInteger(Number(key))) {
                const newKey = prev
                    ? prev + delimiter + transformKey(object[key].id)
                    : transformKey(object[key].id)

                if (!isarray && !isbuffer && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, newKey, currentDepth + 1)
                }

                output[newKey] = value
            } else if (key === 'children' || key === 'detail') {
                if (!isarray && !isbuffer && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, prev, currentDepth)
                }
            } else if (key === 'fields') {
                // eslint-disable-next-line no-useless-return, consistent-return
                return;
            } else {
                const newKey = prev
                    ? prev + delimiter + transformKey(key)
                    : transformKey(key)

                if (!isarray && !isbuffer && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, newKey, currentDepth + 1)
                }

                output[newKey] = value
            }
        })
    }

    step(target)

    return output
}

export function flatten (target, opts) {
    // eslint-disable-next-line no-param-reassign
    opts = opts || {}

    const delimiter = '.'
    const maxDepth = opts.maxDepth
    const transformKey = opts.transformKey || keyIdentity
    const output = {}

    function step (object, prev, currentDepth) {
        // eslint-disable-next-line no-param-reassign
        currentDepth = currentDepth || 1
        // eslint-disable-next-line consistent-return
        Object.keys(object).forEach(function (key) {
            const value = object[key]
            const isarray = opts.safe && Array.isArray(value)
            const type = Object.prototype.toString.call(value)
            const isbuffer = isBuffer(value)
            const isobject = (
                type === '[object Object]' ||
          type === '[object Array]'
            )
            if (Number.isInteger(Number(key))) {
                const newKey = prev
                    ? prev + delimiter + transformKey(object[key].id)
                    : transformKey(object[key].id)

                if (!isarray && !isbuffer && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, newKey, currentDepth + 1)
                }

                output[newKey] = value
            } else if (key === 'fields') {
                // eslint-disable-next-line no-useless-return, consistent-return
                return;
            } else {
                const newKey = prev
                    ? prev + delimiter + transformKey(key)
                    : transformKey(key)

                if (!isarray && !isbuffer && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, newKey, currentDepth + 1)
                }

                output[newKey] = value
            }
        })
    }

    step(target)

    return output
}

/**
 * Unflattens an array to a tree with parent Ids
 */
export function arrayToTree (items,returnRootItemsOnly = true) {
    const rootItems = [];
    const lookupTable = [];

    items.forEach(item => {
        const itemId = item.id;
        const parentId = item.parentId;

        if (!Object.prototype.hasOwnProperty.call(lookupTable, itemId)) {
            lookupTable[itemId] = {};
        }

        const children = lookupTable[itemId].children;

        if (
            children !== undefined &&
            Array.isArray(children)
        ) {
            lookupTable[itemId] = Object.assign(
                {},
                item,
                { children: lookupTable[itemId].children }
            );
        } else {
            lookupTable[itemId] = Object.assign(
                {},
                item
            );
        }

        const treeItem = lookupTable[itemId];

        if (
            isUndefinedOrNull(parentId)
        ) {
            // is a root item
            rootItems.push(treeItem);
        } else {
            if (!Object.prototype.hasOwnProperty.call(lookupTable, parentId)) {
                lookupTable[parentId] = { children: []};
            }
            if (Array.isArray(lookupTable[parentId].children)) {
                lookupTable[parentId].children.push(treeItem);
            } else {
                lookupTable[parentId].children = [treeItem];
            }
        }
    });

    return returnRootItemsOnly?rootItems:lookupTable;

}


export function getAssetDisplayColumns (
    objectApiName,
    hierarchyConfig,
    objectInfo,
    engineId,
    tabId) {
    return hierarchyConfig?.data?.[objectApiName.toLowerCase()]?.fields?.map(field => {
        const type = objectInfo?.fields[field.fieldApiName]?.dataType.toLowerCase();
        return {
            type: castFieldToSupportType(objectInfo?.fields[field.fieldApiName]),
            fieldName: field.fieldApiName,
            label: objectInfo?.fields?.[field.fieldApiName]?.label,
            fieldType: type,
            hideDefaultActions: true,
            sortable: !objectInfo?.fields[field.fieldApiName].calculated,
            editable: field.fieldApiName === 'RecordTypeId'
                ? false
                : objectInfo?.fields[field.fieldApiName].updateable ,
            typeAttributes: getTypeAttributesByType(type, field, objectInfo, engineId, tabId)
        };
    });
}



function castFieldToSupportType (fieldDef) {
    let type = '';
    const fieldType = fieldDef?.dataType.toLowerCase();
    switch (fieldType) {
        // standard types
        case 'date':
            type = 'date-local';
            break;
        case 'datetime':
            type = 'date';
            break;
        case 'time':
            type = 'xTime';
            break;
        case 'percent':
        case 'double':
        case 'int':
            type = 'number';
            break;
        // always readonly as its salesforce system field
        case 'ID':
            type = 'text';
            break;
        case 'string':
            //type = 'text';
            type = fieldDef?.htmlFormatted
                ? 'xImage'
                : (fieldDef?.calculated ? 'xRichText' : 'text');
            break;
        case 'reference':
            type = 'xLookup';
            break;
        case 'textarea':
            type = 'xTextarea';
            break;
        case 'picklist':
        case 'multipicklist':
            type = 'xPicklist';
            break;
        default:
            type = fieldType;
    }
    return type;
}

function getTypeAttributesByType (type, field, objectInfo, engineId, tabId) {
    const rkey = Object.keys(objectInfo.recordTypeInfos).filter (
        key => objectInfo.recordTypeInfos[key].defaultRecordTypeMapping);
    const typeAttributesByType = new Map([
        [
            "reference",
            {
                label: objectInfo?.fields?.[field.fieldApiName]?.label ,
                "fieldName": field.fieldApiName,
                "type": "xLookup",
                "rowId": {
                    fieldName: "Id"
                },
                "hideDefaultActions": true,
                "sortable": !objectInfo?.fields[field.fieldApiName].calculated,
                "disabled": false,
                "fieldType": "reference",
                "editable": field.fieldApiName !== 'RecordTypeId',
                "meta": JSON.stringify({
                    filters: "",
                    formFillMappingId: null,
                    object: objectInfo?.fields?.[field.fieldApiName]?.referenceToInfos[0]?.apiName,
                    referenceNameFields: "Name",
                    enableEventPropertyInterface: true,
                    "engineId": engineId,
                    "childId": tabId
                })
            },
        ],
        ['datetime', {
            timeZone: TIMEZONE,
            month: '2-digit',
            day: '2-digit',
            year: 'numeric',
            hour: 'numeric',
            minute: 'numeric'
        }],
        ['picklist',  {
            label: objectInfo?.fields?.[field.fieldApiName]?.label ,
            "fieldName": field.fieldApiName,
            "type": "xPicklist",
            "hideDefaultActions": true,
            "sortable": true,
            "disabled": false,
            "fieldType": type,
            "rowId": {
                fieldName: "Id"
            },
            "editable": "true",
            "meta": JSON.stringify({
                objectApiName: objectInfo?.apiName,
                fieldApiName: field.fieldApiName,
                defaultRecordTypeId: objectInfo.recordTypeInfos[rkey]?.recordTypeId,
                options: objectInfo?.fields?.[field.fieldApiName]?.picklistValues,
                "engineId": engineId,
                "childId": tabId
            })
        },],
        [
            "text",
            {
                label: objectInfo?.fields?.[field.fieldApiName]?.label,
                "fieldName": field.fieldApiName,
                "type": "xText",

                "hideDefaultActions": true,
                "sortable": true,
                "disabled": false,
                "fieldType": "string"
            },
        ],
    ]);
    return typeAttributesByType.get(type) ?? {};
}