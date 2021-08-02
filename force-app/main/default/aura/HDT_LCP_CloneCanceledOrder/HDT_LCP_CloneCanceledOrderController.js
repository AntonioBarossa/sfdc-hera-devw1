({
    doInit : function(cmp, event, helper) {
        var params = {
            orderId:cmp.get("v.recordId")
        };

        return helper.callApexMethod(cmp, "isCloneAllowed", params).then($A.getCallback(function(isAllowed){
            if (isAllowed)
            {
                return helper.callApexMethod(cmp, "cloneOrder", params).then($A.getCallback(function(){
                    $A.get('e.force:closeQuickAction').fire();
                    helper.showSuccessMessage("", "Ordine clonato con successo");
                    $A.get('e.force:refreshView').fire();
                }));
            }
            else
            {
                $A.get('e.force:closeQuickAction').fire();
                helper.showWarningMessage("", "L'Ordine visualizzato non può essere clonato");
            }
        })).catch($A.getCallback(function(error){
            $A.get('e.force:closeQuickAction').fire();
            helper.showErrorMessage("Errore durante la clonazione", error);
        }));
    }
})
