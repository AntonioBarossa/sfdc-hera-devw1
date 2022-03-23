import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c';
import SUSPENSION_DATE from '@salesforce/schema/wrts_prcgvr__Activity__c.SuspensionDate__c';

export default class HdtResumeActivity extends LightningElement {
    _recordId;
    showMessage = false;
    textColor = 'slds-text-color_default';
    textMessage = 'L\'attività è stata ripresa.';

    @api set recordId(value) {
        this._recordId = value;
        console.log('Init ' + this.recordId);
        const fields = { Id : this.recordId};
        fields[STATUS_FIELD.fieldApiName] = 'Aperta';
        fields[SUSPENSION_DATE.fieldApiName] = null;
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
        console.log('exit');
    }

    get recordId() {
        return this._recordId;
    }

}