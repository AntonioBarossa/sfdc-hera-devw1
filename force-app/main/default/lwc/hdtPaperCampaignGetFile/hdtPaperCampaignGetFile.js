import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getIdByName from '@salesforce/apex/HDT_LC_PaperCampaignGetFile.getIdByName';
import getFileById from '@salesforce/apex/HDT_LC_PaperCampaignGetFile.getFileById';
import getPaperCommunicationRecord from '@salesforce/apex/HDT_LC_PaperCampaignGetFile.getPaperCommunicationRecord';
import createPaperFile from '@salesforce/apex/HDT_LC_PaperCampaignGetFile.createPaperFile';
import checkPaperFile from '@salesforce/apex/HDT_LC_PaperCampaignGetFile.checkPaperFile';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtPaperCampaignGetFile extends NavigationMixin(LightningElement){
    @api recordId;
    @api objectApiName;
    @track showSpinner = false;
    @track PdfUniqueId;

    connectedCallback(event) {
        
        //get PdfUniqueId__c from PaperCommunication
        getPaperCommunicationRecord({ id: this.recordId }).then(paper => {
            this.showSpinner = true;
            console.log(JSON.stringify(paper));
            if (paper.hasOwnProperty('PdfUniqueId__c') && paper.PdfUniqueId__c != null) {
                console.log('PdfUniqueId__c - ' + paper.PdfUniqueId__c);
                this.PdfUniqueId = paper.PdfUniqueId__c;
                console.log('risultato: '+ this.recordId);
                checkPaperFile({ paperId: this.recordId, filename: paper.PdfUniqueId__c }).then(ans => {
                    console.log('risultato: '+ ans);
                    if(ans==false){
                      //1st ws call - get file id by name
                        getIdByName({ filename: paper.PdfUniqueId__c }).then(data => {
                            console.log('risultato: '+JSON.stringify(data));
                            if (data != null) {
                                let dataObj = JSON.parse(data);
                                if (dataObj.data.id != null) {
                                //2nd ws call - get file base64
                                    getFileById({ documentId: dataObj.data.id }).then(doc => {
                                        console.log('risultato: '+JSON.stringify(doc));
                                        if (doc != null) {
                                            let docObj = JSON.parse(doc);
                                            if (docObj.data.fileBase64 != null) {
                                            //create file
                                                createPaperFile({ fileBase64: docObj.data.fileBase64, paperId: this.recordId, filename: this.PdfUniqueId }).then(response => {
                                                    console.log(JSON.stringify(response));
                                                    if (response != null ) {//&& response
                                                        this[NavigationMixin.Navigate]({
                                                            type: 'standard__namedPage',
                                                            attributes: {
                                                                pageName: 'filePreview'
                                                            },
                                                            state : {
                                                                recordIds: response
                                                        }
                                                      });
                                                    this.dispatchEvent(new ShowToastEvent({
                                                        title: '',
                                                        message: 'File creato con successo',
                                                        variant: 'success'
                                                    }));
                                                    this.showSpinner = false;
                                                    } else {
                                                        this.dispatchEvent(new ShowToastEvent({
                                                            title: '',
                                                            message: 'Errore in creazione del file',
                                                             variant: 'error'
                                                    }));
                                                }
                                                this.dispatchEvent(new CustomEvent('afterSave'));
                                            }).catch(err => {
                                                console.log('createPaperFile - ' + JSON.stringify(err));
                                                this.dispatchEvent(new CustomEvent('afterSave'));
                                            });
                                            
                                        }
                                    }
                                    
                                }).catch(err => {
                                    console.log('getFileById - ' + JSON.stringify(err));
                                    this.dispatchEvent(new CustomEvent('afterSave'));
                                });
                            }
                        }
                    }).catch(err => {
                        console.log('getIdByName - ' + JSON.stringify(err));
                        this.dispatchEvent(new CustomEvent('afterSave'));
                    });
                
                }
                else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: '',
                        message: 'Il file è già presente!',
                        variant: 'warning'
                    }));
                    this.showSpinner = false;
                    this.dispatchEvent(new CustomEvent('afterSave'));
                }
                
                }).catch(err => {
                    console.log('getIdByName - ' + JSON.stringify(err));
                    this.dispatchEvent(new CustomEvent('afterSave'));
                });  
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: 'Il file non è ancora stato archiviato',
                    variant: 'error'
                }));
                this.dispatchEvent(new CustomEvent('afterSave'));
                this.showSpinner = false;
            }
        }).catch(err => {
            console.log('getPaperCommunicationRecord - ' + JSON.stringify(err));
            this.dispatchEvent(new CustomEvent('afterSave'));
        });
        
    }

}