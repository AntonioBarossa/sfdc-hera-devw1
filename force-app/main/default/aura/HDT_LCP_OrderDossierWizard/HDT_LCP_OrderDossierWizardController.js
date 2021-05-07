({
    doInit: function (component, event, helper) {

        //EVERIS
        console.log('InitStarted')
        //EVERIS

        component.set('v.loading', true);
        let accountId;
        let saleId;
        let orderParentId;

        var checkprocess = component.get("c.checkCommunityLogin");

        checkprocess.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var res = response.getReturnValue();
                console.log('res: ', res);
                component.set('v.isCommunity', res);
                if (res) {
                    console.log('community');

                    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                    sURLVariables = sPageURL.split('&'),
                    testParam = '';

                    for (let i = 0; i < sURLVariables.length; i++) {
                        testParam = '';
                        testParam = sURLVariables[i].split('=');
                        console.log('sURL ' + testParam);
                        if (testParam[0] == 'c__accountId') {
                            accountId = testParam[1];
                        }
                        if (testParam[0] == 'c__venditaId') {
                            saleId = testParam[1];
                        }
                        if (testParam[0] == 'c__orderParent') {
                            orderParentId = testParam[1];
                        }
                       
                    }

                    if(orderParentId !== undefined){
                        component.set("v.orderParentId", orderParentId);
                        component.set("v.check", true);
                    } else {
                        component.set("v.check", false);
                    }
                }
                else
                {
                    console.log('crm');

                    let pageRef = component.get("v.pageReference");
        			saleId = pageRef.state.c__venditaId;
        			accountId = pageRef.state.c__accountId;

                    if (pageRef.state.c__orderParent !== undefined) {
                        orderParentId = pageRef.state.c__orderParent;
                        component.set("v.orderParentId", orderParentId);
                        component.set("v.check", true);
                    } else {
                        component.set("v.check", false);
                    }
                }
                console.log('saleId: ', saleId);
                console.log('accountId: ', accountId);
                console.log('c__orderParent: ', orderParentId);

                component.set("v.saleId", saleId);
                component.set("v.accountId",accountId);
                helper.helperInit(component, event, helper, saleId, accountId);
                
            }
        });

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response3) {
            workspaceAPI.setTabLabel({
                tabId: response3.tabId,
                label: "Wizard Ordine"
            })
        });

        $A.enqueueAction(checkprocess);
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