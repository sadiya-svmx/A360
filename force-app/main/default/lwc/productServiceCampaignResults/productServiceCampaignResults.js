import { LightningElement, api, track, wire } from 'lwc';
import { parseErrorMessage, verifyApiResponse, formatString } from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/ProductServiceCampaign.ProductServiceCampaignName';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import ChartJSCss from '@salesforce/resourceUrl/ChartJSCSS';
import { loadScript,loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labelResultLines from '@salesforce/label/c.Label_ResultLines';
import labelManage from '@salesforce/label/c.Label_Manage';
import labelManageLines from '@salesforce/label/c.Label_ManageLines';
import labelNoResultLinesFound from '@salesforce/label/c.Label_NoResultLinesFound';
import labelLinesDelivered from '@salesforce/label/c.Label_LinesDelivered';
import labelLinesGenerated from '@salesforce/label/c.Label_LinesGenerated';
import labelCases from '@salesforce/label/c.Label_Case';
import labelReturnOrder from '@salesforce/label/c.Label_ReturnOrder';
import labelWorkOrder from '@salesforce/label/c.Label_WorkOrder';
import labelOpportunity from '@salesforce/label/c.Label_Opportunity';
import labelAssetNotification from '@salesforce/label/c.Label_AssetNotification';
import labelDeliveryInProgress from '@salesforce/label/c.Label_DeliveryInProgress';
import labelStatusDraft from '@salesforce/label/c.Label_PscStatusDraft';
import labelStatusOutputGenerated from '@salesforce/label/c.Label_Status_OutputGenerated';
import labelErrorloadingChartJS from '@salesforce/label/c.Label_ErrorloadingChartJS';
import getResultLineStatus from '@salesforce/apex/PSC_ManageResults_LS.getResultLineStatus';
import getAppNavigationType
    from '@salesforce/apex/COMM_DatabaseUtils.fetchApplicationNavigationType';

const i18n = {
    pageHeader: labelResultLines,
    manageButton: labelManage,
    manageLinesMsg: labelManageLines,
    noResultLinesFoundMsg: labelNoResultLinesFound,
    labelLinesDelivered: labelLinesDelivered,
    labelLinesGenerated: labelLinesGenerated,
    cases: labelCases,
    returnOrder: labelReturnOrder,
    workOrder: labelWorkOrder,
    opportunity: labelOpportunity,
    assetNotification: labelAssetNotification,
    labelDeliveryInProgress: labelDeliveryInProgress,
    statusOutputGenerated: labelStatusOutputGenerated,
    statusDraft: labelStatusDraft,
    errorLoadingChartJs: labelErrorloadingChartJS
}

const CONSOLE = 'Console';
export default class ProductServiceCampaignResults extends NavigationMixin(LightningElement) {
    @api recordId;
    @track resultLineStatus;
    isChartJsInitialized;
    generatedChart;
    deliveredChart;
    activateTabs = false;

    hasGeneratedOutput = false;
    hasLines = false;
    hasCases = false;
    hasWorkOrder= false;
    hasReturnOrder = false;
    hasOpportunity = false;
    hasAssetNotification = false;
    apiInProgress = true;
    showProgressBar = false;
    lineCardMessage;
    progressCounter = 0;

    linesGenerated = '';
    linesDelivered = '';
    appNavigationType;

    get i18n () {
        return i18n;
    }

    get isManageDisabled () {
        return !this.hasLines;
    }

    connectedCallback () {
        if (null == this.recordId) return;

        getAppNavigationType()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                if (result) {
                    this.appNavigationType = result.data;
                }
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            });
        this.fetchResultLineStatus();
    }

    renderedCallback () {
        if (!this.activateTabs) {
            const tabsetelement =this.template.querySelector('lightning-tabset');
            if (tabsetelement) {
                tabsetelement.activeTabValue = 'deliveredChartTab';
                tabsetelement.activeTabValue = 'generatedChartTab';
                this.activateTabs = true;
            }
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ NAME_FIELD ]})
    // eslint-disable-next-line no-unused-vars
    getRecordItems (recordData) {
        this.fetchResultLineStatus();
    }

    fetchResultLineStatus () {
        getResultLineStatus({ pscRecordId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.error = '';
                this.resultLineStatus = result.data;

                if (this.resultLineStatus.isBatchRunning) {
                    this.showProgressBar = true;
                    this.progressCounter = (
                        this.resultLineStatus.linesDelivered
                        /this.resultLineStatus.totalLinesForDelivery
                    ) * 100;

                    window.clearTimeout(this.delayTimeout);

                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    this.delayTimeout = setTimeout(() => {
                        try {
                            this.fetchResultLineStatus();
                        } catch (error) {
                            this.handleError( parseErrorMessage(error) );
                        }
                    }, 300);
                    this.lineCardMessage =this.getManageLineMessage();
                    return;
                }
                this.progressCounter = 100;
                this.showProgressBar = false;

                this.hasLines =
                (this.resultLineStatus.linesGenerated === 0 &&
                 this.resultLineStatus.linesDelivered === 0)
                    ? false: true;

                this.linesDelivered =
                    formatString(i18n.labelLinesDelivered, this.resultLineStatus.linesDelivered);

                this.linesGenerated =
                    formatString(i18n.labelLinesGenerated, this.resultLineStatus.linesGenerated);

                this.hasGeneratedOutput = this.resultLineStatus.linesDelivered === 0 ? false : true;
                this.hasCases = this.resultLineStatus.casesDelivered === 0 ? false: true;
                this.hasWorkOrder = this.resultLineStatus.workOrderDelivered === 0 ? false: true;
                this.hasReturnOrder
                    = this.resultLineStatus.returnOrderDelivered === 0 ? false: true;
                this.hasOpportunity
                    = this.resultLineStatus.opportunityDelivered === 0 ? false: true;
                this.hasAssetNotification
                    = this.resultLineStatus.assetNotificationDelivered === 0 ? false: true;

                this.resultLineStatus.casesDelivered = this.hasCases
                    ? this.formatCount(this.resultLineStatus.casesDelivered) : '';
                this.resultLineStatus.workOrderDelivered = this.hasWorkOrder
                    ? this.formatCount(this.resultLineStatus.workOrderDelivered): '';
                this.resultLineStatus.returnOrderDelivered = this.hasReturnOrder
                    ?  this.formatCount(this.resultLineStatus.returnOrderDelivered) : '';
                this.resultLineStatus.opportunityDelivered = this.hasOpportunity
                    ?  this.formatCount(this.resultLineStatus.opportunityDelivered) : '';
                this.resultLineStatus.assetNotificationDelivered = this.hasAssetNotification
                    ?  this.formatCount(this.resultLineStatus.assetNotificationDelivered) : '';

                this.lineCardMessage =
                    this.hasLines ? this.getManageLineMessage()  : i18n.noResultLinesFoundMsg;
                if (this.hasLines) {
                    if (this.isChartJsInitialized) {
                        return;
                    }
                    this.isChartJsInitialized = true;
                    Promise.all([
                        loadStyle(this, ChartJSCss),
                        loadScript(this, chartjs)
                    ]).then(() => {
                        const configForGeneratedChart = this.configDataForGeneratedChart();
                        const configForDeliveredChart = this.configDataForDeliveredChart();
                        // disable CSS injection
                        window.Chart.platform.disableCSSInjection = true;
                        let canvasElement = this.template.querySelector('canvas.generatedChart');
                        if (canvasElement) {
                            const ctx = canvasElement.getContext('2d');
                            this.generatedChart =
                                        new window.Chart(ctx, configForGeneratedChart);
                            this.generatedChart.canvas.parentNode.style.height = '100%';
                            this.generatedChart.canvas.parentNode.style.width = '100%';
                        }

                        canvasElement = this.template.querySelector('canvas.deliveredChart');
                        if (canvasElement) {
                            const ctx2 = canvasElement.getContext('2d');
                            this.deliveredChart =
                                        new window.Chart(ctx2, configForDeliveredChart);
                            this.deliveredChart.canvas.parentNode.style.height = '100%';
                            this.deliveredChart.canvas.parentNode.style.width = '100%';
                        }
                    }).catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.i18n.errorLoadingChartJs,
                                message: error.message,
                                variant: 'error',
                            }),
                        );
                    });
                } else {
                    this.isChartJsInitialized = false;
                }
            })
            .catch(error => {
                this.resultLineStatus = {};
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false
            });
    }

    getManageLineMessage () {
        return formatString(i18n.manageLinesMsg, '<b>' + i18n.manageButton + '</b>');
    }

    formatCount (count) {
        return count.toString().padStart(2, '0');
    }

    handleManage () {
        const navigationObj = {
            type: 'standard__component',
            attributes: { componentName: 'SVMXA360__pscResultLines' },
            state: { c__pscId: this.recordId, c__type: this.appNavigationType }
        };

        if ( this.appNavigationType === CONSOLE ) {
            this[NavigationMixin.Navigate](navigationObj);
        } else {
            this[NavigationMixin.GenerateUrl](navigationObj)
                .then(generatedUrl => {
                    window.location.replace(generatedUrl);
                });
        }
    }

    configDataForGeneratedChart () {
        const draftColorCode = '#FFB03B';
        const outputGeneratedColorCode = '#52B7D8';
        const generatedChartConfig = {
            type: 'doughnut',
            data: {},
            options: {
                legend: {
                    position: 'right',
                    align: 'start',
                    labels: {
                        usePointStyle: true,
                        fontColor: '#000000'
                    }
                }
            }
        };
        const data = {
            datasets: [],
            labels: []
        };

        const draftCount =
            this.resultLineStatus.linesGenerated - this.resultLineStatus.linesDelivered;
        const datasetObject = {
            data: [],
            backgroundColor: [],
            hoverBackgroundColor: [],
            hoverBorderColor: [],
            hoverBorderWidth: 2
        };

        if (draftCount > 0) {
            datasetObject.data.push(draftCount);
            data.labels.push(this.i18n.statusDraft);
            datasetObject.backgroundColor.push(draftColorCode);
            datasetObject.hoverBackgroundColor.push(draftColorCode);
            datasetObject.hoverBorderColor.push(draftColorCode);
        }

        if (this.resultLineStatus.linesDelivered > 0) {
            datasetObject.data.push(this.resultLineStatus.linesDelivered);
            data.labels.push(this.i18n.statusOutputGenerated);
            datasetObject.backgroundColor.push(outputGeneratedColorCode);
            datasetObject.hoverBackgroundColor.push(outputGeneratedColorCode);
            datasetObject.hoverBorderColor.push(outputGeneratedColorCode);
        }

        data.datasets.push(datasetObject);
        generatedChartConfig.data = data;
        return generatedChartConfig;
    }

    configDataForDeliveredChart () {
        const workOrderColorCode = '#52B7D8';
        const caseColorCode = '#E16032';
        const returnOrderColorCode = '#FFB03B';
        const assetNotiColorCode = '#54A77B';
        const opportunityColorCode = '#E287B2';

        const deliveredChartConfig = {
            type: 'doughnut',
            data: {},
            options: {
                legend: {
                    position: 'right',
                    align: 'start',
                    labels: {
                        usePointStyle: true,
                        fontColor: '#000000'
                    }
                }
            }
        };
        const data = {
            datasets: [],
            labels: []
        };
        const datasetObject = {
            data: [],
            backgroundColor: [],
            hoverBackgroundColor: [],
            hoverBorderColor: [],
            hoverBorderWidth: 2
        };

        if (this.hasWorkOrder) {
            datasetObject.data.push(this.resultLineStatus.workOrderDelivered);
            data.labels.push(this.i18n.workOrder);
            datasetObject.backgroundColor.push(workOrderColorCode);
            datasetObject.hoverBackgroundColor.push(workOrderColorCode);
            datasetObject.hoverBorderColor.push(workOrderColorCode);
        }

        if (this.hasCases) {
            datasetObject.data.push(this.resultLineStatus.casesDelivered);
            data.labels.push(this.i18n.cases);
            datasetObject.backgroundColor.push(caseColorCode);
            datasetObject.hoverBackgroundColor.push(caseColorCode);
            datasetObject.hoverBorderColor.push(caseColorCode);
        }

        if (this.hasReturnOrder) {
            datasetObject.data.push(this.resultLineStatus.returnOrderDelivered);
            data.labels.push(this.i18n.returnOrder);
            datasetObject.backgroundColor.push(returnOrderColorCode);
            datasetObject.hoverBackgroundColor.push(returnOrderColorCode);
            datasetObject.hoverBorderColor.push(returnOrderColorCode);
        }

        if (this.hasAssetNotification) {
            datasetObject.data.push(this.resultLineStatus.assetNotificationDelivered);
            data.labels.push(this.i18n.assetNotification);
            datasetObject.backgroundColor.push(assetNotiColorCode);
            datasetObject.hoverBackgroundColor.push(assetNotiColorCode);
            datasetObject.hoverBorderColor.push(assetNotiColorCode);
        }

        if (this.hasOpportunity) {
            datasetObject.data.push(this.resultLineStatus.opportunityDelivered);
            data.labels.push(this.i18n.opportunity);
            datasetObject.backgroundColor.push(opportunityColorCode);
            datasetObject.hoverBackgroundColor.push(opportunityColorCode);
            datasetObject.hoverBorderColor.push(opportunityColorCode);
        }
        data.datasets.push(datasetObject);
        deliveredChartConfig.data = data;
        return deliveredChartConfig;
    }
}