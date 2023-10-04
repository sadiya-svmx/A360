public with sharing class CreateActualsFromEstimateImpl {

    public static final String STATUS_APPROVED = 'Approved';
    public static final String RECORD_TYPE_ESTIMATE = 'Estimate';

    public CreateActualsFromEstimateImpl() {
    }

    public Common.ServiceResponse cloneEstimateLines(WorkOrder headerRecord){

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            List<SObject> sObjectList = new List<SObject>();
            Id woId = headerRecord.Id;
            Id estimateRecTypeId = SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ESTIMATE).getRecordTypeId();
            
            //Get estimate Work Order related to current Work Order
            List<WorkOrder> estimateWOList = (List<WorkOrder>)SvmxDatabase.query(
                [SELECT Id, CreatedDate
                FROM WorkOrder
                WHERE ParentWorkOrderId = :woId
                AND Status = :STATUS_APPROVED
                AND RecordTypeId = :estimateRecTypeId
                ORDER BY CreatedDate DESC
                LIMIT 1]
            );

            if(estimateWOList.isEmpty()){
                serviceResponse.success = false;
                serviceResponse.message = System.label.Error_NoEstimateWorkOrderFound;
                return serviceResponse;
            }

            Id estimateWoId = estimateWOList[0].Id;

            //Get estimate ProductConsumed
            List<ProductConsumed> prodConsumedList = (List<ProductConsumed>)SvmxDatabase.query(
                [SELECT SVMXA360__BillingType__c, Description, Discount, SVMXA360__EntitledDiscount__c, SVMXA360__EntitledPrice__c, 
                ListPrice, PricebookEntryId, Product2Id, ProductItemId, QuantityConsumed, QuantityUnitOfMeasure, Subtotal,
                SVMXA360__Surcharge__c, SVMXA360__TotalCost__c, TotalPrice, SVMXA360__UnitCost__c, UnitPrice
                FROM ProductConsumed
                WHERE WorkOrderId = :estimateWoId]
            );
            if(!prodConsumedList.isEmpty()){
                for(ProductConsumed pc : prodConsumedList){
                    ProductConsumed pcClone = pc.clone(false, false, false, false);
                    sObjectList.add(pcClone);
                }
            }

            //Get estimate WorkOrderLineItem
            List<WorkOrderLineItem> woliList = (List<WorkOrderLineItem>)SvmxDatabase.query(
                [SELECT Address, AssetId, AssetWarrantyId, SVMXA360__BillingType__c, Description, Discount, Duration, DurationType,
                EndDate, SVMXA360__EntitledDiscount__c, SVMXA360__EntitledPrice__c, SVMXA360__LineType__c, ListPrice, LocationId,
                MinimumCrewSize, SVMXA360__Overtime__c, Priority, PricebookEntryId, Quantity, RecommendedCrewSize, ServiceTerritoryId,
                StartDate, Status, StatusCategory, Subject, Subtotal, SuggestedMaintenanceDate, SVMXA360__Surcharge__c, SVMXA360__TotalCost__c, TotalPrice, 
                SVMXA360__UnitCost__c, UnitPrice, WorkTypeId
                FROM WorkOrderLineItem
                WHERE WorkOrderId = :estimateWoId]
            );
            if(!woliList.isEmpty()){
                for(WorkOrderLineItem woli : woliList){
                    WorkOrderLineItem woliClone = woli.clone(false, false, false, false);
                    sObjectList.add(woliClone);
                }
            }

            //Get estimate Expense
            List<Expense> expenseList = (List<Expense>)SvmxDatabase.query(
                [SELECT AccountId, Amount, Description, Discount, ExpenseEndDate, SVMXA360__EntitledDiscount__c, 
                SVMXA360__EntitledPrice__c, SVMXA360__ExpenseItem__c, ExpenseType, Quantity, ExpenseStartDate, Subtotal, 
                SVMXA360__Surcharge__c, Title, TotalPrice, SVMXA360__TotalCost__c, TransactionDate, SVMXA360__UnitCost__c, UnitPrice
                FROM Expense
                WHERE WorkOrderId = :estimateWoId]
            );
            if(!expenseList.isEmpty()){
                for(Expense exp : expenseList){
                    Expense expClone = exp.clone(false, false, false, false);
                    sObjectList.add(expClone);
                }
            }

            serviceResponse.success = true;
            serviceResponse.data = sObjectList;
            return serviceResponse;
        }catch(exception ex){
            throw ex;
        }
    }
}