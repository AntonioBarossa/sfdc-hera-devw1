({
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

    createComponent:function(component,event,helper,eventDetails){    
        $A.createComponent(
            'wrts_prcgvr:ServiceCatalogLtgCmp_1_1',
            {recordId: eventDetails},
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

        var context = event.getParam('context');
        var accId = event.getParam('accId');
        var catalogId = event.getParam('catalogId');
        var auraFlow = event.getParam('auraFlow');
        console.log('>>>>>>>> on AURA cmp');
        console.log('>>> context: ' + context);
        console.log('>>> accId: ' + accId);
        console.log('>>> catalogId: ' + catalogId);
        console.log('>>> auraFlow: ' + auraFlow);
        catalogId = 'a3K1x000000pTrHEAU';

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
                        c__context: context,
                        c__catalogId: catalogId,
                        c__processType: 'Informative',
                        c__recordTypeName: 'HDT_RT_Informative',
                        c__flowName: 'HDT_FL_PostSalesMasterDispatch',
                        c__createDocuments: true
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