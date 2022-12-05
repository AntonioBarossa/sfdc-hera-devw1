({
    openTabWithSubtab : function(component, event, helper) {
        
        var accountId = component.get("v.accountId");
        var workspaceAPI = component.find("workspace");

        console.log('>>> accountId ' + accountId);

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
                       c__type: 'odlAdsView'
                   }
				}
           });

           workspaceAPI.setTabLabel({
               tabId: i,
               label: 'Vista ODL e ADS'
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
    },

    setAccountId : function(component, event, helper) {

        var action = component.get("c.getAccountDetail");
        action.setParams({
            "recordId": component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var accountId = response.getReturnValue();
                component.set("v.accountId", accountId);
                helper.openTabWithSubtab(component, event, helper);
            } else {
                console.error("getCaseData ERROR");
                console.error(JSON.stringify(response) + " <== response");
            }
        });
        $A.enqueueAction(action);
    }
})