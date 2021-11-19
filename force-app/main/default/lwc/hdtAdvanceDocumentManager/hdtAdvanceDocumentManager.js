import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendAdvanceDocumentation from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendAdvanceDocumentation';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import PHONE_NUMBER_FIELD from '@salesforce/schema/Order.PhoneNumber__c';
import ID_ORDER_FIELD from '@salesforce/schema/Order.Id';
import IS_PRE_DOC_TO_SEND from '@salesforce/schema/Order.isPreDocumentationToSend__c';
import EMAIL_FIELD from '@salesforce/schema/Order.Email__c';

export default class HdtAdvanceDocumentManager extends NavigationMixin(LightningElement) {
    @api recordId;
    @api order;
    @api tipoPlico;
    @api loginChannel;
    @track showModal;
    @track showSendButton = false;
    @track emailRequired = false;
    @track showSpinner = false;
    @track email;
    context = 'DocumentazioneAnticipata';

    modalitaInvio = [
        {
        label:'Stampa Cartacea',
        value:'Stampa Cartacea'
        },
        {
            label:'E-Mail',
            value:'E-Mail'
        }
    ];

    @api
    handleShowModal(){
        this.showModal = true;
        console.log('showModal' + this.showModal);
    }

    @api
    initVariables(params){
        this.tipoPlico = params.tipoDoc;
        this.loginChannel = params.canale;
        console.log('tipoPlico: ' + this.tipoPlico);
        console.log('loginChannel: ' + this.loginChannel);
    }
    
    connectedCallback(){
        this.recordId = this.order.Id;
        console.log('order id' + this.recordId);
    }

    handleChange(event){
        try{
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value;
            if(modSpedizione.localeCompare('E-Mail')===0){
                this.emailRequired = true;
            }else{
                this.emailRequired = false;
                const allValid = [...this.template.querySelectorAll('lightning-input')]
                    .reduce((validSoFar, inputCmp) => {
                                inputCmp.reportValidity();
                                return validSoFar && inputCmp.checkValidity();
                    }, true);
            }
        }catch(error){
            console.error(error);
        }
        
    }

    checkForm(){
        try{
            var modSpedizione = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]");
            var email =this.template.querySelector("lightning-input[data-id=email]");
            
            const comboValid = [...this.template.querySelectorAll('lightning-combobox')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
                if(!comboValid){
                    console.log('KO');
                    
                }else{
                    const allValid = [...this.template.querySelectorAll('lightning-input')]
                    .reduce((validSoFar, inputCmp) => {
                                inputCmp.reportValidity();
                                return validSoFar && inputCmp.checkValidity();
                    }, true);
                    if(!allValid){
                        console.log('KO');
                    }else{

                        const fields = {};
                        // TODO: salvare email/sms su order per marketing cloud.
                        // fields[ID_FIELD.fieldApiName] = this.recordId;
                        // fields[MOD_SPED.fieldApiName] = modSpedizione.value;
                        const recordInput = { fields };
                        updateRecord(recordInput)
                                .then(() => {
                                    console.log('Record aggiornato');
                                    this.sendDocumentFile();
                                })
                                .catch(error => {
                                    console.log('Errore in aggiornamento');
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error creating record',
                                            message: error.body.message,
                                            variant: 'error'
                                        })
                                    );
                                });
                    }
                }
        }catch (error) {
            console.error(error);
        }
    }

    
    sendDocumentFile(){
        const sendMode = 'Sportello'; // La documentazione anticipata non deve essere spedita da Postel, quindi forziamo sendMode = Sportello.
        var formParams = {
            sendMode : sendMode,
            mode : 'Print',
            Archiviato : 'Y',
            TipoPlico:this.tipoPlico
        };
        sendAdvanceDocumentation({
            recordId: this.recordId,
            context: this.context,
            formParams: JSON.stringify(formParams)
        }).then(result => {
            this.closeModal();
        }).catch(error => {
            this.showToast('Errore nell\'invio del documento al cliente.');
            console.error(error);
        });
    }
    closeModal(){
        this.showModal = false;
    }

    showToast(message) {
        const event = new ShowToastEvent({
            title: 'Attenzione',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(event);
    }
    handlePreview(){
        try{
            
            this.showSpinner = true;
            var formParams = {
                mode : 'Preview',
                Archiviato : 'N',
                TipoPlico:this.tipoPlico
            };

            previewDocumentFile({
                recordId: this.recordId,
                context: this.context,
                formParams: JSON.stringify(formParams)
            }).then(result => {
                var resultParsed = JSON.parse(result);
                this.showSpinner = false;
                if(resultParsed.code === '200'){
                    if(resultParsed.result === '000'){
                        this.showPdfFromBase64(resultParsed.base64);
                        this.showSendButton = true;
                    }else{
                        this.showToast('Errore nella composizione del plico');
                    }
                }else{
                    this.showToast('Errore nella composizione del plico');
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
        }catch(error){
            console.error();
        }
    }

    showPdfFromBase64(base64){
        var sliceSize = 512;
        var byteCharacters = window.atob(base64);
        var byteArrays = [];

        for (var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);
            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            var byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }

        const blob = new Blob(byteArrays, { type: 'application/pdf' });
        const blobURL = URL.createObjectURL(blob);
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: blobURL
                }
            }
        );
    }
    
}