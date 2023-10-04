import LOCALE from '@salesforce/i18n/locale';
import Id from '@salesforce/user/Id';

let cachedItems = {};
let store = null;
const userId = Id.substring(Id.length - 4);

/**
 * Get a store for insert, read and delete items from browser local storage
 * @returns {Window Object} It returns window local storage instance
 */

const getStore = () => {
    if (store === null) {
        store = window.localStorage;
    }
    return store;
}

/**
 * Get a item from browser local storage
 * @param {String} key - key to fetch a item from storage
 * @returns {Any} It returns the value from local storage for the key
 */
export const asyncGetItemFromCache = async (key,refreshCache = false) => {
    const newKey = `${userId}${LOCALE}${key}`;
    const ret = cachedItems[newKey];
    if (ret !== undefined && ret !== null && !refreshCache) {
        return ret;
    }

    const valueAsString = getStore().getItem(newKey);
    const value = JSON.parse(valueAsString);
    cachedItems[newKey] = value;
    return value;
}

/**
 * Set a item to browser local storage
 * @param {String} key - key to set a item to storage
 * @param {Any} value - value of any data type as Object, Array or Primitive Data Type
 * @returns {Void} 
 */
export const asyncSetItemIntoCache = async (key, value, overrideValue = false) => {
    const newKey = `${userId}${LOCALE}${key}`;
    cachedItems[newKey] = value;
    if (!overrideValue) {
        getStore().removeItem(newKey);
    }
    return getStore().setItem(newKey, JSON.stringify(value));
}


/**
 * Remove a item from browser local storage
 * @param {String} key - key to remove a item from storage
 * @returns {Void} 
 */
export const asyncRemoveItemFromCache = async (key) => {
    const newKey = `${userId}${LOCALE}${key}`;
    delete cachedItems[newKey];
    getStore().removeItem(newKey);
}

/**
 * claer all items from browser local storage
 * @returns {Void} 
 */
export const asyncClearAllItemsFromCache = async () => {
    getStore().clear();
    cachedItems = {};
}