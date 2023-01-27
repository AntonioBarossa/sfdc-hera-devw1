import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormFields from '@salesforce/apex/HDT_LC_BillingProfileForm.getFormFields';
import createBillingProfile from '@salesforce/apex/HDT_LC_BillingProfileForm.createBillingProfile';
import getAccountOwnerInfo from '@salesforce/apex/HDT_LC_BillingProfileForm.getAccountOwnerInfo';
import getLegalAccount from '@salesforce/apex/HDT_LC_BillingProfileForm.getLegalAccount';
import getCloneBillingProfile from '@salesforce/apex/HDT_LC_BillingProfileForm.getCloneBillingProfile';

export default class hdtBillingProfileForm extends LightningElement {

    @api sale;
    @api accountId;
    @api recordId;
    loading = false;
    @track fields = [];
  //  @track refreshField = true;
    @track fatturazioneElettronicaFields = [];
    isfatturazioneElettronicaVisible = false;
    @track tipologiaIntestatarioFields = [];
    wrapAddressObject = {};
    dataToSubmit = {};
    @api saveErrorMessage = [];
    cloneObject = {};
    isVerifiedAddress = false;
    isForeignAddress = false;
    signatoryTypeIsVisible = false;

    get signatoryTypeOptions() {
        let options = [
            { label: 'Pagatore Alternativo', value: 'Pagatore Alternativo' }
        ];
        if(this.sale != null){
            if (this.sale.Account__r.Category__c === 'Famiglie' 
                || this.sale.Account__r.Category__c === 'Parti comuni'
                || this.sale.Account__r.Category__c === 'Ditta individuale') {
                options.push({ label: 'Stesso Sottoscrittore', value: 'Stesso Sottoscrittore' });
            } else if (this.sale.Account__r.Category__c !== 'Famiglie' 
                        && this.sale.Account__r.Category__c !== 'Parti comuni'
                        && this.sale.Account__r.Category__c !== 'Ditta individuale') {
                options.push({ label: 'Legale Rappresentante', value: 'Legale Rappresentante' });
            }
        }else{
            options.push({ label: 'Stesso Sottoscrittore', value: 'Stesso Sottoscrittore' });
            options.push({ label: 'Legale Rappresentante', value: 'Legale Rappresentante' });
        }
        

        return options;
    }

    validateEmail(email) {
        const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }

    handleCancelEvent(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleGetFormFields(paymentMethod){
        getFormFields({paymentMethod: paymentMethod, accountId: this.accountId}).then(data =>{
            this.loading = false;
            // this.fields = data.choosenFields;
            this.signatoryTypeIsVisible = false;
            
            this.fields = [];
            if(data.choosenFields !== undefined){
                data.choosenFields.forEach(el => {
                    let value = '';
                    let disable = false;
                    let required = false;

                    switch (el) {
                        case 'IbanCountry__c':
                            value = 'IT';
                            disable = true;
                            break;
                        case 'IbanCIN_IBAN__c':
                            value = this.cloneObject.IbanCIN_IBAN__c ?? '';
                            break;
                        case 'BillSendingMethod__c':
                            required = true;
                            value = this.cloneObject.BillSendingMethod__c ?? '';
                            break;
                        case 'SubjectCode__c':
                            required = true;
                            value = this.cloneObject.SubjectCode__c ?? '';
                            break;
                        case 'ElectronicInvoicingMethod__c':
                            required = true;
                            value = this.cloneObject.ElectronicInvoicingMethod__c ?? '';
                            break;
                        case 'XMLType__c':
                            required = true;
                            value = this.cloneObject.XMLType__c ?? '';
                            break;
                        case 'CIG__c':
                            required = true;
                            value = this.cloneObject.CIG__c ?? '';
                            break;
                        case 'CUP__c':
                            required = true;
                            value = this.cloneObject.CUP__c ?? '';
                            break;
                        case 'SubjectCodeStartDate__c':
                            required = true;
                            value = this.cloneObject.SubjectCodeStartDate__c ?? '';
                            break;
                        case 'SignatoryType__c':
                            required = true;
                            value = this.cloneObject.SignatoryType__c ?? '';
                            break;
                        case 'InvoiceEmailAddress__c':
                            required = false;
                            value = this.cloneObject.InvoiceEmailAddress__c ?? '';
                            break;
                        default:
                            console.log('clone value ' + el + ' : ' + this.cloneObject[el]);
                            value = this.cloneObject[el] ?? '';
                            break;
                    }
                    switch (el) {
                        case 'CreateContractAccount__c':
                            this.fields.push({
                                fieldName: el,
                                visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                                disabled: disable,
                                value: false,
                                required: required
                            });
                            break;
                        case 'IbanIsForeign__c':
                            this.fields.push({
                                fieldName: el,
                                visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                                disabled: disable,
                                value: false,
                                required: required
                            });
                            break;
                            default:
                            this.fields.push({
                                fieldName: el,
                                visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                                disabled: disable,
                                value: value,
                                required: required
                            });
                                break;
                    }
                   /* this.fields.push({
                        fieldName: el,
                        visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                        disabled: disable,
                        value: value,
                        required: required
                    }); */
                    value = '';
                });
                console.log('*******:' + JSON.stringify(this.fields));
            }

            if(data.fatturazioneElettronica !== undefined){

                this.fatturazioneElettronicaFields = [];

                data.fatturazioneElettronica.forEach(el => {

                    let required = false;
                    let value = '';

                    switch (el) {
                        case 'ElectronicInvoicingMethod__c':
                            required = true;
                            value = this.cloneObject.ElectronicInvoicingMethod__c ?? 'XML + carta/email';
                            this.dataToSubmit['ElectronicInvoicingMethod__c'] = value;
                            break;
                        case 'XMLType__c':
                            value = this.cloneObject.XMLType__c ?? 'Sintetico';
                            this.dataToSubmit['XMLType__c'] = value;
                            console.log('XMLType__c default: ', value);
                            break;
                        default:
                            value = this.cloneObject[el] ?? '';
                            break;
                    }

                    this.fatturazioneElettronicaFields.push({
                        fieldName: el,
                        required: required,
                        value: value,
                        disabled: false
                    });
                });

                this.isfatturazioneElettronicaVisible = true;
            }

            if (data.tipologiaIntestatario !== undefined) {
                data.tipologiaIntestatario.forEach(el => {

                    let disable = false;
                    let required = false;

                    switch (el) {
                        case 'SignatoryType__c':
                            required = true;
                            break;
                        case 'OtherPayer__c':
                            required = true;
                        break;
                        default:
                            break;
                    }

                    this.tipologiaIntestatarioFields.push({
                        fieldName: el,
                        visibility: (el === 'BankAccountSignatoryFiscalCode__c' || el === 'BankAccountSignatoryFirstName__c' || el === 'BankAccountSignatoryLastName__c' || el === 'OtherPayer__c' || el === 'LegalAgent__c') ? false : true,
                        disabled: (el === 'BankAccountSignatoryFiscalCode__c' || el === 'BankAccountSignatoryFirstName__c' || el === 'BankAccountSignatoryLastName__c') ? true : false,
                        value: '',
                        required: required
                    });
                });

                this.signatoryTypeIsVisible = this.tipologiaIntestatarioFields.length > 0;

                if(this.cloneObject.SignatoryType__c !== undefined){
                    // this.resetTipologiaIntestatario();
                    this.tipologiaIntestatarioInit(this.cloneObject.SignatoryType__c);
                    // this.template.querySelector('[data-name="SignatoryType__c"]').value = data.SignatoryType__c;
                    // let indexOtherPayer = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'SignatoryType__c');
                    // this.tipologiaIntestatarioFields[indexOtherPayer].value = data.SignatoryType__c;
                }
            }

            
            
        }).catch(error => {
            this.loading = false;
            // let errorMessage = '';

            // if (error.body.message !== undefined) {
            //     errorMessage = error.body.message;
            // } else if(error.message !== undefined){
            //     errorMessage = error.message;
            // } else if(error.body.pageErrors !== undefined){
            //     errorMessage = error.body.pageErrors[0].message;
            // }

            // console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: 'Errore',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            console.log('Errore: ',JSON.stringify(error));
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

                    if (this.cloneObject.LegalAgent__c !== undefined && this.cloneObject.LegalAgent__c !== '' && this.cloneObject.LegalAgent__c !== null) {
                        this.tipologiaIntestatarioFields[indexLegalAgent].value = this.cloneObject.LegalAgent__c;

                        getLegalAccount({contactId: this.cloneObject.LegalAgent__c}).then(data =>{
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
                                message: 'Error',
                                variant: 'error',
                                mode: 'sticky'
                            });
                            this.dispatchEvent(toastErrorMessage);
                            console.log('Errore - handleCollectFieldsData: ', JSON.stringify(error));
                        });
                    }

                    break;
                case 'Pagatore Alternativo':
                    let indexOtherPayer = this.tipologiaIntestatarioFields.findIndex(el => el.fieldName === 'OtherPayer__c');
                    this.tipologiaIntestatarioFields[indexOtherPayer].visibility = true;

                    if (this.cloneObject.OtherPayer__c !== undefined && this.cloneObject.OtherPayer__c !== null && this.cloneObject.OtherPayer__c !== '') {

                        this.tipologiaIntestatarioFields[indexOtherPayer].value = this.cloneObject.OtherPayer__c;

                        getAccountOwnerInfo({accountId: this.cloneObject.OtherPayer__c}).then(data =>{
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

                    break;
                default:
                    break;
            }
    }

    handleCollectFieldsData(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;

        let notApplicableFields = ['SignatoryType__c','LegalAgent__c','OtherPayer__c','BillSendingMethod__c'];

        if (!notApplicableFields.includes(event.target.fieldName) && event.target.fieldName !== undefined) {
            let elem = this.fields.find(el => el.fieldName === event.target.fieldName);
            if(elem){
                elem.value = event.target.value;
            }
        }

        if (event.target.name === 'SignatoryType__c') {
            this.dataToSubmit[event.target.name] = event.target.value;
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
                        message: 'Error',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    console.log('Errore - handleCollectFieldsData: ', JSON.stringify(error));
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
           // this.refreshField = false;
            this.fields[this.fields.findIndex(el => el.fieldName === 'InvoiceCertifiedEmailAddress__c')].visibility = event.target.value === 'Invio tramite PEC';
            this.fields[this.fields.findIndex(el => el.fieldName === 'InvoiceCertifiedEmailAddress__c')].required = event.target.value === 'Invio tramite PEC';
            this.fields[this.fields.findIndex(el => el.fieldName === 'SendCertifiedEmailConsentDate__c')].visibility = event.target.value === 'Invio tramite PEC';
            this.fields[this.fields.findIndex(el => el.fieldName === 'SendCertifiedEmailConsentDate__c')].required = event.target.value === 'Invio tramite PEC';
            this.fields[this.fields.findIndex(el => el.fieldName === 'InvoiceEmailAddress__c')].required = event.target.value.includes('e-mail');
            this.fields[this.fields.findIndex(el => el.fieldName === 'InvoiceEmailAddress__c')].visibility = event.target.value.includes('e-mail');
           // this.refreshField = true;
            console.log('*******123:' + JSON.stringify(this.fields));
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

        if (event.target.fieldName === 'ElectronicInvoicingMethod__c') {
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'CUP__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'CIG__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'SubjectCode__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'SubjectCodeStartDate__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'SubjectCodeEndDate__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'ElectronicInvoiceCertifiedEmailAddress__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'XMLType__c')].disabled = event.target.value === 'Estero';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'SubjectCode__c')].required = event.target.value === 'XML PA';
            this.fatturazioneElettronicaFields[this.fatturazioneElettronicaFields.findIndex(el => el.fieldName === 'XMLType__c')].required = event.target.value.includes('XML');
            }

    }

    validFields() {

        console.log('Validation START');

        this.saveErrorMessage = [];
        let concatBillingErrorFields = '';
        let concatAddressErrorFields = '';

        //check Email fields validity start
        if (this.template.querySelector("[data-id='InvoiceEmailAddress__c']") !== null 
            && (this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value !== null && this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value.trim() !== '') 
            && !this.validateEmail(this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value)) {
            
            this.saveErrorMessage.push('Email Invio Bolletta non valido');
        }

        if (this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']") !== null 
            && (this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']").value !== null && this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']").value.trim() !== '') 
            && !this.validateEmail(this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']").value)) {
            
            this.saveErrorMessage.push('Email PEC Invio Bolletta non valido');
        }

        if (this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']") !== null 
            && (this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']").value !== null && this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']").value.trim() !== '') 
            && !this.validateEmail(this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']").value)) {
            
            this.saveErrorMessage.push('PEC Fatturazione Elettronica non valido');
        }
        //check Email fields validity end

        //check iban fields logic start
        if (this.template.querySelector("[data-id='IbanCIN__c']") !== null 
            && this.template.querySelector("[data-id='IbanCIN__c']").value !== null
            && this.template.querySelector("[data-id='IbanCIN__c']").value.length !== 1) {
            this.saveErrorMessage.push('Il campo CIN deve avere 1 carattere');
        }

        if (this.template.querySelector("[data-id='IbanCIN__c']") !== null 
            && this.template.querySelector("[data-id='IbanCIN__c']").value !== null
            && !/^[a-zA-Z]+$/.test(this.template.querySelector("[data-id='IbanCIN__c']").value)) {
            this.saveErrorMessage.push('Il campo CIN può contenere solo lettere');
        }

        if (this.template.querySelector("[data-id='IbanCIN_IBAN__c']") !== null 
             && this.template.querySelector("[data-id='IbanCIN_IBAN__c']").value !== null
             && this.template.querySelector("[data-id='IbanCIN_IBAN__c']").value.length !== 2) {
            this.saveErrorMessage.push('Il campo CIN-IBAN deve avere 2 caratteri');
        }
        if (this.template.querySelector("[data-id='IbanCIN_IBAN__c']") !== null 
             && this.template.querySelector("[data-id='IbanCIN_IBAN__c']").value !== null
             && !/^[0-9]+$/.test(this.template.querySelector("[data-id='IbanCIN_IBAN__c']").value)) {
            this.saveErrorMessage.push('Il campo CIN-IBAN può avere solo caratteri numerici');
        }

        if (this.template.querySelector("[data-id='IbanABI__c']") !== null 
             && this.template.querySelector("[data-id='IbanABI__c']").value !== null
             && this.template.querySelector("[data-id='IbanABI__c']").value.length !== 5) {
            this.saveErrorMessage.push('Il campo ABI deve avere 5 caratteri');
        }
        if (this.template.querySelector("[data-id='IbanABI__c']") !== null 
             && this.template.querySelector("[data-id='IbanABI__c']").value !== null
             && !/^[0-9]+$/.test(this.template.querySelector("[data-id='IbanABI__c']").value)) {
            this.saveErrorMessage.push('Il campo ABI può avere solo caratteri numerici');
        }

        if (this.template.querySelector("[data-id='IbanCAB__c']") !== null 
             && this.template.querySelector("[data-id='IbanCAB__c']").value !== null
             && this.template.querySelector("[data-id='IbanCAB__c']").value.length !== 5) {
            this.saveErrorMessage.push('Il campo CAB deve avere 5 caratteri');
        }
        if (this.template.querySelector("[data-id='IbanCAB__c']") !== null 
             && this.template.querySelector("[data-id='IbanCAB__c']").value !== null
             && !/^[0-9]+$/.test(this.template.querySelector("[data-id='IbanCAB__c']").value)) {
            this.saveErrorMessage.push('Il campo CAB può avere solo caratteri numerici');
        }

        if (this.template.querySelector("[data-id='IbanCodeNumber__c']") !== null 
             && this.template.querySelector("[data-id='IbanCodeNumber__c']").value !== null
             && this.template.querySelector("[data-id='IbanCodeNumber__c']").value.length !== 12) {
            this.saveErrorMessage.push('Il campo Numero Conto deve avere 12 caratteri');
        }
        //check iban fields logic end

        //check required fields start
        if (this.template.querySelector("[data-id='PaymentMethod__c']") !== null 
            && (this.template.querySelector("[data-id='PaymentMethod__c']").value === null || this.template.querySelector("[data-id='PaymentMethod__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Metodo di pagamento, ');
        }

        if (this.template.querySelector("[data-id='BillSendingMethod__c']") !== null 
            && (this.template.querySelector("[data-id='BillSendingMethod__c']").value === null || this.template.querySelector("[data-id='BillSendingMethod__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Modalità invio bolletta, ');
        }

        if (this.template.querySelector("[data-id='InvoiceEmailAddress__c']") !== null 
            && (this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value === null || this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value.trim() === '') 
            && (this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Bolletta per e-mail' || this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Bolletta per e-mail + Carta')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Email Invio Bolletta, ');
        }

        if ( this.template.querySelector("[data-id='BillSendingMethod__c']") !== null &&
             this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Invio tramite PEC' &&
             ( this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']") === null || 
             this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']").value === null ||
             !this.validateEmail(this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']").value) )) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Email PEC invio Bolletta, ');
        }

        if ( this.template.querySelector("[data-id='BillSendingMethod__c']") !== null &&
             this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Invio tramite PEC' &&
             ( this.template.querySelector("[data-id='SendCertifiedEmailConsentDate__c']") === null ||
             this.template.querySelector("[data-id='SendCertifiedEmailConsentDate__c']").value === null ||
             this.template.querySelector("[data-id='SendCertifiedEmailConsentDate__c']").value === '' )) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Data consenso E-mail PEC Invio Bolletta, ');
        }

        if (this.template.querySelector("[data-id='XMLType__c']") !== null 
            && (this.template.querySelector("[data-id='XMLType__c']").value === null || this.template.querySelector("[data-id='XMLType__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Tipo XML, ');
        }

        //check req fields fatturazione elettronica start

        if (this.template.querySelector("[data-id='IbanIsForeign__c']") !== null
            && !this.template.querySelector("[data-id='IbanIsForeign__c']").value
            && this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']") !== null 
            && (this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']").value === null || this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Modalità invio Fatturazione elettronica, ');
        }

        console.log('hdtBillingProfileForm_js - validFields');

        if (this.template.querySelector("[data-id='SubjectCode__c']") !== null 
        && this.template.querySelector("[data-id='SubjectCode__c']").value !== null 
        && this.template.querySelector("[data-id='SubjectCode__c']").value.length !== 7
        && this.template.querySelector("[data-id='SubjectCode__c']").value.length > 0) {
            this.saveErrorMessage.push('Il campo Codice Destinatario deve avere 7 caratteri');
        }

        if ((this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']") !== null 
            && this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']").value === 'XML'
            && this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']").value !== 'Estero')
            && (this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']") !== null && this.template.querySelector("[data-id='SubjectCode__c']") !== null)
            && (this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']").value === null || this.template.querySelector("[data-id='ElectronicInvoiceCertifiedEmailAddress__c']").value === '')
            && (this.template.querySelector("[data-id='SubjectCode__c']").value === null || this.template.querySelector("[data-id='SubjectCode__c']").value === '')) {
            this.saveErrorMessage.push('Devi valorizzare almeno uno dei campi Codice Destinatario o PEC Fatturazione Elettronica');
        }

        // if (this.template.querySelector("[data-id='CIG__c']") !== null 
        //     && (this.template.querySelector("[data-id='CIG__c']").value === null || this.template.querySelector("[data-id='CIG__c']").value === '')) {
        //     concatBillingErrorFields = concatBillingErrorFields.concat('CIG, ');
        // }

        // if (this.template.querySelector("[data-id='CUP__c']") !== null 
        //     && (this.template.querySelector("[data-id='CUP__c']").value === null || this.template.querySelector("[data-id='CUP__c']").value === '')) {
        //     concatBillingErrorFields = concatBillingErrorFields.concat('CUP, ');
        // }

        // if (this.template.querySelector("[data-id='SubjectCodeStartDate__c']") !== null 
        //     && (this.template.querySelector("[data-id='SubjectCodeStartDate__c']").value === null || this.template.querySelector("[data-id='SubjectCodeStartDate__c']").value === '' )) {
        //     concatBillingErrorFields = concatBillingErrorFields.concat('Data inizio Validità Codice Destinatario, ');
        // }
        //check req fields fatturazione elettronica end

        if (this.template.querySelector("[data-id='PaymentMethod__c']").value === 'RID' 
            && this.template.querySelector("[data-id='IbanCIN__c']") !== null 
            && this.template.querySelector("[data-id='IbanCIN__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('CIN, ');
        }

        if (this.template.querySelector("[data-id='PaymentMethod__c']").value === 'RID'
             && this.template.querySelector("[data-id='IbanCIN_IBAN__c']") !== null 
             && this.template.querySelector("[data-id='IbanCIN_IBAN__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('IbanCIN, ');
        }

        if (this.template.querySelector("[data-id='PaymentMethod__c']").value === 'RID' 
            && this.template.querySelector("[data-id='IbanABI__c']") !== null 
            && this.template.querySelector("[data-id='IbanABI__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('ABI, ');
        }

        if (this.template.querySelector("[data-id='PaymentMethod__c']").value === 'RID' 
            && this.template.querySelector("[data-id='IbanCAB__c']") !== null 
            && this.template.querySelector("[data-id='IbanCAB__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('CAB, ');
        }

        if (this.template.querySelector("[data-id='PaymentMethod__c']").value === 'RID' 
            && this.template.querySelector("[data-id='IbanCodeNumber__c']") !== null 
            && this.template.querySelector("[data-id='IbanCodeNumber__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Numero Conto, ');
        }

        if (this.template.querySelector("[data-id='PaymentMethod__c']").value === 'RID' 
            && this.template.querySelector("[data-id='IbanIsForeign__c']").value
            && (this.dataToSubmit['IBAN__c'] === undefined || this.dataToSubmit['IBAN__c'] === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Iban, ');
        }

        if (this.template.querySelector("[data-id='SignatoryType__c']") !== null 
            && (this.template.querySelector("[data-id='SignatoryType__c']").value === '' || this.template.querySelector("[data-id='SignatoryType__c']").value === undefined)
            ) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Tipo Sottoscrittore, ');
        }

        if (this.template.querySelector("[data-id='SignatoryType__c']") !== null 
        && this.template.querySelector("[data-id='SignatoryType__c']").value === 'Pagatore Alternativo'
        && this.template.querySelector("[data-id='OtherPayer__c']") !== null && this.template.querySelector("[data-id='OtherPayer__c']").value === '' ) {
        concatBillingErrorFields = concatBillingErrorFields.concat('Pagatore Alternativo, ');
        } 

        if (this.template.querySelector("[data-id='SignatoryType__c']") !== null 
        && this.template.querySelector("[data-id='SignatoryType__c']").value === 'Legale Rappresentante'
        && this.template.querySelector("[data-id='LegalAgent__c']") !== null 
        && (this.template.querySelector("[data-id='LegalAgent__c']").value === '' || this.template.querySelector("[data-id='LegalAgent__c']").value === null) ) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Legale Rapresentante, ');
        } 

        if (this.template.querySelector("[data-id='BankAccountSignatoryFiscalCode__c']") !== null 
            && (this.template.querySelector("[data-id='BankAccountSignatoryFiscalCode__c']").value === null || this.template.querySelector("[data-id='BankAccountSignatoryFiscalCode__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Codice Fiscale Sottoscrittore CC, ');
        }

        if (this.template.querySelector("[data-id='BankAccountSignatoryFirstName__c']") !== null 
            && (this.template.querySelector("[data-id='BankAccountSignatoryFirstName__c']").value === null || this.template.querySelector("[data-id='BankAccountSignatoryFirstName__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Nome sottoscrittore CC, ');
        }

        if (this.template.querySelector("[data-id='BankAccountSignatoryLastName__c']") !== null 
            && (this.template.querySelector("[data-id='BankAccountSignatoryLastName__c']").value === null || this.template.querySelector("[data-id='BankAccountSignatoryLastName__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Cognome sottoscrittore CC, ');
        }
        //check required fields end
        if (this.template.querySelector("[data-id='BillSendingMethod__c']") !== null 
            && this.template.querySelector("[data-id='BillSendingMethod__c']").value != null && this.template.querySelector("[data-id='BillSendingMethod__c']").value != undefined) {
                if(this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Fatturazione PA' && this.sale.Account__r.Category__c === 'Famiglie'){
                    this.saveErrorMessage.push('Fatturazione PA non è un valore ammissibile per questa tipologia di cliente');
                }
        }
        //validate billing profile fields
        console.log('concatBillingErrorFields: ', concatBillingErrorFields);
        if (concatBillingErrorFields !== '') {

            this.saveErrorMessage.push('Per poter salvare popolare i seguenti campi di billing profile: ' + concatBillingErrorFields.slice(0, -2));
        }
    
        //Validate address
        if(!this.isForeignAddress){
            if (!this.isVerifiedAddress) {
                this.saveErrorMessage.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
            }
        } else {
            let foreignAddressMsg = 'Per poter salvare popolare i seguenti campi di indirizzo: ';

            if (this.dataToSubmit['InvoicingCountry__c'] === undefined || this.dataToSubmit['InvoicingCountry__c'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Stato, ');
            }
            if (this.dataToSubmit['InvoicingProvince__c'] === undefined || this.dataToSubmit['InvoicingProvince__c'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Provincia, ');
            }
            if (this.dataToSubmit['InvoicingCity__c'] === undefined || this.dataToSubmit['InvoicingCity__c'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Comune, ');
            }
            if (this.dataToSubmit['InvoicingStreetName__c'] === undefined || this.dataToSubmit['InvoicingStreetName__c'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Via, ');
            }
            if (this.dataToSubmit['InvoicingStreetNumber__c'] === undefined || this.dataToSubmit['InvoicingStreetNumber__c'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Civico, ');
            }
            if (this.dataToSubmit['InvoicingPostalCode__c'] === undefined || this.dataToSubmit['InvoicingPostalCode__c'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('CAP, ');
            }

            if (concatAddressErrorFields !== '') {
                this.saveErrorMessage.push('Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2));
            }
        }

        console.log('Validation END: ', this.saveErrorMessage.length === 0);

        if(this.saveErrorMessage.length === 0){
            return true;
        }else{
            return this.saveErrorMessage[0];
        }

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
        if(!this.dataToSubmit['InvoicingCountry__c']){
            this.dataToSubmit['InvoicingCountry__c'] = 'ITALIA';
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

        if(this.dataToSubmit['InvoicingCityCode__c'] != this.wrapAddressObject['Codice Comune SAP']){
            this.dataToSubmit['InvoicingCityCode__c'] = this.wrapAddressObject['Codice Comune SAP'];
        }
        if(this.dataToSubmit['InvoicingStreetCode__c'] != this.wrapAddressObject['Codice Via Stradario SAP']){
            this.dataToSubmit['InvoicingStreetCode__c'] = this.wrapAddressObject['Codice Via Stradario SAP'];
        }

        if(this.dataToSubmit['InvoicingPlace__c'] != this.wrapAddressObject['Localita']){
            this.dataToSubmit['InvoicingPlace__c'] = this.wrapAddressObject['Localita'];
        }
        if(this.dataToSubmit['InvoicingPlaceCode__c'] != this.wrapAddressObject['Codice Localita']){
            this.dataToSubmit['InvoicingPlaceCode__c'] = this.wrapAddressObject['Codice Localita'];
        }
        
        this.isVerifiedAddress = this.wrapAddressObject['Flag Verificato'];
        this.isForeignAddress = this.wrapAddressObject['Indirizzo Estero'];

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
        if(this.cloneObject['InvoicingStreetNumberExtension__c'] != undefined){
            this.wrapAddressObject['Estens.Civico'] = this.cloneObject['InvoicingStreetNumberExtension__c'];
        }
        if(this.cloneObject['InvoicingStreetNumber__c'] != undefined){
            this.wrapAddressObject['Civico'] = this.cloneObject['InvoicingStreetNumber__c'];
        }

        if(this.cloneObject['InvoicingCityCode__c'] != undefined){
             this.wrapAddressObject['Codice Comune SAP'] = this.cloneObject['InvoicingCityCode__c'];
        }
        if(this.cloneObject['InvoicingStreetCode__c'] != undefined){
             this.wrapAddressObject['Codice Via Stradario SAP'] = this.cloneObject['InvoicingStreetCode__c'];
        }

        if(this.cloneObject['InvoicingPlace__c'] != undefined){
            this.wrapAddressObject['Localita'] = this.cloneObject['InvoicingPlace__c'];
        }
        if(this.cloneObject['InvoicingPlaceCode__c'] != undefined){
            this.wrapAddressObject['Codice Localita'] = this.cloneObject['InvoicingPlaceCode__c'];
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

            console.log('Error: ', error);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleSaveEvent(){

        this.handleWrapAddressObject();

        if(this.validFields() === true){
            this.saveErrorMessage = [];

            this.dataToSubmit['Account__c'] = this.accountId;
            this.dataToSubmit['IbanCountry__c'] = this.dataToSubmit['PaymentMethod__c'] == 'RID' ? 'IT' : '';

            this.loading = true;
            createBillingProfile({billingProfile: this.dataToSubmit}).then(data =>{
                this.loading = false;
                this.recordId = '';
                this.isVerifiedAddress = false;
                this.isForeignAddress = false;

                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Metodo di pagamento creato con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
                this.dispatchEvent(new CustomEvent('newbillingprofile'));
                this.dispatchEvent(new CustomEvent('newbillingprofilerecord',{detail:data.Id}));
                this.handleCancelEvent();
                
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
        } else {
            console.log('Errors: ',this.saveErrorMessage);
            this.saveErrorMessage.forEach(message => {
                const saveToastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(saveToastErrorMessage);
            });
            this.saveErrorMessage = [];
        }

    }

    connectedCallback(){
        if(this.recordId !== undefined && this.recordId !== ''){
            this.getClone();
        }
        console.log('connectedCallback sale billing form: ', JSON.stringify(this.sale));
    }
}