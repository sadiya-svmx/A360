public with sharing class COMM_Constants {
    public static final String DAYS = 'Days';
    public static final String MONTHS = 'Months';
    public static final String YEARS = 'Years';
    public static final String WEEKS = 'Weeks';
    public static final String CREATE_EVENT = 'create_event';
    public static final String UPDATE_EVENT = 'update_event';
    public static final String WARRANTY_TERM_FIELDS = 'Id,WarrantyTermName,SVMXA360__AssetExpression__c,IsActive,EffectiveStartDate,' 
        + 'WarrantyDuration,ExpensesCoveredDuration,LaborCoveredDuration,PartsCoveredDuration,SVMXA360__TravelCoveredDuration__c,ExchangeType,'
        + 'Exclusions,ExpensesCovered,LaborCovered,PartsCovered,SVMXA360__TravelCovered__c,' 
        + 'IsTransferable,WarrantyUnitOfTime,ExpensesCoveredUnitOfTime,SVMXA360__TravelCoveredUnitOfTime__c,'
        + 'LaborCoveredUnitOfTime,PartsCoveredUnitOfTime,Code,WarrantyType';
    
    public static final String WARRANTY_CONFIG_FIELDS = 'Id,SVMXA360__AutoWarrOnCreateAsset__c,SVMXA360__ObjectMapping__c,'
        + 'SVMXA360__AutoWarrOnUpdateAsset__c,SVMXA360__EffectiveFromConfig__c';

    
    public static final String WARRANTY_TERM_PRODUCT  = 'Id,ProductWarrantyTermNumber,CoveredProductFamily,CoveredProductId,WarrantyTermId,WarrantyTerm.SVMXA360__AssetExpression__c';
    
    public static final String WARRANTY_TERM_PRODUCT_REF_FIELDS = 'SVMXA360__WarrantyTerm__r.SVMXA360__AssetExpression__c,' 
        + 'SVMXA360__WarrantyTerm__r.IsActive,SVMXA360__WarrantyTerm__r.EffectiveStartDate,'
        + 'SVMXA360__WarrantyTerm__r.ExchangeType,SVMXA360__WarrantyTerm__r.ExpensesCoveredDuration,'
        + 'SVMXA360__WarrantyTerm__r.LaborCoveredDuration,SVMXA360__WarrantyTerm__r.PartsCoveredDuration,' 
        + 'SVMXA360__WarrantyTerm__r.Exclusions,SVMXA360__WarrantyTerm__r.ExpensesCovered,'
        + 'SVMXA360__WarrantyTerm__r.LaborCovered,SVMXA360__WarrantyTerm__r.SVMXA360__Onsite_Repair__c,'
        + 'SVMXA360__WarrantyTerm__r.PartsCovered,SVMXA360__WarrantyTerm__r.SVMXA360__RMA_Required__c,'
        + 'SVMXA360__WarrantyTerm__r.SVMXA360__Shipment_Allowed__c,SVMXA360__WarrantyTerm__r.IsTransferable,'
        + 'SVMXA360__WarrantyTerm__r.ExpensesCoveredUnitOfTime,SVMXA360__WarrantyTerm__r.LaborCoveredUnitOfTime,'
        + 'SVMXA360__WarrantyTerm__r.PartsCoveredUnitOfTime,SVMXA360__WarrantyTerm__r.Code,'
        + 'SVMXA360__WarrantyTerm__r.WarrantyType';
    
    public static final String RECORD_TYPE_ENTITLED_SERVICE = 'EntitledServices';
}