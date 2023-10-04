public with sharing class WARR_ManageWarrantyServiceImpl {

    /**This method does the job of creating Warranties for the Assets being passed in the parameters.
     *@param inputParams parameter containing asset record(s) and optional warranty configuration record
     */
    private static final SvmxLogger logger = SvmxLogger.getLogger(SvmxLogger.Application.Warranty);

    public List<SObject> createWarranty(List<SObject> lstAssetRecords, Map<String,String> mapFieldMapping, String termToWarrantyMappingId){
        system.debug(LoggingLevel.INFO,'WARR_ManageWarrantyServiceImpl -createWarranty - enter. CPU time = ' + Limits.getCpuTime() + '; SOQLs = ' + Limits.getQueries());
        List<AssetWarranty> lstAssetWarrantyRecords = new List<AssetWarranty>();
        WARR_ManageWarrantyUtils utils = new WARR_ManageWarrantyUtils();
        Map<Id,Asset> mapIdToAsset = utils.getAssetMap(lstAssetRecords);
        Set<Id> setProductIds = utils.getProductIdsFromAsset(mapIdToAsset.values());
        if (!setProductIds.isEmpty()) {
            Map<String, String> mapProductIdToFamily = utils.getProductIdFamilyMap(setProductIds);
            List<ProductWarrantyTerm> lstProductWarrantyTerms = getProductWarrantyTermRecords(setProductIds, mapProductIdToFamily.values());
            if (!lstProductWarrantyTerms.isEmpty()) {
                Map<Id,Id> mapWarrTermIdToExprId = getTermIdToExpression(lstProductWarrantyTerms);
                Map<Id,Set<Id>> mapQualifiedTermToAsset = getQualifiedTerms(mapIdToAsset.keySet(), mapWarrTermIdToExprId);
                Map<Id,Set<Id>> mapExistingTermIdToAssetId = getExistingWarranties(mapIdToAsset.keySet());

                mapQualifiedTermToAsset = removeExistingWarranties(mapQualifiedTermToAsset, mapExistingTermIdToAssetId);

                Map<Id,WarrantyTerm> mapIdToWarrantyTerm = getWarrantyTermRecords(mapQualifiedTermToAsset.keySet(), termToWarrantyMappingId);
                Map<String, List<AssetWarranty>> mapTermToAssetWarranty = getMapOfTermToAssetWarranty(mapQualifiedTermToAsset, mapIdToAsset.values(), mapProductIdToFamily, lstProductWarrantyTerms);

                for (String eachTermId : mapIdToWarrantyTerm.keySet()) {
                    if (!mapTermToAssetWarranty.containsKey(eachTermId)) {
                        mapIdToWarrantyTerm.remove(eachTermId);
                    }
                }
                
                mapTermToAssetWarranty = applyMapping(termToWarrantyMappingId, mapTermToAssetWarranty, mapIdToWarrantyTerm.values());
                lstAssetWarrantyRecords = getAssetWarrantyRecords(mapTermToAssetWarranty, mapIdToWarrantyTerm.values(), mapFieldMapping, mapIdToAsset);
                lstAssetWarrantyRecords = createAssetWarrantyRecords(lstAssetWarrantyRecords);
            } else {
                system.debug(LoggingLevel.INFO,'No matching Product Warranty Terms');
                logger.error(System.Label.Error_NoMatchingProductWarrantyTerms);
            }
        } else{
            system.debug(LoggingLevel.INFO,'No Products in Asset');
            logger.error(System.Label.Error_NoProductLookupInAsset);
        }
        system.debug(LoggingLevel.INFO,'WARR_ManageWarrantyServiceImpl -createWarranty - exit. CPU time = ' + Limits.getCpuTime() + '; SOQLs = ' + Limits.getQueries());
        return lstAssetWarrantyRecords;
    }

    public AssetWarranty createManualWarranty(WarrantyTerm warrantyTerm, Asset assetRecord, SVMXA360__CONF_WarrantyConfig__c warrantyConfigRule){
        system.debug(LoggingLevel.INFO, 'Warranty Term record = ' + warrantyTerm + 'assetRecord = ' + assetRecord);
        String termToWarrantyMappingId;
        Map<String,String> mapFieldMapping = new Map<String,String>{'Install Date'=>'InstallDate','Purchase Date'=>'PurchaseDate'};
        if(warrantyConfigRule != null){
            termToWarrantyMappingId = warrantyConfigRule.SVMXA360__ObjectMapping__c;
            if(warrantyConfigRule.SVMXA360__EffectiveFromConfig__c != null){
                mapFieldMapping = (Map<String, String>)JSON.deserialize(warrantyConfigRule.SVMXA360__EffectiveFromConfig__c, Map<String,String>.class);
            }
            system.debug(LoggingLevel.INFO, 'termToWarrantyMappingId = ' + termToWarrantyMappingId);
        } else {
            system.debug(LoggingLevel.INFO, 'No Config rule defined');
        }
        AssetWarranty assetWarranty;
        try {
            Map<Id,Set<Id>> mapExistingTermIdToAssetId = getExistingWarranties(new Set<Id>{assetRecord.Id});
            if(mapExistingTermIdToAssetId.containsKey(warrantyTerm.Id) && mapExistingTermIdToAssetId.get(warrantyTerm.Id).contains(assetRecord.Id)) {
                system.debug(LoggingLevel.INFO, 'Warranty exists for this Asset');
                throw new SvmxSystem.SvmxNestedException('Warranty exists for this Asset with this selected Warranty Term');
            } else {
                Map<String, List<AssetWarranty>> mapTermToAssetWarranty = new Map<String, List<AssetWarranty>>();
                assetWarranty = new AssetWarranty(AssetId=assetRecord.Id);
                mapTermToAssetWarranty.put(warrantyTerm.Id, new List<AssetWarranty>{assetWarranty});
                mapTermToAssetWarranty = applyMapping(termToWarrantyMappingId, mapTermToAssetWarranty, new List<WarrantyTerm>{warrantyTerm});
                assetWarranty = getAssetWarrantyRecord(warrantyTerm, assetRecord, mapTermToAssetWarranty.get(warrantyTerm.Id)[0], mapFieldMapping);
                assetWarranty = createAssetWarranty(assetWarranty);
            }    
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception during warranty creation ' + ex.getMessage());
            throw ex;
        }
        return assetWarranty;
    }

    public List<ProductWarrantyTerm> getProductWarrantyTermRecords(Set<Id> setProductIds, List<String> lstProductFamily) {
        String includeProductCriteria = '';
        if (!setProductIds.isEmpty()) {
            includeProductCriteria += 'CoveredProductId IN :setProductIds';
        }
        if(!lstProductFamily.isEmpty()){
            if(!String.isBlank(includeProductCriteria)){
                includeProductCriteria += ' OR ';    
            }
            includeProductCriteria += ' CoveredProductFamily IN :lstProductFamily';
        }
        String whereClause = 'WarrantyTerm.EffectiveStartDate != null and WarrantyTerm.IsActive = true';
        String soqlForWarrantyTemplateProduct = 'Select ' + COMM_Constants.WARRANTY_TERM_PRODUCT + ' from ProductWarrantyTerm WHERE (' + whereClause + ')';
        if (!String.isBlank(includeProductCriteria)) {
            soqlForWarrantyTemplateProduct += ' AND (' + includeProductCriteria + ')';
        }
        system.debug(LoggingLevel.INFO, 'soqlForWarrantyTemplateProduct = ' + soqlForWarrantyTemplateProduct);
        List<ProductWarrantyTerm> lstWarrantyTermProduct = SvmxDatabase.query(Database.query(soqlForWarrantyTemplateProduct));
        return lstWarrantyTermProduct;
    }

    public Map<Id,Id> getTermIdToExpression(List<ProductWarrantyTerm> lstProductWarrantyTerms){
        Map<Id,Id> mapWarrTermIdToExprId = new Map<Id,Id>();
        for(ProductWarrantyTerm eachWarrProductTerm : lstProductWarrantyTerms){
            mapWarrTermIdToExprId.put(eachWarrProductTerm.WarrantyTermId, (Id)eachWarrProductTerm.getSObject('WarrantyTerm').get('SVMXA360__AssetExpression__c'));
        }
        return mapWarrTermIdToExprId;
    }

    public Map<Id,Set<Id>> getQualifiedTerms(Set<Id> setAssetIds, Map<Id,Id> mapWarrTermIdToExprId){
        Map<Id,Set<Id>> mapQualifiedTermToAsset = new Map<Id,Set<Id>>();
        system.debug(LoggingLevel.INFO, 'mapWarrTermIdToExprId size = ' + mapWarrTermIdToExprId.size() + '; mapWarrTermIdToExprId = ' + mapWarrTermIdToExprId);
        Map<String,List<Adm.Context>> assetAndTermContext = new Map<String,List<Adm.Context>>();
        for(Id eachAssetId : setAssetIds){
            for(Id eachWarrTermId : mapWarrTermIdToExprId.keySet()){
                Adm.Context contextOfTermAndExpr = new Adm.Context();
                contextOfTermAndExpr.sObjectRecId = String.valueOf(eachWarrTermId);
                if(mapWarrTermIdToExprId.get(eachWarrTermId) != null){
                    contextOfTermAndExpr.expressionId = String.valueOf(mapWarrTermIdToExprId.get(eachWarrTermId));
                    if(!assetAndTermContext.containsKey(eachAssetId)){
                        assetAndTermContext.put(eachAssetId, new List<Adm.Context>());
                    }
                    assetAndTermContext.get(eachAssetId).add(contextOfTermAndExpr);
                } else{
                    if(!mapQualifiedTermToAsset.containsKey(eachWarrTermId)){
                        mapQualifiedTermToAsset.put(eachWarrTermId, new Set<Id>());
                    }
                    if(!mapQualifiedTermToAsset.get(eachWarrTermId).contains(eachAssetId)){
                        mapQualifiedTermToAsset.get(eachWarrTermId).add(eachAssetId);
                    }
                }
                system.debug(LoggingLevel.INFO, 'assetAndTermContext = ' + assetAndTermContext);
            }
        }
        system.debug(LoggingLevel.INFO, 'assetAndTermContext size = ' + assetAndTermContext.size() + '; assetAndTermContext = ' + assetAndTermContext);
        if(!assetAndTermContext.isEmpty()){
            assetAndTermContext = (new ADM_ExpressionHandler()).matchRecordsForExpressions(assetAndTermContext);
            for(String eachAssetId :assetAndTermContext.keySet()){
                for(Adm.Context eachTerm :assetAndTermContext.get(eachAssetId)){
                    Id warrantyTermId = Id.valueOf(eachTerm.sObjectRecId);
                    if(!mapQualifiedTermToAsset.containsKey(warrantyTermId)){
                        mapQualifiedTermToAsset.put(warrantyTermId, new Set<Id>());
                    }
                    if(!mapQualifiedTermToAsset.get(warrantyTermId).contains(eachAssetId)){
                        mapQualifiedTermToAsset.get(warrantyTermId).add(eachAssetId);
                    }
                }
            }
        }
        system.debug(LoggingLevel.INFO, 'mapQualifiedTermToAsset size = ' + mapQualifiedTermToAsset.size() + '; mapQualifiedTermToAsset = ' + mapQualifiedTermToAsset);
        return mapQualifiedTermToAsset;
    }

    public Map<Id,Set<Id>> getExistingWarranties(Set<Id> setAssetIds){
        Map<Id,Set<Id>> mapExistingTermIdToAssetId = new Map<Id,Set<Id>>();
        for(AssetWarranty eachWarranty : (List<AssetWarranty>)SvmxDatabase.query([Select Id, AssetId, WarrantyTermId, Asset.Product2Id from AssetWarranty where AssetId IN :setAssetIds and EndDate >= TODAY])){
            if(!mapExistingTermIdToAssetId.containsKey(eachWarranty.WarrantyTermId)){
                mapExistingTermIdToAssetId.put(eachWarranty.WarrantyTermId, new Set<Id>());
            }
            mapExistingTermIdToAssetId.get(eachWarranty.WarrantyTermId).add(eachWarranty.AssetId);
        }
        system.debug(LoggingLevel.INFO, 'mapExistingTermIdToAssetId = ' + mapExistingTermIdToAssetId);
        return mapExistingTermIdToAssetId;
    }

    public Map<Id,WarrantyTerm> getWarrantyTermRecords(Set<Id> setQualifiedWarrantyTermIds, String termToWarrantyMappingId){
        String whereClause = '(EffectiveStartDate != null and IsActive = true) Order by WarrantyTermName';
        List<WarrantyTerm> lstWarrantyTerms;
        if(!String.isBlank(termToWarrantyMappingId)){
            lstWarrantyTerms = (new CONF_ObjectMappingHandler()).retrieveSourceRecords(termToWarrantyMappingId, new List<String>((List<String>)new List<Id>(setQualifiedWarrantyTermIds)), COMM_Constants.WARRANTY_TERM_FIELDS.trim().split(','), whereClause);
        } else{
            lstWarrantyTerms = SvmxDatabase.query(Database.query('Select ' + COMM_Constants.WARRANTY_TERM_FIELDS + ' from WarrantyTerm where ID IN :setQualifiedWarrantyTermIds and ' + whereClause));
        }
        Map<Id,WarrantyTerm> mapIdToWarrantyTerm = new Map<Id,WarrantyTerm>();
        for(WarrantyTerm eachWarrantyTerm : lstWarrantyTerms){
            mapIdToWarrantyTerm.put(eachWarrantyTerm.Id, eachWarrantyTerm);
        }
        return mapIdToWarrantyTerm;
    }

    private Map<Id,Set<Id>> removeExistingWarranties(Map<Id,Set<Id>> mapQualifiedTermToAsset, Map<Id,Set<Id>> mapExistingTermIdToAssetId) {
        for (Id eachQualifiedTerm : mapQualifiedTermToAsset.keySet()) {
            if (mapExistingTermIdToAssetId.containsKey(eachQualifiedTerm)) {
                if (mapQualifiedTermToAsset.get(eachQualifiedTerm) != null) {
                    mapQualifiedTermToAsset.get(eachQualifiedTerm).removeAll(mapExistingTermIdToAssetId.get(eachQualifiedTerm));  
                }
            }
        }
        system.debug(LoggingLevel.INFO, 'mapQualifiedTermToAsset size = ' + mapQualifiedTermToAsset.size() + '; mapQualifiedTermToAsset = ' + mapQualifiedTermToAsset);
        return mapQualifiedTermToAsset;
    }

    private Map<String, List<AssetWarranty>> getMapOfTermToAssetWarranty(Map<Id,Set<Id>> mapQualifiedTermToAsset, List<Asset> lstAssetRecords, 
                                                                        Map<String,String> mapProductIdToFamily, List<ProductWarrantyTerm> lstProductWarrantyTerms){
        Map<String, List<AssetWarranty>> mapTermToAssetWarranty = new Map<String, List<AssetWarranty>>();
        Map<String, Set<String>> mapTermToAsset = new Map<String, Set<String>>();
        
        for (Asset eachAsset : lstAssetRecords) {
            for (ProductWarrantyTerm eachWarrTermProduct : lstProductWarrantyTerms) {
                Set<Id> setAssetIds = mapQualifiedTermToAsset.get(eachWarrTermProduct.WarrantyTermId);
                if (setAssetIds != null && setAssetIds.contains(eachAsset.Id) && mapQualifiedTermToAsset.keySet().contains(eachWarrTermProduct.WarrantyTermId)) {
                    system.debug(LoggingLevel.INFO, 'Warranty Term Id = ' + eachWarrTermProduct.WarrantyTermId + '; Asset is:' + eachAsset.Id);
                    if ((eachWarrTermProduct.CoveredProductId != null && eachWarrTermProduct.CoveredProductId == eachAsset.Product2Id) 
                    || (eachWarrTermProduct.CoveredProductFamily != null && eachWarrTermProduct.CoveredProductFamily == mapProductIdToFamily.get(eachAsset.Product2Id))) {
                        if (!(mapTermToAsset.containsKey(eachWarrTermProduct.WarrantyTermId) && mapTermToAsset.get(eachWarrTermProduct.WarrantyTermId).contains(eachAsset.Id))) {
                            if(!mapTermToAssetWarranty.containsKey(eachWarrTermProduct.WarrantyTermId)){
                                mapTermToAssetWarranty.put(eachWarrTermProduct.WarrantyTermId, new List<AssetWarranty>());
                            }
                            mapTermToAssetWarranty.get(eachWarrTermProduct.WarrantyTermId).add(new AssetWarranty(AssetId = eachAsset.Id));
                        
                            if(!mapTermToAsset.containsKey(eachWarrTermProduct.WarrantyTermId)){
                                mapTermToAsset.put(eachWarrTermProduct.WarrantyTermId, new Set<String>());
                            }
                            mapTermToAsset.get(eachWarrTermProduct.WarrantyTermId).add(eachAsset.Id);
                        }
                    }
                }
            }
        }
        
        system.debug(LoggingLevel.INFO, 'mapTermToAssetWarranty size = ' + mapTermToAssetWarranty.size() + '; mapTermToAssetWarranty = ' + mapTermToAssetWarranty);
        return mapTermToAssetWarranty;
    }

    public Map<String, List<AssetWarranty>> applyMapping(String termToWarrantyMappingId, Map<String, List<AssetWarranty>> mapTermToAssetWarranty, List<WarrantyTerm> lstWarrantyTerms){
        if(!String.isBlank(termToWarrantyMappingId) && !lstWarrantyTerms.isEmpty() && !String.isBlank(termToWarrantyMappingId)){
            mapTermToAssetWarranty = (new CONF_ObjectMappingHandler()).applyObjectMapping(termToWarrantyMappingId, mapTermToAssetWarranty, lstWarrantyTerms);
        }
        system.debug(LoggingLevel.INFO, 'mapTermToAssetWarranty = ' + mapTermToAssetWarranty);
        return mapTermToAssetWarranty;
    }

    public List<AssetWarranty> getAssetWarrantyRecords(Map<String,List<AssetWarranty>> mapTermToAssetWarranty, List<WarrantyTerm> lstWarrantyTerms, Map<String,String> mapFieldMapping, Map<Id,Asset> mapIdToAsset){
        List<AssetWarranty> lstWarranties = new List<AssetWarranty>();
        Map<Id, Asset> mapAssetToUpdate = new Map<Id, Asset>();
        for(WarrantyTerm eachTerm : lstWarrantyTerms){
            system.debug(LoggingLevel.INFO, 'eachTerm = ' + eachTerm);
            for(AssetWarranty eachAssetWarranty : mapTermToAssetWarranty.get(eachTerm.Id)){
                Asset assetRecord = mapIdToAsset.get(eachAssetWarranty.AssetId);
                if(assetRecord.SVMXA360__WarrantyEngineNotes__c != null){
                    assetRecord.SVMXA360__WarrantyEngineNotes__c = '';
                    mapAssetToUpdate.put(assetRecord.Id, assetRecord);
                }
                try {
                    eachAssetWarranty = getAssetWarrantyRecord(eachTerm, assetRecord, eachAssetWarranty, mapFieldMapping);
                    if (eachAssetWarranty.EndDate >= Date.today()) {
                        lstWarranties.add(eachAssetWarranty);    
                    }
                } catch (Exception ex) {
                    system.debug(LoggingLevel.INFO, 'Exception during Warranty  = ' + ex.getMessage());
                    logger.error(ex.getMessage(), String.valueOf(assetRecord.Id));
                    if(!mapAssetToUpdate.containsKey(assetRecord.Id)){
                        mapAssetToUpdate.put(assetRecord.Id, assetRecord);
                        mapAssetToUpdate.get(assetRecord.Id).SVMXA360__WarrantyEngineNotes__c = ex.getMessage();
                    } else {
                        mapAssetToUpdate.get(assetRecord.Id).SVMXA360__WarrantyEngineNotes__c += ex.getMessage();
                    }
                }
            }
        }
        try {
            if(!mapAssetToUpdate.isEmpty()){
                Database.SaveResult[] saveResult = Database.update(mapAssetToUpdate.values());
            }    
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'exception = ' + ex.getMessage());
        }
        
        system.debug(LoggingLevel.INFO, 'lstWarranties = ' + lstWarranties);
        return lstWarranties;
    }

    public AssetWarranty getAssetWarrantyRecord(WarrantyTerm eachTerm, Asset assetRecord, AssetWarranty eachAssetWarranty, Map<String,String> mapFieldMapping){
        String coverageField = mapFieldMapping.get(eachTerm.EffectiveStartDate);
        system.debug(LoggingLevel.INFO, 'coverageField  = ' + coverageField);
        if(String.isBlank(coverageField)){
            throw new SvmxSystem.SvmxNestedException('"' + eachTerm.WarrantyTermName + '" ' + System.Label.Error_DateNotInWarrantyConfig + eachTerm.EffectiveStartDate);
        }
        if(assetRecord != null && assetRecord.get(coverageField) != null){
            Date coverageStartsFromDate = Date.valueOf(assetRecord.get(coverageField));
            if(coverageStartsFromDate != null){
                eachAssetWarranty.WarrantyTermId = eachTerm.Id;
                eachAssetWarranty.StartDate = coverageStartsFromDate;
                Date coverageEndDate = calculateDate(coverageStartsFromDate, Integer.valueOf(eachTerm.WarrantyDuration), eachTerm.WarrantyUnitOfTime);
                eachAssetWarranty.EndDate = coverageEndDate;
                
                eachAssetWarranty.PartsCovered = eachTerm.PartsCovered != null ? eachTerm.PartsCovered : 0;
                eachAssetWarranty.PartsCoveredEndDate = (eachTerm.PartsCoveredDuration != null && eachTerm.PartsCoveredUnitOfTime != null) ?
                    calculateDate(coverageStartsFromDate, Integer.valueOf(eachTerm.PartsCoveredDuration), eachTerm.PartsCoveredUnitOfTime) : coverageEndDate;
                
                eachAssetWarranty.ExpensesCovered = eachTerm.ExpensesCovered != null ? eachTerm.ExpensesCovered : 0;
                eachAssetWarranty.ExpensesCoveredEndDate = (eachTerm.ExpensesCoveredDuration != null && eachTerm.ExpensesCoveredUnitOfTime != null) ?
                    calculateDate(coverageStartsFromDate, Integer.valueOf(eachTerm.ExpensesCoveredDuration), eachTerm.ExpensesCoveredUnitOfTime) : coverageEndDate;
                
                eachAssetWarranty.LaborCovered = eachTerm.LaborCovered != null ? eachTerm.LaborCovered : 0;
                eachAssetWarranty.LaborCoveredEndDate = (eachTerm.LaborCoveredDuration != null && eachTerm.LaborCoveredUnitOfTime != null) ?
                    calculateDate(coverageStartsFromDate, Integer.valueOf(eachTerm.LaborCoveredDuration), eachTerm.LaborCoveredUnitOfTime) : coverageEndDate;
                
                eachAssetWarranty.SVMXA360__TravelCovered__c = eachTerm.SVMXA360__TravelCovered__c  != null ? eachTerm.SVMXA360__TravelCovered__c : 0;
                eachAssetWarranty.SVMXA360__TravelCoveredEndDate__c = (eachTerm.SVMXA360__TravelCoveredDuration__c != null && eachTerm.SVMXA360__TravelCoveredUnitOfTime__c != null) ?
                    calculateDate(coverageStartsFromDate, Integer.valueOf(eachTerm.SVMXA360__TravelCoveredDuration__c), eachTerm.SVMXA360__TravelCoveredUnitOfTime__c) : coverageEndDate;
            } else {
                system.debug(LoggingLevel.INFO, 'Coverage date is null');
                throw new SvmxSystem.SvmxNestedException(System.Label.Error_CoverageDateNull);
            }
        } else {
            system.debug(LoggingLevel.INFO, coverageField + ' not defined in Asset ' + assetRecord);
            String errorMessage = String.format(System.Label.Error_EffectiveStartDateNullInAsset, new List<String>{eachTerm.WarrantyTermName, coverageField});
            throw new SvmxSystem.SvmxNestedException(errorMessage);
        }
        return eachAssetWarranty;
    }

    public List<AssetWarranty> createAssetWarrantyRecords(List<AssetWarranty> lstWarranties){
        if(!lstWarranties.isEmpty()){
            system.debug(LoggingLevel.INFO, 'lstWarranties size = ' + lstWarranties.size());
            try {
                lstWarranties = SvmxDatabase.insertRecord(lstWarranties, false);    
            } catch (Exception ex) {
                logger.error(ex.getMessage());
                system.debug(LoggingLevel.INFO, 'Exception = ' + ex);
            }
            system.debug(LoggingLevel.INFO, 'lstWarranties size = ' + lstWarranties.size());
        }
        return lstWarranties;
    }

    public AssetWarranty createAssetWarranty(AssetWarranty assetWarranty){
        if(assetWarranty != null){
            system.debug(LoggingLevel.INFO, 'assetWarranty = ' + assetWarranty);
            try {
                assetWarranty = (AssetWarranty)SvmxDatabase.insertRecord(assetWarranty);    
            } catch (Exception ex) {
                system.debug(LoggingLevel.INFO, 'Exception = ' + ex);
                throw ex;
            }
            system.debug(LoggingLevel.INFO, 'assetWarranty = ' + assetWarranty);
        }
        return assetWarranty;
    }

    private Date calculateDate(Date dateValue, Integer duration, String unitOfCoverage){
        Date calculatedDate;
        system.debug(LoggingLevel.INFO, 'dateValue = ' + dateValue + '; duration = ' + duration + '; unitOfCoverage = ' + unitOfCoverage);
        if(dateValue != null && duration != null && unitOfCoverage != null){
            if(COMM_Constants.YEARS.equalsIgnoreCase(unitOfCoverage)){
                calculatedDate = dateValue.addYears(duration);
            } else if(COMM_Constants.MONTHS.equalsIgnoreCase(unitOfCoverage)){
                calculatedDate = dateValue.addMonths(duration);
            } else if(COMM_Constants.WEEKS.equalsIgnoreCase(unitOfCoverage)){
                calculatedDate = dateValue.addDays(duration*7);
            } else if(COMM_Constants.DAYS.equalsIgnoreCase(unitOfCoverage)){
                calculatedDate = dateValue.addDays(duration);
            } else {
                calculatedDate = dateValue.addDays(duration); 
            }
        }
        return calculatedDate;
    }
}