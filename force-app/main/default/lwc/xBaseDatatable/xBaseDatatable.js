/* eslint-disable max-len */
import { LightningElement, api, track } from 'lwc';
import datatableTpl from './xBaseDatatable.html';
import { classSet } from 'c/utils';
import {
    normalizeBoolean,
    normalizeString,
    isIE11,
    isSafari,
    guid,
    formatString,
    isEmptyString
} from 'c/utils';
import { LightningDatatableResizeObserver } from './datatableResizeObserver';
import { ColumnWidthManager } from './columnWidthManager';
import { generateHeaderIndexes, getDefaultState } from './normalizer';
import {
    setData,
    getData,
    getUserRowByCellKeys,
    updateRowsAndCellIndexes,
    setKeyField,
    getKeyField,
    hasValidKeyField,
} from './rows';
import {
    isResizeColumnDisabled,
    setResizeColumnDisabled,
    getResizeStep,
    setResizeStep,
    getMinColumnWidth,
    setMinColumnWidth,
    getMaxColumnWidth,
    setMaxColumnWidth,
    getColumnsWidths,
    resizeColumnWithDelta,
    getCustomerColumnWidthByObjectType,
    getTableWidthStyle,
    updateColumnWidthsMetadata,
    getResizerDefaultState,
} from './resizer';
import {
    syncSelectedRowsKeys,
    handleRowSelectionChange,
    updateSelectionState,
    getMaxRowSelection,
    setMaxRowSelection,
    getSelectedRowsKeys,
    setSelectedRowsKeys,
    handleSelectAllRows,
    handleDeselectAllRows,
    handleSelectRow,
    handleDeselectRow,
    getHideSelectAllCheckbox,
    getCurrentSelectionLength,
} from './selector';
import {
    syncActiveCell,
    handleCellKeydown,
    updateActiveCell,
    setBlurActiveCell,
    setFocusActiveCell,
    isActiveCell,
    updateTabIndex,
    getIndexesByKeys,
    updateTabIndexActiveCell,
    updateTabIndexActiveRow,
    unsetRowNavigationMode,
    updateRowNavigationMode,
    handleDatatableLosedFocus,
    handleDatatableFocusIn,
    updateTabIndexRow,
    getIndexesActiveCell,
    reactToKeyboardOnRow,
    setCellToFocusFromPrev,
    updateCellToFocusFromPrev,
    resetCellToFocusFromPrev,
    datatableHasFocus,
    setCellClickedForFocus,
    handleKeyDown,
    addFocusStylesToActiveCell,
    refocusCellElement,
} from './keyboard';
import {
    getRowNumberOffset,
    setRowNumberOffset,
    hasRowNumberColumn,
    setShowRowNumberColumn,
} from './rowNumber';
import { getColumns, normalizeColumns } from './columns';
import {
    handleLoadMoreCheck,
    isInfiniteLoadingEnabled,
    setInfiniteLoading,
    getLoadMoreOffset,
    setLoadMoreOffset,
    isLoading,
    setLoading,
    handlePrefetch,
} from './infiniteLoading';

import {
    handleRowActionTriggered,
    handleLoadDynamicActions,
    handleCellButtonClick,
} from './rowLevelActions';
import {
    getSortedBy,
    setSortedBy,
    getSortedDirection,
    setSortedDirection,
    getDefaultSortDirection,
    setDefaultSortDirection,
    updateSorting,
} from './sort';
import {
    updateHeaderActions,
    handleHeaderActionTriggered,
    handleHeaderActionMenuOpening,
    handleHeaderActionMenuClosed,
} from './headerActions';
import { setWrapTextMaxLines } from './wrapText';
import {
    isInlineEditTriggered,
    cancelInlineEdit,
    handleEditCell,
    handleInlineEditFinish,
    handleMassCheckboxChange,
    handleInlineEditPanelScroll,
    getDirtyValues,
    setDirtyValues,
    closeInlineEdit,
} from './inlineEdit';
import {
    isViewportRenderingEnabled,
    setViewportRendering,
    RenderManager,
} from './renderManager';

import { hasTreeDataType } from './tree';
import { setErrors, getTableError, getErrors } from './errors';

import DatatableTypes from './types';
import labelAriaLiveNavigationMode from '@salesforce/label/c.Label_NavigationMode';
import labelAriaLiveActionMode from '@salesforce/label/c.Label_ActionMode';
import labelCountMessage from '@salesforce/label/c.Message_ServiceCountMessage';
import labelLoadMore from '@salesforce/label/c.Label_LoadMore';

const typesMap = new WeakMap();

const i18n = {
    ariaLiveNavigationMode: labelAriaLiveNavigationMode,
    ariaLiveActionMode: labelAriaLiveActionMode,
    loadMore: labelLoadMore,
    count: labelCountMessage
};

/** 
 * A table that displays rows and columns of data.
 */
export default class xBaseDatatable extends LightningElement {
    @api tableClass = 'slds-table_bordered';
    @api lazyLoad = false;

    @track privateSuppressBottomBar = false;
    @track state = getDefaultState();

    _columns = [];
    _detailGridConfig = {
        hideCheckboxColumn: false,
        isLoading: false,
        maxColumnWidth: 1000,
        minColumnWidth: 50,
        reizeColumnDisabled: false,
        rowNumberOffset: 0,
        selectedRows: [],
        showRowNumberColumn: false,
        tableClass: 'slds-table_bordered'
    };
    _hideCheckboxColumn = false;
    _draftValues = [];
    customerSelectedRows = null;
    privateDatatableId = guid();
    @track _columnWidthsMode = 'fixed';
    @track widthsData = getResizerDefaultState();
    @track _renderedRowCount = 0;
    rowHighlightChanged = true;

    // Whether resizing is in progress
    _isResizing = false;

    constructor () {
        super();
        if (!typesMap.has(this.constructor)) {
            const privateTypes = new DatatableTypes(
                this.constructor.customTypes
            );
            typesMap.set(this.constructor, privateTypes);
        }
        this._columnWidthManager = new ColumnWidthManager(this.widthsData);
        this.updateRowsAndCellIndexes = updateRowsAndCellIndexes.bind(this);

        this._renderManager = new RenderManager();
    }

    get i18n () {
        return i18n;
    }

    get privateTypes () {
        return typesMap.get(this.constructor);
    }

    @api
    get detailGridConfig () {
        return this._detailGridConfig;
    }

    set detailGridConfig (value) {
        this._detailGridConfig = Object.assign({}, this._detailGridConfig, value);
    }

    set columns (value) {
        if (JSON.stringify(value) !== JSON.stringify(this._columns)) {
            this._columns = Array.isArray(value) ? [...value] : [];
            this.updateColumns(this._columns);
            this._columnWidthManager.handleColumnsChange(getColumns(this.state));
        }
    }

    /**
     * Array of the columns object that's used to define the data types.
     * Required properties include 'label', 'fieldName', and 'type'. The default type is 'text'.
     * See the Documentation tab for more information.
     * @type {array}
     */
    @api
    get columns () {
        return this._columns;
    }

    /**
     * This value specifies the number of lines after which the
     * content will be cut off and hidden. It must be at least 1 or more.
     * The text in the last line is truncated and shown with an ellipsis.
     * @type {integer}
     */
    @api
    get wrapTextMaxLines () {
        return this.state.wrapTextMaxLines;
    }

    set wrapTextMaxLines (value) {
        const { state } = this;
        setWrapTextMaxLines(state, value);
        this._columnWidthManager.wrapTextMaxLines = state.wrapTextMaxLines;
        this.updateRowsAndCellIndexes(this.state);
    }

    set tableData (value) {
        const data = Array.isArray(value) ? [...value] : [];

        const previousData = getData(this.state);
        const columns = getColumns(this.state);
        this._columnWidthManager.handleDataChange(previousData, data, columns);

        setData(this, data, this.lazyLoad);

        // do necessary updates since rows have changed
        if (hasValidKeyField(this.state)) {
            this.updateRowsState();
        }
        if (this.customerSelectedRows) {
            this.setSelectedRows(this.customerSelectedRows);
        }
    }

    /**
     * The array of data to be displayed.
     * @type {array}
     */
    @api
    // eslint-disable-next-line @lwc/lwc/valid-api
    get tableData () {
        return getData(this.state);
    }

    set keyField (value) {
        setKeyField(this.state, value);
        setDirtyValues(this.state, this._draftValues);
        this.updateRowsState();
    }

    /**
     * Required for better performance.
     * Associates each row with a unique ID.
     * @type {string}
     * @required
     */
    @api
    get keyField () {
        return getKeyField(this.state);
    }

    set hideCheckboxColumn (value) {
        const { state } = this;
        const normalizedValue = normalizeBoolean(value);
        this._hideCheckboxColumn = normalizedValue;

        this._columnWidthManager.handleCheckboxColumnChange(
            state.hideCheckboxColumn,
            normalizedValue,
            getColumns(state)
        );

        this.state.hideCheckboxColumn = normalizeBoolean(value);
        // update the columns metadata again to update the status.
        this.updateColumns(this._columns);
    }

    /**
     * If present, the checkbox column for row selection is hidden.
     * @type {boolean}
     * @default false
     */
    @api
    get hideCheckboxColumn () {
        return this._hideCheckboxColumn;
    }

    set showRowNumberColumn (value) {
        const { state } = this;

        this._columnWidthManager.handleRowNumberColumnChange(
            getRowNumberOffset(state),
            value,
            getColumns(state)
        );

        setShowRowNumberColumn(state, value);
        this.updateColumns(this._columns);
    }

    /**
     * If present, the row numbers are shown in the first column.
     * @type {boolean}
     * @default false
     */
    @api
    get showRowNumberColumn () {
        return hasRowNumberColumn(this.state);
    }

    set rowNumberOffset (value) {
        const { state, widthsData } = this;
        setRowNumberOffset(state, value);

        this._columnWidthManager.handleRowNumberOffsetChange(state, widthsData);
    }

    /**
     * Determines where to start counting the row number.
     * The default is 0.
     * @type {number}
     * @default 0
     */
    @api
    get rowNumberOffset () {
        return getRowNumberOffset(this.state);
    }

    set resizeColumnDisabled (value) {
        setResizeColumnDisabled(this.widthsData, value);
    }

    /**
     * If present, column resizing is disabled.
     * @type {boolean}
     * @default false
     */
    @api
    get resizeColumnDisabled () {
        return isResizeColumnDisabled(this.widthsData);
    }

    set minColumnWidth (value) {
        const { state, widthsData } = this;
        setMinColumnWidth(state, widthsData, value);
        this._columnWidthManager.minColumnWidth = this.minColumnWidth;
    }

    /**
     * The minimum width for all columns.
     * The default is 50px.
     * @type {number}
     * @default 50px
     */
    @api
    get minColumnWidth () {
        return getMinColumnWidth(this.widthsData);
    }

    set maxColumnWidth (value) {
        const { state, widthsData } = this;
        setMaxColumnWidth(state, widthsData, value);
        this._columnWidthManager.maxColumnWidth = this.maxColumnWidth;
    }

    /**
     * The maximum width for all columns.
     * The default is 1000px.
     * @type {number}
     * @default 1000px
     */
    @api
    get maxColumnWidth () {
        return getMaxColumnWidth(this.widthsData);
    }

    set resizeStep (value) {
        setResizeStep(this.widthsData, value);
    }

    /**
     * The width to resize the column when a user presses left or right arrow.
     * The default is 10px.
     * @type {number}
     * @default 10px
     */
    @api
    get resizeStep () {
        return getResizeStep(this.widthsData);
    }

    set sortedBy (value) {
        setSortedBy(this.state, value);
        updateSorting(this.state);
    }

    /**
     * The column fieldName that controls the sorting order.
     * Sort the data using the onsort event handler.
     * @type {string}
     */
    @api
    get sortedBy () {
        return getSortedBy(this.state);
    }

    set sortedDirection (value) {
        setSortedDirection(this.state, value);
        updateSorting(this.state);
    }

    /**
     * Specifies the sorting direction.
     * Sort the data using the onsort event handler.
     * Valid options include 'asc' and 'desc'.
     * @type {string}
     */
    @api
    get sortedDirection () {
        return getSortedDirection(this.state);
    }

    set defaultSortDirection (value) {
        setDefaultSortDirection(this.state, value);
        updateSorting(this.state);
    }

    /**
     * Specifies the default sorting direction on an unsorted column.
     * Valid options include 'asc' and 'desc'.
     * The default is 'asc' for sorting in ascending order.
     * @type {string}
     * @default asc
     */
    @api
    get defaultSortDirection () {
        return getDefaultSortDirection(this.state);
    }

    set enableInfiniteLoading (value) {
        setInfiniteLoading(this.state, value);
    }

    /**
     * If present, you can load a subset of data and then display more
     * when users scroll to the end of the table.
     * Use with the onloadmore event handler to retrieve more data.
     * @type {boolean}
     * @default false
     */
    @api
    get enableInfiniteLoading () {
        return isInfiniteLoadingEnabled(this.state);
    }

    set loadMoreOffset (value) {
        setLoadMoreOffset(this.state, value);
    }

    /**
     * Determines when to trigger infinite loading based on
     * how many pixels the table's scroll position is from the bottom of the table.
     * The default is 20.
     * @type {number}
     * @default 20
     */
    @api
    get loadMoreOffset () {
        return getLoadMoreOffset(this.state);
    }

    set isLoading (value) {
        setLoading(this.state, value);
    }

    /**
     * If present, a spinner is shown to indicate that more data is loading.
     * @type {boolean}
     * @default false
     */
    @api
    get isLoading () {
        return isLoading(this.state);
    }

    get hasChunksLeft () {
        return this.lazyLoad && this.state.hasChunksLeft && this.state.data.length < this.state.totalSize;
    }

    set renderConfig (value) {
        if (typeof value === 'object' && !isIE11) {
            const enableViewportRendering = value.viewportRendering;
            setViewportRendering(this.state, enableViewportRendering);

            this._renderManager.configure(this, value);
            this._renderConfig = value;
        }
    }

    /**
     * @typedef RenderManagerConfig
     * @type {object}
     * @property {boolean} viewportRendering - Specifies whether to defer rendering of rows outside the viewport until the user begins scrolling. To use this feature, create a fixed-height container element for lightning-datatable.
     * @property {number} rowHeight - Specifies the height of a row, in px
     */

    /**
     * Reserved for internal use.
     * Enables and configures advanced rendering modes.
     *
     * @type {RenderManagerConfig} value - config object for datatable rendering
     */
    @api
    get renderConfig () {
        return this._renderConfig;
    }

    get viewportRendering () {
        return isViewportRenderingEnabled(this.state);
    }

    get renderedRows () {
        if (this.viewportRendering && !isIE11) {
            return this.state.rows.slice(0, this._renderedRowCount);
        }
        return this.state.rows;
    }

    set maxRowSelection (value) {
        const previousSelectionLenght = getCurrentSelectionLength(this.state);
        setMaxRowSelection(this.state, value);
        if (previousSelectionLenght > 0) {
            this.fireSelectedRowsChange(this.getSelectedRows());
        }
    }

    /**
     * The maximum number of rows that can be selected.
     * Checkboxes are used for selection by default,
     * and radio buttons are used when maxRowSelection is 1.
     * @type {number}
     */
    @api
    get maxRowSelection () {
        return getMaxRowSelection(this.state);
    }
    set selectedRows (value) {
        this.customerSelectedRows = [...value];
        this.setSelectedRows(this.customerSelectedRows);
        this.updateRowsAndCellIndexes();
    }

    /**
     * Enables programmatic row selection with a list of key-field values.
     * @type {list}
     */
    @api
    get selectedRows () {
        return getSelectedRowsKeys(this.state);
    }

    set highlightedRows (value) {
        this.customerHighlightedRows = [...value];
        this.setHighlightedRows(this.customerHighlightedRows);
        this.rowHighlightChanged = true;
        //TODO# https://servicemax.atlassian.net/browse/A360AM-1441?focusedCommentId=364220
        //this.scrollToViewPortOnLoad (value);
    }

    scrollToViewPortOnLoad (value) {
        const navigateToHighlightedRow =
        this.template.querySelector(`[data-row-key-value="${value}"]`);
        if (navigateToHighlightedRow != null && this.rowHighlightChanged) {
            if ( !this.isInViewport(value)) {
                navigateToHighlightedRow.scrollIntoView({ behavior: 'smooth', block: "center" });
            }
            this.rowHighlightChanged = false;
        }
    }

    isInViewport (value) {
        const navigateToHighlightedRow =
        this.template.querySelector(`[data-row-key-value="${value}"]`);
        const bounding = navigateToHighlightedRow.getBoundingClientRect();
        return (
            bounding.top >= 0 &&
            bounding.left >= 0 &&
            bounding.right <= (window.innerWidth || document.documentElement.clientWidth) &&
            bounding.bottom <= (window.innerHeight || document.documentElement.clientHeight)
        );
    }

    /**
     * Enables programmatic row highlights with a list of key-field values.
     * @type {list}
     */
    @api
    get highlightedRows () {
        return this.state.highlightedRowsKeys;
    }


    set errors (value) {
        setErrors(this.state, value);
        this.updateRowsState();
    }

    /**
     * Specifies an object containing information about cell level, row level, and table level errors.
     * When it's set, error messages are displayed on the table accordingly.
     * @type {object}
     */
    @api
    get errors () {
        return getErrors(this.state);
    }

    /**
     * The current values per row that are provided during inline edit.
     * @type {object}
     */
    @api
    get draftValues () {
        return getDirtyValues(this.state);
    }

    set draftValues (value) {
        this._draftValues = Array.isArray(value) ? [...value] : [];
        setDirtyValues(this.state, value);

        if (hasValidKeyField(this.state)) {
            this.updateRowsAndCellIndexes(this.state);
        }
    }

    /**
     * If present, the table header is hidden.
     * @type {boolean}
     * @default false
     */
    @api
    get hideTableHeader () {
        return this.state.hideTableHeader;
    }

    set hideTableHeader (value) {
        this.state.hideTableHeader = !!value;
    }

    get hasValidKeyField () {
        if (hasValidKeyField(this.state)) {
            return true;
        }
        // eslint-disable-next-line no-console
        console.error(
            `The "keyField" is a required attribute of lightning:datatable.`
        );
        return false;
    }

    get showSelectAllCheckbox () {
        return !getHideSelectAllCheckbox(this.state);
    }

    /**
     * If present, the footer that displays the Save and Cancel buttons is hidden during inline editing.
     * @type {boolean}
     * @default false
     */
    @api
    get suppressBottomBar () {
        return this.privateSuppressBottomBar;
    }

    set suppressBottomBar (value) {
        this.privateSuppressBottomBar = !!value;
    }

    set columnWidthsMode (value) {
        const normalizedValue = normalizeString(value, {
            fallbackValue: 'fixed',
            validValues: ['fixed', 'auto'],
        });
        this._columnWidthManager.columnWidthMode = normalizedValue;

        const { state, widthsData } = this;
        if (widthsData.columnWidthsMode !== normalizedValue) {
            this._columnWidthManager.handleWidthModeChange(getColumns(state));
        }

        widthsData.columnWidthsMode = normalizedValue;
    }

    /**
     * Specifies how column widths are calculated. Set to 'fixed' for columns with equal widths.
     * Set to 'auto' for column widths that are based on the width of the column content and the table width. The default is 'fixed'.
     * @type {string}
     * @default fixed
     */
    @api
    get columnWidthsMode () {
        return this.widthsData.columnWidthsMode;
    }

    connectedCallback () {
        const {
            handleResizeColumn,
            handleUpdateColumnSort,
            handleCellFocusByClick,
            handleFalseCellBlur,
            handleSelectionCellClick,
        } = this;

        this.template.addEventListener(
            'selectallrows',
            handleSelectionCellClick.bind(this)
        );
        this.template.addEventListener(
            'deselectallrows',
            handleSelectionCellClick.bind(this)
        );
        this.template.addEventListener(
            'selectrow',
            handleSelectionCellClick.bind(this)
        );
        this.template.addEventListener(
            'deselectrow',
            handleSelectionCellClick.bind(this)
        );

        this.addEventListener(
            'rowselection',
            handleRowSelectionChange.bind(this)
        );

        this.template.addEventListener(
            'resizecol',
            handleResizeColumn.bind(this)
        );
        this.template.addEventListener(
            'privateupdatecolsort',
            handleUpdateColumnSort.bind(this)
        );

        this.template.addEventListener(
            'privatecellkeydown',
            handleCellKeydown.bind(this)
        );

        this.template.addEventListener(
            'privatecellfocusedbyclick',
            handleCellFocusByClick.bind(this)
        );
        this.template.addEventListener(
            'privatecellfalseblurred',
            handleFalseCellBlur.bind(this)
        );

        // row-level-actions
        this.template.addEventListener(
            'privatecellactiontriggered',
            handleRowActionTriggered.bind(this)
        );
        this.template.addEventListener(
            'privatecellactionmenuopening',
            handleLoadDynamicActions.bind(this)
        );
        this.template.addEventListener(
            'privatecellbuttonclicked',
            handleCellButtonClick.bind(this)
        );

        // header-actions
        this.template.addEventListener(
            'privatecellheaderactionmenuopening',
            handleHeaderActionMenuOpening.bind(this)
        );
        this.template.addEventListener(
            'privatecellheaderactionmenuclosed',
            handleHeaderActionMenuClosed.bind(this)
        );
        this.template.addEventListener(
            'privatecellheaderactiontriggered',
            handleHeaderActionTriggered.bind(this)
        );

        // inline-edit
        this.template.addEventListener(
            'privateeditcell',
            handleEditCell.bind(this)
        );
    }

    render () {
        return datatableTpl;
    }

    handleNextChunk () {
        this.state.data = this.state.data.concat(this.state.chunks.shift());
        this.state.chunkSize = this.state.data.length;
        this.updateRowsState();
        if (this.state.chunks.length === 0) {
            this.state.hasChunksLeft = false;
        }
    }

    get displayedCount () {
        return formatString(this.i18n.count, this.state.data.length, this.state.totalSize, 'records');
    }

    handleTrRowKeyDown (event) {
        // we probably should not be doing this unless we actually are interested in it
        if (
            this.state.keyboardMode === 'NAVIGATION' &&
            this.state.rowMode === true
        ) {
            event.stopPropagation();

            const tr = event.currentTarget;
            const rowKeyValue = tr.getAttribute('data-row-key-value');
            const keyCode = event.keyCode;
            const rowHasChildren = !!tr.getAttribute('aria-expanded');
            const rowExpanded = tr.getAttribute('aria-expanded') === 'true';
            const rowLevel = tr.getAttribute('aria-level');

            const evt = {
                target: tr,
                detail: {
                    rowKeyValue,
                    keyCode,
                    rowHasChildren,
                    rowExpanded,
                    rowLevel,
                    keyEvent: event,
                },
            };

            reactToKeyboardOnRow(this, this.state, evt);
        }
    }

    disconnectedCallback () {
        if (this.privateWidthObserver) {
            this.privateWidthObserver.disconnect();
        }

        this._renderManager.disconnectResizeObserver();
    }

    renderedCallback () {
        const { state, template, widthsData } = this;

        if (!this.privateWidthObserver) {
            this.privateWidthObserver = new LightningDatatableResizeObserver(
                template,
                state,
                widthsData,
                this._columnWidthManager
            );
        } else if (!this.privateWidthObserver.isConnected()) {
            this.privateWidthObserver.observe(template);
        }

        if (this._columnWidthManager.isResizingUpdateQueued()) {
            const fireResizeEvent = this._columnWidthManager.shouldFireResizeEvent(
                widthsData,
                getColumns(state)
            );

            this._columnWidthManager.adjustColumnsSize(
                template,
                getColumns(state),
                widthsData
            );
            this.updateRowsState();

            if (fireResizeEvent) {
                this.fireOnResize(false);
            }
        }

        handlePrefetch.call(this, template, state);
        // customerSelectedRows is only valid till render, after it, the one used should be the one from the state.
        this.customerSelectedRows = null;
        // set the previous focused cell to null after render is done
        resetCellToFocusFromPrev(state);

        if (this.viewportRendering) {
            this._renderManager.connectResizeObserver(this);
            if (!this._renderManager.hasWrapperHeight()) {
                this._renderManager.updateWrapperHeight(this);
            }
        }
        //TODO# https://servicemax.atlassian.net/browse/A360AM-1441?focusedCommentId=364220
        // this.scrollToViewPortOnLoad (this.customerHighlightedRows);
    }

    setSelectedRows (value) {
        setSelectedRowsKeys(this.state, value);
        handleRowSelectionChange.call(this);
    }

    setHighlightedRows (value) {
        this.state.highlightedRowsKeys = Array.isArray(value) ? [...value] : [];
    }

    updateRowsState () {
        const { state, widthsData, template } = this;
        // calculate cell to focus next before indexes are updated
        setCellToFocusFromPrev(state, template);

        this.updateRowsAndCellIndexes(state);

        if (this.viewportRendering) {
            this._renderManager.renderWithinViewport(this);
        }

        this._columnWidthManager.handleRowNumberOffsetChange(state, widthsData);
        // update celltofocus next to null if the row still exists after indexes calculation
        updateCellToFocusFromPrev(state);
        syncSelectedRowsKeys(state, this.getSelectedRows()).ifChanged(() => {
            // Only trigger row selection event once after all the setters have executed
            // Otherwise, event can be fired with stale data if not all setters have been triggered
            if (!this._rowSelectionEventPending) {
                this._rowSelectionEventPending = true;
                Promise.resolve().then(() => {
                    if (this._rowSelectionEventPending) {
                        this.fireSelectedRowsChange(this.getSelectedRows());
                        this._rowSelectionEventPending = false;
                    }
                });
            }
        });
        syncActiveCell(state);

        if (state.keyboardMode === 'NAVIGATION') {
            updateTabIndexActiveCell(state);
            updateTabIndexActiveRow(state);
        }
        // if there is previously focused cell which was deleted set focus from celltofocus next
        if (state.cellToFocusNext && state.activeCell) {
            setFocusActiveCell(this.template, this.state);
        }
    }

    updateColumns (columns) {
        const { state, widthsData, template } = this;
        const hadTreeDataTypePreviously = hasTreeDataType(state);
        // calculate cell to focus next before indexes are updated
        setCellToFocusFromPrev(state, template);
        normalizeColumns(state, columns, this.privateTypes);
        setDirtyValues(state, this._draftValues);
        updateRowNavigationMode(hadTreeDataTypePreviously, state);
        state.headerIndexes = generateHeaderIndexes(getColumns(state));
        // Updates state.wrapText and when isWrapableType, sets internal header actions
        updateHeaderActions(state);
        this.updateRowsAndCellIndexes(state);
        updateSelectionState(state);
        this._columnWidthManager.handleRowNumberOffsetChange(state, widthsData);
        updateColumnWidthsMetadata(state, widthsData);
        // set the celltofocus next to null if the column still exists after indexes calculation
        updateCellToFocusFromPrev(state);

        if (getColumns(state).length !== getColumnsWidths(widthsData).length) {
            if (getData(state).length > 0) {
                // when there are column changes, update the active cell
                syncActiveCell(state);
            }
        }
        if (state.keyboardMode === 'NAVIGATION') {
            updateTabIndexActiveCell(state);
            updateTabIndexActiveRow(state);
        }
        // if there is previously focused cell which was deleted set focus from celltofocus next
        if (state.cellToFocusNext && state.activeCell) {
            setFocusActiveCell(this.template, this.state);
        }
    }

    get computedTableHeaderClass () {
        if (this.state.hideTableHeader) {
            return 'slds-assistive-text';
        }
        return undefined;
    }

    // Min height required while actions menu is opened
    _actionsMinHeightStyle = '';

    get computedScrollerStyle () {
        const minHeight = this._actionsMinHeightStyle
            ? `${this._actionsMinHeightStyle};`
            : '';
        if (this._columnWidthManager.isAutoResizingUpdateQueued()) {
            return `${minHeight}overflow-x:auto`;
        }
        return `${minHeight}${getTableWidthStyle(this.widthsData)}`;
    }

    get computedTableContainerClass () {
        return classSet('')
            .add({ 'slds-table_header-fixed_container': !this.hideTableHeader })
            .add({ 'slds-scrollable_x': !this._isResizing })
            .toString();
    }

    get computedTableClass () {
        return classSet(
            'slds-table slds-table_header-fixed slds-table_edit'
        )
            .add(this.tableClass)
            .add({ 'slds-table_resizable-cols': this.hasResizebleColumns })
            .add({ 'slds-tree slds-table_tree': hasTreeDataType(this.state) })
            .toString();
    }

    get computedTableRole () {
        return hasTreeDataType(this.state) ? 'treegrid' : 'grid';
    }

    get computedTableStyle () {
        if (this._columnWidthManager.columnWidthMode === 'auto') {
            return ['table-layout:auto'].join(';');
        }
        return ['table-layout:fixed', getTableWidthStyle(this.widthsData)].join(
            ';'
        );
    }

    get computedAriaLiveClassForNavMode () {
        return classSet()
            .add({ 'slds-hide': this.state.keyboardMode !== 'NAVIGATION' })
            .add({
                'slds-assistive-text': this.state.keyboardMode === 'NAVIGATION',
            })
            .toString();
    }

    get computedAriaLiveClassForActionMode () {
        return classSet()
            .add({ 'slds-hide': this.state.keyboardMode !== 'ACTION' })
            .add({
                'slds-assistive-text': this.state.keyboardMode === 'ACTION',
            })
            .toString();
    }

    get ariaLiveNavigationModeText () {
        return `${i18n.ariaLiveNavigationMode}`;
    }

    get ariaLiveActionModeText () {
        return `${i18n.ariaLiveActionMode}`;
    }

    get ariaRowCount () {
        return this.state.rows.length;
    }

    get computedTbodyStyle () {
        if (
            hasRowNumberColumn(this.state) &&
            getRowNumberOffset(this.state) >= 0
        ) {
            return (
                'counter-reset: row-number ' + getRowNumberOffset(this.state)
            );
        }
        return '';
    }

    get hasSelectableRows () {
        return !this.state.hideCheckboxColumn;
    }

    get hasResizebleColumns () {
        return !isResizeColumnDisabled(this.widthsData);
    }

    get numberOfColumns () {
        return getColumns(this.state).length;
    }

    get showLoadingIndicator () {
        return isLoading(this.state);
    }

    get scrollerXStyles () {
        const styles = {
            height: '100%',
        };

        if (this.showStatusBar) {
            styles['padding-bottom'] = '3rem';
        }

        if (this._columnWidthManager.isAutoResizingUpdateQueued()) {
            styles['overflow-x'] = 'auto';
        }

        return Object.entries(styles)
            .map(([key, value]) => key + ':' + value)
            .join(';');
    }

    get showStatusBar () {
        return isInlineEditTriggered(this.state) && !this.suppressBottomBar;
    }

    get tableError () {
        return getTableError(this.state);
    }

    handleUpdateColumnSort (event) {
        event.stopPropagation();
        const { fieldName, sortDirection } = event.detail;

        this.fireSortedColumnChange(fieldName, sortDirection);
    }

    handleHorizontalScroll (event) {
        handleInlineEditPanelScroll.call(this, event);
    }

    handleVerticalScroll (event) {
        if (this.enableInfiniteLoading) {
            handleLoadMoreCheck.call(this, event);
        }

        handleInlineEditPanelScroll.call(this, event);

        if (this.viewportRendering) {
            this._renderManager.handleScroll(this, event);
        }
    }

    fireSelectedRowsChange (selectedRows) {
        const event = new CustomEvent('rowselection', {
            detail: { selectedRows },
        });

        this.dispatchEvent(event);
    }

    fireSortedColumnChange (fieldName, sortDirection) {
        const event = new CustomEvent('sort', {
            detail: { fieldName, sortDirection },
        });
        this.dispatchEvent(event);
    }

    fireOnResize (isUserTriggered) {
        const { state, widthsData } = this;
        const event = new CustomEvent('resize', {
            bubbles: true,
            composed: true,
            detail: {
                columnWidths: getCustomerColumnWidthByObjectType(state, widthsData),
                isUserTriggered: !!isUserTriggered,
            },
        });
        this.dispatchEvent(event);
    }

    safariHeaderFix () {
        // W-6363867, W-7143375 Safari Refresh Bug
        if (isSafari) {
            const thead = this.template.querySelector('thead');

            if (thead) {
                /* Safari hack: hide and show the table head to force a browser repaint */
                thead.style.display = 'none';

                // eslint-disable-next-line @lwc/lwc/no-async-operation
                requestAnimationFrame(() => {
                    thead.style.display = '';
                });
            }
        }
    }

    handleResizeColumn (event) {
        event.stopPropagation();
        const { state, widthsData } = this;
        const { colIndex, widthDelta } = event.detail;
        if (widthDelta !== 0) {
            resizeColumnWithDelta(state, widthsData, colIndex, widthDelta);
            this.updateRowsState();
            this.fireOnResize(true);
            this.safariHeaderFix();
        }
    }

    get tableTabIndex () {
        return this.state.focusIsInside ? '-1' : '0';
    }

    handleSelectionCellClick (event) {
        this.handleCellFocusByClick(event);

        if (event.type === 'selectrow') {
            handleSelectRow.call(this, event);
        } else if (event.type === 'deselectrow') {
            handleDeselectRow.call(this, event);
        } else if (event.type === 'selectallrows') {
            handleSelectAllRows.call(this, event);
        } else if (event.type === 'deselectallrows') {
            handleDeselectAllRows.call(this, event);
        }
    }

    handleCellFocusByClick (event) {
        event.stopPropagation();
        const {
            rowKeyValue,
            colKeyValue,
            needsRefocusOnCellElement,
        } = event.detail;
        const { state } = this;
        if (!isActiveCell(state, rowKeyValue, colKeyValue)) {
            if (state.rowMode && state.activeCell) {
                unsetRowNavigationMode(state);
                const { rowIndex } = getIndexesActiveCell(state);
                updateTabIndexRow(state, rowIndex, -1);
            }
            this.setActiveCell(rowKeyValue, colKeyValue);
            refocusCellElement(this.template, state, needsRefocusOnCellElement);
        }
    }

    handleCellClick (event) {
        // handles the case when clicking on the margin/pading of the td/th
        const targetTagName = event.target?.tagName?.toLowerCase();

        if (isEmptyString(targetTagName)) { return; }

        let rowKeyValue, colKeyValue;
        if (targetTagName === 'td' || targetTagName === 'th') {
            // get the row/col key value from the primitive cell.
            const primitiveCell = event.target.querySelector(
                ':first-child'
            );
            rowKeyValue = primitiveCell.rowKeyValue;
            colKeyValue = primitiveCell.colKeyValue;
        } else if (targetTagName === 'c-primitive-cell-factory') {
            rowKeyValue = event.target.rowKeyValue;
            colKeyValue = event.target.colKeyValue;
        }

        if (rowKeyValue && colKeyValue) {
            const { state, template } = this;
            if (
                state.rowMode ||
                !isActiveCell(state, rowKeyValue, colKeyValue)
            ) {
                if (state.rowMode && state.activeCell) {
                    unsetRowNavigationMode(state);
                    const { rowIndex } = getIndexesActiveCell(state);
                    updateTabIndexRow(state, rowIndex, -1);
                }
                this.setActiveCell(rowKeyValue, colKeyValue);
            }

            if (!datatableHasFocus(state, template)) {
                setCellClickedForFocus(state);
            }

            const row = getUserRowByCellKeys(
                this.state,
                rowKeyValue,
                colKeyValue
            )
            this.dispatchEvent(new CustomEvent('rowclick', {
                detail: { row },
                bubbles: true,
                composed: true
            }));
        }
    }

    setActiveCell (rowKeyValue, colKeyValue) {
        const { template, state } = this;
        const { rowIndex, colIndex } = getIndexesByKeys(
            state,
            rowKeyValue,
            colKeyValue
        );
        setBlurActiveCell(template, state);
        updateActiveCell(state, rowKeyValue, colKeyValue);
        addFocusStylesToActiveCell(template, state);
        updateTabIndex(state, rowIndex, colIndex, 0);
    }

    handleFalseCellBlur (event) {
        event.stopPropagation();
        const { template, state } = this;
        const { rowKeyValue, colKeyValue } = event.detail;
        if (!isActiveCell(state, rowKeyValue, colKeyValue)) {
            this.setActiveCell(rowKeyValue, colKeyValue);
        }
        setFocusActiveCell(template, state);
    }

    /**
     * Returns data in each selected row.
     * @returns {array} An array of data in each selected row.
     */
    @api
    getSelectedRows () {
        const data = getData(this.state);
        return this.state.rows.reduce((prev, row, index) => {
            if (row.isSelected) {
                prev.push(data[index]);
            }
            return prev;
        }, []);
    }

    handleTableFocusIn (event) {
        handleDatatableFocusIn.call(this, event);
    }

    handleTableFocusOut (event) {
        handleDatatableLosedFocus.call(this, event);
    }

    /**
     * @return {Object} containing the visible dimensions of the table { left, right, top, bottom, }
     */
    getViewableRect () {
        const scrollerX = this.template
            .querySelector('.slds-scrollable_x')
            .getBoundingClientRect();
        const scrollerY = this.template
            .querySelector('.slds-scrollable_y')
            .getBoundingClientRect();

        return {
            left: scrollerX.left,
            right: scrollerX.right,
            top: scrollerY.top,
            bottom: scrollerY.bottom,
        };
    }

    handleInlineEditFinish (event) {
        handleInlineEditFinish.call(this, event);
    }

    handleMassCheckboxChange (event) {
        handleMassCheckboxChange.call(this, event);
    }

    handleInlineEditSave (event) {
        event.stopPropagation();
        event.preventDefault();

        closeInlineEdit(this);
        const draftValues = this.draftValues;

        this.dispatchEvent(
            new CustomEvent('save', {
                detail: {
                    draftValues,
                },
            })
        );
    }

    handleInlineEditCancel (event) {
        event.stopPropagation();
        event.preventDefault();

        closeInlineEdit(this);

        const customerEvent = new CustomEvent('cancel', {
            cancelable: true,
        });
        this.dispatchEvent(customerEvent);

        if (!customerEvent.defaultPrevented) {
            cancelInlineEdit(this);
        }
    }

    handleTableKeydown (event) {
        handleKeyDown.call(this, event);
    }

    handleResizeStart (event) {
        event.stopPropagation();
        this._isResizing = true;
    }

    handleResizeEnd (event) {
        event.stopPropagation();
        this._isResizing = false;
    }
}