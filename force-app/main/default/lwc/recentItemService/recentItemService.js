import saveRecentItem
    from '@salesforce/apex/ADM_RecentItemsLightningService.saveRecentItem';
import deleteRecentItems
    from '@salesforce/apex/ADM_RecentItemsLightningService.deleteRecentItemsDetails';

import { verifyApiResponse, parseErrorMessage } from 'c/utils';

/**
 * Returns a collection of entity definitions.
 */
const saveRecentViewItem = ( recentItem ) => {
    return saveRecentItem( { requestJson: JSON.stringify(recentItem) } )
        .then(result => {
            let deSerializedResult = {};
            if (result) {
                deSerializedResult = JSON.parse(result);
                if (!verifyApiResponse(deSerializedResult)) {
                    throw new Error(parseErrorMessage(deSerializedResult.message));
                }
                return deSerializedResult;
            }
            return deSerializedResult;
        });
};

/**
 * delete recent items
 */
const deleteRecentItemRecords = ( recentItemList ) => {
    return deleteRecentItems( { requestJson: JSON.stringify(recentItemList) } )
        .then(result => {
            if (result && !verifyApiResponse(result)) {
                throw new Error(result.message);
            }
            return result;
        });
};

export {
    saveRecentViewItem,
    deleteRecentItemRecords
};