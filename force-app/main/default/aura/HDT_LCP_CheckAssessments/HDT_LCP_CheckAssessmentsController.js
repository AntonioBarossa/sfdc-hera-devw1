({
    openTabWithSubtab : function(component, event, helper) {
        
        var myPageRef = component.get("v.pageReference");
        var fiscalCode = myPageRef.state.c__fiscalCode;
        var supplyCity = myPageRef.state.c__supplyCity;
        var customerMarking = myPageRef.state.c__customerMarking;
        var accId = myPageRef.state.c__accId;
        var viewOnly = myPageRef.state.c__viewOnly;
        if(viewOnly){
            component.set("v.viewLwc", true);
            component.set("v.fiscalCode", fiscalCode);
            component.set("v.customerMarking", customerMarking);
            component.set("v.supplyCity", supplyCity);
            return;
        }
       
        var workspaceAPI = component.find("workspace");
        
        console.log('# EnclosingTab -> ' );

        var tabToClose;
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log('# TabId To Close: ' + tabId);
            tabToClose = tabId;
        }).catch(function(error) {
            console.log(error);
        });

        
        var parentId;
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('----------');
            response.forEach((element) => {
                //console.log('# id_' + element.tabId + ' - title: ' + element.title + ' - ' + element.pageReference.type);
                if(element.pageReference.type === 'standard__recordPage'){
                    //console.log(' PR_> ' + element.pageReference.attributes.recordId);
                    if(element.pageReference.attributes.recordId.slice(0,15)=== accId.slice(0,15)){
                        parentId = element.tabId;
                    }
                }
            });
            console.log('----------');
            console.log('# parentId -> ' + parentId);

            console.log('# fiscalCode -> '             + fiscalCode);
            console.log('# supplyCity -> '             + supplyCity);
            console.log('# customerMarking -> '        + customerMarking);

            console.log('# openSubTab -> ' );
            workspaceAPI.openSubtab({
                parentTabId: parentId,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_CheckAssessments'
                    },
                    state: {
                        c__fiscalCode : fiscalCode,
                        c__supplyCity : supplyCity,
                        c__customerMarking : customerMarking,
                        c__viewOnly : true
                    }
                },
                focus: true
            }).then(function(newTabId) {
                console.log('# wizard tab id: ' + newTabId);
                workspaceAPI.setTabLabel({ tabId: newTabId, label: 'Wizard' });
                workspaceAPI.setTabIcon({ tabId: newTabId, icon: 'custom:custom83' });
                
                workspaceAPI.closeTab({ tabId: tabToClose }).then(function(success) {
                    if (success) {
                        workspaceAPI.focusTab({tabId: newTabId});
                    }
                });
            });

        }).catch(function(error) {
            console.log(error);
        });


    }
})