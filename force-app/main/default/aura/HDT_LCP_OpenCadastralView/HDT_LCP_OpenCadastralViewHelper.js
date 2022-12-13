({
    openSubTab: function(component, event, helper) {

        var recordId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");
        console.log('>>recordId', recordId);
        console.log('>>sObjectName', sObjectName);
        var workspaceAPI = component.find("workspace");

        // workspaceAPI.openTab({ url: '/' + recordId })
        //     .then(function(response) {
        
        workspaceAPI.getFocusedTabInfo()
            .then(function(response) {
                let parentTabId = response.isSubtab ? response.parentTabId : response.tabId
                workspaceAPI.openSubtab({
                    parentTabId: parentTabId,
                    pageReference: {
                        type: 'standard__component',
                        attributes: { componentName: 'c__HDT_LCP_OpenCadastralViewLwc' },
                        state: { c__recordid: recordId, c__sobjecttype: sObjectName, c__tab: 'VDC' }
                    }
                    })
                    .then(function(subtabId) {
                        workspaceAPI.setTabLabel({ tabId: subtabId, label: 'Dati Catastali' });
                        workspaceAPI.setTabIcon({ tabId: subtabId, icon: 'custom:custom83', iconAlt: 'Vista Dati Catastali' });
                        $A.get("e.force:closeQuickAction").fire();
                    });
            })
            .catch(function(error) {
                console.log(error);
            });
    }
})
