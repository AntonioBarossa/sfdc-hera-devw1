({
    helperInit : function(component,event,helper,saleId,accountId) {
		var action = component.get('c.controllerInit');
        action.setParams({
            "saleId" : saleId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {

                    let results = response.getReturnValue();
                    
        			component.set("v.parentOrderName", results.orderParentName);
                    component.set("v.orderParentId", results.orderParent);
                    component.set("v.orderParentRecord", results.orderParentRecord);
                    component.set("v.accountId", results.accountId);
                    component.set("v.check", results.check);

                    var myPageRef = component.get("v.pageReference");
                    var newState = Object.assign({}, myPageRef.state, {c__accountId: results.accountId, c__venditaId: saleId, c__orderParent: results.orderParent});
                    component.find("navService").navigate({
                        type: myPageRef.type,
                        attributes: myPageRef.attributes,
                        state: newState
                    });

                    // component.set("v.accountName", results.accountName); // component.set("v.accountName", results.accountName);
                    // component.set("v.fiscalCode", results.fiscalCode); // component.set("v.codFi", results.codFi);
        			// component.set("v.vatNumber", results.vatNumber); // component.set("v.pIv", results.pIv);
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);   
    },
    
    // cancelVendite: function(component, componentId, className){
    //     let cnl = component.get('c.ordineVenditaCancel');
        
    //     let pageRef = component.get("v.pageReference");
    //     let ordineVendita = pageRef.state.c__ordineVendita;
    //     console.log("**************v.cancelVEndite");
    //     cnl.setParams({
    //         "id" : ordineVendita
    //     });
    //     cnl.setCallback(this, function(response) {
    //         var state = response.getState();
    //             console.log("first step");
    //             if (state === "SUCCESS") {
    //                 console.log("*********1");
    //                 var accountid = response.getReturnValue();
    //                 //console.log("++++++++++cnl",accountid);
    //                 this.showToastSucsses("L'ordine di vendita è stato annullato!.");
    //                 //this.closeTab(component);
    //                 this.closeTab(component);
    //         		this.redirectToSObjectSubtab(component,accountid,'Account');
    //             }
    //             else {
    //                 console.log("Failed with state: " + state);
    //             }
    //         });
    //         $A.enqueueAction(cnl);
    // },

    saveDraftHelper: function(component) {
        var orderParentId = component.get("v.orderParentId");
        let action = component.get('c.saveDraftController');
        action.setParams({
            "orderParentId" : orderParentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                this.showToastSucsses('Draft saved');
                
                this.redirectToSObjectSubtabFix(component,orderParentId,'Order');
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    saveOption: function(component){
        var orderParentId = component.get("v.orderParentId");
        let action = component.get('c.saveProsegui');
        action.setParams({
            "orderParentId" : orderParentId
        });
        action.setCallback(this, function(response) {
            	var state = response.getState();
            	var result = response.getReturnValue(); 
                console.log("first step " + state);
                if (state === "SUCCESS") {                
                    console.log("cnl",response.getReturnValue());
                    if(!result){
                        this.showToastError("Non sono stati esitati tutti gli Order");
                    }
                    else{
                        this.showToastSucsses("Concluso con Successo!");
                        this.redirectToSObjectSubtabFix(component,orderParentId,'Order');
                    }
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
    },

    showToastSucsses : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Successo!",
            "message": msg ,
            "type": "success"
        });
        toastEvent.fire();
    },

    showToastError : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Attenzione!",
            "message": msg ,
            "type": "error"
        });
        toastEvent.fire();
    },

    // closeTab: function(component){
    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getFocusedTabInfo().then(function(response) {
    //         var focusedTabId = response.tabId;
    //         workspaceAPI.closeTab({tabId: focusedTabId});
    //     })
    //     .catch(function(error) {
    //         console.log('***************error_:' +error);
    //     });
    // },
    // redirectToSObject : function(component,venditaid,objectApiname){
    //         var workspaceAPI = component.find("workspace");
    //         console.log("Begin Redirect");
    //         workspaceAPI.getFocusedTabInfo().then(function(response) {
    //             console.log("Begin Redirect_2_: " + JSON.stringify(response));
    //             var focusedTabId = response.parentTabId;
    //             console.log("Begin Redirect_3_: " + focusedTabId);
    //             console.log("Begin Redirect_4_: " + venditaid);
    //             console.log("Begin Redirect_5_: " + objectApiname);
    //             workspaceAPI.openTab({//Subtab({
    //                 //parentTabId: focusedTabId,
    //                 //recordId : venditaid,
    //                 pageReference: {
    //                     type: 'standard__recordPage',
    //                     attributes: {
    //                         recordId: venditaid,
    //                         objectApiName:objectApiname,
    //                         actionName : 'view'
    //                     }
    //                 },
    //                 focus: true
    //             })
    //             .catch(function(error) {
    //                 console.log('******' + error);
    //             });
    //         })
    //         .catch(function(error) {
    //             console.log('******' + error);
    //         });
            
    //     },
        // redirectToSObjectSubtab : function(component,venditaid,objectApiname){
        //     var workspaceAPI = component.find("workspace");
        //     console.log("Begin Redirect");
        //     workspaceAPI.getFocusedTabInfo().then(function(response) {
        //         console.log("Begin Redirect_2_: " + JSON.stringify(response));
        //         var focusedTabId = response.parentTabId;
        //         console.log("Begin Redirect_3_: " + focusedTabId);
        //         console.log("Begin Redirect_4_: " + venditaid);
        //         console.log("Begin Redirect_5_: " + objectApiname);
        //         workspaceAPI.openSubtab({//Subtab({
        //             parentTabId: focusedTabId,
        //             //recordId : venditaid,
        //             pageReference: {
        //                 type: 'standard__recordPage',
        //                 attributes: {
        //                     recordId: venditaid,
        //                     objectApiName:objectApiname,
        //                     actionName : 'view'
        //                 }
        //             },
        //             focus: true
        //         })
        //         .catch(function(error) {
        //             console.log('******' + error);
        //         });
        //     })
        //     .catch(function(error) {
        //         console.log('******' + error);
        //     });
            
        // },
        // redirectToSObjectFix : function(component,venditaid,objectApiname){
        //      var workspaceAPI = component.find("workspace");
        //     console.log("Begin Redirect");
        //     workspaceAPI.getFocusedTabInfo().then(function(response) {
        //         console.log("Begin Redirect_2_: " + JSON.stringify(response));
        //         var focusedTabId = response.parentTabId;
        //         var focusedTab = response.tabId;
        //         console.log("Begin Redirect_3_: " + focusedTabId);
        //         console.log("Begin Redirect_4_: " + venditaid);
        //         console.log("Begin Redirect_5_: " + objectApiname);
        //         workspaceAPI.openTab({//Subtab({
        //             //parentTabId: focusedTabId,
        //             //recordId : venditaid,
        //             pageReference: {
        //                 type: 'standard__recordPage',
        //                 attributes: {
        //                     recordId: venditaid,
        //                     objectApiName:objectApiname,
        //                     actionName : 'view'
        //                 }
        //             },
        //             focus: true
        //         }).then(function(response2){
        //             workspaceAPI.closeTab({tabId: focusedTab});
        //         })
        //         .catch(function(error) {
        //             console.log('******' + error);
        //         });
        //     })
        //     .catch(function(error) {
        //         console.log('******' + error);
        //     });
        // },

        redirectToSObjectSubtabFix : function(component,objectId,objectApiname){
            var workspaceAPI = component.find("workspace");
            console.log("Begin Redirect");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                console.log("Begin Redirect_2_: " + JSON.stringify(response));
                var focusedTabId = response.parentTabId;
                var focusedTab = response.tabId;
                
                console.log("Begin Redirect_3_: " + focusedTabId);
                console.log("Begin Redirect_4_: " + objectId);
                console.log("Begin Redirect_5_: " + objectApiname);
                workspaceAPI.openSubtab({//Subtab({
                    parentTabId: focusedTabId,
                    //recordId : venditaid,
                    pageReference: {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: objectId,
                            objectApiName:objectApiname,
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
            
        },

    getOrderParentRecord : function(component){
        var orderParentId = component.get("v.orderParentId");

        var action = component.get("c.getOrderParent");
        action.setParams({orderParentId : orderParentId});
        action.setCallback(this, function(response){
            component.set('v.loading', false);
            var state = response.getState();
            if(state == 'SUCCESS') {
                var retrievedOrderParent = response.getReturnValue();
                component.set('v.orderParentRecord', retrievedOrderParent);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})
