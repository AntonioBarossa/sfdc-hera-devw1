({
    doInit: function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(responseFocus) {
            workspaceAPI.isSubtab({
                tabId: responseFocus.tabId
            }).then(function(response) {
                if (response) {
                    
                }else if(responseFocus != undefined){
                    var focusedTabId = responseFocus.tabId;
                    var objectInfo = responseFocus.pageReference.attributes.objectApiName;
                    console.log('# focusedTabId ' + focusedTabId + ' objectInfo ' + objectInfo);
                    var action = component.get("c.getCase");
                    var caseId = component.get("v.recordId");
                    if(objectInfo != undefined && objectInfo =="Case"){
                        action.setParams({ caseId : caseId });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                let res = response.getReturnValue();
                                console.log('# Res: ' + res);
                                if(res.Lead != null){
                                    var leadId = res.Lead;
                                    console.log('# LeadId: ' + leadId);
                                    workspaceAPI.openTab({
                                        recordId: leadId,
                                        focus: false
                                    }).then(function(responseOpen) {
                                        console.log('# Response open ' + responseOpen);
                                        workspaceAPI.openSubtab({
                                            parentTabId: responseOpen,
                                            recordId: caseId,
                                            focus: true
                                        }).then (function(responseOpenSub) {
                                                workspaceAPI.closeTab({tabId: focusedTabId})
                                                .catch(function(error) {
                                                    console.log(error);}
                                                );
                                        });
                                    })
                                    .catch(function(error) {
                                            console.log(error);
                                    });
                                }
                            }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + 
                                                errors[0].message);
                                    }
                                } else {
                                    console.log("Unknown error");
                                }
                            }
                        });
                        $A.enqueueAction(action);
                    }
                }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})