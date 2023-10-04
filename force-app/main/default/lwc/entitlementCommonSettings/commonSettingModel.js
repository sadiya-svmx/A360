export class commonSettingModel {
    id;
    _assignEntitledService;
    _assignPricebook;
    _adjustServiceThreshold;
    _adjustVisitCountAssignedObject;
    _inheritServiceOnReturnOrder;
    _inheritServiceOnWorkOrder;
    _applyStackRanking;
    _contractStackRankingAPIName;
    _contractStackRankingOrder;
    _warrantyStackRankingAPIName;
    _warrantyStackRankingOrder;

    _isDirty = false;

    constructor (entitledSetting) {
        if (entitledSetting) {
            this.id = entitledSetting.id;
            this._assignEntitledService = entitledSetting.assignEntitledService;
            this._assignPricebook = entitledSetting.assignPricebook;
            this._adjustServiceThreshold = entitledSetting.adjustServiceThreshold;
            this._adjustVisitCountAssignedObject = entitledSetting.adjustVisitCountAssignedObject;
            this._inheritServiceOnReturnOrder = entitledSetting.inheritServiceOnReturnOrder;
            this._inheritServiceOnWorkOrder = entitledSetting.inheritServiceOnWorkOrder;
            this._applyStackRanking = entitledSetting.applyStackRanking;
            this._contractStackRankingAPIName = entitledSetting.contractStackRankingAPIName;
            this._contractStackRankingOrder = entitledSetting.contractStackRankingOrder;
            this._warrantyStackRankingAPIName = entitledSetting.warrantyStackRankingAPIName;
            this._warrantyStackRankingOrder = entitledSetting.warrantyStackRankingOrder;
        }
    }

    get assignEntitledService () {
        return this._assignEntitledService;
    }

    set assignEntitledService (value) {
        if (value !== this._assignEntitledService) {
            this._assignEntitledService = value;
            this._isDirty = true;
        }
    }

    get assignPricebook () {
        return this._assignPricebook;
    }

    set assignPricebook (value) {
        if (value !== this._assignPricebook) {
            this._assignPricebook = value;
            this._isDirty = true;
        }
    }

    get adjustServiceThreshold () {
        return this._adjustServiceThreshold;
    }

    set adjustServiceThreshold (value) {
        if (value !== this._adjustServiceThreshold) {
            this._adjustServiceThreshold = value;
            this._isDirty = true;
        }
    }

    get adjustVisitCountAssignedObject () {
        return this._adjustVisitCountAssignedObject;
    }

    set adjustVisitCountAssignedObject (value) {
        if (value !== this._adjustVisitCountAssignedObject) {
            this._adjustVisitCountAssignedObject = value;
            this._isDirty = true;
        }
    }

    get inheritServiceOnReturnOrder () {
        return this._inheritServiceOnReturnOrder;
    }

    set inheritServiceOnReturnOrder (value) {
        if (value !== this._inheritServiceOnReturnOrder) {
            this._inheritServiceOnReturnOrder = value;
            this._isDirty = true;
        }
    }

    get inheritServiceOnWorkOrder () {
        return this._inheritServiceOnWorkOrder;
    }

    set inheritServiceOnWorkOrder (value) {
        if (value !== this._inheritServiceOnWorkOrder) {
            this._inheritServiceOnWorkOrder = value;
            this._isDirty = true;
        }
    }

    get applyStackRanking () {
        return this._applyStackRanking;
    }

    set applyStackRanking (value) {
        if (value !== this._applyStackRanking) {
            this._applyStackRanking = value;
            this._isDirty = true;
        }
    }

    get contractStackRankingAPIName () {
        return this._contractStackRankingAPIName;
    }

    set contractStackRankingAPIName (value) {
        if (value !== this._contractStackRankingAPIName) {
            this._contractStackRankingAPIName = value;
            this._isDirty = true;
        }
    }

    get contractStackRankingOrder () {
        return this._contractStackRankingOrder;
    }

    set contractStackRankingOrder (value) {
        if (value !== this._contractStackRankingOrder) {
            this._contractStackRankingOrder = value;
            this._isDirty = true;
        }
    }

    get warrantyStackRankingAPIName () {
        return this._warrantyStackRankingAPIName;
    }

    set warrantyStackRankingAPIName (value) {
        if (value !== this._warrantyStackRankingAPIName) {
            this._warrantyStackRankingAPIName = value;
            this._isDirty = true;
        }
    }

    get warrantyStackRankingOrder () {
        return this._warrantyStackRankingOrder;
    }

    set warrantyStackRankingOrder (value) {
        if (value !== this._warrantyStackRankingOrder) {
            this._warrantyStackRankingOrder = value;
            this._isDirty = true;
        }
    }
}