/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is the handler for the MPlan_Template_Trigger1 and ApplicableProduct_Trigger1. 
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Soumyaranjan Pati       19 Apr 2021     Created.
 *              Soumyaranjan Pati       21 June 2021     Updated.
 *****************************************************************************************************/
public with sharing class MPLN_TemplateTriggerHandler {

     /**
     * Private static instance variable to hold instance of this class.
     */
    private static final MPLN_TemplateTriggerHandler instance = new MPLN_TemplateTriggerHandler();

    /**
     * Public method to retrieve instance of this class.
     */
    public static MPLN_TemplateTriggerHandler getInstance() {
        return instance;
    }

    public String generateAPUniqueKey( final SVMXA360__ApplicableProduct__c applicableProduct ) {
        
        String uniqueKeyString = '';

        if (String.isNotBlank( applicableProduct.SVMXA360__ProductId__c ) && String.isNotBlank( applicableProduct.SVMXA360__ProductFamily__c )) {
            applicableProduct.addError(System.Label.Error_Applicable_Product_Validation);
        }

        if (String.isBlank( applicableProduct.SVMXA360__ProductId__c ) && String.isBlank( applicableProduct.SVMXA360__ProductFamily__c )) {
            applicableProduct.addError(System.Label.Error_Applicable_Product_Validation_for_One);
        }
        
        if ( String.isNotBlank( applicableProduct.SVMXA360__MaintenancePlanTemplateId__c ) ) {
            if ( String.isNotBlank( applicableProduct.SVMXA360__ProductId__c ) ) {
                uniqueKeyString = applicableProduct.SVMXA360__MaintenancePlanTemplateId__c + String.valueOf( applicableProduct.SVMXA360__ProductId__c );
            } else if ( String.isNotBlank( applicableProduct.SVMXA360__ProductFamily__c ) ) {
                uniqueKeyString = applicableProduct.SVMXA360__MaintenancePlanTemplateId__c + applicableProduct.SVMXA360__ProductFamily__c;
            }
        }
        
        return uniqueKeyString;
    }

    /**
     * Public method to validate the Maintenance Plan Template records.
     */
    public void validateMPlanTemplateRecords( final SVMXA360__MaintenancePlanTemplate__c mPlanTemplate ) {
        //Round the deciml values
        if ( mPlanTemplate.SVMXA360__GenerationTimeframe__c != null ) {
            mPlanTemplate.SVMXA360__GenerationTimeframe__c = mPlanTemplate.SVMXA360__GenerationTimeframe__c.round(System.RoundingMode.HALF_UP);
        }
        if ( mPlanTemplate.SVMXA360__GenerationHorizon__c != null ) {
            mPlanTemplate.SVMXA360__GenerationHorizon__c = mPlanTemplate.SVMXA360__GenerationHorizon__c.round(System.RoundingMode.HALF_UP);
        }
        if ( mPlanTemplate.SVMXA360__MaintenancePlanDuration__c != null ) {
            mPlanTemplate.SVMXA360__MaintenancePlanDuration__c = mPlanTemplate.SVMXA360__MaintenancePlanDuration__c.round(System.RoundingMode.HALF_UP);
        }
        if ( mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c != null ) {
            mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c = mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c.round(System.RoundingMode.HALF_UP);
        }
        if ( mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c != null ) {
            mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c = mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c.round(System.RoundingMode.HALF_UP);
        }
        //
        if ( mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c != null && mPlanTemplate.SVMXA360__SvcApptGenerationMethod__c != null  && mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c.equalsIgnoreCase('WorkOrderPerAsset') ) {
            addError(mPlanTemplate, System.Label.Error_MPlan_Template_Validation);
        } else if ( mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c == null && mPlanTemplate.SVMXA360__SvcApptGenerationMethod__c != null ) {
            addError(mPlanTemplate, System.Label.Error_MPlan_Template_Validation);
        } else if ( mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c != null && mPlanTemplate.SVMXA360__SvcApptGenerationMethod__c == null && mPlanTemplate.SVMXA360__WorkOrderGenerationMethod__c.equalsIgnoreCase('WorkOrderLineItemPerAsset')) {
            addError(mPlanTemplate, System.Label.Error_MPlan_Template_Validation_for_Fields);
        }

        if ( (mPlanTemplate.SVMXA360__MaintenancePlanDuration__c != null && mPlanTemplate.SVMXA360__MaintenancePlanUnitOfTime__c == null) || (mPlanTemplate.SVMXA360__MaintenancePlanDuration__c == null && mPlanTemplate.SVMXA360__MaintenancePlanUnitOfTime__c != null) ) {
            mPlanTemplate.addError(System.Label.Error_MPLAN_Unit_and_Duration_Blank);
        }

        if ( mPlanTemplate.SVMXA360__GenerationTimeframe__c < 0.5 ) {
            mPlanTemplate.SVMXA360__GenerationTimeframe__c.addError(System.Label.Error_Generation_Timeframe_Negative_Value);
        }

        if ( mPlanTemplate.SVMXA360__MaintenancePlanDuration__c != null && mPlanTemplate.SVMXA360__MaintenancePlanDuration__c.abs() != mPlanTemplate.SVMXA360__MaintenancePlanDuration__c ) {
            mPlanTemplate.SVMXA360__MaintenancePlanDuration__c.addError(System.Label.Error_MPlan_Duration_Negative_Validation);
        }

        if ( mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c != null && mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c.abs() != mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c ) {
            mPlanTemplate.SVMXA360__MaintenanceWindowStartDays__c.addError(System.Label.Error_Maintenance_Window_Negative_Validation);
        }

        if ( mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c != null && mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c.abs() != mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c ) {
            mPlanTemplate.SVMXA360__MaintenanceWindowEndDays__c.addError(System.Label.Error_Maintenance_Window_Negative_Validation);
        }

        if ( mPlanTemplate.SVMXA360__GenerationHorizon__c != null && mPlanTemplate.SVMXA360__GenerationHorizon__c.abs() != mPlanTemplate.SVMXA360__GenerationHorizon__c ) {
            mPlanTemplate.SVMXA360__GenerationHorizon__c.addError(System.Label.Error_Generation_Timeframe_Negative_Value);
        }

    }

    private void addError ( final SVMXA360__MaintenancePlanTemplate__c mPlanTemplate, String errorMessage ) {
        mPlanTemplate.SVMXA360__SvcApptGenerationMethod__c.addError(errorMessage);
    }

    private MPLN_TemplateTriggerHandler() {

    }
}