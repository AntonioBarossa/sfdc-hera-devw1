({
    doInit: function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var action = component.get("c.init");
        action.setParams({
            'activityId': component.get("v.recordId")
        });
        action.setCallback(this,function(response){
        	var state = response.getState();
            if (state === "SUCCESS") {
            	var res = response.getReturnValue();
                if(!res){
                	var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Esito non disponibile per questa activity",
                        "type" : "error"
                    });
                    resultsToast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                	dismissActionPanel.fire();
                }
                else{
                    //Controllo permesso di esitazione C/Q Call
                    var permAction = component.get("c.checkPermission");
                    permAction.setCallback(this,function(permResp){
                        var permState = permResp.getState();
                        if (permState === "SUCCESS") {
                            var permRes = permResp.getReturnValue();
                            if(!permRes){
                                var permErrorToast = $A.get("e.force:showToast");
                                permErrorToast.setParams({
                                    "title": "Error",
                                    "message": "Non si dispone dei permessi necessari all'Esitazione della Comfort / Quality Call.",
                                    "type" : "error"
                                });
                                permErrorToast.fire();
                                var closePanel = $A.get("e.force:closeQuickAction");
                                closePanel.fire();
                            }
                        }
                    });
                    $A.enqueueAction(permAction);
                }                
                // Close the action panel
            }
            component.set("v.HideSpinner",false);
        });
        $A.enqueueAction(action);
    },

    handleResultEvent: function(component, event, helper) {

        console.log('handleResultEvent: ' + event.getParam('orderId'));

        helper.redirectToSObjectSubtab(component,event.getParam('orderId'),'Order');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    handleConfirm: function(component, event, helper) {
        component.set("v.HideSpinner",false);
        console.log('handleConfirm: ' + component.get("v.recordId"));

        var action = component.get("c.confirmContract");

        console.log('LOG 1');
        action.setParams({'ordId': component.get("v.recordId")});

        console.log('LOG 2');
        action.setCallback(this,function(response){
            console.log('LOG 3');
        	var state = response.getState();
            console.log('LOG 4');
            if (state === "SUCCESS") {
                console.log('LOG 5');
            	var res = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Contratto confermato con successo",
                    "type" : "success"
                });
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            } else {
                console.log('LOG 6');
                var res = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "C\'è stato un problema. contattare il supporto",
                    "type" : "Error"
                });
                resultsToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            console.log('LOG 7');
            component.set("v.HideSpinner",true);
        });
        $A.enqueueAction(action);
    },

    handleCancel: function(component, event, helper) {
        console.log('handleCancel ' + component.get("v.recordId"));

        var action = component.get("c.cancelContract");
        action.setParams({'ordId': component.get("v.recordId")});

        action.setCallback(this,function(response){
        	var state = response.getState();
            if (state === "SUCCESS") {
            	var res = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Contratto annullato con successo",
                    "type" : "success"
                });
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
               $A.get('e.force:refreshView').fire();
                
            } else {
                var res = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "C\'è stato un problema. contattare il supporto",
                    "type" : "Error"
                });
                resultsToast.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            component.set("v.HideSpinner",true);
        });
        $A.enqueueAction(action);  
    }
})
