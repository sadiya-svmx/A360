({
    resetRecordId: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.recordId", pageRef.state.c__recordId);
    },

    resetActionName: function(cmp) {
        var pageRef = cmp.get("v.pageReference");

        cmp.set("v.actionName", pageRef.state.c__actionName);
    }
})