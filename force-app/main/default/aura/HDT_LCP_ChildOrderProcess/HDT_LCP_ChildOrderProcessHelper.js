({
    helperInit : function(component,event,helper) {
        console.log('HDT_LCP_ChildOrderProcessHelper.helperInit');
        component.set("v.discardRework", false);
        component.set('v.loading', true);
        try {

            var pageReference = component.get("v.pageReference");
            if (pageReference != null) {

                component.set("v.orderId", pageReference.state.c__orderId);
                component.set("v.orderParentId", pageReference.state.c__orderParent);

                //Gestione Scarti Complessi
                let discardRework = (pageReference.state.c__discardRework === 'true' || pageReference.state.c__discardRework === true)? true : false;
                component.set("v.discardActivityToClose",pageReference.state.c__discardActivityToClose);
                component.set("v.discardRework", discardRework);
                console.log('discardRework: '+discardRework);
                //Fine Gestione Scarti Complessi
                
            }

            /** HRAWRM-451 - Modified parameter extraction method for Community pages 
             *  Andrei Necsulescu - andrei.necsulescu@webresults.it
            */
            if (component.get("v.orderId") == null || component.get("v.orderParentId") == null) {

                var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                tempParam = '';

                console.log('sURLVariables ' + sURLVariables);
                sURLVariables.forEach(element => {
                    tempParam = element.split('=');
                    console.log('element **** ' + element);
                    if (tempParam[0] == 'c__orderId') {
                        component.set("v.orderId", tempParam[1]);
                    }
                    if (tempParam[0] == 'c__orderParent') {
                        component.set("v.orderParentId", tempParam[1]);
                    }

                });

            }

        } catch (error) {
            console.error(error);
        }

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
                    component.set('v.isRepeatedStep',results.stepRepeated);
                    if(ord.RecordType){
                    	component.set("v.recordtypeOrder",ord.RecordType.DeveloperName);
                    }

                    if(results.mainOrderItem){
                        component.set("v.mainOrderItem",results.mainOrderItem);
                    }

                    if(results.analisiConsumi){
                        component.set("v.analisiConsumi",results.analisiConsumi);
                    }
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        
    },

    refreshOrderChild : function (component, event, helper){
        console.log('HDT_LCP_ChildOrderProcessHelper.refreshOrderChild');
        //var action = component.get('c.refreshOrderChild');
        var action = component.get('c.refreshOrderChildAndHistory');
        action.setParams({
            "orderId" : component.get('v.orderId'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.loading', false);
                if (state === "SUCCESS") {                
                    console.log("SUCSSES1",response.getReturnValue());
                    let results = response.getReturnValue();
                    component.set("v.order", results.order);
                    component.set('v.isRepeatedStep',results.stepRepeated);
                    var detailsComp = component.find("detailsComp");
                    detailsComp.loadAccordion();
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
        var checkprocess = component.get("c.isCommunity");
        var navService = component.find("navService");
        console.log('*********check');
        checkprocess.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                let community = response.getReturnValue();
                console.log('*******2:' + JSON.stringify(community));
                if (community != null && community.isCommunity == true) {
                            
                    var pageReference = {
                                    type: 'comm__namedPage',
                                    attributes: {
                                        name: "WizardOrder__c",
                                    },
                                    state: {
                                        "c__accountId": accountId,
                                        "c__venditaId": venditaId
                                    }
                                };
            
                 navService.navigate(pageReference);
                } 
                else{

                    console.log('HDT_LCP_ChildOrderProcessHelper.redirectToComponent');
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

                        $A.get('e.force:refreshView').fire();
                    });
                
                }
            }
        });

        $A.enqueueAction(checkprocess);
                    
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
        
       // })
      /*  .catch(function(error) {
            console.log('******' + error);
        });*/
    },

    redirectToSObjectSubtab : function(component,objectId,objectApiname){
        console.log('HDT_LCP_ChildOrderProcessHelper.redirectToSObjectSubtab');
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
                console.log("refresh", response2);
                workspaceAPI.closeTab({tabId: focusedTab});
                workspaceAPI.refreshTab({
                    tabId: response2,
                    includeAllSubtabs: true
                });
                $A.get('e.force:refreshView').fire();
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