({
    doInit : function(component, event, helper) {
		let pageRef = component.get("v.pageReference");
        let orderParentId = pageRef.state.c__orderParent;
        let accountId = pageRef.state.c__accountId;
        component.set("v.orderParentId",orderParentId);
        component.set("v.accountId",accountId);
        helper.setColums(component,event,helper);
        helper.helperInit(component,event,helper,orderParentId,accountId);
        
    },
    
    handleRowAction : function(component,event,helper){
        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var row = event.getParam('row');
        var action = event.getParam('action');
        console.log("HOLA : " + row.Id);
        console.log("HOLA2 : " + action.value);
        if(action.value == "Avvia Processo"){
            component.set("v.orderId",row.Id);
               // component.set("v.openModale",true);
               
               workspaceAPI.getFocusedTabInfo().then(function(response2) {
                var focusedTabId;
                if(response2.parentTabId){
                    focusedTabId = response2.parentTabId;
                }
                else{
                    focusedTabId = response2.tabId;
                }
                    // /lightning/cmp/HDT_LCP_ChildOrderProcess' open in new subTab;
                workspaceAPI.openSubtab({
                    parentTabId: focusedTabId,
                    pageReference: {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c:HDT_LCP_ChildOrderProcess',
                        },
                        state: {
                            "c__orderParent": component.get("v.orderParentId"),
                            "c__orderId" : row.Id
                        }
                    },
                    focus: true
                }).then(function(response2) {
                    workspaceAPI.setTabLabel({
                        tabId: response2,
                        label: "Processo ordine individuale"
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
    },

    closeModal : function(component,event,helper){
        component.set("v.openModale",false); 
    },

    // cancel: function(component, event, helper) {
    //     helper.cancelVendite(component);
    // },

    saveDraft: function(component, event, helper) {
        helper.saveDraftHelper(component);
    },

    save: function(component, event, helper){
      	helper.saveOption(component);
    }
})
