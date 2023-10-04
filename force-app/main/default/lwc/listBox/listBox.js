import { LightningElement, api, track } from 'lwc';

import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchList';
import { deepCopy, normalizeBoolean } from 'c/utils';

const i18n = {
    items: labelItemsRowCount,
    searchPlaceholder: labelSearchPlaceholder
}

export default class listBox extends LightningElement {
    @track state;
    @track _scrollable = false;
    @track _searchInputValue;

    _selectedRow;
    _keyField;
    _searchPlaceholder = i18n.searchPlaceholder;
    _itemCountLabel = i18n.items;
    _connected;

    @api
    get keyField () {
        return this._keyField;
    }

    set keyField (value) {
        this._keyField = value;
        const columns = this.state ? this.state.columns : [];
        const rows = this.state ? this.state.rows : [];
        this.normalizeState(columns, rows);
    }

    @api
    get items () {
        return this.state.rows;
    }

    set items (value) {
        const columns = this.state ? this.state.columns : [];
        this.normalizeState(columns, value);
    }

    @api
    get itemCountLabel () {
        return this._itemCountLabel;
    }
    set itemCountLabel (value) {
        if (value !== this._itemCountLabel) {
            this._itemCountLabel = value;
        }
    }

    @api
    get columns () {
        return this.state.columns;
    }

    set columns (value) {
        const rows = this.state ? this.state.rows : [];
        this.normalizeState(value, rows);
    }

    @api
    get selectedRow () {
        return this._selectedRow;
    }

    set selectedRow (value) {
        this.setSelectedRow(value);
    }

    @api
    get searchPlaceholder () {
        return this._searchPlaceholder;
    }

    set searchPlaceholder (value) {
        this._searchPlaceholder = value;
    }

    @api
    get searchInputValue () {
        return this._searchInputValue;
    }

    set searchInputValue (value) {
        if (value !== this._searchInputValue) {
            this._searchInputValue = value;

            if (this._connected) {
                this.searchInputElement.value = this._searchInputValue;
            }
        }
    }

    @api
    get scrollable () {
        return this._scrollable || false;
    }

    set scrollable (value) {
        this._scrollable = normalizeBoolean(value);
    }

    get rowCount () {
        return this.state && this.state.rows ? this.state.rows.length : undefined;
    }

    get i18n () {
        return i18n;
    }

    get computedTableContainerClass () {
        const classes = [
            'slds-scrollable',
            'slds-border_bottom',
            'slds-border_left',
            'slds-border_top',
            'slds-border_right',
            'table-container'
        ];

        return this._scrollable ? classes.join(' ') : '';
    }

    get searchInputElement () {
        return this.template.querySelector('.search-input');
    }

    connectedCallback () {
        this._connected = true;
    }

    disconnectedCallback () {
        this._connected = false;
    }

    clearSelectedRows () {
        if (this.state && this.state.rows) {
            this.state.rows.forEach(item => {item.selected = false;});
        }
    }

    dispatchRowSelectedEvent (selectedRow) {
        this.dispatchEvent(
            new CustomEvent('rowselected', {
                composed: true,
                bubbles: true,
                detail: {
                    value: selectedRow,
                }
            })
        );
    }

    handleSearchKeyChange (event) {
        this._searchInputValue = event.target.value;

        this.dispatchEvent(
            new CustomEvent('searchkeychange', {
                composed: true,
                bubbles: true,
                detail: {
                    value: event.target.value,
                }
            })
        );
    }

    handleSelect (event) {
        this.setSelectedRow(event.target.dataset.rowId);
        this.dispatchRowSelectedEvent(this._selectedRow);
    }

    normalizeState (columns, rows) {
        const transformedRows = [];
        rows.forEach(row => {
            const cells = [];
            columns.forEach(column => {
                cells.push({
                    label: column.label,
                    value: row[column.fieldName],
                    tooltip: `${column.label}: ${row[column.fieldName]}`,
                    class: (column.class) ? `slds-truncate ${column.class}`: 'slds-truncate',
                    key: `${row[this.keyField]}${row[column.fieldName]}`
                });
            });
            const mutableRow = deepCopy(row);
            mutableRow.key = row[this.keyField];
            mutableRow.cells = cells;

            transformedRows.push(mutableRow);
        });

        const state = {
            columns,
            rows: transformedRows
        };
        this.state = state;

        if (this._selectedRow) {
            this.setSelectedRow(this._selectedRow.key);
        }
    }

    setSelectedRow (rowKey) {
        this.clearSelectedRows();
        this._selectedRow = this.state.rows.find( item => item.key === rowKey );

        if (this._selectedRow) {
            this._selectedRow.selected = true;
        }
    }
}