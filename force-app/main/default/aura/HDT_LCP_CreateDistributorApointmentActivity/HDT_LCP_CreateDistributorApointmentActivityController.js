({
    handleActivityNavigation : function(component, event, helper) {

        var workspaceAPI = component.find("workspace");
        
        var details = event.getParams('activityId');

        console.log('Event details ' + JSON.stringify(details));

        workspaceAPI.getFocusedTabInfo().then(function(response) {

            var focusedTabId;
            if(response.parentTabId){
                focusedTabId = response.parentTabId;
            }
            else{
                focusedTabId = response.tabId;
            }

            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                pageReference: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: details.activityId,
                        actionName: 'view'
                    }
                },
                focus: true
            })
            }).catch(function(error) {

                var toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams({
                    "title": $A.get("$Label.c.Error"),
                    "message": error,
                    "type": "error"
                });
                
                toastEvent.fire();

                console.error(error);
                helper.closeQuickAction();
            });

    },

    handleError : function(component, event, helper) {

        helper.closeQuickAction();

    }
})
