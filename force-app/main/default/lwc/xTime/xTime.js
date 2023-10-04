import { LightningElement, api } from 'lwc';
import { isNotUndefinedOrNull } from 'c/utils';

/* Component that wraps a lightning-formatted-time component, and converts milliseconds to 
* the ISO 8601 string that lightning-formatted-time expects.
*/
export default class XTime extends LightningElement {
    _value

    @api
    get value () {
        return this._value;
    }

    set value (value) {
        if (isNotUndefinedOrNull(value)) {
            if (value === 0) {
                this._value = "00:00";
            } else {
                const isoDateString = new Date(
                    Date.UTC(null, null, null, null, null, null, value)
                ).toISOString();
                const timeValue = isoDateString.split('T')[1];
                this._value = timeValue.replace(':00.000Z', '');
            }
        }
    }
}