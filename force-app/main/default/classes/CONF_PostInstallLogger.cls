/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements methods required to log post install script summary and details..
 * 
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       19 Oct 2020     Created.
 * A360TOOL-407 Ramachandra Mohan       01 Mar 2021     Email template update.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public without sharing class CONF_PostInstallLogger {
    
    /**
     * Private static const variable to hold space.
     */
    private static final String SPACE 					= ' ';
    
    /**
     * Private static const variable to hold email out policy.
     */
    private static final String EMAIL_OUT_POLICY 		= 'FILTER';
    
    /**
     * Private static const variable to hold email subject.
     */
    private static final String EMAIL_SUBJECT			= 'Asset 360 Configuration Status';
    
    /**
     * Private static const variable to hold display name.
     */
    private static final String SENDER_DISPLAY_NAME 	= 'Asset 360 Notification';
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static CONF_PostInstallLogger postInstallLogger;
    
    /**
     * Private list of strings variable to hold log details for attachment.
     */
    private List<String> logDetailsList = new List<String>();
    
    /**
     * Private list of strings variable to hold log summary for email body.
     */
    private List<String> logSummaryList = new List<String>();
    
    /**
     * Private list of String variable to hold application log.
     */
    private List<String > applicationLogList = new List<String>();
    
    /**
     * Public static method to get instance of this class.
     */
    public static CONF_PostInstallLogger getInstance() {
        
        if( postInstallLogger == null ) {
            postInstallLogger = new CONF_PostInstallLogger();
        }
        
        return postInstallLogger;
    }
    
    /**
     * This method is used to add message for summary.
     */
    public void logSummary( final String message ) {
        logSummaryList.add(message);
    }
    
    public void logDetail( final String message ) {
        logDetailsList.add( System.now() + SPACE + message );
    }
    
    public void applicationLog( final String message ) {
        applicationLogList.add( message );
    }
    
    public void createApplicationLogs( final Id userId ) {
        
        try {
            List<SVMXA360__ApplicationLog__c> applicationLogRecordList = new List<SVMXA360__ApplicationLog__c>();
            
            for( String message : applicationLogList ) {
                
                SVMXA360__ApplicationLog__c applicationLog = new SVMXA360__ApplicationLog__c();
                applicationLog.SVMXA360__Message__c = message;
                applicationLog.SVMXA360__LogType__c = SvmxLogger.Level.Error.name();
                applicationLog.SVMXA360__UserId__c = userId;
                applicationLog.SVMXA360__Timestamp__c = System.currentTimeMillis();
                applicationLog.SVMXA360__ApplicationName__c = SvmxLogger.Application.PostInstallScript.name();
                
                applicationLogRecordList.add(applicationLog);
            }
            
            if( !applicationLogRecordList.isEmpty() ) {
                SvmxDatabase.insertRecord(applicationLogRecordList);
            }
        }
        catch(Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createApplicationLogs() : Error while sending mail Error= ' + e.getMessage() );
            logDetailsList.add('Failed to create application log.');
            logDetailsList.add(e.getMessage());
            logDetailsList.add(e.getStackTraceString());
        }
        
    }
    
    public void sendEmail( final Id userId, final Boolean isUpgrade, final String previousVersion ) {
        
        try {
			
            String userName;
            String userEmail;
            String organizationId;
            String organizationName;
            final List<String> toAddressList = new List<String>();          
            
            try {
                User userRecord = [SELECT Name, Email FROM User WHERE id = :userId WITH SECURITY_ENFORCED ];
                userName = userRecord.Name;
                userEmail = userRecord.Email;
            }
            catch( Exception e ) {
                System.debug( LoggingLevel.ERROR, 'sendEmail() : Failed to get User email. Error= ' + e.getMessage() );
            }
            
            try {
                
                if( String.isBlank(userEmail) ) {
                    for( User adminUserRecord : [Select Name, Email from User where Profile.Name = 'System Administrator' AND IsActive = true] ) {
                        if( String.isNotBlank( adminUserRecord.Email ) ) {
                            toAddressList.add(adminUserRecord.Email);
                        }
                    }
                } else {
                    toAddressList.add(userEmail);
                }
            }
            catch( Exception e ) {
                System.debug( LoggingLevel.ERROR, 'sendEmail() : Failed to get User Info Error= ' + e.getMessage() );
            }

            try {
                final Organization organizationRecord = [SELECT Id, Name FROM Organization WITH SECURITY_ENFORCED];
                organizationId = organizationRecord.Id;
                organizationName = organizationRecord.Name;
            }
            catch( Exception e ) {
                System.debug( LoggingLevel.ERROR, 'sendEmail() : Failed to get Org Info Error= ' + e.getMessage() );
            }
			
            if( toAddressList.size() > 0 ) {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses( toAddressList );
                mail.optOutPolicy = EMAIL_OUT_POLICY;
                mail.setSenderDisplayName( SENDER_DISPLAY_NAME );
                mail.setSubject( EMAIL_SUBJECT );
                mail.setHtmlBody('<div>'+
									'<table style="height: 100%;border-style: ridge;" width="606" cellpadding="20px">'+
										'<tbody>'+
											'<tr style="height: 308px;">'+
												'<td style="width: 596px; height: 308px;"><a title="ServiceMax" href="https://www.servicemax.com"><img class="ge-logo" style="display: block; margin-left: auto; margin-right: auto;" src="https://s3-us-west-1.amazonaws.com/images.servicemax.com/servicemax-2019-logo.svg" alt="ServiceMax" width="203" height="26" /> </a>'+
													'<h2 style="text-align: center;">Asset 360 Import Configuration Status&nbsp;</h2>'+
													'<h4>&nbsp;</h4>'+
													'<h4>Hi &nbsp;'+
                                                    ( String.isNotBlank(userName) ? userName + ',</h4>' : ',</h4>') +
													'<p>Your request to ' + ( (isUpgrade) ? 'upgrade' : 'install' ) + ' package "ServiceMax Asset 360 for Salesforce" was successful.</p>'+
													'<p>&nbsp;</p>'+
                                 					'<b><p>User &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : ' + userName + '('+userId+')</p></b>'+
                                 					'<b><p>Organization &nbsp;&nbsp;: ' + organizationName + '('+organizationId+')</p></b>'+
                                 					'<b><p>Package &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : ServiceMax Asset 360 for Salesforce</p></b>'+
                                 					'<b><p>Install Type &nbsp;&nbsp;&nbsp;&nbsp; : ' + ( (isUpgrade) ? 'Upgrade': 'Fresh Install' ) + 
                                                    (String.isNotBlank(previousVersion) ? '<b><p>Previous Version &nbsp;: ' + previousVersion : '') +
                                 					'</p></b><p>&nbsp;</p>'+
													'<h3>Summary</h3>'+
													'<p>&nbsp;</p>'+
													'<p>'+ ( (logSummaryList.size() > 0 ) ? String.join(logSummaryList, '<br><br>') : 'No new configurations added in this package') +'</p>'+
													'<p>&nbsp;</p>'+
													'<p>&nbsp;</p>'+                              
													'<p><span style="color: #999999;font-size: 8.0pt;">Please note that this is an auto generated email,do not reply.  In case of any queries write to ENG.BLR.A360Tooling@servicemax.com	</span></p>'+
												'</td>'+                            
											'</tr>'+
											'<tr style="height: 2px;">'+
												'<td style="width: 465.7pt; border-right: 1pt solid #bfbfbf; border-bottom: 1pt solid #bfbfbf; border-left: 1pt solid #bfbfbf; border-image: initial; border-top: none; background: #000066; padding: 0in 5.4pt; height: 2px;" colspan="2" valign="top" width="621">'+
													'<p style="margin-right: .1in; margin-bottom: .0001pt; margin-left: .1in; text-align: center;" align="center"><strong><span style="font-size: 14.0pt;">&nbsp;</span></strong></p>'+
												'</td>'+
											'</tr>'+
										'</tbody>'+
									'</table>'+
								'<p>&nbsp;</p>'+
							'</div>');
                if( logDetailsList != null && logDetailsList.size() > 0 ) {
                    
                    Messaging.EmailFileAttachment objFileAttachment = new Messaging.EmailFileAttachment();
                    objFileAttachment.setFileName('Asset 360 Configuration Log.pdf');
                    objFileAttachment.setContentType('application/pdf');
                    objFileAttachment.setBody( 
                        Blob.toPDF('<html>'+
										'<table style="height: 100%;border-style: ridge;">'+
											'<tbody>'+
												'<tr style="height: 308px;">'+
													'<td style="width: 596px; height: 308px;">'+
														'<h2 style="text-align: center;"><b>Asset 360 Import Configuration Report</b>&nbsp;</h2>'+
														'<p>&nbsp;</p>'+
														'<p>&nbsp;</p>'+
														'<h3 style="padding-left:20px"><b>Tooling Log</b></h3>'+
														'<p>&nbsp;</p>'+
														'<p style="padding-left:20px">'+ String.join(logDetailsList, '<br>') +'</p>'+
														'<p>&nbsp;</p>'+
														'<p>&nbsp;</p>'+                              
														'<p><span style="color: #999999;font-size: 8.0pt;padding-left:20px">Please note that this is an auto generated email,do not reply.  In case of any queries write to ENG.BLR.A360Tooling@servicemax.com</span></p>'+
													'</td>'+                            
												'</tr>'+
												'<tr style="height: 2px;">'+
													'<td style="width: 465.7pt; border-right: 1pt solid #bfbfbf; border-bottom: 1pt solid #bfbfbf; border-left: 1pt solid #bfbfbf; border-image: initial; border-top: none; background: #000066; padding: 0in 5.4pt; height: 2px;" colspan="2" valign="top" width="621">'+
														'<p style="margin-right: .1in; margin-bottom: .0001pt; margin-left: .1in; text-align: center;" align="center"><strong><span style="font-size: 14.0pt;">&nbsp;</span></strong></p>'+
													'</td>'+
												'</tr>'+
											'</tbody>'+
										'</table>'+
									'<p>&nbsp;</p>'+
								'</html>'));
                    mail.setFileAttachments( new Messaging.EmailFileAttachment[] {objFileAttachment} );
                }
                
                mail.setUseSignature(false);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                if(result[0].IsSuccess() == false){
                    Messaging.SendEmailError[] error = result[0].getErrors();
                    System.debug( LoggingLevel.DEBUG, 'There was a problem processing the email. Please contact your system administrator. ' + error[0].getMessage() ); 
                }
                else{
                    System.debug( LoggingLevel.DEBUG, 'sendEmail() - Email sent successfully' );
                }
            }
            else {
                System.debug( LoggingLevel.DEBUG, 'sendEmail() - User Mail Id not found');
            }
        }
        
        catch(Exception e) {
            
             System.debug( LoggingLevel.ERROR, 'sendConfiguratorEmail() : Error while sending mail Error= ' + e.getMessage() );
        }
    }
    
    public void sendFailureEmail( final String userName, final String userMail ) {
        
        try {
            
            if( String.isNotBlank(userMail) ) {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses( new List<String> { userMail } );
                mail.optOutPolicy = EMAIL_OUT_POLICY;
                mail.setSenderDisplayName( SENDER_DISPLAY_NAME );
                mail.setSubject( EMAIL_SUBJECT );
                mail.setHtmlBody('<div>'+
									'<table style="height: 100%;border-style: ridge;" width="606" cellpadding="20px">'+
										'<tbody>'+
											'<tr style="height: 308px;">'+
												'<td style="width: 596px; height: 308px;"><a title="ServiceMax" href="https://www.servicemax.com"><img class="ge-logo" style="display: block; margin-left: auto; margin-right: auto;" src="https://s3-us-west-1.amazonaws.com/images.servicemax.com/servicemax-2019-logo.svg" alt="ServiceMax" width="203" height="26" /> </a>'+
													'<h2 style="text-align: center;">Asset 360 Import Configuration Status&nbsp;</h2>'+
													'<h4>&nbsp;</h4>'+
													'<h4>Hi&nbsp;'+ userName +'</h4>'+
													'<p>Your request for loading the default configuration for Asset 360 Failed</p>'+
													'<p>&nbsp;</p>'+
													'<p>&nbsp;</p>'+
													'<p>Asset 360 default configurations already exist, please uninstall and install the package again if you are trying to load the latest Asset 360 Configurations.</p>'+
													'<p>&nbsp;</p>'+
													'<p>&nbsp;</p>'+                              
													'<p><span style="color: #999999;font-size: 8.0pt;">Please note that this is an auto generated email,do not reply.  In case of any queries write to ENG.BLR.A360Tooling@servicemax.com	</span></p>'+
												'</td>'+                            
											'</tr>'+
											'<tr style="height: 2px;">'+
												'<td style="width: 465.7pt; border-right: 1pt solid #bfbfbf; border-bottom: 1pt solid #bfbfbf; border-left: 1pt solid #bfbfbf; border-image: initial; border-top: none; background: #000066; padding: 0in 5.4pt; height: 2px;" colspan="2" valign="top" width="621">'+
													'<p style="margin-right: .1in; margin-bottom: .0001pt; margin-left: .1in; text-align: center;" align="center"><strong><span style="font-size: 14.0pt;">&nbsp;</span></strong></p>'+
												'</td>'+
											'</tr>'+
										'</tbody>'+
									'</table>'+
								'<p>&nbsp;</p>'+
							'</div>');
                
                mail.setUseSignature(false);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                if(result[0].IsSuccess() == false){
                    Messaging.SendEmailError[] error = result[0].getErrors();
                    System.debug( LoggingLevel.DEBUG, 'There was a problem processing the email. Please contact your system administrator. ' + error[0].getMessage() ); 
                }
                else{
                    System.debug( LoggingLevel.DEBUG, 'sendConfiguratorEmail() - Email sent successfully : ' );
                }
            }
            else {
                System.debug( LoggingLevel.DEBUG, 'sendConfiguratorEmail() - User Mail Id not found : ' + userMail );
            }
        }
        
        catch(Exception e) {
            
             System.debug( LoggingLevel.ERROR, 'sendConfiguratorEmail() : Error while sending mail Error= ' + e.getMessage() );
        }
    }

    private CONF_PostInstallLogger() {
    }
}