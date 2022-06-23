import { LightningElement, api, track } from 'lwc';
import getRecordsById from '@salesforce/apex/HDT_LC_AttachmentManager.getRecordsById';
import getAdditionalAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.getAdditionalAttachment';
import getRequiredAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.getRequiredAttachment';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class HdtAttachmentManager extends LightningElement {

    @api recordId;
    @api files;
    @api additional;
    @api required;
    @track numberOfFiles = 0;
    @api paramsWrap;

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

        //getRecordNotifyChange([{recordId: this.recordId}]);
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
        if(this.required?.length > 0 && this.numberOfFiles == 0){
            return { 
                    isValid: false, 
                    errorMessage: 'Inserire gli allegati descritti' 
                    }; 
        }else if(this.additional?.length > 0 && this.numberOfFiles == 0){
            return { 
                    isValid: false, 
                    errorMessage: 'Inserire gli allegati descritti' 
                    }; 
        }else if(!(this.additional?.length || this.required?.length) && this.numberOfFiles > 0){
            return { 
                    isValid: false, 
                    errorMessage: 'Descrivere gli allegati inseriti nel campo "Allegati Aggiuntivi"' 
                    }; 
        }else{
            return { isValid: true };
        }
    }

    connectedCallback(){

        this.getFiles();

        getAdditionalAttachment({
            recordId: this.recordId
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

        getRequiredAttachment({
            recordId: this.recordId,
            paramsWrap: this.paramsWrap
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

    disconnectedCallback(){
        this.dispatchEvent(new CustomEvent('closemttachmentmanager', {bubbles: true, composed: true, detail: {  required: this.required,
                                                                                                                additional: this.additional
                                                                                                               }}));
    }

}