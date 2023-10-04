import { LightningElement, track, api } from 'lwc';
import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    isEmptyString,
    isUndefinedOrNull,
    sortObjectArray,
    IS_MOBILE_DEVICE
} from 'c/utils';

import getAttributeHistories
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getAttributeHistories';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import ChartJSCss from '@salesforce/resourceUrl/ChartJSCSS';
import { loadScript,loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ASSET_OBJ from '@salesforce/schema/Asset';

import labelNewValue from '@salesforce/label/c.Label_NewValue';
import labelMinimum from '@salesforce/label/c.Label_Minimum';
import labelMaximum from '@salesforce/label/c.Label_Maximum';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelHistoricalValues from '@salesforce/label/c.Label_HistoricalValues';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';

import TIMEZONE from '@salesforce/i18n/timeZone';
import LOCALE from '@salesforce/i18n/locale';

const i18n = {
    newValue: labelNewValue,
    minimum: labelMinimum,
    maximum: labelMaximum,
    noResults: labelNoResults,
    badInputDate: labelBadInputDate,
    shortDateFormat: shortDateFormat,
    tooLong: labelMaxLength,
    outOfRangeNumber: labelOutOfRangeNumber,
    cancel: labelCancel,
    historicalValues: labelHistoricalValues,
    formValidation: labelFormValidation,
    timezone: TIMEZONE,
    locale: LOCALE,
}

const MAX_TEXT_LENGTH = 255;
const TEN_ENTRY = '10';
const TWENTY_ENTRY = '20';
const THIRTY_ENTRY = '30';
const FIFTY_ENTRY = '50';
const NUMBER_DATATYPE_VALUE = 'number';
const PICKLIST_DATATYPE_VALUE = 'picklist';
const TEXT_DATATYPE_VALUE = 'text';
const DATE_DATATYPE_VALUE = 'date';
const DATETIME_DATATYPE_VALUE = 'datetime';
const BOOLEAN_DATATYPE_VALUE = 'boolean';

export default class AttributeHistoryView extends LightningElement {

    @track attributeRecordInfo = {};
    @track templateItem = {};
    @track attributeHistoryList = [];
    @track attributeHistories = [];
    @track listViewData = [];
    @track columns =[];
    @track picklistOptions =[];
    @track error;
    @track sortBy = 'createdDate';
    @track sortDirection = 'desc';
    attributeType;
    newValue;
    _listViewTableHeight = 100;
    apiInProgress = false;
    historyViewModalOpen = false;
    noRecordsFound = false;
    selectedEntry = TEN_ENTRY;
    startIndex = 0;
    endIndex = 10;

    booleanTrue = true;
    booleanFalse = false;
    showUpdateBtn = false;

    @track chartConfiguration= {}
    chart;
    tableView = true;
    previousNumberChartView = false;

    renderedCallback () {
        const listViewTable = this.template.querySelector(
            '.svmx-ta-history-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    @api
    handleViewAttributeHistory (attributeRecord, templateItemRecord) {
        this.attributeRecordInfo = JSON.parse(JSON.stringify(attributeRecord));
        this.templateItem = JSON.parse(JSON.stringify(templateItemRecord));

        this.attributeType = this.attributeRecordInfo?.attributeDataType.toLowerCase();

        this.columns = this.getColumns();
        this.historyViewModalOpen = true;
        if (this.isPicklistType) {
            const valueSet =
                this.templateItem.technicalAttribute?.picklistDefinition?.values.length > 0 ?
                this.templateItem.technicalAttribute?.picklistDefinition?.values.split(';') : '';
            this.picklistOptions = this.getPicklistOptions(valueSet);
        }
        if (isEmptyString(this.attributeRecordInfo.id)) {
            this.noRecordsFound = true;
            this.loadChartView();
            return;
        }
        this.loadHistoryRecords();
    }

    loadHistoryRecords () {
        const jsonRequest = {
            attributeId: this.attributeRecordInfo.id,
            sourceObjectName: ASSET_OBJ.objectApiName,
        }
        this.apiInProgress = true;
        getAttributeHistories({ requestJson: JSON.stringify(jsonRequest) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const historyRecords = result?.data?.attributeHistoryDetailList;

                if (isUndefinedOrNull(historyRecords) ||
                    historyRecords?.length === 0) {
                    this.noRecordsFound = true;
                    this.loadChartView();
                    return;
                }
                this.attributeHistories = this.populateHistoryRecordsByType(historyRecords);
                this.attributeHistoryList = JSON.parse(JSON.stringify(this.attributeHistories));
                this.sortData(this.attributeHistoryList);
                this.loadChartView();
            }).catch(error => {
                this.attributeHistoryList= [];
                this.attributeHistories = [];
                this.listViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    loadChartView () {
        if (this.isNumberType && this.previousNumberChartView) {
            this.tableView = false;
            this.viewChartMode();
        }
    }

    populateHistoryRecordsByType (data) {
        const historyList =[];

        if (data?.length > 0) {
            data.forEach(row=>{
                historyList.push(this.formatValue(row));
            })
        }
        return historyList;
    }

    prepareChartConfigs () {

        if ( isUndefinedOrNull(this.attributeHistoryList) ||
            this.attributeHistoryList?.length === 0) {
            return;
        }
        this.chartConfiguration = {};
        const xAxisData = [];
        const yAxisData = [];
        let historyRecords = [];
        let chartViewData = [];
        historyRecords = JSON.parse(JSON.stringify(this.attributeHistoryList));
        chartViewData = historyRecords.slice(this.startIndex,this.endIndex);

        chartViewData = sortObjectArray(
            chartViewData,
            'createdDate',
            'asc'
        );

        chartViewData.forEach(row => {
            xAxisData.push(this.formatDateLabel(row.createdDate));
            yAxisData.push(row.newValue);
        });

        this.chartConfiguration = {
            type: 'line',
            data: {
                labels: xAxisData,
                datasets: [
                    {
                        fill: false,
                        label: 'Attribute Value',
                        data: yAxisData,
                        backgroundColor: [
                            '#80aaff'
                        ],
                        borderColor: [
                            'rgb(80 152 209)'
                        ],
                        pointBackgroundColor: '#80aaff',
                        pointBorderColor: 'rgb(80 152 209)'
                    }
                ]
            },
            options: {
                legend: {
                   display: false
                },
           }
        }
        this.loadChartJS();
    }

    loadChartJS () {

        if (this.isNumberType && !this.isTableView) {
            this.chart = null;
            Promise.all([
                loadStyle(this, ChartJSCss),
                loadScript(this, chartjs)
            ]).then(() => {

                // disable CSS injection
                window.Chart.platform.disableCSSInjection = true;

                const ctx = this.template.querySelector('canvas.linechart').getContext('2d');
                this.chart = new window.Chart(ctx, this.chartConfiguration);
                this.chart.canvas.parentNode.style.height = '100%';
                this.chart.canvas.parentNode.style.width = '100%';
            }).catch(error => {
                this.error = parseErrorMessage(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading ChartJS',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
        }
    }

    formatDateLabel (data) {
        const formatOptionsDateTime = {
            "timeZone": TIMEZONE,
            "year": "numeric",
            "month": "2-digit",
            "day": "2-digit",
            "hour": "2-digit",
            "minute": "2-digit",
            "second": "2-digit"
        };
        const dateformat = new Date(data);
        return new Intl.DateTimeFormat(i18n.locale, formatOptionsDateTime).format(dateformat);
    }

    formatValue (record) {
        // eslint-disable-next-line default-case
        switch (this.attributeType) {
            case NUMBER_DATATYPE_VALUE:
                record.newValue =
                    isEmptyString(record.newValue) ? null : parseFloat(record.newValue);
                break;
            case BOOLEAN_DATATYPE_VALUE:
                record.newValue = (record.newValue === 'true');
                break;
        }
        return record;
    }

    getPicklistOptions (picklistValues) {
        let options =[]
        if (picklistValues?.length > 0 ) {
            options = picklistValues.map(item => {
                return {
                    label: item,
                    value: item
                };
            });
        }
        return options;
    }

    handleHistoryCancel () {
        this.historyViewModalOpen = false;
        this.noRecordsFound = false;
        this.attributeHistoryList= [];
        this.attributeHistories = [];
        this.listViewData = [];
        this.error=null;
        this.newValue = null;
        this.attributeRecordInfo={};
        this.templateItem = {};
        this.selectedEntry = TEN_ENTRY;
        this.startIndex = 0;
        this.endIndex = 10;
        this.sortBy = 'createdDate';
        this.sortDirection = 'desc';
        this.showUpdateBtn = false;
        this.chartConfiguration = {};
        this.tableView = true;
    }

    handleChangeEntryOption (event) {
        this.selectedEntry = event.detail.value;
        const currentMode = this.tableView;

        this.tableView = !currentMode;
        this.apiInProgress = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.tableView = currentMode;
                this.startIndex = 0;
                this.endIndex = isEmptyString(this.selectedEntry) ?
                    null : parseFloat(this.selectedEntry);
                if (!this.isTableView) {
                    this.prepareChartConfigs();
                }
            } catch (e) {
                this.error = parseErrorMessage(e);
            } finally {
                this.apiInProgress = false;
            }
        }, 100);
    }

    handleChange (event) {
        this.showUpdateBtn = false;
        const targetElement = event.target;
        this.newValue = ( targetElement.type === 'checkbox' )?
            targetElement.checked : event.detail.value;
        if (this.isPicklistType || this.isBooleanType || this.newValue) {
            this.showUpdateBtn = true;
        }
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.attributeHistoryList);
    }

    viewTableMode () {
        this.tableView = true;
        this.previousNumberChartView = false;
    }

    viewChartMode () {
        this.tableView = false;
        this.apiInProgress = true;
        this.previousNumberChartView = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.prepareChartConfigs();
            } catch (e) {
                this.error = parseErrorMessage(e);
            } finally {
                this.apiInProgress = false;
            }
        }, 100);
    }

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "name" : this.sortBy;
        this.attributeHistoryList = sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }


    handleUpdate () {
        if (!this.isValidInput()) return;
        this.attributeRecordInfo.value =
             isEmptyString(this.newValue)? '' : this.newValue.toString();
        this.dispatchUpdateEvent (this.attributeRecordInfo);
        this.handleHistoryCancel();
    }

    isValidInput () {
        let isValid = true;
        this.error = '';

        isValid = [...this.template.querySelectorAll(
            '.svmx-ta_input-field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);


        if (!isValid) {
            this.error = this.i18n.formValidation;
        }
        return isValid;
    }

    dispatchUpdateEvent (record) {
        const attributeRecord = JSON.parse(JSON.stringify(record));
        this.dispatchEvent(
            new CustomEvent('closeandrefreshpage', {
                detail: {
                    value: attributeRecord,
                }
            })
        );
    }


    castFieldToSupportType = (fieldType) => {
        let type = '';
        switch (fieldType) {
            // standard types
            case 'date':
                type = 'date-local';
                break;
            case 'datetime':
                type = 'date';
                break;
            case 'number':
                type = 'number';
                break;
            case 'boolean':
                type = 'xCheckbox';
                break;
            case 'picklist':
            case 'text':
                type = 'text';
                break;
            default:
                type = fieldType;
        }
        return type;
    }

    getTypeAttributesByType (type) {
        const typeAttributesByType = new Map([
            ['boolean',
                {
                    disabled: true,
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
            ['date', {
                month: "numeric",
                day: "numeric",
                year: "numeric",
                timeZone: "UTC"
            }]
        ]);
        return typeAttributesByType.get(type) ?? {};
    }

    getColumns () {
        return [
            {
                label: 'Date',
                fieldName: 'createdDate',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'date',
                typeAttributes: {
                    timeZone: TIMEZONE,
                    month: '2-digit',
                    day: '2-digit',
                    year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    second: "numeric"
                }
            },
            {
                label: `Value( ${this.unitLabel} )`,
                fieldName: 'newValue',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: this.castFieldToSupportType(this.attributeType),
                typeAttributes: this.getTypeAttributesByType(this.attributeType),
                cellAttributes: {
                    alignment: 'left'
                },
            },
            {
                label: 'Captured By',
                fieldName: 'createdByName',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
        ];
    }

    get i18n () {
        return i18n;
    }

    get unitLabel () {
        return isEmptyString(this.templateItem?.unit) ? '' : this.templateItem.unit
    }

    get entryOptions () {
        return [
            { label: 'Show 10 Entries', value: TEN_ENTRY },
            { label: 'Show 20 Entries', value: TWENTY_ENTRY },
            { label: 'Show 30 Entries', value: THIRTY_ENTRY },
            { label: 'Show 50 Entries', value: FIFTY_ENTRY },
        ];
    }

    get listViewRecords () {
        if (this.attributeHistoryList && this.attributeHistoryList.length > 0) {
            return this.attributeHistoryList.slice(this.startIndex,this.endIndex);
        }
        return null;
    }

    get isNumberType () {
        return this.attributeType === NUMBER_DATATYPE_VALUE;
    }

    get isTextType () {
        return this.attributeType === TEXT_DATATYPE_VALUE;
    }

    get isPicklistType () {
        return this.attributeType === PICKLIST_DATATYPE_VALUE;
    }

    get isBooleanType () {
        return this.attributeType === BOOLEAN_DATATYPE_VALUE;
    }

    get isDateType () {
        return this.attributeType === DATE_DATATYPE_VALUE;
    }

    get isDateTimeType () {
        return this.attributeType === DATETIME_DATATYPE_VALUE;
    }

    get badInputMessage () {
        return formatString(i18n.badInputDate, i18n.shortDateFormat);
    }

    get stepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 14, 4);
    }

    get tooLongMessage () {
        return formatString(i18n.tooLong, MAX_TEXT_LENGTH);
    }

    get disableUpdateBtn () {
        return !this.showUpdateBtn;
    }

    get isFromMobile () {
        return IS_MOBILE_DEVICE;
    }

    get isTableView () {
        return this.tableView;
    }

}