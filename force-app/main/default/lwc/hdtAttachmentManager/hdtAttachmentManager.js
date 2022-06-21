import { LightningElement, api, track } from 'lwc';
import getRecordsById from '@salesforce/apex/HDT_LC_AttachmentManager.getRecordsById';
import getAdditionalAttachmentFromCase from '@salesforce/apex/HDT_LC_AttachmentManager.getAdditionalAttachmentFromCase';
import getRequiredAttachmentFromCase from '@salesforce/apex/HDT_LC_AttachmentManager.getRequiredAttachmentFromCase';
import updateAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.updateAttachment';
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
        this.additional = event.detail.value;
        /*
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
        */
    }

    afterDelete(event){
        this.getFiles();
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files

        /*
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
        */

        this.getFiles();

        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    getFiles(){
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
        updateAttachment({
            recordId: this.recordId,
            required: this.required,
            additional: this.additional
            }).then(result => {
                console.log(JSON.stringify(result));
            })
            .catch(error => {
                this.error = error;
            }); 
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

        this.getFiles();

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