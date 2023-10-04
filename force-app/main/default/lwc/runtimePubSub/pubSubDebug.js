import { deepCopy } from 'c/utils';


const DEBUG_SYMBOL_PREFIX = 'SVMX_DEBUG';
export const DEBUG_INSTANCE_ID_PROPNAME = Symbol.for(`@@${DEBUG_SYMBOL_PREFIX}_prop_instanceId`);
const generateDebugSymbol = (applicationId, key) =>
    Symbol.for(`@@${DEBUG_SYMBOL_PREFIX}.${applicationId}.${key}@@`);

const getApplicationIdForSymbol = debugSymbol => Symbol.keyFor(debugSymbol).split('.')[1];

/**
 * Stores debug state entries for each registered debug symbol
 * {
 *      'instanceId1': DebugStateEntry(),
 *      'instanceId2': DebugStateEntry(),
 *      ...
 * }
 * {
 *      'instanceId1': [
 *          {
 *              snapshotProp1: 'test',
 *              snapshotProp2: 123.456,
 *              snapshotProp3: true,
 *              snapshotProp4: new Date(),
 *          },
 *          ...
 *      ],
 *      'instanceId2': [
 *          {
 *              snapshotPropA: 'test',
 *              snapshotPropB: 'test2',
 *              snapshotPropC: 'test3'
 *          },
 *          ...
 *      ],
 *      ...
 * }
 */
const DEBUG_STATE = new Map();

/**
 * Stores debug snapshots and settings for a single debug symbol
 * DebugStateEntry {
 *      debugSymbol: Symbol.for('@@SVMX_DEBUG.applicationId.componentKey@@'),
 *      debuggingEnabled: true|false,
 *      maxSnapshotsPerInstance: Number (default: Infinity),
 *      snapshotsByInstanceId: {
 *          'componentInstanceId1': [
 *             {
 *                  snapshotProp1: 'test',
 *                  snapshotProp2: 123.456,
 *                  snapshotProp3: true,
 *                  snapshotProp4: new Date(),
 *              },
 *              ...
 *          ],
 *          'componentInstanceId2': [
 *              {
 *                  snapshotPropA: 'test',
 *                  snapshotPropB: 'test2',
 *                  snapshotPropC: 'test3'
 *              },
 *              ...
 *          ],
 *          ...
 *      },
 *      subscribers: Set(
 *          () => {...},
 *          () => {...},
 *          ...
 *      )
 * }
 */
class DebugStateEntry {
    constructor (debugSymbol, debuggingEnabled = true, maxSnapshotsPerInstance = Infinity) {
        this.debugSymbol = debugSymbol;
        this.debuggingEnabled = debuggingEnabled;
        this.snapshotsByInstanceId = new Map();
        this.subscribers = new Set();
        this.maxSnapshotsPerInstance = maxSnapshotsPerInstance;
    }

    enableDebugging () {
        this.debuggingEnabled = true;
    }

    disableDebugging () {
        this.debuggingEnabled = false;
    }

    setMaxSnapshotsPerInstance (maxSnapshotsPerInstance) {
        if (maxSnapshotsPerInstance !== this.maxSnapshotsPerInstance) {
            this.maxSnapshotsPerInstance = maxSnapshotsPerInstance;

            if (this._trimSnapshots()) {
                this._pushToSubscribers();
            }
        }
    }

    pushSnapshot (instanceId, snapshot) {
        if (this.debuggingEnabled) {
            snapshot[DEBUG_INSTANCE_ID_PROPNAME] = instanceId;

            if (!this.snapshotsByInstanceId.has(instanceId)) {
                this.snapshotsByInstanceId.set(instanceId, []);
            }
            this.snapshotsByInstanceId.get(instanceId).push(snapshot);

            this._trimSnapshots();
            this._pushToSubscribers();
        }
    }

    clearSnapshots () {
        this.snapshotsByInstanceId.clear();

        if (this.debuggingEnabled) {
            this._pushToSubscribers();
        }
    }

    getSnapshots () {
        return [...this.snapshotsByInstanceId.values()].flat();
    }

    registerSubscriber (subscriber) {
        this.subscribers.add(subscriber);
        this._pushToSubscriber(subscriber);
    }

    removeSubscriber (subscriber) {
        this.subscribers.delete(subscriber);
    }

    _pushToSubscriber (subscriber, snapshots = this.getSnapshots()) {
        if (this.debuggingEnabled) {
            subscriber(snapshots);
        }
    }

    _pushToSubscribers () {
        this.subscribers.forEach(subscriber => this._pushToSubscriber(subscriber));
    }

    _trimSnapshots () {
        let trimmedSnapshots = false;

        this.snapshotsByInstanceId.forEach(snapshotsForInstance => {
            if (snapshotsForInstance.length > this.maxSnapshotsPerInstance) {
                snapshotsForInstance.splice(
                    0, snapshotsForInstance.length - this.maxSnapshotsPerInstance
                );
                trimmedSnapshots = true;
            }
        })

        return trimmedSnapshots;
    }
}

/**
 * Generates a new debug symbol, or returns a prexisting one, for the given parameters
 * @param {String} applicationId - Unique Id to differentiate between "applications" in a page
 * @param {String} key - Component key used to differentiate between "components" in an application
 * @param {Boolean} enabledByDefault - Controls whether debugging is enabled for this symbol
 * @param {Number} maxSnapshotsPerInstance - Maximum number of stored snapshots per-instance
 * @returns {Symbol} - Unique symbol to be used as an anchor for sending/receiving debug snapshots
 */
export const getDebugSymbol = (applicationId, key, enabledByDefault, maxSnapshotsPerInstance) => {
    const debugSymbol = generateDebugSymbol(applicationId, key);

    if (!DEBUG_STATE.has(debugSymbol)) {
        const debugStateEntry = new DebugStateEntry(
            debugSymbol,
            enabledByDefault,
            maxSnapshotsPerInstance
        );
        DEBUG_STATE.set(debugSymbol, debugStateEntry);
    } else {
        const debugStateEntry = DEBUG_STATE.get(debugSymbol);

        if (enabledByDefault != null) {
            if (enabledByDefault) {
                debugStateEntry.enableDebugging();
            } else {
                debugStateEntry.disableDebugging();
            }
        }

        if (maxSnapshotsPerInstance != null) {
            debugStateEntry.setMaxSnapshotsPerInstance(maxSnapshotsPerInstance);
        }
    }

    return debugSymbol;
};

/**
 * Validates that a given debug symbol is valid and has been registered
 * @param {Symbol} debugSymbol - The debug symbol to validate
 */
const validateDebugSymbol = debugSymbol => {
    if (!debugSymbol) {
        throw new Error('Debug symbol cannot be null');
    }

    if (!DEBUG_STATE.has(debugSymbol)) {
        throw new Error('Invalid or unrecognized debug symbol');
    }
};

/**
 * Validates that a given subscriber is a non-null function
 * @param {Function} subscriber - The subscriber function to validate
 */
const validateSubscriber = subscriber => {
    if (!subscriber) {
        throw new Error('Debug state subscriber cannot be null');
    }

    if (typeof subscriber !== 'function') {
        throw new Error('Debug state subscriber must be a function');
    }
};

/**
 * Validates that a given snapshot is not null
 * @param {Object} snapshot - The snapshot to validate
 */
const validateSnapshot = snapshot => {
    if (!snapshot) {
        throw new Error('Debug snapshot cannot be null');
    }
};

/**
 * Stores the enabled/disabled debugging state by application id
 */
const DEBUG_MODE_FLAG_BY_APPLICATION_ID = new Map();

/**
 * Stores registered subscribers for the debugging enabled/disabled state at the application level
 */
const DEBUG_MODE_SUBSCRIBERS = new Map();

/**
 * Enables debugging for the specified application
 * @param {String} applicationId - The id of the application to enable debugging for
 */
export const enableDebugging = applicationId => {
    DEBUG_MODE_FLAG_BY_APPLICATION_ID.set(applicationId, true);

    const subscribers = DEBUG_MODE_SUBSCRIBERS.get(applicationId);
    if (subscribers?.size) {
        subscribers.forEach(subscriber => subscriber(true));
    }
};

/**
 * Disables debugging for the specified application
 * @param {String} applicationId - The id of the application to disable debugging for
 */
export const disableDebugging = applicationId => {
    DEBUG_MODE_FLAG_BY_APPLICATION_ID.set(applicationId, false);

    const subscribers = DEBUG_MODE_SUBSCRIBERS.get(applicationId);
    if (subscribers?.size) {
        subscribers.forEach(subscriber => subscriber(false));
    }
};

/**
 * Checks if debugging is enabled for the given application
 * @param {String} applicationId - The id of the application to check the debugging state for
 * @returns {Boolean} - True if the given application is enabled for debugging, false otherwise
 */
export const isDebuggingEnabled = applicationId =>
    DEBUG_MODE_FLAG_BY_APPLICATION_ID.get(applicationId) === true;

/**
 * Registers the subscriber function to the debugging enabled state for the given application.
 * The subscriber will be called immediately with the new enabled state on any change.
 * @param {String} applicationId - The id of the application to register the subscriber for
 * @param {Function} subscriber - The subscriber function to register
 */
export const registerDebuggingEnabledSubscriber = (applicationId, subscriber) => {
    validateSubscriber(subscriber);

    if (!DEBUG_MODE_SUBSCRIBERS.has(applicationId)) {
        DEBUG_MODE_SUBSCRIBERS.set(applicationId, new Set());
    }

    DEBUG_MODE_SUBSCRIBERS.get(applicationId).add(subscriber);
    subscriber(DEBUG_MODE_FLAG_BY_APPLICATION_ID.get(applicationId) ?? false);
};

/**
 * Deregisters the subscriber function to the debugging enabled state for the given application.
 * @param {String} applicationId - The id of the application to deregister the subscriber for
 * @param {Function} subscriber - The subscriber function to deregister
 */
export const deregisterDebuggingEnabledSubscriber = (applicationId, subscriber) => {
    validateSubscriber(subscriber);

    if (!DEBUG_MODE_SUBSCRIBERS.has(applicationId)) {
        return;
    }

    DEBUG_MODE_SUBSCRIBERS.get(applicationId).delete(subscriber);
};

/**
 * Gets the DebugStateEntry instance for the given debug symbol
 * @param {Symbol} debugSymbol - The debug symbol to retrieve the DebugStateEntry for
 * @returns {DebugStateEntry} - The corresponding DebugStateEntry for the given debugSymbol
 */
const getDebugStateEntry = debugSymbol => {
    validateDebugSymbol(debugSymbol);
    return DEBUG_STATE.get(debugSymbol);
};

/**
 * Enables debugging for a specific debug symbol
 * @param {Symbol} debugSymbol - The debug symbol to enable debugging for
 */
export const enableDebuggingFor = debugSymbol => {
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    debugStateEntry.enableDebugging();
};

/**
 * Disables debugging for a specific debug symbol
 * @param {Symbol} debugSymbol - The debug symbol to disable debugging for
 */
export const disableDebuggingFor = debugSymbol => {
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    debugStateEntry.disableDebugging();
};


/**
 * Pushes the given debug snapshot into the list of stored snapshots for the given debug symbol and
 * instance id.
 * @param {Symbol} debugSymbol - Debug symbol the new snapshot should be registered for
 * @param {String} instanceId - Component instance id the new snapshot should be registered for
 * @param {Object} snapshot - Debug snapshot data as a JavaScript Object (any internal format)
 */
export const pushDebugSnapshot = (debugSymbol, instanceId, snapshot) => {
    const applicationId = getApplicationIdForSymbol(debugSymbol);
    if (!isDebuggingEnabled(applicationId)) {
        return;
    }

    validateSnapshot(snapshot);
    const snapshotCopy = deepCopy(snapshot);
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    debugStateEntry.pushSnapshot(instanceId, snapshotCopy);
};

/**
 * Retrieves the currently stored snapshots for the given debug symbol (all component instances)
 * @param {Symbol} debugSymbol - The debug symbol to retrieve snapshots for
 * @returns {Array[Object]} - List of debug snapshots currently stored for the given symbol
 */
export const getDebugSnapshots = debugSymbol => {
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    return debugStateEntry.getSnapshots();
};

/**
 * Registers the given subscriber function with the given debug symbol.
 * The subscriber will be called immediately with a list of the current stored snapshots.
 * Any future change to the list of stored snapshots will cause the the subscriber function to be
 * called again with the full list of stored snapshots.
 * @param {Symbol} debugSymbol - The debug symbol to receive snapshots for
 * @param {Function} subscriber - The subscriber function to receive debug snapshots
 */
export const registerDebugStateSubscriber = (debugSymbol, subscriber) => {
    validateSubscriber(subscriber);
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    debugStateEntry.registerSubscriber(subscriber);
};

/**
 * Deregisters the given subscriber function with the given debug symbol.
 * The subscriber function will no longer be called with the list of updated snapshots when future
 * changes occur.
 * @param {Symbol} debugSymbol - The debug symbol that was used to register the subscriber function
 * @param {Function} subscriber - The subscriber function to deregister
 */
export const deregisterDebugStateSubscriber = (debugSymbol, subscriber) => {
    validateSubscriber(subscriber);
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    debugStateEntry.removeSubscriber(subscriber);
};

/**
 * Clears all stored snapshots (for all component instances) for the given debug symbol
 * @param {Symbol} debugSymbol - The debug symbol for which to clear all stored snapshots
 */
export const clearDebugSnapshots = debugSymbol => {
    const debugStateEntry = getDebugStateEntry(debugSymbol);
    debugStateEntry.clearSnapshots();
};