/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to retrieve metadata related to columns and filter records  
 * for lookup filter component.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni          17 August 2020     Created.
 * A360ENG-539  Jason Bradley        29 Jan 2021        Added SOSL interface for Lookup Field. Greatly
 *                                                      reduces upfront metadata info necessary to
 *                                                      execute the search, and is more efficient for
 *                                                      text searching in general.
 * A360ENG-1648 Jason Bradley       15 Oct 2021         Added empty record id fallback when an invalid
 *                                                      operator exception occurs.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class COMM_LookupModalController {
    // TODO: Best Practice - Use Static over Instance Methods: JIRA# A360ENG-842

    /**
     * This method retrieves the metadata of columns from the  SVMXA360__CONF_LookupConfiguration__c
     * record for the given record id.
     * 
     * @return Returns instance of Common.ServiceResponse with list of Common.FieldDefinition.
     */
    public Common.ServiceResponse getLookupConfigColumns(final String lookupConfigId, final String objectAPIName,
    final String referenceNameField){

        System.debug( LoggingLevel.DEBUG, 'getLookupConfigColumns() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            if(String.isNotBlank(lookupConfigId)){
                List<Common.FieldDefinition> lkpModalColWrapLst = new List<Common.FieldDefinition>();

                List<SVMXA360__CONF_LookupConfiguration__c> lkpConfigLst = getLookupFilterRecords(lookupConfigId);

                if(!lkpConfigLst.isEmpty()){
                    SVMXA360__CONF_LookupConfiguration__c lkpConfig = lkpConfigLst.get(0);
                    lkpConfig.SVMXA360__DisplayFields__c = String.isNotBlank(lkpConfig.SVMXA360__DisplayFields__c) ? lkpConfig.SVMXA360__DisplayFields__c : referenceNameField;
                    lkpModalColWrapLst = getLkpColWrapperLst(lkpConfig);
                    serviceResponse.data = lkpModalColWrapLst;

                    System.debug( LoggingLevel.INFO, 'getLookupConfigColumns() : Formed lookup configuration successfully' );
                }else{
                    System.debug( LoggingLevel.ERROR, 'getLookupConfigColumns() : SVMXA360__CONF_LookupConfiguration__c record not found.' );

                    serviceResponse.success = false;
                    serviceResponse.message = 'SVMXA360__CONF_LookupConfiguration__c record not found.';
                }
            }else if(String.isNotBlank(objectAPIName)){
                SVMXA360__CONF_LookupConfiguration__c lkpConfig = new SVMXA360__CONF_LookupConfiguration__c();
                lkpConfig.SVMXA360__ObjectAPIName__c = objectAPIName;
                lkpConfig.SVMXA360__DisplayFields__c = referenceNameField;
                serviceResponse.data = getLkpColWrapperLst(lkpConfig);
            }else{
                System.debug( LoggingLevel.ERROR, 'getLookupConfigColumns() : Failed to fetch lookup configuration. Error - Required field lookupConfigId/objectAPIName is missing.');

                serviceResponse.success = false;
                serviceResponse.message = 'Required field lookupConfigId/objectAPIName is missing.';
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getLookupConfigColumns() : Failed to fetch lookup configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigColumns() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method forms the List<Common.FieldDefinition> from the SVMXA360__DisplayFields__c field of
     * SVMXA360__CONF_LookupConfiguration__c record.
     * 
     * @return Returns instance of Common.ServiceResponse with list of Common.FieldDefinition.
     */
    private List<Common.FieldDefinition> getLkpColWrapperLst(SVMXA360__CONF_LookupConfiguration__c lkpConfig){
        List<Common.FieldDefinition> lkpModalColWrapLst = new List<Common.FieldDefinition>();

        if(String.isNotBlank(lkpConfig.SVMXA360__ObjectAPIName__c)){
            List<String> fieldNameList = lkpConfig.SVMXA360__DisplayFields__c.toLowerCase().split(',');
            Map<String, Common.FieldDefinition> displayFieldVsLkpColWrapMap =
            new Map<String, Common.FieldDefinition>();

            List<Common.EntityDefinition> entityDefinitionList = COMM_MetadataManager.getInstance().getFieldDefinitions(new List<String>{lkpConfig.SVMXA360__ObjectAPIName__c}, true);

            if(entityDefinitionList != null && !entityDefinitionList.isEmpty() && entityDefinitionList.get(0).fieldDefinitions != null && !entityDefinitionList.get(0).fieldDefinitions.isEmpty()){
                List<Common.FieldDefinition> fieldDefinitionList = entityDefinitionList.get(0).fieldDefinitions;

                for(Common.FieldDefinition fieldDefinition : fieldDefinitionList) {
                    String fieldName = fieldDefinition.apiName.toLowerCase();
                    if(fieldNameList.contains(fieldName)){
                        displayFieldVsLkpColWrapMap.put(fieldName, fieldDefinition);
                    }
                }
            }

            for(String fieldName : fieldNameList) {
                if(displayFieldVsLkpColWrapMap.containsKey(fieldName)) {
                    lkpModalColWrapLst.add(displayFieldVsLkpColWrapMap.get(fieldName));
                }
            }
        }

        return lkpModalColWrapLst;
    }

    /**
     * This method will give the list of object records based on the search term and SVMXA360__CONF_LookupConfiguration__c record.
     * 
     * @param filterCriteria - Filter criteral using which records to be retrieved.
     * 
     * @return Returns instance of Common.ServiceResponse with list of filter records.
     */
    public Common.ServiceResponse getFilteredRecords(Config.LookupFilterCriteria filterCriteria) {
        System.debug( LoggingLevel.DEBUG, 'getFilteredRecords() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // == Pre-validation
            if (filterCriteria == null) {
                System.debug(LoggingLevel.ERROR, 'getMatchingRecordIds() : Failed to fetch records. FilterCriteria cannot be null.');
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }

            // == Filter criteria initial setup + defaults
            filterCriteria.stampDefaults();

            // == Stamp lookup configuration record values, where populated
            if (String.isNotBlank(filterCriteria.lookupConfigId)) {
                List<SVMXA360__CONF_LookupConfiguration__c> lkpConfigLst = getLookupFilterRecords(String.escapeSingleQuotes(filterCriteria.lookupConfigId));

                if (!lkpConfigLst.isEmpty()) {
                    filterCriteria.stampLookupConfiguration(lkpConfigLst[0]);
                }
            }

            serviceResponse.data = COMM_DatabaseUtils.getInstance().filterRecords(filterCriteria);
            System.debug(LoggingLevel.INFO, 'getFilteredRecords() : Fetched records successfully');
        } catch (System.QueryException e) {
            if (e.getMessage() == 'invalid operator') {
                System.debug(LoggingLevel.ERROR, 'getFilteredRecords() : Failed to execute search for records due to null operand value. Responding with empty record list instead. Error' + e.getStackTraceString());
                serviceResponse.data = new List<SObject>();
            } else {
                System.debug(LoggingLevel.ERROR, 'getFilteredRecords() : Failed to execute search for records. Error' + e.getStackTraceString());
                throw e;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getFilteredRecords() : Failed to execute search for records. Error' + e.getStackTraceString());
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getLookupConfigColumns() - exit; serviceResponse.success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }

    private List<SVMXA360__CONF_LookupConfiguration__c> getLookupFilterRecords(String lookupConfigId) {
        return (List<SVMXA360__CONF_LookupConfiguration__c>)SvmxDatabase.query([SELECT SVMXA360__ObjectAPIName__c, SVMXA360__SearchFields__c, SVMXA360__FieldToReturn__c, SVMXA360__DisplayFields__c, SVMXA360__RecordsPerPageReturn__c, SVMXA360__BasicFilter__c, SVMXA360__BasicFilter__r.SVMXA360__Criteria__c FROM SVMXA360__CONF_LookupConfiguration__c WHERE ID =: String.escapeSingleQuotes(lookupConfigId) LIMIT 1]);
    }

    /**
     * This method will give a list of record ids based on the target object name and search term.
     * If a SVMXA360__CONF_LookupConfiguration__c record id is also provided, any populated fields
     * in that record will be used as overrides for the properties supplied directly in <filterCriteria>.
     * 
     * @param filterCriteria - Query info and filter criteria used to retrieve a set of matching record ids.
     * 
     * @return Returns instance of Common.ServiceResponse with list of record ids that match the given filter criteria.
     */
    public Common.ServiceResponse getMatchingRecordIds(Config.LookupFilterCriteria filterCriteria) {
        System.debug( LoggingLevel.DEBUG, 'getMatchingRecordIds() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // == Pre-validation
            if (filterCriteria == null) {
                System.debug(LoggingLevel.ERROR, 'getMatchingRecordIds() : Failed to fetch records. FilterCriteria cannot be null.');
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }

            // == Filter criteria initial setup + defaults
            filterCriteria.stampDefaults();
        
            // == Stamp lookup configuration record values, where populated
            if (String.isNotBlank(filterCriteria.lookupConfigId)) {
                List<SVMXA360__CONF_LookupConfiguration__c> lkpConfigLst = getLookupFilterRecords(String.escapeSingleQuotes(filterCriteria.lookupConfigId));

                if (!lkpConfigLst.isEmpty()) {
                    filterCriteria.stampLookupConfiguration(lkpConfigLst[0]);
                }
            }

            // == Resolve any reference type search fields to their "name" fields
            filterCriteria.resolveReferenceSearchFieldsToNameFields();

            // == Execute search and stamp results in response packet (Uses SOSL where applicable, LDS
            // will be used on the client-side for caching the full record details)
            // SOSL mode disabled for now for improved field search support. It seems some standard fields aren't indexed.
            /*if (filterCriteria.searchTerm.length() > 1 && (String.isNotBlank(filterCriteria.searchOperator) && filterCriteria.searchOperator == 'contains')) {
                // TODO: Support multiple target objects (Would need changes to lookup configuration as well, not worth looking at unless needed)
                serviceResponse.data = COMM_DatabaseUtils.getInstance().filterRecordIdsSOSL(filterCriteria)[0];
            } else {*/
                serviceResponse.data = COMM_DatabaseUtils.getInstance().filterRecordIds(filterCriteria);
            //}

            System.debug(LoggingLevel.INFO, 'getMatchingRecordIds() : Fetched records successfully');
        } catch (System.QueryException e) {
            if (e.getMessage() == 'invalid operator') {
                System.debug(LoggingLevel.ERROR, 'getMatchingRecordIds() : Failed to execute search for record ids due to null operand value. Responding with empty record Id list instead. Error' + e.getStackTraceString());
                serviceResponse.data = new List<Id>();
            } else {
                System.debug(LoggingLevel.ERROR, 'getMatchingRecordIds() : Failed to execute search for record ids. Error' + e.getStackTraceString());
                throw e;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getMatchingRecordIds() : Failed to execute search for record ids. Error' + e.getStackTraceString());
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getMatchingRecordIds() - exit; serviceResponse.success= ' + serviceResponse.success);
        }
        
        return serviceResponse;
    }
}