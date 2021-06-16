({
    closeTabMain : function(component, event, helper) {
        console.log("PROVAILLIGHTNING");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
    }
})
