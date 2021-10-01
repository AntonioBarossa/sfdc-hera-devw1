({
    recordUpdated : function(cmp, event, helper) {
        var activity = cmp.get("v.activity");

        var orderId = activity.Order__c;

        var scriptName;
        switch (activity.Type__c) {
            case "Quality Call":
                scriptName = "Quality call";
                break;
            case "Comfort Call":
                scriptName = "Comfort call";
                break;
            default:
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Nessuno Script disponibile",
                    message: "Non è presente uno Script per l'Attività corrente",
                    type: "warning"
                });
                toastEvent.fire();
        }
        
        cmp.set("v.orderId", orderId);
        cmp.set("v.scriptName", scriptName);
        cmp.set("v.isLoading", false);
    },
    handleCloseAction : function(cmp, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})
