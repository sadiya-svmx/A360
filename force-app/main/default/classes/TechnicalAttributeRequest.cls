/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Wrapper class to capture technical attribute values on different objects
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
global virtual class TechnicalAttributeRequest {
    
    @AuraEnabled
    @InvocableVariable(label='Object API Name' description='API Name of the object on which attributes are captured' required=true)
    global String objectName;
    
    @AuraEnabled
    @InvocableVariable(label='Source/Connection' description='Source from where attributes are captured' required=false)
    global String source;

    @AuraEnabled
    @InvocableVariable(label='Target Object' description='Target Object where the attribute values will be stored' required=false)
    global String targetObject;
    
    @AuraEnabled
    @InvocableVariable(label='Attribute list' description='Details of the records on which attributes are captured' required=true)
    global List<TechnicalAttributeData> attributeList;

}