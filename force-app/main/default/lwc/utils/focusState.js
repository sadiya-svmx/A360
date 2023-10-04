/* eslint-disable no-unused-expressions */
export class FocusState {
    constructor (updateInterval = 0) {
        this._updateInterval = updateInterval;
    }

    _timeoutId;
    _focusHandler;
    _blurHandler;
    _hasFocus;

    focus () {
        this._respondToFocusChange(true);
    }

    blur () {
        this._respondToFocusChange(false);
    }

    _respondToFocusChange (newValue) {
        clearTimeout(this._timeoutId);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._timeoutId = setTimeout(() => {
            const focusChanged = this._hasFocus !== newValue;
            this._hasFocus = newValue;

            if (focusChanged) {
                if (newValue) {
                    this._focusHandler?.();
                } else {
                    this._blurHandler?.();
                }
            }
        }, this._updateInterval);
    }

    onFocus (handler) {
        this._focusHandler = handler;
    }

    onBlur (handler) {
        this._blurHandler = handler;
    }
}