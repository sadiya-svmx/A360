/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is the implementation class which implements service contract services.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       06 Apr 2021     Created.
 *****************************************************************************************************/
public class EVER_EntitlementServiceImpl {
	
    public Ever.ServiceCoverage getServiceCoverages( final Id sourceRecordId, Adm.EntitlementSettings entitlementSettings ) {
        
        Ever.ServiceCoverage serviceCoverage = new Ever.ServiceCoverage();
        
        try {
            
            final String sourceObjectName = String.valueOf( sourceRecordId.getSobjectType() );
            
            if( entitlementSettings != null ) {
                updateEntitlementSettings(sourceObjectName, entitlementSettings );
            } else {
                entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( sourceObjectName );
            }
            
            serviceCoverage = new EVER_InteractiveEntitlementEngine( sourceObjectName ).getServiceCoverageDetails(sourceRecordId, entitlementSettings );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Failed to retrieve Service Coverages. Error' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoverages() - exit; serviceCoverage= ' + serviceCoverage );
        }
        
        return serviceCoverage;
    }
    
    public Common.ServiceResponse getEntitlementVerficationHistory( final Id sourceRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            if( String.IsBlank(sourceRecordId) ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            serviceResponse = new EVER_EntitlementHistory().getEntitlementVerficationHistory( sourceRecordId );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Failed to retrieve Service Coverages. Error' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - exit; serviceResponse= ' + serviceResponse );
        }
        
        return serviceResponse;
    }
    
    public Common.ServiceResponse saveServiceCoverage( final Id sourceRecordId, final Ever.ServiceCoverage serviceCoverage ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            if( String.IsBlank(sourceRecordId) ) {
                
                System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            new EVER_InteractiveEntitlementEngine(String.valueOf( sourceRecordId.getSobjectType() )).saveServiceCoverage(sourceRecordId, serviceCoverage);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to save Service Coverages. Error' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - exit; serviceResponse= ' + serviceResponse );
        }
        
        return serviceResponse;
    }
    
    private void updateEntitlementSettings( final String sourceObjectName, final Adm.EntitlementSettings entitlementSettings ) {
        
        Adm.EntitlementSettings defaultEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( sourceObjectName );

        if ( defaultEntitlementSettings == null ) {

            defaultEntitlementSettings = new Adm.EntitlementSettings();
            defaultEntitlementSettings.allowOverrideSettings = true;
            defaultEntitlementSettings.futureEntitlements = true;
            defaultEntitlementSettings.expiredEntitlements = true;
            defaultEntitlementSettings.fullyConsumedServices = true;
            defaultEntitlementSettings.coveredBy = 'Asset';
            defaultEntitlementSettings.includeParentAsset = false;
            defaultEntitlementSettings.includeRootAsset = false;
            defaultEntitlementSettings.matchAccount = false;
        }
                
        entitlementSettings.scope = ( entitlementSettings.scope == null ) ? defaultEntitlementSettings.Scope : entitlementSettings.scope;
        entitlementSettings.allowOverrideSettings = (entitlementSettings.allowOverrideSettings == null ) ? defaultEntitlementSettings.allowOverrideSettings : entitlementSettings.allowOverrideSettings;
        entitlementSettings.futureEntitlements = ( entitlementSettings.futureEntitlements == null ) ? defaultEntitlementSettings.futureEntitlements : entitlementSettings.futureEntitlements;
        entitlementSettings.expiredEntitlements = (entitlementSettings.expiredEntitlements == null) ? defaultEntitlementSettings.expiredEntitlements : entitlementSettings.expiredEntitlements;
        entitlementSettings.fullyConsumedServices = (entitlementSettings.fullyConsumedServices == null) ? defaultEntitlementSettings.fullyConsumedServices : entitlementSettings.fullyConsumedServices;
        entitlementSettings.objectAPIName = sourceObjectName;
        entitlementSettings.coveredBy = (entitlementSettings.coveredBy == null ) ? defaultEntitlementSettings.coveredBy : entitlementSettings.coveredBy;
        entitlementSettings.assetAPIName = (entitlementSettings.assetAPIName == null) ? defaultEntitlementSettings.assetAPIName : entitlementSettings.assetAPIName;
        entitlementSettings.accountAPIName = (entitlementSettings.accountAPIName == null) ? defaultEntitlementSettings.accountAPIName : entitlementSettings.accountAPIName;
        entitlementSettings.includeParentAsset = (entitlementSettings.includeParentAsset == null) ? defaultEntitlementSettings.includeParentAsset : entitlementSettings.includeParentAsset;
        entitlementSettings.includeRootAsset = (entitlementSettings.includeRootAsset == null) ? defaultEntitlementSettings.includeRootAsset : entitlementSettings.includeRootAsset;
        entitlementSettings.matchAccount = (entitlementSettings.matchAccount == null ) ? defaultEntitlementSettings.matchAccount : entitlementSettings.matchAccount ;
        entitlementSettings.defaultBillingType = (entitlementSettings.defaultBillingType == null ) ? defaultEntitlementSettings.defaultBillingType : entitlementSettings.defaultBillingType; 
    }
}