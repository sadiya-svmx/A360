/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This handler class contains utility methods for technical attributes create and update.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       5 Sept 2022     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class TA_TechnicalAttributeHelper {

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

    //Method to create TechAttr.TechnicalAttribute wrapper for Attributes from template item
    public static TechAttr.TechnicalAttribute buildAttributeFromTemplateItem (SVMXA360__SM_TA_TemplateItem__c templateItem) {
        
        System.debug( LoggingLevel.FINE, 'buildAttributeFromTemplateItem() - enter; templateItem = ' + templateItem);
        
        TechAttr.TechnicalAttribute technicalAttribute = new TechAttr.TechnicalAttribute();
        technicalAttribute.id = templateItem.SVMXA360__AttributeId__c;
        technicalAttribute.name = templateItem.SVMXA360__AttributeId__r.Name;
        technicalAttribute.dataType = templateItem.SVMXA360__AttributeId__r.SVMXA360__DataType__c;
        technicalAttribute.developerName = templateItem.SVMXA360__AttributeId__r.SVMXA360__DeveloperName__c;
        technicalAttribute.defaultValue = templateItem.SVMXA360__AttributeId__r.SVMXA360__DefaultValue__c;
        technicalAttribute.unit = templateItem.SVMXA360__AttributeId__r.SVMXA360__Unit__c;
        technicalAttribute.maximumValue = templateItem.SVMXA360__AttributeId__r.SVMXA360__MaximumValue__c;
        technicalAttribute.minimumValue = templateItem.SVMXA360__AttributeId__r.SVMXA360__MinimumValue__c;
        technicalAttribute.isReadonly = (templateItem.SVMXA360__AttributeId__r.SVMXA360__IsReadonly__c != NULL)? templateItem.SVMXA360__AttributeId__r.SVMXA360__IsReadonly__c: false;
        technicalAttribute.isRequired = (templateItem.SVMXA360__AttributeId__r.SVMXA360__IsRequired__c != NULL)? templateItem.SVMXA360__AttributeId__r.SVMXA360__IsRequired__c: false;
        technicalAttribute.message = templateItem.SVMXA360__AttributeId__r.SVMXA360__Message__c;
        technicalAttribute.helptext = templateItem.SVMXA360__AttributeId__r.SVMXA360__HelpText__c;
        technicalAttribute.description = templateItem.SVMXA360__AttributeId__r.SVMXA360__Description__c;
        
        if (technicalAttribute.DataType.equalsIgnoreCase('Picklist')) {
            Config.PicklistDefinition picklistDef = new Config.PicklistDefinition();
            picklistDef.id = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__c;
            picklistDef.name = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.Name;
            picklistDef.description = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Description__c;
            picklistDef.developerName = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__DeveloperName__c;
            picklistDef.type = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Type__c;
            picklistDef.values = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Values__c;
            picklistDef.defaultValue = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__DefaultValue__c;
            technicalAttribute.picklistDefinition = picklistDef;
        }   
            
        System.debug( LoggingLevel.FINE, 'buildAttributeFromTemplateItem() - exit; technicalAttribute = ' + technicalAttribute);
        
        return technicalAttribute;
    }

    //Method to create TechAttr.AttributeRecord wrapper for Asset
    public static TechAttr.AttributeRecord buildAttributeRecordForAsset (SVMXA360__SM_TA_AssetTechnicalAttribute__c assetAttributeRecord) {
        
        System.debug( LoggingLevel.FINE, 'buildAttributeRecordForAsset() - enter; assetAttributeRecord = ' + assetAttributeRecord);
        
        TechAttr.AttributeRecord attributeRecord = new TechAttr.AttributeRecord();
        attributeRecord.id = assetAttributeRecord.Id;
        attributeRecord.parentRecordId = assetAttributeRecord.SVMXA360__AssetId__c;
        attributeRecord.templateItemId = assetAttributeRecord.SVMXA360__TemplateItemId__c;
        attributeRecord.attributeId = assetAttributeRecord.SVMXA360__AttributeId__c;
        attributeRecord.attributeDataType = assetAttributeRecord.SVMXA360__AttributeId__r.SVMXA360__DataType__c;
        attributeRecord.value = assetAttributeRecord.SVMXA360__Value__c;
        attributeRecord.previousValue = assetAttributeRecord.SVMXA360__PreviousValue__c;
        attributeRecord.source = assetAttributeRecord.SVMXA360__Source__c;
        attributeRecord.capturedOn = assetAttributeRecord.SVMXA360__CapturedOn__c;
        attributeRecord.capturedBy = assetAttributeRecord.SVMXA360__CapturedBy__c;
        attributeRecord.previousCapturedOn = assetAttributeRecord.SVMXA360__PreviousCapturedOn__c;
        attributeRecord.previousCapturedBy = assetAttributeRecord.SVMXA360__PreviousCapturedBy__c;
        attributeRecord.booleanValue = ( assetAttributeRecord.SVMXA360__BooleanValue__c != NULL)? assetAttributeRecord.SVMXA360__BooleanValue__c: false;
        attributeRecord.previousBooleanValue = assetAttributeRecord.SVMXA360__PreviousBooleanValue__c;
        attributeRecord.numberValue = assetAttributeRecord.SVMXA360__NumberValue__c;
        attributeRecord.previousNumberValue = assetAttributeRecord.SVMXA360__PreviousNumberValue__c;
        attributeRecord.dateValue = assetAttributeRecord.SVMXA360__DateValue__c;
        attributeRecord.previousDateValue = assetAttributeRecord.SVMXA360__PreviousDateValue__c;
        attributeRecord.datetimeValue = assetAttributeRecord.SVMXA360__DatetimeValue__c;
        attributeRecord.previousDatetimeValue = assetAttributeRecord.SVMXA360__PreviousDatetimeValue__c;
        
        System.debug( LoggingLevel.FINE, 'buildAttributeRecordForAsset() - exit; attributeRecord = ' + attributeRecord);
        
        return attributeRecord;
    }

    public static TechAttr.TechnicalAttributeTemplateItem buildTemplateItem( SVMXA360__SM_TA_TemplateItem__c techAttrTemplateItemRecord ) {

        System.debug( LoggingLevel.FINEST, 'buildTemplateItem() - enter; techAttrTemplateItemRecord = ' + techAttrTemplateItemRecord);
        
        TechAttr.TechnicalAttributeTemplateItem techAttrTemplateItem = new TechAttr.TechnicalAttributeTemplateItem();

        techAttrTemplateItem.id = techAttrTemplateItemRecord.Id;
        techAttrTemplateItem.developerName = techAttrTemplateItemRecord.SVMXA360__DeveloperName__c;
        techAttrTemplateItem.categoryId = techAttrTemplateItemRecord.SVMXA360__CategoryId__c;
        techAttrTemplateItem.attributeId = techAttrTemplateItemRecord.SVMXA360__AttributeId__c;
        techAttrTemplateItem.attributeName = techAttrTemplateItemRecord.SVMXA360__AttributeId__r.Name;
        techAttrTemplateItem.defaultValue = techAttrTemplateItemRecord.SVMXA360__DefaultValue__c;
        techAttrTemplateItem.helptext = techAttrTemplateItemRecord.SVMXA360__HelpText__c;
        techAttrTemplateItem.isReadonly = (techAttrTemplateItemRecord.SVMXA360__IsReadonly__c != NULL)? techAttrTemplateItemRecord.SVMXA360__IsReadonly__c: false;
        techAttrTemplateItem.isRequired = (techAttrTemplateItemRecord.SVMXA360__IsRequired__c != NULL)? techAttrTemplateItemRecord.SVMXA360__IsRequired__c: false;
        techAttrTemplateItem.maximumValue = techAttrTemplateItemRecord.SVMXA360__MaximumValue__c;
        techAttrTemplateItem.minimumValue = techAttrTemplateItemRecord.SVMXA360__MinimumValue__c;
        techAttrTemplateItem.status = techAttrTemplateItemRecord.SVMXA360__Status__c;
        techAttrTemplateItem.templateId = techAttrTemplateItemRecord.SVMXA360__TemplateId__c;
        techAttrTemplateItem.dataType = techAttrTemplateItemRecord.SVMXA360__AttributeId__r.SVMXA360__DataType__c;
        techAttrTemplateItem.message = techAttrTemplateItemRecord.SVMXA360__Message__c;
        techAttrTemplateItem.sequence = techAttrTemplateItemRecord.SVMXA360__Sequence__c!= null ? Integer.ValueOf(techAttrTemplateItemRecord.SVMXA360__Sequence__c) : 1000;
        
        System.debug( LoggingLevel.FINEST, 'buildTemplateItem() - exit; techAttrTemplateItem = ' + techAttrTemplateItem);
        
        return techAttrTemplateItem;
    }

    public static void populateCloneTemplateItemRecords ( List<SVMXA360__SM_TA_TemplateItem__c> itemRecords, String templateId ) {

        try {

            List<SVMXA360__SM_TA_TemplateItem__c> cloneItemRecords = new List<SVMXA360__SM_TA_TemplateItem__c>();

            for ( SVMXA360__SM_TA_TemplateItem__c itemRec : itemRecords ) {

                SVMXA360__SM_TA_TemplateItem__c cloneItemRec = new SVMXA360__SM_TA_TemplateItem__c();
                cloneItemRec.SVMXA360__CategoryId__c = itemRec.SVMXA360__CategoryId__c;
                cloneItemRec.SVMXA360__AttributeId__c = itemRec.SVMXA360__AttributeId__c;
                cloneItemRec.SVMXA360__DefaultValue__c = itemRec.SVMXA360__DefaultValue__c;
                cloneItemRec.SVMXA360__HelpText__c = itemRec.SVMXA360__HelpText__c;
                cloneItemRec.SVMXA360__Message__c = itemRec.SVMXA360__Message__c;
                cloneItemRec.SVMXA360__Status__c = 'Inactive';
                cloneItemRec.SVMXA360__TemplateId__c = templateId;
                cloneItemRec.SVMXA360__IsReadonly__c = itemRec.SVMXA360__IsReadonly__c;
                cloneItemRec.SVMXA360__IsRequired__c = itemRec.SVMXA360__IsRequired__c;
                cloneItemRec.SVMXA360__MaximumValue__c = itemRec.SVMXA360__MaximumValue__c;
                cloneItemRec.SVMXA360__MinimumValue__c = itemRec.SVMXA360__MinimumValue__c;
                cloneItemRec.SVMXA360__DeveloperName__c = (String)itemRec.SVMXA360__DeveloperName__c.left(72) + '_' + string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,8);
                cloneItemRecords.add(cloneItemRec);
            }

            if ( !cloneItemRecords.isEmpty() ) {
                Svmxdatabase.insertRecord(cloneItemRecords);
            }

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'populateCloneTemplateRecords() : Failed to clone template item records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'populateCloneTemplateRecords() - exit;' );
        }
    }

    public static SVMXA360__SM_TA_Template__c populateCloneTemplateRecord ( SVMXA360__SM_TA_Template__c  templateRecord ) {

        SVMXA360__SM_TA_Template__c cloneTemplateRecord = new SVMXA360__SM_TA_Template__c();

        try {

            cloneTemplateRecord.Name = 'CopyOf_'+templateRecord.Name;
            cloneTemplateRecord.SVMXA360__Description__c = templateRecord.SVMXA360__Description__c;
            cloneTemplateRecord.SVMXA360__DeveloperName__c = (String)templateRecord.SVMXA360__DeveloperName__c.left(72) + '_' + string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,8);
            cloneTemplateRecord.SVMXA360__CategorySequenceJSON__c = templateRecord.SVMXA360__CategorySequenceJSON__c;

            cloneTemplateRecord = (SVMXA360__SM_TA_Template__c) SvmxDatabase.insertRecord(cloneTemplateRecord);

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'populateCloneTemplateRecords() : Failed to clone template item records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'populateCloneTemplateRecords() - exit;' );
        }

        return cloneTemplateRecord;
    }

    /**
     * This method is used to create TechnicalAttribute wrapper for requested TechnicalAttribute record.
     * 
     * @param technicalAttributeRecord Technical Attribute sobject record from which wrapper to be created.
     * 
     * @return Returns TechAttr.TechnicalAttribute instance with populated values from technicalAttributeRecord.
     */
    public static TechAttr.TechnicalAttribute createTechnicalAttribute( final SVMXA360__SM_TA_TechnicalAttribute__c technicalAttributeRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createTechnicalAttribute() - enter; technicalAttributeRecord= ' + technicalAttributeRecord);
        
        TechAttr.TechnicalAttribute technicalAttribute = new TechAttr.TechnicalAttribute();

        technicalAttribute.id = technicalAttributeRecord.id;
        technicalAttribute.name = technicalAttributeRecord.Name;
        technicalAttribute.dataType = technicalAttributeRecord.SVMXA360__DataType__c;
        technicalAttribute.developerName = technicalAttributeRecord.SVMXA360__DeveloperName__c;
        technicalAttribute.defaultValue = technicalAttributeRecord.SVMXA360__DefaultValue__c;
        technicalAttribute.unit = technicalAttributeRecord.SVMXA360__Unit__c;
        technicalAttribute.maximumValue = technicalAttributeRecord.SVMXA360__MaximumValue__c;
        technicalAttribute.minimumValue = technicalAttributeRecord.SVMXA360__MinimumValue__c;
        technicalAttribute.isReadonly = ( technicalAttributeRecord.SVMXA360__IsReadonly__c != null )? technicalAttributeRecord.SVMXA360__IsReadonly__c : false;
        technicalAttribute.isRequired = ( technicalAttributeRecord.SVMXA360__IsRequired__c != null ) ? technicalAttributeRecord.SVMXA360__IsRequired__c : false;
        technicalAttribute.message = technicalAttributeRecord.SVMXA360__Message__c;
        technicalAttribute.helptext = technicalAttributeRecord.SVMXA360__HelpText__c;
        technicalAttribute.description = technicalAttributeRecord.SVMXA360__Description__c;        
        if (technicalAttributeRecord.SVMXA360__DataType__c.equalsIgnoreCase('Picklist') && technicalAttributeRecord.SVMXA360__PicklistDefinitionId__c != null) {
            Config.PicklistDefinition picklistDefinition = new Config.PicklistDefinition();
            picklistDefinition.id = technicalAttributeRecord.SVMXA360__PicklistDefinitionId__c;
            technicalAttribute.picklistDefinition = picklistDefinition;
        } 
        technicalAttribute.lastModifiedDate = technicalAttributeRecord.LastModifiedDate;
        technicalAttribute.lastModifiedBy = technicalAttributeRecord.LastModifiedBy.Name;
        
        System.debug( LoggingLevel.FINEST, 'createTechnicalAttribute() - exit; technicalAttribute= ' + technicalAttribute);
        
        return technicalAttribute;
    }

    /**
     * Private method to create TechnicalAttribute record.
     * 
     * @param technicalAttribute TechnicalAttribute wrapper for which SObject to be created.
     * @return Returns TechnicalAttribute sobject with populated values from TechnicalAttribute.
     */
    public static SVMXA360__SM_TA_TechnicalAttribute__c createTechnicalAttributeRecord( final TechAttr.TechnicalAttribute technicalAttribute ) {
        
        System.debug( LoggingLevel.FINEST, 'createTechnicalAttributeRecord() - enter; technicalAttribute= ' + technicalAttribute);
        
        SVMXA360__SM_TA_TechnicalAttribute__c technicalAttributeRecord = new SVMXA360__SM_TA_TechnicalAttribute__c();

        if( technicalAttribute.name == null || String.isBlank( technicalAttribute.dataType ) ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        if( String.isNotBlank( technicalAttribute.id ) ) {
            technicalAttributeRecord.Id = technicalAttribute.id;
        } else {
            technicalAttributeRecord.SVMXA360__DeveloperName__c = technicalAttribute.developerName;
        }
        
        technicalAttributeRecord.Name = technicalAttribute.name;
        technicalAttributeRecord.SVMXA360__DataType__c = technicalAttribute.dataType;
        technicalAttributeRecord.SVMXA360__DefaultValue__c = technicalAttribute.defaultValue;
        technicalAttributeRecord.SVMXA360__Unit__c = technicalAttribute.unit;
        technicalAttributeRecord.SVMXA360__MaximumValue__c = technicalAttribute.maximumValue;
        technicalAttributeRecord.SVMXA360__MinimumValue__c = technicalAttribute.minimumValue;
        technicalAttributeRecord.SVMXA360__IsReadonly__c = technicalAttribute.isReadonly != null ? technicalAttribute.isReadonly : false;
        technicalAttributeRecord.SVMXA360__IsRequired__c = technicalAttribute.isRequired != null ? technicalAttribute.isRequired : false;
        technicalAttributeRecord.SVMXA360__Message__c = technicalAttribute.message;
        technicalAttributeRecord.SVMXA360__HelpText__c = technicalAttribute.helptext;
        technicalAttributeRecord.SVMXA360__Description__c = technicalAttribute.description;

        System.debug( LoggingLevel.FINEST, 'createTechnicalAttributeRecord() - exit; technicalAttributeRecord= ' + technicalAttributeRecord);
        
        return technicalAttributeRecord;
    }

    public static  void populateTempAssociationsRecords(  List<SVMXA360__SM_TA_TemplateAssociation__c> tempAssociations, String templateId ) {
        
        try {

            List<SVMXA360__SM_TA_TemplateAssociation__c> clonedAssociationList = new List<SVMXA360__SM_TA_TemplateAssociation__c>();
            
            for (SVMXA360__SM_TA_TemplateAssociation__c associationRecord : tempAssociations ) {
                associationRecord.Id = null;
                SVMXA360__SM_TA_TemplateAssociation__c cloneRecord = new SVMXA360__SM_TA_TemplateAssociation__c();
                cloneRecord = associationRecord;
                cloneRecord.SVMXA360__TemplateId__c = templateId;
                clonedAssociationList.add(cloneRecord);
            }
            Svmxdatabase.insertRecord(clonedAssociationList);
        }
        catch ( Exception e ) {
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'populateTempAssociationsRecords() - exit;' );
        }

    }

    /**
     * This method is form response structure to return details of template, template item, category each template item belongs to, attribute associated with 
     * each template item and values of these attribute for the given record Id 
     * 
     * @param Map<String, SVMXA360__SM_TA_TemplateItem__c> and AssetId
     * 
     * @return List<TechAttr.TechnicalAttributeCategory>
     */
    public static List<TechAttr.TechnicalAttributeCategory> createResponseForMatchingAttributes (Map<String, SVMXA360__SM_TA_TemplateItem__c> templateItemPerAttributeMap, String assetId) {
        
        System.debug( LoggingLevel.FINEST, 'createResponseForMatchingAttributes() - enter; templateItemPerAttributeMap = ' + templateItemPerAttributeMap);
        
        List<TechAttr.TechnicalAttributeCategory> attributeCategoryList = new List<TechAttr.TechnicalAttributeCategory>();
        
        try {
            List<SVMXA360__SM_TA_AssetTechnicalAttribute__c> assetTechAttributeList  = queryAttributeValuesForAsset(new List<String>(templateItemPerAttributeMap.keySet()), assetId); //Query Asset Technical attributes
            
            Map<String, SVMXA360__SM_TA_AssetTechnicalAttribute__c> assetTechAttrPerAttributeMap = new Map<String, SVMXA360__SM_TA_AssetTechnicalAttribute__c>(); // Map<AttributeId, AssetTechnicalAttribute>
            for (SVMXA360__SM_TA_AssetTechnicalAttribute__c eachAssetAttr: assetTechAttributeList) {
                assetTechAttrPerAttributeMap.put(eachAssetAttr.SVMXA360__AttributeId__c, eachAssetAttr);
            }
            
            Map<String, TechAttr.TechnicalAttributeCategory> categoryDetailsPerIdMap = new Map<String, TechAttr.TechnicalAttributeCategory>();
            Map<String, List<SVMXA360__SM_TA_TemplateItem__c>> templateItemPerCategoryMap = new Map<String, List<SVMXA360__SM_TA_TemplateItem__c>>();
            TechAttr.TechnicalAttributeCategory attributeCategory;
            Map<String, String> templateIdAndCategorySequenceMap = new Map<String, String>();
            Map <String, TechAttr.TechAttrTemplateCategorySequence> categorySequenceMap = new Map <String, TechAttr.TechAttrTemplateCategorySequence>();
            
            //Group template items per the category they belong to
            for (SVMXA360__SM_TA_TemplateItem__c eachItem: templateItemPerAttributeMap.values()) {
                if (!templateItemPerCategoryMap.containsKey(eachItem.SVMXA360__CategoryId__c)) {
                    templateItemPerCategoryMap.put(eachItem.SVMXA360__CategoryId__c, new List<SVMXA360__SM_TA_TemplateItem__c>());
                }
                templateItemPerCategoryMap.get(eachItem.SVMXA360__CategoryId__c).add(eachItem);
                
                if(!templateIdAndCategorySequenceMap.containsKey(eachItem.SVMXA360__TemplateId__c) && !String.isBlank(eachItem.SVMXA360__TemplateId__r.SVMXA360__CategorySequenceJSON__c)){
                    templateIdAndCategorySequenceMap.put(eachItem.SVMXA360__TemplateId__c, eachItem.SVMXA360__TemplateId__r.SVMXA360__CategorySequenceJSON__c);
                }
                
                if (!categoryDetailsPerIdMap.containsKey(eachItem.SVMXA360__CategoryId__c)) {
                    
                    attributeCategory = new TechAttr.TechnicalAttributeCategory();
                    attributeCategory.Id = eachItem.SVMXA360__CategoryId__c;
                    attributeCategory.name = eachItem.SVMXA360__CategoryId__r.Name;
                    attributeCategory.developerName = eachItem.SVMXA360__CategoryId__r.SVMXA360__DeveloperName__c;
                    attributeCategory.description = eachItem.SVMXA360__CategoryId__r.SVMXA360__Description__c;
                    attributeCategory.templateId = eachItem.SVMXA360__TemplateId__c;
                    categoryDetailsPerIdMap.put(eachItem.SVMXA360__CategoryId__c, attributeCategory);
                }
            }
            
            //Process category sequence per template
            for ( String categorySeqJson: templateIdAndCategorySequenceMap.values()) {
                
                if (categorySeqJson != NULL) {
                    List<TechAttr.TechAttrTemplateCategorySequence> techAttrTemplateCategorySequences = 
                        (List<TechAttr.TechAttrTemplateCategorySequence>) JSON.deserialize(categorySeqJson, List<TechAttr.TechAttrTemplateCategorySequence>.class);
                    for ( TechAttr.TechAttrTemplateCategorySequence categorySequence : techAttrTemplateCategorySequences ) {
                        categorySequenceMap.put(categorySequence.categoryId, categorySequence);
                    }
                }
                
            }
            
            //Form response wrapper with attribute values 
            TechAttr.TechnicalAttributeCategory techAttrCategory;
            
            for (String categoryId: templateItemPerCategoryMap.keySet()) {
                
                techAttrCategory = categoryDetailsPerIdMap.get(categoryId);
                
                List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
                for (SVMXA360__SM_TA_TemplateItem__c tempItem: templateItemPerCategoryMap.get(categoryId)) {
                    
                    //build template item wrapper
                    TechAttr.TechnicalAttributeTemplateItem attrTemplateItem = buildTemplateItem( tempItem );  
                    attrTemplateItem.templateName = tempItem.SVMXA360__TemplateId__r.Name;
                    
                    //build attributeRecord wrapper with values
                    if(assetTechAttrPerAttributeMap.get(attrTemplateItem.attributeId) != NULL){
                        attrTemplateItem.attributeRecord = buildAttributeRecordForAsset(assetTechAttrPerAttributeMap.get(attrTemplateItem.attributeId));
                    }
                    
                    //build technicalAttribute wrapper
                    attrTemplateItem.technicalAttribute = buildAttributeFromTemplateItem(tempItem) ;
                    
                    technicalAttributeTemplateItems.add(attrTemplateItem);
                }
                
                techAttrCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;
                if (categorySequenceMap.get(techAttrCategory.Id) != NULL) {
                    techAttrCategory.sequence = categorySequenceMap.get(techAttrCategory.Id).sequence;
                }
                attributeCategoryList.add(techAttrCategory);
            }
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createResponseForMatchingAttributes() : Failed to query Template items. Error' + e.getStackTraceString() );
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createResponseForMatchingAttributes() - enter; attributeCategoryList = ' + attributeCategoryList);
        }
        
        return attributeCategoryList;
    }

    public static List<SVMXA360__SM_TA_AssetTechnicalAttribute__c> queryAttributeValuesForAsset (List<String> attributeIds, String recordId) {
        
        List<SVMXA360__SM_TA_AssetTechnicalAttribute__c> assetTechAttributeList = SvmxDatabase.query( [Select Id, SVMXA360__TemplateItemId__c, SVMXA360__AssetId__c, SVMXA360__AttributeId__c, SVMXA360__AttributeId__r.SVMXA360__DataType__c, SVMXA360__Value__c, SVMXA360__Source__c, SVMXA360__CapturedOn__c, SVMXA360__CapturedBy__c,
                                                                                    SVMXA360__PreviousValue__c, SVMXA360__PreviousCapturedOn__c, SVMXA360__PreviousCapturedBy__c, SVMXA360__BooleanValue__c, SVMXA360__PreviousBooleanValue__c,
                                                                                    SVMXA360__NumberValue__c, SVMXA360__PreviousNumberValue__c, SVMXA360__DateValue__c, SVMXA360__PreviousDateValue__c, SVMXA360__DatetimeValue__c, SVMXA360__PreviousDatetimeValue__c
                                                                                    from SVMXA360__SM_TA_AssetTechnicalAttribute__c
                                                                                    where SVMXA360__AttributeId__c IN: attributeIds AND SVMXA360__AssetId__c =: recordId] );
                                                                                     
        return assetTechAttributeList;
        
    }

    /**
     * method to create TechnicalAttributeTemplate record.
     * 
     * @param technicalAttributeTemplate TechnicalAttributeTemplate wrapper for which SObject to be created.
     * @return Returns TechnicalAttributeTemplate sobject with populated values from TechnicalAttributeTemplate.
     */
    public static SVMXA360__SM_TA_Template__c createTechAttrTemplateRecord( TechAttr.TechnicalAttributeTemplate technicalAttributeTemplate ) {
        
        System.debug( LoggingLevel.FINEST, 'createTechAttrTemplateRecord() - enter; technicalAttributeTemplate = ' + technicalAttributeTemplate);
        
        SVMXA360__SM_TA_Template__c techAttrTemplateRecord = new SVMXA360__SM_TA_Template__c();

        if( technicalAttributeTemplate.name == null || String.isBlank( technicalAttributeTemplate.developerName ) ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        if( String.isNotBlank( technicalAttributeTemplate.id ) ) {
            techAttrTemplateRecord.Id = technicalAttributeTemplate.id;
        } else {
            techAttrTemplateRecord.SVMXA360__DeveloperName__c = technicalAttributeTemplate.developerName;
        }
        
        techAttrTemplateRecord.Name = technicalAttributeTemplate.name;
        techAttrTemplateRecord.SVMXA360__Description__c = technicalAttributeTemplate.description;
        techAttrTemplateRecord.SVMXA360__Status__c = technicalAttributeTemplate.status;
        
        System.debug( LoggingLevel.FINEST, 'createTechAttrTemplateRecord() - exit; techAttrTemplateRecord= ' + techAttrTemplateRecord);
        
        return techAttrTemplateRecord;
    }

    /**
     * method to create TechnicalAttributeTemplate.
     * 
     * @param techAttrTemplateRecord TechnicalAttributeTemplate Record for which SObject to be queried.
     * @return Returns TechnicalAttributeTemplate sobject with populated values from TechnicalAttributeTemplateRecord.
     */
    public static TechAttr.TechnicalAttributeTemplate createTechAttrTemplate( SVMXA360__SM_TA_Template__c techAttrTemplateRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createTechAttrTemplate() - enter; techAttrTemplateRecord = ' + techAttrTemplateRecord);
        
        TechAttr.TechnicalAttributeTemplate techAttributeTemplate = new TechAttr.TechnicalAttributeTemplate();

        techAttributeTemplate.name = techAttrTemplateRecord.Name;
        techAttributeTemplate.id = techAttrTemplateRecord.Id;
        techAttributeTemplate.developerName = techAttrTemplateRecord.SVMXA360__DeveloperName__c;
        techAttributeTemplate.description = techAttrTemplateRecord.SVMXA360__Description__c;
        
        System.debug( LoggingLevel.FINEST, 'createTechAttrTemplate() - exit; techAttributeTemplate = ' + techAttributeTemplate);
        
        return techAttributeTemplate;
    }

    /**
     * This method is used to create PicklistDefinition wrapper for requested PicklistDefinition record.
     * 
     * @param picklistDefinitionRecord Picklist Definition sobject record from which wrapper to be created.
     * 
     * @return Returns Config.PicklistDefinition instance with populated values from picklistDefinitionRecord.
     */
    public static Config.PicklistDefinition createPicklistDefinition( final SVMXA360__CONF_PicklistDefinition__c picklistDefinitionRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createPicklistDefinition() - enter; picklistDefinitionRecord= ' + picklistDefinitionRecord);
        
        Config.PicklistDefinition picklistDefinition = new Config.PicklistDefinition();

        picklistDefinition.id = picklistDefinitionRecord.id;
        picklistDefinition.name = picklistDefinitionRecord.Name;
        picklistDefinition.description = picklistDefinitionRecord.SVMXA360__Description__c;
        picklistDefinition.developerName = picklistDefinitionRecord.SVMXA360__DeveloperName__c;
        picklistDefinition.type = picklistDefinitionRecord.SVMXA360__Type__c;
        picklistDefinition.values = picklistDefinitionRecord.SVMXA360__Values__c;
        picklistDefinition.defaultValue = picklistDefinitionRecord.SVMXA360__DefaultValue__c;
        picklistDefinition.lastModifiedDate = picklistDefinitionRecord.LastModifiedDate;
        picklistDefinition.lastModifiedBy = picklistDefinitionRecord.LastModifiedBy.Name;
        
        System.debug( LoggingLevel.FINEST, 'createPicklistDefinition() - exit; picklistDefinition= ' + picklistDefinition);
        
        return picklistDefinition;
    }

    /**
     * method to create PicklistDefinition record.
     * 
     * @param picklistDefinition PicklistDefinition wrapper for which SObject to be created.
     * @return Returns PicklistDefinition sobject with populated values from PicklistDefinition.
     */
    public static SVMXA360__CONF_PicklistDefinition__c createPicklistDefinitionRecord( final Config.PicklistDefinition picklistDefinition ) {
        
        System.debug( LoggingLevel.FINEST, 'createPicklistDefinitionRecord() - enter; picklistDefinition= ' + picklistDefinition);
        
        SVMXA360__CONF_PicklistDefinition__c picklistDefinitionRecord = new SVMXA360__CONF_PicklistDefinition__c();

        if( picklistDefinition == null || picklistDefinition.name == null || String.isBlank( picklistDefinition.values ) ) {
             
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Invalid request parameters. TechnicalAttribute Picklist Definition= ' + picklistDefinition );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }
        
        if( String.isNotBlank( picklistDefinition.id ) ) {
            picklistDefinitionRecord.Id = picklistDefinition.id;
        } else {
            picklistDefinitionRecord.SVMXA360__DeveloperName__c = picklistDefinition.developerName;
        }
        
        picklistDefinitionRecord.Name = picklistDefinition.name;
        picklistDefinitionRecord.SVMXA360__Description__c = picklistDefinition.description;
        picklistDefinitionRecord.SVMXA360__Values__c = picklistDefinition.values;
        picklistDefinitionRecord.SVMXA360__DefaultValue__c = picklistDefinition.defaultValue;
        picklistDefinitionRecord.SVMXA360__Type__c = picklistDefinition.type;
        
        System.debug( LoggingLevel.FINEST, 'createPicklistDefinitionRecord() - exit; picklistDefinitionRecord= ' + picklistDefinitionRecord);
        
        return picklistDefinitionRecord;
    }

    /**
     * This method is used to retrieve all Technical Attributes records
     * 
     * @returns Returns list of Technical Attribute records.
     */
    public static List<SVMXA360__SM_TA_TechnicalAttribute__c > getAllTechnicalAttributeRecords(final String filterElement) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeRecords() - enter;  filterElement= ' + filterElement );
        
        List<SVMXA360__SM_TA_TechnicalAttribute__c > technicalAttributeRecordList = new List<SVMXA360__SM_TA_TechnicalAttribute__c >();
        
        try {

            // Validate for required fields.
            if( String.isNotBlank( filterElement ) ) {
                technicalAttributeRecordList = SvmxDatabase.query( [SELECT Id, Name, LastModifiedDate, SVMXA360__Description__c, LastModifiedBy.Name, SVMXA360__DataType__c, SVMXA360__DeveloperName__c, SVMXA360__DefaultValue__c, SVMXA360__Unit__c, SVMXA360__MaximumValue__c, SVMXA360__MinimumValue__c, SVMXA360__IsReadonly__c, SVMXA360__IsRequired__c, SVMXA360__Message__c, SVMXA360__HelpText__c, SVMXA360__PicklistDefinitionId__c FROM SVMXA360__SM_TA_TechnicalAttribute__c WHERE id =:filterElement ORDER BY Name] );
            } else {
                technicalAttributeRecordList = SvmxDatabase.query( [SELECT Id, Name, LastModifiedDate, SVMXA360__Description__c, LastModifiedBy.Name, SVMXA360__DataType__c, SVMXA360__DeveloperName__c, SVMXA360__DefaultValue__c, SVMXA360__Unit__c, SVMXA360__MaximumValue__c, SVMXA360__MinimumValue__c, SVMXA360__IsReadonly__c, SVMXA360__IsRequired__c, SVMXA360__Message__c, SVMXA360__HelpText__c, SVMXA360__PicklistDefinitionId__c FROM SVMXA360__SM_TA_TechnicalAttribute__c ORDER BY Name] );
            }
            
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTechnicalAttributeRecords() : Failed to retrieve Technical Attributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeRecords() - exit; technicalAttributeRecordList.size()= ' + technicalAttributeRecordList.size() );
        }
        
        return technicalAttributeRecordList;
    }

    public static SVMXA360__SM_TA_TemplateAssociation__c buildTemplateAssociationRecord( TechAttr.TechAttrTemplateAssociation tempAssociation, Map<String, Schema.DescribeFieldResult> associationFieldResultMap ) {

        System.debug( LoggingLevel.DEBUG, 'buildTemplateAssociationRecord() - enter;');
        
        SVMXA360__SM_TA_TemplateAssociation__c tempAssociationRecord = new SVMXA360__SM_TA_TemplateAssociation__c();
        CONF_ObjectMappingHandler objMapHandler = new CONF_ObjectMappingHandler();

        if( String.isNotBlank( tempAssociationRecord.id ) ) {
            tempAssociationRecord.Id = tempAssociationRecord.id;
        } 

        tempAssociationRecord.SVMXA360__ProductId__c = tempAssociation.productId;
        tempAssociationRecord.SVMXA360__ProductFamily__c = tempAssociation.productFamily;
        tempAssociationRecord.SVMXA360__TemplateId__c = tempAssociation.templateId;
        
        if ( tempAssociation.customFieldValueMap != null ) {

            for ( String customFieldApiName : tempAssociation.customFieldValueMap.keySet() ) {

                String value = tempAssociation.customFieldValueMap.get(customFieldApiName);
                if ( String.isBlank(value)) {
                    tempAssociationRecord.put(customFieldApiName,null);
                    continue;
                }

                if (associationFieldResultMap.containsKey(customFieldApiName)) {
                    Schema.DescribeFieldResult fieldDescribe = associationFieldResultMap.get(customFieldApiName);
                    Schema.DisplayType displayType = fieldDescribe.getType();
                    Object fieldValue = objMapHandler.getFieldValueByType(displayType, value);
                    tempAssociationRecord.put(customFieldApiName,fieldValue);
                }
            }
        }
        return tempAssociationRecord;
    }

    public static TechAttr.TechnicalAttributeCategory populateDummyCategory( SVMXA360__SM_TA_Template__c templateRecord) {
        System.debug( LoggingLevel.DEBUG, 'populateDummyCategory() - enter; templateRecord = ' + templateRecord );

        TechAttr.TechnicalAttributeCategory dummyCategory = new TechAttr.TechnicalAttributeCategory();
        dummyCategory.name = 'New Group';
        dummyCategory.description = 'New Group Description';
        dummyCategory.developerName = templateRecord.SVMXA360__DeveloperName__c + '_' +'New_Group';

        List<TechAttr.TechnicalAttributeTemplateItem> technicalAttributeTemplateItems = new List<TechAttr.TechnicalAttributeTemplateItem>();
        dummyCategory.technicalAttributeTemplateItems = technicalAttributeTemplateItems;

        return dummyCategory;
    }

    public static void saveCategoryRecords( List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveCategoryRecords() - enter; technicalAttributeCategories = ' + technicalAttributeCategories );

        try {

            List<SVMXA360__SM_TA_Category__c> categoryRecords = new List<SVMXA360__SM_TA_Category__c>();
            Map<String, TechAttr.TechnicalAttributeCategory> techAttrCategoryMap = new Map<String, TechAttr.TechnicalAttributeCategory>();
            Integer sequenceCount = 1;

            for ( TechAttr.TechnicalAttributeCategory techAttrCategory : technicalAttributeCategories ) {

                if( techAttrCategory.name == null || String.isBlank( techAttrCategory.developerName ) ) {
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                }

                techAttrCategory.sequence = sequenceCount;

                techAttrCategoryMap.put( techAttrCategory.developerName, techAttrCategory );
                
                categoryRecords.add( buildCategoryRecord( techAttrCategory ) );

                sequenceCount += 1;
            }

            categoryRecords = (List<SVMXA360__SM_TA_Category__c>) SvmxDatabase.upsertRecord(categoryRecords);

            List<Id> categoryRecIds = new List<Id>();

            TechAttr.TechnicalAttributeCategory techAttributeCategory = new TechAttr.TechnicalAttributeCategory();
            
            for ( SVMXA360__SM_TA_Category__c categoryRecord : categoryRecords ) {

                techAttributeCategory = techAttrCategoryMap.get(categoryRecord.SVMXA360__DeveloperName__c);
                techAttributeCategory.id = categoryRecord.id;
            }
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveCategoryRecords() : Failed to save TechnicalAttributeCategories. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveCategoryRecords() : Failed to save TechnicalAttributeCategories. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveCategoryRecords() - exit; technicalAttributeCategories = ' + technicalAttributeCategories );
        }
    }

    public static void saveTemplateItemRecords( List<TechAttr.TechnicalAttributeCategory> technicalAttributeCategories, String templateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTemplateItemRecords() - enter; technicalAttributeCategories = ' + technicalAttributeCategories );

        try {

            List<SVMXA360__SM_TA_TemplateItem__c> templateItemRecords = new List<SVMXA360__SM_TA_TemplateItem__c>();
            Map<String,TechAttr.TechnicalAttributeTemplateItem> techAttrTemplateMap = new Map<String,TechAttr.TechnicalAttributeTemplateItem>();
            
            for ( TechAttr.TechnicalAttributeCategory techAttrCategory : technicalAttributeCategories ) {

                for ( TechAttr.TechnicalAttributeTemplateItem techAttrTemplateItem : techAttrCategory.technicalAttributeTemplateItems) {
                    
                    if( String.isBlank( techAttrTemplateItem.developerName ) || techAttrTemplateItem.attributeId == null ) {
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
                    }

                    techAttrTemplateMap.put(techAttrTemplateItem.developerName,techAttrTemplateItem);

                    templateItemRecords.add( buildTemplateItemRecord( techAttrTemplateItem, techAttrCategory.id ) );
                }
            }

            List<Id> templateRecIds = new List<Id>();

            if ( !templateItemRecords.isEmpty() ) {

                templateItemRecords = (List<SVMXA360__SM_TA_TemplateItem__c>) SvmxDatabase.upsertRecord(templateItemRecords);

                for ( SVMXA360__SM_TA_TemplateItem__c templateRec : templateItemRecords ) {
                    templateRecIds.add(templateRec.Id);
                    TechAttr.TechnicalAttributeTemplateItem tempItem = techAttrTemplateMap.get(templateRec.SVMXA360__DeveloperName__c);
                    tempItem.id = templateRec.Id;
                }
            }

            if ( !templateRecIds.isEmpty() && !templateItemRecords.isEmpty() ) {
                SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TemplateItem__c WHERE SVMXA360__TemplateId__c = :templateId AND Id NOT IN :templateRecIds ] );
            } else {
                SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_TA_TemplateItem__c WHERE SVMXA360__TemplateId__c = :templateId ] );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTemplateItemRecords() : Failed to save TechnicalAttributeCategories. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveTemplateItemRecords() : Failed to save TechnicalAttributeCategories. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTemplateItemRecords() - exit; technicalAttributeCategories = ' + technicalAttributeCategories );
        }
    }

    private static SVMXA360__SM_TA_Category__c buildCategoryRecord( TechAttr.TechnicalAttributeCategory techAttrCategory ) {

        System.debug( LoggingLevel.FINEST, 'buildCategoryRecord() - enter; techAttrCategory = ' + techAttrCategory);
        
        SVMXA360__SM_TA_Category__c technicalAttributeCategoryRecord = new SVMXA360__SM_TA_Category__c();

        if( String.isNotBlank( techAttrCategory.id ) ) {
            technicalAttributeCategoryRecord.Id = techAttrCategory.id;
        } 
        technicalAttributeCategoryRecord.SVMXA360__DeveloperName__c = techAttrCategory.developerName;
        
        
        technicalAttributeCategoryRecord.Name = techAttrCategory.name;
        technicalAttributeCategoryRecord.SVMXA360__Description__c = techAttrCategory.description;
        
        System.debug( LoggingLevel.FINEST, 'buildCategoryRecord() - exit; technicalAttributeCategoryRecord = ' + technicalAttributeCategoryRecord);
        
        return technicalAttributeCategoryRecord;
    }

    private static SVMXA360__SM_TA_TemplateItem__c buildTemplateItemRecord( TechAttr.TechnicalAttributeTemplateItem techAttrTemplateItem, String categoryId ) {

        System.debug( LoggingLevel.FINEST, 'buildTemplateItemRecord() - enter; techAttrTemplateItem = ' + techAttrTemplateItem);
        
        SVMXA360__SM_TA_TemplateItem__c techAttrTemplateItemRecord = new SVMXA360__SM_TA_TemplateItem__c();

        if( String.isNotBlank( techAttrTemplateItem.id ) ) {
            techAttrTemplateItemRecord.Id = techAttrTemplateItem.id;
        } else {
            techAttrTemplateItemRecord.SVMXA360__DeveloperName__c = techAttrTemplateItem.developerName;
            techAttrTemplateItemRecord.SVMXA360__TemplateId__c = techAttrTemplateItem.templateId;
        }
        
        techAttrTemplateItemRecord.SVMXA360__DeveloperName__c = techAttrTemplateItem.developerName;
        techAttrTemplateItemRecord.SVMXA360__CategoryId__c = categoryId;
        techAttrTemplateItemRecord.SVMXA360__AttributeId__c = techAttrTemplateItem.attributeId;
        techAttrTemplateItemRecord.SVMXA360__DefaultValue__c = techAttrTemplateItem.defaultValue;
        techAttrTemplateItemRecord.SVMXA360__HelpText__c = techAttrTemplateItem.helptext;
        techAttrTemplateItemRecord.SVMXA360__Message__c = techAttrTemplateItem.message;
        techAttrTemplateItemRecord.SVMXA360__IsReadonly__c = techAttrTemplateItem.isReadonly != null ? techAttrTemplateItem.isReadonly : false;
        techAttrTemplateItemRecord.SVMXA360__IsRequired__c = techAttrTemplateItem.isRequired != null ? techAttrTemplateItem.isRequired : false;
        techAttrTemplateItemRecord.SVMXA360__MaximumValue__c = techAttrTemplateItem.maximumValue;
        techAttrTemplateItemRecord.SVMXA360__MinimumValue__c = techAttrTemplateItem.minimumValue;
        techAttrTemplateItemRecord.SVMXA360__Status__c = techAttrTemplateItem.status;
        techAttrTemplateItemRecord.SVMXA360__Sequence__c = techAttrTemplateItem.sequence;
        
        
        System.debug( LoggingLevel.FINEST, 'buildTemplateItemRecord() - exit; techAttrTemplateItemRecord = ' + techAttrTemplateItemRecord);
        
        return techAttrTemplateItemRecord;
    }

    /**
     * This method is used to create Attribute History wrapper for requested attribute record.
     * 
     * @return Returns TechAttr.AttributeHistory instance with populated values from AttributeHistoryRecords.
     */
    public static List<TechAttr.AttributeHistory> createAttributeHistories( final List<SObject> historyRecordList ) {
        
        System.debug( LoggingLevel.FINEST, 'createAttributeHistories() - enter; historyRecordList= ' + historyRecordList);

        Map<String,List<SObject>> attributeHistoryMap = new Map<String,List<SObject>>();

        List<TechAttr.AttributeHistory> attributeHistoryList = new List<TechAttr.AttributeHistory>();

        if (historyRecordList == null || historyRecordList.size() == 0) {
            return attributeHistoryList;
        }

        for (SObject historyRecord : historyRecordList) {
            String attributeId = String.valueOf(historyRecord.get('ParentId'));
            if (!attributeHistoryMap.containsKey(attributeId)) {
                attributeHistoryMap.put(attributeId, new List<SObject>());
            }
            attributeHistoryMap.get(attributeId).add(historyRecord);
        }

        for (String attributeId : attributeHistoryMap.keySet()) {
            TechAttr.AttributeHistory attributeHistory = new TechAttr.AttributeHistory();
            attributeHistory.attributeId = attributeId;
            attributeHistory.attributeHistoryDetailList = createAttributeHistoryDetails(attributeHistoryMap.get(attributeId));
            attributeHistoryList.add(attributeHistory);
        }
        
        System.debug( LoggingLevel.FINEST, 'createAttributeHistories() - exit; attributeHistoryList= ' + attributeHistoryList);
        
        return attributeHistoryList;
    }


    /**
     * This method is used to create Attribute History details list wrapper for requested attribute record.
     * 
     * @return Returns List<TechAttr.TechnicalAttribute> instance with populated values from AttributeHistoryRecords.
     */
    public static List<TechAttr.TechnicalAttribute> createTechnicalAttributeFromAssetAttribute(final List<SObject> assetAttributeList) {
        CONF_ObjectMappingHandler objMapHandler = new CONF_ObjectMappingHandler();
        List<TechAttr.TechnicalAttribute> attributeList = new List<TechAttr.TechnicalAttribute>();
        TechAttr.TechnicalAttribute attrRecord;
        for(SObject record : assetAttributeList) {
            attrRecord = new TechAttr.TechnicalAttribute();
            attrRecord.id = String.valueOf(record.id);
            attrRecord.name = (String)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__AttributeId__r.name') ;
            attrRecord.dataType = (String)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__AttributeId__r.SVMXA360__DataType__c');
            attrRecord.unit = (String)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__AttributeId__r.SVMXA360__Unit__c');
            attrRecord.defaultValue = (String)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__TemplateItemId__r.SVMXA360__DefaultValue__c');
            if ((String)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__TemplateItemId__c') == null) { //mahima
                attrRecord.maximumValue = (Double)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__AttributeId__r.SVMXA360__MaximumValue__c');
                attrRecord.minimumValue = (Double)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__AttributeId__r.SVMXA360__MinimumValue__c');
            } else {
                attrRecord.maximumValue = (Double)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__TemplateItemId__r.SVMXA360__MaximumValue__c');
                attrRecord.minimumValue = (Double)objMapHandler.getValueOfMultiReference(record, 'SVMXA360__TemplateItemId__r.SVMXA360__MinimumValue__c');
            }
            
            attributeList.add(attrRecord);
        }
        return attributeList;
    }

    /**
     * This method is used to create Attribute History details list wrapper for requested attribute record.
     * 
     * @return Returns List<TechAttr.AttributeHistoryDetail> instance with populated values from AttributeHistoryRecords.
     */
    public static List<TechAttr.AttributeHistoryDetail> createAttributeHistoryDetails( final List<SObject> historyRecordList ) {//remove the instance from param and make it public
        
        System.debug( LoggingLevel.FINEST, 'createAttributeHistoryDetails() - enter; historyRecordList= ' + historyRecordList);

        if (historyRecordList == null || historyRecordList.size() == 0) {
            return null;
        }

        CONF_ObjectMappingHandler objMapHandler = new CONF_ObjectMappingHandler();
        List<TechAttr.AttributeHistoryDetail> attributeHistoryDetailList = new List<TechAttr.AttributeHistoryDetail>();
        TechAttr.AttributeHistoryDetail historyDetail;
        SObject valueFieldRecord;
        //Map for Value field
        Map<String,SObject> mapvalueFieldByCreatedDate = new Map<String,SObject>();
        String createdRecordNewValue;
        for(SObject historyRecord: historyRecordList) {

            string fieldName = String.valueOf(historyRecord.get('Field'));
            if(fieldName == 'SVMXA360__Value__c'){

                createdRecordNewValue = String.valueOf(historyRecord.get('OldValue'));

                String key = String.valueOf(Datetime.valueOf(historyRecord.get('CreatedDate')));
                mapvalueFieldByCreatedDate.put(key,historyRecord);
            }
        }
        if (mapvalueFieldByCreatedDate ==null || mapvalueFieldByCreatedDate.size() == 0 ) {
            SObject createdHistoryRecord = historyRecordList[historyRecordList.size()-1];
            createdRecordNewValue = (String)objMapHandler.getValueOfMultiReference(createdHistoryRecord,'Parent.SVMXA360__Value__c');
        }
        for(SObject historyRecord: historyRecordList) {

            string fieldName = String.valueOf(historyRecord.get('Field'));

            if (fieldName != 'SVMXA360__CapturedOn__c' && fieldName != 'created') { 
                continue;
            }
            
            historyDetail = new TechAttr.AttributeHistoryDetail();
            historyDetail.id = String.valueOf(historyRecord.get('Id'));
            historyDetail.parentId = String.valueOf(historyRecord.get('ParentId'));
            historyDetail.createdById = String.valueOf(historyRecord.get('CreatedById'));
            historyDetail.createdByName = (String)objMapHandler.getValueOfMultiReference(historyRecord,'CreatedBy.Name');
            historyDetail.createdDate = Datetime.valueOf(historyRecord.get('CreatedDate'));
            historyDetail.technicalAttributeId = (String)objMapHandler.getValueOfMultiReference(historyRecord,'Parent.SVMXA360__AttributeId__c');
            historyDetail.dataType = String.valueOf(historyRecord.get('DataType'));
            historyDetail.field = String.valueOf(historyRecord.get('Field'));

            if (fieldName == 'SVMXA360__CapturedOn__c') {
                String key = String.valueOf(Datetime.valueOf(historyRecord.get('CreatedDate'))); 

                if (mapvalueFieldByCreatedDate.containsKey(key)) {

                    valueFieldRecord = mapvalueFieldByCreatedDate.get(key); 
                    historyDetail.oldValue = String.valueOf(valueFieldRecord.get('OldValue'));
                    historyDetail.newValue = String.isBlank(String.valueOf(valueFieldRecord.get('NewValue'))) ? null : String.valueOf(valueFieldRecord.get('NewValue'));
                    
                }
                else if (valueFieldRecord !=null) {
                    
                    historyDetail.oldValue = String.valueOf(valueFieldRecord.get('OldValue'));
                    historyDetail.newValue = String.valueOf(valueFieldRecord.get('OldValue'));
                }
                else  {
                    
                    historyDetail.oldValue = (String)objMapHandler.getValueOfMultiReference(historyRecord,'Parent.SVMXA360__Value__c');
                    historyDetail.newValue = (String)objMapHandler.getValueOfMultiReference(historyRecord,'Parent.SVMXA360__Value__c');
                }
            } else if (fieldName == 'created') {
                
                historyDetail.oldValue = null;
                //Old value of first history record.
                historyDetail.newValue = createdRecordNewValue;
            }
            attributeHistoryDetailList.add(historyDetail);
            
        }
        
        System.debug( LoggingLevel.FINEST, 'createAttributeHistories() - exit; attributeHistoryDetailList= ' + attributeHistoryDetailList);
        
        return attributeHistoryDetailList;
    }

    /**
     * This method is used to clone technical attribute records.
     * 
     */
    public static void cloneTechnicalAttributeRecords ( List<String> attributeIds, TechAttr.TechnicalAttributeCategory technicalAttributeCategory ) {

        System.debug( LoggingLevel.FINEST, 'cloneTechnicalAttributeRecords() - enter; attributeIds = ' + attributeIds);

        String attributeQuery = 'SELECT ' + String.join( TechnicalAttributeFields, ',') + ' FROM SVMXA360__SM_TA_TechnicalAttribute__c where Id IN: attributeIds' ;

        System.debug( LoggingLevel.FINE, 'queryAttributeDetails() : attributeQuery = ' + attributeQuery );

        List<SVMXA360__SM_TA_TechnicalAttribute__c> attributeList = SvmxDatabase.query( Database.Query( attributeQuery ) );
        Map<String,SVMXA360__SM_TA_TechnicalAttribute__c> attributeMap = new Map<String,SVMXA360__SM_TA_TechnicalAttribute__c>();

        for ( SVMXA360__SM_TA_TechnicalAttribute__c techAttribute : attributeList ) {
            SVMXA360__SM_TA_TechnicalAttribute__c technicalAttribute = new SVMXA360__SM_TA_TechnicalAttribute__c();
            technicalAttribute.Name = techAttribute.Name;
            technicalAttribute.SVMXA360__DataType__c = techAttribute.SVMXA360__DataType__c;
            technicalAttribute.SVMXA360__DeveloperName__c = (String)techAttribute.SVMXA360__DeveloperName__c.left(64) + '_' + string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,16);
            technicalAttribute.SVMXA360__DefaultValue__c = techAttribute.SVMXA360__DefaultValue__c;
            technicalAttribute.SVMXA360__Unit__c = techAttribute.SVMXA360__Unit__c;
            technicalAttribute.SVMXA360__MaximumValue__c = techAttribute.SVMXA360__MaximumValue__c;
            technicalAttribute.SVMXA360__MinimumValue__c = techAttribute.SVMXA360__MinimumValue__c;
            technicalAttribute.SVMXA360__IsRequired__c = techAttribute.SVMXA360__IsRequired__c;
            technicalAttribute.SVMXA360__Message__c = techAttribute.SVMXA360__Message__c;
            technicalAttribute.SVMXA360__Description__c = techAttribute.SVMXA360__Description__c;
            technicalAttribute.SVMXA360__HelpText__c = techAttribute.SVMXA360__HelpText__c;
            technicalAttribute.SVMXA360__PicklistDefinitionId__c = techAttribute.SVMXA360__PicklistDefinitionId__c;
            attributeMap.put(techAttribute.Id,technicalAttribute);
        }

        if ( attributeMap.size() > 0 ) {

            SvmxDatabase.insertRecord( attributeMap.values() );

            for ( TechAttr.TechnicalAttributeTemplateItem templateItem : technicalAttributeCategory.technicalAttributeTemplateItems ) {
                SVMXA360__SM_TA_TechnicalAttribute__c attribute = attributeMap.get(templateItem.attributeId);
                templateItem.attributeId = attribute.Id;
                templateItem.attributeName = attribute.Name;
            }
        }

    }

    /**
     * This method is used to retrieve all user groups for configured technical attributes.
     */
    public static Map<Id,SVMXA360__CONF_UserGroupTechnicalAttribute__c> getExistingUserGroups(Set<String> attributeIdSet) {
        
        System.debug( LoggingLevel.DEBUG, 'getExistingUserGroups() - enter:' +attributeIdSet );        
        Map<Id,SVMXA360__CONF_UserGroupTechnicalAttribute__c> mapUserGroupTA = new Map<Id,SVMXA360__CONF_UserGroupTechnicalAttribute__c>();

        if(! attributeIdSet.isEmpty() ) {

            for (SVMXA360__CONF_UserGroupTechnicalAttribute__c eachRecord : (List<SVMXA360__CONF_UserGroupTechnicalAttribute__c>)SvmxDatabase.query([Select Id,Name,SVMXA360__TechnicalAttributeId__c,SVMXA360__UserGroupId__c from SVMXA360__CONF_UserGroupTechnicalAttribute__c where SVMXA360__TechnicalAttributeId__c IN :attributeIdSet]) ) {
                mapUserGroupTA.put(eachRecord.SVMXA360__UserGroupId__c,eachRecord);
            }
        }

        System.debug( LoggingLevel.DEBUG, 'getExistingUserGroups() - exit; mapUserGroupTA = ' + mapUserGroupTA );

        return mapUserGroupTA;
    }

    /**
     * This method is used to create UserGroup wrapper for requested UserGroup record.
     * 
     * @param userGroupRecord UserGroup sobject record from which wrapper to be created.
     * 
     * @return Returns TechAttr.UserGroup instance with populated values from userGroupRecord.
     */
    public static TechAttr.UserGroup createUserGroup( final SVMXA360__CONF_UserGroup__c userGroupRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createUserGroup() - enter; userGroupRecord= ' + userGroupRecord);
        
        TechAttr.UserGroup userGroup = new TechAttr.UserGroup();

        userGroup.id = userGroupRecord.id;
        userGroup.name = userGroupRecord.Name;
        userGroup.developerName = userGroupRecord.SVMXA360__DeveloperName__c;
        userGroup.description = userGroupRecord.SVMXA360__Description__c;  
        userGroup.active = ( userGroupRecord.SVMXA360__Active__c != null ) ? userGroupRecord.SVMXA360__Active__c : false;
        userGroup.lastModifiedDate = userGroupRecord.LastModifiedDate;
        userGroup.lastModifiedBy = userGroupRecord.LastModifiedBy.Name;
        
        System.debug( LoggingLevel.FINEST, 'createUserGroup() - exit; userGroup= ' + userGroup);
        
        return userGroup;
    }

    public static SVMXA360__CONF_UserGroupTechnicalAttribute__c buildUserGroupTARecord( TechAttr.UserGroupTechnicalAttribute userGroupAttribute ) {

        System.debug( LoggingLevel.FINEST, 'buildUserGroupTARecord() - enter; userGroupAttribute = ' + userGroupAttribute);
        
        SVMXA360__CONF_UserGroupTechnicalAttribute__c userGroupAttributeRecord = new SVMXA360__CONF_UserGroupTechnicalAttribute__c();

        if( String.isBlank( userGroupAttribute.technicalAttributeId ) || userGroupAttribute.userGroup == null || String.isBlank( userGroupAttribute.userGroup.id ) ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        userGroupAttributeRecord.SVMXA360__TechnicalAttributeId__c = userGroupAttribute.technicalAttributeId;
        userGroupAttributeRecord.SVMXA360__UserGroupId__c = userGroupAttribute.userGroup.id;
       
        
        System.debug( LoggingLevel.FINEST, 'buildUserGroupTARecord() - exit; userGroupAttributeRecord = ' + userGroupAttributeRecord);
        
        return userGroupAttributeRecord;
    }
}