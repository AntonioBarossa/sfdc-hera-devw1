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
                var msg = 'Non puoi riprendere una vendità conclusa';
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
                label: "Vendite"
            });
           
        })
        .catch(function(error) {
            console.log(error);
        });
        })
        .catch(function(error) {
            console.log(error);
        });
                /*var pageReference = {
                    //type: 'standard__component',
                    type: 'standard__navItemPage',
                    attributes: {
                       // componentName: 'c:HDT_LCP_venditaContainer',
                       apiName: 'Vendite'
                    },
                    state: {
                        "c__accountId": component.get("v.recordId"),
                        "c__venditeId" : response.getReturnValue().Id
                    }
                };
       			navService.navigate(pageReference);*/
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

	
	/* 	$A.get("e.force:closeQuickAction").fire();
      	var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:HDT_LCP_Container",
            componentAttributes: {
                recId:  component.get("v.recordId")

            }
        });
        evt.fire(); */

   /*     var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Account/0019E00001BGYGJQA5/view',
            //url: 'lightning/cmp/HDT_LCP_WizardProcessoVendita/',
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
          //  console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
                console.log(error);
        });
    }*/
    }
})
