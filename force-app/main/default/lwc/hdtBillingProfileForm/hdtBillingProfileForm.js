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
    @track fatturazioneElettronicaFields = [];
    isfatturazioneElettronicaVisible = false;
    @track tipologiaIntestatarioFields = [];
    wrapAddressObject = {};
    dataToSubmit = {};
    saveErrorMessage = [];
    cloneObject = {};
    isVerifiedAddress = false;
    isForeignAddress = false;
    signatoryTypeIsVisible = false;

    get signatoryTypeOptions() {
        let options = [
            { label: 'Pagatore Alternativo', value: 'Pagatore Alternativo' }
        ];

        if (this.sale.Account__r.Category__c === 'Famiglie' 
            || this.sale.Account__r.Category__c === 'Parti comuni'
            || this.sale.Account__r.Category__c === 'Ditta individuale') {
            options.push({ label: 'Stesso Sottoscrittore', value: 'Stesso Sottoscrittore' });
        } else if (this.sale.Account__r.Category__c !== 'Famiglie' 
                    && this.sale.Account__r.Category__c !== 'Parti comuni'
                    && this.sale.Account__r.Category__c !== 'Ditta individuale') {
            options.push({ label: 'Legale Rappresentante', value: 'Legale Rappresentante' });
        }

        return options;
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
                        case 'XMLType__c':
                            value = 'Sintetico';
                            console.log('XMLType__c default: ', value);
                            break;
                        case 'IbanCountry__c':
                            value = 'IT';
                            disable = true;
                            break;
                        case 'BillSendingMethod__c':
                            required = true;
                            break;
                        case 'SubjectCode__c':
                            required = true;
                            break;
                        case 'ElectronicInvoicingMethod__c':
                            required = true;
                            break;
                        case 'XMLType__c':
                            required = true;
                            break;
                        case 'CIG__c':
                            required = true;
                            break;
                        case 'CUP__c':
                            required = true;
                            break;
                        case 'SubjectCodeStartDate__c':
                            required = true;
                            break;
                        case 'SignatoryType__c':
                            required = true;
                            break;
                        case 'InvoiceEmailAddress__c':
                            required = true;
                            break;
                        default:
                            break;
                    }

                    this.fields.push({
                        fieldName: el,
                        visibility: (el !== 'InvoiceCertifiedEmailAddress__c' && el !== 'SendCertifiedEmailConsentDate__c' && el !== 'IBAN__c'),
                        disabled: disable,
                        value: value,
                        required: required
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

                    let disable = false;
                    let required = false;

                    switch (el) {
                        case 'SignatoryType__c':
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
        let concatBillingErrorFields = '';
        let concatAddressErrorFields = '';

        //check iban fields logic start
        if (this.template.querySelector("[data-id='IbanCIN__c']") !== null 
            && this.template.querySelector("[data-id='IbanCIN__c']").value !== null
            && this.template.querySelector("[data-id='IbanCIN__c']").value.length !== 1) {
            this.saveErrorMessage.push('Il campo CIN deve avere 1 carattere');
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
            && (this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value === null || this.template.querySelector("[data-id='InvoiceEmailAddress__c']").value === '') 
            && (this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Bolletta per e-mail' || this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Bolletta per e-mail + Carta')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Email Invio Bolletta, ');
        }

        if (this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']") !== null 
            && this.template.querySelector("[data-id='InvoiceCertifiedEmailAddress__c']").value === null 
            && this.template.querySelector("[data-id='BillSendingMethod__c']").value === 'Invio tramite PEC') {
            concatBillingErrorFields = concatBillingErrorFields.concat('Email PEC invio Bolletta, ');
        }

        if (this.template.querySelector("[data-id='XMLType__c']") !== null 
            && (this.template.querySelector("[data-id='XMLType__c']").value === null || this.template.querySelector("[data-id='XMLType__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Tipo XML, ');
        }

        //check req fields fatturazione elettronica start
        /*if (this.template.querySelector("[data-id='SubjectCode__c']") !== null 
            && (this.template.querySelector("[data-id='SubjectCode__c']").value === null || this.template.querySelector("[data-id='SubjectCode__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Codice Destinatario, ');
        }

        if (this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']") !== null 
            && (this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']").value === null || this.template.querySelector("[data-id='ElectronicInvoicingMethod__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Modalità invio Fatturazione elettronica, ');
        }

        if (this.template.querySelector("[data-id='CIG__c']") !== null 
            && (this.template.querySelector("[data-id='CIG__c']").value === null || this.template.querySelector("[data-id='CIG__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('CIG, ');
        }

        if (this.template.querySelector("[data-id='CUP__c']") !== null 
            && (this.template.querySelector("[data-id='CUP__c']").value === null || this.template.querySelector("[data-id='CUP__c']").value === '')) {
            concatBillingErrorFields = concatBillingErrorFields.concat('CUP, ');
        }

        if (this.template.querySelector("[data-id='SubjectCodeStartDate__c']") !== null 
            && (this.template.querySelector("[data-id='SubjectCodeStartDate__c']").value === null || this.template.querySelector("[data-id='SubjectCodeStartDate__c']").value === '' )) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Data inizio Validità Codice Destinatario, ');
        }*/
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
            && this.template.querySelector("[data-id='SignatoryType__c']").value === '') {
            concatBillingErrorFields = concatBillingErrorFields.concat('Tipo Sottoscrittore, ');
        }

        if (this.template.querySelector("[data-id='BankAccountSignatoryFiscalCode__c']") !== null 
            && this.template.querySelector("[data-id='BankAccountSignatoryFiscalCode__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Codice Fiscale Sottoscrittore CC, ');
        }

        if (this.template.querySelector("[data-id='BankAccountSignatoryFirstName__c']") !== null 
            && this.template.querySelector("[data-id='BankAccountSignatoryFirstName__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Nome sottoscrittore CC, ');
        }

        if (this.template.querySelector("[data-id='BankAccountSignatoryLastName__c']") !== null 
            && this.template.querySelector("[data-id='BankAccountSignatoryLastName__c']").value === null) {
            concatBillingErrorFields = concatBillingErrorFields.concat('Cognome sottoscrittore CC, ');
        }
        //check required fields end
        
        //validate billing profile fields
        console.log('concatBillingErrorFields: ', concatBillingErrorFields);
        if (concatBillingErrorFields !== '') {
            
            isValid = false;
            this.saveErrorMessage.push('Per poter salvare popolare i seguenti campi di billing profile: ' + concatBillingErrorFields.slice(0, -2));
        }
    
        //Validate address
        if(!this.isForeignAddress){
            if (!this.isVerifiedAddress) {
                isValid = false;
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
                isValid = false;
                this.saveErrorMessage.push('Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2));
            }
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

        this.handleWrapAddressObject();

        if(this.validFields()){

            this.dataToSubmit['Account__c'] = this.accountId;
            this.dataToSubmit['IbanCountry__c'] = 'IT';

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