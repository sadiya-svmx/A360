/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides sorting implementation for all the data types.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                11 Aug 2021     Created.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public class COMM_SObjectSorter {

    public Static List<SortByInfo> sortingDetailList;
    
    public class SObjectWrapper implements Comparable {
        public sObject sObjectRecord;
        // Constructor
        public SObjectWrapper(sObject sObj) {
            this.sObjectRecord = sObj;
        }

        public Integer compareTo(Object compareTo) {
            // Cast argument to SObjectWrapper
            SObjectWrapper compareTosObj = (SObjectWrapper)compareTo;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;

            for(SortByInfo sortingDetail : sortingDetailList){

                if(returnValue != 0){
                    break;
                }

                Object fieldValue = sObjectRecord.get(sortingDetail.fieldAPIName);
                Object compareToValue = compareTosObj.sObjectRecord.get(sortingDetail.fieldAPIName);
                
                if(fieldValue == null && compareToValue == null){
                    return 0;
                } else if(fieldValue == null && compareToValue != null){
                    return sortingDetail.sortingOrder.equals('asc') ? -1 : 1;
                } else if(fieldValue != null && compareToValue == null){
                    return sortingDetail.sortingOrder.equals('asc') ? 1 : -1;
                }
        
                if (sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.Double.name()) || sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.Percent.name())
                    || sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.Currency.name() )) {
                    // Set return value to a positive value.
                    if(double.valueOf(fieldValue) > double.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? 1 : -1;
                    }else if(double.valueOf(fieldValue) < double.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? -1 : 1;
                    }
                } else if(sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.Integer.name()) ){
                    if(integer.valueOf(fieldValue) > integer.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? 1 : -1;
                    }else if(integer.valueOf(fieldValue) < integer.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? -1 : 1;
                    }
                } else if(sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.Boolean.name()) ){
                    if(boolean.valueOf(fieldValue) == false){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? 1 : -1;
                    }else if(boolean.valueOf(fieldValue) == true){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? -1 : 1;
                    }
                } else if(sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.Date.name())){
                    if(date.valueOf(fieldValue) > date.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? 1 : -1;               
                    }else if(date.valueOf(fieldValue) < date.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? -1 : 1;               
                    }
                } else if(sortingDetail.dataType.equalsIgnoreCase( Schema.DisplayType.DateTime.name())){
                    if(dateTime.valueOf(fieldValue) > dateTime.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? 1 : -1;               
                    }else if(dateTime.valueOf(fieldValue) < dateTime.valueOf(compareToValue)){
                        returnValue = sortingDetail.sortingOrder.equals('asc') ? -1 : 1;               
                    }
                } else if(sortingDetail.dataType.equalsIgnoreCase(Schema.DisplayType.STRING.name()) || sortingDetail.dataType.equalsIgnoreCase(Schema.DisplayType.EMAIL.name()) ||
                    sortingDetail.dataType.equalsIgnoreCase(Schema.DisplayType.PICKLIST.name()) ||  sortingDetail.dataType.equalsIgnoreCase(Schema.DisplayType.TEXTAREA.name() )){
                    returnValue = (sortingDetail.sortingOrder.equals('asc') ? 1 : -1) * String.valueOf(fieldValue).compareTo(String.valueOf(compareToValue));
                } else if(sortingDetail.dataType.equalsIgnoreCase(Schema.DisplayType.REFERENCE.name())){
                    if(!sortingDetail.referenceNameFields.isEmpty()){
                        String lookupName;
                        String compareLookupName;
                        if(sObjectRecord.getSObject(sortingDetail.relationshipName) != null){
                            lookupName = (String)sObjectRecord.getSObject(sortingDetail.relationshipName).get(sortingDetail.referenceNameFields[0]);
                        }
                        if(compareTosObj.sObjectRecord.getSObject(sortingDetail.relationshipName) != null){
                            compareLookupName = (String)compareTosObj.sObjectRecord.getSObject(sortingDetail.relationshipName).get(sortingDetail.referenceNameFields[0]);
                        }
                        if(lookupName == null && lookupName == null){
                            returnValue = 0;
                        } else if(lookupName == null && compareLookupName != null){
                            returnValue = sortingDetail.sortingOrder.equals('asc') ? -1 : 1;
                        } else if(lookupName != null && lookupName == null){
                            returnValue = sortingDetail.sortingOrder.equals('asc') ? 1 : -1;
                        } else {
                            returnValue = (sortingDetail.sortingOrder.equals('asc') ? 1 : -1) * lookupName.compareTo(compareLookupName);
                        }

                    }

                }    
            }

            return returnValue;
        }
    }

    public class SortByInfo {
        public String fieldAPIName;
        public String dataType;
        public String sortingOrder; 
        public String relationshipName;
        public List<String> referenceNameFields;
    }
}