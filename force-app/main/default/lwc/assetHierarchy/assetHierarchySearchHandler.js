import {
    i18n,
    loadDataFromProcessedRecords,
    populateResult  } from "./assetHierarchyHelper";
import {
    ASSET_HIERARCHY_ORDER,
    raf,
    chunk,
    isFirefox,
    isNotUndefinedOrNull,
    arrayToTree,
    flattenById
} from 'c/utils';
import ASSET_OBJECT from '@salesforce/schema/Asset';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import LOCATION_OBJECT from '@salesforce/schema/Location';
import findAssetsOfRelatedParent
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.findAssetsOfRelatedParent";
import getAssetHierarchyByRelatedParent
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.getAssetHierarchyByRelatedParent";
const OBJECTAPIMAP = {
    '131': LOCATION_OBJECT.objectApiName,
    '001': ACCOUNT_OBJECT.objectApiName,
    '02i': ASSET_OBJECT.objectApiName
};
export  class AssetHierarchySearchHandler {
    pObject;
    noMatchingFoundMessage;
    isResultsLoading = false;
    searchKey;
    isChunksLoading = false;
    handleSearchBlur () {
        // eslint-disable-next-line @lwc/lwc/no-async-operation, consistent-return    
        this.blurTimeout = setTimeout(() => {
            const searchList = this.template.querySelector(`[data-searchbox="searchbox"]`);
            searchList.classList.remove("slds-is-open");
        }, 300);
    }

    handleSearchKeyChange (event) {
        this.searchHandler.noMatchingFoundMessage = null;
        this.isSearchResultHasInvalidNode = false;
        window.clearTimeout(this.blurTimeout);
        window.clearTimeout(this.delayTimeout);
        window.clearTimeout(this.searchHandler.chunkTimeout);
        const searchKey = event.detail.value;
        const searchList = this.template.querySelector(`[data-searchbox="searchbox"]`);
        if (searchKey.length >= 0 && searchKey.length < 3) {
            searchList.classList.remove("slds-is-open");
            this.searchResults = [];
            return;
        }
        searchList.classList.add("slds-is-open");
        this.searchHandler.scrollEventListener = false;
        event.stopPropagation();
        this.searchHandler.isResultsLoading = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation, consistent-return
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
            if (this.searchKey === '') {
                this.handleRefresh();
                this.searchHandler.isResultsLoading = false;
                return;
            }
            if (this.order === ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                this.searchHandler.searchAssetOnlyTreeByProperty (this.searchKey,this);
                if (this.searchResults.length === 0) {
                    this.searchHandler.noMatchingFoundMessage = i18n.noMatchingRecordFound;
                }
                return;
            }
            const results = this.searchTreeByProperty(this.searchKey,true);
            if (results.length > 0) {
                // eslint-disable-next-line max-len
                const regex = new RegExp(`(${this.searchHandler.sanitizeRegex(this.searchKey)})`, 'gi');
                const searchResult = [];

                results.forEach(result => {
                    const parsedResult = result.split('.');
                    const property = parsedResult.pop();
                    const parsedResultWithoutprop = parsedResult.join('.');
                    const objectAPIName =
                    this.flattenedData[`${parsedResultWithoutprop}.objectApiName`];
                    let recordName = this.flattenedData[`${parsedResultWithoutprop}.name`];
                    const cleanRecordName = recordName;
                    if (recordName.toLowerCase() !== this.searchKey.toLowerCase()) {
                        recordName = recordName.replace(
                            regex,
                            `<mark>$1</mark>`);
                    }
                    let searchText;
                    if (property !== 'name') {
                        // eslint-disable-next-line max-len
                        searchText = this.flattenedData[`${parsedResultWithoutprop}.${property}`];
                        if (searchText.toLowerCase()
                            !== this.searchKey.toLowerCase()) {
                            searchText = searchText.replace(
                                regex,
                                `<mark>$1</mark>`);
                        }
                    }
                    let iconName = this.hierarchyConfig
                        ?.data?.[objectAPIName]?.displayIconName;
                    iconName = iconName?.includes(":")
                        ? iconName
                        : this.flattenedData[`${parsedResultWithoutprop}.${iconName}`];
                    const isIcon = iconName && !iconName.includes("/");
                    const isImage = iconName && iconName.includes("/");
                    const matchedRowId = parsedResult.pop();
                    searchResult.push({
                        'objectAPIName': objectAPIName,
                        'iconName': iconName,
                        'isIcon': isIcon,
                        'isImage': isImage,
                        'recordId': matchedRowId,
                        'recordName': recordName,
                        'cleanRecordName': cleanRecordName,
                        'searchText': searchText,
                        'result': parsedResult,
                        'serverSideFetch': false,
                        'isFilterNotMatched': false
                    });

                });
                this.searchHandler.isResultsLoading = false;
                if (searchResult.length > 20) {
                    this.searchHandler.isChunksLoading = true;
                    const chunks = chunk(searchResult, 20);
                    this.searchResults = chunks.shift();
                    this.searchHandler.lazyLoadData ( chunks,this);
                } else {
                    this.searchResults = searchResult;
                }
            } else {
                this.searchHandler.isResultsLoading = false;
                this.searchResults = [];
            }
            if (this.order !== ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                raf(() => {
                    this.searchHandler.peformServerSideSearch (this);
                }).call(this);
            } else if (this.searchResults.length === 0) {
                this.searchHandler.noMatchingFoundMessage = i18n.noMatchingRecordFound;
            }
        }, 300);
    }

    searchAssetOnlyTreeByProperty (searchKey, that) {
        const thatobj = that;
        const searchKeyLowerCase = searchKey.toLowerCase();
        let iconName = thatobj.hierarchyConfig?.data?.asset?.displayIconName;
        const regex = new RegExp(`(${this.sanitizeRegex(searchKey)})`, 'gi');
        const searchResult = thatobj.assetResults.filter (record => {
            return Object.keys(record).findIndex(key => {
                let value = record[key];
                if (typeof record[key] === 'object') {
                    value = record[key].Name;
                }
                return value
                && typeof value === 'string'
                && value?.indexOf('<img') === -1
                && value?.toLowerCase().includes(searchKeyLowerCase);
            }) > -1;
        }).map(rec => {
            iconName = iconName?.includes(":") ? iconName: rec[iconName];
            const isIcon = iconName && !iconName.includes("/");
            const isImage = iconName && iconName.includes("/");
            let recordName = rec.Name;
            let searchText;
            if (recordName.toLowerCase() !== searchKey.toLowerCase()
                && recordName.toLowerCase().includes(searchKey.toLowerCase())) {
                recordName = recordName.replace(
                    regex,
                    `<mark>$1</mark>`);
            } else if (!recordName.toLowerCase().includes(searchKey.toLowerCase())) {
                const keys = Object.keys(rec);
                const keyIndex = keys.findIndex(key => {
                    let value = rec[key];
                    if (typeof rec[key] === 'object') {
                        value = rec[key].Name;
                    }
                    return value
                    && typeof value === 'string'
                    && value?.indexOf('<img') === -1
                    && value?.toLowerCase().includes(searchKeyLowerCase);
                });
                searchText = typeof rec[keys[keyIndex]] === 'object'
                    ? rec[keys[keyIndex]].Name
                    : rec[keys[keyIndex]];
                if (searchText.toLowerCase() !== searchKey.toLowerCase()) {
                    searchText = searchText.replace(
                        regex,
                        `<mark>$1</mark>`);
                }
            }
            return {
                'objectAPIName': 'asset',
                'iconName': iconName,
                'isIcon': isIcon,
                'isImage': isImage,
                'recordId': rec.Id,
                'recordName': recordName,
                'cleanRecordName': rec.Name,
                'searchText': searchText,
                'result': null,
                'serverSideFetch': false,
                'isFilterNotMatched': false
            };
        });
        thatobj.isResultsLoading = false;
        if (searchResult.length > 20) {
            this.isChunksLoading = true;
            const chunks = chunk(searchResult, 20);
            thatobj.searchResults = chunks.shift();
            this.lazyLoadData ( chunks,thatobj);
        } else {
            thatobj.searchResults = searchResult;
        }
        thatobj.searchHandler.isResultsLoading = false;
        return true;
    }

    handleSearchResultScroll () {
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        if (this.handleAutoEnableScrollBarEvent && isFirefox) {
            this.handleAutoEnableScrollBarEvent = false;
            return;
        }
        const searchList = this.template.querySelector(`[data-searchbox="searchbox"]`);
        searchList.classList.add("slds-is-open");
        if (!this.searchHandler.scrollEventListener) {
            this.searchHandler.scrollEventListener = true;
            window.addEventListener('click', function hideResultListItems () {
                searchList.classList.remove("slds-is-open");
                window.removeEventListener('click',hideResultListItems);
            });
        }
    }

    handleSearchFocus () {
        if (this.searchResults.length > 0) {
            window.clearTimeout(this.blurTimeout);
            this.isSearchResultHasInvalidNode = false
            if (isFirefox) {
                this.handleAutoEnableScrollBarEvent = true;
            }
            const searchList = this.template.querySelector(`[data-searchbox="searchbox"]`);
            raf (() => {
                // eslint-disable-next-line max-len
                const selectedListRowRemove = this.template.querySelector(".svmx-asset-hierarchy_searchlistselected");
                if (isNotUndefinedOrNull(selectedListRowRemove)) {
                    // eslint-disable-next-line max-len
                    selectedListRowRemove.classList.remove("svmx-asset-hierarchy_searchlistselected");
                }
                const rowWrapperIndex =
            this.searchResults
                .findIndex(wrap => wrap.recordId === this.selectedListId);
                if (rowWrapperIndex !== -1) {
                    if (this.searchResults[rowWrapperIndex].isFilterNotMatched) {
                        if (isNotUndefinedOrNull(this.selectedListId)) {
                            // eslint-disable-next-line max-len
                            const selectedListRow = this.template.querySelector(`[data-selectedid="${this.selectedListId}"]`);
                            if (isNotUndefinedOrNull(selectedListRow)) {
                                // eslint-disable-next-line max-len
                                selectedListRow.classList.add("svmx-asset-hierarchy_searchlistselectedInvalid");
                            }
                        }
                    } else {
                        if (isNotUndefinedOrNull(this.selectedListId)) {
                            // eslint-disable-next-line max-len
                            const selectedListRow = this.template.querySelector(`[data-selectedid="${this.selectedListId}"]`);
                            if (isNotUndefinedOrNull(selectedListRow)) {
                                // eslint-disable-next-line max-len
                                selectedListRow.classList.add("svmx-asset-hierarchy_searchlistselected");
                            }
                        }
                    }
                }
                searchList.classList.add("slds-is-open");
            }).call (this);
            this.searchHandler.scrollEventListener = false;
            if (isNotUndefinedOrNull(this.selectedListId)) {
                const selectedListRow =
                this.template.querySelector(`[data-id="${this.selectedListId}"]`);
                if (isNotUndefinedOrNull(selectedListRow)) {
                    selectedListRow.parentNode.scrollTop = selectedListRow.offsetTop;
                }
            }
        }
    }

    handleSearchResultSelect (event) {
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.selectedListId = event.currentTarget.dataset.id;
        this.showIllustration = true;
        this.refreshing = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(()=>{
            const searchList = this.template.querySelector(`[data-searchbox="searchbox"]`);
            searchList.classList.remove("slds-is-open");
            if (isNotUndefinedOrNull(this.selectedListId)) {
                const selectedListRow =
                this.template.querySelector(`[data-selectedid="${this.selectedListId}"]`);
                if (isNotUndefinedOrNull(selectedListRow)) {
                    selectedListRow.classList.remove("svmx-asset-hierarchy_searchlistselected");
                }
            }
            const rowWrapperIndex =
            this.searchResults
                .findIndex(wrap => wrap.recordId === this.selectedListId);
            if (isNotUndefinedOrNull(this.selectedListId)) {
                const selectedListRow =
                this.template.querySelector(`[data-selectedid="${this.selectedListId}"]`);
                if (isNotUndefinedOrNull(selectedListRow)) {
                    selectedListRow.classList.add("svmx-asset-hierarchy_searchlistselected");
                }
            }
            const record = this.searchResults[rowWrapperIndex].result;
            if (this.searchResults[rowWrapperIndex].isFilterNotMatched) {
                return;
            }
            if (this.order === ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                this.searchResults[rowWrapperIndex].result =
                    this.searchTreeByProperty (
                        this.searchResults[rowWrapperIndex].recordId,
                        false,
                        '.id');
                if (!this.searchResults[rowWrapperIndex].result
                    || this.searchResults[rowWrapperIndex].result.length ===0) {
                    if (isNotUndefinedOrNull(this.selectedListId)) {
                        // eslint-disable-next-line max-len
                        const selectedListRow = this.template.querySelector(`[data-selectedid="${this.selectedListId}"]`);
                        if (isNotUndefinedOrNull(selectedListRow)) {
                            // eslint-disable-next-line max-len
                            selectedListRow.classList.add("svmx-asset-hierarchy_searchlistselectedInvalid");
                        }
                    }
                    this.searchResults[rowWrapperIndex].isFilterNotMatched
                            = true;
                    this.isSearchResultHasInvalidNode = true;
                    searchList.classList.add("slds-is-open");
                    const searchHandler = this;
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    setTimeout(() => {
                        raf (() => {
                            searchHandler.isSearchResultHasInvalidNode = false;
                            searchList.classList.remove("slds-is-open");
                        }).call (this);
                    }, 10000);
                    this.showIllustration = false;
                    this.refreshing = false;
                    return;
                }
                this.searchResults[rowWrapperIndex].result
                    = this.searchResults[rowWrapperIndex].result[0].split('.');
                this.searchResults[rowWrapperIndex].result.pop();
            }
            if (this.searchResults[rowWrapperIndex].serverSideFetch) {
                const relatedParent = this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET
                    ? record.AccountId
                    : record.LocationId;
                getAssetHierarchyByRelatedParent ({
                    assetId: record.Id,
                    config: this.hierarchyConfigData,
                    relatedParentId: relatedParent,
                    hierarchyOrder: this.order
                }).then (result => {
                    this.searchResults[rowWrapperIndex].serverSideFetch = false;
                    const path = this.searchTreeByProperty(result.id,false, '.id');
                    if (path && path.length >0 ) {
                        let path1 = path[0].split('.');
                        path1.pop();

                        const childArr = result.detail??result.children;
                        // eslint-disable-next-line max-len
                        const childArrToTree = arrayToTree (populateResult(childArr,this.allKeys,true));
                        const arrtree = flattenById(childArrToTree);
                        const assetIdVal = record.Id;
                        let resultInArr = [result]
                        if (result.children) {
                            let idpaths ;
                            Object.keys(arrtree).forEach(key => {
                                if (key.toLowerCase().indexOf('id') !== -1) {
                                    const propertyParts = key.split('.');
                                    propertyParts.pop();
                                    // eslint-disable-next-line max-len
                                    if (arrtree[key]?.indexOf(record.Id) > -1
                                        && propertyParts.length > 1) {
                                        propertyParts.pop();
                                        idpaths = propertyParts;
                                    }
                                }
                            });
                            if (idpaths) {
                                for (let index = idpaths.length; index > -1; index--) {
                                    const idKey = idpaths.join('.') + '.id';
                                    if (this.flattenedData[idKey]) {
                                        path1 = JSON.parse(JSON.stringify(idpaths));
                                        break;
                                    }
                                    idpaths.pop();
                                }
                                const treeParentId = idpaths.pop();
                                const arrTrees = arrayToTree (populateResult(result.children.filter(
                                    child => !idpaths.includes(child.id)),this.allKeys,true),false);
                                const treeChilds = arrTrees[treeParentId];
                                resultInArr = [{
                                    id: treeParentId,
                                    children: treeChilds.children
                                }];
                            }
                        }
                        if (arrtree
                            && Object.keys(arrtree)
                                .findIndex(key => key.includes(assetIdVal)) >-1) {
                            // eslint-disable-next-line max-len
                            loadDataFromProcessedRecords (
                                JSON.parse(JSON.stringify(path1)),
                                resultInArr,
                                this.data,
                                this.allKeys,
                                this.hierarchyConfig?.data,
                                this.assetReferencedFields,
                                true);
                            childArr.forEach (item => {
                                if (!path1.includes(item.id)) {
                                    path1.push (item.id);
                                }
                            });
                            this.rearrangeDataToTop (this.data ,JSON.parse(JSON.stringify(path1)));
                            this.viewData = this.data;
                            this.searchResults[rowWrapperIndex].result = path1;
                            this.highlightRow(this.searchResults[rowWrapperIndex]);
                            this.flattenedData = flattenById(this.data);
                            this.showIllustration = false;
                            this.viewData = JSON.parse(JSON.stringify(this.data));
                        } else {
                            if (isNotUndefinedOrNull(this.selectedListId)) {
                                // eslint-disable-next-line max-len
                                const selectedListRow = this.template.querySelector(`[data-selectedid="${this.selectedListId}"]`);
                                if (isNotUndefinedOrNull(selectedListRow)) {
                                    // eslint-disable-next-line max-len
                                    selectedListRow.classList.add("svmx-asset-hierarchy_searchlistselectedInvalid");
                                }
                            }
                            this.searchResults[rowWrapperIndex].isFilterNotMatched
                                 = true;
                            this.isSearchResultHasInvalidNode = true;
                            searchList.classList.add("slds-is-open");
                            // eslint-disable-next-line @lwc/lwc/no-async-operation
                            setTimeout(() => {
                                raf (() => {
                                    this.isSearchResultHasInvalidNode = false;
                                    searchList.classList.remove("slds-is-open");
                                }).call (this);
                            }, 10000);
                            this.showIllustration = false;
                        }
                        this.refreshing = false;
                    }
                });
            } else {
                const expandedRows = [];
                this.searchResults[rowWrapperIndex].result.forEach(item => {
                    expandedRows.push(item);
                });
                expandedRows.push(this.searchResults[rowWrapperIndex].recordId);
                this.rearrangeDataToTop (this.data ,expandedRows);
                this.viewData = this.data;
                this.highlightRow(this.searchResults[rowWrapperIndex]);
                this.showIllustration = false;
                this.refreshing = false;
            }
        },10);

    }

    async peformServerSideSearch ( that) {
        that.isSeverSideSearch =  !that.searchHandler.isResultsLoading;
        that.serverSearchInitiatedTimeStamp = Date.now();
        const serverSearchResults = await findAssetsOfRelatedParent ({
            term: that.searchKey,
            config: that.hierarchyConfigData,
            relatedParentId: that.rootId,
            timestampInMills: that.serverSearchInitiatedTimeStamp });
        if (String(that.serverSearchInitiatedTimeStamp)
            !== String(serverSearchResults?.timestampInMills)) {
            return;
        }
        if (serverSearchResults?.result?.length === 0
            && that.searchResults.length ===0) {
            that.searchHandler.noMatchingFoundMessage = i18n.noMatchingRecordFound;
        } else {
            const regex = new RegExp(
                `(${that.searchHandler.sanitizeRegex(that.searchKey)})`, 'gi');
            let iconName = that.hierarchyConfig
                ?.data?.[ASSET_OBJECT.objectApiName.toLowerCase()]?.displayIconName;

            let parsedSearchResult = serverSearchResults?.result?.map( item =>{
                const detailRecord = JSON.parse(item.record);
                iconName = iconName?.includes(":") ? iconName : detailRecord[iconName];
                const isIcon = iconName && !iconName.includes("/");
                const isImage = iconName && iconName.includes("/");
                let searchText;
                let recordName = detailRecord.Name;
                if (recordName.toLowerCase().includes(that.searchKey.toLowerCase())) {
                    if (recordName.toLowerCase() !== that.searchKey.toLowerCase()) {
                        recordName = recordName.replace(
                            regex,
                            `<mark>$1</mark>`);
                    }
                } else {
                    const fieldIndex = item.fields.findIndex (
                        field =>  {
                            if (field.includes('.')) {
                                const fieldParts = field.split('.');
                                return  fieldParts.length === 2
                                && detailRecord[fieldParts[0]]
                                && typeof detailRecord[fieldParts[0]][fieldParts[1]] === 'string'
                                && detailRecord[fieldParts[0]][fieldParts[1]]?.toLowerCase()
                                    .includes(that.searchKey.toLowerCase());
                            }
                            return  typeof detailRecord[field] === 'string'
                                && detailRecord[field]?.toLowerCase()
                                    .includes(that.searchKey.toLowerCase());
                        } );
                    if (fieldIndex !== -1) {
                        if (item.fields[fieldIndex].includes('.')) {
                            const fieldParts = item.fields[fieldIndex].split('.');
                            searchText = detailRecord[fieldParts[0]][fieldParts[1]];
                        } else {
                            searchText = detailRecord[item.fields[fieldIndex]];
                        }
                    }
                    if (isNotUndefinedOrNull(searchText)) {
                        if (searchText.toLowerCase()
                            !== that.searchKey.toLowerCase()) {
                            searchText = searchText.replace(
                                regex,
                                `<mark>$1</mark>`);
                        }
                    } else {
                        recordName = undefined;
                    }
                }
                return {
                    'objectAPIName': ASSET_OBJECT.objectApiName.toLowerCase(),
                    'iconName': iconName,
                    'isIcon': isIcon,
                    'isImage': isImage,
                    'recordId': item.id,
                    'recordName': recordName,
                    'cleanRecordName': detailRecord.Name,
                    'searchText': searchText,
                    'result': detailRecord,
                    'serverSideFetch': true,
                    'isFilterNotMatched': false
                }
            }).filter (item => isNotUndefinedOrNull(item.recordName)
                    && (that.searchResults.length === 0
                    || that.searchResults.findIndex(
                        searchedItem => searchedItem.recordId === item.recordId) === -1 ));

            if (that.order !== ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                parsedSearchResult =  parsedSearchResult.filter ( item => {
                    let relatedParentId;
                    if (OBJECTAPIMAP[that.rootId.substring(0, 3)] === ASSET_OBJECT.objectApiName) {
                        return true;
                    }
                    if (that.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET) {
                        relatedParentId = item.result.RootAsset.LocationId;
                    } else {
                        relatedParentId = item.result.RootAsset.AccountId;
                    }
                    const path = that.searchTreeByProperty (relatedParentId, false, '.id');
                    return path && path.length >0;
                });
            }

            if ( parsedSearchResult !== undefined) {

                if (parsedSearchResult.length === 0
                    && that.searchResults.length ===0) {
                    that.searchHandler.noMatchingFoundMessage = i18n.noMatchingRecordFound;
                } else if (parsedSearchResult.length > 20) {
                    const chunks = chunk(parsedSearchResult, 20);
                    that.searchResults
                        = that.searchResults.concat (chunks.shift());
                    that.searchHandler.lazyLoadData ( chunks,that);
                } else {
                    that.searchResults
                        = that.searchResults.concat (parsedSearchResult);
                }

            } else if (that.searchResults.length === 0 ) {
                that.searchHandler.noMatchingFoundMessage = i18n.noMatchingRecordFound;
            }
        }
        that.isSeverSideSearch =  !that.isSeverSideSearch;
    }

    lazyLoadData (data,that) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.chunkTimeout = setTimeout(() => {
            that.searchResults = that.searchResults.concat(data.shift());
            if (data.length > 0) {
                that.searchHandler.lazyLoadData(data,that);
            } else {
                that.searchHandler.isChunksLoading = false;
            }
        }, 100);
    }

    sanitizeRegex (searchString) {
        try {
            return (searchString)
                ? searchString.replace(/[#-.]|[[-^]|[?|{}]/g, '\\$&')
                : searchString;
        } catch (e) {
            return searchString;
        }
    }
}