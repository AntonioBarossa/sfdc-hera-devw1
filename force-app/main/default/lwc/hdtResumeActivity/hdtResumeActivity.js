import { LightningElement,api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import STATUS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c';
// import SUSPENSION_DATE from '@salesforce/schema/wrts_prcgvr__Activity__c.SuspensionDate__c';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c', 'wrts_prcgvr__Activity__c.SuspensionDate__c','wrts_prcgvr__Activity__c.Type__c'];
export default class HdtResumeActivity extends LightningElement {
    @api recordId;
    // _recordId;
    wrts_prcgvr__Activity__c;
    actType;
    showMessage = false;
    textColor = 'slds-text-color_default';
    textMessage = 'L\'attività è stata ripresa.';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        console.log('recordId: ' + this.recordId);
        if (error) {
            let message = 'Errore sconosciuto';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore in fase di get del record Attività.',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.wrts_prcgvr__Activity__c = data;
            this.actType = this.wrts_prcgvr__Activity__c.fields.Type__c.value;
            const fields = { Id : this.recordId};
            fields['SuspensionDate__c'] = null;
            if (this.actType === 'Presa Appuntamento'){
                fields['wrts_prcgvr__Status__c'] = 'Creata';
            }else{
                fields['wrts_prcgvr__Status__c'] = 'Aperta';
            }
            const recordInput = { fields };
            updateRecord(recordInput).then( () => {
                console.log('OK');
                this.showMessage = true;
            }).catch(error => {
                console.error(error);
                console.log('KO');
                this.showMessage = true;
                if (error.body.message){
                    this.textMessage = 'Si è verificato il seguente errore durante la lavorazione dell\'attività: ' + error.body.message;
                }else{
                    this.textMessage = 'Si è verificato un errore, contattare l\'amministratore di sistema.';
                }
                this.textColor = 'slds-text-color_error';
            }); 
        }
    }

    //vecchia gestione ripresa attività
    // @api set recordId(value) {
    //     this._recordId = value;
    //     console.log('Init ' + this.recordId);
    //     const fields = { Id : this.recordId};
    //     fields[STATUS_FIELD.fieldApiName] = 'Aperta';
    //     fields[SUSPENSION_DATE.fieldApiName] = null;
    //     const recordInput = { fields };
    //     updateRecord(recordInput).then( () => {
    //         console.log('OK');
    //         this.showMessage = true;
    //     }).catch(error => {
    //         console.error(error);
    //         console.log('KO');
    //         this.showMessage = true;
    //         if (error.body.message){
    //             this.textMessage = 'Si è verificato il seguente errore durante la lavorazione dell\'attività: ' + error.body.message;
    //         }else{
    //             this.textMessage = 'Si è verificato un errore, contattare l\'amministratore di sistema.';
    //         }
    //         this.textColor = 'slds-text-color_error';
    //     });  
    //     console.log('exit');
    // }

    // get recordId() {
    //     return this._recordId;
    // }

}