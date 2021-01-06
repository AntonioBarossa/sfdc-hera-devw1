({
    helperInitRedirect : function(component,event,helper) {
		var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var self = this;
		var action = component.get('c.controllerInit');
        action.setParams({'saleId' : component.get('v.recordId')});
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("first step");
            console.log('state: ' + state);
            if (state === "SUCCESS") {
                var res = response.getReturnValue();

                console.log('res: '+ JSON.stringify(res));

                var check = res.check;
                var accountid = res.accountId;
                var orderParent = res.orderParent;
                if(check){
                    workspaceAPI.getFocusedTabInfo().then(function(response2) {
                        var focusedTabId;
                        if(response2.parentTabId){
                            focusedTabId = response2.parentTabId;
                        }
                        else{
                        	focusedTabId = response2.tabId;
                        }
                            // /lightning/cmp/HDT_LCP_OrderDossierWizard' Component Wizard Action From Order;
                        workspaceAPI.openSubtab({
                            parentTabId: focusedTabId,
                            pageReference: {
                                type: 'standard__component',
                                attributes: {
                                    componentName: 'c:HDT_LCP_OrderDossierWizard',
                                },
                                state: {
                                    "c__orderParent": orderParent,
                                    "c__accountId" : accountid
                                }
                            },
                            focus: true
                        }).then(function(response2) {
                            workspaceAPI.setTabLabel({
                                tabId: response2,
                                label: "Wizard Processi"
                            });
                            
                        })
                        .catch(function(error) {
                            console.log('******' + error);
                        });
                    })
                    .catch(function(error) {
                        console.log('******' + error);
                    });
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Errore!",
                        "message": "La Vendita Non Risulta Attiva",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
	}
})
