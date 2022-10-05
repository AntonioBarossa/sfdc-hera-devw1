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

        var campaignMemberId = myPageRef.state.c__campaignMemberId;
        console.log('campaignMemberId -->'+campaignMemberId);

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
        // id dell'Interaction
        var interactionId = myPageRef.state.c__interactionId;
        //id dell'activity
        var activityId = myPageRef.state.c__activityId;
        var documentPaymentMethod = myPageRef.state.c__documentPaymentMethod;

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
        console.log('# servicePointId -> '          + servicePointId);
        console.log('# billingProfileId -> '        + billingProfileId);
        console.log('# serviceRequestId -> '        + serviceRequestId);
        console.log('# compatibile -> '             + compatibile);
        console.log('# orderId -> '             + orderId);
        console.log('# interactionId -> '             + interactionId);
        console.log('# activityId -> '                  + activityId);
        console.log('# documentPaymentMethod -> '             + documentPaymentMethod);
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
            var interactionTabId;
            var orderTabId;
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
                    } else if(element.pageReference.attributes.recordId===interactionId){
                        interactionTabId = element.tabId;
                    }
                    else if(element.pageReference.attributes.recordId===orderId){
                        orderTabId = element.tabId;
                    }
                    else if(element.pageReference.attributes.recordId===parentRecordId){
                        orderTabId = element.tabId;
                    }
                }
            });
            console.log('----------');
            console.log('# accountTabId: ' + accountTabId);
            component.set("v.accountTabId", accountTabId);

            console.log('# leadTabId: ' + leadTabId);
            component.set("v.leadTabId", leadTabId);

            console.log('# interactionTabId: ' + interactionTabId);
            component.set("v.interactionTabId", interactionTabId);

            console.log('# orderTabId: ' + orderTabId);
            component.set("v.orderTabId", orderTabId);
            
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

            if(processType === 'Annullamento prestazione' || processType === 'Annullamento segnalazioni' || processType === 'Ripristina fase' || processType === 'Ripensamento'
                || processType === 'KO Definitivo' || processType === 'KO Forzato' || processType === 'KO Risolto' 
                || processType === 'Modifica dati contrattuali' || processType === 'Modifica post accertamento' || processType === 'AnnullamentoVarIndFornitura'
                || processType === 'Cessazione' || processType === 'Cessazione post accertamento' || processType === 'Reclamo da cittadino' || processType === 'Posizionamento contenitore'
                || processType === 'Annullamento comunicazione pagamenti tari' || processType ==='Annullamento doppi pagamenti tari' || processType ==='Annullamento storno rateizzazione tari' || processType ==='Annullamento errore fatturazione'
                || processType ==='Annullamento rimborso tari' || processType ==='Annullamento contratti TARI' || processType ==='Annullamento prestazione tari' || processType === 'Sospensione' || processType === 'Chiusura'){

                inputVariables.push({ name : 'ProcessType', type : 'String', value : processType });
                //Gestione Risottomissione Annullamento
                if (discardRework !== undefined){
                    inputVariables.push({ name : 'discardRework', type : 'Boolean', value : discardRework });
                    inputVariables.push({ name : 'activityId', type : 'String', value : activityId });
                } 
            }

            if(processType === 'Annullamento da activity'){
                inputVariables.push({ name : 'ProcessType', type : 'String', value : 'Annullamento prestazione' });
                inputVariables.push({ name : 'isCheckOwnerOk', type : 'Boolean', value : isUserActivity });
                inputVariables.push({ name : 'activityId', type : 'String', value : activityId });
            }

            if(processType === 'Ripristina fase da activity'){
                inputVariables.push({ name : 'ProcessType', type : 'String', value : 'Ripristina fase' });
                inputVariables.push({ name : 'isCheckOwnerOk', type : 'Boolean', value : isUserActivity });
                inputVariables.push({ name : 'discardRework', type : 'Boolean', value : discardRework });
                inputVariables.push({ name : 'activityId', type : 'String', value : activityId });
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
        if(campaignMemberId != null){
            inputVariables.push({ name : 'CampaignMemberId', type : 'String', value : campaignMemberId});
        }
        if(leadId != null){
            inputVariables.push({ name : 'LeadId', type : 'String', value : leadId});
        }
        if(servicePointId != null){
            inputVariables.push({ name : 'InputServicePointId', type : 'String', value : servicePointId});
        }
        if(billingProfileId != null){
            inputVariables.push({ name : 'BillingProfileId', type : 'String', value : billingProfileId});
        }
        if(serviceRequestId != null){
            inputVariables.push({ name : 'ServiceRequestId', type : 'String', value : serviceRequestId});
        }
        if(compatibile != null){
            inputVariables.push({ name : 'Compatibile', type : 'String', value : compatibile});
        }
        if(orderId != null){
            inputVariables.push({ name : 'OrderId', type : 'String', value : orderId});
        }        
        if(interactionId != null){
            inputVariables.push({ name : 'InteractionId', type : 'String', value : interactionId});
        }
        if(documentPaymentMethod != null){
            inputVariables.push({ name : 'DocumentPaymentMethod', type : 'String', value : documentPaymentMethod});
        }

        console.log('## inputVariables -> ');
        inputVariables.forEach(e => console.log('# ' + e.name + '- ' + e.value));

        flow.startFlow(flowName, inputVariables);
    },
    
    handleStatusChange : function (component, event, helper) {
    
       console.log('### EVENT STATUS: ' + event.getParam("status"));
       var workspaceAPI = component.find("workspace");
 
        
       if(event.getParam("status") === "FINISHED" 
       || event.getParam("status") === "FINISHED_SCREEN"
       || event.getParam("status") === "ERROR") {
			           
        
            var flowfinal = component.find("flowData");
			flowfinal.destroy();
           	component.set("v.isLoading", true);
			console.log('#isLoading >>> ' + component.get("v.isLoading"));
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

                var action = component.get("c.isMandatoryComplete"); //start call
                action.setParams({
                    "recordid" : component.get('v.recordid') 
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('RESPONSE >>> ' + response.getState());
                    if (state === "SUCCESS") {
                        component.set("v.thereIsActivity", response.getReturnValue());
                    }
                    console.log('# thereIsActivity >>>> ' + component.get('v.thereIsActivity') );
                    if( !component.get('v.thereIsActivity') ){  // error "management"
                        var toastEvent = $A.get("e.force:showToast"); // activities-to-complete error
                        toastEvent.setParams({
                            "title": "Errore",
                            "message": "Ci sono attività obbligatorie da completare.",
                            "type" : "error"
                        });
                        toastEvent.fire();
                    } else {                                    // standard error
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Errore",
                            "message": "Non è stato possibile portare a termine le operazioni.\nSi prega di contattare l'Amministratore di sistema",
                            "type" : "error"
                        });
                        toastEvent.fire();
                    }
                    helper.finishFlow(component, newCaseId);
                });
                $A.enqueueAction(action);

                
        
            }else{
                helper.finishFlow(component, newCaseId);
            }
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