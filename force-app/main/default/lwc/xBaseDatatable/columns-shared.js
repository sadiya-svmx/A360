export function isCustomerColumn (column) {
    return column.internal !== true;
}

export function getColumns (state) {
    return state.columns;
}