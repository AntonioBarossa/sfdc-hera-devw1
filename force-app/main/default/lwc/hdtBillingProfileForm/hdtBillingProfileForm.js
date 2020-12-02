import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormFields from '@salesforce/apex/HDT_LC_BillingProfileForm.getFormFields';
import createBillingProfile from '@salesforce/apex/HDT_LC_BillingProfileForm.createBillingProfile';

export default class hdtBillingProfileForm extends LightningElement {

    @api accountId;
    loading = false;
    fields;
    dataToSubmit = {};

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handlePaymentMethodSelect(event){
        this.loading = true;
        this.dataToSubmit[event.target.fieldName] = event.target.value;
        this.template.querySelector('[data-id="modal-body"]').classList.remove('modal-body-height');

        getFormFields({paymentMethod: event.target.value, accountId: this.accountId}).then(data =>{
            this.loading = false;
            this.fields = data;
            console.log(JSON.parse(JSON.stringify(data)));
            
        }).catch(error => {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
            console.log('Errore: ',error.body.message);
        });

    }

    handleCollectFieldsData(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;
        console.log(this.dataToSubmit);
    }

    validFields() {

        let isValid = true;

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {

                switch (field.fieldName) {
                    case 'PaymentMethod__c':
                        if(field.value == null){
                            isValid = false;
                            field.reportValidity();
                        }
                        break;
                    case 'InvoiceEmailAddress__c':
                        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
                            isValid = false;
                            field.reportValidity();
                        }
                        break;
                    case 'InvoiceCertifiedEmailAddress__c':
                        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
                            isValid = false;
                            field.reportValidity();
                        }
                        break;
                    default:
                        isValid = false;
                        break;
                }

            });
        } else {
            isValid = false;
        }

        return isValid;

    }


    handleSaveEvent(){
        if(this.validFields()){

            this.dataToSubmit['Account__c'] = this.accountId;

            this.loading = true;
            createBillingProfile({billingProfile: this.dataToSubmit}).then(data =>{
                this.loading = false;
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Metodo di pagamento creato con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
                this.dispatchEvent(new CustomEvent('newbillingprofile'));
                this.handleCancelEvent();
                
            }).catch(error => {
                this.loading = false;
    
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        }

    }
}