import labelChooseARow from '@salesforce/label/c.Placeholder_Choose_a_row_to_select';
import labelSelectAll from '@salesforce/label/c.Placeholder_SelectAll';
import labelSort from '@salesforce/label/c.Label_SortBy';
import labelSortAsc from '@salesforce/label/c.Label_SortByAscending';
import labelSortDesc from '@salesforce/label/c.Label_SortByDescending';
import labelSortNone from '@salesforce/label/c.Label_None';
import PrimitiveDatatableCell from 'c/primitiveDatatableCell';
import { api, track } from 'lwc';
import { classSet, classListMutation, isRTL } from 'c/utils';

import selectable from './selectableHeader.html';
import sortable from './sortableHeader.html';
import nonsortable from './nonsortableHeader.html';

const i18n = {
    chooseARow: labelChooseARow,
    selectAll: labelSelectAll,
    sort: labelSort,
    sortAsc: labelSortAsc,
    sortDesc: labelSortDesc,
    sortNone: labelSortNone,
};

function preventDefaultAndStopPropagation (event) {
    event.preventDefault();
    event.stopPropagation();
}

export default class PrimitiveHeaderFactory extends PrimitiveDatatableCell {
    @api colIndex;
    @api sorted;
    @api sortedDirection;
    @api resizestep;
    @api columnWidth;
    @api showCheckbox = false;
    @api dtContextId;

    @track _resizable;
    @track _def = {};
    @track _sortable = false;
    _actions = [];

    @api
    get actions () {
        return this._actions;
    }

    set actions (value) {
        this._actions = {
            customerActions: Array.isArray(value.customerActions) ? [...value.customerActions] : [],
            internalActions: Array.isArray(value.internalActions) ? [...value.internalActions] : [],
            menuAlignment: value.menuAlignment
        }
    }

    @api
    get resizable () {
        return this._resizable;
    }

    set resizable (value) {
        this._resizable = value;
        this.updateElementClasses();
    }

    @api
    get def () {
        return this._def;
    }

    set def (value) {
        this._def = value;
        this.updateElementClasses();
    }

    @api
    get sortable () {
        return this._sortable;
    }

    @api
    getDomWidth () {
        const child = this.template.querySelector('.slds-cell-fixed');
        if (child) {
            return child.offsetWidth;
        }
        return '';
    }

    set sortable (value) {
        this._sortable = value;
        this.updateElementClasses();
    }

    render () {
        if (this.isSelectableHeader) {
            return selectable;
        } else if (this.sortable) {
            return sortable;
        }
        return nonsortable;
    }

    renderedCallback () {
        if (this.isSelectableHeader && this.showCheckbox) {
            this.updateBulkSelectionCheckbox();
        }
    }

    updateElementClasses () {
        classListMutation(this.classList, {
            'slds-is-sortable': this.isSortable,
            'slds-is-resizable': this.isResizable,
        });
    }

    get columnStyles () {
        const outlineStyle = this.isSortable ? '' : 'outline:none;';

        // In RTL, we need to explicitly position the column headers.
        // We do this by setting the offset (in pixels) from the start of the table.
        const offsetStyle = isRTL() ? `right: ${this.def.offset}px;` : '';

        return `
            width: ${this.columnWidth}px;
            ${outlineStyle}
            ${offsetStyle}
        `;
    }

    get headerStyles () {
        return `
            box-shadow:none;
        `;
    }

    get computedClass () {
        return classSet('slds-cell-fixed')
            .add({ 'slds-has-button-menu': this.hasActions })
            .toString();
    }

    get computedSortClass () {
        return classSet('slds-th__action slds-text-link_reset')
            .add({ 'slds-is-sorted': this.sorted })
            .add({ 'slds-is-sorted_asc': this.isAscSorting })
            .add({ 'slds-is-sorted_desc': this.isDescSorting })
            .toString();
    }

    get isAscSorting () {
        return this.sortedDirection === 'asc';
    }

    get isDescSorting () {
        return this.sortedDirection === 'desc';
    }

    get sortedOrderLabel () {
        if (this.sorted) {
            return this.sortedDirection === 'desc'
                ? i18n.sortDesc
                : i18n.sortAsc;
        }
        return i18n.sortNone;
    }

    get isSelectableHeader () {
        return this.def.type === 'SELECTABLE_CHECKBOX';
    }

    get isRegularHeader () {
        return this.def.type !== 'SELECTABLE_CHECKBOX';
    }

    get isResizable () {
        return this.resizable && this.def.resizable !== false;
    }

    get isSortable () {
        return this.sortable;
    }

    get i18n () {
        return i18n;
    }

    get headerRole () {
        return this.isResizable || this.sortable ? 'button' : false;
    }

    get resizeStep () {
        return this.resizestep;
    }

    get computedOptionName () {
        return `${this.dtContextId}-options`;
    }

    handleSelectAllRows () {
        const { rowKeyValue, colKeyValue } = this;
        const actionName =
            this.def.bulkSelection === 'none'
                ? 'selectallrows'
                : 'deselectallrows';
        const actionEvent = new CustomEvent(actionName, {
            bubbles: true,
            composed: true,
            detail: {
                rowKeyValue,
                colKeyValue,
            },
        });

        this.dispatchEvent(actionEvent);
    }

    handleSortingClick (event) {
        event.preventDefault();
        if (this.isSortable) {
            preventDefaultAndStopPropagation(event);
            this.fireSortedColumn(
                this.def.fieldName,
                this.getTargetSortDirection()
            );
            this.fireCellFocusByClickEvent();
        }
    }

    getTargetSortDirection () {
        if (this.sorted) {
            return this.sortedDirection === 'desc' ? 'asc' : 'desc';
        }
        return this.sortedDirection;
    }

    fireSortedColumn (fieldName, sortDirection) {
        const event = new CustomEvent('privateupdatecolsort', {
            bubbles: true,
            composed: true,
            detail: { fieldName, sortDirection },
        });
        this.dispatchEvent(event);
    }

    get hasActions () {
        return (
            this.actions.customerActions.length > 0 ||
            this.actions.internalActions.length > 0
        );
    }

    updateBulkSelectionCheckbox () {
        const allCheckbox = this.template.querySelector(
            '.datatable-select-all'
        );
        allCheckbox.indeterminate = this.def.bulkSelection === 'some';

        // Note: since we have to handle the indeterminate state,
        //       this is to remove a raptor warning `Unneccessary update of property "checked"`
        allCheckbox.checked = !(this.def.bulkSelection === 'none');
    }
}