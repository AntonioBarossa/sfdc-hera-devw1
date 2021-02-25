({
    helperInit : function(component,event,helper) {
        component.set('v.loading', true);
        var pageReference = component.get("v.pageReference");
        component.set("v.orderId", pageReference.state.c__orderId);
        component.set("v.orderParentId", pageReference.state.c__orderParent);

        var action = component.get('c.controllerInit');
        var orderId = component.get('v.orderId');
        action.setParams({
            "orderId" : orderId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.loading', false);
                if (state === "SUCCESS") {                
                    console.log("SUCSSES1",response.getReturnValue());
                    let results = response.getReturnValue();
                    let ord = results.order;
                    component.set("v.order", results.order);
                    let orderItem = results.orderItem;
                    if(orderItem && orderItem.Service_Point__c !== undefined) {
                        component.set('v.orderPod',orderItem.Service_Point__r.ServicePointCode__c);
                    }
                    component.set("v.ordername", ord.Name);
                    component.set("v.orderstatus",ord.Status);
                    component.set('v.accountId',results.accountId);
                    component.set('v.venditaId',results.venditaId);
                    if(ord.RecordType){
                    	component.set("v.recordtypeOrder",ord.RecordType.DeveloperName);
                    }
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        
    },

    refreshOrderChild : function (component, event, helper){
        var action = component.get('c.refreshOrderChild');
        action.setParams({
            "orderId" : component.get('v.orderId'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.loading', false);
                if (state === "SUCCESS") {                
                    console.log("SUCSSES1",response.getReturnValue());
                    let result = response.getReturnValue();
                    component.set("v.order", result);
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
    },
    
    setCheckbox : function (component, event, helper){
        var processo = component.get("v.selectedValue");
        if(processo == "Prima Attivazione")
        {
        	component.set('v.precheck','KO');
            component.set('v.compatibilita','OK'); 
            component.set('v.causale',"E' necessario effettuare un subentro");
        }
        else if(processo == 'Subentro')
        {
            component.set('v.precheck','OK');
            component.set('v.compatibilita','OK');
            component.set('v.causale',"");
        }
    },

    saveOp : function (component, event, helper){
        var action = component.get('c.saveOption');
        var orderId = component.get('v.orderId');
        var processo = component.get('v.selectedValue');
        var parentOrderId = component.get('v.parentOrderId');
        console.log("*****Processo: " + processo);
        // action.setParams({
        //     "orderId" : orderId,
        //     "processo" : processo,
        //     "parentOrderId" : parentOrderId
        // });
        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //         if (state === "SUCCESS") {                
        //              $A.get('e.force:refreshView').fire();
        //         }
        //         else {
        //             console.log("Failed with state: " + state);
        //         }
        //     });
        // $A.enqueueAction(action);
    },

    redirectToComponent : function(component,accountId,venditaId,orderParent){
        var workspaceAPI = component.find("workspace");
        console.log("Begin Redirect");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log("Begin Redirect_2_: " + JSON.stringify(response));
            var focusedTabId = response.parentTabId;
            var focusedTab = response.tabId;

            //INIZIO SVILUPPI EVERIS

            workspaceAPI.closeTab({tabId: focusedTab}).then(function(){

                $A.get('e.force:refreshView').fire();
           
            });

            
            
            /*workspaceAPI.openSubtab({//Subtab({ NON SEMBRA ESSERE NECESSARIO APRIRE UN NUOVO TAB
                parentTabId: focusedTabId,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: "c__HDT_LCP_OrderDossierWizard"
                    },
                    state: {
                        c__accountId: accountId,
                        c__venditaId: venditaId,
                        c__orderParent: orderParent
                    }
                },
                focus: true
            }).then(function(response2){
                workspaceAPI.closeTab({tabId: focusedTab});
            })
            .catch(function(error) {
                console.log('******' + error);
            });*/

            //FINE SVILUPPI EVERIS
        
        })
        .catch(function(error) {
            console.log('******' + error);
        });
    },

    redirectToSObjectSubtab : function(component,objectId,objectApiname){
        var workspaceAPI = component.find("workspace");
        console.log("Begin Redirect");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log("Begin Redirect_2_: " + JSON.stringify(response));
            var focusedTabId = response.parentTabId;
            var focusedTab = response.tabId;
            
            console.log("Begin Redirect_3_: " + focusedTabId);
            console.log("Begin Redirect_4_: " + objectId);
            console.log("Begin Redirect_5_: " + objectApiname);
            
            workspaceAPI.openTab({//Subtab({
                parentTabId: focusedTabId,
                pageReference: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: objectId,
                        objectApiName: objectApiname,
                        actionName : 'view'
                    }
                },
                focus: true
            }).then(function(response2){
                workspaceAPI.closeTab({tabId: focusedTab});
            })
            .catch(function(error) {
                console.log('******' + error);
            });
        
        })
        .catch(function(error) {
            console.log('******' + error);
        });
    }
})
