({
    openTabWithSubtabHelp : function(component, event, helper) {

        var accountId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");

        $A.get("e.force:closeQuickAction").fire();

        workspaceAPI.openTab({
            url: '/' + accountId
        }).then(function(response) {
            var i = workspaceAPI.openSubtab({
                parentTabId: response,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_ViewLwcSubTab'
                    },
                    state: {
                        c__recordid: accountId,
                        c__type: 'cmor'
                    }
				}
            });

            workspaceAPI.setTabLabel({
                tabId: i,
                label: 'CMOR'
            });
            workspaceAPI.setTabIcon({
                tabId: i,
                icon: 'custom:custom83'
            });
            
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})
