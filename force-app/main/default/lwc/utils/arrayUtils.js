/**
 * Sorts an object array by property and direction
 * @param {Array} incomingArray - The array to sort.
 * @param {String} sortBy - The property to sort on.
 * @param {String} sortDirection - The direction of the sort (asc or desc).
 * @returns {Array} A sorted array.
 */
export function sortObjectArray (incomingArray, sortBy, sortDirection) {
    const copyOfArray = [...incomingArray];

    const keyValue = a => {
        return (typeof a[sortBy] === 'string') ? a[sortBy].toUpperCase() : a[sortBy];
    };

    const isReverse = sortDirection === "asc" ? 1 : -1;

    copyOfArray.sort((x, y) => {
        const xVal = keyValue(x) ? keyValue(x) : "";
        const yVal = keyValue(y) ? keyValue(y) : "";

        return isReverse * ((xVal > yVal) - (yVal > xVal));
    });

    return copyOfArray;

}

/**
 * Compare two arrays and return true if they are equal
 * @param {array} array1 - first array to compare
 * @param {array} array2 - second array to compare
 * @returns {boolean} if the arrays are identical
 */
export function arraysEqual (array1, array2) {
    // if either array is falsey, return false
    if (!array1 || !array2) {
        return false;
    }

    // if array lengths don't match, return false
    if (array1.length !== array2.length) {
        return false;
    }

    for (let index = 0; index < array1.length; index++) {
        // Check if we have nested arrays
        if (array1[index] instanceof Array && array2[index] instanceof Array) {
            // recurse into the nested arrays
            if (!arraysEqual(array1[index], array2[index])) {
                return false;
            }
        } else if (array1[index] !== array2[index]) {
            // Warning - two different object instances will never be equal: {x:20} != {x:20}
            return false;
        }
    }

    return true;
}

/**
 * Group array of object by object type
 * @param {array} list - collection of objects
 * @param {function} keyGetter - get a key to group the object
 * @returns {array} grouped array object
 */
export function groupByObject (list, keyGetter) {
    const map = new Map();
    list.forEach((item) => {
        const key = keyGetter(item);
        const collection = map.get(key);
        if (!collection) {
            map.set(key, [item]);
        } else {
            collection.push(item);
        }
    });

    return map;
}