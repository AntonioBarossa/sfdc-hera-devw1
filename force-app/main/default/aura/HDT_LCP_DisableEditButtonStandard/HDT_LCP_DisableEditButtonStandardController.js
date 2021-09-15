({
    doInit: function (component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "error",
            "title": "Errore",
            "message": "Attenzione, non è possibile modificare record da questa vista",
            "mode": "sticky"
        });

        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId}
            ).catch(function (error) {
                console.log(error);
            }
            );
        })
        .catch(function(error) {
            console.log(error);
        });

    }
})