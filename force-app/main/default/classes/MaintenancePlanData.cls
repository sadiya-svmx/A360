/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Wrapper class to construct request/response for MaintenancePlan CPQ Service 
 * for flow or global class 
 *
 * 
 *
 * @author Jaysukh Patel
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jaysukh Patel           18 Sep 2021     Created.
 *****************************************************************************************************/
global with sharing class MaintenancePlanData {

    @InvocableVariable(label='Source Record Id' description='The record Id of the Source Record' required=true)
    global String sourceRecordId;

    @InvocableVariable(label='Operation Type' description='Operation Type one of FOR-TEMPLATE/FOR-PRODUCT. Default value is FOR-TEMPLATE')
    global String operationType;

    @InvocableVariable(label='Maintenance Plan Template Id' description='The record Id of the Maintenance Plan Template' required=false)
    global String maintenancePlanTemplateId;

    @InvocableVariable(label='Maintenance Plan Template Product Id' description='The Id of Product Record associated to Maintenance Plan Template')
    global String maintenancePlanTemplateProductId;

    @InvocableVariable(label='Maintenance Plan Title' description='The Title of the Maintenance Plan')
    global String maintenancePlanTitle;

    @InvocableVariable(label='Start Date' description='The Start Date of the Maintenance Plan')
    global Date startDate;

    @InvocableVariable(label='Date of the first work order in the next batch' description='The Date of the first work order in the next batch of the Maintenance Plan')
    global Date dateOfFirstWorkOrderInNextBatch;

    @InvocableVariable(label='Maintenance Plan Record' description='The Maintenance Plan Record that needs to be created')
    global MaintenancePlan sourceMaintenancePlan;

    @InvocableVariable(label='Maintenance Asset Records' description='The Maintenance Asset Records that needs to be created')
    global List<MaintenanceAsset> sourceMaintenanceAssetList;

    @InvocableVariable(label='Subscription Id' description='The record Id of the Subscription Record')
    global String subscriptionId;

    @InvocableVariable(label='Subscription Field API Name' description='The Subscription Field API Name on Maintenance Plan object')
    global String subscriptionFieldName;

    @InvocableVariable(label='MaintenancePlan Id' description='Return the created maintenancePlan Id')
    global String maintenancePlanId;
}