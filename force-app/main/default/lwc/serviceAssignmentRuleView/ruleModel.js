import { normalizeDeveloperName } from 'c/utils';

export class ruleModel {
    id;
    _name = '';
    _developerName;
    _objectLabel = '';
    _objectAPIName ='';
    _description;
    _active = true;
    _qualifyingCriteria;
    _product = {};
    _isDirty = false;
    _sequence;

    constructor (ruleRecord, objectDefinition) {
        if (objectDefinition) {
            this._objectLabel = objectDefinition.label;
            this._objectAPIName = objectDefinition.apiName;
        }
        this._qualifyingCriteria = [];
        if (ruleRecord) {
            this.id = ruleRecord.id;
            this._name = ruleRecord.name;
            this._description = ruleRecord.description;
            this._active = ruleRecord.active || false;
            this._developerName = ruleRecord.developerName;
            this._sequence = ruleRecord.sequence;
            this._product = ruleRecord.product || {};
            if (ruleRecord.qualifyingCriteria) {
                this._qualifyingCriteria = ruleRecord.qualifyingCriteria;
            }
        }
    }

    get isDirty () {
        return this._isDirty;
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

    get objectLabel () {
        return this._objectLabel;
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

    get active () {
        return this._active;
    }
    set active (value) {
        if (value !== this._active) {
            this._active = value;
            this._isDirty = true;
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

    get product () {
        return this._product;
    }
    set product (value) {
        if (value !== this._product) {
            this._product = value;
            this._isDirty = true;
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
            this._qualifyingCriteria.expressionDetailList.forEach(expressionDetail => {
                expressionDetail.id = null;
            });
        }
    }

    getRecordData () {
        const record = {
            id: this.id || null,
            name: this.name,
            description: this.description,
            active: this.active || false,
            developerName: this.developerName,
            objectAPIName: this._objectAPIName,
            sequence: this._sequence,
            product: this.product || {}
        }
        return record;
    }
}