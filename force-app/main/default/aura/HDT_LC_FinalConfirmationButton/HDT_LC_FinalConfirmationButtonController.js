({
    doInit: function(component, event, helper) {
        var recId=component.get("v.recordId")
        console.log('krist: '+recId);
        var action = component.get("c.updateRecord");
        action.setParams({orderId: component.get("v.recordId")});
        action.setCallback(this, function(response) {
            if(response.getReturnValue()=='ok'){
                console.log('OK');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Aggiornamento",
                    "message": "Ordine aggiornato correttamente"
                });
                resultsToast.fire();

                component.set("v.callLwc", 'true');
            }
            else {
                console.log('error');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Errore",
                    "message": "Non è stato possibile aggiornare l'ordine"
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },  

    handleclose: function(component, event, helper) {
        console.log('dentro handleclose');
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    }
})