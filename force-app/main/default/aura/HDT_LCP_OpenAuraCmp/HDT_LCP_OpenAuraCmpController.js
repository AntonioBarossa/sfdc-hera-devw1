({
    openTabWithSubtab : function(component, event, helper) {
        
        var myPageRef = component.get("v.pageReference");
        var caseId = myPageRef.state.c__id;
        var flowName = myPageRef.state.c__flowName;
        var resumeFromDraft = myPageRef.state.c__resumeFromDraft;
        var accId = myPageRef.state.c__accid;

        var processType = myPageRef.state.c__processType;
        var recordTypeName = myPageRef.state.c__recordTypeName;

        //var cluster = myPageRef.state.c__cluster;
        var recordToCancell = myPageRef.state.c__recordToCancell;
        var sObjectRecordToCancell = myPageRef.state.c__sObjectRecordToCancell;

        console.log('# accId -> ' + accId);
        console.log('# caseId -> ' + caseId);
        console.log('# flowName -> ' + flowName);
        console.log('# resumeFromDraft -> ' + resumeFromDraft);
        console.log('# processType -> ' + processType);
        console.log('# recordTypeName -> ' + recordTypeName);
        //console.log('# cluster -> ' + cluster);
        console.log('# recordToCancell -> ' + recordToCancell);
        console.log('# sObjectRecordToCancell -> ' + sObjectRecordToCancell);

                
        var workspaceAPI = component.find("workspace");

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
                    if(element.pageReference.attributes.recordId=== accId){
                        parentId = element.tabId;
                    }
                }
            });
            console.log('----------');
            console.log('# parentId -> ' + parentId);

            workspaceAPI.openSubtab({
                parentTabId: parentId,
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__HDT_LCP_RunFlowFromAura'
                    },
                    state: {
                        c__recordid: caseId,
                        c__accid: accId,
                        c__flowName: flowName,
                        c__resumeFromDraft: resumeFromDraft,
                        c__processType: processType,
                        c__recordTypeName: recordTypeName,
                        c__recordToCancell: recordToCancell,
                        c__sObjectRecordToCancell: sObjectRecordToCancell,
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