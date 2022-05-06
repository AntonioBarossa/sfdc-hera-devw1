import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import sendAdvanceDocumentation from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendAdvanceDocumentation';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import PHONE_NUMBER_FIELD from '@salesforce/schema/Order.PhoneNumber__c';
import EMAIL_FIELD from '@salesforce/schema/Order.Email__c';
import DOC_SENDING_METHOD_FIELD from '@salesforce/schema/Order.DocSendingMethod__c';
import SIGNATURE_METHOD_FIELD from '@salesforce/schema/Order.SignatureMethod__c';
import PARENT_ORDER_FIELD from '@salesforce/schema/Order.ParentOrder__c';

const fields = [PHONE_NUMBER_FIELD,EMAIL_FIELD,DOC_SENDING_METHOD_FIELD,SIGNATURE_METHOD_FIELD, PARENT_ORDER_FIELD];

export default class HdtAdvanceDocumentManagerFlow extends NavigationMixin(LightningElement) 
{
    @api recordId;
    @api isLawEighty;
    @api order;
    @api tipoPlico;
    @api loginChannel;
    @track cardTitle = 'Gestione Documentazione Anticipata';
    @track signMode;
    @track fieldsObj = [];
    @track childRecordId;
    @track showModal;
    @track showSendButton = false;
    @track emailRequired = false;
    @track smsRequired = false;
    @track showSpinner = false;
    @track email;
    @track phone;

    context = 'DocumentazioneAnticipata';

    @track modalitaInvio = [];

    @wire(getRecord,{recordId: '$childRecordId', fields})
    wiredRecord({error, data})
    {
        if(data)
        {
            if(this.isLawEighty)
            {
                console.log('# Phone >>> ' + data.fields.PhoneNumber__c.value);
                console.log('# Email >>> ' + data.fields.Email__c.value);
                console.log('# Modalita Invio >>> ' + data.fields.DocSendingMethod__c.value);
                console.log('# Sign Mode >>> ' + data.fields.SignatureMethod__c.value);
                console.log('# Parent Order >>> ' + data.fields.ParentOrder__c.value);
                this.order = data;
                this.phone = data.fields.PhoneNumber__c.value;
                this.email = data.fields.Email__c.value;
                this.modalitaInvio = data.fields.DocSendingMethod__c.value;
                this.signMode = data.fields.SignatureMethod__c.value;
                this.recordId = data.fields.ParentOrder__c.value;
                this.context = 'Order';
                this.fieldsObj.push({type: 'text', dataId: 'sendMode', disabled: true, label: 'Modalità Invio', value: this.modalitaInvio });
                this.fieldsObj.push({type: 'text', dataId: 'signMode', disabled: true, label: 'Modalità Firma', value: this.signMode });
                this.fieldsObj.push({type: 'email', dataId: 'email', disabled: true, label: 'Email invio documentazione', value: this.email });
                this.fieldsObj.push({type: 'phone', dataId: 'phone', disabled: true, label: 'Cellulare invio documentazione', value: this.phone });
                console.log('# fieldsObj >>> ' + JSON.stringify(this.fieldsObj));
            }    
        }
        else if(error)
        {
            console.log(JSON.stringify(error));
        }
    }

    connectedCallback()
    {
        this.cardTitle = "Gestione Legge 80"
        this.childRecordId = this.recordId;
        console.log('# Record Id >>> ' + this.recordId);
        return;
    }

    sendDocumentFile(){
        //const sendMode = 'Sportello'; // La documentazione anticipata non deve essere spedita da Postel, quindi forziamo sendMode = Sportello.
        let sendMode = this.isLawEighty ? this.modalitaInvio : 'Sportello'
        let tipoPlico = this.isLawEighty ? '' : this.tipoPlico
        this.showSpinner = true;
        var formParams = {
            sendMode : sendMode,
            mode : 'Print',
            Archiviato : 'Y',
            TipoPlico: tipoPlico
        };
        sendAdvanceDocumentation({
            recordId: this.recordId,
            context: this.context,
            formParams: JSON.stringify(formParams)
        }).then(result => {
            this.showSpinner = false;
            if(this.availableActions.find(action => action === 'NEXT')){

                const navigateNextEvent = new FlowNavigationNextEvent();
    
                this.dispatchEvent(navigateNextEvent);
    
            } else {
    
                const navigateFinish = new FlowNavigationFinishEvent();
    
                this.dispatchEvent(navigateFinish);
            }
        }).catch(error => {
            this.showSpinner = false;
            this.showToast('Errore nell\'invio del documento al cliente.');
            console.error(error);
        });
    }

    handlePreview(){
        try{
            let tipoPlico = this.isLawEighty ? '' : this.tipoPlico
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

        let blob = new Blob(byteArrays, { type: 'application/pdf' });
        const blobURL = URL.createObjectURL(blob);
        console.log('URL >>> ' + blobURL);
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: blobURL
                }
            }
        );
    }

    showToast(message) {
        const event = new ShowToastEvent({
            title: 'Attenzione',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(event);
    }
}