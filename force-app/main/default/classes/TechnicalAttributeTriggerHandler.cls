/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class prevents user to update or delete Technical Attributes. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-1926 Karthick Saravanan      16 June 2022      Created.
 *****************************************************************************************************/
public with sharing class TechnicalAttributeTriggerHandler {    

    /**
     * This method prevents users to update Unit, DataType and Developer Name fields on Technical Attribute record
     * @param newTAList Trigger.newlist - List of new Technical Attributes.
     * @param oldMap Trigger.oldMap - Old map of Technical Attributes.
     * @return void.
     *
     */
    public void preventToUpdateAttributeDefinition(List<SVMXA360__SM_TA_TechnicalAttribute__c> newTAList,map<Id, SVMXA360__SM_TA_TechnicalAttribute__c> oldMap){
        System.debug( LoggingLevel.DEBUG, 'preventToUpdateAttributeDefinition() enter - oldMap: ' + oldMap);
        try {
            
            for(SVMXA360__SM_TA_TechnicalAttribute__c eachTA : newTAList) {
                if( eachTA.SVMXA360__DeveloperName__c!= oldMap.get(eachTA.Id).SVMXA360__DeveloperName__c){
                    eachTA.addError('DeveloperName cannot be updated.');
                }
                if(eachTA.SVMXA360__DataType__c!= oldMap.get(eachTA.Id).SVMXA360__DataType__c){
                    eachTA.addError('DataType cannot be updated.');
                }
                if(eachTA.SVMXA360__Unit__c!= oldMap.get(eachTA.Id).SVMXA360__Unit__c){
                    eachTA.addError('Unit cannot be updated.');
                }
            }

        } catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventToUpdateAttributeDefinition() : Failed to perform updation of TA record. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'preventToUpdateAttributeDefinition() exit');
        }
    }
    
    /**
     * This method is used to perform the check on Technical Attributes prior delete, to ensure there are no related Template Items or Asset-TA records assosicated.*
     * @param oldMap Trigger.oldMap - Old map of Technical Attributes.
     * @return void.
     *
     */
    public void preventDeletionRelatedTA(Map<Id, SVMXA360__SM_TA_TechnicalAttribute__c> oldMap) {
        System.debug( LoggingLevel.DEBUG, 'preventDeletionRelatedTA() enter - oldMap: ' + oldMap);
        try {
            new TA_TechnicalAttributeHandler().deleteCheckOnTA( oldMap.KeySet(), Trigger.isExecuting );
        } catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDeletionRelatedTA() : Failed to perform check on deletion of TA based on realted record. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'preventDeletionRelatedTA() exit');
        }
    }

    /**
     * This method prevents users to create or update record without having value on any custom field except TemplateId.
     * @param newList Trigger.newlist - List of new Template Associations.
     * @param oldMap Trigger.oldMap - Old map of Template Associations.
     * @return void.
     *
     */
    public void preventToUpdateMatchValue(List<SVMXA360__SM_TA_TemplateAssociation__c> newList,map<Id, SVMXA360__SM_TA_TemplateAssociation__c> oldMap){
        System.debug( LoggingLevel.DEBUG, 'preventToUpdateMatchValue() enter - newList: ' + newList);
        System.debug( LoggingLevel.DEBUG, 'preventToUpdateMatchValue() enter - oldMap: ' + oldMap);
        try {

            Set<String> templateAssociationFields = new Set<String>();

            //Retrieve all custom fields from Template Association Object - SVMXA360__SM_TA_TemplateAssociation__c
            Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions( 'SVMXA360__SM_TA_TemplateAssociation__c' , true );
            
            for( Common.FieldDefinition fieldDefinition : entityDefinition.fieldDefinitions ) {

                if (fieldDefinition.apiName.toLowerCase().endsWith('__c') && fieldDefinition.apiName != 'SVMXA360__TemplateId__c') {
                    templateAssociationFields.add(fieldDefinition.apiName);
                }
            }
            if (templateAssociationFields == null || templateAssociationFields.size() == 0) {
                return;
            }

            for(SVMXA360__SM_TA_TemplateAssociation__c eachRecord : newList) {
                Boolean hasFieldValue = false;
                for(String fieldName : templateAssociationFields) {

                    if (eachRecord.get(fieldName) != null) {
                        hasFieldValue = true;
                        break;
                    }
                }
                if (!hasFieldValue) {
                    eachRecord.addError(System.Label.Label_TemplateMatchFieldValueErr);
                }
            }
        } catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventToUpdateMatchValue() : Failed to perform create or update of Template Asscociation record. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'preventToUpdateMatchValue() exit');
        }
    }
    
}