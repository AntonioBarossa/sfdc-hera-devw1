import { LightningElement, api, track } from 'lwc';
import getRecordsById from '@salesforce/apex/HDT_QR_ContentDocument.getRecordsById';
import getAdditionalAttachmentFromCase from '@salesforce/apex/HDT_LC_AttachmentManager.getAdditionalAttachmentFromCase';
import getRequiredAttachmentFromCase from '@salesforce/apex/HDT_LC_AttachmentManager.getRequiredAttachmentFromCase';
import updateAdditionalAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.updateAdditionalAttachment';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class HdtAttachmentManager extends LightningElement {

    @api recordId;
    @api files;
    @api additional;
    @api required;
    @track numberOfFiles = 0;

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleAdditionalChange(event){
        console.log(event.target.value);
        this.additional = event.target.value;
        updateAdditionalAttachment({
            caseId: this.recordId,
            additional: this.additional != null ? this.additional : ''
        }).then(result => {
            console.log(result == true ? 'ok update' : 'ko update');
        })
        .catch(error => {
            this.error = error;
        });
        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    afterDelete(event){
        this.getRecord();
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files

        /*
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
        */

        this.getRecord();

        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    getRecord(){
        getRecordsById({
            recordId: this.recordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                this.numberOfFiles = Object.keys(result).length;
                if( this.numberOfFiles > 0 )
                    this.files = result;
                else
                    this.files = null;
            })
            .catch(error => {
                this.error = error;
            }); 
    }

    @api
    validate(){
        if(this.required?.length > 0 && this.numberOfFiles == 0){
            return { 
                isValid: false, 
                errorMessage: 'Inserisci un valore.' 
                 }; 
        }else if(this.additional?.length > 0 && this.numberOfFiles == 0){
            return { 
                isValid: false, 
                errorMessage: 'Inserisci un valore.' 
                 }; 
        }else if(this.additional?.length <= 0 && this.required?.length <= 0 && this.numberOfFiles > 0){
            return { 
                isValid: false, 
                errorMessage: 'Inserisci un valore.' 
                 }; 
        }else{
            return { isValid: true };
        }
    }

    connectedCallback(){

        this.getRecord();

        getAdditionalAttachmentFromCase({
            caseId: this.recordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                if(result.length > 0 )
                    this.additional = result;
                else
                    this.additional = '';
            })
            .catch(error => {
                this.error = error;
            });

        getRequiredAttachmentFromCase({
            caseId: this.recordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                if(result.length > 0 )
                    this.required = result;
                else
                    this.required = '';
            })
            .catch(error => {
                this.error = error;
            });
            //chiamare la tabella degli allegati e chiamare i campi del case
            
    }

    

}