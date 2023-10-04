/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete Technical Attribute information.
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Karthick Saravanan      16 June 2022      Created.
 *****************************************************************************************************/
public with sharing class TA_TechnicalAttribute_LS {

    /**
     * This method retrieves all available Technical Attributes
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Technical Attributes.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllTechnicalAttributes(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttribute_LS -getTechnicalAttributes() - enter--'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserialize( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve attributes from manager 
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getAllTechnicalAttributes(inputData);
            System.debug( LoggingLevel.INFO, 'getAllTechnicalAttributes() : Retrieved TAs successfully' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTechnicalAttributes() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTechnicalAttributes() : Failed to retrieve attributes. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributes() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all available Template Associations
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Template Associations for a template.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllTemplateAssociations(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttribute_LS -getAllTemplateAssociations() - enter--'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserialize( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve attributes from manager 
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getAllTemplateAssociations(inputData);
            System.debug( LoggingLevel.INFO, 'getAllTemplateAssociations() : Retrieved Template Associations successfully' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTemplateAssociations() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTemplateAssociations() : Failed to retrieve Template Association. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTemplateAssociations() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieved the information of Technical Attribute
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse getTechnicalAttributeWithDetails( final String attributeId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeWithDetails() - enter; attributeId= ' + attributeId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeWithDetails( attributeId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to get Technical Attribute. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeWithDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Technical Attribute
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveTechnicalAttribute( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttribute() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TechAttr.TechnicalAttribute technicalAttribute = (TechAttr.TechnicalAttribute) JSON.deserializeStrict( requestJson, TechAttr.TechnicalAttribute.class );
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttribute( technicalAttribute );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttribute() : Failed to save Technical Attribute. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttribute() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Technical Attribute Template
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute Template.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveTechnicalAttributeTemplate( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplate() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TechAttr.TechnicalAttributeTemplate technicalAttributeTemplate = (TechAttr.TechnicalAttributeTemplate) JSON.deserializeStrict( requestJson, TechAttr.TechnicalAttributeTemplate.class );
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplate( technicalAttributeTemplate );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplate() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplate() : Failed to save Technical Attribute Template. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplate() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method checks related recors of Technical Attribute during delete action.
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteCheckOnRelatedTA( final String attributeId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteCheckOnRelatedTA() - enter; attributeId= ' + attributeId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().deleteCheckOnRelatedTA( attributeId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttribute() : Failed to delete Technical Attribute. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCheckOnRelatedTA() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Technical Attribute
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTechnicalAttribute( final String attributeId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttribute() - enter; attributeId= ' + attributeId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttribute( attributeId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttribute() : Failed to delete Technical Attribute. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttribute() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method returns the related records of Technical Attribute.
     * 
     * @return Returns instance of Common.ServiceResponse with response of related records of Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse getWhereUsedDetails( final String attributeId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() - enter; attributeId= ' + attributeId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new TA_TechnicalAttributeHandler().deleteCheckOnTA( new Set<Id>{attributeId} ).get(0);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedDetails() : Failed to retrieve related records of Technical Attribute. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Technical Attribute Template Item
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute template item.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTechnicalAttributeTemplateItems( final list<String> templateItemList ) { 
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItems() - enter; templateItemList= ' + templateItemList );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateItem(templateItemList);
            System.debug( LoggingLevel.INFO, 'deleteTechnicalAttributeTemplateItems() : Saved Technical Attribute Template Item' );
            serviceResponse.success = true;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateItems() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItems() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    /**
     * This method deletes Technical Attribute Template Item
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute template item.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTechnicalAttributeTemplateItem( final String templateItemId ) { 
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItem() - enter; templateItemId= ' + templateItemId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateItem(new list<string>{templateItemId});
            System.debug( LoggingLevel.INFO, 'deleteTechnicalAttributeTemplateItem() : Saved Technical Attribute Template Item' );
            serviceResponse.success = true;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateItem() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateItem() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    /**
     * This method deletes the Technical Attribute Template Category
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute template Category.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTechnicalAttributeTemplateCategory( final string categoryId ) { 
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateCategory() - enter; categoryId= ' + categoryId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateCategory(categoryId);
            System.debug( LoggingLevel.INFO, 'deleteTechnicalAttributeTemplateCategory() : Saved Technical Attribute Template Category' );
            serviceResponse.success = true;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateCategory() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateCategory() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Technical Attribute Template Association
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute template Association.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTechnicalAttributeTemplateAssociation( final string templateAssociation ) { 
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateAssociation() - enter; templateAssociation= ' + templateAssociation );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplateAssociation(templateAssociation);
            System.debug( LoggingLevel.INFO, 'deleteTechnicalAttributeTemplateAssociation() : Saved Technical Attribute Template Association' );
            serviceResponse.success = true;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplateAssociation() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplateAssociation() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

	/**
     * This method deletes the Technical Attribute template
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Technical Attribute template.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTechnicalAttributeTemplate( final String templateId ) { 
        System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplate() - enter; templateId= ' + templateId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TA_TechnicalAttributeManager.getInstance().deleteTechnicalAttributeTemplate(templateId);
            System.debug( LoggingLevel.INFO, 'deleteTechnicalAttributeTemplate() : Saved Technical Attribute Template' );
            serviceResponse.success = true;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTechnicalAttributeTemplate() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTechnicalAttributeTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Technical Attribute Categories
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute Categories.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveTechnicalAttributeTemplateCategories( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateCategories() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TechAttr.TechnicalAttributeTemplateCategories technicalAttributeCategories = (TechAttr.TechnicalAttributeTemplateCategories) JSON.deserializeStrict( requestJson, TechAttr.TechnicalAttributeTemplateCategories.class );
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateCategories( technicalAttributeCategories );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateCategories() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateCategories() : Failed to save Technical Attribute. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateCategories() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Technical Attribute Categories
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute Categories.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveTechnicalAttributeTemplateAssociations( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateAssociations() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TechAttr.TechAttrTemplateAssociationList templateAssociationList = (TechAttr.TechAttrTemplateAssociationList) JSON.deserializeStrict( requestJson, TechAttr.TechAttrTemplateAssociationList.class );
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociations( templateAssociationList );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociations() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociations() : Failed to save Technical Attribute. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateAssociations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieved the information of Categories and respective Items
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Categories and respective Items.
     */
    @AuraEnabled
    public static Common.ServiceResponse getTechnicalAttributeTemplateCategories( final String templateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateCategories() - enter; templateId = ' + templateId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateCategories( templateId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateCategories() : Failed to get Technical Attribute. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateCategories() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
     }
        
     /**
     * This method saves the information of Technical Attribute TemplateAssociation
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute TemplateAssociation.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveTechnicalAttributeTemplateAssociation( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateAssociation() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            TechAttr.TechAttrTemplateAssociation templateAssociation = (TechAttr.TechAttrTemplateAssociation) JSON.deserializeStrict( requestJson, TechAttr.TechAttrTemplateAssociation.class );
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveTechnicalAttributeTemplateAssociation( templateAssociation );
        }
        
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociation() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateAssociation() : Failed to save Technical Attribute. Error=' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }

        return serviceResponse;
    }

    /**
     * This method fetch technical attribute for asset
     * 
     * @return Returns instance of Common.ServiceResponse with data as List<TechAttr.TechnicalAttributeCategory>
     */
    @AuraEnabled
    public static Common.ServiceResponse fetchAttributesForAsset( final String parentRecordId ) {

        System.debug( LoggingLevel.DEBUG, 'fetchAttributesForAsset() - enter; Record Id = ' + parentRecordId );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().fetchAttributesForAsset( parentRecordId);
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'fetchAttributesForAsset() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchAttributesForAsset() - exit; serviceResponse.success ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method save the information of Asset Technical Attributes
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Asset Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveAttributeRecords( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveAttributeRecords() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {             

            TechAttr.AttributeRecordList attributeRecordDetails = (TechAttr.AttributeRecordList) JSON.deserializeStrict( requestJson, TechAttr.AttributeRecordList.class );

            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveAttributeRecords( attributeRecordDetails );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveAttributeRecords() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveAttributeRecords() : Failed to save Asset Technical Attributes. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveAttributeRecords() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieved the information of Template
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Template.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getTechnicalAttributeTemplateDetails( final String templateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTemplateDetails() - enter; templateId = ' + templateId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getTechnicalAttributeTemplateDetails( templateId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateDetails() : Failed to get Technical Attribute. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method clones the Technical Attribute Template Record
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Technical Attribute Template.
     */
    @AuraEnabled
    public static Common.ServiceResponse cloneTechnicalAttributeTemplate( final String templateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributeTemplate() - enter; templateId = ' + templateId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().cloneTechnicalAttributeTemplate( String.escapeSingleQuotes( templateId ) );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributeTemplate() : Failed to clone Technical Attribute Template. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributeTemplate() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieve history information of Asset Technical Attributes
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Asset Technical Attribute Histories.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAttributeHistories( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAttributeHistories() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {             

            TechAttr.AttributeHistoryRequest historyReq = (TechAttr.AttributeHistoryRequest) JSON.deserializeStrict( requestJson, TechAttr.AttributeHistoryRequest.class );

            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getAttributeHistories( historyReq );
            //new TA_TechnicalAttributeHelper().getAttributeHistories(historyReq);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'getAttributeHistories() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAttributeHistories() : Failed to retrieve history information of Asset Technical Attributes. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveAttributeRecords() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method fetch technical attribute for asset
     * 
     * @return Returns instance of Common.ServiceResponse with data as List<TechAttr.TechnicalAttributeCategory>
     */
    @AuraEnabled
    public static Common.ServiceResponse fetchAttributesHistoryList( final String jsonRequest ) {

        System.debug( LoggingLevel.DEBUG, 'fetchAttributesForAsset() - enter; Record Id = ' +  jsonRequest);

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            TechAttr.AttributeHistoryFilter request =  (TechAttr.AttributeHistoryFilter)JSON.deserializeStrict(jsonRequest, TechAttr.AttributeHistoryFilter.class);
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getAttributesHistoryList(request);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'fetchAssetAttributesHistoryList() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'fetchAssetAttributesHistoryList() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchAssetAttributesHistoryList() - exit; serviceResponse.success ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method fetch technical attribute for asset
     * 
     * @return Returns instance of Common.ServiceResponse with data as List<TechAttr.TechnicalAttributeCategory>
     */
    @AuraEnabled
    public static Common.ServiceResponse fetchAllAttributes( final String parentRecordId, final String objectName ) {

        System.debug( LoggingLevel.DEBUG, 'fetchAllAttributes() - enter; Record Id = ' +  parentRecordId);

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getAllAttributesAssociatedToParent(parentRecordId, String.escapeSingleQuotes(objectName));
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'fetchAllAttributes() : Failed to get Technical Attributes. Error=' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchAllAttributes() - exit; serviceResponse.success ' + serviceResponse.success );
        }

        return serviceResponse;
    }
    
    /**
     * This method clone technical attributes
     * 
     * @return Returns instance of Common.ServiceResponse with data as TechAttr.TechnicalAttributeCategory
     */
    @AuraEnabled
    public static Common.ServiceResponse cloneTechnicalAttributes( final String jsonRequest ) {

        System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributes() - enter; jsonRequest = ' +  jsonRequest);

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            TechAttr.TechnicalAttributeCategory request =  (TechAttr.TechnicalAttributeCategory)JSON.deserializeStrict(jsonRequest, TechAttr.TechnicalAttributeCategory.class);
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().cloneTechnicalAttributes(request);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributes() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'cloneTechnicalAttributes() : Failed to clone Technical Attributes. Error=' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'cloneTechnicalAttributes() - exit; serviceResponse.success ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method fetch current user information
     * 
     * @return Returns instance of Common.ServiceResponse 
     */
    @AuraEnabled
    public static Common.ServiceResponse fetchCurrentLoggedInUser() {

        System.debug( LoggingLevel.DEBUG, 'fetchCurrentLoggedInUser() - enter; ');

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse = new ADM_PageLayoutService().getUserInfo();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'fetchCurrentLoggedInUser() : Failed to get userInfo. Error=' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchCurrentLoggedInUser() - exit; serviceResponse.success ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method retrieves all available User Groups
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all User Groups.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllUserGroups(final String attributeId, final String searchTerm) {
        
        System.debug( LoggingLevel.DEBUG, 'TA_TechnicalAttribute_LS -getAllUserGroups() - enter--'+attributeId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {          
            // Retrieve user groups from manager 
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().getAllUserGroups(attributeId,searchTerm);
            System.debug( LoggingLevel.INFO, 'getAllUserGroups() : Retrieved user groups successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllUserGroups() : Failed to retrieve user groups. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllUserGroups() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Technical Attribute Assignment
     * 
     * @return Returns instance of Common.ServiceResponse with response of the User Group Technical Attribute.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveUserGroupTechnicalAttribute( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveUserGroupTechnicalAttribute() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final List<TechAttr.UserGroupTechnicalAttribute> taUserGroups = (List<TechAttr.UserGroupTechnicalAttribute>) JSON.deserializeStrict( requestJson, List<TechAttr.UserGroupTechnicalAttribute>.class );
            
            serviceResponse.data = TA_TechnicalAttributeManager.getInstance().saveUserGroupTechnicalAttribute(taUserGroups);
            System.debug( LoggingLevel.INFO, 'saveUserGroupTechnicalAttribute() : Saved User Group Technical Attribute' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveUserGroupTechnicalAttribute() : Failed to deserialize User Group Technical Attribute. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveUserGroupTechnicalAttribute() : Failed to User Group Technical Attribute records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveUserGroupTechnicalAttribute() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}