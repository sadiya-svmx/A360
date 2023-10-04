import {
    asyncSetItemIntoCache,
    classListMutation,
    ASSET_HIERARCHY_LOCALSTORAGE,
    formatString
} from 'c/utils';
import { i18n } from "./assetHierarchyHelper";
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import LOCATION_OBJECT from '@salesforce/schema/Location';
import ASSET_OBJECT from '@salesforce/schema/Asset';
const AH_LIMITS = {
    ACTIVE_FILTER_COUNT: 2
}
export class AssetHierarchyFilterHandler {

    async handleFilterList () {
        if (!this.filterSelected) {
            this.filterValuesChanged = false;
            await this.getLocalStorageCacheFilters();
        }
        this.filterValidationError = undefined;
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.updateFilterHeight ();
    }


    handleCancelFilter () {
        this.filterSelected = !this.filterSelected;
        this.filterValuesChanged = false;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
    }

    handleLocationAddFilter () {
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.newFilterEntityDefinition = this.locationEntityDefinition;
        this.newObjectTypeExpression = {
            "advancedExpression": "",
            "criteria": "",
            "description": "",
            "developerName": "",
            "expressionDetailList": [],
            "expressionType": "",
            "id": "",
            "lastModifiedBy": "",
            "lastModifiedDate": "",
            "name": "",
            "objectAPIName": "Location",
            "type": "Standard Expression"
        };
        this.showAddFilterModal = true;
    }

    handleAssetAddFilter () {
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.newFilterEntityDefinition = this.assetEntityDefinition;
        this.newObjectTypeExpression = {
            "advancedExpression": "",
            "criteria": "",
            "description": "",
            "developerName": "",
            "expressionDetailList": [],
            "expressionType": "",
            "id": "",
            "lastModifiedBy": "",
            "lastModifiedDate": "",
            "name": "",
            "objectAPIName": "Asset",
            "type": "Standard Expression"
        };
        this.showAddFilterModal = true;
    }

    handleAccountAddFilter () {
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.newFilterEntityDefinition = this.accountEntityDefinition;
        this.newObjectTypeExpression = {
            "advancedExpression": "",
            "criteria": "",
            "description": "",
            "developerName": "",
            "expressionDetailList": [],
            "expressionType": "",
            "id": "",
            "lastModifiedBy": "",
            "lastModifiedDate": "",
            "name": "",
            "objectAPIName": "Account",
            "type": "Standard Expression"
        };
        this.showAddFilterModal = true;
    }

    handleClearAccountFilter () {
        this.accountClientFilter = [];
        this.updateFilterHeight ();
        this.filterValuesChanged = true;

    }


    handleClearAssetFilter () {
        this.assetClientFilter = [];
        this.updateFilterHeight ();
        this.filterValuesChanged = true;
    }


    handleClearLocationFilter () {
        this.locationClientFilter = [];
        this.filterValuesChanged = true;
        this.updateFilterHeight ();
    }

    handleLocationCloseFilter () {
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.showAddFilterModal = !this.showAddFilterModal;
        this.updateFilterHeight ();
    }

    handleSaveFilter () {
        const expressionBuilder = this.template.querySelector( '.svmx-asset-hierarchy-add-filter');

        if (expressionBuilder.reportValidity()) {
            return;
        }

        const builderData = expressionBuilder.expressionData.getRecordData();
        builderData.active = this.template.querySelector(
            '.svmx-asset-hierarchy-active-filter').checked;
        if (builderData.id) {
            if ( builderData.objectAPIName === ASSET_OBJECT.objectApiName ) {
                const index = this.assetClientFilter.findIndex (
                    item => String(item.id) === String(builderData.id));
                this.assetClientFilter[index] = builderData;
            } else if ( builderData.objectAPIName === LOCATION_OBJECT.objectApiName ) {
                const index = this.locationClientFilter.findIndex (
                    item => String(item.id) === String(builderData.id));
                this.locationClientFilter[index] = builderData;
            } else if ( builderData.objectAPIName === ACCOUNT_OBJECT.objectApiName ) {
                const index = this.accountClientFilter.findIndex (
                    item => String(item.id) === String(builderData.id));
                this.accountClientFilter[index] = builderData;
            }
        } else {
            builderData.id = Date.now();
            if ( builderData.objectAPIName === ASSET_OBJECT.objectApiName ) {
                this.assetClientFilter.push (builderData);
            } else if ( builderData.objectAPIName === LOCATION_OBJECT.objectApiName ) {
                this.locationClientFilter.push (builderData);
            } else if ( builderData.objectAPIName === ACCOUNT_OBJECT.objectApiName ) {
                this.accountClientFilter.push (builderData);
            }
        }
        this.filterValuesChanged = true;
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.showAddFilterModal = !this.showAddFilterModal;
        this.updateFilterHeight ();
    }

    handleDeleteFilter (event) {
        const id = event.currentTarget.dataset.id;
        const type = event.currentTarget.dataset.objecttype;
        if ( type === ASSET_OBJECT.objectApiName ) {
            this.assetClientFilter = [...this.assetClientFilter.filter (
                item => String(item.id) !== String(id))];
        } else if ( type === LOCATION_OBJECT.objectApiName ) {
            this.locationClientFilter = [...this.locationClientFilter.filter (
                item => String(item.id) !== String(id))];
        } else if ( type === ACCOUNT_OBJECT.objectApiName ) {
            this.accountClientFilter = [...this.accountClientFilter.filter (
                item => String(item.id) !== String(id))];
        }
        this.filterValuesChanged = true;
    }

    handleEditFilter (event) {
        const id = event.currentTarget.dataset.id;
        const type = event.currentTarget.dataset.objecttype;
        if ( type === ASSET_OBJECT.objectApiName ) {
            this.newFilterEntityDefinition = this.assetEntityDefinition;
            const index = this.assetClientFilter.findIndex (item => String(item.id) === String(id));
            this.newObjectTypeExpression = this.assetClientFilter[index];
        } else if ( type === LOCATION_OBJECT.objectApiName ) {
            this.newFilterEntityDefinition = this.locationEntityDefinition;
            const index = this.locationClientFilter.findIndex (
                item => String(item.id) === String(id));
            this.newObjectTypeExpression = this.locationClientFilter[index];
        } else if ( type === ACCOUNT_OBJECT.objectApiName ) {
            this.newFilterEntityDefinition = this.accountEntityDefinition;
            const index = this.accountClientFilter.findIndex (
                item => String(item.id) === String(id));
            this.newObjectTypeExpression = this.accountClientFilter[index];
        }
        this.filterSelected = !this.filterSelected;
        classListMutation(this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.showAddFilterModal = true;
    }

    handleClientFilterActivate (event) {
        const id = event.currentTarget.dataset.id;
        const type = event.currentTarget.dataset.objecttype;
        if ( type === ASSET_OBJECT.objectApiName ) {
            const index = this.assetClientFilter.findIndex (item => String(item.id) === String(id));
            this.assetClientFilter[index].active = !this.assetClientFilter[index].active;
        } else if ( type === LOCATION_OBJECT.objectApiName ) {
            const index = this.locationClientFilter.findIndex (
                item => String(item.id) === String(id));
            this.locationClientFilter[index].active = !this.locationClientFilter[index].active;
        } else if ( type === ACCOUNT_OBJECT.objectApiName ) {
            const index = this.accountClientFilter.findIndex (
                item => String(item.id) === String(id));
            this.accountClientFilter[index].active = !this.accountClientFilter[index].active;
        }
        this.filterValuesChanged = true;
    }

    handleAdminFilterActivate (event) {
        const type = event.currentTarget.dataset.type;
        if ( type === ASSET_OBJECT.objectApiName ) {
            this.assetAdminfilterEnabled = !this.assetAdminfilterEnabled;
        } else if ( type === LOCATION_OBJECT.objectApiName ) {
            this.locationAdminfilterEnabled = !this.locationAdminfilterEnabled;
        } else if ( type === ACCOUNT_OBJECT.objectApiName ) {
            this.accountAdminfilterEnabled = !this.accountAdminfilterEnabled;
        }
        this.filterValuesChanged = true;
    }

    isActiveFiltersAboveThreshold (filterActiveCount,objectLabel,that) {
        if (filterActiveCount > AH_LIMITS.ACTIVE_FILTER_COUNT ) {
            that.filterValidationError.push(formatString(
                i18n.limitActiveFilters,
                objectLabel,
                AH_LIMITS.ACTIVE_FILTER_COUNT
            ));
            return true;
        }
        return false;
    }

    validateFilters (that) {
        let isFiltersValid = true;
        that.filterValidationError = [];
        const assetFilter = [...that.assetClientFilter.filter ( item => item.active)];
        const assetActiveCount = (that.assetAdminfilterEnabled
            && that.assetCriteriaExpression)
            ? assetFilter.length + 1
            : assetFilter.length;
        if (this.isActiveFiltersAboveThreshold (
            assetActiveCount,
            that.assetEntityDefinition?.label,
            that) ) {
            isFiltersValid = false;
        }
        if (that.showLocationFilter) {
            const locationFilter = [...that.locationClientFilter.filter ( item => item.active)];
            const locationFilterActiveCount = (that.locationAdminfilterEnabled
                && that.locationCriteriaExpression)
                ? locationFilter.length + 1
                : locationFilter.length;
            if (this.isActiveFiltersAboveThreshold (
                locationFilterActiveCount,
                that.locationEntityDefinition?.label,
                that
            ) ) {
                isFiltersValid = false;
            }
        }
        if (that.showAccountFilter) {
            const accountFilter = [...that.accountClientFilter.filter ( item => item.active)];
            const accountFilterActiveCount = (that.accountAdminfilterEnabled
                && that.accountCriteriaExpression)
                ? accountFilter.length + 1
                : accountFilter.length;
            if (this.isActiveFiltersAboveThreshold (
                accountFilterActiveCount,
                that.accountEntityDefinition?.label,
                that
            ) ) {
                isFiltersValid = false;
            }
        }
        return isFiltersValid;
    }

    handleApplyFilter () {
        if (!this.searchFilter.validateFilters(this)) return;
        const assetFilter = [...this.assetClientFilter.filter ( item => item.active)];
        if (this.assetCriteriaExpression && this.assetAdminfilterEnabled) {
            assetFilter.push (this.assetCriteriaExpression);
        }

        const updatedConfig = JSON.parse (JSON.stringify (this.hierarchyConfig));
        updatedConfig.data.asset.expressions = assetFilter;
        if (this.showLocationFilter) {
            const locationFilter = [...this.locationClientFilter.filter ( item => item.active)];
            if (this.locationCriteriaExpression && this.locationAdminfilterEnabled) {
                locationFilter.push(this.locationCriteriaExpression);
            }
            updatedConfig.data.location.expressions = locationFilter;
        }

        if (this.showAccountFilter) {
            const accountFilter = [...this.accountClientFilter.filter ( item => item.active)];
            if (this.accountCriteriaExpression && this.accountAdminfilterEnabled) {
                accountFilter.push(this.accountCriteriaExpression);
            }
            updatedConfig.data.account.expressions = accountFilter;
        }

        this.selectedRows = [];
        this.targetRecord = {
            id: undefined,
            objectApiName: undefined
        }
        this.hierarchyConfig = updatedConfig;
        this.filterSelected = !this.filterSelected;
        classListMutation (this.filterPanelEl.classList, {
            'slds-is-open': this.filterSelected
        });
        this.refreshRootId ();

        /* eslint-disable max-len */
        let localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.CACHE_KEY}${LOCATION_OBJECT.objectApiName}`;
        asyncSetItemIntoCache (localStorageKey,this.locationClientFilter,true);
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.CACHE_KEY}${ASSET_OBJECT.objectApiName}`;
        asyncSetItemIntoCache (localStorageKey,this.assetClientFilter,true);
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.CACHE_KEY}${ACCOUNT_OBJECT.objectApiName}`;
        asyncSetItemIntoCache (localStorageKey,this.accountClientFilter,true);
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.ADMIN_CACHE_KEY}${LOCATION_OBJECT.objectApiName}`;
        asyncSetItemIntoCache (localStorageKey,this.locationAdminfilterEnabled,true);
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.ADMIN_CACHE_KEY}${ASSET_OBJECT.objectApiName}`;
        asyncSetItemIntoCache (localStorageKey,this.assetAdminfilterEnabled,true);
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.ADMIN_CACHE_KEY}${ACCOUNT_OBJECT.objectApiName}`;
        asyncSetItemIntoCache (localStorageKey,this.accountAdminfilterEnabled,true);
        this.filterValuesChanged = false;
    }
}