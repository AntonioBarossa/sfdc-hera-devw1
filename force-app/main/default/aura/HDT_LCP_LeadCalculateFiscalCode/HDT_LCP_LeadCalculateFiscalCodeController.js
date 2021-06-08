({
    init: function(component, event, helper) {
        var param = component.get("v.recordId");
        var action = component.get("c.calculateLeadFiscalCode");
         action.setParams({leadId:param });
         action.setCallback(this, function(response)
         {
             var state = response.getState();
             console.log(response.getReturnValue());
         	if (state === "SUCCESS") 
         	{
                console.log("SUCCESS");
                if(response.getReturnValue()!=''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                        "message": response.getReturnValue()
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    window.location.reload();
                }
         	}
         	else
         	{
                console.log("Error");
         	}    
         });
         $A.enqueueAction(action);	
    },
})