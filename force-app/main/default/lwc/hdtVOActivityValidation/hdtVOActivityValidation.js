import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import valida from '@salesforce/apex/HDT_UTL_ActivityCustom.validaActivityVocal';

export default class hdtVOActivityValidation extends LightningElement {


    @api isRiassignButton = false;
    @api loading = false;
    @api isShowButtonRiassign = false;
    @api isApproveFase = false;
    @api recordId;
    @api causale = '';
    @api caseid;


    approve(){
        valida({
            recordId : this.recordId,
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
            recordId : this.recordId,
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