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
                        componentName: 'c__HDT_LCP_ViewLwcSubTab'
                    },
                    state: {
                        c__recordid: accountId,
                        c__type: 'socialBonus'
                    }
				}
            });

            workspaceAPI.setTabLabel({
                tabId: i,
                label: 'Bonus sociale'
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