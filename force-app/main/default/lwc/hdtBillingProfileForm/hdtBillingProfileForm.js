import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormFields from '@salesforce/apex/HDT_LC_BillingProfileForm.getFormFields';
import createBillingProfile from '@salesforce/apex/HDT_LC_BillingProfileForm.createBillingProfile';
import getAccountOwnerInfo from '@salesforce/apex/HDT_LC_BillingProfileForm.getAccountOwnerInfo';
import getLegalAccount from '@salesforce/apex/HDT_LC_BillingProfileForm.getLegalAccount';
import getCloneBillingProfile from '@salesforce/apex/HDT_LC_BillingProfileForm.getCloneBillingProfile';

export default class hdtBillingProfileForm extends LightningElement {

    @api accountId;
    @api recordId;
    loading = false;
    @track fields = [];
    @track fatturazioneElettronicaFields = [];
    isfatturazioneElettronicaVisible = false;
    @track tipologiaIntestatarioFields = [];
    wrapAddressObject = {};
    dataToSubmit = {};
    saveErrorMessage = '';
    cloneObject = {};

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleGetFormFields(paymentMethod){
        getFormFields({paymentMethod: paymentMethod, accountId: this.accountId}).then(data =>{
            this.loading = false;
            // this.fields = data.choosenFields;
            
            this.fields = [];
            if(data.choosenFields !== undefined){
                data.choosenFields.forEach(el => {
                    let value = '';
                    let disable = false;

                    switch (el) {
                        case 'XMLType__c':
                            value = 'Sintetico';
                            console.log('XMLType__c default: ', value);

                            break;
                        case 'IbanCountry__c':
                            value = 'IT';
                            disable = true;
                            break;
                    
                        default:
                            break;
                    }


                    this.fields.push({
                        fieldName: el,
                        visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                        disabled: disable,
                        value: value
                    });
                    value = '';
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

    handlePaymentMethodSelect(event){
        this.loading = true;
        this.fatturazioneElettronicaFields = [];
        this.tipologiaIntestatarioFields = [];
        this.dataToSubmit[event.target.fieldName] = event.target.value;
        this.template.querySelector('[data-id="modal-body"]').classList.remove('modal-body-height');
        this.handleGetFormFields(event.target.value);
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

    tipologiaIntestatarioInit(fieldValue){
            switch (fieldValue) {
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
                            message: 'Error',
                            message: 'Error',
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(toastErrorMessage);
                        console.log('Errore - tipologiaIntestatarioInit: ', JSON.stringify(error));
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

    handleCollectFieldsData(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;

        if (event.target.fieldName === 'SignatoryType__c') {
            this.resetTipologiaIntestatario();
            this.tipologiaIntestatarioInit(event.target.value);
        }

        if (event.target.fieldName === 'LegalAgent__c') {

            console.log('legale rapresentante: ', event.target.value);

            if(event.target.value != '') {
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
                        message: error.body.message,
                        message: 'Error',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    console.log('Errore - handleCollectFieldsData: ', error.body.message);
                });
            } else {
                this.setTipologiaIntestatario({
                    fiscalCode: '',
                    firstName: '',
                    lastName: ''
                });
            }

        }

        if (event.target.fieldName === 'OtherPayer__c') {

            if(event.target.value != '') {
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
            } else {
                this.setTipologiaIntestatario({
                    fiscalCode: '',
                    firstName: '',
                    lastName: ''
                });
            }
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
            this.fields[this.fields.findIndex(el => el.fieldName === 'IbanCountry__c')].visibility = !event.target.value;
            this.fields[this.fields.findIndex(el => el.fieldName === 'IBAN__c')].visibility = event.target.value;

            this.fields[this.fields.findIndex(el => el.fieldName === 'IBAN__c')].value = ' ';

            console.log('IBAN__c value on toggle: ', this.fields[this.fields.findIndex(el => el.fieldName === 'IBAN__c')].value);
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
                            this.saveErrorMessage = 'Devi scegliere un metodo di pagamento';
                        }
                        break;
                    // case 'InvoiceEmailAddress__c':
                    //     if (field.value !== null && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
                    //         isValid = false;
                    //         field.reportValidity();
                    //     }
                    //     break;
                    // case 'InvoiceCertifiedEmailAddress__c':
                    //     if (field.value !== null && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
                    //         isValid = false;
                    //         field.reportValidity();
                    //     }
                    //     break;
                }

            });
        } else {
            isValid = false;
        }

        return isValid;

    }

    handleWrapAddressObject(){

        this.wrapAddressObject = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();

        console.log('handleWrapAddressObject: ', JSON.stringify(this.wrapAddressObject));

        if(this.dataToSubmit['InvoicingStreetName__c'] != this.wrapAddressObject['Via']){
            this.dataToSubmit['InvoicingStreetName__c'] = this.wrapAddressObject['Via'];
        }
        if(this.dataToSubmit['InvoicingCity__c'] != this.wrapAddressObject['Comune']){
            this.dataToSubmit['InvoicingCity__c'] = this.wrapAddressObject['Comune'];
        }
        if(this.dataToSubmit['InvoicingPostalCode__c'] != this.wrapAddressObject['CAP']){
            this.dataToSubmit['InvoicingPostalCode__c'] = this.wrapAddressObject['CAP'];
        }
        if(this.dataToSubmit['InvoicingCountry__c'] != this.wrapAddressObject['Stato']){
            this.dataToSubmit['InvoicingCountry__c'] = this.wrapAddressObject['Stato'];
        }
        if(this.dataToSubmit['InvoicingProvince__c'] != this.wrapAddressObject['Provincia']){
            this.dataToSubmit['InvoicingProvince__c'] = this.wrapAddressObject['Provincia'];
        }
        if(this.dataToSubmit['InvoicingStreetNumberExtension__c'] != this.wrapAddressObject['Estens.Civico']){
            this.dataToSubmit['InvoicingStreetNumberExtension__c'] = this.wrapAddressObject['Estens.Civico'];
        }
        if(this.dataToSubmit['InvoicingStreetNumber__c'] != this.wrapAddressObject['Civico']){
            this.dataToSubmit['InvoicingStreetNumber__c'] = this.wrapAddressObject['Civico'];
        }

    }

    handleWrapAddressObjectReverse(){

        if(this.cloneObject['InvoicingStreetName__c'] != undefined){
            this.wrapAddressObject['Via'] = this.cloneObject['InvoicingStreetName__c'];
        }
        if(this.cloneObject['InvoicingCity__c'] != undefined){
            this.wrapAddressObject['Comune'] = this.cloneObject['InvoicingCity__c'];
        }
        if(this.cloneObject['InvoicingPostalCode__c'] != undefined){
            this.wrapAddressObject['CAP'] = this.cloneObject['InvoicingPostalCode__c'];
        }
        if(this.cloneObject['InvoicingCountry__c'] != undefined){
            this.wrapAddressObject['Stato'] = this.cloneObject['InvoicingCountry__c'];
        }
        if(this.cloneObject['InvoicingProvince__c'] != undefined){
            this.wrapAddressObject['Provincia'] = this.cloneObject['InvoicingProvince__c'];
        }
        if(this.dataToSubmit['InvoicingStreetNumberExtension__c'] != undefined){
            this.wrapAddressObject['Estens.Civico'] = this.cloneObject['InvoicingStreetNumberExtension__c'];
        }
        if(this.cloneObject['InvoicingStreetNumber__c'] != undefined){
            this.wrapAddressObject['Civico'] = this.cloneObject['InvoicingStreetNumber__c'];
        }

        this.template.querySelector("c-hdt-target-object-address-fields").getInstanceWrapObjectBilling(this.wrapAddressObject);

    }

    getClone(){
        
        this.loading = true;
        getCloneBillingProfile({billingProfileId: this.recordId}).then(data =>{
            this.loading = false;
            console.log('getClone: ', JSON.parse(JSON.stringify(data)));
            this.cloneObject = data;
            this.dataToSubmit = this.cloneObject;
            delete this.dataToSubmit.Id;
            this.handleGetFormFields(this.cloneObject.PaymentMethod__c);
            this.handleWrapAddressObjectReverse();

            console.log('data.SignatoryType__c: ', this.cloneObject.SignatoryType__c);

            // if(this.cloneObject.SignatoryType__c !== undefined){
            //     // this.resetTipologiaIntestatario();
            //     // this.tipologiaIntestatarioInit(data.SignatoryType__c);
            //     // this.template.querySelector('[data-name="SignatoryType__c"]').value = data.SignatoryType__c;
            //     // let indexOtherPayer = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'SignatoryType__c');
            //     // this.tipologiaIntestatarioFields[indexOtherPayer].value = data.SignatoryType__c;
            // }

        }).catch(error => {
            this.loading = false;

            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                message: 'Error',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleSaveEvent(){
        if(this.validFields()){

            this.dataToSubmit['Account__c'] = this.accountId;

            // if(Object.keys(this.wrapAddressObject).length === 0){
                console.log('save address:');
                this.handleWrapAddressObject();
            // }

            this.loading = true;
            createBillingProfile({billingProfile: this.dataToSubmit}).then(data =>{
                this.loading = false;
                this.recordId = '';
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
            console.log(this.saveErrorMessage);
            const saveToastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: this.saveErrorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(saveToastErrorMessage);
        }

    }

    connectedCallback(){
        if(this.recordId !== undefined && this.recordId !== ''){
            this.getClone();
        }
    }
}