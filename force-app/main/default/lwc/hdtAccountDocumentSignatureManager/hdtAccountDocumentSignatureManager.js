import { LightningElement,api,track,wire } from 'lwc';
import getInfoAccountStatement from '@salesforce/apex/HDT_LC_DocumentSignatureManager.getInfoAccountStatement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Account.Id';
import MOD_SPED from '@salesforce/schema/Account.SendMode__c';

export default class HdtAccountDocumentSignatureManager extends NavigationMixin(LightningElement) {
    @api context;
    @api recordId;
    @api documents;
    @api tipoPlico;
    @track dataLoaded = false;
    @track inputParams;
    @track showSendButton = false;
    @track emailRequired = false;
    @track showSpinner = false;
    @track email;
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
    connectedCallback(){
        console.log('account ' + this.recordId);
        getInfoAccountStatement({
            accountId: this.recordId
        }).then(result => {
            console.log(this.documents);
            var resultJSON = JSON.parse(result);
            this.email = resultJSON.email;
            console.log(resultJSON);
            var inputParams = {
                dataConfirmed:false,
                context:this.context,
                recordId:this.recordId,
                processType:'',
                source : resultJSON.source,
                phone : resultJSON.telefono,
                email : resultJSON.email,
                accountId : this.recordId,
                quoteType : 'ND',
                sendMode:'',
                signMode:'',
                addressWrapper : {
                    completeAddress : ''
                },
                documents:this.documents,
                tipoPlico:this.tipoPlico
            }
            this.inputParams = JSON.stringify(inputParams);
            this.dataLoaded = true;
            console.log(this.inputParams);
        }).catch(error => {
            console.log('errore ' +JSON.stringify(error));
        });
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
                        fields[ID_FIELD.fieldApiName] = this.recordId;
                        fields[MOD_SPED.fieldApiName] = modSpedizione.value;
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
        var sendMode = this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value;
        if(sendMode.localeCompare('Stampa Cartacea')===0){
            sendMode = 'Sportello';
        }
        var email = this.template.querySelector("lightning-input[data-id=email]").value;
        var formParams = {
            sendMode : sendMode,
            email : this.template.querySelector("lightning-input[data-id=email]").value,      
            mode : 'Print',
            Archiviato : 'Y',
            EstrattoConto:this.documents,
            TipoPlico:this.tipoPlico
        };
        sendDocument({
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
        this.dispatchEvent(new CustomEvent('closemodal'));
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
                sendMode : this.template.querySelector("lightning-combobox[data-id=modalitaSpedizione]").value,
                email : this.template.querySelector("lightning-input[data-id=email]").value,      
                mode : 'Preview',
                Archiviato : 'N',
                EstrattoConto:this.documents,
                TipoPlico:this.tipoPlico
            };

            previewDocumentFile({
                recordId: this.recordId,
                context: this.context,
                formParams: JSON.stringify(formParams)
            }).then(result => {
                var resultParsed = JSON.parse(result);
                if(resultParsed.code === '200'){
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
                        this.url = blobURL;
                        this.fileName = 'myFileName.pdf';
                        this.showFile = true;
                        this.showSpinner = false;
                        this[NavigationMixin.Navigate](
                            {
                                type: 'standard__webPage',
                                attributes: {
                                    url: blobURL
                                }
                            }
                        );
                        this.showSendButton = true;
                        this.dispatchEvent(new CustomEvent('previewexecuted'));
                    }else{
                        this.showSpinner = false;
                        this.showToast('Errore nella composizione del plico');
                    }
                }else{
                    this.showSpinner = false;
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
    
}