import { LightningElement,api,wire } from 'lwc';
import getRecord from '@salesforce/apex/HDT_QR_ActivityCustom.getRecordByIdS';
import riassegna from '@salesforce/apex/HDT_UTL_ActivityCustom.riassegnaComCod';
import cambia from '@salesforce/apex/HDT_UTL_ActivityCustom.cambiaphaseComm';

export default class HdtCommercialRiassignButton extends LightningElement {


    @api isRiassignButton = false;
    @api isApproveFase = false;
    @api recordId;
    @api caseid;


    connectedCallback(){
        console.log('IDDDDD:' + this.recordId);
        getRecord({
            activityId: this.recordId
        }).then(result => {
            this.caseid = result.case__c;
            if(result.case__r.phase__c == 'In Lavorazione'){
                this.isRiassignButton = true;
            }
            else if(result.case__r.phase__c == 'In Attesa Approvazione'){
                this.isApproveFase = true;
            }
            /*
            const event = new ShowToastEvent({
                title: 'Successo',
                message: 'Approvazione Inviata',
                variant: 'success',
            });
            this.dispatchEvent(event);*/
        });

    }

    handleSave(){
        riassegna({
            recordId : this.recordId
        }).then(result => {
            if(result){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Approvazione Inviata',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
        });
     
    }

    approve(){
        cambia({
            recordId : this.recordId,
            causale : 'Si'
        }).then(result => {
            if(result){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Arprovato',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
        });
     
    }

    reject(){
        cambia({
            recordId : this.recordId,
            causale : 'No'
        }).then(result => {
            if(result){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Rifiutato',
                    variant: 'success',
                });
                this.dispatchEvent(event);
            }
        });
     
    }




}