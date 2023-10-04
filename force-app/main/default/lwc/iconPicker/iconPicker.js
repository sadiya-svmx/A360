import { LightningElement, track, api } from 'lwc';

import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelTitle from '@salesforce/label/c.Title_IconPicker';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchList';

import SLDSIcons from '@salesforce/resourceUrl/SLDSicons';

const i18n = {
    apply: labelApply,
    cancel: labelCancel,
    modalTitle: labelTitle,
    searchPlaceholder: labelSearchPlaceholder
}

const CATEGORIES = new Set([
    'standard',
    'doctype',
    'custom'
]);

export default class IconPicker extends LightningElement {
    @track data = [];
    @track filteredData = [];

    _selectedIcon;
    _isOpen;

    connectedCallback () {
        CATEGORIES.forEach(category => {
            const request = new XMLHttpRequest();
            request.addEventListener("load", () => {
                let svgDoc;
                if (request.responseXML) {
                    svgDoc = request.responseXML;
                } else {
                    const domParser = new DOMParser();
                    svgDoc = domParser.parseFromString(request.response, 'image/svg+xml');
                }
                Array.from(svgDoc.getElementsByTagName("symbol"))
                    .forEach(symbol => {
                        this.data.push({
                            category: category,
                            name: symbol.id.replace(/_/g, " "),
                            fullName: `${category}:${symbol.id}`
                        });
                    });
            });
            request.open("GET", `${SLDSIcons}/${category}-sprite/svg/symbols.svg`);
            request.send();
        });
    }

    @api
    get selectedIcon () {
        return this._selectedIcon;
    }
    set selectedIcon (newValue) {
        this._selectedIcon = newValue;
    }

    @api
    get isOpen () {
        return this._isOpen;
    }
    set isOpen (newValue) {
        if (newValue === true) {
            this.filterData('');
        }

        this._isOpen = newValue;
    }

    get isApplyDisabled () {
        return !this.selectedIcon
    }

    get i18n () {
        return i18n;
    }

    handleCancelModal () {
        this.dispatchEvent(
            new CustomEvent('iconpickerclosed')
        );
    }

    handleApply () {
        this.dispatchEvent(
            new CustomEvent('apply', {
                detail: {
                    value: this.selectedIcon
                }
            })
        );
    }

    handleIconSelected (event) {
        this._selectedIcon = event.target.value;
    }

    handleSearchKeyChange (event) {
        const searchKey = event.detail.value;

        if (searchKey && searchKey.length >= 1 && searchKey.length < 2) {
            return;
        }
        this.filterData(searchKey);
    }

    /**
     * Filters the list by the searchValue provided
     * @param {String} searchValue - the string value that is used to search the list
    */
    filterData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.filteredData = this.data;
        } else {
            this.filteredData = this.data.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const nameMatch = item.name
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const fullNameMatch = item.fullName
                    ? item.fullName
                        .toLowerCase()
                        .indexOf(loweredSearchValue)
                    : -1;

                return (
                    nameMatch !== -1 ||
                    fullNameMatch !== -1
                );
            });
        }
    }

}