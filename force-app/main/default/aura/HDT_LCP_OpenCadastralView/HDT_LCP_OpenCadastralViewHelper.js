({
    openSubTab: function(component, event, helper) {

        var recordId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({ url: '/' + recordId })
            .then(function(response) {
                workspaceAPI.openSubtab({
                    parentTabId: response,
                    pageReference: {
                        type: 'standard__component',
                        attributes: { componentName: 'c__HDT_LCP_OpenCadastralViewLwc' },
                        state: { c__recordid: recordId, c__tab: 'VDC' }
                    }
                })
                    .then(function(subtabId) {
                        workspaceAPI.setTabLabel({ tabId: subtabId, label: 'Vista Dati Catastali' });
                        workspaceAPI.setTabIcon({ tabId: subtabId, icon: 'custom:custom83', iconAlt: 'Vista Dati Catastali' });
                        $A.get("e.force:closeQuickAction").fire();
                    });
            })
            .catch(function(error) {
                console.log(error);
            });
    }
})
