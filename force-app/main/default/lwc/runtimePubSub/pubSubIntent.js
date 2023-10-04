/*
{
    applicationId1: {
        intent1: [
            () => {},
            () => {}
        ],
        intent2: [
            () => {},
            () => {},
            () => {}
        ]
    },
    applicationId2: {
        intent1: [
            () => {},
            () => {},
            () => {}
        ],
        intent2: []
    }
}
*/
const IntentListeners = {};

const DEFAULT_APPLICATION_ID = 'ALL';

export const subscribeToIntent =
(applicationId = DEFAULT_APPLICATION_ID, intentName, subscriber) => {
    if (!intentName) {
        throw new Error('Intent name is required.');
    }

    if (!subscriber) {
        throw new Error('Subscriber function is required.');
    }

    let entryForEngine = IntentListeners[applicationId];
    if (!entryForEngine) {
        entryForEngine = {};
        IntentListeners[applicationId] = entryForEngine;
    }

    let entryForIntent = entryForEngine[intentName];
    if (!entryForIntent) {
        entryForIntent = new Set();
        entryForEngine[intentName] = entryForIntent;
    }
    entryForIntent.add(subscriber);
};

export const subscribeToIntents =
(applicationId = DEFAULT_APPLICATION_ID, intentSubscriberMap = {}) => {
    Object.keys(intentSubscriberMap).forEach(intentName => {
        const subscriber = intentSubscriberMap[intentName];
        subscribeToIntent(applicationId, intentName, subscriber);
    });
};

export const unsubscribeFromIntent =
(applicationId = DEFAULT_APPLICATION_ID, intentName, subscriber) => {
    if (!intentName) {
        throw new Error('Intent name is required.');
    }

    if (!subscriber) {
        throw new Error('Subscriber function is required.');
    }

    // eslint-disable-next-line no-unused-expressions
    IntentListeners[applicationId]?.[intentName]?.delete(subscriber);
};

export const unsubscribeFromIntents =
(applicationId = DEFAULT_APPLICATION_ID, intentSubscriberMap = {}) => {
    Object.keys(intentSubscriberMap).forEach(intentName => {
        const subscriber = intentSubscriberMap[intentName];
        unsubscribeFromIntent(applicationId, intentName, subscriber);
    });
};

// eslint-disable-next-line @lwc/lwc/no-rest-parameter
export const publishIntent = (applicationId, intentName, ...values) => {
    // eslint-disable-next-line no-unused-expressions
    IntentListeners[applicationId]?.[intentName]?.forEach(listener => listener(...values));
};