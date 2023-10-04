/* eslint-disable no-unused-expressions */
/* eslint-disable @lwc/lwc/no-rest-parameter */
/* eslint-disable @lwc/lwc/no-for-of */
import { LightningElement, api } from 'lwc';

import Label_ShowLess from '@salesforce/label/c.Label_ShowLess';
import Label_ShowMore from '@salesforce/label/c.Label_ShowMore';

const i18n = {
    showLess: Label_ShowLess,
    showMore: Label_ShowMore
};

export const DEFAULT_COLLAPSED_ROWS_VISIBLE = 5;

const SELECTOR = {
    ExpandCollapseLink: '[data-expandcollapselink]',
    DisplayTokenSequenceContainer: '[data-displaysequencecontainer]',
    DisplayToken: '[data-displaytoken]'
};

export default class DisplayTokenSequence extends LightningElement {
    _tokenSequence = [];
    @api set tokenSequence (value) {
        this._tokenSequence = value ?? [];
        this.handleTokenSequenceChanged();
    }

    get tokenSequence () {
        return this._tokenSequence;
    }

    get tokens () {
        return this.tokenSequence?.tokens ?? [];
    }

    get i18n () {
        return i18n;
    }

    isShowingMore = false;
    isCollapsible = true;

    toggleShowMore () {
        this.isShowingMore = !this.isShowingMore;
        this.template.querySelector(SELECTOR.ExpandCollapseLink)?.blur();
    }

    get expandCollapseLinkText () {
        return this.isShowingMore ? i18n.showLess : i18n.showMore;
    }

    rowHeight = null;
    collapsedHeight = null;
    recalculateRowHeight () {
        // NOTE: offsetHeight is used because tokens are guaranteed to have 0 top/bottom margins
        this.rowHeight = this.template.querySelector(SELECTOR.DisplayToken)?.offsetHeight;
        if (this.rowHeight != null && this.rowHeight > 0) {
            this.collapsedHeight = Math.ceil(this.rowHeight * DEFAULT_COLLAPSED_ROWS_VISIBLE);
            this.increaseCollapsedHeightToContainLine();
        } else {
            this.collapsedHeight = null;
        }
    }

    increaseCollapsedHeightToContainLine () {
        const displayTokenElems = this.template.querySelectorAll(SELECTOR.DisplayToken);
        if (displayTokenElems.length) {
            const upperBound = displayTokenElems[0].offsetTop;
            let lowerBound = upperBound;

            // Determine which token resides just before the collapsed boundary
            let tokenI = 0;
            while (
                tokenI < displayTokenElems.length &&
                (lowerBound - upperBound) <= this.collapsedHeight
            ) {
                const nextToken = displayTokenElems[tokenI];
                lowerBound = nextToken.offsetTop + nextToken.offsetHeight;
                tokenI++;
            }

            // Find the next closest terminator token from the boundary token
            tokenI--;
            while (
                tokenI < displayTokenElems.length &&
                displayTokenElems[tokenI].dataset.isterminator !== 'true'
            ) {
                tokenI++;
            }

            // Increase collapsed height to contain terminator token
            if (tokenI >= displayTokenElems.length) {
                tokenI = displayTokenElems.length - 1;
            }

            const terminatorToken = displayTokenElems[tokenI];
            lowerBound = terminatorToken.offsetTop + terminatorToken.offsetHeight;
            this.collapsedHeight = lowerBound - upperBound;
        }
    }

    totalHeight = null;
    recalculateTotalHeight () {
        this.totalHeight = this.template.querySelector(
            SELECTOR.DisplayTokenSequenceContainer
        )?.offsetHeight;

        if (this.collapsedHeight == null) {
            this.isCollapsible = false;
        } else if (this.totalHeight <= this.collapsedHeight) {
            this.isCollapsible = false;
        } else {
            this.isCollapsible = true;
        }
    }

    get containerStyle () {
        const containerStyleEntries = [];

        if (this.isCollapsible && !this.isShowingMore) {
            if (this.collapsedHeight != null) {
                containerStyleEntries.push(
                    `max-height: ${this.collapsedHeight}px`
                );
                containerStyleEntries.push('overflow: hidden');
            }
        }

        return containerStyleEntries.join(';');
    }

    handleTokenSequenceChanged () {
        this.recalculateRowHeight();
        this.recalculateTotalHeight();
    }

    connectedCallback () {
        this.hasRendered = false;
    }

    hasRendered = false;
    renderedCallback () {
        if (!this.hasRendered) {
            this.handleTokenSequenceChanged();
            this.hasRendered = true;
        }
    }
}