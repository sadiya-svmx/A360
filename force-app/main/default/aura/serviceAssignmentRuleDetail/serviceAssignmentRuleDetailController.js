({
    doInit : function(cmp, event, helper) {
        helper.resetRecordId(cmp);
        helper.resetObjectName(cmp);
        helper.resetActionName(cmp);
    },

    onPageReferenceChange: function(cmp, evt, helper) {
        helper.resetRecordId(cmp);
        helper.resetObjectName(cmp);
        helper.resetActionName(cmp);
    }
  
})