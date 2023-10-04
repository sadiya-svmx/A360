/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides implementation for fetching feature Param value from LMO to subscriber
 * org which is used to enhance certain configurable features
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        			Name                    Date            Comment
 *****************************************************************************************************
 *    A360ADM-2038          Sachin S                12 July 2022     Created.
 *****************************************************************************************************/
public with sharing class COMM_FeatureAccessManager {
	
    /**
    * Private static variable to hold instance of this class.
    */
    private static COMM_FeatureAccessManager instance;

   /**
    * Feature Parameter - Configurable Limit Value
    */
    private static Map<String, Object> configurableFeatureValueMap = new Map<String, Object> {
        'SPMAllowedTabs' => 4
    };

    /**
    * Static method to retrieve instance of this class. Only one instance of 
    * this class will be created per transaction.
    */
    public static COMM_FeatureAccessManager getInstance () {
        if( instance == null ) {
            instance = new COMM_FeatureAccessManager();
        }
        return instance;
    } 

    public List<Adm.FeatureParameter> getAllFeatureParameterValues () {
        List<Adm.FeatureParameter> featureParamList = new List<Adm.FeatureParameter>();
        for (String featureKey : configurableFeatureValueMap.keySet()) {
			Adm.FeatureParameter featureParam = new Adm.FeatureParameter(featureKey, configurableFeatureValueMap.get(featureKey)); 
			featureParamList.add(featureParam);            
        }
		return featureParamList;						        
    }     
    
    private COMM_FeatureAccessManager () {
        for (String featureKey : configurableFeatureValueMap.keySet()) {
			initFeatureValue(featureKey);			            
        }
    }
    
    private void initFeatureValue (String featureKey){
        try {
        	configurableFeatureValueMap.put(featureKey, System.FeatureManagement.checkPackageIntegerValue(featureKey));
        } catch (Exception ex){
			System.debug(loggingLevel.INFO, 'Failed to Retrieve ' + featureKey + ' From LMO, using Default Value');            
        }        
    }
}