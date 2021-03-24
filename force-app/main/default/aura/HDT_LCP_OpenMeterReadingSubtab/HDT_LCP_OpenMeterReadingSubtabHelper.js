({

    openTabWithSubtab : function(component, event, helper) {
        console.log('# openTabWithSubtab # ');
        
        var accountId = component.get("v.recordId");
        console.log('# accountId # ' + accountId);
        
        var workspaceAPI = component.find("workspace");
        console.log('# workspaceAPI loaded # ');
        
        var allTabIds = [];
        workspaceAPI.getAllTabInfo().then(function(response) {
            allTabIds = this.allTab(component, event, helper, response)
        })
        .catch(function(error) {
            console.log(error);
        });

        console.log('### open tabs -> '  + allTabIds.length);

        workspaceAPI.openTab({
            url: '/' + accountId
        }).then(function(response) {
            console.log('## here ##');
            var i = workspaceAPI.openSubtab({
                parentTabId: response,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_OpenMeterReadingLwc'
                    },
                    state: {
                        c__recordid: accountId
                    }
				}
            });

            workspaceAPI.setTabLabel({
                tabId: i,
                label: 'Letture'
            });
            workspaceAPI.setTabIcon({
                tabId: i,
                icon: 'custom:custom97'
            });
            $A.get("e.force:closeQuickAction").fire();
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    allTab: function(component, event, helper, response) {
        var tabIds = [];
        var i;
        
        for (i = 0; i < response.length; i++) {
            console.log('# tab N° ' + (i+1));
            console.log('-> ' + response[i].tabId + ' # ' + response[i].title);
            
            var n;
            for (n = 0; n < response[i].subtabs.length; n++) {
                console.log('# sub tab N° ' + (n+1));
                console.log('# ' + response[i].subtabs[n].tabId + '# ' + response[i].subtabs[n].title);
                tabIds.push(response[i].tabId);
            }
        }
        //console.log('### open tabs -> '  + tabIds.length);
        return tabIds;
    }
})