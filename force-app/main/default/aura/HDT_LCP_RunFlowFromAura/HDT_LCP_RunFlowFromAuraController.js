({

    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var caseId = myPageRef.state.c__recordid;
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


        console.log('# attribute to run flow #');
        console.log('# caseId -> ' + caseId);
        component.set("v.recordid", caseId)
        console.log('# component set recordid -> '+component.get("v.recordid"))
        console.log('# flowName -> ' + flowName);
        console.log('# accId -> ' + accId);
        console.log('# processType -> ' + processType);
        console.log('# recordTypeName -> ' + recordTypeName);
        //console.log('# cluster -> ' + cluster);
        console.log('# recordToCancell -> ' + recordToCancell);
        console.log('# sObjectRecordToCancell -> ' + sObjectRecordToCancell);
        console.log('# context -> '+context);
        console.log('# parentRecordId -> ' +parentRecordId);
        console.log('# campaignId -> ' + campaignId)
        console.log('# leadId -> ' + leadId);
        console.log('# ----------------- #');

        var workspaceAPI = component.find("workspace");
        var flow = component.find("flowData");
        var subTabToClose;

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
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
            });
            console.log('----------');
            console.log('# accountTabId: ' + accountTabId);
            component.set("v.accountTabId", accountTabId);

            console.log('# leadTabId: ' + leadTabId);
            component.set("v.leadTabId", leadTabId);
            
            console.log('# subTabToClose: ' + subTabToClose);
            component.set("v.subTabToClose", subTabToClose);
        });

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
            if(processType === 'Annullamento prestazione' || processType === 'Ripristina fase' || processType === 'Ripensamento'){
                inputVariables.push({ name : 'ProcessType', type : 'String', value : processType });
            }

            component.set('v.enableRefresh', true);
        }
        if(recordToCancell != null)
                inputVariables.push({ name : 'recordToCancell', type : 'String', value : recordToCancell });
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
        }
        if(campaignId != null){
            inputVariables.push({ name : 'CampaignId', type : 'String', value : campaignId});
        }
        if(leadId != null){
            inputVariables.push({ name : 'LeadId', type : 'String', value : leadId});
        }

        console.log('## inputVariables -> ');
        inputVariables.forEach(e => console.log('# ' + e.name + '- ' + e.value));

        flow.startFlow(flowName, inputVariables);

    },
    
    handleStatusChange : function (component, event) {
    
       console.log('### EVENT STATUS: ' + event.getParam("status"));
       var workspaceAPI = component.find("workspace");

       if(event.getParam("status") === "FINISHED" 
       || event.getParam("status") === "FINISHED_SCREEN"
       || event.getParam("status") === "ERROR") {

            var accountTabId = component.get("v.accountTabId");
            var leadTabId = component.get("v.leadTabId");
            var subTabToClose = component.get("v.subTabToClose");
            var enableRefresh = component.get('v.enableRefresh');
            var flowfinal = component.find("flowData");
                
            if(event.getParam("status") === "ERROR"){
                //Sembra non esserci nella struttura dell'event il messaggio di errore
                /*event: {
                    "_name":"",
                    "_source":{},
                    "_params":{
                        "status":"ERROR",
                        "flowTitle":"Gestione Annullamento",
                        "showHeader":true,
                        "guid":"5576e83980290edaf4536891f79f179e6928cf-b934"
                    },
                    "target":null,
                    "currentTarget":null}
                */
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

            console.log('# recordid -> ' +component.get("v.recordid"));
            if(outputVariables != null){      
                for(var i = 0; i < outputVariables.length; i++) {
                    outputVar = outputVariables[i];
                    
                    if(outputVar.name === "CaseId") {
                        newCaseId = outputVar.value;
                    }
                }
            }else{
                newCaseId=component.get("v.recordid");
            }

            console.log('# outputVariable -> '+outputVariables);
            console.log('# newCaseId -> '+newCaseId);
            //Gestione chiusura errore in creazione
            if(newCaseId == null || newCaseId == undefined){
                
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


                /*workspaceAPI.closeTab({ tabId: subTabToClose }).then(function(response) {
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
                });*/


            }
        }
    }
})