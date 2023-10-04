import { LightningElement, api, track } from 'lwc';
import {
    parseErrorMessage,
    verifyApiResponse,
    isEmptyString,
    isUndefinedOrNull
} from 'c/utils';

import { NavigationMixin } from 'lightning/navigation';
import getSupplierWarranties
    from '@salesforce/apex/WARR_ManageWarranty_LS.getSupplierWarranties';

import label_Supplier from '@salesforce/label/c.Label_Supplier';
import label_Component from '@salesforce/label/c.Label_Component';
import label_Expires from '@salesforce/label/c.Label_Expires';
import label_CheckNow from '@salesforce/label/c.Label_CheckNow';
import label_WarrantyNotRun from '@salesforce/label/c.Label_WarrantyNotRun';
import label_NoWarranty from '@salesforce/label/c.Label_NoWarranty';
import label_CoverageExpiresMsg from '@salesforce/label/c.Label_CoverageExpiresMsg';
import label_SupplierWarranties from '@salesforce/label/c.Label_SupplierWarranties';
import label_SupplierWarranty from '@salesforce/label/c.Label_SupplierWarranty';
import label_ShowMore from '@salesforce/label/c.Label_ShowMore';
import label_ShowLess from '@salesforce/label/c.Label_ShowLess';
import menu_ShowAll from '@salesforce/label/c.Menu_ShowAll';
import label_Error from '@salesforce/label/c.Label_Error';
import button_OK from '@salesforce/label/c.Button_OK';
import label_Found from '@salesforce/label/c.Label_Found';
import label_Warranty_Terms from '@salesforce/label/c.Label_Warranty_Terms';
import labelAsset from '@salesforce/label/c.LabelAsset';
import LOCALE from '@salesforce/i18n/locale';

const i18n = {
    supplier: label_Supplier,
    component: label_Component,
    expires: label_Expires,
    checkNow: label_CheckNow,
    warrantyNotRun: label_WarrantyNotRun,
    noWarranty: label_NoWarranty,
    coverageExpiresMsg: label_CoverageExpiresMsg,
    supplierWarranties: label_SupplierWarranties,
    supplierWarranty: label_SupplierWarranty,
    showMore: label_ShowMore,
    showLess: label_ShowLess,
    showAll: menu_ShowAll,
    error: label_Error,
    oK: button_OK,
    found: label_Found,
    warrantyTerms: label_Warranty_Terms,
    asset: labelAsset
}

const NoAsset = 'no asset';

export default class SupplierWarrantyResult extends NavigationMixin (LightningElement) {

    @api recordId;
    @api objectApiName;
    @api flexipageRegionWidth;
    @api appNavigationType;

    @track warrantyList = [];
    @track supplierWarranties = [];
    @track listViewData = [];
    @track columns;

    @track sectionInfo = {};

    initialMode = true;
    showMoreBtn = false;
    showLessBtn = false;
    tableView = false
    warrantyViewModalOpen = false;
    noWarranty = false;
    baseUrl;
    _listViewTableHeight = 100;

    showTooltip = false;
    apiInProgress = false;
    noAssetFoundMsg;

    connectedCallback () {
        this.baseUrl = window.location.origin;
        this.columns = this.getColumns();
    }

    renderedCallback () {

        const listViewTable = this.template.querySelector(
            '.svmx-supplier-warranty');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    get i18n () {
        return i18n;
    }

    get showAllBtn () {
        return this.warrantyList?.length > 10;
    }

    get computedDataTableHeight () {
        return (this.listViewData?.length > 10) ?
            `height:400px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    get cardTitle () {
        let title=this.i18n.supplierWarranties;

        if (this.warrantyList?.length > 3) {
            title = title+` (${this.warrantyList?.length} ${this.i18n.found})`;
        } else if (this.warrantyList?.length === 1) {
            title = this.i18n.supplierWarranty;
        }
        return title;
    }

    get isSmallDevice () {
        return ( this.flexipageRegionWidth.toLowerCase() === 'small');
    }

    get layoutItemSize () {
        const columns = (this.isSmallDevice) ? 2 : 3;
        return 12 / columns;
    }

    getColumns () {
        return [
            {
                label: this.i18n.asset,
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                sortable: false,
                fieldName: 'componentUrl',
                typeAttributes: {
                    label: {
                        fieldName: 'componentName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.warrantyTerms,
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                sortable: false,
                fieldName: 'warrantyTermUrl',
                typeAttributes: {
                    label: {
                        fieldName: 'warrantyTermName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.supplier,
                fieldName: 'supplierName',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: false,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.i18n.expires,
                fieldName: 'expireDate',
                type: "date",
                hideDefaultActions: true,
                wrapText: false,
                sortable: false,
                typeAttributes: {
                    month: "numeric",
                    day: "numeric",
                    year: "numeric",
                    timeZone: "UTC"
                }
            },
        ];
    }

    checkWarranty () {
        this.tableView = false;
        this.showMoreBtn = false;

        if (this.apiInProgress) return;

        this.apiInProgress = true;
        this.noAssetFoundMsg ='';
        this.error ='';
        this.noWarranty = false;
        getSupplierWarranties({ recordId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    const message = result.message.toLowerCase();
                    if (message.indexOf(NoAsset.toLowerCase()) >= 0) {
                        this.noAssetFoundMsg = result.message;
                    } else {
                        this.error = result.message;
                    }
                    return;
                }

                const warrRecords = result?.data;
                if (isUndefinedOrNull(warrRecords) ||
                    warrRecords?.length === 0) {
                    this.noWarranty = true;
                    return;
                }
                this.warrantyList = this.populateWarrantyRecords(warrRecords);
                if (this.warrantyList?.length > 0) {
                    this.tableView = true;

                    if (this.warrantyList?.length > 3) {
                        this.showMoreBtn = true;
                    }
                    const warranties = JSON.parse(JSON.stringify(this.warrantyList));
                    this.listViewData = warranties.slice(0,3);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.warrantyList =[];
                this.listViewData =[];
            }).finally( () => {
                this.apiInProgress = false;
                this.initialMode = false;
            });
    }

    populateWarrantyRecords (data) {
        const sfdcBaseUrl = this.baseUrl+'/';
        if (data?.length > 0) {
            data.forEach(row=>{
                if (row.componentId) {
                    row.componentUrl = sfdcBaseUrl + row.componentId;
                }
                if (row.warrantyTermId) {
                    row.warrantyTermUrl = sfdcBaseUrl + row.warrantyTermId;
                }
                row.expireDate = this.formatDateLabel(row?.expireDate);
                row.helpText = `${this.i18n.expires} ${row.expireDate} <br/> ${row.supplierName}`;
            })
        }
        return data;
    }

    viewAssetRecord (event) {
        const targetElement = event.target;
        const targetRecordId = targetElement.dataset.assetid;
        this.redirectToRecordPage (targetRecordId,'Asset');
    }

    viewWarrantyTermRecord (event) {
        const targetElement = event.target;
        const targetRecordId = targetElement.dataset.id;
        this.redirectToRecordPage (targetRecordId,'WarrantyTerm');
    }

    redirectToRecordPage (recId,objectName) {
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objectName,
                actionName: 'view' },
        };
        this[NavigationMixin.GenerateUrl](pageRef)
            .then(url => { window.open(url); });
    }

    showMore () {
        this.showMoreBtn = false;
        this.showLessBtn = true;

        const warranties = JSON.parse(JSON.stringify(this.warrantyList));
        this.listViewData = warranties.slice(0,10);
    }

    showLess () {
        this.showMoreBtn = true;
        this.showLessBtn = false;
        const warranties = JSON.parse(JSON.stringify(this.warrantyList));
        this.listViewData = warranties.slice(0,3);
    }

    showAll () {
        this.warrantyViewModalOpen = true;
    }

    handleMouseOver (event) {
        const targetElement = event.target;
        const id = targetElement.dataset.id;
        const eachRecordData = {};
        if (!this.isSmallDevice) {
            return;
        }

        if (!isEmptyString(id)) {

            const warranty = this.warrantyList.find(
                item => item.id === id);
            const iconHighlighted =
                this.template.querySelector(`div[data-sectionid="${id}"]`);
            const requiredTopPosition = 51;
            const requiredPosition = 94;
            const elmtop = iconHighlighted.getBoundingClientRect().top;
            const elmleft = iconHighlighted.getBoundingClientRect().left;
            const top = elmtop - requiredTopPosition;
            const left = elmleft - requiredPosition;
            eachRecordData.thresholdPOStyle
                =`position:fixed;transform:translate(${left}px,${top}px);`
            eachRecordData.thresholdPOStyle += 'inset:0px auto auto 0px;';
            eachRecordData.thresholdPOStyle += this.isSmallDevice ?
                'width:20%;' : 'width:25%';
            eachRecordData.bodyStyle = 'height: 150px;';
            eachRecordData.message = `${this.i18n.expires} ${warranty?.expireDate}`;
            eachRecordData.warranty = warranty;
            this.sectionInfo = eachRecordData;
            this.showTooltip = true;
        }
    }

    handleMouseOut () {
        this.sectionInfo = {}
        this.showTooltip = false;

    }

    formatDateLabel (dateVal) {
        if (dateVal === null || dateVal === undefined || dateVal ==='') {
            return null;
        }
        const formatOptionsDate = {
            "timeZone": 'UTC',
            "year": "numeric",
            "month": "2-digit",
            "day": "2-digit"
        };
        const dateformat = new Date(dateVal);
        return new Intl.DateTimeFormat(LOCALE, formatOptionsDate).format(dateformat);
    }

    handleWarrantyCancel () {
        this.warrantyViewModalOpen = false;
    }
}