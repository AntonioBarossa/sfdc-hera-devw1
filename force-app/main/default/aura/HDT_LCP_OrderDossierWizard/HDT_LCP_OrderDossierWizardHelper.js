({
    helperInit : function(component,event,helper,orderParentId,accountId) {
        console.log('*******ORDParent ' + orderParentId);
        console.log('*******ACC ' + accountId);
		var action = component.get('c.controllerInit');
        action.setParams({
            "orderParentId" : orderParentId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("SUCSSES1",response.getReturnValue());
                    let results = response.getReturnValue();

                    let childOrdersList = results.childOrdersList;// let orderList = results.orderList;
                    let orderItemList = results.orderItemList;
                    console.log("******* orderItemList:" + orderItemList);
                    childOrdersList.forEach(ord => {
                        if(ord.RecordType){
                            ord.recordtypename = ord.RecordType.Name;
                        }
                        ord.pod = '';
                        ord.CustomerName__c = '/lightning/r/Order/' + ord.Id + '/view';
                        orderItemList.forEach( ordItem => {
                            if(ordItem.OrderId == ord.Id && ordItem.Service_Point__c !== undefined){
                                ord.pod = ordItem.Service_Point__r.ServicePointCode__c;
                            }
                        });

                    });
                    
                    component.set("v.accountName", results.accountName); // component.set("v.accountName", results.accountName);
        			component.set("v.parentOrderName", results.orderParentName); // component.set("v.ordineVenditaName",results.ordineVenditaName);
        			component.set("v.fiscalCode", results.fiscalCode); // component.set("v.codFi", results.codFi);
        			component.set("v.vatNumber", results.vatNumber); // component.set("v.pIv", results.pIv);
        
                    component.set("v.childOrdersList",childOrdersList);// component.set("v.orderList",orderList);
                    // component.set("v.step", 2)
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);   
	},
    setColums : function(component,event,helper){
        component.set('v.columnsDocumenti', [
            {fieldName: 'CustomerName__c', // This field should have the actual URL in it.
             type: 'url', 
             sortable: "false",
             label: 'Numero Ordine',
             typeAttributes: {
                 label: {
                     fieldName: 'OrderNumber' 
                     // whatever field contains the actual label of the link
                 },
                 target: '_parent', 
                 tooltip: 'Open the customer page'
             }},
            {label: 'POD/PDR', fieldName: 'pod', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            {label: 'Tipologia', fieldName: 'recordtypename', type: 'text'},
            {type:  'button',typeAttributes:{
                	iconName: 'utility:edit',
                    label: 'Avvia Processo', 
                    name: 'editRecord', 
                    title: 'Avvia Processo', 
                    disabled: false, 
                    value: 'Avvia Processo'
                }
            }
        ]);  
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
    // saveDraftHelper: function(component) {
    //     var ordineVendita = component.get("v.ordineVenditaId");
    //     let action = component.get('c.saveDraftController');
    //     action.setParams({
    //         "ordineVendita" : ordineVendita
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {                
    //            //console.log("cnl",response.getReturnValue());
    //             this.showToastSucsses('Draft saved');
                
    //             //this.closeTab(component);
    //             this.redirectToSObjectSubtabFix(component,ordineVendita,'Ordine_di_Vendita__c');
    //         }
    //         else {
    //             console.log("Failed with state: " + state);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    // saveOption: function(component){
    //     var ordineVendita = component.get("v.ordineVenditaId");
    //     let action = component.get('c.saveProsegui');
    //     action.setParams({
    //         "ordineVendita" : ordineVendita
    //     });
    //     action.setCallback(this, function(response) {
    //         	var state = response.getState();
    //         	var result = response.getReturnValue(); 
    //             console.log("first step " + state);
    //             if (state === "SUCCESS") {                
    //                 console.log("cnl",response.getReturnValue());
    //                 if(!result){
    //                     this.showToastError("Non sono stati esitati tutti gli Order");
    //                 }
    //                 else{
    //                     this.showToastSucsses("Concluso con Successo!");
    //                    // this.redirectToSObject(component,venditaId,'Vendite__c');
    //                     //this.closeTab(component);
    //                     this.redirectToSObjectSubtabFix(component,ordineVendita,'Ordine_di_Vendita__c');
    //                 }
    //             }
    //             else {
    //                 console.log("Failed with state: " + state);
    //             }
    //         });
    //         $A.enqueueAction(action);
    // },
    // showToastSucsses : function(msg) {
    //     var toastEvent = $A.get("e.force:showToast");
    //     toastEvent.setParams({
    //         "title": "Successo!",
    //         "message": msg ,
    //         "type": "success"
    //     });
    //     toastEvent.fire();
    // },
    // showToastError : function(msg) {
    //     var toastEvent = $A.get("e.force:showToast");
    //     toastEvent.setParams({
    //         "title": "Attenzione!",
    //         "message": msg ,
    //         "type": "error"
    //     });
    //     toastEvent.fire();
    // },
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
        // redirectToSObjectSubtabFix : function(component,venditaid,objectApiname){
        //     var workspaceAPI = component.find("workspace");
        //     console.log("Begin Redirect");
        //     workspaceAPI.getFocusedTabInfo().then(function(response) {
        //         console.log("Begin Redirect_2_: " + JSON.stringify(response));
        //         var focusedTabId = response.parentTabId;
        //         var focusedTab = response.tabId;
                
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
            
        // }
})
