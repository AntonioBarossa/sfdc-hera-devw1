import { LightningElement,track,api,wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/Case.Id';
import BillSendingMethod from '@salesforce/schema/Case.BillSendingMethod__c';
import InvoiceCertifiedEmailAddress from '@salesforce/schema/Case.InvoiceCertifiedEmailAddress__c';
import InvoiceEmail from '@salesforce/schema/Case.InvoiceEmail__c';
import CareOf from '@salesforce/schema/Case.CareOf__c';
const FIELDS = ['Case.BillSendingMethod__c',
				'Case.InvoiceCertifiedEmailAddress__c',
                'Case.InvoiceEmail__c',
                'Case.CareOf__c'];
export default class HdtBillDeliveryChooser extends LightningElement {
    @api accountId;
    @api caseId;
    @api modInvioBoll;
    @api email;
    @api pec;
    @api presso;
    @api indirizzo;
    @api nextVariant;
    @api nextLabel;
    @track emailRequired = false;
    @track pecRequired= false;
    @track addressRequired= false;
    @api availableActions = [];
    @api cancelCase = false;

    get options() {
        return [
            { label: 'Bolletta per E-mail', value: 'Bolletta per e-mail' },
            { label: 'Cartaceo', value: 'Cartaceo' },
            { label: 'Invio tramite PEC', value: 'Invio tramite PEC'}
        ];
    }
    @wire(getRecord, { recordId: '$caseId', fields: FIELDS })
        wiredCase({ error, data }) {
            if (error) {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('data error ' +message);
            } else if (data) {
                console.log('data loaded');
                if(!this.modInvioBoll)
                    this.modInvioBoll = data.fields.BillSendingMethod__c.value;
                if(!this.email)
                    this.email = data.fields.InvoiceEmail__c.value;
                if(!this.pec)
                    this.pec = data.fields.InvoiceCertifiedEmailAddress__c.value;
                if(!this.presso)
                    this.presso = data.fields.CareOf__c.value;
            }
        }

    handleChange(event){
        this.modInvioBoll = event.detail.value;
        if(this.modInvioBoll.localeCompare('Bolletta per e-mail')==0){
            this.emailRequired = true;
            this.pecRequired = false;
            this.addressRequired = false;
        }else if(this.modInvioBoll.localeCompare('Invio tramite PEC')==0){
            this.emailRequired = false;
            this.pecRequired = true;
            this.addressRequired = false;
        }else{
            this.emailRequired = false;
            this.pecRequired = false;
            this.addressRequired = true;
        }
    }
    handleGoNext(event){
        try{
            var address = this.template.querySelector('c-hdt-generic-address-chooser-flow').getAddressValue();
            const allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
            if(!allValid){
                this.isError = true;
                return;
            }else if(this.addressRequired && !address){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message:'Attenzione! Seleziona un indirizzo valido.',
                        variant: 'error',
                    }),
                );
            }else{
                const fields = {};
                var pec = this.template.querySelector("lightning-input[data-id=pec]").value;
                var email = this.template.querySelector("lightning-input[data-id=email]").value;
                var presso = this.template.querySelector("lightning-input[data-id=presso]").value;
                fields[ID_FIELD.fieldApiName] = this.caseId;
                fields[BillSendingMethod.fieldApiName] = this.modInvioBoll;
                fields[InvoiceCertifiedEmailAddress.fieldApiName] = pec;
                fields[InvoiceEmail.fieldApiName] = email;
                fields[CareOf.fieldApiName] = presso;
                const recordInput = { fields };
                updateRecord(recordInput)
                .then(() => {
                    // Display fresh data in the form
                    console.log('Record aggiornato');
                    if(this.availableActions.find(action => action === 'NEXT')){
                        const modInvioChangeEvent = new FlowAttributeChangeEvent('modInvioBoll', this.modInvioBoll);
                        this.dispatchEvent(modInvioChangeEvent);
                        const emailChangeEvent = new FlowAttributeChangeEvent('email', email);
                        this.dispatchEvent(emailChangeEvent);
                        const pecChangeEvent = new FlowAttributeChangeEvent('pec', pec);
                        this.dispatchEvent(pecChangeEvent);
                        const pressoChangeEvent = new FlowAttributeChangeEvent('presso', presso);
                        this.dispatchEvent(pressoChangeEvent);
                        const indirizzoChangeEvent = new FlowAttributeChangeEvent('indirizzo', address);
                        this.dispatchEvent(indirizzoChangeEvent);
                        
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
            
                    } else {
                        const modInvioChangeEvent = new FlowAttributeChangeEvent('modInvioBoll', this.modInvioBoll);
                        this.dispatchEvent(modInvioChangeEvent);
                        const emailChangeEvent = new FlowAttributeChangeEvent('email', email);
                        this.dispatchEvent(emailChangeEvent);
                        const pecChangeEvent = new FlowAttributeChangeEvent('pec', pec);
                        this.dispatchEvent(pecChangeEvent);
                        const pressoChangeEvent = new FlowAttributeChangeEvent('presso', presso);
                        this.dispatchEvent(pressoChangeEvent);
                        const indirizzoChangeEvent = new FlowAttributeChangeEvent('indirizzo', address);
                        this.dispatchEvent(indirizzoChangeEvent);
            
                        const navigateFinish = new FlowNavigationFinishEvent();
            
                        this.dispatchEvent(navigateFinish);
                    }
                })
                .catch(error => {
                    console.log('Errore in aggiornamento ' + error.body.message);
                });
                this.isError = false;
            }
        }catch(error){
            console.log(error);
        }
    }

    handleCancel(){

        this.cancelCase = true;

        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);

        } else{

            const navigateFinish = new FlowNavigationFinishEvent();
        
            this.dispatchEvent(navigateFinish);

        }

    }

}