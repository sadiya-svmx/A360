import {
    formatString,
    OPERATOR_VALUE,
    PUBSUB_KEYS,
    StaticallyComparable,
    isNotUndefinedOrNull,
    verifyApiResponse
} from 'c/utils';
import { HEADER, getSectionData } from 'c/runtimePubSub';
import { getFieldDefinitionsForEntity } from 'c/metadataService';

export const SEARCH_REQUEST = {
    SEARCH_TERM: 'searchTerm',
    SEARCH_FIELDS: 'lstSearchInFields',
    LOOKUP_CONFIG_ID: 'lookupConfigId',
    SEARCH_OPERATOR: 'searchOperator',
    OBJECT_NAME: 'objectName',
    FIELDS: 'fields',
    WHERE_CLAUSE: 'whereClause',
    APPLY_CONTEXT_FILTER: 'applyContextFilter',
    REFERENCE_NAME_FIELD: 'referenceNameField',
    LOOKUP_MATCHING_FIELD: 'lookupMatchingField',
    LOOKUP_CONTEXT: 'lookupContext',
    HEADER_RECORD_DATA: 'headerRecordData'
};

export const SEARCH_REQUEST_DEFAULTS = {
    [SEARCH_REQUEST.SEARCH_OPERATOR]: OPERATOR_VALUE.CONTAINS
};

const SEARCH_DEBOUNCE_INTERVAL_MS = 300;

export default class SearchModelController extends StaticallyComparable {
    // === PROPERTY: _searchDebounceTimeoutId ===
    _searchDebounceTimeoutId;

    _headerObjectDescribe;

    // === PROPERTY: filters ===
    _filters = '';
    get filters () {
        return this._filters;
    }

    set filters (value) {
        this._filters = value;
        this.setSearchRequestProperty(SEARCH_REQUEST.WHERE_CLAUSE, this.filters);
    }

    // === PROPERTY: searchTerm ===
    _searchTerm;
    get searchTerm () {
        return this._searchTerm || '';
    }

    set searchTerm (value) {
        this._searchTerm = value;
        this.setSearchRequestProperty(SEARCH_REQUEST.SEARCH_TERM, this.searchTerm);
    }

    // === PROPERTY: searchLabel ===
    get searchLabel () {
        return (this.mc('schema').targetObjectLabel) ?
            formatString(
                this.mc('ui').i18n.contextName,
                this.searchTerm,
                this.mc('schema').targetObjectLabel
            ) :
            this.searchTerm;
    }

    // === PROPERTY: searchRequest ===
    // Generation of search request. <searchRequest> setter should be used whenever one or more
    // of the properties the search results are dependent on are changed.
    _searchRequest = Object.assign({}, SEARCH_REQUEST_DEFAULTS);
    get searchRequest () {
        return this._searchRequest;
    }

    set searchRequest (value) {
        this._searchRequest = Object.assign({}, SEARCH_REQUEST_DEFAULTS, value);
        this.createSearchRequestJson();
    }

    resetSearchRequest () {
        this.createSearchRequestJson();
    }

    createSearchRequestJson () {
        if (this.isSearchRequestValid(this._searchRequest)) {
            if (this._searchDebounceTimeoutId) {
                clearTimeout(this._searchDebounceTimeoutId);
            }

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this._searchDebounceTimeoutId = setTimeout(
                async () => {
                    const headerRecordData = getSectionData({
                        engineId: this.mc('staticConfig').engineId,
                        whichSection: HEADER
                    });

                    if (headerRecordData && Object.keys(headerRecordData).length) {
                        const headerRecordRequestData = {};
                        const {
                            attributes
                        } = headerRecordData;

                        if (attributes && attributes.type) {
                          const objectApiName = attributes.type;

                          if (this._headerObjectDescribe !== null) {
                            const response = await getFieldDefinitionsForEntity(
                              objectApiName
                            );
                            this._headerObjectDescribe = await this.mc(
                              "utils"
                            ).handleApexResponse(response);
                          }

                          Object.keys(headerRecordData).forEach(
                            (headerRecordField) => {
                              if (
                                headerRecordField !== PUBSUB_KEYS.ACTIVE_TAB
                              ) {
                                const fieldDefintion =
                                  this._headerObjectDescribe?.fieldDefinitions.find(
                                    (field) =>
                                      field.apiName === headerRecordField
                                  );

                                if (
                                  fieldDefintion &&
                                  fieldDefintion.dataType === "DATE" &&
                                  isNotUndefinedOrNull(
                                    headerRecordData[headerRecordField]
                                  )
                                ) {
                                  headerRecordData[headerRecordField] =
                                    headerRecordData[headerRecordField].split(
                                      "T"
                                    )[0];
                                }
                                headerRecordRequestData[headerRecordField] =
                                  headerRecordData[headerRecordField];
                              }
                            }
                          );
                        }

                        if (Object.keys(headerRecordRequestData).length) {
                            this.setHeaderRecordData(headerRecordRequestData);
                        } else {
                            this.clearHeaderRecordData();
                        }
                    } else {
                        this.clearHeaderRecordData();
                    }
                    this.searchRequestJSON = JSON.stringify(this._searchRequest);

                },
                SEARCH_DEBOUNCE_INTERVAL_MS
            );
        }
    }


    async getObjectDefinition (objectAPIName) {
        let objectDefinition = {};
        if (objectAPIName) {
            objectDefinition = await getFieldDefinitionsForEntity(objectAPIName)
                .then( result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return {};
                    }
                    this.error = null;
                    return result.data;
                });
        }

        return objectDefinition;
    }

    // === METHOD: setHeaderRecordData ===
    setHeaderRecordData (headerRecordData) {
        this._searchRequest[SEARCH_REQUEST.HEADER_RECORD_DATA] = headerRecordData;
    }

    // === METHOD: clearHeaderRecordData ===
    clearHeaderRecordData () {
        delete this._searchRequest[SEARCH_REQUEST.HEADER_RECORD_DATA];
    }

    // === PROPERTY: searchRequestJSON ===
    _searchRequestJSON;
    get searchRequestJSON () {
        return this._searchRequestJSON;
    }

    set searchRequestJSON (value) {
        this._searchRequestJSON = value;
        this.mc('results').refreshSearchResults();
    }

    // === METHOD: isSearchRequestValid ===
    isSearchRequestValid (searchRequest) {
        return searchRequest && searchRequest[SEARCH_REQUEST.OBJECT_NAME];
    }

    // === METHOD: setSearchRequestProperty ===
    setSearchRequestProperty (propertyName, propertyValue) {
        this.searchRequest = Object.assign({}, this.searchRequest,
            { [propertyName]: propertyValue });
    }

    // === METHOD: setSearchRequestProperties ===
    setSearchRequestProperties (properties) {
        this.searchRequest = Object.assign({}, this.searchRequest, properties);
    }
}