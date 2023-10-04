import { LightningElement, track, wire } from 'lwc';
import getPSCConfigSetting from
    '@salesforce/apex/ADM_ProductServiceCampaign_LS.getSettingConfigTemplates';
import updateRec from '@salesforce/apex/ADM_ProductServiceCampaign_LS.updateConfigTemplateSetting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { parseErrorMessage, verifyApiResponse, ADMIN_MODULES } from 'c/utils';
import PSC_ICONS from '@salesforce/resourceUrl/pscIcons';
import labelPSCName from '@salesforce/label/c.Label_Product_Service_Campaigns';
import titleSetting from '@salesforce/label/c.Label_Settings';
import btnEdit from '@salesforce/label/c.Btn_Edit';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnSave from '@salesforce/label/c.Btn_Save';
import lblBatchSearchResult from '@salesforce/label/c.Label_Batch_Size_For_Search_Results';
import lblBatchOutput from '@salesforce/label/c.Label_Batch_Size_For_Delivery_Output';
import lblMaxSearchResult from '@salesforce/label/c.Label_Max_Search_Res_Generated_per_Campaign';
import labelPscSettingsSaved from '@salesforce/label/c.Label_PscSettingsSaved';
import lblRecordSaveError from '@salesforce/label/c.Title_AlertError';
import lblClear from '@salesforce/label/c.Label_Clear';
import lblLoading from '@salesforce/label/c.AltText_Loading';
import lblNumberTen from '@salesforce/label/c.Label_Number_Ten';
import lblNumberTwenty from '@salesforce/label/c.Number_Twenty_Label';
import lblNumberThirty from '@salesforce/label/c.Number_Thirty_Label';
import lblNumberForty from '@salesforce/label/c.Number_Forty_Label';
import lblNumberFifty from '@salesforce/label/c.Number_Fifty_Label';
import lblNumberFiveHundred from '@salesforce/label/c.Number_Five_Hundred_Label';
import lblNumberOneThousand from '@salesforce/label/c.Label_Number_One_Thousand';
import lblNumberOneThsFiveHund from '@salesforce/label/c.Label_Number_One_Thousand_Five_Hundred';
import lblNumberTwoThousand from '@salesforce/label/c.Label_Number_Two_Thousand';
import lblNumberTwoThousandFH from '@salesforce/label/c.Label_Number_Two_Thousand_Five_Hundred';
import lblNumberTwoHFifty from '@salesforce/label/c.Label_Number_Two_Hundred_Fifty';
import lblNumberSevenHUnFifty from '@salesforce/label/c.Number_Seven_Hundred_Fifty_Label';
import lblNumberOneThousTwoHFifty from
    '@salesforce/label/c.Label_Number_One_Thousand_Two_Hundred_Fifty';
import labelHelp from '@salesforce/label/c.Label_Help';
import urlPscSettingHelp from '@salesforce/label/c.URL_PscSettingHelp';
const i18n = {
    titlePSCName: labelPSCName,
    titleSetting: titleSetting,
    btnEdit: btnEdit,
    btnCancel: btnCancel,
    btnSave: btnSave,
    btnClear: lblClear,
    lblBatchSearchResult: lblBatchSearchResult,
    lblBatchOutput: lblBatchOutput,
    lblMaxSearchResult: lblMaxSearchResult,
    labelPscSettingsSaved: labelPscSettingsSaved,
    lblRecordSaveError: lblRecordSaveError,
    loading: lblLoading,
    lblNumberTen: lblNumberTen,
    lblNumberTwenty: lblNumberTwenty,
    lblNumberThirty: lblNumberThirty,
    lblNumberForty: lblNumberForty,
    lblNumberFifty: lblNumberFifty,
    lblNumberFiveHundred: lblNumberFiveHundred,
    lblNumberOneThousand: lblNumberOneThousand,
    lblNumberOneThsFiveHund: lblNumberOneThsFiveHund,
    lblNumberTwoThousand: lblNumberTwoThousand,
    lblNumberTwoThousandFH: lblNumberTwoThousandFH,
    lblNumberTwoHFifty: lblNumberTwoHFifty,
    lblNumberSevenHUnFifty: lblNumberSevenHUnFifty,
    lblNumberOneThousTwoHFifty: lblNumberOneThousTwoHFifty,
    lblExpandingSection: labelPSCName+' '+titleSetting,
    help: labelHelp,
    helpLink: urlPscSettingHelp,
};

import { saveRecentViewItem }
    from 'c/recentItemService';

export default class PscSettingAdminDetail extends NavigationMixin(LightningElement) {
  @track editMode = false;
  @track batchSearchNewVal;
  @track batchOutputNewVal;
  @track maxSearchNewVal;
  @track editRecordIdVal;
  @track currentPageReference;
  pscLogoUrl = `${PSC_ICONS}/pscIcons/ServiceMax_Logo.svg`;
  apiInProgress = false;

  get i18n () {
      return i18n;
  }
  get batchSearchOptions () {
      return [
          { label: this.i18n.lblNumberTwoHFifty, value: '250' },
          { label: this.i18n.lblNumberFiveHundred, value: '500' },
          { label: this.i18n.lblNumberSevenHUnFifty, value: '750' },
          { label: this.i18n.lblNumberOneThousand, value: '1000' },
          { label: this.i18n.lblNumberOneThousTwoHFifty, value: '1250' },
      ];
  }
  get batchOutputOptions () {
      return [
          { label: this.i18n.lblNumberTen, value: '10' },
          { label: this.i18n.lblNumberTwenty, value: '20' },
          { label: this.i18n.lblNumberThirty, value: '30' },
          { label: this.i18n.lblNumberForty, value: '40' },
          { label: this.i18n.lblNumberFifty, value: '50' },
      ];
  }
  get maxSearchOptions () {
      return [
          { label: this.i18n.lblNumberFiveHundred, value: '500' },
          { label: this.i18n.lblNumberOneThousand, value: '1000' },
          { label: this.i18n.lblNumberOneThsFiveHund, value: '1500' },
          { label: this.i18n.lblNumberTwoThousand, value: '2000' },
          { label: this.i18n.lblNumberTwoThousandFH, value: '2500' },
      ];
  }

  @wire(CurrentPageReference)
  currPageRef (pageref) {
      if (pageref && pageref.state &&
          pageref.state.c__currentItem === 'psc_settings') {
          this.getTheConfigSettingValue();
      }
  }

  getTheConfigSettingValue () {
      this.apiInProgress = true;
      getPSCConfigSetting()
          .then(result => {
              const recentlyViewedRecord = {
                  configurationId: result.data[0].id,
                  configurationName: ADMIN_MODULES.PRODUCT_SERVICE_CAMPAIGNS_SETTINGS,
                  configurationType: ADMIN_MODULES.PRODUCT_SERVICE_CAMPAIGNS_SETTINGS
              };
              saveRecentViewItem(recentlyViewedRecord)
                  .then(recentItem => {
                      if (!verifyApiResponse(recentItem)) {
                          this.error = recentItem.message;
                      }
                  });
              this.populateConfigSettingData(result);
          })
          .catch(error => {
              this.error = error;
          });
  }

  populateConfigSettingData (result) {
      if (result) {
          this.editRecordIdVal = result.data[0].id;
          this.batchSearchNewVal
            = result.data[0].searchBatch ? String(result.data[0].searchBatch) : '';
          this.batchOutputNewVal
            = result.data[0].deliveryBatch ? String(result.data[0].deliveryBatch) : '';
          this.maxSearchNewVal
            = result.data[0].searchResultPerPSC ? String(result.data[0].searchResultPerPSC) : '';
      }
      this.apiInProgress = false;
  }

  handleCancel () {
      this.editMode = false;
      this.getTheConfigSettingValue();
  }

  handleBatchSearchChange (event) {
      this.batchSearchNewVal = event.target.value;
  }
  handleBatchOutputChange (event) {
      this.batchOutputNewVal = event.target.value;
  }
  handleMaxSearchChange (event) {
      this.maxSearchNewVal = event.target.value;
  }

  handleEdit () {
      this.editMode = true;
  }

  handleHelpClick () {
      window.open(i18n.helpLink, '_blank');
  }

  handleSave () {
      this.apiInProgress = true;
      updateRec({ requestJson: JSON.stringify({ id: this.editRecordIdVal,
          searchBatch: this.batchSearchNewVal,
          deliveryBatch: this.batchOutputNewVal,
          searchResultPerPSC: this.maxSearchNewVal }) })
          .then(result => {

              if (!verifyApiResponse(result)) {
                  throw new Error(result.message);
              }

              const evt = new ShowToastEvent({
                  title: this.i18n.labelPscSettingsSaved,
                  message: result,
                  variant: 'success'
              });
              this.dispatchEvent(evt);
          })
          .catch(error => {
              this.error = parseErrorMessage(error);
              const evt = new ShowToastEvent({
                  title: this.i18n.lblRecordSaveError,
                  message: this.error,
                  variant: 'error',
                  mode: 'sticky'
              });
              this.dispatchEvent(evt);
          }).finally(() => {
              this.apiInProgress = false;
          });
      this.editMode = false;
  }
}