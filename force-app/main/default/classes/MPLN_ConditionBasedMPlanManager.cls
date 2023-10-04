/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods with actual implementation which will be
 * comsumed by the class MPLN_ConditionBasedMPlan_LS.
 * 
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                23 May 2023     Created.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class MPLN_ConditionBasedMPlanManager {

    public static final String ACTIVE = 'Active';
    public static final String ASSETOBJ = 'ASSET';

    private static final MPLN_ConditionBasedMPlanManager instance = new MPLN_ConditionBasedMPlanManager ();
    COMM_MetadataManager commMetadataManager = COMM_MetadataManager.getInstance();
    
    /**
     * Public method to retrieve instance of this class.
     */
    public static MPLN_ConditionBasedMPlanManager getInstance() {
        return instance;
    }
    
    public List<Mpln.MaintenanceAssetInformation> getMatchingAssetsFromTemplate (Mpln.MaintenanceAssetRequest maintenanceAssetRequest) {
        if (maintenanceAssetRequest == null || maintenanceAssetRequest.templateId == null) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' maintenanceAssetRequest= ' + maintenanceAssetRequest );
		}
		
        Map<String, SVMXA360__ApplicableProduct__c> productWorkTypeIdMap = new Map<String, SVMXA360__ApplicableProduct__c>();
        Map<String, SVMXA360__ApplicableProduct__c> productFamilyWorkTypeIdMap = new Map<String, SVMXA360__ApplicableProduct__c>();
        for (SVMXA360__ApplicableProduct__c applicableProductRec : (List<SVMXA360__ApplicableProduct__c>)SvmxDatabase.query([SELECT SVMXA360__ProductId__c, SVMXA360__ProductId__r.Name, SVMXA360__WorkTypeId__c, SVMXA360__ProductFamily__c, 
                                                                   SVMXA360__WorkTypeId__r.Name FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =:maintenanceAssetRequest.templateId])) {
             if (applicableProductRec.SVMXA360__ProductId__c != null) {
                 productWorkTypeIdMap.put(applicableProductRec.SVMXA360__ProductId__c, applicableProductRec);                                                           
             } 
             if (applicableProductRec.SVMXA360__ProductFamily__c != null) {
                 productFamilyWorkTypeIdMap.put(applicableProductRec.SVMXA360__ProductFamily__c, applicableProductRec);
             }
        }
        
        List<Mpln.MaintenanceAssetInformation> mAssetInfoList = new List<Mpln.MaintenanceAssetInformation>();
        if (maintenanceAssetRequest.sourceRecordId != null){
            String sourceId = maintenanceAssetRequest.sourceRecordId;
            List<Asset> assetList = new List<Asset>();
            Set<String> productIdSet = productWorkTypeIdMap.keySet();
            Set<String> productFamilySet = productFamilyWorkTypeIdMap.keySet();
            String whereClause = '';
            String additionalWhereClause = '';
            String query = '';
            //Asset Criteria
            if(maintenanceAssetRequest.assetCriteria !=null && 
                            String.isNotBlank(maintenanceAssetRequest.assetCriteria)) {
                List<Adm.Expression> expressionRecList = ADM_ExpressionManager.getInstance().getExpressionsWithDetails(new List<Id>{maintenanceAssetRequest.assetCriteria}, null).values();
                if (!expressionRecList.isEmpty()){
                    Adm.Expression expressionRec = expressionRecList[0];
                    expressionRec.criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expressionRec);
                    additionalWhereClause = expressionRec.criteria;
                }
            }
            sObjectType sObjectTypeStr = Id.valueOf(sourceId).getSObjectType();
            if (sObjectTypeStr == Asset.getSobjectType()) {
                //includeChildAssets
                if(maintenanceAssetRequest.includeChildAssets) {
                    whereClause = ' ( Id =' + '\'' + String.escapeSingleQuotes(sourceId) + '\'' + ' OR ParentId =' + '\'' + String.escapeSingleQuotes(sourceId) + '\')';
                } else{
                    whereClause = ' Id ='+'\'' + String.escapeSingleQuotes(sourceId) + '\'';
                }
                additionalWhereClause =  String.isBlank(additionalWhereClause) ? ' ' : ' AND ' + additionalWhereClause;
                whereClause += additionalWhereClause;
                whereClause += ' AND (Product2Id IN: productIdSet OR Product2.Family IN: productFamilySet)';
                query = 'SELECT Id, Name, Product2Id, Product2.Family FROM Asset WHERE '+ whereClause;

                assetList = (List<Asset>) SvmxDatabase.query(Database.query(query));

            } else if (sObjectTypeStr == Schema.Location.getSobjectType()) {
                whereClause = ' LocationId ='+'\'' + String.escapeSingleQuotes(sourceId) + '\'';
                additionalWhereClause =  String.isBlank(additionalWhereClause) ? ' ' : ' AND ' + additionalWhereClause;
                additionalWhereClause += ' AND (Product2Id IN: productIdSet OR Product2.Family IN: productFamilySet)';
                whereClause += additionalWhereClause;
                query = 'SELECT Id, Name, Product2Id, Product2.Family FROM Asset WHERE '+ whereClause;
                assetList = (List<Asset>) SvmxDatabase.query(Database.query(query));
            }
            
            for (Asset assetRec : assetList){
                Mpln.MaintenanceAssetInformation mAssetInfo = new Mpln.MaintenanceAssetInformation();
                mAssetInfo.assetId = assetRec.Id;
                mAssetInfo.assetName = assetRec.Name; 
                mAssetInfo.productId = assetRec.Product2Id;
                SVMXA360__ApplicableProduct__c applicableProductRec;                         
                if (productWorkTypeIdMap.containsKey(assetRec.Product2Id)) {
                    applicableProductRec = productWorkTypeIdMap.get(assetRec.Product2Id);
                } else if (assetRec.Product2Id != null && productFamilyWorkTypeIdMap.containsKey(assetRec.Product2.Family)) {
                    applicableProductRec = productFamilyWorkTypeIdMap.get(assetRec.Product2.Family);
                } 
                
                if (applicableProductRec != null) {
                    mAssetInfo.workTypeId = applicableProductRec.SVMXA360__WorkTypeId__c;
                    mAssetInfo.workTypeName = applicableProductRec.SVMXA360__WorkTypeId__r.Name;
                } 
                mAssetInfoList.add(mAssetInfo);                        
            }
		}
        return mAssetInfoList;

    }

    /**
     * Public method to retrieve Workrules for the Template.
     * @param: Mpln.MaintenanceWorkRuleRequest maintenanceWorkRuleRequest
     * @ex: {"templateId":"a127X000002bpB1"}
     */
    public List<Mpln.ProductWorkRuleInfo> getWorkRulesFromMaintenanceTemplate( Mpln.MaintenanceWorkRuleRequest maintenanceWorkRuleRequest) {
        if (maintenanceWorkRuleRequest == null || maintenanceWorkRuleRequest.templateId == null) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' maintenanceWorkRuleRequest= ' + maintenanceWorkRuleRequest );
		}

        Map<String,List<Mpln.WorkRuleInformation>> productIdWorkRuleMap = new Map<String,List<Mpln.WorkRuleInformation>>();
        Map<String,String> productMap = new Map<String,String>();
        Map<String,String> applicableProductMap = new Map<String,String>();
        List<Mpln.ProductWorkRuleInfo> productWorkRuleInfoList = new List<Mpln.ProductWorkRuleInfo>();

        if(String.isNotEmpty(maintenanceWorkRuleRequest.templateId) ) {
            
            List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();
            workRuleTemplateList = SvmxDatabase.query([SELECT Id,Name,SVMXA360__WorkTypeId__c,SVMXA360__ApplicableProductId__c,SVMXA360__WorkTypeId__r.Name,SVMXA360__SortOrder__c,SVMXA360__AdvancedExpression__c,
                                                       SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c,SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__r.Name,SVMXA360__ApplicableProductId__r.SVMXA360__ProductFamily__c,
                                                       SVMXA360__SM_TechnicalAttributeTemplate__c,(SELECT SVMXA360__TechnicalAttribute__r.Name,SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c,SVMXA360__ConditionType__c,SVMXA360__Operand__c,
                                                       SVMXA360__Operator__c,SVMXA360__StartAt__c,SVMXA360__StopAt__c,SVMXA360__Threshold__c,SVMXA360__RecurrencePattern__c,SVMXA360__TechnicalAttributeCategory__c,SVMXA360__FieldAPIName__c,SVMXA360__Sequence__c 
                                                       FROM SVMXA360__Asset_Conditions__r ORDER BY SVMXA360__Sequence__c ASC)
                                                       FROM SVMXA360__MaintenanceWorkRuleTemplate__c 
                                                       WHERE SVMXA360__MaintenancePlanTemplateId__c =: maintenanceWorkRuleRequest.templateId AND SVMXA360__ApplicableProductId__c!=null
                                                    ]); 
            //Start:for asset object if any lookup fields are selected, then get Name field for referenceObject                                        
            Map<String,String> lookupIdLabelMap = getLookupLabelForFields(workRuleTemplateList);
            //endhere
            for( SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec : workRuleTemplateList ) {
                if(String.isNotBlank(workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c)) {
                    String productId = workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c;
                    productIdWorkRuleMap = mapProductIdWorkRuleInfo(productId,workRuleTemplateRec,productIdWorkRuleMap,lookupIdLabelMap);
                    productMap.put(productId,workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__r.Name);
                    applicableProductMap.put(productId,workRuleTemplateRec.SVMXA360__ApplicableProductId__c);
                } else{
                    String productFamily = workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductFamily__c;
                    productIdWorkRuleMap = mapProductIdWorkRuleInfo(productFamily,workRuleTemplateRec,productIdWorkRuleMap,lookupIdLabelMap);
                    productMap.put(productFamily,productFamily);
                    applicableProductMap.put(productFamily,workRuleTemplateRec.SVMXA360__ApplicableProductId__c);
                }
            }
            
            if (!productIdWorkRuleMap.isEmpty()) {
                for(String productKey : productIdWorkRuleMap.keyset()) {
                    Mpln.ProductWorkRuleInfo productWorkRuleInfo = new Mpln.ProductWorkRuleInfo();
                    productWorkRuleInfo.productId = productKey;
                    productWorkRuleInfo.productName = productMap.get(productKey);
                    productWorkRuleInfo.applicableProduct = applicableProductMap.get(productKey);
                    productWorkRuleInfo.workRuleInformation = productIdWorkRuleMap.get(productKey);
                    productWorkRuleInfoList.add(productWorkRuleInfo);
                }
                return productWorkRuleInfoList;
            }

        }
        return null;
    }

    public List<Mpln.ProductWorkRuleInfo> getWorkRulesFromPlan( List<String> maintenanceAssetIds ) {
        System.debug(LoggingLevel.INFO, 'getWorkRulesFromPlan() - enter; maintenanceAssetIds= ' + maintenanceAssetIds );
        Map<String, Mpln.ProductWorkRuleInfo> productWorkRuleInfoMap = new Map<String, Mpln.ProductWorkRuleInfo>();

        try {
            if (maintenanceAssetIds != null && !maintenanceAssetIds.isEmpty()) {
                List<SVMXA360__SM_MaintenanceWorkRule__c> maintenanceWorkRulesList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__WorkType__c, SVMXA360__WorkType__r.Name, SVMXA360__SortOrder__c, SVMXA360__AdvancedExpression__c,
                                                       SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c, SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Name,                                                  
                                                       SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Product2Id, SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Product2.Name, (SELECT SVMXA360__TechnicalAttribute__r.Name, SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c,SVMXA360__ConditionType__c, SVMXA360__Operand__c,
                                                       SVMXA360__Operator__c, SVMXA360__StartAt__c, SVMXA360__StopAt__c, SVMXA360__Threshold__c, SVMXA360__RecurrencePattern__c, SVMXA360__TechnicalAttributeCategory__c, SVMXA360__FieldAPIName__c, SVMXA360__Sequence__c FROM SVMXA360__Asset_Conditions__r ORDER BY SVMXA360__Sequence__c ASC)
                                                       FROM SVMXA360__SM_MaintenanceWorkRule__c WHERE SVMXA360__MaintenancePlanAsset__c IN: maintenanceAssetIds]);  

                for (SVMXA360__SM_MaintenanceWorkRule__c workRuleRec : maintenanceWorkRulesList) {
                    Mpln.WorkRuleInformation workRuleInfo = mapWorkRuleInfo(workRuleRec);
                    String assetId = workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c; 
                    if (assetId != null){
                        if (productWorkRuleInfoMap.containsKey(assetId)) {
                            Mpln.ProductWorkRuleInfo productWorkRuleInfo = productWorkRuleInfoMap.get(assetId);
                            productWorkRuleInfo.workRuleInformation.add(workRuleInfo);
                        } else {
                            Mpln.ProductWorkRuleInfo productWorkRuleInfo = new Mpln.ProductWorkRuleInfo();
                            productWorkRuleInfo.productId = assetId;
                            productWorkRuleInfo.productName = workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Name;
                            productWorkRuleInfo.workRuleInformation = new List<Mpln.WorkRuleInformation>{workRuleInfo};
                            productWorkRuleInfoMap.put(assetId, productWorkRuleInfo);
                        }
                    } 
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getWorkRulesFromPlan() : Failed to fetch Maintenance Assets Work Rule info. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getWorkRulesFromPlan() - exit;' );
        }  

        return productWorkRuleInfoMap.values();
    }

    public List<Mpln.MaintenanceAssetInformation> getMaintenanceAssets( String mplanId ) {
        System.debug(LoggingLevel.INFO, 'getMaintenanceAssets() - enter; mplanId= ' + mplanId );

        List<Mpln.MaintenanceAssetInformation> mAssetInfoList = new List<Mpln.MaintenanceAssetInformation>();
        try {
            if (String.isBlank(mplanId)) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' mplanId= ' + mplanId );
            }

            List<SVMXA360__SM_MaintenancePlanAsset__c> mplanAssetList = SvmxDatabase.query([SELECT Id, SVMXA360__Asset__c, SVMXA360__Asset__r.Name, SVMXA360__WorkType__c, SVMXA360__WorkType__r.Name 
                                                                        FROM SVMXA360__SM_MaintenancePlanAsset__c WHERE SVMXA360__MaintenancePlan__c =: mplanId]);
            for (SVMXA360__SM_MaintenancePlanAsset__c mplanAssetRec : mplanAssetList) {
                Mpln.MaintenanceAssetInformation mAssetInfo = new Mpln.MaintenanceAssetInformation();
                mAssetInfo.id = mplanAssetRec.Id;
                mAssetInfo.assetId = mplanAssetRec.SVMXA360__Asset__c;
                mAssetInfo.assetName = mplanAssetRec.SVMXA360__Asset__r.Name;
                mAssetInfo.workTypeId = mplanAssetRec.SVMXA360__WorkType__c;
                mAssetInfo.workTypeName = mplanAssetRec.SVMXA360__WorkType__r.Name;
                mAssetInfoList.add(mAssetInfo);
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getMaintenanceAssets() : Failed to fetch Maintenance Assets. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getMaintenanceAssets() - exit;' );
        }  

        return mAssetInfoList;
    }

    /**
     * Public method to retrieve Workrules for the selected Assets.
     * @param: Mpln.MaintenanceWorkRuleRequest maintenanceWorkRuleRequest
     * @ex: {"templateId":"a127X000002bpB1","productIds":["01t7X000006MHDE","01t7X000006MHDJ"]}
     */
    public List<Mpln.ProductWorkRuleInfo> getWorkRulesFromTemplate( Mpln.MaintenanceWorkRuleRequest maintenanceWorkRuleRequest ) {
        if (maintenanceWorkRuleRequest == null || maintenanceWorkRuleRequest.templateId == null) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' maintenanceWorkRuleRequest= ' + maintenanceWorkRuleRequest );
		}

        Map<String,List<Mpln.WorkRuleInformation>> productIdWorkRuleMap = new Map<String,List<Mpln.WorkRuleInformation>>();
        List<Mpln.ProductWorkRuleInfo> productWorkRuleInfoList = new List<Mpln.ProductWorkRuleInfo>();
         
        if(String.isNotEmpty(maintenanceWorkRuleRequest.templateId) && !maintenanceWorkRuleRequest.productIds.isEmpty()) {
            //get all the Maintenance Work rule template for the selected Asset and associated to templete
            List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();

            Map<String,List<Product2>> productFamilyMap = new Map<String,List<Product2>>();
            Set<Id> productIdSet = new Set<Id>();

            for (Product2 productRec : (List<Product2>)SvmxDatabase.query([SELECT Id,Name,Family FROM Product2 WHERE Id IN: maintenanceWorkRuleRequest.productIds])) {
                
                if(String.isNotBlank(productRec.Family)) {
                    if(productFamilyMap.containsKey(productRec.Family)) {
                        List<Product2> prodList = productFamilyMap.get(productRec.Family);
                        prodList.add(productRec);
                        productFamilyMap.put(productRec.Family,prodList);    
                    } else{
                        productFamilyMap.put(productRec.Family,new List<Product2>{productRec});
                    }
                }
            }

            workRuleTemplateList = SvmxDatabase.query([SELECT Id,Name,SVMXA360__WorkTypeId__c,SVMXA360__ApplicableProductId__c,SVMXA360__WorkTypeId__r.Name,SVMXA360__SortOrder__c,SVMXA360__AdvancedExpression__c,
                                                       SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c,SVMXA360__ApplicableProductId__r.SVMXA360__ProductFamily__c,
                                                       SVMXA360__SM_TechnicalAttributeTemplate__c,(SELECT SVMXA360__TechnicalAttribute__r.Name,SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c,SVMXA360__ConditionType__c,SVMXA360__Operand__c,
                                                       SVMXA360__Operator__c,SVMXA360__StartAt__c,SVMXA360__StopAt__c,SVMXA360__Threshold__c,SVMXA360__RecurrencePattern__c,SVMXA360__TechnicalAttributeCategory__c, 
                                                       SVMXA360__Sequence__c, SVMXA360__FieldAPIName__c FROM SVMXA360__Asset_Conditions__r
                                                       ORDER By SVMXA360__Sequence__c ASC)
                                                       FROM SVMXA360__MaintenanceWorkRuleTemplate__c 
                                                       WHERE SVMXA360__MaintenancePlanTemplateId__c =: maintenanceWorkRuleRequest.templateId 
                                                       ORDER BY SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c NULLS LAST
                                                    ]);  
            //Start:for asset object if any lookup fields are selected, then get Name field for referenceObject
            Map<String,String> lookupIdLabelMap = getLookupLabelForFields(workRuleTemplateList);
            //endhere
            for( SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec : workRuleTemplateList ) {

                if(String.isNotBlank(workRuleTemplateRec.SVMXA360__ApplicableProductId__c)) {

                    //get product id from applicable product's product lookup or product family

                    if(String.isNotBlank(workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c)) {
                        String productId = workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductId__c;
                        productIdSet.add(productId);
                        productIdWorkRuleMap = mapProductIdWorkRuleInfo(productId,workRuleTemplateRec,productIdWorkRuleMap,lookupIdLabelMap);
                    } else {
                        if(productFamilyMap.get(workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductFamily__c) != null) {
                            List<Product2> productList = productFamilyMap.get(workRuleTemplateRec.SVMXA360__ApplicableProductId__r.SVMXA360__ProductFamily__c);
                            for(Product2 productRec : productList) {
                                if(!productIdSet.contains(productRec.Id)) {
                                    productIdWorkRuleMap = mapProductIdWorkRuleInfo(productRec.Id,workRuleTemplateRec,productIdWorkRuleMap,lookupIdLabelMap);
                                }
                                
                            }
                        }
                    }                                                                                               
                } 
                
            } 

            //iterate over the request product Ids and populate ProductWorkRuleInfo wrapper with ProductId and List<WorkRuleInformation> 
            for( String productId : maintenanceWorkRuleRequest.productIds) {

                Mpln.ProductWorkRuleInfo productWorkRuleInfo = new Mpln.ProductWorkRuleInfo();

                if(productIdWorkRuleMap.containsKey(productId)) {

                    productWorkRuleInfo.productId = productId;
                    
                    productWorkRuleInfo.workRuleInformation = productIdWorkRuleMap.get(productId).isEmpty() ? null : productIdWorkRuleMap.get(productId);
                }  else {
                    productWorkRuleInfo.productId = productId;
                    productWorkRuleInfo.workRuleInformation = null;
                }
                productWorkRuleInfoList.add(productWorkRuleInfo);
            }
        }
        return productWorkRuleInfoList;
    }

    private Map<String,List<Mpln.WorkRuleInformation>> mapProductIdWorkRuleInfo(String productId,
                                                                    SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec,
                                                                    Map<String,List<Mpln.WorkRuleInformation>> productIdWorkRuleMap,
                                                                    Map<String,String> lookUpIdLabelMap) {

        if(productIdWorkRuleMap.containsKey(productId)) {

            Mpln.WorkRuleInformation mWorkRuleInfo = mapWorkRuleTemplateInfo(workRuleTemplateRec,lookUpIdLabelMap);
            List<Mpln.WorkRuleInformation> workRuleInformationList = productIdWorkRuleMap.get(productId);
            workRuleInformationList.add(mWorkRuleInfo);
            productIdWorkRuleMap.put(productId,workRuleInformationList);

        } else {

            Mpln.WorkRuleInformation mWorkRuleInfo = mapWorkRuleTemplateInfo(workRuleTemplateRec,lookUpIdLabelMap);
            productIdWorkRuleMap.put(productId, new List<Mpln.WorkRuleInformation>{mWorkRuleInfo});
        }
        return productIdWorkRuleMap;
    }

    /**
     * private method to form WorkRuleInformation wrapper record.
     * @param: SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec 
     * @ex: 
     */
    private Mpln.WorkRuleInformation mapWorkRuleTemplateInfo( SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec, 
                                                            Map<String,String> lookUpIdLabelMap) {

        Mpln.WorkRuleInformation mWorkRuleInfo = new Mpln.WorkRuleInformation();  
        mWorkRuleInfo.workRuleId = workRuleTemplateRec.id;
        mWorkRuleInfo.workRuleTitle = workRuleTemplateRec.Name;
        mWorkRuleInfo.workType = workRuleTemplateRec.SVMXA360__WorkTypeId__r.Name;  
        mWorkRuleInfo.workTypeId = workRuleTemplateRec.SVMXA360__WorkTypeId__c;
        mWorkRuleInfo.sortOrder = workRuleTemplateRec.SVMXA360__SortOrder__c;
        mWorkRuleInfo.attributeTemplate = workRuleTemplateRec.SVMXA360__SM_TechnicalAttributeTemplate__c;
        mWorkRuleInfo.advancedExpression = workRuleTemplateRec.SVMXA360__AdvancedExpression__c;
        List<Mpln.ConditionTypeInfo> mConditionTypeList = new List<Mpln.ConditionTypeInfo>();
        for( SVMXA360__SM_Condition__c conditionRec : workRuleTemplateRec.Asset_Conditions__r ) {
            Mpln.ConditionTypeInfo mConditionType = mapConditionTypeInfo(conditionRec,lookUpIdLabelMap);
            mConditionTypeList.add(mConditionType);
        } 
        mWorkRuleInfo.detail = mConditionTypeList;
        return mWorkRuleInfo;
    }

    private Mpln.WorkRuleInformation mapWorkRuleInfo( SVMXA360__SM_MaintenanceWorkRule__c workRuleRec ) {
        Mpln.WorkRuleInformation mWorkRuleInfo = new Mpln.WorkRuleInformation();  
        mWorkRuleInfo.workRuleTitle = workRuleRec.Name;
        mWorkRuleInfo.workType = workRuleRec.SVMXA360__WorkType__r.Name;  
        mWorkRuleInfo.workTypeId = workRuleRec.SVMXA360__WorkType__c;
        mWorkRuleInfo.sortOrder = workRuleRec.SVMXA360__SortOrder__c;
        mWorkRuleInfo.advancedExpression = workRuleRec.SVMXA360__AdvancedExpression__c;
        List<Mpln.ConditionTypeInfo> mConditionTypeList = new List<Mpln.ConditionTypeInfo>();
        for( SVMXA360__SM_Condition__c conditionRec : workRuleRec.Asset_Conditions__r ) {
            Mpln.ConditionTypeInfo mConditionType = mapConditionTypeInfo(conditionRec,null);
            mConditionTypeList.add(mConditionType);
        } 
        mWorkRuleInfo.detail = mConditionTypeList;
        return mWorkRuleInfo;
    }

    private Mpln.ConditionTypeInfo mapConditionTypeInfo( SVMXA360__SM_Condition__c conditionRec,
                                                            Map<String,String> lookUpIdLabelMap) {
        Mpln.ConditionTypeInfo mConditionType = new Mpln.ConditionTypeInfo();
        mConditionType.id = conditionRec.id;
        mConditionType.conditionType = conditionRec.SVMXA360__ConditionType__c;
        mConditionType.sequence = Integer.valueOf(conditionRec.SVMXA360__Sequence__c);
        //FREQUENCY
        if(mConditionType.conditionType == 'Frequency') {
            Mpln.FrequencyInfo frequencyInfo = new Mpln.FrequencyInfo();
            frequencyInfo.operator = conditionRec.SVMXA360__Operator__c;
            frequencyInfo.attributeCategory = conditionRec.SVMXA360__TechnicalAttributeCategory__c;
            frequencyInfo.attributeValue = conditionRec.SVMXA360__Operand__c;
            frequencyInfo.startAt = conditionRec.SVMXA360__StartAt__c;
            frequencyInfo.stopAt = conditionRec.SVMXA360__StopAt__c;
            frequencyInfo.threshold = conditionRec.SVMXA360__Threshold__c == null ? 0 : conditionRec.SVMXA360__Threshold__c;
            
            if(String.isBlank(conditionRec.SVMXA360__TechnicalAttribute__c)) {
                frequencyInfo.attributeCategory = ASSETOBJ;
                frequencyInfo.attribute = conditionRec.SVMXA360__FieldAPIName__c;
                frequencyInfo.attributeName = String.isNotBlank(conditionRec.SVMXA360__FieldAPIName__c) ? 
                                        commMetadataManager.getFieldDefinition(ASSETOBJ,conditionRec.SVMXA360__FieldAPIName__c,false).label : null;
                if(lookUpIdLabelMap != null && lookUpIdLabelMap.get(frequencyInfo.attributeValue) != null) {
                    frequencyInfo.attributeDatatype = 'Reference';
                    frequencyInfo.attributeLookUpLabel = lookUpIdLabelMap.get(frequencyInfo.attributeValue);
                }  
            } else{
                frequencyInfo.attribute = conditionRec.SVMXA360__TechnicalAttribute__c;
                frequencyInfo.attributeName = conditionRec.SVMXA360__TechnicalAttribute__r.Name;
                frequencyInfo.attributeDatatype = conditionRec.SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c;                       
            }
            mConditionType.frequency = frequencyInfo;
        } else if(mConditionType.conditionType == 'Criteria') {
            Mpln.CriteriaInfo criteriaInfo = new Mpln.CriteriaInfo();
            criteriaInfo.operator = conditionRec.SVMXA360__Operator__c;
            criteriaInfo.attributeCategory = conditionRec.SVMXA360__TechnicalAttributeCategory__c;
            criteriaInfo.attributeValue = conditionRec.SVMXA360__Operand__c;
            criteriaInfo.threshold = conditionRec.SVMXA360__Threshold__c == null ? 0 : conditionRec.SVMXA360__Threshold__c;

            if(String.isBlank(conditionRec.SVMXA360__TechnicalAttribute__c)) {
                criteriaInfo.attributeCategory = ASSETOBJ;
                criteriaInfo.attribute = conditionRec.SVMXA360__FieldAPIName__c;  
                criteriaInfo.attributeName = String.isNotBlank(conditionRec.SVMXA360__FieldAPIName__c) ? 
                                    commMetadataManager.getFieldDefinition(ASSETOBJ,conditionRec.SVMXA360__FieldAPIName__c,false).label : null;
                if(lookUpIdLabelMap != null && lookUpIdLabelMap.get(criteriaInfo.attributeValue) != null) {
                    criteriaInfo.attributeDatatype = 'Reference';
                    criteriaInfo.attributeLookUpLabel = lookUpIdLabelMap.get(criteriaInfo.attributeValue);
                } 
            } else{
                criteriaInfo.attribute = conditionRec.SVMXA360__TechnicalAttribute__c;
                criteriaInfo.attributeName = conditionRec.SVMXA360__TechnicalAttribute__r.Name;
                criteriaInfo.attributeDatatype = conditionRec.SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c;    
            }

            mConditionType.criteria = criteriaInfo;    
        } else {
            mConditionType.recurrenceRule = conditionRec.SVMXA360__RecurrencePattern__c;    
        }   
        
        return mConditionType;
    }

    /****************************
     * @method:  getLookupLabelForFields
     * @description: Method to get Name field on for the reference object that is selected on Asset fields
     */
    private Map<String,String> getLookupLabelForFields(List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList) {

        Map<String,String> lookupIdObjectLabelMap = new Map<String,String>();
        Map<String,String> lookupIdLabelMap = new Map<String,String>();
        if(!workRuleTemplateList.isEmpty()) {
            for(SVMXA360__MaintenanceWorkRuleTemplate__c templateRec : workRuleTemplateList) {
                if(!templateRec.SVMXA360__Asset_Conditions__r.isEmpty()) {
                    for(SVMXA360__SM_Condition__c conditionRec : templateRec.SVMXA360__Asset_Conditions__r) {
                        if(String.isNotBlank(conditionRec.SVMXA360__FieldAPIName__c)) {
                            //get Field definitation
                            Common.FieldDefinition fldDefinition = commMetadataManager.getFieldDefinition(ASSETOBJ,conditionRec.SVMXA360__FieldAPIName__c,false);
                            if(fldDefinition.dataType == 'REFERENCE') {
                                String referenceToLabel = fldDefinition.referenceTo[0];
                                lookupIdObjectLabelMap.put(conditionRec.SVMXA360__Operand__c,referenceToLabel);    
                            }
                        }
                    }
                }
            }
            //for Lookup, identify the Name field and query the name from object and map recordId and Name to show on condition defination
            if(!lookupIdObjectLabelMap.isEmpty()) {
                for (String recordId : lookupIdObjectLabelMap.keyset()) {
                    String objectName = lookupIdObjectLabelMap.get(recordId);
                    //get Name field for the reference object
                    String nameFld = COMM_UiApi_Utils.getNameFields(objectName)[0];
                    String query = 'SELECT Id,'+nameFld +' FROM ' + objectName + ' WHERE Id=' + '\'' + String.escapeSingleQuotes(recordId) + '\''+' LIMIT 1';
                    List<sObject> objectDataList = (List<sObject>)SvmxDatabase.query(Database.query(query));
                    sObject objectData = objectDataList[0];
                    //Map to store recordId and Name for the object
                    lookupIdLabelMap.put((String)objectData.get('Id'),(String)objectData.get(nameFld));
                }
            }
        }
        return lookupIdLabelMap;
    }

    /**
     * public method to get attribute template record.
     * @param:  
     * @ex: 
     */
    public List<Mpln.MplnTemplateRecord> getAttributeTemplates() {
        
        List<SVMXA360__SM_TA_Template__c> attributeTemplates = (List<SVMXA360__SM_TA_Template__c>)SvmxDatabase.query(
                                                                                                [SELECT Id,Name FROM SVMXA360__SM_TA_Template__c 
                                                                                               WHERE SVMXA360__Status__c =: ACTIVE
                                                                                                ORDER BY CreatedDate 
                                                                                                LIMIT 50000]);
        if(!attributeTemplates.isEmpty()) {
            List<Mpln.MplnTemplateRecord> attributeTemplateList = new List<Mpln.MplnTemplateRecord>();
            for (SVMXA360__SM_TA_Template__c attributeTemplateRec : attributeTemplates) {
                Mpln.MplnTemplateRecord templateRec = new Mpln.MplnTemplateRecord();
                templateRec.id = attributeTemplateRec.Id;
                templateRec.name = attributeTemplateRec.Name;
                attributeTemplateList.add(templateRec);
            }

            return attributeTemplateList;
        }
        return null;
    }

    /**
     * public method to get attribute categories for selected attribute template record.
     * @param:  Mpln.MplnTemplateRecord templateRequest
     * @ex: {id:'recordId'}
     */
    public List<Mpln.MplnTemplateRecord> getAttributeCategories(Mpln.MplnTemplateRecord templateRequest) {
        if (templateRequest == null || templateRequest.id == null) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' templateRequest= ' + templateRequest );
		}

        if(!String.isBlank(templateRequest.id)) {

            Map<String,Mpln.MplnTemplateRecord> attibuteCategoryMap = new Map<String,Mpln.MplnTemplateRecord>();  

            List<SVMXA360__SM_TA_TemplateItem__c> templateItemList = (List<SVMXA360__SM_TA_TemplateItem__c>)SvmxDatabase.query([SELECT SVMXA360__CategoryId__c,SVMXA360__CategoryId__r.Name,SVMXA360__AttributeId__c,
                                                                                                            SVMXA360__AttributeId__r.Name ,SVMXA360__AttributeId__r.SVMXA360__DataType__c 
                                                                                                            FROM SVMXA360__SM_TA_TemplateItem__c
                                                                                                            WHERE SVMXA360__TemplateId__c =: templateRequest.id
                                                                                                            Order by CreatedDate DESC
                                                                                                            LIMIT 50000]);


            for(SVMXA360__SM_TA_TemplateItem__c templateItem : templateItemList ) {
                if(!attibuteCategoryMap.containsKey(templateItem.SVMXA360__CategoryId__c)) {
                    Mpln.MplnTemplateRecord templateRecord = new Mpln.MplnTemplateRecord();
                    templateRecord.id = templateItem.SVMXA360__CategoryId__c;
                    templateRecord.name = templateItem.SVMXA360__CategoryId__r.Name;
                    attibuteCategoryMap.put(templateItem.SVMXA360__CategoryId__c,templateRecord);
                }    
            }return attibuteCategoryMap.values();
        }
        return null;
    }

    /**
     * public method to get attributes for selected attribute category record.
     * @param:  Mpln.MplnTemplateRecord templateRequest
     * @ex: {id:'recordId'}
     */
    public List<Mpln.TechnicalAttributeInfo> getAttributes(Mpln.MplnTemplateRecord templateRequest) {
        if (templateRequest == null || templateRequest.id == null) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' templateRequest= ' + templateRequest );
		}

        if(!string.isBlank(templateRequest.id)) {
            Map<String,Mpln.TechnicalAttributeInfo> attributeMap = new Map<String,Mpln.TechnicalAttributeInfo>();
            
            List<SVMXA360__SM_TA_TemplateItem__c> templateItemList = (List<SVMXA360__SM_TA_TemplateItem__c>)SvmxDatabase.query([SELECT SVMXA360__AttributeId__c,SVMXA360__AttributeId__r.SVMXA360__DefaultValue__c,
                                                                                                            SVMXA360__AttributeId__r.Name ,SVMXA360__AttributeId__r.SVMXA360__DataType__c ,SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__c,
                                                                                                            SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Values__c,SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__DefaultValue__c
                                                                                                            FROM SVMXA360__SM_TA_TemplateItem__c
                                                                                                            WHERE SVMXA360__CategoryId__c =: templateRequest.id
                                                                                                            Order by CreatedDate DESC
                                                                                                            LIMIT 50000]);

            if (!templateItemList.isEmpty()) {
                Map<String,List<String>> attributeIdPicklistValuesMap = new Map<String,List<String>>();
                Map<String,String> attributeIdPicklistDefaultMap = new Map<String,String>();
                for(SVMXA360__SM_TA_TemplateItem__c templateItem : templateItemList ) {
                    if(String.isNotBlank(templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__c) && 
                        String.isNotBlank(templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Values__c)) {
                        List<String> picklistValues = templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__Values__c.split(';');
                        attributeIdPicklistValuesMap.put(templateItem.SVMXA360__AttributeId__c,picklistValues);
                        attributeIdPicklistDefaultMap.put(templateItem.SVMXA360__AttributeId__c,templateItem.SVMXA360__AttributeId__r.SVMXA360__PicklistDefinitionId__r.SVMXA360__DefaultValue__c);
                    }
                }

                for(SVMXA360__SM_TA_TemplateItem__c templateItem : templateItemList ) {
                    if(!attributeMap.containsKey(templateItem.SVMXA360__AttributeId__c)) {
                        Mpln.TechnicalAttributeInfo attributeRecord = new Mpln.TechnicalAttributeInfo();
                        attributeRecord.id = templateItem.SVMXA360__AttributeId__c;
                        attributeRecord.name = templateItem.SVMXA360__AttributeId__r.Name;
                        attributeRecord.dataType = templateItem.SVMXA360__AttributeId__r.SVMXA360__DataType__c;
                        attributeRecord.defaultValue = templateItem.SVMXA360__AttributeId__r.SVMXA360__DefaultValue__c;
                        attributeRecord.picklistValues = attributeIdPicklistValuesMap.get(templateItem.SVMXA360__AttributeId__c) == null ? new List<String>() :
                                                        attributeIdPicklistValuesMap.get(templateItem.SVMXA360__AttributeId__c);
                        //if picklist values are present, then get the default picklist value
                        if(attributeRecord.picklistValues.size() > 0 && 
                            attributeIdPicklistDefaultMap.get(templateItem.SVMXA360__AttributeId__c) != null) {
                            attributeRecord.defaultValue = attributeIdPicklistDefaultMap.get(templateItem.SVMXA360__AttributeId__c);  
                        }
                        attributeMap.put(templateItem.SVMXA360__AttributeId__c,attributeRecord);    
                    }
                }
                return attributeMap.values();
            }
        }  
        return null;   
    }

    public String saveMaintenancePlan (SVMXA360__SM_MaintenancePlan__c maintenancePlanRecord, String maintenanceAssetsJSON) {
        
        System.debug(LoggingLevel.INFO, 'saveMaintenancePlan() - enter; maintenancePlanRecord= ' + maintenancePlanRecord + ' maintenanceAssetsJSON= ' +  maintenanceAssetsJSON);
        String newRecordId;

        Savepoint sp = Database.setSavePoint();        
        try {
            SvmxDatabase.upsertRecord( maintenancePlanRecord );
            newRecordId = maintenancePlanRecord.Id;
            List<Mpln.MaintenanceAssetInformation> maintenanceAssetInfoList = ((List<Mpln.MaintenanceAssetInformation>)JSON.deserialize(maintenanceAssetsJSON, List<Mpln.MaintenanceAssetInformation>.class)); 
            List<SVMXA360__SM_MaintenancePlanAsset__c> mplanAssetsToUpsert = new List<SVMXA360__SM_MaintenancePlanAsset__c>();
            Map<String, List<Mpln.WorkRuleInformation>> mplanAssetWorkRuleInfoMap = new Map<String, List<Mpln.WorkRuleInformation>>();

            if (!maintenanceAssetInfoList.isEmpty()) {

                for (Mpln.MaintenanceAssetInformation mplanAssetInfo : maintenanceAssetInfoList) {
                    SVMXA360__SM_MaintenancePlanAsset__c mAssetRecord = mapMaintenanceAssetFields(mplanAssetInfo, newRecordId);
                    String mplanAssetKey = mAssetRecord.SVMXA360__MaintenancePlan__c + '' + mAssetRecord.SVMXA360__Asset__c;
                    if (mplanAssetInfo.workRules != null) {
                        mplanAssetWorkRuleInfoMap.put( mplanAssetKey, mplanAssetInfo.workRules );
                    }
                    mplanAssetsToUpsert.add(mAssetRecord);
                }   
            }

            if (!mplanAssetsToUpsert.isEmpty()) {
                SvmxDatabase.upsertRecord( mplanAssetsToUpsert );
            }

            List<SVMXA360__SM_MaintenanceWorkRule__c> mWorkRulesList = new List<SVMXA360__SM_MaintenanceWorkRule__c>();
            Map<String, List<Mpln.ConditionTypeInfo>> mplanWRConditionalInfoMap = new Map<String, List<Mpln.ConditionTypeInfo>>();
            Set<String> mAssetIds = new Set<String>();

            for (SVMXA360__SM_MaintenancePlanAsset__c mAssetRecord : mplanAssetsToUpsert) {
                mAssetIds.add(mAssetRecord.Id);
                String mplanAssetKey = mAssetRecord.SVMXA360__MaintenancePlan__c + '' + mAssetRecord.SVMXA360__Asset__c;
                if (mplanAssetWorkRuleInfoMap.containsKey(mplanAssetKey)) {
                    List<Mpln.WorkRuleInformation> workRuleInfoList = mplanAssetWorkRuleInfoMap.get(mplanAssetKey);
                    for (Mpln.WorkRuleInformation workRuleInfo : workRuleInfoList) {
                        SVMXA360__SM_MaintenanceWorkRule__c	workRuleRec = mapWorkRuleFields(workRuleInfo, mAssetRecord.Id) ;
                        workRuleRec.SVMXA360__MaintenancePlan__c = newRecordId;
                        String mplanAssetConditionKey = workRuleRec.SVMXA360__MaintenancePlanAsset__c + '' + workRuleRec.SVMXA360__SortOrder__c;
                        if (workRuleInfo.detail != null) {
                            mplanWRConditionalInfoMap.put(mplanAssetConditionKey, workRuleInfo.detail);
                        }
                        mWorkRulesList.add(workRuleRec);                        
                    }
                }
            }

            if (!mWorkRulesList.isEmpty()) {
                SvmxDatabase.upsertRecord( mWorkRulesList );
            }
        
            List<SVMXA360__SM_Condition__c> assetConditionList = new List<SVMXA360__SM_Condition__c>();
            Set<String> workRuleIds = new Set<String>();
            for (SVMXA360__SM_MaintenanceWorkRule__c workRuleRec : mWorkRulesList) {
                workRuleIds.add(workRuleRec.Id);
                String mplanAssetConditionKey = workRuleRec.SVMXA360__MaintenancePlanAsset__c + '' + workRuleRec.SVMXA360__SortOrder__c;
                if (mplanWRConditionalInfoMap.containsKey(mplanAssetConditionKey)) {
                    List<Mpln.ConditionTypeInfo> wRConditionInfoList = mplanWRConditionalInfoMap.get(mplanAssetConditionKey);
                    for (Mpln.ConditionTypeInfo conditionInfo : wRConditionInfoList) {
                        SVMXA360__SM_Condition__c conditionRec = mapConditionFields(conditionInfo, workRuleRec.Id);
                        assetConditionList.add(conditionRec);
                    }
                }
            }

            Set<String> conditionIds = new Set<String>();

            if (!assetConditionList.isEmpty()) {
                SvmxDatabase.upsertRecord( assetConditionList );
                for (SVMXA360__SM_Condition__c conditionRec : assetConditionList) {
                    conditionIds.add(conditionRec.Id);
                }
            }
            deleteRecords(new List<String>{newRecordId}, mAssetIds, workRuleIds, conditionIds);

        }
        catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveMaintenancePlan() :  Failed to create Maintenance Plan. Error= ' + e.getMessage());
            throw e;
        }  
        catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveMaintenancePlan() : Failed to create Maintenance Plan. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveMaintenancePlan() - exit;' );
        }  

        return newRecordId;
    }


    private SVMXA360__SM_MaintenanceWorkRule__c mapWorkRuleFields (Mpln.WorkRuleInformation workRuleInfo, Id assetId) {
        SVMXA360__SM_MaintenanceWorkRule__c	workRuleRec = new SVMXA360__SM_MaintenanceWorkRule__c();
        workRuleRec.Name = workRuleInfo.workRuleTitle;
        workRuleRec.SVMXA360__MaintenancePlanAsset__c = assetId;
        workRuleRec.SVMXA360__AdvancedExpression__c = workRuleInfo.advancedExpression;
        workRuleRec.SVMXA360__SortOrder__c = workRuleInfo.sortOrder;
        workRuleRec.SVMXA360__WorkType__c = workRuleInfo.workTypeId;     
        return workRuleRec; 
    }   

    private SVMXA360__SM_MaintenancePlanAsset__c mapMaintenanceAssetFields (Mpln.MaintenanceAssetInformation mplanAssetInfo, String mplanId) {
        SVMXA360__SM_MaintenancePlanAsset__c mAssetRecord = new SVMXA360__SM_MaintenancePlanAsset__c();
        mAssetRecord.SVMXA360__MaintenancePlan__c = mplanId;
        mAssetRecord.SVMXA360__Asset__c = mplanAssetInfo.assetId;
        mAssetRecord.SVMXA360__WorkType__c = mplanAssetInfo.workTypeId;
        return mAssetRecord;
    }

    private SVMXA360__SM_Condition__c mapConditionFields(Mpln.ConditionTypeInfo conditionInfo, String workRuleId) {
        SVMXA360__SM_Condition__c conditionRec = new SVMXA360__SM_Condition__c();
        conditionRec.SVMXA360__MaintenanceWorkRule__c = workRuleId;
        conditionRec.SVMXA360__ConditionType__c = conditionInfo.conditionType;
        conditionRec.SVMXA360__Sequence__c = conditionInfo.sequence != null ? conditionInfo.sequence : 0;
        conditionRec.SVMXA360__RecurrencePattern__c = conditionInfo.recurrenceRule;
        if (conditionRec.SVMXA360__ConditionType__c.equalsIgnoreCase('Frequency') && conditionInfo.frequency != null) {
            conditionRec.SVMXA360__Operator__c = conditionInfo.frequency.operator; 
            conditionRec.SVMXA360__Operand__c = conditionInfo.frequency.attributeValue;
            conditionRec.SVMXA360__StartAt__c = conditionInfo.frequency.startAt;
            conditionRec.SVMXA360__StopAt__c = conditionInfo.frequency.stopAt;
            conditionRec.SVMXA360__Threshold__c = conditionInfo.frequency.threshold;
            if(conditionInfo.frequency.attributeCategory == ASSETOBJ) {
                conditionRec.SVMXA360__TechnicalAttribute__c = null;    
                conditionRec.SVMXA360__TechnicalAttributeCategory__c = null;
                conditionRec.SVMXA360__FieldAPIName__c = conditionInfo.frequency.attribute;
            } else {
                conditionRec.SVMXA360__FieldAPIName__c = null;
                conditionRec.SVMXA360__TechnicalAttribute__c = conditionInfo.frequency.attribute;
                conditionRec.SVMXA360__TechnicalAttributeCategory__c = conditionInfo.frequency.attributeCategory;
            }
        } else if (conditionRec.SVMXA360__ConditionType__c.equalsIgnoreCase('Criteria') && conditionInfo.criteria != null ){
            conditionRec.SVMXA360__Operator__c = conditionInfo.criteria.operator; 
            conditionRec.SVMXA360__Operand__c = conditionInfo.criteria.attributeValue;
            conditionRec.SVMXA360__Threshold__c = conditionInfo.criteria.threshold;
            if(conditionInfo.criteria.attributeCategory == ASSETOBJ) {
                //if asset object is selected then clear technical attribute fields
                conditionRec.SVMXA360__FieldAPIName__c = conditionInfo.criteria.attribute;
                conditionRec.SVMXA360__TechnicalAttribute__c = null;    
                conditionRec.SVMXA360__TechnicalAttributeCategory__c = null;
            } else{
                //if technical attribute is seleted then clear fieldapiname
                conditionRec.SVMXA360__FieldAPIName__c = null;
                conditionRec.SVMXA360__TechnicalAttribute__c = conditionInfo.criteria.attribute;    
                conditionRec.SVMXA360__TechnicalAttributeCategory__c = conditionInfo.criteria.attributeCategory;
            }
        }    
        
        return conditionRec;
    }

    /**
     * public method to Save Workrule for the tempalte
     * @param: String mplnRecordId, String maintenanceAssetsJSON
     * @ex: 
     */
    public void saveWorkRuleTemplate (Mpln.MaintenanceAssetInformation maintenanceAssetInfo) {

        Savepoint sp = Database.setSavePoint();        
        try { 
            List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateList = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();
            Map<String, List<Mpln.ConditionTypeInfo>> mplanWRConditionalInfoMap = new Map<String, List<Mpln.ConditionTypeInfo>>();
            Set<String> mplanWorkRuleIdSet = new Set<String>();

                if( maintenanceAssetInfo != null && maintenanceAssetInfo.workRules != null) {
                    for(Mpln.WorkRuleInformation mplnWorkRuleTemplateInfo : maintenanceAssetInfo.workRules ) {
                        SVMXA360__MaintenanceWorkRuleTemplate__c templateRec = new SVMXA360__MaintenanceWorkRuleTemplate__c();
                        if(String.isNotBlank(mplnWorkRuleTemplateInfo.workRuleId)) {
                            mplanWorkRuleIdSet.add(mplnWorkRuleTemplateInfo.workRuleId);
                            templateRec = new SVMXA360__MaintenanceWorkRuleTemplate__c(id = mplnWorkRuleTemplateInfo.workRuleId);
                        }
                        templateRec.Name = mplnWorkRuleTemplateInfo.workRuleTitle;
                        templateRec.SVMXA360__SM_TechnicalAttributeTemplate__c = mplnWorkRuleTemplateInfo.attributeTemplate;
                        templateRec.SVMXA360__WorkTypeId__c = mplnWorkRuleTemplateInfo.workTypeId;
                        templateRec.SVMXA360__ApplicableProductId__c = maintenanceAssetInfo.applicableProduct == null ? null : maintenanceAssetInfo.applicableProduct;
                        templateRec.SVMXA360__SortOrder__c = mplnWorkRuleTemplateInfo.sortOrder;
                        templateRec.SVMXA360__AdvancedExpression__c = mplnWorkRuleTemplateInfo.advancedExpression;
                        templateRec.SVMXA360__MaintenancePlanTemplateId__c = maintenanceAssetInfo.mplnTemplateId;
                        templateRec.SVMXA360__Type__c = 'Condition';
                        if(mplnWorkRuleTemplateInfo.detail != null) {
                            mplanWRConditionalInfoMap.put(templateRec.SVMXA360__ApplicableProductId__c,mplnWorkRuleTemplateInfo.detail);    
                        }
                        workRuleTemplateList.add(templateRec);
                    }
                }

                

                if(!workRuleTemplateList.isEmpty()) {
                    SvmxDatabase.upsertRecord(workRuleTemplateList);  
                }

                List<SVMXA360__SM_Condition__c> assetConditionList = new List<SVMXA360__SM_Condition__c>();
                for(SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec : workRuleTemplateList) {
                    if(mplanWRConditionalInfoMap.containsKey(workRuleTemplateRec.SVMXA360__ApplicableProductId__c)) {
                        for(Mpln.ConditionTypeInfo conditionTypeInfo : mplanWRConditionalInfoMap.get(workRuleTemplateRec.SVMXA360__ApplicableProductId__c)) {
                            SVMXA360__SM_Condition__c conditionRec = new SVMXA360__SM_Condition__c();
                            conditionRec = mapConditionFields(conditionTypeInfo, null);
                            if(conditionTypeInfo.id !=null ) {
                                conditionRec.id = conditionTypeInfo.id;
                            }
                            conditionRec.SVMXA360__MaintenanceWorkRuleTemplate__c = workRuleTemplateRec.Id;
                            assetConditionList.add(conditionRec);
                        }
                    }
                }
                if(!assetConditionList.isEmpty()) {
                    SvmxDatabase.upsertRecord(assetConditionList);        
                }

                //If only Asset conditions are deleted from workrule, then delete the asset condtions from database also
                if(!mplanWorkRuleIdSet.isEmpty()) {
                    List<SVMXA360__SM_Condition__c> conditionListToDelete = new List<SVMXA360__SM_Condition__c>();
                    //get all asset conditions for workrule template
                    List<Mpln.ConditionTypeInfo> conditionInfoList = new List<Mpln.ConditionTypeInfo>();
                    Set<Id> conditionIdSet = new Set<Id>();
                    for(SVMXA360__MaintenanceWorkRuleTemplate__c workruleTemplate : [SELECT Id,
                                                (SELECT Id FROM SVMXA360__Asset_Conditions__r WHERE Id NOT IN :assetConditionList) 
                                                FROM SVMXA360__MaintenanceWorkRuleTemplate__c 
                                                WHERE Id IN: mplanWorkRuleIdSet]) {
                        if(!workruleTemplate.SVMXA360__Asset_Conditions__r.isEmpty()) {
                            conditionListToDelete.addAll(workruleTemplate.SVMXA360__Asset_Conditions__r);
                        }
                    } 
                    if(!conditionListToDelete.isEmpty()) {
                        SvmxDatabase.deleteRecord(conditionListToDelete);
                    }   
                }
            
        } catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveWorkRuleTemplate() :  Failed to create Maintenance Plan. Error= ' + e.getMessage());
            throw e;
        }  
        catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveWorkRuleTemplate() : Failed to create Maintenance Plan. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveWorkRuleTemplate() - exit;' );
        }
    }

    /**
     * public method to delete Workrules and asset conditions from the template
     * @param: String requestJson
     * @ex: [{'id':recordId}]
     */
    public void deleteWorkRules(List<String> workRuleIdList) {
        System.debug(LoggingLevel.INFO, 'deleteWorkRules() - enter; requestJson= ' + workRuleIdList);   
        
        List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleListToDelete = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();
        
        if(!workRuleIdList.isEmpty()) {
            for(String workRuleId :  workRuleIdList) {
                SVMXA360__MaintenanceWorkRuleTemplate__c templateRecToDelete = new SVMXA360__MaintenanceWorkRuleTemplate__c(id=workRuleId);
                workRuleListToDelete.add(templateRecToDelete);       
            }
        }  
            
        if(!workRuleListToDelete.isEmpty()) {
            List<SVMXA360__SM_Condition__c> assetConditionList = SvmxDatabase.query([SELECT Id FROM SVMXA360__SM_Condition__c 
                                                                                    WHERE SVMXA360__MaintenanceWorkRuleTemplate__c IN: workRuleListToDelete]);
            SvmxDatabase.deleteRecord(workRuleListToDelete);
            if(!assetConditionList.isEmpty()) {
                SvmxDatabase.deleteRecord(assetConditionList);    
            }
        }
    }
    
    public void deleteRecords (List<String> mplanIds) {
        System.debug(LoggingLevel.INFO, 'deleteRecords() - enter; mplanIds= ' + mplanIds );
		Savepoint sp = Database.setSavePoint();        
		try {
			deleteRecords(mplanIds, null, null, null);
        }catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'deleteRecords() : Failed to delete Maintenance Plan. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deleteRecords() - exit;' );
        } 
    }
    
    private void deleteRecords (List<String> mplanIds, Set<String> mAssetIds, Set<String> workRuleIds, Set<String> conditionIds) {
		if (mplanIds != null && !mplanIds.isEmpty()) {
            List<SVMXA360__SM_MaintenanceWorkRule__c> workRuleList = (List<SVMXA360__SM_MaintenanceWorkRule__c>)SvmxDatabase.query([SELECT Id, (SELECT Id FROM SVMXA360__Asset_Conditions__r WHERE Id NOT IN: conditionIds )
                                                                                                                                    FROM SVMXA360__SM_MaintenanceWorkRule__c WHERE (Id NOT IN: workRuleIds AND SVMXA360__MaintenancePlan__c IN: mplanIds) OR Id IN: workRuleIds ]);
            
            List<SVMXA360__SM_Condition__c> conditionsToDelete = new List<SVMXA360__SM_Condition__c>();    
            List<SVMXA360__SM_MaintenanceWorkRule__c> workRulesToDelete = new List<SVMXA360__SM_MaintenanceWorkRule__c>();
            
            for (SVMXA360__SM_MaintenanceWorkRule__c workRuleRec : workRuleList) {
                conditionsToDelete.addAll(workRuleRec.Asset_Conditions__r);
                if (workRuleIds != null && !workRuleIds.contains(workRuleRec.Id)) {
                    workRulesToDelete.add(workRuleRec);
                }
            }  
            
            SvmxDatabase.deleteRecord( conditionsToDelete );
            
            SvmxDatabase.deleteRecord( workRulesToDelete );
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__SM_MaintenancePlanAsset__c WHERE Id NOT IN:mAssetIds AND 
                                        SVMXA360__MaintenancePlan__c IN: mplanIds]);
        }
    }

}