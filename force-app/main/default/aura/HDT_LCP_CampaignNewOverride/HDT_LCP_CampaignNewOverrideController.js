({
    doInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            console.log(focusedTabId);
            component.set('v.tabId', focusedTabId);
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    cancelDialog: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({ tabId: component.get('v.tabId') });
    },

    saveRecord: function (component, event, helper) {
        component.find("newCampaign").handleSubmit();
    },

    afterExecution: function (component, event, helper) {
        console.log("salvato!");
        var workspaceAPI = component.find("workspace");
        var recordId = event.getParam('newRecordId')
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