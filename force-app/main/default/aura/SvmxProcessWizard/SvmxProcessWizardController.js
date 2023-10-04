({
    launchAction : function(component, event, helper) {
        var flowComponent = component.find('flowlauncher');
        var eventmessage = event.getParam('eventmsg');
        flowComponent.launchActioninModal(eventmessage);
    },
    refreshview : function(component, event, helper) {
        // defer refresh view
        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 10
        );
    }
})