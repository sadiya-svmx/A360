/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides aura enabled method for 
 * invoking custom action services.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                03 May 2021     Created.
 *****************************************************************************************************/
public class CONF_CustomAction {

  @AuraEnabled
  public static SvmxGlobal.SvmxResponse executeAction(String requestJson) {
    SvmxGlobal.SvmxResponse serviceResponse = new SvmxGlobal.SvmxResponse();

    try{  
        SvmxGlobal.ActionRequest deserializedReq = (SvmxGlobal.ActionRequest)JSON.deserialize(requestJson, SvmxGlobal.ActionRequest.class);  
        ISPMAction action = (ISPMAction)Type.forName(deserializedReq.actionName).newInstance();
        serviceResponse = action.execute(deserializedReq.pageData);
    }catch(SvmxSystem.SvmxNestedException e){
            
        System.debug( LoggingLevel.ERROR, 'executeAction() : Failed to invoke custom button action. Error' + e.getStackTraceString());
        serviceResponse.success = false;
        serviceResponse.message = e.getMessage();        
    }catch(Exception e) {
            
        System.debug( LoggingLevel.ERROR, 'executeAction() : Failed to invoke custom button action. Error' + e.getStackTraceString());
        serviceResponse.success = false;
        serviceResponse.message = System.label.Error_InvalidCustomAction;
    } finally {
        System.debug( LoggingLevel.DEBUG, 'executeAction() - exit; serviceResponse.success= ' + serviceResponse.success);
    }
	  return serviceResponse;
  }
}