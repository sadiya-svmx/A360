import { isUndefinedOrNull } from './utils'

/**
 * Determines whether 'white' or 'black' is an appropriate constrasting color 
 * based on the color brightness of the hexColor parameter.
 * @see {https://www.w3.org/TR/AERT/#color-contrast}
 * @param {String} hexcolor - 6 digit hex code for color
 * @return {String} - returns "white" or "black"
 */
export function getContrastingColor (hexColor) {
    if (isUndefinedOrNull(hexColor) || hexColor.length === 0) return null;

    let copyOfHexColor = hexColor;
    // Strip leading # if hexColor value is like #FF0000;
    if (hexColor.slice(0, 1) === '#') {
        copyOfHexColor = hexColor.slice(1);
    }

    const r = parseInt(copyOfHexColor.substr(0,2), 16);
    const g = parseInt(copyOfHexColor.substr(2,2), 16);
    const b = parseInt(copyOfHexColor.substr(4,2), 16);

    const yiq = ((r*299) + (g*587) + (b*114)) / 1000;
    return (yiq >= 125) ? 'black' : 'white';
}

let a11yIdCounter = 0;
export function generateA11yId (prefix = 'input') {
    a11yIdCounter++;
    return `${prefix}-${a11yIdCounter}`;
}