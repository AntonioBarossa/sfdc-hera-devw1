import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import DESCRIPTION_DOC from '@salesforce/schema/ContentDocument.Description';
import ID_DOC from '@salesforce/schema/ContentDocument.Id';

export default class HdtUploadDocuments extends LightningElement {
    @api recordId; //record to attach file
    @api title; //modal title
    @api acceptedFormats; //configure accepted formats
    @api description; //description to identify file purpose
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



        let uploadedFile = event.detail.files[0];
        let documentId = uploadedFile.documentId;

        console.log('handleUploadFinished: ' + documentId);
        console.log('this.description: ' + this.description);

        if (this.description !== undefined && this.description !== null && this.description !== '') {

            const fields = {};
            fields[ID_DOC.fieldApiName] = documentId;
            fields[DESCRIPTION_DOC.fieldApiName] = this.description;
            const recordInput = { fields };

            updateRecord(recordInput)
                    .then(() => {
                        console.log('hdtUploadDocument - updateRecord - OK!');
                    })
                    .catch(error => {
                        console.log('hdtUploadDocument - updateRecord - error: ' + JSON.stringify(error));
                    });
        }
    }

    connectedCallback(){
        console.log('hdtUploadDocuments - connectedCallback: ', JSON.stringify(this.acceptedFormats));
    }
}