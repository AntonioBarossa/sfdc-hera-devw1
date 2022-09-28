({
    openWizardForCase : function(component,event) {
        console.log('@@@working in progress...');
        console.log('@@@@openWizardForCase' );
        let workspaceAPI = component.find("workspace");
        let recordId = component.get("v.recordId");
        let url = '/lightning/cmp/c__HDT_LCP_OpenAuraCmp?c__id='+recordId+'&c__flowName=HDT_FL_PostSalesDiscardDispatch';
        const that = this;
        
        let parentId;
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('----------');
            response.forEach((element) => {
                if(element.pageReference.type === 'standard__recordPage'){
                    
                    if(element.pageReference.attributes.recordId === recordId){
                        parentId = element.tabId;
                    }
                    
                }
            });
            console.log('----------');

        }).catch(function(error) {
            console.log(error);
        });

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.parentTabId;
            if (!focusedTabId){
                focusedTabId = parentId;
            }
            
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
                that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
        })
        .catch(function(error) {
            console.log('@@@@catch getFocusTabInfo');
            that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
    },

    openWizardForOrder : function(component,event){
        console.log('@@@@openWizardForOrder' );
        let workspaceAPI = component.find("workspace");
        let recordId = component.get("v.recordId");
        const that = this;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let order = component.get('v.order');
            let focusedTabId = response.parentTabId;
            console.log('@@@@getFocusTabInfo ' + order.Id +'/'+order.ParentOrder__c+'/'+focusedTabId );
            if (focusedTabId){
                workspaceAPI.openSubtab({
                    parentTabId: focusedTabId,
                    pageReference: {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c:HDT_LCP_ChildOrderProcess',
                        },
                        state: {
                            "c__orderParent": order.ParentOrder__c,
                            "c__orderId" : order.Id,
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
                    that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                });
            }else{
                workspaceAPI.openTab({
                    pageReference: {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c:HDT_LCP_ChildOrderProcess',
                        },
                        state: {
                            "c__orderParent": order.ParentOrder__c,
                            "c__orderId" : order.Id,
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
                    that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                });
            }
        })
        .catch(function(error) {
            console.log('@@@@catch getFocusTabInfo');
            that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
    },

    openWizardForActivity : function(component,event){
        console.log('@@@@openWizardForActivity' );
        let workspaceAPI = component.find("workspace");
        let recordId = component.get("v.recordId");
        const that = this;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let activity = component.get('v.activity');
            let saleId;
            let accountid;
            let orderParentId;
            if(activity.Order__r.ParentOrder__c!=null && activity.Order__r.ParentOrder__c!=undefined && activity.Order__r.ParentOrder__c!=''){
                console.log('@@@@get parent values');
                saleId = activity.Order__r.ParentOrder__r.Sale__c;
                accountid = activity.Order__r.ParentOrder__r.AccountId;
                orderParentId = activity.Order__r.ParentOrder__c;
            }else{
                console.log('@@@@get order values');
                saleId = activity.Order__r.Sale__c;
                accountid = activity.Order__r.AccountId;
                orderParentId = activity.Order__c;
            } 
            let focusedTabId = response.parentTabId;
            if (focusedTabId){
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
                            "c__ordineVendita": orderParentId,
                            "c__discardRework": true,
                            "c__discardActivityId": activity.Id
                        }
                    },
                    focus: true
                }).then(function(response) {
                    console.log('@@@@then openSubTab');
                    workspaceAPI.setTabLabel({
                        tabId: response,
                        label: "Processo Busta Docusign non consegnata"
                    });
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                })
                .catch(function(error) {
                    console.log('@@@@catch openSubTab');
                    that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                });
            }else{
                workspaceAPI.openTab({
                    pageReference: {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c:HDT_LCP_OrderDossierWizard',
                        },
                        state: {
                            "c__venditaId": saleId,
                            "c__accountId" : accountid,
                            "c__ordineVendita": orderParentId,
                            "c__discardRework": true,
                            "c__discardActivityId": activity.Id
                        }
                    },
                    focus: true
                }).then(function(response) {
                    console.log('@@@@then openSubTab');
                    workspaceAPI.setTabLabel({
                        tabId: response,
                        label: "Processo Busta Docusign non consegnata"
                    });
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                })
                .catch(function(error) {
                    console.log('@@@@catch openSubTab');
                    that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                });
            }
        })
        .catch(function(error) {
            console.log('@@@@catch getFocusTabInfo');
            that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
    },

    //Gestione Risottomissione Annullamento
    openWizardForAnnulment : function(component,event) {
        console.log('@@@working in progress...');
        console.log('@@@@openWizardForAnnullment' );
        let workspaceAPI = component.find("workspace");
        let recordId = component.get("v.inputRecordId");
        let activityId = component.get('v.recordId');
        let objectToCancel = component.get('v.objectToCancell');
        let url = '/lightning/cmp/c__HDT_LCP_OpenAuraCmp?c__id='+recordId+'&c__flowName=HDT_FL_GestioneAnnullamento&c__sObjectRecordToCancell='+objectToCancel+'&c__processType=Annullamento+prestazione&c__discardRework=true&c__activityId='+activityId;
        const that = this;
        let parentId;
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('----------');
            response.forEach((element) => {
                if(element.pageReference.type === 'standard__recordPage'){
                    
                    if(element.pageReference.attributes.recordId === activityId){
                        parentId = element.tabId;
                    }
                    
                }
            });
            console.log('----------');

        }).catch(function(error) {
            console.log(error);
        });


        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.parentTabId;
            if (!focusedTabId){
                focusedTabId = parentId;
            }
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                url: url,
                focus: true
            }).then(function(response) {
                console.log('@@@@then openSubTab');
                workspaceAPI.setTabLabel({
                    tabId: response,
                    label: "Wizard Annullamento"
                });
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            })
            .catch(function(error) {
                console.log('@@@@catch openSubTab');
                that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
        })
        .catch(function(error) {
            console.log('@@@@catch getFocusTabInfo');
            that.showAlert(component,JSON.stringify(error),'error','Attenzione!');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
    },

    showAlert: function(component,message,variant,title){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : variant
        });
        toastEvent.fire();
    }
})