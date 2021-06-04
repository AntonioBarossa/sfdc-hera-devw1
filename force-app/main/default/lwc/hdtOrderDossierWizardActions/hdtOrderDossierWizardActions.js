import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.save';
import cancel from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.cancel';
import isSaveDisabled from '@salesforce/apex/HDT_LC_OrderDossierWizardActions.isSaveDisabled';

export default class hdtOrderDossierWizardActions extends LightningElement {
    
    @api orderParentRecord;
    currentStep = 2;
    loading = false;
    isSaveButtonDisabled = false;
    isDialogVisible = false;

    getSaveButtonStatus(){
        this.loading = true;
        isSaveDisabled({orderParentId: this.orderParentRecord.Id}).then(data =>{
            console.log('isSaveDisabled: ', data);
            this.loading = false;
            this.isSaveButtonDisabled = data;

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

    handleSave(){
        this.loading = true;
        save({orderParent: this.orderParentRecord}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoorderrecordpage'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Order confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    callCancel(cancellationReason){
        this.loading = true;
        cancel({orderParent: this.orderParentRecord, cancellationReason: cancellationReason}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoorderrecordpage'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Order annullato con successo',
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

    connectedCallback(){
        this.getSaveButtonStatus();
    }

}