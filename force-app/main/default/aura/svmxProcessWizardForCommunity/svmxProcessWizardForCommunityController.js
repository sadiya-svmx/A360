({
    launchAction : function(component, event, helper) {
        var flowComponent = component.find('flowlauncher');
        var eventmessage = event.getParam('eventmsg');
        flowComponent.launchActioninModal(eventmessage);
    },
})