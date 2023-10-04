import { getSoqlIdList, getDisplayValue, StaticallyComparable } from 'c/utils';

import getMatchingRecordIds from
    '@salesforce/apex/COMM_LookupFilterLightningService.getMatchingRecordIds';

import { SEARCH_REQUEST } from './search';

export default class ResultsModelController extends StaticallyComparable {
    // === PROPERTY: recordTypeInfos ===
    _recordTypeInfos = [];
    get recordTypeInfos () {
        return this._recordTypeInfos;
    }

    set recordTypeInfos (value) {
        this._recordTypeInfos = value;
    }

    // === PROPERTY: _searchResultIdsLDS ===
    _searchResultIdsLDS;

    // === PROPERTY: _searchResultIdsApex ===
    _searchResultIdsApex;

    // === PROPERTY: searchResultIds ===
    // Executes a search using the search request JSON (only returning matching Ids, using SOSL)
    get searchResultIds () {
        return this._searchResultIdsLDS || this._searchResultIdsApex || [];
    }

    set searchResultIds (value) {
        const newIds = value || [];
        if (!newIds.length) {
            this._searchResultIdsLDS = this._searchResultIdsApex = newIds;
            this.searchResultRecords = [];
        } else {
            // Switch between wire adapters depending on object support availability
            if (this.mc('schema').isTargetObjectUiSupported) {
                this._searchResultIdsLDS = value;
                this._searchResultIdsApex = undefined;
            } else {
                this._searchResultIdsLDS = undefined;
                this._searchResultIdsApex = value;
            }
        }
    }

    // === PROPERTY: options ===
    options = [];

    // === PROPERTY: searchResultRecords ===
    // Uses the UI API to retrieve the partial record data for all records returned by the last
    // search operation and generates a new set of selectable options using that data. Executes
    // when the search result ids list changes.
    _searchResultRecords;
    get searchResultRecords () {
        return this._searchResultRecords || [];
    }

    set searchResultRecords (value) {
        const hasRecordType = value.find(val => val.apiName === 'RecordType');
        const availableRecords = [];
        const shouldFilterRecordTypes = this.recordTypeInfos?.length > 0 && hasRecordType;
        if (shouldFilterRecordTypes) {
            value.forEach(record => {
                this.recordTypeInfos.forEach(recordTypeInfo => {
                    if (record.id === recordTypeInfo.recordTypeId && recordTypeInfo.isAvailable) {
                        availableRecords.push(record);
                    }
                });
            });
        }
        this._searchResultRecords = shouldFilterRecordTypes ? availableRecords : value;
        this.options = this.searchResultRecords.map(record => {
            const label = this.mc('utils').generateDisplayLabelForRecord(record);

            const option = {
                Id: record.id,
                value: record.id,
                label: label.primary,
                secondaryLabel: label.secondary,
                relatedLabel: this.mc('utils').generateRelatedLabel(record)
            };

            option.cssClass = this.mc('ui').computedListboxOptionClass(option);

            if (this.mc('schema')._resultFieldApiNames?.length) {
                this.mc('schema')._resultFieldApiNames.forEach(field => {
                    option[field] = getDisplayValue(record, field);
                });
            }

            return option;
        });
    }

    // === PROPERTY: searchResultsFromIdsRequestJSON ===
    get searchResultsFromIdsRequestJSON () {
        if (!this._searchResultIdsApex?.length) {
            return undefined;
        }

        if (!this.mc('schema')._resultFieldApiNames?.length) {
            return undefined;
        }

        return JSON.stringify({
            [SEARCH_REQUEST.OBJECT_NAME]: this.mc('schema').resolvedTargetObjectApiName,
            [SEARCH_REQUEST.WHERE_CLAUSE]: `Id IN ${getSoqlIdList(this._searchResultIdsApex)}`,
            [SEARCH_REQUEST.FIELDS]:
                this.mc('schema')._resultFieldApiNames.map(field => field.split('.')[1])
        });
    }

    // === PROPERTY: _dropdownVisible ===
    _dropdownVisible = false;

    // === PROPERTY: _dropdownBottomUp ===
    _dropdownBottomUp = false;

    // === METHOD: refreshSearchResults ===
    async refreshSearchResults () {
        if (!this.mc('results')._dropdownVisible &&
            !this.mc('advancedSearch')._showAdvancedSearchModal
        ) {
            return;
        }

        this.mc('ui').apiInProgress = true;

        const requestJson = this.mc('search').searchRequestJSON;
        if (requestJson) {
            try {
                const response = await getMatchingRecordIds({ requestJson });
                this.searchResultIds = await this.mc('utils').handleApexResponse(response);
            } catch (err) {
                this.mc('utils').handleError(err);
            }
        }

        this.mc('ui').apiInProgress = false;

        this.mc('debug').pushChangeDebugSnapshot();
    }
}