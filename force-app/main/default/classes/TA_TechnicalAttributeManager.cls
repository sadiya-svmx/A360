/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/save/delete Technical Attribute information  
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID         Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Karthick Saravanan       16 June 2022      Created.
 A360AM-2521 Sandeep Dhariwal         25 Aug  2023      Time of Occurrence changes.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class TA_TechnicalAttributeManager {
    
    // List of fields to be queried from TechnicalAttribute object.
    private final static List<String> TechnicalAttributeFields = new List<String>{
        'Id', 
        'Name',
        'LastModifiedDate',
        'LastModifiedBy.Name',
        'SVMXA360__DataType__c',
        'SVMXA360__DeveloperName__c',
        'SVMXA360__DefaultValue__c',
        'SVMXA360__Unit__c',        
        'SVMXA360__MaximumValue__c',
        'SVMXA360__MinimumValue__c',
        'SVMXA360__IsReadonly__c',
        'SVMXA360__IsRequired__c',
        'SVMXA360__Message__c',
        'SVMXA360__Description__c',
        'SVMXA360__HelpText__c',
        'SVMXA360__PicklistDefinitionId__c'
    };

    // List of fields to be queried from TechnicalAttribute Template Association object.
    private final static Set<String> TemplateAssociationFields = new Set<String>{
        'Id', 
        'Name',
        'LastModifiedDate',
        'LastModifiedBy.Name',
        'CreatedDate',
        'CreatedById',
        'CreatedBy.Name'
    };

    // List of fields to be searched from TechnicalAttribute object.
    private final static List<String> searchConditions = new List<String>{
        'Name',
        'SVMXA360__DeveloperName__c',
        'SVMXA360__Unit__c'
    };

    // List of fields to be queried from TechnicalAttribute Template Item object.
    private final static List<String> TemplateItemFields = new List<String>{
        'Id', 
        'SVMXA360__AttributeId__c',
        'SVMXA360__AttributeId__r.Name',
        'SVMXA360__AttributeId__r.SVMXA360__DataType__c',
        'SVMXA360__CategoryId__c',
        'SVMXA360__DefaultValue__c',
        'SVMXA360__DeveloperName__c',
        'SVMXA360__HelpText__c',
        'SVMXA360__IsReadonly__c',        
        'SVMXA360__IsRequired__c',
        'SVMXA360__MaximumValue__c',
        'SVMXA360__Message__c',
        'SVMXA360__MinimumValue__c',
        'SVMXA360__Status__c',
        'SVMXA360__TemplateId__c',
        'SVMXA360__Sequence__c',
        'Name'
    };
    
    private final static List<String> attributeFieldsFromTemplateItem = new List<String>{
        'SVMXA360__AttributeId__r.SVMXA360__DeveloperName__c', 
        'SVMXA360__AttributeId__r.SVMXA360__DefaultValue__c',
        'SVMXA360__AttributeId__r.SVMXA360__Unit__c',
        'SVMXA360__AttributeId__r.SVMXA360__MaximumValue__c',
        'SVMXA360__AttributeId__r.SVMXA360__MinimumValue__c',
        'SVMXA360__AttributeId__r.SVMXA360__IsReadonly__c',
        'SVMXA360__AttributeId__r.SVMXA360__IsRequired__c',        
        'SVMXA360__AttributeId__r.SVMXA360__Message__c',
        'SVMXA360__AttributeId__r.SVMXA360__HelpText__c',
        'SVMXA360__AttributeId__r.SVMXA360__Description__c',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__c',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.Name',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__DefaultValue__c',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Description__c',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__DeveloperName__c',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Type__c',
        'SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Values__c'
    };

    // List of fields to be queried from Asset TechnicalAttribute History object.
    private final static List<String> attributeHistoryFields = new List<String>{
        'Id', 
        'ParentId',
        'Field',
        'DataType',
        'IsDeleted',
        'OldValue',
        'NewValue',
        'CreatedBy.Name',
        'Parent.SVMXA360__TemplateItemId__c',
        'Parent.SVMXA360__TemplateItemId__r.SVMXA360__DefaultValue__c',
        'CreatedById',
        'CreatedDate',
        'Parent.SVMXA360__AttributeId__c',
        'Parent.SVMXA360__Value__c'
    };

    // List of fields to be queried from attribute object like Asset Technical Attribute . Mahima
    private final static List<String> attributeFields = new List<String>{
        'Id', 
        'SVMXA360__TemplateItemId__c',
        'SVMXA360__TemplateItemId__r.SVMXA360__DefaultValue__c', 
        'SVMXA360__TemplateItemId__r.SVMXA360__MinimumValue__c', 
        'SVMXA360__TemplateItemId__r.SVMXA360__MaximumValue__c', 
        'SVMXA360__AttributeId__r.name', 
        'SVMXA360__AttributeId__r.SVMXA360__Unit__c', 
        'SVMXA360__AttributeId__r.SVMXA360__DataType__c',
        'SVMXA360__AttributeId__r.SVMXA360__MaximumValue__c',
        'SVMXA360__AttributeId__r.SVMXA360__MinimumValue__c'
    };

    //Holds Attribute field Name mapping 
    private Map<TechAttr.AttributeField, String> attributeFieldMap = new Map<TechAttr.AttributeField, String>();

    //Varible to store Asset object name
    private final String ASSET_OBJ = 'Asset';

     //Varible to store Asset field on asset attribute object 
     private final String ASSET_FIELD = 'SVMXA360__AssetId__c';
    
    //Variable to store object name for Asset Technical attribute
    private final String ASSET_TECH_ATTRIBUTE = 'SVMXA360__SM_TA_AssetTechnicalAttribute__c';

    //variable to store history
    private final String HISTORY_OBJ = '__History';

    //Variable to store Default source
    private final String DEFAULT_SOURCE = 'Web';

    public static Boolean skipTriggerExecution = false;
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static TA_TechnicalAttributeManager instance;
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static TA_TechnicalAttributeManager getInstance() {
        
        if( instance == null ) {
            instance = new TA_TechnicalAttributeManager();
        }
        
        return instance;
    }

    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private TA_TechnicalAttributeManager() {
    }

    /**
    * This method is used to clone the Technical Attributes for the requested category within a template.
    */
    public TechAttr.TechnicalAttributeCategory cloneTechnicalAttributes(TechAttr.TechnicalAttributeCategory technicalAttributeCategory) {
        
        System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributes() - enter - technicalAttributeCategory='+technicalAttributeCategory );

        try {

            if( technicalAttributeCategory == null ) {                
                System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributes() : Invalid arguments.');
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<String> attributeIds = new List<String>();

            for ( TechAttr.TechnicalAttributeTemplateItem templateItem : technicalAttributeCategory.technicalAttributeTemplateItems ) {
                attributeIds.add( templateItem.attributeId );
            }

            TA_TechnicalAttributeHelper.cloneTechnicalAttributeRecords( attributeIds, technicalAttributeCategory);

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributes() : Failed to clone technicalAttributes. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributes() : Failed to clone technicalAttributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributes() - exit; technicalAttributeCategory = ' + technicalAttributeCategory );
        }

        return technicalAttributeCategory;
    }
    /**
    * This method is used to retrieve all the Technical Attributes configured.
    */
    public TechAttr.TechnicalAttributes getAllTechnicalAttributes(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttributeManager-getAllTechnicalAttributes() - enter - inputData='+inputData );

        TechAttr.TechnicalAttributes technicalAttributes = new TechAttr.TechnicalAttributes();
        
        try {
            if( inputData == null ) {                
                System.debug( LoggingLevel.ERROR, 'getAllTechnicalAttributes() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            String recQueryStr;
            String countQueryStr;
            String whereClause='';

            recQueryStr = 'SELECT ' + String.join( TechnicalAttributeFields, ',') + ' FROM SVMXA360__SM_TA_TechnicalAttribute__c';
            countQueryStr ='SELECT count() FROM SVMXA360__SM_TA_TechnicalAttribute__c';
            
            if(String.isNotBlank(inputData.searchTerm) ){
                String searchKey =  '%'+String.escapeSingleQuotes(inputData.searchTerm)+'%';
                whereClause+= ' WHERE ( ';                
                for (Integer index=0;index< searchConditions.size();index++){                        
                    whereClause+= searchConditions[index]+' Like \''+searchKey+'\'';                   
                    if(index != searchConditions.size()-1){
                        whereClause+=' OR ';
                    }
                }
                whereClause+= ' )';         
            }
            recQueryStr +=whereClause;
            countQueryStr +=whereClause;

            //Added with security enforced to perform FLS check on count query
            if(!Test.isRunningTest()){
                countQueryStr+=' WITH SECURITY_ENFORCED';
            }

            if(String.isNotBlank(inputData.sortField) && String.isNotBlank(inputData.sortOrder)){
                //ORDER BY clause
                recQueryStr +=' ORDER BY '+ String.escapeSingleQuotes(inputData.sortField)+' '+String.escapeSingleQuotes(inputData.sortOrder);
            }       
            //LIMIT and OFFSET clause
            recQueryStr += (inputData.limitCount!=null) ? ' LIMIT '+ inputData.limitCount:'';
            recQueryStr += (inputData.queryOffset!=null) ? ' OFFSET '+ inputData.queryOffset:'';     


            System.debug(LoggingLevel.INFO, 'getAllTechnicalAttributes() :query for Total Count is :'+countQueryStr);
            System.debug(LoggingLevel.INFO, 'getAllTechnicalAttributes() :query for RecordList is :'+recQueryStr);

            //Get the total count of Attribute.
            Integer recordCount = database.countQuery(countQueryStr);

            List<TechAttr.TechnicalAttribute> attributeList = new List<TechAttr.TechnicalAttribute>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            for (SVMXA360__SM_TA_TechnicalAttribute__c objTA :  (List<SVMXA360__SM_TA_TechnicalAttribute__c>) SvmxDatabase.query(recQueryStr)) {  
                attributeList.add(TA_TechnicalAttributeHelper.createTechnicalAttribute(objTA));
            }

            technicalAttributes.totalRecordCount = recordCount;
            technicalAttributes.technicalAttributeList = attributeList;

            System.debug(LoggingLevel.INFO, 'getTechnicalAttributes() :query for recordCount is :'+recordCount);
            System.debug(LoggingLevel.INFO, 'getTechnicalAttributes() :attributeList size :'+attributeList.size());
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributes() : Failed to retrieve technicalAttributes. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributes() : Failed to retrieve technicalAttributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributes() - exit; technicalAttributes.size()= ' + technicalAttributes.totalRecordCount );
        }
        
        return technicalAttributes;
    }

    /**
    * This method is used to retrieve all the TemplateAssociations configured for the template.
    */
    public List<SVMXA360__SM_TA_TemplateAssociation__c> getAllTemplateAssociations(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttributeManager-getAllTemplateAssociations() - enter - inputData='+inputData );

        List<SVMXA360__SM_TA_TemplateAssociation__c> templateAssociationList = new List<SVMXA360__SM_TA_TemplateAssociation__c>();
        
        try {
            if( inputData == null || string.isBlank(inputData.parentId) ) {                
                System.debug( LoggingLevel.ERROR, 'getAllTemplateAssociations() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            //Retrieve all custom fields from Template Association Object - SVMXA360__SM_TA_TemplateAssociation__c
            Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions( 'SVMXA360__SM_TA_TemplateAssociation__c' , true );
            
            for( Common.FieldDefinition fieldDefinition : entityDefinition.fieldDefinitions ) {

                if (fieldDefinition.apiName.endsWith('__c')) {
                    TemplateAssociationFields.add(fieldDefinition.apiName);
                }
                if (fieldDefinition.apiName.endsWith('__c') && fieldDefinition.dataType == 'REFERENCE') {
                    String refFieldName = getReference(fieldDefinition.apiName, '.Name');
                    TemplateAssociationFields.add(refFieldName);
                }
            }
            System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttributeManager-getAllTemplateAssociations() - TemplateAssociationFields='+TemplateAssociationFields );
            
            Id parentRecordId = (Id) inputData.parentId;

            String recQueryStr;
            
            recQueryStr = 'SELECT ' + String.join(new List<String>(TemplateAssociationFields), ',') + ' FROM SVMXA360__SM_TA_TemplateAssociation__c';
            //where clause for parent object - Template Id
            recQueryStr +=' WHERE SVMXA360__TemplateId__c =\''+parentRecordId+'\'';
            //Default DESC ORDER - Name
            recQueryStr +=' ORDER BY Name DESC';
            System.debug(LoggingLevel.INFO, 'getAllTemplateAssociations() :query for recQueryStr is :'+recQueryStr);
            /* sfge-disable-next-line ApexFlsViolationRule */
            templateAssociationList = SvmxDatabase.query(recQueryStr);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTemplateAssociations() : Failed to retrieve templateAssociationList. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllTemplateAssociations() : Failed to retrieve templateAssociationList. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTemplateAssociations() - exit; templateAssociationList.size()= ' + templateAssociationList.size());
        }
        
        return templateAssociationList;
    }

    /**
     * This method is used to retrieve details of the Technical Attribute for requested id.
     */
    public TechAttr.TechnicalAttribute getTechnicalAttributeWithDetails( final String attributeId ) {

        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeWithDetails() - enter; attributeId= ' + attributeId);

        TechAttr.TechnicalAttribute technicalAttribute = new TechAttr.TechnicalAttribute();

        try {

            if( String.isBlank(attributeId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' attributeId= ' + attributeId );
            }

            // Retrieve details of the Technical Attribute for requested id.
            List<TechAttr.TechnicalAttribute > technicalAttributeList = createTechnicalAttributes( TA_TechnicalAttributeHelper.getAllTechnicalAttributeRecords(attributeId) );
            if( technicalAttributeList!= null && technicalAttributeList.size() > 0 ) {
                
                technicalAttribute = technicalAttributeList.get(0);
            } else {
                System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeWithDetails() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeWithDetails() : Retrieved Technical Attributes for requested id.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeWithDetails() : Failed to retrieve Technical Attribute. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeWithDetails() : Failed to retrieve Technical Attribute. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeWithDetails() - exit; technicalAttribute= ' + technicalAttribute);
        }

        return technicalAttribute;
    }

    /**
     * This method is used to retrieve Picklist Definition details.
     */
    public Config.PicklistDefinition getPicklistDefinitionDetails(String picklistDefinitionId) {
        
        System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionDetails() - enter - picklistDefinitionId='+ picklistDefinitionId );
        
        Config.PicklistDefinition picklistDefinition = new Config.PicklistDefinition();
        
        try {

            if( String.IsBlank(picklistDefinitionId) ) {
                System.debug( LoggingLevel.ERROR, 'getPicklistDefinitionDetails() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve Picklist Definition details for requested id.
            picklistDefinition = createPicklistDefinitions ( getPicklistDefinitionRecords( new List<String> {picklistDefinitionId} ) ).get(0);
            
            
            System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionDetails() : Retrieved picklistDefinition.' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getPicklistDefinitionDetails() : Failed to retrieve picklistDefinition. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionDetails() - exit; picklistDefinition = ' + picklistDefinition );
        }
        
        return picklistDefinition;
    }

    /**
     * This method is used to retrieve Picklist Definition details.
     */
    public Map<Id,Config.PicklistDefinition> getPicklistDefinitionDetails(final List<String> picklistDefinitionIds) {
        
        System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionDetails() - enter - picklistDefinitionIds='+ picklistDefinitionIds );
        
        Map<Id,Config.PicklistDefinition> picklistDefinitionMap = new Map<Id,Config.PicklistDefinition>();
        List<Config.PicklistDefinition> picklistDefinitionList = new List<Config.PicklistDefinition>();
        
        try {

            if( picklistDefinitionIds == null || picklistDefinitionIds.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'getPicklistDefinitionDetails() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Create Picklist Definition wrapper.
            picklistDefinitionList = createPicklistDefinitions ( getPicklistDefinitionRecords( picklistDefinitionIds ));

            for(Config.PicklistDefinition picklistDef : picklistDefinitionList) {
                picklistDefinitionMap.put(picklistDef.id,picklistDef);
            }
            
            System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionDetails() : Retrieved picklistDefinitions.' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getPicklistDefinitionDetails() : Failed to retrieve picklistDefinitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionDetails() - exit; picklistDefinitionMap.size() = ' + picklistDefinitionMap.size() );
        }
        
        return picklistDefinitionMap;
    }

    /**
     * This method is used to save requested Technical Attribute(TA). If Technical Attribute id not exists then, 
     * new Technical Attribute record will be created otherwise, existing Technical Attribute will be updated.
     * 
     * @param TechnicalAttribute Technical Attribute wrapper instance to be created/updated.
     * 
     * @return Returns TechAttr.TechnicalAttribute with created/updated record details.
     */
    public TechAttr.TechnicalAttribute saveTechnicalAttribute( final TechAttr.TechnicalAttribute technicalAttribute ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttribute() - enter; technicalAttribute= ' + technicalAttribute );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Technical Attribute informations.
            if( technicalAttribute == null ) {
             
                System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Invalid request parameters. technicalAttribute= ' + technicalAttribute );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            saveTechnicalAttributes( new List<TechAttr.TechnicalAttribute> {technicalAttribute} ).get(0);
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to save TechnicalAttribute. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to save TechnicalAttribute. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttribute() - exit; technicalAttribute= ' + technicalAttribute );
        }
        
        return technicalAttribute;
    }

    /**
     * This method is used to save requested Technical Attribute Template. If Technical Attribute Template id not exists then, 
     * new Technical Attribute Template record will be created otherwise, existing Technical Attribute Template will be updated.
     * 
     * @param TechnicalAttributeTemplate Technical Attribute Template wrapper instance to be created/updated.
     * 
     * @return Returns TechAttr.TechnicalAttributeTemplate with created/updated record details.
     */
    public TechAttr.TechnicalAttributeTemplate saveTechnicalAttributeTemplate( TechAttr.TechnicalAttributeTemplate technicalAttributeTemplate ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplate() - enter; technicalAttributeTemplate = ' + technicalAttributeTemplate );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Technical Attribute informations.
            if( technicalAttributeTemplate == null ) {
             
                System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplate() : Invalid request parameters. technicalAttributeTemplate= ' + technicalAttributeTemplate );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            SVMXA360__SM_TA_Template__c techAttrTemplateRecord = TA_TechnicalAttributeHelper.createTechAttrTemplateRecord(technicalAttributeTemplate);
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            techAttrTemplateRecord = (SVMXA360__SM_TA_Template__c) SvmxDatabase.upsertRecord(techAttrTemplateRecord);
            
            technicalAttributeTemplate.id =  techAttrTemplateRecord.Id;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'technicalAttributeTemplate() : Failed to save technicalAttributeTemplate. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'technicalAttributeTemplate() - exit; technicalAttributeTemplate= ' + technicalAttributeTemplate );
        }
        
        return technicalAttributeTemplate;
    }

    /**
     * This method is used to clone Technical Attribute Template.
     * 
     * @param templateId Id of the Template Record to be cloned.
     * 
     * @return Returns TechAttr.TechnicalAttributeTemplate with cloned record details.
     */
    public TechAttr.TechnicalAttributeTemplate cloneTechnicalAttributeTemplate( String templateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributeTemplate() - enter; templateId = ' + templateId );
        
        Savepoint sPoint = Database.setSavepoint();

        TechAttr.TechnicalAttributeTemplate technicalAttributeTemplate = new TechAttr.TechnicalAttributeTemplate();
        
        try {
            
            // Verify request for valid Technical Attribute informations.
            if( templateId == null ) {
             
                System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributeTemplate() : Invalid request parameters. templateId= ' + templateId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_Template__c> templateRecords = SvmxDatabase.query( [Select Id, SVMXA360__CategorySequenceJSON__c, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c from SVMXA360__SM_TA_Template__c Where Id =: templateId ] );

            SVMXA360__SM_TA_Template__c templateRecord = templateRecords.get(0);
            templateRecords.clear();

            SVMXA360__SM_TA_Template__c cloneTemplateRecord = TA_TechnicalAttributeHelper.populateCloneTemplateRecord( templateRecord );

            String templateItemQuery = 'Select ' + String.join( TemplateItemFields, ',') + ' FROM SVMXA360__SM_TA_TemplateItem__c where SVMXA360__TemplateId__c = :templateId';
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_TemplateItem__c> itemRecords = SvmxDatabase.query( Database.Query( templateItemQuery ) );
            
            if ( !itemRecords.isEmpty() ) {
                TA_TechnicalAttributeHelper.populateCloneTemplateItemRecords( itemRecords, cloneTemplateRecord.Id );
            }

            Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions( 'SVMXA360__SM_TA_TemplateAssociation__c' , true );
            
            for( Common.FieldDefinition fieldDefinition : entityDefinition.fieldDefinitions ) {

                if (fieldDefinition.apiName.endsWith('__c')) {
                    TemplateAssociationFields.add(fieldDefinition.apiName);
                }
                if (fieldDefinition.apiName.endsWith('__c') && fieldDefinition.dataType == 'REFERENCE') {
                    String refFieldName = getReference(fieldDefinition.apiName, '.Name');
                    TemplateAssociationFields.add(refFieldName);
                }
            }

            List<String> associationFieldNames = new List<String>(TemplateAssociationFields);
            associationFieldNames.remove(associationFieldNames.indexOf('Name'));
            associationFieldNames.remove(associationFieldNames.indexOf('LastModifiedDate'));
            associationFieldNames.remove(associationFieldNames.indexOf('LastModifiedBy.Name'));
            associationFieldNames.remove(associationFieldNames.indexOf('CreatedDate'));
            associationFieldNames.remove(associationFieldNames.indexOf('CreatedById'));
            associationFieldNames.remove(associationFieldNames.indexOf('CreatedBy.Name'));
            associationFieldNames.remove(associationFieldNames.indexOf('SVMXA360__TemplateId__c'));

            String recQueryStr = 'SELECT ' + String.join(associationFieldNames, ',') + ' FROM SVMXA360__SM_TA_TemplateAssociation__c';
            recQueryStr +=' WHERE SVMXA360__TemplateId__c =\''+templateId+'\'';
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            List<SVMXA360__SM_TA_TemplateAssociation__c> tempAssociations = SvmxDatabase.query(recQueryStr);

            if ( !tempAssociations.isEmpty() ) {
                TA_TechnicalAttributeHelper.populateTempAssociationsRecords( tempAssociations, cloneTemplateRecord.Id );
            }

            technicalAttributeTemplate = TA_TechnicalAttributeHelper.createTechAttrTemplate(cloneTemplateRecord);
        
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributeTemplate() : Failed to clone technicalAttributeTemplate. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributeTemplate() - exit; technicalAttributeTemplate= ' + technicalAttributeTemplate );
        }
        
        return technicalAttributeTemplate;
    }

    /**
     * This method is used to save list of TechnicalAttribute records.
     */
    public List<TechAttr.TechnicalAttribute> saveTechnicalAttributes( final List<TechAttr.TechnicalAttribute> technicalAttributes ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributes() - enter; technicalAttributes= ' + technicalAttributes );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Technical Attribute informations.
            if( technicalAttributes == null ||  technicalAttributes.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' technicalAttributes= ' + technicalAttributes );
            }

            Map<String,Config.PicklistDefinition> picklistAttributeMap = new Map<String,Config.PicklistDefinition>();
            List<Config.PicklistDefinition> picklistDefinitions = new List<Config.PicklistDefinition>();
            
            for( TechAttr.TechnicalAttribute eachTA : technicalAttributes ) {
                if( eachTA.dataType.equalsIgnoreCase('Picklist') &&  eachTA.picklistDefinition != null) {
                    picklistAttributeMap.put(eachTA.developerName,eachTA.picklistDefinition);
                }
            }
            picklistDefinitions.addAll(picklistAttributeMap.values());
            
            // Build TechnicalAttribute records.
            List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = createTechnicalAttributeRecords(technicalAttributes);

            // Upsert PicklistDefinitions records.
            if (picklistDefinitions.size() > 0 ) {
                picklistDefinitions = savePicklistDefinitions( picklistDefinitions );
            }

            for( Integer index = 0; index < technicalAttributes.size(); index++ ) { 

                final TechAttr.TechnicalAttribute technicalAttribute = technicalAttributes.get(index);
                final SVMXA360__SM_TA_TechnicalAttribute__c technicalAttributeRecord = technicalAttributeRecords.get(index);
                technicalAttribute.id = technicalAttributeRecord.id;

                if (picklistAttributeMap.containsKey(technicalAttribute.developerName)) {
                    Config.PicklistDefinition picklistDefinition = picklistAttributeMap.get(technicalAttribute.developerName);
                    technicalAttributeRecord.SVMXA360__PicklistDefinitionId__c = picklistDefinition.Id;
                }
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            technicalAttributeRecords = (List<SVMXA360__SM_TA_TechnicalAttribute__c>) SvmxDatabase.upsertRecord(technicalAttributeRecords);

            // Update Id's for technicalAttributes in response
            for( Integer index = 0; index < technicalAttributeRecords.size(); index++ ) {
                technicalAttributes.get(index).id = technicalAttributeRecords.get(index).Id;
            }

            System.debug( LoggingLevel.INFO, 'saveTechnicalAttributes() : Saved technicalAttributeRecords = ' + technicalAttributeRecords.size() );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : Failed to save TechnicalAttributes. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : Failed to save TechnicalAttributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributes() - exit; technicalAttributes= ' + technicalAttributes );
        }
        
        return technicalAttributes;
    }

    /**
     * This method is used to retrieve Histories of given Asset Technical Attribute record .
     */
    public TechAttr.AttributeHistory getAttributeHistories(TechAttr.AttributeHistoryRequest historyRequest) {
        
        System.debug( LoggingLevel.DEBUG, 'getAttributeHistories() - enter - historyRequest='+ historyRequest );
        
        TechAttr.AttributeHistory attributeHistories = new TechAttr.AttributeHistory();

        try {

            if( historyRequest == null || String.IsBlank(historyRequest.attributeId)  || String.IsBlank(historyRequest.sourceObjectName)) {
                System.debug( LoggingLevel.ERROR, 'getAttributeHistories() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            String objectName;
            if (historyRequest.sourceObjectName.equalsIgnoreCase(ASSET_OBJ)) {
                objectName = ASSET_TECH_ATTRIBUTE.replace('__c',HISTORY_OBJ);           
            }

            //List<TechAttr.AttributeHistory> attributeHistoryList = getAttributesHistories( new List<String> {historyRequest.attributeId},objectName, null, null );
            List<SObject> recordList = getAttributesHistories( new List<String> {historyRequest.attributeId},objectName, null, null, null );
            List<TechAttr.AttributeHistory> attributeHistoryList = TA_TechnicalAttributeHelper.createAttributeHistories (recordList);
            if (attributeHistoryList!=null && attributeHistoryList.size()>0){
                attributeHistories = attributeHistoryList[0];
            }
            // Retrieved histories for requested id.
            System.debug( LoggingLevel.FINE, 'getAttributeHistories() : attributeHistories = ' + attributeHistories );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAttributeHistories() : Failed to retrieve picklistDefinition. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAttributeHistories() - exit; attributeHistories = ' + attributeHistories );
        }
        
        return attributeHistories;
    }

    /**
     * This method is used to retrieve Histories of given Asset Technical Attribute records .
     */
    public List<SObject> getAttributesHistories(List<String> attributeList, String objectName, dateTime startDate, dateTime endDate, integer rowlimit) { //return type List<AttributeHistoryDetail>, pass limit
        
        System.debug( LoggingLevel.DEBUG, 'getAttributesHistories() - enter - attributeList='+ attributeList );
        
        List<SObject> recordList = new List<SObject>();
        try {

            if( attributeList == null || attributeList.size() == 0 || String.IsBlank(objectName)) {
                System.debug( LoggingLevel.ERROR, 'getAttributesHistories() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            list<string> historyRecordFieldList = new list<string>{'created', 'SVMXA360__Value__c', 'SVMXA360__CapturedOn__c'};
            String historyQuery = 'Select ' + String.join( attributeHistoryFields, ',') +' from '+ objectName + ' where parentId IN : attributeList AND Field IN :historyRecordFieldList';
            if(startDate != null && endDate != null) {
                historyQuery = historyQuery + ' AND CreatedDate >=: startDate AND CreatedDate <=: endDate';
            }
            historyQuery = historyQuery + ' Order By CreatedDate DESC';

            if(rowlimit != null) {
                historyQuery = historyQuery + ' LIMIT '+rowlimit;
            }

            System.debug( LoggingLevel.FINE, 'getAttributesHistories() : historyQuery = ' + historyQuery );
            /* sfge-disable-next-line ApexFlsViolationRule */
            recordList = SvmxDatabase.query( Database.Query( historyQuery ) ); 
            // Retrieved histories for requested id.
            System.debug( LoggingLevel.FINE, 'getAttributesHistories() : recordList = ' + recordList );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAttributesHistories() : Failed to retrieve picklistDefinition. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAttributesHistories() - exit; recordList = ' + recordList );
        }
        
        return recordList;
    }

    /**
     * This method is used to retrieve Histories of given Asset Technical Attribute records . Mahima
     */
    public List<TechAttr.AttributeHistoryDetail> getAttributesHistoryList (TechAttr.AttributeHistoryFilter request) {
        System.debug( LoggingLevel.DEBUG, 'getAttributesHistoryList() - enter; mapJSONRequest= ' + request);
        
        List<TechAttr.AttributeHistoryDetail> attributeHistoryDetailList = new List<TechAttr.AttributeHistoryDetail>();
        List<SObject> recordList = new List<SObject>();
        try {
            
            if (request.objectId == NULL || request.objectName == NULL ) {
                System.debug( LoggingLevel.ERROR, 'getAttributesHistoryList() - Failed to fetch history; no assetId');
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            if (request.objectName.equalsIgnoreCase(ASSET_OBJ)) {
                request.objectName = ASSET_TECH_ATTRIBUTE.replace('__c',HISTORY_OBJ);           
            }
            if ( request.endDate != null ) {
                request.endDate = request.endDate.addHours(23);
                request.endDate = request.endDate.addMinutes(59);
                request.endDate = request.endDate.addSeconds(59);
            }
            recordList = getAttributesHistories(request.attributeIdList, request.objectName, request.startDate, request.endDate, request.rowlimit );
            List<TechAttr.AttributeHistory> attributeHistoryList = TA_TechnicalAttributeHelper.createAttributeHistories (recordList);
            if (attributeHistoryList!=null && attributeHistoryList.size()>0){ 
                for(TechAttr.AttributeHistory eachAttribute : attributeHistoryList) {
                    if (eachAttribute.attributeHistoryDetailList !=null && eachAttribute.attributeHistoryDetailList.size() > 0 ) {
                        attributeHistoryDetailList.addAll(eachAttribute.attributeHistoryDetailList);
                    }
                }
            }
            //attributeHistoryList = TA_TechnicalAttributeHelper.createAttributeHistoryDetails (recordList);            

        } catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAttributesHistoryList() :  Failed to fetch history. Error' + e.getStackTraceString() );
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAttributesHistoryList() - exit;  ' );
        }
        return attributeHistoryDetailList;
    }
    
    //Queries Template Items based on template ids provided
    public  List<TechAttr.TechnicalAttribute> getAllAttributesAssociatedToParent (string parentRecordId, string objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllAttributesAssociatedToParent() : parentRecordId = ' + parentRecordId );
        List<TechAttr.TechnicalAttribute> assetTechnicalAttributesList = new List<TechAttr.TechnicalAttribute>();
        List<SObject> recordList = new List<SObject>();
        try {
            string parentField;
            if (objectName.equalsIgnoreCase(ASSET_OBJ)) {
                objectName = ASSET_TECH_ATTRIBUTE;
                parentField = ASSET_FIELD;        
            }
            String query = 'Select ' + String.join( attributeFields, ',') +' from '+ objectName + ' where ' + parentField + '= : parentRecordId ';
            /* sfge-disable-next-line ApexFlsViolationRule */
            recordList =  SvmxDatabase.query( Database.Query( query ) ); 
            assetTechnicalAttributesList = TA_TechnicalAttributeHelper.createTechnicalAttributeFromAssetAttribute(recordList); 
                    
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllAttributesAssociatedToParent() : Failed to query Template items. Error' + e.getStackTraceString() );
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllAttributesAssociatedToParent() - exit; Templates Items found =  ' + assetTechnicalAttributesList);
        }
        
        return assetTechnicalAttributesList;                                                        
    } 
    

    public List<Config.PicklistDefinition> savePicklistDefinitions (final List<Config.PicklistDefinition> picklistDefinitions ) {

        System.debug( LoggingLevel.DEBUG, 'savePicklistDefinitions() - enter; picklistDefinitions= ' + picklistDefinitions );
        
        Savepoint sPoint = Database.setSavepoint();

        try {
            
            // Verify request for valid picklistDefinitions.
            if( picklistDefinitions == null || picklistDefinitions.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'savePicklistDefinitions() : Invalid request parameters. picklistDefinitions= ' + picklistDefinitions );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_PicklistDefinition__c> picklistDefinitionRecords = (List<SVMXA360__CONF_PicklistDefinition__c>) SvmxDatabase.upsertRecord( createPicklistDefinitionRecords(picklistDefinitions));

            for( Integer index = 0; index < picklistDefinitions.size(); index++ ) {

                final Config.PicklistDefinition picklistDefinition = picklistDefinitions.get(index);
                final SVMXA360__CONF_PicklistDefinition__c picklistDefinitionRecord = picklistDefinitionRecords.get(index);
                picklistDefinition.id = picklistDefinitionRecord.Id;
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'savePicklistDefinitions() : Failed to save picklistDefinitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'savePicklistDefinitions() : Failed to save picklistDefinitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePicklistDefinitions() - exit; picklistDefinitions= ' + picklistDefinitions.size() );
        }
        
        return picklistDefinitions;

    }

    /**
     * This method is used to get list of TechnicalAttribute Category and Template Item records.
     */
    public List<TechAttr.TechnicalAttributeCategory> getTechnicalAttributeTemplateCategories( String templateId ) {
    
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateCategories() - enter; templateId = ' + templateId );

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeTemplateCategories = new List<TechAttr.TechnicalAttributeCategory>();
        SVMXA360__SM_TA_Template__c templateRecord = new SVMXA360__SM_TA_Template__c();

        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_Template__c> templateRecords = SvmxDatabase.query( [Select Id,SVMXA360__CategorySequenceJSON__c, SVMXA360__DeveloperName__c from SVMXA360__SM_TA_Template__c Where Id =: templateId ] );

            if( templateRecords == null || templateRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' templateId = ' + templateId );
            }

            templateRecord = templateRecords.get(0);
            templateRecords.clear(); 

            if ( templateRecord.SVMXA360__CategorySequenceJSON__c != null ) {

                Map <String, TechAttr.TechAttrTemplateCategorySequence> categorySequenceMap = new Map <String, TechAttr.TechAttrTemplateCategorySequence>();

                List<TechAttr.TechAttrTemplateCategorySequence> techAttrTemplateCategorySequences = 
                    (List<TechAttr.TechAttrTemplateCategorySequence>) JSON.deserialize(templateRecord.SVMXA360__CategorySequenceJSON__c, List<TechAttr.TechAttrTemplateCategorySequence>.class);
                
                for ( TechAttr.TechAttrTemplateCategorySequence categorySequence : techAttrTemplateCategorySequences ) {
                    categorySequenceMap.put(categorySequence.categoryId, categorySequence);
                }

                Set<String> categoryIds = categorySequenceMap.keySet();

                String categoryQuery = 'Select Id, Name, SVMXA360__Description__c, (  Select ' + String.join( TemplateItemFields, ',') + 
                    ' FROM SVMXA360__TechnicalAttributeTemplateItems__r where SVMXA360__TemplateId__c = :templateId ORDER by SVMXA360__Sequence__c ASC ) from SVMXA360__SM_TA_Category__c Where Id IN : categoryIds';

                System.debug( LoggingLevel.DEBUG, 'categoryQuery = ' + categoryQuery );
                /* sfge-disable-next-line ApexFlsViolationRule */ 
                List<SVMXA360__SM_TA_Category__c> categoryRecords = SvmxDatabase.query( Database.Query( categoryQuery ) ); 

                TechAttr.TechnicalAttributeCategory techAttrCategory;
                TechAttr.TechAttrTemplateCategorySequence categorySequence = new TechAttr.TechAttrTemplateCategorySequence();
                List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems;

                for ( SVMXA360__SM_TA_Category__c category : categoryRecords ) {

                    categorySequence = categorySequenceMap.get(category.Id);

                    techAttrCategory = new TechAttr.TechnicalAttributeCategory();
                    techAttrCategory.sequence = categorySequence.sequence;
                    techAttrCategory.developerName = categorySequence.developerName;
                    techAttrCategory.name = category.Name;
                    techAttrCategory.id = category.Id;
                    techAttrCategory.description = category.SVMXA360__Description__c;

                    technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();

                    for ( SVMXA360__SM_TA_TemplateItem__c tempItem : category.SVMXA360__TechnicalAttributeTemplateItems__r ) {
                        technicalAttributeTemplateItems.add( TA_TechnicalAttributeHelper.buildTemplateItem(tempItem) );
                    }

                    techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;

                    technicalAttributeTemplateCategories.add(techAttrCategory);
                }

            } else {
                technicalAttributeTemplateCategories.add( TA_TechnicalAttributeHelper.populateDummyCategory(templateRecord) );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateCategories() : Failed to get TechnicalAttributeCategories. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateCategories() : Failed to get TechnicalAttributeCategories. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateCategories() - exit; technicalAttributeTemplateCategories = ' + technicalAttributeTemplateCategories );
        }

        return technicalAttributeTemplateCategories;
    }

    /**
     * This method is used to save list of TechnicalAttribute Category and Template Item records.
     */
    public List<TechAttr.TechnicalAttributeCategory> saveTechnicalAttributeTemplateCategories( TechAttr.TechnicalAttributeTemplateCategories technicalAttributeTemplateCategories ) {

        List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories = technicalAttributeTemplateCategories.techAttrTemplateCategories;
        String templateId = technicalAttributeTemplateCategories.templateId;
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateCategories() - enter; technicalAttributeTemplateCategories = ' + technicalAttributeTemplateCategories );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {

            // Verify request for valid Technical Attribute informations.
            if( technicalAttributeCategories == null || technicalAttributeCategories.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' techAttrTemplateCategories= ' + technicalAttributeCategories );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_Template__c> templateRecords = SvmxDatabase.query( [Select Id, SVMXA360__CategorySequenceJSON__c, SVMXA360__Status__c from SVMXA360__SM_TA_Template__c Where Id =: templateId ] );

            if( templateRecords == null || templateRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' templateId = ' + templateId );
            }

            SVMXA360__SM_TA_Template__c templateRecord = templateRecords.get(0);
            templateRecords.clear();

            TA_TechnicalAttributeHelper.saveCategoryRecords( technicalAttributeCategories );

            TA_TechnicalAttributeHelper.saveTemplateItemRecords( technicalAttributeCategories, templateId );

            List<TechAttr.TechAttrTemplateCategorySequence> techAttrTemplateCategorySequences = new List<TechAttr.TechAttrTemplateCategorySequence>();
            Set<Id> categoryIds = new Set<Id>();

            for (TechAttr.TechnicalAttributeCategory techAttrCategory : technicalAttributeCategories ) {
                TechAttr.TechAttrTemplateCategorySequence categorySequence = new TechAttr.TechAttrTemplateCategorySequence();
                categorySequence.developerName = techAttrCategory.developerName;
                categorySequence.sequence = techAttrCategory.sequence;
                categorySequence.categoryId = techAttrCategory.id;
                categoryIds.add(techAttrCategory.id);
                techAttrTemplateCategorySequences.add(categorySequence);
            }

            Set<Id> categoryIdsForDeletion = new Set<Id>();

            if ( templateRecord.SVMXA360__CategorySequenceJSON__c != null ) {

                List<TechAttr.TechAttrTemplateCategorySequence> existingTemplateCategorySequences = 
                        (List<TechAttr.TechAttrTemplateCategorySequence>) JSON.deserialize(templateRecord.SVMXA360__CategorySequenceJSON__c, List<TechAttr.TechAttrTemplateCategorySequence>.class);
                
                if ( !categoryIds.isEmpty() ) {
                    for ( TechAttr.TechAttrTemplateCategorySequence techSequence : existingTemplateCategorySequences ) {
                        if ( !categoryIds.contains(techSequence.categoryId) ) {
                            categoryIdsForDeletion.add(techSequence.categoryId);
                        }
                    }
                }
            }

            if ( !categoryIdsForDeletion.isEmpty() ) {
                deleteCategories(categoryIdsForDeletion);
            }

            templateRecord.SVMXA360__CategorySequenceJSON__c = JSON.serializePretty(techAttrTemplateCategorySequences);
            templateRecord.SVMXA360__Status__c = 'Active';
            /* sfge-disable-next-line ApexFlsViolationRule */
            templateRecord = (SVMXA360__SM_TA_Template__c) SvmxDatabase.upsertRecord(templateRecord);

            System.debug( LoggingLevel.INFO, 'saveTechnicalAttributeTemplateCategories() : Saved TechnicalAttributeCategories = ' + technicalAttributeCategories.size() );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateCategories() : Failed to save TechnicalAttributeCategories. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateCategories() : Failed to save TechnicalAttributeCategories. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateCategories() - exit; technicalAttributeCategories = ' + technicalAttributeCategories );
        }
        
        return technicalAttributeCategories;
    }

    private void deleteCategories ( Set<Id> categoryIdsForDeletion ) {

        System.debug( LoggingLevel.DEBUG, 'deleteCategories() - enter; categoryIdsForDeletion = ' + categoryIdsForDeletion );

        try {

            List<SVMXA360__SM_TA_Category__c> categoryRecordsForDeletion = new List<SVMXA360__SM_TA_Category__c>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_Category__c> categoryRecords = SvmxDatabase.Query( [Select Id, (Select Id from SVMXA360__TechnicalAttributeTemplateItems__r)  from SVMXA360__SM_TA_Category__c where Id IN :categoryIdsForDeletion] );

            for ( SVMXA360__SM_TA_Category__c categoryRec : categoryRecords ) {
                
                if ( categoryRec.SVMXA360__TechnicalAttributeTemplateItems__r.size() == 0 ) {
                    categoryRecordsForDeletion.add(categoryRec);
                }
            }

            if ( !categoryRecordsForDeletion.isEmpty() ) {
                SvmxDatabase.deleteRecord(categoryRecordsForDeletion);
            }

        } catch ( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCategories() : Failed to delete Categories. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }    

    /**
     * This method is used to save list of Technical Attribute Template Association records.
     */
    public TechAttr.TechAttrTemplateAssociation saveTechnicalAttributeTemplateAssociation( TechAttr.TechAttrTemplateAssociation templateAssociation ) {

        TechAttr.TechAttrTemplateAssociationList tempAssociationList = new TechAttr.TechAttrTemplateAssociationList();
        Savepoint sPoint = Database.setSavepoint();

        try {

            // Verify request for valid Technical Attribute Association information.
            if( templateAssociation == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' templateAssociation = ' + templateAssociation );
            }

            List<TechAttr.TechAttrTemplateAssociation> tempAssociations = new List<TechAttr.TechAttrTemplateAssociation>();

            tempAssociations.add(templateAssociation);
            tempAssociationList.templateAssociations = tempAssociations;

            tempAssociationList = saveTechnicalAttributeTemplateAssociations( tempAssociationList );

            if (tempAssociationList.templateAssociations!=null && tempAssociationList.templateAssociations.size() > 0) {
                templateAssociation = tempAssociationList.templateAssociations.get(0);
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociation() : Failed to save templateAssociations. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociation() : Failed to save templateAssociations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateAssociation() - exit; templateAssociations = ' + templateAssociation );
        }

        return templateAssociation;
    }

    /**
     * This method is used to save list of Technical Attribute Template Association records.
     */
    public TechAttr.TechAttrTemplateAssociationList saveTechnicalAttributeTemplateAssociations( TechAttr.TechAttrTemplateAssociationList tempAssociationList ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateAssociations() - enter;' );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Technical Attribute Association information.
            if( tempAssociationList == null || tempAssociationList.templateAssociations.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' tempAssociationList = ' + tempAssociationList );
            }

            List<SVMXA360__SM_TA_TemplateAssociation__c> templateAssociationRecords = new List<SVMXA360__SM_TA_TemplateAssociation__c>();
            // Retrieve field describe for TA-Match Values Object.
            Map<String, Schema.DescribeFieldResult> associationFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( 'SVMXA360__SM_TA_TemplateAssociation__c' );

            for ( TechAttr.TechAttrTemplateAssociation tempAssociation : tempAssociationList.templateAssociations ) {
                templateAssociationRecords.add( TA_TechnicalAttributeHelper.buildTemplateAssociationRecord( tempAssociation,associationFieldResultMap ) );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            templateAssociationRecords = (List<SVMXA360__SM_TA_TemplateAssociation__c>) SvmxDatabase.upsertRecord(templateAssociationRecords);

            System.debug( LoggingLevel.INFO, 'saveTechnicalAttributeTemplateAssociations() : Saved templateAssociationRecords = ' + templateAssociationRecords );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociations() : Failed to save templateAssociations. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociations() : Failed to save templateAssociations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateAssociations() - exit; ' );
        }
        
        return tempAssociationList;
    }

    /**
     * This method is used to save list Technical Attributes for an target objects.
     * ex - Asset or Opportunity.
     */
    public TechAttr.AttributeRecordList saveAttributeRecords( TechAttr.AttributeRecordList attributeRecordDetails ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveAttributeRecords() - enter;' );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Asset Technical Attribute information.
            if(attributeRecordDetails == null || attributeRecordDetails.attributeRecords ==null || attributeRecordDetails.attributeRecords.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' attributeRecordDetails = ' + attributeRecordDetails );
            } else if (String.isBlank(attributeRecordDetails.sourceObjectName)){
                throw new SvmxSystem.SvmxNestedException( ' ObjectName: ' + ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            if (String.isBlank(attributeRecordDetails.targetObjectName) && attributeRecordDetails.sourceObjectName.equalsIgnoreCase(ASSET_OBJ)) {
                attributeRecordDetails.targetObjectName = ASSET_TECH_ATTRIBUTE;              
            }

            //Fetch Fields on Target Object
            attributeFieldMap = TechAttr.getAttributeFieldsMap( attributeRecordDetails.sourceObjectName ); 

            final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
            SObjectType objectType = describeManager.getsObjectType( attributeRecordDetails.targetObjectName );
            Map<String, Schema.SObjectField> targetFieldResultMap = describeManager.getObjectFieldMap( attributeRecordDetails.targetObjectName );
            
            new TA_TechnicalAttributeHandler().validateTargetObjectFieldNames ( targetFieldResultMap );

            final List<SObject> targetAttributeRecords = new List<SObject>();
            for( TechAttr.AttributeRecord eachAttributeRecord : attributeRecordDetails.attributeRecords ) {
                targetAttributeRecords.add( buildTargetAttributeRecord( eachAttributeRecord,  targetFieldResultMap, objectType, attributeRecordDetails.requestSource ) );
            }
            
            if ( !targetAttributeRecords.isEmpty()) { 
                SvmxDatabase.upsertRecord(targetAttributeRecords);
            }
            
            // Update Id's for technicalAttributes in response
            for( Integer index = 0; index < targetAttributeRecords.size(); index++ ) {
                attributeRecordDetails.attributeRecords.get(index).id = (Id)targetAttributeRecords.get(index).get('Id');
            }

            System.debug( LoggingLevel.INFO, 'saveAttributeRecords() : Saved Asset Technical Attributes = ' + attributeRecordDetails );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveAttributeRecords() : Failed to save Asset Technical Attributes. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveAttributeRecords() : Failed to save Asset Technical Attributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveAttributeRecords() - exit; ' );
        }
        
        return attributeRecordDetails;
    }

    /**
     * This method is used to check the reference records during deletion of Technical Attribute for requested id.
     */
    public TechAttr.TechnicalAttributeReference deleteCheckOnRelatedTA( final String attributeId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteCheckOnRelatedTA() - enter; attributeId= ' + attributeId );
        TechAttr.TechnicalAttributeReference attributeReference = new TechAttr.TechnicalAttributeReference();
        try {
            
            if( String.isBlank(attributeId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' attributeId= ' + attributeId );
            }
            
            attributeReference = new TA_TechnicalAttributeHandler().deleteCheckOnTA( new Set<Id>{attributeId} ).get(0);

            if (attributeReference.relatedAssetTechnicalAttributes == null && attributeReference.relatedTemplates == null) {
                deleteTechnicalAttributes( new List<String>{attributeId} );
            }            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnRelatedTA() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnRelatedTA() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCheckOnRelatedTA() - exit' );
        }

        return attributeReference;
    }

    /**
     * This method is used to delete Technical Attributes and its related TA-Template Items for requested id from confirmation popup.
     */
    public void deleteTechnicalAttribute( final String attributeId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttribute() - enter; attributeId= ' + attributeId );
        
        try {
            
            if( String.isBlank(attributeId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' attributeId= ' + attributeId );
            }

            deleteTechnicalAttributes( new List<String>{attributeId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttribute() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttribute() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttribute() - exit' );
        }
    }

    /**
     * This method is used to delete Technical Attributes and its related TA-Template Items for requested id.
     */
    public void deleteTechnicalAttributes( final List<String> attributeIdIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributes() - enter; attributeIdIdList= ' + attributeIdIdList );
        final SavePoint sPoint = Database.setSavepoint();
        
        try {
            
            if( attributeIdIdList == null || attributeIdIdList.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' attributeIdIdList= ' + attributeIdIdList );
            }
            
            skipTriggerExecution = true;

            Set<Id> picklistIdSet = new Set<Id>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            for(SVMXA360__SM_TA_TechnicalAttribute__c eachTA : (List<SVMXA360__SM_TA_TechnicalAttribute__c>)SvmxDatabase.query( [SELECT SVMXA360__PicklistDefinitionId__c FROM SVMXA360__SM_TA_TechnicalAttribute__c WHERE Id IN :attributeIdIdList AND SVMXA360__DataType__c ='Picklist'] ) ) {
                picklistIdSet.add(eachTA.SVMXA360__PicklistDefinitionId__c);
            }

            /* sfge-disable-next-line ApexFlsViolationRule */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_PicklistDefinition__c WHERE Id IN :picklistIdSet ] );
            /* sfge-disable-next-line ApexFlsViolationRule */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TemplateItem__c WHERE SVMXA360__AttributeId__c IN :attributeIdIdList ] );           
            /* sfge-disable-next-line ApexFlsViolationRule */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TechnicalAttribute__c WHERE Id IN :attributeIdIdList ] );
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback(sPoint);

            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributes() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback(sPoint);

            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributes() : Failed to delete Technical Attributes. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributes() - exit' );
        }
    }

    /**
     * This method is used to delete Picklist Definition record for requested id.
     */
    public void deletePicklistDefinition( final String picklistDefinitionId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePicklistDefinition() - enter; picklistDefinitionId= ' + picklistDefinitionId );
        
        try {
            
            if( String.isBlank(picklistDefinitionId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' picklistDefinitionId= ' + picklistDefinitionId );
            }
            
            deletePicklistDefinitions( new List<String>{picklistDefinitionId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deletePicklistDefinition() : Failed to delete Picklist Definition. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deletePicklistDefinition() : Failed to delete Picklist Definition. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePicklistDefinition() - exit' );
        }
    }

    /**
     * This method is used to delete Picklist Definition records for requested list of ids.
     */
    public void deletePicklistDefinitions( final List<String> picklistDefinitionIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePicklistDefinitions() - enter; picklistDefinitionIdList= ' + picklistDefinitionIdList );
        
        final SavePoint sPoint = Database.setSavepoint();

        try {
            
            if( picklistDefinitionIdList == null || picklistDefinitionIdList.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' picklistDefinitionIdList= ' + picklistDefinitionIdList );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_PicklistDefinition__c WHERE Id IN :picklistDefinitionIdList ] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'deletePicklistDefinitions() : Failed to delete Picklist Definition. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback(sPoint);

            System.debug( LoggingLevel.ERROR, 'deletePicklistDefinitions() : Failed to delete Picklist Definition. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePicklistDefinitions() - exit' );
        }
    }

    /**
     * This method is used to delete technical attribute template items associated with a category which is being removed. 
     */
    public void deleteTechnicalAttributeTemplateCategory(final string categoryId ) {
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateCategory() - enter' );
        try {
            if( categoryId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' categoryId= ' + categoryId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TemplateItem__c WHERE SVMXA360__CategoryId__c =: categoryId ] );
            /* sfge-disable-next-line ApexFlsViolationRule */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_Category__c WHERE id =: categoryId ] );
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateCategory() : Deleted TA template Items' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateCategory() : Failed to deleted TA template Items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateCategory() - exit' );
        }
    }

    /**
     * This method is used to delete technical attribute template item. 
     */
    public void deleteTechnicalAttributeTemplateItem(final list<string> templateItemIdList) {

        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItem() - enter' );
        try {
            if( templateItemIdList == null || templateItemIdList.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' templateItemIdList ' + templateItemIdList );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TemplateItem__c WHERE Id IN :templateItemIdList ] );
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItem() : Deleted TA template Items' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateItem() : Failed to deleted TA template Items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItem() - exit' );
        }
    }

    /**
     * This method is used to delete technical attribute template association. 
     */
    public void deleteTechnicalAttributeTemplateAssociation(final string templateAssociation ) {

        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateAssociation() - enter' );
        try {
            if( templateAssociation == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' templateAssociation= ' + templateAssociation );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TemplateAssociation__c WHERE Id = :templateAssociation ] );
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateAssociation() : Deleted TA template Association' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateAssociation() : Failed to deleted TA template Items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateAssociation() - exit' );
        }
    }

    /**
     * This method is used to delete technical attribute template. 
    */
    public void deleteTechnicalAttributeTemplate(final string templateId ) {

        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplate() - enter' );
        try {
            if( templateId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' templateId= ' + templateId );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_Template__c> templateRecords = SvmxDatabase.query( [Select Id,SVMXA360__CategorySequenceJSON__c from SVMXA360__SM_TA_Template__c Where Id = :templateId ] );

            SVMXA360__SM_TA_Template__c templateRecord = templateRecords.get(0);
            templateRecords.clear();
            
            Set<Id> categoryIds = new Set<Id>();

            if ( templateRecord.SVMXA360__CategorySequenceJSON__c != null ) {

                List<TechAttr.TechAttrTemplateCategorySequence> techAttrTemplateCategorySequences = 
                    (List<TechAttr.TechAttrTemplateCategorySequence>) JSON.deserialize(templateRecord.SVMXA360__CategorySequenceJSON__c, List<TechAttr.TechAttrTemplateCategorySequence>.class);
                
                for ( TechAttr.TechAttrTemplateCategorySequence categorySequence : techAttrTemplateCategorySequences ) {
                    categoryIds.add(categorySequence.categoryId);
                }
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_Template__c WHERE Id = :templateId ] );

            if ( !categoryIds.isEmpty() ) {
                deleteCategories(categoryIds);
            }
            
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplate() : Failed to deleted TA template. Error= ' + e.getStackTraceString() );
            throw e; 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplate() - exit' );
        }
    }


    /**
     * This method is used to retrieve Picklist Definition records for the requested ids.
     */
    public List<SVMXA360__CONF_PicklistDefinition__c> getPicklistDefinitionRecords( final List<String> picklistDefinitionIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionRecords() - enter picklistDefinitionIds='+ picklistDefinitionIds );
        
        List<SVMXA360__CONF_PicklistDefinition__c> picklistDefinitionRecords = new List<SVMXA360__CONF_PicklistDefinition__c>();
            
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            picklistDefinitionRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__DeveloperName__c,SVMXA360__Description__c, SVMXA360__Values__c, SVMXA360__DefaultValue__c, SVMXA360__Type__c FROM SVMXA360__CONF_PicklistDefinition__c WHERE Id IN :picklistDefinitionIds]);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPicklistDefinitionRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPicklistDefinitionRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPicklistDefinitionRecords() - exit' );
        }
        
        return picklistDefinitionRecords;
    }

    private List<SVMXA360__SM_TA_TechnicalAttribute__c> createTechnicalAttributeRecords( final List<TechAttr.TechnicalAttribute> technicalAttributes ) {
        
        final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords = new List<SVMXA360__SM_TA_TechnicalAttribute__c>();
        for( TechAttr.TechnicalAttribute technicalAttribute : technicalAttributes ) {
            technicalAttributeRecords.add( TA_TechnicalAttributeHelper.createTechnicalAttributeRecord(technicalAttribute) );
        }
        
        return technicalAttributeRecords;
    }

    private List<SVMXA360__CONF_PicklistDefinition__c> createPicklistDefinitionRecords( final List<Config.PicklistDefinition> picklistDefinitions ) {
        
        final List<SVMXA360__CONF_PicklistDefinition__c> picklistDefinitionRecords = new List<SVMXA360__CONF_PicklistDefinition__c>();
        for( Config.PicklistDefinition picklistDefinition : picklistDefinitions ) {
            picklistDefinitionRecords.add( TA_TechnicalAttributeHelper.createPicklistDefinitionRecord(picklistDefinition) );
        }
        
        return picklistDefinitionRecords;
    }

    private List<TechAttr.TechnicalAttribute> createTechnicalAttributes( final List<SVMXA360__SM_TA_TechnicalAttribute__c> technicalAttributeRecords ) {
        
        final List<TechAttr.TechnicalAttribute> technicalAttributes = new List<TechAttr.TechnicalAttribute>();
        final Map<Id,TechAttr.TechnicalAttribute> picklistDefinitionIdMap = new Map<Id,TechAttr.TechnicalAttribute>();
        
        for( SVMXA360__SM_TA_TechnicalAttribute__c technicalAttributeRecord : technicalAttributeRecords ) {
            
            final TechAttr.TechnicalAttribute technicalAttribute = TA_TechnicalAttributeHelper.createTechnicalAttribute(technicalAttributeRecord);
            if( technicalAttribute.dataType.equalsIgnoreCase('Picklist') && technicalAttribute.picklistDefinition.id != null  ) {
                picklistDefinitionIdMap.put( technicalAttribute.picklistDefinition.id, technicalAttribute );
            }
            technicalAttributes.add(technicalAttribute);
        }
        if( !picklistDefinitionIdMap.isEmpty() ) {
            final Map<Id,Config.PicklistDefinition> picklistDefinitionMap = getPicklistDefinitionDetails( new List<Id>(picklistDefinitionIdMap.keySet()) );
            for( TechAttr.TechnicalAttribute technicalAttribute: picklistDefinitionIdMap.values() ) {
                technicalAttribute.picklistDefinition = picklistDefinitionMap.get(technicalAttribute.picklistDefinition.id);
            }
        }
        
        return technicalAttributes;
    }

    private List<Config.PicklistDefinition> createPicklistDefinitions( final List<SVMXA360__CONF_PicklistDefinition__c> picklistDefinitionRecords ) {
        
        final List<Config.PicklistDefinition> picklistDefinitions = new List<Config.PicklistDefinition>();
        
        for( SVMXA360__CONF_PicklistDefinition__c picklistDefinitionRecord : picklistDefinitionRecords ) {
            
            final Config.PicklistDefinition picklistDefinition = TA_TechnicalAttributeHelper.createPicklistDefinition(picklistDefinitionRecord);
            picklistDefinitions.add(picklistDefinition);
        }
        
        return picklistDefinitions;
    }

    private SObject buildTargetAttributeRecord( TechAttr.AttributeRecord attributeRecord, Map<String, Schema.SObjectField> targetFieldResultMap, SObjectType objectType, String source ) {
        
        System.debug( LoggingLevel.DEBUG, 'buildTargetAttributeRecord() - enter; attributeRecord=' + attributeRecord);
        
        SObject targetRecord = objectType.newSObject();
        try {   
            targetRecord.put( 'Id', attributeRecord.id);
            if( String.isNotBlank( attributeRecord.id ) ) {
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousValue), attributeRecord.previousValue);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousValue), attributeRecord.previousValue);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousCapturedBy), attributeRecord.previousCapturedBy);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousCapturedOn), attributeRecord.previousCapturedOn);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousNumberValue), attributeRecord.previousNumberValue);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousBooleanValue), attributeRecord.previousBooleanValue);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousDateValue), attributeRecord.previousDateValue);
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.PreviousDatetimeValue), attributeRecord.previousDatetimeValue);
            } else {
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.sourceRecord), attributeRecord.parentRecordId);   //parent Record Id - asset or opp.
                targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Attribute), attributeRecord.attributeId); //Lookup to Tech Attribute 
            }
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.TemplateItem), attributeRecord.templateItemId); //Lookup to Template Item 
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Source), !String.isBlank(source) ? source : DEFAULT_SOURCE );
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.CapturedBy), UserInfo.getUserId() );
            DateTime currentDateTime = Datetime.now();
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.CapturedOn), currentDateTime );
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.TimeofOccurence), currentDateTime );
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.Value), attributeRecord.value );
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.SourceRecordId), attributeRecord.sourceRecordId );
            targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.WorkorderId), attributeRecord.workorderId );
            
            switch on attributeRecord.attributeDataType.toLowerCase() {
    
                when 'number' {
                    
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.NumberValue), attributeRecord.numberValue );
                }
                when 'boolean' {
                    
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.BooleanValue), attributeRecord.booleanValue );
                }
                when 'date' {
                    
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.DateValue), attributeRecord.dateValue );
                }
                when 'datetime' {
                   
                    targetRecord.put( attributeFieldMap.get(TechAttr.AttributeField.DatetimeValue), attributeRecord.datetimeValue );
                }
            }
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'buildTargetAttributeRecord() : Failed to map target records. Error = ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'buildTargetAttributeRecord() : Failed to map target records. Error = ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildTargetAttributeRecord() - exit' );
        }
        
        return targetRecord;
    }

    private static String getReference(String fieldName, String postfix) {
        String refName = '';
        if (fieldName.endsWith('Id')) {
            refName = fieldName.replace('Id', '') + postfix;
        } else {
            refName = fieldName.replace('__c', '__r') + postfix;
        }
        return refName;
    }

    /**
     * This method is used to get details Template record.
     */
    public TechAttr.TechnicalAttributeTemplate getTechnicalAttributeTemplateDetails( String templateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateDetails() - enter; templateId = ' + templateId );

        TechAttr.TechnicalAttributeTemplate technicalAttributeTemplate = new TechAttr.TechnicalAttributeTemplate();
        
        try {
            
            // Verify request for valid Technical Attribute Template Id.
            if( templateId == null ) {
             
                System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateDetails() : Invalid request parameters. templateId= ' + templateId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__SM_TA_Template__c> templateRecords = SvmxDatabase.query( [Select Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Description__c from SVMXA360__SM_TA_Template__c Where Id =: templateId ] );

            if( templateRecords == null || templateRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' templateId = ' + templateId );
            }

            SVMXA360__SM_TA_Template__c templateRecord = templateRecords.get(0);
            templateRecords.clear();

            technicalAttributeTemplate = TA_TechnicalAttributeHelper.createTechAttrTemplate(templateRecord);
            
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateDetails() : Failed to save technicalAttributeTemplate. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateDetails() - exit; technicalAttributeTemplate= ' + technicalAttributeTemplate );
        }
        
        return technicalAttributeTemplate;
    }
    
    /**
     * This method is used to fetch all the applicable templates and attributes for a particular Asset 
     * 
     * @param assetId Asset Record Id
     * 
     * @return List<TechAttr.TechnicalAttributeCategory> Returns details of each category with attributes in them
    */
    
    public List<TechAttr.TechnicalAttributeCategory> fetchAttributesForAsset ( String assetId ) {
        
        System.debug( LoggingLevel.DEBUG, 'fetchAttributesForAsset() - enter; assetId= ' + assetId);
        
        List<TechAttr.TechnicalAttributeCategory> attributeCategoryList = new List<TechAttr.TechnicalAttributeCategory>();
        
        try {
            
            //Fetch all the applicale templates for Asset
            Set<String> templateIdSet = getMatchingTemplateIds (ASSET_OBJ, assetId); 
            
            if (templateIdSet == NULL || templateIdSet.isEmpty()) {
                return attributeCategoryList;
            }
            
            //Fetch attribute and values for each of these templates
            Map<String, SVMXA360__SM_TA_TemplateItem__c> templateItemPerAttributeMap = fetchAttributesFromTemplates (new List<String>(templateIdSet), assetId);  
        
            //Form response wrapper
            attributeCategoryList = TA_TechnicalAttributeHelper.createResponseForMatchingAttributes (templateItemPerAttributeMap, assetId);
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchAttributesForAsset() : Failed to fetch attribute for asset. Error = ' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchAttributesForAsset() - exit;  ' );
        }
        
        return attributeCategoryList;
        
    }
    
    /**
     * This method is used to query all match rules related to the object and evaluate these match rules to fetch applicable templates
     * 
     * @param objectname,recordId   example:Asset , AssetId
     * 
     * @return Set<String> Returns list of template Ids
    */
    
    private Set<String> getMatchingTemplateIds ( String objectName, String recordId) {
        
        System.debug( LoggingLevel.DEBUG, 'getMatchingTemplateIds() - enter; recordId = ' + recordId);
        Set<String> templateIdList = new Set<String>(); 
        
        try {
            
            List<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleList = queryTemplateMatchRuleForObject(objectName);
            
            if (matchRuleList != NULL && !matchRuleList.isEmpty()) {
                templateIdList = evaluateMatchRules (objectName, recordId, matchRuleList); 
            }
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getMatchingTemplateIds() : Failed to fetch templates. Error' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getMatchingTemplateIds() - exit;  ' );
        }
        
        return templateIdList;
    }
    
     
    /**
     * This method is used to query Match rules for Asset object
     * 
     * @param objectName Object API Name for which Match rules have to be retrieved
     * 
     * @return Returns List of Template Match rule records (SVMXA360__CONF_TA_TemplateMatchRule__c)
     */
    private List<SVMXA360__CONF_TA_TemplateMatchRule__c> queryTemplateMatchRuleForObject( String objectName) {
        /* sfge-disable-next-line ApexFlsViolationRule */ 
        List<SVMXA360__CONF_TA_TemplateMatchRule__c> templateMatchRuleList= SvmxDatabase.query( [ Select Id, SVMXA360__MatchRuleMaster__c, SVMXA360__ObjectApiName__c, SVMXA360__FieldApiName__c, SVMXA360__ReferenceFieldsLabel__c, SVMXA360__OperandFieldApiName__c, SVMXA360__OperandObjectApiName__c, SVMXA360__RuleType__c, SVMXA360__RuleName__c, SVMXA360__Sequence__c,SVMXA360__FieldDataType__c,
                                                                                SVMXA360__MatchRuleMaster__r.SVMXA360__Sequence__c, SVMXA360__MatchRuleMaster__r.SVMXA360__MatchRuleCriteria__c, SVMXA360__MatchRuleMaster__r.SVMXA360__RuleType__c
                                                                                from SVMXA360__CONF_TA_TemplateMatchRule__c where SVMXA360__ObjectApiName__c =: objectName AND SVMXA360__RuleType__c = 'Detail'
                                                                                AND SVMXA360__MatchRuleMaster__r.SVMXA360__Sequence__c != NULL
                                                                                Order By SVMXA360__MatchRuleMaster__r.SVMXA360__Sequence__c, SVMXA360__Sequence__c ]);
                                                                                
        System.debug( LoggingLevel.FINEST, 'queryTemplateMatchRuleForObject() - enter; Template Match rules = ' + templateMatchRuleList);                                                                        
          
        return templateMatchRuleList;
    }
    
    /**
     * This method is used to fetch all the fieldApiNames from match rule, query them, evaluate criteria on Operand Object and fetch the final list of template Ids
     * 
     * @param objectName,recordId,MatchRules 
     * 
     * @return Set<String> Returns List of Template Ids
     */
    
    private Set<String> evaluateMatchRules ( String objectName, String recordId, final List<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleList) {
        
        System.debug( LoggingLevel.DEBUG, 'evaluateMatchRules () : matchRuleList = ' + matchRuleList );
        
        Set<string> templateIdSet = new Set<string>();
        
        try {
            
            Map<String, List<TechAttr.TemplateMatchRuleDetails>> ruleDetailsPerMasterMatchRuleMap = getAllFieldsFromMatchRule (objectName, recordId, matchRuleList);  //Query all Fields configured in match rule on Object
            
            Map<String, string> masterRuleIdAndCriteriaMap = new Map<String, String>();  // Map <Master rule Id, Criteria>
            for (SVMXA360__CONF_TA_TemplateMatchRule__c eachRule: matchRuleList) {
                if ( !masterRuleIdAndCriteriaMap.containsKey(eachRule.SVMXA360__MatchRuleMaster__c) && !String.isBlank(eachRule.SVMXA360__MatchRuleMaster__r.SVMXA360__MatchRuleCriteria__c) ) {
                    masterRuleIdAndCriteriaMap.put(eachRule.SVMXA360__MatchRuleMaster__c, eachRule.SVMXA360__MatchRuleMaster__r.SVMXA360__MatchRuleCriteria__c);
                }
            }
            System.debug( LoggingLevel.DEBUG, 'evaluateMatchRules () : masterRuleIdAndCriteriaMap = ' + masterRuleIdAndCriteriaMap );
            
            templateIdSet = fetchTemplateIds (ruleDetailsPerMasterMatchRuleMap, masterRuleIdAndCriteriaMap);  //Query operand Object based on field values from Match rule
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'evaluateMatchRules() : Failed to fetch templates. Error' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'evaluateMatchRules() - exit;  ' );
        }
        
        return templateIdSet;
    }
    
    private Map<String, List<TechAttr.TemplateMatchRuleDetails>> getAllFieldsFromMatchRule (String objectName, String recordId, List<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleList) {
        
        System.debug( LoggingLevel.ERROR, 'getAllFieldsFromMatchRule() : Enter - recordId = ' + recordId );
        
        CONF_ObjectMappingHandler objMapHandler = new CONF_ObjectMappingHandler();
        
        Map<String, List<TechAttr.TemplateMatchRuleDetails>> ruleDetailsPerMasterMatchRuleMap = new Map<String, List<TechAttr.TemplateMatchRuleDetails>>();
        
        try {
            
            Set<String> allFieldsToQuery = new Set<String>();
            
            for (SVMXA360__CONF_TA_TemplateMatchRule__c eachRule: matchRuleList) {
                
                if (eachRule.SVMXA360__RuleType__c.equals('Detail') && !String.isBlank(eachRule.SVMXA360__FieldApiName__c) ) {
                    
                    TechAttr.TemplateMatchRuleDetails ruleDetail = new TechAttr.TemplateMatchRuleDetails();
                    ruleDetail.id = eachRule.Id;
                    ruleDetail.fieldApiName =  eachRule.SVMXA360__FieldApiName__c;
                    ruleDetail.objectApiName = eachRule.SVMXA360__ObjectApiName__c;
                    ruleDetail.referenceFieldApiNames = getReferenceFieldsToQuery(eachRule.SVMXA360__FieldApiName__c);
                    ruleDetail.masterRuleid = eachRule.SVMXA360__MatchRuleMaster__c;
                    ruleDetail.operandObject = eachRule.SVMXA360__OperandObjectApiName__c;
                    ruleDetail.fieldType = eachRule.SVMXA360__FieldDataType__c;
                    
                    if (!ruleDetailsPerMasterMatchRuleMap.containsKey(eachRule.SVMXA360__MatchRuleMaster__c)) {
                        ruleDetailsPerMasterMatchRuleMap.put(eachRule.SVMXA360__MatchRuleMaster__c, new List<TechAttr.TemplateMatchRuleDetails>());
                    }
                    ruleDetailsPerMasterMatchRuleMap.get(eachRule.SVMXA360__MatchRuleMaster__c).add(ruleDetail);
                    
                    allFieldsToQuery.add(ruleDetail.fieldApiName);
                    allFieldsToQuery.addAll(ruleDetail.referenceFieldApiNames);
                }
            }
            
             //Query fields from the record
             List<SObject> recordList = queryFieldValues (objectName, recordId, allFieldsToQuery) ;  
        
            if (recordList != NULL && recordList[0] != NULL ) {
                
                for (String masterRecordId: ruleDetailsPerMasterMatchRuleMap.keySet() ) {
                    for (TechAttr.TemplateMatchRuleDetails eachRule: ruleDetailsPerMasterMatchRuleMap.get(masterRecordId) ) {
                        
                        Boolean referenceExists = true;
                        if (!eachRule.referenceFieldApiNames.isEmpty()) {  //It's a lookup field
                            
                            for (String referenceField: eachRule.referenceFieldApiNames) {
                                if ( recordList[0].get(referenceField) == NULL) {
                                    referenceExists = false;
                                    break; //reference field is empty/null - value cannot be retrieved
                                }
                            }
                        } 
                        
                        if (referenceExists) {  //Only if reference/lookup field has a value, retrieve that field from record
                            eachRule.value = objMapHandler.getValueOfMultiReference (recordList[0],eachRule.fieldApiName );
                        }
                    }
                    
                }
                
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllFieldsFromMatchRule() : Failed to fetch values for fields in Match rule. Error' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllFieldsFromMatchRule() - exit; ruleDetailsPerMasterMatchRuleMap: ' + ruleDetailsPerMasterMatchRuleMap);
        }
        
        return ruleDetailsPerMasterMatchRuleMap;
            
    }
    
    //Fetching all there reference fields for fieldApiName configured in match rule
    private List<String> getReferenceFieldsToQuery (String fieldNameFromRule) {
        
        List<String> referenceFieldsToQuery = new List<String>();
        List<String> referenceObjects = fieldNameFromRule.split('\\.');
        
        if( referenceObjects.size() == 1 ) {   //only one level
            return referenceFieldsToQuery;
        }
        else if (referenceObjects.size() > 0) {  //There are lookup fields to query
            
            String fieldApiName = referenceObjects[ referenceObjects.size() - 1 ];
            String referenceField = '';
            String objectName = '';
            
            for (integer i = 0; i< referenceObjects.size() - 1 ; i++ ) {
                if ( fieldAPIName != referenceObjects[i] ) {
                    if ( referenceObjects[i].endsWith('__r') ) {
                        objectName = referenceObjects[i].replace('__r', '__c');
                    
                    }else {
                        objectName = referenceObjects[i] + 'Id';
                    }
                    referenceFieldsToQuery.add(referenceField + objectName);
                    referenceField = referenceField + referenceObjects[i] + '.';
                }
            }
        } 
        
        return referenceFieldsToQuery;
	}
    
    /**
     * Method to query fields on any object
     * @param : objectName,recordId and list of field Names
     */
    private List<SObject> queryFieldValues (String objectName, String recordId, Set<String> fieldApiNameSet) {
        
        System.debug( LoggingLevel.ERROR, 'queryFieldValues() : Enter - recordId = ' + recordId );
        
        List<SObject> recordList;
        
        try {
            String strQuery = 'SELECT ' + String.join(new List<String>(fieldApiNameSet), ',') + ' FROM '+ objectName + '  WHERE ID =: recordId';
            
            System.debug(LoggingLevel.DEBUG, 'queryFieldValues() : Query is :'+strQuery);
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            recordList = SvmxDatabase.query(Database.Query( strQuery));
        
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'queryFieldValues() : Failed to query object. Error' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'queryFieldValues() - exit; recordList: ' + recordList);
        }
        
       return recordList;
        
    }
    
    //method to replace values on criterias defined in match rules
    private String replaceCriteriaWithValue (String criteria, List<TechAttr.TemplateMatchRuleDetails> ruleDetails) {
        
        String queryCriteria = criteria;
        COMM_ExpressionUtils expUtils = COMM_ExpressionUtils.getInstance();
        
        try{
            
            for (TechAttr.TemplateMatchRuleDetails eachRule: ruleDetails) {
                
                String fieldName = eachRule.objectApiName + '.'+ eachRule.fieldApiName;
                
                if (eachRule.value != NULL ){
                    
                    switch on eachRule.fieldType.toUpperCase() {
                        
                        when 'STRING', 'REFERENCE', 'EMAIL', 'PICKLIST','MULTIPICKLIST', 'TEXTAREA', 'PHONE', 'URL' {
                            
                            queryCriteria = queryCriteria.replace(fieldName, '\''+ eachRule.value + '\'');  //replacing with value in quotes for string and other data types
                            
                        }
                        when 'INTEGER', 'DOUBLE', 'CURRENCY', 'PERCENT', 'BOOLEAN'{
                            
                            queryCriteria = queryCriteria.replace(fieldName,  String.valueOf(eachRule.value) );  
                        }
                        when 'TIME' {
                            
                            queryCriteria = queryCriteria.replace(fieldName,  String.valueOf(eachRule.value) + 'Z');  
                            
                        }
                        when 'DATE' {
                            
                            queryCriteria = queryCriteria.replace(fieldName,  String.valueOf(expUtils.getFormattedDateValue(String.valueOf(eachRule.value))) ) ; 
                            
                        }
                        when 'DATETIME' {
                        
                            queryCriteria = queryCriteria.replace(fieldName,  expUtils.getFormattedDateTimeValue(String.valueOf(eachRule.value)) ); 
                            
                        }
                        
                    }
                    
                }else {
                    
                    queryCriteria = queryCriteria.replace(fieldName, 'NULL' );  //Value not found on parent record, set it to NUll
                }
                
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'replaceCriteriaWithValue() : Failed to replace query criteria. Error = ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'replaceCriteriaWithValue() - exit; Query Criteria queryCriteria =  ' + queryCriteria);
        }
        return queryCriteria;
    }
    
    /**
     * This method is used to run query on the Operand Object from Match rule to fetch associatedTemplates
     * 
     * @param objectName,recordId,MatchRules 
     * 
     * @return Set<String> Returns List of Template Ids
     */
    
    private set<string> fetchTemplateIds ( Map<String, List<TechAttr.TemplateMatchRuleDetails>> ruleDetailsPerMasterMatchRuleMap, Map<String, string> masterRuleIdAndCriteriaMap){
        
        System.debug(LoggingLevel.DEBUG, ' fetchTemplateIds() : masterRuleIdAndCriteriaMap: '+ masterRuleIdAndCriteriaMap);
        Set<String> templateIdSet = new Set<String>();
        
        try {
            
            Boolean templateFound = false;
            for (String masterRuleId: ruleDetailsPerMasterMatchRuleMap.keySet()) {  
                
                String criteria = replaceCriteriaWithValue( masterRuleIdAndCriteriaMap.get(masterRuleId), ruleDetailsPerMasterMatchRuleMap.get(masterRuleId));
            
                if (criteria != ''){
                    
                    //For 7.0 Release, we are limiting it to TemplateAssociation Object
                    String queryStr = 'Select Id, SVMXA360__TemplateId__c from SVMXA360__SM_TA_TemplateAssociation__c Where ';
                    queryStr += ' ( ' + criteria + ' ) ';
                    queryStr += 'Order By LastModifiedDate ';
                    
                    System.debug(LoggingLevel.DEBUG, ' fetchTemplateIds(): Template Association query: '+ queryStr);
                    /* sfge-disable-next-line ApexFlsViolationRule */
                    List<SVMXA360__SM_TA_TemplateAssociation__c> templateAssociationList = SvmxDatabase.query(queryStr);
                    
                    for (SVMXA360__SM_TA_TemplateAssociation__c eachTA: templateAssociationList) {
                        if (eachTA.SVMXA360__TemplateId__c != NULL) {
                            templateIdSet.add(eachTA.SVMXA360__TemplateId__c);
                            templateFound = true;
                        }
                    }
                    if (templateFound) { //Once template is found, match rules aren't evaluated anymore
                        break;
                    }
                    
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchTemplateIds() : Failed to query Template association. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchTemplateIds() - exit; Templates found templateIdSet =  ' + templateIdSet);
        }
        
        return templateIdSet;
        
    }
    
    /**
     * Method to fetch attribute and value details from template Items based on template Ids provided in request
     * Returns Map< AttributeId, template Item>
     */
    private Map<String, SVMXA360__SM_TA_TemplateItem__c> fetchAttributesFromTemplates ( List<String> templateIdList, String recordId ){
        
        System.debug(LoggingLevel.DEBUG, ' fetchAttributesFromTemplates() : templateIdList: '+ templateIdList);
        
        Map<String, SVMXA360__SM_TA_TemplateItem__c> templateItemPerAttributeMap;
        
        try {
            
            //Based on setting - fetch all templates or first matching template
            Boolean matchAllTemplates = false;
            Adm.ApplicationSetting techAttributeSetting = ADM_ApplicationSettingsManager.getInstance().getApplicationSetting(ADM_ApplicationSettingsManager.technicalAttributeSettingName);
            if (techAttributeSetting != NUll && techAttributeSetting.settingValue == 'All') {
                matchAllTemplates = true;
            }
            
            if (!matchAllTemplates) {
                templateIdList = new List<string>{templateIdList[0]} ;//Consider the first matching template
            }  
            
            templateItemPerAttributeMap = removeDuplicateAttributes( queryTemplateDetails(templateIdList) ); //Query template items and remove duplicate attributes
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'fetchAttributesFromTemplates() : Failed to query Template items. Error' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchAttributesFromTemplates() - exit; Templates Items found =  ' + templateItemPerAttributeMap);
        }
        
        return templateItemPerAttributeMap;
    }
    
    //method to remove duplicate attributes in the list of template items
    private Map<String, SVMXA360__SM_TA_TemplateItem__c> removeDuplicateAttributes (List<SVMXA360__SM_TA_TemplateItem__c> templateItemsList) {
        
        Map<String, SVMXA360__SM_TA_TemplateItem__c> templateItemPerAttributeMap = new Map<String, SVMXA360__SM_TA_TemplateItem__c>();
        
        for (SVMXA360__SM_TA_TemplateItem__c eachItem: templateItemsList) {
            if(!templateItemPerAttributeMap.containsKey(eachItem.SVMXA360__AttributeId__c)){
                templateItemPerAttributeMap.put(eachItem.SVMXA360__AttributeId__c, eachItem);
            }
        }
        /* sfge-disable-next-line ApexFlsViolationRule */
        List<SVMXA360__ApplicationSetting__c> applicationSettings = SvmxDatabase.query([Select Id, SVMXA360__SettingValue__c from SVMXA360__ApplicationSetting__c where SVMXA360__DeveloperName__c = 'User_Group']);

        if ( applicationSettings != null && !applicationSettings.isEmpty() && applicationSettings[0].SVMXA360__SettingValue__c == 'true' ) {

            Set<String> userGroupIds = fetchUserGroups();
            Map<String, SVMXA360__SM_TA_TemplateItem__c> templateItemFilteredAttributeMap = new Map<String, SVMXA360__SM_TA_TemplateItem__c>();
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_UserGroupTechnicalAttribute__c> userGroupAttributes = SvmxDatabase.query([Select SVMXA360__TechnicalAttributeId__c from SVMXA360__CONF_UserGroupTechnicalAttribute__c where SVMXA360__UserGroupId__c IN: userGroupIds and SVMXA360__TechnicalAttributeId__c IN: templateItemPerAttributeMap.keySet()]);

            if ( !userGroupAttributes.isEmpty() ) {

                for ( SVMXA360__CONF_UserGroupTechnicalAttribute__c userGroupAttribute: userGroupAttributes ) {
                    if(!templateItemFilteredAttributeMap.containsKey(userGroupAttribute.SVMXA360__TechnicalAttributeId__c)){
                        templateItemFilteredAttributeMap.put(userGroupAttribute.SVMXA360__TechnicalAttributeId__c, templateItemPerAttributeMap.get(userGroupAttribute.SVMXA360__TechnicalAttributeId__c));
                    }
                }

            }
            return templateItemFilteredAttributeMap;
        }
        
        return templateItemPerAttributeMap;
    }
    
    //Queries Template Items based on template ids provided
    private  List<SVMXA360__SM_TA_TemplateItem__c> queryTemplateDetails (List<String> templateIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'queryTemplateDetails() : templateIdList = ' + templateIdList );
        List<SVMXA360__SM_TA_TemplateItem__c> templateItemsList;
        
        try{
            
            TemplateItemFields.add('SVMXA360__TemplateId__r.Name');
            TemplateItemFields.add('SVMXA360__TemplateId__r.SVMXA360__Status__c');
            TemplateItemFields.add('SVMXA360__TemplateId__r.SVMXA360__CategorySequenceJSON__c');
            TemplateItemFields.add('SVMXA360__CategoryId__r.Name');
            TemplateItemFields.add('SVMXA360__CategoryId__r.SVMXA360__DeveloperName__c');
            TemplateItemFields.add('SVMXA360__CategoryId__r.SVMXA360__Description__c');
            TemplateItemFields.addAll(attributeFieldsFromTemplateItem);
            
            String templateItemQuery = 'Select ' + String.join( TemplateItemFields, ',') +' from SVMXA360__SM_TA_TemplateItem__c where SVMXA360__TemplateId__c IN: templateIdList AND SVMXA360__TemplateId__r.SVMXA360__Status__c = \'Active\' ORDER BY SVMXA360__Sequence__c';
            
            System.debug( LoggingLevel.FINE, 'queryTemplateDetails() : templateItemQuery = ' + templateItemQuery );
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            templateItemsList = SvmxDatabase.query( Database.Query( templateItemQuery ) );   //Fetch template Items for Active Templates
                    
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'queryTemplateDetails() : Failed to query Template items. Error' + e.getStackTraceString() );
            throw e;
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'queryTemplateDetails() - exit; Templates Items found =  ' + templateItemsList);
        }
        
        return templateItemsList;                                                        
    } 

    //Fetch the User groups to which the current logged in user has access.
    private Set<String> fetchUserGroups () {
        
        Set<String> userGroupIds = new Set<String>();
        String userId = UserInfo.getUserId();
        /* sfge-disable-next-line ApexFlsViolationRule */
        List<SVMXA360__CONF_UserGroupMember__c> userGroupMembers = SvmxDatabase.query( [Select SVMXA360__UserGroupId__c from SVMXA360__CONF_UserGroupMember__c Where SVMXA360__UserId__c =: userId AND SVMXA360__UserGroupId__r.SVMXA360__Active__c = true ] );
        
        if ( !userGroupMembers.isEmpty() ) {
            for (SVMXA360__CONF_UserGroupMember__c groupMember: userGroupMembers ) {
                userGroupIds.add(groupMember.SVMXA360__UserGroupId__c);
            }
        }
        return userGroupIds;
    }


    /**
    * This method is used to retrieve all the Technical Attributes configured.
    */
    public List<TechAttr.UserGroup> getAllUserGroups(String attributeId, String searchTerm) {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttributeManager-getAllUserGroups() - enter - attributeId='+attributeId );

        List<TechAttr.UserGroup> userGroups = new List<TechAttr.UserGroup>();
        Map<Id,SVMXA360__CONF_UserGroupTechnicalAttribute__c> mapUserGroupTA = new Map<Id,SVMXA360__CONF_UserGroupTechnicalAttribute__c>();
        
        try {
            if( String.isBlank(attributeId) ) {                
                System.debug( LoggingLevel.ERROR, 'getAllUserGroups() : Invalid arguments. attributeId = ' + attributeId);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            String recQueryStr = 'SELECT Id,Name,SVMXA360__DeveloperName__c,SVMXA360__Description__c,SVMXA360__Active__c,LastModifiedDate,LastModifiedBy.Name FROM SVMXA360__CONF_UserGroup__c';
            
            if(String.isNotBlank(searchTerm) ){
                String searchKey =  '%'+String.escapeSingleQuotes(searchTerm)+'%';
                recQueryStr += ' WHERE Name Like \''+searchKey+'\'';   
            }
            //default usergroup limit is 1000 
            recQueryStr += ' LIMIT 1000';  

            System.debug(LoggingLevel.INFO, 'getAllUserGroups() : recQueryStr= :'+recQueryStr);

            mapUserGroupTA = TA_TechnicalAttributeHelper.getExistingUserGroups( new Set<String>{attributeId} );
            /* sfge-disable-next-line ApexFlsViolationRule */
            for (SVMXA360__CONF_UserGroup__c eachUserGroup :  (List<SVMXA360__CONF_UserGroup__c>) SvmxDatabase.query(recQueryStr)) {  

                if ( !mapUserGroupTA.containsKey(eachUserGroup.Id)) {
                    userGroups.add(TA_TechnicalAttributeHelper.createUserGroup(eachUserGroup));
                }
            }
            System.debug(LoggingLevel.INFO, 'getAllUserGroups() :userGroups = :'+userGroups);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllUserGroups() : Failed to retrieve user groups. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllUserGroups() : Failed to retrieve user groups. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllUserGroups() - exit; userGroups.size()= ' + userGroups.size() );
        }
        
        return userGroups;
    }
    
    /**
     * This method is used to save list of User Group Technical Attribute records.
     */
    public List<TechAttr.UserGroupTechnicalAttribute> saveUserGroupTechnicalAttribute( List<TechAttr.UserGroupTechnicalAttribute> taUserGroups ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveUserGroupTechnicalAttribute() - enter; taUserGroups='+taUserGroups );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Technical Attribute Association information.
            if( taUserGroups == null || taUserGroups.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' taUserGroups = ' + taUserGroups );
            }

            List<SVMXA360__CONF_UserGroupTechnicalAttribute__c> userGroupAttributeRecords = new List<SVMXA360__CONF_UserGroupTechnicalAttribute__c>();
           
            for ( TechAttr.UserGroupTechnicalAttribute eachUserGroupTA : taUserGroups ) {
                userGroupAttributeRecords.add( TA_TechnicalAttributeHelper.buildUserGroupTARecord( eachUserGroupTA ) );
            }

            userGroupAttributeRecords = (List<SVMXA360__CONF_UserGroupTechnicalAttribute__c>) SvmxDatabase.upsertRecord(userGroupAttributeRecords);

            System.debug( LoggingLevel.INFO, 'saveUserGroupTechnicalAttribute() : Saved userGroupAttributeRecords = ' + userGroupAttributeRecords );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveUserGroupTechnicalAttribute() : Failed to save User Group Technical Attribute records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveUserGroupTechnicalAttribute() : Failed to save User Group Technical Attribute records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveUserGroupTechnicalAttribute() - exit; ' );
        }
        
        return taUserGroups;
    }
}