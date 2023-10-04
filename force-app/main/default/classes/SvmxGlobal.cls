/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are exposed globally
 *
 * @author Sachin S
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                03 May 2021     Created.
 *              Manish Kushwah          11 Aug 2021     Updated class to add couple of wrapper classes A360AM-1165
 *              Jaysukh Patel           03 Sep 2021     Marked SvmxResponse and SvmxError class virtual
 *              Jaysukh Patel           18 Sep 2021     Remove MaintenancePlanData wrapper to seprate class
 *              Karthick S              21 Sep 2021     Remove ServiceContractData and EntitledServiceData wrapper to seprate class
 *****************************************************************************************************/
global class SvmxGlobal {

    /**
     * Wrapper structure for custom button action request.
     */
	global class ActionRequest {
        @AuraEnabled
        global String actionName {get; set;}
        
        @AuraEnabled
        global SvmxPageData pageData {get; set;}
    }

    /**
     * Wrapper structure for runtime page data request/response.
     */
    @JsonAccess(serializable='always' deserializable='always')
    global class SvmxPageData {
        @AuraEnabled global String transactionType;
        @AuraEnabled global String pageLayoutId;
        @AuraEnabled global String sourceRecordId;
        @AuraEnabled global String targetRecordId;
        @AuraEnabled global String recordId;
        @AuraEnabled global sObject headerRecord;
        @AuraEnabled global List<SvmxPageDetail> pageDetails;
        @AuraEnabled global String detailLineId;
        @AuraEnabled global String actionType;
    }

    /**
     * Wrapper structure for related object details.
     */
	@JsonAccess(serializable='always' deserializable='always')
    global class SvmxPageDetail {
        @AuraEnabled global String uniqueKey;
        @AuraEnabled global List<sObject> detailRecords;
        @AuraEnabled global List<String> deleteIds;
    }

    /**
     * A wrapper class used to populate service response.
     */
    global virtual class SvmxResponse {
        
        // Boolean variable represents the request status.
        @AuraEnabled global Boolean success {get;set;}
        
        // String instance variable to hold success/error messages.
        @AuraEnabled global String message {get;set;}
        
        // Generic instance variable to hold response data.
        @AuraEnabled global Object data {get;set;}

        // Instance variable to hold multiple errors
        @AuraEnabled global List<SvmxError> errors {get;set;}

        // Wrapper class constructor.
        global SvmxResponse() {
            this.success = true;
        }
    }

    /**
     * Wrapper structure for capture error details.
     */
    global virtual class SvmxError {
  
        // String instance variable to hold referenceId values to map back to request object properties.
        @AuraEnabled global String referenceId {get;set;}
      
        // Error message
        @AuraEnabled global String message {get;set;}
      
        // Instance variable to hold multiple errors
        @AuraEnabled global List<SvmxError> errors {get;set;}
    }
}