({

    initHelper: function(component, event, helper){
        var myPageRef = component.get("v.pageReference");
        var activityId = myPageRef.state.c__activityid;
        component.set("v.activityid", activityId);
        console.log('>>> activityId ' + activityId);
        this.setDefaultRequestObj(component, event, helper);
    },

    helperOpenSubTab: function(component, event, helper){
        console.log('Avviata apertura');
        var accountId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");
        var myPageRef = component.get("v.pageReference");
        var defaultRequestObj = component.get("v.defaultRequestObj");
        
        var tab = 'EC';
        if(myPageRef != null && myPageRef.state.c__accountid != null){
            accountId = myPageRef.state.c__accountid;
        }
        if(myPageRef != null && myPageRef.state.c__tab != null){
            tab = myPageRef.state.c__tab;
        }

        console.log('>>> accountId ' + accountId);
        console.log('>>> tab ' + tab);

        var tabToClose;
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log('# TabId To Close: ' + tabId);
            tabToClose = tabId;
        }).catch(function(error) {
            console.log(error);
        });

        workspaceAPI.getFocusedTabInfo().then(function(responseFocus) {
            console.log('Tab1 ' + responseFocus.pageReference.attributes.objectApiName);
            workspaceAPI.openTab({
                url: '/' + accountId
            }).then(function(response) {
                var i = workspaceAPI.openSubtab({
                    parentTabId: response,
                    focus:false,
                    pageReference: {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c__HDT_LCP_AcctStmtOpenLwc'
                        },
                        state: {
                            c__recordid: accountId,
                            c__tab: tab,
                            c__defaultRequestObj: defaultRequestObj
                        }
                    }
                });

                workspaceAPI.setTabLabel({
                    tabId: i,
                    label: 'Estratto conto'
                });
                workspaceAPI.setTabIcon({
                    tabId: i,
                    icon: 'custom:custom83'
                });
                workspaceAPI.closeTab({tabId: tabToClose});
                workspaceAPI.focusTab({tabId: i});
                
            })
            .catch(function(error) {
                console.log(error);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    setDefaultRequestObj: function(component, event, helper) {
		console.log('# open from quick action #');

		var activityId = component.get('v.activityid');

		console.log('# activityId from quick action > ' + activityId);

        var action = component.get("c.buildDefaultRequest");
        action.setParams({
            activityId: activityId
        });

        action.setCallback(this, function (response) {
            var returnObj = response.getReturnValue();
            console.log('>>> returnObj ' + returnObj);
            component.set("v.defaultRequestObj", returnObj);
            this.helperOpenSubTab(component, event, helper);

        });
        $A.enqueueAction(action);
    }
})
