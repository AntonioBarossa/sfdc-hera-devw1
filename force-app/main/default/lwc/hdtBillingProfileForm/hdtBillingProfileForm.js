import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormFields from '@salesforce/apex/HDT_LC_BillingProfileForm.getFormFields';

export default class hdtBillingProfileForm extends LightningElement {

    loading = false;
    fields;

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handlePaymentMethodSelect(event){
        this.loading = true;
        this.template.querySelector('[data-id="modal-body"]').classList.remove('modal-body-height');

        getFormFields({paymentMethod: event.target.value}).then(data =>{
            this.loading = false;
            this.fields = data;
            console.log(JSON.parse(JSON.stringify(data)));
            
        }).catch(error => {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }
}