import { LightningElement, api } from 'lwc';

import labelExpression from '@salesforce/label/c.Label_Expression';
import labelAdvancedExpression from '@salesforce/label/c.Label_Advanced_Expression';
import labelExpressionName from '@salesforce/label/c.Label_ExpressionName';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelDisplayRule from '@salesforce/label/c.Label_DisplayRule';
import labelSourceObject from '@salesforce/label/c.Label_SourceObject';
import labelTargetObject from '@salesforce/label/c.Label_TargetObject';
import labelObject from '@salesforce/label/c.Label_Object';
import labelMappingName from '@salesforce/label/c.Label_Mapping_Name';
import labelDisplayed from '@salesforce/label/c.Label_Displayed';
import labelQualifyingCriteria from '@salesforce/label/c.Sec_QualifyingCriteria';
import labelHidden from '@salesforce/label/c.Label_Hidden';
import labelMappingValues from '@salesforce/label/c.Label_Mapping_Values';
import labelNoAdvancedLookup from '@salesforce/label/c.Label_No_Advanced_Lookup';
import labelNoLookupConfiguration from '@salesforce/label/c.Label_NoLookupConfiguration';
import labelLookupFilter from '@salesforce/label/c.Label_LookupFilter';
import labelLookupContext from '@salesforce/label/c.Label_LookupContext';
import labelLookupAutofill from '@salesforce/label/c.Label_LookupAutoFillMapping';
import labelFieldsReturned from '@salesforce/label/c.Label_LookupFieldsReturned';
import labelSearchFields from '@salesforce/label/c.Sec_Search_Fields';
import labelConditionsLogic from '@salesforce/label/c.Label_Conditions_Logic';
import labelSourceValues from '@salesforce/label/c.Label_LookupSourceValues';
import labelLookupFilterName from '@salesforce/label/c.Label_LookupFilterName';
import labelOverrideContext from '@salesforce/label/c.Label_OverrideContext';
import labelOverride from '@salesforce/label/c.Label_Override';
import labelContextMatching from '@salesforce/label/c.Label_LookupContextMatching';
import labelAlwaysDisplay from '@salesforce/label/c.Label_AlwaysDisplay';
import labelFieldChange from '@salesforce/label/c.Label_FieldChange';
import labelOnLoad from '@salesforce/label/c.Label_OnLoad';
import labelFieldName from '@salesforce/label/c.Label_FieldName';
import labelMappedBy from '@salesforce/label/c.Label_Mapped_By';
import labelMappedTo from '@salesforce/label/c.Label_Mapped_To';
import labelMatched from '@salesforce/label/c.Label_Matched';
import labelNotMatched from '@salesforce/label/c.Label_NotMatched';
import labelApplied from '@salesforce/label/c.Label_Applied';
import labelNotApplied from '@salesforce/label/c.Label_NotApplied';
import labelEvaluateAlways from '@salesforce/label/c.Label_EvaluateAlways';
import labelValueMapping from '@salesforce/label/c.Label_ValueMapping';
import labelQualifyingCriteriaDetails from '@salesforce/label/c.Label_Qualifying_Criteria_Details';
import labelCriteriaName from '@salesforce/label/c.Label_CriteriaName';
import labelFieldMapping from '@salesforce/label/c.Label_FieldMapping';
import labelMappingDetails from '@salesforce/label/c.Label_Mapping_Details';
import labelRawJsonData from '@salesforce/label/c.Label_Raw_Json_Data';
import labelMappingNotApplied from '@salesforce/label/c.Label_Mapping_Not_Applied';

const i18n = {
    labelExpression,
    labelAdvancedExpression,
    labelExpressionName,
    labelDeveloperName,
    labelDisplayRule,
    labelObject,
    labelSourceObject,
    labelTargetObject,
    labelMappingName,
    labelDisplayed,
    labelQualifyingCriteria,
    labelHidden,
    labelMappingValues,
    labelNoAdvancedLookup,
    labelNoLookupConfiguration,
    labelLookupFilter,
    labelLookupContext,
    labelLookupAutofill,
    labelLookupFilterName,
    labelOverrideContext,
    labelOverride,
    labelContextMatching,
    labelAlwaysDisplay,
    labelFieldChange,
    labelOnLoad,
    labelFieldsReturned,
    labelSearchFields,
    labelConditionsLogic,
    labelSourceValues,
    labelFieldName,
    labelMappedBy,
    labelMappedTo,
    labelMatched,
    labelNotMatched,
    labelApplied,
    labelNotApplied,
    labelEvaluateAlways,
    labelValueMapping,
    labelQualifyingCriteriaDetails,
    labelCriteriaName,
    labelFieldMapping,
    labelMappingDetails,
    labelRawJsonData,
    labelMappingNotApplied,
};

export default class RuntimeDebugConsoleCard extends LightningElement {
    @api cards = [];
    @api isSourceToTarget = false;

    get i18n () {
        return i18n;
    }

    @api
    scrollIntoCard (value) {
        const cardEl = this.template.querySelector(
            `[data-created-id="${value}"]`,
        );
        cardEl.scrollIntoView();
    }

    getJsonFile (json) {
        const parsedJson = JSON.parse(json);
        const key = Object.keys(parsedJson)[0];
        const prettyJson = JSON.stringify(parsedJson[key], null, 2);
        return new File([prettyJson], `${key}.json`, {
            type: 'application/json',
        });
    }

    handleJsonDownload (event) {
        const jsonData = event.target.getAttribute('data-json');
        const jsonFile = this.getJsonFile(jsonData);
        const jsonDataURI = URL.createObjectURL(jsonFile);

        const link = document.createElement('a');
        link.href = jsonDataURI;
        link.download = jsonFile.name;
        link.click();

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            URL.revokeObjectURL(jsonDataURI);
            link.href = '';
            link.download = '';
        }, 0);
    }
}