import { normalizeDeveloperName, areObjectsEqual } from 'c/utils';

const DEFAULT_PRICEBOOK = {
    id: '',
    name: undefined
}

export class RuleModel {

    id;

    _name = '';
    _developerName ;
    _description = '';
    _isRuleActive = true;
    _isDirty = false;
    _qualifyingCriteria = [{}];
    _objectLabel = '';
    _objectAPIName = '';
    _pricebook = DEFAULT_PRICEBOOK;
    _sequence;

    constructor (ruleRecord, entityDefintion) {
        this._isDirty = false;
        if (entityDefintion) {
            this._objectLabel = entityDefintion.label;
            this._objectAPIName = entityDefintion.value;
        }
        if (ruleRecord) {
            this.id = ruleRecord.id;
            this._name = ruleRecord.name;
            this._description = ruleRecord.description;
            this._isRuleActive = ruleRecord.active || false;
            this._developerName = ruleRecord.developerName;
            this._sequence = ruleRecord.sequence;
            this._pricebook = ruleRecord.pricebook ? ruleRecord.pricebook : DEFAULT_PRICEBOOK;
            if (ruleRecord.qualifyingCriteria) {
                this._qualifyingCriteria = ruleRecord.qualifyingCriteria;
            } else {
                this._qualifyingCriteria = [{}];
            }
        }
    }

    get name () {
        return this._name;
    }

    set name (value) {
        if (value !== this._name) {
            this._name = value;
            this._isDirty = true;
        }
    }

    get developerName () {
        return this._developerName;
    }

    set developerName (value) {
        if (value !== this._developerName) {
            this._developerName = value;
            this._isDirty = true;
        }
    }

    get description () {
        return this._description;
    }

    set description (value) {
        if (value !== this._description) {
            this._description = value;
            this._isDirty = true;
        }
    }

    get isRuleActive () {
        return this._isRuleActive;
    }

    set isRuleActive (value) {
        if (value !== this._isRuleActive) {
            this._isRuleActive = value;
            this._isDirty = true;
        }
    }

    get isDirty () {
        return this._isDirty;
    }

    set isDirty (value) {
        if (value !== this._iisDirty) {
            this._isDirty = value;
        }
    }

    get qualifyingCriteria () {
        return this._qualifyingCriteria;
    }

    set qualifyingCriteria (value) {
        if (value !== this._qualifyingCriteria) {
            this._qualifyingCriteria = value;
            this._isDirty = true;
        }
    }

    get objectLabel () {
        return this._objectLabel;
    }

    get objectAPIName () {
        return this._objectAPIName;
    }

    set objectAPIName (value) {
        if (value !== this._objectAPIName) {
            this._objectAPIName = value;
            this._isDirty = true;
        }
    }

    get pricebook () {
        return this._pricebook;
    }

    set pricebook (value) {
        if (!areObjectsEqual(value, this._pricebook)) {
            this._pricebook = value;
            this._isDirty = true;
        }
    }

    get pricebookName () {
        return this._pricebook ? this._pricebook.name : '';
    }

    getRecordData () {
        return {
            id: this.id || null,
            name: this.name,
            description: this.description,
            active: this.isRuleActive || false,
            developerName: this.developerName,
            objectAPIName: this._objectAPIName,
            qualifyingCriteria: this._qualifyingCriteria,
            sequence: this._sequence,
            pricebook: this._pricebook,
        }
    }

    markAsClone (namePrefix) {
        this._name = namePrefix + ' ' + this._name;
        this.id = null;
        this._sequence = null;
        this._developerName = normalizeDeveloperName(this._name);
        if (this._qualifyingCriteria) {
            this._qualifyingCriteria.id = null;
            this._qualifyingCriteria.developerName = this._developerName;
            if (this._qualifyingCriteria.expressionDetailList
                && this._qualifyingCriteria.expressionDetailList.length > 0) {
                this._qualifyingCriteria.expressionDetailList.forEach(expressionDetail => {
                    expressionDetail.id = null;
                });
            }

        }
    }

}