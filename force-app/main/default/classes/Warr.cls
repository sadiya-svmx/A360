/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have definitions which are consumed across all WARR business modules.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       23 Jan 2023     Created.
 *****************************************************************************************************/
public with sharing class Warr {
    
    /**
     * Base plan record wrapper
     */
    public virtual class WarrRecord {
        
        // Salesforce record Id
        @AuraEnabled public String id {get;set;}
        
        // Record name
        @AuraEnabled public String name {get;set;}
        
        // Record last modified date.
        @AuraEnabled public Datetime lastModifiedDate {get;set;}
        
        // Record last modified user.
        @AuraEnabled public String lastModifiedBy {get;set;}
    }

    /**
* Wrapper class to hold Vendor Warranty Info. 
*/
public class SupplierWarranty extends WarrRecord {

    // Salesforce record Id of the warranty
	@AuraEnabled public String componentId {get;set;}

    // Record name of the warranty
	@AuraEnabled public String componentName {get;set;}

    // Name of the Supplier Account
	@AuraEnabled public String supplierName {get;set;}

    // Record Id of the warranty term
	@AuraEnabled public String warrantyTermId {get;set;}

    // Record name of the warranty term
	@AuraEnabled public String warrantyTermName {get;set;}

    // End date of the warranty
	@AuraEnabled public Date expireDate {get;set;}
}
}