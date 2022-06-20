import { LightningElement, api, track } from 'lwc';
import getRecordsById from '@salesforce/apex/HDT_QR_ContentDocument.getRecordsById';
import getAttachmentInfoFromCase from '@salesforce/apex/HDT_LC_AttachmentManager.getAttachmentInfoFromCase';
import getRequiredAttachmentFromCase from '@salesforce/apex/HDT_LC_AttachmentManager.getRequiredAttachmentFromCase';
import { getRecord, getFieldValue, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class HdtAttachmentManager extends LightningElement {

    @api recordId;
    @api files;
    @track additional;
    @track required;

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files

        /*
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
        */

        getRecordsById({
            recordId: this.recordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                if(Object.keys(result).length > 0 )
                    this.files = result;
                else
                this.files = null;
            })
            .catch(error => {
                this.error = error;
            });
        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    connectedCallback(){
        getRecordsById({
            recordId: this.recordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                if(Object.keys(result).length > 0 )
                    this.files = result;
                else
                this.files = null;
            })
            .catch(error => {
                this.error = error;
            });
        
            //chiamare la tabella degli allegati e chiamare i campi del case
            
    }

    

}