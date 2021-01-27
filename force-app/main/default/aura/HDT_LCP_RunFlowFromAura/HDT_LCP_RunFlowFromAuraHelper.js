({
    closeSubTab : function(component,event, helper) {
        var workspaceAPI = component.find("workspace");
        var subTabToClose = component.get("v.subTabToClose");
        workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {

        }).catch(function(error) {
            console.log(error);
        });
    },

    closeSubTabAndRefresh : function(component,event, helper) {
        var workspaceAPI = component.find("workspace");
        var subTabToClose = component.get("v.subTabToClose");
        workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
            console.log('# OK Refresh page #');
            $A.get('e.force:refreshView').fire();
        }).catch(function(error) {
            console.log(error);
        });
    }
    
})