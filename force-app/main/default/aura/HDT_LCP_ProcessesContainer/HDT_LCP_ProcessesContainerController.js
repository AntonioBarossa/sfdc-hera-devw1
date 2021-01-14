({

    init: function (component, event, helper) {
        var action = component.get('c.controllerInitRedirect'); 
        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var self = this;
        var orderParentId = component.get('v.recordId') ;
        const ntfLib = component.find('notifLib');
        const ntfSvc = component.find('notify');
        
        action.setParams({
            "orderParentId" : orderParentId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("first step");
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var check = res.check;
                var accountid = res.accountId;
                var orderParentId = res.orderParentId;
                var saleId = res.saleId;
                console.log('********'+res);
                if(check){
                    workspaceAPI.getFocusedTabInfo().then(function(response2) {
                        var focusedTabId;
                        if(response2.parentTabId){
                            focusedTabId = response2.parentTabId;
                        }
                        else{
                            focusedTabId = response2.tabId;
                        }
                        // /lightning/cmp/HDT_LCP_WizardProcessi' Component Wizard Action From Order;
                        workspaceAPI.openSubtab({
                            parentTabId: focusedTabId,
                            pageReference: {
                                type: 'standard__component',
                                attributes: {
                                    componentName: 'c:HDT_LCP_OrderDossierWizard',
                                },
                                state: {
                                    "c__venditaId": saleId,
                                    "c__accountId" : accountid,
                                    "c__ordineVendita": orderParentId
                                }
                            },
                            focus: true
                        }).then(function(response2) {
                            workspaceAPI.setTabLabel({
                                tabId: response2,
                                label: "Wizard Ordine"
                            });
                            
                        })
                        .catch(function(error) {
                            console.log('******' + error);
                        });
                    })
                    .catch(function(error) {
                        console.log('******' + error);
                    });
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Errore!",
                        "message": "Non è possibile riprendere il processo poiché risulta Concluso.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }}
        });
        $A.enqueueAction(action);   
    }
})
