import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import sendAdvanceDocumentation from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendAdvanceDocumentation';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import { updateRecord } from 'lightning/uiRecordApi';
import PHONE_NUMBER_FIELD from '@salesforce/schema/Order.PhoneNumber__c';
import ID_ORDER_FIELD from '@salesforce/schema/Order.Id';
import IS_PRE_DOC_TO_SEND from '@salesforce/schema/Order.isPreDocumentationToSend__c';
import EMAIL_FIELD from '@salesforce/schema/Order.Email__c';

export default class HdtModuloInformativoModal extends NavigationMixin(LightningElement) {

    @api order; //HDT_QR_Order.getRecordById()
    email = '';
    sms = '';
    loading = false;
    showModuloModal = false;
    moduloSendTypeSelection = '';
    tipoDoc = '';
    showEmail = false;
    showStampa = false;
    showSms = false;
    isSendTypeSelectionVisible = false;
    disabledConfirm = true;
    get moduloInformativoSendTypeOptions() {
        let options = [
            { label: 'Email', value: 'Email' },
            { label: 'SMS', value: 'SMS' }
        ];

        return options;
    }

    get disabledConfirm(){
        return this.moduloSendTypeSelection == '';
    }

    handleModuloSendTypeSelection(event){
        console.log('handleModuloSendTypeSelection: ' + event.target.value);
        this.moduloSendTypeSelection = event.target.value;
        this.disabledConfirm = false;

        switch (this.moduloSendTypeSelection) {
            case 'Email':
                this.showEmail = true;
                this.showSms = false;
                break;
            case 'SMS':
                this.showSms = true;
                this.showEmail = false;
                break;
            default:
                break;
        }
    }

    @api
    handleShowModal(){
        this.showModuloModal = true;
    }

    @api
    initVariables(params){
        this.tipoDoc = params.tipoDoc;
        console.log('tipoDoc: ' + this.tipoDoc);
    }

    handleCancel(){
        this.moduloSendTypeSelection = '';
        this.showEmail = false;
        this.showStampa = false;
        this.showSms = false;
        this.showModuloModal = false;
    }
    
    handleConfirm(){
        this.loading = true;

        const fields = {};
        fields[ID_ORDER_FIELD.fieldApiName] = this.order.Id;
        fields[IS_PRE_DOC_TO_SEND.fieldApiName] = true;
        
        switch (this.moduloSendTypeSelection) {
            case 'Email':
                fields[EMAIL_FIELD.fieldApiName] = this.email;
                break;
            case 'SMS':
                fields[PHONE_NUMBER_FIELD.fieldApiName] = this.sms;
                break;
            default:
                break;
        }

        const recordInput = { fields };

        this.loading = true;
        var formParams = {     
            mode : 'Print',
            Archiviato : 'Y',
            TipoPlico: this.tipoDoc,
            sendMode:'Sportello'
        };
        sendAdvanceDocumentation({
            recordId: this.order.Id,
            context: 'DocumentazioneAnticipata',
            formParams: JSON.stringify(formParams)
        }).then(result => {
            this.loading = false;
            this.handleCancel();
            const event = new ShowToastEvent({
                title: 'Successo',
                message: 'Documentazione inviata',
                variant: 'success',
            });
            this.dispatchEvent(event);

                updateRecord(recordInput)
                    .then(() => {
                        console.log('hdtModuloInformatioModal - updateRecord - OK!');
                    })
                    .catch(error => {
                        console.log('hdtModuloInformatioModal - updateRecord - error: ' + JSON.stringify(error));
                    });
        }).catch(error => {
            this.loading = false;
            const event = new ShowToastEvent({
                title: 'Attenzione',
                message: 'Non è stato possibile inviare la documentazione al cliente',
                variant: 'error',
            });
            this.dispatchEvent(event);
            console.error(error);
        });
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

    handleInvia(){
        this.isSendTypeSelectionVisible = true;
    }

    handleStampa(){
        this.loading = true;
        // try{
        //     var sendMode = this.order.DocSendingMethod__c;
        //     var signMode = this.order.SignatureMethod__c;
        //     if(sendMode.localeCompare('Stampa Cartacea')===0){
        //         sendMode = 'Sportello';
        //     }
        //     var formParams = {
        //         sendMode : sendMode,
        //         signMode : signMode,      
        //         mode : 'Print',
        //         Archiviato : 'Y'
        //     }
        //     sendDocument({
        //         recordId: this.order.Id,
        //         context: 'Order',
        //         formParams: JSON.stringify(formParams)
        //     }).then(result => {
        //         this.loading = false;
        //         this.handleCancel();
        //         const event = new ShowToastEvent({
        //             title: 'Successo',
        //             message: 'Documentazione inviata',
        //             variant: 'success',
        //         });
        //         this.dispatchEvent(event);
        //         const fields = {};
        //         fields[ID_ORDER_FIELD.fieldApiName] = this.order.Id;
        //         fields[IS_PRE_DOC_TO_SEND.fieldApiName] = true;
        //         const recordInput = { fields };

        //         updateRecord(recordInput)
        //             .then(() => {
        //                 console.log('hdtModuloInformatioModal - updateRecord - OK!');
        //             })
        //             .catch(error => {
        //                 console.log('hdtModuloInformatioModal - updateRecord - error: ' + JSON.stringify(error));
        //             });
        //     }).catch(error => {
        //         this.loading = false;
        //         const event = new ShowToastEvent({
        //             title: 'Attenzione',
        //             message: 'Errore nell\'invio del documento al cliente.',
        //             variant: 'error',
        //         });
        //         this.dispatchEvent(event);
        //         console.error(error);
        //     });
        // }catch(error){
        //     this.loading = false;
        //     console.error(error);
        // }


        var formParams = {
            mode : 'Preview',
            TipoPlico: this.tipoDoc,
            Archiviato : 'N',
        };

        previewDocumentFile({
            recordId: this.order.Id,
            context: 'DocumentazioneAnticipata',
            formParams: JSON.stringify(formParams)
        }).then(result => {
            this.loading = false;
            this.handleCancel();
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
    }

    handleSms(){ // TO DO: Da capire doppo come si fa ad interagire con marketing cloud
        const fields = {};
            fields[ID_ORDER_FIELD.fieldApiName] = this.order.Id;
            fields[PHONE_NUMBER_FIELD.fieldApiName] = this.sms;
            const recordInput = { fields };

            updateRecord(recordInput)
                    .then(() => {
                        this.loading = false;
                        this.handleCancel();
                        const event = new ShowToastEvent({
                            title: 'Successo',
                            message: 'Documentazione inviata',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                        console.log('hdtModuloInformatioModal - updateRecord - OK!');
                    })
                    .catch(error => {
                        this.loading = false;
                        const event = new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'Errore nell\'invio del SMS.',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                        console.log('hdtModuloInformatioModal - updateRecord - error: ' + JSON.stringify(error));
                    });
    }

    handleClose(){
        this.showModuloModal = false;
    }

    connectedCallback(){
        this.email = this.order.SalesContact__r.Email;
        this.sms = this.order.SalesContact__r.MobilePhone;
    }
}