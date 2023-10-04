/* eslint-disable no-unused-expressions */
import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProcessWizardDetailsByObject
    from '@salesforce/apex/ADM_ProcessWizardLightningService.getProcessWizardDetailsByObject';
import saveProcessWizards
    from '@salesforce/apex/ADM_ProcessWizardLightningService.saveProcessWizards';
import {
    getFieldDefinitionsForEntity
} from 'c/metadataService';
import {
    getObservableObject,
    guid,
    deepCopy,
    handleMenuSelection,
    isEmptyString,
    normalizeDeveloperName,
    parseErrorMessage,
    sortObjectArray,
    verifyApiResponse,
    ICON_NAMES
} from 'c/utils';

import labelActive from '@salesforce/label/c.Label_Active';
import labelServiceProcessManager from '@salesforce/label/c.Label_Service_Process_Manager';
import labelWizards from '@salesforce/label/c.Label_Wizards';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelObjectName from '@salesforce/label/c.Label_ObjectName';
import labelActiveWizards from '@salesforce/label/c.Label_ActiveWizards';
import labelInActiveWizards from '@salesforce/label/c.Label_InactiveWizards';
import labelInactive from '@salesforce/label/c.Label_Inactive';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelWizardHelp from '@salesforce/label/c.URL_WizardHelp';
import labelSave from '@salesforce/label/c.Button_Save';
import labelSavingWizard from '@salesforce/label/c.AltText_SavingWizard';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelAddWizard from '@salesforce/label/c.Button_AddWizard';
import labelShowMenuAltText from '@salesforce/label/c.AltText_ShowMenu';
import labelReorderWizards from '@salesforce/label/c.Label_ReorderWizards';
import messageNoWizards from '@salesforce/label/c.Message_NoWizards';
import messageNoInactiveWizards from '@salesforce/label/c.Message_NoInactiveWizards';
import labelCopy from '@salesforce/label/c.Label_Copy';
import labelWizardOrder from '@salesforce/label/c.Title_WizardOrder';
import labelStepOrder from '@salesforce/label/c.Title_StepOrder';
import labelDeleteWizard from '@salesforce/label/c.Title_DeleteWizard';
import labelDeleteWizardPrompt from '@salesforce/label/c.Label_DeletedWizardPrompt';
import labelDeleteStep from '@salesforce/label/c.Title_DeleteStep';
import labelDeleteStepPrompt from '@salesforce/label/c.Label_DeletedStepPrompt';
import labelOperationUndone from '@salesforce/label/c.Label_Operation_Cannot_Be_Undone';
import labelRemove from '@salesforce/label/c.Button_Remove';
import labelDelete from '@salesforce/label/c.Button_Delete';
import filterPlaceholderLabel from '@salesforce/label/c.Label_WizardFilterPlaceholder';
import labelWizardStepRemoval from '@salesforce/label/c.Label_WizardStepRemovalAlert';
import labelReorderWarning from '@salesforce/label/c.Title_AlertWarning';
import labelOK from '@salesforce/label/c.Button_OK';
import labelReorderWarningPromptLine1 from '@salesforce/label/c.Label_ReorderWarningPrompt_Line1';
import labelReorderWarningPromptLine2 from '@salesforce/label/c.Label_ReorderWarningPrompt_Line2';

const i18n = {
    active: labelActive,
    pageHeader: labelServiceProcessManager,
    wizards: labelWizards,
    addWizard: labelAddWizard,
    showMenuAltText: labelShowMenuAltText,
    reorderWizards: labelReorderWizards,
    inactive: labelInactive,
    items: labelItemsRowCount,
    help: labelHelp,
    loading: labelLoading,
    cancel: labelCancel,
    save: labelSave,
    confirm: labelConfirm,
    remove: labelRemove,
    delete: labelDelete,
    objectName: labelObjectName,
    activeWizards: labelActiveWizards,
    inactiveWizards: labelInActiveWizards,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    noResults: labelNoResults,
    noWizards: messageNoWizards,
    noInactiveWizards: messageNoInactiveWizards,
    helpLink: labelWizardHelp,
    savingWizard: labelSavingWizard,
    wasSaved: labelWasSaved,
    wizardOrderDialogTitle: labelWizardOrder,
    stepOrderDialogTitle: labelStepOrder,
    copy: labelCopy,
    deleteWizardTitle: labelDeleteWizard,
    deleteWizardPrompt: labelDeleteWizardPrompt,
    deleteWizardWarning: labelOperationUndone,
    deleteStepTitle: labelDeleteStep,
    deleteStepPrompt: labelDeleteStepPrompt,
    deleteStepWarning: labelOperationUndone,
    filterPlaceholder: filterPlaceholderLabel,
    wizardStepRemovalAlert: labelWizardStepRemoval,
    labelReorderWarning: labelReorderWarning,
    labelOK: labelOK,
    labelReorderWarningPromptLine1: labelReorderWarningPromptLine1,
    labelReorderWarningPromptLine2: labelReorderWarningPromptLine2,
};

const TAB_TYPES = {
    ACTIVE: 'active',
    INACTIVE: 'inactive'
};

export default class WizardAdminDetail extends NavigationMixin(
    LightningElement
) {
    currentPageReference;

    @track error;
    @track apiInProgress = false;
    @track data = [];
    @track activeTab = TAB_TYPES.ACTIVE;
    @track entityDefinition;

    newWizardConfigOpen;
    existingWizardConfigOpen;
    newStepConfigOpen;
    existingStepConfigOpen;
    reorderWizardOpen;
    reorderStepsOpen;
    deleteWizardDialogOpen;
    deleteStepDialogOpen;
    searchInProgress = false;
    searchString;
    expandedSections;
    renderTemplateFlag;
    reorderWarningStepDialogOpen;

    _actionName;
    _objectApiName;
    _objectLabel;
    _currentWizard;
    _pendingWizardToDelete;
    _pendingStepToDelete;
    _dirty = false;
    _childStepList =[];
    _dependentStepRemoved=false;

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        if (pageRef && pageRef.state) {
            this.clearState();

            if (pageRef.state.c__objectName) {
                this._objectApiName = pageRef.state.c__objectName;
                if (!this.entityDefinition ||
                     this.entityDefinition.apiName !== this._objectApiName) {
                    this.getObjectFields(this._objectApiName)
                        .then(result => {
                            this.entityDefinition = result;
                        })
                        .catch(error => {
                            this.error = parseErrorMessage(error);
                        });
                }
            }

            if (pageRef.state.c__objectLabel) {
                this._objectLabel = pageRef.state.c__objectLabel;
            }

            if (pageRef.state.c__actionName) {
                this._actionName = pageRef.state.c__actionName.toLowerCase();
            }

            this.clearWizardSearch();
            this.loadView();
        }
    }

    /**
     * Saves the Process Wizard data to the Salesforce database.
     */
    @api
    save () {
        this.saveWizardData();
    }

    /**
     * Returns a copy of the wizards data
     */
    @api
    get wizardData () {
        return deepCopy(this.data);
    }

    get i18n () {
        return i18n;
    }

    get tabTypes () {
        return TAB_TYPES;
    }

    get title () {
        return `${this.i18n.wizards} - ${this._objectLabel}`;
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    clearState () {
        this.error = null;
        this._actionName = null;
        this._objectApiName = null;
        this._objectLabel = null;
        this._currentWizard = null;
        this.apiInProgress = false;
        this.data = [];
        this._pendingWizardToDelete = null;
        this._pendingStepToDelete = null;
        this.newWizardConfigOpen = false;
        this.existingWizardConfigOpen = false;
        this.newStepConfigOpen = false;
        this.existingStepConfigOpen = false;
        this.reorderWizardOpen = false;
        this.reorderStepsOpen = false;
        this.reorderWarningStepDialogOpen = false;
        this.deleteWizardDialogOpen = false;
        this._dirty = false;
        this.activeTab = TAB_TYPES.ACTIVE;
    }

    get nextWizardSequenceNumber () {
        const currentTopSequence = this.activeWizards.reduce(
            (highestSequence, wizard) => {
                let topSequence = highestSequence;
                if (wizard.sequence > topSequence) {
                    topSequence = wizard.sequence;
                }
                return topSequence;
            },
            0
        );

        return currentTopSequence + 1;
    }

    get noActiveResults () {
        return (this.activeWizards && this.activeWizards.length === 0)
            ? true
            :(this.activeWizards.filter(e => {return e.isVisible;}).length === 0)
                ? true
                : undefined;
    }

    get noInactiveResults () {
        return (this.inactiveWizards && this.inactiveWizards.length === 0)
            ? true
            : (this.inactiveWizards.filter(e => {return e.isVisible;}).length === 0)
                ? true
                : undefined;
    }

    get activeWizards () {
        if (!this.data) {
            return undefined;
        }

        return sortObjectArray(
            this.data.filter(element => {
                return element.active;
            }),
            'sequence',
            'asc'
        );
    }

    get inactiveWizards () {
        if (!this.data) {
            return undefined;
        }

        return sortObjectArray(
            this.data.filter(element => {
                return !element.active;
            }),
            'name',
            'asc'
        );
    }

    get reorderButtonDisabled () {
        const moreThan1Wizard = this.activeWizards && this.activeWizards.length > 1;
        const searchKeyLen = this.searchString?.length;
        return this.activeTab === TAB_TYPES.INACTIVE || !moreThan1Wizard || searchKeyLen > 0;
    }

    get saveButtonDisabled () {
        return !this._dirty;
    }

    get saveButtonVariant () {
        return this.saveButtonDisabled ? 'neutral' : 'brand';
    }

    get wizardOrderOptions () {
        const activeWizards = this.activeWizards;
        if (activeWizards && activeWizards.length > 0) {
            const options = activeWizards.map(wizard => {
                return {
                    label: wizard.name,
                    value: wizard.referenceId
                };
            });

            return options;
        }

        return [];
    }

    get wizardStepOptions () {
        if (this._currentWizard && this._currentWizard.steps) {
            const sortedSteps = sortObjectArray(
                this._currentWizard.steps,
                'sequence',
                'asc'
            );

            return sortedSteps.map(step => {
                return {
                    label: step.name,
                    value: step.referenceId
                };
            });
        }

        return [];
    }

    get totalActiveWizardCount () {
        return this.data.filter((w) => {return w.active;}).length;
    }

    get totalInactiveWizardCount () {
        return this.data.filter((w) => {return !w.active;}).length;
    }

    get childStepsExists () {
        return this._childStepList.length > 0 ? true : false;
    }

    get childSteps () {
        return this._childStepList;
    }

    renderedCallback () {
        if (this.wizardToScrollTo) {
            const wizardElement = this.getWizardElementByReference(this.wizardToScrollTo);
            const scrollingParent = this.template.querySelector('.scrollable');

            if (wizardElement && scrollingParent) {
                this.scrollIntoViewIfNeeded(wizardElement, scrollingParent);
            }

            this.wizardToScrollTo = null;
        }
    }

    dispatchWizardDataChanged () {
        if (!this.searchInProgress) {
            this._dirty = true;
            this.dispatchEvent(
                new CustomEvent('wizarddatachanged', {
                    composed: true,
                    bubbles: true,
                    detail: {
                        value: `${this._objectLabel} ${i18n.wizards}`
                    }
                })
            );
        }
    }

    dispatchWizardDataSaved () {
        this.dispatchEvent(
            new CustomEvent('wizarddatasaved', {
                composed: true,
                bubbles: true
            })
        );
    }

    loadView () {
        this.apiInProgress = true;

        getProcessWizardDetailsByObject({
            requestJson: JSON.stringify({
                objectAPIName: this._objectApiName
            })
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.error = null;
            this.setViewData(result.data);
        })
            .catch(error => {
                this.error = error;
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    setViewData (data) {
        // Set up referenceIds
        if (!data || !Array.isArray(data)) {
            this.data = [];
            return;
        }

        data.forEach(item => {
            item.referenceId = guid();

            if (item.steps) {
                const stepReferenceMap = new Map();
                item.steps.forEach(step => {
                    const stepReferenceId = guid();
                    stepReferenceMap.set(step.id, stepReferenceId)
                    step.referenceId = stepReferenceId;

                    if (step.stepParameters) {
                        step.stepParameters.forEach(param => {
                            param.referenceId = guid();
                        })
                    }
                });
                if (stepReferenceMap.size > 0) {
                    item.steps.forEach(step => {
                        if (step.dependentSteps) {
                            step.dependentSteps.forEach(depStep => {
                                depStep.referenceId = stepReferenceMap.get(depStep.dependentStepId);
                            });
                        }
                    });
                }
            }
        });

        this.data = getObservableObject(data, () =>
            this.dispatchWizardDataChanged()
        );
    }

    handleAddStep (event) {
        const wizard = event.detail.value;

        const configDialog = this.template.querySelector('.stepConfig');

        configDialog.objectApiName = this._objectApiName;
        const sequence = wizard && wizard.steps ? wizard.steps.length + 1 : 1;
        configDialog.sequence = sequence;
        configDialog.wizardReferenceId = wizard.referenceId;
        // configDialog.wizard = wizard;
        configDialog.wizardDevName = wizard.developerName;
        configDialog.wizardStepDevNames = this.getWizardStepDeveloperNames(wizard);
        configDialog.showDependentStepFlag = wizard.stepDependencyType === 'Checklist';
        const currentStep = { referenceId: '', sequence: sequence };
        configDialog.dependentStepsList = this.getDependentStepsList(currentStep, wizard);

        this.newStepConfigOpen = true;
    }

    handleStepRemoved (event) {
        this._pendingStepToDelete = event.detail;
        this.deleteStepDialogOpen = true;
        this.getChildStepByDependentStepId();
    }

    handleAddWizard () {
        const configDialog = this.template.querySelector('.wizardConfig');

        configDialog.objectApiName = this._objectApiName;
        configDialog.sequence = this.nextWizardSequenceNumber;
        configDialog.active = this.activeTab === TAB_TYPES.ACTIVE;

        this.newWizardConfigOpen = true;
    }

    handleNewStepConfigChanged (event) {
        const wizard = this.getLocalWizardByReferenceId(
            event.detail.value.wizardReferenceId
        );
        const step = event.detail.value;
        step.isModified = true;
        if (wizard && wizard.steps) {
            wizard.steps.push(step);
        } else {
            wizard.steps = [step];
        }

        if (this.searchString) {
            this.clearWizardSearch();
            this.expandedSections = wizard?.name;
            this.wizardToScrollTo = wizard?.referenceId;
        }

        this.newStepConfigOpen = false;
        this._dirty = true;
    }

    handleNewStepConfigClosed () {
        this.newStepConfigOpen = false;
    }

    handleDeleteStepCancel () {
        this.deleteStepDialogOpen = false;
        this._pendingStepToDelete = undefined;
    }

    handleDeleteWizardCancel () {
        this.deleteWizardDialogOpen = false;
        this._pendingWizardToDelete = undefined;
    }

    handleDeleteStepConfirm () {
        if (!this._pendingStepToDelete) return;

        const {
            wizardReferenceId,
            stepReferenceId
        } = this._pendingStepToDelete;

        const wizardIdx = this.getLocalWizardIndexByReferenceId(
            wizardReferenceId
        );
        const wizard = this.getLocalWizardByReferenceId(wizardReferenceId);

        const dataIndex = this.getLocalStepIndexByReferenceId(
            stepReferenceId,
            wizard
        );

        if (dataIndex > -1 && wizardIdx > -1) {
            wizard.isModified = true;
            wizard.steps.splice(dataIndex, 1);
            this.updateStepSequences(wizard);
            this.data.splice(wizardIdx, 1, wizard);
            wizard.steps.forEach(step => {
                if (step.dependentSteps) {
                    const depStepIdx = step.dependentSteps.findIndex(
                        depStep => depStep.referenceId === stepReferenceId
                    );
                    if (depStepIdx > -1) {
                        step.dependentSteps.splice(depStepIdx, 1);
                    }
                }
            });
        }

        this.deleteStepDialogOpen = false;
    }

    handleDeleteWizardConfirm () {
        if (!this._pendingWizardToDelete) return;

        const dataIndex = this.getLocalWizardIndexByReferenceId(
            this._pendingWizardToDelete.referenceId
        );

        if (dataIndex > -1) {
            this.data.splice(dataIndex, 1);
            this.updateWizardSequences();
        }

        this.deleteWizardDialogOpen = false;
    }

    handleNewWizardConfigChanged (event) {
        const newWizard = event.detail.value;
        newWizard.isModified = true

        if (this.searchString) {
            this.clearWizardSearch();
        }

        this.data.push(Object.assign({}, newWizard));
        this.newWizardConfigOpen = false;

        this.wizardToScrollTo = newWizard.referenceId;
    }

    handleNewWizardConfigClosed () {
        this.newWizardConfigOpen = false;
    }

    handleWizardConfigChanged (event) {
        const wizard = event.detail.value;
        wizard.isModified = true

        const dataIndex = this.getLocalWizardIndexByReferenceId(
            wizard.referenceId
        );
        this.data.splice(dataIndex, 1, wizard);

        this.existingWizardConfigOpen = false;
    }

    handleWizardConfigClosed () {
        this.existingWizardConfigOpen = false;
    }

    handleStepConfigChanged (event) {
        const step = event.detail.value;
        step.isModified = true;

        const wizard = this.getLocalWizardByReferenceId(
            step.wizardReferenceId
        );

        const dataIndex = this.getLocalStepIndexByReferenceId(
            step.referenceId,
            wizard
        );

        wizard.steps.splice(dataIndex, 1, step);

        this.existingStepConfigOpen = false;
        this._dirty = true;
    }

    handleDeveloperNameChange (event) {
        const step = event.detail.value;
        step.isModified = true;

        const wizard = this.getLocalWizardByReferenceId(
            step.wizardReferenceId
        );

        const dataIndex = this.getLocalStepIndexByReferenceId(
            step.referenceId,
            wizard
        );

        wizard.steps.splice(dataIndex, 1, step);
    }

    handleStepConfigClosed () {
        this.existingStepConfigOpen = false;
    }

    handleCancelEdit () {
        this.navigateToListView();
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    handleReorderWizards () {
        this.reorderWizardOpen = true;
    }

    handleSave () {
        this.saveWizardData();
    }

    handleTabActive (event) {
        this.activeTab = event.target.value;
    }

    handleWizardOrderChange (event) {
        const orderedWizardValues = event.detail.value;

        for (let i = 0; i < orderedWizardValues.length; i++) {
            const wizard = this.getLocalWizardByReferenceId(
                orderedWizardValues[i]
            );

            if (wizard) {
                wizard.sequence = i + 1;
                wizard.isModified = true;
                this._dirty = true;
            }
        }

        this.handleWizardOrderClosed();
    }

    handleWizardOrderClosed () {
        this.reorderWizardOpen = false;
    }

    handleStepOrderChange (event) {
        const orderedStepValues = event.detail.value;

        for (let i = 0; i < orderedStepValues.length; i++) {
            const dataIndex = this._currentWizard.steps.findIndex(
                step => step.referenceId === orderedStepValues[i]
            );

            if (dataIndex > -1) {
                const step = this._currentWizard.steps[dataIndex];
                step.sequence = i + 1;
                step.isModified = true;
            }
        }

        if (this._currentWizard?.stepDependencyType === 'Checklist') {
            this.reconcileDependentSteps();
        }
        // Trigger render
        const wizardReferenceId = this._currentWizard.referenceId;
        const dataIndex = this.getLocalWizardIndexByReferenceId(
            wizardReferenceId
        );
        const wizard = this.getLocalWizardByReferenceId(wizardReferenceId);
        this.data.splice(dataIndex, 1, wizard);

        this.handleStepOrderClosed();
    }

    reconcileDependentSteps () {
        const stepSeqMap = this.getCurrentWizardStepSequenceMap();
        this._currentWizard.steps?.forEach(step => {
            const stepSeqValue = Number(stepSeqMap[step.referenceId]);
            step?.dependentSteps?.forEach((depStep, index, depSteps) => {
                const depStepSeqValue = Number(stepSeqMap[depStep.referenceId]);
                if ((depStepSeqValue > stepSeqValue)) {
                    depSteps.splice(index, 1);
                    this._dependentStepRemoved = true;
                }
            });
        });
    }

    getCurrentWizardStepSequenceMap () {
        return this._currentWizard?.steps?.reduce(( seqMap, step ) => {
            seqMap[step.referenceId] = step.sequence;
            return seqMap;
        }, {});
    }

    handleStepOrderClosed () {
        this.reorderStepsOpen = false;
        if (this._dependentStepRemoved) {
            this.reorderWarningStepDialogOpen = true;
            this._dependentStepRemoved = false;
        }
    }

    getLocalWizardIndexByReferenceId (referenceId) {
        return this.data.findIndex(
            wizard => wizard.referenceId === referenceId
        );
    }

    getLocalWizardByReferenceId (referenceId) {
        const dataIndex = this.getLocalWizardIndexByReferenceId(referenceId);

        if (dataIndex > -1) {
            return this.data[dataIndex];
        }

        return null;
    }

    getLocalStepIndexByReferenceId (referenceId, wizard) {
        return wizard.steps.findIndex(step => step.referenceId === referenceId);
    }

    getDependentStepReferenceId (depStepId, wizard) {
        return wizard.steps.filter(step => step.id === depStepId)[0]?.referenceId;
    }

    getLocalStepByReferenceId (referenceId, wizard) {
        const dataIndex = this.getLocalStepIndexByReferenceId(
            referenceId,
            wizard
        );

        if (dataIndex > -1) {
            const currentStep = wizard.steps[dataIndex];
            if (currentStep?.dependentSteps) {
                currentStep?.dependentSteps.forEach(depStep => {
                    if (!depStep.referenceId) {
                        // eslint-disable-next-line max-len
                        depStep.referenceId = this.getDependentStepReferenceId(depStep.dependentStepId, wizard);
                    }
                });
            }
            return currentStep;
        }

        return null;
    }

    getDeveloperNameForClone (wizardName) {
        let developerName = normalizeDeveloperName(wizardName);

        const matchingWizards = this.data.filter(wizard =>
            wizard.developerName.startsWith(developerName)
        );

        if (matchingWizards && matchingWizards.length > 0) {
            const matchCount = matchingWizards.length + 1;
            const developerNameMax = 40;

            const adjustedMaxLength =
                developerNameMax - matchCount.toString().length;

            developerName = developerName
                .substring(0, adjustedMaxLength)
                .concat(matchCount);
        }

        return developerName;
    }

    handleActivateWizard (event) {
        this.activateWizard(event.detail.value.referenceId, true);
    }

    handleCloneWizard (event) {
        const unproxiedData = getObservableObject.target(this.data);

        const stepReferenceMap = new Map();

        const sourceWizard = unproxiedData.find(
            wizard => wizard.id === event.detail.value.id
        );
        // console.log(`Source wizard: ${JSON.stringify(sourceWizard)}`)
        if (sourceWizard) {
            const clone = JSON.parse(JSON.stringify(sourceWizard));
            // const clone = Object.assign({}, sourceWizard);
            clone.name = sourceWizard.name + ' - ' + i18n.copy;
            clone.referenceId = guid();
            clone.id = null;
            clone.isModified = true;
            clone.lastModifiedDate = null;
            clone.lastModifiedBy = null;

            clone.developerName = this.getDeveloperNameForClone(clone.name);

            const sequence = clone.sequence ? clone.sequence + 1 : 1;
            clone.sequence = clone.active ? sequence : null;

            // Remove IDs from Steps
            if (clone.steps) {
                clone.steps = [...clone.steps];
                clone.steps.forEach(step => {
                    const stepReferenceId = guid();
                    if (step.id) {
                        stepReferenceMap.set(step.id, stepReferenceId);
                    }
                    step.id = null;
                    step.isModified = true;
                    step.lastModifiedDate = null;
                    step.lastModifiedBy = null;
                    step.referenceId = stepReferenceId;
                    step.developerName = null;
                    if (step.stepParameters) {
                        step.stepParameters.forEach(param => {
                            param.id = null;
                            param.isModified = true;
                            param.referenceId = guid();
                        })
                    }
                });
                if (stepReferenceMap.size > 0) {
                    clone.steps.forEach(step => {
                        if (step.dependentSteps) {
                            step.dependentSteps.forEach(depStep => {
                                const depStepId = depStep.dependentStepId;
                                depStep.referenceId = stepReferenceMap.get(depStepId);
                                depStep.dependentStepId = null;
                                depStep.id = null;
                                depStep.isModified = true;
                            })
                        }
                    });
                }
            }

            // Remove IDs from Access
            if (clone.access) {
                clone.access.forEach(access => {
                    access.id = null;
                    access.name = null;
                    access.isModified = true;
                    access.lastModifiedDate = null;
                    access.lastModifiedBy = null;
                });
            }

            const dataIndex = this.getLocalWizardIndexByReferenceId(sourceWizard.referenceId);
            this.data.splice(dataIndex + 1, 0, clone);
            this.updateWizardSequences();
        }
    }

    updateStepSequences (wizard) {
        wizard.steps.forEach((step, index) => {
            step.sequence = index + 1;
            step.isModified = true;
        });
    }

    updateWizardSequences () {
        if (!this.data || this.data.length === 0) return;
        // Set all inactive sequences to null.
        this.data.forEach(wizard => {
            if (!wizard.active) {
                wizard.sequence = null;
            }
        });

        // Get active wizards (which are ordered by sequence) and update their sequence
        this.activeWizards.forEach((wizard, index) => {
            wizard.sequence = index + 1;
            wizard.isModified = true;
        });
    }

    handleDeleteWizard (event) {
        this.deleteWizardDialogOpen = true;
        this._pendingWizardToDelete = event.detail.value;
    }

    handleInactivateWizard (event) {
        this.activateWizard(event.detail.value.referenceId, false);
    }

    handleReorderSteps (event) {
        this._currentWizard = this.getLocalWizardByReferenceId(
            event.detail.value.referenceId
        );
        this.reorderStepsOpen = true;
    }

    handleReorderWarningClose () {
        this.reorderWarningStepDialogOpen = false;
    }

    handleWizardProperties (event) {
        const configDialog = this.template.querySelector(
            '.existingWizardConfig'
        );

        configDialog.wizardRecord = this.getLocalWizardByReferenceId(
            event.detail.value.referenceId
        );

        this.existingWizardConfigOpen = true;
    }

    handleStepProperties (event) {
        const { wizardReferenceId, stepReferenceId } = event.detail;

        const configDialog = this.template.querySelector('.existingStepConfig');

        const wizard = this.getLocalWizardByReferenceId(wizardReferenceId);

        const wizardStep = this.getLocalStepByReferenceId(
            stepReferenceId,
            wizard
        );
        configDialog.processStepRecord = wizardStep;
        configDialog.wizardReferenceId = wizardReferenceId;
        configDialog.wizardDevName = wizard.developerName;
        configDialog.wizardStepDevNames = this.getWizardStepDeveloperNames(wizard);
        configDialog.showDependentStepFlag = wizard.stepDependencyType === 'Checklist';
        const currentStep = { referenceId: wizardStep.referenceId, sequence: wizardStep.sequence };
        // eslint-disable-next-line max-len
        configDialog.dependentStepsList = this.getDependentStepsList(currentStep, wizard);
        this.existingStepConfigOpen = true;
    }

    getWizardStepDeveloperNames (wizard) {
        const stepDeveloperNames = [];
        wizard?.steps?.forEach(step => {
            stepDeveloperNames.push({
                stepDevName: step?.developerName,
                stepReferenceId: step.referenceId
            });
        });
        return stepDeveloperNames;
    }

    activateWizard (wizardReferenceId, isActive) {
        const dataIndex = this.getLocalWizardIndexByReferenceId(
            wizardReferenceId
        );

        const wizard = this.getLocalWizardByReferenceId(wizardReferenceId);
        wizard.active = isActive;
        wizard.isModified = true;
        if (isActive) {
            wizard.sequence = this.nextWizardSequenceNumber;
        }

        this.data.splice(dataIndex, 1, wizard);
        this.updateWizardSequences();
    }

    navigateToListView () {
        handleMenuSelection(
            {
                detail: {
                    name: 'service_wizards',
                    targetType: 'LWC',
                    targetDeveloperName: 'c-wizard-admin-list-view'
                }
            },
            this
        );
    }

    saveWizardData () {
        if (this._dirty) {
            this.apiInProgress = true;
            this.data = [...this.data];
            const dataToSave = this.sanitizeDataForSave(this.data);

            const saveRequest = {
                wizards: dataToSave,
                objectAPINames: [this._objectApiName]
            };

            saveProcessWizards({
                requestJson: JSON.stringify(saveRequest)
            })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }

                    this.error = null;
                    this._dirty = false;
                    this.showSaveSuccessNotification();

                    // Notify Aura to clear unsaved changes in the 
                    //lightning:unsavedChanges component.
                    this.dispatchWizardDataSaved();

                    this.setViewData(result.data);
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                });
        }
    }

    sanitizeDataForSave (data) {
        const wizardStepDevNames = [];
        return data.map(wizard => {
            if (wizard.steps) {
                wizard.steps.forEach(step => {
                    delete step.wizardReferenceId;
                    delete step.targetLabel;
                    delete step.targetId;

                    if (step.stepParameters) {
                        step.stepParameters.forEach(param => {
                            delete param.isFieldMappingType;
                        })
                    }

                    if (!step.developerName) {
                        const stepDevRawString = wizard.developerName + ' ' + step.name;
                        step.developerName = this.getNewStepDeveloperName(
                            step,
                            wizardStepDevNames,
                            stepDevRawString,
                            140
                        );
                        step.isModified = true;
                    }
                    wizardStepDevNames.push(step);
                });
            }
            return wizard;
        });
    }

    getNewStepDeveloperName (step, wizardStepDevNames, stepName, maxLength) {
        let developerName = normalizeDeveloperName(stepName, maxLength, '');
        const matchingWizards = [];
        wizardStepDevNames.forEach(stepDevObj => {
            if (stepDevObj.developerName
                && stepDevObj.developerName.startsWith(developerName)
                && stepDevObj.referenceId !== step.referenceId) {
                matchingWizards.push(stepDevObj.developerName);
            }
        });
        if (matchingWizards && matchingWizards.length > 0) {
            const matchCount = matchingWizards.length + 1;
            const adjustedMaxLength = maxLength - matchCount.toString().length;
            developerName = developerName.substring(0, adjustedMaxLength).concat(matchCount);
        }

        return developerName;
    }

    getWizardElementByReference (referenceId) {
        return this.template.querySelector(`c-wizard[data-reference='${referenceId}']`);
    }

    scrollIntoViewIfNeeded (element, scrollingParent) {
        if (!element || !scrollingParent) return;

        const parentRect = scrollingParent.getBoundingClientRect();
        const findMeRect = element.getBoundingClientRect();
        if (findMeRect.top < parentRect.top) {
            if (element.offsetTop + findMeRect.height < parentRect.height) {
                scrollingParent.scrollTop = 0;
            } else {
                scrollingParent.scrollTop = element.offsetTop;
            }
        } else if (findMeRect.bottom > parentRect.bottom) {
            scrollingParent.scrollTop += findMeRect.bottom - parentRect.bottom;
        }

    }

    showSaveSuccessNotification () {
        const evt = new ShowToastEvent({
            title: `${this._objectLabel} ${this.i18n.wizards} ${this.i18n.wasSaved}`,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    async getObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

        return result;
    }

    handleSearchKeyChange (event) {
        const searchKey = event.detail.value;
        this.searchString = event.detail.value;
        if (searchKey &&
            (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.setWizardItemVisibility(searchKey);
                this.renderTemplateFlag = searchKey;
            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    // eslint-disable-next-line consistent-return
    setWizardItemVisibility (searchKey) {
        if (!this.data) {
            return undefined;
        }
        this.searchInProgress=true;
        const searchKeyLower = searchKey.toLowerCase();
        this.data?.forEach(wizard => {
            const wizardName = wizard?.name?.toLowerCase();
            const wizardDevName = wizard?.developerName.toLowerCase();
            const wizardMatch = (wizardName.includes(searchKeyLower) ||
                                    wizardDevName.includes(searchKeyLower));
            if (wizardMatch) {
                wizard.isVisible = true;
                wizard?.steps?.forEach(step => { step.isVisible=true;});
            } else {
                wizard.isVisible = false;
                wizard?.steps?.forEach(step => {
                    const stepName = step.name.toLowerCase();
                    const stepDevName = step.target.toLowerCase();
                    step.isVisible = stepName.includes(searchKeyLower) ||
                                        stepDevName.includes(searchKeyLower);
                });
                if (wizard?.steps?.filter(s => {return s.isVisible;})?.length > 0) {
                    wizard.isVisible = true;
                }
            }
        });
        this.setExpandedSections(searchKeyLower);
        this.searchInProgress=false;
    }

    setExpandedSections (searchKey) {
        this.expandedSections = '';
        const currentSearchResult = this.data.filter((wizard) => {
            if (this.activeTab === TAB_TYPES.ACTIVE) {
                return wizard.isVisible && wizard.active;
            }
            return wizard.isVisible && !wizard.active;
        });
        const wizardTotalCount = (this.activeTab === TAB_TYPES.ACTIVE)
            ? this.totalActiveWizardCount
            : this.totalInactiveWizardCount;

        if (currentSearchResult?.length <= wizardTotalCount && searchKey?.length > 0) {
            this.expandedSections = this.data.reduce((result, value) => {
                if (value.isVisible) {
                    result.push(value.name);
                }
                return result;
            }, []);
        }
    }

    clearWizardSearch () {
        const searchInput = this.template.querySelector('.search-input');
        if (searchInput) {
            searchInput.value = '';
        }
        this.searchString = '';
        this.setWizardItemVisibility(this.searchString);
    }

    getDependentStepsList (currentStep, wizard) {
        const dependentStepsList = new Array();
        wizard?.steps?.forEach(step => {
            if (step.referenceId !== currentStep.referenceId
                && Number(currentStep.sequence) > Number(step.sequence)) {
                let cyclicDependencyFlag = false;
                step?.dependentSteps?.forEach(dependentStep => {
                    if (currentStep.referenceId === dependentStep.referenceId) {
                        cyclicDependencyFlag = true;
                    }
                });
                if (!cyclicDependencyFlag) {
                    dependentStepsList.push({ label: step.name, value: step.referenceId });
                }
            }
        });
        return dependentStepsList;
    }

    getChildStepByDependentStepId () {
        const {
            wizardReferenceId,
            stepReferenceId
        } = this._pendingStepToDelete;
        if (wizardReferenceId && stepReferenceId) {
            const wizard = this.getLocalWizardByReferenceId(wizardReferenceId);

            this._childStepList = wizard?.steps?.filter(step => {
                let depArray = [];
                // eslint-disable-next-line max-len
                depArray = step?.dependentSteps?.filter(depStep => depStep.referenceId === stepReferenceId);
                return depArray?.length > 0 ? true : false;
            });
        }
    }
}