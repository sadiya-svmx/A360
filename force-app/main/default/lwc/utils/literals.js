import USER_OBJECT from "@salesforce/schema/User";
import USER_ID from "@salesforce/user/Id";
import { getActualValue } from "./api/uiRecord";
import { isARecord } from "./api/common";
import { normalizeFieldApiName } from "./normalize";
import { FUNCTION_LITERALS, OBJECT_MAPPING_TYPES } from "./constants";
import { getTommorrow, getYestersday, getToday, getNow } from "./dateUtils";


const getDateTimeLiteralResolvers = () => {

    const formatters = {
        today: {
            date: () => getToday().toSaveDateFormat(),
            datetime: () => getToday().toISOString(),
            string: () => getToday().toISOString(),
        },
        tomorrow: {
            date: () => getTommorrow().toSaveDateFormat(),
            datetime: () => getTommorrow().toISOString(),
            string: () => getTommorrow().toISOString(),
        },
        yesterday: {
            date: () => getYestersday().toSaveDateFormat(),
            datetime: () => getYestersday().toISOString(),
            string: () => getYestersday().toISOString(),
        },
        now: {
            datetime: () => getNow().toISOString().split('.')[0]+'.000Z',
            date: () => getNow().toSaveDateFormat(),
            string: () => getNow().toISOString().split('.')[0]+'.000Z',
        },
        next_n_days: {
            date: () => null,
            datetime: () => null,
            string: () => null,
        },
        last_n_days: {
            date: () => null,
            datetime: () => null,
            string: () => null,
        },
    };
    const applyFn = (fnName, fieldType, params) =>
        (fieldType && formatters[fnName][fieldType]
            ? formatters[fnName][fieldType](params)
            : formatters[fnName].date(params));

    const now = (fieldType, params) => applyFn("now", fieldType, params);
    const today = (fieldType, params) =>
        applyFn("today", fieldType, params);
    const yesterday = (fieldType, params) =>
        applyFn("yesterday", fieldType, params);
    const tomorrow = (fieldType, params) =>
        applyFn("tomorrow", fieldType, params);
    const next_n_days = (fieldType, params) =>
        applyFn("next_n_days", fieldType, params);
    const last_n_days = (fieldType, params) =>
        applyFn("last_n_days", fieldType, params);

    return {
        now,
        today,
        yesterday,
        tomorrow,
        next_n_days,
        last_n_days,
    };
};

const {
    now,
    today,
    tomorrow,
    yesterday,
    next_n_days,
    last_n_days,
} = getDateTimeLiteralResolvers();

export const dateTimeLiterals = {
    NOW: now,
    FSVMXNOW: now,
    TODAY: today,
    FSVMXTODAY: today,
    YESTERDAY: yesterday,
    FSVMXYESTERDAY: yesterday,
    TOMORROW: tomorrow,
    FSVMXTOMORROW: tomorrow,
    NEXT_N_DAYS: next_n_days,
    LAST_N_DAYS: last_n_days,
};

const objectLiterals = {
    "FSVMX.USERTRUNK": () => null,
    "FSVMX.GEOLOCATION.COORDS.LATITUDE": () => null,
    "FSVMX.GEOLOCATION.COORDS.LONGITUDE": () => null,
    "FSVMX.GEOLOCATION.COORDS.ACCURACY": () => null,
};

const combinedLiterals = {
    ...dateTimeLiterals,
    ...objectLiterals,
};

export const resolveLiterals = (value, fieldType) => {
    if (!value || typeof value !== "string") {
        return value;
    }

    // eslint-disable-next-line  @lwc/lwc/no-rest-parameter
    const [literal, ...params] = value.toUpperCase().split(":");
    return typeof combinedLiterals[literal] === "function"
        ? fieldType
            ? combinedLiterals[literal](fieldType.toLowerCase(), params)
            : combinedLiterals[literal](params)
        : value;
};

export const resolveUserRecordByObjectMapping = async (
    mappingConfig,
    asyncExecuteQueryFn
) => {
    // resolve user record
    const userLiterals = ((mappingConfig || {}).objectMappingDetails || []).filter(
        (ff) =>
            ff.mappingType === OBJECT_MAPPING_TYPES.FUNCTION &&
      ff.value === FUNCTION_LITERALS.USER
    );

    const userLiteralApiNames = (userLiterals || []).map(
        (ff) => `${USER_OBJECT.objectApiName}.${ff.literalParameterAPIName}`
    );

    const resolvedUserRecord = userLiteralApiNames.length
        ? await asyncExecuteQueryFn(USER_ID, userLiteralApiNames)
        : null;
    return resolvedUserRecord;
};

export const resolveUserRecordByExpressions = async (
    expressionDetails,
    asyncExecuteQueryFn
) => {
    // resolve user record
    const userLiterals = (expressionDetails || []).filter(
        (ff) =>
            ff.operandType === OBJECT_MAPPING_TYPES.FUNCTION &&
      ff.operand === FUNCTION_LITERALS.USER || ff.sourceObjectName === 'User'
    );

    const userLiteralApiNames = [];
    (userLiterals || []).forEach (
        (ff) => {
            if ( ff.sourceObjectName === 'User' ) {
                userLiteralApiNames.push(`${USER_OBJECT.objectApiName}.${ff.fieldAPIName}`);
            }
            if ( ff.operand === FUNCTION_LITERALS.USER ) {
                userLiteralApiNames.push(
                    `${USER_OBJECT.objectApiName}.${ff.literalParameterAPIName}`
                );
            }
        }
    );

    const resolvedUserRecord = userLiteralApiNames.length
        ? await asyncExecuteQueryFn(USER_ID, userLiteralApiNames)
        : null;
    return resolvedUserRecord;
};

export const resolveCurrentRecordByObjectMapping = async (
    mappingConfig,
    literalName,
    currentRecord,
    asyncExecuteQueryFn
) => {
    const currentRecordLiterals = ((mappingConfig || {}).objectMappingDetails || []).filter(
        (ff) =>
            ff.mappingType === OBJECT_MAPPING_TYPES.FUNCTION &&
            ff.value === literalName
    );

    const resolvedCurrentRecord = {};
    // eslint-disable-next-line @lwc/lwc/no-for-of
    for (const ff of currentRecordLiterals) {
        const fields = ff.literalParameterAPIName.split(".");
        const curFieldApiName = normalizeFieldApiName(fields[0]);
        const fieldValue = currentRecord[curFieldApiName];

        if (fields.length > 1 && fieldValue && ff.relatedObjectDetails) {
            const relatedObjectList = ff.relatedObjectDetails.split(".");
            const objectApiName = relatedObjectList.shift();
            fields.shift();
            const fieldRelationShip = `${objectApiName}.${fields.join(".")}`;
            // eslint-disable-next-line no-await-in-loop
            const record = await asyncExecuteQueryFn(fieldValue, [fieldRelationShip]);
            if (isARecord(record)) {
                resolvedCurrentRecord[ff.literalParameterAPIName] = getActualValue(
                    record,
                    fieldRelationShip
                );
            }
        } else if (fields.length > 1) {
            resolvedCurrentRecord[ff.literalParameterAPIName] =
                currentRecord[curFieldApiName];
        } else {
            resolvedCurrentRecord[ff.literalParameterAPIName] =
                currentRecord[ff.literalParameterAPIName];
        }
    }

    return resolvedCurrentRecord;
};