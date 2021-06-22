({
    init: function(component, event, helper) {
        var param = component.get("v.recordId");
        var action = component.get("c.changeRecordTypeOfLead");
         action.setParams({leadId:param });
         action.setCallback(this, function(response)
         {
             var state = response.getState();
             console.log(response.getReturnValue());
         	if (state === "SUCCESS") 
         	{
                console.log("SUCCESS");
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": response.getReturnValue(),
                  "slideDevName": "Detail"
                });
                navEvt.fire();
         	}
         	else
         	{
                console.log("Error");
         	}    
         });
         $A.enqueueAction(action);	
    },
})