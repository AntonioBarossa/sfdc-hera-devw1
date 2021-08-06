({
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        if(pageReference != null && pageReference.state !== null && pageReference.state.c__caseId !== null){
           component.set("v.recordId", pageReference.state.c__caseId);
        }
        component.set("v.showComp",true);
    },

    closeTabMain : function(component, event, helper) {
        console.log("PROVAILLIGHTNING");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
    }
})
