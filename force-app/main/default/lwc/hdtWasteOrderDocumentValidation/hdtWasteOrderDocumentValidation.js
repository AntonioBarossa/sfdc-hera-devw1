import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue,getRecordNotifyChange  } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { CloseActionScreenEvent } from 'lightning/actions';
import OUTCOME from '@salesforce/schema/Order.Outcome__c';
import NOTE from '@salesforce/schema/Order.PraxidiaNote__c';
import TYPE from '@salesforce/schema/Order.ProcessType__c';
import ID_FIELD from '@salesforce/schema/Order.Id';
import FASE from '@salesforce/schema/Order.Phase__c';
export default class HdtWasteOrderDocumentValidation extends LightningElement {

    @api recordId;
    @track completeButton = 'Completa';
    @track closeButton = 'Chiudi';
    @track disableButton = false;
    @track showWaste = false;
    @track showSpinner = false;
    @track noteValidation;
    @track valueWaste;
    @track type;
    optionsWaste = [
        { label: 'Documentazione completa', value: 'Documentazione completa' },
        { label: 'Documentazione incompleta di dati catastali', value: 'Documentazione incompleta di dati catastali' },
        { label: 'Documentazione incompleta di allegati', value: 'Documentazione incompleta di allegati' },
        { label: 'documentazione incompleta di più elementi', value: 'documentazione incompleta di più elementi' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: [OUTCOME,NOTE,TYPE] })
    wiredOrder({ error, data }) {
        if (data) {
            this.type = getFieldValue(data,TYPE);
            this.noteValidation = getFieldValue(data,NOTE);
            this.valueWaste = getFieldValue(data,OUTCOME);
        } else if (error) {
            console.log(error);
        }
    }
    handleChange(event){
        this.valueWaste = event.detail.value;
    }

    async handleConfirmClick(recordInput) {
        const result = await LightningConfirm.open({
            message: 'Premendo OK verrà inviata la pratica verso i sistemi a valle, assicurati che la documentazione sia completa',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });
        if(result){
            var record = recordInput;
            this.updateRecordOrder(record,false);
            
        }else{
            this.closeQuickAction();
        }
    }

    handleClick(event){
        this.showSpinner = true;
        this.disableButton = !this.disableButton;
        if (event.target.name === 'complete') {
            // Create the recordInput object
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[OUTCOME.fieldApiName] = this.valueWaste;
            fields[NOTE.fieldApiName] = this.template.querySelector("lightning-textarea[data-id=noteWaste]").value;
            if(this.valueWaste === 'Documentazione completa'){
                fields[FASE.fieldApiName] = 'Documentazione Validata';
                const recordInput = { fields };
                this.handleConfirmClick(recordInput);
            }else{
                const recordInput = { fields };
                this.updateRecordOrder(recordInput,true);
            }
            const recordInput = { fields };        
        }else{
            this.closeQuickAction();
        }
    }
    closeQuickAction() {
        this.showSpinner = false;
        this.dispatchEvent(new CustomEvent('closeaction'));
    }

    updateRecordOrder(recordInput,showMessage){
        updateRecord(recordInput)
        .then(() => {
            if(showMessage){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Validazione Documentale aggiornata',
                        variant: 'success'
                    })
                );
            }
            this.showSpinner = false;
            this.dispatchEvent(new CustomEvent('complete'));
            //this.closeQuickAction();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore nell\' aggiornamento della validazione',
                    message: error.message,
                    variant: 'error'
                })
            );
            this.closeQuickAction();
        });
    }
    
}