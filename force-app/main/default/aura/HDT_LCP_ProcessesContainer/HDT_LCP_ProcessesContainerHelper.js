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
                // var check = res.check;
                // var accountid = res.accountId;
                // var ordineVendita = res.ordineVendita;
                console.log('res: '+ JSON.stringify(res));
                // if(check){
                //     workspaceAPI.getFocusedTabInfo().then(function(response2) {
                //         var focusedTabId;
                //         if(response2.parentTabId){
                //             focusedTabId = response2.parentTabId;
                //         }
                //         else{
                //         	focusedTabId = response2.tabId;
                //         }
                //             // /lightning/cmp/HDT_LCP_WizardProcessi' Component Wizard Action From Order;
                //         workspaceAPI.openSubtab({
                //             parentTabId: focusedTabId,
                //             pageReference: {
                //                 type: 'standard__component',
                //                 attributes: {
                //                     componentName: 'c:HDT_LCP_WizardProcessi',
                //                 },
                //                 state: {
                //                     "c__ordineVendita": ordineVendita,
                //                     "c__accountId" : accountid
                //                 }
                //             },
                //             focus: true
                //         }).then(function(response2) {
                //             workspaceAPI.setTabLabel({
                //                 tabId: response2,
                //                 label: "Wizard Processi"
                //             });
                            
                //         })
                //         .catch(function(error) {
                //             console.log('******' + error);
                //         });
                //     })
                //     .catch(function(error) {
                //         console.log('******' + error);
                //     });
                // }
            //     else{
            //         var toastEvent = $A.get("e.force:showToast");
            //         toastEvent.setParams({
            //             "title": "Errore!",
            //             "message": "La Vendita Non Risulta Attiva",
            //             "type": "error"
            //         });
            //         toastEvent.fire();
            //     }
            }
        });
        $A.enqueueAction(action);   
	}
})
