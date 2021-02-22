({
    doInit : function(component, event, helper) {
		let pageRef = component.get("v.pageReference");
        let saleId = pageRef.state.c__venditaId;
        let accountId = pageRef.state.c__accountId;
        component.set("v.saleId",saleId);

        console.log('Order Parent Check '+pageRef.state.c__orderParent)

        if (pageRef.state.c__orderParent !== undefined) {
            let orderParentId = pageRef.state.c__orderParent;

            console.log('Order Parent Id: '+orderParentId);

            component.set("v.orderParentId",orderParentId);
            component.set("v.check", true);
        } else {
            component.set("v.check", false);
        }

        component.set("v.accountId",accountId);
        helper.helperInit(component,event,helper,saleId,accountId);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response3) {
            workspaceAPI.setTabLabel({
            tabId: response3.tabId,
            label: "Wizard Ordine"
        })});
    },
    
    handleRowActionEvent : function(component,event,helper){
        
        let c__orderParent = event.getParam('c__orderParent');
        let c__orderId = event.getParam('c__orderId');
        let action = event.getParam('action');

        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");

        if(action === "Avvia Processo"){

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
                            "c__orderParent": c__orderParent,
                            "c__orderId" : c__orderId
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

    handleOrderRefreshEvent: function(component,event,helper){
        helper.getOrderParentRecord(component);
    },

    closeModal : function(component,event,helper){
        component.set("v.openModale",false); 
    },

    handleTableRefreshEvent : function(component,event,helper){
        var tableCmp = component.find("hdtOrderDossierWizardTable");
        tableCmp.setTableData();
    },

    redirectToOrderRecordPage : function(component, event, helper){
        var objectId = component.get("v.orderParentId");
        var objectApiname = 'Order';
        helper.redirectToSObjectSubtabFix(component,objectId,objectApiname);
    }
})
