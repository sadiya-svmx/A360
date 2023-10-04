import { publishIntent } from 'c/runtimePubSub';

export const INTENTS = {
    LOCK_PAGE_SCROLL: 'LOCK_PAGE_SCROLL',
    UNLOCK_PAGE_SCROLL: 'UNLOCK_PAGE_SCROLL',
    SET_HEIGHT_OFFSET: 'SET_HEIGHT_OFFSET'
};

export function lockPageScroll (applicationId) {
    publishIntent(applicationId, INTENTS.LOCK_PAGE_SCROLL);
}

export function unlockPageScroll (applicationId) {
    publishIntent(applicationId, INTENTS.UNLOCK_PAGE_SCROLL);
}

export function setHeightOffset (applicationId, offsetValue) {
    publishIntent(applicationId, INTENTS.SET_HEIGHT_OFFSET, offsetValue);
}