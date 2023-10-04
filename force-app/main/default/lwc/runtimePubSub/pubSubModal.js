import {
    getNestedValue,
    setNestedValue
} from 'c/utils';


export const HEADER = 'HEADER';
export const GRID = 'GRID';
/**
 * structure of =>  ChangeDetectionState = {
    engineId1: {
        HEADER:  {
        'field-name': 'latestMutatedValue'
        },
        GRID: {
            tabIndex: {
                rowIndex: { 'field-name': 'latestMutatedValue' }
            }
        },
    },
    engineId2: {
        HEADER:  {
        'field-name': 'latestMutatedValue'
        },
        GRID: {
            tabIndex: {
                rowIndex: { 'field-name': 'latestMutatedValue' }
            }
        },
    },
};
 */
/**
 * structure of => Observers = {
    engineId1: {
        HEADER:  {
        'field-name': []
        },
        GRID: {
            rowIndex: { 'field-name': []}
        },
    },
    engineId2: {
        HEADER:  {
        'field-name': []
        },
        GRID: {
            rowIndex: { 'field-name': []}
        },
    },
};
 */
const ChangeDetectionState = {
};

const ChangeDetectionStateListeners = {
};

let lookupResolvedState = {
};

let rowSelectionState = {
};

const VALID_SECTIONS = [HEADER, GRID];

function validatePathDescriptors ({
    whichSection
}) {
    if (!VALID_SECTIONS.includes(whichSection)) {
        throw new Error('Invalid section name specified. Must be one of the following: [' +
            VALID_SECTIONS.join(', ') + ']');
    }
}

function validateSubscriber (subscriber) {
    if (!(subscriber instanceof Function)) {
        throw new Error('Invalid subscriber. Cannot be null and must be of type \'function\'.');
    }
}

function getPathString ({
    engineId,
    whichSection = HEADER,
    fieldName,
    tabIndex = null,
    rowIndex = null,
}) {
    validatePathDescriptors({ whichSection, fieldName });

    let pathStringParts = engineId ? [engineId] : [];

    if (whichSection === HEADER) {
        pathStringParts.push(whichSection);
    } else if (whichSection === GRID) {
        pathStringParts = pathStringParts.concat([
            whichSection,
            tabIndex,
            rowIndex
        ]);
    }

    if (fieldName) {
        pathStringParts.push(fieldName);
    }

    return pathStringParts.join('.');
}

function getSubscribersForPath (pathString) {
    if (!pathString) {
        throw new Error('Invalid path string. Must be a non-empty dot-delimited string.');
    }

    let subscribers = getNestedValue(ChangeDetectionStateListeners, pathString);
    if (!subscribers) {
        subscribers = setNestedValue(
            ChangeDetectionStateListeners,
            pathString,
            new Set()
        );
    }

    return subscribers;
}

function getSubscribers ({
    engineId,
    whichSection,
    fieldName,
    tabIndex,
    rowIndex
}) {
    const pathString = getPathString({ engineId, whichSection, fieldName, tabIndex, rowIndex });
    return getSubscribersForPath(pathString);
}


export const subscribe = ({
    engineId,
    whichSection = HEADER,
    fieldName,
    tabIndex = null,
    rowIndex = null,
    subscriber
}) => {
    validateSubscriber(subscriber);
    const subscribers = getSubscribers({ engineId, whichSection, fieldName, tabIndex, rowIndex });
    subscribers.add(subscriber);
    // Pass through the current value on subscriber init
    subscriber(
        getNestedValue(
            ChangeDetectionState,
            getPathString({ engineId, whichSection, fieldName, tabIndex, rowIndex })
        )
    );
};


export const unsubscribe = ({
    engineId,
    whichSection = HEADER,
    fieldName,
    tabIndex = null,
    rowIndex = null,
    subscriber
}) => {
    validateSubscriber(subscriber);
    const subscribers = getSubscribers({ engineId, whichSection, fieldName, tabIndex, rowIndex });
    subscribers.delete(subscriber);
};


export const publish = ({
    engineId,
    whichSection = HEADER,
    fieldName,
    tabIndex = null,
    rowIndex = null,
    value
}) => {
    const subscribers = getSubscribers({ engineId, whichSection, fieldName, tabIndex, rowIndex });
    subscribers.forEach(subscriber => {
        subscriber(value);
    });
}


export const registerRuntimeFieldValueChange = ({
    engineId,
    whichSection = HEADER,
    fieldName = 'Dummy',
    value ='',
    rowIndex = null,
    tabIndex = null,
}) => {
    // Store the latest state in the change detection object
    setNestedValue(
        ChangeDetectionState,
        getPathString({ engineId, whichSection, fieldName, tabIndex, rowIndex }),
        value
    );

    // Notify all subscribers of the value change
    publish({ engineId, whichSection, fieldName, tabIndex, rowIndex, value });
}

export const pullRuntimeFieldValueChange = ({
    engineId,
    whichSection = '',
    fieldName = '',
    rowIndex = null,
    tabIndex = null,
}) => {
    return getNestedValue(
        ChangeDetectionState,
        getPathString({ engineId, whichSection, fieldName, tabIndex, rowIndex })
    );
};

export const registerRuntimeGridValues = ({
    engineId,
    whichSection = '',
    fieldName = '',
    value ='',
    rowIndex = null,
    tabIndex = null,
}) => {
    registerRuntimeFieldValueChange({
        engineId,
        whichSection,
        fieldName,
        value,
        rowIndex,
        tabIndex,
    });
};

export const getSectionData = ({
    engineId,
    whichSection = '',
    tabIndex = null,
    rowIndex = null
}) => {
    return getNestedValue(
        ChangeDetectionState,
        getPathString({ engineId, whichSection, tabIndex, rowIndex })
    );
}

export const clearPubSubCache = (engineId) => {
    if (engineId) {
        if (ChangeDetectionState[engineId]) {
            delete ChangeDetectionState[engineId];
        }
        if (ChangeDetectionStateListeners[engineId]) {
            delete ChangeDetectionStateListeners[engineId];
        }
        if (lookupResolvedState[engineId]) {
            delete lookupResolvedState[engineId];
        }
        if (rowSelectionState[engineId]) {
            delete rowSelectionState[engineId];
        }
    } else {
        ChangeDetectionState.HEADER = {};
        ChangeDetectionState.GRID = {};
        ChangeDetectionStateListeners.HEADER = {};
        ChangeDetectionStateListeners.GRID = {};
        lookupResolvedState = {};
        rowSelectionState = {};
    }
};

export const setResolvedLookupState = (engineId, value, label) => {
    if (engineId) {
        lookupResolvedState[engineId] = lookupResolvedState[engineId] || {};
        lookupResolvedState[engineId][value] = label;
    } else {
        lookupResolvedState[value] = label;
    }
}

export const getResolvedLookupState = (engineId) => {
    return engineId? lookupResolvedState[engineId]: lookupResolvedState;
}

export const getResolvedLookupValue = (engineId, value) => {
    return engineId ? lookupResolvedState[engineId]?.[value] : lookupResolvedState[value];
}

export const setRowSelectionState = (engineId, value, selectedIds) => {
    if (engineId) {
        rowSelectionState[engineId] = rowSelectionState[engineId] || {};
        rowSelectionState[engineId][value] = selectedIds;
    } else {
        rowSelectionState[value] = selectedIds;
    }
}

export const getRowSelectionIds = (engineId, value) => {
    return engineId ? rowSelectionState[engineId]?.[value] : rowSelectionState[value];
}