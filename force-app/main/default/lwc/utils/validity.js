import labelBadInput from '@salesforce/label/c.Validity_BadInput';
import labelPatternMismatch from '@salesforce/label/c.Validity_PatternMismatch';
import labelRangeOverflow from '@salesforce/label/c.Validity_RangeOverflow';
import labelRangeUnderflow from '@salesforce/label/c.Validity_RangeUnderflow';
import labelStepMismatch from '@salesforce/label/c.Validity_StepMismatch';
import labelTooLong from '@salesforce/label/c.Validity_TooLong';
import labelTooShort from '@salesforce/label/c.Validity_TooShort';
import labelTypeMismatch from '@salesforce/label/c.Validity_TypeMismatch';
import labelValueMissing from '@salesforce/label/c.Validity_ValueMissing';

const constraintsSortedByPriority = [
    'customError',
    'badInput',
    'patternMismatch',
    'rangeOverflow',
    'rangeUnderflow',
    'stepMismatch',
    'tooLong',
    'tooShort',
    'typeMismatch',
    'valueMissing'
];

const defaultLabels = {
    badInput: labelBadInput,
    customError: labelBadInput,
    patternMismatch: labelPatternMismatch,
    rangeOverflow: labelRangeOverflow,
    rangeUnderflow: labelRangeUnderflow,
    stepMismatch: labelStepMismatch,
    tooLong: labelTooLong,
    tooShort: labelTooShort,
    typeMismatch: labelTypeMismatch,
    valueMissing: labelValueMissing
};

function resolveBestMatch (validity) {
    let validityState;
    if (validity && validity.valid === false) {
        validityState = 'badInput';
        constraintsSortedByPriority.some((stateName) => {
            if (validity[stateName] === true) {
                validityState = stateName;
                return true;
            }
            return false;
        });
    }
    return validityState;
}

function computeConstraint (valueProvider, constraint) {
    const provider = valueProvider[constraint];
    if (typeof provider === 'function') {
        return provider();
    }
    if (typeof provider === 'boolean') {
        return provider;
    }
    return false;
}

function newValidityState (constraintsProvider) {
    class ValidityState {
        get valueMissing () {
            return computeConstraint(constraintsProvider, 'valueMissing');
        }

        get typeMismatch () {
            return computeConstraint(constraintsProvider, 'typeMismatch');
        }

        get patternMismatch () {
            return computeConstraint(constraintsProvider, 'patternMismatch');
        }

        get tooLong () {
            return computeConstraint(constraintsProvider, 'tooLong');
        }

        get tooShort () {
            return computeConstraint(constraintsProvider, 'tooShort');
        }

        get rangeUnderflow () {
            return computeConstraint(constraintsProvider, 'rangeUnderflow');
        }

        get rangeOverflow () {
            return computeConstraint(constraintsProvider, 'rangeOverflow');
        }

        get stepMismatch () {
            return computeConstraint(constraintsProvider, 'stepMismatch');
        }

        get customError () {
            return computeConstraint(constraintsProvider, 'customError');
        }

        get badInput () {
            return computeConstraint(constraintsProvider, 'badInput');
        }

        get valid () {
            return !(
                this.valueMissing ||
                this.typeMismatch ||
                this.patternMismatch ||
                this.tooLong ||
                this.tooShort ||
                this.rangeUnderflow ||
                this.rangeOverflow ||
                this.stepMismatch ||
                this.customError ||
                this.badInput
            );
        }
    }

    return new ValidityState();
}

export function buildSyntheticValidity (constraintProvider) {
    return Object.freeze(newValidityState(constraintProvider));
}

export function getErrorMessage (validity, labelMap) {
    const key = resolveBestMatch(validity);
    if (key) {
        return labelMap[key] ? labelMap[key] : defaultLabels[key];
    }
    return '';
}

export class FieldConstraintApi {
    constructor (inputComponentProvider, constraintProviders) {
        this._inputComponentProvider = inputComponentProvider;
        this._constraintsProvider = Object.assign({}, constraintProviders);
        if (!this._constraintsProvider.customError) {
            this._constraintsProvider.customError = () =>
                typeof this._customValidityMessage === 'string' &&
                this._customValidityMessage !== '';
        }
    }

    get validity () {
        if (!this._constraint) {
            this._constraint = buildSyntheticValidity(
                this._constraintsProvider
            );
        }

        return this._constraint;
    }

    checkValidity () {
        const isValid = this.validity.valid;
        if (!isValid) {
            if (this.inputComponent) {
                this.inputComponent.dispatchEvent(
                    new CustomEvent('invalid', { cancellable: true })
                );
            }
        }
        return isValid;
    }

    reportValidity (callback) {
        const valid = this.checkValidity();

        if (this.inputComponent) {
            this.inputComponent.classList.toggle('slds-has-error', !valid);

            if (callback) {
                callback(this.validationMessage);
            }
        }

        return valid;
    }

    setCustomValidity (message) {
        this._customValidityMessage = message;
    }

    get validationMessage () {
        return getErrorMessage(this.validity, {
            customError: this._customValidityMessage,
            badInput: this.inputComponent.messageWhenBadInput,
            patternMismatch: this.inputComponent.messageWhenPatternMismatch,
            rangeOverflow: this.inputComponent.messageWhenRangeOverflow,
            rangeUnderflow: this.inputComponent.messageWhenRangeUnderflow,
            stepMismatch: this.inputComponent.messageWhenStepMismatch,
            tooShort: this.inputComponent.messageWhenTooShort,
            tooLong: this.inputComponent.messageWhenTooLong,
            typeMismatch: this.inputComponent.messageWhenTypeMismatch,
            valueMissing: this.inputComponent.messageWhenValueMissing
        });
    }

    get inputComponent () {
        if (!this._inputComponentElement) {
            this._inputComponentElement = this._inputComponentProvider();
        }
        return this._inputComponentElement;
    }
}