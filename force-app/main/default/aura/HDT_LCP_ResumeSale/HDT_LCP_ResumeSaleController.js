({
    init: function (component, event, helper) {
        var action = component.get('c.loadVendite'); 
        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var self = this;
        var venditeId = component.get('v.recordId') ;
        const ntfLib = component.find('notifLib');
        const ntfSvc = component.find('notify');

        action.setParams({
            "id" : venditeId
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
            console.log("SUCSSES");
            if (state === "SUCCESS") {
                
                console.log("SUCSSES1",response.getReturnValue());
                var accountId = response.getReturnValue().Account__c;
                var workspaceAPI = component.find("workspace");
                var status = response.getReturnValue().Status__c;
                console.log('status==='+status);
                var msg = 'Non è possibile riprendere la vendita poiché risulta Conclusa!';
                if (status !== 'Bozza') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg ,
                        "type": "error"
                    });
                    toastEvent.fire();
                    return;
                }
               
        workspaceAPI.getFocusedTabInfo().then(function(response2) {

            var focusedTabId = response2.tabId;
            console.log('focusedTabId=='+focusedTabId);
            console.log('saleId=='+venditeId);
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                pageReference: {
                    type: 'standard__component',
                    
                    attributes: {
                       componentName: 'c:HDT_LCP_sellingWizard',
             
                    },
                    state: {
                        "c__accountId": accountId,
                        "c__saleId" : venditeId

                    }
                },
                focus: true
            }).then(function(response3) {
                workspaceAPI.setTabLabel({
                tabId: response3,
                label: "Wizard Vendita"
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
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    }
})
