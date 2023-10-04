export class lookupModel {

    id;
    _lookupName = '';
    _developerName ;
    _coveredBy = '';
    _objectLabel = '';
    _objectAPIName ='';
    _description;
    _objectFields;
    _searchFields;
    _displayFields;
    _fieldToReturn;
    _numberOfRecords;
    _expressionId;

    constructor (lookupRecord, fieldDefinitions) {
        if (fieldDefinitions) {
            this._fieldDetails = fieldDefinitions;
        }

        if (lookupRecord) {
            this.id = lookupRecord.id;
            this._lookupName = lookupRecord.name;
            this._objectAPIName = lookupRecord.objectAPIName;
            this._description = lookupRecord.description;
            this._developerName = lookupRecord.developerName;
            this._numberOfRecords = "" + lookupRecord.recordsPerPage;
            this._fieldToReturn = lookupRecord.fieldToReturn;
            this._expressionId = lookupRecord.basicFilterId;
            if (lookupRecord.searchFields) {
                this._searchFields = lookupRecord.searchFields.split(",");
            }

            if (lookupRecord.displayFields) {
                this._displayFields = lookupRecord.displayFields.split(",");
            }

            if (lookupRecord.expression) {
                this._expression = lookupRecord.expression;
            }
        }
    }

    get recordData () {

        return {
            id: this.id,
            name: this.lookupName,
            developerName: this.developerName,
            description: this.description,
            basicFilterId: this.expressionId,
            defaultLookup: true,
            displayFields: this.displayFields.join(","),
            searchFields: this.searchFields.join(","),
            extendedFields: "",
            fieldToReturn: this.fieldToReturn,
            objectAPIName: this.objectAPIName,
            defaultOperator: "",
            recordsPerPage: this.numberOfRecords
        };

    }

    get lookupName () {
        return this._lookupName;
    }

    set lookupName (value) {
        if (value !== this._lookupName) {
            this._lookupName = value;
            this._isDirty = true;
        }
    }

    set description (descriptionValue) {
        if (descriptionValue !== this._description) {
            this._description = descriptionValue;
            this._isDirty = true;
        }
    }

    get description () {
        return this._description;
    }

    set objectAPIName (value) {
        if (value !== this._developerName) {
            this._objectAPIName = value;
            this._isDirty = true;
        }
    }

    get objectAPIName () {
        return this._objectAPIName;
    }

    set developerName (value) {
        if (value !== this._developerName) {
            this._developerName = value;
            this._isDirty = true;
        }
    }

    get developerName () {
        return this._developerName;
    }

    set lookupRecord (record) {
        this._lookupRecord = record;
    }

    get lookupRecord () {
        return this._lookupRecord;
    }

    set fieldDetails (fieldDefinitions) {
        this._fieldDetails = fieldDefinitions;
    }

    get fieldDetails () {
        return  this._fieldDetails;
    }

    set searchFields (searchFields) {
        this._searchFields = searchFields;
    }

    get searchFields () {
        return  this._searchFields;
    }

    set displayFields (displayFields) {
        this._displayFields = displayFields;
    }

    get displayFields () {
        return  this._displayFields;
    }

    set fieldToReturn (selectedField) {
        if (selectedField !== this._fieldToReturn) {
            this._fieldToReturn = selectedField;
            this._isDirty = true;
        }
    }

    get fieldToReturn () {
        return  this._fieldToReturn;
    }

    get numberOfRecords () {
        return  this._numberOfRecords;
    }

    set numberOfRecords (noOfrecords) {
        this._numberOfRecords = noOfrecords;
    }

    get expressionId () {
        return  this._expressionId;
    }

    set expressionId (value) {
        if (value !== this._expressionId) {
            this._expressionId = value;
            this._isDirty = true;
        }
    }
}