import { LightningElement,api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import valida from '@salesforce/apex/HDT_UTL_ActivityCustom.validaActivityDocument';
import rejectActivity from '@salesforce/apex/HDT_UTL_ActivityCustom.rejectActivityDocument';

export default class hdtDocumentActivityValidation extends LightningElement {

    @api isRiassignButton = false;
    @api loading = false;
    @api isShowButtonRiassign = false;
    @api isApproveFase = false;
    @api recordId;
    @api causale = '';
    @api caseid;
    @api showModal=false;
    @track note='';
    @api showModalSpinner=false;

    @track ActType='';
    @track isValidazioneDocumentale=false;
    @track error;

    showButton = false;
    disableButton = false;

    get approveLabel(){
        return this.ActType === 'Validazione Documentale'||this.ActType === 'Documenti non validati' ? 'Documenti Validati' : 'Vocal Order Validati';
    }

    get rejectLabel(){ 
        return this.ActType === 'Validazione Documentale'||this.ActType === 'Documenti non validati' ? 'Documenti non Validati' : 'Vocal Order Non Validati';
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['wrts_prcgvr__Activity__c.Type__c'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.ActType = data.fields.Type__c.value;
            this.showButton = true; 
        }
    }

    approve(){
        console.log('APPROVE');
        this.disableButton = true;
        valida({
            recordid : this.recordId,
            validazione : 'Si'
        }).then(result => {
            console.log('ENTRATO NEL THEN');
            if(result == 'Not User'){
                console.log('Not User');
                const event = new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                this.disableButton = false;
            }
            if(result == ''){
                console.log('User');
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Attività Validata, Procedi con l\'order',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                updateRecord({ fields: { Id: this.recordId } });
            }
        });
     
    }

    reject(){
        console.log('rigettata');
        this.showModal=true;
       /* valida({
            recordid : this.recordId,
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
            updateRecord({ fields: { Id: this.recordId } });
        });*/
    }

    rejectAct(){
        console.log('REJECTACT');
        console.log('@@@Note: '+this.note);
        this.showModalSpinner=true;
        this.disableButton = true;
        rejectActivity({
            recordId : this.recordId,
            noteChiusura : this.note
        }).then(result => {
            if(result == 'Not User'){
                const event = new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                this.showModal=false;
                this.disableButton = false;
            }
            else{
                if(result == 'Creata'){
                    const event = new ShowToastEvent({
                        title: 'Successo',
                        message: 'Attività Non Validata',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    this.showModal=false;
                }
                updateRecord({ fields: { Id: this.recordId } });
            }
            this.showModalSpinner=false;
        }).catch(error =>{
            const event = new ShowToastEvent({
                title: 'Errore',
                message: 'Non è stato possibile gestire l\'Attivita',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.showModal=false;
            console.log(error);
            this.showModalSpinner=false;
            this.disableButton = false;
        });
    }

    handleInputChange(event) {
        this.note = event.detail.value;
    }

    closeModal(){
        this.note='';
        this.showModal=false;
    }
}