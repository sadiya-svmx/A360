/* eslint-disable @lwc/lwc/no-rest-parameter */
/* eslint-disable @lwc/lwc/no-for-of */

import { classSet } from './classSet';

class DisplayToken {
    constructor (value, index = 0, sequence) {
        this.index = index;
        this.value = value;
        this.sequence = sequence;

        this.isSingleLine = false;
        this.isWeak = false;
        this.isStrong = false;
        this.hasLeftPadding = false;
        this.hasRightPadding = true;
        this.isTerminator = false;
    }

    singleLine (value = true) {
        this.isSingleLine = !!value;
        return this;
    }

    weak (value = true) {
        this.isWeak = !!value;
        return this;
    }

    strong (value = true) {
        this.isWeak = !value;
        this.isStrong = !!value;
        return this;
    }

    leftPadding (value = true) {
        this.hasLeftPadding = value;
        return this;
    }

    rightPadding (value = true) {
        this.hasRightPadding = value;
        return this;
    }

    terminator (value = true) {
        this.isTerminator = value;
        return this;
    }

    add (value) {
        return this.sequence.add(value);
    }

    get classList () {
        return classSet({
            'svmx-display_block': this.isSingleLine,
            'svmx-display_inline-block': !this.isSingleLine,
            'svmx-text-color_weak': this.isWeak,
            'svmx-text-color_strong': this.isStrong,
            'slds-m-left_xx-small': this.hasLeftPadding,
            'slds-m-right_xx-small': this.hasRightPadding
        }).toString();
    }
}

class TokenSequence {
    constructor () {
        this.tokens = [];
    }

    add (value) {
        const nextToken = new DisplayToken(value, this.tokens.length, this);
        this.tokens.push(nextToken);
        return nextToken;
    }

    addFromToken (token) {
        token.index = this.tokens.length;
        token.sequence = this;
        this.tokens.push(token);
        return token;
    }

    addFromSequence (sequence) {
        for (const token of sequence.tokens) {
            this.addFromToken(token);
        }
        sequence.tokens.length = 0;
    }

    first () {
        return this.tokens.at(0);
    }

    last () {
        return this.tokens.at(-1);
    }
}

export function createDisplayTokenSequence () {
    return new TokenSequence();
}

export function joinDisplayTokenSequences (...sequences) {
    const newSequence = new TokenSequence();
    for (const sequence of sequences) {
        for (const token of sequence.tokens) {
            newSequence.addFromToken(token);
        }
    }
    return newSequence;
}