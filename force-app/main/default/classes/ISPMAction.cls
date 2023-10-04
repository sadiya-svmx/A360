/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides global interface for implementing 
 * custom action services. 
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
global interface ISPMAction {
    SvmxGlobal.SvmxResponse execute(SvmxGlobal.SvmxPageData pageData);
}