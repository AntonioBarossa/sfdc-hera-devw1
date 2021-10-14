({
    init: function (component, event, helper) {
        var action = component.get('c.loadCase'); 
        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var self = this;
        var caseId = component.get('v.recordId') ;
        const ntfLib = component.find('notifLib');
        const ntfSvc = component.find('notify');

        action.setParams({
            "id" : caseId
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
            console.log("SUCSSES");
            if (state === "SUCCESS") {

                let results = response.getReturnValue();
                
                console.log("SUCSSES1",response.getReturnValue());
                var status = results.case.Status;
                var workspaceAPI = component.find("workspace");
                var phase = results.case.Phase__c;
                console.log('status ==='+ status);

                var msg = 'Non è possibile riprendere il processo poiché risulta Conclusa!';
                var msg2= 'Non è possibile riprendere il processo poiché risulta gia in lavorazione!';
                var msg3= 'Processo in attesa di approvazione!';

                if (status == 'Closed') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg ,
                        "type": "error"
                    });
                    toastEvent.fire();
                    return;
                } else if(phase == 'In Attesa Approvazione') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg3 ,
                        "type": "error"
                    });
                    toastEvent.fire();
                    return;
                }/*else if(phase == 'In Lavorazione'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg2 ,
                        "type": "error"
                    });
                    toastEvent.fire();
                    return;
                }*/else{
                        if(results.case.Type == 'Documentale/Copia Contratto'){
                            workspaceAPI.getFocusedTabInfo().then(function(response2) {

                                var focusedTabId = response2.tabId;
                                console.log('focusedTabId=='+focusedTabId);
                                workspaceAPI.openSubtab({
                                    parentTabId: focusedTabId,
                                    pageReference: {
                                        type: 'standard__component',
                                        
                                        attributes: {
                                        componentName: 'c:HDT_LCP_CopiaContratto',
                                
                                        },
                                        state: {
                                            "c__caseId": caseId
                                        }
                                    },
                                    focus: true
                                }).then(function(response3) {
                                    workspaceAPI.setTabLabel({
                                    tabId: response3,
                                    label: "Copia Contratto"
                                });
                        
                                })
                                .catch(function(error) {
                                    console.log(error);
                                });
    
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        }else{
                            workspaceAPI.getFocusedTabInfo().then(function(response2) {

                                var focusedTabId = response2.tabId;
                                console.log('focusedTabId=='+focusedTabId);
                                workspaceAPI.openSubtab({
                                    parentTabId: focusedTabId,
                                    pageReference: {
                                        type: 'standard__component',
                                        
                                        attributes: {
                                        componentName: 'c:HDT_LCP_RecordEditFormFlowSales',
                                
                                        },
                                        state: {
                                            "c__caseId": caseId
                                        }
                                    },
                                    focus: true
                                }).then(function(response3) {
                                    workspaceAPI.setTabLabel({
                                    tabId: response3,
                                    label: "Contratti Bonus Commerciale"
                                });
                        
                                })
                                .catch(function(error) {
                                    console.log(error);
                                });
    
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        }
                }
               
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    }
})
