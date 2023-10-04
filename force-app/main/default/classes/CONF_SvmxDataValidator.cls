/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides methods to validate Asset360 metadata like mapping, 
 * expression, pagelayout etc.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       16 Sep 2020     Created.
 *****************************************************************************************************/
public class CONF_SvmxDataValidator {

    public List<Config.DataValidationResult> validateEntitlementRules( final List<Adm.EntitlementRule> entitlementRuleList ) {
        
        List<Config.DataValidationResult> dataValidationResultList = new List<Config.DataValidationResult>();
        
        for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
            Config.DataValidationResult dataValidationResult = validateEntitlementRule(entitlementRule);
            if(!dataValidationResult.success){
                dataValidationResultList.add( dataValidationResult );
            }
        }
        
        return dataValidationResultList;
    }
    
    public Config.DataValidationResult validateEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        
        Config.DataValidationResult dataValidationResult = new Config.DataValidationResult();
        
        final String sourceObject = entitlementRule.objectAPIName;
        
        if( String.isNotBlank(sourceObject) && !isObjectExists(sourceObject) ) {
            
            dataValidationResult.success = false;
            dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + sourceObject );
        }
        
        if( entitlementRule.expression != null ) {
            dataValidationResult = validateExpression(entitlementRule.expression);
        }
        
        return dataValidationResult;
    }
    
    /**
     * This method is used to validate list of wizard records.
     * @param processWizardList list of process wizard to be validated.
     * 
     * @return Returns list of data validation result for each requested wizard.
     */
    public List<Config.DataValidationResult> validateProcessWizards( final List<Adm.ProcessWizard> processWizardList ) {
        
        List<Config.DataValidationResult> dataValidationResultList = new List<Config.DataValidationResult>();
        
        for( Adm.ProcessWizard processWizard : processWizardList ) {
            Config.DataValidationResult dataValidationResult = validateProcessWizard(processWizard);
            if(!dataValidationResult.success){
                dataValidationResultList.add( dataValidationResult );
            }
        }
        
        return dataValidationResultList;
    }
    
    /**
     * This method is used to validate a wizard record.
     * @param processWizard the of process wizard to be validated.
     * 
     * @return Returns A data validation result for requested process wizard.
     */
    public Config.DataValidationResult validateProcessWizard( final Adm.ProcessWizard processWizard ) {
        
        Config.DataValidationResult dataValidationResult = new Config.DataValidationResult();
        
        final String sourceObject = processWizard.objectAPIName;
        
        if( String.isNotBlank(sourceObject) && !isObjectExists(sourceObject) ) {
            
            dataValidationResult.success = false;
            dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + sourceObject );
        }
        
        return dataValidationResult;
    }
    
    /**
     * This method is used to validate list of object mapping records.
     * @param objectMappingList List of object mapping to be validated.
     * 
     * @return Returns list of data validation result for each requested object mapping.
     */
    public List<Config.DataValidationResult> validateMappings( final List<Adm.ObjectMapping> objectMappingList ) {
        
        List<Config.DataValidationResult> dataValidationResultList = new List<Config.DataValidationResult>();
        
        for( Adm.ObjectMapping objectMapping : objectMappingList ) {
            Config.DataValidationResult dataValidationResult = validateMapping(objectMapping);
            if(!dataValidationResult.success){
                dataValidationResultList.add( dataValidationResult );
            }
        }
        
        return dataValidationResultList;
    }
    
    public Config.DataValidationResult validateMapping( final Adm.ObjectMapping objectMapping ) {
        
        Config.DataValidationResult dataValidationResult = new Config.DataValidationResult();
        
        final String sourceObject = objectMapping.sourceObjectAPIName;
        final String targetObject = objectMapping.targetObjectAPIName;
        
        if( String.isNotBlank(sourceObject) && !isObjectExists(sourceObject) ) {
            
            dataValidationResult.success = false;
            dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + sourceObject );
        }
        
        if( String.isNotBlank(targetObject) && !isObjectExists(targetObject) ) {
            
            dataValidationResult.success = false;
            dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + targetObject );
        }
        
        if( objectMapping.objectMappingDetails != null && !objectMapping.objectMappingDetails.isEmpty() ) {
            
            for( Adm.ObjectMappingDetail objectMappingDetail : objectMapping.objectMappingDetails ) {
                
                final String sourceField = objectMappingDetail.sourceFieldAPIName;
                final String targetField = objectMappingDetail.targetFieldAPIName;
                
                if( String.isNotBlank(sourceObject) && String.isNotBlank(sourceField) && !isFieldExists(sourceObject, sourceField ) ) {
                    
                    dataValidationResult.success = false;
                    dataValidationResult.errors.add( ErrorMessage.FIELD_NOT_EXISTS + sourceObject +'-'+ sourceField );
                }
                
                if( String.isNotBlank(targetObject) && String.isNotBlank(targetField) && !isFieldExists(targetObject, targetField ) ) {
                    
                    dataValidationResult.success = false;
                    dataValidationResult.errors.add( ErrorMessage.FIELD_NOT_EXISTS + targetObject +'-'+ targetField );
                }
            }
        }
        
        return dataValidationResult;
    }
    
    public List<Config.DataValidationResult> validateExpressions( final List<Adm.Expression> expressionList ) {
        
        List<Config.DataValidationResult> dataValidationResultList = new List<Config.DataValidationResult>();
        
        for( Adm.Expression expression : expressionList ) {
            Config.DataValidationResult dataValidationResult = validateExpression(expression);
            if(!dataValidationResult.success){
                dataValidationResultList.add( dataValidationResult );
            }
        }
        
        return dataValidationResultList;
    }
    
    public Config.DataValidationResult validateExpression( final Adm.Expression expression ) {
        
        Config.DataValidationResult dataValidationResult = new Config.DataValidationResult();
        
        final String objectName = expression.objectAPIName;
        
        if( String.isNotBlank(objectName) && !isObjectExists(objectName) ) {
            
            dataValidationResult.success = false;
            dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + objectName );
        }
        
        if( expression.expressionDetailList != null && !expression.expressionDetailList.isEmpty() ) {
            
            for( Adm.ExpressionDetail expressionDetail : expression.expressionDetailList ) {
                
                final String fieldName = expressionDetail.fieldAPIName;
                
                if( String.isNotBlank(objectName) && String.isNotBlank(fieldName) && !isFieldExists(objectName, fieldName ) ) {
                    
                    dataValidationResult.success = false;
                    dataValidationResult.errors.add( ErrorMessage.FIELD_NOT_EXISTS + objectName +'-'+ fieldName );
                }
            }
        }
        
        return dataValidationResult;
    }
    
    public List<Config.DataValidationResult> validatePageLayouts( final List<Adm.PageLayout> pageLayoutList ) {
        
        List<Config.DataValidationResult> dataValidationResultList = new List<Config.DataValidationResult>();
        
        for( Adm.PageLayout pageLayout : pageLayoutList ) {
            Config.DataValidationResult dataValidationResult = validatePageLayout(pageLayout);
            if(!dataValidationResult.success){
                dataValidationResultList.add( dataValidationResult );
            }
        }
        
        return dataValidationResultList;
    }
    
    public Config.DataValidationResult validatePageLayout( final Adm.PageLayout pageLayout ) {
        
        Config.DataValidationResult dataValidationResult = new Config.DataValidationResult();
        
        if( pageLayout.pageHeader != null ) {
            
            final String objectName = pageLayout.pageHeader.objectAPIName;
            if( String.isNotBlank(objectName) && !isObjectExists(objectName) ) {
                
                dataValidationResult.success = false;
                dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + objectName );
            }
            
            if( pageLayout.pageHeader.sections != null && pageLayout.pageHeader.sections.size() > 0 ) {
                
                for( Adm.PageSection pageSection : pageLayout.pageHeader.sections ) {
                    
                    if( pageSection.elements != null && pageSection.elements.size() > 0 ) {
                        validatePageElement(dataValidationResult, objectName, pageSection.elements );
                    }
                }
            } 
        }
        
        if( pageLayout.lines != null && pageLayout.lines.size() > 0 ) {
            
            for( Adm.PageDetail pageDetail : pageLayout.lines ) {
                
                final String detailObjectName = pageDetail.objectAPIName;
                if( String.isNotBlank(detailObjectName) && !isObjectExists(detailObjectName) ) {
                    
                    dataValidationResult.success = false;
                    dataValidationResult.errors.add( ErrorMessage.OBJECT_NOT_EXISTS + detailObjectName );
                }
                
                if( pageDetail.elements != null && pageDetail.elements.size() > 0 ) {
                    validatePageElement(dataValidationResult, detailObjectName, pageDetail.elements );
                }
            }
        }
        
        
        return dataValidationResult;
    }
    
    private void validatePageElement( final Config.DataValidationResult dataValidationResult, final String objectName, final List<Adm.PageElement> elements ) {
        
        for( Adm.PageElement pageElement : elements ) {
            
            if( String.isNotBlank( pageElement.name ) && !isFieldExists(objectName, pageElement.name ) ) {
                
                dataValidationResult.success = false;
                dataValidationResult.errors.add( ErrorMessage.FIELD_NOT_EXISTS + objectName +'-'+ pageElement.name );
            }
        }
    }
    
    private Boolean isObjectExists( final String objectName ) {
        
        COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
        Map<String, Schema.SObjectType> sObjectTypeMap = describeManager.getGlobalDescribe();
        
    	return ( sObjectTypeMap.containsKey(objectName.toLowerCase()) || Common.DefaultAllowedCoreObjects.values().contains(objectName.toLowerCase()) );    
    }
    
    private Boolean isFieldExists( final String objectName, final String fieldName ) {
        
        COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
        Map<String, Schema.SObjectField> sObjectFieldMap = describeManager.getObjectFieldMap( objectName );
        
        return sObjectFieldMap.containsKey(fieldName.toLowerCase());
    }

    public static String getErrorFromValidationResult(List<Config.DataValidationResult> dataValidationResultList){

        String error = '';
        if(dataValidationResultList != null && dataValidationResultList.size() > 0){
            for(Config.DataValidationResult result : dataValidationResultList){
                error += String.join(result.errors, ' , ');
            }
        }
        return error;
    }
}