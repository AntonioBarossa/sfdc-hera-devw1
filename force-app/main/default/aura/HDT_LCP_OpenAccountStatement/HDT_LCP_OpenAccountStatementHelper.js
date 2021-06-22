({

    openSubTab: function(component, event, helper) {

        var accountId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({
            url: '/' + accountId
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_AcctStmtOpenLwc'
                    },
                    state: {
                        c__recordid: accountId,
                        c__tab: 'EC'
                    }
                }
            }).then(function(subtabId) {

                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: 'Estratto conto'
                });
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: 'custom:custom83',
                    iconAlt: 'Estratto conto'
                });
                $A.get("e.force:closeQuickAction").fire();
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }

})