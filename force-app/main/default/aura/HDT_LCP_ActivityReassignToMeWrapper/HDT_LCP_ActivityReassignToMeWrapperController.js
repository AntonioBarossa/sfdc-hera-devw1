({
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    assignerUpdated : function(component, event, helper){
        $A.get("e.c:HDT_LCE_AssignerUpdated").fire();
    }
})
