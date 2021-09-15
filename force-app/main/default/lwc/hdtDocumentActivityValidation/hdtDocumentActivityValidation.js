import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import valida from '@salesforce/apex/HDT_UTL_ActivityCustom.validaActivityDocument';

export default class hdtDocumentActivityValidation extends LightningElement {


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
            if(result == ''){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Validata, Procedi con l\'order',
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
            if(result == 'NoApprovata'){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Non Validata, Procedi con l\'annullamento dell\'order',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
            else if(result == 'Creata'){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Non Validata, è stata generata l\'attivita di Documento non Validato',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
            else if(result == 'NonChiusa'){
                const event = new ShowToastEvent({
                    title: 'Warninf',
                    message: 'Chiudi l\'attivita di Documento non Validato per poter procedere con la chiusura.',
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
        });
     
    }




}