({
    redirectToSObjectSubtab : function(component,objectId,objectApiname){
        var workspaceAPI = component.find("workspace");
        console.log("Begin Redirect");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log("Begin Redirect_2_: " + JSON.stringify(response));
            var focusedTabId = response.parentTabId;
            var focusedTab = response.tabId;
            
            console.log("Begin Redirect_3_: " + focusedTabId);
            console.log("Begin Redirect_4_: " + objectId);
            console.log("Begin Redirect_5_: " + objectApiname);
            
            workspaceAPI.openTab({//Subtab({
                parentTabId: focusedTabId,
                pageReference: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: objectId,
                        objectApiName: objectApiname,
                        actionName : 'view'
                    }
                },
                focus: true
            }).then(function(response2){
                workspaceAPI.closeTab({tabId: focusedTab});
                $A.get('e.force:refreshView').fire();
            })
            .catch(function(error) {
                console.log('******' + error);
            });
        
        })
        .catch(function(error) {
            console.log('******' + error);
        });
    }
})
