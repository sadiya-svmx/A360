/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete Pagelayouts.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                18 Sep 2020     Created.
 * A360CE-902   Ramachandra Mohan       13 Aug 2021     Service to retrieve entitlement custom labels.
 *****************************************************************************************************/
public with sharing class ADM_CustomLabelService extends ADM_AbstractCustomLabelService {
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_CustomLabelService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_CustomLabelService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    /**
     * This method is used to retrieve all custom labels required for interactive entitlement.
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    override public Common.ServiceResponse getEntitlementCustomLabels() {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementCustomLabels() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        List<Adm.CustomLabel> customLabelList = new List<Adm.CustomLabel>();

        customLabelList.add(new Adm.CustomLabel('Title_ServiceCoverage', System.Label.SVMXA360.Title_ServiceCoverage));
        customLabelList.add(new Adm.CustomLabel('Label_EntitledService', System.Label.SVMXA360.Label_EntitledService));
        customLabelList.add(new Adm.CustomLabel('Label_CoverageEnds', System.Label.SVMXA360.Label_CoverageEnds));
        customLabelList.add(new Adm.CustomLabel('Button_SelectServiceCoverage', System.Label.SVMXA360.Button_SelectServiceCoverage));
        customLabelList.add(new Adm.CustomLabel('Label_CoveredByWarranty', System.Label.SVMXA360.Label_CoveredByWarranty));
        customLabelList.add(new Adm.CustomLabel('Label_CoveredByContract', System.Label.SVMXA360.Label_CoveredByContract));
        customLabelList.add(new Adm.CustomLabel('Label_CoveredByEntitlement', System.Label.SVMXA360.Label_CoveredByEntitlement));
        customLabelList.add(new Adm.CustomLabel('Label_MultipleCoveragesFound', System.Label.SVMXA360.Label_MultipleCoveragesFound));
        customLabelList.add(new Adm.CustomLabel('Label_MultipleEntitlementFound', System.Label.SVMXA360.Label_MultipleEntitlementFound));
        customLabelList.add(new Adm.CustomLabel('Label_NoResultsFound', System.Label.SVMXA360.Label_NoResultsFound));
        customLabelList.add(new Adm.CustomLabel('Message_NoCurrentCoverage', System.Label.SVMXA360.Message_NoCurrentCoverage));
        customLabelList.add(new Adm.CustomLabel('AltText_Loading', System.Label.SVMXA360.AltText_Loading));
        customLabelList.add(new Adm.CustomLabel('Message_SelectService', System.Label.SVMXA360.Message_SelectService));
        customLabelList.add(new Adm.CustomLabel('Message_ServiceCountMessage', System.Label.SVMXA360.Message_ServiceCountMessage));
        customLabelList.add(new Adm.CustomLabel('Message_ServiceCountMessageWithoutBrackets', System.Label.SVMXA360.Message_ServiceCountMessageWithoutBrackets));
        customLabelList.add(new Adm.CustomLabel('Message_Expiring', System.Label.SVMXA360.Message_Expiring));
        customLabelList.add(new Adm.CustomLabel('Label_Expired', System.Label.SVMXA360.Label_Expired));
        customLabelList.add(new Adm.CustomLabel('Label_StartDate', System.Label.SVMXA360.Label_StartDate));
        customLabelList.add(new Adm.CustomLabel('Label_EndDate', System.Label.SVMXA360.Label_EndDate));
        customLabelList.add(new Adm.CustomLabel('Label_NotApplicable', System.Label.SVMXA360.Label_NotApplicable));
        customLabelList.add(new Adm.CustomLabel('Message_ExpiringWithoutBrackets', System.Label.SVMXA360.Message_ExpiringWithoutBrackets));
        customLabelList.add(new Adm.CustomLabel('Label_RemainingServiceCountType', System.Label.SVMXA360.Label_RemainingServiceCountType));
        customLabelList.add(new Adm.CustomLabel('Label_ConsumedServiceCountType', System.Label.SVMXA360.Label_ConsumedServiceCountType));
        customLabelList.add(new Adm.CustomLabel('Label_CoveredBy', System.Label.SVMXA360.Label_CoveredBy));
        customLabelList.add(new Adm.CustomLabel('Label_Threshold', System.Label.SVMXA360.Label_Threshold));
        customLabelList.add(new Adm.CustomLabel('Label_Warranties', System.Label.SVMXA360.Label_Warranties));
        customLabelList.add(new Adm.CustomLabel('Label_Contracts', System.Label.SVMXA360.Label_Contracts));
        customLabelList.add(new Adm.CustomLabel('Label_NoCoverage', System.Label.SVMXA360.Label_NoCoverage));
        customLabelList.add(new Adm.CustomLabel('Label_RecordUpdatedSuccessfully', System.Label.SVMXA360.Label_RecordUpdatedSuccessfully));
        customLabelList.add(new Adm.CustomLabel('Label_Warranty', System.Label.SVMXA360.Label_Warranty));
        customLabelList.add(new Adm.CustomLabel('Label_Contract', System.Label.SVMXA360.Label_Contract));
        customLabelList.add(new Adm.CustomLabel('Label_IncidentNotCovered', System.Label.SVMXA360.Label_IncidentNotCovered));
        customLabelList.add(new Adm.CustomLabel('Label_No_Warranty_Coverage_Available', System.Label.SVMXA360.Label_No_Warranty_Coverage_Available));
        customLabelList.add(new Adm.CustomLabel('Label_Colon', System.Label.SVMXA360.Label_Colon));
        customLabelList.add(new Adm.CustomLabel('Label_Confirm_Coverage', System.Label.SVMXA360.Label_Confirm_Coverage));
        customLabelList.add(new Adm.CustomLabel('Label_Selected_Coverage', System.Label.SVMXA360.Label_Selected_Coverage));
        customLabelList.add(new Adm.CustomLabel('Label_SelectBillingType', System.Label.SVMXA360.Label_SelectBillingType));
        customLabelList.add(new Adm.CustomLabel('Label_Select_Coverage', System.Label.Label_Select_Coverage));
        customLabelList.add(new Adm.CustomLabel('Btn_Save', System.Label.SVMXA360.Btn_Save));
        customLabelList.add(new Adm.CustomLabel('LabelAsset', System.Label.SVMXA360.LabelAsset));
        customLabelList.add(new Adm.CustomLabel('Label_WorkOrder', System.Label.SVMXA360.Label_WorkOrder));
        customLabelList.add(new Adm.CustomLabel('Label_BillingType', System.Label.SVMXA360.Label_BillingType));
        customLabelList.add(new Adm.CustomLabel('Label_See_All_Entitlement_Services', System.Label.SVMXA360.Label_See_All_Entitlement_Services));
        customLabelList.add(new Adm.CustomLabel('Label_FutureEntitlements', System.Label.SVMXA360.Label_FutureEntitlements));
        customLabelList.add(new Adm.CustomLabel('Label_ExpiredEntitlements', System.Label.SVMXA360.Label_ExpiredEntitlements));
        customLabelList.add(new Adm.CustomLabel('Label_MatchAccount', System.Label.SVMXA360.Label_MatchAccount));
        customLabelList.add(new Adm.CustomLabel('Label_Account', System.Label.SVMXA360.Label_Account));
        customLabelList.add(new Adm.CustomLabel('Label_Asset', System.Label.SVMXA360.Label_Asset));
        customLabelList.add(new Adm.CustomLabel('Label_AccountAPIName', System.Label.SVMXA360.Label_AccountAPIName));
        customLabelList.add(new Adm.CustomLabel('Label_AssetAPIName', System.Label.SVMXA360.Label_AssetAPIName));
        customLabelList.add(new Adm.CustomLabel('Label_IncludeRootAsset', System.Label.SVMXA360.Label_IncludeRootAsset));
        customLabelList.add(new Adm.CustomLabel('Label_IncludeParentAsset', System.Label.SVMXA360.Label_IncludeParentAsset));
        customLabelList.add(new Adm.CustomLabel('Label_IncludeFullyConsumedServices', System.Label.SVMXA360.Label_IncludeFullyConsumedServices));
        customLabelList.add(new Adm.CustomLabel('Button_Apply', System.Label.SVMXA360.Button_Apply));
        customLabelList.add(new Adm.CustomLabel('Label_Service_Entitlement', System.Label.SVMXA360.Label_Service_Entitlement ));
        customLabelList.add(new Adm.CustomLabel('Label_Total_In_Brackets', System.Label.Label_Total_In_Brackets));
        customLabelList.add(new Adm.CustomLabel('Label_Term', System.Label.SVMXA360.Label_Term ));
        customLabelList.add(new Adm.CustomLabel('Label_Entitled_Services', System.Label.SVMXA360.Label_Entitled_Services));
        customLabelList.add(new Adm.CustomLabel('Label_No_Contract_Coverages_Available', System.Label.SVMXA360.Label_No_Contract_Coverages_Available));
        customLabelList.add(new Adm.CustomLabel('Label_ReturnOrder', System.Label.SVMXA360.Label_ReturnOrder));
        customLabelList.add(new Adm.CustomLabel('Label_Filter', System.Label.SVMXA360.Label_Filter));
        customLabelList.add(new Adm.CustomLabel('Label_Notes', System.Label.SVMXA360.Label_Notes));
        customLabelList.add(new Adm.CustomLabel('Btn_Cancel', System.Label.SVMXA360.Btn_Cancel));  
        customLabelList.add(new Adm.CustomLabel('Label_ExpiringSoon', System.Label.Label_ExpiringSoon));
        customLabelList.add(new Adm.CustomLabel('Label_ServiceConsumption', System.Label.Label_ServiceConsumption));
        customLabelList.add(new Adm.CustomLabel('Label_Expired_On', System.Label.Label_Expired_On));
        customLabelList.add(new Adm.CustomLabel('Label_RemainingServiceCountType_Mob', System.Label.Label_RemainingServiceCountType_Mob));
        customLabelList.add(new Adm.CustomLabel('Label_ConsumedServiceCountType_Mob', System.Label.Label_ConsumedServiceCountType_Mob));

        serviceResponse.data = customLabelList;
        return serviceResponse;
    }
    
    /**
     * This method provides all the custom labels required for
     * screen designer
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    public Static List<Adm.CustomLabel> getPageLayoutCustomLabels(){
        List<Adm.CustomLabel> customLabelList = new List<Adm.CustomLabel>();
        customLabelList.add(new Adm.CustomLabel('Label_PageLayoutDeleted', System.Label.Label_PageLayoutDeleted));
        customLabelList.add(new Adm.CustomLabel('Error_UnexpectedInternalError', System.Label.Error_UnexpectedInternalError));
        customLabelList.add(new Adm.CustomLabel('Btn_Save', System.Label.Btn_Save));
        customLabelList.add(new Adm.CustomLabel('Label_NewScreenDesigner', System.Label.Label_NewScreenDesigner));
        customLabelList.add(new Adm.CustomLabel('Label_ScreenDesigner', System.Label.Label_ScreenDesigner));
        customLabelList.add(new Adm.CustomLabel('Label_DeveloperName', System.Label.Label_DeveloperName));
        customLabelList.add(new Adm.CustomLabel('Label_LastModified', System.Label.Label_LastModified));
        customLabelList.add(new Adm.CustomLabel('Label_LastModifiedBy', System.Label.Label_LastModifiedBy));
        customLabelList.add(new Adm.CustomLabel('Label_PageLayoutName', System.Label.Label_PageLayoutName));
        customLabelList.add(new Adm.CustomLabel('Error_ObjectNotVisible', System.Label.Error_ObjectNotVisible));
        customLabelList.add(new Adm.CustomLabel('Menu_Edit', System.Label.Menu_Edit));
        customLabelList.add(new Adm.CustomLabel('Menu_Clone', System.Label.Menu_Clone));
        customLabelList.add(new Adm.CustomLabel('Label_Completed', System.Label.Label_Completed));
        customLabelList.add(new Adm.CustomLabel('Label_CannotBeEdited', System.Label.Label_CannotBeEdited));
        customLabelList.add(new Adm.CustomLabel('Label_Delete_Modal', System.Label.Label_Delete_Modal));
        customLabelList.add(new Adm.CustomLabel('Label_ScreenDesignerName', System.Label.Label_ScreenDesignerName));
        customLabelList.add(new Adm.CustomLabel('Label_FieldName', System.Label.Label_FieldName));
        customLabelList.add(new Adm.CustomLabel('Label_APIName', System.Label.Label_APIName));
        customLabelList.add(new Adm.CustomLabel('Label_ReadOnly', System.Label.Label_ReadOnly));
        customLabelList.add(new Adm.CustomLabel('AltText_Required', System.Label.AltText_Required));
        customLabelList.add(new Adm.CustomLabel('Label_DataSource', System.Label.Label_DataSource));
        customLabelList.add(new Adm.CustomLabel('Label_Disabled', System.Label.Label_Disabled));
        customLabelList.add(new Adm.CustomLabel('Label_Enabled', System.Label.Label_Enabled));
        customLabelList.add(new Adm.CustomLabel('Label_FieldProperties', System.Label.Label_FieldProperties));
        customLabelList.add(new Adm.CustomLabel('Label_Configure', System.Label.Label_Configure));
        customLabelList.add(new Adm.CustomLabel('Label_Lookup', System.Label.Label_Lookup));
        customLabelList.add(new Adm.CustomLabel('Label_NoLookupConfigured', System.Label.Label_NoLookupConfigured));
        customLabelList.add(new Adm.CustomLabel('Label_AddSpace', System.Label.Label_AddSpace));
        customLabelList.add(new Adm.CustomLabel('Label_CancelModal', System.Label.Label_CancelModal));
        customLabelList.add(new Adm.CustomLabel('Label_ContinueConfirmation', System.Label.Label_ContinueConfirmation));
        customLabelList.add(new Adm.CustomLabel('Button_NoGoBack', System.Label.Button_NoGoBack));
        customLabelList.add(new Adm.CustomLabel('Button_YesContinue', System.Label.Button_YesContinue));
        customLabelList.add(new Adm.CustomLabel('Label_NewSection', System.Label.Label_NewSection));
        customLabelList.add(new Adm.CustomLabel('Label_ClickSelectButton', System.Label.Label_ClickSelectButton));
        customLabelList.add(new Adm.CustomLabel('Label_DefaultSection', System.Label.Label_DefaultSection));
        customLabelList.add(new Adm.CustomLabel('Label_AddNewRelatedSection', System.Label.Label_AddNewRelatedSection));
        customLabelList.add(new Adm.CustomLabel('Label_ParentObjectSection', System.Label.Label_ParentObjectSection));
        customLabelList.add(new Adm.CustomLabel('Label_RelatedObjectSection', System.Label.Label_RelatedObjectSection));
        customLabelList.add(new Adm.CustomLabel('Label_SectionDeleteModal', System.Label.Label_SectionDeleteModal));
        customLabelList.add(new Adm.CustomLabel('Menu_Delete', System.Label.Menu_Delete));
        customLabelList.add(new Adm.CustomLabel('Label_DescriptionMaximumCharacters', System.Label.Label_DescriptionMaximumCharacters));
        customLabelList.add(new Adm.CustomLabel('Message_EnterDeveloperName', System.Label.Message_EnterDeveloperName));
        customLabelList.add(new Adm.CustomLabel('Message_NameValidation', System.Label.Message_NameValidation));
        customLabelList.add(new Adm.CustomLabel('Label_NameMaximumCharacters', System.Label.Label_NameMaximumCharacters));
        customLabelList.add(new Adm.CustomLabel('Message_InvalidValue', System.Label.Message_InvalidValue));
        customLabelList.add(new Adm.CustomLabel('Message_ColumnsValidation', System.Label.Message_ColumnsValidation));
        customLabelList.add(new Adm.CustomLabel('Label_SelectFields', System.Label.Label_SelectFields));
        customLabelList.add(new Adm.CustomLabel('Label_ShowFieldsOnLayout', System.Label.Label_ShowFieldsOnLayout));
        customLabelList.add(new Adm.CustomLabel('Label_HideFieldsOnLayout', System.Label.Label_HideFieldsOnLayout));
        customLabelList.add(new Adm.CustomLabel('Label_NoFieldsToDisplay', System.Label.Label_NoFieldsToDisplay));
        customLabelList.add(new Adm.CustomLabel('Placeholder_SearchExpressions', System.Label.Placeholder_SearchExpressions));
        customLabelList.add(new Adm.CustomLabel('Button_NewExpression', System.Label.Button_NewExpression));
        customLabelList.add(new Adm.CustomLabel('Placeholder_SearchLookupFilters', System.Label.Placeholder_SearchLookupFilters));
        customLabelList.add(new Adm.CustomLabel('Button_NewLookupFilter', System.Label.Button_NewLookupFilter));
        customLabelList.add(new Adm.CustomLabel('Placeholder_SearchMappings', System.Label.Placeholder_SearchMappings));
        customLabelList.add(new Adm.CustomLabel('Button_NewMapping', System.Label.Button_NewMapping));
        customLabelList.add(new Adm.CustomLabel('Button_Refresh', System.Label.Button_Refresh));
        customLabelList.add(new Adm.CustomLabel('Label_ClickToAddFields', System.Label.Label_ClickToAddFields));
        customLabelList.add(new Adm.CustomLabel('Button_AddField', System.Label.Button_AddField));
        customLabelList.add(new Adm.CustomLabel('Label_DoneReordering', System.Label.Label_DoneReordering));
        customLabelList.add(new Adm.CustomLabel('Label_ReorderWizards', System.Label.Label_ReorderWizards));
        customLabelList.add(new Adm.CustomLabel('Message_AddressSectionErrors', System.Label.Message_AddressSectionErrors));
        customLabelList.add(new Adm.CustomLabel('Title_Toast_Error_in_Warranty', System.Label.Title_Toast_Error_in_Warranty));
        customLabelList.add(new Adm.CustomLabel('Button_Confirm', System.Label.Button_Confirm));
        customLabelList.add(new Adm.CustomLabel('Label_Description', System.Label.Label_Description));
        customLabelList.add(new Adm.CustomLabel('Button_CloneLayout', System.Label.Button_CloneLayout));
        customLabelList.add(new Adm.CustomLabel('Label_CopyOf', System.Label.Label_CopyOf));
        customLabelList.add(new Adm.CustomLabel('Label_SectionProperties', System.Label.Label_SectionProperties));
        customLabelList.add(new Adm.CustomLabel('Label_General', System.Label.Label_General));
        customLabelList.add(new Adm.CustomLabel('Label_Title', System.Label.Label_Title));
        customLabelList.add(new Adm.CustomLabel('Label_Columns', System.Label.Label_Columns));
        customLabelList.add(new Adm.CustomLabel('Label_AddRow', System.Label.Label_AddRow));
        customLabelList.add(new Adm.CustomLabel('Label_DeleteRow', System.Label.Label_DeleteRow));
        customLabelList.add(new Adm.CustomLabel('Label_RemoveSection', System.Label.Label_RemoveSection));
        customLabelList.add(new Adm.CustomLabel('Label_SectionName', System.Label.Label_SectionName));
        customLabelList.add(new Adm.CustomLabel('Label_Object', System.Label.Label_Object));
        customLabelList.add(new Adm.CustomLabel('Message_GenericFormValidationError', System.Label.Message_GenericFormValidationError));
        customLabelList.add(new Adm.CustomLabel('Label_BasicInformation', System.Label.Label_BasicInformation));
        customLabelList.add(new Adm.CustomLabel('Button_AddSection', System.Label.Button_AddSection));
        customLabelList.add(new Adm.CustomLabel('Button_Done', System.Label.Button_Done));
        customLabelList.add(new Adm.CustomLabel('Message_UnableToSelectConfiguredValues', System.Label.Message_UnableToSelectConfiguredValues));
        customLabelList.add(new Adm.CustomLabel('Title_ObjectSelector', System.Label.Title_ObjectSelector));
        customLabelList.add(new Adm.CustomLabel('Message_EnterSectionName', System.Label.Message_EnterSectionName));
        customLabelList.add(new Adm.CustomLabel('Label_SectionNameMaximumCharacters', System.Label.Label_SectionNameMaximumCharacters));
        customLabelList.add(new Adm.CustomLabel('Label_LookupFilters', System.Label.Label_LookupFilters));
        customLabelList.add(new Adm.CustomLabel('Button_Apply', System.Label.Button_Apply));
        customLabelList.add(new Adm.CustomLabel('Button_Cancel', System.Label.Button_Cancel));
        customLabelList.add(new Adm.CustomLabel('Button_RemoveAssociation', System.Label.Button_RemoveAssociation));
        customLabelList.add(new Adm.CustomLabel('Label_Selected', System.Label.Label_Selected));
        customLabelList.add(new Adm.CustomLabel('Label_NoResultsFound', System.Label.Label_NoResultsFound));
        customLabelList.add(new Adm.CustomLabel('Message_SaveLayoutErrorOccured', System.Label.Message_SaveLayoutErrorOccured));
        customLabelList.add(new Adm.CustomLabel('Label_WasSaved', System.Label.Label_WasSaved));
        customLabelList.add(new Adm.CustomLabel('Placeholder_SearchLayout', System.Label.Placeholder_SearchLayout));
        customLabelList.add(new Adm.CustomLabel('Label_RecentItems', System.Label.Label_RecentItems));
        customLabelList.add(new Adm.CustomLabel('Lbl_Not_set', System.Label.Lbl_Not_set));
        customLabelList.add(new Adm.CustomLabel('Sec_QualifyingCriteria', System.Label.Sec_QualifyingCriteria));
        customLabelList.add(new Adm.CustomLabel('Label_FieldMapping', System.Label.Label_FieldMapping));
        customLabelList.add(new Adm.CustomLabel('Label_ValueMapping', System.Label.Label_ValueMapping));
        customLabelList.add(new Adm.CustomLabel('Label_None', System.Label.Label_None));
        customLabelList.add(new Adm.CustomLabel('Label_LookupContext', System.Label.Label_LookupContext));
        customLabelList.add(new Adm.CustomLabel('Label_ContextSourceObject', System.Label.Label_ContextSourceObject));
        customLabelList.add(new Adm.CustomLabel('Label_OverrideContext', System.Label.Label_OverrideContext));
        customLabelList.add(new Adm.CustomLabel('Label_Context', System.Label.Label_Context));
        customLabelList.add(new Adm.CustomLabel('Label_MatchingField', System.Label.Label_MatchingField));
        customLabelList.add(new Adm.CustomLabel('Label_SourceObject', System.Label.Label_SourceObject));
        customLabelList.add(new Adm.CustomLabel('Label_TargetObject', System.Label.Label_TargetObject));
        customLabelList.add(new Adm.CustomLabel('Label_ExpressionName', System.Label.Label_ExpressionName));
        customLabelList.add(new Adm.CustomLabel('Label_Mapping_Name', System.Label.Label_Mapping_Name));
        customLabelList.add(new Adm.CustomLabel('Label_LookupFilterName', System.Label.Label_LookupFilterName));
        customLabelList.add(new Adm.CustomLabel('Label_CancelModalTitle', System.Label.Label_CancelModalTitle));
        customLabelList.add(new Adm.CustomLabel('Error_DuplicateSectionName', System.Label.Error_DuplicateSectionName));
        customLabelList.add(new Adm.CustomLabel('Error_SectionError', System.Label.Error_SectionError));
        customLabelList.add(new Adm.CustomLabel('Label_RelatedListProperties', System.Label.Label_RelatedListProperties));
        customLabelList.add(new Adm.CustomLabel('Title_ScreenDesignerList', System.Label.Title_ScreenDesignerList));
        customLabelList.add(new Adm.CustomLabel('Label_ChangeObject', System.Label.Label_ChangeObject));
        customLabelList.add(new Adm.CustomLabel('URL_ScreenDesignerHelp', System.Label.URL_ScreenDesignerHelp));

        customLabelList.add(new Adm.CustomLabel('Error_TransactionDeleted', System.Label.Error_TransactionDeleted));
        customLabelList.add(new Adm.CustomLabel('Button_NewTransaction', System.Label.Button_NewTransaction));
        customLabelList.add(new Adm.CustomLabel('Label_Type', System.Label.Label_Type));
        customLabelList.add(new Adm.CustomLabel('Label_TransactionName', System.Label.Label_TransactionName));
        customLabelList.add(new Adm.CustomLabel('Label_GeneralInformation', System.Label.Label_GeneralInformation));
        customLabelList.add(new Adm.CustomLabel('Title_FormLayout', System.Label.Title_FormLayout));
        customLabelList.add(new Adm.CustomLabel('Button_Select', System.Label.Button_Select));
        customLabelList.add(new Adm.CustomLabel('Label_DefaultValues_DataMappingrule', System.Label.Label_DefaultValues_DataMappingrule));
        customLabelList.add(new Adm.CustomLabel('Label_TypeOfRecordToCreate', System.Label.Label_TypeOfRecordToCreate)); 
        customLabelList.add(new Adm.CustomLabel('Label_TypeOfTransaction', System.Label.Label_TypeOfTransaction));
        customLabelList.add(new Adm.CustomLabel('Title_TransactionList', System.Label.Title_TransactionList));
        customLabelList.add(new Adm.CustomLabel('Label_AllowNoEntries', System.Label.Label_AllowNoEntries));
        customLabelList.add(new Adm.CustomLabel('Label_DataSource', System.Label.Label_DataSource));
        customLabelList.add(new Adm.CustomLabel('Label_FieldType', System.Label.Label_FieldType));
        customLabelList.add(new Adm.CustomLabel('Label_TypeOfRecordToEdit', System.Label.Label_TypeOfRecordToEdit));
        customLabelList.add(new Adm.CustomLabel('Label_WhereTransactionAppear', System.Label.Label_WhereTransactionAppear));
        customLabelList.add(new Adm.CustomLabel('Error_ObjectInvalid', System.Label.Error_ObjectInvalid));
        customLabelList.add(new Adm.CustomLabel('Label_Name', System.Label.Label_Name));
        customLabelList.add(new Adm.CustomLabel('Title_AddSection_AddFields', System.Label.Title_AddSection_AddFields));
        customLabelList.add(new Adm.CustomLabel('Label_Operation_Cannot_Be_Undone', System.Label.Label_Operation_Cannot_Be_Undone));
        customLabelList.add(new Adm.CustomLabel('Message_ResetLayout', System.Label.Message_ResetLayout));
        customLabelList.add(new Adm.CustomLabel('Placeholder_EnterTransactionName', System.Label.Placeholder_EnterTransactionName));
        customLabelList.add(new Adm.CustomLabel('Label_SortBy', System.Label.Label_SortBy));
        customLabelList.add(new Adm.CustomLabel('Label_SortByAscending', System.Label.Label_SortByAscending));
        customLabelList.add(new Adm.CustomLabel('Label_SortByDescending', System.Label.Label_SortByDescending));
        customLabelList.add(new Adm.CustomLabel('Label_SelectDataSource', System.Label.Label_SelectDataSource));
        customLabelList.add(new Adm.CustomLabel('Message_AddFieldToSection', System.Label.Message_AddFieldToSection)); 

        customLabelList.add(new Adm.CustomLabel('Title_Header', System.Label.Title_Header)); 
        customLabelList.add(new Adm.CustomLabel('Message_TypeChangeWillBeLost', System.Label.Message_TypeChangeWillBeLost)); 
        customLabelList.add(new Adm.CustomLabel('Error_PleaseSelectField', System.Label.Error_PleaseSelectField)); 
        customLabelList.add(new Adm.CustomLabel('Label_EditHeaderChild', System.Label.Label_EditHeaderChild)); 
        customLabelList.add(new Adm.CustomLabel('Label_CreateHeaderChild', System.Label.Label_CreateHeaderChild)); 
        customLabelList.add(new Adm.CustomLabel('Error_InvalidFieldInSection', System.Label.Error_InvalidFieldInSection));  
        customLabelList.add(new Adm.CustomLabel('Label_PrepopulateDefaultValue', System.Label.Label_PrepopulateDefaultValue)); 
        customLabelList.add(new Adm.CustomLabel('Message_EnterScreenName', System.Label.Message_EnterScreenName)); 
        customLabelList.add(new Adm.CustomLabel('Label_Transaction_Designer', System.Label.Label_Transaction_Designer)); 
        customLabelList.add(new Adm.CustomLabel('URL_TransactionDesignerHelp', System.Label.URL_TransactionDesignerHelp)); 

        CustomLabelList.add(new Adm.CustomLabel('Label_ApexClass', System.Label.Label_ApexClass));
        CustomLabelList.add(new Adm.CustomLabel('Label_ButtonTitle', System.Label.Label_ButtonTitle));
        CustomLabelList.add(new Adm.CustomLabel('Error_ButtonTitle', System.Label.Error_ButtonTitle));
        CustomLabelList.add(new Adm.CustomLabel('Error_MaximumCharacterAllowed', System.Label.Error_MaximumCharacterAllowed));
        CustomLabelList.add(new Adm.CustomLabel('Error_ApexClass', System.Label.Error_ApexClass));
        CustomLabelList.add(new Adm.CustomLabel('Label_OpenRecord', System.Label.Label_OpenRecord));
        CustomLabelList.add(new Adm.CustomLabel('Label_LookupConfiguration', System.Label.Label_LookupConfiguration));
        CustomLabelList.add(new Adm.CustomLabel('Label_FieldLabelOverride', System.Label.Label_FieldLabelOverride));
        CustomLabelList.add(new Adm.CustomLabel('Label_TooltipOverrideLabel', System.Label.Label_TooltipOverrideLabel));
        CustomLabelList.add(new Adm.CustomLabel('Label_NewButton', System.Label.Label_NewButton));
        CustomLabelList.add(new Adm.CustomLabel('Label_AddButton', System.Label.Label_AddButton));
        CustomLabelList.add(new Adm.CustomLabel('Title_ButtonConfiguration', System.Label.Title_ButtonConfiguration));
        CustomLabelList.add(new Adm.CustomLabel('Label_TooltipButtonDisabled', System.Label.Label_TooltipButtonDisabled));
        CustomLabelList.add(new Adm.CustomLabel('Label_CopyToClipboard', System.Label.Label_CopyToClipboard));
        CustomLabelList.add(new Adm.CustomLabel('Label_ExtendedEditDisplay', System.Label.Label_ExtendedEditDisplay));
        CustomLabelList.add(new Adm.CustomLabel('Label_SelectableGrid', System.Label.Label_SelectableGrid));
        CustomLabelList.add(new Adm.CustomLabel('Message_CopytoClipboardSuccess', System.Label.Message_CopytoClipboardSuccess));
        CustomLabelList.add(new Adm.CustomLabel('Label_ItemsRowCount', System.Label.Label_ItemsRowCount));
        CustomLabelList.add(new Adm.CustomLabel('Error_UniqueTitle', System.Label.Error_UniqueTitle));

        customLabelList.add(new Adm.CustomLabel('Label_SalesforceFieldset', System.Label.Label_SalesforceFieldset));
        customLabelList.add(new Adm.CustomLabel('Label_SelectFieldset', System.Label.Label_SelectFieldset));
        customLabelList.add(new Adm.CustomLabel('Label_Autofill_Mapping', System.Label.Label_Autofill_Mapping));
        customLabelList.add(new Adm.CustomLabel('Label_AdvancedOptions', System.Label.Label_AdvancedOptions));
        customLabelList.add(new Adm.CustomLabel('Error_PleaseSelectExpression', System.Label.Error_PleaseSelectExpression));
        customLabelList.add(new Adm.CustomLabel('Error_PleaseAddHeaderOrRelatedSection', System.Label.Error_PleaseAddHeaderOrRelatedSection));
        customLabelList.add(new Adm.CustomLabel('Label_Hide', System.Label.Label_Hide));
        customLabelList.add(new Adm.CustomLabel('Label_Display', System.Label.Label_Display));
        customLabelList.add(new Adm.CustomLabel('Label_CriteriaToFilterRelatedRecords', System.Label.Label_CriteriaToFilterRelatedRecords));
        customLabelList.add(new Adm.CustomLabel('Label_PrePopulateValuesRelatedSection', System.Label.Label_PrePopulateValuesRelatedSection));
        customLabelList.add(new Adm.CustomLabel('Label_PrePopulateValuesRelatedSection', System.Label.Label_MapFieldsRelatedSourceObject));
        customLabelList.add(new Adm.CustomLabel('Label_AlwaysDisplay', System.Label.Label_AlwaysDisplay));
        customLabelList.add(new Adm.CustomLabel('Label_EvaluateAlways', System.Label.Label_EvaluateAlways));
        customLabelList.add(new Adm.CustomLabel('Label_EvaluateOnLoad', System.Label.Label_EvaluateOnLoad));
        customLabelList.add(new Adm.CustomLabel('Label_EvaluateOnFieldChange', System.Label.Label_EvaluateOnFieldChange));
        customLabelList.add(new Adm.CustomLabel('Label_DisplayRules', System.Label.Label_DisplayRules));
        customLabelList.add(new Adm.CustomLabel('Label_Expression ', System.Label.Label_Expression));
        customLabelList.add(new Adm.CustomLabel('Label_MaximumRulesClickOnInfo', System.Label.Label_MaximumRulesClickOnInfo));
        customLabelList.add(new Adm.CustomLabel('Info_TooltipTextForVisibilityCriteria', System.Label.Info_TooltipTextForVisibilityCriteria));
        customLabelList.add(new Adm.CustomLabel('Label_ItemsSelected', System.Label.Label_ItemsSelected));

        customLabelList.add(new Adm.CustomLabel('Label_UseDefaultMapping', System.Label.Label_UseDefaultMapping));
        customLabelList.add(new Adm.CustomLabel('Label_ExpressionTrue', System.Label.Label_ExpressionTrue));
        customLabelList.add(new Adm.CustomLabel('Button_Moveup', System.Label.Button_Moveup));
        customLabelList.add(new Adm.CustomLabel('Button_Movedown', System.Label.Button_Movedown));
        customLabelList.add(new Adm.CustomLabel('Button_AddConditionalMap', System.Label.Button_AddConditionalMap));
        customLabelList.add(new Adm.CustomLabel('Button_AlwaysApply', System.Label.Button_AlwaysApply));
        customLabelList.add(new Adm.CustomLabel('Button_Conditional', System.Label.Button_Conditional));
        customLabelList.add(new Adm.CustomLabel('Label_ApplyMapping', System.Label.Label_ApplyMapping));
        customLabelList.add(new Adm.CustomLabel('Message_SectionReadValidation', System.Label.Message_SectionReadValidation));
        customLabelList.add(new Adm.CustomLabel('Button_OK', System.Label.Button_OK));
        customLabelList.add(new Adm.CustomLabel('Picklist_Field', System.Label.Picklist_Field));
        customLabelList.add(new Adm.CustomLabel('Title_DefaultMappedValue', System.Label.Title_DefaultMappedValue));
        customLabelList.add(new Adm.CustomLabel('Message_SelectExpression', System.Label.Message_SelectExpression));
        customLabelList.add(new Adm.CustomLabel('Message_SelectMapping', System.Label.Message_SelectMapping));
        customLabelList.add(new Adm.CustomLabel('Message_IncompleteConfig', System.Label.Message_IncompleteConfig));
        customLabelList.add(new Adm.CustomLabel('Message_SectionRequiredField', System.Label.Message_SectionRequiredField));
        customLabelList.add(new Adm.CustomLabel('Message_InvalidLookupContext', System.Label.Message_InvalidLookupContext));
        customLabelList.add(new Adm.CustomLabel('Message_InvalidAutofillConfig', System.Label.Message_InvalidAutofillConfig));
        customLabelList.add(new Adm.CustomLabel('Label_Tags', System.Label.Label_Tags));
        customLabelList.add(new Adm.CustomLabel('Placeholder_SearchTag', System.Label.Placeholder_SearchTag));
        customLabelList.add(new Adm.CustomLabel('Label_MultiAddSearch', System.Label.Label_MultiAddSearch));
        customLabelList.add(new Adm.CustomLabel('Title_Section', System.Label.Title_Section));
        customLabelList.add(new Adm.CustomLabel('Message_UpdateTransaction', System.Label.Message_UpdateTransaction));
        customLabelList.add(new Adm.CustomLabel('Message_DeleteTransaction', System.Label.Message_DeleteTransaction));
        customLabelList.add(new Adm.CustomLabel('Message_TransactionWhereUsed', System.Label.Message_TransactionWhereUsed));
        customLabelList.add(new Adm.CustomLabel('Message_TransactionUpdate', System.Label.Message_TransactionUpdate));
        customLabelList.add(new Adm.CustomLabel('Message_TransactionDisassociate', System.Label.Message_TransactionDisassociate));
        customLabelList.add(new Adm.CustomLabel('Message_DeleteScreen', System.Label.Message_DeleteScreen));
        customLabelList.add(new Adm.CustomLabel('Message_ScreenDisassociate', System.Label.Message_ScreenDisassociate));
        customLabelList.add(new Adm.CustomLabel('Message_ScreenUpdate', System.Label.Message_ScreenUpdate));
        customLabelList.add(new Adm.CustomLabel('Message_ScreenWhereUsed', System.Label.Message_ScreenWhereUsed));
        customLabelList.add(new Adm.CustomLabel('Label_WizardStep', System.Label.Label_WizardStep));
        customLabelList.add(new Adm.CustomLabel('Error_AddFieldValidation', System.Label.Error_AddFieldValidation));
        customLabelList.add(new Adm.CustomLabel('Title_RelatedListControls', System.Label.Title_RelatedListControls));
        customLabelList.add(new Adm.CustomLabel('Label_WhereUsed', System.Label.Label_WhereUsed));
        customLabelList.add(new Adm.CustomLabel('Button_Close', System.Label.Button_Close));
        customLabelList.add(new Adm.CustomLabel('Message_TransactionUnused', System.Label.Message_TransactionUnused));
        customLabelList.add(new Adm.CustomLabel('Message_ScreenUnused', System.Label.Message_ScreenUnused));
        customLabelList.add(new Adm.CustomLabel('Picklist_AllTransactions', System.Label.Picklist_AllTransactions));

        customLabelList.add(new Adm.CustomLabel('Message_ConditionalMappingToggle', System.Label.Message_ConditionalMappingToggle));
        customLabelList.add(new Adm.CustomLabel('Title_ResetMapping', System.Label.Title_ResetMapping));
        customLabelList.add(new Adm.CustomLabel('Label_LastUpdated', System.Label.Label_LastUpdated));

        return customLabelList;
    }
}