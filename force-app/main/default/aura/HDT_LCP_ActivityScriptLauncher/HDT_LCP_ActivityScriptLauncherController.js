({
    doInit : function(cmp, event, helper) {
        helper.callApexMethod(cmp, "getScriptConfig", {activityId: cmp.get("v.recordId")}).then($A.getCallback(function(scriptConfig){
            if (scriptConfig.scriptName) {
                cmp.set("v.scriptName", scriptConfig.scriptName);
                cmp.set("v.scriptTarget", scriptConfig.scriptTarget);
                cmp.set("v.isLoading", false);
            }
            else {
                helper.showWarningMessage("Nessuno Script disponibile", "Non è presente uno Script per l'Attività corrente");
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        }),$A.getCallback(function(){
            helper.showErrorMessage("Errore caricamento Script", "Non è stato possibile calcolare lo Script da utilizzare");
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }));
    },
    handleCloseAction : function(cmp, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();

        $A.get('e.force:refreshView').fire();
    },
    handleResultEvent: function(component, event, helper) {

        console.log('handleResultEvent: ' + event.getParam('orderId'));

        /*helper.redirectToSObjectSubtab(component,event.getParam('orderId'),'Order');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();*/
    }
})
