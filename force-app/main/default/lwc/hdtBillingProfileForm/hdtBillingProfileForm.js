import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormFields from '@salesforce/apex/HDT_LC_BillingProfileForm.getFormFields';
import createBillingProfile from '@salesforce/apex/HDT_LC_BillingProfileForm.createBillingProfile';
import getAccountOwnerInfo from '@salesforce/apex/HDT_LC_BillingProfileForm.getAccountOwnerInfo';
import getLegalAccount from '@salesforce/apex/HDT_LC_BillingProfileForm.getLegalAccount';

export default class hdtBillingProfileForm extends LightningElement {

    @api accountId;
    loading = false;
    @track fields = [];
    @track fatturazioneElettronicaFields = [];
    isfatturazioneElettronicaVisible = false;
    @track tipologiaIntestatarioFields = [];
    dataToSubmit = {};

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handlePaymentMethodSelect(event){
        this.loading = true;
        this.fatturazioneElettronicaFields = [];
        this.tipologiaIntestatarioFields = [];
        this.dataToSubmit[event.target.fieldName] = event.target.value;
        this.template.querySelector('[data-id="modal-body"]').classList.remove('modal-body-height');

        getFormFields({paymentMethod: event.target.value, accountId: this.accountId}).then(data =>{
            this.loading = false;
            // this.fields = data.choosenFields;
            
            this.fields = [];
            if(data.choosenFields !== undefined){
                data.choosenFields.forEach(el => {
                    let value = '';

                    switch (el) {
                        case 'XMLType__c':
                            value = 'Sintetico';
                            console.log('XMLType__c default: ', value);

                            break;
                    
                        default:
                            break;
                    }


                    this.fields.push({
                        fieldName: el,
                        visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                        disabled: false,
                        value: value
                    });
                });
            }

            if(data.fatturazioneElettronica !== undefined){
                this.fatturazioneElettronicaFields = data.fatturazioneElettronica;
                this.isfatturazioneElettronicaVisible = true;
            }

            if (data.tipologiaIntestatario !== undefined) {
                data.tipologiaIntestatario.forEach(el => {
                    this.tipologiaIntestatarioFields.push({
                        fieldName: el,
                        visibility: (el === 'BankAccountSignatoryFiscalCode__c' || el === 'BankAccountSignatoryFirstName__c' || el === 'BankAccountSignatoryLastName__c' || el === 'OtherPayer__c' || el === 'LegalAgent__c') ? false : true,
                        disabled: (el === 'BankAccountSignatoryFiscalCode__c' || el === 'BankAccountSignatoryFirstName__c' || el === 'BankAccountSignatoryLastName__c') ? true : false,
                        value: ''
                    });
                });
            }
            
        }).catch(error => {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                // message: error.body.message,
                message: 'Error',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            // console.log('Errore: ',error.body.message);
        });

    }

    setTipologiaIntestatario(params){
        let indexCode = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'BankAccountSignatoryFiscalCode__c');
        let indexFirstName = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'BankAccountSignatoryFirstName__c');
        let indexLastName = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'BankAccountSignatoryLastName__c');
        this.tipologiaIntestatarioFields[indexCode].visibility = true;
        this.tipologiaIntestatarioFields[indexFirstName].visibility = true;
        this.tipologiaIntestatarioFields[indexLastName].visibility = true;

        this.tipologiaIntestatarioFields[indexCode].value = params.fiscalCode;
        this.tipologiaIntestatarioFields[indexFirstName].value = params.firstName;
        this.tipologiaIntestatarioFields[indexLastName].value = params.lastName;

        this.dataToSubmit['BankAccountSignatoryFiscalCode__c'] = params.fiscalCode;
        this.dataToSubmit['BankAccountSignatoryFirstName__c'] = params.firstName;
        this.dataToSubmit['BankAccountSignatoryLastName__c'] = params.lastName;

    }

    resetTipologiaIntestatario(){
        let indexCode = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'BankAccountSignatoryFiscalCode__c');
        let indexFirstName = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'BankAccountSignatoryFirstName__c');
        let indexLastName = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'BankAccountSignatoryLastName__c');
        this.tipologiaIntestatarioFields[indexCode].visibility = false;
        this.tipologiaIntestatarioFields[indexFirstName].visibility = false;
        this.tipologiaIntestatarioFields[indexLastName].visibility = false;
        this.tipologiaIntestatarioFields[indexCode].value = '';
        this.tipologiaIntestatarioFields[indexFirstName].value = '';
        this.tipologiaIntestatarioFields[indexLastName].value = '';

        this.dataToSubmit['BankAccountSignatoryFiscalCode__c'] = '';
        this.dataToSubmit['BankAccountSignatoryFirstName__c'] = '';
        this.dataToSubmit['BankAccountSignatoryLastName__c'] = '';

        let indexLegalAgent = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'LegalAgent__c');
        this.tipologiaIntestatarioFields[indexLegalAgent].visibility = false;
        this.dataToSubmit['LegalAgent__c'] = '';

        let indexOtherPayer = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'OtherPayer__c');
        this.tipologiaIntestatarioFields[indexOtherPayer].visibility = false;
        this.dataToSubmit['OtherPayer__c'] = '';
    }

    handleCollectFieldsData(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;

        if (event.target.fieldName === 'SignatoryType__c') {
            this.resetTipologiaIntestatario();
            switch (event.target.value) {
                case 'Stesso Sottoscrittore':
                    getAccountOwnerInfo({accountId: this.accountId}).then(data =>{
                        this.loading = false;
                        
                        this.setTipologiaIntestatario({
                            fiscalCode: data.FiscalCode__c,
                            firstName: data.FirstName__c,
                            lastName: data.LastName__c
                        });
                    }).catch(error => {
                        this.loading = false;
                        const toastErrorMessage = new ShowToastEvent({
                            title: 'Errore',
                            // message: error.body.message,
                            message: 'Error',
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(toastErrorMessage);
                        // console.log('Errore: ',error.body.message);
                    });
    
                    break;
                case 'Legale Rappresentante':
                    let indexLegalAgent = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'LegalAgent__c');
                    this.tipologiaIntestatarioFields[indexLegalAgent].visibility = true;
                    break;
                case 'Pagatore Alternativo':
                    let indexOtherPayer = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'OtherPayer__c');
                    this.tipologiaIntestatarioFields[indexOtherPayer].visibility = true;
                    break;
                default:
                    break;
            }
        }

        if (event.target.fieldName === 'LegalAgent__c') {
            getLegalAccount({contactId: event.target.value}).then(data =>{
                this.loading = false;

                this.setTipologiaIntestatario({
                    fiscalCode: data.FiscalCode__c,
                    firstName: data.FirstName,
                    lastName: data.LastName
                });

            }).catch(error => {
                this.loading = false;
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    // message: error.body.message,
                    message: 'Error',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
                // console.log('Errore: ',error.body.message);
            });
        }

        if (event.target.fieldName === 'OtherPayer__c') {
            getAccountOwnerInfo({accountId: event.target.value}).then(data =>{
                this.loading = false;

                this.setTipologiaIntestatario({
                    fiscalCode: data.FiscalCode__c,
                    firstName: data.FirstName__c,
                    lastName: data.LastName__c
                });

            }).catch(error => {
                this.loading = false;
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    // message: error.body.message,
                    message: 'Error',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
                // console.log('Errore: ',error.body.message);
            });
        }

        if (event.target.fieldName === 'BillSendingMethod__c') {
            this.fields[this.fields.findIndex(el => el.fieldName === 'InvoiceCertifiedEmailAddress__c')].visibility = event.target.value === 'Invio tramite PEC';
            this.fields[this.fields.findIndex(el => el.fieldName === 'SendCertifiedEmailConsentDate__c')].visibility = event.target.value === 'Invio tramite PEC';
        }

        if(event.target.fieldName === 'IbanIsForeign__c'){
            this.fields[this.fields.findIndex(el => el.fieldName === 'IbanCIN_IBAN__c')].visibility = !event.target.value;
            this.fields[this.fields.findIndex(el => el.fieldName === 'IbanCIN__c')].visibility = !event.target.value;
            this.fields[this.fields.findIndex(el => el.fieldName === 'IbanABI__c')].visibility = !event.target.value;
            this.fields[this.fields.findIndex(el => el.fieldName === 'IbanCAB__c')].visibility = !event.target.value;
            this.fields[this.fields.findIndex(el => el.fieldName === 'IbanCodeNumber__c')].visibility = !event.target.value;
            this.fields[this.fields.findIndex(el => el.fieldName === 'IBAN__c')].visibility = event.target.value;
        }

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
                        if (field.value !== null && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
                            isValid = false;
                            field.reportValidity();
                        }
                        break;
                    case 'InvoiceCertifiedEmailAddress__c':
                        if (field.value !== null && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
                            isValid = false;
                            field.reportValidity();
                        }
                        break;
                }

            });
        } else {
            isValid = false;
        }

        return isValid;

    }

    handleWrapAddressObject(event){
        console.log('handleWrapAddressObject: ', JSON.stringify(event.detail.wrapAddressObject));
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
                    // message: error.body.message,
                    message: 'Error',
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        } else {
            console.log('Error: Check input validity!');
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Check input validity',
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        }

    }
}