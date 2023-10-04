import LOCALE from '@salesforce/i18n/locale';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { FIELD_DATA_TYPES } from './constants'

export const TIMEZONE_GMT = 'GMT';

export function formatDateValue (value, dataType, timeZone) {
    if (!value) return null;

    let formatOptions;

    switch (dataType) {
        case FIELD_DATA_TYPES.DATE:
            formatOptions = {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                timeZone: 'UTC'
            };
            break;
        case FIELD_DATA_TYPES.DATETIME:
            formatOptions = {
                hour: '2-digit',
                minute: '2-digit',
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                timeZone: timeZone || TIMEZONE
            };
            break;
        case FIELD_DATA_TYPES.TIME:
            formatOptions = {
                hour: '2-digit',
                minute: '2-digit',
                timeZone: 'UTC'
            };
            break;

        // no default
    }

    return new Intl.DateTimeFormat(LOCALE, formatOptions).format(getDateTimeValue(value, dataType));
}

export function getDateTimeValue (value, dataType) {
    let dateObj = value;
    if (typeof value === 'string' || typeof value === 'number') {
        const _value = (dataType === FIELD_DATA_TYPES.TIME) ? getTimeValue(value) : value;

        dateObj = new Date( isFinite(_value) ? parseInt(_value, 10) : Date.parse(_value) );
    }
    return dateObj;
}

export function getTimeValue (value) {
    const dateValue = new Date().toISOString().split('T')[0];
    const timeValue = value;

    return `${dateValue}T${timeValue}Z`;
}

/**
 * Adds months to the date parameter and returns a new Date.
 * @param {Object} date - Date object 
 * @param {Number} value - Number of months to add. Can also be a negative value.
 * @return {Object} A new Date object as a result of the calculation.
 */
export function addMonths (date, value) {
    const newDate = new Date(date.getTime());
    const dayOfMonth = newDate.getDate();
    const year = newDate.getFullYear();
    const isLeapYear = ((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0);
    const daysInMonth =
        [31, (isLeapYear ? 29 : 28),31,30,31,30,31,31,30,31,30,31][newDate.getMonth()];

    newDate.setDate(1);
    newDate.setMonth(newDate.getMonth() + value * 1);
    newDate.setDate(Math.min(dayOfMonth, daysInMonth));

    return newDate;
}

/**
 * Adds days to the date parameter and returns a new Date.
 * @param {Object} date - Date object 
 * @param {Number} value - Number of months to add. Can also be a negative value.
 * @return {Object} A new Date object as a result of the calculation.
 */
export function addDays (date, value) {
    const newDate = new Date(date.getTime());

    newDate.setDate(newDate.getDate() + value * 1);

    return newDate;
}

/**
 * Calculates the number of days between the start and end dates.
 * @param {Object} startDate - from date
 * @param {Object} endDate - to date
 * @return {Number} Number - number of days between the start and end dates
 */
export function calculateDateDiffInDays (startDate, endDate) {
    const DAY_TO_MILLISECONDS = 864e5; // 1000ms * 60s * 60m * 24h

    const startTimeStamp = Number(startDate);
    const endTimeStamp = Number(endDate);

    const diffInDays = (startTimeStamp - endTimeStamp) / DAY_TO_MILLISECONDS;

    return Math.abs(Math.round(diffInDays));
}

/**
 * Formats a Javascript Date object to an Apex Date-only string
 * @param {Object} dateTime - Javascript Date Object
 * @return {String} String - Apex Date string
 */
export function formatDateTimeToApexDateString (dateTime, useUTC = true) {
    const dateParts = [];

    const month = useUTC ? dateTime.getUTCMonth() + 1 : dateTime.getMonth() + 1;
    const day = useUTC ? dateTime.getUTCDate() : dateTime.getDate()

    dateParts.push(useUTC ? dateTime.getUTCFullYear() : dateTime.getFullYear());
    dateParts.push(month.toString().padStart(2, '0'));
    dateParts.push(day.toString().padStart(2, '0'));

    return dateParts.join('-');
}

export const isValidDate = (date) => {
    if (date && Object.prototype.toString.call(date) === "[object Date]") {
        return true;
    } else if (date && typeof date === "string") {
        const res = new Date(date);
        return !(String(res) === "Invalid Date");
    }
    return false;
};


// eslint-disable-next-line no-extend-native
Object.defineProperty(Date.prototype, "toSaveDateFormat", {
    value: function () {
        return (
            this.getFullYear() +
        "-" +
        new Intl.NumberFormat("en-IN", { minimumIntegerDigits: 2 }).format(
            this.getMonth() + 1
        ) +
        "-" +
        new Intl.NumberFormat("en-IN", { minimumIntegerDigits: 2 }).format(
            this.getDate()
        )
        );
    },
});


// eslint-disable-next-line no-extend-native
Object.defineProperty(Date.prototype, "toISODateString", {
    value: function () {
        return (
            this.getUTCFullYear() + "-" + (this.getUTCMonth() + 1) + "-" + this.getUTCDate()
        );
    },
});

export const getToday = () => {
    const dateValue = new Date();
    return new Date(
        dateValue.getFullYear(),
        dateValue.getMonth(),
        dateValue.getDate()
    );
};

export const getTommorrow = () => {
    const dateValue = new Date();
    return new Date(
        dateValue.getFullYear(),
        dateValue.getMonth(),
        dateValue.getDate() + 1
    );
};

export const getYestersday = () => {
    const dateValue = new Date();
    return new Date(
        dateValue.getFullYear(),
        dateValue.getMonth(),
        dateValue.getDate() - 1
    );
};

export const getNow = () => {
    return new Date();
};

export const convertToUserTimeZone = (dateTimeStr, userTimeZoneOffset) => {
    // dateTimeStr should be this format: 2021-06-11T11:00:00.000Z
    // userTimeZoneOffset should be this format: -07:00
    // so updatedTimeZoneStr should be converted to: 2021-06-11T11:00:00.000-07:00
    // to convert user time zone date time should be above format
    if (
        isValidDate(dateTimeStr) &&
        userTimeZoneOffset
    ) {
        const updatedTimeZoneStr = dateTimeStr.includes("Z")
            ? dateTimeStr.replace("Z", userTimeZoneOffset)
            : dateTimeStr + userTimeZoneOffset;

        return new Date(updatedTimeZoneStr).toISOString();
    }
    return dateTimeStr;
};


export const convertToLocalDateByUserTimeZone = (dateTimeStr, timeZoneOffset) => {
    if (
        isValidDate(dateTimeStr) &&
        timeZoneOffset
    ) {
        const userTimeZoneOffset = timeZoneOffset.includes("+")
            ? timeZoneOffset.replace("+", "-")
            : timeZoneOffset.replace("-", "+");
        const dateTimeArr = dateTimeStr.split('+');
        const updatedTimeZoneStr = dateTimeArr[0].includes("Z")
            ? dateTimeArr[0].replace("Z", userTimeZoneOffset)
            : dateTimeArr[0] + userTimeZoneOffset;

        const dateTimeISO =  new Date(updatedTimeZoneStr).toISOString();
        const lcoalDateTimeArr = dateTimeISO.split('T');
        return lcoalDateTimeArr[0];
    }
    return dateTimeStr;
};