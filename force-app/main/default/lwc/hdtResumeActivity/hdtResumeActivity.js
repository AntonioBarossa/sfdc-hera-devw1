import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c';
import SUSPENSION_DATE from '@salesforce/schema/wrts_prcgvr__Activity__c.SuspensionDate__c';

export default class HdtResumeActivity extends LightningElement {
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        console.log('Init ' + this.recordId);
        const fields = { Id : this.recordId};
        fields[STATUS_FIELD.fieldApiName] = 'Aperta';
        fields[SUSPENSION_DATE.fieldApiName] = null;
        const recordInput = { fields };
        updateRecord(recordInput).then( () => {
            console.log('OK');
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch(error => {
            console.error(error);
            console.log('KO');
            const event = new ShowToastEvent({
                title: 'Errore!',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
        });  
        console.log('exit');
    }

    get recordId() {
        return this._recordId;
    }

}