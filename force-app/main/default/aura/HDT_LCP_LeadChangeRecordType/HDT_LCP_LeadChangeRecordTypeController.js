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
                console.log("SUCCESS:" + response.getReturnValue());
                let res = response.getReturnValue();
                if(res.comm == 'true'){    
                    window.open(res.url, "_self");
                }
                else{
                    var navEvt = $A.get("e.force:navigateToURL");
                    navEvt.setParams({
                        "url": res.url
                    });
                    navEvt.fire();
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