import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.save';
//INIZIO SVILUPPI EVERIS
import updateOrder from '@salesforce/apex/HDT_LC_SelfReading.updateOrder';
//FINE SVILUPPI EVERIS
import saveDraft from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.saveDraft';
import cancel from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.cancel';

export default class hdtChildOrderProcessActions extends LightningElement {
    @api order;
    @api lastStepNumber;
    @api draftObject;
    @api draftObjectApiName;
    @api diffDraftObjectApiName;
    @api diffFields;
    loading = false;
    isDialogVisible = false;
    
    get disabledSave(){
        //INIZIO SVILUPPI EVERIS

        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

            console.log(this.lastStepNumber);

            return !(this.lastStepNumber === 1);

        }

        //FINE SVILUPPI EVERIS

        console.log('lastStepNumber disabledSave: ', this.lastStepNumber);
        console.log('this.order.Step__c disabledSave: ', this.order.Step__c);
        return (this.order.Step__c !== this.lastStepNumber);
    }

    handleSave(){
        this.loading = true;
        //INIZIO SVILUPPI EVERIS
        /*if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
            
            updateOrder({recordId: this.order.Id, completed:true})
            .then(result => {

                console.log(result);

                this.loading = false; 

                this.dispatchEvent(new CustomEvent('redirecttoparent'));

                return;

            })

        }
        //FINE SVILUPPI EVERIS*/
        save({order: this.order}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoparent'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleSaveDraft(){
        // console.log('handleSaveDraft: ' + this.draftObjectApiName + ' ' + JSON.stringify(this.draftObject));
        console.log('handleSaveDraft: ' + this.draftObjectApiName);
        console.log('handleSaveDraft: ' + JSON.stringify(this.draftObject));
        console.log('handleSaveDraft Diff: ' + this.diffDraftObjectApiName + ' ' + JSON.stringify(this.diffFields));

        //INIZIO SVILUPPI EVERIS
        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
           
            this.loading = true;
      
            updateOrder({recordId: this.order.Id, completed:true})
            .then(result => {

                console.log(result);

                this.loading = false; 

                this.dispatchEvent(new CustomEvent('redirecttoparent'));

                return;

            });
            
        }
        //FINE SVILUPPI EVERIS
        
        if ( this.draftObject != null && this.diffFields == null) {

            this.loading = true;
            saveDraft({objectApiName: this.draftObjectApiName, objectToUpdate: this.draftObject}).then(data =>{
                this.loading = false;
    
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
    
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Processo salvato in bozza',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    
            }).catch(error => {
                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else if( this.diffFields != null && this.draftObject == null ) {

            this.loading = true;
            saveDraft({objectApiName:this.diffDraftObjectApiName, objectToUpdate: this.diffFields}).then(data =>{
                this.loading = false;
    
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
    
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Processo salvato in bozza',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    
            }).catch(error => {
                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else if(this.draftObject != null && this.diffFields != null){

            this.loading = true;
            saveDraft({
                objectApiName: this.draftObjectApiName,
                objectToUpdate: this.draftObject,
                diffObjectApiName: this.diffDraftObjectApiName,
                diffObjectToUpdate: this.diffFields

                }).then(data =>{
                this.loading = false;
    
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
    
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Processo salvato in bozza',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    
            }).catch(error => {
                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else {
            console.log('hdtChildOrderProcessActions - handleSaveDraft - draftObject has no data');
            this.dispatchEvent(new CustomEvent('redirecttoparent'));
        }
    }

    callCancel(cancellationReason){
        this.loading = true;
        cancel({order: this.order, cancellationReason: cancellationReason}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoparent'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo annullato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleCancel(){
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){

            this.callCancel(event.detail.choice);

        } else {
            this.isDialogVisible = false;
        }
    }
}