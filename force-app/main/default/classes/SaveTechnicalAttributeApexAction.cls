/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief An invocable apex action to save technical attributes
 *
 * @author Jeevika Rao
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID            Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-1927     Jeevika Rao         08 Aug 2022     Created.
 *****************************************************************************************************/
global with sharing class SaveTechnicalAttributeApexAction {

    /**
     * This method is to save Technical Attribute values on a record (Asset,Opportunity etc.)
     * 
     * @param TechnicalAttributeRequest Request structure with valid info related to technical attributes
     * 
     * @return Returns List<TechnicalAttributeRequest>
     */
    @InvocableMethod(label='Save Technical Attributes' description='Apex action to save Technical Attributes' category='Asset 360 Actions')
    global static List<TechnicalAttributeRequest> saveTechnicalAttributes( final List<TechnicalAttributeRequest> technicalAttributeDataRequestList) {
        
        System.debug(LoggingLevel.DEBUG, 'saveTechnicalAttributes - enter.  technicalAttributeDataRequestList - '+ technicalAttributeDataRequestList);
        
        List<TechnicalAttributeRequest> technicalAttributeDataList = new List<TechnicalAttributeRequest>();

        try {
            if( technicalAttributeDataRequestList == null || technicalAttributeDataRequestList.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : Invalid request parameters. technicalAttributeDataRequestList= ' + technicalAttributeDataRequestList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            Common.RequestOption requestOption = new Common.RequestOption();
            requestOption.operationType = 'ApexAction';
            requestOption.isCreateActivityLogs = true;
            technicalAttributeDataList.add( new TA_TechnicalAttributeHandler().saveTechnicalAttributes(technicalAttributeDataRequestList[0], requestOption ));
           
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : Failed to save technical attribute value. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : Failed to save technical attribute value. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributes() - exit; technicalAttributeDataRequestList = ' + technicalAttributeDataRequestList );
        }

        return technicalAttributeDataList;
    }
}