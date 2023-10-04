/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This class prevents user to create/update user group member record without user detail.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID          Name                    Date            Comment
 *****************************************************************************************************
 *  A360AM-2253  Sandeep Dhariwal      17 Nov 2022        Created.
 *****************************************************************************************************/
public with sharing class UserGroupMemberTriggerHandler {
    
    public static void checkUserRecord( List<SVMXA360__CONF_UserGroupMember__c> userGroupMembers ) {

        System.debug( LoggingLevel.DEBUG, 'checkUserRecord() enter - userGroupMembers: ' + userGroupMembers);

        try { 
            for ( SVMXA360__CONF_UserGroupMember__c userGroupMember : userGroupMembers ) {

                if ( userGroupMember.SVMXA360__UserId__c == null ) {
                    userGroupMember.SVMXA360__UserId__c.addError(Label.Message_UserRequired);
                }
            }
        } 
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'checkUserRecord() : Failed to check User Record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'checkUserRecord() - exit');
        } 
    }
}