import labelAssetName from '@salesforce/label/c.Label_Asset';
import labelAvailableFields from '@salesforce/label/c.Label_Available_Fields';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelCity from '@salesforce/label/c.Label_City';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelCollapseAll from '@salesforce/label/c.Label_CollapseAll';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelExpandAll from '@salesforce/label/c.AltText_ExpandAll';
import labelFieldstoDisplay from '@salesforce/label/c.Label_SelectFieldstoDisplay';
import labelLaunchSPMWizards from '@salesforce/label/c.Label_LaunchSPMWizards';
import labelLocation from '@salesforce/label/c.Label_Location';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelSerialNumber from '@salesforce/label/c.Label_SerialNumber';
import labelSettings from '@salesforce/label/c.Label_Settings';
import labelSelectAssetFields from '@salesforce/label/c.Label_SelectAssetFields';
import labelSelectLocationFields from '@salesforce/label/c.Label_SelectLocationFields';
import labelServiceProcessFor from '@salesforce/label/c.Label_Service_Process_For';
import labelShowAll from '@salesforce/label/c.Menu_ShowAll';
import labelStatus from '@salesforce/label/c.Label_Status';
import labelType from '@salesforce/label/c.Label_Type';
import labelVisitorAddresss from '@salesforce/label/c.Label_VisitorAddress';
import labelZipCode from '@salesforce/label/c.Label_ZipCode';
import labelNoDataHeading from '@salesforce/label/c.Message_NoData_Heading';
import labelNoDataBody from '@salesforce/label/c.Message_AssetHierarchy_NoData_Body';
import labelOpenSplitViewLabel from '@salesforce/label/c.AltText_SplitViewOpen';
import labelCloseSplitViewLabel from '@salesforce/label/c.AltText_SplitViewClose';
import labelSearchResultsWarning from '@salesforce/label/c.Message_SearchResultsHierarchyWarning';
import labelSelectAccountFields from '@salesforce/label/c.Label_SelectAccountFields';
import labelAccount from '@salesforce/label/c.Label_Account';
import labelFieldsLimit from '@salesforce/label/c.Message_FieldsLimitDisplay';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelTransactonSavedMessage from '@salesforce/label/c.Messge_TransactionSaved';
import labelNoMatchingResultFound from '@salesforce/label/c.Label_NoResultsFound';
import labelRestoreDefaults from '@salesforce/label/c.Btn_Restore_Defaults';
import labelSelectAtLeastOneField from '@salesforce/label/c.Error_SelectAtLeastOneField';
import labelResetColumnWidths from '@salesforce/label/c.Label_ResetColumnWidths';
import labelYearAgo from '@salesforce/label/c.Label_Year_Ago';
import labelMonthAgo from '@salesforce/label/c.Label_Month_Ago';
import labelDayAgo from '@salesforce/label/c.Label_Day_Ago';
import labelHourAgo from '@salesforce/label/c.Label_Hour_Ago';
import labelMinuteAgo from '@salesforce/label/c.Label_Minute_Ago';
import labelSecondAgo from '@salesforce/label/c.Label_Second_Ago';
import labelIncorrectPlotHierarchyField from
    '@salesforce/label/c.Message_IncorrectPlotHierarchyField';
import serverSideSearchMessage from '@salesforce/label/c.Message_HierarchySearchServerSide';

import ahfilter from '@salesforce/label/c.Label_Filters';
import closemsg from '@salesforce/label/c.Button_Close';
import closeAltText from '@salesforce/label/c.AltText_Close';
import cancelFilter from '@salesforce/label/c.Btn_Cancel';
import readonlyFilter from '@salesforce/label/c.Label_ReadOnly';
import activeFilter from '@salesforce/label/c.Label_Active';
import editFilter from '@salesforce/label/c.Btn_Edit';
import addFilter from '@salesforce/label/c.Button_AddFilter';
import applyFilter from '@salesforce/label/c.Button_Apply';
import removeAllFilter from '@salesforce/label/c.Button_RemoveAllFilter';
import removeFilter from '@salesforce/label/c.Label_RemoveFilter';
import filterModalTitle from '@salesforce/label/c.Title_FilterModal';
import limitActiveFilters from '@salesforce/label/c.Message_ActiveFilterLimitDisplay';
import searchedInvalidHierarchyNode from '@salesforce/label/c.Messge_searchedInvalidHierarchyNode';
import labelChildAssetsMenuItem from '@salesforce/label/c.Menu_Child_Assets';
import {
    deepCopy,
    arrayToTree,
    isEmptyString,
    isNotUndefinedOrNull } from 'c/utils';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import LOCATION_OBJECT from '@salesforce/schema/Location';
import ASSET_OBJECT from '@salesforce/schema/Asset';
export const OBJECTAPIMAP = {
    '131': LOCATION_OBJECT.objectApiName,
    '001': ACCOUNT_OBJECT.objectApiName,
    '02i': ASSET_OBJECT.objectApiName
};

export const i18n = {
    assetName: labelAssetName,
    availableFields: labelAvailableFields,
    cancel: labelCancel,
    city: labelCity,
    clone: labelCloneMenuItem,
    collapseAll: labelCollapseAll,
    confirm: labelConfirm,
    delete: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    expandAll: labelExpandAll,
    fieldstoDisplay: labelFieldstoDisplay,
    launchSPMWizards: labelLaunchSPMWizards,
    locationName: labelLocation,
    product: labelProduct,
    save: labelSave,
    searchPlaceholder: labelSearchPlaceholder,
    searchResultsWarning: labelSearchResultsWarning,
    selectAssetFields: labelSelectAssetFields,
    selectLocationFields: labelSelectLocationFields,
    selectAccountFields: labelSelectAccountFields,
    serialNumber: labelSerialNumber,
    settings: labelSettings,
    serviceProcessFor: labelServiceProcessFor,
    showAll: labelShowAll,
    status: labelStatus,
    type: labelType,
    visitorAddress: labelVisitorAddresss,
    zipCode: labelZipCode,
    noDataHeading: labelNoDataHeading,
    noDataBody: labelNoDataBody,
    openSplitView: labelOpenSplitViewLabel,
    closeSplitView: labelCloseSplitViewLabel,
    accountName: labelAccount,
    fieldsLimit: labelFieldsLimit,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    deleteSuccess: labelDeletedSuccess,
    transactionSuccess: labelTransactonSavedMessage,
    noMatchingRecordFound: labelNoMatchingResultFound,
    restoreDefaults: labelRestoreDefaults,
    selectAtLeastOneField: labelSelectAtLeastOneField,
    resetColumnWidths: labelResetColumnWidths,
    incorrectPlotHierarchyField: labelIncorrectPlotHierarchyField,
    yearAgo: labelYearAgo,
    monthAgo: labelMonthAgo,
    dayAgo: labelDayAgo,
    hourAgo: labelHourAgo,
    minuteAgo: labelMinuteAgo,
    secondAgo: labelSecondAgo,
    ahfilter: ahfilter,
    applyFilter: applyFilter,
    closemsg: closemsg,
    closeAltText: closeAltText,
    cancelFilter: cancelFilter,
    readonlyFilter: readonlyFilter,
    activeFilter: activeFilter,
    editFilter: editFilter,
    addFilter: addFilter,
    removeAllFilter: removeAllFilter,
    removeFilter: removeFilter,
    filterModalTitle: filterModalTitle,
    serverSideSearchMessage: serverSideSearchMessage,
    limitActiveFilters: limitActiveFilters,
    searchedInvalidHierarchyNode: searchedInvalidHierarchyNode,
    childAssets: labelChildAssetsMenuItem
}

export function assignNotificationRecord (target, notifications, opts) {
    // eslint-disable-next-line no-param-reassign
    opts = opts || {}

    const delimiter = '.'
    const maxDepth = opts.maxDepth
    const transformKey = opts.transformKey || keyIdentity

    function step (object, prev, currentDepth) {
        // eslint-disable-next-line no-param-reassign
        currentDepth = currentDepth || 1
        // eslint-disable-next-line consistent-return
        Object.keys(object).forEach(function (key) {
            const value = object[key]
            const isarray = opts.safe && Array.isArray(value)
            const type = Object.prototype.toString.call(value)
            const isobject = (
                type === '[object Object]' ||
          type === '[object Array]'
            )
            if (Number.isInteger(Number(key))) {
                const newKey = prev
                    ? prev + delimiter + transformKey(object[key].id)
                    : transformKey(object[key].id)

                if (!isarray && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, newKey, currentDepth + 1)
                }
            } else if (key === 'children' || key === 'detail') {
                if (!isarray && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, prev, currentDepth)
                }
            } else if (key === 'fields') {
                const objectInfo = notifications.get(object.id);
                if (!(objectInfo === null || objectInfo === undefined)) {
                    const notificationRecords = [];
                    objectInfo.forEach(item => {
                        notificationRecords.push(
                            {
                                'Name': item.title,
                                'Description': item.description,
                                'recordId': item.id,
                                'CreatedDate': item.notificationDate,
                                'Url': '/'+item.id,
                                'TimeSince': timeSince(new Date(item.notificationDate)),
                                'AssetName': item.assetName
                            }
                        );
                    });
                    object.notificationRecords = notificationRecords;
                    //object.notificationRecords = objectInfo;
                }
                // eslint-disable-next-line no-useless-return, consistent-return
                return;
            } else {
                const newKey = prev
                    ? prev + delimiter + transformKey(key)
                    : transformKey(key)

                if (!isarray && isobject && Object.keys(value).length &&
            (!opts.maxDepth || currentDepth < maxDepth)) {
                    return step(value, newKey, currentDepth + 1)
                }
            }
        })
    }

    function timeSince (date) {

        const seconds = Math.floor((new Date() - date) / 1000);
        let interval = seconds / 31536000;
        if (interval > 1) {
            return Math.floor(interval) + i18n.yearAgo;
        }
        interval = seconds / 2592000;
        if (interval > 1) {
            return Math.floor(interval) + i18n.monthAgo;
        }
        interval = seconds / 86400;
        if (interval > 1) {
            return Math.floor(interval) + i18n.dayAgo;
        }
        interval = seconds / 3600;
        if (interval > 1) {
            return Math.floor(interval) + i18n.hourAgo;
        }
        interval = seconds / 60;
        if (interval > 1) {
            return Math.floor(interval) + i18n.minuteAgo;
        }
        return Math.floor(seconds) + i18n.secondAgo;
    }
    function keyIdentity (key) {
        return key
    }

    step(target,notifications)
    return target;
}

export function loadData (path1,
    assetData,
    dataTobeProcessed,
    allKeys,
    hierarchyConfig,
    assetReferencedFields,
    enableFetchOption = false) {
    const rowitem = path1.shift();
    const index = dataTobeProcessed.findIndex(item =>  item.id === rowitem);
    if (index  === -1) {
        return;
    }
    if (path1.length>0) {
        if (dataTobeProcessed[index].children) {
            loadData(
                deepCopy(path1),
                assetData,
                dataTobeProcessed[index].children,
                allKeys,
                hierarchyConfig,
                assetReferencedFields,
                enableFetchOption);
        }
        if (dataTobeProcessed[index].detail) {
            loadData(
                deepCopy(path1),
                assetData,
                dataTobeProcessed[index].detail,
                allKeys,
                hierarchyConfig,
                assetReferencedFields,
                enableFetchOption);
        }
    } else {
        if (assetData
            && assetData.length >0
        ) {
            if (dataTobeProcessed[index].detail
                && dataTobeProcessed[index].detail.length >0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] !== ASSET_OBJECT.objectApiName ) {
                const updatedChildren = [];
                assetData.forEach(assetItem => {
                    if (!allKeys.has(assetItem.Id )) {
                        updatedChildren.push(assetItem);
                    }
                });
                dataTobeProcessed[index].detail.push(...populateResultRaw(
                    updatedChildren,
                    hierarchyConfig,
                    assetReferencedFields,
                    allKeys,
                    true));
            } else if (
                assetData.length > 0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] !== ASSET_OBJECT.objectApiName) {
                dataTobeProcessed[index].detail = arrayToTree(
                    populateResultRaw(
                        assetData,
                        hierarchyConfig,
                        assetReferencedFields,
                        allKeys,
                        true
                    ));
            }
            if (dataTobeProcessed[index].children
                && dataTobeProcessed[index].children.length >0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] === ASSET_OBJECT.objectApiName ) {

                const updatedChildren = [];
                assetData.forEach(assetItem => {
                    if (!allKeys.has(assetItem.Id )) {
                        updatedChildren.push(assetItem);
                    }
                });
                dataTobeProcessed[index].children.push(...populateResultRaw(
                    updatedChildren,
                    hierarchyConfig,
                    assetReferencedFields,
                    allKeys,
                    true));
            } else if (assetData.length > 0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] === ASSET_OBJECT.objectApiName) {
                dataTobeProcessed[index].children = populateResultRaw(
                    assetData,
                    hierarchyConfig,
                    assetReferencedFields,
                    allKeys,
                    true);
            }
        }
        dataTobeProcessed[index].enableFetch = enableFetchOption;
    }
}

export function loadDataFromProcessedRecords (path1,
    assetData,
    dataTobeProcessed,
    allKeys,
    hierarchyConfig,
    assetReferencedFields,
    enableFetchOption = false) {
    const rowitem = path1.shift();
    const index = dataTobeProcessed.findIndex(item =>  item.id === rowitem);
    if (index  === -1) {
        return;
    }
    if (path1.length>0) {
        if (dataTobeProcessed[index].children) {
            loadDataFromProcessedRecords(
                deepCopy(path1),
                assetData,
                dataTobeProcessed[index].children,
                allKeys,
                hierarchyConfig,
                assetReferencedFields,
                enableFetchOption);
        }
        if (dataTobeProcessed[index].detail) {
            loadDataFromProcessedRecords(
                deepCopy(path1),
                assetData,
                dataTobeProcessed[index].detail,
                allKeys,
                hierarchyConfig,
                assetReferencedFields,
                enableFetchOption);
        }
    } else {
        if (assetData
            && assetData.length >0
        ) {
            if (dataTobeProcessed[index].detail
                && dataTobeProcessed[index].detail.length >0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] !== ASSET_OBJECT.objectApiName ) {
                dataTobeProcessed[index].detail = arrayToTree(
                    populateResult(
                        assetData[0].detail,
                        allKeys,
                        true
                    ));
            }
            if (dataTobeProcessed[index].children
                && dataTobeProcessed[index].children.length >0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] === ASSET_OBJECT.objectApiName ) {

                const updatedChildren = [];
                assetData[0].children.forEach(assetItem => {
                    if (!allKeys.has(assetItem.id )) {
                        updatedChildren.push(assetItem);
                    }
                });
                dataTobeProcessed[index].children.push(...populateResult(
                    updatedChildren,
                    allKeys,
                    true));
            } else if (assetData.length > 0
                && OBJECTAPIMAP[rowitem.substring(0, 3)] === ASSET_OBJECT.objectApiName) {
                dataTobeProcessed[index].children = populateResult(
                    assetData[0].children,
                    allKeys,
                    true);
            }
        }
        dataTobeProcessed[index].enableFetch = enableFetchOption;
    }
}

export function populateResultRaw (
    currentResult,
    hierarchyConfigData,
    assetReferencedFields,
    allKeys,
    enableDataFetch = false) {
    return currentResult.map( res => {
        const currentDetailResult = {};
        currentDetailResult.id = res.Id;
        currentDetailResult.parentId = res.ParentId;
        const objectId = res.Id;
        if (OBJECTAPIMAP[objectId.substring(0, 3)] === ASSET_OBJECT.objectApiName) {
            currentDetailResult.objectApiName = ASSET_OBJECT.objectApiName.toLowerCase();
            currentDetailResult.parentId = res.ParentId;
            currentDetailResult.fields = hierarchyConfigData?.asset?.fields;
        } else if (OBJECTAPIMAP[objectId.substring(0, 3)]
                                     === LOCATION_OBJECT.objectApiName) {
            currentDetailResult.objectApiName = LOCATION_OBJECT.objectApiName.toLowerCase();
            currentDetailResult.parentId = res.ParentLocationId;
            currentDetailResult.fields = hierarchyConfigData?.location?.fields;
        } else {
            currentDetailResult.objectApiName = ACCOUNT_OBJECT.objectApiName.toLowerCase();
            currentDetailResult.parentId = res.ParentId;
            currentDetailResult.fields = hierarchyConfigData?.account?.fields;
        }
        currentDetailResult.name = res.Name;
        currentDetailResult.url = '/' + res.Id;
        currentDetailResult.record = JSON.stringify(res);

        const detailRecord = res;
        allKeys.add(currentDetailResult.id );
        const apiName = currentDetailResult.objectApiName;
        let displayIconName;
        if ( hierarchyConfigData?.[apiName]?.displayIconName
            && !hierarchyConfigData[apiName].displayIconName.includes(":")) {
                displayIconName = hierarchyConfigData[apiName].displayIconName;
        }
        currentDetailResult.fields.forEach((field) => {
            if (assetReferencedFields.includes(field.fieldApiName)) {
                const fieldName = field.fieldApiName;
                let sObjRecord;
                if (isNotUndefinedOrNull(fieldName) && fieldName.endsWith("Id")) {
                    const relatedRecord = fieldName.replace("Id", "");
                    sObjRecord = detailRecord[relatedRecord];
                } else if (isNotUndefinedOrNull(fieldName)
                            && fieldName.endsWith("__c")) {
                    const relatedRecord = fieldName.replace("__c", "__r");
                    sObjRecord = detailRecord[relatedRecord];
                }
                if (isNotUndefinedOrNull(sObjRecord)) {
                    currentDetailResult[field.fieldApiName] = sObjRecord.Id;
                    currentDetailResult[`${field.fieldApiName}Name`] = sObjRecord.Name;
                    if (fieldName === 'RecordTypeId') {
                        currentDetailResult[`${field.fieldApiName}Url`] = sObjRecord.Name;
                    } else {
                        currentDetailResult[`${field.fieldApiName}Url`] = '/' + sObjRecord.Id;
                    }                    }
            }
            else {
                currentDetailResult[field.fieldApiName] = detailRecord[field.fieldApiName];
            }
            if (field.fieldApiName === 'ParentLocationId') {
                currentDetailResult.parentId = currentDetailResult[field];
            }
        });
        if (isNotUndefinedOrNull(displayIconName)
        && isEmptyString(currentDetailResult[displayIconName])) {
            currentDetailResult[displayIconName] = detailRecord[displayIconName];
        }
        currentDetailResult.enableFetch = enableDataFetch;
        return currentDetailResult;
    });
}

export function populateResult (currentResult, allKeys, enableDataFetch = false) {
    return currentResult.map( res => {
        const currentDetailResult = JSON.parse(JSON.stringify(res));
        const detailRecord = JSON.parse(currentDetailResult.record);
        allKeys.add(currentDetailResult.id );
        currentDetailResult.fields.forEach((field) => {
            if (Object.keys(res.lookupRecords)?.indexOf(field) !== -1) {
                const lookupRecord = JSON.parse(res.lookupRecords[field]);
                if (lookupRecord) {
                    currentDetailResult[field] = lookupRecord.Id;
                    currentDetailResult[`${field}Name`] = lookupRecord.Name;
                    if (lookupRecord.attributes.type === 'RecordType') {
                        currentDetailResult[`${field}Url`]
                        = lookupRecord.Name;
                    } else {
                        currentDetailResult[`${field}Url`]
                        = '/' + lookupRecord.Id;
                    }
                }
            } else {
                currentDetailResult[field] = detailRecord[field];
            }
        });
        currentDetailResult.enableFetch = enableDataFetch;
        return currentDetailResult;
    });
}