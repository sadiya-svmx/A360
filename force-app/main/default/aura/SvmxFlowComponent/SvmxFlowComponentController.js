({
    init: function (cmp, event, helper) {
        helper.launchAction(cmp);
    },
    
    handleStatusChange: function (cmp, event,helper) {
        helper.handleFlowStatusChange(cmp,event);
    },

    destroyComponent: function (cmp, event, helper) {
        helper.destroyComponent(cmp,event);
    }
});