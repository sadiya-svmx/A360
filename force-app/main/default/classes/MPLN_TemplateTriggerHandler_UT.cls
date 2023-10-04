/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is the UT for the MPLN_TemplateTriggerHandler, MPlan_Template_Trigger1 and ApplicableProduct_Trigger1. 
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Soumyaranjan Pati       19 Apr 2021     Created.
 *****************************************************************************************************/
@IsTest
public with sharing class MPLN_TemplateTriggerHandler_UT {
    @testSetup public static void setup() {
        SVMXA360__MaintenancePlanTemplate__c mpTemplate = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c', 
        new Map<String,Object>{
            'Name' => 'TestTemplate',
            'SVMXA360__MaintenancePlanDuration__c' => 2,
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Years',
            'SVMXA360__IsActive__c' => true,
            'SVMXA360__WorkOrderGenerationMethod__c' => 'WorkOrderPerAsset',
            'SVMXA360__SvcApptGenerationMethod__c' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true,
            'SVMXA360__GenerationTimeframe__c' => 1
        });

        WorkType workTypeRecord = (WorkType) SvmxTestDataFactory.insertSObject( 'WorkType', 
        new Map<String,Object>{
            'Name' => 'TestWorkType',
            'ShouldAutoCreateSvcAppt' => true,
            'EstimatedDuration' => 1.00,
            'DurationType' => 'Hours',
            'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1
        });

        SVMXA360__ApplicableProduct__c applicableProduct = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ApplicableProduct__c', 
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ProductFamily__c' => 'Turbines'
        });
        

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplate = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c', 
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProduct.Id,
            'Name' => 'Test Workrule Template',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => 'FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;'
        });

        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', 
        new Map<String,Object>{
            'Name' => 'TestProduct',
            'IsActive' => true
        });
        
        Product2 product1 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 600',
            'ProductCode' => 'SPA600',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 600'  
        });

        Product2 product2 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 700',
            'ProductCode' => 'SPA700',
            'IsActive' => true,
            'Family' => 'Laptops',
            'StockKeepingUnit' => 'Solar Panel 700'
        });

        Product2 product3 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 800',
            'ProductCode' => 'SPA800',
            'IsActive' => true,
            'Family' => 'Laptops',
            'StockKeepingUnit' => 'Solar Panel 800'
        });
        
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account', new Map<String, Object> {
            'Name' =>  'Dream House'
        });
        
        Asset newAsset1 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 600', 
            'Product2Id' => product1.Id, 
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today() 
        });
        
        Asset newAsset2 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 700', 
            'Product2Id' => product2.Id, 
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today() 
        });

        Asset newAsset3 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 800', 
            'Product2Id' => product3.Id, 
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today(),
            'SerialNumber' => 'SP8001' 
        });

        Asset newAsset4 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 800 C1', 
            'Product2Id' => product3.Id, 
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today(),
            'SerialNumber' => 'SP8001C1',
            'ParentId' =>  newAsset3.id
        });

        WorkType workType = (WorkType) SvmxTestDataFactory.insertSObject('WorkType', new Map<String,Object>{
            'Name'=> 'Solar Maintenance', 
            'EstimatedDuration' => 1, 
            'DurationType'=>'Hours',
            'ShouldAutoCreateSvcAppt' => true,
            'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1
        });

        SVMXA360__MaintenancePlanTemplate__c  maintenanceTemplate = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject('SVMXA360__MaintenancePlanTemplate__c', new Map<String,Object>{
            'Name'=> 'Solar Panel Template', 
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Months', 
            'SVMXA360__GenerationHorizon__c' => 3,
            'SVMXA360__GenerationTimeframe__c' => 3,
            'SVMXA360__GenerationTimeframeType__c' => 'Months',
            'SVMXA360__IsActive__c' => true,
            'SVMXA360__MaintenancePlanDuration__c' => 3,
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Months',
            'SVMXA360__MaintenanceWindowEndDays__c' => 3,
            'SVMXA360__MaintenanceWindowStartDays__c' => 3,
            'SVMXA360__WorkTypeId__c' => workType.id,
            'SVMXA360__WorkOrderGenerationMethod__c' => 'WorkOrderPerAsset',
            'SVMXA360__SvcApptGenerationMethod__c' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true
        });

        SVMXA360__ApplicableProduct__c applicableProduct1 = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject('SVMXA360__ApplicableProduct__c', new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c'=> maintenanceTemplate.id, 
            'SVMXA360__ProductId__c' => product1.Id, 
            'SVMXA360__ProductFamily__c' => null , 
            'SVMXA360__WorkTypeId__c' => workType.id
        });

        Schema.Location locationVar = (Schema.Location) SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{
            'Name'=> 'Test location', 
            'LocationType' => 'Van',
            'ExternalReference' => 'test123'
        });

        AssociatedLocation assoLocation = (AssociatedLocation) SvmxTestDataFactory.insertSObject('AssociatedLocation', new Map<String,Object>{
            'ParentRecordId'=> acc.id, 
            'LocationId' => locationVar.id
        });
    }

    @IsTest
    static void testApplicableProductTrigger(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__ProductFamily__c, SVMXA360__ProductId__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        Product2 productData = [SELECT id from Product2 where Name =: 'TestProduct'];
        Test.startTest();
        
        update applicableProductRecord;
        
        String response = MPLN_TemplateTriggerHandler.getInstance().generateAPUniqueKey( applicableProductRecord );
        System.assert(response != null);
    

        Test.stopTest();
    }

    @IsTest
    static void testApplicableProductTriggerwithError(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__ProductFamily__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        Product2 productData = [SELECT id from Product2 where Name =: 'TestProduct'];
        Test.startTest();
        
        
        
        try{
            applicableProductRecord.SVMXA360__ProductId__c = productData.Id;
            update applicableProductRecord;

            String response = MPLN_TemplateTriggerHandler.getInstance().generateAPUniqueKey( applicableProductRecord );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testApplicableProductTriggerwithError2(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__ProductFamily__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        Test.startTest();

        try{
            applicableProductRecord.SVMXA360__ProductId__c = null;
            applicableProductRecord.SVMXA360__ProductFamily__c = null;
            update applicableProductRecord;

            String response = MPLN_TemplateTriggerHandler.getInstance().generateAPUniqueKey( applicableProductRecord );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testValidateMPTemplateforWO(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        
        Test.startTest();
        
        
        mpTemplate.SVMXA360__WorkOrderGenerationMethod__c = 'WorkOrderPerAsset';
        mpTemplate.SVMXA360__SvcApptGenerationMethod__c = 'SvcApptPerWorkOrderLineItem';
        mpTemplate.SVMXA360__MaintenancePlanDuration__c = -2;
        mpTemplate.SVMXA360__MaintenancePlanUnitOfTime__c = null;
        mpTemplate.SVMXA360__GenerationTimeframe__c = -2;
        mpTemplate.SVMXA360__MaintenanceWindowStartDays__c = -2;
        mpTemplate.SVMXA360__MaintenanceWindowEndDays__c = -2;
        mpTemplate.SVMXA360__GenerationHorizon__c = -2;
        
        try{
            MPLN_TemplateTriggerHandler.getInstance().validateMPlanTemplateRecords( mpTemplate );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('Exception') != -1);
        }

        try{
            mpTemplate.SVMXA360__WorkOrderGenerationMethod__c = null;
            MPLN_TemplateTriggerHandler.getInstance().validateMPlanTemplateRecords( mpTemplate );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('Exception') != -1);
        }

        try{
            mpTemplate.SVMXA360__WorkOrderGenerationMethod__c = 'WorkOrderLineItemPerAsset';
            mpTemplate.SVMXA360__SvcApptGenerationMethod__c = null;
            MPLN_TemplateTriggerHandler.getInstance().validateMPlanTemplateRecords( mpTemplate );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('Exception') != -1);
        }
        try{
            mpTemplate.SVMXA360__GenerationTimeframe__c = 0;
            MPLN_TemplateTriggerHandler.getInstance().validateMPlanTemplateRecords( mpTemplate );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('Exception') != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testValidateMPTemplateforApt(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        
        Test.startTest();
        
        mpTemplate.SVMXA360__WorkOrderGenerationMethod__c = 'WorkOrderLineItemPerAsset';
        mpTemplate.SVMXA360__SvcApptGenerationMethod__c = 'SvcApptPerWorkOrder';
        mpTemplate.SVMXA360__MaintenancePlanDuration__c = -2;
        mpTemplate.SVMXA360__MaintenancePlanUnitOfTime__c = null;
        mpTemplate.SVMXA360__GenerationTimeframe__c = -2;
        mpTemplate.SVMXA360__MaintenanceWindowStartDays__c = -2;
        mpTemplate.SVMXA360__MaintenanceWindowEndDays__c = -2;
        mpTemplate.SVMXA360__GenerationHorizon__c = -2;
        
        try{
            MPLN_TemplateTriggerHandler.getInstance().validateMPlanTemplateRecords( mpTemplate );
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf('Exception') != -1);
        }
        
        Test.stopTest();
    }
    public MPLN_TemplateTriggerHandler_UT() {

    }
}