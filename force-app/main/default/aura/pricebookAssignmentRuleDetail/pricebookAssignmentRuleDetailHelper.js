({
    resetRecordId: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.recordId", pageRef.state.c__recordId);
    },

    resetObjectName: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.objectName", pageRef.state.c__objectName);
    },

    resetActionName: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.actionName", pageRef.state.c__actionName);
    } 
})