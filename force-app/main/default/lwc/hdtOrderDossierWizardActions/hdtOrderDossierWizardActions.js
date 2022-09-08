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
import { getRecord } from 'lightning/uiRecordApi';
import SIGN_FIELD from '@salesforce/schema/Order.SignatureMethod__c';
import SEND_FIELD from '@salesforce/schema/Order.DocSendingMethod__c';import getPicklistValue from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.getActivePicklistValue';
import RequestSource from '@salesforce/schema/Order.RequestSource__c';
import WasteCommodityType from '@salesforce/schema/Order.WasteCommodityType__c';
import SIGNED_FIELD from '@salesforce/schema/Order.ContractSigned__c';
//Il seguente campo è stato utilizzato per tracciare l'ultimo SignatureMethod inviato a docusign.
import OLDSIGN_FIELD from '@salesforce/schema/Order.SignMode__c';
import CHANNEL_FIELD from '@salesforce/schema/Order.Channel__c';
import isOnlyAmend from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.isOnlyAmend';
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
    isCommunity=false;

    get disablePrintButtonFunction() {
        return this.isPrintButtonDisabled  || (this.signatureMethod == 'Vocal Order' && (this.isVocalAndActivityNotClose && this.orderParentRecord.Phase__c != 'Documentazione da validare' && (this.channel !== null && this.channel == 'Teleselling Outbound')));
    }

    get disablePreviewButton(){
        return this.isPreviewForbidden || this.isSaveButtonDisabled;
    }

    @wire(getPicklistValue,{objectApiName: 'Order', fieldApiName: 'SignMode__c'})
    activeValue;

    @wire(getRecord, { recordId: '$recordId', fields: [SIGN_FIELD,SEND_FIELD,SIGNED_FIELD,OLDSIGN_FIELD, CHANNEL_FIELD,RequestSource,WasteCommodityType] })
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
            // 28/12/2021: commentata logica che disabilita il component documentale, poichè deve sempre essere visibile nel wizard.
            //this.enableDocumental = !signed;
            console.log('### Signature method >>> ' + this.signatureMethod)
            console.log('### ParentOrder Channel >>> ' + this.channel);
            this.enableDocumental = this.signatureMethod !== 'Contratto già firmato';
            if(this.commodityType && this.provenienza && this.commodityType === 'Ambiente' && this.provenienza != 'Da contribuente'){
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
                    getCachedUuid().then(uuid => {
                        if(this.isCommunity && uuid) {
                            this.isPreviewForbidden = false;
                            this.isModalOpen = true;
                        } else {
                            this.handlePreview();
                        }
                    }).catch(error =>{
                        console.error(error);
                        this.isPreviewForbidden = false;
                    });
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
                let data = JSON.parse(result);
                console.log('DATA.ISCOMMUNITY -->'+data.isCommunity);
                 if(data.isCommunity){
                    this.saveScript(data.campaignMemberStatus, true);
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
                        this.showMessage('Attenzione',resultParsed.message,'warning');
                        this.previewExecuted = true;
                        this.isPrintButtonDisabled = false;
                        this.loading = false;
                        return;
                    }
                    if(resultParsed.code === '200' || resultParsed.code === '201'){
                        if(resultParsed.result === '000'){
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
                        }else{
                            this.loading = false;
                            this.showMessage('Attenzione',resultParsed.message,'error');
                        }
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
        save({orderParent: this.orderParentRecord}).then(data =>{
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
        this.getSaveButtonStatus();
        this.getIsOnlyAmend();
        this.getCancelButtonStatus();
        this.getActivityVocalOrder();
        //this.getFraud();
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

    saveScript(esito, isResponsed) {
        // LOAD TOOLBAR STUFF
        Promise.all([
            loadScript(this, cttoolbar)
        ])
        .then(() => {
            getCachedUuid()
            .then(uuid => {
                console.log('CACHED UUID: ' + uuid);
                window.TOOLBAR.EASYCIM.saveScript(uuid, esito, isResponsed);
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