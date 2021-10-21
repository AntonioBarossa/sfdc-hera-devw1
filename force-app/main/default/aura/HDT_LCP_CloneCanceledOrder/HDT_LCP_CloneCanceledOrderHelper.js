({
    callApexMethod : function(cmp,methodName,params){
		return new Promise($A.getCallback(function(resolve, reject) {
			var action = cmp.get("c."+methodName);
			if (params) action.setParams(params);
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					resolve(response.getReturnValue());
				}
				else
				{
					var error = "";
					var errors = response.getError();
                    console.log(JSON.stringify(errors));
		            if (errors) {
                        if (errors[0]) {
                            if (errors[0].message) {
                                error = errors[0].message;
                            }
                            if (errors[0].pageErrors) {
                                error = errors[0].pageErrors[0].message;
                            }
                        }
	                }
	                reject( error );
				}
			});
			$A.enqueueAction(action);
		}));
	},
    showErrorMessage: function(title,message){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({            
            'title' : title,
            'type': 'error',
            'message' : message
        });
        showToast.fire();
    },
    showWarningMessage: function(title,message){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : title,
            'type': 'warning',
            'message' : message
        });
        showToast.fire();
    },
    showSuccessMessage: function(title,message){
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            'title' : title,
            'type': 'success',
            'message' : message
        });
        showToast.fire();
    },
    openOrderWizard: function(component) {
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
                var orderParentId = res.orderParentId;
                var saleId = res.saleId;
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
                                    "c__ordineVendita": orderParentId
                                }
                            };
        
                            navService.navigate(pageReference);

                        } else {

                            workspaceAPI.getFocusedTabInfo().then(function(response2) {
                                var focusedTabId;
                                if(response2.parentTabId){
                                    console.log("response2.parentTabId", response2.parentTabId);
                                    focusedTabId = response2.parentTabId;
                                }
                                else{
                                    console.log("response2.tabId", response2.tabId);
                                    focusedTabId = response2.tabId;
                                }
                                console.log("openSubtab", focusedTabId);
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
                                    console.log("setTabLabel");
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
