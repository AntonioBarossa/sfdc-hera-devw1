({

    init: function (component, event, helper) {
        var action = component.get('c.controllerInitRedirect'); 
        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var self = this;
        var orderId = component.get('v.recordId') ;
        const ntfLib = component.find('notifLib');
        const ntfSvc = component.find('notify');
        
        action.setParams({
            "orderId" : orderId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log("first step");
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var check = res.check;
                var accountid = res.accountId;
                var saleId = res.saleId;
                var macroProcessType = res.macroProcessType;
                var orderParentId = !(saleId || res.orderParent)? orderId : res.orderParent;
                console.log('********'+res);
                if(check){

                    /** HRAWRM-451 - Added check if in Community for redirect 
                     *  Andrei Necsulescu - andrei.necsulescu@webresults.it
                    */
                    var action2 = component.get("c.isCommunity");

                    action2.setCallback(this,function(response2){

                        var res = response2.getReturnValue();

                        if (res.isCommunity) {
                            
                            var pageReference = {
                                type: 'comm__namedPage',
                                attributes: {
                                    name: 'WizardOrder__c',
                                },
                                state: {
                                    "c__venditaId": saleId,
                                    "c__accountId" : accountid,
                                    "c__ordineVendita": orderParentId,
                                    "c__macroProcessType": macroProcessType
                                }
                            };
        
                            navService.navigate(pageReference);

                        } else {

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
                                            "c__ordineVendita": orderParentId,
                                            "c__macroProcessType": macroProcessType
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

                    });
                    $A.enqueueAction(action2); 
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
