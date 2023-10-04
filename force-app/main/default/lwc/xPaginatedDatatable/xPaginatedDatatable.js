import { api, track, LightningElement } from 'lwc';
import { sortObjectArray } from 'c/utils';

import labelAscending from '@salesforce/label/c.Label_Ascending';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import buttonFirst from '@salesforce/label/c.Button_First';
import buttonLast from '@salesforce/label/c.Button_Last';
import buttonPrevious from '@salesforce/label/c.Button_Previous';
import buttonNext from '@salesforce/label/c.Button_Next';
import labelItemsSelected from '@salesforce/label/c.Label_ItemsSelected';
import labelFound from '@salesforce/label/c.Label_Found';
import labelDefaultEntityLabel from '@salesforce/label/c.Label_ItemsRowCount';

const i18n = {
    labelAscending: labelAscending,
    labelLoading: labelLoading,
    buttonFirst: buttonFirst,
    buttonLast: buttonLast,
    buttonPrevious: buttonPrevious,
    buttonNext: buttonNext,
    labelItemsSelected: labelItemsSelected,
    labelFound: labelFound,
    labelDefaultEntityLabel: labelDefaultEntityLabel
};

export default class XPaginatedDatatable extends LightningElement {
    pageNumber = 1;
    pagePrev;
    pagePrevPrev;
    pageNext;
    pageNextNext;
    totalRecords;
    totalPages;
    apiInProgress;
    preSelectedRecordIds = new Set();
    masterSelectedCollection = {};
    connected = false;
    recordSize = 50;
    rowOffset;

    @track displayRecords;
    @api defaultSortDirection = i18n.labelAscending;
    @api keyField = 'Id' ;
    @api entityName = labelDefaultEntityLabel;
    @api showInfoHeader = false;
    @api columns;
    @api suppressBottomBar;
    @api draftValues;
    @api errors;
    @api showRowNumberColumn = false;

    _sortedBy;
    @api get sortedBy () {
        return this._sortedBy;
    }
    set sortedBy (value) {
        this._sortedBy = this._sortedBy || value;
    }

    _sortedDirection;
    @api get sortedDirection () {
        return this._sortedDirection;
    }
    set sortedDirection (value) {
        this._sortedDirection = this._sortedDirection || value;
    }

    _records;
    @api get records () {
        return this._records;
    }
    set records (value) {
        this._records = value;

        //Records are set again from the parent component after first time load 
        if (this.connected) {
            //sort data to the state of the child component
            this._records =
                sortObjectArray(this._records, this.sortedBy, this.sortedDirection);

            this.resetCollection();
            this.generateDisplayDetails();
        }
    }

    _classList;
    @api get classList () {
        return this._classList;
    }
    set classList (value) {
        this._classList = value;
    }

    get i18n () {
        return i18n;
    }

    get disablePreviousButtons () {
        return this.pageNumber === 1;
    }

    get disableNextButtons () {
        return this.pageNumber === this.totalPages;
    }

    get fillFirst () {
        return this.disablePreviousButtons === true ? '#E4E3E1' : '#706E6B';
    }

    get fillLast () {
        return this.disableNextButtons === true ? '#E4E3E1' : '#706E6B';
    }

    get selectedCount () {
        return Object.keys(this.masterSelectedCollection).length;
    }

    get totalItemsLabel () {
        return `${this.totalRecords} ${this.entityName} ${i18n.labelFound}`;
    }

    connectedCallback () {
        this.connected = true;
        this.generateDisplayDetails();
    }

    resetCollection () {
        this.apiInProgress = true;
        const keys = Object.keys(this.masterSelectedCollection || {});

        (keys || []).forEach(key => {

            let recordExists = false;
            for (const record in this._records) {
                if ( false === Object.prototype.hasOwnProperty.call(this._records, record) ) {
                    continue;
                }
                const Id = record[this.keyField];
                if (Id === key) {
                    recordExists = true;
                    break;
                }
            }

            if (!recordExists) {
                delete this.masterSelectedCollection[key];
            }
        });
    }

    generateDisplayDetails () {
        this.apiInProgress = true;
        this.totalRecords = this._records.length;
        this.totalPages = Math.ceil(this.totalRecords / Number(this.recordSize));
        this.totalPages = this.totalPages === 0 ? 1 : this.totalPages;
        this.pageNumber = this.pageNumber > this.totalPages ? this.totalPages : this.pageNumber;
        this.setPageNumbers(this.pageNumber);
        this.processRecords();
    }

    handleSortData (event) {
        this.apiInProgress = true;
        const { fieldName, sortDirection } = event.detail;
        this._sortedBy = fieldName;
        this._sortedDirection = sortDirection;

        this._records =
            sortObjectArray(this._records, this.sortedBy, this.sortedDirection);

        this.processRecords();
    }

    handleNavigation (event) {
        this.apiInProgress = true;
        let buttonName = event.target.title || event.target.name;

        if ( event.target.localName === 'path' ) {
            buttonName = event.target.parentElement.parentElement.title;
        }

        if (buttonName === i18n.buttonFirst) {
            this.pageNumber = 1;
        } else if (buttonName === i18n.buttonNext) {
            this.pageNumber =
                this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        } else if (buttonName === i18n.buttonPrevious) {
            this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        } else if (buttonName === i18n.buttonLast) {
            this.pageNumber = this.totalPages;
        }
        this.processRecords();
    }

    handlePageJump (event) {
        if (!event.target.title) {
            return;
        }
        this.pageNumber = Number(event.target.title);
        this.processRecords();
    }

    setPageNumbers (pageNumber) {
        this.pagePrev =  pageNumber > 1 ? pageNumber - 1 : null;
        this.pagePrevPrev = pageNumber > 2 ? pageNumber - 2 : null;
        this.pageNext = pageNumber < this.totalPages ? pageNumber + 1 : null;
        this.pageNextNext = (pageNumber + 1 ) < this.totalPages ? pageNumber + 2 : null;
        this.rowOffset = ( pageNumber - 1 ) * this.recordSize;
    }

    handleKeyPress (event) {
        if (event.keyCode !== 13) {
            return;
        }

        const pageNo = event.target.value;
        if ( isNaN(pageNo) || !isFinite(pageNo) || pageNo % 1 !== 0
        || pageNo > this.totalPages || pageNo <= 0 ) {
            event.target.classList.add('slds-has-error');
            return;
        }

        event.target.classList.remove('slds-has-error');
        this.pageNumber = Number(pageNo);
        this.processRecords();
    }

    get preSelectedRows () {
        return [...this.preSelectedRecordIds];
    }

    processRecords () {
        this.setPageNumbers(this.pageNumber);
        //Load data to display on current request
        this.loadData();

        //After changing data jot down the current record selection state
        this.populateOnLoadSelection();
        this.apiInProgress = false;
    }

    //row selection logic here
    handleRowSelection (event) {
        this.populateCurrentSelection(event.detail.selectedRows);

        this.dispatchEvent(new CustomEvent('paginatedrowselection', {
            detail: {
                //Passing list as well to resamble with the lightning datatable row selection event
                selectedRows:
                    Object.values(this.masterSelectedCollection)
            }
        } ));
    }

    handleCellChange (event) {
        this.dispatchEvent(new CustomEvent('cellchange', {
            detail: event.detail
        } ));
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        switch (actionName) {
            case 'delete':
                this.masterSelectedCollection = {};
                break;
            default:
        }

        this.dispatchEvent(new CustomEvent('paginatedrowaction', {
            detail: event.detail
        } ));
    }

    loadData () {
        const startLoop = ((this.pageNumber - 1) * Number(this.recordSize));
        const endLoop =
            (this.pageNumber * Number(this.recordSize) >= this.totalRecords)
                ? this.totalRecords : this.pageNumber * Number(this.recordSize);
        this.displayRecords = this._records.slice(startLoop, endLoop);
    }

    populateOnLoadSelection () {
        this.preSelectedRecordIds.clear();

        this.displayRecords.forEach( row => {
            const rowId = row[this.keyField];
            if ( this.masterSelectedCollection[rowId] ) {
                this.preSelectedRecordIds.add(rowId);
            }
        });
    }

    populateCurrentSelection (currentSelectedRows) {
        const currentSelectedRecordsId = new Set();

        currentSelectedRows.forEach( row => {
            //Add record id into the currentSelectedRecordsId set
            currentSelectedRecordsId.add(row[this.keyField]);

            //Add current selected record Ids into this.masterSelectedCollection
            this.masterSelectedCollection[row[this.keyField]] = row;

            //Remove the selected ids from preSelectedRecordIds set
            this.preSelectedRecordIds.delete(row[this.keyField]);
        });

        //Now remove the unselected ids form the this.masterSelectedCollection
        this.preSelectedRecordIds.forEach( preSelectedId => {
            delete this.masterSelectedCollection[preSelectedId];
        });

        this.preSelectedRecordIds = new Set(currentSelectedRecordsId);
    }
}