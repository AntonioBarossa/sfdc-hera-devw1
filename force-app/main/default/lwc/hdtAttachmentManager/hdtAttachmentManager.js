/*
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/06/2022
    * @description JS - Gestione Allegati Obbligatori e Aggiuntivi
*/

import { LightningElement, api, track } from 'lwc';
import getRecordsById from '@salesforce/apex/HDT_LC_AttachmentManager.getRecordsById';
import getAdditionalAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.getAdditionalAttachment';
import getRequiredAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.getRequiredAttachment';
import getRecordsToCheck from '@salesforce/apex/HDT_LC_AttachmentManager.getRecordsToCheck';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class HdtAttachmentManager extends LightningElement {

    @track currObject;
    @api objectName;
    @api recordId;
    @api subProcessType;
    @api files;
    @api additional;
    @api required;
    @track numberOfFiles = 0;
    @api paramsWrap;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
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
    specificValidate(){
        let objectToReturn = null;
        if(this.objectName.toUpperCase() == 'CASE'){
            switch(this.currObject.Type.toUpperCase()) {
                case 'MODIFICA DATI CONTRATTUALI':
                case 'MODIFICA POST ACCERTAMENTO':
                    if( 'SUPERFICIE' == this.currObject.Subprocess__c?.toUpperCase() && 
                        'NON DOMESTICO' == this.currObject.ServicePoint__r?.SupplyType__c.toUpperCase() && 
                        this.currObject.DeclaredArea__c < this.currObject.Surface__c){
                        objectToReturn = { 
                            isValid: false, 
                            errorMessage: 'Per il seguente sottoprocesso è obbligatorio allegare il modulo "Riduzione superficie aziende-TARI"' 
                            };
                    }else if('COABITAZIONI' == this.currObject.Subprocess__c.toUpperCase() || 'DATI CATASTALI' == this.currObject.Subprocess__c.toUpperCase()){
                        objectToReturn = { 
                            isValid: false, 
                            errorMessage: 'Per il seguente sottoprocesso è obbligatorio inserire almeno un allegato' 
                            };
                    }else{
                        objectToReturn = { 
                            isValid: true
                        } 
                    }
                    break;
                default:
                    objectToReturn = { 
                        isValid: true
                    } 
                    break;
            }
        }
        return objectToReturn;
    }

    @api
    validate(){ 
        if(this.numberOfFiles == 0){    //se non ci sono allegati, quale messaggio mostrare
            var checkCustomValidate = this.specificValidate();
            if(checkCustomValidate?.isValid == false){
                return checkCustomValidate;
            }else if(this.required?.length > 0){
                return { 
                        isValid: false, 
                        errorMessage: 'Inserire gli allegati Obbligatori' 
                        };
        
    /*  }else if(this.additional?.length > 0 && this.numberOfFiles == 0){
            return { 
                    isValid: false, 
                    errorMessage: 'Inserire gli allegati descritti' 
                    }; 
        }else if(!(this.additional?.length || this.required?.length) && this.numberOfFiles > 0){
            return { 
                    isValid: false, 
                    errorMessage: 'Descrivere gli allegati inseriti nel campo "Allegati Aggiuntivi"' 
                    }; 
    */
            }else{
                return { isValid: true };
            }
        }
    }

    async connectedCallback(){

        this.getFiles();

        this.currObject = await getRecordsToCheck({
            recordId: this.recordId
            });

        if(!this.additional){
            getAdditionalAttachment({
                recordId: this.recordId
                })
                .then(result => {
                    console.log(JSON.stringify(result));
                    if(result?.length > 0 )
                        this.additional = result;
                    else
                        this.additional = '';
                })
                .catch(error => {
                    this.error = error;
                });
        }

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
        console.log("disconnectedCallback -> manager")
        this.dispatchEvent(new CustomEvent('close_attachment_manager', 
                            {bubbles: true, composed: true, 
                                detail: {  required: this.required,
                                            additional: this.additional }}));
    }

}