import { getActualValue } from "./api/uiRecord";
import { isARecord } from "./api/common";
import { arraysEqual } from "./arrayUtils";
import { normalizeFieldApiName } from "./normalize";
import { getReferenceObjectNameFromFieldInfo } from "./lookupUtils";
import { dateTimeLiterals, resolveUserRecordByExpressions } from './literals';

let acorn = null;
let moment = null;

const originalValue = '__Original_Value__';

const STR_TYPES = ['string', 'textarea', 'text', 'url', 'email', 'phone'];

const STRINGISH_TYPES = STR_TYPES.reduce(
    (acc, curr) => ({
        ...acc,
        [curr]: curr,
    }),
    {},
);

const stringishType = {
    ...STRINGISH_TYPES,
    picklist: 'picklist',
    combobox: 'combobox',
};

const mungers = {
    boolean: (val) => {
        if (typeof val === 'string') {
            const v = val.toLowerCase().trim();
            if (v === 'true' || v === 'yes') {
                return true;
            }
            if (v === 'false' || v === 'no' || v === '') {
                return false;
            }
            return val;
        }
        return !!val;
    },
    double: (value) => value && +value,
    percent: (value) => value && +value,
    currency: (value) => value && +value,
    integer: (value) => value && +value,
    multipicklist: (value) => value && value.split(';'),
};

const warning = (skip, message) => {
    if (!skip) {
        console.error(message);
    }
}

const commonEvaluators = {
    isnull: (left) => left === null || left === undefined,
    isnotnull: (left) => !(left === null || left === undefined),
    eq: (left, right) => left === right,
    ne: (left, right) => left !== right,
};

const arrayUnaryOperators = {
    isnotnull: (left) => !!(left && Array.isArray(left) && left.length > 0),
    isnull: (left) => !arrayUnaryOperators.isnotnull(left),
};

const arrayUnary = (type) =>
    type === 'multipicklist' ||
  type === 'checkbox' ||
  type === 'multi-select picklist';

const booleanEvaluators = {
    eq: (left, right) => mungers.boolean(left) === mungers.boolean(right),
    ne: (left, right) => !booleanEvaluators.eq(left, right),
};

// TODO: if right is undefined 'notin' behavior may be incorrect
const includes = (left, right) =>
    !!(
        right &&
    right
        .split(',')
        .map((item) => item.trim())
        .includes(left)
    );

const stringEvaluators = {
    ...commonEvaluators,
    starts: (left, right) => !!(left && left.startsWith(right)),
    contains: (left, right) =>
        (left !== null && left !== undefined
            ? !!(left && left.includes(right))
            : left === right), // true: null === null or undefined === undefined
    notcontain: (left, right) =>
        (left !== null && left !== undefined
            ? !!(left && !left.includes(right))
            : left !== right), // false: null === null or undefined === undefined
    gt: (left, right) => left > right,
    lt: (left, right) => left < right,
    ge: (left, right) => left >= right,
    le: (left, right) => left <= right,
    includes: (left, right) => includes(left, right),
    excludes: (left, right) => !includes(left, right),
    in: (left, right) => includes(left, right),
    notin: (left, right) => !includes(left, right),
};

const picklistEvaluator = {
    ...stringEvaluators,
    eq: (left, right) => includes(left, right),
    ne: (left, right) => (right ? !includes(left, right) : left !== right),
};

const numberEvaluators = {
    ...commonEvaluators,
    gt: (left, right) => left > right,
    lt: (left, right) => left < right,
    ge: (left, right) => left >= right,
    le: (left, right) => left <= right,
};

const dateTimeEvaluators = {
    ...commonEvaluators,
    eq: (left, right, precision = 'minute') =>
        !!(left && moment(left).isSame(moment(right), precision)),
    ne: (left, right, precision = 'minute') =>
        !dateTimeEvaluators.eq(left, right, precision),
    gt: (left, right, precision = 'minute') =>
        !!(left && moment(left).isAfter(moment(right), precision)),
    lt: (left, right, precision = 'minute') =>
        !!(left && moment(left).isBefore(moment(right), precision)),
    ge: (left, right, precision = 'minute') =>
        !!(left && moment(left).isSameOrAfter(moment(right), precision)),
    le: (left, right, precision = 'minute') =>
        !!(left && moment(left).isSameOrBefore(moment(right), precision)),
};

const nextNDaysEvaluators = {
    ...commonEvaluators,
    eq: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        const exp1 = left && moment(left).isSameOrAfter(moment(today), precision);
        const exp2 = left && moment(left).isSameOrBefore(moment(right), precision);
        return !!(exp1 && exp2);
    },
    ne: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        const exp1 = left && moment(left).isBefore(moment(today), precision);
        const exp2 = left && moment(left).isAfter(moment(right), precision);
        return !!(exp1 || exp2);
    },
    gt: (left, right, precision = 'date') => {
        return !!(left && moment(left).isAfter(moment(right), precision));
    },
    ge: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        return !!(left && moment(left).isSameOrAfter(moment(today), precision));
    },
    lt: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        return !!(left && moment(left).isBefore(moment(today), precision));
    },
    le: (left, right, precision = 'date') => {
        return !!(left && moment(left).isSameOrBefore(moment(right), precision));
    }

};

const lastNDaysEvaluators = {
    ...commonEvaluators,
    eq: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        const exp1 = left && moment(left).isSameOrAfter(moment(right), precision);
        const exp2 = left && moment(left).isBefore(moment(today), precision);
        return !!(exp1 && exp2);
    },
    ne: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        const exp1 = left && moment(left).isBefore(moment(right), precision);
        const exp2 = left && moment(left).isSameOrAfter(moment(today), precision);
        return !!(exp1 || exp2);
    },
    gt: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        return !!(left && moment(left).isSameOrAfter(moment(today), precision));
    },
    ge: (left, right, precision = 'date') =>
        !!(left && moment(left).isSameOrAfter(moment(right), precision)),
    lt: (left, right, precision = 'date') =>
        !!(left && moment(left).isBefore(moment(right), precision)),
    le: (left, right, precision = 'date') => {
        const today = moment().startOf('day').format('YYYY-MM-DD');
        return !!(left && moment(left).isBefore(moment(today), precision));
    },
};

const multipicklistEvaluators = {
    includes: (left, right) =>
        !!(
            left &&
      right &&
      Array.isArray(left) &&
      Array.isArray(right) &&
      right.some((o) => left.includes(o))
        ),
    eq: (left, right) => arraysEqual(left, right),
    ne: (left, right) => !arraysEqual(left, right),
    excludes: (left, right) =>
        !!(
            left &&
      right &&
      Array.isArray(left) &&
      Array.isArray(right) &&
      right.every((o) => !left.includes(o))
        ),
    // eslint-disable-next-line  @lwc/lwc/no-rest-parameter        
    in: (...args) => multipicklistEvaluators.includes(...args),
    // eslint-disable-next-line  @lwc/lwc/no-rest-parameter
    notin: (...args) => multipicklistEvaluators.excludes(...args),
};

const evaluateMultipicklist = (expression, value) => {
    const { operator, operand } = expression;

    warning(
        Array.isArray(operand),
        'You have passed a non array operand to expression evaluator for multi picklist',
    );

    warning(
        Array.isArray(value),
        'You have passed a non array value to expression evaluator for multi picklist',
    );

    const evaluator = multipicklistEvaluators[operator];
    return evaluator && evaluator(value, operand);
};

const evaluateBoolean = (expression, value) => {
    const { operator, operand } = expression;
    const evaluator = booleanEvaluators[operator];
    return !!(evaluator && evaluator(value, operand));
};

const evaluateString = (expression, value) => {
    const { operator, operand: op } = expression;

    const left = value && value.toLocaleLowerCase();
    const right = op && op.toLocaleLowerCase();
    const evaluator = stringEvaluators[operator];
    return evaluator && evaluator(left, right);
};

const evaluatePicklist = (expression, value) => {
    const { operand, operator } = expression;
    const right = operand.toLocaleLowerCase();
    const left = value && value.toLocaleLowerCase();
    const evaluator = picklistEvaluator[operator];
    return !!(evaluator && evaluator(left, right));
};

const evaluateNumber = (expression, value) => {
    const { operator, operand } = expression;
    const evaluator = numberEvaluators[operator];

    let status;
    switch (operator) {
        case 'eq':
            status =
        (value === undefined || value === null) &&
        (operand === undefined || operand === null);
            break;
        case 'ne':
            status =
        ((value === undefined || value === null) &&
          (operand !== undefined || operand !== null)) ||
        ((value !== undefined || value !== null) &&
          (operand === undefined || operand === null));
            break;
        default:
            status = false;
            break;
    }

    return (
        status ||
    (value !== undefined &&
      value !== null &&
      evaluator &&
      evaluator(+value, +operand))
    );
};

const evaluateDate = (expression, value, precision = 'date') => {
    const { operator, operand } = expression;

    warning(
        moment(value).isValid(),
        'You have passed an invalid date value to expression evaluator',
    );
    warning(
        moment(operand).isValid(),
        'Your expression passed to expression evaluator, contains an invalid date operand',
    );

    const evaluator = dateTimeEvaluators[operator];
    return !!(value && evaluator && evaluator(value, operand, precision));
};

const evaluateDateTime = (expression, value, precision = 'minute') => {
    const { operator, operand } = expression;

    warning(
        moment(value).isValid(),
        'You have passed an invalid datetime value to expression evaluator',
    );
    warning(
        moment(operand).isValid(),
        'Your expression passed to expression evaluator, contains an invalid datetime operand',
    );
    const evaluator = dateTimeEvaluators[operator];
    return !!(value && evaluator && evaluator(value, operand, precision));
};

const evaluateNextNDays = (expression, value, precision = 'date') => {
    const { operator, operand } = expression;

    warning(
        moment(value).isValid(),
        'You have passed an invalid date value to expression evaluator',
    );
    warning(
        moment(operand).isValid(),
        'Your expression passed to expression evaluator, contains an invalid date operand',
    );

    const evaluator = nextNDaysEvaluators[operator];
    return !!(value && evaluator && evaluator(value, operand, precision));
};

const evaluateLastNDays = (expression, value, precision = 'date') => {
    const { operator, operand } = expression;

    warning(
        moment(value).isValid(),
        'You have passed an invalid date value to expression evaluator',
    );
    warning(
        moment(operand).isValid(),
        'Your expression passed to expression evaluator, contains an invalid date operand',
    );

    const evaluator = lastNDaysEvaluators[operator];
    return !!(value && evaluator && evaluator(value, operand, precision));
};

const evaluators = {
    id: evaluateBoolean,
    boolean: evaluateBoolean,
    string: evaluateString,
    textarea: evaluateString,
    picklist: evaluatePicklist,
    url: evaluateString,
    phone: evaluateString,
    email: evaluateString,
    combobox: evaluateString,
    number: evaluateNumber,
    integer: evaluateNumber,
    double: evaluateNumber,
    percent: evaluateNumber,
    currency: evaluateNumber,
    date: evaluateDate,
    datetime: evaluateDateTime,
    text: evaluateString,
    multipicklist: evaluateMultipicklist,
    checkbox: evaluateMultipicklist,
    'radio button': evaluateString,
    'multi-select picklist': evaluateMultipicklist,
    last_n_days: evaluateLastNDays,
    next_n_days: evaluateNextNDays,
};

const evaluateExpression = async (
    expression,
    record,
    userRecord,
    asyncExecuteQueryFn,
    objectDescribe,
    recordId,
    objectApiName,
) => {
    const {
        operator,
        fieldAPIName: fieldName,
        operandType,
        relatedObjectDetails,
        literalParameterAPIName,
        relationshipName,
        relationshipFieldAPIName,
        sourceObjectName,
    } = expression;
    let {
        operand,
    } = expression;
    const fieldType  = expression.fieldType.toLowerCase();
    let isDateLiterals;
    if (operandType === 'Function' && operand!== 'User' ) {
        isDateLiterals = operand;
        operand = dateTimeLiterals[operand](fieldType);
    } else if (operandType === 'Function' && operand === 'User' && isARecord(userRecord)) {
        operand = getActualValue(
            userRecord,
            literalParameterAPIName
        );
    }

    let op = operator || 'eq';
    let operandRaw = operand;
    const fType = fieldType;
    // change operator if operand is not given to cover the use cases of equal/not equal empty value
    if (operandRaw === undefined && stringishType[fType]) {
        switch (op) {
            case 'eq':
                op = 'isnull';
                break;
            case 'ne':
                op = 'isnotnull';
                break;
            case 'gt':
            case 'ge':
            case 'lt':
            case 'le':
                operandRaw = '';
                break;
            default:
                break;
        }
    }
    const oper =
    typeof operandRaw === 'string' && mungers[fieldType]
        ? mungers[fieldType](operandRaw)
        : operandRaw;
    const isUnary = op === 'isnull' || op === 'isnotnull';

    // for LAST_N_DAYS and NEXT_N_DAYS literal
    let [opExp] =
    (expression[originalValue] && expression[originalValue].split(':')) || [];
    opExp = opExp && opExp.toLowerCase();
    const isSplLiteral =
    (opExp && [`last_n_days`, `next_n_days`].some((l) => opExp.match(l))) ||
    false;

    const fldType = isSplLiteral ? opExp : fieldType;
    const type = fieldType === 'reference' ? 'string' : fldType;

    // resolve reference field and multi level reference field api
    let value = null;
    const fields = fieldName.split(".");
    // resolving record first in case of record undefined
    if (record === undefined && recordId && objectApiName && sourceObjectName !== 'User') {
        let firstLeveleFieldName;
        if (fields.length > 1) {
            firstLeveleFieldName = normalizeFieldApiName(fields[0]);
        } else {
            firstLeveleFieldName= fieldName;
        }
        const fieldRelationShip = `${objectApiName}.${firstLeveleFieldName}`;
        const recordResult = await asyncExecuteQueryFn(recordId, [fieldRelationShip]);
        let fieldValue = null;
        if (isARecord(recordResult)) {
            fieldValue = getActualValue(
                recordResult,
                firstLeveleFieldName
            );
        }
        // eslint-disable-next-line no-param-reassign
        record = record ?? {};
        record[firstLeveleFieldName] =  fieldValue;
    }

    if (sourceObjectName === 'User' && isARecord(userRecord)) {
        value = getActualValue(
            userRecord,
            fieldName
        );
    } else if (fields.length > 1 && relatedObjectDetails) {
        const curFieldApiName = normalizeFieldApiName(fields[0]);
        const fieldValue = record[curFieldApiName];
        if (fieldValue) {
            const relatedObjectList = relatedObjectDetails.split(".");
            const relatedObjectApiName = relatedObjectList.shift();
            fields.shift();
            let fieldRelationShip;
            if (operandType === 'Value' && fieldType === 'reference') {
                const arrRelationShipName = relationshipName.split(".");
                const requiredRelationShipName = arrRelationShipName.slice(1);
                fieldRelationShip =
                    `${relatedObjectApiName}.${requiredRelationShipName.join(
                        '.'
                    )}.${relationshipFieldAPIName}`;
            } else {
                fieldRelationShip = `${relatedObjectApiName}.${fields.join(".")}`;
            }
            // eslint-disable-next-line no-await-in-loop
            const recordResult = await asyncExecuteQueryFn(fieldValue, [fieldRelationShip]);
            if (isARecord(recordResult)) {
                value = getActualValue(
                    recordResult,
                    fieldRelationShip
                );
            }
        }
    } else if (fieldType === 'reference' &&
        operandType === 'Value' &&
        relationshipName &&
        relationshipFieldAPIName &&
        record[fieldName]) {

        const fieldValue = record[fieldName];
        const objectName = getReferenceObjectNameFromFieldInfo(objectDescribe[fieldName]);
        const fieldRelationShip = `${objectName}.${relationshipFieldAPIName}`;
        // eslint-disable-next-line no-await-in-loop
        const recordResult = await asyncExecuteQueryFn(fieldValue, [fieldRelationShip]);
        if (isARecord(recordResult)) {
            value = getActualValue(
                recordResult,
                relationshipFieldAPIName
            );
        }
    }  else {
        value = record[fieldName];
    }

    value = typeof value === 'string' && mungers[fieldType]
        ? mungers[fieldType](value)
        : value;

    const evaluator = !isUnary
        ? evaluators[type]
        : arrayUnary(fieldType)
            ? arrayUnaryOperators[op]
            : commonEvaluators[op];

    const precision =
    fieldType === 'date' || fieldType === 'datetime'
        ? // $FlowFixMe: Symbols cannot be used in computed properties
        isDateLiterals
            ? // $FlowFixMe: Symbols cannot be used in computer properties
            isDateLiterals === 'FSVMXNOW'
                ? 'minute'
                : 'date'
            : undefined
        : undefined;
    const args = isUnary
        ? [value, oper]
        : [{ ...expression, operand: oper, operator: op }, value, precision];

    warning(
        evaluator,
        `Couldn't find a way to evaluate expression: ${JSON.stringify(expression)}`,
    );

    return !!(evaluator && evaluator(...args));
};

/*
    evaluates a boolean expression
    (for example: true && (false || (true || false)))
    represented as javascript ast
*/
const evaluateBooleanASTExpression = (expression) => {
    const booleanExpressionEvaluators = {
        '&&': (left, right) => left && right,
        '||': (left, right) => left || right,
    };

    const { left, right, operator, type, value, argument } = expression;

    // Disabling eqeqeq so that flowtype properly realizes we're handling the ! case here
    // eslint-disable-next-line eqeqeq
    if (type === 'UnaryExpression' && operator == '!') {
        return !evaluateBooleanASTExpression(argument);
    }

    if (type === 'Literal') {
        return value;
    }

    const leftValue =
    left.type === 'Literal' ? left.value : evaluateBooleanASTExpression(left);

    const rightValue =
    right.type === 'Literal'
        ? right.value
        : evaluateBooleanASTExpression(right);

    return booleanExpressionEvaluators[operator](leftValue, rightValue);
};

const evaluateAdvancedExpression = (exps, advExp) => {
    const boolExp = advExp
        .toLowerCase()
        .replace(/\d+/g, (m) => exps[+m - 1].toString())
        .replace(/and/g, '&&')
        .replace(/or/g, '||')
        .replace(/not/g, '!');

    const ast = acorn.parse(boolExp);
    return evaluateBooleanASTExpression(ast.body[0].expression);
};

export const evaluateExpressions = async (
    expressions,
    record,
    advancedExpression,
    asyncExecuteQueryFn,
    objectDescribe,
    recordId,
    objectApiName,
) => {
    try {
        acorn = window.acorn;
        moment = window.moment;
        if (!acorn || !moment) {
            throw new Error('acorn or moment is not loaded');
        }
        const expressionValues = [];
        const userRecord = await resolveUserRecordByExpressions(expressions, asyncExecuteQueryFn);
        // eslint-disable-next-line @lwc/lwc/no-for-of
        for (const exp of expressions) {
            // eslint-disable-next-line no-await-in-loop
            const result = await evaluateExpression(
                exp,
                record,
                userRecord,
                asyncExecuteQueryFn,
                objectDescribe,
                recordId,
                objectApiName,
            );
            expressionValues.push(result);
        }
        const advExp =
            advancedExpression ||
            expressions.map((e, idx) => `${idx + 1}`).join(' AND ');
        return evaluateAdvancedExpression(expressionValues, advExp);
    } catch (e) {
        console.error(e);
        return false;
    }
};