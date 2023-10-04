/**
A utility to determine if an icon Name is from a static resource or Standard Salesforce
@param {String} iconName - The name of the icon
@return {Boolean} - True if the icon is from a static resource, false if it is standard Salesforce
**/
export function isImageFromStaticResource (iconName) {
    return iconName && iconName.indexOf(':') === -1;
}