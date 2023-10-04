/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Utility class for SOQL/SOSL operations.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       01 Jul 2020     Created.
 *              Jason Bradley           29 Jan 2021     Added filterRecordIdsSOSL for bare-bones SOSL querying (full record details to be retrieved on the client-side via LDS), and refactored condition building logic.
 *****************************************************************************************************/
public with sharing class COMM_DatabaseUtils {

    // Static variable to hold instance of this class.
    private static final COMM_DatabaseUtils instance = new COMM_DatabaseUtils();
    
    // Default limit count while retrieving records.
    private static final Integer DEFAULT_LIMIT = 20;

    // Static string variable to hold greater symbol : >
    private static final String GREATOR_SYMBOL = '>';
    
    // Static string variable to hold lesser symbol : <
    private static final String LESSER_SYMBOL= '<';
    
    // Static string variable to order : ASC
    private static final String ASC_ORDER = 'ASC';
    
    // Static string variable to order : DESC
    private static final String DESC_ORDER = 'DESC';

    // Static string variable to store package version
    public static  String  SvmxVersion = '';
    
    // Static method to get instance of this class.
    public static COMM_DatabaseUtils getInstance() {
        return instance;
    }
    
    /**
     * This method is used to retrieve records requested filter criteria.
     * 
     * @param filterCriteria Filter criteral using which records to be retrieved.
     * 
     * @return Returns list of sobject records for requested filter criteria.
     */
    public List<SObject> queryRecords( final Config.FilterCriteria filterCriteria ) {
        
        System.debug( LoggingLevel.DEBUG, 'queryRecords() - enter; filterCriteria= ' + filterCriteria );
        
        List<SObject> recordList = new List<SObject>();
        
        try {
            
            if( filterCriteria == null || filterCriteria.fields == null || filterCriteria.fields.isEmpty() || String.isBlank(filterCriteria.objectName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'queryRecords() : One or more required parameters are missing.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );  
            }
            
            String queryString = 'SELECT ' + String.join( filterCriteria.fields, ',' ) + ' FROM ' + String.escapeSingleQuotes(filterCriteria.objectName);

            // Search terms and where clauses are not applicable when record id exists in the filter. 
            if( String.isNotBlank( filterCriteria.id ) ) {
                queryString += ' WHERE Id = \'' + String.escapeSingleQuotes( filterCriteria.id ) + '\'';
            } else if (filterCriteria.developerNames!=null && filterCriteria.developerNames.size() > 0) {
                queryString +=' WHERE SVMXA360__DeveloperName__c IN (\'' + String.join(filterCriteria.developerNames, '\',\'') + '\')';
            }
            else {
                
                // Search term applied only on Name field. 
                if( String.isNotBlank( filterCriteria.searchTerm ) ) {
                    queryString += ' WHERE Name LIKE  \'%' + String.escapeSingleQuotes(filterCriteria.searchTerm)  + '%\' ';
                }
                
                // Append where clause along with search term if exists.
                if( String.isNotBlank( filterCriteria.whereClause ) ) {
                    queryString += String.isNotBlank( filterCriteria.searchTerm ) ? ' AND ' +  filterCriteria.whereClause : ' WHERE ' + filterCriteria.whereClause;
                }

                if(String.isNotBlank(filterCriteria.sortField) && String.isNotBlank(filterCriteria.sortOrder)){
                    //ORDER BY clause
                    queryString +=' ORDER BY '+String.escapeSingleQuotes(filterCriteria.sortField)+' '+String.escapeSingleQuotes(filterCriteria.sortOrder);
                }
                
                // If linit not exists, set limit count to default.
                queryString += ' LIMIT ' + ( filterCriteria.limitCount != null ? filterCriteria.limitCount : DEFAULT_LIMIT );
            }
            
            System.debug( LoggingLevel.INFO, 'queryRecords() : queryString= ' + queryString );
            recordList = SvmxDatabase.query( queryString );
        } 
        catch (Exception e) {

            System.debug( LoggingLevel.ERROR, 'getFieldDefinitionsList() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            throw e;
        } 
        finally {
            System.debug( LoggingLevel.DEBUG, 'queryRecords() - exit; recordList= ' + recordList );
        }

        return recordList;  
    }
    
    /**
     * This method is used to retrieve package version.
     * 
     * @return Returns package version of A360.
     */
    public String getPackageVersion() {
        
        System.debug( LoggingLevel.DEBUG, 'getPackageVersion() - enter');
        
        try {

            if ( String.isBlank(SvmxVersion) ) {
                String queryString = 'SELECT MajorVersion,MinorVersion FROM Publisher WHERE NamespacePrefix = \'SVMXA360\' AND MajorVersion != 0';
                
                List<Publisher> pbList = database.query( queryString );

                if(pbList.size() > 0) {
                    SvmxVersion = String.valueOf(pbList.get(0).MajorVersion) + '.' + String.valueOf(pbList.get(0).MinorVersion);
                }
            }

        } 
        catch(System.TypeException e) {
            //default version
            return '6.0';
        }

        catch (Exception e) {

            System.debug( LoggingLevel.ERROR, 'getPackageVersion() : Failed to retrieve package version. Error' + e.getStackTraceString() );
            throw e;
        } 
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPackageVersion() - exit; SvmxVersion= ' + SvmxVersion );
        }

        return SvmxVersion;  

    }

    /**
     * This method will give the filter record of object based on the filtercriteria.
     * 
     * @param filterCriteria Filter criteral using which records to be retrieved.
     * 
     * @return Returns list of sobject records for requested filter criteria.
     */
    public List<SObject> filterRecords( final Config.LookupFilterCriteria filterCriteria ) {
        // TODO: (Technical Debt - Performance and Debugging): JIRA# A360ENG-841
        System.debug(LoggingLevel.DEBUG, 'filterRecords() - enter; filterCriteria= ' + filterCriteria);
        
        List<SObject> recordList = new List<SObject>();
        
        try {
            if (filterCriteria == null || !filterCriteria.isValid() || !filterCriteria.hasSelectFields()) {
                System.debug(LoggingLevel.ERROR, 'filterRecords() : One or more required parameters are missing.');
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);  
            }
            
            String queryString = 'SELECT ' + String.join(filterCriteria.fields, ',') +
                ' FROM ' + String.escapeSingleQuotes( filterCriteria.objectName ) +
                getLookupFilterWhereClause(filterCriteria);
            
            System.debug(LoggingLevel.INFO, 'filterRecords() : queryString= ' + queryString);

            recordList = SvmxDatabase.query(queryString);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'filterRecords() : Failed to retrieve field definitions. Error' + e.getStackTraceString());
            throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'filterRecords() - exit; recordList= ' + recordList);
        }

        return recordList;  
    }

    /**
     * Executes a SOQL query given the specified filter criteria, and returns a list
     * of Ids for the matching records. Useful when you need specific text search operators
     * beyond just "Contains".
     * Only Ids are returned to allow for client-side caching through the LDS.
     * 
     * @param filterCriteria Filter criteral using which records to be retrieved.
     * 
     * @return Returns list of SObject ids for the requested filter criteria.
     */
    public List<Id> filterRecordIds(final Config.LookupFilterCriteria filterCriteria) {
        // TODO: (Technical Debt - Performance and Debugging): JIRA# A360ENG-841
        System.debug(LoggingLevel.DEBUG, 'filterRecordIds() - enter; filterCriteria= ' + filterCriteria);

        List<Id> recordIds = new List<Id>();

        try {
            if (filterCriteria == null || !filterCriteria.isValid()) {
                System.debug(LoggingLevel.ERROR, 'filterRecordIds() : One or more required parameters are missing.');
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }

            String queryString = 'SELECT Id' + 
                ' FROM ' + filterCriteria.objectName +
                getLookupFilterWhereClause(filterCriteria, true);

            System.debug(LoggingLevel.INFO, 'filterRecordIds() : queryString= ' + queryString);

            List<SObject> records = SvmxDatabase.query(queryString);
            for (SObject record : records) {
                recordIds.add(record.Id);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'filterRecordIds() : Failed to execute search for record ids. Error' + e.getStackTraceString());
            throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'filterRecordIds() - exit; recordIds= ' + recordIds);
        }

        return recordIds;  
    }

    /**
     * Executes a SOSL query given the specified filter criteria, and returns a 2-dimensional list
     * of Ids for the matching records. Each inner-list is a list of record ids for a single
     * SObjectType. By far the most performant approach for Contains text searches.
     * Only Ids are returned to allow for client-side caching through the LDS.
     * 
     * @param filterCriteria Filter criteral using which records to be retrieved.
     * 
     * @return Returns list of lists of SObject ids for the requested filter criteria.
     */
    public List<List<Id>> filterRecordIdsSOSL(final Config.LookupFilterCriteria filterCriteria) {
        // TODO: (Technical Debt - Performance and Debugging): JIRA# A360ENG-841
        System.debug(LoggingLevel.DEBUG, 'filterRecordIdsSOSL() - enter; filterCriteria= ' + filterCriteria);

        List<List<Id>> recordIdsBySObjectType = new List<List<Id>>();

        try {
            if (filterCriteria == null || !filterCriteria.isValid()) {
                System.debug(LoggingLevel.ERROR, 'filterRecordIdsSOSL() : One or more required parameters are missing.');
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }

            /* TODO: Allow SOSL SearchGroup to be configurable:
                https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_in.htm#topic-title
            */
            String queryString = 'FIND ' + getFindClause(filterCriteria) +
                ' IN ALL FIELDS' +
                ' RETURNING ' + filterCriteria.objectName +
                '(Id ' + getLookupFilterWhereClause(filterCriteria, false) + ')';

            System.debug(LoggingLevel.INFO, 'filterRecordIdsSOSL() : queryString= ' + queryString);

            List<List<SObject>> recordsBySObjectType = SvmxDatabase.search(queryString);
            if (recordsBySObjectType == null || recordsBySObjectType.size() == 0) {
                System.debug(LoggingLevel.ERROR, 'filterRecordIdsSOSL() : Failed to execute SOSL search.');
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.OBJECT_NOT_EXISTS);
            }

            // Coerce multi-SObject record lists into multi-SObject Id lists
            for (List<SObject> records : recordsBySObjectType) {
                List<Id> recordIds = new List<Id>();
                recordIdsBySObjectType.add(recordIds);

                for (SObject record : records) {
                    recordIds.add(record.Id);
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'filterRecordIdsSOSL() : Failed to execute search for record ids. Error' + e.getStackTraceString());
            throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'filterRecordIdsSOSL() - exit; recordIdsBySObjectType= ' + recordIdsBySObjectType);
        }

        return recordIdsBySObjectType;  
    }

    private String getLookupFilterWhereClause(Config.LookupFilterCriteria filterCriteria, Boolean applySearchTerm) {
        List<String> conditions = new List<String>();
        
        String whereClause = '';

        // Search terms and where clauses are not applicable when record id exists in the filter. 
        if (String.isNotBlank(filterCriteria.id)) {
            conditions.add('Id = \'' + String.escapeSingleQuotes(filterCriteria.id) + '\'');
        } else {
            // Add base filter criteria
            if (String.isNotBlank(filterCriteria.whereClause)) {
                conditions.add(filterCriteria.whereClause);
            }

            // Apply the lookup context filter
            String contextFilter = filterCriteria.getContextFilter();
            if (String.isNotBlank(contextFilter)) {
                conditions.add(contextFilter);
            }

            // Apply search term filter criteria (if applicable)
            if (applySearchTerm == true && filterCriteria.hasSearchFields() &&
                String.isNotBlank(filterCriteria.searchTerm)) {

                filterCriteria.searchTerm = String.escapeSingleQuotes(filterCriteria.searchTerm);

                // TODO: Make getFilterClauseWithSearchField an instance method of Config.LookupFilterCriteria?
                String filterClauseWithSearchField = getFilterClauseWithSearchField(filterCriteria);
                if (String.isNotBlank(filterClauseWithSearchField)) {
                    conditions.add(filterClauseWithSearchField);
                }
            }
        }

        Integer limitCount = filterCriteria.limitCount;
        limitCount = limitCount != null && limitCount > 0 ? limitCount : DEFAULT_LIMIT;

        return (conditions.size() > 0 ? ' WHERE ' + String.join(conditions, ' AND ') : '') +
            // A bit confusing to have LIMIT tacked onto a method that is related to the where
            // clause, but I'll leave this for now to avoid additional refactoring.
            ' LIMIT ' + limitCount;
    }

    private String getLookupFilterWhereClause(Config.LookupFilterCriteria filterCriteria) {
        return getLookupFilterWhereClause(filterCriteria, true);
    }

    /**
     * This method will give the filter record of object based on the filtercriteria.
     * 
     * @param filterCriteria - Filter criteral using which records to be retrieved.
     * 
     * @return Returns where clause string based on the all the fields where we want to do search  
     * along with the related serach operator.
     */
    private String getFilterClauseWithSearchField(Config.LookupFilterCriteria filterCriteria){
        String filterClause = '';

        if(filterCriteria.lstSearchInFields == null || filterCriteria.lstSearchInFields.isEmpty()){
            return filterClause;
        }

        List<String> filterConditions = new List<String>();

        for (String searchField : filterCriteria.lstSearchInFields) {
            Common.FieldDefinition fieldDefinition = COMM_MetadataManager.getInstance().getFieldDefinition(
                filterCriteria.objectName,
                searchField,
                true
            );

            String fieldFilter = getFilterClause(filterCriteria, searchField, fieldDefinition.dataType);
            if (String.isNotBlank(fieldFilter)) {
                filterConditions.add(fieldFilter);
            }
        }

        if (!filterConditions.isEmpty()) {
            filterClause = ' ( ' + String.join(filterConditions, ' OR ') + ' ) ';
        }

        return filterClause;
    }

    /**
     * This method will give the filter record of object based on the filtercriteria.
     * 
     * @param filterCriteria - Filter criteral using which records to be retrieved.
     *
     * @param searchField - Search field which will be used to form where clause.
     * 
     * @return Returns where clause string based on the searchfield and serach operator.
     */
    private String getFilterClause(Config.LookupFilterCriteria filterCriteria, String searchField, String dataType){
        String filterClause = ''; 
        if(String.isNotBlank(searchField) && String.isNotBlank(filterCriteria.searchTerm) && String.isNotBlank(filterCriteria.searchOperator) && String.isNotBlank(dataType)){
            if(datatype.equalsIgnoreCase( Schema.DisplayType.Integer.name() ) || datatype.equalsIgnoreCase( Schema.DisplayType.Long.name() )
            || datatype.equalsIgnoreCase( Schema.DisplayType.Percent.name() ) || datatype.equalsIgnoreCase( Schema.DisplayType.Currency.name() ) 
            || datatype.equalsIgnoreCase( Schema.DisplayType.Double.name() ) ) {
                filterClause = filterCriteria.searchTerm.isNumeric() ?
                searchField +' = ' + filterCriteria.searchTerm : '';
            }else if( datatype.equalsIgnoreCase( Schema.DisplayType.ID.name() ) ) {
                filterClause = filterCriteria.searchTerm InstanceOf ID ?
                    searchField +' = \'' + filterCriteria.searchTerm +'\'' : '';
            }else{
                if(filterCriteria.searchOperator == 'exact match'){
                    filterClause = searchField +' = \'' + String.escapeSingleQuotes(filterCriteria.searchTerm) + '\'';
                } else if(filterCriteria.searchOperator == 'contains'){
                    filterClause = searchField+' like \'%' + String.escapeSingleQuotes(filterCriteria.searchTerm) + '%\'';
                } else if(filterCriteria.searchOperator == 'starts with'){
                    filterClause = searchField+' like \'' + String.escapeSingleQuotes(filterCriteria.searchTerm) + '%\'';
                } else if(filterCriteria.searchOperator == 'ends with'){
                    filterClause = searchField+' like \'%' + String.escapeSingleQuotes(filterCriteria.searchTerm) + '\'';
                }
            }
        }
        return filterClause;
    }

    /**
     * Returns a SOSL FIND clause according to the configuration in the Config.LookupFilterCriteria
     * that is passed.
     * 
     * @param filterCritera - Filter criteria that specifies what value to search for and which
     * operator to use to search for it.
     * 
     * @return Returns a SOSL FIND clause string based on the searchField and searchOperator.
     */
    private String getFindClause(Config.LookupFilterCriteria filterCriteria) {
        String searchTerm = String.escapeSingleQuotes(filterCriteria.searchTerm);
        switch on filterCriteria.searchOperator.toLowerCase() {
            when 'contains' {
                return '\'' + searchTerm + '\'';
            }
            when 'starts with' {
                return '\'' + searchTerm + '*\'';
            }
            when 'ends with' {
                return '\'*' + searchTerm + '\'';
            }
            when else {
                return '\'' + searchTerm + '\'';
            }
        }
    }

    /**
     * This method is used to return the user theme.
     * 
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * successful update of source record, Otherwise, set it to 'false'.
     */
    @AuraEnabled
    public static Common.ServiceResponse fetchApplicationNavigationType() {
        
        System.debug( LoggingLevel.DEBUG, 'fetchApplicationNavigationType() - enter');
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        serviceResponse.data = 'Standard';

        try {
            List<UserAppInfo>  appInfo = SvmxDatabase.query([Select AppDefinitionId from UserAppInfo where 
                                                             UserId = :userinfo.getUserId()]);
            if(!appInfo.isEmpty()) {
                List<AppDefinition> appDef = SvmxDatabase.query([Select NavType,Id from AppDefinition where 
                                                                durableId = :appInfo[0].AppDefinitionId]);
                if(!appDef.isEmpty()) {
                    serviceResponse.data = appDef[0].NavType;
                }
            }
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchApplicationNavigationType() : Failed to get the user theme. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchApplicationNavigationType() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to return the user theme.
     * 
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * successful update of source record, Otherwise, set it to 'false'.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getObjectAPIFromRecordId(String objectId) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectAPIFromRecordId() - enter');
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            if(String.isNotBlank(objectId)){
                ID objectRecId = objectId;
                String objectApiName = objectRecId.getSObjectType().getDescribe().getName();
                serviceResponse.data = objectApiName;
            }else{
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
        }
        catch(StringException ex){
             System.debug( LoggingLevel.ERROR, 'getObjectAPIFromRecordId() : Failed to get the ObjectAPI for given recordId. Error' + ex.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectAPIFromRecordId() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        return serviceResponse;
    }

    /**
     * This method will give the orderby and limit clause based on the filtercriteria.
     * 
     * @param orderByCriteria - OrderBy critera using which order and how many records to be retrieved.
     *
     * @return Returns orderby,limit and offset clause clause string based on filterCriteria.
     */
    public String getOrderByLimitClause(Config.FilterCriteria orderByCriteria){
        String orderByLimitClause = '';
        
        //descending order use  < operator and ascending order use > operator
        //custom offsetClause - record id comparision to get start index of the next set - orderByCriteria.id is last recordId
        if(String.isNotBlank(orderByCriteria.id)) {
            String orderSymbol ='';
            if(String.isNotBlank(orderByCriteria.sortOrder) &&  orderByCriteria.sortOrder == ASC_ORDER) {
                orderSymbol = GREATOR_SYMBOL;
            }else {
                orderSymbol = LESSER_SYMBOL;
            }           
            orderByLimitClause += ' AND Id '+String.escapeSingleQuotes(orderSymbol)+'\''+String.escapeSingleQuotes(orderByCriteria.id)+'\'';
        }
        
        if(String.isNotBlank(orderByCriteria.sortField) && String.isNotBlank(orderByCriteria.sortOrder)){
            //ORDER BY clause
            orderByLimitClause +=' ORDER BY '+String.escapeSingleQuotes(orderByCriteria.sortField)+' '+String.escapeSingleQuotes(orderByCriteria.sortOrder);
        }       
        //LIMIT and OFFSET clause
        orderByLimitClause += (orderByCriteria.limitCount!=null) ? ' LIMIT '+ orderByCriteria.limitCount:'';
        orderByLimitClause += (orderByCriteria.queryOffset!=null) ? ' OFFSET '+ orderByCriteria.queryOffset:'';     
        
        return orderByLimitClause;
    }
    
    public List<Common.PicklistValue> getCurrencyCodeValues(Config.FilterCriteria filterCriteria){
        
        System.debug( LoggingLevel.DEBUG, 'getCurrencyCodeValues - filterCriteria='+filterCriteria);
        
        List<Common.PicklistValue> picklistValues = new List<Common.PicklistValue>();
        try {
        
            if( filterCriteria == null || String.isBlank(filterCriteria.objectName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getCurrencyCodeValues() : Invalid argument; filterCriteria= ' + filterCriteria);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            if (!UserInfo.isMultiCurrencyOrganization()) {
                return picklistValues;
            }
        
            Map<String, Schema.DescribeFieldResult> fieldDescribe = COMM_DescribeManager.getInstance().getFieldDescribeResults(filterCriteria.objectName);
            if(!fieldDescribe.isEmpty()){
                Schema.DescribeFieldResult describeResult = fieldDescribe.get('CurrencyIsoCode');
                for(Schema.PicklistEntry eachValue : describeResult.getPicklistValues()){
                    
                    Common.PicklistValue picklistValue = new Common.PicklistValue();
                    picklistValue.label = eachValue.getValue()+' - '+eachValue.getLabel();
                    picklistValue.value = eachValue.getValue();                    
                    picklistValues.add( picklistValue );
                }
            }
            System.debug(LoggingLevel.INFO, 'getCurrencyCodeValues() : Picklist values of CurrencyIsoCode field = ' + picklistValues);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getCurrencyCodeValues() : Failed to retrieve currency codes. Error= ' + e.getMessage() );
            throw e;
        }
        catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'getCurrencyCodeValues() : Failed to retrieve currency codes. Error= ' + ex.getStackTraceString() );
            throw ex;
        }
        return picklistValues;
    }
    

    // Private class constructor to avoid creating multiple instance of this class.
    private COMM_DatabaseUtils(){}
}