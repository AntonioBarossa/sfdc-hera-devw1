import { LightningElement,api,wire } from 'lwc';
import getRecord from '@salesforce/apex/HDT_QR_ActivityCustom.getRecordByIdS';
import riassegna from '@salesforce/apex/HDT_UTL_ActivityCustom.riassegnaComCod';
import cambia from '@salesforce/apex/HDT_UTL_ActivityCustom.cambiaphaseComm';

export default class HdtCommercialRiassignButton extends LightningElement {


    @api isRiassignButton = false;
    @api loading = false;
    @api isShowButtonRiassign = false;
    @api isApproveFase = false;
    @api recordId;
    @api causale = '';
    @api caseid;

    handleReassignmentReasonChange(event){
        if(event.detail.value !=undefined &&event.detail.value !=""){
            this.isShowButtonRiassign= true;
            this.causale = event.detail.value;
        }else{
            this.isShowButtonRiassign= false;
        }
    }
    connectedCallback(){
        this.loading = true;
        console.log('IDDDDD:' + this.recordId);
        getRecord({
            activityId: this.recordId
        }).then(result => {
            console.log('enter::::' + JSON.stringify(result));
            this.caseid = result.Case__c;
            if(result.Case__r.Phase__c != 'In Attesa Approvazione'){
                console.log('enter::::INLAV');
                this.isRiassignButton = true;
            }
            else if(result.Case__r.Phase__c == 'In Attesa Approvazione'){
                this.isApproveFase = true;
            }
            this.loading = false;
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
            recordId : this.recordId,
            causale : this.causale
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
            if(result == true){
                const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Approvato',
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