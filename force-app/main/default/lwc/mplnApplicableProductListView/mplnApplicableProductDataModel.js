import getAllApplicableProducts
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getAllApplicableProducts';
import { verifyApiResponse } from 'c/utils';
const fieldListForSearch = ['productName', 'productFamily', 'workTypeName'];
const baseUrl = window.location.origin;

export default function getDataModel () {
    const modal = {};
    modal.getAllApplicableProducts = async ({
        onErrorCallback = () => {},
        onNetworkErrorCallback = () => {}
    }, { maintenancePlanTemplateId }) => {
        try {
            modal.response = await getAllApplicableProducts({ maintenancePlanTemplateId });
            const { response }  = modal;
            if (!verifyApiResponse(response)) {
                const { message } = response;
                onErrorCallback(message);
                return {
                    recordCount: null,
                    data: [],
                };
            }
            modal.originalRecords = modal.getListViewData();
            return {
                recordCount: response.data?.length,
                data: response.data,
            };
        } catch (error) {
            onNetworkErrorCallback(error);
        }
        return {
            recordCount: null,
            data: [],
        };
    };

    modal.getFilteredRecords = ({ searchKey }) => {
        const filteredRecords = [];
        const allRecords = modal.originalRecords || [];
        const searchKeyStr =
      searchKey?.length ? searchKey.toLowerCase() : '';
        if ( searchKeyStr === '') {
            return allRecords;
        }
        const fieldList = fieldListForSearch;
        allRecords.forEach((item)=> {
            const fieldValue = fieldList.find(fieldItem => {
                const val = item[fieldItem];
                if (val && val.toLowerCase().indexOf(searchKeyStr) !== -1) {
                    return true;
                }
                return false;
            });
            if (fieldValue) {
                filteredRecords.push(item);
            }
        });
        return filteredRecords;
    };

    modal.getListViewData = () => {
        const sfdcBaseUrl = baseUrl+'/';
        const data  =  modal.response?.data || [];
        const listViewData = [];
        if (data.length === 0 ) return [];
        data.forEach(item => {
            const dataItem = { ...item };
            if (dataItem.name) {
                dataItem.NameUrl = sfdcBaseUrl + dataItem.id;
            }
            if (dataItem.productId) {
                dataItem.productUrl = sfdcBaseUrl + dataItem.productId;
            }
            if (dataItem.workTypeId) {
                dataItem.workTypeUrl = sfdcBaseUrl + dataItem.workTypeId;
            }

            listViewData.push(dataItem);
        });
        return listViewData;
    };

    return modal;
}