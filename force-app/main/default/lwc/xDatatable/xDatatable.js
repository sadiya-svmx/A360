import LightningDatatable from 'lightning/datatable';
import xCheckboxCell from './xCheckboxCell.html';
import xUrlCell from './xUrlCell.html';
import xEditPopoverCell from './xEditPopoverCell.html';
import xImageCell from './xImageCell.html';

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

export default class XDatatable extends LightningDatatable {
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
            typeAttributes: commonTypeAttributes,
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
                'objectApiName',
                'fieldType',
            ]
        },
        xImage: {
            template: xImageCell,
            typeAttributes: commonTypeAttributes,
        },
    };
}