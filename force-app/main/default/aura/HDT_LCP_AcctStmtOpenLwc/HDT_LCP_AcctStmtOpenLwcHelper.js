({

    getEnclosingTabId: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(subtabId) {
            console.log('>>>>>>>>> ' + subtabId);
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: 'Estratto conto'
            });
            workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: 'custom:custom83',
                iconAlt: 'Estratto conto'
            });
       })
        .catch(function(error) {
            console.log(error);
        });
    },

    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('modalbox');
        var cmpBack = component.find('modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    openModal:function(component,event,helper){    
        var cmpTarget = component.find('modalbox');
        var cmpBack = component.find('modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },

    createComponent:function(component, event, helper){    

        var catalogId = event.getParam('catalogId');
        console.log('>>>>>>>> on AURA cmp');
        console.log('>>> catalogId: ' + catalogId);

        $A.createComponent(
            'wrts_prcgvr:ServiceCatalogLtgCmp_1_1',
            {recordId: catalogId},
            function(lwcCmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(lwcCmp);
                    component.set("v.body", body);

                    helper.openModal(component,event,helper);

                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.error("Error: " + errorMessage);
                }
            }
        );
    },

    openSubTab: function(component, event, helper) {

        //var context = event.getParam('context');
        var parameters = event.getParam('parameters');
        console.log('>>> PARAMETERS: ' + parameters);
        var paramObj = JSON.parse(parameters);

        var accId = event.getParam('accId');
        var catalogId = event.getParam('catalogId');

        console.log('>>>>>>>> on AURA cmp');
        console.log('>>> accId: ' + accId);
        console.log('>>> context: ' + paramObj.context);
        console.log('>>> catalogId: ' + catalogId);
        console.log('>>> processType: ' + paramObj.processType);
        console.log('>>> recordTypeName: ' + paramObj.recordTypeName);
        console.log('>>> flowName: ' + paramObj.flowName);
        console.log('>>> documentPaymentMethod: ' + paramObj.documentPaymentMethod);
        //var accountId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({
            url: '/' + accId
        }).then(function(response) {
            var i = workspaceAPI.openSubtab({
                parentTabId: response,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_RunFlowFromAura'
                    },
                    state: {
                        c__accid: accId,
                        c__context: paramObj.context,
                        c__catalogId: catalogId,
                        c__processType: paramObj.processType,
                        c__recordTypeName: paramObj.recordTypeName,
                        c__flowName: paramObj.flowName,
                        c__createDocuments: paramObj.createDocuments,
                        c__documentPaymentMethod: paramObj.documentPaymentMethod
                    }
                }
            });

            workspaceAPI.setTabLabel({
                tabId: i,
                label: 'Wizard'
            });
            workspaceAPI.setTabIcon({
                tabId: i,
                icon: 'custom:custom83'
            });
            //$A.get("e.force:closeQuickAction").fire();
        })
        .catch(function(error) {
            console.log(error);
        });
    }

})