import { assert, chunk } from 'c/utils';
import { classSet, isObjectLike } from './utils';
import { createRowKeysGenerator, generateColKeyValue } from './keys';
import { isTreeType } from './types';
import {
    isSelectedRow,
    isDisabledRow,
    isHighlightedRow,
    getRowSelectionInputType,
} from './selector-shared';
import { getTreeStateIndicatorFieldNames, getStateTreeColumn } from './tree';
import {
    getColumns,
    getTypeAttributesValues,
    getSubTypeAttributesValues,
    getCellAttributesValues,
    isCustomerColumn,
} from './columns';
import { isRowNumberColumn, getRowNumberErrorColumnDef } from './rowNumber';
import { getRowError } from './errors';
import { getDirtyValue } from './inlineEdit-shared';

export function getRowsDefaultState () {
    return {
        data: [],
        keyField: undefined,
        rows: [],
        indexes: {}
    };
}

export function setData (component, data, lazyLoad) {
    if (Array.isArray(data)) {
        if (lazyLoad) {
            const chunks = chunk(data, component.state.chunkSize ?? 50);
            component.state.data = chunks.shift();
            component.state.chunks = chunks;
            component.state.totalSize = data?.length;
            if (chunks.length > 0) {
                component.state.hasChunksLeft = true;
            }
        } else {
            component.state.data = data;
        }
    } else {
        component.state.data = [];
    }
}

export function getData (state) {
    return state.data;
}

export function getRows (state) {
    return state.rows;
}

export function setKeyField (state, value) {
    assert(
        typeof value === 'string',
        `The "keyField" value expected in lightning:datatable must be type String.`
    );
    if (typeof value === 'string') {
        state.keyField = value;
    } else {
        state.keyField = undefined;
    }
}

export function getKeyField (state) {
    return state.keyField;
}

export function hasValidKeyField (state) {
    const keyField = getKeyField(state);
    return typeof keyField === 'string';
}

/**
 * It resolve the css classes for a row based on the row.isSelected state
 * @param {object} row - a row object in state.rows collection
 * @returns {string} the classSet string
 */
export function resolveRowClassNames (row) {
    const classes = classSet('slds-hint-parent');
    if (row.isSelected) {
        classes.add('slds-is-selected');
    }

    if (row.isHighlighted) {
        classes.add('svmx-is-highlighted');
    }

    return classes.toString();
}

/**
 *
 * @param {object} state - data table state
 * @param {string} rowKeyValue - computed id for the row
 * @param {string} colKeyValue - computed id for the column
 *
 * @return {object} The user row that its related to the action.
 */
export function getUserRowByCellKeys (state, rowKeyValue, colKeyValue) {
    const rowIndex = state.indexes[rowKeyValue][colKeyValue][0];
    return getData(state)[rowIndex];
}

/**
 * It compute the state.rows collection based on the current normalized (data, columns)
 * and generate cells indexes map(state.indexes)
 * @param {object} state - the current datatable state
 */
export function updateRowsAndCellIndexes () {
    const { state, privateTypes: types } = this;
    const { keyField } = state;
    const data = getData(state);
    const columns = getColumns(state);
    const { computeUniqueRowKey } = createRowKeysGenerator(keyField);
    const scopeCol = columns.find(
        colData => types.isValidType(colData.type) && colData.isScopeCol
    );
    // initializing indexes
    state.indexes = {};
    if ( data === undefined) {
        state.rows = [];
        return;
    }
    state.rows = data.reduce((prev, rowData, rowIndex) => {
        const row = {
            key: computeUniqueRowKey(rowData), // attaching unique key to the row
            cells: [],
        };
        const rowErrors = getRowError(state, row.key);

        state.indexes[row.key] = { rowIndex };
        row.detailKey = `${row.key}-detail`
        row.inputType = getRowSelectionInputType(state);
        row.isSelected = isSelectedRow(state, row.key);
        row.ariaSelected = row.isSelected ? 'true' : false;
        row.isDisabled = isDisabledRow(state, row.key);
        row.isHighlighted = isHighlightedRow(state, row.key);
        row.classnames = resolveRowClassNames(row);
        row.detail = rowData.detail;
        row.enableFetch = rowData.enableFetch;
        Object.assign(row, getRowStateForTree(rowData, state));
        if (row.detail) {
            const padding = row.level * 20;
            row.detailPadding = `padding-left:${padding}px;`;
        }
        row.tabIndex = -1;
        const colLength = columns.length;
        columns.reduce((currentRow, colData, colIndex) => {
            const { fieldName } = colData;
            const colKeyValue = generateColKeyValue(colData, colIndex);
            const dirtyValue = getDirtyValue(state, row.key, colKeyValue);
            const computedCellValue =
                dirtyValue !== undefined ? dirtyValue : rowData[fieldName];
            // cell object creation
            const style = classSet(`${colData.style};`)
                .add({ 'padding: 0px;': types.isCustomType(colData.type) &&
                    !types.standardCellLayoutForCustomType(colData.type)
                });
            if (colIndex === 0) {
                // TODO: A360AM-1728 'z-index' was set to 'unset' from 1
                style.add (colLength > 2
                    ? 'padding-top:8px; padding-bottom: 8px;'
                    :'z-index: 1');
            }
            const cell = {
                columnType: colIndex === 0 ?'tree' : colData.type,
                columnSubType: colData.typeAttributes
                    ? colData.typeAttributes.subType
                    : undefined,
                dataLabel: colData.label,
                value: computedCellValue, // value based on the fieldName
                rowKeyValue: row.key, // unique row key value
                colKeyValue, // unique column key value
                tabIndex: -1, // tabindex
                isCheckbox: colData.type === 'SELECTABLE_CHECKBOX',
                class: computeCellClassNames(colData, rowErrors, dirtyValue),
                hasError:
                    rowErrors.fieldNames &&
                    rowErrors.fieldNames.indexOf(colData.fieldName) !== -1 ,
                isDataType:
                    types.isValidType(colData.type) && !colData.isScopeCol,
                isDataTypeScope:
                    types.isValidType(colData.type) && colData.isScopeCol,
                wrapText: state.wrapText[colKeyValue], // wrapText state
                wrapTextMaxLines: state.wrapText[colKeyValue]
                    ? state.wrapTextMaxLines
                    : undefined,
                paddingStyle: style.toString()
            };
            if (isCustomerColumn(colData)) {
                Object.assign(
                    cell,
                    computeCellTypeAttributes(rowData, colData, types),
                    computeCellAttributes(rowData, colData),
                    computeCellEditable(colData)
                );
                if (isTreeType(colData.type)) {
                    Object.assign(cell,
                        computeCellStateTypeAttributes(row),
                        computeCellNotification(rowData),
                        computeCellNotificationRecords(rowData));
                }
            } else if (isRowNumberColumn(colData)) {
                const scopeColValue = rowData[scopeCol.fieldName];
                const errorColumnDef = getRowNumberErrorColumnDef(
                    rowErrors,
                    scopeColValue
                );
                Object.assign(
                    cell,
                    computeCellTypeAttributes(rowData, errorColumnDef, types)
                );
            }

            // adding cell indexes to state.indexes
            // Keeping the hash for backward compatibility,
            // but we need to have 2 indexes, 1 for columns and one for rows,
            // because of memory usage and also at certain
            // point we might have the data but not the columns
            state.indexes[row.key][colKeyValue] = [rowIndex, colIndex];

            currentRow.push(cell);
            return currentRow;
        }, row.cells);

        prev.push(row);
        return prev;
    }, []);
}

function computeCellNotification (rowData) {
    if (rowData.notificationRecords && rowData.notificationRecords.length > 0) {
        return {
            hasNotifications: rowData.notificationRecords.length
        };
    }
    return {
        hasNotifications: false
    };
}

function computeCellNotificationRecords (rowData) {
    if (rowData.notificationRecords && rowData.notificationRecords.length > 0) {
        return {
            notificationRecords: rowData.notificationRecords
        };
    }
    return {
        notificationRecords: undefined
    };
}

export function computeCellAttributes (row, column) {
    const cellAttributesValues = getCellAttributesValues(column);
    return Object.keys(cellAttributesValues).reduce((attrs, attrName) => {
        const attrValue = cellAttributesValues[attrName];
        attrs[attrName] = resolveAttributeValue(attrValue, row);

        return attrs;
    }, {});
}

export function computeCellTypeAttributes (row, column, types) {
    if (column.typeAttributes && column.typeAttributes.subType) {
        return computeCellSubTypeAttributes(row, column, types);
    }
    const attributesNames = types.getType(column.type).typeAttributes;
    const typeAttributesValues = getTypeAttributesValues(column);

    return attributesNames.reduce((attrs, attrName, index) => {
        const typeAttributeName = `typeAttribute${index}`;

        attrs[typeAttributeName] = resolveAttributeValue(
            typeAttributesValues[attrName],
            row
        );

        return attrs;
    }, {});
}

export function computeCellSubTypeAttributes (row, column, types) {
    const attributesNames = types.getType(column.typeAttributes.subType).typeAttributes;
    const typeAttributesValues = getSubTypeAttributesValues(column);

    return attributesNames.reduce((attrs, attrName, index) => {
        const typeAttributeName = `typeAttribute${index}`;
        attrs[typeAttributeName] = resolveAttributeValue(
            typeAttributesValues[attrName],
            row
        );

        return attrs;
    }, {});
}

function computeCellEditable (column) {
    return {
        editable: column.editable,
    };
}

function computeCellClassNames (column, rowErrors, dirtyValue) {
    const classNames = classSet('');
    classNames.add({ 'slds-cell-edit': column.editable === true });
    classNames.add({ 'slds-tree__item': isTreeType(column.type) });
    classNames.add({
        'slds-has-error':
            rowErrors.fieldNames &&
            rowErrors.fieldNames.indexOf(column.fieldName) !== -1,
    });
    classNames.add({ 'slds-is-edited': dirtyValue !== undefined });
    return classNames.toString();
}

/**
 * Attaches if the row containing this cell hasChildren or not and isExpanded or not
 * attributes to typeAttribute21 and typeAttribute22 respectively
 * typeAttribute0-typeAttribute20 are reserved for  types supported by tree
 * @param {object}row - current row which is stored in state.rows
 * @returns {{typeAttribute21, typeAttribute22: boolean}} typeAttributes
 * describing state of the row associated
 */
function computeCellStateTypeAttributes (row) {
    return {
        typeAttribute21: row.hasChildren,
        typeAttribute22: row.isExpanded === true,
    };
}

export function getRowIndexByKey (state, key) {
    if (!state.indexes[key]) {
        return undefined;
    }

    return state.indexes[key].rowIndex;
}

export function getRowByKey (state, key) {
    const rows = getRows(state);
    return rows[getRowIndexByKey(state, key)];
}

export function rowKeyExists (state, key) {
    return !!state.indexes[key];
}

export function getRowsTotal (state) {
    return getRows(state).length;
}

function resolveAttributeValue (attrValue, row) {
    if (isObjectLike(attrValue)) {
        const fieldName = attrValue.fieldName;
        if (fieldName) {
            return row[fieldName];
        }
    }

    return attrValue;
}

function getRowStateForTree (row, state) {
    const column = getStateTreeColumn(state);
    if (column) {
        return {
            level: getRowLevel(column, row),
            posInSet: getRowPosInSet(column, row),
            setSize: getRowSetSize(column, row),
            isExpanded: isRowExpanded(column, row),
            ariaExpanded: isRowExpanded(column, row) + '',
            hasChildren: getRowHasChildren(column, row),
        };
    }
    return {};
}

export function getRowLevel (column, row) {
    const typeAttributesValues = getTypeAttributesValues(column);
    const attrValue = resolveAttributeValue(
        typeAttributesValues[getTreeStateIndicatorFieldNames().level],
        row
    );
    return attrValue ? attrValue : 1;
}

function getRowPosInSet (column, row) {
    const typeAttributesValues = getTypeAttributesValues(column);
    const attrValue = resolveAttributeValue(
        typeAttributesValues[getTreeStateIndicatorFieldNames().position],
        row
    );
    return attrValue ? attrValue : 1;
}

function getRowSetSize (column, row) {
    const typeAttributesValues = getTypeAttributesValues(column);
    const attrValue = resolveAttributeValue(
        typeAttributesValues[getTreeStateIndicatorFieldNames().setsize],
        row
    );
    return attrValue ? attrValue : 1;
}

export function isRowExpanded (column, row) {
    const typeAttributesValues = getTypeAttributesValues(column);
    const hasChildren = resolveAttributeValue(
        typeAttributesValues[getTreeStateIndicatorFieldNames().children],
        row
    );
    if (hasChildren) {
        const attrValue = resolveAttributeValue(
            typeAttributesValues[getTreeStateIndicatorFieldNames().expanded],
            row
        );
        return !!attrValue;
    }
    return undefined;
}

export function getRowHasChildren (column, row) {
    const typeAttributesValues = getTypeAttributesValues(column);
    const hasChildren = resolveAttributeValue(
        typeAttributesValues[getTreeStateIndicatorFieldNames().children],
        row
    );
    return !!hasChildren;
}