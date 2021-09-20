import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendAdvanceDocumentation from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendAdvanceDocumentation';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import { updateRecord } from 'lightning/uiRecordApi';
import PHONE_NUMBER_FIELD from '@salesforce/schema/Order.PhoneNumber__c';
import ID_ORDER_FIELD from '@salesforce/schema/Order.Id';
import IS_PRE_DOC_TO_SEND from '@salesforce/schema/Order.isPreDocumentationToSend__c';

export default class HdtModuloInformativoModal extends LightningElement {

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
    get moduloInformativoSendTypeOptions() {
        let options = [
            { label: 'Email', value: 'Email' },
            { label: 'Stampa', value: 'Stampa' }
        ];

        return options;
    }

    get disabledConfirm(){
        return this.moduloSendTypeSelection == '';
    }

    handleModuloSendTypeSelection(event){
        console.log('handleModuloSendTypeSelection: ' + event.target.value);
        this.moduloSendTypeSelection = event.target.value;

        switch (this.moduloSendTypeSelection) {
            case 'Email':
                this.showEmail = true;
                this.showStampa = false;
                this.showSms = false;
                break;
            case 'Stampa':
                this.showStampa = true;
                this.showEmail = false;
                this.showSms = false;
                break;
            case 'SMS':
                this.showSms = true;
                this.showEmail = false;
                this.showStampa = false;
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
        
        switch (this.moduloSendTypeSelection) {
            case 'Email':
                this.handleEmail();
                break;
            case 'Stampa':
                this.handleStampa();
                break;
            case 'SMS':
                this.handleSms();
                break;
            default:
                break;
        }
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

    handleEmail(){
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
            const fields = {};
                fields[ID_ORDER_FIELD.fieldApiName] = this.order.Id;
                fields[IS_PRE_DOC_TO_SEND.fieldApiName] = true;
                const recordInput = { fields };

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

    handleStampa(){
        this.loading = true;
        try{
            var sendMode = this.order.DocSendingMethod__c;
            var signMode = this.order.SignatureMethod__c;
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
                recordId: this.order.Id,
                context: 'Order',
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
                const fields = {};
                fields[ID_ORDER_FIELD.fieldApiName] = this.order.Id;
                fields[IS_PRE_DOC_TO_SEND.fieldApiName] = true;
                const recordInput = { fields };

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
                    message: 'Errore nell\'invio del documento al cliente.',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                console.error(error);
            });
        }catch(error){
            this.loading = false;
            console.error(error);
        }
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

    connectedCallback(){
        this.email = this.order.SalesContact__r.Email;
        this.sms = this.order.SalesContact__r.MobilePhone;
    }
}