({
    doInit: function (component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "error",
            "title": "Errore",
            "message": "Attenzione, non è possibile creare record da questa vista",
            "mode": "sticky"
        });
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (responseFocus) {
            var focusedTabId = responseFocus.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId })
                .catch(function (error) {
                    console.log(error);
                }
                );
        }).catch(function (error) {
                console.log(error);
        });
        /*var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": component.get("v.sObjectName")
        });
        homeEvt.fire();*/
    }
})