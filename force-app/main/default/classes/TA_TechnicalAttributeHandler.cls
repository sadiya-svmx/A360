/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/save/delete TA informations from Salesforce Org. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID         Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Karthick Saravanan      16 June 2022      Created.
 A360AM-1859 Jeevika Rao             26 June 2022      Included methods to save Asset Technical Attributes
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class TA_TechnicalAttributeHandler {
    
    //Private variable to hold logger instance for entitlement.
    private final SvmxLogger logger = SvmxLogger.getLogger( SvmxLogger.Application.TechnicalAttribute );
    
    //Holds Attribute field Name mapping 
    private Map<TechAttr.AttributeField, String> attributeFieldMap = new Map<TechAttr.AttributeField, String>();
    
    //Variable to store API source
    private final String API_SOURCE = 'External System';
    
    //Varible to store Asset object name
    private final String ASSET_OBJ = 'Asset';
    
    //Variable to store object name for Asset Technical attribute
    private final String ASSET_TECH_ATTRIBUTE = 'SVMXA360__SM_TA_AssetTechnicalAttribute__c';
    
    private final TA_TechnicalAttributeManager taManager = TA_TechnicalAttributeManager.getInstance();
    
    
    public List<SVMXA360__SM_TA_TechnicalAttribute__c> deleteCheckOnTA (Set<Id> attributeIdSet, boolean isTriggerExecution) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteCheckOnTA() - enter; attributeIdSet= ' + attributeIdSet+ ',isTriggerExecution = ' + isTriggerExecution );

        List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = new List<SVMXA360__SM_TA_TechnicalAttribute__c>();
        try {

            for (TechAttr.TechnicalAttributeReference eachTAReference : deleteCheckOnTA(attributeIdSet) ) {

                SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord = (SVMXA360__SM_TA_TechnicalAttribute__c)Trigger.oldMap.get(eachTAReference.id);

                if ( (eachTAReference.relatedAssetTechnicalAttributes != null && eachTAReference.relatedAssetTechnicalAttributes.size() > 0) ||
                     (eachTAReference.relatedTemplates != null && eachTAReference.relatedTemplates.size() > 0) ) {

                    attributeRecord.addError(Label.Error_ActionNotSupported+' '+Label.Message_AssetTimeline_Error_Body);
                }
                technicalAttributeRecords.add(attributeRecord);
            }            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnTA() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnTA() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCheckOnTA() - exit; technicalAttributeRecords= ' + technicalAttributeRecords );
        }

        return technicalAttributeRecords;
    }
    
    public List<TechAttr.TechnicalAttributeReference> deleteCheckOnTA (Set<Id> attributeIdSet) {
        System.debug( LoggingLevel.DEBUG, 'deleteCheckOnTA() - enter; attributeIdSet= ' + attributeIdSet );

        List<TechAttr.TechnicalAttributeReference> technicalAttributeReferences = new List<TechAttr.TechnicalAttributeReference>();
        try {
            if( attributeIdSet == null || attributeIdSet.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' attributeIdSet= ' + attributeIdSet );
            }

            for (SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord : (List<SVMXA360__SM_TA_TechnicalAttribute__c>)SvmxDatabase.query([ 
                SELECT ID, Name,
                    (SELECT ID, Name, SVMXA360__TemplateId__c, SVMXA360__TemplateId__r.Name FROM TechnicalAttributeTemplateItems__r),
                    (SELECT ID, Name FROM AssetTechnicalAttributes__r),
                    (SELECT Id, SVMXA360__UserGroupId__c, SVMXA360__UserGroupId__r.Name FROM A360_User_Group_Technical_Attributes__r)
                FROM SVMXA360__SM_TA_TechnicalAttribute__c
                WHERE ID IN : attributeIdSet
            ]) ) {
                technicalAttributeReferences.add(relatedRecordsCheckOnTA(attributeRecord));
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnTA() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnTA() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCheckOnTA() - exit; technicalAttributeReferences= ' + technicalAttributeReferences );
        }

        return technicalAttributeReferences;

    }

    private TechAttr.TechnicalAttributeReference relatedRecordsCheckOnTA (SVMXA360__SM_TA_TechnicalAttribute__c attributeRecord) {
        
        System.debug( LoggingLevel.DEBUG, 'relatedRecordsCheckOnTA() - enter; attributeRecord= ' + attributeRecord );
        
        TechAttr.TechnicalAttributeReference attributeReference = new TechAttr.TechnicalAttributeReference();
        attributeReference.id = attributeRecord.Id;
        attributeReference.name = attributeRecord.Name;

        //In case only Asset Technical Attributes are presnet
        if ( !attributeRecord.AssetTechnicalAttributes__r.isEmpty() && attributeRecord.AssetTechnicalAttributes__r.size() > 0) {
            
            List<Adm.LookupInfo> assetTARecords = new List<Adm.LookupInfo>();
            for (SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTA : attributeRecord.AssetTechnicalAttributes__r) {

                Adm.LookupInfo assetTARecord = new Adm.LookupInfo();
                assetTARecord.id = assetTA.Id;
                assetTARecord.name = assetTA.Name;
                assetTARecords.add(assetTARecord);               
            }
            attributeReference.relatedAssetTechnicalAttributes = assetTARecords;
        }
        //In case only Technical Attribute Template Items are presnet
        if ( !attributeRecord.TechnicalAttributeTemplateItems__r.isEmpty() && attributeRecord.TechnicalAttributeTemplateItems__r.size() > 0) {
            
            //load unique related templates for the attribute
            Map<Id,TechAttr.TemplateItem> templateIdMap = new Map<Id,TechAttr.TemplateItem>();
            TechAttr.TemplateItem templateItem;
            for (SVMXA360__SM_TA_TemplateItem__c templateItemRecord : attributeRecord.TechnicalAttributeTemplateItems__r) {
                
                templateItem = new TechAttr.TemplateItem();
                templateItem.id = templateItemRecord.Id;
                templateItem.name = templateItemRecord.Name;
                templateItem.templateId =templateItemRecord.SVMXA360__TemplateId__c;
                templateItem.templateName =templateItemRecord.SVMXA360__TemplateId__r.Name;

                templateIdMap.put(templateItem.templateId,templateItem);          
            }
            attributeReference.relatedTemplates = templateIdMap.values();
        }

        //In case only User Groups are present
        if ( !attributeRecord.A360_User_Group_Technical_Attributes__r.isEmpty() && 
            attributeRecord.A360_User_Group_Technical_Attributes__r.size() > 0 ) {
            
            //load unique user groups for the attribute
            Map<Id,Adm.LookupInfo> userGroupMap = new Map<Id,Adm.LookupInfo>();
            Adm.LookupInfo userGroupRecord;

            for ( SVMXA360__CONF_UserGroupTechnicalAttribute__c userGroupTechAttr : attributeRecord.A360_User_Group_Technical_Attributes__r ) {
                
                userGroupRecord = new Adm.LookupInfo();
                userGroupRecord.id = userGroupTechAttr.SVMXA360__UserGroupId__c;
                userGroupRecord.name = userGroupTechAttr.SVMXA360__UserGroupId__r.Name;

                userGroupMap.put(userGroupRecord.id, userGroupRecord);          
            }
            attributeReference.relatedUserGroups = userGroupMap.values();
        }

        System.debug( LoggingLevel.DEBUG, 'relatedRecordsCheckOnTA() - exit; attributeReference= ' + attributeReference );

        return attributeReference;
    }

    private void populateAssetRecordId( TechnicalAttributeRequest requestData ) {

        final TechAttr.TechnicalAttributeRequest technicalAttributeRequest = (TechAttr.TechnicalAttributeRequest) requestData;
        Map<String,List<TechAttr.TechnicalAttributeData>> externalValueTechnicalAttributeMap = new  Map<String,List<TechAttr.TechnicalAttributeData>>();

        for( TechnicalAttributeData attributeData : technicalAttributeRequest.attributeList ) {
            TechAttr.TechnicalAttributeData technicalAttributeData = (TechAttr.TechnicalAttributeData) attributeData;
    
            if ( String.isBlank(technicalAttributeData.recordId) && String.isBlank(technicalAttributeData.recordName)  ) {
                if ( !technicalAttributeData.assetIdentifiers.isEmpty() ) {
                    String externalValue = '';
        
                    for ( TechAttr.AssetIdentifier assetIdentifier : technicalAttributeData.assetIdentifiers ) {
                        externalValue = externalValue + assetIdentifier.value;
                    }
                    if( !externalValueTechnicalAttributeMap.containsKey(externalValue) ) {
                        externalValueTechnicalAttributeMap.put( externalValue, new List<TechAttr.TechnicalAttributeData>() );
                    }
                    externalValueTechnicalAttributeMap.get(externalValue).add(technicalAttributeData);
                }
            }
        }

        if ( !externalValueTechnicalAttributeMap.isEmpty() ) {
            Set<String> externalFieldValues = externalValueTechnicalAttributeMap.keySet();
            String assetQuery = ' Select Id, ' + technicalAttributeRequest.assetIdentifierFieldAPIName + ' from Asset Where ' + technicalAttributeRequest.assetIdentifierFieldAPIName + ' IN :externalFieldValues';
            System.debug(LoggingLevel.INFO, 'saveTechnicalAttributes() - assetQuery = ' + assetQuery);
            List<Asset> assetList = SvmxDatabase.query(Database.query( assetQuery ) );

            for ( Asset assetRecord : assetList ) {
                if ( externalValueTechnicalAttributeMap.containsKey((String)assetRecord.get(technicalAttributeRequest.assetIdentifierFieldAPIName)) ) {
                    for ( TechAttr.TechnicalAttributeData techAttrData : externalValueTechnicalAttributeMap.get((String)assetRecord.get(technicalAttributeRequest.assetIdentifierFieldAPIName)) ) {
                        techAttrData.recordId = assetRecord.Id;
                    }
                }
            }
        }

        for (TechnicalAttributeData eachRec: technicalAttributeRequest.attributeList) {

            TechAttr.TechnicalAttributeData attrData = (TechAttr.TechnicalAttributeData) eachRec;
                
            if ( String.isBlank(attrData.recordId) && attrData.assetIdentifiers != null && 
                 !attrData.assetIdentifiers.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Asset not found for the asset identifiers' );
                String identifierValue = '';
                for ( TechAttr.AssetIdentifier identifier : attrData.assetIdentifiers ) {
                    identifierValue = identifierValue + identifier.value;
                }
                throw new SvmxSystem.SvmxNestedException( 'RecordId: '+ ErrorMessage.ASSET_NOT_FOUND + ' ' +identifierValue);
            }     
        }
    }
    
   
    /**
     * This method is used to save the Technical Attribute values.
     * 
     * @param TechnicalAttributeRequest Information of Technical Attribute values that need to be updated
     * @param Common.RequestOption Whether to create Activity logs or not
     * @return TechnicalAttributeRequest
     * @see TA_TechnicalAttributeService
     * 
     * @example saveTechnicalAttributes(TechnicalAttributeRequest);
     */
    
    public TechnicalAttributeRequest saveTechnicalAttributes(final TechnicalAttributeRequest requestData, Common.RequestOption requestOption) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributes() - enter; request=' + requestData);
        
        Savepoint savePoint = Database.setSavepoint();
        
        try {
            
            // Per conversion logic
            if( requestData instanceof TechAttr.TechnicalAttributeRequest ) {
                populateAssetRecordId(requestData);
            }
            
            validateRequestParameters (requestData);
            
            //Fetch source record Ids based on record names provided in the request
            Set<String> sourceRecordIds = retrieveSourceRecordId(requestData);  
            
            //Fetch Master Technical attributes, create new if not found 
            Set<String> attributeDeveloperNames = new Set<String>();
            Map<String, List<String>> picklistAttrNameValueMap = new Map<String, List<String>>();
            
            for (TechnicalAttributeData eachAttr: requestData.attributeList) {
                
                attributeDeveloperNames.add(eachAttr.attributeKey);
            
                if(eachAttr.dataType != NULL){
                    if (eachAttr.DataType.equalsIgnoreCase('boolean')) {   //validate Boolean value input
                        if ( !(eachAttr.value.equalsIgnoreCase('true') || eachAttr.value.equalsIgnoreCase('false') )) {
                            throw new SvmxSystem.SvmxNestedException( eachAttr.value + ': '+ System.label.Error_InvalidBooleanValue + ': ' + eachAttr.attributeKey );
                        } 
                    }
                    else if( eachAttr.dataType.equalsIgnoreCase('Picklist')){
                        if(!picklistAttrNameValueMap.containsKey(eachAttr.attributeKey.toUpperCase())){
                            picklistAttrNameValueMap.put(eachAttr.attributeKey.toUpperCase(), new List<String>());
                        }
                        picklistAttrNameValueMap.get(eachAttr.attributeKey.toUpperCase()).add(eachAttr.value);
                    }
                    
                }
                
                
            }
            
            //Query existing technical Attribute records
            Map<String, SVMXA360__SM_TA_TechnicalAttribute__c> existingAttributesByNameMap = fetchMasterTechnicalAttribute (attributeDeveloperNames); 
            
            //Insert technical attributes if not available
            Map<String, String> newAttributesByNameMap = handleTechAttributeCreation (requestData , existingAttributesByNameMap, picklistAttrNameValueMap );
            
            //Update existing Picklist Definition with new values if not present
            if( !picklistAttrNameValueMap.isEmpty()){
                List<SVMXA360__CONF_PicklistDefinition__c> picklistDefUpdateList = updateExistingPicklistDefValues (picklistAttrNameValueMap, existingAttributesByNameMap);
                
                if (!picklistDefUpdateList.isEmpty()) {
                    try {
                        SvmxDatabase.updateRecord ( picklistDefUpdateList, true );
                    }catch (SvmxSystem.SvmxNestedException ex) {
                        throw new SvmxSystem.SvmxNestedException(ex.getMessage());
                    }
                }
            }
             
            // Fetch Target Records and update with new values. If not found, create new records. For example, create Asset Technical Atttributes when Source ObjectName = Asset
            
            if (String.isBlank(requestData.targetObject) && requestData.objectName.equalsIgnoreCase(ASSET_OBJ)) {
                requestData.targetObject = ASSET_TECH_ATTRIBUTE;              
            }
            
            //Fetch Fields on Target Object
            attributeFieldMap = TechAttr.getAttributeFieldsMap( requestData.objectName ); 
            
            final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
            SObjectType objectType = describeManager.getsObjectType( requestData.targetObject );
            Map<String, Schema.SObjectField> targetFieldResultMap = describeManager.getObjectFieldMap( requestData.targetObject );
            
            validateTargetObjectFieldNames ( targetFieldResultMap);
        
            //Insert new target records with values - Map < AssetId/SourceId, List<targetRecords> >
            Map<String, List<SObject>> targetRecordsBySourceIdMap = handleNewAttributes(requestData, newAttributesByNameMap, targetFieldResultMap, objectType); 
            
            //Update existing target records if already present
            targetRecordsBySourceIdMap = handleExistingAttributes(requestData, sourceRecordIds, existingAttributesByNameMap, targetFieldResultMap, objectType, targetRecordsBySourceIdMap);
            
            System.debug(LoggingLevel.ERROR, 'saveTechnicalAttribute() :Before upsert - targetRecordsBySourceIdMap = ' + targetRecordsBySourceIdMap);
            
            if ( !targetRecordsBySourceIdMap.isEmpty()) {
                
                List<SObject> targetRecordsToUpsert = new List<SObject>();
                for ( String sourceRecordId : targetRecordsBySourceIdMap.keySet() ) {
                    targetRecordsToUpsert.addAll(targetRecordsBySourceIdMap.get(sourceRecordId));
                }
                
                try {
                    SvmxDatabase.upsertRecord ( targetRecordsToUpsert, true );
                }
                catch (SvmxSystem.SvmxNestedException ex) {
                    throw new SvmxSystem.SvmxNestedException(ex.getMessage());
                }
            }
            if (requestOption.isCreateActivityLogs) {
                createStatusLogs (targetRecordsBySourceIdMap, null, requestOption.operationType);  //create status logs for successful upsertion (message = null)
            }
            
        }
        catch (SvmxSystem.SvmxServiceException e) {
            
            Database.rollback( savePoint );
            
            if (requestOption.isCreateActivityLogs) {
                createStatusLogs (null, e.getMessage(), requestOption.operationType); // TA update failed
            }            
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to save Technical attributes. Error' + e.getStackTraceString() );
            throw e;
            
        }    
        catch( Exception e ) {
            
            Database.rollback( savePoint );
            
            if (requestOption.isCreateActivityLogs) {
                createStatusLogs (null, e.getMessage(), requestOption.operationType); // TA update failed
            }            
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to save Technical attributes. Error' + e.getStackTraceString() );
            
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveTechnicalAttribute() - exit; response = ' +  requestData );
        }
        
        return requestData;
    }
    
    //Method to validate required parameters
    private void validateRequestParameters (final TechnicalAttributeRequest requestData) {
        if(requestData == null || requestData.attributeList ==null || requestData.attributeList.isEmpty()) {
            throw new SvmxSystem.SvmxNestedException( System.label.Error_InvalidRequest);
        } else if (String.isBlank(requestData.objectName)){
            throw new SvmxSystem.SvmxNestedException( 'ObjectName: ' + ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
    }
    
	/**
     * This method is used to create new Technical Attributes in the Org for the given request.
    */
    public Map<String, String> handleTechAttributeCreation (final TechnicalAttributeRequest requestData,  Map<String, SVMXA360__SM_TA_TechnicalAttribute__c> existingAttributesByNameMap,  Map<String, List<String>> picklistAttrNameValueMap ) {
        
        Map<String, String> newAttributeIdByNameMap = new Map<String, String>();
        Set<String> attributeKeySet = new set<String>(); //keeping track of unique set of Attribute Keys to insert         
        try{
            List<TechAttr.TechnicalAttribute> attributeToInsertList = new List<TechAttr.TechnicalAttribute>();
            for (TechnicalAttributeData eachAttr: requestData.attributeList) {
                String attrKey = eachAttr.attributeKey.toUpperCase();
                if(!existingAttributesByNameMap.containsKey(attrKey)){
                    
                    if (String.isBlank(eachAttr.dataType)) {
                        eachAttr.dataType = 'Text';
                    }
                    
                    if (!attributeKeySet.contains(attrKey)){
                        attributeToInsertList.add( createAttributeWrapper (eachAttr, picklistAttrNameValueMap.get(attrKey))); //create TechAttr.TechnicalAttribute wrapper
                        attributeKeySet.add(attrKey);
                    }
                    
                } 
                else if (existingAttributesByNameMap.containsKey(attrKey) ){  //existing attribute - verify datatypes are matching
                    if(existingAttributesByNameMap.get(attrKey) != NULL && !String.isBlank(eachAttr.dataType) && !existingAttributesByNameMap.get(attrKey).SVMXA360__DataType__c.equalsIgnoreCase(eachAttr.dataType)) {
                        throw new SvmxSystem.SvmxNestedException( eachAttr.dataType + ': '+ System.label.Error_AttributeDatatypeMismatch + ': ' + attrKey);
                    }
                }
            }
            
            if(!attributeToInsertList.isEmpty()) {
                List<TechAttr.TechnicalAttribute> newAttributeRecords = taManager.saveTechnicalAttributes( attributeToInsertList) ;  //inserts new TA and Picklist definitions
                
                for (TechAttr.TechnicalAttribute eachAttr: newAttributeRecords) {
                    newAttributeIdByNameMap.put(eachAttr.developerName, eachAttr.Id);
                }
            }
            
            attributeKeySet.clear();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'handleTechAttributeCreation() : Failed to create Technical Attribute Record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleTechAttributeCreation() - exit' );
        }
        
        return newAttributeIdByNameMap;
    }
    
    /**
     * This method is used to create wrapper as per TechAttr.TechnicalAttribute
     */
    
     private TechAttr.TechnicalAttribute createAttributeWrapper(  final TechnicalAttributeData attrData , List<string> picklistValues) {
        
        System.debug( LoggingLevel.FINEST, 'createAttributeWrapper() - enter; attrData= ' + attrData);
        
        TechAttr.TechnicalAttribute technicalAttribute = new TechAttr.TechnicalAttribute();
        technicalAttribute.name = attrData.attributeKey;
        technicalAttribute.developerName = attrData.attributeKey;
        technicalAttribute.dataType = !String.isBlank(attrData.DataType) ? attrData.DataType : 'Text';  //default datatype to 'Text' in case not provided in the request
        technicalAttribute.unit = attrData.unit;
        
        if (attrData.DataType.equalsIgnoreCase('Picklist')) {
            Config.PicklistDefinition picklistDef = new Config.PicklistDefinition();
            picklistDef.name = attrData.attributeKey + '_PLD';
            picklistDef.developerName = attrData.attributeKey + '_PLD';
            picklistDef.type = 'Technical Attribute';
            picklistDef.values = String.join( picklistValues, ';');
            technicalAttribute.picklistDefinition = picklistDef;
        }
        
        return technicalAttribute;
    }
    
    
    /**
     * This method is used to retrieve Parent record Id and name when either record Id or name is provided
     */
    public Set<String> retrieveSourceRecordId( final TechnicalAttributeRequest requestData ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecordId() - enter; requestData= ' + requestData );
        Set<String> sourceRecordIds = new Set<String>();
        
        try {
            
            Set<String> srcRecordNames = new Set<String>();
            Set<Id> srcRecordIds = new Set<Id>();
            
            for (TechnicalAttributeData eachRec: requestData.attributeList) {
                
                if ( String.isBlank(eachRec.recordId) && String.isBlank(eachRec.recordName)  ) {
                    System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : recordId/recordName missing in the request' );
                    throw new SvmxSystem.SvmxNestedException( 'RecordId/recordName: '+ ErrorMessage.MISSING_REQUIRED_PARAMETER);
                } else if (String.isBlank(eachRec.recordId) && !String.isBlank(eachRec.recordName)) {
                    srcRecordNames.add(eachRec.recordName);
                } else if (!String.isBlank(eachRec.recordId)) {
                    srcRecordIds.add(eachRec.recordId);
                }
                
            }
            
            Map<string,String> recordIdByNameMap = new Map<String, String>();
            
            if (!srcRecordNames.isEmpty() || !srcRecordIds.isEmpty()) {
                
                List<SObject> sourceRecords = SvmxDatabase.query(Database.query('Select Id, Name from ' + String.escapeSingleQuotes(requestData.objectName) + ' Where ID IN: srcRecordIds OR Name IN: srcRecordNames')) ;
                
                if (sourceRecords == NULL || sourceRecords.isEmpty()) {
                    String errorMessage = 'RecordId/recordName: '+ Label.Error_RecordNotExists;
                    errorMessage += !String.isblank(requestData.attributeList[0].recordId) ? requestData.attributeList[0].recordId:requestData.attributeList[0].recordname;
                    throw new SvmxSystem.SvmxNestedException(errorMessage);
                } else {
                    for (SObject eachSobj: sourceRecords) {
                        sourceRecordIds.add(String.valueOf(eachSobj.get('Id')));
                        if (recordIdByNameMap.containsKey(String.valueOf(eachSobj.get('Name')))) {
                            continue;
                        }
                        recordIdByNameMap.put(String.valueOf(eachSobj.get('name')), String.valueOf(eachSobj.get('Id')));
                    }
                }
            } 
            
            Set<String> assetIdAttributeKey = new Set<String>();
            String uniqueKey;
            for (TechnicalAttributeData eachRec: requestData.attributeList) {
                
                if (String.isBlank(eachRec.recordId) && !String.isBlank(eachRec.recordName)) {
                    if (recordIdByNameMap.containsKey(eachRec.recordName)) {
                        eachRec.recordId = recordIdByNameMap.get(eachRec.recordName);
                    } else {
                        throw new SvmxSystem.SvmxNestedException( 'recordName: '+ system.label.Error_RecordNotExists + ' - ' + eachRec.recordName);
                    }
                }
                if(!recordIdByNameMap.values().contains(eachRec.recordId)){
                    System.debug( LoggingLevel.ERROR, 'retrieveSourceRecordId() : Record not does exists with record Id = '+eachRec.recordId );
                    throw new SvmxSystem.SvmxNestedException( 'recordId: '+ system.label.Error_RecordNotExists + ' - ' + eachRec.recordId);
                }
                
                if( String.isBlank(eachRec.attributeKey )) {
                    System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : AttributeKey missing in the request' );
                    throw new SvmxSystem.SvmxNestedException( 'AttributeKey: '+ System.label.Error_RequestMissingParameter + ': ' + eachRec.recordId );
                }
                else if (eachRec.attributeKey.length() > 80) {
                    throw new SvmxSystem.SvmxNestedException( System.label.Error_AttributeKeyTooLong + ': ' + eachRec.attributeKey );
                }
                else if (eachRec.value == null) {
                    throw new SvmxSystem.SvmxNestedException( 'Value: '+ System.label.Error_RequestMissingParameter + ': ' + eachRec.recordId );
                }
                
                //duplicate check - combination of Record Id and Attribute Key should be unique per request
                uniqueKey = eachRec.recordId +  eachRec.attributeKey.toUpperCase() ;
                if (assetIdAttributeKey.contains(uniqueKey)) {
                    System.debug( LoggingLevel.ERROR, 'retrieveSourceRecordId() : Invalid request parameters. Duplicate values for Attribute Key = ' + eachRec.attributeKey );
                    throw new SvmxSystem.SvmxNestedException( Label.Error_MultipleAttributeValue +  ' : ' +  eachRec.attributeKey  );
                } else {
                    assetIdAttributeKey.add (uniqueKey);
                }
            
            }
          
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecordId() : Failed to retrieve Source record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecordId() - exit' );
        }
        return sourceRecordIds;
    }
    
    /**
     * This method is used to retrieve Technical Attribute records based on developer names
     * 
     * @param Set<String> Attributes developer names for which Tech attributes need to be retrieved
     */
    
    public Map<String, SVMXA360__SM_TA_TechnicalAttribute__c> fetchMasterTechnicalAttribute (final Set<String> attributesNames ) {
        
        System.debug( LoggingLevel.DEBUG, 'fetchMasterTechnicalAttribute() - enter; attributesNames= ' + attributesNames );
        
        Map<String, SVMXA360__SM_TA_TechnicalAttribute__c> existingAttributesByNameMap = new Map<String, SVMXA360__SM_TA_TechnicalAttribute__c>();
        
        try{
            
            for(SVMXA360__SM_TA_TechnicalAttribute__c existingAttr: (List<SVMXA360__SM_TA_TechnicalAttribute__c>)SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DataType__c, SVMXA360__DeveloperName__c, SVMXA360__DefaultValue__c, SVMXA360__Unit__c, SVMXA360__PicklistDefinitionId__c FROM SVMXA360__SM_TA_TechnicalAttribute__c WHERE SVMXA360__DeveloperName__c IN: attributesNames] )){
                existingAttributesByNameMap.put(existingAttr.SVMXA360__DeveloperName__c.toupperCase(), existingAttr);
            }
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchMasterTechnicalAttribute() : Failed to retrieve parent record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchMasterTechnicalAttribute() - exit' + existingAttributesByNameMap);
        }
        
        return existingAttributesByNameMap;
    }
    
    /**
     * This method is used to update existing Picklist definitions with new values from the request
     */
    
    public List<SVMXA360__CONF_PicklistDefinition__c> updateExistingPicklistDefValues ( Map<String, List<String>> picklistAttrNameValueMap,  Map<String, SVMXA360__SM_TA_TechnicalAttribute__c> existingAttributesByNameMap) {
        
        System.debug( LoggingLevel.DEBUG, 'updateExistingPicklistDefValues() - enter; picklistAttrNameValueMap= ' + picklistAttrNameValueMap );
        
        List<SVMXA360__CONF_PicklistDefinition__c> picklistDefUpdateList = new List<SVMXA360__CONF_PicklistDefinition__c>();
        
        try{
            
            Map<String, String> picklistIdAndAttributeNameMap = new Map<String, String>();
            Map<String, String> attributeValueByIdMap = new Map<String, String>();
            
            for (SVMXA360__SM_TA_TechnicalAttribute__c eachAttr: existingAttributesByNameMap.values()) {
                if (eachAttr.SVMXA360__PicklistDefinitionId__c != NULL) {
                    picklistIdAndAttributeNameMap.put(eachAttr.SVMXA360__PicklistDefinitionId__c ,eachAttr.SVMXA360__DeveloperName__c.toUpperCase());
                }
            }
            
            List<SVMXA360__CONF_PicklistDefinition__c> picklistRecords = taManager.getPicklistDefinitionRecords (new List<String>(picklistIdAndAttributeNameMap.keySet())) ;
            
            boolean toBeUpdated = false;
            for (SVMXA360__CONF_PicklistDefinition__c eachDef: picklistRecords) {
                List<String> picklistValues = eachDef.SVMXA360__Values__c.split(';');
                List<String> newValues = picklistAttrNameValueMap.get( picklistIdAndAttributeNameMap.get(eachDef.Id) );
                
                System.debug(LoggingLevel.debug, 'picklistValues = '+ picklistValues + ' --- newValues = '+newValues);
                for (String eachValue: newValues) {
                    if(!String.isBlank(eachValue) && !picklistValues.contains(eachValue)) {
                        eachDef.SVMXA360__Values__c += ';'+ eachValue;
                        toBeUpdated = true;
                    }
                }
                if (toBeUpdated) {
                    picklistDefUpdateList.add(eachDef);
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateExistingPicklistDefValues() : Failed to retrieve picklist definition record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateExistingPicklistDefValues() - exit' );
        }
        
        return picklistDefUpdateList;
    }
    
    /**
     * This method is to insert new Target Records for all the new Technical Attributes created with new attribute values provided in the request 
     */
    public Map<String, List<SObject>>  handleNewAttributes (final TechnicalAttributeRequest requestData, Map<String, String> newAttributesByNameMap, Map<String, Schema.SObjectField> targetFieldResultMap, SObjectType objectType ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleNewAttributes() - enter; request=' + requestData);
        
        Map<String, List<SObject>> targetRecordsBySourceIdMap = new Map<String, List<SObject>>();
        
        try{
            
            for (TechnicalAttributeData eachAttr: requestData.attributeList) {
                
                if (newAttributesByNameMap.containsKey(eachAttr.attributeKey)) {
                    
                    if (!targetRecordsBySourceIdMap.containsKey(eachAttr.recordId)) {
                        targetRecordsBySourceIdMap.put (eachAttr.recordId, new List<SObject>()) ;
                    }
                    targetRecordsBySourceIdMap.get(eachAttr.recordId).add(mapNewTargetRecordFields ( eachAttr,  newAttributesByNameMap.get(eachAttr.attributeKey), requestData.source, targetFieldResultMap, objectType));
                    
                }
            }            
            
        }catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'handleNewAttributes() : Failed to create target records. Error = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleNewAttributes() - exit' );
        }
        
        return targetRecordsBySourceIdMap;
    }
    
    /**
     * This method is to create a new instance of Target object and map fields on Target Records with new attribute values provided in the request 
     */
    public SObject mapNewTargetRecordFields (TechnicalAttributeData attrData, String techAttributeId, String requestSource, Map<String, Schema.SObjectField> targetFieldResultMap, SObjectType objectType) {
        
        System.debug( LoggingLevel.DEBUG, 'mapNewTargetRecordFields() - enter; attrData=' + attrData);
        
        SObject targetRecord = objectType.newSObject();
       try {
            
                DateTime currentDateTime = Datetime.now();
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.sourceRecord), attrData.recordId );   //Asset Id/Source Record Id
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Attribute), techAttributeId); //Lookup to Tech Attribute 
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Source), !String.isBlank(requestSource) ? requestSource : API_SOURCE );
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.CapturedBy), UserInfo.getUserId() );
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.CapturedOn), currentDateTime );

                if ( attrData.timeOfOccurence != null && String.isNotBlank(attrData.timeOfOccurence) && 
                     String.isNotEmpty(attrData.timeOfOccurence)) {
                     targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.TimeofOccurence), Datetime.valueOf(attrData.timeOfOccurence) );
                } else {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.TimeofOccurence), currentDateTime );
                }

                if( attrData instanceof TechAttr.TechnicalAttributeData ) {
                    populateLastOccurrenceValues(attrData,targetRecord);
                } 
                
            
            switch on attrData.dataType.toLowerCase() {
    
                when 'number' {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Decimal.valueOf(attrData.value)) );
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.NumberValue), Decimal.valueOf(attrData.value) );
                }
                when 'boolean' {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Boolean.valueOf(attrData.value)) );
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.BooleanValue), Boolean.valueOf(attrData.value) );
                }
                when 'date' {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Date.valueOf(attrData.value)) );
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.DateValue), Date.valueOf(attrData.value) );
                }
                when 'datetime' {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Datetime.valueOf(attrData.value)) );
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.DatetimeValue), Datetime.valueOf(attrData.value) );
                }
                when else {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(attrData.value) );
                }
            }
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'mapNewTargetRecordFields() : Failed to map target records. Error = ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'mapNewTargetRecordFields() : Failed to map target records. Error = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'mapNewTargetRecordFields() - exit' );
        }
        
        return targetRecord;
   
    }

    private void populateLastOccurrenceValues ( TechnicalAttributeData attrData, SObject targetRecord ) {
        
        TechAttr.TechnicalAttributeData technicalAttributeData = (TechAttr.TechnicalAttributeData) attrData;

        if ( technicalAttributeData.lastOccurrenceTimeList != null ) {
            List<TechAttr.LastOccurrenceTimeValue> lastoccurrenceValues = new List<TechAttr.LastOccurrenceTimeValue>();
            TechAttr.LastOccurrenceTimeValue lastOccurrenceTimeValue;

            for ( TechAttr.LastOccurrenceTime lastOccurrenceTime: technicalAttributeData.lastOccurrenceTimeList ) {
                lastOccurrenceTimeValue = new TechAttr.LastOccurrenceTimeValue();
                lastOccurrenceTimeValue.timeOfOccurence = Datetime.valueOf(lastOccurrenceTime.timeOfOccurence);
                lastOccurrenceTimeValue.value = String.valueOf(lastOccurrenceTime.value);
                lastoccurrenceValues.add(lastOccurrenceTimeValue);
            }
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.LastOccurence), String.valueOf(lastoccurrenceValues) );
        }
    }
    
   /**
     * This method is to update Target Records with new attribute values provided in the request 
     */
    public Map<String, List<SObject>> handleExistingAttributes (final TechnicalAttributeRequest requestData, Set<String> sourceRecordIds, Map<String, SVMXA360__SM_TA_TechnicalAttribute__c> existingAttributesByNameMap , Map<String, Schema.SObjectField> targetFieldResultMap, SObjectType objectType, Map<String, List<SObject>> targetRecordsBySourceIdMap) {
       
        System.debug( LoggingLevel.DEBUG, 'handleExistingAttributes() - enter' );
        
        try{
            
            if (!existingAttributesByNameMap.isEmpty()) {
                Map<Id, String> existingAttributeIdNameMap = new Map<Id, String>();
                for(SVMXA360__SM_TA_TechnicalAttribute__c existingAttr: existingAttributesByNameMap.values() ){
                    existingAttributeIdNameMap.put(existingAttr.Id, existingAttr.SVMXA360__DeveloperName__c.toUpperCase());
                }
                
                Map<String, Map<String, SObject>> targetRecBySourceIdMap = fetchExistingAttributeValues( requestData.targetObject, attributeFieldMap.values(), sourceRecordIds , existingAttributeIdNameMap);
                
                for (TechnicalAttributeData eachAttr: requestData.attributeList) {
                    
                    if (!targetRecordsBySourceIdMap.containsKey(eachAttr.recordId)) {
                        targetRecordsBySourceIdMap.put(eachAttr.recordId, new List<SObject>());
                    }
                    
                   if (existingAttributesByNameMap.containsKey (eachAttr.attributeKey.toUpperCase())) {   //attribute exists
                        
                        eachAttr.dataType = existingAttributesByNameMap.get(eachAttr.attributeKey.toUpperCase()).SVMXA360__DataType__c;
                        
                        if (targetRecBySourceIdMap.get(eachAttr.recordId) != NULL && targetRecBySourceIdMap.get(eachAttr.recordId).get(eachAttr.attributeKey.toUpperCase()) != NULL) { //target Record exists
                            targetRecordsBySourceIdMap.get(eachAttr.recordId).add(mapExistingTargetRecordFields ( targetRecBySourceIdMap.get(eachAttr.recordId).get(eachAttr.attributeKey.toUpperCase()), eachAttr, requestData.source, targetFieldResultMap) );
                        } else {
                            //create new target record with values for existing attribute Id
                            targetRecordsBySourceIdMap.get(eachAttr.recordId).add( mapNewTargetRecordFields ( eachAttr, existingAttributesByNameMap.get(eachAttr.attributeKey.toUpperCase()).Id, requestData.source, targetFieldResultMap, objectType) ); 
                        }
                    }
                }
            }
            
        }catch( Exception e ) {
                
            System.debug( LoggingLevel.ERROR, 'handleExistingAttributes() : Failed to create target records. Error = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleExistingAttributes() - exit' );
        }
            
       return targetRecordsBySourceIdMap;
    
    }
    
    /**
     * This method is to update an existing target record instance and map fields with new attribute values provided in the request 
     */
    public SObject mapExistingTargetRecordFields (SObject targetRecord, TechnicalAttributeData attrData, string requestSource,  Map<String, Schema.SObjectField> targetFieldResultMap) {
        
        System.debug( LoggingLevel.DEBUG, 'mapExistingTargetRecordFields() - enter; attrData=' + attrData);
        
        try{
            
            //Previous value and value update
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousValue), targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.Value)));  //current value of Target record becomes previous value
            
             
            //Source update
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Source), API_SOURCE );
            
            //Previous CapturedBy and CapturedBy update
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousCapturedBy), targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.CapturedBy)));
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.CapturedBy), UserInfo.getUserId() );
            
            
            //Previous CapturedOn and CapturedOn update
            DateTime currentDateTime = Datetime.now();
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousCapturedOn), targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.CapturedOn)));
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.CapturedOn), currentDateTime );
           
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Source), !String.isBlank(requestSource) ? requestSource : API_SOURCE );

            if ( attrData.timeOfOccurence != null && String.isNotBlank(attrData.timeOfOccurence) && 
                 String.isNotEmpty(attrData.timeOfOccurence)) {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.TimeofOccurence), Datetime.valueOf(attrData.timeOfOccurence) );
            } else {
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.TimeofOccurence), currentDateTime );
            }

            if( attrData instanceof TechAttr.TechnicalAttributeData ) {
                populateLastOccurrenceValues(attrData,targetRecord);
            }
            
            switch on attrData.dataType.toLowerCase() {
        
                when 'number' {
                    
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Decimal.valueOf(attrData.value)) );   //Current value update
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousNumberValue) , targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.NumberValue)));
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.NumberValue), Decimal.valueOf(attrData.value) );
                    
                }
                when 'boolean' {
                    
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Boolean.valueOf(attrData.value)) );   
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousBooleanValue) , targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.BooleanValue)));
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.BooleanValue), Boolean.valueOf(attrData.value) );
                   
                }
                when 'date' {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Date.valueOf(attrData.value)) );   
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousDateValue) , targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.DateValue)));
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.DateValue), Date.valueOf(attrData.value) );
                   
                }
                when 'datetime' {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(Datetime.valueOf(attrData.value)) );   
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousDatetimeValue) , targetRecord.get(attributeFieldMap.get(TechAttr.AttributeField.DatetimeValue)));
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.DatetimeValue), Datetime.valueOf(attrData.value) );
                    
                }
                when else {
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), String.valueOf(attrData.value) );  
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'mapExistingTargetRecordFields() : Failed to map target records. Error =' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'mapExistingTargetRecordFields() : Failed to map target records. Error = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'mapExistingTargetRecordFields() - exit' );
        }
        
        return targetRecord;
    }
    
    /**
     * This method is to retrieve Target object records based on the related master attribute Ids and source ID provided in the request 
     * For example: Asset Technical Attribute records will be fetched based on 
     *  1. Asset Id provided in the request  
     *  2. Master Attribute ID fetched previously based on the attribute developer name provided in the request
     */
    
    public Map<String, Map<String, SObject>> fetchExistingAttributeValues ( String targetObjectName, List<String> fieldNames, Set<String> sourceRecordIds, Map<Id, String> existingAttributeIdNameMap) {
        
        System.debug( LoggingLevel.DEBUG, 'fetchExistingAttributeValues() - Enter : sourceRecordIds = ' + sourceRecordIds);
        
        Map<String, Map<String, SObject>> targetRecBySourceIdMap = new Map<String, Map<String, SObject>>(); // Map< AssetId, Map<Attribute Developer Name, Target Record>>
        
        try {
            
            System.debug( LoggingLevel.deBUG, 'sourceRecordIds = ' + sourceRecordIds );
            Set<Id> existingAttributeIds = existingAttributeIdNameMap.keySet();
            System.debug( LoggingLevel.DEBUG, 'existingAttributeIds = ' + existingAttributeIds);
            
            String queryStr = 'SELECT Id,' + String.join( fieldNames, ',') + ' FROM ' + String.escapeSingleQuotes(targetObjectName);
            queryStr += ' WHERE ' + attributeFieldMap.get(TechAttr.AttributeField.sourceRecord) + ' IN: sourceRecordIds AND ' + attributeFieldMap.get(TechAttr.AttributeField.Attribute) + ' IN: existingAttributeIds'; 
            
            System.debug(LoggingLevel.DEBUG, 'Query to fetch attribute values = '+ queryStr);
            
            for (SObject targetRec: SvmxDatabase.query(Database.query( queryStr))) {
                
                String sourceRecId = String.valueOf(targetRec.get(attributeFieldMap.get(TechAttr.AttributeField.sourceRecord)));
                String attributeRecId = String.valueOf(targetRec.get(attributeFieldMap.get(TechAttr.AttributeField.Attribute)));
                
                if ( !String.isBlank(sourceRecId) &&  !String.isBlank(attributeRecId) && existingAttributeIdNameMap.get(attributeRecId) != NULL) {
                    if(!targetRecBySourceIdMap.containsKey( sourceRecId)){
                        targetRecBySourceIdMap.put( sourceRecId, new Map<String, SObject>());
                    }
                    if (!targetRecBySourceIdMap.get(sourceRecId).containsKey(existingAttributeIdNameMap.get(attributeRecId).toUpperCase())) {
                        targetRecBySourceIdMap.get(sourceRecId).put(existingAttributeIdNameMap.get(attributeRecId).toUpperCase(), targetRec);
                    }
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchExistingAttributeValues() : Failed to fetch target records. Error = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchExistingAttributeValues() - exit' +  targetRecBySourceIdMap);
        }
        
        return targetRecBySourceIdMap;
    }
    
    public void validateTargetObjectFieldNames (Map<String, Schema.SObjectField> targetFieldResultMap) { 
        
        System.debug( LoggingLevel.deBUG, 'validateTargetObjectFieldNames() - Enter : targetFieldResultMap = ' + targetFieldResultMap );
        try {
            for (String fieldApiName: attributeFieldMap.values() ) {
                if (!targetFieldResultMap.containsKey (fieldApiName)) {
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS + fieldApiName);
                }
            }
        }catch (SvmxSystem.SvmxNestedException ex) {
            throw ex;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTargetObjectFieldNames() : Field does not exist on Target object = ' + e.getMessage() );
            throw e;
        }
        
    }
    
    /**
     * Method to publish Application event logs that in turn create TA Activity Logs
    */
    
    private void createStatusLogs (Map<String, List<SObject>> targetRecordsBySourceIdMap, string message, String operationType) {
        
        System.debug( LoggingLevel.DEBUG, 'createStatusLogs() - Enter : message = ' + message );
        System.debug( LoggingLevel.DEBUG, 'createStatusLogs() - Enter : targetRecordsBySourceIdMap = ' + targetRecordsBySourceIdMap );
        
        List<SvmxLogger.ApplicationEventLog> eventLogList = new List<SvmxLogger.ApplicationEventLog>();
        
        try {
        
            SvmxLogger.ApplicationEventLog eventLog;
        
            if (!String.isBlank(message)) {  //upsertion failed, update logs with error message
                
                eventLog = new SvmxLogger.ApplicationEventLog();
                eventLog.applicationName = SvmxLogger.Application.TechnicalAttribute.name();
                eventLog.logLevel = SvmxLogger.Level.Error.name();
                eventLog.message = message;
                eventLog.operationType = operationType;
                eventLog.userId = UserInfo.getUserId();
                eventLogList.add(eventLog);
                
            }
            else if (targetRecordsBySourceIdMap != NULL ) {   //success scenario
                
                for (String sourceId: targetRecordsBySourceIdMap.keySet()) {
                    
                    eventLog = new SvmxLogger.ApplicationEventLog();
                    eventLog.applicationName = SvmxLogger.Application.TechnicalAttribute.name();
                    eventLog.logLevel = SvmxLogger.Level.Info.name();
                    eventLog.message = targetRecordsBySourceIdMap.get(sourceId).size() + ' ' + Label.Message_AttributeValueSaved;
                    eventLog.sourceRecordId = sourceId;
                    eventLog.operationType = operationType;
                    eventLog.userId = UserInfo.getUserId();
                    eventLogList.add(eventLog);
                
                }
            }
        
            if (!eventLogList.isEmpty()) {
                logger.publish(eventLogList);  //publish Application event Logs
            }
        }
        catch (SvmxSystem.SvmxNestedException ex) {
            throw ex;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createStatusLogs() : Failed to publish Application Log event = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createStatusLogs() - Exit ');
        }
        
    }
    
    
}