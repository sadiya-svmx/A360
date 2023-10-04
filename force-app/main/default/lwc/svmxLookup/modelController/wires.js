import {
    isReferenceField,
    formatString,
    StaticallyComparable
} from 'c/utils';

export default class WiresModelController extends StaticallyComparable {
    handleWiredContextObjectInfo ({ error: e, data: objectDefinition }) {
        const error = e;

        if (!error && objectDefinition?.fields) {
            // Find the context object name fields
            this.mc('schema').contextDefaultNameFields = objectDefinition.nameFields;
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }

    handleWiredLookupConfigRecords ({ error: e, data: lookupConfig }) {
        const error = e;

        if (!error && lookupConfig) {
            this.mc('staticConfig').lookupConfig = lookupConfig;
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }

    handleWiredLookupContextRecord ({ error: e, data: lookupContextRecord }) {
        const error = e;

        if (!error && lookupContextRecord) {
            this.mc('contextSearch').contextRecord = lookupContextRecord;
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }

    handleWiredObjectInfo ({ error: e, data: objectDefinition }) {
        let error = e;

        if (!error && objectDefinition && objectDefinition.fields) {
            // Find and validate the target lookup field
            if (this.mc('schema').fieldApiName) {
                // TODO: Worth it to add case sensitivity support for field api?
                const fieldDefinition = objectDefinition.fields[this.mc('schema').fieldApiName];

                // Validate field api
                if (!fieldDefinition) {
                    error = new Error(formatString(
                        this.mc('ui').i18n.invalidFieldApi,
                        this.mc('schema').fieldApiName
                    ));
                }

                // Validate field data type
                if (!isReferenceField(fieldDefinition)) {
                    error = new Error(formatString(
                        this.mc('ui').i18n.notAReference,
                        this.mc('schema').fieldApiName
                    ));
                }

                // Store field definition
                this.mc('schema').fieldDefinition = fieldDefinition;
            }
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }

    handleWiredTargetObjectInfo ({ error: e, data: objectDefinition }) {
        let error = e;

        if (!error && objectDefinition) {
            try {
                this.mc('schema').targetObjectDefinition = objectDefinition;
            } catch (err) {
                error = err;
            }
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }

    handleWiredSelectionRecord ({ error: e, data: selectionRecord }) {
        const error = e;

        if (!error && selectionRecord) {
            this.mc('selection').selectionRecord = selectionRecord;
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }

    handleWiredSearchResultRecords ({ error: e, data: recordUIResponse }) {
        const error = e;

        if (!error && recordUIResponse) {
            this.mc('results').searchResultRecords = Object.values(recordUIResponse.records);
        }

        if (error) {
            this.mc('utils').handleError(error);
        }
    }
}