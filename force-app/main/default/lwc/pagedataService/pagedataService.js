import getPageData from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getPageData';
import savePageData from '@salesforce/apex/CONF_PageLayoutRunTime_LS.savePageData';
import getNewChildRecord from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getNewChildRecord';
import { verifyApiResponse, parseErrorMessage } from 'c/utils';

/**
 * Returns the source and target record collection of sObject(s) configured in pagelayout
 * 
 * @param {string} pageLayoutId - a string value representing the pagelayout name/Id
 * @param {string} recordId - a string value representing the recordId
 */
const getPageDataForLayout = (pageLayoutId, recordId) => {
    const requestPayload = { pageLayoutId, recordId };
    return getPageData({ requestJson: JSON.stringify(requestPayload) })
        .then(result => {
            if (verifyApiResponse(result)) {
                return result;
            }

            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
};

/**
 * Returns the master record collection of sObject(s) configured in pagelayout
 * 
 * @param {object} payload - object payload representing pageLayoutId, headerRecord & detailRecords
 */
const savePageDataForLayout = payload => {
    const requestPayload = { requestJson: JSON.stringify(payload) };

    return savePageData(requestPayload)
        .then(result => {
            if (verifyApiResponse(result)) {
                result.data = JSON.parse(result.data);
                return result;
            }
            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
};

/**
 * Returns the new child record sObject configured in value/field mapping
 * 
 * @param {string} pageLayoutId - a string value representing the pagelayout name/Id
 * @param {string} detailLineId - a string value representing related section title
 * @param {string} sourceRecordId - a string value representing source record Id
*/
const getNewChildRecordForLayout = (pageLayoutId, detailLineId, sourceRecordId) => {
    const requestPayload = { pageLayoutId, detailLineId, sourceRecordId };
    return getNewChildRecord({ requestJson: JSON.stringify(requestPayload) })
        .then(result => {
            if (verifyApiResponse(result)) {
                return result;
            }

            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
};

export {
    getPageDataForLayout,
    savePageDataForLayout,
    getNewChildRecordForLayout
};