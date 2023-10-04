export function synchronizeAttrs (element, values) {
    if (!element) {
        return;
    }

    const attributes = Object.keys(values);
    attributes.forEach((attribute) => {
        smartSetAttribute(element, attribute, values[attribute]);
    });
}

export function smartSetAttribute (element, attribute, value) {
    if (element.tagName.match(/^C/i)) {
        const normalizedAttribute = attribute.replace(/-\w/g, (m) => m[1].toUpperCase());
        element[normalizedAttribute] = value ? value : null;
    } else if (value) {
        element.setAttribute(attribute, value);
    } else {
        element.removeAttribute(attribute);
    }
}

export function getRealDOMId (el) {
    if (el && typeof el === 'string') {
        return el;
    } else if (el) {
        return el.getAttribute('id');
    }
    return null;
}