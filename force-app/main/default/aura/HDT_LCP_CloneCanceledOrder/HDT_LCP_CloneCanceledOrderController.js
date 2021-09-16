({
    doInit : function(cmp, event, helper) {
        var params = {
            orderId:cmp.get("v.recordId")
        };

        return helper.callApexMethod(cmp, "cloneOrder", params).then($A.getCallback(function(){

            $A.get('e.force:closeQuickAction').fire();
            helper.showSuccessMessage("Ordine clonato", "Operazione eseguita con successo");
            $A.get('e.force:refreshView').fire();

        })).catch($A.getCallback(function(error){
            
            $A.get('e.force:closeQuickAction').fire();
            helper.showWarningMessage("Non è stato possibile clonare l'Ordine", error);
        }));
    }
})
