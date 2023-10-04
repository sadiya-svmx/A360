/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Wrapper class to capture each technical attribute's details.
 * 
 * @author Jeevika Rao
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jeevika Rao        05 July 2022        Created.
 *****************************************************************************************************/
global virtual class TechnicalAttributeData {
    
    @AuraEnabled
    @InvocableVariable(label='Attribute Developer Name' description='Developer Name/Unique Name of the attribute' required=true)
    global String attributeKey;

    @AuraEnabled
    @InvocableVariable(label='Value' description='Value of the attribute' required=true)
    global String value;
    
    @AuraEnabled
    @InvocableVariable(label='Attribute DataType' description='Datatype of the attribute' required=false)
    global String dataType;

    @AuraEnabled
    @InvocableVariable(label='Unit' description='Unit of the attribute' required=false)
    global String unit;
    
    @AuraEnabled
    @InvocableVariable(label='Record Id' description='SFDC Id of the record (Asset, Opportunity, etc) on which technical attributes are captured' required=false)
    global String recordId;
    
    @AuraEnabled
    @InvocableVariable(label='Record Name' description='Name of the record (Asset, Oppportunity etc) on which technical attributes are captured' required=false)
    global String recordName;

    @AuraEnabled
    @InvocableVariable(label='Time of Occurence' description='The time of occurence of the change in value for the attribute' required=false)
    global String timeOfOccurence;

    @AuraEnabled
    global String templateItemId;
}