({
    doInit: function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(responseFocus) {
            workspaceAPI.isSubtab({
                tabId: responseFocus.tabId
            }).then(function(response) {
                if (response) {
                    var focusedTabId = responseFocus.tabId;
                    var parentTabId = responseFocus.parentTabId;
                    var objectInfo = responseFocus.pageReference.attributes.objectApiName;
                    var recordId = responseFocus.pageReference.attributes.recordId;
                    workspaceAPI.getTabInfo({
                        tabId: parentTabId
                    }).then(function(responseTabInfo) {
                        var parentRecordId = responseTabInfo.pageReference.attributes.recordId;
                        if(objectInfo == 'Account'){
                            console.log(recordId);
                            workspaceAPI.openTab({
                                recordId: recordId,
                                focus: true
                            }).then(function(responseOpen) {
                                workspaceAPI.openSubtab({
                                    parentTabId: responseOpen,
                                    recordId: parentRecordId,
                                    focus: false
                                }).then (function(responseOpenSub) {
                                        workspaceAPI.closeTab({tabId: parentTabId})
                                        .catch(function(error) {
                                            console.log(error);}
                                        );
                                });
                            })
                            .catch(function(error) {
                                    console.log(error);
                            });
                        }
                    });
                }else{
                    
                }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})