({
    finishFlow : function(component, newCaseId) 
    {
        	console.log("Inside Helper");
        	
        	var workspaceAPI = component.find("workspace");
        	var accountTabId = component.get("v.accountTabId");
            var leadTabId = component.get("v.leadTabId");
            var interactionTabId = component.get("v.interactionTabId");
            var subTabToClose = component.get("v.subTabToClose");
            var enableRefresh = component.get('v.enableRefresh');

            console.log('# Refresh page -> ' + enableRefresh);
            console.log('# close -> ' + subTabToClose + ' - refresh -> ' + accountTabId);
            //console.log('# outputVariable -> '+outputVariables);
            console.log('# newCaseId -> '+newCaseId);
        	
        	console.log('HELPER_FIRST_CONDITION');
        	if(newCaseId == null || newCaseId == undefined){
                console.log('HELPER_INSIDE_FIRST_CONDITION');
                workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
                    console.log('# Refresh page -> ' + enableRefresh);
                    
                    console.log('# OK Refresh page #');
                    $A.get('e.force:refreshView').fire();
                
                    if(accountTabId != null){
                        workspaceAPI.focusTab({tabId : accountTabId}).
                        then(function(response) {
                            workspaceAPI.refreshTab({
                                    tabId: accountTabId,
                                    includeAllSubtabs: true
                                }).catch(function(error) {
                                    console.log(error);
                                });
                        });
                    } else if(leadTabId != null){
                        workspaceAPI.focusTab({tabId : leadTabId}).
                        then(function(response) {
                            workspaceAPI.refreshTab({
                                    tabId: leadTabId,
                                    includeAllSubtabs: true
                                }).catch(function(error) {
                                    console.log(error);
                                });
                        });
                    } else if(interactionTabId != null){
                        workspaceAPI.focusTab({tabId : interactionTabId}).
                        then(function(response) {
                            workspaceAPI.refreshTab({
                                    tabId: interactionTabId,
                                    includeAllSubtabs: true
                                }).catch(function(error) {
                                    console.log(error);
                                });
                        });
                    }

                }).catch(function(error) {
                    console.log(error);
                });

                return;
            }
        	console.log('HELPER_SECOND_CONDITION');
            if(!enableRefresh && (accountTabId != null || leadTabId != null)){
                var parentTabId = accountTabId != null ? accountTabId : leadTabId;
                workspaceAPI.openSubtab({
                    parentTabId: parentTabId,
                    pageReference: {
                        type: "standard__recordPage",
                        attributes: {
                            recordId: newCaseId,
                            objectApiName: "Case",
                            actionName: "view"
                        }
                    },
                    focus: true
                }).then(function(response){

                    workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
                        console.log('# Refresh page -> ' + enableRefresh);
                        console.log('# OK Refresh page #');
                        $A.get('e.force:refreshView').fire();
                        
        
                        //workspaceAPI.focusTab({tabId : subTabToRefresh}).then(function(response) {
                        //    workspaceAPI.refreshTab({
                        //        tabId: subTabToRefresh,
                        //        includeAllSubtabs: true
                        //    }).catch(function(error) {
                        //        console.log(error);
                        //    });
                        //});
        
                        }).catch(function(error) {
                            console.log(error);
                        });
                    });
            }else{

                workspaceAPI.focusTab({
                    pageReference: {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: newCaseId,
                        objectApiName: "Case",
                        actionName: "view"
                    }
                },
                focus: true
                })
                .then(function(response) {
                    workspaceAPI.closeTab({ tabId: subTabToClose}).then(function(response){
                        console.log('# Refresh page -> ' + enableRefresh);
                        
                        console.log('# OK Refresh page #');
                        $A.get('e.force:refreshView').fire();
                    }).catch(function(error){
                        console.log(error);
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });


                /*workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
                        console.log('# Refresh page -> ' + enableRefresh);
                        
                        console.log('# OK Refresh page #');
                        $A.get('e.force:refreshView').fire();
                    
        
                        workspaceAPI.focusTab({tabId : subTabToRefresh}).then(function(response) {
                        workspaceAPI.refreshTab({
                                tabId: subTabToRefresh,
                                includeAllSubtabs: true
                            }).catch(function(error) {
                                console.log(error);
                            });
                        });
        
                }).catch(function(error) {
                    console.log(error);
                });*/

            }        
        
    }
})