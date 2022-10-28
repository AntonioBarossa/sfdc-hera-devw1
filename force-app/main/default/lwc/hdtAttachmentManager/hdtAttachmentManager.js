/*
    * @author Marco Arci (marco.arci@webresults.it)
    * @date 27/06/2022
    * @description JS - Gestione Allegati Obbligatori e Aggiuntivi
*/

import { LightningElement, api, track, wire } from 'lwc';
import getRecordsById from '@salesforce/apex/HDT_LC_AttachmentManager.getRecordsById';
import getAdditionalAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.getAdditionalAttachment';
import getRequiredAttachment from '@salesforce/apex/HDT_LC_AttachmentManager.getRequiredAttachment';
import getRecordsToCheck from '@salesforce/apex/HDT_LC_AttachmentManager.getRecordsToCheck';
import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE} from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";
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
    @api interviewId;

     //subscribe
     @wire(MessageContext)
     messageContext;
     //subscribe

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
                if( this.numberOfFiles > 0 ){
                    this.files = result;
                }else{
                    this.files = null;
                }
            })
            .catch(error => {
                this.error = error;
            }); 
    }

    outputObject(){
        return {
            AdditionalAttachments__c: this.template.querySelector("[data-id='AdditionalAttachments__c']")?.value
        };
    }

    
    @api
    specificValidate(){
        let objectToReturn = { 
            isValid: true
        };
        /*
        if(this.objectName?.toUpperCase() == 'CASE'){
            switch(this.currObject.Type.toUpperCase()) {
                case 'MODIFICA DATI CONTRATTUALI':
                    if( this.currObject.RequestSource__c.toUpperCase() != 'DA CONTRIBUENTE' ){
                        objectToReturn = { 
                            isValid: false, 
                            errorMessage: 'È obbligatorio inserire almeno un allegato' 
                        };  
                    }
                
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
                case 'PIANO RATEIZZAZIONE':
                    objectToReturn = { 
                        isValid: false, 
                        errorMessage: 'È obbligatorio inserire almeno un allegato' 
                    };
                    break;
                
                default:
                    break;
            }
        }
        */
        return objectToReturn;
    }


    subscribeMC() {
		// recordId is populated on Record Pages, and this component
		// should not update when this component is on a record page.
        this.subscription = subscribe(
            this.messageContext,
            BUTTONMC,
            (mc) => {if(this.interviewId==mc.sessionid) this.eventButton = mc.message},
            //{ scope: APPLICATION_SCOPE }
        );
		// Subscribe to the message channel
	}

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    @api
    validate(){ 
        console.log("event catched   "+this.eventButton);
        this.unsubscribeToMessageChannel();
        let message, isValid=true;

        if('cancel' != this.eventButton){
            
            if(this.numberOfFiles == 0){    //se non ci sono allegati, quale messaggio mostrare
                var checkCustomValidate = this.specificValidate();
                if(checkCustomValidate?.isValid == false){
                    isValid = checkCustomValidate?.isValid;
                    message = checkCustomValidate?.errorMessage;
                }else if(this.required?.length > 0){
                    isValid = true;
            
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
                }
            }
        }

        let outputAdditional = this.outputObject();
        if(this.interviewId){
            if(!isValid){
                window.sessionStorage.setItem(this.interviewId, JSON.stringify(outputAdditional));
            }else{
                window.sessionStorage.removeItem(this.interviewId);
            }
        }

        return { 
            isValid : isValid, 
            errorMessage: message? message : null
        };
    }

    async connectedCallback(){

        this.subscribeMC();

        this.getFiles();

        this.currObject = await getRecordsToCheck({
            recordId: this.recordId
            });


        const oldAdditional = window.sessionStorage.getItem(this.interviewId);
        if(this.interviewId && oldAdditional){
            try{
                this.additional = JSON.parse(oldAdditional)?.AdditionalAttachments__c;
            }catch(e){
                console.log(e);
            }
        }

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
                                detail: {   required: this.required,
                                            additional: this.additional,
                                            numberOfFiles : this.files?.length
                                        }}));
    }

}