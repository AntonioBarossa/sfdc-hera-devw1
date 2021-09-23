import { LightningElement, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getActivity from '@salesforce/apex/HDT_QR_ActivityCustom.getRecordByOrderIdAndType';
import saveActivityVO from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.createActivityVocalOrder'
import save from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.save';
import save2 from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.save2';
import cancel from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.cancel';
import isSaveDisabled from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.isSaveDisabled';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import { getRecord } from 'lightning/uiRecordApi';
import SIGN_FIELD from '@salesforce/schema/Order.SignatureMethod__c';
import SEND_FIELD from '@salesforce/schema/Order.DocSendingMethod__c';
import SIGNED_FIELD from '@salesforce/schema/Order.ContractSigned__c';

export default class hdtOrderDossierWizardActions extends NavigationMixin(LightningElement) {
    
    @api orderParentRecord;
    @api recordId
    currentStep = 2;
    loading = false;
    signatureMethod = '';
    isSaveButtonDisabled = false;
    isCancelButtonDisabled = false;
    isDialogVisible = false;
    isPrintButtonDisabled = true;
    isOrderPhaseToCheck = true;
    parentOrder;
    isVocalAndActivityNotClose = true;
    enableDocumental = false;


    get disablePrintButtonFunction() {
        return this.isPrintButtonDisabled  || (this.signatureMethod == 'Vocal Order' && (this.isVocalAndActivityNotClose && this.orderParentRecord.Phase__c != 'Documentazione da validare'));
    }


    @wire(getRecord, { recordId: '$recordId', fields: [SIGN_FIELD,SEND_FIELD,SIGNED_FIELD] })
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
            var signed = this.parentOrder.fields.ContractSigned__c.value;
            this.signatureMethod = data.fields.SignatureMethod__c.value;
            this.enableDocumental = !signed;
        }
    }

    getCancelButtonStatus(){
        if (this.orderParentRecord.Status === 'Completed') {
            this.isCancelButtonDisabled = true;
        }
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

    handlePreview(){
        try{
            
            this.loading = true;
            var formParams = {
                mode : 'Preview',
                Archiviato : 'N',
            };
            saveActivityVO({
                orderParent : this.orderParentRecord
            }).then(result => {
                if(result == 'Documentazione da validare'){
                    this.orderParentRecord.Phase__c = 'Documentazione da validare';
                }
                previewDocumentFile({
                    recordId: this.recordId,
                    context: 'Order',
                    formParams: JSON.stringify(formParams)
                }).then(result => {
                    var resultParsed = JSON.parse(result);
                    if(resultParsed.code === '200' || resultParsed.code === '201'){
                        if(resultParsed.result === '000'){
                            var base64 = resultParsed.base64;
                            var sliceSize = 512;
                            base64 = base64.replace(/^[^,]+,/, '');
                            base64 = base64.replace(/\s/g, '');
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
                        }else{
                            this.loading = false;
                            this.showMessage('Attenzione',resultParsed.message,'error');
                        }
                    }else{
                        this.loading = false;
                        this.showMessage('Attenzione','Errore nella composizione del plico','error');
                    }
                    this.isPrintButtonDisabled = false;
                })
                .catch(error => {
                    this.loading = false;
                    console.error(error);
                });
            });
        }catch(error){
            console.error();
        }
        this.isPrintButtonDisabled = false;
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
            if(sendMode.localeCompare('Stampa Cartacea')===0){
                sendMode = 'Sportello';
            }
            var formParams = {
                sendMode : sendMode,
                signMode : signMode,      
                mode : 'Print',
                Archiviato : 'Y'
            }
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
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
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
        this.getCancelButtonStatus();
        this.getActivityVocalOrder();
    }

    getActivityVocalOrder(){
        getActivity({
            orderId: this.recordId,
            type: 'Validazione Vocal Order'
        }).then(result => {
            console.log('*********2:' + JSON.stringify(result));
            if(result != undefined && result != null && result.length > 0 && result[0].wrts_prcgvr__Status__c == 'Completed' && result[0].Validation__c == 'Si'){
                this.isVocalAndActivityNotClose = false;
            }
        })
        .catch(error => {
            this.loading = false;
            console.error(error);
        });
    }

}