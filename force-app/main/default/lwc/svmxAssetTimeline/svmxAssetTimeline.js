/* eslint-disable no-undef */
import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/RecordSelection__c';
import LOCALE from '@salesforce/i18n/locale';
import TIMEZONE from '@salesforce/i18n/timeZone';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import d3JS from '@salesforce/resourceUrl/d3minified';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getTimelineCategories
    from '@salesforce/apex/AMGT_TimeLine_LS.getTimelineCategories';
import {
    addDays,
    addMonths,
    calculateDateDiffInDays,
    classListMutation,
    debounce,
    formatDateTimeToApexDateString,
    formatString,
    getContrastingColor,
    isEmptyString,
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    parseErrorMessage,
    sortObjectArray,
    verifyApiResponse,
    raf
} from 'c/utils';
import getTimelineData
    from '@salesforce/apex/AMGT_TimeLine_LS.getTimelineData';

import { FiltersViewModel } from './filtersViewModel';

import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelClose from '@salesforce/label/c.Button_Close';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelShowing from '@salesforce/label/c.Label_Showing';
import labelFilter from '@salesforce/label/c.Label_Filter';
import labelFilters from '@salesforce/label/c.Label_Filters';
import labelRefresh from '@salesforce/label/c.Button_Refresh';
import labelTimelineSummary from '@salesforce/label/c.Label_Timeline_Summary';
import labelStartDate from '@salesforce/label/c.Label_StartDate';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelEndDateGreater from '@salesforce/label/c.Label_EndDateErrorMessage';
import labelDateRange from '@salesforce/label/c.Label_DateRange';
import labelTypesToShow from '@salesforce/label/c.Label_TypesToShow';
import labelNoName from '@salesforce/label/c.Label_NoName';
import labelTypesToShowMissing from '@salesforce/label/c.Message_TypesToShowMissing';
import labelStartDateMissing from '@salesforce/label/c.Message_StartDateMissingWhenEndDateEntered';
import labelEndDateMissing from '@salesforce/label/c.Message_EndDateMissingWhenStartDateEntered';
import labelErrorHeading from '@salesforce/label/c.Message_AssetTimeline_Error_Heading';
import labelErrorBody from '@salesforce/label/c.Message_AssetTimeline_Error_Body';
import labelNoDataHeading from '@salesforce/label/c.Message_NoData_Heading';
import labelNoDataBody from '@salesforce/label/c.Message_AssetTimeline_NoData_Body';
import labelRecordNotExists from '@salesforce/label/c.Error_RecordNotExists';
import labelFieldNotExists from '@salesforce/label/c.Error_FieldInaccessibleOrNotExists';
import labelSelectAll from '@salesforce/label/c.Label_SelectAll';
import limitFilterTypes from '@salesforce/label/c.Message_FilterFieldsLimitDisplay';
import labelSectionBands from '@salesforce/label/c.Label_SectionLabel_Band';
import labelSectionEvents from '@salesforce/label/c.Label_SectionLabel_Event';
import labelSectionMilestones from '@salesforce/label/c.Label_SectionLabel_Milestone';
import labelAndMore from '@salesforce/label/c.Label_AndMore';

const i18n = {
    apply: labelApply,
    cancel: labelCancel,
    close: labelClose,
    filter: labelFilter,
    filters: labelFilters,
    loading: labelLoading,
    refresh: labelRefresh,
    showing: labelShowing,
    timelineSummary: labelTimelineSummary,
    dateRange: labelDateRange,
    startDate: labelStartDate,
    startDateMissing: labelStartDateMissing,
    endDate: labelEndDate,
    endDateMissing: labelEndDateMissing,
    endDateGreaterThanStart: labelEndDateGreater,
    typesToShow: labelTypesToShow,
    typesToShowMissing: labelTypesToShowMissing,
    noName: labelNoName,
    timeZone: TIMEZONE,
    errorHeading: labelErrorHeading,
    errorBody: labelErrorBody,
    invalidField: labelFieldNotExists,
    noDataHeading: labelNoDataHeading,
    noDataBody: labelNoDataBody,
    recordNotExists: labelRecordNotExists,
    selectAll: labelSelectAll,
    limitFilterTypes: limitFilterTypes,
    labelSectionBands: labelSectionBands,
    labelSectionEvents: labelSectionEvents,
    labelSectionMilestones: labelSectionMilestones,
    labelAndMore
};

const dateTimeFormat = new Intl.DateTimeFormat(LOCALE);
const leftAndRightArrowBandPath = 'M0,12 L12,0 h{0} l12,12 l-12,12 h-{0}z';
const leftArrowBandPath = 'M0,12 L12,0 h{0} q3,0 3,3 v18 q0,3 -3,3 h-{0}Z';
const rightArrowBandPath = 'M0 0 h {0} 3 l12 12 l-12 12 h-{0} q-3,0 -3,-3 v-18 q0,-3 3,-3z';
const normalBandPath = 'M0 0 h {0} 3 q3,0 3,3 v18 q0,3 -3,3 h-{0} q-3,0 -3,-3 v-18 q0,-3 3,-3z'

const OBJECT_FALLBACK_ICON = 'standard:timeslot';
const DEFAULT_DAYS_TO_SHOW = 14;
const MAX_OBJECT_FILTERS_ALLOWED = 15;
const MAX_SWIMLANES_PER_HEIGHT = {
    Small: 7,
    Medium: 9,
    Large: 14
}
const SECTION_CATEGORIES = {
    band: 'band',
    event: 'event',
    milestone: 'milestone',
}

const SECTION_STATE = {
    hidden: 'hidden',
    expanded: 'expanded',
    collapsed: 'collapsed'
}
export default class SvmxAssetTimeline extends NavigationMixin(LightningElement) {
    @api assetField;
    @api earliestRange;
    @api flexipageRegionWidth;
    @api label;
    @api latestRange;
    @api objectApiName;
    @api preferredHeight;
    @api recordId;
    @api daysToShow = DEFAULT_DAYS_TO_SHOW;

    @track error;
    @track apiInProgress = false;
    @track hasRecordFormLoadError = false;
    @track filtersModel = new FiltersViewModel([], null, null);
    @track tempFiltersModel;
    @track showIllustration = false;
    @track showFilterPanel = false;
    @track filterMap = {};
    @track filterList = [];
    @track validationError;

    showFilter = false;
    assetName;
    filterValuesChanged = false;
    isMouseOver = false;
    illustrationImageName;
    illustrationHeading;
    illustrationMessage;
    mapZoomEndDate;
    mapZoomStartDate;
    mouseOverObjectAPIName;
    mouseOverRecord;
    mouseOverRecordId;
    mouseOverRecordUrl;
    totalMapZoomRecords = 0;
    totalTimelineRecords;
    dummyVal;
    @track duplicatecheck = new Set();

    _assetId;
    _d3brush = null;
    _d3LocalisedShortDateFormat = null;
    _d3Rendered = false;
    _d3timelineCanvas = null;
    _d3timelineCanvasAxis = null;
    _d3timelineCanvasAxisLabel = null;
    _d3timelineCanvasMap = null;
    _d3timelineCanvasMapAxis = null;
    _d3timelineCanvasSVG;
    _d3timelineCanvasAxisSVG;
    _d3timelineMap;
    _d3timelineMapAxis;
    _d3timelineMapSVG;
    _d3timelineMapAxisSVG;
    _initialAssetDataLoad = false;
    _objectFilter = [];
    _timelineData;
    _timelineHeight = null;
    _timelineItems;
    _timelineWidth = 'LARGE';
    sections = new Set();
    timelineCategories = [];
    configDeveloperName;


    get bandLabel () {
        // eslint-disable-next-line max-len
        return this.timelineCategories[this.timelineCategories.findIndex(item => item.categoryType === 'Bands')]?.label;
    }

    get eventsLabel () {
        // eslint-disable-next-line max-len
        return this.timelineCategories[this.timelineCategories.findIndex(item => item.categoryType === 'Events')]?.label;
    }

    get milestonesLabel () {
        // eslint-disable-next-line max-len
        return this.timelineCategories[this.timelineCategories.findIndex(item => item.categoryType === 'Milestones')]?.label;
    }

    @wire(MessageContext)
    messageContext;

    get assetId () {
        return this._assetId;
    }

    set assetId (newValue) {
        if (this._assetId !== newValue) {
            this._assetId = newValue;

            if (isNotUndefinedOrNull(this._assetId)) {
                this._initialAssetDataLoad = true;
            }
        }
    }

    get canvasEl () {
        return this.template.querySelector('.svmx-asset-timeline_canvas');
    }

    get canvasAxisEl () {
        return this.template.querySelector('.svmx-asset-timeline_canvas-axis');
    }

    get computedTimelineSummaryDetailClass () {
        return `svmx-asset-timeline_summary-verbose ${this.flexipageRegionWidth}`;
    }

    get mapEl () {
        return this.template.querySelector('.svmx-asset-timeline_map');
    }

    get mapAxisEl () {
        return this.template.querySelector('.svmx-asset-timeline_map-axis');
    }

    get filterPanelEl () {
        return this.template.querySelector('.svmx-asset-timeline_filter-panel');
    }

    get filterStartDateEl () {
        return this.template.querySelector('.svmx-asset-timeline_filter-startdate');
    }

    get filterEndDateEl () {
        return this.template.querySelector('.svmx-asset-timeline_filter-enddate');
    }

    get tooltipEl () {
        return this.template.querySelector('c-svmx-record-popover');
    }

    get tooltipListEl () {
        return this.template.querySelector('c-svmx-list-record-popover');
    }

    get timelineDataCount () {
        return (this._timelineData && Array.isArray(this._timelineData))
            ? this._timelineData.length : 0;
    }

    get hasTimelineData () {
        return (this.timelineDataCount > 0);
    }

    get i18n () {
        return i18n;
    }

    get isFilterDisplayed () {
        return (this.filterPanelEl && this.filterPanelEl.classList.contains('slds-is-open'));
    }

    get showSummary () {
        const timelineDataExists = this.hasTimelineData;
        const noError = isUndefinedOrNull(this.error);
        return timelineDataExists && noError;
    }

    get timelineSummary () {
        return formatString(i18n.timelineSummary, this.daysToShow, this.totalMapZoomRecords);
    }

    get filterOptions () {
        return (this._objectFilter && Array.isArray(this._objectFilter)) ? this._objectFilter : [];
    }

    get filterValues () {
        return (this.tempFiltersModel && this.tempFiltersModel.typesToShow)
            ? this.tempFiltersModel.typesToShow : [];
    }

    get formattedMapZoomStart () {
        return (this.mapZoomStartDate) ? dateTimeFormat.format(this.mapZoomStartDate) : null;
    }

    get formattedMapZoomEnd () {
        return (this.mapZoomEndDate) ? dateTimeFormat.format(this.mapZoomEndDate) : null;
    }

    get formattedTimelineStart () {
        return (this.tempFiltersModel && this.tempFiltersModel.startDate)
            ? formatDateTimeToApexDateString(this.tempFiltersModel.startDate, false)
            : null;
    }

    get formattedTimelineEnd () {
        return (this.tempFiltersModel && this.tempFiltersModel.endDate)
            ? formatDateTimeToApexDateString(this.tempFiltersModel.endDate, false)
            : null;
    }

    get requestDateRange () {
        this.filtersModel.startDate.setHours(0,0,1);
        this.filtersModel.endDate.setHours(23,59,59);
        return [ this.filtersModel.startDate, this.filtersModel.endDate ];
    }

    get objectFieldForWire () {
        return `${this.objectApiName}.${this.assetField}`;
    }

    clearState () {
        this.assetId = undefined;
        this.assetName = undefined;
        this._timelineData = [];
        this.tempFiltersModel = new FiltersViewModel(null, null, null);
        this.showFilterPanel = false;
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$objectFieldForWire' })
    wiredObjectRecord ({ error, data }) {
        if (data) {
            const assetFieldValue = getFieldValue(data, this.objectFieldForWire);

            if (isNotUndefinedOrNull(assetFieldValue)) {
                this.assetId = assetFieldValue;
            } else {
                this.apiInProgress = true;

                const displayNoData = debounce(() => {
                    try {
                        this.clearState();
                        this.updateIllustrationForDataResponse();
                    }
                    finally {
                        this.apiInProgress = false;
                    }
                }, 300)

                displayNoData();
                return;
            }

            this.loadTimelineData();
        } else if (error) {
            this.handleError(error);
        }
    }

    connectedCallback () {
        this._timelineHeight = this.getPreferredHeight();
        this._d3LocalisedShortDateFormat = this.getUserDateFormat();
        this.subscribeToMessageChannel();
    }

    disconnectedCallback () {
        this.unsubscribeToMessageChannel();
        window.removeEventListener('resize', this.resizeHandler);
        window.removeEventListener('scroll', this.scrollHandler);
    }

    renderedCallback () {
        if (!this._d3Rendered) {
            if (this.flexipageRegionWidth !== undefined) {
                this._timelineWidth = this.flexipageRegionWidth;
            }

            //set the height of the component as the height is dynamic based on the properties
            this.canvasEl.setAttribute('style', 'height:' + this._timelineHeight + 'px');

            loadScript(this, d3JS)
                .then(() => {
                    this._d3timelineCanvasSVG = d3
                        .select(this.canvasEl)
                        .append('svg');

                    this._d3timelineCanvasAxisSVG = d3
                        .select(this.canvasAxisEl)
                        .append('svg');

                    this._d3timelineMapSVG = d3
                        .select(this.mapEl)
                        .append('svg');

                    this._d3timelineMapAxisSVG = d3
                        .select(this.mapAxisEl)
                        .append('svg');

                    this.processTimeline();
                })
                .catch((error) => {
                    this.handleError(error);
                });

            this._d3Rendered = true;
        }
    }

    handleError (error) {
        this.showFilterPanel = false;
        this.error = parseErrorMessage(error);

        if (error
            && error.message
            && error.message.trim().toUpperCase() === i18n.recordNotExists.toUpperCase()) {
            this.updateIllustrationForDataResponse();
        } else if (error?.body?.errorCode === 'INVALID_FIELD') {
            this.updateIllustration(
                true,
                'error:page_not_available',
                i18n.errorHeading,
                formatString(i18n.invalidField, this.objectApiName, this.assetField)
            );
        } else {
            this.updateIllustration(
                true,
                'error:page_not_available',
                i18n.errorHeading,
                i18n.errorBody
            );
        }
    }

    subscribeToMessageChannel () {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel () {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage (message) {
        if (message.source === 'c/assetHierarchy' &&
            message.recordId !== this.assetId &&
            message.sourceId === this.recordId) {
            this.assetId = message.recordId;
            const timelineRequest = {
                parentRecordId: message.recordId,
                fieldApiName: 'id',
                startDate: null,
                endDate: null
            }

            if (isUndefinedOrNull(this.filtersModel.startDate)
                || isUndefinedOrNull(this.filtersModel.endDate)) {
                this.initializeTimelineDates();
            }

            timelineRequest.startDate = formatDateTimeToApexDateString(
                this.filtersModel.startDate,
                false);
            timelineRequest.endDate = formatDateTimeToApexDateString(
                this.filtersModel.endDate,
                false);

            this.loadTimelineData(timelineRequest);
        }
    }

    updateIllustrationForDataResponse () {
        if (this.hasTimelineData) {
            this.updateIllustration(false);
        } else {
            this.showNoDataIllustration();
        }
    }

    showNoDataIllustration () {
        this.updateIllustration(
            true,
            'no_data:open_road',
            i18n.noDataHeading,
            i18n.noDataBody
        );
    }

    loadTimelineData (request = this.getTimelineRequest()) {
        if (this.canvasDimensions.width === 0) {
            return;
        }

        this.apiInProgress = true;
        this.clearCanvasAndMap();

        getTimelineData({ requestJson: JSON.stringify( request ) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.error = null;
                this._timelineData = result.data.timelineResults;
                this.configDeveloperName = result.data.configDevloperName;
                this.assetName = result.data.displayName;
                this.showFilterPanel = true;
                getTimelineCategories({ developerName: this.configDeveloperName }).
                then(categories => {
                    if (categories) {
                        this.timelineCategoriesResp =categories;
                        this.timelineCategories = [...categories];
                    }
                    this.updateIllustrationForDataResponse();
                    this.processTypesToShow(result.data.typesToShow);
                    this.processTimeline();
                })
            })
            .catch(error => {
                this._timelineData = [];
                this.handleError(error);
            })
            .finally(() => {
                this._initialAssetDataLoad = false;
                this.apiInProgress = false;
            });
    }

    initializeTimelineDates () {
        const { startDate, endDate } = this.getDateRangeFromProperties();

        this.filtersModel.startDate = startDate;
        this.filtersModel.endDate = endDate;
        this.filtersModel.isDirty = false;
    }

    getDateRangeFromProperties () {
        const startMonths = parseInt(this.earliestRange, 10);
        const endMonths = parseInt(this.latestRange, 10);

        const currentDate = this.getTodayBasedOnTimezone();

        const startingDate = addMonths(currentDate, -startMonths);
        const endingDate = addMonths(currentDate, endMonths);

        return {
            startDate: startingDate,
            endDate: endingDate
        };
    }

    getTimelineRequest () {
        const timelineRequest = {
            parentRecordId: this.recordId,
            fieldApiName: this.assetField,
            startDate: null,
            endDate: null
        }

        if (isUndefinedOrNull(this.filtersModel.startDate)
            || isUndefinedOrNull(this.filtersModel.endDate)) {
            this.initializeTimelineDates();
        }

        timelineRequest.startDate = formatDateTimeToApexDateString(
            this.filtersModel.startDate,
            false);
        timelineRequest.endDate = formatDateTimeToApexDateString(
            this.filtersModel.endDate,
            false);

        return timelineRequest;
    }

    clearCanvasAndMap () {
        if (this._d3timelineCanvasSVG) {
            this._d3timelineCanvasSVG.selectAll('*').remove();
        }
        if (this._d3timelineCanvasAxisSVG) {
            this._d3timelineCanvasAxisSVG.selectAll('*').remove();
        }
        if (this._d3timelineMapSVG) {
            this._d3timelineMapSVG.selectAll('*').remove();
        }

        if (this._d3timelineMapAxisSVG) {
            this._d3timelineMapAxisSVG.selectAll('*').remove();
        }
    }

    get maxBandsToBeDisplay () {
        let height;

        switch (this.preferredHeight) {
            case 'Large':
                height = 3;
                break;
            default:
                height = 2;
                break;
        }

        return height;
    }

    getMilestoneSwimlane () {
        let height;

        switch (this.preferredHeight) {
            case 'Small':
                height = 5;
                break;
            case 'Large':
                height = 12;
                break;
            default:
                height = 7;
                break;
        }

        return height;
    }

    getPreferredHeight () {
        let height;

        switch (this.preferredHeight) {
            case 'Small':
                height = 200;
                break;
            case 'Large':
                height = 425;
                break;
            default:
                height = 275;
                break;
        }

        return height;
    }

    getUserDateFormat () {
        const userShortDate = shortDateFormat;

        let d3DateFormat = userShortDate.replace(/dd/gi, 'd');
        d3DateFormat = d3DateFormat.replace(/d/gi, 'd');
        d3DateFormat = d3DateFormat.replace(/M/gi, 'm');
        d3DateFormat = d3DateFormat.replace(/MM/gi, 'm');
        d3DateFormat = d3DateFormat.replace(/YYYY/gi, 'y');
        d3DateFormat = d3DateFormat.replace(/YY/gi, 'y');

        d3DateFormat = d3DateFormat.replace(/d/gi, '%d');
        d3DateFormat = d3DateFormat.replace(/m/gi, '%m');
        d3DateFormat = d3DateFormat.replace(/y/gi, '%Y');

        return d3DateFormat;
    }

    processTimeline () {
        if (this._d3Rendered === true && this._timelineData) {
            this.clearCanvasAndMap();

            if (!this.hasTimelineData) {
                return;
            }

            this._timelineItems = this.processTimelineItems();
            this._d3timelineCanvas = this.processTimelineCanvas();

            const axisDividerConfig = {
                tickFormat: this._d3LocalisedShortDateFormat,
                innerTickSize: -this._d3timelineCanvas.SVGHeight,
                translate: [0, this._d3timelineCanvas.SVGHeight],
                tickPadding: 0,
                ticks: 6,
                class: 'axis-ticks'
            };

            this._d3timelineCanvasAxis = this.processAxis(
                axisDividerConfig,
                this._d3timelineCanvasSVG,
                this._d3timelineCanvas
            );

            const axisLabelConfig = {
                tickFormat: this._d3LocalisedShortDateFormat,
                innerTickSize: 0,
                tickPadding: 2,
                translate: [0, 5],
                ticks: 6,
                class: 'axis-label'
            };

            this._d3timelineCanvasAxisLabel = this.processAxis(
                axisLabelConfig,
                this._d3timelineCanvasAxisSVG,
                this._d3timelineCanvas
            );

            this._d3timelineMap = this.processTimelineMap();
            this._d3timelineMap.redraw();

            const mapAxisConfig = {
                tickFormat: this._d3LocalisedShortDateFormat,
                innerTickSize: 4,
                tickPadding: 4,
                ticks: 6,
                class: 'axis-label'
            };

            this._d3timelineMapAxis = this.processAxis(
                mapAxisConfig,
                this._d3timelineMapAxisSVG,
                this._d3timelineMap
            );

            this._d3brush = this.processBrush();

            const that = this;

            that.resizeHandler = debounce(() => {
                const canvasDimensions = that.canvasDimensions;
                if (canvasDimensions.width !== 0) {
                    that._d3timelineCanvas.x.range([
                        0,
                        canvasDimensions.width
                    ]);
                    that._d3timelineMap.x.range([
                        0,
                        Math.max(canvasDimensions.width, 0)
                    ]);
                    if (that.tooltipEl) {
                        that.tooltipEl.hidePopover();
                    }
                    if (that.tooltipListEl) {
                        that.tooltipListEl.hideListPopover();
                    }
                    that._d3timelineCanvasAxis.redraw();
                    that._d3timelineCanvasAxisLabel.redraw();
                    that._d3timelineMap.redraw();
                    that._d3timelineMapAxis.redraw();
                    that._d3brush.redraw();
                }
            }, 200);

            that.scrollHandler = debounce(() => {
                const canvasDimensions = that.canvasDimensions;
                if (canvasDimensions.width !== 0) {
                    if (that.tooltipEl) {
                        this.tooltipEl.hidePopover();
                    }
                    if (that.tooltipListEl) {
                        this.tooltipListEl.hideListPopover();
                    }
                }
            }, 200);

            window.addEventListener('resize', that.resizeHandler);
            window.addEventListener('scroll', that.scrollHandler);
        }
    }

    processTypesToShow (typesToShow) {
        this._objectFilter = [];
        const _filterValues = [];
        this.filterMap = {};
        this.filterList = [];
        const objvalMap = {};
        if (typesToShow) {
            this.filterMap[this.bandLabel] = [];
            this.filterMap[this.milestonesLabel] = [];
            this.filterMap[this.eventsLabel] = [];
            // eslint-disable-next-line @lwc/lwc/no-for-of
            for (const [key, value] of Object.entries(typesToShow)) {
                const valuekey = key.split('^#SEP#^')[0];
                if (valuekey.toLowerCase() === 'asset') {
                    this.filterMap[this.milestonesLabel].push ({
                        label: value.label,
                        expressionName: value.expressionName,
                        iconName: value.iconName ?? OBJECT_FALLBACK_ICON,
                        value: key,
                        isArray: true,
                        sequence: value.sequence,
                        category: SECTION_CATEGORIES.milestone,
                        checked: value.showMatchingRecordsOnLoad,
                        actualLabel: value.label
                    });
                } else if (value.isTimespanEvent) {
                    this.filterMap[this.bandLabel].push ({
                        label: value.label,
                        expressionName: value.expressionName,
                        iconName: value.iconName ?? OBJECT_FALLBACK_ICON,
                        value: key,
                        isArray: true,
                        sequence: value.sequence,
                        category: SECTION_CATEGORIES.band,
                        checked: value.showMatchingRecordsOnLoad,
                        actualLabel: value.label
                    });
                } else {
                    this.filterMap[this.eventsLabel].push ({
                        label: value.label,
                        expressionName: value.expressionName,
                        iconName: value.iconName ?? OBJECT_FALLBACK_ICON,
                        value: key,
                        isArray: true,
                        sequence: value.sequence,
                        category: SECTION_CATEGORIES.event,
                        checked: value.showMatchingRecordsOnLoad,
                        actualLabel: value.label
                    });
                }
                objvalMap[valuekey] = value.label;
                if (value.showMatchingRecordsOnLoad === true) {
                    _filterValues.push(key);
                }
            }
            if (this.filterMap[this.bandLabel]
                && this.filterMap[this.bandLabel].length >0) {
                this.filterList.push (this.populateFilterObj(this.bandLabel));
            }
            if (this.filterMap[this.eventsLabel]
                && this.filterMap[this.eventsLabel].length >0) {
                this.filterList.push (this.populateFilterObj(this.eventsLabel));
            }
            if (this.filterMap[this.milestonesLabel]
                && this.filterMap[this.milestonesLabel].length >0) {
                this.filterList.push (this.populateFilterObj(this.milestonesLabel));
            }
        }

        if (this._initialAssetDataLoad ||
            (this.filtersModel.typesToShow && this.filtersModel.typesToShow.length === 0)) {
            this.filtersModel.typesToShow = _filterValues.sort();
            this.filtersModel.isDirty = false;
        }

        this._objectFilter = sortObjectArray(this._objectFilter, 'label', 'asc');
    }

    populateFilterObj (key) {
        const filterObjs = this.filterMap[key].sort((item1, item2)=>{
            if (item1.sequence < item2.sequence) {
                return -1;
            } else if (item1.sequence > item2.sequence) {
                return 1;
            }
            return 0;
        });
        return {
            key: key,
            value: filterObjs,
            label: key
        }
    }

    processTimelineItems () {
        const timelineItems = [];

        if (this.hasTimelineData) {
            this._timelineData.forEach( (item, index) => {
                const itemCopy = {};

                itemCopy.id = index;
                itemCopy.recordId = item.id;
                itemCopy.fullDisplayName
                    = isEmptyString(item.displayName) ? i18n.noName : item.displayName;
                itemCopy.displayName
                    = isEmptyString(item.displayName)
                        ? i18n.noName
                        : this.trimText(item.displayName, 30);

                let startDate = item.startDate;
                if (!item.startDate.includes('T')) {
                    startDate += 'T00:01';
                }
                itemCopy.startDate = new Date(startDate);
                itemCopy.startDate.setMilliseconds(0);

                itemCopy.startDateOnly = new Date(
                    itemCopy.startDate.getFullYear(),
                    itemCopy.startDate.getMonth(),
                    itemCopy.startDate.getDate()
                );

                itemCopy.isBand = isNotUndefinedOrNull(item.endDate);
                const uniqueEntities = item.uniqueName.split('^#SEP#^')
                itemCopy.type = uniqueEntities[uniqueEntities.length-1];
                itemCopy.uniqueName = item.uniqueName;
                itemCopy.showRecord = true;
                itemCopy.endDate = null
                if (itemCopy.isBand) {
                    let endDate = item.endDate;
                    if (!item.endDate.includes('T')) {
                        endDate += 'T00:01';
                    }
                    itemCopy.endDate = new Date(endDate);
                    itemCopy.endDate.setMilliseconds(0);
                }

                itemCopy.objectAPIName = item.objectAPIName;
                itemCopy.objectLabel = item.objectLabel;
                itemCopy.expressionName = item.expressionName;
                itemCopy.backgroundColor = item.backgroundColor;
                itemCopy.sequence = item.sequence;
                itemCopy.iconName
                    = isNotUndefinedOrNull(item.iconName)
                        ? item.iconName.replace(/\s+/g, '')
                        : OBJECT_FALLBACK_ICON;
                itemCopy.record = item.record;

                timelineItems.push(itemCopy);

            });

        }

        return timelineItems;
    }

    get canvasDimensions () {
        const dimensions = {
            width: this.canvasEl.offsetWidth,
            height: this.canvasEl.offsetHeight
        }
        return dimensions;
    }

    get mapDimensions () {
        const dimensions = {
            width: this.mapEl.offsetWidth,
            height: this.mapEl.offsetHeight
        }
        return dimensions;
    }

    countTimelineCanvasItems (records, canvasDomain) {
        let mapZoomRecords = 0;

        if (isUndefinedOrNull(records) || (Array.isArray(records) && records.length === 0)) {
            return mapZoomRecords;
        }

        records.forEach(item => {
            const endTime = (item.isBand) ? item.endDate : item.startDate;

            const canvasStartDate = new Date(JSON.parse(JSON.stringify(canvasDomain[0])));
            const canvasEndDate = new Date(JSON.parse(JSON.stringify(canvasDomain[1])));
            canvasStartDate.setHours(0,0,0,0);
            canvasEndDate.setHours(23,59,0,0);
            const startDate = new Date(item.startDate.getTime());
            const endDate = new Date(endTime.getTime());
            if (!JSON.stringify(item.startDate).includes('T')) {
                startDate.setHours(0,0,0,0);
            }
            if (!JSON.stringify(item.startDate).includes('T')) {
                endDate.setHours(0,0,0,0);
            }
            if (canvasStartDate <= endDate && startDate <= canvasEndDate) {
                mapZoomRecords++;
            }
        });

        return mapZoomRecords;
    }

    processTimelineCanvas () {
        const that = this;

        const timelineCanvasDIV = that.canvasEl;
        const timelineCanvas = that._d3timelineCanvasSVG;
        const timelineHeight = that._timelineHeight;
        const timelineData = that._timelineItems;
        const width = that.canvasDimensions.width;

        timelineCanvasDIV.setAttribute('style', 'max-height:' + timelineHeight + 'px');
        timelineCanvas.SVGHeight = timelineHeight;

        timelineCanvas.x = d3.scaleTime().domain(that.requestDateRange).rangeRound([0, width]);

        timelineCanvas.y = function (swimlane) {
            return swimlane * 25 * 1 + (swimlane + 1) * 5;
        };

        timelineCanvas.width = width;
        timelineCanvas.height = timelineHeight;

        timelineCanvas.mouseOver = function (event, d) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            that.mouseOverTimeout = setTimeout(() => {
                that.mouseOverRecord = d;
                that.mouseOverRecordId = d.recordId;
                that.mouseOverObjectAPIName = d.objectAPIName;

                that[NavigationMixin.GenerateUrl](
                    that.getPageReferenceForRecord(d.recordId))
                    .then(url => {
                        that.mouseOverRecordUrl = url;
                    });
                that.hasRecordFormLoadError = false;
                that.isMouseOver = true;

                const tooltipDIV = that.tooltipEl;
                if (tooltipDIV) {
                    tooltipDIV.hidePopover();
                    if (that.tooltipListEl) {
                        that.tooltipListEl.hideListPopover();
                    }
                    tooltipDIV.showPopover(
                        that.mouseOverRecordId,
                        that.mouseOverObjectAPIName,
                        this,
                        that.canvasEl,
                        that.mouseOverRecord.fullDisplayName,
                        that.mouseOverRecord,
                        null, event.screenX,event.screenY);
                }
            }, 10);
        };



        timelineCanvas.setBBox = function (selection) {
            selection.each(function (d) {
                d.bbox = this.getBBox();
            });
        };

        timelineCanvas.redraw = function (domain) {
            if (domain) {
                timelineCanvas.x.domain(domain);
            }

            const unitInterval = (timelineCanvas.x.domain()[1] - timelineCanvas.x.domain()[0])
                / timelineCanvas.width;
            const data = timelineData.sort((item1, item2)=>{
                if (item1.sequence < item2.sequence) {
                    return -1;
                } else if (item1.sequence > item2.sequence) {
                    return 1;
                }
                return 0;
            }).filter(function (d) {
                if (d.isBand) {
                    d.endTime = d.endDate;
                } else {
                    d.endTime = new Date(
                        d.startDate.getTime() + unitInterval * (d.displayName.length * 6 + 80)
                    );
                    d.endTime.setMilliseconds(0);
                }

                const canvasStartDate = new Date(
                    JSON.parse(JSON.stringify(timelineCanvas.x.domain()[0])));
                const canvasEndDate = new Date(
                    JSON.parse(JSON.stringify(timelineCanvas.x.domain()[1])));
                canvasStartDate.setHours(0,0,0,0);
                canvasEndDate.setHours(0,0,0,0);
                const startDate = new Date(d.startDate.getTime());
                const endDate = new Date(d.endTime.getTime());
                startDate.setHours(0,0,0,0);
                endDate.setHours(0,0,0,0);
                return canvasStartDate <= endDate
                    && startDate <= canvasEndDate
                    && that.filtersModel.typesToShow.includes(d.uniqueName);
            });
            that.totalMapZoomRecords
                = that.countTimelineCanvasItems(data, timelineCanvas.x.domain());

            if (data.length === 0 && !that.hasTimelineData) {
                that.showNoDataIllustration();
            }

            timelineCanvas.width = timelineCanvas.x.range()[1];
            timelineCanvas.attr('width', timelineCanvas.width);

            let i = 0;
            let swimlane = 0;

            const sortedData = that.sortTimelineResults(data);
            const bandRecords = sortedData.filter(d => d.type === 'Bands'
                && d.objectAPIName.toLowerCase() !== 'asset');
            const eventRecords = sortedData.filter(d => !(d.isBand)
                && d.type === 'Event'
                && d.objectAPIName.toLowerCase() !== 'asset');
            const mileStoneRecords = that.sortTimelineResults(data.filter( d =>
                    d.objectAPIName.toLowerCase() === 'asset'));

            const eventsGroupedByStartDate = d3.group(eventRecords, d => d.startDateOnly);

            // Bands have an End Date whereas Events End Date is calculated.
            // Calculating swimlanes has to be handled in a sep routine 
            // because we want to display bands at the top of the canvas y-axis, 
            // then event records below them.
            const bandLanes = [];
            const bandSwimLane = 0;
            bandRecords.forEach(function (entry) {
                for (i = 0, swimlane = 0; i < bandLanes.length; i++, swimlane++) {
                    if (entry.startDate > bandLanes[i]) {
                        break;
                    }
                }

                entry.swimlane = swimlane+1;
                bandLanes[swimlane] = entry.endTime??entry.startDate;
            });

            let bandLanesLength = bandLanes.length === 0 ? 0 : bandLanes.length+1;
            if (bandRecords.length > 0 && !bandRecords[0].showRecord) {
                bandLanesLength = 1;
            }
            let swimLanesSize = bandLanesLength;

            eventsGroupedByStartDate.forEach((value, ) => {
                if (value && Array.isArray(value)) {
                    value.sort((a, b) => d3.ascending(a.sequence, b.sequence));

                    value.forEach((item, index) => {
                        item.swimlane = index + bandLanesLength+1;

                        if (item.swimlane > swimLanesSize) {
                            swimLanesSize = item.swimlane;
                        }
                    });
                }
            });
            const milestonesLanesLength = that.getMilestoneSwimlane()+1;
            mileStoneRecords.forEach(function (entry) {
                entry.swimlane = milestonesLanesLength;
            });
            // eslint-disable-next-line max-len
            const svgHeight = Math.max(timelineCanvas.y(MAX_SWIMLANES_PER_HEIGHT[that.preferredHeight]), timelineHeight);
            timelineCanvas.height = timelineHeight;

            timelineCanvas.attr('height', svgHeight - 1);
            timelineCanvas.SVGHeight = svgHeight;
            const hasBands = bandRecords.length >0;
            const hasEvents = eventRecords.length >0;
            const hasMileStones = mileStoneRecords.length >0;
            const isEventsCollapsed = hasEvents && !eventRecords[0].showRecord;
            const isMileStonesCollapsed = hasMileStones && !mileStoneRecords[0].showRecord;
            const milestoneSectionState = hasMileStones
                ? (isMileStonesCollapsed ? SECTION_STATE.collapsed : SECTION_STATE.expanded)
                : SECTION_STATE.hidden;
            const eventSectionState = hasEvents
                ? (isEventsCollapsed ? SECTION_STATE.collapsed : SECTION_STATE.expanded)
                : SECTION_STATE.hidden;
            that.clearSectionLabel(timelineCanvas);
            if (hasBands) {
                that.addSectionLabel(
                    timelineCanvas,
                    that,
                    bandRecords,
                    that.bandLabel,
                    bandSwimLane,
                    SECTION_CATEGORIES.band);
                that.createBands (
                    timelineCanvas,
                    bandRecords,
                    that,
                    SECTION_CATEGORIES.band,
                    eventSectionState,
                    milestoneSectionState
                );
            } else {
                that.clearBands (timelineCanvas, SECTION_CATEGORIES.band);
            }
            if (hasEvents) {
                let sectionLabelSwimlane = bandLanesLength > that.maxBandsToBeDisplay
                    ? that.maxBandsToBeDisplay+1
                    : bandLanesLength;
                if (eventRecords.length >0 && !eventRecords[0].showRecord) {
                    sectionLabelSwimlane = that.getMilestoneSwimlane();
                    sectionLabelSwimlane += hasMileStones
                        ? (isMileStonesCollapsed ? 0 : -1) //placing above milestone label;
                        : 1; //completely moving to end of view area
                }
                that.addSectionLabel(
                    timelineCanvas,
                    that,
                    eventRecords,
                    that.eventsLabel,
                    sectionLabelSwimlane,
                    SECTION_CATEGORIES.event);
                that.createEvents (
                    timelineCanvas,
                    eventRecords,
                    that,
                    SECTION_CATEGORIES.event,
                    milestoneSectionState,
                    bandLanesLength
                );
            } else {
                that.clearEvents (timelineCanvas, SECTION_CATEGORIES.event);
            }
            if (hasMileStones) {
                that.addSectionLabel(
                    timelineCanvas,
                    that,
                    mileStoneRecords,
                    that.milestonesLabel,
                    (mileStoneRecords[0].showRecord
                     ? that.getMilestoneSwimlane()//has Milestone
                     : that.getMilestoneSwimlane()+1),//has Milestone label only
                    SECTION_CATEGORIES.milestone);
                that.createBands (
                    timelineCanvas,
                    mileStoneRecords.filter(entry=> entry.isBand),
                    that,
                    SECTION_CATEGORIES.milestone,
                    hasEvents,
                    hasMileStones
                );
                that.createEvents (
                    timelineCanvas,
                    mileStoneRecords.filter(entry=> !entry.isBand),
                    that,
                    SECTION_CATEGORIES.milestone,
                    hasMileStones,
                    bandLanesLength
                );
            } else {
                that.clearBands (timelineCanvas, SECTION_CATEGORIES.milestone);
                that.clearEvents (timelineCanvas, SECTION_CATEGORIES.milestone);
            }
            timelineCanvas
                .selectAll('.timeline-canvas-today')
                .data([that.getTodayBasedOnTimezone()])
                .join(
                    enter => enter.append('g')
                        .attr('class', 'timeline-canvas-today')
                        .attr('transform', function (d) {
                            return `translate(${timelineCanvas.x(d)}, 0)`;
                        })
                        .append('line')
                        .attr('stroke', '#EA8288')
                        .attr('y2', timelineCanvas.SVGHeight),
                    update =>
                        update
                            .attr('transform', function (d) {
                                return `translate(${timelineCanvas.x(d)}, 0)`;
                            })
                            .raise(),
                    exit => exit.remove()
                );
        }
        return timelineCanvas;
    }

    createEventsInMiniMap (
        timelineMap,
        eventRecords
    ) {
        timelineMap
            .selectAll('.timeline-map-record')
            .data(eventRecords, d => d.id)
            .join(
                enter =>
                    enter.append('g')
                        .attr('class', 'timeline-map-record')
                        .attr('transform', function (d) {
                            // eslint-disable-next-line max-len
                            return `translate(${timelineMap.x(d.startDate)}, ${timelineMap.y(d.swimlane)})`;
                        })
                        .append('rect')
                        .attr('style', function () {
                            return 'fill: #98C3EE; stroke: #4B97E6';
                        })
                        .attr('width', 3)
                        .attr('height', 2)
                        .attr('rx', 0.2)
                        .attr('ry', 0.2),
                update =>
                    update
                        .attr('transform', function (d) {
                            // eslint-disable-next-line max-len
                            return `translate(${timelineMap.x(d.startDate)}, ${timelineMap.y(d.swimlane)})`;
                        })
            );
    }

    clearEvents (timelineCanvas, type) {
        timelineCanvas.data = timelineCanvas
        .selectAll(`.timeline-canvas-record-${type}`).remove();
        timelineCanvas.moreData = timelineCanvas
            .selectAll(`.timeline-canvas-more-record-${type}`).remove();
    }

    createEvents (
        timelineCanvas,
        eventRecords,
        that,
        type,
        milestoneSectionState,
        bandlanesLength
    ) {
        that.clearEvents (timelineCanvas, type);
        if (eventRecords.length > 0 && !eventRecords[0].showRecord) {
            return;
        }
        let filteredEventRecords = eventRecords;
        let moreEventRecords = [];
        const milestoneSwimlane  = that.getMilestoneSwimlane();
        if (type !== SECTION_CATEGORIES.milestone) {
            if (bandlanesLength > that.maxBandsToBeDisplay) {
                // adjust the band lanes 
                const updatedBandLanes = bandlanesLength - (that.maxBandsToBeDisplay+1);
                eventRecords.forEach (item => {
                    item.swimlane = item.swimlane - updatedBandLanes;
                });
            }
            if (milestoneSectionState !== SECTION_STATE.hidden) {
                const maxEvents = milestoneSectionState === SECTION_STATE.collapsed
                    ? milestoneSwimlane
                    : milestoneSwimlane-1;
                filteredEventRecords = eventRecords.filter (
                    item => item.swimlane < maxEvents);
                moreEventRecords = eventRecords.filter (
                    item => item.swimlane >= maxEvents);
            } else {
                filteredEventRecords = eventRecords.filter (
                    item => item.swimlane <= milestoneSwimlane);
                moreEventRecords = eventRecords.filter (
                    item => item.swimlane > milestoneSwimlane);
            }
        }
        if (moreEventRecords.length === 1) {
            filteredEventRecords = [...filteredEventRecords,...moreEventRecords];
            moreEventRecords = [];
        }
        const moreEventsGroupedByStartDate = d3.group(moreEventRecords, d => d.startDateOnly);
        const recordListByDate  = [];
        moreEventsGroupedByStartDate.forEach((value,  ) => {
            if (value && Array.isArray(value)) {
                value.sort((a, b) => d3.ascending(a.sequence, b.sequence));
                if (value.length === 1) {
                    filteredEventRecords = [...filteredEventRecords,...value];
                } else if (value.length > 0) {
                    recordListByDate.push(value);
                }
            }
        });

        timelineCanvas.data = timelineCanvas
        .selectAll(`.timeline-canvas-record-${type}`)
        .data(filteredEventRecords, function (d) {
            return d.id;
        })
        .attr('transform', function (d) {
            // eslint-disable-next-line max-len
            return `translate(${timelineCanvas.x(d.startDate)}, ${timelineCanvas.y(d.swimlane)})`;
        });


        timelineCanvas.records = timelineCanvas.data
            .enter()
            .append('g')
            .attr('class', `timeline-canvas-record-${type}`)
            .attr('data-id', function (d) {
                return d.recordId;
            })
            .attr('transform', function (d) {
                // eslint-disable-next-line max-len
                return `translate(${timelineCanvas.x(d.startDate)}, ${timelineCanvas.y(d.swimlane)})`;
            })
            .on('click', timelineCanvas.mouseOver)
            //.on('mouseleave', timelineCanvas.mouseOut);

        if (timelineCanvas.records.size() > 0) {
            const rec = timelineCanvas.records
                .append('svg')
                .attr('height', 22)
                .attr('width', 22)
                .attr('class', function (d) {
                    const classes = ['slds-icon'];
                    const objectIconName = d.iconName;
                    const iconParts = objectIconName.split(':');
                    const styleGroup = iconParts[0];
                    const style = iconParts[1].replaceAll('_', '-')

                    if (styleGroup === 'utility') {
                        classes.push('slds-icon-text-default');
                    } else {
                        classes.push(`slds-icon-${styleGroup}-${style}`);
                    }

                    classes.push(`timeline-canvas-icon-${styleGroup}`);

                    return classes.join(' ');
                });

            rec
                .append('rect')
                .attr('height', '100%')
                .attr('width', '100%')
                .attr('rx', 3)
                .attr('ry', 3)
                .attr('fill', function () {
                    const parent = this.parentNode;

                    if (parent.classList.contains('slds-icon-text-default')) {
                        return 'transparent';
                    }

                    const parentStyle = getComputedStyle(this.parentNode);
                    const parentColor = parentStyle.getPropertyValue('background-Color');
                    return parentColor;
                });

            rec
                .append('use')
                .attr('height', 22)
                .attr('width', 22)
                .attr('href', function (d) {
                    const objectIconName = d.iconName;
                    const iconParts = objectIconName.split(':');
                    // eslint-disable-next-line max-len
                    const iconImage = `/_slds/icons/${iconParts[0]}-sprite/svg/symbols.svg#${iconParts[1]}`;
                    return iconImage;
                });

            timelineCanvas.records
                .selectAll(`.timeline-canvas-icon-action-${type} rect`)
                .attr('rx', 50)
                .attr('ry', 50);

            timelineCanvas.records
                .selectAll(`.timeline-canvas-icon-action-${type} use`)
                .attr('height', 16)
                .attr('width', 16)
                .attr('x', 2)
                .attr('y', 2);

            timelineCanvas.records
                .append('line')
                .attr('class', `timeline-canvas-record-line-${type}`)
                .attr('x1', 24)
                .attr('y1', 12)
                .attr('x2', 24 + 8)
                .attr('y2', 12);
            timelineCanvas.records
                .append('text')
                .attr('class', `timeline-canvas-record-label-${type}`)
                .attr('x', 24 + 10)
                .attr('y', 16)
                .attr('font-size', 12)
                .on('click', timelineCanvas.mouseOver)
                .text(function (d) {
                    return d.displayName;
                });

            timelineCanvas.records.call(timelineCanvas.setBBox);
            timelineCanvas.records
                .insert('svg:rect', 'svg.slds-icon')
                .attr('width', d => d.bbox.width)
                .attr('height', d => d.bbox.height)
                .attr('style', 'fill: #FFFFFF');
        }


        if (recordListByDate.length > 0) {
            const tooltipDIV = that.tooltipListEl;
            const tooltipRecDiv = that.tooltipEl;
            recordListByDate.forEach(recordList => {
                if (recordList && recordList.length > 0) {
                    const grpDate = recordList[0].startDate;
                    const displayRecords = [{
                        title: dateTimeFormat.format(grpDate),
                        key: new Date().getTime()+1,
                        records: recordList
                    }];
                    timelineCanvas.moreData = timelineCanvas
                        .selectAll(`.timeline-canvas-more-record-${type}`)
                        .data([recordList[0]], function (d) {
                            return d.id;
                        })
                        .attr('transform', function (d) {
                            // eslint-disable-next-line max-len
                            return `translate(${timelineCanvas.x(d.startDate)}, ${timelineCanvas.y(d.swimlane)})`;
                        });
                    timelineCanvas.moreRecords = timelineCanvas.moreData
                        .enter()
                        .append('g')
                        .attr('class', `timeline-canvas-more-record-${type}`)
                        .attr('data-id', function (d) {
                            return d.recordId;
                        })
                        .attr('transform', function (d) {
                            // eslint-disable-next-line max-len
                            return `translate(${timelineCanvas.x(d.startDate)}, ${timelineCanvas.y(d.swimlane)})`;
                        });
                    timelineCanvas.moreRecords
                        .append('rect')
                        .attr('height', '20px')
                        .attr('width', '50px')
                        .attr('rx', 0)
                        .attr('ry', 3)
                        .attr('fill', function () {
                           return "#FFFFFF";
                        });
                    timelineCanvas.moreRecords
                        .append('text')
                        .attr('class', `timeline-canvas-more-record-label-${type}`)
                        .attr('x', 0)
                        .attr('y', 16)
                        .attr('font-size', 13)
                        .attr('fill', 'blue')
                        .attr('cursor','pointer')
                        .on('click', function () {
                            if (tooltipDIV) {
                                if (tooltipRecDiv) {
                                    tooltipRecDiv.hidePopover();
                                }
                                tooltipDIV.hideListPopover();
                                tooltipDIV.showListPopover(
                                    displayRecords,
                                    this,
                                    that.canvasEl);
                            }
                        })
                        .text(function () {
                            return formatString(i18n.labelAndMore,recordList.length);
                        });
                }
            });
        }
    }

    createBandsInMiniMap (
        timelineMap,
        bandRecords
    ) {
        timelineMap
            .selectAll('.timeline-map-band')
            .data(bandRecords, d => d.id)
            .join(
                enter => enter.append('g')
                    .attr('class', 'timeline-map-band')
                    .attr('transform', function (d) {
                        // eslint-disable-next-line max-len
                        return `translate(${timelineMap.x(d.startDate)}, ${timelineMap.y(d.swimlane)})`;
                    })
                    .append('rect')
                    .attr('style', function () {
                        return 'fill: #98C3EE; stroke: #4B97E6';
                    })
                    .attr('width', function (d) {
                        const startDateX = timelineMap.x(d.startDate);
                        const endDateX = timelineMap.x(d.endDate);
                        const width = endDateX - startDateX;
                        return width >=0 ? width : 0;
                    })
                    .attr('height', 2)
                    .attr('rx', 0.2)
                    .attr('ry', 0.2),
                update =>
                    update
                        .attr('transform', function (d) {
                            // eslint-disable-next-line max-len
                            return `translate(${timelineMap.x(d.startDate)}, ${timelineMap.y(d.swimlane)})`;
                        })
                        .selectAll('rect')
                        .attr('width', function (d) {
                            const startDateX = timelineMap.x(d.startDate);
                            const endDateX = timelineMap.x(d.endDate);
                            const width = endDateX - startDateX;
                            return width >=0 ? width : 0;
                        })
            );
    }

    clearBands (timelineCanvas,type) {
        timelineCanvas
            .selectAll(`.timeline-canvas-band-${type}`).remove();
        timelineCanvas.selectAll(`.timeline-canvas-more-band-${type}`).remove();
    }

    createBands (
        timelineCanvas,
        bandRecords,
        that,
        type,
        eventSectionState,
        milstoneSectionState
    ) {
        that.clearBands (timelineCanvas,type);
        if (bandRecords.length >0 && !bandRecords[0].showRecord) {
            return;
        }
        let filteredBandRecords = bandRecords;
        let moreBandRecords = [];
        let maxBands = that.getMilestoneSwimlane()+1;
        let lessOtherItems = 0;
        if (milstoneSectionState !== SECTION_STATE.hidden) {
           lessOtherItems += milstoneSectionState === SECTION_STATE.expanded ? 2 : 1;
        }
        if (eventSectionState !== SECTION_STATE.expanded) {
            lessOtherItems += eventSectionState === SECTION_STATE.collapsed ? 1 : 0;
        } else {
            maxBands = this.maxBandsToBeDisplay;
            lessOtherItems = 0;
        }
        maxBands -= lessOtherItems;
        if (type !== SECTION_CATEGORIES.milestone) {
            filteredBandRecords = bandRecords.filter (
                item => item.swimlane < maxBands);
            moreBandRecords = bandRecords.filter (
                item => item.swimlane >= maxBands);
        }
        if (moreBandRecords.length === 1) {
            filteredBandRecords = [...filteredBandRecords,...moreBandRecords];
            moreBandRecords = [];
        }
        timelineCanvas.bandData = timelineCanvas
                .selectAll(`.timeline-canvas-band-${type}`)
                .data(filteredBandRecords, function (d) {
                    return d.id;
                })
                .attr('transform', function (d) {
                    return 'translate(' + timelineCanvas.x(d.startDate)
                        + ', ' + timelineCanvas.y(d.swimlane) + ')';
                });

        timelineCanvas.bandData
            .selectAll(`.timeline-canvas-band-background-${type}`)
            .attr('d', function (d) {
                return that.getRecordBandPathData(d, timelineCanvas);
            })
            .attr('transform', function (d) {
                return that.getRecordBandTransform(d, timelineCanvas);
            });
        timelineCanvas.bandData
            .selectAll(`.timeline-canvas-band-icon-${type}`)
            .attr('x', function (d) {
                const bandX = timelineCanvas.x(d.startDate);
                return (bandX < 0) ? Math.abs(bandX) + 22 : 0;
            });

        timelineCanvas.bandData
            .selectAll(`.timeline-canvas-band-label-${type}`)
            .attr('x', function (d) {
                const bandX = timelineCanvas.x(d.startDate);
                return (bandX < 0) ? Math.abs(bandX) + 42 : 20;
            });

        timelineCanvas.recordBands = timelineCanvas.bandData
            .enter()
            .append('g')
            .attr('class', `timeline-canvas-band-${type}`)
            .attr('data-id', function (d) {
                return d.recordId;
            })
            .attr('transform', function (d) {
                // eslint-disable-next-line max-len
                return `translate(${timelineCanvas.x(d.startDate)}, ${timelineCanvas.y(d.swimlane)})`;
            })
            .on('click', timelineCanvas.mouseOver);

        if (timelineCanvas.recordBands.size() > 0) {
            timelineCanvas.recordBands
                .append('path')
                .attr('class', `timeline-canvas-band-background-${type}`)
                .attr('d', function (d) {
                    return that.getRecordBandPathData(d, timelineCanvas);
                })
                .attr('style', function (d) {
                    const fillColor = isUndefinedOrNull(d.backgroundColor)
                        ? '#d8edff'
                        : d.backgroundColor;

                    return `fill: ${fillColor}`;
                })
                .attr('transform', function (d) {
                    return that.getRecordBandTransform(d, timelineCanvas);
                });

            const recr = timelineCanvas.recordBands
                .append('svg')
                .attr('height', 22)
                .attr('width', 22)
                .attr('x', function (d) {
                    const bandX = timelineCanvas.x(d.startDate);
                    return (bandX < 0) ? Math.abs(bandX) + 22 : 0;
                })
                .attr('class', function (d) {
                    const classes = ['slds-icon'];
                    const objectIconName = d.iconName;
                    const iconParts = objectIconName.split(':');
                    const styleGroup = iconParts[0];
                    const style = iconParts[1].replaceAll('_', '-')

                    if (styleGroup === 'utility') {
                        classes.push('slds-icon-text-default');
                    } else {
                        classes.push(`slds-icon-${styleGroup}-${style}`);
                    }

                    classes.push(`timeline-canvas-icon-${type}-${styleGroup}`);
                    classes.push(`timeline-canvas-band-icon-${type}`);

                    return classes.join(' ');
                });
                recr
                .append('rect')
                .attr('height', '100%')
                .attr('width', '100%')
                .attr('rx', 3)
                .attr('ry', 3)
                .attr('fill', function (d) {
                    let fillColor;
                    if (d.endDate) {
                        fillColor =  'transparent';
                    } else {
                        const parent = this.parentNode;

                        if (parent.classList.contains('slds-icon-text-default')) {
                            return 'transparent';
                        }

                        const parentStyle = getComputedStyle(this.parentNode);
                        const parentColor = parentStyle.getPropertyValue('background-Color');
                        fillColor =  parentColor;
                    }
                    return fillColor;
                });

                recr
                .append('use')
                .attr('height', 22)
                .attr('width', 22)
                .attr('href', function (d) {
                    const objectIconName = d.iconName;
                    const iconParts = objectIconName.split(':');
                    // eslint-disable-next-line max-len
                    const iconImage = `/_slds/icons/${iconParts[0]}-sprite/svg/symbols.svg#${iconParts[1]}`;
                    return iconImage;
                });

            timelineCanvas.recordBands
                .append('text')
                .attr('class', `timeline-canvas-band-label-${type}`)
                .attr('x', function (d) {
                    const bandX = timelineCanvas.x(d.startDate);
                    return (bandX < 0) ? Math.abs(bandX) + 42 : 26;
                })
                .attr('y', 16)
                .attr('font-size', 12)
                .attr('cursor', 'pointer')
                .attr('style', function (d) {
                    let fillColor = '#080707';

                    if (isNotUndefinedOrNull(d.backgroundColor)
                        && getContrastingColor(d.backgroundColor) === 'white') {
                        fillColor = '#ffffff';
                    }

                    return `fill: ${fillColor}`;
                })
                .on('click', timelineCanvas.mouseOver)
                .text(function (d) {
                    return d.displayName;
                });

            timelineCanvas.recordBands.call(timelineCanvas.setBBox);

            // deal with overlapping text.
            timelineCanvas.recordBands
                .insert('svg:rect', `.timeline-canvas-band-background-${type}`)
                .attr('width', d => d.bbox.width)
                .attr('height', d => d.bbox.height)
                .attr('style', 'fill: #FFFFFF');
        }
        const firstMoreBands = moreBandRecords.length > 0
            ? [moreBandRecords[0]]
            : [];
        timelineCanvas.moreBandData = timelineCanvas
            .selectAll(`.timeline-canvas-more-band-${type}`)
            .data(firstMoreBands, function (d) {
                return d.id;
            })
            .attr('transform', function (d) {
                return 'translate(' + timelineCanvas.x(d.startDate)
                    + ', ' + timelineCanvas.y(d.swimlane) + ')';
            });
        const daysAdd = that.daysToShow/2;
        let startBrushDate;
        if (!that.mapZoomStartDate) {
            // eslint-disable-next-line max-len
            const midpoint = new Date((that.filtersModel.startDate.getTime() + that.filtersModel.endDate.getTime()) / 2);
            startBrushDate = addDays(midpoint, -(that.daysToShow / 2));
        }
        const startDate = that.mapZoomStartDate
            ? new Date(that.mapZoomStartDate)
            : startBrushDate;
        if (startDate) {
            startDate.setDate(startDate.getDate()+daysAdd)
        }
        timelineCanvas.moreBandsData = timelineCanvas.moreBandData
            .enter()
            .append('g')
            .attr('class', `timeline-canvas-more-band-${type}`)
            .attr('data-id', function (d) {
                return d.recordId;
            })
            .attr('transform', function (d) {
                // eslint-disable-next-line max-len
                return `translate(${timelineCanvas.x(startDate??d.startDate)}, ${timelineCanvas.y(d.swimlane)})`;
            });

        if (moreBandRecords.length > 0) {
            const tooltipDIV = that.tooltipListEl;
            const tooltipRecDiv = that.tooltipEl;
            const bandsGroupedByStartDate = d3.group(moreBandRecords, d => d.startDateOnly);
            const groupedBands = [];
            bandsGroupedByStartDate.forEach((value,key ) => {
                if (value && Array.isArray(value)) {
                    groupedBands.push({
                        key: ''+key,
                        title: dateTimeFormat.format(new Date(key)),
                        records: value
                    })
                }
            });
            timelineCanvas.moreBandsData
            .append('text')
            .attr('class', `timeline-canvas-more-band-label-${type}`)
            .attr('x', 10)
            .attr('y', 16)
            .attr('font-size', 12)
            .attr('cursor', 'pointer')
            .attr('fill', 'blue')
            .on('click', function ( ) {
                if (tooltipDIV) {
                    if (tooltipRecDiv) {
                        tooltipRecDiv.hidePopover();
                    }
                    tooltipDIV.hideListPopover();
                    tooltipDIV.showListPopover(
                        groupedBands,
                        this,
                        that.canvasEl);
                }
            })
            .text(function () {
                return formatString(i18n.labelAndMore,moreBandRecords.length);
            });
        }

    }

    clearSectionLabel (timelineCanvas) {
        timelineCanvas
            .selectAll('.timeline-canvas-record-section-label')
            .remove();
         timelineCanvas
            .selectAll('.timeline-canvas-band-section')
            .remove();
    }


    addSectionLabel (timelineCanvas, that, records, label,swimline, type) {
        const recordsVisible = records[0].showRecord;
        timelineCanvas.sectionLabelEvent =  timelineCanvas
        .selectAll('.timeline-canvas-band-section')
        .data([records[0]], function (d) {
            return d.id;
        })
        .enter()
        .append('g')
        .attr('class', 'timeline-canvas-record-section-label')
        .attr('data-id', function (d) {
            return d.recordId;
        });
        timelineCanvas.sectionLabelEvent
        .append('rect')
        .attr('height', '20px')
        .attr('width', '250px')
        .attr('rx', 3)
        .attr('ry', 3)
        .attr('fill', function () {
            return 'rgb(243 243 243)';
        })
        .attr('cursor', 'pointer')
        .on('click', function () {
            that.handleSectionLabelClick(timelineCanvas,type,records);
        }) .attr('transform', function () {
            // eslint-disable-next-line max-len
            return `translate(0, ${timelineCanvas.y(swimline)})`;
        });
        timelineCanvas.sectionLabelEvent
        .append('text')
        .attr('class', 'timeline-canvas-band-label-text')
        .attr('x', 5)
        .attr('y', 15)
        .attr('font-size', 13)
        .attr('style','user-select:none')
        .attr('cursor', 'pointer')
        .text( label)
        .attr('transform', function () {
            // eslint-disable-next-line max-len
            return `translate(0, ${timelineCanvas.y(swimline)})`;
        })
        .attr('opacity', function () {
            return '.5';
        })
        .on('click', function () {
            that.handleSectionLabelClick(timelineCanvas,type,records);
        });
        timelineCanvas.sectionLabelEvent
        .append('use')
        .attr('class', `timeline-canvas-band-chev-down-${type}`)
        .attr('x', 220)
        .attr('y', 2)
        .attr('height', 18)
        .attr('width', 22)
        .attr('href', function () {
            return type !== 'band'
            ? '/_slds/icons/utility-sprite/svg/symbols.svg#jump_to_bottom'
            :`/_slds/icons/utility-sprite/svg/symbols.svg#chevrondown`;
        } )
        .attr('cursor', 'pointer')
        .attr('transform', function () {
            // eslint-disable-next-line max-len
            return `translate(0, ${timelineCanvas.y(swimline)})`;
        })
        .attr('style', function () {
            return recordsVisible
            ? 'visibility: visible;'
            : 'visibility: hidden;';
        })
        .attr('opacity', function () {
            return '.5';
        })
        .on('click', function () {
            that.handleSectionLabelClick(timelineCanvas,type,records);
        });
        timelineCanvas.sectionLabelEvent
        .append('use')
        .attr('class', `timeline-canvas-band-chev-up-${type}`)
        .attr('x', 220)
        .attr('y', 2)
        .attr('height', 18)
        .attr('width', 22)
        .attr('style', function () {
            return recordsVisible
            ? 'visibility: hidden;'
            : 'visibility: visible;';
        })
        .attr('href', function () {
            return type !== 'band'
            ? '/_slds/icons/utility-sprite/svg/symbols.svg#jump_to_top'
            : `/_slds/icons/utility-sprite/svg/symbols.svg#chevronright`;
        })
        .attr('transform', function () {
            // eslint-disable-next-line max-len
            return `translate(0, ${timelineCanvas.y(swimline)})`;
        })
        .attr('opacity', function () {
            return '.5';
        })
        .on('click', function () {
            that.handleSectionLabelClick(timelineCanvas,type,records);
        });
    }

    handleSectionLabelClick (timelineCanvas, type, records) {
        const isVisibleFlag = timelineCanvas.selectAll(`.timeline-canvas-band-chev-down-${type}`)
            .attr('style') === 'visibility: hidden;'
        records.forEach(record => {
            record.showRecord = isVisibleFlag;
        });
        this.resizeHandler();
    }

    getRecordBandPathData (record, timelineCanvas) {
        let pathPadding = 24;
        const startDateX = timelineCanvas.x(record.startDate);
        const endDateX = timelineCanvas.x(record.endDate);
        const viewPortX = timelineCanvas.x(timelineCanvas.x.domain()[1]);

        const useLeftArrowBand = (startDateX < 0);
        const useRightArrowBand = (endDateX > viewPortX)

        let pathData, bandLength;

        if (useLeftArrowBand && useRightArrowBand) {
            pathData = leftAndRightArrowBandPath;
            bandLength = timelineCanvas.width - pathPadding;
            pathPadding = 0;
        }
        else if (useLeftArrowBand) {
            pathData = leftArrowBandPath;
            bandLength = endDateX;
            pathPadding = 18;
        } else if (useRightArrowBand) {
            pathData = rightArrowBandPath;
            bandLength = timelineCanvas.width - startDateX;
            pathPadding = 18;
        } else {
            pathData = normalBandPath;
            bandLength = endDateX - startDateX;
            pathPadding = (bandLength - 6 < 0) ? 0 : 6; // 6 = 3pts x 2 Rounded Corners
        }

        bandLength = bandLength - pathPadding;
        return formatString(pathData, bandLength < 0 ? 0 : bandLength);
    }

    getRecordBandTransform (record, timelineCanvas) {
        const startDateX = timelineCanvas.x(record.startDate);
        const leftPosition = (startDateX < 0) ? Math.abs(startDateX) : 0;
        return `translate(${leftPosition}, 0)`;
    }

    processAxis (axisConfig, targetSVG, target) {
        const that = this;
        targetSVG.attr('width', target.width);

        let x_axis = d3
            .axisBottom(target.x)
            .tickSizeInner(axisConfig.innerTickSize)
            .ticks(axisConfig.ticks)
            .tickFormat(d3.timeFormat(axisConfig.tickFormat))
            .tickPadding(axisConfig.tickPadding);

        const axis = targetSVG
            .insert('g', ':first-child')
            .attr('class', axisConfig.class + '-' + this._timelineWidth)
            .call(x_axis)
            .call(g => g.select(".domain").remove());

        if (typeof axisConfig.translate === 'object') {
            axis.attr('transform', function () {
                return `translate(${axisConfig.translate[0]}, ${axisConfig.translate[1]})`;
            });
        }

        that.formatCanvasAxisTickLine(axis, axisConfig);

        axis.redraw = function () {
            targetSVG.attr('width', target.width);

            if (axisConfig.class === 'axis-ticks') {
                axisConfig.innerTickSize = -target.SVGHeight;
                axisConfig.translate = [0, target.SVGHeight];
            }

            x_axis = x_axis.tickSizeInner(axisConfig.innerTickSize);

            if (typeof axisConfig.translate === 'object') {
                axis.attr('transform', function () {
                    return `translate(${axisConfig.translate[0]}, ${axisConfig.translate[1]})`;
                });
            }

            axis
                .call(x_axis)
                .call(g => g.select(".domain").remove());

            that.formatCanvasAxisTickLine(axis, axisConfig);
        };

        return axis;
    }

    formatCanvasAxisTickLine (axis, axisConfig) {
        if (axisConfig.class === 'axis-ticks') {
            axis.selectAll('.tick line')
                .attr('stroke-width', '1')
                .attr('stroke', 'rgb(221, 224, 228)')
                .attr('stroke-dasharray', '9, 9')
                .attr('shape-rendering', 'crispEdges');
        }

        axis.selectAll('.tick text')
            .attr('font-size', '0.7rem')
            .attr('fill', 'rgb(62, 62, 60)');
    }

    processTimelineMap () {
        const that = this;
        const timelineMap = that._d3timelineMapSVG;
        const timelineData = that._timelineItems;
        const mapDimensions = that.mapDimensions;

        timelineMap.x = d3
            .scaleTime()
            .domain(that.requestDateRange)
            .range([0, mapDimensions.width]);

        timelineMap.y = function (swimlane) {
            return Math.min(swimlane, 9) * 4;
        };
        timelineMap.filter = function (d) {
            return that.filtersModel.typesToShow.includes(d.uniqueName);
        };

        timelineMap.width = mapDimensions.width;
        timelineMap.height = mapDimensions.height;

        timelineMap.redraw = function () {
            let i = 0;
            let swimlane = 0;
            const unitInterval = (timelineMap.x.domain()[1] - timelineMap.x.domain()[0])
                / timelineMap.width;

            const data = timelineData
                .filter(function (d) {
                    if (d.isBand) {
                        d.endTime = d.endDate;
                    } else {
                        d.endTime = new Date(d.startDate.getTime() + unitInterval * 10);
                        d.endTime.setMilliseconds(0);
                    }
                    return true;
                })
                .filter(timelineMap.filter);

            const bandRecords = that.sortTimelineResults(data.filter(d => d.isBand
                && d.objectAPIName.toLowerCase() !== 'asset'));
            const eventRecords = that.sortTimelineResults(data.filter(d => !(d.isBand)
                && d.objectAPIName.toLowerCase() !== 'asset'));
            const mileStoneRecords = that.sortTimelineResults(data.filter(d =>
                d.objectAPIName.toLowerCase() === 'asset'));

            const bandLanes = [];
            const eventLanes = [];
            const mileStoneLanes = [];

            bandRecords.forEach(function (entry) {
                for (i = 0, swimlane = 0; i < bandLanes.length; i++, swimlane++) {
                    if (entry.startDate > bandLanes[i]) {
                        break;
                    }
                }

                entry.swimlane = swimlane;
                bandLanes[swimlane] = entry.endTime;
            });

            const bandLanesLength = bandLanes.length;
            eventRecords.forEach(function (entry) {
                for (i = bandLanesLength, swimlane = bandLanesLength;
                    i < eventLanes.length; i++, swimlane++) {
                    if (entry.startDate > eventLanes[i]) {
                        break;
                    }
                }

                entry.swimlane = swimlane;
                eventLanes[swimlane] = entry.endTime;
            });

            const eventLanesLength = eventLanes.length + bandLanesLength;
            mileStoneRecords.forEach(function (entry) {
                for (i = 0, swimlane = 0; i < bandLanes.length; i++, swimlane++) {
                    for (i = eventLanesLength, swimlane = eventLanesLength;
                        i < mileStoneLanes.length; i++, swimlane++) {
                        if (entry.startDate > mileStoneLanes[i]) {
                            break;
                        }
                    }
                    if (entry.startDate > mileStoneLanes[i]) {
                        break;
                    }
                }
                entry.swimlane = swimlane;
                mileStoneLanes[swimlane] = entry.endTime;
            });

            const milestoneBandRecords = that.sortTimelineResults(
                mileStoneRecords.filter(d => d.isBand));
            const milestoneEventRecords = that.sortTimelineResults(
                mileStoneRecords.filter(d => !(d.isBand)));
            timelineMap.width = timelineMap.x.range()[1];
            timelineMap.attr('width', timelineMap.width);
            that.createBandsInMiniMap (timelineMap,[...bandRecords,...milestoneBandRecords]);
            that.createEventsInMiniMap (timelineMap,[...eventRecords,...milestoneEventRecords]);

            timelineMap
                .selectAll('.timeline-map-today')
                .data([that.getTodayBasedOnTimezone()])
                .join(
                    enter => enter.append('g')
                        .attr('class', 'timeline-map-today')
                        .attr('transform', function (d) {
                            return `translate(${timelineMap.x(d)}, 0)`;
                        })
                        .append('line')
                        .attr('stroke', '#EA8288')
                        .attr('y2', timelineMap.height),
                    update =>
                        update
                            .attr('transform', function (d) {
                                return `translate(${timelineMap.x(d)}, 0)`;
                            }),
                    exit => exit.remove()
                )
        };

        return timelineMap;
    }

    processBrush () {
        const that = this;

        const d3timeline = that._d3timelineCanvas;
        const timelineAxis = that._d3timelineCanvasAxis;
        const timelineAxisLabel = that._d3timelineCanvasAxisLabel;

        const timelineMap = that._d3timelineMap;
        const timelineMapSVG = that._d3timelineMapSVG;

        const timelineMapLayoutGroup = timelineMapSVG.append('g');

        let emptySelectionStart;
        let startBrush;
        let endBrush;

        if (that.mapZoomStartDate !== undefined) {
            startBrush = that.mapZoomStartDate;
            endBrush = that.mapZoomEndDate;
        } else {
            const startDate = new Date(that.filtersModel.startDate.getTime());
            const endDate = new Date(that.filtersModel.endDate.getTime());

            const daysBetween = calculateDateDiffInDays(startDate, endDate);

            if (daysBetween <= 14) {
                startBrush = startDate;
                endBrush = endDate;
            } else if (daysBetween > 14 && daysBetween < 60) {
                const midpoint = new Date((startDate.getTime() + endDate.getTime()) / 2);
                startBrush = addDays(midpoint, -7);
                endBrush = addDays(midpoint, 7);
            } else {
                const midpoint = new Date((startDate.getTime() + endDate.getTime()) / 2);
                startBrush = addDays(midpoint, -(that.daysToShow / 2));
                endBrush = addDays(midpoint, that.daysToShow / 2);
            }
        }

        timelineMapLayoutGroup
            .append('g')
            .attr('class', 'brush')
            .attr('transform', 'translate(0, -1)');

        const xBrush = d3.select(that.mapEl).select('g.brush');

        let brush = d3
            .brushX()
            .extent([
                [0, 0],
                [timelineMap.width, timelineMap.height]
            ])
            .on('brush', brushed)
            .on('start', brushStart)
            .on('end', brushEnd);

        // eslint-disable-next-line max-len
        const handle = xBrush
            .selectAll('.handle--custom')
            .data([{ type: 'w' }, { type: 'e' }])
            .enter()
            .append('path')
            .attr('class', 'handle--custom')
            .attr('fill', '#61adfc')
            .attr('fill-opacity', 1)
            .attr('stroke', '#000')
            .attr('height', 40)
            .attr('stroke-width', 1)
            .attr('cursor', 'ew-resize')
            .attr(
                'd',
                // eslint-disable-next-line max-len
                'M0,0 L75,0 L75,176 C75,184.284271 68.2842712,191 60,191 L15,191 C6.71572875,191 1.01453063e-15,184.284271 0,176 L0,0 L0,0 Z'
            );
        xBrush
            .call(brush)
            .call(brush.move, [new Date(startBrush), new Date(endBrush)]
                .map(timelineMap.x))
            .select('.selection')
            .attr('fill', '#61adfc');

        brush.redraw = function () {
            brush = d3
                .brushX()
                .extent([
                    [0, 0],
                    [timelineMap.width, timelineMap.height]
                ])
                .on('brush', brushed)
                .on('start', brushStart)
                .on('end', brushEnd);

            startBrush = new Date(that.mapZoomStartDate.getTime());
            endBrush = new Date(that.mapZoomEndDate.getTime());

            xBrush
                .call(brush)
                .call(brush.move, [new Date(startBrush), new Date(endBrush)]
                    .map(timelineMap.x));
        };

        function brushed (event) {
            const selections = [];

            const selection = event.selection;

            if (isNotUndefinedOrNull(selection)) {
                const x1 = timelineMap.x.invert(selection[0]);
                const x2 = timelineMap.x.invert(selection[1]);

                selections.push(x1);
                selections.push(x2);
                if (that.tooltipEl) {
                    that.tooltipEl.hidePopover();
                }
                if (that.tooltipListEl) {
                    that.tooltipListEl.hideListPopover();
                }
                d3timeline.redraw(selections);
                timelineAxis.redraw();
                timelineAxisLabel.redraw();

                handle.attr('transform', function (d, i) {
                    return 'translate(' + (selection[i] - 2) + ', ' + 0 + ') scale(0.05)';
                });

                const daysSelected = calculateDateDiffInDays(
                    d3timeline.x.domain()[1],
                    d3timeline.x.domain()[0]
                );
                that.daysToShow = daysSelected > 0 ? daysSelected : 1;
                that.mapZoomStartDate = x1
                that.mapZoomEndDate = x2;
            }
        }

        function brushStart ({ selection }) {
            if (selection) {
                emptySelectionStart = timelineMap.x.invert(selection[0]);
                handle.attr('transform', function (d, i) {
                    return 'translate(' + (selection[i] - 2) + ', ' + 0 + ') scale(0.05)';
                });
            }
        }

        function brushEnd ({ selection }) {
            if (selection === null) {
                that.mapZoomStartDate = emptySelectionStart;

                const daysBetween = that.getDaysBetweenFilterDateRange();

                let daysToAdd;
                if (daysBetween <= 2) {
                    daysToAdd = daysBetween;
                }
                else if (daysBetween > 2 && daysBetween <= 14) {
                    daysToAdd = daysBetween - 2;
                } else if (daysBetween > 14 && daysBetween < 60) {
                    daysToAdd = 7
                } else {
                    daysToAdd = 14
                }

                let endDate = addDays(new Date(emptySelectionStart.getTime()), daysToAdd);

                if (endDate > that.filtersModel.endDate) {
                    endDate = that.filtersModel.endDate;
                }

                that.mapZoomEndDate = endDate;
                that._d3brush.redraw();
            }
        }

        return brush;
    }

    getDaysBetweenFilterDateRange () {
        const startDate = new Date(this.filtersModel.startDate.getTime());
        const endDate = new Date(this.filtersModel.endDate.getTime());

        const daysBetween = calculateDateDiffInDays(startDate, endDate);

        return daysBetween;
    }

    trimText (text, length) {
        if (isNotUndefinedOrNull(text)) {
            return text.length <= length ? text : text.slice(0, length) + '...';
        }

        return '';
    }

    handleApplyFilter () {
        if (!this.validateFilterFields()) {
            return;
        }

        this.filtersModel = new FiltersViewModel(
            this.tempFiltersModel.typesToShow,
            this.tempFiltersModel.startDate,
            this.tempFiltersModel.endDate
        );

        this.handleToggleFilter();
        this.filterValuesChanged = false;
        this.mapZoomStartDate = undefined;
        this.mapZoomEndDate = undefined;
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.daysToShow = DEFAULT_DAYS_TO_SHOW;
        this.sections.clear();
        this.loadTimelineData();
    }

    clearFilterFieldsValidity () {
        const startDateEl = this.filterStartDateEl;
        const endDateEl = this.filterEndDateEl;
        this.validationError = undefined;

        startDateEl.setCustomValidity('');
        startDateEl.reportValidity();
        endDateEl.setCustomValidity('');
        endDateEl.reportValidity();
    }

    validateFilterFields () {
        const startDateEl = this.filterStartDateEl;
        const endDateEl = this.filterEndDateEl;

        this.clearFilterFieldsValidity();

        let filterFieldsValid = true;

        if (this.isAllObjectFiltersChecked () < 0) {
            this.validationError = i18n.typesToShowMissing;
            this.reportValidityForFilter ();
            filterFieldsValid = false;
        } else  {
            const recordCount = new Set ();
            this.tempFiltersModel.typesToShow.forEach (objType =>{
                recordCount.add(objType.split("_")[0]);
            } );
            if (recordCount.size > MAX_OBJECT_FILTERS_ALLOWED) {
                this.validationError = formatString(
                    i18n.limitFilterTypes,
                    MAX_OBJECT_FILTERS_ALLOWED
                );
                this.reportValidityForFilter ();
                typesEl.reportValidity();
                filterFieldsValid = false;
            }
        }

        const startDateValue = startDateEl.value;
        const endDateValue = endDateEl.value;

        if (isEmptyString(startDateValue) && !isEmptyString(endDateValue)) {
            filterFieldsValid = false;
            startDateEl.setCustomValidity(i18n.startDateMissing);
            startDateEl.reportValidity();
        } else if (!isEmptyString(startDateValue) && isEmptyString(endDateValue)) {
            filterFieldsValid = false;
            endDateEl.setCustomValidity(i18n.endDateMissing);
            endDateEl.reportValidity();
        } else if (!isEmptyString(startDateValue) && !isEmptyString(endDateValue)) {
            const start = new Date(startDateValue);
            start.setHours(0, 0, 0, 0);
            const end = new Date(endDateValue);
            end.setHours(0, 0, 0, 0);

            if (start > end) {
                endDateEl.setCustomValidity(i18n.endDateGreaterThanStart);
                filterFieldsValid = false;
            }

            endDateEl.reportValidity();
        } else {
            // When both start and end date are empty, default to the date range provided 
            // by the component properties.
            const { startDate, endDate } = this.getDateRangeFromProperties();

            this.tempFiltersModel.startDate = startDate;
            this.tempFiltersModel.endDate = endDate;
        }

        return filterFieldsValid;
    }

    reportValidityForFilter () {
        const elements = this.template.querySelectorAll(`[data-key]`);
        elements.forEach(element => {
            element.reportValidity();
        });
    }

    handleCancelFilter () {
        this.handleToggleFilter();
        this.filterValuesChanged = false;
    }

    handleFilterTypesChange (event) {
        const newValues = event.target.value;
        this.tempFiltersModel.typesToShow = newValues.sort();
        this.tempFiltersModel.typesToShow = this.tempFiltersModel.typesToShow
            .concat(this.getCriteriaFilters ());
        this.filterValuesChanged = this.tempFiltersModel.isDirty;
        this.populateSelectAllCheckBoxVal();
    }

    handleRefresh () {
        this.sections.clear();
        this.loadTimelineData();
    }

    populateFilterCheckboxValues () {
        const checkboxElements = this.template.querySelectorAll('[data-key]');
        if (checkboxElements) {
            checkboxElements.forEach(element => {
                element.checked = this.tempFiltersModel.typesToShow.includes(element.dataset.key);
            });
        }
    }

    handleToggleFilter () {
        const filterPopover = this.filterPanelEl;
        const refreshButton = this.template.querySelector('.svmx-asset-timeline_refresh-button');

        const filterPanelIsVisible = this.isFilterDisplayed;
        classListMutation(filterPopover.classList, {
            'slds-is-open': !filterPanelIsVisible
        });

        refreshButton.disabled = !filterPanelIsVisible;

        if (!filterPanelIsVisible) {
            this.tempFiltersModel = new FiltersViewModel(
                JSON.parse(JSON.stringify(this.filtersModel.typesToShow)),
                this.filtersModel.startDate,
                this.filtersModel.endDate
            );
            this.populateFilterCheckboxValues ();
            raf(()=>{
                const parentElements = this.template
                .querySelectorAll(`.svmx-assetTimeline_headerCheckbox`);
            parentElements.forEach (parentElement=> {
                const retValue = this.isAllChildChecked(parentElement.name);
                if ( retValue === 0) {
                    parentElement.indeterminate = false;
                    parentElement.checked = true;
                } else if ( retValue > 0) {
                    parentElement.checked = false;
                    parentElement.indeterminate = true;
                } else if ( retValue < 0) {
                    parentElement.indeterminate = false;
                    parentElement.checked = false;
                }
            });
            this.populateSelectAllCheckBoxVal ();}).call(this);

        } else {
            this.tempFiltersModel = new FiltersViewModel(null, null, null);
        }

        this.clearFilterFieldsValidity();
    }

    handleFilterStartDateChange (event) {
        const newValue = event.target.value;
        const splitString = isEmptyString(newValue)
            ? []
            : newValue.split('-');
        const currDate = new Date();
        if (splitString.length >0 ) {
            currDate.setFullYear(splitString[0],splitString[1]-1,splitString[2]);
        }
        this.tempFiltersModel.startDate = isEmptyString(newValue)
            ? null
            : currDate;

        this.filterValuesChanged = this.tempFiltersModel.isDirty;
    }

    handleFilterEndDateChange (event) {
        const newValue = event.target.value;
        const splitString = isEmptyString(newValue)
            ? []
            : newValue.split('-');
        const currDate = new Date();
        if (splitString.length >0 ) {
            currDate.setFullYear(splitString[0],splitString[1]-1,splitString[2]);
        }
        this.tempFiltersModel.endDate = isEmptyString(newValue)
            ? null
            : currDate;
        this.filterValuesChanged = this.tempFiltersModel.isDirty;
    }

    handleRecordNavigation (event) {
        const id = event.currentTarget.getAttribute('data-record-id');

        this[NavigationMixin.Navigate](this.getPageReferenceForRecord(id));
    }

    getPageReferenceForRecord (recordId) {
        return {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        };
    }

    updateIllustration (show, imageName, heading, message) {
        this.showIllustration = show;

        if (imageName) {
            this.illustrationImageName = imageName;
        }

        if (heading) {
            this.illustrationHeading = heading;
        }

        if (message) {
            this.illustrationMessage = message;
        }
    }

    detectOverflow (referenceRect, boundaryRect) {
        const overflowOffsets = {
            top: boundaryRect.top - referenceRect.top,
            bottom: referenceRect.bottom - boundaryRect.bottom,
            left: boundaryRect.left - referenceRect.left ,
            right: referenceRect.right - boundaryRect.right,
        };

        return overflowOffsets;
    }

    sortTimelineResults (data) {
        const copyOfData = [...data];

        return copyOfData.sort(function (item1, item2) {
            const nullSequenceResult = (item1.sequence === null) - (item2.sequence === null);
            const sequenceResult = d3.ascending(item1.sequence, item2.sequence);

            return nullSequenceResult
                || d3.ascending(item1.startDate, item2.startDate)
                || sequenceResult;
        });
    }

    getTodayBasedOnTimezone () {
        const formatOptions = {
            "hourCycle": "h23",
            "timeZone": i18n.timeZone,
            "year": "numeric",
            "month": "2-digit",
            "day": "2-digit",
            "hour": "2-digit",
            "minute": "2-digit",
            "second": "2-digit"
        };

        const formatter = new Intl.DateTimeFormat('en-US', formatOptions);

        const today = new Date();
        const todayDateParts = formatter.formatToParts(today);

        const todayDateStruct = todayDateParts.reduce(function (accumulator, currentValue) {
            if (currentValue.type !== 'literal') {
                accumulator[currentValue.type] = currentValue.value;
            }
            return accumulator;
        }, {});

        const todayInTimeZone = new Date(
            parseInt(todayDateStruct.year, 10),
            parseInt(todayDateStruct.month, 10) - 1,
            parseInt(todayDateStruct.day, 10),
            parseInt(todayDateStruct.hour, 10),
            parseInt(todayDateStruct.minute, 10),
            parseInt(todayDateStruct.second, 10)
        );

        return todayInTimeZone;
    }

    get computeIconName () {
        return this.mouseOverRecord
            ? this.mouseOverRecord.iconName
            : 'custom:custom20';
    }

    handleHeaderCheckboxChange (event) {
        event.target.checked = event.target.indeterminate ? true : event.target.checked;
        this.toggleFilterCheckboxes ( event.target.checked, event.target.name);
        this.populateSelectAllCheckBoxVal ();
        this.dummyVal = this.tempFiltersModel._typesToShow;
    }

    handleFilterCheckboxChange (event) {
        const element = event.target;
        this.toggleFilter (element);
    }

    handleSelectAll (event) {
        const isChecked = event.target.checked;
        this.tempFiltersModel.typesToShow =[];
        if (isChecked) {
            this.tempFiltersModel.typesToShow = this._objectFilter.map (filter=>{
                return filter.value;
            })
        }
        this.toggleFilterCheckboxes (isChecked);
        const elements = this.template.querySelectorAll(`.svmx-assetTimeline_headerCheckbox`);
        elements.forEach(element => {
            element.indeterminate = false;
            element.checked = isChecked;
        });
        this.toggleFilterCheckboxes ( isChecked, this.bandLabel);
        this.toggleFilterCheckboxes ( isChecked, this.milestonesLabel);
        this.toggleFilterCheckboxes ( isChecked, this.eventsLabel);
        this.populateSelectAllCheckBoxVal ();
        this.filterValuesChanged = this.tempFiltersModel.isDirty;
        this.dummyVal = this.tempFiltersModel._typesToShow;
    }

    handleClickCheckbox (event) {
        const element = this.template.querySelector(`[data-key="${event.target.dataset.id}"]`);
        element.checked = !element.checked;
        this.toggleFilter (element);
    }

    toggleFilter (element) {
        const typesToShow = this.tempFiltersModel.typesToShow;
        const index = typesToShow.findIndex (type => type === element.dataset.key);
        if (index > -1) {
            typesToShow.splice (index,1);
        } else {
            typesToShow.push (element.dataset.key);
        }
        this.tempFiltersModel.isDirty = true;
        this.filterValuesChanged = this.tempFiltersModel.isDirty;
        const parentElement = this.template
            .querySelector(`[data-hkey="${element.dataset.parent}"]`);
        if (parentElement) {
            const retValue = this.isAllChildChecked(parentElement.name);
            if ( retValue === 0) {
                parentElement.indeterminate = false;
                parentElement.checked = true;
            } else if ( retValue > 0) {
                parentElement.checked = false;
                parentElement.indeterminate = true;
            } else if ( retValue < 0) {
                parentElement.indeterminate = false;
                parentElement.checked = false;
            }
        }
        this.populateSelectAllCheckBoxVal ();
    }

    populateSelectAllCheckBoxVal () {
        const selectAllElement = this.template
            .querySelector(".svmx-assetTimeline_allheaderCheckbox");
        if (selectAllElement) {
            const retValue = this.isAllObjectFiltersChecked();
            if ( retValue === 0) {
                selectAllElement.indeterminate = false;
                selectAllElement.checked = true;
            } else if ( retValue > 0) {
                selectAllElement.checked = false;
                selectAllElement.indeterminate = true;
            } else if ( retValue < 0) {
                selectAllElement.indeterminate = false;
                selectAllElement.checked = false;
            }
        }
    }

    isAllChildChecked (dataKeyToFilter) {
        const elements = this.template.querySelectorAll(`[data-parent="${dataKeyToFilter}"]`);
        let count = 0;
        let checkCount = 0;
        elements.forEach(element => {
            count++;
            if (element.checked) {
                checkCount++;
            }
        });
        let retvalue = 0;
        if (count === checkCount) {
            retvalue = 0;
        } else if (count > checkCount) {
            if (checkCount === 0) {
                retvalue = -1;
            } else {
                retvalue = 1;
            }
        }
        return retvalue;
    }

    isAllObjectFiltersChecked () {
        const count = this.template.querySelectorAll(`[data-key]`).length
            + this.filterOptions.length;
        const checkCount = this.filterValues.length;
        let retvalue = 0;
        if (count === checkCount) {
            retvalue = 0;
        } else if (count > checkCount) {
            if (checkCount === 0) {
                retvalue = -1;
            } else {
                retvalue = 1;
            }
        }
        return retvalue;
    }

    getCriteriaFilters () {
        const elements = this.template.querySelectorAll(`[data-key]`);
        const selectedCriteriaFilters = [];
        elements.forEach(element => {
            if (element.checked) {
                selectedCriteriaFilters.push(element.dataset.key)
            }
        });
        return selectedCriteriaFilters;
    }

    toggleFilterCheckboxes (isChecked, dataKeyToFilter) {
        const elements = this.template.querySelectorAll(`[data-parent="${dataKeyToFilter}"]`);
        const typesToShow = this.tempFiltersModel.typesToShow;
        elements.forEach(element => {
            element.checked = isChecked;
            const index = typesToShow.findIndex (type => type === element.dataset.key);
            if (index > -1 && !element.checked) {
                typesToShow.splice (index,1);
            } else if (index === -1 && element.checked) {
                typesToShow.push (element.dataset.key);
            }
        });
        this.tempFiltersModel.isDirty = true;
        this.filterValuesChanged = this.tempFiltersModel.isDirty;
    }
}