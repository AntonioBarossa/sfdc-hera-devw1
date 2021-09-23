import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import valida from '@salesforce/apex/HDT_UTL_ActivityCustom.validaActivityVocal';

export default class hdtVOActivityValidation extends LightningElement {


    @api isRiassignButton = false;
    @api loading = false;
    @api isShowButtonRiassign = false;
    @api isApproveFase = false;
    @api recordId;
    @api causale = '';
    @api caseid;

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