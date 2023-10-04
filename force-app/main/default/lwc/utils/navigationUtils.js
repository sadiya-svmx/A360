import { NavigationMixin } from 'lightning/navigation';

const APP_TAB = {
    type: 'standard__navItemPage',
    attributes: {
        apiName: 'SVMXA360__setupHome'
    }
};

const STANDARD_OBJECT_PAGE = {
    type: 'standard__objectPage'
};

const STANDARD_RECORD_PAGE = {
    type: 'standard__recordPage',
    attributes: {
        actionName: 'view'
    }
};

const WEB_PAGE = {
    type: 'standard__webPage',
};

export function getPageReference (event) {
    const navigateTo = {};
    let attributes = {};
    let state = {};
    switch (event.detail.targetType) {
        case 'LWC':
        case 'FLEXI-PAGE':
            state = {
                state: {
                    c__currentItem: event.detail.name,
                    c__target: event.detail.targetDeveloperName
                }
            }
            Object.assign(navigateTo, APP_TAB, state);
            break;
        case 'OBJECT-URL':
            attributes = {
                attributes: {
                    objectApiName: event.detail.targetDeveloperName,
                    actionName: 'list'
                }
            }
            Object.assign(navigateTo, STANDARD_OBJECT_PAGE, attributes);
            break;
        case 'RECORD-URL':
            attributes = {
                attributes: {
                    recordId: event.detail.targetDeveloperName,
                    actionName: 'view'
                }
            }
            Object.assign(navigateTo, STANDARD_RECORD_PAGE, attributes);
            break;
        case 'URL':
            attributes = {
                attributes: {
                    url: event.detail.targetDeveloperName
                }
            }
            Object.assign(navigateTo, WEB_PAGE, attributes);
            break;
        default:
            console.error('Valid target type not specified')
    }

    return navigateTo;
}

export function handleMenuSelection (event, cmp) {
    const navigateTo = getPageReference(event, cmp)

    // TODO: Add isConnected check with Summer '20.
    // Check whether the calling component extends NavigationMixin. 
    if (cmp[NavigationMixin.Navigate]) {
        cmp[NavigationMixin.Navigate](navigateTo);
    } else {
        console.error("LWC does not extend NavigationMixin");
    }

}