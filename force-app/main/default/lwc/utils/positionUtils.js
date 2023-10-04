import { isUndefinedOrNull } from './utils'

/**
 * Determines whether the element will overflow the window height
 * @see {https://www.w3.org/TR/AERT/#color-contrast}
 * @param {SecureElement} elem - SecureElement returned from an LWC querySelector
 * @return {Boolean} - returns true or false
 */
export function isElementOverflowingViewport (elem) {
    if (isUndefinedOrNull(elem)) return null;

    const boundClientRect = elem.getBoundingClientRect();
    if (boundClientRect.bottom > (window.innerHeight || document.documentElement.clientHeight)) {
        return true;
    }

    return false;
}