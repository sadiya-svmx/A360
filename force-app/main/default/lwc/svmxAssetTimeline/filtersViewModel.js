export class FiltersViewModel {
    _typesToShow = [];
    _startDate;
    _endDate;
    _isDirty = false;

    constructor (typesToShow, startDate, endDate) {
        this._typesToShow = typesToShow;
        this._startDate = startDate;
        this._endDate = endDate;
    }

    get isDirty () {
        return this._isDirty;
    }
    set isDirty (value) {
        this._isDirty = value;
    }

    get typesToShow () {
        return this._typesToShow;
    }

    set typesToShow (value) {
        if (value !== this._typesToShow) {
            this._typesToShow = value;
            this.isDirty = true;
        }
    }

    get startDate () {
        return this._startDate;
    }

    set startDate (value) {
        if (!this.datesOnlyEqual(value, this._startDate)) {
            this._startDate = value;
            this.isDirty = true;
        }
    }

    get endDate () {
        return this._endDate;
    }

    set endDate (value) {
        if (!this.datesOnlyEqual(value, this._endDate)) {
            this._endDate = value;
            this.isDirty = true;
        }
    }

    isDate (value) {
        return (
            Object.prototype.toString.call(value) === '[object Date]' &&
            !isNaN(value.getTime())
        );
    }

    datesOnlyEqual (date1, date2) {
        const date1IsDate = this.isDate(date1);
        const date2IsDate = this.isDate(date2);

        const day1 = date1IsDate ? date1.getUTCDate() : null;
        const month1 = date1IsDate ? date1.getUTCMonth() : null;
        const year1 = date1IsDate ? date1.getUTCFullYear() : null;

        const day2 = date2IsDate ? date2.getUTCDate() : null;
        const month2 = date2IsDate ? date2.getUTCMonth() : null;
        const year2 = date2IsDate ? date2.getUTCFullYear() : null;

        return day1 === day2 && month1 === month2 && year1 === year2;
    }
}