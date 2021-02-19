({
	doInit : function(component, event, helper) {
        var recordid = component.get("v.pageReference").state.c__recordId;
        component.set('v.recordId', recordid);
	},

    goback : function(component, event, helper) {
        console.log('# close this aura #');
        var prodId = event.getParam('prodId');
        console.log('#  # ' + prodId);
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }

})