import { getUserRowByCellKeys } from './rows';
import { getUserColumnIndex } from './columns';

/**
 *
 * @param {CustomEvent} event - row action
 */
export function handleRowActionTriggered (event) {
    const { rowKeyValue, colKeyValue, action } = event.detail;
    const selectedRow = getUserRowByCellKeys(
        this.state,
        rowKeyValue,
        colKeyValue
    );

    event.stopPropagation();

    this.dispatchEvent(
        new CustomEvent('rowaction', {
            detail: {
                row: JSON.parse(JSON.stringify(selectedRow)),
                action: JSON.parse(JSON.stringify(action)),
            },
        })
    );
}

/**
 *
 * @param {CustomEvent} event - load dynamic actions
 */
export function handleLoadDynamicActions (event) {
    const {
        rowKeyValue,
        colKeyValue,
        actionsProviderFunction,
        doneCallback,
        saveContainerPosition,
    } = event.detail;
    const selectedRow = getUserRowByCellKeys(
        this.state,
        rowKeyValue,
        colKeyValue
    );

    saveContainerPosition(this.getViewableRect());

    event.stopPropagation();
    actionsProviderFunction(JSON.parse(JSON.stringify(selectedRow)), doneCallback);
}

/**
 *
 * @param {CustomEvent} event - fire `rowaction` on cell-button click
 */
export function handleCellButtonClick (event) {
    event.stopPropagation();
    const { rowKeyValue, colKeyValue } = event.detail;
    const row = getUserRowByCellKeys(this.state, rowKeyValue, colKeyValue);
    const userColumnIndex = getUserColumnIndex(this.state, colKeyValue);
    const userColumnDefinition = this._columns[userColumnIndex];

    this.dispatchEvent(
        new CustomEvent('rowaction', {
            detail: {
                row: JSON.parse(JSON.stringify(row)),
                action: JSON.parse(JSON.stringify(userColumnDefinition.typeAttributes)),
            },
        })
    );
}