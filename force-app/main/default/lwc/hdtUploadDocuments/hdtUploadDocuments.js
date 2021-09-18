import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtUploadDocuments extends LightningElement {
    @api recordId; //record to attach file
    @api title; //modal title
    @api acceptedFormats; //configure accepted formats
    visible = false;
    @api isDone = false;

    //handle modal open event
    handleOpenModal(){
        this.visible = true;
    }

    //handle modal close event
    handleCloseModal() {
        this.visible = false;
    }

    //handle upload finished event
    handleUploadFinished(event) {
        this.isdone = true;
        const toastSuccessMessage = new ShowToastEvent({
            title: 'Successo',
            message: 'Documento caricato con successo',
            variant: 'success'
        });
        this.dispatchEvent(toastSuccessMessage);
        this.visible = false;
       // this.isdone = true;
    }

    connectedCallback(){
        console.log('hdtUploadDocuments - connectedCallback: ', JSON.stringify(this.acceptedFormats));
    }
}