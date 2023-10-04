/* eslint-disable no-unused-expressions */
({
    handleInit : function(component, event, helper) {
        var isMobile = $A.get('$Browser.isPhone') || $A.get('$Browser.isTablet');
        if (isMobile) {
            component.set('v.showIcons', true);
        }
    },
    launchAction : function(component, event, helper) {
        var flowComponent = component.find('flowlauncher');
        var eventmessage = event.getParam('eventmsg');
        flowComponent.launchActioninModal(eventmessage);
    },
    handleCloseAction : function() {
        $A.get("e.force:closeQuickAction").fire();
    }
})