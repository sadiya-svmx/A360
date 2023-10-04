import labelEquals from '@salesforce/label/c.Label_Equals';
import labelNotEquals from '@salesforce/label/c.Label_NotEquals';
import labelGreaterThan from '@salesforce/label/c.Label_GreaterThan';
import labelGreaterThanOrEqual from '@salesforce/label/c.Label_GreaterThanOrEqual';
import labelLessThan from '@salesforce/label/c.Label_LessThan';
import labelLessThanOrEqual from '@salesforce/label/c.Label_LessThanOrEqual';
import labelStartsWith from '@salesforce/label/c.Label_StartsWith';
import labelContains from '@salesforce/label/c.Label_Contains';
import labelDoesNotContain from '@salesforce/label/c.Label_DoesNotContain';
import labelIsNull from '@salesforce/label/c.Label_IsNull';
import labelIsNotNull from '@salesforce/label/c.Label_IsNotNull';
import labelIncludes from '@salesforce/label/c.Label_Includes';
import labelExcludes from '@salesforce/label/c.Label_Excludes';
import labelEditScreen from '@salesforce/label/c.Button_EditScreen';
import labelEditTransaction from '@salesforce/label/c.Button_EditTransaction';
import labelEnableDebug from '@salesforce/label/c.Button_Debug';
import labelAnd from '@salesforce/label/c.Label_And';
import labelOr from '@salesforce/label/c.Label_Or';

export const ASSET_HIERARCHY_ORDER = {
    LOCATION_THEN_ASSET: 'Location > Asset',
    ASSET_ONLY: 'Asset Only',
    ACCOUNT_THEN_ASSET: 'Account > Asset'
}

export const ASSET_HIERARCHY_ORDER_TO_ROOT_OBJECT = {
    [ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET]: 'Location',
    [ASSET_HIERARCHY_ORDER.ASSET_ONLY]: 'Asset',
    [ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET]: 'Account'
}

export const ASSET_HIERARCHY_LOCALSTORAGE = {
    APP_NAME: 'A360AM',
    APP_KEY: 'AH',
    APP_MODE: 'SPLITMODE',
    CACHE_KEY: 'FILTERCACHE',
    ADMIN_CACHE_KEY: 'ADMINFILTERCACHE'
}

export const FIELD_DATA_TYPES = {
    ADDRESS: 'ADDRESS',
    BASE64: 'BASE64',
    BOOLEAN: 'BOOLEAN',
    COMBOBOX: 'COMBOBOX',
    CURRENCY: 'CURRENCY',
    DATE: 'DATE',
    DATETIME: 'DATETIME',
    DOUBLE: 'DOUBLE',
    EMAIL: 'EMAIL',
    ENCRYPTEDSTRING: 'ENCRYPTEDSTRING',
    ID: 'ID',
    INTEGER: 'INTEGER',
    LOCATION: 'LOCATION',
    LONG: 'LONG',
    MULTIPICKLIST: 'MULTIPICKLIST',
    PERCENT: 'PERCENT',
    PHONE: 'PHONE',
    PICKLIST: 'PICKLIST',
    REFERENCE: 'REFERENCE',
    STRING: 'STRING',
    TEXTAREA: 'TEXTAREA',
    TIME: 'TIME',
    URL: 'URL',
};

export const MAPPING_TYPES = {
    FIELD: 'Field Mapping',
    VALUE: 'Value Mapping',
};

export const UNSUPPORTED_EVENT_FIELDS = [
    'WhatId',
    'WhoId',
    'OwnerId',
    'Subject',
];

export const SUPPORTED_USER_FIELDS = [
    'City',
    'CompanyName',
    'Country',
    'Department',
    'Division',
    'Email',
    'EmployeeNumber',
    'FirstName',
    'Id',
    'IsActive',
    'LanguageLocaleKey',
    'LastName',
    'ManagerId',
    'MobilePhone',
    'Name',
    'Phone',
    'PostalCode',
    'ProfileId',
    'State',
    'Street',
    'TimeZoneSidKey',
    'Title',
    'UserType',
    'Username',
];

export const SUPPORTED_TRANSACTION_FIELDS = [
    'Name',
    'SVMXA360__DeveloperName__c',
    'LastModifiedById',
    'LastModifiedDate',
    'SVMXA360__TransactionType__c',
    'SVMXA360__SourceObjectAPIName__c',
    'SVMXA360__ObjectAPIName__c'
];

export const OBJECT_MAPPING_TYPES = {
    FIELD: 'Field',
    VALUE: 'Value',
    FUNCTION: 'Function',
};

export const OPERATION_TYPES = {
    DELETE: 'delete',
    UPDATE: 'update',
    WHEREUSED: 'whereused'
};

export const ROW_ACTION_TYPES = {
    DELETE: 'delete',
    EDIT: 'edit',
    CLONE: 'clone',
};

export const VALUE_INPUT_FIELD_CONTEXT = {
    RUNTIME: 'RUNTIME',
    ADMIN: 'ADMIN'
};

export const PAGE_ACTION_TYPES = {
    NEW: 'new',
    EDIT: 'edit',
    CLONE: 'clone',
    VIEW: 'view',
};

export const DATE_TIME_FUNCTION_LITERALS = {
    NOW: 'FSVMXNOW',
    TODAY: 'FSVMXTODAY',
    TOMORROW: 'FSVMXTOMORROW',
    YESTERDAY: 'FSVMXYESTERDAY'
}

export const FUNCTION_LITERALS = {
    USER: 'User',
    CURRENTRECORD: 'Current Record',
    CURRENTRECORDHEADER: 'Current Record Header',
}

export const MAPPING_TYPE = {
    FIELD: 'Field',
    FUNCTION: 'Function',
    VALUE: 'Value',
}

export const DATA_TYPE_ICONS = {
    [FIELD_DATA_TYPES.ADDRESS]: 'utility:location',
    [FIELD_DATA_TYPES.BASE64]: 'utility:attach',
    [FIELD_DATA_TYPES.BOOLEAN]: 'utility:toggle',
    [FIELD_DATA_TYPES.CURRENCY]: 'utility:currency',
    [FIELD_DATA_TYPES.DATE]: 'utility:date_input',
    [FIELD_DATA_TYPES.DATETIME]: 'utility:date_time',
    [FIELD_DATA_TYPES.DOUBLE]: 'utility:number_input',
    [FIELD_DATA_TYPES.EMAIL]: 'utility:email',
    [FIELD_DATA_TYPES.ENCRYPTEDSTRING]: 'utility:password',
    [FIELD_DATA_TYPES.ID]: 'utility:bookmark',
    [FIELD_DATA_TYPES.INTEGER]: 'utility:number_input',
    [FIELD_DATA_TYPES.LONG]: 'utility:number_input',
    [FIELD_DATA_TYPES.MULTIPICKLIST]: 'utility:multi_picklist',
    [FIELD_DATA_TYPES.PERCENT]: 'utility:number_input',
    [FIELD_DATA_TYPES.PHONE]: 'utility:call',
    [FIELD_DATA_TYPES.PICKLIST]: 'utility:picklist',
    [FIELD_DATA_TYPES.REFERENCE]: 'utility:record_lookup',
    [FIELD_DATA_TYPES.STRING]: 'utility:text',
    [FIELD_DATA_TYPES.TEXTAREA]: 'utility:textarea',
    [FIELD_DATA_TYPES.TIME]: 'utility:clock',
    [FIELD_DATA_TYPES.URL]: 'utility:link',
};

export const OBJECT_DEFAULT_ICON = 'custom:custom57';

export const TRANSACTION_API_NAME = 'SVMXA360__CONF_Layout__c';

export const OBJECT_ICONS = {
    account: 'standard:account',
    asset: 'standard:asset_object',
    assetwarranty: 'standard:asset_warranty',
    case: 'standard:case',
    contact: 'standard:contact',
    contractlineitem: 'standard:contract_line_item',
    event: 'standard:event',
    expense: 'standard:expense',
    location: 'standard:location',
    opportunity: 'standard:opportunity',
    product2: 'standard:product',
    productitem: 'standard:product_item',
    pricebook2: 'standard:pricebook',
    pricebookentry: 'standard:price_book_entries',
    productconsumed: 'standard:product_consumed',
    productrequest: 'standard:product_request',
    productrequestlineitem: 'standard:product_request_line_item',
    productrequired: 'standard:product_required',
    producttransfer: 'standard:product_transfer',
    productwarrantyterm: 'standard:product_warranty_term',
    recordsetfiltercriteria: 'standard:filter_criteria',
    returnorder: 'standard:return_order',
    returnorderlineitem: 'standard:return_order_line_item',
    shipment: 'standard:shipment',
    servicecontract: 'standard:service_contract',
    task: 'standard:task',
    warrantyterm: 'standard:warranty_term',
    workorder: 'standard:work_order',
    workorderlineitem: 'standard:work_order_item',
    worktype: 'standard:work_type',
    user: 'standard:user',
};

export const OPERATOR_TYPES = {
    EQUALS: 'eq',
    NOT_EQUALS: 'ne',
    GREATER_THAN: 'gt',
    GREATER_THAN_OR_EQUAL: 'ge',
    LESS_THAN: 'lt',
    LESS_THAN_OR_EQUAL: 'le',
    STARTS_WITH: 'starts',
    CONTAINS: 'contains',
    DOES_NOT_CONTAIN: 'notcontain',
    IS_NULL: 'isnull',
    IS_NOT_NULL: 'isnotnull',
    INCLUDES: 'in',
    EXCLUDES: 'notin'
};

export const OPERATOR_MAP = {
    eq: labelEquals,
    ne: labelNotEquals,
    gt: labelGreaterThan,
    ge: labelGreaterThanOrEqual,
    lt: labelLessThan,
    le: labelLessThanOrEqual,
    starts: labelStartsWith,
    contains: labelContains,
    notcontain: labelDoesNotContain,
    isnull: labelIsNull,
    isnotnull: labelIsNotNull,
    in: labelIncludes,
    notin: labelExcludes,
    and: labelAnd,
    or: labelOr,

};

export const ADMIN_MODULES = {
    EXPRESSION: 'Expression',
    MAPPING: 'Mapping',
    ASSET_HIERARCHY: 'Asset Hierarchy',
    ASSET_TIMELINE: 'Asset Timeline',
    WARRANTY_MANAGEMENT_SETTINGS: 'Warranty Management Settings',
    ENTITLEMENT_SETTINGS: 'Entitlement Settings',
    PSC_CONFIGURATION_TEMPLATES: 'PSC Congfiguration Templates',
    PRODUCT_SERVICE_CAMPAIGNS_SETTINGS: 'Product Service Campaigns Settings',
    DEPOT_SETTINGS: 'Depot Settings',
    TRANSLATIONS: 'Translations',
    WIZARD: 'Wizard',
    AUTOMATIC_RULES: 'Automatic Rules',
    INTERACTIVE_ENTITLEMENT: 'Interactive Entitlement',
    ENTITLEMENT_SERVICE_ASSIGNMENT_RULES: 'Entitlement Service Assignment Rules',
    PRICEBOOK_ASSIGNMENT_RULES: 'Priceboook Assignment Rules',
    TRANSACTION: 'Transaction',
    SCREEN: 'Screen',
    USAGE_STATISTICS: 'Usage Statistics',
    WARRANTY_MANAGEMENT: 'Warranty Management',
    DEPOT: 'Depot',
    CONFIGURATION_TEMPLATES: 'Configuration Templates',
    PRODUCT_SERVICE_CAMPAIGNS: 'Product Service Campaigns',
    LOOKUP_FILTER: 'Lookup Filter',
    VISIBILITY_CRITERIA: 'Visibility Criteria',
    DEBUG_TRANSACTIONS: 'Debug Transactions',
    TEMPLATE_RULES: 'Template Rules',
    TECHNICAL_ATTRIBUTE_SETTINGS: 'Technical Atrribute Settings',
    MAINTENANCE_PLAN_PROCESS: 'Maintenance Plan'

};

export const OPERATOR_OPTIONS_BY_TYPE = {
    [OPERATOR_TYPES.EQUALS]: { label: labelEquals, value: OPERATOR_TYPES.EQUALS },
    [OPERATOR_TYPES.NOT_EQUALS]: { label: labelNotEquals, value: OPERATOR_TYPES.NOT_EQUALS },
    [OPERATOR_TYPES.GREATER_THAN]: { label: labelGreaterThan, value: OPERATOR_TYPES.GREATER_THAN },
    [OPERATOR_TYPES.GREATER_THAN_OR_EQUAL]: {
        label: labelGreaterThanOrEqual,
        value: OPERATOR_TYPES.GREATER_THAN_OR_EQUAL
    },
    [OPERATOR_TYPES.LESS_THAN]: { label: labelLessThan, value: OPERATOR_TYPES.LESS_THAN },
    [OPERATOR_TYPES.LESS_THAN_OR_EQUAL]: {
        label: labelLessThanOrEqual,
        value: OPERATOR_TYPES.LESS_THAN_OR_EQUAL
    },
    [OPERATOR_TYPES.STARTS_WITH]: { label: labelStartsWith, value: OPERATOR_TYPES.STARTS_WITH },
    [OPERATOR_TYPES.CONTAINS]: { label: labelContains, value: OPERATOR_TYPES.CONTAINS },
    [OPERATOR_TYPES.DOES_NOT_CONTAIN]: {
        label: labelDoesNotContain,
        value: OPERATOR_TYPES.DOES_NOT_CONTAIN
    },
    [OPERATOR_TYPES.IS_NULL]: { label: labelIsNull, value: OPERATOR_TYPES.IS_NULL },
    [OPERATOR_TYPES.IS_NOT_NULL]: { label: labelIsNotNull, value: OPERATOR_TYPES.IS_NOT_NULL },
    [OPERATOR_TYPES.INCLUDES]: { label: labelIncludes, value: OPERATOR_TYPES.INCLUDES },
    [OPERATOR_TYPES.EXCLUDES]: { label: labelExcludes, value: OPERATOR_TYPES.EXCLUDES }
};

const stringOperatorTemplate = [
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.EQUALS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.NOT_EQUALS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.GREATER_THAN],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.GREATER_THAN_OR_EQUAL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.LESS_THAN],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.LESS_THAN_OR_EQUAL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.STARTS_WITH],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.CONTAINS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.DOES_NOT_CONTAIN],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NULL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NOT_NULL]
]

const TEXTOPERATORTEMPLATE = [
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.EQUALS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.NOT_EQUALS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.STARTS_WITH],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.CONTAINS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.DOES_NOT_CONTAIN],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NULL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NOT_NULL]
]

const numberOperatorTemplate = [
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.EQUALS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.NOT_EQUALS],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.GREATER_THAN],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.GREATER_THAN_OR_EQUAL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.LESS_THAN],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.LESS_THAN_OR_EQUAL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NULL],
    OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NOT_NULL]
]

export const OPERATOR_OPTIONS_BY_FIELD_TYPE = {
    [FIELD_DATA_TYPES.ADDRESS]: stringOperatorTemplate,
    [FIELD_DATA_TYPES.BASE64]: [],
    [FIELD_DATA_TYPES.BOOLEAN]: [
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.EQUALS],
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.NOT_EQUALS]
    ],
    [FIELD_DATA_TYPES.CURRENCY]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.DATE]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.DATETIME]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.DOUBLE]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.EMAIL]: stringOperatorTemplate,
    [FIELD_DATA_TYPES.ENCRYPTEDSTRING]: [],
    [FIELD_DATA_TYPES.INTEGER]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.LONG]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.MULTIPICKLIST]: [
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.EQUALS],
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.NOT_EQUALS],
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NULL],
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.IS_NOT_NULL],
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.INCLUDES],
        OPERATOR_OPTIONS_BY_TYPE[OPERATOR_TYPES.EXCLUDES],
    ],
    [FIELD_DATA_TYPES.PERCENT]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.PHONE]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.ID]: stringOperatorTemplate,
    [FIELD_DATA_TYPES.PICKLIST]: stringOperatorTemplate,
    [FIELD_DATA_TYPES.REFERENCE]: stringOperatorTemplate,
    [FIELD_DATA_TYPES.STRING]: TEXTOPERATORTEMPLATE,
    [FIELD_DATA_TYPES.TEXTAREA]: TEXTOPERATORTEMPLATE,
    [FIELD_DATA_TYPES.TIME]: numberOperatorTemplate,
    [FIELD_DATA_TYPES.URL]: TEXTOPERATORTEMPLATE,
}

export const OPERATOR_VALUE = {
    CONTAINS: 'Contains',
    STARTS_WITH: 'Starts With',
    ENDS_WITH: 'Ends With',
    EXACT_MATCH: 'Exact Match'
}

export const SEARCH_TEXT_OPERATOR_TYPES = new Set(
    [
        OPERATOR_TYPES.CONTAINS,
        OPERATOR_TYPES.DOES_NOT_CONTAIN,
        OPERATOR_TYPES.STARTS_WITH
    ]
)

export const TEXTOPERATORS = new Set(
    [
        OPERATOR_TYPES.EQUALS,
        OPERATOR_TYPES.NOT_EQUALS,
        OPERATOR_TYPES.STARTS_WITH,
        OPERATOR_TYPES.CONTAINS,
        OPERATOR_TYPES.DOES_NOT_CONTAIN,
        OPERATOR_TYPES.IS_NULL,
        OPERATOR_TYPES.IS_NOT_NULL
    ]
)

export const STEP_TYPES = {
    FLOW: 'Flow',
    LWC: 'Lightning Web Component',
    TRANSACTION: 'SPM Transaction',
    URL: 'url',
    RECORDACTION: 'Record Action'
}

export const STEP_PARAMETER_TYPES = {
    FIELD_NAME: 'Field',
    VALUE: 'Value'
}

export const UNSUPPORTED_FIELD_TYPES = new Set([
    FIELD_DATA_TYPES.BASE64,
    FIELD_DATA_TYPES.ADDRESS,
    FIELD_DATA_TYPES.LOCATION
])

export const EXPRESSION = {
    EXPRESSION_TYPE: 'EVER-RULE-CRITERIA',
    TYPE: 'Standard Expression',
    VISIBILITY_RULE_CRITERIA: 'VISIBILITY-RULE-CRITERIA',
    CONFIGURATION_FILTER: 'CONFIGURATION-FILTER',
}

export const FIELD_API_NAMES = {
    CURRENCY_ISO_CODE: 'CurrencyIsoCode',
    RECORD_TYPE_ID: 'RecordTypeId',
    PRODUCT2ID: 'Product2Id',
    QUANTITY: 'Quantity',
}

export const STEP_TYPE_ICONS = {
    [STEP_TYPES.FLOW]: 'utility:flow',
    [STEP_TYPES.TRANSACTION]: 'utility:builder',
    [STEP_TYPES.LWC]: 'standard:lightning_component',
    [STEP_TYPES.URL]: 'standard:link',
    [STEP_TYPES.RECORDACTION]: 'standard:lightning_component',
};

export const CUSTOM_FIELD_DATA_TYPES = {
    X_LOOKUP: 'xLookup',
    X_CHECKBOX: 'xCheckbox',
    X_TEXTAREA: 'xTextarea',
    X_PICKLIST: 'xPicklist'
}

export const UNSUPPORTED_UI_API_OBJECTS =  new Set([
    'BusinessHours'
]);

export const PAGE_ELEMENT_TYPES = {
    BUTTON: 'Button'
};

export const PAGE_ELEMENT_EVENT_TYPES = {
    CLICK: 'Button Click'
};

export const PAGE_ELEMENT_ACTION_TYPES = {
    INVOKE_WEBSERVICE: 'Invoke Webservice',
    INVOKE_JAVASCRIPT: 'Invoke Javascript',
};

export const PAGE_ELEMENT_STATIC_ACTIONS = {
    EDIT_SCREEN: {
        label: labelEditScreen,
        name: "editScreen",
        icon: "",
    },
    EDIT_TRANSACTION: {
        label: labelEditTransaction,
        name: "editTransaction",
        icon: "",
    },
    DEBUG_TRANSACTION: {
        label: labelEnableDebug,
        name: "enableDebug",
        icon: "",
    },
};