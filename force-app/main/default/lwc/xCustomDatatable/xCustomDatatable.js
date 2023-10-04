import xBaseDatatable from 'c/xBaseDatatable';
import xCheckboxCell from './xCheckboxCell.html';
import xUrlCell from './xUrlCell.html';
import xEditPopoverCell from './xEditPopoverCell.html';
import xRichText from './xRichText.html';
import xTime from './xTime.html';

const commonTypeAttributes = [
    'disabled',
    'editable',
    'label',
    'fieldName',
    'fieldType',
    'meta',
    'required',
    'rowId',
    'type',
    'recordTypeId',
    'controllerValue',
];

export default class xCustomDatatable extends xBaseDatatable {
    static customTypes = {
        xCheckbox: {
            template: xCheckboxCell,
            typeAttributes: [
                'disabled',
                'fieldName',
                'fieldType',
                'required',
                'rowId',
                'type',
            ],
        },
        xLookup: {
            template: xEditPopoverCell,
            typeAttributes: [
                'disabled',
                'editable',
                'label',
                'fieldName',
                'fieldType',
                'meta',
                'required',
                'rowId',
                'type',
                'recordTypeId',
                'controllerValue',
                'showPopover',
                'isInConsole',
                'objectApiName',
                'rowActions'
            ],
        },
        xTextarea: {
            template: xEditPopoverCell,
            typeAttributes: commonTypeAttributes,
        },
        xPicklist: {
            template: xEditPopoverCell,
            typeAttributes: commonTypeAttributes
        },
        xUrl: {
            template: xUrlCell,
            standardCellLayout: true,
            typeAttributes: [
                'disabled',
                'label',
                'target',
                'tooltip',
                'showPopover',
                'isInConsole',
                'objectApiName',
                'rowActions'
            ]
        },
        xRichText: {
            template: xRichText,
            standardCellLayout: true
        },
        xTime: {
            template: xTime,
            standardCellLayout: true
        }
    };
}