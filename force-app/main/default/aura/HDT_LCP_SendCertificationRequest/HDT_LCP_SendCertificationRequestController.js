({
    handleActionClose : function(component, event, helper) {

        console.log('received closing event');
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

    }
})