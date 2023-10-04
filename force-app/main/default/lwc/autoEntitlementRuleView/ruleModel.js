import { normalizeDeveloperName } from 'c/utils';

export class ruleModel {
        id;
        _name = '';
        _developerName ;
        _defaultBillingType = '';
        _coveredBy = 'Account';
        _objectLabel = '';
        _objectAPIName ='';
        _description;
        _isActive = true;
        _resolutionMethod;
        _includeRootAsset;
        _includeParentAsset;
        _matchAccount;
        _accountAPIName;
        _assetAPIName;
        _expression;
        _sequence;
        _warrantyTypes;
        _whatToCheck = [];
        _isDirty = false;

        constructor (ruleRecord, objectDefintion) {
            if (objectDefintion) {
                this._objectLabel = objectDefintion.label;
                this._objectAPIName = objectDefintion.apiName;
            }

            this._expression = [];
            if (ruleRecord) {
                this.id = ruleRecord.id;
                this._name = ruleRecord.name;
                this._coveredBy = ruleRecord.coveredBy;
                this._description = ruleRecord.description;
                this._isActive = ruleRecord.isActive || false;
                this._resolutionMethod = ruleRecord.resolutionMethod;
                this._includeRootAsset = ruleRecord.includeRootAsset;
                this._includeParentAsset = ruleRecord.includeParentAsset;
                this._matchAccount = ruleRecord.matchAccount;
                this._developerName = ruleRecord.developerName;
                this._accountAPIName = ruleRecord.accountAPIName;
                this._assetAPIName = ruleRecord.assetAPIName;
                this._sequence = ruleRecord.sequence;
                this._warrantyTypes = ruleRecord.warrantyTypes;
                this._defaultBillingType = ruleRecord.defaultBillingType;
                if (ruleRecord.checkWarranties) {
                    this._whatToCheck.push('warranty');
                }
                if (ruleRecord.checkContracts) {
                    this._whatToCheck.push('contract');
                }
                if (ruleRecord.expression) {
                    this._expression = ruleRecord.expression;
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

        get defaultBillingType () {
            return this._defaultBillingType;
        }

        set defaultBillingType (value) {
            if (value !== this._defaultBillingType) {
                this._defaultBillingType = value;
                this._isDirty = true;
            }
        }

        get objectLabel () {
            return this._objectLabel;
        }

        get coveredBy () {
            return this._coveredBy;
        }
        set coveredBy (value) {
            if (value !== this._coveredBy) {
                this._coveredBy = value;
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

        get isActive () {
            return this._isActive;
        }
        set isActive (value) {
            if (value !== this._isActive) {
                this._isActive = value;
                this._isDirty = true;
            }
        }

        get whatToCheck () {
            return this._whatToCheck;
        }
        set whatToCheck (value) {
            if (value !== this._whatToCheck) {
                this._whatToCheck = value;
                this._isDirty = true;
            }
        }

        get matchAccount () {
            return this._matchAccount;
        }
        set matchAccount (value) {
            if (value !== this._matchAccount) {
                this._matchAccount = value;
                this._isDirty = true;
            }
        }

        get resolutionMethod () {
            return this._resolutionMethod;
        }
        set resolutionMethod (value) {
            if (value !== this._resolutionMethod) {
                this._resolutionMethod = value;
                this._isDirty = true;
            }
        }

        get includeRootAsset () {
            return this._includeRootAsset;
        }
        set includeRootAsset (value) {
            if (value !== this._includeRootAsset) {
                this._includeRootAsset = value;
                this._isDirty = true;
            }
        }

        get includeParentAsset () {
            return this._includeParentAsset;
        }
        set includeParentAsset (value) {
            if (value !== this._includeParentAsset) {
                this._includeParentAsset = value;
                this._isDirty = true;
            }
        }

        get accountAPIName () {
            return this._accountAPIName;
        }
        set accountAPIName (value) {
            if (value !== this._accountAPIName) {
                this._accountAPIName = value;
                this._isDirty = true;
            }
        }

        get assetAPIName () {
            return this._assetAPIName;
        }
        set assetAPIName (value) {
            if (value !== this._assetAPIName) {
                this._assetAPIName = value;
                this._isDirty = true;
            }
        }

        get expression () {
            return this._expression;
        }
        set expression (value) {
            if (value !== this._expression) {
                this._expression = value;
                this._isDirty = true;
            }
        }

        get warrantyTypes () {
            return this._warrantyTypes;
        }
        set warrantyTypes (value) {
            if (value !== this._warrantyTypes) {
                this._warrantyTypes = value;
                this._isDirty = true;
            }
        }

        markAsClone (namePrefix) {
            this._name = namePrefix + ' ' + this._name;
            this.id = null;
            this._sequence = null;
            this._developerName = normalizeDeveloperName(this._name);
            if (this._expression) {
                this._expression.id = null;
                this._expression.developerName = this._developerName;
                this._expression.expressionDetailList.forEach(expressionDetail => {
                    expressionDetail.id = null;
                });
            }
        }

        getRecordData () {

            const record = {
                id: this.id || null,
                name: this.name,
                coveredBy: this.coveredBy,
                description: this.description,
                defaultBillingType: this._defaultBillingType,
                isActive: this.isActive || false,
                checkContracts: this._whatToCheck.includes('contract') || false,
                checkWarranties: this._whatToCheck.includes('warranty') || false,
                resolutionMethod: this.resolutionMethod,
                includeRootAsset: this.includeRootAsset || false,
                includeParentAsset: this.includeParentAsset || false,
                matchAccount: this.matchAccount || false,
                developerName: this.developerName,
                objectAPIName: this._objectAPIName,
                accountAPIName: this._accountAPIName,
                assetAPIName: this._assetAPIName,
                sequence: this._sequence,
                warrantyTypes: this._warrantyTypes,
            }

            return record;
        }
}