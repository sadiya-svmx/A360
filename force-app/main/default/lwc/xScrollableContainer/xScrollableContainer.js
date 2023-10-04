import { LightningElement, api } from 'lwc';

import {
    ComponentMixin, RegisterComponent, ComponentRegistered, ApplicationId,
    INTENTS
} from 'c/xApplication';

import {
    subscribeToIntents,
    unsubscribeFromIntents
} from 'c/runtimePubSub';

export default class XScrollableContainer extends ComponentMixin(LightningElement) {
    connectedCallback () {
        this[RegisterComponent]();
    }

    [ComponentRegistered] () {
        this.subscribeToApplicationIntents();
    }

    disconnectedCallback () {
        this.unsubscribeFromApplicationIntents();
    }

    @api
    lockPageScroll () {
        const scrollable = this.template.querySelector('.svmx-scrollable');
        scrollable.classList.add('scroll-locked');
    }

    @api
    unlockPageScroll () {
        const scrollable = this.template.querySelector('.svmx-scrollable');
        scrollable.classList.remove('scroll-locked');
    }

    @api
    setHeightOffset (heightOffset) {
        this.heightOffset = heightOffset;
    }

    heightOffset;
    get styleOverrides () {
        if (this.heightOffset) {
            const maxHeightCalc = `calc(100vh - ${this.heightOffset})`;
            return `max-height: ${maxHeightCalc}; height: ${maxHeightCalc};`;
        }
        return '';
    }

    subscribeToApplicationIntents () {
        subscribeToIntents(
            this[ApplicationId], {
                [INTENTS.LOCK_PAGE_SCROLL]: this.lockPageScroll.bind(this),
                [INTENTS.UNLOCK_PAGE_SCROLL]: this.unlockPageScroll.bind(this),
                [INTENTS.SET_HEIGHT_OFFSET]: this.setHeightOffset.bind(this)
            }
        );
    }

    unsubscribeFromApplicationIntents () {
        unsubscribeFromIntents(
            this[ApplicationId], {
                [INTENTS.LOCK_PAGE_SCROLL]: this.lockPageScroll,
                [INTENTS.UNLOCK_PAGE_SCROLL]: this.unlockPageScroll,
                [INTENTS.SET_HEIGHT_OFFSET]: this.setHeightOffset
            }
        );
    }
}