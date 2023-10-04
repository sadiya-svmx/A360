import {
    FIELD_DATA_TYPES,
    OPERATOR_TYPES,
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    DATE_TIME_FUNCTION_LITERALS,
    getRelationshipFieldValue
} from 'c/utils';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import messageInvalidException from '@salesforce/label/c.Message_InvalidExpressionError';

const STRING_VAR = [
    FIELD_DATA_TYPES.STRING,
    FIELD_DATA_TYPES.COMBOBOX,
    FIELD_DATA_TYPES.REFERENCE,
    FIELD_DATA_TYPES.EMAIL,
    FIELD_DATA_TYPES.PICKLIST,
    FIELD_DATA_TYPES.MULTIPICKLIST,
    FIELD_DATA_TYPES.TEXTAREA,
    FIELD_DATA_TYPES.PHONE,
    FIELD_DATA_TYPES.ID,
    FIELD_DATA_TYPES.URL
];
const TIME_VAR = [
    FIELD_DATA_TYPES.TIME
];
const NUMBER_VAR = [
    FIELD_DATA_TYPES.CURRENCY,
    FIELD_DATA_TYPES.LOCATION,
    FIELD_DATA_TYPES.DOUBLE,
    FIELD_DATA_TYPES.PERCENT,
    FIELD_DATA_TYPES.INTEGER
];
const DATE_VAR = [FIELD_DATA_TYPES.DATE];
const DATETIME_VAR = [FIELD_DATA_TYPES.DATETIME];

const LOGICAL_OPERATORS = {
    AND: 'AND',
    OR: 'OR',
    LOGICAL_AND: '&&',
    LOGICAL_OR: '||'
};


export class SvmxExpressionValidator {
    expressionDetails;
    userTimeZone = TIME_ZONE;
    userFieldVal;
    userLiteralCheck;

    loadExpressions (expressions) {
        this.expressionDetails = expressions;
    }

    validateExpression (objRecord, expressionId, userRec) {
        const expressionResults = {};
        let returnVal = null;
        try {
            if (expressionId) {
                const expression = this.expressionDetails[expressionId];
                let simulatedAdvancedExpression = '';
                let expressionDetailCounter = 1;
                expression.expressionDetailList.forEach(criteria => {
                    this.validateExpressionForErrors(criteria);
                    if (expressionDetailCounter === 1) {
                        simulatedAdvancedExpression += expressionDetailCounter.toString();
                    } else {
                        simulatedAdvancedExpression += ' ' +
                            LOGICAL_OPERATORS.AND+ ' ' +expressionDetailCounter;
                    }
                    expressionDetailCounter++;
                    let fieldVal = null;
                    const operator = criteria.operator;
                    const sequence = criteria.sequence;
                    this.userLiteralCheck = criteria.operandType.toLowerCase() === 'function' &&
                                                criteria.operand.toLowerCase() === 'user';
                    fieldVal = (criteria.sourceObjectName
                        && criteria?.sourceObjectName?.toLowerCase() === 'user')
                        ? this.getFieldValue(criteria, userRec)
                        : this.getFieldValue(criteria, objRecord);
                    if (this.userLiteralCheck) {
                        const literalParamApiName = criteria.literalParameterAPIName;
                        const lastindex = literalParamApiName.lastIndexOf('.');
                        const fieldAPIName = literalParamApiName.substring(lastindex+1);
                        const relationshipName = literalParamApiName.substring(0,lastindex);
                        this.userFieldVal = getRelationshipFieldValue(
                            relationshipName,
                            fieldAPIName,
                            userRec);
                    }
                    switch (operator) {
                        case OPERATOR_TYPES.EQUALS:
                            expressionResults[sequence] = this.validateEquals(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.NOT_EQUALS:
                            expressionResults[sequence] = !this.validateEquals(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.STARTS_WITH:
                            expressionResults[sequence] = this.validateStarts(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.CONTAINS:
                            expressionResults[sequence] = this.validateContains(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.DOES_NOT_CONTAIN:
                            expressionResults[sequence] = !this.validateContains(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.IS_NULL:
                            expressionResults[sequence] = this.validateIsNull(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.IS_NOT_NULL:
                            expressionResults[sequence] = !this.validateIsNull(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.GREATER_THAN:
                            expressionResults[sequence] = this.validateGreaterThan(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.LESS_THAN:
                            expressionResults[sequence] = this.validateLesserThan(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.LESS_THAN_OR_EQUAL:
                            expressionResults[sequence] = this.validateLE(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.GREATER_THAN_OR_EQUAL:
                            expressionResults[sequence] = this.validateGE(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.INCLUDES:
                            expressionResults[sequence] = this.validateIn(
                                fieldVal,
                                criteria
                            );
                            break;
                        case OPERATOR_TYPES.EXCLUDES:
                            expressionResults[sequence] = !this.validateIn(
                                fieldVal,
                                criteria
                            );
                            break;
                        default:
                            expressionResults[sequence] = true;
                    }
                });
                let advancedExpression = expression.advancedExpression
                    ? expression.advancedExpression.toUpperCase()
                    : simulatedAdvancedExpression;
                if (!this.validateAdvanceExpression(advancedExpression)) {
                    return null;
                }
                const exprArray = Object.keys(expressionResults);
                let exprLength = exprArray.length - 1;
                while (exprLength >= 0) {
                    if (
                        Object.prototype.hasOwnProperty.call(
                            expressionResults,
                            exprArray[exprLength]
                        )
                    ) {
                        advancedExpression = advancedExpression.replaceAll(
                            exprArray[exprLength],
                            expressionResults[exprArray[exprLength]]
                        );
                        exprLength--;
                    }

                }
                advancedExpression = advancedExpression.replaceAll(
                    LOGICAL_OPERATORS.AND, LOGICAL_OPERATORS.LOGICAL_AND);
                advancedExpression = advancedExpression.replaceAll(LOGICAL_OPERATORS.OR,
                    LOGICAL_OPERATORS.LOGICAL_OR);
                if (/^\d+$/.test(advancedExpression)) {
                    throw new Error("Expression line item not matching with advanced expression");
                } else {
                    // eslint-disable-next-line no-eval
                    returnVal = eval(advancedExpression);
                }

            }
        } catch (error) {
            console.error(error);
        } finally {
            this.userFieldVal = null;
            this.userLiteralCheck = null;
        }
        return returnVal;
    }

    validateEquals (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (STRING_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = fieldVal === matchvalue;
        } else if (TIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = this.getTime(fieldVal) === this.getTime(matchvalue);
        } else if (
            expressioncriteria.fieldType === FIELD_DATA_TYPES.BOOLEAN &&
            typeof fieldVal !== 'undefined'
        ) {
            decision = fieldVal?.toString() === matchvalue?.toString();
        } else if (NUMBER_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = Number(fieldVal) === Number(matchvalue);
        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.MULTIPICKLIST
                && fieldVal) {
            decision = fieldVal === matchvalue;
        } else if (DATETIME_VAR .includes(expressioncriteria.fieldType) && fieldVal) {
            const operandType = expressioncriteria.operandType;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                const operandDate = this.getDate(matchvalue);
                const myDateVal  = new Date(fieldVal);
                const updatedDateVal = new Date(
                    myDateVal.getFullYear(),
                    myDateVal.getMonth(),
                    myDateVal.getDate());
                decision = operandDate.getTime() === updatedDateVal.getTime();
            } else {
                decision = fieldVal === matchvalue;
            }
        } else if (DATE_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const fieldValparts = fieldVal.split('-');
            const mydate = new Date(
                fieldValparts[0],
                fieldValparts[1] - 1,
                fieldValparts[2]
            );

            let operandDate = null;
            const operandType = expressioncriteria.operandType;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                operandDate = this.getDate(matchvalue);
            } else {
                const operandParts = matchvalue?.split('T')[0]?.split('-');
                operandDate = new Date(
                    operandParts[0],
                    operandParts[1] - 1,
                    operandParts[2]
                );
            }
            decision = mydate.getTime() === operandDate.getTime();
        }
        return decision;
    }

    validateStarts (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (STRING_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = fieldVal.indexOf(matchvalue) === 0;
        }
        return decision;
    }

    validateContains (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (STRING_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = fieldVal.indexOf(matchvalue) > -1;
        }
        return decision;
    }

    validateIsNull (fieldVal, expressioncriteria) {
        let decision = false;
        if (
            STRING_VAR.includes(expressioncriteria.fieldType) ||
            NUMBER_VAR.includes(expressioncriteria.fieldType) ||
            DATE_VAR.includes(expressioncriteria.fieldType)  ||
            DATETIME_VAR.includes(expressioncriteria.fieldType) ||
            TIME_VAR.includes(expressioncriteria.fieldType)
        ) {
            decision = fieldVal === null;
        }
        return decision;
    }

    validateGreaterThan (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (NUMBER_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = Number(fieldVal) > Number(matchvalue);
        } else if (TIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = this.getTime(fieldVal) > this.getTime(matchvalue);
        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.PICKLIST
                    && fieldVal) {
            try {
                decision = Number(fieldVal) > Number(matchvalue);
            } catch (exception) {
                decision = false;
            }
        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.REFERENCE
                    && fieldVal) {
            try {
                decision = Number(fieldVal) > Number(matchvalue);
            } catch (exception) {
                decision = false;
            }
        } else if (DATETIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const operandType = expressioncriteria.operandType;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                const operandDate = this.getDate(matchvalue);
                const myDateVal  = this.getLocaleDateFromUTC(new Date(fieldVal));
                const updatedDateVal = new Date(
                    myDateVal.getFullYear(),
                    myDateVal.getMonth(),
                    myDateVal.getDate());
                decision = updatedDateVal.getTime() > operandDate.getTime();
            } else {
                const inputDateTime = Date.parse(fieldVal);
                const expressionDate = Date.parse(matchvalue);
                decision = inputDateTime > expressionDate;
            }
        } else if (DATE_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const fieldValparts = fieldVal.split('-');
            const mydate = new Date(
                fieldValparts[0],
                fieldValparts[1] - 1,
                fieldValparts[2]
            );
            const operandType = expressioncriteria.operandType;
            let operandDate;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                operandDate = this.getDate(matchvalue);
            } else {
                const operandParts = matchvalue?.split('T')[0]?.split('-');
                operandDate = new Date(
                    operandParts[0],
                    operandParts[1] - 1,
                    operandParts[2]
                );
            }
            decision = mydate > operandDate;
        }
        return decision;
    }

    validateLesserThan (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (NUMBER_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = Number(fieldVal) < Number(matchvalue);
        } else if (TIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = this.getTime(fieldVal) < this.getTime(matchvalue);
        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.PICKLIST
                && fieldVal) {
            try {
                decision = Number(fieldVal) < Number(matchvalue);
            } catch (exception) {
                decision = false;
            }

        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.REFERENCE
                && fieldVal) {
            try {
                decision = Number(fieldVal) < Number(matchvalue);
            } catch (exception) {
                decision = false;
            }
        } else if (DATETIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const operandType = expressioncriteria.operandType;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                const operandDate = this.getDate(matchvalue);
                const myDateVal  = this.getLocaleDateFromUTC( new Date(fieldVal));
                const updatedDateVal = new Date(
                    myDateVal.getFullYear(),
                    myDateVal.getMonth(),
                    myDateVal.getDate());
                decision = updatedDateVal.getTime() < operandDate.getTime();
            } else {
                const inputDateTime = Date.parse(fieldVal);
                const expressionDate = Date.parse(matchvalue);
                decision = inputDateTime < expressionDate;
            }
        } else if (DATE_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const fieldValparts = fieldVal.split('-');
            const mydate = new Date(
                fieldValparts[0],
                fieldValparts[1] - 1,
                fieldValparts[2]
            );
            const operandType = expressioncriteria.operandType;
            let operandDate;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                operandDate = this.getDate(matchvalue);
            } else {
                const operandParts = matchvalue?.split('T')[0]?.split('-');
                operandDate = new Date(
                    operandParts[0],
                    operandParts[1] - 1,
                    operandParts[2]
                );
            }
            decision = mydate < operandDate;
        }
        return decision;
    }

    validateGE (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (NUMBER_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = Number(fieldVal) >= Number(matchvalue);
        } else if (TIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = this.getTime(fieldVal) >= this.getTime(matchvalue);
        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.PICKLIST
                && fieldVal) {
            try {
                decision = Number(fieldVal) >= Number(matchvalue);
            } catch (exception) {
                decision = false;
            }

        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.REFERENCE
                && fieldVal) {
            try {
                decision = Number(fieldVal) >= Number(matchvalue);
            } catch (exception) {
                decision = false;
            }
        } else if (DATETIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const operandType = expressioncriteria.operandType;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                const operandDate = this.getDate(matchvalue);
                const myDateVal  = this.getLocaleDateFromUTC( new Date(fieldVal));
                const updatedDateVal = new Date(
                    myDateVal.getFullYear(),
                    myDateVal.getMonth(),
                    myDateVal.getDate());
                decision = updatedDateVal.getTime() >= operandDate.getTime();
            } else {
                const inputDateTime = Date.parse(fieldVal);
                const expressionDate = Date.parse(matchvalue);
                decision = inputDateTime >= expressionDate;
            }
        } else if (DATE_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const fieldValparts = fieldVal.split('-');
            const mydate = new Date(
                fieldValparts[0],
                fieldValparts[1] - 1,
                fieldValparts[2]
            );
            const operandType = expressioncriteria.operandType;
            let operandDate;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                operandDate = this.getDate(matchvalue);
            } else {
                const operandParts = matchvalue?.split('T')[0]?.split('-');
                operandDate = new Date(
                    operandParts[0],
                    operandParts[1] - 1,
                    operandParts[2]
                );
            }
            decision = mydate >= operandDate;
        }
        return decision;
    }

    validateLE (fieldVal, expressioncriteria) {
        let decision = false;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (NUMBER_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = Number(fieldVal) <= Number(matchvalue);
        } else if (TIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            decision = this.getTime(fieldVal) <= this.getTime(matchvalue);
        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.PICKLIST
                && fieldVal) {
            try {
                decision = Number(fieldVal) <= Number(matchvalue);
            } catch (exception) {
                decision = false;
            }

        } else if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.REFERENCE
                  && fieldVal) {
            try {
                decision = Number(fieldVal) <= Number(matchvalue);
            } catch (exception) {
                decision = false;
            }
        } else if (DATETIME_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const operandType = expressioncriteria.operandType;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                const operandDate = this.getDate(matchvalue);
                const myDateVal  = this.getLocaleDateFromUTC( new Date(fieldVal));
                const updatedDateVal = new Date(
                    myDateVal.getFullYear(),
                    myDateVal.getMonth(),
                    myDateVal.getDate());
                decision = updatedDateVal <= operandDate;
            } else {
                const inputDateTime = Date.parse(fieldVal);
                const expressionDate = Date.parse(matchvalue);
                decision = inputDateTime <= expressionDate;
            }
        } else if (DATE_VAR.includes(expressioncriteria.fieldType) && fieldVal) {
            const fieldValparts = fieldVal.split('-');
            const mydate = new Date(
                fieldValparts[0],
                fieldValparts[1] - 1,
                fieldValparts[2]
            );
            const operandType = expressioncriteria.operandType;
            let operandDate;
            if (!this.userLiteralCheck && operandType.toLowerCase() === 'function') {
                operandDate = this.getDate(matchvalue);
            } else {
                const operandParts = matchvalue?.split('T')[0]?.split('-');
                operandDate = new Date(
                    operandParts[0],
                    operandParts[1] - 1,
                    operandParts[2]
                );
            }
            decision = mydate <= operandDate;
        }
        return decision;
    }

    validateIn (fieldVal, expressioncriteria) {
        let matchedCount = 0;
        const matchvalue = this.userLiteralCheck ? this.userFieldVal : expressioncriteria.operand;
        if (expressioncriteria.fieldType.toUpperCase() === FIELD_DATA_TYPES.MULTIPICKLIST
            && fieldVal) {
            const includedValList = fieldVal.split(';');
            const matchValList = matchvalue.split(';');
            matchValList.forEach(value => {
                if ( includedValList.find(eachValue => value === eachValue)) {
                    matchedCount++;
                }
            });
        }
        return matchedCount >0;
    }

    getLocaleDateFromUTC (utcDate) {
        const localeDate = utcDate.toLocaleString('en-US', {
            timeZone: this.userTimeZone,
            timeZoneName: 'short'
        });
        const dateonly =  localeDate.split(',')[0];
        if (!dateonly) {
            return null;
        }
        const updateArr = dateonly.split('/');
        if (!updateArr) {
            return null;
        }
        return new Date(updateArr[2], updateArr[0]-1, updateArr[1]);
    }

    getDate (operand) {
        const event = new Date();
        const updateeve = event.toLocaleString('en-US', {
            timeZone: this.userTimeZone,
            timeZoneName: 'short'
        });
        const dateonly =  updateeve.split(',')[0];
        if (!dateonly) {
            return null;
        }
        const updateArr = dateonly.split('/');
        if (!updateArr) {
            return null;
        }
        let operandDate = new Date(updateArr[2],updateArr[0]-1,updateArr[1]);
        if (operand.toUpperCase() === DATE_TIME_FUNCTION_LITERALS.TODAY) {
            operandDate = new Date(
                operandDate.getFullYear(),
                operandDate.getMonth(),
                operandDate.getDate()
            );
        } else if (operand.toUpperCase() === DATE_TIME_FUNCTION_LITERALS.YESTERDAY) {
            operandDate = new Date(
                operandDate.getFullYear(),
                operandDate.getMonth(),
                operandDate.getDate() - 1
            );
        } else if (operand.toUpperCase() === DATE_TIME_FUNCTION_LITERALS.TOMORROW) {
            operandDate = new Date(
                operandDate.getFullYear(),
                operandDate.getMonth(),
                operandDate.getDate() + 1
            );
        }
        return operandDate;
    }

    getTime (timeStr) {
        const timeParts = timeStr.split(":");
        let timeVal;
        try {
            timeVal = Number(timeParts[0]) + Number(timeParts[1]);
        } catch (error) {
            console.error(error);
        }
        return timeVal;
    }

    validateAdvanceExpression (advanceExpression) {
        let validateExpression =  advanceExpression.slice();
        validateExpression = validateExpression.replaceAll('(','');
        validateExpression = validateExpression.replaceAll(')','');
        validateExpression = validateExpression.replaceAll(LOGICAL_OPERATORS.AND,'');
        validateExpression = validateExpression.replaceAll(LOGICAL_OPERATORS.OR,'');
        validateExpression = validateExpression.replaceAll(' ','');
        return /^\d+$/.test(validateExpression);
    }

    validateExpressionForErrors (expression) {
        let validatedExpression = false;
        if (isNotUndefinedOrNull(expression.operator) &&
            isNotUndefinedOrNull(expression.operandType) &&
            isNotUndefinedOrNull(expression.sequence) &&
            isNotUndefinedOrNull(expression.fieldType)
        ) {
            if (expression.fieldType === FIELD_DATA_TYPES.REFERENCE
                && isNotUndefinedOrNull(expression.relationshipName)) {
                validatedExpression = true;
            } else if (isNotUndefinedOrNull(expression.fieldAPIName)) {
                validatedExpression = true;
            }
            if (isUndefinedOrNull (expression.operand)) {
                if (expression.operator === OPERATOR_TYPES.IS_NOT_NULL ||
                expression.operator === OPERATOR_TYPES.IS_NULL) {
                    validatedExpression = validatedExpression && true;
                } else {
                    validatedExpression = false;
                }
            }
        }
        if (!validatedExpression) {
            throw new Error(messageInvalidException);
        }
    }

    getFieldValue (criteria, objRec) {
        let fieldVal = '';
        if (objRec) {
            if (criteria.fieldType === FIELD_DATA_TYPES.REFERENCE &&
                !this.userLiteralCheck) {
                fieldVal = getRelationshipFieldValue(
                    criteria.relationshipName,
                    criteria.relationshipFieldAPIName,
                    objRec);
            } else if (criteria.fieldAPIName.includes('.')) {
                const lastindex = criteria.fieldAPIName.lastIndexOf('.');
                const relationshipFieldAPIName = criteria.fieldAPIName.substring(lastindex+1);
                const relationshipName = criteria.fieldAPIName.substring(0, lastindex);
                fieldVal = getRelationshipFieldValue(
                    relationshipName,
                    relationshipFieldAPIName,
                    objRec);
            } else {
                fieldVal = objRec?.fields[criteria.fieldAPIName]?.value;
            }
        }
        return fieldVal;
    }
}