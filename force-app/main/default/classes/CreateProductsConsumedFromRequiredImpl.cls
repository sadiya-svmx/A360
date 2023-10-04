public with sharing class CreateProductsConsumedFromRequiredImpl {
    public CreateProductsConsumedFromRequiredImpl() {
    }

    public Common.ServiceResponse mapProductRequired(WorkOrder headerRecord){

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            Id woId = headerRecord.Id;
            Map<Id, Id> prodPriceBookEntryMap = new Map<Id, Id>();
            Set<Id> reqProdSet = new Set<Id>();
            List<Id> reqProdList = new List<Id>();
            List<ProductConsumed> newProdConsumedList = new List<ProductConsumed>();
            
            String woQuery ='SELECT Id,Pricebook2Id ';
            if(UserInfo.isMultiCurrencyOrganization()){
                woQuery += ',CurrencyIsoCode ';
            }
            woQuery += 'FROM WorkOrder ';
            woQuery += 'WHERE Id = \'' + woId + '\'';
            List<WorkOrder> woList = (List<WorkOrder>)SvmxDatabase.query(woQuery);
            WorkOrder woObj = woList[0];
            
            String woCurrencyCode;
            if(UserInfo.isMultiCurrencyOrganization()){
                woCurrencyCode = String.valueOf(woObj.get('CurrencyIsoCode'));
            }

            if(woObj.Pricebook2Id == null){
                serviceResponse.success = false;
                serviceResponse.message = System.label.Info_WorkOrderPricebookRequired;
                return serviceResponse;
            }

            List<ProductRequired> prodRequiredList = (List<ProductRequired>)SvmxDatabase.query(
                [SELECT Id, Product2Id, QuantityRequired
                FROM ProductRequired
                WHERE ParentRecordId = :woId]
            );
            
            if(prodRequiredList.isEmpty()){
                serviceResponse.success = false;
                serviceResponse.message = System.label.Error_NoRequiredProductsFound;
                return serviceResponse;
            } else {
                for(ProductRequired prodReq : prodRequiredList){
                    reqProdSet.add(prodReq.Product2Id);
                }
            }
            reqProdList.addAll(reqProdSet);

            List<String> whereClause = new List<String>{
                'Pricebook2Id = \'' + woObj.Pricebook2Id + '\'',
                'Product2Id IN (\'' + String.join(reqProdList, '\',\'') + '\')',
                'IsActive = true'
            };

            if (UserInfo.isMultiCurrencyOrganization() && !String.isBlank(woCurrencyCode)) {
                whereClause.add('CurrencyIsoCode = \'' + woCurrencyCode + '\'');
            }

            String pbeQuery = 'SELECT Id, Pricebook2Id, Product2Id ' +
                                'FROM PricebookEntry ' +
                                'WHERE ' + String.join(whereClause, ' AND ');

            List<PricebookEntry> priceBookEntryList = (List<PricebookEntry>)SvmxDatabase.query(pbeQuery);

            if(priceBookEntryList.isEmpty()){
                serviceResponse.success = false;
                serviceResponse.message = System.label.Info_WorkOrderPricebookWarning;
                return serviceResponse;
            }
            
            for(PricebookEntry pbe : priceBookEntryList){
                prodPriceBookEntryMap.put(pbe.Product2Id, pbe.Id);
            }

            for(ProductRequired prodReq : prodRequiredList){
                if(prodPriceBookEntryMap.containsKey(prodReq.Product2Id)){
                    ProductConsumed newProdCon = new ProductConsumed();
                    newProdCon.PricebookEntryId = prodPriceBookEntryMap.get(prodReq.Product2Id);
                    newProdCon.QuantityConsumed = prodReq.QuantityRequired;
                    newProdConsumedList.add(newProdCon);
                } 
            }

            serviceResponse.success = true;
            serviceResponse.data = newProdConsumedList;
            return serviceResponse;
        }catch(exception ex){
            throw ex;
        }
    }
}