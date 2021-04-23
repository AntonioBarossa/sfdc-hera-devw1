({
    doInit: function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var action = component.get("c.isValidPhase");
        action.setParams({'recordId': component.get("v.recordId")});
        action.setCallback(this,function(response){
        	var state = response.getState();
            console.log("first step");
            if (state === "SUCCESS") {                
            	var res = response.getReturnValue();
                if(!res){
                	var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Validazione Non richiesta o Già Effettuata",
                        "type" : "error"
                    });
                    resultsToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                	dismissActionPanel.fire();
                }
                
                // Close the action panel
            }
            console.log('ReturnValue--> '+res);
            component.set("v.formValid",res);
            component.set("v.HideSpinner",false);
        });
        $A.enqueueAction(action);  
    },

    handleComplete: function(component, event, helper){

        var action = component.get("c.saveValidation");

        console.log('AURA_EVENT--> '+event.getParam('validated'));

        var isValidated = event.getParam('validated');

        console.log('AURA: Event Detail--> '+isValidated);

        action.setParams({
            caseId: component.get("v.recordId"),
            allValidated: isValidated
        });
        action.setCallback(this,function(response){

            var state = response.getState();
            if(state === "SUCCESS"){

                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();  

            }

        });
        $A.enqueueAction(action); 

    },

    handleCancel: function(component, event, helper) {
        //close the modal
        $A.get("e.force:closeQuickAction").fire();
    }
})
