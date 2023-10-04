/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A class to hold error messages used across all classes.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       07 May 2020     Created.
 * A360TOOL-54  Manish Kushwah          06 Oct 2020     Added three new Error Messages(FAILED_TO_RETRIEVE_USER_INFO, ASSET360_LICENSE_MISSING, LICENSE_AVAILABILITY_ISSUE)
 *              Manish Kushwah          08 Jan 2021     Added for the story A360AM-99
 * A360AM-100   Manish Kushwah          28 Jan 2021     PSC_CONF_MISSING_INACTIVE added for the story A360AM-100
 *****************************************************************************************************/
public class ErrorMessage {

    /**
     * String constant to hold invalid argument error message
     */
	public static final String RECORD_NOT_EXISTS 				= System.Label.Error_RecordNotExists;

    /**
     * String constant to hold invalid argument error message
     */
	public static final String INVALID_ARGUMENT 				= System.Label.Error_InvalidArgument;

    /**
     * String constant to hold missing field error message
     */
    public static final String FIELD_NOT_EXISTS 				= System.Label.Error_FieldNotExists;

    /**
     * String constant to hold invalid or inaccessible field error message
     */
    public static final String FIELD_INACCESSIBLE_OR_NOT_EXISTS = System.Label.Error_FieldInaccessibleOrNotExists;
    
    /**
     * String constant to hold error message when the target field is not a reference field
     */
    public static final String FIELD_NOT_A_REFERENCE 			= System.Label.Error_FieldIsNotAReference;

    /**
     * String constant to hold unsupported type error message
     */
    public static final String TYPE_UNSUPPORTED 				= System.Label.Error_UnsupportedType;

    /**
     * String constant to hold restricted access message
     */
    public static final String RESTRICTED_ACCESS 				= System.Label.Error_RestrictedAccess;

    /**
     * String constant to hold missing required parameter error message
     */
	public static final String MISSING_REQUIRED_PARAMETER 		= System.Label.Error_MissingParameter;

    /**
     * String constant to hold object not exists error message
     */
    public static final String OBJECT_NOT_EXISTS				= System.Label.Error_ObjectNotVisible;

    /**
     * String constant to hold object inaccessible or not exists error message
     */
    public static final String OBJECT_INACCESSIBLE_OR_NOT_EXISTS = System.Label.Error_ObjectInaccessibleOrNotExists;

    /**
     * String constant to hold url not found error message
     */
    public static final String REST_RESOURCE_NOT_FOUND         	= System.Label.Error_NoMatchingURL;

    /**
     * String constant to hold url not found error message
     */
    public static final String REQUEST_IS_BLANK                 = System.Label.Error_InvalidRequest;

    /**
     * String constant to hold url not found error message
     */
    public static final String INVALID_REQUIRED_FIELD           = System.Label.Error_MissingRequiredFields;

    /**
     * String constant to hold url not found error message
     */
    public static final String INVALID_REQUEST_URL      		= System.Label.Error_InvalidRequestURL;

    /**
     * String constant to hold qualifying criteria error message
     */
    public static final String INVALID_QUALIFYING_CRITERIA      = System.Label.Error_InvalidQualifyingCriteria;

    /**
     * String constant to hold object does not exist error message
     */
    public static final String SCREEN_NOT_FOUND                 = System.Label.Messge_ScreenNotFound;

    /**
     * String constant to hold user record not found error message
     */
    public static final String FAILED_TO_RETRIEVE_USER_INFO     = System.Label.Error_FailedToRetrieveUserInfo;

    /**
     * String constant to hold license type is not available error message
     */
    public static final String ASSET360_LICENSE_MISSING         = System.Label.Error_Asset360LicenseMissing;

    /**
     * String constant to hold license is not available error message
     */
    public static final String LICENSE_AVAILABILITY_ISSUE       = System.Label.Error_LicenseAvailabilityIssue;

    /**
     * String constant to hold feature not licensed error message
     */
    public static final String FEATURE_NOT_LICENSED       		= System.Label.Error_FeatureNotLicensed;

    /**
     * String constant to hold Results Already Generated error message
     */
    public static final String RESULTS_ALREADY_GENERATED       	= System.Label.Error_ResultsAlreadyGenerated;

    /**
     * String constant to hold Batch In Progress error message
     */
    public static final String BATCH_IN_PROGRESS       		    = System.Label.Error_BatchInProgress;

    /**
     * String constant to hold PSC configuration is missing or inactive error message
     */
    public static final String PSC_CONF_MISSING_INACTIVE        = System.Label.Error_PscConfigurationMissingOrInactive;

    /**
     * String constant to hold Duplicate Error message for Screen/Transaction Designer
     */
    public static final String DUPLICATE_SCREEN_TRANSACTION     = System.Label.Error_DuplicateDeveloperName;

    /**
     * String constant to hold the Fields should contain the values for Service coverage screen.
     */
    public static final String FIELD_SHOULD_CONTAIN_VALUE       = System.Label.Error_FieldShouldContainValue;

    /**
     * String constant to hold the invalid template error message.
     */
    public static final String TEMPLATE_WITHOUT_WORK_RULE       = System.Label.Error_TemplateWithoutWorkRule;

    /**
     * String constant to hold the requireed fields error message.
     */
    public static final String ENTER_REQUIRED_FIELDS  = System.Label.Label_RequiredErrorMessage;
    
    /**
     * String constant to hold the error message for disabled feature.
     */
    public static final String FEATURE_DISABLED  = System.Label.Error_FeatureDisabled;

    /**
     * String constant to hold the error message for invalid current record header for mappings.
     */
    public static final String INVALID_CRH_MAPPING = System.Label.Error_InvalidCRHMapping;

    /**
     * String constant to hold the error message for invalid current record header for Lookup Configs.
     */
    public static final String INVALID_CRH_LOOKUP = System.Label.Error_InvalidCRHLookup;

    /**
     * String constant to hold the error message for invalid field set configuration.
     */
    public static final String INVALID_FIELDSET_CONFIG = System.Label.Error_InvalidFieldSetConfig;

    /**
     * String constant to hold the error message for missing assets.
     */
    public static final String ASSET_NOT_FOUND = System.Label.Error_MissingAsset;
}