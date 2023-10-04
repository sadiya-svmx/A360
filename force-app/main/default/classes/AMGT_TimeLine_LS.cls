/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve asset timeline data.
 *
 * @author Ryan Follmer
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ryan Follmer            10 December 2020  Created.
 *****************************************************************************************************/
 
public with sharing class AMGT_TimeLine_LS {

    @AuraEnabled(cacheable=true)
    public static List<Amgt.TimelineCategory> getTimelineCategories(String developerName){
        List<Amgt.TimelineCategory> timelineCategories = new List<Amgt.TimelineCategory>();
        try {
            Map<String,String> translatedVals = ADM_TranslationUtils.getInstance().getTranslationMapForTags(
                    new List<String>{'TimelineCategory'},
                    new List<String>{
                        developerName+'-'+'Bands',
                        developerName+'-'+'Events',
                        developerName+'-'+'Milestones'});
            Map<String,String> deftranslatedVals = ADM_TranslationUtils.getInstance().getTranslationMapForTags(
                new List<String>{'TimelineCategory'},
                new List<String>{
                    'Bands',
                    'Events',
                    'Milestones'});
            Amgt.TimelineCategory bandCategory = new Amgt.TimelineCategory();
            bandCategory.categoryType = 'Bands';
            bandCategory.label = translatedVals.containsKey('TimelineCategory'+developerName+'-'+'Bands')
                ? translatedVals.get('TimelineCategory'+developerName+'-'+'Bands')
                : deftranslatedVals.get('TimelineCategoryBands');
            Amgt.TimelineCategory eventCategory = new Amgt.TimelineCategory();
            eventCategory.categoryType = 'Events';
            eventCategory.label = translatedVals.containsKey('TimelineCategory'+developerName+'-'+'Events')
                ? translatedVals.get('TimelineCategory'+developerName+'-'+'Events')
                : deftranslatedVals.get('TimelineCategoryEvents');
            Amgt.TimelineCategory milestonesCategory = new Amgt.TimelineCategory();
            milestonesCategory.categoryType = 'Milestones';
            milestonesCategory.label = translatedVals.containsKey('TimelineCategory'+developerName+'-'+'Milestones')
                ? translatedVals.get('TimelineCategory'+developerName+'-'+'Milestones')
                : deftranslatedVals.get('TimelineCategoryMilestones');
            timelineCategories.add(bandCategory);
            timelineCategories.add(eventCategory);
            timelineCategories.add(milestonesCategory);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return timelineCategories;
    }

    @AuraEnabled
    public static Common.ServiceResponse getTimelineData( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineData() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Amgt.TimelineRequest request = (Amgt.TimelineRequest) JSON.deserializeStrict( requestJson, Amgt.TimelineRequest.class );

            // Verify request parameters for required information.
            if( request == null 
                || String.isBlank( request.parentRecordId ) 
                || String.isBlank( request.fieldApiName ) 
                || request.startDate == null
                || request.endDate == null
            ) {
                System.debug( LoggingLevel.ERROR, 'getTimelineData() : Invalid arguments. request= ' + request);

                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }            

            serviceResponse.data = AMGT_TimeLineManager.getInstance().getTimelineData(request);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'getTimelineData() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getTimelineData() : Failed to retrieve Timeline data. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineData() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

}