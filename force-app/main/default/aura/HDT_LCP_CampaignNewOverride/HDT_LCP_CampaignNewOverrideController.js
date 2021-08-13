({
    doInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            console.log('nel init ' + focusedTabId);
            component.set('v.tabId', focusedTabId);
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    cancelDialog: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        
        if (event == null) {

            workspaceAPI.closeTab({ tabId: component.get('v.tabId') });

        } else {

            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });

        }
    },

    saveRecord: function (component, event, helper) {
        component.find("newCampaign").handleSubmit();
    },

    afterExecution: function (component, event, helper) {

        console.log("salvato!");

        var workspaceAPI = component.find("workspace");
        var recordId = event.getParam('newRecordId');

        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            component.set('v.tabId', focusedTabId);
        });

        workspaceAPI.openTab({
            recordId: recordId,
            focus: true
        }).then(function (response) {
            //close the tab
            $A.enqueueAction(component.get('c.cancelDialog'));
        }).catch(function (error) {
            console.log(error);
        });
    }
})