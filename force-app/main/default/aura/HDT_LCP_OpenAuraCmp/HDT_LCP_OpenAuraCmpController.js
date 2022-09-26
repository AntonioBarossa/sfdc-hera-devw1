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
        var createDocuments = myPageRef.state.c__createDocuments;
        var serviceCatalogId = myPageRef.state.c__catalogId;
        var context = myPageRef.state.c__context;

        //variabile per innesco da altri case
        var parentRecordId = myPageRef.state.c__parentRecordId;

        //variabile per innesco da campagne
        var campaignId = myPageRef.state.c__campaignId;
        var campaignMemberId = myPageRef.state.c__campaignMemberId;
        


        // id del lead oggetto del process.
        var leadId = myPageRef.state.c__leadId;

        //attributo per innesco da ServicePoint
        var servicePointId = myPageRef.state.c__servicePointId;
        //attributo per innesco da BillingProfile
        var billingProfileId = myPageRef.state.c__billingProfileId;
        //attributo per sequenzializzazione
        var serviceRequestId = myPageRef.state.c__serviceRequestId;
        //attributo per esito compatibilita
        var compatibile = myPageRef.state.c__compatibile;

        // id dell'Order
        var orderId = myPageRef.state.c__orderId;

        // id dell'interaction
        var interactionId = myPageRef.state.c__interactionId;
        // activityId
        var activityId = myPageRef.state.c__activityId;

        //Gestione Risottomissione Annullamento
        let discardRework = undefined;
        if (myPageRef.state.c__discardRework === true || myPageRef.state.c__discardRework === 'true'){
            discardRework = true;
        } else if (myPageRef.state.c__discardRework === false || myPageRef.state.c__discardRework === 'false'){
            discardRework = false;
        }
        console.log('# discardRework -> '                 + discardRework);
        //Fine Gestione Risottomissione Annullamento

        //Gestione Owner Activity
        var isUserActivity = myPageRef.state.c__IsUserActivity;
        console.log('# isUserActivity -> '                 + isUserActivity);
        //Fine Gestione Owner Activity
        console.log('# context -> '                 + context);
        console.log('# accId -> '                   + accId);
        console.log('# caseId -> '                  + caseId);
        console.log('# flowName -> '                + flowName);
        console.log('# resumeFromDraft -> '         + resumeFromDraft);
        console.log('# processType -> '             + processType);
        console.log('# recordTypeName -> '          + recordTypeName);
        //console.log('# cluster -> ' + cluster);
        console.log('# recordToCancell -> '         + recordToCancell);
        console.log('# sObjectRecordToCancell -> '  + sObjectRecordToCancell);
        console.log('# parentRecordId --> '         + parentRecordId);
        console.log('# campaignId -> '              + campaignId);
        console.log('# campaignMemberId --> '       +campaignMemberId);
        console.log('# leadId -> '                  + leadId);
        console.log('# servicePointId -> '          + servicePointId);
        console.log('# billingProfileId -> '        + billingProfileId);
        console.log('# serviceRequestId -> '        + serviceRequestId);
        console.log('# compatibile -> '             + compatibile);
        console.log('# orderId -> '                 + orderId);
        console.log('# InteractionId -> '           + interactionId);
        console.log('# activityId -> '              + activityId);

                
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
                    } else if(element.pageReference.attributes.recordId === leadId){
                        parentId = element.tabId;
                    } else if(element.pageReference.attributes.recordId === interactionId){
                        parentId = element.tabId;
                    }
                    else if(element.pageReference.attributes.recordId === orderId){
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
                        c__context: context,
                        c__createDocuments: createDocuments,
                        c__catalogId: serviceCatalogId,
                        c__parentRecordId: parentRecordId,
                        c__campaignId: campaignId,
                        c__leadId: leadId,
                        c__servicePointId: servicePointId,
                        c__billingProfileId: billingProfileId,
                        c__serviceRequestId: serviceRequestId,
                        c__compatibile: compatibile,
                        c__orderId: orderId,
                        c__interactionId: interactionId,
                        //Gestione Risottomissione Annullamento
                        c__discardRework: discardRework,
                        c__campaignMemberId: campaignMemberId,
                        //Gestione Owner Activity
                        c__IsUserActivity:isUserActivity,
                        //activityId per annullamento Attività
                        c__activityId:activityId
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