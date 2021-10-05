({
    doInit: function(component, event, helper) {
        var action = component.get("c.completeCase");
        var myPageRef = component.get("v.pageReference");
        var caseId = myPageRef.state.c__recordId;
        console.log(caseId);
        action.setParams({'caseId': caseId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            if (state === "SUCCESS") {                
            	var res = response.getReturnValue();
                console.log(JSON.stringify(res));
                var resultsToast = $A.get("e.force:showToast");
                if(res == 'success'){
                    resultsToast.setParams({
                        "title": "Case completato con successo",
                        "message": "",
                        "type" : "success"
                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();  
                } else if(res != '') {
                    resultsToast.setParams({
                        "title": "Error",
                        "message": res,
                        "type" : "error"
                    });
                    resultsToast.fire();
                }
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action); 

    }
})
