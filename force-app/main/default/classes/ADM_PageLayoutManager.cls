/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete Pagelayouts.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                8 Jun 2020      Created.
 * A360TOOL-7   Ramachandra Mohan       21 Sep 2020     Methods to support bulk save.
 * A360ENG-911  Jason Bradley           20 Apr 2021     Fixed queryPageElements not returning Custom
 *                                                      Button configuration.
 * A360ADM-976  Sachin S                29 Apr 2021     Included name fields for the entities Value/Field Mapping,
 *                                                      Form Fill & Lookup Config.
 * A360TOOL-876 Ramachandra Mohan       26 Nov 2021     Included null check for readOnly properties.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_PageLayoutManager {

    private Set<Id> pageSectionIds;
    private Set<Id> pageDetailSectionIds;
    private Set<Id> pageElementIds;
    private Set<Id> pageEventIds;
    private Set<Id> mappingIds;
    private Set<Id> expressionBasedIds;
    private Set<Id> lookupConfigIds;
    private Map<String, List<String>> fieldSetMap;
    private List<SVMXA360__CONF_LayoutElement__c> buttonElements;
    private List<SVMXA360__CONF_ExpressionBasedMappingRow__c> expressionMappingRows;

    private static ADM_PageLayoutManager instance;

    private static final String TRANSACTION_STANDALONEEDIT = 'Standalone Edit';
    private static final String TRANSACTION_SOURCETOTARGET = 'Source To Target';
    private static final String SCREENTYPE_TRANSACTION = 'TRANSACTION'; 
    private static final String CONTEXTKEY_SECTIONTITLE = 'SPM Section Title';
    private static final String CONTEXTKEY_BUTTON = 'SPM Button';

    public static ADM_PageLayoutManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_PageLayoutManager();
        }
        
        return instance;
    }

    public List<Adm.PageLayout> getAllPageLayoutsWithDetails(){
        
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayoutsWithDetails() - enter' );
        
        List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();  
        
        try {

            final Map<Id, SVMXA360__CONF_Layout__c> layoutMap = new Map<Id, SVMXA360__CONF_Layout__c>();
            layoutMap.putAll( queryAllPageLayoutWithChildren() );
            
            pageLayoutList = getPageLayoutsWithChildDetails(layoutMap);
            
            final Map<String, List<String>> tagsMap = getSVMXTags( (List<String>) new List<Id>( layoutMap.keySet() )  );
            
            for( Adm.PageLayout pageLayout : pageLayoutList ) {
                pageLayout.pageHeader.tags = tagsMap.get(pageLayout.id);
                pageLayout.tags = tagsMap.get(pageLayout.id);
            }
        }
        catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getAllPageLayoutsWithDetails() : Failed to retrieve page layouts. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayoutsWithDetails() - exit; pageLayoutList.size()= ' + pageLayoutList.size() );
        }

        return pageLayoutList;
    }

    public List<Adm.PageLayout> getPageLayoutsWithDetails(List<String> pageLayoutIds){
        
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayoutsWithDetails() - enter' );
        
        List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();  
        
        try {
            if( pageLayoutIds.size() > 0 && pageLayoutIds != null ) { 
                final Map<Id, SVMXA360__CONF_Layout__c> layoutMap = new Map<Id, SVMXA360__CONF_Layout__c>();
                layoutMap.putAll( queryAllPageLayoutWithChildren(pageLayoutIds) );
                
                pageLayoutList = getPageLayoutsWithChildDetails(layoutMap);
            }
        }
        catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getAllPageLayoutsWithDetails() : Failed to retrieve page layouts. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayoutsWithDetails() - exit; pageLayoutList.size()= ' + pageLayoutList.size() );
        }

        return pageLayoutList;
    }

    public List<Adm.PageLayout> getPageLayoutsWithChildDetails(Map<Id, SVMXA360__CONF_Layout__c> layoutMap) {

            List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>(); 

            final Map<Id, List<SVMXA360__CONF_LayoutElement__c>> layoutIdHeaderMap = new Map<Id, List<SVMXA360__CONF_LayoutElement__c>>();
            final Map<Id, List<SVMXA360__CONF_LayoutElement__c>> layoutIdDetailMap = new Map<Id, List<SVMXA360__CONF_LayoutElement__c>>();
            final Map<Id, List<SVMXA360__CONF_LayoutElement__c>> layoutIdSectionMap = new Map<Id, List<SVMXA360__CONF_LayoutElement__c>>();

            populateSectionDetailMap( layoutIdHeaderMap, layoutIdSectionMap, layoutIdDetailMap );
            Set<String> expressionBasedMappingIds = new Set<String>();
            
            for(SVMXA360__CONF_Layout__c layoutRecord  : layoutMap.values() ) {
                
                Adm.PageLayout pageLayoutInfo = createPageHeaderWrapper(layoutRecord);
                
                if (layoutRecord.SVMXA360__ApplyMapping__c != null && layoutRecord.SVMXA360__ApplyMapping__c.equalsIgnoreCase('conditional')) {
                    expressionBasedMappingIds.add(layoutRecord.Id);
                }
                
                final List<SVMXA360__CONF_LayoutElement__c> layoutElementList = new List<SVMXA360__CONF_LayoutElement__c>();
                if( layoutIdHeaderMap.containsKey( layoutRecord.Id ) ) {
                    layoutElementList.addAll( layoutIdHeaderMap.get(layoutRecord.Id) );
                }

                // TODO: Handle related list more than 200 records
                // to avoid Aggregate query has too many rows for direct assignment error.
                final Map<String, Adm.PageSection> layoutSectionMap = new Map<String, Adm.PageSection>();
                for(SVMXA360__CONF_LayoutSection__c layoutSection : layoutRecord.SVMXA360__LayoutSections__r) {
                    
                    final Adm.PageSection pageSection = createSectionWrapper(layoutSection);    
                    layoutSectionMap.put(layoutSection.Id, pageSection);
                    
                    if( layoutIdSectionMap.containsKey( layoutSection.Id ) ) {
                        layoutElementList.addAll( layoutIdSectionMap.get(layoutSection.Id) );
                    }
                }
                
                // TODO: Handle related list more than 200 records
                // to avoid Aggregate query has too many rows for direct assignment error.
                final Map<String, Adm.PageDetail> layoutDetailMap = new Map<String, Adm.PageDetail>();
                for(SVMXA360__CONF_LayoutRelatedSection__c relatedSection : layoutRecord.SVMXA360__RelatedSections__r) {
                    
                    if (relatedSection.SVMXA360__ApplyValueMapping__c != null && relatedSection.SVMXA360__ApplyValueMapping__c.equalsIgnoreCase('conditional')) {
                        expressionBasedMappingIds.add(relatedSection.Id);
                    }
                    
                    final Adm.PageDetail pageDetail = createDetailSectionWrapper(relatedSection);
                    layoutDetailMap.put(relatedSection.Id, pageDetail);
                    
                    if( layoutIdDetailMap.containsKey( relatedSection.Id ) ) {
                        layoutElementList.addAll( layoutIdDetailMap.get(relatedSection.Id) );
                    }
                }
                
                for( SVMXA360__CONF_LayoutElement__c layoutElement : layoutElementList ){
                    
                    if (layoutElement.SVMXA360__ApplyMapping__c != null && layoutElement.SVMXA360__ApplyMapping__c.equalsIgnoreCase('conditional')) {
                        expressionBasedMappingIds.add(layoutElement.Id);
                    }
                    
                    if(layoutElement.SVMXA360__LayoutId__c != null && layoutElement.SVMXA360__Type__c.equalsIgnoreCase('Button')){
                        
                        if(pageLayoutInfo.pageHeader.elements == null){
                            pageLayoutInfo.pageHeader.elements = new List<Adm.PageElement>();
                        }

                        pageLayoutInfo.pageHeader.elements.add(createElementWrapper(layoutElement));
                    }

                    if(layoutSectionMap.containsKey(layoutElement.SVMXA360__LayoutSection__c)){
                        final Adm.PageSection pageSectionInfo = layoutSectionMap.get(layoutElement.SVMXA360__LayoutSection__c);
                        
                        if(pageSectionInfo.elements == null){
                            pageSectionInfo.elements = new List<Adm.PageElement>();
                        }
                        
                        pageSectionInfo.elements.add(createElementWrapper(layoutElement));
                    }
                    
                    if(layoutDetailMap.containsKey(layoutElement.SVMXA360__LayoutRelatedSection__c)){
                        final Adm.PageDetail pageDetailInfo = layoutDetailMap.get(layoutElement.SVMXA360__LayoutRelatedSection__c);
                        
                        if(pageDetailInfo.elements == null){
                            pageDetailInfo.elements = new List<Adm.PageElement>();
                        }
                        
                        pageDetailInfo.elements.add(createElementWrapper(layoutElement));
                    }
                }
                
                pageLayoutInfo.pageHeader.sections = layoutSectionMap.values();
                pageLayoutInfo.lines = layoutDetailMap.values();
                
                if (pageLayoutInfo != null && pageLayoutInfo.lines != null && pageLayoutInfo.lines.size() > 0) {
		    for( Adm.PageDetail pageDetail : pageLayoutInfo.lines ) {
			if (pageDetail != null && pageDetail.elements != null && pageDetail.elements.size() > 0)  {
			    for( Adm.PageElement pageElement : pageDetail.elements ) {
				if( pageElement.applyMapping != null && 'conditional'.equalsIgnoreCase(pageElement.applyMapping) ) {
				    expressionBasedMappingIds.add(pageElement.Id);
				}
			    }
			}
		    }
		}

                pageLayoutList.add( pageLayoutInfo );
            }
            
			populateExpressionBaseMapping( pageLayoutList, expressionBasedMappingIds );
        
        return pageLayoutList;

    }    
    
    private void populateExpressionBaseMapping( final List<Adm.PageLayout> pageLayoutList, final Set<String> expressionBasedMappingIds ) {
        
        Map<String, Adm.ExpressionBasedMapping> expBasedMappingParentMap = queryExpressionBasedMappings (new List<String>(expressionBasedMappingIds ));
        
        for( Adm.PageLayout pageLayoutInfo : pageLayoutList ) {
            
            pageLayoutInfo.pageHeader.expressionBasedMapping = expBasedMappingParentMap.containsKey(pageLayoutInfo.id) ? expBasedMappingParentMap.get(pageLayoutInfo.id): null;
	    if (pageLayoutInfo != null && pageLayoutInfo.lines != null && pageLayoutInfo.lines.size() > 0) {
	       for( Adm.PageDetail pageDetail : pageLayoutInfo.lines ) {

		  pageDetail.expressionBasedValueMapping = expBasedMappingParentMap.containsKey(pageDetail.id) ? expBasedMappingParentMap.get(pageDetail.id): null;
		  if (pageDetail != null && pageDetail.elements != null && pageDetail.elements.size() > 0)  {
		     for( Adm.PageElement pageElement : pageDetail.elements ) {
			pageElement.expressionBasedMapping = expBasedMappingParentMap.containsKey(pageElement.id) ? expBasedMappingParentMap.get(pageElement.id): null;
		     }
		   }
	        }
	    }
            
            if( pageLayoutInfo.pageHeader.elements != null ) {
                
                for( Adm.PageElement pageElement : pageLayoutInfo.pageHeader.elements ) {
                    pageElement.expressionBasedMapping = expBasedMappingParentMap.containsKey(pageElement.id) ? expBasedMappingParentMap.get(pageElement.id): null;
                }
            }
            
            if( pageLayoutInfo.pageHeader.sections != null ) {
                
                for( Adm.pageSection section : pageLayoutInfo.pageHeader.sections ) {
                    if( section.elements != null ) {
                        for( Adm.PageElement pageElement : section.elements ) {
                            pageElement.expressionBasedMapping = expBasedMappingParentMap.containsKey(pageElement.id) ? expBasedMappingParentMap.get(pageElement.id): null;
                        }
                    }
                }
            }
        }
    }
    
    private void populateSectionDetailMap( final Map<Id, List<SVMXA360__CONF_LayoutElement__c>> layoutIdHeaderMap, final Map<Id, List<SVMXA360__CONF_LayoutElement__c>> layoutIdSectionMap, final Map<Id, List<SVMXA360__CONF_LayoutElement__c>> layoutIdDetailMap ) {
        
        for( SVMXA360__CONF_LayoutElement__c layoutElement : queryAllPageElements() ) {
            
            if(layoutElement.SVMXA360__LayoutId__c != null && layoutElement.SVMXA360__Type__c.equalsIgnoreCase('Button')){
                
                if( !layoutIdHeaderMap.containsKey(layoutElement.SVMXA360__LayoutId__c) ) {
                    layoutIdHeaderMap.put( layoutElement.SVMXA360__LayoutId__c, new List<SVMXA360__CONF_LayoutElement__c>() );
                }
                
                layoutIdHeaderMap.get( layoutElement.SVMXA360__LayoutId__c).add(layoutElement );
            }

            if( String.isNotBlank(layoutElement.SVMXA360__LayoutSection__c) ) {
                
                if( !layoutIdSectionMap.containsKey(layoutElement.SVMXA360__LayoutSection__c) ) {
                    layoutIdSectionMap.put( layoutElement.SVMXA360__LayoutSection__c, new List<SVMXA360__CONF_LayoutElement__c>() );
                }
                
                layoutIdSectionMap.get( layoutElement.SVMXA360__LayoutSection__c).add(layoutElement );
            }
            
            if( String.isNotBlank(layoutElement.SVMXA360__LayoutRelatedSection__c) ) {
                
                if( !layoutIdDetailMap.containsKey(layoutElement.SVMXA360__LayoutRelatedSection__c) ) {
                    layoutIdDetailMap.put( layoutElement.SVMXA360__LayoutRelatedSection__c, new List<SVMXA360__CONF_LayoutElement__c>() );
                }
                layoutIdDetailMap.get( layoutElement.SVMXA360__LayoutRelatedSection__c ).add(layoutElement);
            }
        }
    }

    public void manageSVMXTags (final String pageLayoutId, final List<String> tagsList) {
        ADM_TagHandler.getInstance().manageSVMXTags(pageLayoutId, tagsList);
    }

    public Map<String, List<String>> getSVMXTags (final List<String> pageLayoutList) {
        return ADM_TagHandler.getInstance().getSVMXTags(pageLayoutList);
    }

    public List<String> getAllTags () {
        return ADM_TagHandler.getInstance().getAllTags();
    }

    /**
     * This method retrieves pagelayout details for requested id and populate 
     * informations it to the object mapping wrapper.
     */
    public Adm.PageLayout getPageLayoutDetails( final String pageLayoutId, final Boolean translationRequired, Adm.SourceOrigin sourceOrigin ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - enter' );
        
        Adm.PageLayout pageLayoutInfo;
        
        try {
            
            // Verify pagelayout id
            if( String.isBlank(pageLayoutId) ) {
             
                System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Invalid request parameters. pageLayoutId= ' + pageLayoutId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.SCREEN_NOT_FOUND );
            }
            
            SVMXA360__CONF_Layout__c layoutRecord = queryPageLayoutWithChildren( pageLayoutId );
            if(translationRequired){
                layoutRecord = (SVMXA360__CONF_Layout__c)ADM_TranslationUtils.getInstance().getTranslatedRecord(layoutRecord);
            }
            pageLayoutInfo = createPageHeaderWrapper(layoutRecord);

            List<String> expressionBasedMappingIds = new List<String>();

            if (layoutRecord.SVMXA360__ApplyMapping__c != null && layoutRecord.SVMXA360__ApplyMapping__c.equalsIgnoreCase('conditional')) {
                expressionBasedMappingIds.add(layoutRecord.Id);
            }

            /*
                Note: The below query is to identify the system admin profile to enable
                launch designer link, hence FLS check not required. 
            */

            if ( Schema.sObjectType.SVMXA360__CONF_Layout__c.isAccessible() && 
                    Schema.sObjectType.SVMXA360__CONF_Layout__c.isUpdateable() && 
                    Schema.sObjectType.SVMXA360__CONF_Layout__c.isCreateable() && 
                    Schema.sObjectType.SVMXA360__CONF_Layout__c.isdeletable()) {
                        pageLayoutInfo.launchDesigner = true;
            } else {
                pageLayoutInfo.launchDesigner = false;
            }                                       
            pageLayoutInfo.enableDebugMode = ADM_SPMSettingsManager.getDebugModeSettings();                                       
            final Map<String, Adm.PageSection> layoutSectionMap = new Map<String, Adm.PageSection>();
            
            List<SVMXA360__CONF_LayoutSection__c> layoutSectionList = layoutRecord.SVMXA360__LayoutSections__r;
            if(translationRequired){
                layoutSectionList = (List<SVMXA360__CONF_LayoutSection__c>)ADM_TranslationUtils.getInstance().getTranslatedRecord(layoutSectionList);
            }
            for(SVMXA360__CONF_LayoutSection__c layoutSection : layoutSectionList){
                final Adm.PageSection pageSection = createSectionWrapper(layoutSection);    
                layoutSectionMap.put(layoutSection.Id, pageSection);
            }

            final Map<String, Adm.PageDetail> layoutDetailMap = new Map<String, Adm.PageDetail>();
            List<SVMXA360__CONF_LayoutRelatedSection__c> layoutRelatedSectionList = layoutRecord.SVMXA360__RelatedSections__r;
            
            for(SVMXA360__CONF_LayoutRelatedSection__c relatedSection : layoutRelatedSectionList){
                if (relatedSection.SVMXA360__ApplyValueMapping__c != null && relatedSection.SVMXA360__ApplyValueMapping__c.equalsIgnoreCase('conditional')) {
                    expressionBasedMappingIds.add(relatedSection.Id);
                }
                final Adm.PageDetail pageDetail = createDetailSectionWrapper(relatedSection);
                layoutDetailMap.put(relatedSection.Id, pageDetail);
            }

            if(translationRequired){
                layoutRelatedSectionList = (List<SVMXA360__CONF_LayoutRelatedSection__c>)ADM_TranslationUtils.getInstance().getTranslatedRecord(layoutRelatedSectionList);
            }    

            List<SVMXA360__CONF_LayoutElement__c> elementsList = queryPageElements(pageLayoutId, layoutSectionMap.keySet(), layoutDetailMap.keySet());
            
            for (SVMXA360__CONF_LayoutElement__c layoutElement : elementsList) {

                if (layoutElement.SVMXA360__ApplyMapping__c != null && layoutElement.SVMXA360__ApplyMapping__c.equalsIgnoreCase('conditional')) {
                    expressionBasedMappingIds.add(layoutElement.Id);
                }
            }

            Map<String, Adm.ExpressionBasedMapping> expBasedMappingParentMap = queryExpressionBasedMappings (expressionBasedMappingIds);
            pageLayoutInfo.pageHeader.expressionBasedMapping = expBasedMappingParentMap.containsKey(layoutRecord.Id) ? expBasedMappingParentMap.get(layoutRecord.Id): null;
 
            for(SVMXA360__CONF_LayoutRelatedSection__c relatedSectionRec : layoutRelatedSectionList){
                if(layoutDetailMap.containsKey(relatedSectionRec.Id)){
                    Adm.PageDetail pageDetail = layoutDetailMap.get(relatedSectionRec.Id);
                    pageDetail.title = relatedSectionRec.Name;
                    pageDetail.expressionBasedValueMapping = expBasedMappingParentMap.containsKey(relatedSectionRec.Id) ? expBasedMappingParentMap.get(relatedSectionRec.Id): null;
                }                  
            }

            for( SVMXA360__CONF_LayoutElement__c layoutElement : elementsList ){
                Adm.PageElement pageElement;
                if(layoutElement.SVMXA360__LayoutId__c != null && layoutElement.SVMXA360__Type__c.equalsIgnoreCase('Button')){
                    
                    if(buttonElements == null){
                        buttonElements =  new List<SVMXA360__CONF_LayoutElement__c>();
                    }
                    buttonElements.add(layoutElement);
                }

                if(layoutSectionMap.containsKey(layoutElement.SVMXA360__LayoutSection__c)){
                    final Adm.PageSection pageSectionInfo = layoutSectionMap.get(layoutElement.SVMXA360__LayoutSection__c);
                    
                    if(pageSectionInfo.elements == null){
                        pageSectionInfo.elements = new List<Adm.PageElement>();
                    }
                    
                    pageElement = createElementWrapper(layoutElement);
                    pageElement.expressionBasedMapping = expBasedMappingParentMap.containsKey(pageElement.Id) ? expBasedMappingParentMap.get(pageElement.Id): null;

                    pageSectionInfo.elements.add(pageElement);
                }
                
                if(layoutDetailMap.containsKey(layoutElement.SVMXA360__LayoutRelatedSection__c)){
                    final Adm.PageDetail pageDetailInfo = layoutDetailMap.get(layoutElement.SVMXA360__LayoutRelatedSection__c);
                    
                    if(pageDetailInfo.elements == null){
                        pageDetailInfo.elements = new List<Adm.PageElement>();
                    }
                    pageElement = createElementWrapper(layoutElement);
                    pageElement.expressionBasedMapping = expBasedMappingParentMap.containsKey(pageElement.Id) ? expBasedMappingParentMap.get(pageElement.Id): null;

                    pageDetailInfo.elements.add(pageElement);
                }

            }
 
            pageLayoutInfo.pageHeader.sections = layoutSectionMap.values();

            if(buttonElements != null){

                if(translationRequired){
                    buttonElements = (List<SVMXA360__CONF_LayoutElement__c>)ADM_TranslationUtils.getInstance().getTranslatedRecord(buttonElements);
                }
                for(SVMXA360__CONF_LayoutElement__c layoutElement : buttonElements){
                    if(pageLayoutInfo.pageHeader.elements == null){
                        pageLayoutInfo.pageHeader.elements = new List<Adm.PageElement>();
                    }

                    Adm.PageElement pageElement = createElementWrapper(layoutElement);
                    pageLayoutInfo.pageHeader.elements.add(pageElement);
                }
            }

            pageLayoutInfo.pageHeader.tags = getSVMXTags(new List<String> {pageLayoutId})?.get(pageLayoutId);
            pageLayoutInfo.lines = layoutDetailMap.values();

        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve page layout. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            if(sourceOrigin == Adm.SourceOrigin.Admin){
                saveRecentItemInfo(pageLayoutInfo);
            }
            System.debug( LoggingLevel.FINEST, 'getPageLayoutDetails() - exit; Page Layout Detail ' + pageLayoutInfo );
        }
        
        return pageLayoutInfo;

    }  

    public List<Adm.PageLayout> getAllPageLayouts( final String screenType, final Boolean translationRequired){
        
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - enter :  screenType ' +  screenType );
        
        List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();  
        
        try{

            List<SVMXA360__CONF_Layout__c> layoutRecordList = new List<SVMXA360__CONF_Layout__c>();

            if(String.isBlank(screenType) || screenType.equalsIgnoreCase('Screen')){
                List<String> screenTypeValues = new List<String> {'', 'Screen'};
                layoutRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__HideName__c, SVMXA360__ObjectAPIName__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__TransactionType__c, SVMXA360__FieldSets__c,
                SVMXA360__SourceObjectAPIName__c, SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, SVMXA360__ScreenType__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__ApplyMapping__c FROM SVMXA360__CONF_Layout__c 
                WHERE SVMXA360__ScreenType__c IN : screenTypeValues ORDER BY Name]);
            } else {
                layoutRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__HideName__c, SVMXA360__ObjectAPIName__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__TransactionType__c, SVMXA360__FieldSets__c,
                SVMXA360__SourceObjectAPIName__c, SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, SVMXA360__ScreenType__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__ApplyMapping__c FROM SVMXA360__CONF_Layout__c 
                WHERE SVMXA360__ScreenType__c =: screenType ORDER BY Name]);
            }

            if(translationRequired){
                layoutRecordList = (List<SVMXA360__CONF_Layout__c>)ADM_TranslationUtils.getInstance().getTranslatedRecord(layoutRecordList);
            }

            Map<String, List<String>> layoutTagsMap = new Map<String, List<String>>();
            List<String> layoutIds = new List<String>();
            for (SVMXA360__CONF_Layout__c layoutRecord  : layoutRecordList) {
                layoutIds.add(layoutRecord.Id);
            }

            layoutTagsMap = getSVMXTags (layoutIds) ;

            for(SVMXA360__CONF_Layout__c layoutRecord  : layoutRecordList){
                Adm.PageLayout layoutWrapRecord = createPageHeaderWrapper( layoutRecord );
                if (layoutTagsMap.containsKey(layoutRecord.Id)) {
                    layoutWrapRecord.pageHeader.tags = layoutTagsMap.get(layoutRecord.Id);
                }
                pageLayoutList.add( layoutWrapRecord );                            
            }

        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getAllPageLayouts() : Failed to retrieve page layouts. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - exit; pageLayoutList.size()= ' + pageLayoutList.size() );
        }

        return pageLayoutList;
    }

    /**
     * This method retrieves transaction details of specific object 
     * Input parameters are screen type and object name of layout
     */
    public Common.ServiceResponse getLayoutsByObjectNameAndType( final String screenType, final String objectName ){
        
        System.debug( LoggingLevel.DEBUG, 'getLayoutsByObjectNameAndType() - enter :  screenType : ' +  screenType + 'objectName :' + objectName );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();  
        
        try{

            // Verify for valid parameters.
            if( String.isBlank(screenType) || String.isBlank(objectName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getLayoutsByObjectNameAndType() : Invalid request parameters. screenType = ' + screenType + 'objectName =' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<SVMXA360__CONF_Layout__c> layoutRecordList = new List<SVMXA360__CONF_Layout__c>();

            //Querying page layout based on target object for 'standalone' transaction type and based on source object for 'source to target' transaction type
            if( String.isNotBlank(screenType) && screenType.equalsIgnoreCase(SCREENTYPE_TRANSACTION) && String.isNotBlank(objectName) ){
                layoutRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__HideName__c, SVMXA360__ObjectAPIName__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__TransactionType__c, SVMXA360__FieldSets__c,
                                                        SVMXA360__SourceObjectAPIName__c, SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, SVMXA360__ScreenType__c, SVMXA360__ValueMapping__c, SVMXA360__ApplyMapping__c,
                                                        SVMXA360__ValueMapping__r.Name FROM SVMXA360__CONF_Layout__c 
                                                        WHERE SVMXA360__ScreenType__c = : screenType AND 
                                                        ( (SVMXA360__ObjectAPIName__c = : objectName AND SVMXA360__TransactionType__c = :TRANSACTION_STANDALONEEDIT) OR 
                                                        (SVMXA360__SourceObjectAPIName__c = : objectName AND SVMXA360__TransactionType__c = :TRANSACTION_SOURCETOTARGET) ) 
                                                        ORDER BY Name] );
            }
            for( SVMXA360__CONF_Layout__c layoutRecord  : layoutRecordList ){
                pageLayoutList.add( createPageHeaderWrapper( layoutRecord ) );                            
            }
            serviceResponse.data = pageLayoutList;

        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getLayoutsByObjectNameAndType() : Failed to retrieve page layouts. Error= ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLayoutsByObjectNameAndType() - exit; pageLayoutList.size()= ' + pageLayoutList.size() );
        }

        return serviceResponse;
    }

    /**
     * This method is used to validate page layout and line details.
     * 
     * @param pageLayout Page Layout with layout details to be validated.
     */
    public Adm.ValidationResult validatePageLayout( Adm.PageLayout pageLayout, final List<Adm.ReferenceData> referenceDatas ) {
        return validatePageLayouts( new List<Adm.PageLayout>{pageLayout}, referenceDatas).get(0);
    }
    
    /**
     * This method is used to validate page layout and line details.
     * 
     * @param pageLayoutList Page Layout with layout details to be validated.
     */
    public List<Adm.ValidationResult> validatePageLayouts( List<Adm.PageLayout> pageLayoutList, final List<Adm.ReferenceData> referenceDatas ) {
        
        System.debug( LoggingLevel.DEBUG, 'validatePageLayouts() - enter');
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {

			final Set<String> expressionSet = new Set<String>();
			List<SVMXA360__CONF_Expression__c> expressionList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Expression__c] );
            
            for( SVMXA360__CONF_Expression__c expressionRecord : expressionList ) {
                expressionSet.add(expressionRecord.SVMXA360__DeveloperName__c);
            }
            
            final Set<String> mappingSet = new Set<String>();
			List<SVMXA360__CONF_ObjectMapping__c> mappingList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ObjectMapping__c] );
            
            for( SVMXA360__CONF_ObjectMapping__c mappingRecord : mappingList ) {
                mappingSet.add(mappingRecord.SVMXA360__DeveloperName__c);
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                
                for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                    
                    if( referenceData.configType == Adm.ConfigurationType.Mapping ) {
                        mappingSet.add(configurationData.developerName);
                    }
                    if( referenceData.configType == Adm.ConfigurationType.Expression ) {
                        expressionSet.add(configurationData.developerName);
                    }
                }
            }
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            
            for( Adm.PageLayout pageLayout : pageLayoutList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.Transactions );
                validationResults.add( validationResult );
                
                // Verify request for valid page layout informations.
                if( pageLayout == null || pageLayout.pageHeader == null ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validatePageLayouts() : Invalid request parameters. pageLayout= ' + pageLayout );
                    validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER);
                    
                    continue;
                }
                
                validateExpressionBaseMapping(validationResult, expressionSet, mappingSet, pageLayout.pageHeader.expressionBasedMapping );
                
                if( String.isNotBlank(pageLayout.pageHeader.valueMapping) && !mappingSet.contains(pageLayout.pageHeader.valueMapping ) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object Value Mapping does not exists : '+ pageLayout.pageHeader.valueMapping ) );
                }
                
                if( String.isNotBlank(pageLayout.pageHeader.fieldMapping) && !mappingSet.contains(pageLayout.pageHeader.fieldMapping ) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object Field Mapping does not exists : '+ pageLayout.pageHeader.fieldMapping ) );
                }
                
                if ( String.isNotBlank(pageLayout.pageHeader.qualifyingCriteria) && !expressionSet.contains(pageLayout.pageHeader.qualifyingCriteria) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Qualifying Criteria does not exists : '+ pageLayout.pageHeader.qualifyingCriteria ) );
                }
                
                if( String.isNotBlank(pageLayout.pageHeader.objectAPIName) && !entityDefinitionMap.containsKey(pageLayout.pageHeader.objectAPIName) ) {
                    
                    try {
                        final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(pageLayout.pageHeader.objectAPIName);
                        entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                    }
                    catch( SvmxSystem.SvmxNestedException e ) {
                        
                        validationResult.setError('Object does not exists: ' + pageLayout.pageHeader.objectAPIName);
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object does not exists : '+ pageLayout.pageHeader.objectAPIName ) );
                        
                    }
                } 
                
                if( String.isNotBlank(pageLayout.pageHeader.sourceObjectAPIName) && !entityDefinitionMap.containsKey(pageLayout.pageHeader.sourceObjectAPIName) ) {
                    
                    try {
                        final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(pageLayout.pageHeader.sourceObjectAPIName);
                        entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                    }
                    catch( SvmxSystem.SvmxNestedException e ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object does not exists : '+ pageLayout.pageHeader.sourceObjectAPIName ) );
                    }
                }
                
                validateLines(entityDefinitionMap, pageLayout, validationResult, expressionSet, mappingSet);
                
                for( Adm.PageSection section : pageLayout.pageHeader.sections ) {
                    
                    if ( String.isNotBlank(section.visibilityCriteria) && !expressionSet.contains(section.visibilityCriteria) ) {
                        
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Visiblity Criteria does not exists : '+ section.visibilityCriteria ) );
                    }
                    
                    if( section.elements != null && section.elements.size() > 0 ) {
                        validatePageElement( section.elements, validationResult, expressionSet, mappingSet, entityDefinitionMap.get( pageLayout.pageHeader.objectAPIName ) );
                    }
                    
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validatePageLayouts() : Failed to validate Page Layout. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validatePageLayouts() : Failed to validate Page Layout. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validatePageLayouts() - exit');
        }
        
        return validationResults;
    }

    private void validateExpressionBaseMapping( final Adm.ValidationResult validationResult, final Set<String> expressionSet, final Set<String> mappingSet, Adm.ExpressionBasedMapping expressionBasedMapping ) {
        
        if( expressionBasedMapping != null && expressionBasedMapping.rows != null ) {
            
            for( Adm.ExpressionMappingRow expressionMappingRow : expressionBasedMapping.rows ) {
                
                if( String.isNotBlank(expressionMappingRow.expressionDeveloperName) && !expressionSet.contains(expressionMappingRow.expressionDeveloperName) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Expression does not exists for expression based mapping: '+ expressionMappingRow.expressionName ) );
                }
                
                if( String.isNotBlank(expressionMappingRow.mappingDeveloperName) && !mappingSet.contains(expressionMappingRow.mappingDeveloperName) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object Mapping does not exists for expression based mapping: '+ expressionMappingRow.mappingName ) );
                }
            }
        }
    }
    
    private void validatePageElement( final List<Adm.PageElement> elements, final Adm.ValidationResult validationResult, final Set<String> expressionSet, final Set<String> mappingSet, final Common.EntityDefinition entityDefinition ) {
        
        for ( Adm.PageElement element : elements ) {
            
            if ( String.isNotBlank(element.formFillMappingId)  && !mappingSet.contains(element.formFillMappingId) ) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Form Fill Mapping does not exists : '+ element.formFillMappingId ) );
            }
            
            if ( String.isNotBlank(element.lookupConfigExpressionId)  && !expressionSet.contains(element.lookupConfigExpressionId) ) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Lookup Configuration expression does not exists : '+ element.lookupConfigExpressionId ) );
            }
            
            if( element.name != null && entityDefinition != null && entityDefinition.fieldDefinitionsByApiName != null && !entityDefinition.fieldDefinitionsByApiName.containsKey(element.name.toLowerCase()) ) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object ' + entityDefinition.label + '; Field does not exists : '+ element.name ) );
            }
            
            validateExpressionBaseMapping(validationResult, expressionSet, mappingSet, element.expressionBasedMapping );
        }
    }
    
    private void validateLines( final Map<String,Common.EntityDefinition> entityDefinitionMap, final Adm.PageLayout pageLayout, final Adm.ValidationResult validationResult, final Set<String> expressionSet, final Set<String> mappingSet ) {
        
        for( Adm.PageDetail line : pageLayout.lines ) {
            
            validateExpressionBaseMapping(validationResult, expressionSet, mappingSet, line.expressionBasedValueMapping );
            
            if ( String.isNotBlank(line.visibilityCriteria) && !expressionSet.contains(line.visibilityCriteria) ) {
                
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Visiblity Criteria does not exists : '+ line.visibilityCriteria ) );
            }
            
            if ( String.isNotBlank(line.qualifyingCriteria) && !expressionSet.contains(line.qualifyingCriteria) ) {
                
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Qualifying Criteria does not exists : '+ line.qualifyingCriteriaName ) );
            }
            
            if ( String.isNotBlank(line.valueMapping) && !mappingSet.contains(line.valueMapping) ) {
                
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Line Value Mapping does not exists : '+ line.valueMapping ) );
            }

            if( String.isNotBlank(line.fieldMapping) && !mappingSet.contains(line.fieldMapping) ) {
                validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Line Field Mapping does not exists : '+ line.fieldMapping ) );
            }
            
            if( String.isNotBlank(line.objectAPIName) && !entityDefinitionMap.containsKey(line.objectAPIName) ) {
                
                try {
                    final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(line.objectAPIName);
                    entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                }
                catch( SvmxSystem.SvmxNestedException e ) {
                    
                    validationResult.setError('Object does not exists: ' + line.objectAPIName); //TODO Create custom label
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object does not exists : '+ line.objectAPIName ) );
                    
                }
            }
            
            if( String.isNotBlank(line.sourceObjectAPIName) && !entityDefinitionMap.containsKey(line.sourceObjectAPIName) ) {
                
                try {
                    final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(line.sourceObjectAPIName);
                    entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                }
                catch( SvmxSystem.SvmxNestedException e ) {
                    
                    validationResult.setError('Source Object does not exists: ' + line.sourceObjectAPIName); //TODO Create custom label
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Transactions, 'Object does not exists : '+ line.sourceObjectAPIName ) );
                    
                }
            }
            
            if( line.elements != null && line.elements.size() > 0 ) {
                validatePageElement( line.elements, validationResult, expressionSet, mappingSet, entityDefinitionMap.get(line.objectAPIName)  );
            }
        }
    }
    
    public Adm.PageLayout savePageLayout( final Adm.PageLayout pageLayoutInfo, Adm.SourceOrigin sourceOrigin ){
        
        System.debug( LoggingLevel.DEBUG, 'savePageLayout() - enter' );

        Savepoint sp = Database.setSavePoint();

        try{
            pageSectionIds = new Set<Id>();
            pageDetailSectionIds = new Set<Id>();
            pageElementIds = new Set<Id>();
            pageEventIds = new Set<Id>();
            expressionBasedIds = new Set<Id>();

            if(pageLayoutInfo == null || pageLayoutInfo.pageHeader == null){
                System.debug( LoggingLevel.ERROR, 'savePageLayout() : Invalid request parameters. pageLayoutInfo= ' + pageLayoutInfo );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );            
            }

            if(pageLayoutInfo.developerName != null){
                List<SVMXA360__CONF_Layout__c> layoutList = SvmxDatabase.query([SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__DeveloperName__c =: pageLayoutInfo.developerName
                                                             AND Id !=: pageLayoutInfo.id]);
                if(!layoutList.isEmpty()){
                    System.debug( LoggingLevel.ERROR, 'savePageLayout() : Duplicate Layout Record found. Record Id= ' + layoutList[0].Id );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.DUPLICATE_SCREEN_TRANSACTION );            
                }
            }

            List<SVMXA360__CONF_LayoutSection__c> pageSectionList = new List<SVMXA360__CONF_LayoutSection__c>();
            List<SVMXA360__CONF_LayoutRelatedSection__c> pageDetailList = new List<SVMXA360__CONF_LayoutRelatedSection__c>();
            Map<Integer, Adm.PageSection> headerSectionSequenceMap = new Map<Integer, Adm.PageSection>();
            Map<Integer, Adm.PageDetail> detailSectionSequenceMap = new Map<Integer, Adm.PageDetail>();
            SVMXA360__CONF_Layout__c layoutRecord = mapHeaderFields(pageLayoutInfo);

            String objectAPIName = layoutRecord.SVMXA360__ObjectAPIName__c;
            if(layoutRecord.SVMXA360__ScreenType__c.equalsIgnoreCase(SCREENTYPE_TRANSACTION) && layoutRecord.SVMXA360__TransactionType__c.equalsIgnoreCase(TRANSACTION_SOURCETOTARGET)){
                objectAPIName = layoutRecord.SVMXA360__SourceObjectAPIName__c;
            }
            if(layoutRecord.SVMXA360__FieldMapping__c != null || layoutRecord.SVMXA360__ValueMapping__c != null){
                validateMappingForHeader(new List<String>{layoutRecord.SVMXA360__FieldMapping__c, layoutRecord.SVMXA360__ValueMapping__c});
            }

            validateFieldSet(objectAPIName, layoutRecord.SVMXA360__FieldSets__c);

            layoutRecord = (SVMXA360__CONF_Layout__c)SvmxDatabase.upsertRecord(layoutRecord);
            ADM_TranslationUtils.getInstance().createTranslatedRecord(new List<SVMXA360__CONF_Layout__c> {layoutRecord});
            
            if (pageLayoutInfo.pageHeader.applyMapping != null && pageLayoutInfo.pageHeader.applyMapping.equalsIgnoreCase('conditional') && 
                pageLayoutInfo.pageHeader.expressionBasedMapping != null) {
                
                createExpressionBasedMapping (pageLayoutInfo.pageHeader.expressionBasedMapping, layoutRecord.Id);    
            }             
            
            pageLayoutInfo.id = layoutRecord.Id;
            
            final Adm.PageHeader pageHeader = pageLayoutInfo.pageHeader;

            if(pageHeader.sections != null && !pageHeader.sections.isEmpty()){
                for(Adm.PageSection pageSectionInfo : pageHeader.sections){
                    SVMXA360__CONF_LayoutSection__c sectionRecord = mapSectionFields( pageSectionInfo, pageLayoutInfo.id);
                    headerSectionSequenceMap.put(pageSectionInfo.sequence, pageSectionInfo);
                    pageSectionList.add(sectionRecord);
                }
            }

            if(pageLayoutInfo.lines != null && !pageLayoutInfo.lines.isEmpty()){
                for(Adm.PageDetail pageDetailInfo : pageLayoutInfo.lines){
                    SVMXA360__CONF_LayoutRelatedSection__c lineDetailRecord = mapDetailFields(pageDetailInfo, pageLayoutInfo.id);
                    objectAPIName = lineDetailRecord.SVMXA360__ObjectAPIName__c;
                    if(layoutRecord.SVMXA360__ScreenType__c.equalsIgnoreCase(SCREENTYPE_TRANSACTION) && layoutRecord.SVMXA360__TransactionType__c.equalsIgnoreCase(TRANSACTION_SOURCETOTARGET)){
                        objectAPIName = lineDetailRecord.SVMXA360__SourceObjectAPIName__c;
                    }
                    validateFieldSet(objectAPIName, lineDetailRecord.SVMXA360__FieldSets__c);
                    detailSectionSequenceMap.put(pageDetailInfo.sequence, pageDetailInfo);
                    pageDetailList.add(lineDetailRecord);
                }
            }

            Map<String, Adm.PageElement> sectionElementMap = new Map<String, Adm.PageElement>();
            Map<String, Adm.PageEvent> elementEventMap = new Map<String, Adm.PageEvent>();

            List<SVMXA360__CONF_LayoutElement__c> elementList = new List<SVMXA360__CONF_LayoutElement__c>();
            List<SVMXA360__CONF_SPMEvent__c> eventList = new List<SVMXA360__CONF_SPMEvent__c>();

            manageSVMXTags(pageLayoutInfo.id, pageHeader.tags);

            if(pageHeader.elements != null && !pageHeader.elements.isEmpty()){
                elementList.addAll(mapHeaderElements(pageLayoutInfo.id, pageHeader.elements, sectionElementMap));
            }

            if(!pageSectionList.isEmpty()){
                pageSectionList = (List<SVMXA360__CONF_LayoutSection__c>)SvmxDatabase.upsertRecord( pageSectionList );
                ADM_TranslationUtils.getInstance().createTranslatedRecord(pageSectionList);
                elementList.addAll(mapSectionIds(pageSectionList, sectionElementMap, headerSectionSequenceMap));
                pageSectionList.clear();
                
            }

            if(!pageDetailList.isEmpty()){
                validateCRHForMappings(layoutRecord.SVMXA360__ObjectAPIName__c);
                pageDetailList = (List<SVMXA360__CONF_LayoutRelatedSection__c>)SvmxDatabase.upsertRecord( pageDetailList );
                ADM_TranslationUtils.getInstance().createTranslatedRecord(pageDetailList);
                elementList.addAll(mapPageDetailIds(pageDetailList, sectionElementMap, detailSectionSequenceMap));
                pageDetailList.clear();
            }

            if(!elementList.isEmpty()){
                validateCRHForLookupConfigs(layoutRecord.SVMXA360__ObjectAPIName__c);
                elementList = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.upsertRecord( elementList );
                eventList = mapElementIds(elementList, sectionElementMap, elementEventMap);
                ADM_TranslationUtils.getInstance().createTranslatedRecord(buttonElements);
                elementList.clear();
            }

            if(!eventList.isEmpty()){
                eventList = (List<SVMXA360__CONF_SPMEvent__c>)SvmxDatabase.upsertRecord( eventList );
                mapEventIds(eventList, elementEventMap);
                eventList.clear();
            }

            deleteRecords(pageLayoutInfo.id);

            if(expressionMappingRows != null && !expressionMappingRows.isEmpty()){
                SvmxDatabase.upsertRecord( expressionMappingRows );
            }

        }catch(SvmxSystem.SvmxNestedException e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save page layout. Error= ' + e.getMessage() );
            throw e;
        }catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save page layout. Error= ' + e.getMessage());
            throw e;
        }catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save page layout. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            if(sourceOrigin == Adm.SourceOrigin.Admin){
                saveRecentItemInfo(pageLayoutInfo);
            }
            System.debug( LoggingLevel.DEBUG, 'savePageLayout() - exit; pageLayoutInfo ' + pageLayoutInfo );
        }

        return pageLayoutInfo;
    }
    
    public List<Adm.PageLayout> savePageLayouts( final List<Adm.PageLayout> pageLayoutInfoList ) {
        return savePageLayouts( pageLayoutInfoList, true );
    }
    
    public List<Adm.PageLayout> savePageLayouts( final List<Adm.PageLayout> pageLayoutInfoList, final Boolean allOrNothing ){
        
        System.debug( LoggingLevel.DEBUG, 'savePageLayouts() - enter' );

        Savepoint sp = Database.setSavePoint();

        try{
            pageSectionIds = new Set<Id>();
            pageDetailSectionIds = new Set<Id>();
            pageElementIds = new Set<Id>();
            pageEventIds = new Set<Id>();
            expressionBasedIds = new Set<Id>();

            if(pageLayoutInfoList == null || pageLayoutInfoList.size() == 0) {
                
                System.debug( LoggingLevel.ERROR, 'savePageLayouts() : Invalid request parameters. pageLayoutInfoList= ' + pageLayoutInfoList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );            
            }
            
            List<SVMXA360__CONF_LayoutSection__c> allPageSectionList = new List<SVMXA360__CONF_LayoutSection__c>();
            List<SVMXA360__CONF_LayoutRelatedSection__c> allPageDetailList = new List<SVMXA360__CONF_LayoutRelatedSection__c>();
            Map<id,List<SVMXA360__CONF_LayoutSection__c>> pageSectionMap = new Map<Id, List<SVMXA360__CONF_LayoutSection__c>>();
            Map<Id,List<SVMXA360__CONF_LayoutRelatedSection__c>> pageDetailMap = new Map<Id,List<SVMXA360__CONF_LayoutRelatedSection__c>>();
            
            Map<Id, Map<Integer, Adm.PageSection>> idHeaderSectionSequenceMap = new Map<Id,Map<Integer, Adm.PageSection>>();
            Map<Id, Map<Integer, Adm.PageDetail>> idDetailSectionSequenceMap = new Map<Id,Map<Integer, Adm.PageDetail>>();
            
            List<SVMXA360__CONF_Layout__c> layoutRecordList = createLayoutRecords(pageLayoutInfoList);
            layoutRecordList = (List<SVMXA360__CONF_Layout__c>)SvmxDatabase.upsertRecord(layoutRecordList, allOrNothing);
            ADM_TranslationUtils.getInstance().createTranslatedRecord(layoutRecordList);
            
            for( Integer index = 0; index < pageLayoutInfoList.size(); index++ ) {
                
                List<SVMXA360__CONF_LayoutSection__c> pageSectionList = new List<SVMXA360__CONF_LayoutSection__c>();
                List<SVMXA360__CONF_LayoutRelatedSection__c> pageDetailList = new List<SVMXA360__CONF_LayoutRelatedSection__c>();
                Map<Integer, Adm.PageSection> headerSectionSequenceMap = new Map<Integer, Adm.PageSection>();
                Map<Integer, Adm.PageDetail> detailSectionSequenceMap = new Map<Integer, Adm.PageDetail>();
                
                Adm.PageLayout pageLayoutInfo = pageLayoutInfoList.get(Index);
                final Adm.PageHeader pageHeader = pageLayoutInfo.pageHeader;
                
                pageLayoutInfo.id = layoutRecordList.get(index).id;
                if( pageHeader.sections != null && !pageHeader.sections.isEmpty() ) {
                    
                    for(Adm.PageSection pageSectionInfo : pageHeader.sections) {
                        
                        SVMXA360__CONF_LayoutSection__c sectionRecord = mapSectionFields( pageSectionInfo, pageLayoutInfo.id);
                        headerSectionSequenceMap.put(pageSectionInfo.sequence, pageSectionInfo);
                        pageSectionList.add(sectionRecord);
                        allPageSectionList.add(sectionRecord);
                    }
                    
                    pageSectionMap.put( pageLayoutInfo.id, pageSectionList );
                }
                
                if( pageLayoutInfo.lines != null && !pageLayoutInfo.lines.isEmpty() ) { 
                    
                    for( Adm.PageDetail pageDetailInfo : pageLayoutInfo.lines ) {
                        
                        SVMXA360__CONF_LayoutRelatedSection__c lineDetailRecord = mapDetailFields(pageDetailInfo, pageLayoutInfo.id);
                        detailSectionSequenceMap.put(pageDetailInfo.sequence, pageDetailInfo);
                        pageDetailList.add(lineDetailRecord);
                        allPageDetailList.add(lineDetailRecord);
                    }
                    
                    pageDetailMap.put( pageLayoutInfo.id, pageDetailList );
                }
                
                idHeaderSectionSequenceMap.put( pageLayoutInfo.id, headerSectionSequenceMap );
                idDetailSectionSequenceMap.put( pageLayoutInfo.id, detailSectionSequenceMap );
            }
            
            if( !allPageSectionList.isEmpty() ) {
                allPageSectionList = (List<SVMXA360__CONF_LayoutSection__c>)SvmxDatabase.upsertRecord( allPageSectionList, allOrNothing );
                ADM_TranslationUtils.getInstance().createTranslatedRecord(allPageSectionList);
            }

            if(!allPageDetailList.isEmpty()){
                allPageDetailList = (List<SVMXA360__CONF_LayoutRelatedSection__c>)SvmxDatabase.upsertRecord( allPageDetailList, allOrNothing );
                ADM_TranslationUtils.getInstance().createTranslatedRecord(allPageDetailList);
            }
            
            Map<String, Adm.PageElement> sectionElementMap = new Map<String, Adm.PageElement>();
            Map<String, Adm.PageEvent> elementEventMap = new Map<String, Adm.PageEvent>();

            List<SVMXA360__CONF_LayoutElement__c> elementList = new List<SVMXA360__CONF_LayoutElement__c>();
            List<SVMXA360__CONF_SPMEvent__c> eventList = new List<SVMXA360__CONF_SPMEvent__c>();
            
            for( Adm.PageLayout pageLayoutInfo : pageLayoutInfoList ) {

                List<SVMXA360__CONF_LayoutSection__c> singlePageSectionList = pageSectionMap.get( pageLayoutInfo.id );
                List<SVMXA360__CONF_LayoutRelatedSection__c> singlePageDetailList = pageDetailMap.get( pageLayoutInfo.id );

                if(pageLayoutInfo.pageHeader.elements != null && !pageLayoutInfo.pageHeader.elements.isEmpty()){
                    elementList.addAll(mapHeaderElements(pageLayoutInfo.id, pageLayoutInfo.pageHeader.elements, sectionElementMap));
                }

                if( singlePageSectionList != null && !singlePageSectionList.isEmpty() ) {
                    
                    elementList.addAll( mapSectionIds( singlePageSectionList, sectionElementMap, idHeaderSectionSequenceMap.get(pageLayoutInfo.id) ) );
                    singlePageSectionList.clear();
                }
                
                if( singlePageDetailList != null && !singlePageDetailList.isEmpty() ) {
                    elementList.addAll(mapPageDetailIds(singlePageDetailList, sectionElementMap, idDetailSectionSequenceMap.get(pageLayoutInfo.id)));
                    singlePageDetailList.clear();
                }
            }
            
            if( !elementList.isEmpty() ) {
                
                elementList = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.upsertRecord( elementList, allOrNothing );
                eventList = mapElementIds(elementList, sectionElementMap, elementEventMap);
                ADM_TranslationUtils.getInstance().createTranslatedRecord(buttonElements);
                elementList.clear();
            }

            if(!eventList.isEmpty()){
                eventList = (List<SVMXA360__CONF_SPMEvent__c>)SvmxDatabase.upsertRecord( eventList );
                mapEventIds(eventList, elementEventMap);
                eventList.clear();
            }

            deleteRecords(layoutRecordList);

        } 
        catch(SvmxSystem.SvmxNestedException e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'savePageLayouts() : Failed to save page layout. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'savePageLayouts() : Failed to save page layout. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'savePageLayouts() - exit; pageLayoutInfoList ' + pageLayoutInfoList.size() );
        }

        return pageLayoutInfoList;
    }

    private List<SVMXA360__CONF_Layout__c> createLayoutRecords( List<Adm.PageLayout> pageLayoutInfoList ) {
        
        List<SVMXA360__CONF_Layout__c> layoutRecordList = new List<SVMXA360__CONF_Layout__c>();
        Map<String, Id> developerNameIdMap = new Map<String, Id>();
        
        List<SVMXA360__CONF_Layout__c> layoutList = (List<SVMXA360__CONF_Layout__c>) SvmxDatabase.query( [SELECT Id, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c]);
        for( SVMXA360__CONF_Layout__c layoutRecord :  layoutList ) {
            developerNameIdMap.put( layoutRecord.SVMXA360__DeveloperName__c, layoutRecord.id );
        }
        
        for( Adm.PageLayout pageLayoutInfo : pageLayoutInfoList ) {
            
            if( developerNameIdMap.containsKey(pageLayoutInfo.developerName) ) {
                pageLayoutInfo.id = developerNameIdMap.get(pageLayoutInfo.developerName);
            }
            
            SVMXA360__CONF_Layout__c layoutRecord = mapHeaderFields(pageLayoutInfo);
            layoutRecordList.add(layoutRecord);
        }
        return layoutRecordList;
    }
    /**
     * This method is used to delete page layout and related records 
     * for requested page layout id.
     */
    public void deletePageLayout( final String pageLayoutId ){
        System.debug( LoggingLevel.DEBUG, 'deletePageLayout() - enter; pageLayoutId = '+ pageLayoutId );

        Savepoint sp = Database.setSavePoint();

        try{
            // Verify for valid page layout id.
            if( String.isBlank( pageLayoutId ) ) {
                        
                System.debug( LoggingLevel.ERROR, 'deletePageLayout() : Invalid request parameters. pageLayoutId= ' + pageLayoutId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.SCREEN_NOT_FOUND );
            }

            List<SVMXA360__CONF_LayoutElement__c> layoutElements = SvmxDatabase.query([SELECT Id, (SELECT Id FROM SVMXA360__SPM_Events__r) FROM SVMXA360__CONF_LayoutElement__c WHERE SVMXA360__LayoutSection__r.SVMXA360__Layout__c =: pageLayoutId 
                                                                    OR SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c =: pageLayoutId]);
            
            List<SVMXA360__CONF_SPMEvent__c> events = new List<SVMXA360__CONF_SPMEvent__c>();
            for(SVMXA360__CONF_LayoutElement__c element: layoutElements){
                if(!element.SVMXA360__SPM_Events__r.isEmpty()){
                    events.addAll(element.SVMXA360__SPM_Events__r);
                }
            }
            
            manageSVMXTags(pageLayoutId, new List<String>());

            SvmxDatabase.deleteRecord( events );

            SvmxDatabase.deleteRecord( layoutElements );

            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE Id =: pageLayoutId] );

            /*
                Deleting the Pagelayout/Screen from recent items
            */
            Adm.RecentItemInfo recentItemInfo = new Adm.RecentItemInfo();
            recentItemInfo.configurationId = pageLayoutId;
            ADM_RecentItemsManager.getInstance().deleteRecentItemsDetails(new List<Adm.RecentItemInfo> {recentItemInfo});
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'deletePageLayout() : Failed to delete page layout. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'deletePageLayout() : Failed to delete page layout. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePageLayout() - exit; pageLayoutId ' + pageLayoutId );
        }
    }

    void validateCRHForMappings(String headerObject){
        if(mappingIds != null){
            for(SVMXA360__CONF_ObjectMapping__c objectMappingRec : (List<SVMXA360__CONF_ObjectMapping__c>)SvmxDatabase.query([SELECT Id, Name, SVMXA360__HeaderRecordObject__c 
                                                                    FROM SVMXA360__CONF_ObjectMapping__c WHERE Id IN: mappingIds])){
                if(objectMappingRec.SVMXA360__HeaderRecordObject__c != null && !objectMappingRec.SVMXA360__HeaderRecordObject__c.equalsIgnoreCase(headerObject)){
                    System.debug( LoggingLevel.ERROR, 'validateCRHForMappings() : Invalid Header Object Config for Mapping = ' + objectMappingRec.Name );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_CRH_MAPPING + ', ' + objectMappingRec.Name);            
                }
            }
        }
    }

    void validateCRHForLookupConfigs(String headerObject){
        if(lookupConfigIds != null){
            for(SVMXA360__CONF_LookupConfiguration__c lookupConfigRec : (List<SVMXA360__CONF_LookupConfiguration__c>)SvmxDatabase.query([SELECT Id, Name, SVMXA360__HeaderRecordObject__c 
                                                                        FROM SVMXA360__CONF_LookupConfiguration__c WHERE Id IN: lookupConfigIds])){
                if(lookupConfigRec.SVMXA360__HeaderRecordObject__c != null && !lookupConfigRec.SVMXA360__HeaderRecordObject__c.equalsIgnoreCase(headerObject)){
                    System.debug( LoggingLevel.ERROR, 'validateCRHForLookupConfigs() : Invalid Header Object Config for Lookup = ' + lookupConfigRec.Name );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_CRH_LOOKUP + ', ' + lookupConfigRec.Name);            
                }
            }
        }
    }

    void validateMappingForHeader(List<String> headerMappingIds){

        for(SVMXA360__CONF_ObjectMapping__c objectMappingRec : (List<SVMXA360__CONF_ObjectMapping__c>)SvmxDatabase.query([SELECT Id, Name, SVMXA360__HeaderRecordObject__c FROM 
                                                                    SVMXA360__CONF_ObjectMapping__c WHERE Id IN: headerMappingIds])){
            if(objectMappingRec.SVMXA360__HeaderRecordObject__c != null){
                System.debug( LoggingLevel.ERROR, 'validateMappingForHeader() : Invalid Header Object Config for Mapping = ' + objectMappingRec.Name );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_CRH_MAPPING + ', ' + objectMappingRec.Name);            
            }
        }
                                                                  
    }

    Adm.PageLayout createPageHeaderWrapper( final SVMXA360__CONF_Layout__c layoutRecord ){
        final Adm.PageLayout pageLayoutInfo = new Adm.PageLayout();
        pageLayoutInfo.id = layoutRecord.Id;
        pageLayoutInfo.developerName = layoutRecord.SVMXA360__DeveloperName__c;
        pageLayoutInfo.name = layoutRecord.Name;
        pageLayoutInfo.hideName = layoutRecord.SVMXA360__HideName__c == null ? false : layoutRecord.SVMXA360__HideName__c;
        pageLayoutInfo.description = layoutRecord.SVMXA360__Description__c;
        pageLayoutInfo.lastModifiedBy = layoutRecord.LastModifiedBy.Name;
        pageLayoutInfo.lastModifiedDate = String.valueOfGmt(layoutRecord.LastModifiedDate);

        final Adm.PageHeader pageHeader = new Adm.PageHeader();
        pageHeader.objectAPIName = layoutRecord.SVMXA360__ObjectAPIName__c;
        pageHeader.sourceObjectAPIName = layoutRecord.SVMXA360__SourceObjectAPIName__c;
        pageHeader.fieldMapping = layoutRecord.SVMXA360__FieldMapping__c;
        pageHeader.fieldMappingName = layoutRecord.SVMXA360__FieldMapping__r.Name;
        pageHeader.qualifyingCriteria = layoutRecord.SVMXA360__QualifyingCriteria__c;
        pageHeader.valueMapping = layoutRecord.SVMXA360__ValueMapping__c;
        pageHeader.valueMappingName = layoutRecord.SVMXA360__ValueMapping__r.Name;
        pageHeader.screenType = layoutRecord.SVMXA360__ScreenType__c;
        pageHeader.transactionType = layoutRecord.SVMXA360__TransactionType__c;
        pageHeader.fieldSets = deserializeFieldSet(layoutRecord.SVMXA360__FieldSets__c);
        pageHeader.applyMapping = layoutRecord.SVMXA360__ApplyMapping__c;
        pageLayoutInfo.pageHeader = pageHeader;
        return pageLayoutInfo;
    }

    Adm.PageSection createSectionWrapper( final SVMXA360__CONF_LayoutSection__c layoutSection){

        final Adm.PageSection pageSection = new Adm.PageSection();
        pageSection.id = layoutSection.Id;
        pageSection.name = layoutSection.Name;
        pageSection.hideName = layoutSection.SVMXA360__HideName__c == null ? false : layoutSection.SVMXA360__HideName__c;
        pageSection.columns = Integer.valueOf(layoutSection.SVMXA360__NoOfColumn__c);
        pageSection.sequence = Integer.valueOf(layoutSection.SVMXA360__SectionSequence__c);
        pageSection.visibilityCriteria = layoutSection.SVMXA360__VisibilityCriteriaID__c;
        pageSection.visibilityCriteriaName = layoutSection.SVMXA360__VisibilityCriteriaID__r.Name;
        pageSection.evaluationEvent = layoutSection.SVMXA360__EvaluationEvent__c;
        pageSection.readOnly = layoutSection.SVMXA360__ReadOnly__c == null ? false : layoutSection.SVMXA360__ReadOnly__c;
        return pageSection;
    }

    Adm.PageDetail createDetailSectionWrapper( final SVMXA360__CONF_LayoutRelatedSection__c relatedSection ){
        final Adm.PageDetail pageDetail = new Adm.PageDetail();
        pageDetail.id = relatedSection.Id;
        pageDetail.name = relatedSection.Name;
        pageDetail.objectAPIName = relatedSection.SVMXA360__ObjectAPIName__c;
        pageDetail.sequence = Integer.valueOf(relatedSection.SVMXA360__SectionSequence__c);
        pageDetail.addRow = relatedSection.SVMXA360__AllowNew__c;
        pageDetail.deleteRow = relatedSection.SVMXA360__AllowDelete__c;
        pageDetail.allowZeroLines = relatedSection.SVMXA360__AllowZeroLines__c;
        pageDetail.sortBy = relatedSection.SVMXA360__SortBy__c;
        pageDetail.presentationType = relatedSection.SVMXA360__PresentationType__c;
        pageDetail.controllerReferenceField = relatedSection.SVMXA360__ControllerReferenceField__c;
        pageDetail.sourceControllerReferenceField = relatedSection.SVMXA360__SourceControllerReferenceField__c;
        pageDetail.extendedEditDisplayColumns = relatedSection.SVMXA360__ExtendedEditDisplayColumns__c != null ? Integer.valueOf(relatedSection.SVMXA360__ExtendedEditDisplayColumns__c): null;
        pageDetail.fieldMapping = relatedSection.SVMXA360__FieldMapping__c;
        pageDetail.fieldMappingName = relatedSection.SVMXA360__FieldMapping__r.Name;
        pageDetail.qualifyingCriteria = relatedSection.SVMXA360__QualifyingCriteria__c;
        pageDetail.qualifyingCriteriaName = relatedSection.SVMXA360__QualifyingCriteria__r.Name;
        pageDetail.sourceObjectAPIName = relatedSection.SVMXA360__SourceObjectAPIName__c;
        pageDetail.valueMapping = relatedSection.SVMXA360__ValueMapping__c;
        pageDetail.valueMappingName = relatedSection.SVMXA360__ValueMapping__r.Name;
        pageDetail.selectableGrid = relatedSection.SVMXA360__IsSelectable__c;
        pageDetail.fieldSets = deserializeFieldSet(relatedSection.SVMXA360__FieldSets__c);
        pageDetail.readOnly = relatedSection.SVMXA360__ReadOnly__c == null ? false : relatedSection.SVMXA360__ReadOnly__c;
        pageDetail.visibilityCriteria = relatedSection.SVMXA360__VisibilityCriteriaID__c;
        pageDetail.visibilityCriteriaName = relatedSection.SVMXA360__VisibilityCriteriaID__r.Name;
        pageDetail.multiAddSearchField = relatedSection.SVMXA360__MultiAddSearchFieldApiName__c;
        pageDetail.evaluationEvent = relatedSection.SVMXA360__EvaluationEvent__c;
        pageDetail.applyValueMapping = relatedSection.SVMXA360__ApplyValueMapping__c;
        return pageDetail;
    }

    Adm.PageElement createElementWrapper( final SVMXA360__CONF_LayoutElement__c layoutElement ) {
        final Adm.PageElement pageElement = new Adm.PageElement();
        pageElement.id = layoutElement.Id;
        pageElement.name = layoutElement.SVMXA360__ElementAPIName__c;
        pageElement.readOnly = layoutElement.SVMXA360__ReadOnly__c == null ? false : layoutElement.SVMXA360__ReadOnly__c;
        pageElement.required = layoutElement.SVMXA360__Required__c;
        pageElement.sequence = Integer.valueOf(layoutElement.SVMXA360__ElementSequence__c);     
        pageElement.type = layoutElement.SVMXA360__Type__c;
        PageElement.row = Integer.valueOf(layoutElement.SVMXA360__Row__c);
        pageElement.column = Integer.valueOf(layoutElement.SVMXA360__Column__c);
        pageElement.lookupConfigId = layoutElement.SVMXA360__LookupConfiguration__c;
        pageElement.lookupConfigExpressionId = layoutElement.SVMXA360__LookupConfiguration__r.SVMXA360__BasicFilter__c;
        pageElement.lookupConfigName = layoutElement.SVMXA360__LookupConfiguration__r.Name;
        pageElement.lookupContext = layoutElement.SVMXA360__LookupContext__c;
        pageElement.lookupContextSource = layoutElement.SVMXA360__LookupContextSource__c;
        pageElement.lookupMatchingField = layoutElement.SVMXA360__LookupMatchingField__c;
        pageElement.overrideLookupContext = layoutElement.SVMXA360__OverrideLookupContext__c;
        pageElement.formFillMappingId = layoutElement.SVMXA360__FormFillMappingId__c;
        pageElement.formFillMappingName = layoutElement.SVMXA360__FormFillMappingId__r.Name;
        pageElement.title = layoutElement.SVMXA360__Title__c;
        pageElement.applyMapping = layoutElement.SVMXA360__ApplyMapping__c;
        for(SVMXA360__CONF_SPMEvent__c eventRecord : layoutElement.SVMXA360__SPM_Events__r){
            if(pageElement.events == null){
                pageElement.events = new List<Adm.PageEvent>();
            }
            pageElement.events.add(createEventWrapper(eventRecord));
        }
        return pageElement;      
    }

    Adm.PageEvent createEventWrapper( final SVMXA360__CONF_SPMEvent__c eventRecord ){
        final Adm.PageEvent pageEvent = new Adm.PageEvent();
        pageEvent.id = eventRecord.Id;
        pageEvent.type = eventRecord.SVMXA360__Type__c;
        pageEvent.actionType = eventRecord.SVMXA360__ActionType__c;
        pageEvent.actionTarget = eventRecord.SVMXA360__ActionTarget__c;   
        return pageEvent;     
    }

    List<SVMXA360__CONF_LayoutElement__c> mapHeaderElements(String layoutId,List<Adm.PageElement> pageElements, Map<String, Adm.PageElement> sectionElementMap){
        List<SVMXA360__CONF_LayoutElement__c> elementList = new List<SVMXA360__CONF_LayoutElement__c>();

        for(Adm.PageElement pageElement : pageElements){
            SVMXA360__CONF_LayoutElement__c elementRecord = mapElementFields(pageElement);
            elementRecord.SVMXA360__LayoutId__c = layoutId;
            sectionElementMap.put(elementRecord.SVMXA360__LayoutId__c + '-' + elementRecord.SVMXA360__ElementSequence__c, pageElement);
            elementList.add(elementRecord);
        }

        return elementList;
    }

    List<SVMXA360__CONF_LayoutElement__c> mapSectionIds(List<SVMXA360__CONF_LayoutSection__c> pageSectionList, Map<String, Adm.PageElement> sectionElementMap,
                                                            Map<Integer, Adm.PageSection> headerSectionSequenceMap){
        List<SVMXA360__CONF_LayoutElement__c> elementList = new List<SVMXA360__CONF_LayoutElement__c>();
        // TODO: Handle related list more than 200 records
        // to avoid Aggregate query has too many rows for direct assignment error.
        for(SVMXA360__CONF_LayoutSection__c sectionRecord : pageSectionList){
            Integer sequenceKey = Integer.valueOf(sectionRecord.SVMXA360__SectionSequence__c);

            if(headerSectionSequenceMap.containsKey(sequenceKey)){
   
                Adm.PageSection pageSection = headerSectionSequenceMap.get(sequenceKey);
                pageSection.id = sectionRecord.Id;
                pageSectionIds.add(sectionRecord.Id);
                
                if(pageSection.elements != null && !pageSection.elements.isEmpty()){
                    for(Adm.PageElement pageElement : pageSection.elements){
                        SVMXA360__CONF_LayoutElement__c elementRecord = mapElementFields(pageElement);
                        elementRecord.SVMXA360__LayoutSection__c = pageSection.id;
                        sectionElementMap.put(elementRecord.SVMXA360__LayoutSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c, pageElement);
                        elementList.add(elementRecord);
                    }
                }
                
            }
        }

        return elementList;
    } 

    List<SVMXA360__CONF_LayoutElement__c> mapPageDetailIds(List<SVMXA360__CONF_LayoutRelatedSection__c> pageDetailList, Map<String, Adm.PageElement> sectionElementMap,
                                                                Map<Integer, Adm.PageDetail> detailSectionSequenceMap){
        List<SVMXA360__CONF_LayoutElement__c> elementList = new List<SVMXA360__CONF_LayoutElement__c>();
        Map<Integer, SVMXA360__CONF_ExpressionBasedMapping__c> expressionBasedChildMap = new Map<Integer, SVMXA360__CONF_ExpressionBasedMapping__c>();
        // TODO: Handle related list more than 200 records
        // to avoid Aggregate query has too many rows for direct assignment error.
        if(lookupConfigIds == null){
            lookupConfigIds = new Set<Id>();
        }
        for(SVMXA360__CONF_LayoutRelatedSection__c detailSectionRecord : pageDetailList){
            Integer sequenceKey = Integer.valueOf(detailSectionRecord.SVMXA360__SectionSequence__c);

            if(detailSectionSequenceMap.containsKey(sequenceKey)){
                
                Adm.PageDetail pageDetail = detailSectionSequenceMap.get(sequenceKey);
                pageDetail.id = detailSectionRecord.Id; 
                pageDetailSectionIds.add(detailSectionRecord.Id);  
                
                if(pageDetail.elements != null && !pageDetail.elements.isEmpty()){
                    for(Adm.PageElement pageElement : pageDetail.elements){
                        SVMXA360__CONF_LayoutElement__c elementRecord = mapElementFields(pageElement);
                        if(elementRecord.SVMXA360__LookupConfiguration__c != null){
                            lookupConfigIds.add(elementRecord.SVMXA360__LookupConfiguration__c);
                        }
                        elementRecord.SVMXA360__LayoutRelatedSection__c = pageDetail.id;
                        sectionElementMap.put(elementRecord.SVMXA360__LayoutRelatedSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c, pageElement);
                        elementList.add(elementRecord);
                    }
                }

                if(pageDetail.applyValueMapping != null && pageDetail.applyValueMapping.equalsIgnoreCase('conditional')
                    && pageDetail.expressionBasedValueMapping != null){
                    Adm.ExpressionBasedMapping expressionBasedMapping = pageDetail.expressionBasedValueMapping;
                    SVMXA360__CONF_ExpressionBasedMapping__c expressionMappingRec = new SVMXA360__CONF_ExpressionBasedMapping__c ();
                    if (expressionBasedMapping.id != null) {
                        expressionMappingRec.Id = expressionBasedMapping.id;
                    }
                    expressionMappingRec.SVMXA360__TransactionChild__c = pageDetail.id;
                    expressionBasedChildMap.put(sequenceKey, expressionMappingRec);
                }
            }  
        }
                    
        if (!expressionBasedChildMap.isEmpty()) {
            SvmxDatabase.upsertRecord(expressionBasedChildMap.values());
        }

        for (Integer sequence : expressionBasedChildMap.keySet()) {
            if(detailSectionSequenceMap.containsKey(sequence)){
                SVMXA360__CONF_ExpressionBasedMapping__c expressionMappingRec = expressionBasedChildMap.get(sequence);
                Adm.PageDetail pageDetail = detailSectionSequenceMap.get(sequence);
                expressionBasedIds.add(expressionMappingRec.Id);
                createExpressionBasedMappingRows (pageDetail.expressionBasedValueMapping.rows, expressionMappingRec.Id);
            }
        }
        return elementList;
    } 

    List<SVMXA360__CONF_SPMEvent__c> mapElementIds(List<SVMXA360__CONF_LayoutElement__c> elementList, Map<String, Adm.PageElement> sectionElementMap, Map<String, Adm.PageEvent> elementEventMap){
        List<SVMXA360__CONF_SPMEvent__c> eventList = new List<SVMXA360__CONF_SPMEvent__c>();
        
        Map<String, SVMXA360__CONF_ExpressionBasedMapping__c> expressionBasedChildMap = new Map<String, SVMXA360__CONF_ExpressionBasedMapping__c>();
        for(SVMXA360__CONF_LayoutElement__c elementRecord : elementList){
            Adm.PageElement pageElement;
            String sequenceKey;
            if(elementRecord.SVMXA360__LayoutId__c != null && sectionElementMap.containsKey(elementRecord.SVMXA360__LayoutId__c + '-' + elementRecord.SVMXA360__ElementSequence__c)){
                pageElement = sectionElementMap.get(elementRecord.SVMXA360__LayoutId__c + '-' + elementRecord.SVMXA360__ElementSequence__c);
                if(elementRecord.SVMXA360__Type__c.equalsIgnoreCase('Button')){
                    if(buttonElements == null){
                        buttonElements = new List<SVMXA360__CONF_LayoutElement__c>();
                    }
                    buttonElements.add(elementRecord);
                }
            }else if(elementRecord.SVMXA360__LayoutSection__c != null && sectionElementMap.containsKey(elementRecord.SVMXA360__LayoutSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c)){
                sequenceKey = elementRecord.SVMXA360__LayoutSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c;
                pageElement = sectionElementMap.get(elementRecord.SVMXA360__LayoutSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c);             
            }else if(elementRecord.SVMXA360__LayoutRelatedSection__c != null && sectionElementMap.containsKey(elementRecord.SVMXA360__LayoutRelatedSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c)){
                sequenceKey = elementRecord.SVMXA360__LayoutRelatedSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c;
                pageElement = sectionElementMap.get(elementRecord.SVMXA360__LayoutRelatedSection__c + '-' + elementRecord.SVMXA360__ElementSequence__c);
            }

            if(pageElement != null){
                pageElement.id = elementRecord.Id;
                pageElementIds.add(elementRecord.Id);

                if(pageElement.events != null && !pageElement.events.isEmpty()){
                    for(Adm.PageEvent pageEvent : pageElement.events){
                        SVMXA360__CONF_SPMEvent__c eventRecord = mapEventFields(pageEvent);
                        eventRecord.SVMXA360__LayoutElementId__c = elementRecord.Id;
                        elementEventMap.put(eventRecord.SVMXA360__LayoutElementId__c + '-' + eventRecord.SVMXA360__Type__c, pageEvent);
                        eventList.add(eventRecord);
                    }
                }

                if(pageElement.applyMapping != null && pageElement.applyMapping.equalsIgnoreCase('conditional')
                    && pageElement.expressionBasedMapping != null && sequenceKey != null){
                    Adm.ExpressionBasedMapping expressionBasedMapping = pageElement.expressionBasedMapping;
                    SVMXA360__CONF_ExpressionBasedMapping__c expressionMappingRec = new SVMXA360__CONF_ExpressionBasedMapping__c ();
                    if (expressionBasedMapping.id != null) {
                        expressionMappingRec.Id = expressionBasedMapping.id;
                    }
                    expressionMappingRec.SVMXA360__TransactionElement__c = elementRecord.id;
                    expressionBasedChildMap.put(sequenceKey, expressionMappingRec);                        
                }   
            }
        }

        if (!expressionBasedChildMap.isEmpty()) {
            SvmxDatabase.upsertRecord(expressionBasedChildMap.values());
        }

        for (String sequence : expressionBasedChildMap.keySet()) {
            if(sectionElementMap.containsKey(sequence)){
                SVMXA360__CONF_ExpressionBasedMapping__c expressionMappingRec = expressionBasedChildMap.get(sequence);
                Adm.PageElement pageElement = sectionElementMap.get(sequence);
                expressionBasedIds.add(expressionMappingRec.Id);
                createExpressionBasedMappingRows (pageElement.expressionBasedMapping.rows, expressionMappingRec.Id);
            }
        }
        return eventList;
    }

    void mapEventIds(List<SVMXA360__CONF_SPMEvent__c> eventList, Map<String, Adm.PageEvent> elementEventMap){
        for(SVMXA360__CONF_SPMEvent__c eventRecord : eventList){
            Adm.PageEvent pageEvent;
            if(eventRecord.SVMXA360__LayoutElementId__c != null && elementEventMap.containsKey(eventRecord.SVMXA360__LayoutElementId__c + '-' + eventRecord.SVMXA360__Type__c)){
                pageEvent = elementEventMap.get(eventRecord.SVMXA360__LayoutElementId__c + '-' + eventRecord.SVMXA360__Type__c);
            }

            if(pageEvent != null){
                pageEvent.id = eventRecord.Id;
                pageEventIds.add(eventRecord.Id);
            }
        }
    }

    void validateFieldSet(String objectAPIName, String fieldSetsInfo){
        if(objectAPIName != null && fieldSetsInfo != null){
            List<String> availableFieldSets = new List<String>();
            if(fieldSetMap == null){
                fieldSetMap = new Map<String, List<String>>();
            }
            SObjectType sObjType = COMM_DescribeManager.getInstance().getsObjectType( objectAPIName );
            if(fieldSetMap.containsKey(objectAPIName)){
                availableFieldSets = fieldSetMap.get(objectAPIName);
            } else {
                List<Schema.FieldSet> fieldsetList = sObjType.getDescribe().FieldSets.getMap().values();
                for(Schema.FieldSet fieldSet : fieldsetList){
                    availableFieldSets.add(fieldSet.getName());
                }
                fieldSetMap.put(objectAPIName, availableFieldSets);
            }

            List<String> configuredFieldSets = (List<String>)JSON.deserialize(fieldSetsInfo, List<String>.class);

            for(String fieldSetName : configuredFieldSets){
                if(!test.isRunningTest() && !availableFieldSets.contains(fieldSetName)){
                    System.debug( LoggingLevel.ERROR, 'validateFieldSet() : Invalid field Set Configured for Object = ' + objectAPIName );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_FIELDSET_CONFIG + ', ' + objectAPIName);
                }
            }

        }
    }

    SVMXA360__CONF_Layout__c mapHeaderFields(final Adm.PageLayout pageLayoutInfo){
        SVMXA360__CONF_Layout__c layoutRecord = new SVMXA360__CONF_Layout__c();
        if(pageLayoutInfo.id != null){
            layoutRecord.Id = pageLayoutInfo.id;
        }
        layoutRecord.SVMXA360__DeveloperName__c = pageLayoutInfo.developerName;         
        layoutRecord.Name = pageLayoutInfo.name;
        layoutRecord.SVMXA360__HideName__c = pageLayoutInfo.hideName == null ? false : pageLayoutInfo.hideName;
        layoutRecord.SVMXA360__Description__c = pageLayoutInfo.description;

        final Adm.PageHeader pageHeader = pageLayoutInfo.pageHeader;

        layoutRecord.SVMXA360__ObjectAPIName__c = pageHeader.objectAPIName;
        layoutRecord.SVMXA360__SourceObjectAPIName__c = pageHeader.sourceObjectAPIName;
        layoutRecord.SVMXA360__FieldMapping__c = pageHeader.fieldMapping;
        layoutRecord.SVMXA360__QualifyingCriteria__c = pageHeader.qualifyingCriteria;
        layoutRecord.SVMXA360__ValueMapping__c = pageHeader.valueMapping;
        layoutRecord.SVMXA360__ScreenType__c = pageHeader.screenType != null ? pageHeader.screenType : 'Screen';
        layoutRecord.SVMXA360__TransactionType__c = pageHeader.transactionType;  
        layoutRecord.SVMXA360__ApplyMapping__c = pageHeader.applyMapping;
        layoutRecord.SVMXA360__FieldSets__c = serializeFieldSet(pageHeader.fieldSets);     
        return layoutRecord;
    }

    SVMXA360__CONF_LayoutRelatedSection__c mapDetailFields( final Adm.PageDetail pageDetailInfo, String headerId ){
        SVMXA360__CONF_LayoutRelatedSection__c lineDetailRecord = new SVMXA360__CONF_LayoutRelatedSection__c(SVMXA360__Layout__c = headerId);
        if(pageDetailInfo.id != null){
            lineDetailRecord.Id = pageDetailInfo.id;
        }
        if(mappingIds == null){
            mappingIds = new Set<Id>();                 
        }
        lineDetailRecord.Name = pageDetailInfo.name;
        lineDetailRecord.SVMXA360__ObjectAPIName__c = pageDetailInfo.objectAPIName;
        lineDetailRecord.SVMXA360__SectionSequence__c = pageDetailInfo.sequence;
        lineDetailRecord.SVMXA360__AllowNew__c = pageDetailInfo.addRow;
        lineDetailRecord.SVMXA360__AllowDelete__c = pageDetailInfo.deleteRow;
        lineDetailRecord.SVMXA360__AllowZeroLines__c = pageDetailInfo.allowZeroLines;
        lineDetailRecord.SVMXA360__SortBy__c = pageDetailInfo.sortBy;
        lineDetailRecord.SVMXA360__PresentationType__c = pageDetailInfo.presentationType;
        lineDetailRecord.SVMXA360__ControllerReferenceField__c = pageDetailInfo.controllerReferenceField;
        lineDetailRecord.SVMXA360__SourceControllerReferenceField__c = pageDetailInfo.sourceControllerReferenceField;
        lineDetailRecord.SVMXA360__ExtendedEditDisplayColumns__c = pageDetailInfo.extendedEditDisplayColumns;
        lineDetailRecord.SVMXA360__FieldMapping__c = pageDetailInfo.fieldMapping;
        if(lineDetailRecord.SVMXA360__FieldMapping__c != null){
            mappingIds.add(lineDetailRecord.SVMXA360__FieldMapping__c);
        }
        lineDetailRecord.SVMXA360__QualifyingCriteria__c = pageDetailInfo.qualifyingCriteria;
        lineDetailRecord.SVMXA360__SourceObjectAPIName__c = pageDetailInfo.sourceObjectAPIName;
        lineDetailRecord.SVMXA360__ValueMapping__c = pageDetailInfo.valueMapping;
        if(lineDetailRecord.SVMXA360__ValueMapping__c != null){
            mappingIds.add(lineDetailRecord.SVMXA360__ValueMapping__c);
        }
        lineDetailRecord.SVMXA360__IsSelectable__c = pageDetailInfo.selectableGrid != null ? pageDetailInfo.selectableGrid: false;
        lineDetailRecord.SVMXA360__FieldSets__c = serializeFieldSet(pageDetailInfo.fieldSets);     
        lineDetailRecord.SVMXA360__ReadOnly__c = pageDetailInfo.readOnly != null ? pageDetailInfo.readOnly: false;
        lineDetailRecord.SVMXA360__VisibilityCriteriaID__c = pageDetailInfo.visibilityCriteria;
        lineDetailRecord.SVMXA360__EvaluationEvent__c = pageDetailInfo.evaluationEvent;
        lineDetailRecord.SVMXA360__MultiAddSearchFieldApiName__c = pageDetailInfo.multiAddSearchField;
        lineDetailRecord.SVMXA360__ApplyValueMapping__c = pageDetailInfo.applyValueMapping;
        return lineDetailRecord;
    }

    SVMXA360__CONF_LayoutSection__c mapSectionFields( Adm.PageSection pageSection, String headerId ){
        SVMXA360__CONF_LayoutSection__c layoutSection = new SVMXA360__CONF_LayoutSection__c(SVMXA360__Layout__c = headerId);
        if(pageSection.id != null){
            layoutSection.Id = pageSection.id;
        }
        layoutSection.Name = pageSection.name;
        layoutSection.SVMXA360__HideName__c = pageSection.hideName == null ? false : pageSection.hideName;
        layoutSection.SVMXA360__NoOfColumn__c = pageSection.columns;
        layoutSection.SVMXA360__SectionSequence__c = pageSection.sequence;
        layoutSection.SVMXA360__VisibilityCriteriaID__c = pageSection.visibilityCriteria;
        layoutSection.SVMXA360__EvaluationEvent__c = pageSection.evaluationEvent;
        layoutSection.SVMXA360__ReadOnly__c = pageSection.readOnly != null ? pageSection.readOnly: false;
        return layoutSection;
    }

    SVMXA360__CONF_LayoutElement__c mapElementFields(Adm.PageElement pageElement){
        SVMXA360__CONF_LayoutElement__c elementRecord = new SVMXA360__CONF_LayoutElement__c();
        if(pageElement.id != null){
            elementRecord.Id = pageElement.id;
        }
        elementRecord.SVMXA360__ElementAPIName__c = pageElement.name;
        elementRecord.SVMXA360__ReadOnly__c = pageElement.readOnly;
        elementRecord.SVMXA360__Required__c = pageElement.required;
        elementRecord.SVMXA360__ElementSequence__c = pageElement.sequence;     
        elementRecord.SVMXA360__Type__c = pageElement.type;       
        elementRecord.SVMXA360__Row__c = pageElement.row;       
        elementRecord.SVMXA360__Column__c = pageElement.column;  
        elementRecord.SVMXA360__LookupConfiguration__c = pageElement.lookupConfigId;
        elementRecord.SVMXA360__LookupContext__c = pageElement.lookupContext;
        elementRecord.SVMXA360__LookupContextSource__c = pageElement.lookupContextSource;
        elementRecord.SVMXA360__LookupMatchingField__c = pageElement.lookupMatchingField;
        elementRecord.SVMXA360__OverrideLookupContext__c = pageElement.overrideLookupContext;  
        elementRecord.SVMXA360__FormFillMappingId__c = pageElement.formFillMappingId;
        elementRecord.SVMXA360__Title__c = pageElement.title;
        elementRecord.SVMXA360__ApplyMapping__c = pageElement.applyMapping;
        return elementRecord; 
    }

    void createExpressionBasedMappingRows( List<Adm.ExpressionMappingRow> rows, String masterId) {

        if (expressionMappingRows == null) {
            expressionMappingRows = new List<SVMXA360__CONF_ExpressionBasedMappingRow__c> ();
        }

        for (Adm.ExpressionMappingRow expressionMappingRow : rows) {
            SVMXA360__CONF_ExpressionBasedMappingRow__c rowRecord = new SVMXA360__CONF_ExpressionBasedMappingRow__c ();
            rowRecord.SVMXA360__ExpressionBasedMapping__c = masterId;
            rowRecord.SVMXA360__ExpressionId__c = expressionMappingRow.expressionId;
            rowRecord.SVMXA360__ObjectMappingId__c = expressionMappingRow.mappingId;
            rowRecord.SVMXA360__Sequence__c = expressionMappingRow.sequence;
            expressionMappingRows.add(rowRecord);
        }
    }

    void createExpressionBasedMapping (Adm.ExpressionBasedMapping expressionBasedMapping, String parentId) {
        SVMXA360__CONF_ExpressionBasedMapping__c expressionMappingRec = new SVMXA360__CONF_ExpressionBasedMapping__c ();
        if (expressionBasedMapping.id != null) {
            expressionMappingRec.Id = expressionBasedMapping.id;
        }
        expressionMappingRec.SVMXA360__TransactionHeader__c = parentId;
        SvmxDatabase.upsertRecord(expressionMappingRec);
        expressionBasedIds.add(expressionMappingRec.Id);
        createExpressionBasedMappingRows (expressionBasedMapping.rows, expressionMappingRec.Id);
    }

    SVMXA360__CONF_SPMEvent__c mapEventFields(Adm.PageEvent pageEvent){
        SVMXA360__CONF_SPMEvent__c eventRecord = new SVMXA360__CONF_SPMEvent__c();
        if(pageEvent.id != null){
            eventRecord.Id = pageEvent.id;
        }   
        eventRecord.SVMXA360__Type__c = pageEvent.type;
        eventRecord.SVMXA360__ActionType__c = pageEvent.actionType;
        eventRecord.SVMXA360__ActionTarget__c = pageEvent.actionTarget;
        return eventRecord;  
    }

    void saveRecentItemInfo(Adm.PageLayout pageLayoutInfo){
        Adm.RecentItemInfo recentItemInfo = new Adm.RecentItemInfo();
        recentItemInfo.configurationId = pageLayoutInfo.id;
        recentItemInfo.configurationType = pageLayoutInfo.pageHeader.screenType;
        recentItemInfo.configurationName = pageLayoutInfo.name;
        recentItemInfo.configurationDeveloperName = pageLayoutInfo.developerName;
        ADM_RecentItemsManager.getInstance().saveRecentItem(recentItemInfo);
    }

    SVMXA360__CONF_Layout__c queryPageLayoutWithChildren( final String pageLayoutId ){
        
        final List<SVMXA360__CONF_Layout__c> layoutList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__HideName__c, SVMXA360__ObjectAPIName__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ScreenType__c,
                                                    SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__TransactionType__c, SVMXA360__ApplyMapping__c,
                                                    SVMXA360__FieldSets__c, (SELECT Id, Name, SVMXA360__HideName__c, SVMXA360__Layout__c, SVMXA360__NoOfColumn__c, SVMXA360__SectionSequence__c, SVMXA360__VisibilityCriteriaID__c, SVMXA360__VisibilityCriteriaID__r.Name, SVMXA360__EvaluationEvent__c,  
                                                    SVMXA360__ReadOnly__c FROM SVMXA360__LayoutSections__r), (SELECT Id, Name, SVMXA360__AllowDelete__c, SVMXA360__AllowNew__c, SVMXA360__AllowZeroLines__c, SVMXA360__Layout__c, SVMXA360__ObjectAPIName__c, SVMXA360__ExtendedEditDisplayColumns__c,
                                                    SVMXA360__SectionSequence__c, SVMXA360__ControllerReferenceField__c, SVMXA360__SourceControllerReferenceField__c, SVMXA360__PresentationType__c, SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, 
                                                    SVMXA360__QualifyingCriteria__r.Name, SVMXA360__SourceObjectAPIName__c, SVMXA360__IsSelectable__c, SVMXA360__SortBy__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__FieldSets__c, SVMXA360__ReadOnly__c, 
                                                    SVMXA360__VisibilityCriteriaID__c, SVMXA360__VisibilityCriteriaID__r.Name, SVMXA360__EvaluationEvent__c, SVMXA360__MultiAddSearchFieldApiName__c, SVMXA360__ApplyValueMapping__c FROM SVMXA360__RelatedSections__r)
                                                    FROM SVMXA360__CONF_Layout__c WHERE Id =: pageLayoutId 
                                                    OR SVMXA360__DeveloperName__c =: pageLayoutId] );  
        
        if(layoutList.isEmpty()){
            System.debug( LoggingLevel.ERROR, 'queryPageLayoutWithChildren() : Requested PageLayout does not exist. pageLayoutId= ' + pageLayoutId );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.SCREEN_NOT_FOUND );            
        }

        return layoutList[0];    
    }
    
    List<SVMXA360__CONF_Layout__c> queryAllPageLayoutWithChildren() {
        
        final List<SVMXA360__CONF_Layout__c> layoutList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__HideName__c, SVMXA360__ObjectAPIName__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ScreenType__c, SVMXA360__ApplyMapping__c,
                                                    SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__TransactionType__c, 
                                                    SVMXA360__FieldSets__c, (SELECT Id, Name, SVMXA360__HideName__c, SVMXA360__Layout__c, SVMXA360__NoOfColumn__c, SVMXA360__SectionSequence__c, SVMXA360__VisibilityCriteriaID__c, SVMXA360__VisibilityCriteriaID__r.Name, SVMXA360__EvaluationEvent__c, SVMXA360__ReadOnly__c 
                                                    FROM SVMXA360__LayoutSections__r), (SELECT Id, Name, SVMXA360__AllowDelete__c, SVMXA360__AllowNew__c, SVMXA360__AllowZeroLines__c, SVMXA360__Layout__c, SVMXA360__ObjectAPIName__c, SVMXA360__ExtendedEditDisplayColumns__c,
                                                    SVMXA360__SectionSequence__c, SVMXA360__ControllerReferenceField__c, SVMXA360__SourceControllerReferenceField__c, SVMXA360__PresentationType__c, SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, 
                                                    SVMXA360__QualifyingCriteria__r.Name, SVMXA360__SourceObjectAPIName__c, SVMXA360__IsSelectable__c, SVMXA360__SortBy__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__FieldSets__c, SVMXA360__ReadOnly__c, 
                                                    SVMXA360__VisibilityCriteriaID__c, SVMXA360__VisibilityCriteriaID__r.Name, SVMXA360__EvaluationEvent__c, SVMXA360__MultiAddSearchFieldApiName__c, SVMXA360__ApplyValueMapping__c FROM SVMXA360__RelatedSections__r) FROM SVMXA360__CONF_Layout__c] ); 
        
        return layoutList;    
    }

    List<SVMXA360__CONF_Layout__c> queryAllPageLayoutWithChildren(List<String> pageLayoutIds) {
        
        final List<SVMXA360__CONF_Layout__c> layoutList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__HideName__c, SVMXA360__ObjectAPIName__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ScreenType__c, SVMXA360__ApplyMapping__c,
                                                    SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__TransactionType__c, 
                                                    SVMXA360__FieldSets__c, (SELECT Id, Name, SVMXA360__HideName__c, SVMXA360__Layout__c, SVMXA360__NoOfColumn__c, SVMXA360__SectionSequence__c, SVMXA360__VisibilityCriteriaID__c, SVMXA360__VisibilityCriteriaID__r.Name, SVMXA360__EvaluationEvent__c, SVMXA360__ReadOnly__c 
                                                    FROM SVMXA360__LayoutSections__r), (SELECT Id, Name, SVMXA360__AllowDelete__c, SVMXA360__AllowNew__c, SVMXA360__AllowZeroLines__c, SVMXA360__Layout__c, SVMXA360__ObjectAPIName__c, SVMXA360__ExtendedEditDisplayColumns__c,
                                                    SVMXA360__SectionSequence__c, SVMXA360__ControllerReferenceField__c, SVMXA360__SourceControllerReferenceField__c, SVMXA360__PresentationType__c, SVMXA360__FieldMapping__c, SVMXA360__FieldMapping__r.Name, SVMXA360__QualifyingCriteria__c, 
                                                    SVMXA360__QualifyingCriteria__r.Name, SVMXA360__SourceObjectAPIName__c, SVMXA360__IsSelectable__c, SVMXA360__SortBy__c, SVMXA360__ValueMapping__c, SVMXA360__ValueMapping__r.Name, SVMXA360__FieldSets__c, SVMXA360__ReadOnly__c, 
                                                    SVMXA360__VisibilityCriteriaID__c, SVMXA360__VisibilityCriteriaID__r.Name, SVMXA360__EvaluationEvent__c, SVMXA360__MultiAddSearchFieldApiName__c, SVMXA360__ApplyValueMapping__c FROM SVMXA360__RelatedSections__r) FROM SVMXA360__CONF_Layout__c WHERE Id IN :pageLayoutIds] ); 
        
        return layoutList;    
    }

    Map<String, Adm.ExpressionBasedMapping> queryExpressionBasedMappings (List<String> expressionBasedMappingIds) {
        Map<String, Adm.ExpressionBasedMapping> expressionBasedMappingParentMap = new Map<String, Adm.ExpressionBasedMapping>();

        if (expressionBasedMappingIds != null && !expressionBasedMappingIds.isEmpty()) {
            for (SVMXA360__CONF_ExpressionBasedMapping__c expressionBasedMappingRec : (List<SVMXA360__CONF_ExpressionBasedMapping__c>)SvmxDatabase.query( [SELECT Id, SVMXA360__TransactionHeader__c, SVMXA360__TransactionChild__c, 
                SVMXA360__TransactionElement__c, (SELECT Id, SVMXA360__ExpressionId__c, SVMXA360__ExpressionId__r.Name, SVMXA360__ExpressionId__r.SVMXA360__DeveloperName__c, SVMXA360__ObjectMappingId__c, SVMXA360__ObjectMappingId__r.Name, SVMXA360__ObjectMappingId__r.SVMXA360__DeveloperName__c, SVMXA360__Sequence__c FROM SVMXA360__Expression_Based_Mapping_Rows__r) 
                FROM SVMXA360__CONF_ExpressionBasedMapping__c WHERE SVMXA360__TransactionHeader__c IN: expressionBasedMappingIds OR SVMXA360__TransactionChild__c IN: expressionBasedMappingIds OR 
                SVMXA360__TransactionElement__c IN: expressionBasedMappingIds])) {

                Adm.ExpressionBasedMapping expressionBasedMapping = new Adm.ExpressionBasedMapping();
                expressionBasedMapping.id = expressionBasedMappingRec.Id;
                expressionBasedMapping.rows = new List<Adm.ExpressionMappingRow>();
                for (SVMXA360__CONF_ExpressionBasedMappingRow__c rowRecord : expressionBasedMappingRec.SVMXA360__Expression_Based_Mapping_Rows__r) {
                    Adm.ExpressionMappingRow row = new Adm.ExpressionMappingRow();
                    row.sequence = Integer.valueOf(rowRecord.SVMXA360__Sequence__c);
                    row.expressionId = rowRecord.SVMXA360__ExpressionId__c;
                    row.expressionName = rowRecord.SVMXA360__ExpressionId__r.Name;
                    row.expressionDeveloperName = rowRecord.SVMXA360__ExpressionId__r.SVMXA360__DeveloperName__c;
                    row.mappingId = rowRecord.SVMXA360__ObjectMappingId__c;
                    row.mappingName = rowRecord.SVMXA360__ObjectMappingId__r.Name;
                    row.mappingDeveloperName = rowRecord.SVMXA360__ObjectMappingId__r.SVMXA360__DeveloperName__c;
                    expressionBasedMapping.rows.add(row);
                }
                if (expressionBasedMappingRec.SVMXA360__TransactionHeader__c != null) {

                    expressionBasedMappingParentMap.put(expressionBasedMappingRec.SVMXA360__TransactionHeader__c, expressionBasedMapping);

                } else if (expressionBasedMappingRec.SVMXA360__TransactionChild__c != null) {
                    expressionBasedMappingParentMap.put(expressionBasedMappingRec.SVMXA360__TransactionChild__c, expressionBasedMapping);

                } else if (expressionBasedMappingRec.SVMXA360__TransactionElement__c != null) {
                    expressionBasedMappingParentMap.put(expressionBasedMappingRec.SVMXA360__TransactionElement__c, expressionBasedMapping);
                }
            }
        }
        return expressionBasedMappingParentMap;
    }

    // NOTE: <pageLayoutId> can match either the Id of an SVMXA360__CONF_Layout__c record OR the SVMXA360__CONF_Layout__c.SVMXA360__DeveloperName__c
    List<SVMXA360__CONF_LayoutElement__c> queryPageElements ( String pageLayoutId, Set<String> sectionIds, Set<String> relatedSectionIds ){

        List<SVMXA360__CONF_LayoutElement__c> pageElementList = new List<SVMXA360__CONF_LayoutElement__c>();
        if(!sectionIds.isEmpty() || !relatedSectionIds.isEmpty()){
            pageElementList = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.query([
                SELECT 
                    Name, SVMXA360__ElementAPIName__c, SVMXA360__ElementSequence__c, SVMXA360__ReadOnly__c, SVMXA360__Title__c, 
                    SVMXA360__LookupContext__c, SVMXA360__LookupMatchingField__c, SVMXA360__OverrideLookupContext__c, SVMXA360__LookupConfiguration__c,
                    SVMXA360__LookupConfiguration__r.Name, SVMXA360__LookupConfiguration__r.SVMXA360__BasicFilter__c, SVMXA360__LookupContextSource__c, SVMXA360__FormFillMappingId__c,
                    SVMXA360__FormFillMappingId__r.Name, SVMXA360__Required__c, SVMXA360__LayoutRelatedSection__c, SVMXA360__LayoutSection__c,
                    SVMXA360__LayoutId__c, SVMXA360__Type__c, SVMXA360__Row__c, SVMXA360__Column__c, SVMXA360__ApplyMapping__c,
                    (
                        SELECT
                            SVMXA360__Type__c, SVMXA360__ActionType__c, SVMXA360__ActionTarget__c 
                        FROM
                            SVMXA360__SPM_Events__r
                    )
                FROM
                    SVMXA360__CONF_LayoutElement__c
                WHERE
                    SVMXA360__LayoutSection__c IN :sectionIds OR
                    SVMXA360__LayoutRelatedSection__c IN :relatedSectionIds OR
                    (
                        SVMXA360__LayoutId__c =: pageLayoutId OR
                        SVMXA360__LayoutId__r.SVMXA360__DeveloperName__c =: pageLayoutId
                    )
            ]);
        }

        return pageElementList;
    }
    
    List<SVMXA360__CONF_LayoutElement__c> queryAllPageElements () {

        List<SVMXA360__CONF_LayoutElement__c> pageElementList = new List<SVMXA360__CONF_LayoutElement__c>();
        
        pageElementList = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.query( [SELECT Id, Name, SVMXA360__ElementAPIName__c, SVMXA360__ElementSequence__c, SVMXA360__ReadOnly__c, SVMXA360__LookupContext__c, SVMXA360__LookupMatchingField__c, 
                                                                                      SVMXA360__OverrideLookupContext__c, SVMXA360__LookupConfiguration__c, SVMXA360__LookupContextSource__c, SVMXA360__Required__c, SVMXA360__FormFillMappingId__c, SVMXA360__FormFillMappingId__r.Name, SVMXA360__ApplyMapping__c,
                                                                                      SVMXA360__LookupConfiguration__r.Name, SVMXA360__LookupConfiguration__r.SVMXA360__BasicFilter__c, SVMXA360__LayoutRelatedSection__c, SVMXA360__LayoutSection__c, SVMXA360__LayoutId__c, SVMXA360__Type__c, SVMXA360__Row__c, SVMXA360__Column__c, SVMXA360__Title__c, 
                                                                                      (SELECT Id, SVMXA360__Type__c, SVMXA360__ActionType__c, SVMXA360__ActionTarget__c FROM SVMXA360__SPM_Events__r)
                                                                                      FROM SVMXA360__CONF_LayoutElement__c]);
        
        return pageElementList;
    }
    
    void deleteRecords(String pageHeaderId){
        if(pageSectionIds != null && pageDetailSectionIds != null && pageElementIds != null){
            
            List<SVMXA360__CONF_LayoutElement__c> layoutElements = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.query([SELECT Id, (SELECT Id FROM SVMXA360__SPM_Events__r WHERE Id NOT IN: pageEventIds) FROM SVMXA360__CONF_LayoutElement__c WHERE Id NOT IN: pageElementIds AND (SVMXA360__LayoutSection__c IN: pageSectionIds OR 
                                                                    SVMXA360__LayoutRelatedSection__c IN: pageDetailSectionIds OR SVMXA360__LayoutId__c =: pageHeaderId)]);

            List<SVMXA360__CONF_SPMEvent__c> events = new List<SVMXA360__CONF_SPMEvent__c>();
            for(SVMXA360__CONF_LayoutElement__c element: layoutElements){
                if(!element.SVMXA360__SPM_Events__r.isEmpty()){
                    events.addAll(element.SVMXA360__SPM_Events__r);
                }
            }
            SvmxDatabase.deleteRecord( events );

            /*
                Delete Page Elements which is not part of page layout info.
            */
            SvmxDatabase.deleteRecord( layoutElements );

            /*
                Delete all the existing expression based mappings records.
            */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_ExpressionBasedMapping__c WHERE (SVMXA360__TransactionHeader__c =: pageHeaderId OR 
                                        SVMXA360__TransactionChild__c IN: pageDetailSectionIds OR SVMXA360__TransactionElement__c IN: pageElementIds) AND Id NOT IN: expressionBasedIds] );

            /*
                Delete all the existing expression based mapping row records.
            */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_ExpressionBasedMappingRow__c WHERE SVMXA360__ExpressionBasedMapping__c IN: expressionBasedIds] );

            /*
                Delete Page Sections which is not part of page layout info.
            */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_LayoutSection__c WHERE SVMXA360__Layout__c =: pageHeaderId AND Id NOT IN: pageSectionIds] ); 

            /*
                Delete Page Detail Sections which is not part of page layout info.
            */            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_LayoutRelatedSection__c WHERE SVMXA360__Layout__c =: pageHeaderId AND Id NOT IN: pageDetailSectionIds] ); 

        }
    }
    
    List<String> deserializeFieldSet(String fieldSetJson){
        if(fieldSetJson != null){
            List<String> deserializedFieldSet = (List<String>)JSON.deserialize(fieldSetJson, List<String>.class);
            return deserializedFieldSet;
        }
        return null;
    }

    String serializeFieldSet(List<String> fieldSets){
        if(fieldSets != null){
            return JSON.serialize(fieldSets, true);
        }
        return null;
    }

    void deleteRecords( List<SVMXA360__CONF_Layout__c> pageHeaderIds) {
        
        if(pageSectionIds != null && pageDetailSectionIds != null && pageElementIds != null){
            List<SVMXA360__CONF_LayoutElement__c> layoutElements = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.query([SELECT Id, (SELECT Id FROM SVMXA360__SPM_Events__r WHERE Id NOT IN: pageEventIds) FROM SVMXA360__CONF_LayoutElement__c WHERE Id NOT IN: pageElementIds AND (SVMXA360__LayoutSection__c IN: pageSectionIds OR 
                                                                    SVMXA360__LayoutRelatedSection__c IN: pageDetailSectionIds OR SVMXA360__LayoutId__c IN: pageHeaderIds)]);
            
            List<SVMXA360__CONF_SPMEvent__c> events = new List<SVMXA360__CONF_SPMEvent__c>();
            for(SVMXA360__CONF_LayoutElement__c element: layoutElements){
                if(!element.SVMXA360__SPM_Events__r.isEmpty()){
                    events.addAll(element.SVMXA360__SPM_Events__r);
                }
            }
            SvmxDatabase.deleteRecord( events );            
            /*
                Delete Page Elements which is not part of page layout info.
            */
            SvmxDatabase.deleteRecord( layoutElements );

            /*
                Delete Page Sections which is not part of page layout info.
            */
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_LayoutSection__c WHERE SVMXA360__Layout__c IN :pageHeaderIds AND Id NOT IN: pageSectionIds] ); 

            /*
                Delete Page Detail Sections which is not part of page layout info.
            */            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_LayoutRelatedSection__c WHERE SVMXA360__Layout__c IN :pageHeaderIds AND Id NOT IN: pageDetailSectionIds] ); 

        }
    }

    ADM_PageLayoutManager(){}
}