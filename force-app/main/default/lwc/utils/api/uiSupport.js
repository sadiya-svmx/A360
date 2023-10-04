import { isCustomObjectOrField } from './common';
import { IS_MOBILE_DEVICE } from '../deviceUtils';

// TODO: Migrate to /ui-api/object-info - JIRA# A360ENG-859
import supportedObjectApis from './uiSupportedObjects';
const UI_API_SUPPORTED_STANDARD_OBJECTS = new Set(supportedObjectApis);

import mobileUnsupportedObjectApis from './uiMobileUnsupportedObjects';
const UI_API_MOBILE_UNSUPPORTED_OBJECTS = new Set(mobileUnsupportedObjectApis);

export function isObjectSupportedByUiApi (objectApiName) {
    if (!objectApiName) {
        return false;
    }

    if (IS_MOBILE_DEVICE) {
        return !UI_API_MOBILE_UNSUPPORTED_OBJECTS.has(objectApiName) &&
        (
            isCustomObjectOrField(objectApiName) ||
            UI_API_SUPPORTED_STANDARD_OBJECTS.has(objectApiName)
        );
    }

    return isCustomObjectOrField(objectApiName) ||
            UI_API_SUPPORTED_STANDARD_OBJECTS.has(objectApiName);
}