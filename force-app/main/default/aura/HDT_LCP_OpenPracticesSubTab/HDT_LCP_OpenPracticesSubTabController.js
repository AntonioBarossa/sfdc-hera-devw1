({
    openTabWithSubtab : function(component, event, helper) {

        var accountId = component.get("v.recordId");     
        var workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({
            url: '/' + accountId
        }).then(function(response) {
            var i = workspaceAPI.openSubtab({
                parentTabId: response,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_OpenPracticesLwc'
                    },
                    state: {
                        c__recordid: accountId,
                        c__type: 'vasPractices'
                    }
				}
            });

            workspaceAPI.setTabLabel({
                tabId: i,
                label: 'Pratiche VAS'
            });
            workspaceAPI.setTabIcon({
                tabId: i,
                icon: 'custom:custom83'
            });
            $A.get("e.force:closeQuickAction").fire();
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})