({
    handleMenuSelection: function(component, event, helper) {
        var utils = component.find("utils");
        var navService = component.find("navService");
        var name = event.getParam("name");
        var targetType = event.getParam("targetType");
        var targetDeveloperName = event.getParam("targetDeveloperName");
        var transformedEvent = {
            detail: {
                name: name,
                targetType: targetType,
                targetDeveloperName: targetDeveloperName
            }
        };
        var pageRef = utils.getPageReference(transformedEvent);
        navService.navigate(pageRef);
    },
    
    handleSplitterClick: function(component, event, helper) {
        event.stopPropagation();
        var currentExpandedState = component.get("v.expanded");
        component.set("v.expanded", !currentExpandedState);
    }
});