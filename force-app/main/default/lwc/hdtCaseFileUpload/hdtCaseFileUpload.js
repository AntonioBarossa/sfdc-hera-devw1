import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import getFiles from '@salesforce/apex/HDT_LC_CaseFileUpload.getFiles';
import deleteFile from '@salesforce/apex/HDT_LC_CaseFileUpload.deleteFile';
import updatePhaseAllegatiRicevuti from '@salesforce/apex/HDT_LC_CaseFileUpload.updatePhaseAllegatiRicevuti';
// import fileSelectorStyle from '@salesforce/resourceUrl/fileSelectorStyle';

const FIELDS = ['Case.Type',
				'Case.Cluster__c',
                'Case.Phase__c'];

export default class FileUploadExample extends LightningElement {
    @api recordId;
    columns;
    data;
    allegatiPresenti = false;
    files = [];
    //tmpFiles = [];
    urls = [];
    cardTitle;
    relatedUrl;    
    get acceptedFormats() {
        return ['.pdf', '.png', '.txt'];
    }

    @track caseRecord;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log('data error ' +message);
        } else if (data) {

            this.caseRecord = data;
            
        }
    }

    connectedCallback() {
        
        this.getAttachmentFiles();
        
    }

    getAttachmentFiles(){

        this.files = [];

        getFiles({recordId: this.recordId})
        .then(response => {
            if(response && response.length > 0){
                console.log('CI SONO FILE');
                this.allegatiPresenti = true;
                this.cardTitle = 'Files ('+response.length+')';
                this.relatedUrl = '/lightning/r/AttachedContentDocument/'+ this.recordId +'/related/AttachedContentDocuments/view';

                let i = 0;
                response.forEach( ( record ) => {
                    if(i<3){
                        let tempRec = Object.assign( {}, record );
                        
                        const tmpFiles = [
                            { label: 'Title', fieldName: 'Title', type: 'text'},
                            { label: 'Id', fieldName: 'Id', type: 'text'},
                            { label: 'LastModifiedDate', fieldName: 'LastModifiedDate', type: 'text'},
                            { label: 'ContentSize', fieldName: 'ContentSize', type: 'text'},
                            { label: 'FileExtension', fieldName: 'FileExtension', type: 'text'},
                            { label: 'Url', fieldName: 'Url', type: 'text'}
                        ];

                        tmpFiles.Title = tempRec.Title;
                        tmpFiles.Id = tempRec.Id;
                        tmpFiles.Url = '/' + tempRec.Id;
                        tmpFiles.FileExtension = tempRec.FileExtension;
                        tmpFiles.ContentSize = tempRec.ContentSize;                    
                        tmpFiles.LastModifiedDate = this.formatDate(tempRec.LastModifiedDate);
                        console.log('tmpFiles.LastModifiedDate -->'+tmpFiles.LastModifiedDate);
                        this.files.push(tmpFiles);
                        i++;
                    }
                });

                //this.files = this.tmpFiles;

                console.log('this.files --> '+this.files);
                
            }
            else{
                console.log('NON CI SONO FILE');
                this.allegatiPresenti = false;
                this.cardTitle = 'Files ('+response.length+')';
                this.relatedUrl = '/lightning/r/AttachedContentDocument/'+ this.recordId +'/related/AttachedContentDocuments/view';
            }
        })
    }

    formatDate(value) {
        let date = new Date(value);
        const day = date.toLocaleString('default', { day: '2-digit' });
        const month = date.toLocaleString('en', { month: 'short' });
        const year = date.toLocaleString('default', { year: 'numeric' });
        return day + '-' + month + '-' + year;
    }

    handleOnselect(event){

        console.log('ENTRATO IN HANDLE ON SELECT');

        if(this.allegatiPresenti){
            this.allegatiPresenti = false;
        }
        else{
            this.allegatiPresenti = true;
        }
    }

    handleDelete(event){

        console.log('ENTRATO IN handleDelete');
        console.log('event.target.value --> '+event.target.value);

        deleteFile({recordId: event.target.value})
        .then(() => {

            const evt = new ShowToastEvent({
                title: 'SUCCESS',
                message: ' File(s) delete successfully',
                variant: 'success',
            });
            this.dispatchEvent(evt);
    
            this.getAttachmentFiles();

        });
    }



    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files.length;
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: uploadedFiles + ' File(s) uploaded  successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);

        this.getAttachmentFiles();

        if(this.caseRecord.fields.Type.value == 'Consumo Anomalo Idrico' && this.caseRecord.fields.Cluster__c.value == 'Segnalazioni' && !this.allegatiPresenti && this.caseRecord.fields.Phase__c.value == 'Risposta ricevuta'){
            updatePhaseAllegatiRicevuti({recordId: this.recordId})
            .then(() => {

                setTimeout(() => {
                    eval("$A.get('e.force:refreshView').fire();");
            }, 2000); 

            });
        }

        
    }
}