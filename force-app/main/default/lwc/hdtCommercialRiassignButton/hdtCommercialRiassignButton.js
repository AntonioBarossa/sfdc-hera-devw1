import { LightningElement,api,wire } from 'lwc';
import getRecord from '@salesforce/apex/HDT_QR_ActivityCustom.getRecordByIdS';
import riassegna from '@salesforce/apex/HDT_UTL_ActivityCustom.riassegnaComCod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cambia from '@salesforce/apex/HDT_UTL_ActivityCustom.cambiaphaseComm';
import { getRecordNotifyChange  } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';

export default class HdtCommercialRiassignButton extends LightningElement {


    @api isRiassignButton = false;
    @api loading = false;
    @api isShowButtonRiassign = false;
    @api isInApprovazione = false;
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
        getRecord({
            activityId: this.recordId
        }).then(result => {
            this.caseid = result.Case__c;
            if(this.caseid != undefined && this.caseid != ''){           
                if(result.Case__r.Phase__c != 'In Attesa Approvazione'){
                    this.isRiassignButton = true;
                }
                else if(result.Case__r.Phase__c == 'In Attesa Approvazione'){
                    if(result.OwnerId == userId && (result.ManuallyReassigned__c == true || result.Queued__c == true)){
                        this.isApproveFase = true;
                    }else{
                        this.isInApprovazione = true;
                    }
                }
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
            console.log('prerefresh');
            if(result == true){
                console.log('prerefreshPOST');
               // this.isRiassignButton = false;
               // this.isApproveFase = true;
                /*const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Approvazione Inviata',
                    variant: 'success',
                });
                this.dispatchEvent(event);*/
                //this.dispatchEvent(new CustomEvent('refreshpage'));
            }
        });
        window.location.reload();
    }

    approve(){
        cambia({
            recordId : this.recordId,
            causale : 'Si'
        }).then(result => {
            console.log('prerefresh');
            if(result == true){
               /* const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Approvato',
                    variant: 'success',
                });
                this.dispatchEvent(event);*/
                //window.location.reload();
            }
        });
        window.location.reload();
    }

    reject(){
        console.log('rigettata');
        cambia({
            recordId : this.recordId,
            causale : 'No'
        }).then(result => {
            if(result == true){
               /* const event = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Rifiutato',
                    variant: 'success',
                });
                this.dispatchEvent(event);*/
                //window.location.reload();
            }
        });
        window.location.reload();
    }




}