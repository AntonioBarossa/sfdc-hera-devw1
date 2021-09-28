import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import valida from '@salesforce/apex/HDT_UTL_ActivityCustom.validaActivityVocal';
import TYPE_ACTIVITY from '@salesforce/schema/wrts_prcgvr__Activity__c.Type__c';

export default class hdtVOActivityValidation extends LightningElement {


    @api isRiassignButton = false;
    @api loading = false;
    @api isShowButtonRiassign = false;
    @api isApproveFase = false;
    @api recordId;
    @api showFunction = false;
    @api causale = '';
    @api caseid;

    @wire(getRecord, { recordId: '$recordId', fields: [TYPE_ACTIVITY] })
    wiredParentOrder({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Order',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.parentOrder = data;
            this.showFunction = data.fields.Type__c.value;
        }
    }

    save(){
        let validation = this.template.querySelector('[data-name="Validation__c"]').value;
        valida({
            recordid : this.recordId,
            validazione : validation
        }).then(result => {
            if(result == true){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Validata',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }else{
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Non Validata, Procedi con la Richiesta di un nuovo VO oppure Annulla l\'order',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
            updateRecord({ fields: { Id: this.recordId } });
        });
    }
    approve(){
        valida({
            recordid : this.recordId,
            validazione : 'Si'
        }).then(result => {
            if(result == true){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Validata',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
        });
     
    }

    reject(){
        console.log('rigettata');
        valida({
            recordid : this.recordId,
            validazione : 'No'
        }).then(result => {
            if(!result){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Non Validata, Procedi con la Richiesta di un nuovo VO oppure Annulla l\'order',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
        });
     
    }




}