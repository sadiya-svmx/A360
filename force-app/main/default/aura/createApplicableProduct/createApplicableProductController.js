({
	closeMethodInAuraController : function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();
	},
	
	closeAndRefresh : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
		$A.get('e.force:refreshView').fire();
    }
    
})