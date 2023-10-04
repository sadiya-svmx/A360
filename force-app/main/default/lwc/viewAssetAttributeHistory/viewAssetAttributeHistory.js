/* eslint-disable max-len */
import { LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import contractLineItemsListViewResource from '@salesforce/resourceUrl/contractLineItemsListView';
import NAME_FIELD from '@salesforce/schema/Asset.Name';
import LOCALE from '@salesforce/i18n/locale';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import fetchAttributesHistoryList from '@salesforce/apex/TA_TechnicalAttribute_LS.fetchAttributesHistoryList';
import fetchAllAttributes from '@salesforce/apex/TA_TechnicalAttribute_LS.fetchAllAttributes';
import labelAttributeHistoryTitle from '@salesforce/label/c.Label_AssetAttributeHistory';
import labelSelectAttribute from '@salesforce/label/c.Label_SelectAttributes';
import labelSelectAttributeModalLabel from '@salesforce/label/c.Label_SelectAttributesModalLabel';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelApply from '@salesforce/label/c.Button_Apply';
import labelAvailable from '@salesforce/label/c.Label_Available';
import labelSelected from '@salesforce/label/c.Label_Selected';
import labelStartDate from '@salesforce/label/c.Label_FromDate';
import labelEndDate from '@salesforce/label/c.Label_ToDate';
import labelHighlightOutOfBound from '@salesforce/label/c.Label_highlightOutOfBound';
import labelDateError from '@salesforce/label/c.Label_FromDateLessThanToDate';
import labelToDateError from '@salesforce/label/c.Label_ToDateMoreThanFromDate';
import labelAttributeSelectionError from '@salesforce/label/c.Label_AttributeSelectionError';
import labelApplyBtn from '@salesforce/label/c.Button_Apply';
import labelRequiredFieldMsg from '@salesforce/label/c.Label_RequiredFieldMsg';
import labelRecordCountValidationMsg from '@salesforce/label/c.Label_RecordCountValidationMsg';
import labelAttributeHistoryHelpText from '@salesforce/label/c.Label_AttributeHistoryHelpText';
import labelAttributeHistoryNoRecords from '@salesforce/label/c.Label_AttributeHistoryNoRecords';
import labelAttributeHistoryHelpLink from '@salesforce/label/c.Label_AttributeHistoryHelpLink';
import labelAttributeHistoryDownload from '@salesforce/label/c.Label_AttributeHistoryDownload';
import {
    parseErrorMessage,
    verifyApiResponse,
    isNotUndefinedOrNull,
    sortObjectArray
} from 'c/utils';
import ICONS from '@salesforce/resourceUrl/pscIcons';
import labelHelp from '@salesforce/label/c.Label_Help';
const i18n = {
    helpLink: labelAttributeHistoryHelpLink,
    help: labelHelp,
    attributeHistoryTitle: labelAttributeHistoryTitle,
    selectAttribute: labelSelectAttribute,
    selectAttributeModalLabel: labelSelectAttributeModalLabel,
    cancel: labelCancel,
    apply: labelApply,
    available: labelAvailable,
    selected: labelSelected,
    startDate: labelStartDate,
    endDate: labelEndDate,
    dateError: labelDateError,
    highlightOutOfBound: labelHighlightOutOfBound,
    locale: LOCALE,
    timezone: TIMEZONE,
    toDateError: labelToDateError,
    attributeSelectionError: labelAttributeSelectionError,
    applyBtn: labelApplyBtn,
    labelRequiredFieldMsg: labelRequiredFieldMsg,
    labelRecordCountValidationMsg: labelRecordCountValidationMsg,
    labelAttributeHistoryHelpText: labelAttributeHistoryHelpText,
    labelAttributeHistoryNoRecords: labelAttributeHistoryNoRecords,
    labelAttributeHistoryDownload: labelAttributeHistoryDownload
}
const MAX_RECORDCOUNT = 4000;
export default class ViewAssetAttributeHistory extends NavigationMixin (LightningElement) {
    i18n = i18n;
    logoUrl = `${ICONS}/pscIcons/ServiceMax_Logo.svg`;
    recordId;
    apiInProgress = false;
    objectAPIName;
    showModal = false;
    hasEmptySelectedId = true;
    dateError = false;
    disableApplyBtn = true;
    endDate;
    startDate;
    error;
    isHighlightOutOfBound = false;
    noRecordsFound = false;
    columnFieldNameToLabel = new Map();
    @track selectedAttributes = new Set();
    @track allAssetAttribute = [];
    @track allAssetAttributeDetailList = [];
    @track attributeHistoryList = [];
    @track allAttributeHistoryList = [];
    @track columns = [];
    @track data = [];
    @track userInfo;
    @track sortBy = 'createdDate';
    @track sortDirection = 'desc';

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD]})
    assetRecord;

     get assetName () {
        return getFieldValue(this.assetRecord.data, NAME_FIELD);
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        this.apiInProgress = true;
        if (currentPageReference && currentPageReference.state) {
            this.clearState();
            if (currentPageReference.state.c__recordId) {
                this.recordId = currentPageReference.state.c__recordId;
            }
            if (currentPageReference.state.c__objectAPIName) {
                this.objectAPIName = currentPageReference.state.c__objectAPIName;
            }
            if (currentPageReference.state.c__userInfo) {
                this.userInfo = JSON.parse(currentPageReference.state.c__userInfo);
            }
            this.endDate = new Date();
            this.startDate = new Date();
            let month, date;
            this.startDate.setDate(this.endDate.getDate() - 30);
            //accepted input date format yyyy-mm-dd, eg- 2023-09-01
            month = this.startDate.getMonth() + 1;
            month = month < 10? '0'+month : month;
            date = this.startDate.getDate() < 10 ? '0'+this.startDate.getDate() : this.startDate.getDate();
            this.startDate = this.startDate.getFullYear()+'-'+month+'-'+date;

            month = this.endDate.getMonth() + 1;
            month = month < 10? '0'+month : month;
            date = this.endDate.getDate() < 10 ? '0'+this.endDate.getDate() : this.endDate.getDate();
            this.endDate = this.endDate.getFullYear()+'-'+month+'-'+date;
            this.loadData();
        }
    }

    renderedCallback () {
        loadStyle(this, contractLineItemsListViewResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    loadData () {
        this.apiInProgress = true;
        fetchAllAttributes ({ parentRecordId: this.recordId, objectName: this.objectAPIName })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                if (isNotUndefinedOrNull(result.data)) {
                    this.allAssetAttributeDetailList = JSON.parse(JSON.stringify(result.data));
                    result.data.forEach( rec => {
                        const hasAttribute = this.allAssetAttribute.find(element => {
                            if (element.value === rec.id) {
                              return true;
                            }
                            return false;
                          });
                        if (!this.selectedAttributes.has(rec.id) && !hasAttribute) {
                            const row = {};
                            row.value = rec.id;
                            row.label = rec.name;
                            this.allAssetAttribute.push(row);
                        }
                    })
                }
                this.fetchAttributesHistoryList();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.apiInProgress = false;
            })
    }

    fetchAttributesHistoryList () {
        const jsonRequest = {};
        jsonRequest.objectId = this.recordId;
        jsonRequest.objectName = this.objectAPIName;
        jsonRequest.startDate = this.startDate;
        jsonRequest.endDate = this.endDate;
        this.columns = [];
        this.data = [];
        this.noRecordsFound = false;
        if (this.selectedAttributes?.size === 0) {
            const idList = [];
            this.allAssetAttribute.forEach( rec => idList.push(rec.value) );
            jsonRequest.attributeIdList = idList;
        } else {
            jsonRequest.attributeIdList = [...this.selectedAttributes];
        }
        this.attributeHistoryList = [];
        this.allAttributeHistoryList = [];
        this.error = '';
        fetchAttributesHistoryList ({ jsonRequest: JSON.stringify(jsonRequest) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                if (isNotUndefinedOrNull(result.data) && result.data.length !== 0) {
                    this.allAttributeHistoryList = result.data;
                    this.sortData(this.allAttributeHistoryList);
                    if (this.allAttributeHistoryList.length > MAX_RECORDCOUNT) {
                        this.error = this.i18n.labelRecordCountValidationMsg;
                        this.apiInProgress = false;
                        return;
                    }
                    this.attributeHistoryList = this.allAttributeHistoryList;
                    this.constructColumn();
                    this.constructData();
                } else {
                    this.noRecordsFound = true;
                }
                this.apiInProgress = false;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.apiInProgress = false;
            })
    }

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "name" : this.sortBy;
        this.allAttributeHistoryList = sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

    constructColumn () { //formatting to be taken care
        this.columns = [];
        let eachCol;
        const columnNameList = []; //to prevent duplicate entry
        eachCol = { 'label': 'Attribute Name', 'fieldName': 'attributeName', 'type': 'button', 'initialWidth': 250, 'typeAttributes': { label: { fieldName: 'attributeName' }, name: 'view',variant: 'base' }, 'cellAttributes': { alignment: 'left' }};
        this.columns.push(eachCol);
        this.attributeHistoryList.forEach(rec => {
            if (!columnNameList.includes(rec.createdDate)) {
                eachCol = {};
                const colLabel = this.formatColumnLabel(rec.createdDate, "h11") +' ('+rec.createdByName+')';
                eachCol = { 'label': colLabel,
                'fieldName': rec.createdDate,
                'type': 'text',
                'cellAttributes': {
                    'iconName': { 'fieldName': colLabel },
                    'iconPosition': 'right',
                    'class': { 'fieldName': colLabel+'_class' }
                }, };
                this.columns.push(eachCol);
                columnNameList.push(rec.createdDate);
            }
        })
        if (this.columns.length > 5) {
            this.columns.forEach(col => {
                col.initialWidth = 275;
            });
        } else if (this.columns.length === 2) {
            this.columns[0].initialWidth = 0;
            this.columns[1].initialWidth = 1000;
        }
    }
    //This is for formatting  dateTime
    formatColumnLabel (fieldName, hourCycle) {
        const formatOptionsDateTime = {
            "hourCycle": hourCycle,
            "timeZone": this.i18n.timezone,
            "year": "numeric",
            "month": "2-digit",
            "day": "2-digit",
            "hour": "2-digit",
            "minute": "2-digit",
            "second": "2-digit"
        };
        const dateformat = new Date(fieldName);
        return new Intl.DateTimeFormat(i18n.locale, formatOptionsDateTime).format(dateformat);
    }

    formatDateLabel (fieldName) {
        const formatOptionsDate = {
            "timeZone": this.i18n.timezone,
            "year": "numeric",
            "month": "2-digit",
            "day": "2-digit"
        };
        const dateformat = new Date(fieldName);
        return new Intl.DateTimeFormat(i18n.locale, formatOptionsDate).format(dateformat);
    }

    constructData () {
        this.data = [];
        //this.datatableData = [];
        const rowSet = [];
        this.attributeHistoryList.forEach(rec => {
            const attributeDetails = this.allAssetAttributeDetailList.find(attr => attr.id === rec.parentId)
            if (!rowSet.includes(rec.parentId)) {
                const row = {};
                row.attributeName = isNotUndefinedOrNull(attributeDetails.unit) ? attributeDetails.name + '('  + attributeDetails.unit + ')' : attributeDetails.name;
                row.id = rec.parentId;
                row.attributeType = attributeDetails.dataType;
                row.minValue =  parseFloat(attributeDetails.minimumValue);
                row.maxValue =  parseFloat(attributeDetails.maximumValue);
                this.columns.forEach(col => {
                    if (col.fieldName !== 'attributeName') {
                        row[col.fieldName] = '';
                    }
                })
                rowSet.push(rec.parentId);
                this.data.push(row);
            }
        })

        this.attributeHistoryList.forEach(rec => {
            const row = this.data.find(item => {return item.id === rec.parentId});
            if ( row.attributeType === 'Datetime' ) {
                row[rec.createdDate] = this.formatColumnLabel(rec.newValue, "h11");
            } else if ( row.attributeType === 'Date' ) {
                row[rec.createdDate] = this.formatDateLabel(rec.newValue);
            } else {
                row[rec.createdDate] = rec.newValue;
            }
        })

        if (this.isHighlightOutOfBound) {
            this.data.forEach(rec => {
                if (rec.attributeType === 'Number') {
                    this.columns.forEach(col => {
                        if (col.fieldName !== 'attributeName') {
                            const classs = col.label+'_class';
                            if (parseFloat(rec[col.fieldName]) < rec.minValue) {
                                rec[col.label] = 'utility:arrowdown';
                                rec[classs] = 'svmx-historyDatatable-outOfBoundValue';
                            } else if (parseFloat(rec[col.fieldName]) > rec.maxValue) {
                                rec[col.label] = 'utility:arrowup';
                                rec[classs] = 'svmx-historyDatatable-outOfBoundValue';
                            }
                        }
                    })
                }
            })
        }
    }

    handleOnChangeOutOfBound (event) {
        this.isHighlightOutOfBound = event.target.checked;
        this.constructData();
    }

    handleDownloadClick () {
        // Prepare a html table
        let doc = '<head>';
        doc += '</head>';
        doc += '<table><tr>';
        doc += '<td><b>'+this.assetName +'</b> </td>';
        doc += '<td><b>'+this.i18n.startDate +':</b> </td>';
        doc += '<td style="text-align:left">'+this.startDate+'</td>';
        doc += '<td><b>'+this.i18n.endDate+' :</b></td>';
        doc += '<td style="text-align:left">'+this.endDate+'</td>';
        if (this.isHighlightOutOfBound) {
            doc += '<td><p><span style="font-size:10px;">&#9745;</span> '+ this.i18n.highlightOutOfBound+'</td></tr></table><br>';
        } else {
            doc += '<td><p>&#x2610; '+ this.i18n.highlightOutOfBound+'</td></tr></table><br>';
        }
        doc += '<table>';
        doc += '<style>';
        doc += 'table, th, td {';
        doc += 'border: 1px solid black;';
        doc += 'border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columns.forEach(col => {
            doc += '<th>'+ col.label +'</th>'
        });
        doc += '</tr>';
        // Add the data rows
        this.data.forEach(record => {
            doc += '<tr>';
            this.columns.forEach(col => {
                doc += '<td style="text-align: left">';
                if (this.isHighlightOutOfBound && record[col.label] === 'utility:arrowdown') {
                    doc += '<p style="color: #e06000;">'+record[col.fieldName]+'&#8595;</p></td>';
                } else if (this.isHighlightOutOfBound  && record[col.label] === 'utility:arrowup') {
                    doc += '<p style="color: #e06000;">'+record[col.fieldName]+'&#8593;</p></td>';
                } else {
                    doc += '<p>'+record[col.fieldName]+'</p></td>';
                }
                doc += '</td>';
            })
            doc += '</tr>';
        });
        doc += '</table>';
        const element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        const downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = this.calculateFileName();
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    calculateFileName () {
        const todaysDate =  new Date();
        let date = this.formatColumnLabel(todaysDate, "h23");
        date = date.replace(/\//g,'-')
        date = date.replace(/,/, '');
        date = date.replace(/:/g, '-');
        const fileName = 'AttributesHistory '+this.assetName+' '+date+'('+this.userInfo.userTimeZoneName.replace(/ *\([^)]*\) */g,'')+').xls';
        return fileName;
    }

    handleCancelModal () {
        this.showModal = false;
    }

    handleSelectAttributeClick () {
        this.showModal = true;
        this.hasEmptySelectedId = true;
    }

    handleApply () {
        this.apiInProgress = true;
        this.showModal = false;
        if ( !this.dateError ) {
            this.loadData();
            this.disableApplyBtn = true;
        }
    }

    handleSelectChange (event) {
        this.selectedAttributes = new Set();
        event.detail.value.forEach( rec => {
            this.selectedAttributes.add(rec);
        });
        this.hasEmptySelectedId = false;
    }

    handleDateChange (event) {
        const dateName = event.target.name;
        const dateValue = event.target.value;
        const startDateField = this.template.querySelector('.svmx-startDate');
        const endDateField = this.template.querySelector('.svmx-endDate');
        if ( isNotUndefinedOrNull(dateValue) ) {
            if ( dateName === 'fromDate') {
                if (isNotUndefinedOrNull(this.endDate)) {
                    if (Date.parse(dateValue) > Date.parse(this.endDate)) {
                        startDateField.setCustomValidity(this.i18n.dateError);
                        this.dateError = true;
                    } else {
                        startDateField.setCustomValidity('');
                        if (!endDateField.checkValidity()) {
                            endDateField.setCustomValidity('');
                        }
                        this.dateError = false;
                    }
                } else {
                    this.dateError = true;
                }
                this.startDate = dateValue;
            } else {
                if (isNotUndefinedOrNull(this.startDate)) {
                    if (Date.parse(dateValue) < Date.parse(this.startDate)) {
                        endDateField.setCustomValidity(this.i18n.toDateError);
                        this.dateError = true;
                    } else {
                        endDateField.setCustomValidity('');
                        if (!startDateField.checkValidity()) {
                            startDateField.setCustomValidity('');
                        }
                        this.dateError = false;
                    }
                } else {
                    this.dateError = true;
                }
                this.endDate = dateValue;
            }
            startDateField.reportValidity();
            endDateField.reportValidity();
        } else {
            if ( dateName === 'fromDate' ) {
                this.startDate = null;
            } else {
                this.endDate = null;
            }
            if ( this.startDate === null || this.endDate === null ) {
                this.dateError = true;
            }
        }
        if (this.dateError) {
            this.disableApplyBtn = true;
        } else {
            this.disableApplyBtn = false;
        }
    }

    viewAssetDetail () {
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectAPIName, // objectApiName is optional
                actionName: 'view'
            }
        }
        if ( this.userInfo.userType !== 'Standard' && this.userInfo.userType !== 'CsnOnly') {
            this[NavigationMixin.Navigate](pageRef);
        } else {
            this[NavigationMixin.GenerateUrl](pageRef).then(url => {
                window.open(url, "_blank");
            });
        }
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    get getColumns () {
        return this.columns;
    }

    get getData () {
        return this.data;
    }

    get getAllAssetAttribute () {
        return this.allAssetAttribute;
    }

    get getSelectedAttribute () {
        const selectedList = [...this.selectedAttributes];
        return selectedList;
    }

    get isDownloadDisabled () {
        return this.attributeHistoryList.length <= 0 ? true : false;
    }

    clearState () {
        this.selectedAttributes = new Set();
        this.allAssetAttribute = [];
        this.allAssetAttributeDetailList = [];
        this.attributeHistoryList = [];
        this.allAttributeHistoryList = [];
        this.columns = [];
        this.data = [];
        this.showModal = false;
        this.hasEmptySelectedId = true;
        this.columnFieldNameToLabel = new Map();
    }
}