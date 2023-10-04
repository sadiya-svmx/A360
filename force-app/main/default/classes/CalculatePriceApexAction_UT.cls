@isTest
public with sharing class CalculatePriceApexAction_UT {
    @TestSetup
    public static void createData(){
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPricebookEntry = 
        (PricebookEntry)SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String,Object>{'IsActive'=>true, 'Pricebook2Id'=>standardPricebookId, 
                                                                            'Product2Id'=>product.Id, 'UnitPrice'=>200, 'UseStandardPrice'=>false});

        Pricebook2 pricebook = 
        (Pricebook2)SvmxTestDataFactory.insertSObject('Pricebook2', new Map<String,Object>{'IsActive'=> true, 'Description'=>'Test Pricebook 1', 'Name'=> 'Test Pricebook 1'});

        PricebookEntry pricebookEntry = 
        (PricebookEntry)SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String,Object>{'IsActive'=> true, 'Pricebook2Id'=>pricebook.Id, 
                                                                            'Product2Id'=> product.Id,'UnitPrice' => 200});

        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        ServiceContract scon = 
        (ServiceContract)SvmxTestDataFactory.insertSObject('ServiceContract', new Map<String,Object>{'Name'=> 'Service Contract 1', 'AccountId'=> acc.Id});
        
        SVMXA360__ContractPriceLineItem__c cpliWOLILabor = 
        (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__EntitledDiscount__c'=>15,
                                                                                                                    'SVMXA360__Surcharge__c'=>null,
                                                                                                                    'SVMXA360__EntitledPrice__c'=>null,
                                                                                                                    'SVMXA360__ServiceContractId__c'=>scon.id,
                                                                                                                    'SVMXA360__LineType__c'=>'Labor'});
        SVMXA360__ContractPriceLineItem__c cpliPart = 
        (SVMXA360__ContractPriceLineItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItem__c', new Map<String,Object>{'SVMXA360__ProductId__c'=> product.Id, 
                                                                                                                    'SVMXA360__EntitledDiscount__c' => 10,
                                                                                                                    'SVMXA360__Surcharge__c' => null,
                                                                                                                    'SVMXA360__EntitledPrice__c' => null,
                                                                                                                    'SVMXA360__ServiceContractId__c'=>scon.id,
                                                                                                                    'SVMXA360__LineType__c' => 'Parts'});
        
        List<SVMXA360__ContractPriceLineItem__c> lstCPLIExpense = new List<SVMXA360__ContractPriceLineItem__c>();
        lstCPLIExpense.add(new SVMXA360__ContractPriceLineItem__c(SVMXA360__EntitledDiscount__c=10, SVMXA360__EntitledPrice__c=null, SVMXA360__Surcharge__c=null, 
                            SVMXA360__ServiceContractId__c=scon.id,SVMXA360__LineType__c='Expense',SVMXA360__ExpenseItem__c='Airfare'));
        lstCPLIExpense.add(new SVMXA360__ContractPriceLineItem__c(SVMXA360__EntitledDiscount__c=null, SVMXA360__EntitledPrice__c=70, SVMXA360__Surcharge__c=null, 
                            SVMXA360__ServiceContractId__c=scon.id,SVMXA360__LineType__c='Expense',SVMXA360__ExpenseItem__c='Gas'));
        lstCPLIExpense.add(new SVMXA360__ContractPriceLineItem__c(SVMXA360__EntitledDiscount__c=null, SVMXA360__EntitledPrice__c=null, SVMXA360__Surcharge__c=20, 
                            SVMXA360__ServiceContractId__c=scon.id,SVMXA360__LineType__c='Expense',SVMXA360__ExpenseItem__c='Lodging'));
        lstCPLIExpense.add(new SVMXA360__ContractPriceLineItem__c(SVMXA360__EntitledDiscount__c=5, SVMXA360__EntitledPrice__c=null, SVMXA360__Surcharge__c=null, 
                            SVMXA360__ServiceContractId__c=scon.id,SVMXA360__LineType__c='Expense'));
        
        insert lstCPLIExpense;
        
        WorkOrder workOrderRecord = new WorkOrder(Priority = 'Medium', Pricebook2Id=pricebook.Id, ServiceContractId=scon.Id);
        insert workOrderRecord;

        ProductConsumed productConsumed = new ProductConsumed();
        productConsumed.PricebookEntryId = pricebookEntry.Id;
        productConsumed.QuantityConsumed = 0;
        productConsumed.WorkOrderId = workOrderRecord.Id;
        insert productConsumed;
        
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(PricebookEntryId=pricebookEntry.Id, WorkOrderId=workOrderRecord.Id, SVMXA360__LineType__c='Labor');
        insert workOrderLineItem;

        Expense expenseAirfare = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{'TransactionDate'=> Date.today(), 'Amount'=> 50, 
                                                                                        'WorkOrderId' => workOrderRecord.Id, 'SVMXA360__ExpenseItem__c'=>'Airfare'});
        Expense expenseLodging = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{'TransactionDate'=> Date.today(), 'Amount'=> 100, 
                                                                                        'WorkOrderId' => workOrderRecord.Id, 'SVMXA360__ExpenseItem__c'=>'Lodging'});
        Expense expenseGas = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{'TransactionDate'=> Date.today(), 'Amount'=> 150, 
                                                                                        'WorkOrderId' => workOrderRecord.Id, 'SVMXA360__ExpenseItem__c'=>'Gas'});
        Expense expense = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{'TransactionDate'=> Date.today(), 'Amount'=> 150, 
                                                                                        'WorkOrderId' => workOrderRecord.Id});                                                                                        
    }

    @isTest
    static void calculatePriceWithEmptyRequest() {
        String exceptionMessage = '';
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage.contains('missing'));
    }

    @isTest
    static void calculatePriceWithNoRecords() {
        String exceptionMessage = '';
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.workOrderRecordId = [Select Id from WorkOrder].Id;
        eachParam.isServiceContractPriority = false;
        lstInputParams.add(eachParam);
        List<CalculatePriceApexAction.PriceCalRequest> lstOutputData;
        try{
            lstOutputData = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(lstOutputData.size() == lstInputParams.size());
    }

    @isTest
    static void calculatePriceWithInvalidInput() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        lstSObjects = [Select Id, PricebookEntryId, QuantityConsumed, WorkOrderId from ProductConsumed];
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.workOrderRecordId = '123456';
        eachParam.isServiceContractPriority = false;
        eachParam.lstProductConsumedRecords = lstSObjects;
        lstInputParams.add(eachParam);
        List<CalculatePriceApexAction.PriceCalRequest> lstOutputData;
        try{
            lstOutputData = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != '');
    }

    @isTest
    static void calculatePriceForProductConsumed() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        lstSObjects = [Select Id, PricebookEntryId, QuantityConsumed, WorkOrderId from ProductConsumed];
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.workOrderRecordId = [Select Id from WorkOrder].Id;
        eachParam.isServiceContractPriority = false;
        eachParam.lstProductConsumedRecords = lstSObjects;
        lstInputParams.add(eachParam);
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void calculateDiscountForWOLI() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        lstSObjects = [Select Id, SVMXA360__LineType__c, PricebookEntryId, WorkOrderId from WorkOrderLineItem];
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.lstWOLIRecords = lstSObjects;
        lstInputParams.add(eachParam);
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void calculateDiscountPriceForExpense() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        lstSObjects = [Select Id, TransactionDate, Amount, WorkOrderId, SVMXA360__ExpenseItem__c from Expense];
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.lstExpenseRecords = lstSObjects;
        lstInputParams.add(eachParam);
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void calculatePriceForPCWithWarranty(){
        Product2 prod = [Select Id from Product2 limit 1];
        Account acc = [Select Id from Account limit 1];
        Contact cont = (Contact) SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => prod.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});

        WarrantyTerm warrTerm = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', getWarrantyTemplateField());
        AssetWarranty assetWarranty = 
        (AssetWarranty)SvmxTestDataFactory.insertSObject('AssetWarranty', new Map<String,Object>{'AssetId'=>asst.Id, 'StartDate'=>Date.today(), 'EndDate'=> Date.today().addDays(20), 'PartsCovered'=>100, 'WarrantyTermId'=>warrTerm.Id});

        Pricebook2 pricebook = [Select Id from Pricebook2 where Name = 'Test Pricebook 1' limit 1];
        PricebookEntry pricebookEntry = [Select Id from PricebookEntry where Pricebook2Id = :pricebook.Id limit 1];
        
        WorkOrder workOrderRecord = new WorkOrder(Priority='Medium', AssetWarrantyId=assetWarranty.Id, Pricebook2Id=pricebook.Id);
        insert workOrderRecord;

        List<SObject> lstSObjects = new List<SObject>();
        
        ProductConsumed productConsumed = new ProductConsumed();
        productConsumed.PricebookEntryId = pricebookEntry.Id;
        productConsumed.QuantityConsumed = 0;
        productConsumed.WorkOrderId = workOrderRecord.Id;
        insert productConsumed;
        
        lstSObjects.add(productConsumed);
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.isServiceContractPriority = false;
        eachParam.lstProductConsumedRecords = lstSObjects;
        lstInputParams.add(eachParam);
        String exceptionMessage = '';
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void calculatePriceForWOLIWithWarranty(){
        Product2 prod = [Select Id from Product2 limit 1];
        Account acc = [Select Id from Account limit 1];
        Contact cont = (Contact) SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => prod.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});

        WarrantyTerm warrTerm = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', getWarrantyTemplateField());
        AssetWarranty assetWarranty = 
        (AssetWarranty)SvmxTestDataFactory.insertSObject('AssetWarranty', new Map<String,Object>{'AssetId'=>asst.Id, 'StartDate'=>Date.today(), 'EndDate'=> Date.today().addDays(20), 'PartsCovered'=>100, 'WarrantyTermId'=>warrTerm.Id});

        Pricebook2 pricebook = [Select Id from Pricebook2 where Name = 'Test Pricebook 1' limit 1];
        PricebookEntry pricebookEntry = [Select Id from PricebookEntry where Pricebook2Id = :pricebook.Id limit 1];
        
        WorkOrder workOrderRecord = new WorkOrder(Priority='Medium', AssetWarrantyId=assetWarranty.Id, Pricebook2Id=pricebook.Id);
        insert workOrderRecord;

        List<SObject> lstSObjects = new List<SObject>();
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(PricebookEntryId=pricebookEntry.Id, WorkOrderId=workOrderRecord.Id, SVMXA360__LineType__c='Labor');
        insert workOrderLineItem;

        lstSObjects.add(workOrderLineItem);
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.isServiceContractPriority = false;
        eachParam.lstWOLIRecords = lstSObjects;
        lstInputParams.add(eachParam);
        String exceptionMessage = '';
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void calculatePriceForExpenseWithWarranty(){
        Product2 prod = [Select Id from Product2 limit 1];
        Account acc = [Select Id from Account limit 1];
        Contact cont = (Contact) SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => prod.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});

        WarrantyTerm warrTerm = (WarrantyTerm) SvmxTestDataFactory.insertSObject('WarrantyTerm', getWarrantyTemplateField());
        AssetWarranty assetWarranty = 
        (AssetWarranty)SvmxTestDataFactory.insertSObject('AssetWarranty', new Map<String,Object>{'AssetId'=>asst.Id, 'StartDate'=>Date.today(), 'EndDate'=> Date.today().addDays(20), 'ExpensesCovered'=>100, 'WarrantyTermId'=>warrTerm.Id});

        WorkOrder workOrderRecord = new WorkOrder(Priority = 'Medium', AssetWarrantyId=assetWarranty.Id);
        insert workOrderRecord;

        Expense expenseRecord = (Expense) SvmxTestDataFactory.insertSObject('Expense', new Map<String,Object>{'TransactionDate'=> Date.today(), 
                                                                                        'Amount'=>200, 'WorkOrderId' => workOrderRecord.Id,
                                                                                        'SVMXA360__ExpenseItem__c'=>'Lodging'});
        List<SObject> lstSObjects = new List<SObject>();
        lstSObjects.add(expenseRecord);
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        eachParam.lstExpenseRecords = lstSObjects;
        lstInputParams.add(eachParam);
        String exceptionMessage = '';
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void calculatePriceForWONotEntitled() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        lstSObjects = [Select Id, PricebookEntryId, QuantityConsumed, WorkOrderId from ProductConsumed];
        List<CalculatePriceApexAction.PriceCalRequest> lstInputParams = new List<CalculatePriceApexAction.PriceCalRequest>();
        CalculatePriceApexAction.PriceCalRequest eachParam = new CalculatePriceApexAction.PriceCalRequest();
        WorkOrder wo = [Select Id, ServiceContractId from WorkOrder];
        wo.ServiceContractId = null;
        update wo;
        eachParam.workOrderRecordId = wo.Id;
        eachParam.isServiceContractPriority = false;
        eachParam.lstProductConsumedRecords = lstSObjects;
        lstInputParams.add(eachParam);
        try{
            lstInputParams = CalculatePriceApexAction.calculatePrice(lstInputParams);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    static Map<String,Object> getWarrantyTemplateField(){
        Map<String,Object> mapFieldValue = new Map<String,Object>();
        mapFieldValue.put('EffectiveStartDate', 'Install Date');
        mapFieldValue.put('WarrantyDuration', 1);
        mapFieldValue.put('ExpensesCoveredDuration', 1);
        mapFieldValue.put('LaborCoveredDuration', 1);
        mapFieldValue.put('PartsCoveredDuration', 1);
        mapFieldValue.put('IsActive', true);
        mapFieldValue.put('LaborCovered', 50);
        mapFieldValue.put('PartsCovered', 50);
        mapFieldValue.put('WarrantyUnitOfTime', 'Years');
        mapFieldValue.put('ExpensesCoveredUnitOfTime', 'Years');
        mapFieldValue.put('LaborCoveredUnitOfTime', 'Years');
        mapFieldValue.put('PartsCoveredUnitOfTime', 'Years');
        return mapFieldValue;
    }
}