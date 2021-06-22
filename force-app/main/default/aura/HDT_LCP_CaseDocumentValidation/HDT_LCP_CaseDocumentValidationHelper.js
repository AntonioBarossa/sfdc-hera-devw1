({
	isValidPhase : function(component){
        var action = component.get("c.isValidPhase");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.phaseValid", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    }
})