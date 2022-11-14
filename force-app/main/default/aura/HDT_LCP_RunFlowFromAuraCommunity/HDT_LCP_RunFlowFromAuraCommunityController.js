({

    doInit : function(component, event, helper) {
        
        var flowName = '';
        var accId = '';
        var leadId = '';
        var processType = '';
        var recordTypeName = '';
        var campaignId = '';
        var campaignMemberId = '';

        var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), testParam = '';
                    
        for(let i = 0; i < sURLVariables.length; i++){
            
            testParam = '';
            testParam = sURLVariables[i].split('=');
            
            if (testParam[0] == 'c__accid'){
                accId = testParam[1];
            }
            if (testParam[0] == 'c__leadId'){
                leadId = testParam[1];
            }
            if (testParam[0] == 'c__campaignId'){
                campaignId = testParam[1];
            }
            if (testParam[0] == 'c__flowName'){
                flowName = testParam[1];
            }
            if (testParam[0] == 'c__processType'){
                processType = testParam[1];
            }
            if(testParam[0] == 'c__recordTypeName'){
                recordTypeName = testParam[1];
            }
            if(testParam[0] == 'c__campaignMemberId'){
                campaignMemberId = testParam[1];
            }
            
        }

        var caseId = null;
        component.set("v.campaignId",campaignId);
        component.set("v.campaignMemberId",campaignMemberId);
        /*
        var flowName = myPageRef.state.c__flowName;
        var accId = myPageRef.state.c__accid;

        var processType = myPageRef.state.c__processType;
        var recordTypeName = myPageRef.state.c__recordTypeName;

        //var cluster = myPageRef.state.c__cluster;
        var recordToCancell = myPageRef.state.c__recordToCancell;
        var sObjectRecordToCancell = myPageRef.state.c__sObjectRecordToCancell;
        var createDocuments = myPageRef.state.c__createDocuments;
        var serviceCatalogId = myPageRef.state.c__catalogId;
        var resumeFromDraft = myPageRef.state.c__resumeFromDraft;

        //variabile per informative
        var context = myPageRef.state.c__context;

        //variabile per innesco da altri case
        var parentRecordId = myPageRef.state.c__parentRecordId;

        //variabile per innesco da campagne
        var campaignId = myPageRef.state.c__campaignId;

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

*/
        console.log('# attribute to run flow #');
       // console.log('# caseId -> ' + caseId);
      //  component.set("v.recordid", caseId)
      //  console.log('# component set recordid -> '+component.get("v.recordid"))
        console.log('# flowName -> ' + flowName);
       console.log('# accId -> ' + accId);
        console.log('# processType -> ' + processType);
        console.log('# recordTypeName -> ' + recordTypeName);
        console.log('# campaignMemberId -> ' + campaignMemberId);
        //console.log('# cluster -> ' + cluster);
        /*   console.log('# recordToCancell -> ' + recordToCancell);
        console.log('# sObjectRecordToCancell -> ' + sObjectRecordToCancell);
        console.log('# context -> '+context);
        console.log('# parentRecordId -> ' +parentRecordId);
        console.log('# campaignId -> ' + campaignId)
        console.log('# leadId -> ' + leadId);
        console.log('# servicePointId -> '          + servicePointId);
        console.log('# billingProfileId -> '        + billingProfileId);
        console.log('# serviceRequestId -> '        + serviceRequestId);
        console.log('# compatibile -> '             + compatibile);
        console.log('# ----------------- #');
        */
       // var workspaceAPI = component.find("workspace");
        var flow = component.find("flowData");
        var subTabToClose;
        console.log('*********:RUNFLOWLOG');
       /* workspaceAPI.getEnclosingTabId().then(function(tabId) {
            console.log('# getEnclosingTabId: ' + tabId);
            subTabToClose = tabId;
        }).catch(function(error) {
            console.log(error);
        });

        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('----------');
            var accountTabId;
            var leadTabId;
            response.forEach((element) => {
                if(element.pageReference.type === 'standard__recordPage'){                    
                    if(element.pageReference.attributes.recordId===accId){
                        accountTabId = element.tabId;
                        //element.subtabs.forEach((sub) => {
                        //    if(sub.caseId === caseId){
                        //        subTabToRefresh = sub.tabId;
                        //    }
                        //});
                    } else if(element.pageReference.attributes.recordId===leadId){
                        leadTabId = element.tabId;
                    }
                }
            });*/
         /*   console.log('----------');
            console.log('# accountTabId: ' + accountTabId);
            component.set("v.accountTabId", accountTabId);

            console.log('# leadTabId: ' + leadTabId);
            component.set("v.leadTabId", leadTabId);
            
            console.log('# subTabToClose: ' + subTabToClose);
            component.set("v.subTabToClose", subTabToClose);
        });*/
        console.log('*********:RUNFLOWLOG2');
        var inputVariables = [];

        if(caseId === null || caseId === 'undefined' || caseId === undefined){
            console.log('# CaseId is NULL');
            if (accId != null){
                inputVariables.push({ name : 'AccountId', type : 'String', value : accId });
            }
            inputVariables.push({ name : 'ProcessType', type : 'String', value : processType });
            inputVariables.push({ name : 'RecordTypeName', type : 'String', value : recordTypeName });
            component.set('v.enableRefresh', false);
        } else {
            console.log('# CaseId is NOT NULL');
            //{ name : "InputCase", type : "SObject", value: {"Id" : caseId}}
            inputVariables.push({ name : 'InputCase', type : 'String', value : caseId });

            if(processType === 'Annullamento prestazione' || processType === 'Annullamento segnalazioni' || processType === 'Ripristina fase' || processType === 'Ripensamento'
            || processType === 'Modifica dati contrattuali' || processType === 'Modifica post accertamento' || processType === 'AnnullamentoVarIndFornitura'
            || processType === 'Cessazione' || processType === 'Cessazione post accertamento' || processType === 'Variazione indirizzo di fornitura tari' || processType === 'Reclamo da cittadino' || processType === 'Posizionamento contenitore'
            || processType === 'Annullamento comunicazione pagamenti tari' || processType ==='Annullamento doppi pagamenti tari' || processType ==='Annullamento storno rateizzazione tari'
            || processType ==='Annullamento errore fatturazione' || processType ==='Annullamento rimborso tari' || processType ==='Annullamento contratti TARI' || processType ==='Annullamento prestazione tari'){
                inputVariables.push({ name : 'ProcessType', type : 'String', value : processType });
            }

            component.set('v.enableRefresh', true);
        }
        console.log('*********:RUNFLOWLOG3');
      /*  if(recordToCancell != null)
           //     inputVariables.push({ name : 'recordToCancell', type : 'String', value : recordToCancell });
        if(sObjectRecordToCancell != null)
                inputVariables.push({ name : 'sObjectRecordToCancell', type : 'String', value : sObjectRecordToCancell });
        if(resumeFromDraft != null){
            inputVariables.push({ name : 'ResumeFromDraft', type : 'Boolean', value : resumeFromDraft });
        }
        if(processType === 'Informative'){
            inputVariables.push({ name : 'Context', type : 'String', value : context });
        }
        if(createDocuments != null){
            inputVariables.push({ name : 'createDocuments', type : 'Boolean', value : createDocuments });
        }
        if(serviceCatalogId != null){
            inputVariables.push({ name : 'serviceCatalogId', type : 'String', value : serviceCatalogId });
        }
        if(parentRecordId != null){
            inputVariables.push({ name : 'ParentRecordId', type : 'String', value : parentRecordId });
        }*/
        if(campaignId != null){
            inputVariables.push({ name : 'CampaignId', type : 'String', value : campaignId});
        }
        if(campaignMemberId != null){
            inputVariables.push({ name : 'CampaignMemberId', type : 'String', value : campaignMemberId});
        }
        if(leadId != null){
            inputVariables.push({ name : 'LeadId', type : 'String', value : leadId});
        }
     //   if(servicePointId != null){
     //       inputVariables.push({ name : 'InputServicePointId', type : 'String', value : servicePointId});
     //   }
     //   if(billingProfileId != null){
      //      inputVariables.push({ name : 'BillingProfileId', type : 'String', value : billingProfileId});
      //  }
      //  if(serviceRequestId != null){
      //      inputVariables.push({ name : 'ServiceRequestId', type : 'String', value : serviceRequestId});
     //   }
     //   if(compatibile != null){
     //       inputVariables.push({ name : 'Compatibile', type : 'String', value : compatibile});
      //  }

        console.log('## inputVariables -> ');
        inputVariables.forEach(e => console.log('# ' + e.name + '- ' + e.value));

        flow.startFlow(flowName, inputVariables);

    },
    
    handleStatusChange : function (component, event) {

        console.log('### EVENT STATUS: ' + event.getParam("status"));
        var workspaceAPI = component.find("workspace");

        if(event.getParam("status") === "FINISHED" || event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "ERROR") {

            var accountTabId = component.get("v.accountTabId");
            var leadTabId = component.get("v.leadTabId");
            var subTabToClose = component.get("v.subTabToClose");
            var enableRefresh = component.get('v.enableRefresh');
            var flowfinal = component.find("flowData");
                
            if(event.getParam("status") === "ERROR"){
                console.log('Inside Error condition: ' + JSON.stringify(event));

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Errore",
                    "message": "Non è stato possibile portare a termine le operazioni.\nSi prega di contattare l'Amministratore di sistema",
                    "type" : "error"
                });
                toastEvent.fire();
            }
           
            flowfinal.destroy();

            console.log('# Refresh page -> ' + enableRefresh);

            console.log('# close -> ' + subTabToClose + ' - refresh -> ' + accountTabId);

            //if(!enableRefresh){
            var outputVariables = event.getParam('outputVariables');
            var outputVar;
            var newCaseId;
            var isCommunity;
            var statusCampaignMember;

            console.log('# recordid -> ' +component.get("v.recordid"));
            if(outputVariables != null){      
                for(var i = 0; i < outputVariables.length; i++) {
                    outputVar = outputVariables[i];
                    
                    if(outputVar.name === "CaseId") {
                        newCaseId = outputVar.value;
                    }
                    if(outputVar.name === "isCommunity") {
                        isCommunity = outputVar.value;
                    }
                    if(outputVar.name === "Status_CampaignMember") {
                        statusCampaignMember = outputVar.value;
                    }
                }
            }
            else{
                newCaseId=component.get("v.recordid");
            }

            if(isCommunity && statusCampaignMember != null && statusCampaignMember != ''){
                //Richiamo saveScript
                var SaveScriptLauncher=component.find('SaveScriptLauncher');
                SaveScriptLauncher.saveScript(statusCampaignMember, true);
            }

            console.log('# outputVariable -> '+outputVariables);
            console.log('# newCaseId -> '+newCaseId);
            var campaignId = component.get("v.campaignId");
            console.log('# campaignId -> ' +campaignId);
            var campaignMemberId = component.get("v.campaignMemberId");
            console.log('# campaignMemberId -> ' +campaignMemberId);
            var navService = component.find("navService");
            var navOnRecId = (newCaseId != null && newCaseId != undefined) ? newCaseId : campaignMemberId;
            var pageReference = 
            {
                "type":"standard__recordPage",
                "attributes":
                {
                    "recordId": navOnRecId,
                    "actionName" : "view"
                }
            }

            navService.navigate(pageReference);
            /* ToDo: inserire redirect alla pagina del campaign member o campaign */
            // var navEvt = $A.get("e.force:navigateToSObject");
            // navEvt.setParams({
            // "recordId": campaignId
            // });
            // navEvt.fire();
            //Gestione chiusura errore in creazione
            /*if(newCaseId == null || newCaseId == undefined){
                
                workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
                    console.log('# Refresh page -> ' + enableRefresh);
                    
                    console.log('# OK Refresh page #');
                    $A.get('e.force:refreshView').fire();
                
                    if(accountTabId != null){
                        workspaceAPI.focusTab({tabId : accountTabId}).
                        then(function(response) {
                            workspaceAPI.refreshTab({
                                    tabId: accountTabId,
                                    includeAllSubtabs: true
                                }).catch(function(error) {
                                    console.log(error);
                                });
                        });
                    } else if(leadTabId != null){
                        workspaceAPI.focusTab({tabId : leadTabId}).
                        then(function(response) {
                            workspaceAPI.refreshTab({
                                    tabId: leadTabId,
                                    includeAllSubtabs: true
                                }).catch(function(error) {
                                    console.log(error);
                                });
                        });
                    }

                }).catch(function(error) {
                    console.log(error);
                });

                return;

            }
            if(!enableRefresh && accountTabId != null){
                workspaceAPI.openSubtab({
                    parentTabId: accountTabId,
                    pageReference: {
                        type: "standard__recordPage",
                        attributes: {
                            recordId: newCaseId,
                            objectApiName: "Case",
                            actionName: "view"
                        }
                    },
                    focus: true
                }).then(function(response){

                    workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
                        console.log('# Refresh page -> ' + enableRefresh);
                        console.log('# OK Refresh page #');
                        $A.get('e.force:refreshView').fire();
                        
        
                        //workspaceAPI.focusTab({tabId : subTabToRefresh}).then(function(response) {
                        //    workspaceAPI.refreshTab({
                        //        tabId: subTabToRefresh,
                        //        includeAllSubtabs: true
                        //    }).catch(function(error) {
                        //        console.log(error);
                        //    });
                        //});
        
                        }).catch(function(error) {
                            console.log(error);
                        });
                    });
            }else{

                workspaceAPI.focusTab({
                    pageReference: {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: newCaseId,
                        objectApiName: "Case",
                        actionName: "view"
                    }
                },
                focus: true
                })
                .then(function(response) {
                    workspaceAPI.closeTab({ tabId: subTabToClose}).then(function(response){
                        console.log('# Refresh page -> ' + enableRefresh);
                        
                        console.log('# OK Refresh page #');
                        $A.get('e.force:refreshView').fire();
                    }).catch(function(error){
                        console.log(error);
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });


                workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
                        console.log('# Refresh page -> ' + enableRefresh);
                        
                        console.log('# OK Refresh page #');
                        $A.get('e.force:refreshView').fire();
                    
        
                        workspaceAPI.focusTab({tabId : subTabToRefresh}).then(function(response) {
                        workspaceAPI.refreshTab({
                                tabId: subTabToRefresh,
                                includeAllSubtabs: true
                            }).catch(function(error) {
                                console.log(error);
                            });
                        });
        
                }).catch(function(error) {
                    console.log(error);
                });


            }*/
        }
    },
    onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId'); 
        console.log("Tab closed: " + tabId);
        console.log("Tab Current: " +component.get("v.subTabToClose"));
        // if (component.get("v.subTabToClose") == tabId && component.get("v.subTabToClose") ) {
        //     location.reload();
        // }
        //

    }
})