({
    openTabWithSubtab : function(component, event, helper) {
        //console.log('# openTabWithSubtab # ');

        var accountId = component.get("v.recordId");
        //console.log('# accountId # ' + accountId);
        
        var workspaceAPI = component.find("workspace");
        //console.log('# workspaceAPI loaded # ');
        
        //workspaceAPI.getAllTabInfo().then(function(response) {
        //    //console.log('--> ' + response[0].tabId);
        //    //console.log('--> ' + response[0].subtabs[0].tabId);
        //})
        //.catch(function(error) {
        //    console.log(error);
        //});

        workspaceAPI.openTab({
            //url: '/lightning/r/Account/' + accountId + '/view'
            url: '/' + accountId
        }).then(function(response) {
            var i = workspaceAPI.openSubtab({
                parentTabId: response,
                //url: '/lightning/n/Estratto_Conto'
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
            $A.get("e.force:closeQuickAction").fire();
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})