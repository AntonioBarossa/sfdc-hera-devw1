({
    openTabWithSubtab : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var accountId = component.get("v.accountId");
        var workspaceAPI = component.find("workspace");

        console.log('>>> accountId ' + accountId);
        console.log('>>> recordId ' + recordId);

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
                       c__type: 'gaaView',
                       c__relatedtoid: recordId
                   }
				}
           });

           workspaceAPI.setTabLabel({
               tabId: i,
               label: 'Vista GAA'
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
