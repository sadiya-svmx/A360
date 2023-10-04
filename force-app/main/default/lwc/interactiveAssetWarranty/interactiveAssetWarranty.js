import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import lnkClose from '@salesforce/label/c.Link_Close';
import secName from '@salesforce/label/c.Section_Create_Asset_Warranty';
import txtSecMessage from '@salesforce/label/c.Text_Section_Message';
import lblWarrantyTerms from '@salesforce/label/c.Label_Warranty_Terms';
import lblCoverageEffectiveFrom from '@salesforce/label/c.Label_Coverage_Effective_From';
import lblMaterialCovered from '@salesforce/label/c.Label_Material_Percent_Covered';
import lblLaborCovered from '@salesforce/label/c.Label_Labor_Percent_Covered';
import lblExpenseCovered from '@salesforce/label/c.Label_Expenses_Percent_Covered';
import lnkViewAll from '@salesforce/label/c.Link_View_All';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnSave from '@salesforce/label/c.Btn_Save';
import lblApplWarrTerms from '@salesforce/label/c.Label_Applicable_Warranty_Terms';
import lblOtherWarrTerms from '@salesforce/label/c.Label_Other_Warranty_Terms';
import placeholderSrchWarrTerm from '@salesforce/label/c.Placeholder_Search_for_Warranty_Term';
import placeholderChooseRow from '@salesforce/label/c.Placeholder_Choose_a_row_to_select';
import lblToastMessage from '@salesforce/label/c.Label_Toast_Warranty_Created';
import lblToastError from '@salesforce/label/c.Label_Toast_Select_Warranty';
import lblToastTitleError from '@salesforce/label/c.Title_Toast_Error_in_Warranty';

import getAssetRecord from '@salesforce/apex/WARR_ManageWarranty_LS.getAssetRecord';
import getMatchingWarrantyTermRecords
    from '@salesforce/apex/WARR_ManageWarranty_LS.getMatchingWarrantyTermRecords';
import getUnmatchedWarrantyTermRecords
    from '@salesforce/apex/WARR_ManageWarranty_LS.getUnmatchedWarrantyTermRecords';
import searchWarrantyTermRecords
    from '@salesforce/apex/WARR_ManageWarranty_LS.searchWarrantyTermRecords';
import createWarranty from '@salesforce/apex/WARR_ManageWarranty_LS.createManualWarranty';

const i18n = {
    lnkClose: lnkClose,
    secName: secName,
    txtSecMessage: txtSecMessage,
    lblWarrantyTerms: lblWarrantyTerms,
    lblCoverageEffectiveFrom: lblCoverageEffectiveFrom,
    lblMaterialCovered: lblMaterialCovered,
    lblLaborCovered: lblLaborCovered,
    lblExpenseCovered: lblExpenseCovered,
    lnkViewAll: lnkViewAll,
    btnCancel: btnCancel,
    btnSave: btnSave,
    lblApplWarrTerms: lblApplWarrTerms,
    lblOtherWarrTerms: lblOtherWarrTerms,
    placeholderSrchWarrTerm: placeholderSrchWarrTerm,
    placeholderChooseRow: placeholderChooseRow,
    lblToastMessage: lblToastMessage,
    lblToastError: lblToastError,
    lblToastTitleError: lblToastTitleError
};

const SHOW_ROWS = 6;

export default class InteractiveAssetWarranty extends NavigationMixin(
    LightningElement
) {
    @api recordId;
    @track searchKeyword = '';
    activeSections = ['ApplicableWarrantyTerm', 'OtherWarrantyTerm'];
    matchingWarrantyTerms = [];
    unMatchedWarrantyTerms = [];
    matchingWarrantyTermsForSearch;
    unMatchedWarrantyTermsForSearch;
    countMatched;
    countUnmatched;
    assetName;
    assetRecord;
    applWarrantyTerm;
    otherWarrantyTerm;
    showMatchedViewAll = false;
    showunMatchedViewAll = false;
    selectedWarrantyTermId;

    get i18n () {
        return i18n;
    }

    connectedCallback () {
        this.loadAssetName();
        this.populateWarrantyTerms();
    }

    loadAssetName () {
        getAssetRecord({ assetId: this.recordId })
            .then(result => {
                this.assetName = result.Name;
                this.assetRecord = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.i18n.lblToastTitleError,
                        message: '{0}',
                        messageData: [error.body.message],
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });
    }

    populateWarrantyTerms () {
        getMatchingWarrantyTermRecords({ assetId: this.recordId }).then(
            matchedTermRecord => {
                this.matchingWarrantyTermsForSearch = matchedTermRecord;
                const matchingWarrantyTermIds = this.getMatchingWarrantyTermIds(
                    matchedTermRecord
                );
                const matchingTerms = [...matchedTermRecord];
                this.showRowsInMatchingTable(matchingTerms);

                getUnmatchedWarrantyTermRecords({
                    lstWarrantyTermIds: matchingWarrantyTermIds
                }).then(unmatchedTermRecord => {
                    this.unMatchedWarrantyTermsForSearch = unmatchedTermRecord;
                    const unMatchedTerms = [...unmatchedTermRecord];
                    this.showRowsInNotMatchingTable(unMatchedTerms);
                });
            }
        );
    }

    getMatchingWarrantyTermIds (result) {
        const warrantyTermIds = [];
        if (result) {
            result.forEach(eachTerm => {
                warrantyTermIds.push(eachTerm.Id);
            });
        }
        return warrantyTermIds;
    }

    showRowsInMatchingTable (matchingTerms) {
        if (matchingTerms.length > SHOW_ROWS) {
            this.matchingWarrantyTerms = matchingTerms.splice(0, SHOW_ROWS);
            this.countMatched = SHOW_ROWS + '+';
            this.showMatchedViewAll = true;
        } else {
            this.matchingWarrantyTerms = matchingTerms;
            this.countMatched = matchingTerms.length;
            this.showMatchedViewAll = false;
        }
        this.applWarrantyTerm = `${this.i18n.lblApplWarrTerms} (${this.countMatched})`;
    }

    showRowsInNotMatchingTable (unMatchedTerms) {
        if (unMatchedTerms.length > SHOW_ROWS) {
            this.unMatchedWarrantyTerms = unMatchedTerms.splice(0, SHOW_ROWS);
            this.countUnmatched = SHOW_ROWS + '+';
            this.showunMatchedViewAll = true;
        } else {
            this.unMatchedWarrantyTerms = unMatchedTerms;
            this.countUnmatched = unMatchedTerms.length;
            this.showunMatchedViewAll = false;
        }
        this.otherWarrantyTerm = `${this.i18n.lblOtherWarrTerms} (${this.countUnmatched})`;
    }

    handleSearch (event) {
        const allWarrantyTermRecords = this.matchingWarrantyTermsForSearch.concat(
            this.unMatchedWarrantyTermsForSearch
        );
        this.performSearch(allWarrantyTermRecords, event.target.value);
    }

    performSearch (allWarrantyTermRecords, searchKey) {
        searchWarrantyTermRecords({
            lstWarrantyTermRecords: allWarrantyTermRecords,
            searchKeyword: searchKey
        }).then(result => {
            const matchedTerms = [];
            const unMatchedTerms = [];
            if (result && Array.isArray(result) && result.length > 0) {
                result.forEach(eachTerm => {
                    const eachMatchingTermId = this.matchingWarrantyTermsForSearch.find(
                        eachMatchingTerm => eachTerm.Id === eachMatchingTerm.Id
                    );
                    if (eachMatchingTermId) {
                        matchedTerms.push(eachTerm);
                    }

                    const eachUnMatchingTermId = this.unMatchedWarrantyTermsForSearch.find(
                        eachUnMatchingTerm => eachTerm.Id === eachUnMatchingTerm.Id
                    );
                    if (eachUnMatchingTermId) {
                        unMatchedTerms.push(eachTerm);
                    }
                });
            }
            this.showRowsInMatchingTable(matchedTerms);
            this.showRowsInNotMatchingTable(unMatchedTerms);
        });
    }

    handleCancel () {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSelect (event) {
        this.selectedWarrantyTermId = event.target.value;
    }

    handleSave () {
        if (this.selectedWarrantyTermId) {
            const getWarrTermToSave = this.getWarrRecord(this.selectedWarrantyTermId);
            createWarranty({
                warrantyTermRecord: JSON.stringify(getWarrTermToSave),
                assetRecord: this.assetRecord
            })
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: this.i18n.lblToastMessage + ' ' + this.assetName,
                        message: result,
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CustomEvent('close'));
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: this.i18n.lblToastTitleError,
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                });
        } else {
            const evt = new ShowToastEvent({
                title: this.i18n.lblToastTitleError,
                message: this.i18n.lblToastError,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        }
    }

    getWarrRecord (selectedWarrantyTermId) {
        let foundTerm;

        foundTerm = this.matchingWarrantyTerms.find(
            eachTerm => eachTerm.Id === selectedWarrantyTermId
        );
        if (foundTerm) {
            return foundTerm;
        }

        foundTerm = this.unMatchedWarrantyTerms.find(
            eachTerm => eachTerm.Id === selectedWarrantyTermId
        );

        return foundTerm;
    }

    viewWarrantyTermRecord (event) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.target,
                objectApiName: 'WarrantyTerm',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url);
        });
    }

    viewAllMatching () {
        this.matchingWarrantyTerms = this.matchingWarrantyTermsForSearch;
        this.countMatched = this.matchingWarrantyTermsForSearch.length;
        this.applWarrantyTerm = `${this.i18n.lblApplWarrTerms} (${this.countMatched})`;
        this.showMatchedViewAll = false;
    }

    viewAllNotMatching () {
        this.unMatchedWarrantyTerms = this.unMatchedWarrantyTermsForSearch;
        this.countUnmatched = this.unMatchedWarrantyTermsForSearch.length;
        this.otherWarrantyTerm = `${this.i18n.lblOtherWarrTerms} (${this.countUnmatched})`;
        this.showunMatchedViewAll = false;
    }
}