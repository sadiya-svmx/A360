({
    resetRecordId: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.recordId", pageRef.state.c__recordId);
    },

    resetObjectName: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.objectAPIName", pageRef.state.c__objectName);
    },

    resetActionName: function(cmp) {
        var pageRef = cmp.get("v.pageReference");
        cmp.set("v.actionName", pageRef.state.c__action);
    },

    resetSequence: function(cmp) {
        var pageRef = cmp.get("v.pageReference");
        cmp.set("v.sequence", pageRef.state.c__sequence);
    }
})