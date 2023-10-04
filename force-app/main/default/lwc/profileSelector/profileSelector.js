import { LightningElement, track, api } from 'lwc';
import getAllProfiles from '@salesforce/apex/COMM_MetadataLightningService.getAllProfiles';

import { parseErrorMessage, verifyApiResponse } from 'c/utils';

import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_ProfileSearch';
import labelSelectProfiles from '@salesforce/label/c.Label_SelectProfiles';
import labelAvailableProfiles from '@salesforce/label/c.Label_AvailableProfiles';
import labelSelectedProfiles from '@salesforce/label/c.Label_SelectedProfiles';
import labelMessage from '@salesforce/label/c.Message_ProfileSelector';
import labelAssignedToAnotherConfiguration from
    '@salesforce/label/c.Label_AssignedToAnotherConfiguration';

const i18n = {
    apply: labelApply,
    cancel: labelCancel,
    searchPlaceholder: labelSearchPlaceholder,
    listBoxLabel: labelSelectProfiles,
    sourceLabel: labelAvailableProfiles,
    selectedLabel: labelSelectedProfiles,
    label: labelMessage,
    assignedToAnotherConfiguration: labelAssignedToAnotherConfiguration
};

export default class ProfileSelector extends LightningElement {
    @track availableProfiles = [];
    @track availableProfileOptions = [];

    @track _selectedValues = [];
    @track _searchInputValue;
    @track showLoadingIndicator = false;

    _generateOptions = false;

    @track error;

    @api
    get value () {
        return this._selectedValues || [];
    }
    set value (newValue) {
        this._selectedValues = newValue || [];
    }

    @api hideLabel = false;
    @api assignedProfiles = [];
    @api label = i18n.label;

    get i18n () {
        return i18n;
    }

    get hasPreviouslyAssignedProfiles () {
        return this.assignedProfiles && this.assignedProfiles.length > 0;
    }

    connectedCallback () {
        this.getProfileData();
    }

    dispatchProfileSelectedEvent (values) {
        this.dispatchEvent(
            new CustomEvent('profileselected', {
                composed: true,
                bubbles: true,
                detail: {
                    value: values
                }
            })
        );
    }

    getProfileData () {
        this.showLoadingIndicator = true;

        getAllProfiles()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.error = null;
                this.availableProfiles = result.data;
                this._generateOptions = true;

                this.generateOptions(this.availableProfiles);
            })
            .finally(() => {
                this.showLoadingIndicator = false;
            });
    }

    generateOptions (profileRecords) {
        this.availableProfileOptions = profileRecords.map(profile => {
            return this.createOption(profile);
        });
    }

    createOption (profileRecord) {
        return {
            label: (this.assignedProfiles.includes(profileRecord.id))
                ? `${profileRecord.name} *`: profileRecord.name,
            value: profileRecord.id
        };
    }

    handleChange (event) {
        this._selectedValues = event.detail.value;
        this.filterAvailableProfiles();
        this.dispatchProfileSelectedEvent(event.detail.value);
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && searchKey.length >= 1 && searchKey.length < 3) {
            return;
        }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this._searchInputValue = searchKey;
                this.filterAvailableProfiles();
            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    filterAvailableProfiles () {
        const searchValue = this._searchInputValue;

        if (!searchValue || searchValue.length === 0) {
            this.generateOptions(this.availableProfiles);
        } else {
            const filteredProfiles = this.availableProfiles.filter(profile => {
                const loweredSearchValue = searchValue.toLowerCase();

                const nameMatch = profile.name
                    ? profile.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                const selectedOptionIndex = this._selectedValues
                    ? this._selectedValues.indexOf(profile.id)
                    : -1;

                return nameMatch !== -1 || selectedOptionIndex > -1;
            });

            this.generateOptions(filteredProfiles);
        }
    }
}