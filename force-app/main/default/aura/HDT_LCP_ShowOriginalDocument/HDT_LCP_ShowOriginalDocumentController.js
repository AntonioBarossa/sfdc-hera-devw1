({
    closeAction : function(component, event, helper) {
                console.log('close-----');

        $A.get("e.force:closeQuickAction").fire();
    }
})