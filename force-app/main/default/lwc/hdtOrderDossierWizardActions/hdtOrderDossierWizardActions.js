import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';    // params: n/a
import getActivity from '@salesforce/apex/HDT_QR_ActivityCustom.getRecordByOrderIdAndType';
import saveActivityVO from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.createActivityVocalOrder'
import seekFraud from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.seekFraud';
import save from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.save';
import save2 from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.save2';
import cancel from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.cancel';
import isSaveDisabled from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.isSaveDisabled';
import isCommunity from '@salesforce/apex/HDT_LC_SellingWizardController.checkCommunityLogin';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import createActChangeAddress from '@salesforce/apex/HDT_LC_DocumentSignatureManager.createActChangeAddress';
import { getRecord } from 'lightning/uiRecordApi';
import SIGN_FIELD from '@salesforce/schema/Order.SignatureMethod__c';
import SEND_FIELD from '@salesforce/schema/Order.DocSendingMethod__c';
import getPicklistValue from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.getActivePicklistValue';
import RequestSource from '@salesforce/schema/Order.RequestSource__c';
import WasteCommodityType from '@salesforce/schema/Order.WasteCommodityType__c';
import SIGNED_FIELD from '@salesforce/schema/Order.ContractSigned__c';
//Il seguente campo è stato utilizzato per tracciare l'ultimo SignatureMethod inviato a docusign.
import OLDSIGN_FIELD from '@salesforce/schema/Order.SignMode__c';
import CHANNEL_FIELD from '@salesforce/schema/Order.Channel__c';
import DELIVERED_DOC from '@salesforce/schema/Order.DeliveredDocumentation__c';
import isOnlyAmend from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.isOnlyAmend';
import getEcid from '@salesforce/apex/HDT_LC_CampaignsController.getEcid';
import getCurrentProfile from '@salesforce/apex/HDT_LC_CampaignsController.getCurrentProfile';

// TOOLBAR STUFF
import { loadScript } from 'lightning/platformResourceLoader';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
export default class hdtOrderDossierWizardActions extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @api orderParentRecord;
    @api recordId
    @api discardRework;
    @api discardActivityId;
    isPreviewForbidden = false;
    currentStep = 2;
    loading = false;
    channel = '';
    provenienza = '';
    commodityType='';
    signatureMethod = '';
    isSaveButtonDisabled = false;
    isCancelButtonDisabled = false;
    isDialogVisible = false;
    isPrintButtonDisabled = true;
    isOrderPhaseToCheck = true;
    parentOrder;
    isVocalAndActivityNotClose = true;
    enableDocumental = true;
    isAmend = false;
    @track isFraud = false;
    @track firstLoginTime;
    @track currentUserProfile;
    isCommunity=false;
    @track cmAgentState = '';

    get disablePrintButtonFunction() {
        return this.isPrintButtonDisabled  || (this.signatureMethod == 'Vocal Order' && (this.isVocalAndActivityNotClose && this.orderParentRecord.Phase__c != 'Documentazione da validare' && (this.channel !== null && this.channel == 'Teleselling Outbound')));
    }

    get disablePreviewButton(){
        return this.isPreviewForbidden || this.isSaveButtonDisabled;
    }
    @api
    disableSendButton(){
        console.log('in disableSendButton');
        this.isPrintButtonDisabled = true;
        this.isPreviewForbidden = false;
    }
    @wire(getPicklistValue,{objectApiName: 'Order', fieldApiName: 'SignMode__c'})
    activeValue;

    @wire(getRecord, { recordId: '$recordId', fields: [SIGN_FIELD,SEND_FIELD,SIGNED_FIELD,OLDSIGN_FIELD, CHANNEL_FIELD,RequestSource,WasteCommodityType,DELIVERED_DOC] })
    wiredParentOrder({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Order',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.parentOrder = data;
            //var signed = this.parentOrder.fields.ContractSigned__c.value;
            this.signatureMethod = data.fields.SignatureMethod__c.value;
            this.channel = data.fields.Channel__c.value;
            this.commodityType = data.fields.WasteCommodityType__c.value 
            this.provenienza = data.fields.RequestSource__c.value;
            var deliveredDoc = data.fields.DeliveredDocumentation__c.value;
            // 28/12/2021: commentata logica che disabilita il component documentale, poichè deve sempre essere visibile nel wizard.
            //this.enableDocumental = !signed;
            console.log('### Signature method >>> ' + this.signatureMethod)
            console.log('### ParentOrder Channel >>> ' + this.channel);
            this.enableDocumental = this.signatureMethod !== 'Contratto già firmato';
            if(this.commodityType && this.provenienza && this.commodityType === 'Ambiente' && (this.provenienza != 'Da contribuente' || deliveredDoc)){
                this.enableDocumental = false;
            }
        }
    }

    getCancelButtonStatus(){
        if (this.orderParentRecord.Status === 'Completed') {
            this.isCancelButtonDisabled = true;
        }
    }

    getIsOnlyAmend(){
        isOnlyAmend({orderParent: this.orderParentRecord}).then(data =>{
            console.log('isOnlyAmend: ', data);
            this.isAmend = data;

        }).catch(error => {
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    getSaveButtonStatus(){
        this.loading = true;
        isSaveDisabled({orderParent: this.orderParentRecord}).then(data =>{
            console.log('isSaveDisabled: ', data);
            this.loading = false;
            this.isSaveButtonDisabled = data;

        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    checkReitekStatus(){
       
        if(this.currentUserProfile === 'Hera Teleseller Partner User'){
            let getAgentIDPromise =  window.TOOLBAR.AGENT.getAgentID();
            let isTimeOver = false;

            let timeout = setTimeout(() => {
                
                console.log("Scattato il timeout della promise, verrà eseguito il codice del timeout");
                isTimeOver = true;
                const evt = new ShowToastEvent({
                    title: 'Attenzione!',
                    message: 'Non è stato possibile verificare lo stato della barra.',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                console.log('PRIMA DI NEW SALE');
                this.cmAgentState = 'AGENT:LOGGEDOUT';
                this.handleModalPreview();
                console.log('DOPO NEW SALE');
            }, 2000);
            
            console.log('DOPO TIMEOUT');

            getAgentIDPromise.then((data) => {
                window.clearTimeout(timeout);
                if (!isTimeOver) {
                    console.log('getAgentID SUCCESS');
                    if (typeof data !== "undefined") {
                        console.log('data != undefined');
                        window.TOOLBAR.AGENT.getAgentStateByID(data).then((agentState) => {
                            console.log('getAgentStateByID SUCCESS');
                            if (typeof agentState === "object") {
                                console.log('agentState = OBJECT');
                                console.log("ID:", agentState.ID, "FirstLoginTime:", agentState.FirstLoginTime, "agentState:", agentState);
                                this.firstLoginTime = agentState.FirstLoginTime;
                                console.log('ARRIVATO PRIMA DI LANCIO CHECK OPEN SCRIPT');
                                this.cmAgentState = agentState.State;
                                console.log('this.cmAgentState --> '+this.cmAgentState);
                                this.handleModalPreview();
                            }
                        }).bind(this), error => {
                            console.log('getAgentStateByID ERROR');
                            console.log(error)
                        };
                    }
                    console.log("Promise risolta, codice eseguito");
                } else {
                    isTimeOver = false
                    console.log("Promise risolta dopo il timeout, NON è stato eseguita il codice nella THEN");
                }
            }).catch(err => {
                    console.log('getAgentIDPromise ERROR');
                    console.log(err);
            });  
        }else{
            this.handleModalPreview();
        }              
    }

    handleModalPreview(){
        this.isPreviewForbidden = true;
        
        /*if( this.isFraud ){
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Possibile frode in corso, tutti gli ordini correlati verranno annullati.',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
        }else{
            console.log('Nessuna Frode in corso');
        }*/
        console.log('### Start Fraud ###');
        this.loading = true;
        seekFraud({recordId: this.recordId, orderParent: this.orderParentRecord}).then(result =>{
            console.log('### Fraud Result >>> ' + result);
            this.loading = false;

            var resultParsed = JSON.parse(result);
            console.log('### Is Fraud >>> ' + resultParsed.isFraud);
            this.isFraud = resultParsed.isFraud;

            if(this.isFraud)
            {
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Attenzione!',
                    message: 'Possibile frode in corso, tutti gli ordini correlati verranno annullati.',
                    variant: 'warning'
                });
                this.dispatchEvent(toastSuccessMessage);
                this.dispatchEvent(new CustomEvent('redirecttoorderrecordpage'));
                return;
            }
            else
            {

                isCommunity().then(result => {
                    this.isCommunity = result;
                    // getCachedUuid().then(uuid => {
                    //     if(this.isCommunity && uuid) {
                    //         this.isPreviewForbidden = false;
                    //         this.isModalOpen = true;
                    //     } else {
                    //         this.handlePreview();
                    //     }
                        
                    // }).catch(error =>{
                    //     console.error(error);
                    //     this.isPreviewForbidden = false;
                    // });
                    this.handlePreview();
                }).catch(error => {
                    this.loading = false;
                    console.error(error);
                    this.isPreviewForbidden = false;
                });
            }
        })
        .catch(error => {
            console.log('#FRAUD_ERROR >>> ' + JSON.stringify(error));
        })
        
    }

    handlePreview(){
        try{
            console.log('Entrato in handlePreview.');
            console.log('this.orderParentRecord --> '+this.orderParentRecord);
            this.loading = true;
            var sendMode = this.parentOrder.fields.DocSendingMethod__c.value;
            var signMode = this.parentOrder.fields.SignatureMethod__c.value; 
            if(sendMode.localeCompare('Stampa Cartacea')===0){
                sendMode = 'Sportello';
            }
            var formParams = {
                mode : 'Preview',
                Archiviato : 'N',
                sendMode : sendMode,
                signMode : signMode,
            };
            console.log('punto 1');

            saveActivityVO({
                orderParent : this.orderParentRecord
            }).then(result => {
                console.log('ENTRATO IN SAVEACTIVITYVO'); 
                let data = JSON.parse(result);
                console.log('DATA.ISCOMMUNITY -->'+data.isCommunity);
                console.log('DATA --> '+JSON.stringify(data));
                 if(data.isCommunity && this.currentUserProfile === 'Hera Teleseller Partner User'){
                    // if(this.isCommunity && this.currentUserProfile === 'Hera Teleseller Partner User'){ //IF TEMPORANEO PER FAR FUNZIONARE PREVIEW [HRADTR_GV]
                    let campaignMemberId = data.campaignMemberId;
                    let campaignMemberStatus = data.campaignMemberStatus;
                    let ecid;
                    console.log('campaignMemberId --> '+campaignMemberId);
                    console.log('campaignMemberStatus --> '+campaignMemberStatus);
                    console.log('this.cmAgentState 2 --> '+this.cmAgentState);
                    //ottenimento ecid da campaignMember/callout
                    if(this.cmAgentState !== 'AGENT:PAUSE' && this.cmAgentState !== 'AGENT:LOGGEDOUT'){
                        getEcid({ 'campaignMemberId': campaignMemberId}).then(data => {
                            console.log("getEcid launch SUCCESS --> " + JSON.stringify(data));
                            ecid = data;
                            console.log('getEcid ecid --> '+ecid);
                            //controllo openScript con parametro ecid
                            if(ecid != null && ecid != undefined && ecid != ''){
                                let ecidLoginTime;
                                let openScriptNotPresent;
                                console.log('checkValidityOpenScript START');
                                if(localStorage.getItem("openScript-"+ecid) != null){
                                    console.log('checkValidityOpenScript PUNTO 1');
                                    ecidLoginTime = localStorage.getItem("openScript-"+ecid);
                                    console.log('checkValidityOpenScript PUNTO 2');
                                    console.log('ecidLoginTime --> '+ecidLoginTime);
                                    console.log('firstLoginTime --> '+this.firstLoginTime);
        
                                    if(ecidLoginTime < this.firstLoginTime){
                                        console.log('checkValidityOpenScript PUNTO 3');
                                        localStorage.removeItem("openScript-"+ecid);
                                        console.log('checkValidityOpenScript PUNTO 4');
                                        openScriptNotPresent = true;
                                    }
                                    else{
                                        console.log('checkValidityOpenScript PUNTO 5');
                                        openScriptNotPresent = false;
                                    }
                                }
                                else{
                                    openScriptNotPresent = true;
                                }
                                console.log('#### PUNTO 3 checkOpenScript ####');
        
                                if(openScriptNotPresent === true){
        
                                    console.log('#### PUNTO 5 checkOpenScript ####');
        
                                    window.TOOLBAR.EASYCIM.openScript("", ecid, true).then((data => {
                                        console.log('Nuova Vendita OrderDossierWizardActions OPENSCRIPT ESEGUITA');
                                        console.log('#### PUNTO 6 checkOpenScript ####');
        
                                        console.log('## data --> '+JSON.stringify(data));
                                        console.log('## data.result --> '+data.result);
                                        console.log('## data.terminated --> '+data.terminated);
                                        console.log('## data.readOnly --> '+data.readOnly);
        
                                        if(data && data.result == true && data.terminated != true && data.readOnly != true){
                                            console.log('data OK');
                                            localStorage.setItem("openScript-"+ecid , Date.now());
                                            console.log('data.campaignMemberStatus --> '+campaignMemberStatus);
                                            this.saveScript(ecid, campaignMemberStatus, true);
                                            console.log('value saved --> ',localStorage.getItem("openScript-"+ecid));
                                            console.log('### PUNTO 10 : data --> ',data,' ###');   
                                        }
                                        else{
                                            console.log('#### PUNTO 10.1 ####');
                                            console.log('## readOnly = true #');
                                            console.log('## data --> '+JSON.stringify(data));
                                            console.log('## data.result --> '+data.result);
                                            console.log('## data.terminated --> '+data.terminated);
                                            console.log('## data.readOnly --> '+data.readOnly);
                                            //####  blocco attività  ####
                                            try {
                                                console.log('### PUNTO 10.2 ###');
                                                //alert("Errore! Non puoi effettuare la chiamata in questo momento.");
                                                const evt = new ShowToastEvent({
                                                    title: 'Errore',
                                                    message: 'Il contatto è in gestione lato EasyCIM da altro operatore.',
                                                    variant: 'warning',
                                                    mode: 'dismissable'
                                                });
                                                this.dispatchEvent(evt);
                                                console.log('#### PUNTO 11 ####');
                                            } catch (error) {
                                                console.error('ERRORE --> ',error);
                                            }
                                        }
                                        
                                    }).bind(this), error => {
                                        console.log('ERROR')
                                        console.log(error)
                                    });
                                }
                                else{
                                    console.log('openScript non eseguita perché già effettuata');
                                    console.log('data.campaignMemberStatus --> '+campaignMemberStatus);
                                    console.log('data.ecid --> '+ecid);
                                    this.saveScript(ecid, campaignMemberStatus, true);

                                }
                            }
                            else{
                                console.log('ecid non valorizzato');
                            }
                        }).catch(err => {
                            console.log(err);
                        });
                    }
                    else{
                        const evt = new ShowToastEvent({
                            title: 'Attenzione!',
                            message: 'Per proseguire verificare che lo stato della barra sia "disponibile". ',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                }
                if(data.orderPhase == 'Documentazione da validare'){
                    this.orderParentRecord.Phase__c = 'Documentazione da validare';
                }
                previewDocumentFile({
                    recordId: this.recordId,
                    context: 'Order',
                    formParams: JSON.stringify(formParams)
                }).then(result => {
                    var resultParsed = JSON.parse(result);
                    if(resultParsed.status === 'sizeLimit')
                    {
                        console.log('PUNTO 1 sizeLimit INIZIO');
                        this.showMessage('Attenzione',resultParsed.message,'warning');
                        this.previewExecuted = true;
                        this.isPrintButtonDisabled = false;
                        this.loading = false;
                        console.log('PUNTO 2 sizeLimit FINE');
                        return;
                    }
                    if(resultParsed.code === '200' || resultParsed.code === '201'){
                        console.log('PUNTO 3 CODE 200 || 201 INIZIO');

                        if(resultParsed.result === '000'){
                            console.log('PUNTO 4 RESULT 000 INIZIO');
                            var base64 = resultParsed.base64;
                            var sliceSize = 512;
                            var byteCharacters = window.atob(base64);
                            var byteArrays = [];
                            for ( var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize ) {
                                var slice = byteCharacters.slice(offset, offset + sliceSize);
                                var byteNumbers = new Array(slice.length);
                                for (var i = 0; i < slice.length; i++) {
                                    byteNumbers[i] = slice.charCodeAt(i);
                                }
                                var byteArray = new Uint8Array(byteNumbers);

                                byteArrays.push(byteArray);
                            }
                            this.blob = new Blob(byteArrays, { type: 'application/pdf' });
                            const blobURL = URL.createObjectURL(this.blob);
                            this.loading = false;
                            this[NavigationMixin.Navigate](
                                {
                                    type: 'standard__webPage',
                                    attributes: {
                                        url: blobURL
                                    }
                                }
                            );
                            this.previewExecuted = true;
                            this.isPrintButtonDisabled = false;
                            console.log('PUNTO 5 RESULT 000 FINE');

                            console.log('FLAG METODO GET ABILITAZIONE - INIZIO');
                            console.log('this.isPrintButtonDisabled --> '+this.isPrintButtonDisabled);
                            console.log('this.signatureMethod --> '+this.signatureMethod);
                            console.log('this.isVocalAndActivityNotClose --> '+this.isVocalAndActivityNotClose);
                            console.log('this.orderParentRecord.Phase__c --> '+this.orderParentRecord.Phase__c);
                            console.log('this.channel --> '+this.channel);
                            console.log('FLAG METODO GET ABILITAZIONE - INIZIO');


                        }else{
                            console.log('PUNTO 6 RESULT 000 ELSE INIZIO');

                            this.loading = false;
                            this.showMessage('Attenzione',resultParsed.message,'error');
                            console.log('resultParsed --> '+JSON.stringify(resultParsed));
                            console.log('PUNTO 7 RESULT 000 ELSE FINE');

                        }
                        console.log('PUNTO 8 CODE 200 || 201 FINE');

                    }else{
                        this.loading = false;
                        this.showMessage('Attenzione','Errore nella composizione del plico','error');
                    }
                    if(this.signatureMethod == 'Vocal Order' && (this.isVocalAndActivityNotClose && this.orderParentRecord.Phase__c != 'Documentazione da validare' && (this.channel !== null && this.channel == 'Telefono Outbound'))){
                        const toastSuccessMessage = new ShowToastEvent({
                            title: 'Successo',
                            message: 'Ordine sottomesso, in attesa validazione',
                            variant: 'success',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(toastSuccessMessage);
                    }
                    this.isPreviewForbidden = false;
                })
                .catch(error => {
                    console.log('ERROR 1');
                    this.loading = false;
                    const toastSuccessMessage = new ShowToastEvent({
                        title: 'Attenzione!',
                        message: 'La dimesione del plico è superiore al limite consentito per la preview. Procedere con l\'invio dei documenti al cliente',
                        variant: 'warning',
                        mode: 'pester'
                    });
                    this.dispatchEvent(toastSuccessMessage);
                    console.error(error);
                    this.previewExecuted = true;
                    this.isPrintButtonDisabled = false;
                });
            }).catch(error => {
                console.log('ERROR 2');
                this.loading = false;
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Errore nella procedura di creazione dell\'activity.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastSuccessMessage);
                console.error(error);
                this.isPreviewForbidden = false;
            });
        }catch(error){
            this.loading = false;
            this.isPreviewForbidden = false;
            console.error();
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    confirmPreview() {
        this.isPreviewForbidden = true;
        this.closeModal();
        this.handlePreview();
        
    }

    showMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

    sendDocumentFile(){
        this.loading = true;
        try{
            var sendMode = this.parentOrder.fields.DocSendingMethod__c.value;
            var signMode = this.parentOrder.fields.SignatureMethod__c.value; 
            var oldSignMode = this.parentOrder.fields.SignMode__c.value;
            if(sendMode.localeCompare('Stampa Cartacea')===0){
                sendMode = 'Sportello';
            }
            var discardOldEnvelope = false;
            if (signMode.localeCompare('OTP Remoto') === 0 && oldSignMode && oldSignMode.localeCompare('OTP Coopresenza') === 0){
                discardOldEnvelope = true;
            }
            console.log('discardRework --> '+this.discardRework);
            console.log('discardActivityId --> '+this.discardActivityId);
            var formParams = {
                sendMode : sendMode,
                signMode : signMode,      
                mode : 'Print',
                Archiviato : 'Y',
                DiscardOldEnvelope : discardOldEnvelope,
                discardRework : this.discardRework,
                discardActivityId : this.discardActivityId
            }
            console.log('formParams --> '+JSON.stringify(formParams));
            sendDocument({
                recordId: this.recordId,
                context: 'Order',
                formParams: JSON.stringify(formParams)
            }).then(result => {
                this.handleSave2();
            }).catch(error => {
                this.showToast('Errore nell\'invio del documento al cliente.');
                console.error(error);
            });
        }catch(error){
            console.error(error);
        }
    }

    handleSave(){
        this.loading = true;

        createActChangeAddress({
            recordId: this.recordId
        }).then(result => {
            console.log('CreateActChangeAddress successfully run');
        }).catch(error => {
            this.showToast('Errore nella creazione dell\'activity di Modifica Indirizzo Fornitura.');
            console.error(error);
        });

        save({orderParent: this.orderParentRecord}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('redirecttoorderrecordpage'));
            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Order confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }

    handleSave2(){
        this.loading = true;
        //Impedisco l'errore "TypeError: 'set' on proxy: trap returned falsish for property 'SignMode__c'"
        this.orderParentRecord = JSON.parse(JSON.stringify(this.orderParentRecord))
        //Se l'invio va a buon fine il signMode utilizzato viene sallvato nel campo SignMode.
        var signMode = this.parentOrder.fields.SignatureMethod__c.value
        let newSignMode;
        try{
            if (this.activeValue){
                this.activeValue.data.forEach((element) => {
                    if (element && element.localeCompare(signMode) === 0){
                        newSignMode = signMode;
                    }
                });
            }
        }catch(e){
            console.error(e);
        }
        this.orderParentRecord.SignMode__c = newSignMode;
        save2({orderParent: this.orderParentRecord,isPlicoSend:true}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoorderrecordpage'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Order confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
            //this.sendDocumentFile();

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    callCancel(cancellationReason){
        this.loading = true;
        cancel({orderParent: this.orderParentRecord, cancellationReason: cancellationReason}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoorderrecordpage'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Order annullato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            let errorMessage;
            try{
                errorMessage = error.body.pageErrors[0].message;
            }catch (e){
                errorMessage = (error.body.message !== undefined) ? error.body.message : error.message;
            }
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleCancel(){
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){
            this.callCancel(event.detail.choice);

        } else {
            this.isDialogVisible = false;
        }
    }

    connectedCallback(){
        console.log('ENTRATO IN CONNECTED CALLBACK');

        this.getSaveButtonStatus();
        this.getIsOnlyAmend();
        this.getCancelButtonStatus();
        this.getActivityVocalOrder();

        this.getFirstLoginTime();
        //this.getFraud();
    }

    getFirstLoginTime(){

        isCommunity().then(result => {
            console.log('isCommunity START');
            this.isCommunity = result;
            console.log('THIS.isCommunity --> '+this.isCommunity);

            getCurrentProfile({ 'campaignMemberId': this.recordId}).then(data => {
                this.currentUserProfile = data;

                if(this.isCommunity === true && this.currentUserProfile === 'Hera Teleseller Partner User'){
                    console.log('isCommunity TRUE');
    
                    window.TOOLBAR.AGENT.getAgentID().then((data) => {
                        if (typeof data !== "undefined") {
                            window.TOOLBAR.AGENT.getAgentStateByID(data).then((agentState) => {
                                if (typeof agentState === "object") {
                                    console.log("ID:", agentState.ID, "FirstLoginTime:", agentState.FirstLoginTime, "agentState:", agentState);
                                    this.firstLoginTime = agentState.FirstLoginTime;
                                    console.log('THIS.FIRSTLOGINTIME --> '+this.firstLoginTime);
                                    if(agentState.State === 'AGENT:PAUSE'){
                                        const evt = new ShowToastEvent({
                                            title: 'Attenzione!',
                                            message: 'Per proseguire verificare che lo stato della barra sia "disponibile". ',
                                            variant: 'warning',
                                            mode: 'dismissable'
                                        });
                                        this.dispatchEvent(evt);
                                    }
                                }
                            });
                        }
                    });
                }
                else{
                    console.log('isCommunity non valorizzato');
                    console.log('Profilo diverso da teleseller');
                }
                
            }),error => {
                console.log('getCurrentProfile ERROR');
                console.log(error);
            };  


            
        }).catch(error => {
            console.error(error);
        });

        
    }

    getActivityVocalOrder(){
        getActivity({
            orderId: this.recordId,
            type: 'Validazione Vocal Order'
        }).then(result => {
            console.log('*********2:' + JSON.stringify(result));
            if(result != undefined && result != null && result.length > 0 && result[0].wrts_prcgvr__Status__c == 'Chiusa' && result[0].Validation__c == 'Si'){
                this.isVocalAndActivityNotClose = false;
            }
        })
        .catch(error => {
            this.loading = false;
            console.error(error);
        });
    }

    saveScript(ecid, esito, isResponsed) {
        // LOAD TOOLBAR STUFF
        Promise.all([
            loadScript(this, cttoolbar)
        ])
        .then(() => {
            // getCachedUuid()
            // .then(uuid => {
            //     console.log('CACHED UUID: ' + uuid);
            //     window.TOOLBAR.EASYCIM.saveScript(uuid, esito, isResponsed);
            //     console.log('SAVESCRIPT DONE');
            // });
            console.log('data.ecid --> '+ecid);
            // window.TOOLBAR.EASYCIM.saveScript(ecid, esito, isResponsed);
            console.log('SAVESCRIPT RESULT 1A localStorage.getItem("openScript-"'+ecid+') --> '+localStorage.getItem("openScript-"+ecid));
            window.TOOLBAR.EASYCIM.saveScript(ecid, esito, isResponsed)
            .then((data) => {
                console.log('SAVESCRIPT RESULT DATA --> '+data);
                if(data){
                    localStorage.removeItem("openScript-"+ecid);
                    console.log('SAVESCRIPT RESULT 1B localStorage.getItem("openScript-"'+ecid+') --> '+localStorage.getItem("openScript-"+ecid));
                }
                console.log('SAVESCRIPT DONE');
            });

        })
        .catch(error => console.error(error));
    }

    getFraud(){
        this.loading = true;
        
        seekFraud({recordId: this.recordId, orderParent: this.orderParentRecord}).then(result =>{
            this.loading = false;

            var resultParsed = JSON.parse(result);
            this.isFraud = resultParsed.isFraud;

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: result.get('message'),
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';
            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }
            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

}