({
    openWizardForCase : function(component,event) {
        console.log('@@@working in progress...');
        console.log('@@@@openWizardForOrder' );
        let workspaceAPI = component.find("workspace");
        let recordId = component.get("v.recordId");
        let url = '/lightning/cmp/c__HDT_LCP_OpenAuraCmp?c__id='+recordId+'&c__flowName=HDT_FL_PostSalesDiscardDispatch';
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.parentTabId;
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                url: url,
                focus: true
            }).then(function(response) {
                console.log('@@@@then openSubTab');
                workspaceAPI.setTabLabel({
                    tabId: response,
                    label: "Processo PostSales"
                });
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            })
            .catch(function(error) {
                console.log('@@@@catch openSubTab');
                this.showAllert(component,error.body.message,'error','Attenzione!');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
        })
        .catch(function(error) {
            console.log('@@@@catch getFocusTabInfo');
            this.showAllert(component,error.body.message,'error','Attenzione!');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
    },

    openWizardForOrder : function(component,event){
        console.log('@@@@openWizardForOrder' );
        let workspaceAPI = component.find("workspace");
        let recordId = component.get("v.recordId");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let order = component.get('v.order');
            let focusedTabId = response.parentTabId;
            console.log('@@@@getFocusTabInfo ' + order.Id +'/'+order.ParentOrder__c+'/'+focusedTabId );
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c:HDT_LCP_ChildOrderProcess',
                    },
                    state: {
                        "c__orderParent": order.Id,
                        "c__orderId" : order.ParentOrder__c,
                        "c__discardRework": true,
                        "c__discardActivityToClose" : recordId
                    }
                },
                focus: true
            }).then(function(response) {
                console.log('@@@@then openSubTab');
                workspaceAPI.setTabLabel({
                    tabId: response,
                    label: "Processo ordine individuale"
                });
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            })
            .catch(function(error) {
                console.log('@@@@catch openSubTab');
                this.showAllert(component,error.body.message,'error','Attenzione!');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
        })
        .catch(function(error) {
            console.log('@@@@catch getFocusTabInfo');
            this.showAllert(component,error.body.message,'error','Attenzione!');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
    },

    showAllert: function(component,message,variant,title){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : variant
        });
        toastEvent.fire();
    }
})