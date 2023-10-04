/* eslint-disable consistent-return */

import sendToNewRelic from '@salesforce/apex/CONF_PageLayoutRunTime_LS.sendToNewRelic';

async function sendToNewRelicServer (data) {
    return sendToNewRelic({ requestJson: JSON.stringify(data) })
        .then(() => {
            return true;
        })
        .catch((e) => {
            console.error(e);
            return false;
        });
}

/**
 * log SPM runtime usage insights data to new relic server
 * @param [{colName: value,...} {colName: value,...}] array of record to be logged in new relic
 * @return {success: 'true', uuid} return message of logging newrelic success or failure
 */
export const logUsageInsightsSPMRuntime = async (data) => {
    if (!Array.isArray(data)) {
        return;
    }

    const prepareData = (data || []).map(d => {
        return { ...d, eventType: "SPMRuntime" };
    });
    const result = await sendToNewRelicServer(prepareData);
    return result;
}